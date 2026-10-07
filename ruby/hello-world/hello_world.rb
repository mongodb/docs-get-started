require 'json'
require 'mongo'

# A few sample product documents seeded by this app so you can run it
# without loading an external dataset.
SAMPLE_PRODUCTS = [
  {
    name: 'Wireless Mouse',
    category: 'Electronics',
    price: BSON::Decimal128.new('24.99'),
    tags: ['wireless', 'usb', 'ergonomic']
  },
  {
    name: 'Standing Desk',
    category: 'Furniture',
    price: BSON::Decimal128.new('349.99'),
    tags: ['adjustable', 'office']
  },
  {
    name: 'Noise-Cancelling Headphones',
    category: 'Electronics',
    price: BSON::Decimal128.new('199.99'),
    tags: ['bluetooth', 'wireless', 'over-ear']
  }
].freeze

uri = ENV['MONGODB_URI']
if uri.nil? || uri.empty?
  abort 'Set the MONGODB_URI environment variable before running this app.'
end

client = Mongo::Client.new(uri)

begin
  database = client.use('get_started')
  products = database[:products]

  # Seed the collection so the app has data to query. Clearing the
  # collection first keeps results consistent across repeated runs.
  products.delete_many({})
  products.insert_many(SAMPLE_PRODUCTS)

  query = { name: 'Wireless Mouse' }
  product = products.find(query).first

  # The driver returns a Decimal128 as a BigDecimal, which doesn't serialize
  # as "$numberDecimal". Convert it back so the output matches the other
  # sample applications.
  product['price'] = BSON::Decimal128.new(product['price'])

  puts product.to_extended_json(mode: :relaxed)
ensure
  client.close
end

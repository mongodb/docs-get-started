using MongoDB.Bson;
using MongoDB.Driver;

// A few sample product documents seeded by this app so you can run it
// without loading an external dataset.
var sampleProducts = new[]
{
    new BsonDocument
    {
        { "name", "Wireless Mouse" },
        { "category", "Electronics" },
        { "price", 24.99m },
        { "tags", new BsonArray { "wireless", "usb", "ergonomic" } }
    },
    new BsonDocument
    {
        { "name", "Standing Desk" },
        { "category", "Furniture" },
        { "price", 349.99m },
        { "tags", new BsonArray { "adjustable", "office" } }
    },
    new BsonDocument
    {
        { "name", "Noise-Cancelling Headphones" },
        { "category", "Electronics" },
        { "price", 199.99m },
        { "tags", new BsonArray { "bluetooth", "wireless", "over-ear" } }
    }
};

var uri = Environment.GetEnvironmentVariable("MONGODB_URI");
var client = new MongoClient(uri);

var database = client.GetDatabase("get_started");
var products = database.GetCollection<BsonDocument>("products");

// Seed the collection so the app has data to query. Clearing the
// collection first keeps results consistent across repeated runs.
products.DeleteMany(Builders<BsonDocument>.Filter.Empty);
products.InsertMany(sampleProducts);

var filter = Builders<BsonDocument>.Filter.Eq("name", "Wireless Mouse");
var product = products.Find(filter).FirstOrDefault();

// The .NET driver's JSON writer pads braces and colons, and wraps a decimal
// price in a $numberDecimal object. Format the document by hand so the output
// matches the other sample applications.
var tags = string.Join(", ", product["tags"].AsBsonArray.Select(tag => $"\"{tag}\""));
Console.WriteLine(
    "{\"_id\": {\"$oid\": \"" + product["_id"] + "\"}, " +
    "\"name\": \"" + product["name"] + "\", " +
    "\"category\": \"" + product["category"] + "\", " +
    "\"price\": " + product["price"] + ", " +
    "\"tags\": [" + tags + "]}");

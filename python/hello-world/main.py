import os

from bson.decimal128 import Decimal128
from bson.json_util import dumps
from pymongo import MongoClient

# A few sample product documents seeded by this app so you can run it
# without loading an external dataset.
sample_products = [
    {
        "name": "Wireless Mouse",
        "category": "Electronics",
        "price": Decimal128("24.99"),
        "tags": ["wireless", "usb", "ergonomic"],
    },
    {
        "name": "Standing Desk",
        "category": "Furniture",
        "price": Decimal128("349.99"),
        "tags": ["adjustable", "office"],
    },
    {
        "name": "Noise-Cancelling Headphones",
        "category": "Electronics",
        "price": Decimal128("199.99"),
        "tags": ["bluetooth", "wireless", "over-ear"],
    },
]


def run_get_started():
    uri = os.environ.get("MONGODB_URI")
    if not uri or not uri.strip():
        raise SystemExit("Set the MONGODB_URI environment variable before running this app.")

    client = MongoClient(uri)

    try:
        database = client["get_started"]
        products = database["products"]

        # Seed the collection so the app has data to query. Clearing the
        # collection first keeps results consistent across repeated runs.
        products.delete_many({})
        products.insert_many(sample_products)

        query = {"name": "Wireless Mouse"}
        product = products.find_one(query)
        if product is None:
            raise SystemExit("No product found matching the query.")

        # Serialize as relaxed Extended JSON so the ObjectId keeps its
        # "$oid" wrapper and the Decimal128 price keeps its
        # "$numberDecimal" wrapper.
        print(dumps(product))
    finally:
        client.close()


if __name__ == "__main__":
    run_get_started()

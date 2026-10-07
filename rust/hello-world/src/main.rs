use mongodb::Client;
use mongodb::bson::Bson;
use mongodb::bson::Document;
use mongodb::bson::doc;

// A few sample product documents seeded by this app so you can run it
// without loading an external dataset.
fn sample_products() -> Vec<Document> {
    vec![
        doc! { "name": "Wireless Mouse", "category": "Electronics", "price": 24.99, "tags": ["wireless", "usb", "ergonomic"] },
        doc! { "name": "Standing Desk", "category": "Furniture", "price": 349.99, "tags": ["adjustable", "office"] },
        doc! { "name": "Noise-Cancelling Headphones", "category": "Electronics", "price": 199.99, "tags": ["bluetooth", "wireless", "over-ear"] },
    ]
}

#[tokio::main]
async fn main() -> mongodb::error::Result<()> {
    let uri = std::env::var("MONGODB_URI")
        .ok()
        .filter(|uri| !uri.trim().is_empty())
        .expect("Set the MONGODB_URI environment variable before running this app.");

    let client = Client::with_uri_str(&uri).await?;

    let database = client.database("get_started");
    let products = database.collection::<Document>("products");

    // Seed the collection so the app has data to query. Clearing the
    // collection first keeps results consistent across repeated runs.
    products.delete_many(doc! {}).await?;
    products.insert_many(sample_products()).await?;

    let product = products
        .find_one(doc! { "name": "Wireless Mouse" })
        .await?
        .expect("No product with the name 'Wireless Mouse' was found");

    // serde_json renders the Extended JSON compactly. Insert spaces after
    // colons and commas so the output matches the other sample applications.
    let ejson = Bson::from(product).into_relaxed_extjson();
    println!("{}", ejson.to_string().replace("\":", "\": ").replace(",\"", ", \""));

    Ok(())
}

import static com.mongodb.client.model.Filters.eq;

import com.mongodb.client.MongoClient;
import com.mongodb.client.MongoClients;
import com.mongodb.client.MongoCollection;
import com.mongodb.client.MongoDatabase;
import java.util.List;
import org.bson.Document;

public class HelloWorld {

    // A few sample product documents seeded by this app so you can run
    // it without loading an external dataset.
    private static final List<Document> SAMPLE_PRODUCTS = List.of(
        new Document("name", "Wireless Mouse")
            .append("category", "Electronics")
            .append("price", 24.99)
            .append("tags", List.of("wireless", "usb", "ergonomic")),
        new Document("name", "Standing Desk")
            .append("category", "Furniture")
            .append("price", 349.99)
            .append("tags", List.of("adjustable", "office")),
        new Document("name", "Noise-Cancelling Headphones")
            .append("category", "Electronics")
            .append("price", 199.99)
            .append("tags", List.of("bluetooth", "wireless", "over-ear"))
    );

    public static void main(String[] args) {
        String uri = System.getenv("MONGODB_URI");
        if (uri == null || uri.isBlank()) {
            System.err.println("Set the MONGODB_URI environment variable before running this app.");
            System.exit(1);
        }

        try (MongoClient client = MongoClients.create(uri)) {
            MongoDatabase database = client.getDatabase("get_started");
            MongoCollection<Document> products = database.getCollection("products");

            // Seed the collection so the app has data to query. Clearing
            // the collection first keeps results consistent across
            // repeated runs.
            products.deleteMany(new Document());
            products.insertMany(SAMPLE_PRODUCTS);

            Document product = products.find(eq("name", "Wireless Mouse")).first();
            if (product == null) {
                System.err.println("No product found matching the query.");
                System.exit(1);
            }
            System.out.println(product.toJson());
        }
    }
}

import static com.mongodb.client.model.Filters.eq;

import com.mongodb.client.result.DeleteResult;
import com.mongodb.client.result.InsertManyResult;
import com.mongodb.reactivestreams.client.MongoClient;
import com.mongodb.reactivestreams.client.MongoClients;
import com.mongodb.reactivestreams.client.MongoCollection;
import com.mongodb.reactivestreams.client.MongoDatabase;
import java.math.BigDecimal;
import java.util.List;
import org.bson.Document;
import org.bson.types.Decimal128;
import reactor.core.publisher.Mono;

public class HelloWorld {

    // A few sample product documents seeded by this app so you can run
    // it without loading an external dataset.
    private static final List<Document> SAMPLE_PRODUCTS = List.of(
        new Document("name", "Wireless Mouse")
            .append("category", "Electronics")
            .append("price", new Decimal128(new BigDecimal("24.99")))
            .append("tags", List.of("wireless", "usb", "ergonomic")),
        new Document("name", "Standing Desk")
            .append("category", "Furniture")
            .append("price", new Decimal128(new BigDecimal("349.99")))
            .append("tags", List.of("adjustable", "office")),
        new Document("name", "Noise-Cancelling Headphones")
            .append("category", "Electronics")
            .append("price", new Decimal128(new BigDecimal("199.99")))
            .append("tags", List.of("bluetooth", "wireless", "over-ear"))
    );

    public static void main(String[] args) {
        String uri = System.getenv("MONGODB_URI");
        if (uri == null || uri.isEmpty()) {
            System.err.println("Set the MONGODB_URI environment variable to your connection string.");
            System.exit(1);
        }

        try (MongoClient client = MongoClients.create(uri)) {
            run(client);
        } catch (RuntimeException e) {
            // The try-with-resources closes the client before the process
            // exits, so the client is shut down cleanly on error paths.
            System.err.println(e.getMessage());
            System.exit(1);
        }
    }

    private static void run(MongoClient client) {
        MongoDatabase database = client.getDatabase("get_started");
        MongoCollection<Document> products = database.getCollection("products");

        // Each reactive driver call returns a Publisher. Wrapping it in a
        // Reactor Mono and calling block() runs the operation and waits for
        // it to complete before moving on.

        // Seed the collection so the app has data to query. Clearing the
        // collection first keeps results consistent across repeated runs.
        DeleteResult deleteResult = Mono.from(products.deleteMany(new Document())).block();
        if (deleteResult == null || !deleteResult.wasAcknowledged()) {
            throw new IllegalStateException("Failed to clear the products collection.");
        }

        InsertManyResult insertResult = Mono.from(products.insertMany(SAMPLE_PRODUCTS)).block();
        if (insertResult == null || !insertResult.wasAcknowledged()) {
            throw new IllegalStateException("Failed to insert the sample products.");
        }

        Document product = Mono.from(products.find(eq("name", "Wireless Mouse")).first()).block();
        if (product == null) {
            throw new IllegalStateException("No product found matching the query.");
        }
        System.out.println(product.toJson());
    }
}

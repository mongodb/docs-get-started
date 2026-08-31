import com.mongodb.client.model.Filters.eq
import com.mongodb.kotlin.client.coroutine.MongoClient
import kotlin.system.exitProcess
import kotlinx.coroutines.flow.firstOrNull
import kotlinx.coroutines.runBlocking
import org.bson.Document

// A few sample product documents seeded by this app so you can run
// it without loading an external dataset.
private val SAMPLE_PRODUCTS = listOf(
    Document("name", "Wireless Mouse")
        .append("category", "Electronics")
        .append("price", 24.99)
        .append("tags", listOf("wireless", "usb", "ergonomic")),
    Document("name", "Standing Desk")
        .append("category", "Furniture")
        .append("price", 349.99)
        .append("tags", listOf("adjustable", "office")),
    Document("name", "Noise-Cancelling Headphones")
        .append("category", "Electronics")
        .append("price", 199.99)
        .append("tags", listOf("bluetooth", "wireless", "over-ear"))
)

fun main() = runBlocking {
    val uri = System.getenv("MONGODB_URI")
    if (uri.isNullOrEmpty()) {
        System.err.println("Set the MONGODB_URI environment variable to your connection string.")
        exitProcess(1)
    }

    MongoClient.create(uri).use { client ->
        val database = client.getDatabase("get_started")
        val products = database.getCollection<Document>("products")

        // The coroutine driver exposes suspending functions, so these
        // calls run inside the runBlocking coroutine.

        // Seed the collection so the app has data to query. Clearing
        // the collection first keeps results consistent across
        // repeated runs.
        val deleteResult = products.deleteMany(Document())
        if (!deleteResult.wasAcknowledged()) {
            System.err.println("Failed to clear the products collection.")
            exitProcess(1)
        }

        val insertResult = products.insertMany(SAMPLE_PRODUCTS)
        if (!insertResult.wasAcknowledged()) {
            System.err.println("Failed to insert the sample products.")
            exitProcess(1)
        }

        val product = products.find(eq("name", "Wireless Mouse")).firstOrNull()
        if (product == null) {
            System.err.println("No product found matching the query.")
            exitProcess(1)
        }
        println(product.toJson())
    }
}

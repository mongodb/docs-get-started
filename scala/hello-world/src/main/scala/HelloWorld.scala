import org.mongodb.scala._
import org.mongodb.scala.model.Filters.equal

import Helpers._

object HelloWorld {

  // A few sample product documents seeded by this app so you can run it
  // without loading an external dataset.
  private val sampleProducts = Seq(
    Document(
      "name" -> "Wireless Mouse",
      "category" -> "Electronics",
      "price" -> 24.99,
      "tags" -> Seq("wireless", "usb", "ergonomic")
    ),
    Document(
      "name" -> "Standing Desk",
      "category" -> "Furniture",
      "price" -> 349.99,
      "tags" -> Seq("adjustable", "office")
    ),
    Document(
      "name" -> "Noise-Cancelling Headphones",
      "category" -> "Electronics",
      "price" -> 199.99,
      "tags" -> Seq("bluetooth", "wireless", "over-ear")
    )
  )

  def main(args: Array[String]): Unit = {
    val uri = sys.env.get("MONGODB_URI")
      .filter(_.trim.nonEmpty)
      .getOrElse {
        System.err.println("Set the MONGODB_URI environment variable before running this app.")
        sys.exit(1)
      }

    val client = MongoClient(uri)
    try {
      val database = client.getDatabase("get_started")
      val products = database.getCollection[Document]("products")

      // Seed the collection so the app has data to query. Clearing the
      // collection first keeps results consistent across repeated runs.
      products.deleteMany(Document()).headResult()
      products.insertMany(sampleProducts).headResult()

      val product = products.find(equal("name", "Wireless Mouse")).results().headOption.getOrElse {
        System.err.println("No product found matching the query.")
        sys.exit(1)
      }
      println(product.toJson())
    } finally {
      client.close()
    }
  }
}

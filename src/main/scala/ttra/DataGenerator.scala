package ttra

import org.apache.spark.SparkContext
import org.apache.spark.sql.SQLContext

import scala.util.Random

case class Person(age: Int, name: String, location: String)

object DataGenerator {

  def name(rand: Random): String = List.fill(5)("abcdefghijklmnopqrstuvwxyz".toList(rand.nextInt(25))).mkString

  def location(rand: Random): String = rand.nextInt(12) match {
    case 1 | 2 | 3 | 4 => "London"
    case 0 | 5 | 6 => "Manchester"
    case 7 => "Norwich"
    case 8 => "Leeds"
    case 9 => "Reading"
    case 10 => "York"
    case 11 => "Bath"
  }

  def age(rand: Random): Int = (rand.nextGaussian() * 20 + 40).toInt

  def apply(sc: SparkContext, sqlContext: SQLContext, tableName: String = "people"): Unit = {
    import sqlContext.implicits._

    val rand: Random = new Random()

    val people =
      List.fill(10000)(Person(age(rand), name(rand), location(rand)))
      .filter(p => 18 <= p.age && p.age <= 75)

    println("Generated " + people.size + " random people")

    sc.makeRDD[Person](
      people
    )
    .toDF()
    .createOrReplaceTempView(tableName)
  }
}

---
name: scala-developer
description: "Expert Scala development including functional programming, Akka, Apache Spark, and big data processing"
---

# Scala Developer

## Overview

Master Scala for functional programming, concurrent systems with Akka, and big data processing with Apache Spark.

## When to Use This Skill

- Use when building Spark applications
- Use when functional programming needed
- Use when JVM with better syntax
- Use when big data processing

## How It Works

### Step 1: Scala Fundamentals

```scala
// Immutable by default
val name: String = "John"
var counter: Int = 0

// Case classes (immutable data)
case class User(id: Long, name: String, email: String)

val user = User(1, "John", "john@email.com")
val updatedUser = user.copy(name = "Jane")

// Pattern matching
def describe(x: Any): String = x match {
  case i: Int if i > 0 => s"Positive integer: $i"
  case s: String => s"String: $s"
  case User(id, name, _) => s"User $name with id $id"
  case list: List[_] => s"List with ${list.length} elements"
  case _ => "Unknown"
}

// Option handling
def findUser(id: Long): Option[User] = {
  users.find(_.id == id)
}

findUser(1) match {
  case Some(user) => println(s"Found: ${user.name}")
  case None => println("Not found")
}

// For comprehensions
val result = for {
  user <- findUser(1)
  profile <- findProfile(user.id)
  settings <- getSettings(profile.id)
} yield UserWithSettings(user, settings)

// Higher-order functions
val numbers = List(1, 2, 3, 4, 5)
val doubled = numbers.map(_ * 2)
val evens = numbers.filter(_ % 2 == 0)
val sum = numbers.reduce(_ + _)
```

### Step 2: Collections & FP

```scala
// Immutable collections
val list = List(1, 2, 3)
val set = Set("a", "b", "c")
val map = Map("a" -> 1, "b" -> 2)

// Collection operations
val users = List(
  User(1, "Alice", "alice@email.com"),
  User(2, "Bob", "bob@email.com"),
  User(3, "Charlie", "charlie@email.com")
)

val names = users.map(_.name)
val activeUsers = users.filter(_.isActive)
val grouped = users.groupBy(_.department)
val sorted = users.sortBy(_.name)

// Flatmap and chaining
val orders = users.flatMap(_.orders)
  .filter(_.status == "completed")
  .groupBy(_.category)
  .mapValues(_.map(_.total).sum)

// Futures for async
import scala.concurrent.Future
import scala.concurrent.ExecutionContext.Implicits.global

def fetchUser(id: Long): Future[User] = Future {
  // async operation
  database.findUser(id)
}

val userFuture = for {
  user <- fetchUser(1)
  orders <- fetchOrders(user.id)
} yield UserWithOrders(user, orders)

userFuture.onComplete {
  case Success(result) => println(result)
  case Failure(ex) => println(s"Error: ${ex.getMessage}")
}
```

### Step 3: Akka Actors

```scala
import akka.actor.{Actor, ActorSystem, Props}

// Define messages
case class SendMessage(to: String, content: String)
case class MessageReceived(from: String, content: String)

// Actor implementation
class ChatActor extends Actor {
  def receive: Receive = {
    case SendMessage(to, content) =>
      println(s"Sending to $to: $content")
      sender() ! MessageReceived(self.path.name, content)
      
    case MessageReceived(from, content) =>
      println(s"Received from $from: $content")
  }
}

// Actor system
val system = ActorSystem("ChatSystem")
val alice = system.actorOf(Props[ChatActor], "alice")
val bob = system.actorOf(Props[ChatActor], "bob")

alice ! SendMessage("bob", "Hello!")

// Typed Actors (Akka Typed)
import akka.actor.typed.{ActorRef, Behavior}
import akka.actor.typed.scaladsl.Behaviors

object Counter {
  sealed trait Command
  case class Increment(replyTo: ActorRef[Int]) extends Command
  case object Reset extends Command

  def apply(count: Int = 0): Behavior[Command] = 
    Behaviors.receive { (context, message) =>
      message match {
        case Increment(replyTo) =>
          val newCount = count + 1
          replyTo ! newCount
          apply(newCount)
        case Reset =>
          apply(0)
      }
    }
}
```

### Step 4: Apache Spark

```scala
import org.apache.spark.sql.SparkSession
import org.apache.spark.sql.functions._

val spark = SparkSession.builder()
  .appName("DataAnalysis")
  .master("local[*]")
  .getOrCreate()

import spark.implicits._

// Read data
val df = spark.read
  .option("header", "true")
  .option("inferSchema", "true")
  .csv("data/sales.csv")

// Transformations
val result = df
  .filter($"amount" > 100)
  .groupBy($"category", $"region")
  .agg(
    sum($"amount").as("total_sales"),
    count("*").as("order_count"),
    avg($"amount").as("avg_order")
  )
  .orderBy($"total_sales".desc)

// Write results
result.write
  .mode("overwrite")
  .parquet("output/sales_summary")

// Dataset API (type-safe)
case class Sale(category: String, amount: Double, region: String)

val sales: Dataset[Sale] = df.as[Sale]
val categoryTotals = sales
  .groupByKey(_.category)
  .mapGroups { (category, sales) =>
    (category, sales.map(_.amount).sum)
  }
```

## Best Practices

### ✅ Do This

- ✅ Prefer immutability
- ✅ Use case classes
- ✅ Leverage pattern matching
- ✅ Use Option over null
- ✅ Type everything explicitly

### ❌ Avoid This

- ❌ Don't use mutable state
- ❌ Don't ignore compiler warnings
- ❌ Don't overuse implicits
- ❌ Don't block in actors

## Related Skills

- `@senior-data-engineer` - Data pipelines
- `@big-data-engineer` - Big data processing

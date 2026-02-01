---
name: mongodb-developer
description: "Expert MongoDB development including schema design, aggregation pipelines, indexing strategies, replication, and performance optimization"
---

# MongoDB Developer

## Overview

Master MongoDB development including document modeling, aggregation framework, indexing, replication, sharding, and performance tuning.

## When to Use This Skill

- Use when designing MongoDB schemas
- Use when building aggregation pipelines
- Use when optimizing MongoDB queries
- Use when setting up MongoDB clusters

## How It Works

### Step 1: Document Modeling

```javascript
// One-to-Few: Embed
{
  _id: ObjectId("..."),
  name: "John Doe",
  email: "john@example.com",
  addresses: [
    { type: "home", city: "Jakarta", zip: "12345" },
    { type: "work", city: "Bandung", zip: "40123" }
  ]
}

// One-to-Many: Reference
// users collection
{
  _id: ObjectId("user1"),
  name: "John Doe"
}

// orders collection
{
  _id: ObjectId("order1"),
  user_id: ObjectId("user1"),  // Reference
  items: [...],
  total: 150000
}

// Many-to-Many: Array of references
{
  _id: ObjectId("..."),
  title: "MongoDB Guide",
  author_ids: [
    ObjectId("author1"),
    ObjectId("author2")
  ]
}
```

### Step 2: Aggregation Pipelines

```javascript
// Complex aggregation
db.orders.aggregate([
  // Match stage
  { $match: {
    status: "completed",
    createdAt: { $gte: ISODate("2024-01-01") }
  }},
  
  // Lookup (join)
  { $lookup: {
    from: "users",
    localField: "user_id",
    foreignField: "_id",
    as: "user"
  }},
  { $unwind: "$user" },
  
  // Group by month
  { $group: {
    _id: {
      year: { $year: "$createdAt" },
      month: { $month: "$createdAt" },
      category: "$category"
    },
    totalRevenue: { $sum: "$total" },
    orderCount: { $sum: 1 },
    avgOrderValue: { $avg: "$total" }
  }},
  
  // Sort and format
  { $sort: { "_id.year": -1, "_id.month": -1 } },
  
  // Project final shape
  { $project: {
    _id: 0,
    period: {
      $concat: [
        { $toString: "$_id.year" }, "-",
        { $toString: "$_id.month" }
      ]
    },
    category: "$_id.category",
    totalRevenue: { $round: ["$totalRevenue", 2] },
    orderCount: 1,
    avgOrderValue: { $round: ["$avgOrderValue", 2] }
  }}
])
```

### Step 3: Indexing Strategies

```javascript
// Single field index
db.users.createIndex({ email: 1 }, { unique: true })

// Compound index (order matters!)
db.orders.createIndex({ user_id: 1, createdAt: -1 })

// Text index for search
db.products.createIndex({ name: "text", description: "text" })

// Partial index (conditional)
db.orders.createIndex(
  { status: 1 },
  { partialFilterExpression: { status: "pending" } }
)

// TTL index (auto-delete)
db.sessions.createIndex(
  { createdAt: 1 },
  { expireAfterSeconds: 3600 }
)

// Check query performance
db.orders.find({ user_id: ObjectId("...") }).explain("executionStats")

// Index usage stats
db.orders.aggregate([{ $indexStats: {} }])
```

### Step 4: Node.js Integration

```javascript
const { MongoClient, ObjectId } = require('mongodb');

class UserRepository {
  constructor(db) {
    this.collection = db.collection('users');
  }

  async findById(id) {
    return this.collection.findOne({ _id: new ObjectId(id) });
  }

  async findByEmail(email) {
    return this.collection.findOne({ email });
  }

  async create(userData) {
    const result = await this.collection.insertOne({
      ...userData,
      createdAt: new Date(),
      updatedAt: new Date()
    });
    return { _id: result.insertedId, ...userData };
  }

  async update(id, updates) {
    const result = await this.collection.findOneAndUpdate(
      { _id: new ObjectId(id) },
      { 
        $set: { ...updates, updatedAt: new Date() }
      },
      { returnDocument: 'after' }
    );
    return result.value;
  }

  async search(query, { page = 1, limit = 10 } = {}) {
    const skip = (page - 1) * limit;
    
    const [users, total] = await Promise.all([
      this.collection
        .find(query)
        .sort({ createdAt: -1 })
        .skip(skip)
        .limit(limit)
        .toArray(),
      this.collection.countDocuments(query)
    ]);

    return { users, total, page, pages: Math.ceil(total / limit) };
  }
}
```

## Best Practices

### ✅ Do This

- ✅ Design for query patterns
- ✅ Embed for read-heavy data
- ✅ Create compound indexes
- ✅ Use explain() for queries
- ✅ Set appropriate write concern

### ❌ Avoid This

- ❌ Don't create too many indexes
- ❌ Don't embed unbounded arrays
- ❌ Don't normalize like SQL
- ❌ Don't skip connection pooling

## Related Skills

- `@senior-database-engineer-nosql` - NoSQL patterns
- `@senior-nodejs-developer` - Node.js integration

---
name: senior-database-engineer-nosql
description: "Expert NoSQL database engineering including MongoDB, Redis, document design, caching strategies, and distributed data patterns"
---

# Senior Database Engineer (NoSQL)

## Overview

This skill transforms you into an experienced Senior Database Engineer specializing in NoSQL databases. You'll design efficient document schemas, implement caching strategies, handle distributed data patterns, and optimize performance for various NoSQL systems.

## When to Use This Skill

- Use when designing NoSQL database schemas
- Use when choosing between NoSQL database types
- Use when implementing caching with Redis
- Use when working with MongoDB, DynamoDB, or Cassandra
- Use when handling unstructured or semi-structured data
- Use when scaling horizontally

## How It Works

### Step 1: Choose the Right NoSQL Type

```
NoSQL DATABASE TYPES
├── DOCUMENT (MongoDB, CouchDB, Firestore)
│   ├── Best for: Flexible schemas, nested data
│   ├── Data model: JSON/BSON documents
│   └── Use case: CMS, catalogs, user profiles
│
├── KEY-VALUE (Redis, DynamoDB, Memcached)
│   ├── Best for: Caching, sessions, real-time data
│   ├── Data model: Key → Value pairs
│   └── Use case: Sessions, leaderboards, queues
│
├── COLUMN-FAMILY (Cassandra, HBase)
│   ├── Best for: Time-series, write-heavy workloads
│   ├── Data model: Row key → Column families
│   └── Use case: IoT, logs, analytics
│
└── GRAPH (Neo4j, Amazon Neptune)
    ├── Best for: Highly connected data
    ├── Data model: Nodes + Edges
    └── Use case: Social networks, recommendations
```

### Step 2: Design MongoDB Documents

```javascript
// Document Design Patterns

// 1. EMBEDDED DOCUMENTS (denormalized)
// ✅ Good for: Data accessed together, 1:few relationships
{
  "_id": ObjectId("..."),
  "email": "user@example.com",
  "profile": {
    "name": "John Doe",
    "avatar": "https://..."
  },
  "addresses": [
    { "type": "home", "street": "123 Main St", "city": "NYC" },
    { "type": "work", "street": "456 Office Blvd", "city": "NYC" }
  ]
}

// 2. REFERENCES (normalized)
// ✅ Good for: Large/growing subdocuments, many-to-many
{
  "_id": ObjectId("order123"),
  "userId": ObjectId("user456"),  // Reference
  "productIds": [ObjectId("prod1"), ObjectId("prod2")],
  "total": 299.99
}

// 3. BUCKET PATTERN (for time-series)
{
  "_id": ObjectId("..."),
  "sensorId": "temp-001",
  "date": ISODate("2025-01-30"),
  "measurements": [
    { "ts": ISODate("..."), "value": 23.5 },
    { "ts": ISODate("..."), "value": 24.1 }
  ],
  "count": 2,
  "sum": 47.6
}
```

### Step 3: Master Redis Patterns

```redis
# STRING: Simple key-value
SET user:1:name "John Doe"
GET user:1:name
SETEX session:abc123 3600 "user_data"  # Expires in 1 hour

# HASH: Object-like structure
HSET user:1 name "John" email "john@example.com" age 30
HGET user:1 name
HGETALL user:1

# LIST: Queues, recent items
LPUSH queue:emails "email1" "email2"
RPOP queue:emails
LRANGE recent:products 0 9  # Last 10 products

# SET: Unique collections
SADD tags:article:1 "tech" "news" "trending"
SMEMBERS tags:article:1
SINTER tags:article:1 tags:article:2  # Common tags

# SORTED SET: Leaderboards, rankings
ZADD leaderboard 1500 "player1" 1200 "player2"
ZREVRANGE leaderboard 0 9 WITHSCORES  # Top 10
ZINCRBY leaderboard 100 "player1"

# CACHING PATTERN
def get_user(user_id):
    cached = redis.get(f"user:{user_id}")
    if cached:
        return json.loads(cached)
    
    user = db.users.find_one({"_id": user_id})
    redis.setex(f"user:{user_id}", 3600, json.dumps(user))
    return user
```

## Examples

### Example 1: MongoDB Indexing

```javascript
// Create indexes
db.products.createIndex({ "sku": 1 }, { unique: true })
db.products.createIndex({ "category": 1, "price": 1 })
db.products.createIndex({ "name": "text", "description": "text" })
db.orders.createIndex({ "userId": 1, "createdAt": -1 })

// Compound index for queries
db.orders.find({ userId: "123", status: "pending" })
    .sort({ createdAt: -1 })
// Needs: { userId: 1, status: 1, createdAt: -1 }
```

### Example 2: Cache-Aside Pattern

```python
import redis
import json

class CacheService:
    def __init__(self, redis_client, db, ttl=3600):
        self.redis = redis_client
        self.db = db
        self.ttl = ttl
    
    def get(self, key, fetch_fn):
        # Try cache first
        cached = self.redis.get(key)
        if cached:
            return json.loads(cached)
        
        # Cache miss - fetch from DB
        data = fetch_fn()
        if data:
            self.redis.setex(key, self.ttl, json.dumps(data))
        return data
    
    def invalidate(self, key):
        self.redis.delete(key)
```

## Best Practices

### ✅ Do This

- ✅ Design schema based on query patterns (not entity relationships)
- ✅ Embed data that is queried together
- ✅ Use TTL for cache expiration
- ✅ Implement cache invalidation strategy
- ✅ Use connection pooling
- ✅ Handle cache failures gracefully

### ❌ Avoid This

- ❌ Don't use NoSQL just because it's trendy
- ❌ Don't neglect indexing
- ❌ Don't store unbounded arrays in documents
- ❌ Don't cache everything (be selective)
- ❌ Don't forget about consistency requirements

## Common Pitfalls

**Problem:** Document too large (MongoDB 16MB limit)
**Solution:** Use bucket pattern or store references.

**Problem:** Cache stampede (many requests hit DB after cache expires)
**Solution:** Use cache locking or probabilistic early expiration.

**Problem:** Stale cache data
**Solution:** Implement cache-aside with proper invalidation.

## Related Skills

- `@senior-database-engineer-sql` - For relational databases
- `@senior-backend-developer` - For application integration
- `@senior-data-analyst` - For analytics queries

---
name: senior-database-engineer-nosql
description: "Expert NoSQL database architecture including database selection, data modeling patterns, and distributed data strategies"
---

# Senior Database Engineer (NoSQL)

## Overview

This skill provides strategic guidance for NoSQL database architecture decisions. Focus on choosing the right database type, understanding trade-offs, and designing for scalability.

> **Note:** For hands-on implementation details, use the specialized skills:
>
> - `@mongodb-developer` - MongoDB implementation
> - `@redis-specialist` - Redis implementation

## When to Use This Skill

- Use when choosing between NoSQL database types
- Use when designing distributed data architecture
- Use when evaluating SQL vs NoSQL trade-offs
- Use when planning horizontal scaling strategies

## How It Works

### Step 1: Choose the Right NoSQL Type

```text
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

### Step 2: SQL vs NoSQL Decision Matrix

| Criteria | SQL | NoSQL |
|----------|-----|-------|
| Schema | Fixed, predefined | Flexible, dynamic |
| Transactions | ACID guaranteed | Usually eventual consistency |
| Scaling | Vertical (scale up) | Horizontal (scale out) |
| Relationships | Complex joins | Embedded or referenced |
| Best for | Structured, relational | Unstructured, high volume |

### Step 3: Data Modeling Principles

```text
EMBEDDING vs REFERENCING

EMBED when:
├── Data is accessed together (read pattern)
├── Relationship is 1:few
├── Data doesn't change frequently
└── Document size stays bounded

REFERENCE when:
├── Data is accessed independently
├── Relationship is 1:many or many:many
├── Data changes frequently
└── Unbounded growth possible
```

### Step 4: Consistency Patterns

```text
CAP THEOREM
├── Consistency: All nodes see same data
├── Availability: System always responds
├── Partition tolerance: Works despite network issues

CHOOSE TWO:
├── CP (MongoDB): Consistent but may be unavailable
├── AP (Cassandra): Available but eventually consistent
└── CA (Traditional SQL): Not partition tolerant
```

## Best Practices

### ✅ Do This

- ✅ Choose database based on access patterns (not familiarity)
- ✅ Design schema around queries (not entities)
- ✅ Use connection pooling
- ✅ Implement proper error handling for network partitions
- ✅ Plan for data growth and sharding from day 1

### ❌ Avoid This

- ❌ Don't use NoSQL just because it's trendy
- ❌ Don't ignore consistency requirements
- ❌ Don't skip capacity planning
- ❌ Don't forget about backup and recovery

## Related Skills

- `@mongodb-developer` - MongoDB hands-on implementation
- `@redis-specialist` - Redis hands-on implementation
- `@elasticsearch-developer` - Search engine implementation
- `@senior-database-engineer-sql` - For relational databases
- `@database-modeling-specialist` - For ER diagrams and normalization

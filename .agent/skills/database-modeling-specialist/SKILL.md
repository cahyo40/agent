---
name: database-modeling-specialist
description: "Expert database modeling including ER diagrams, normalization, denormalization, schema design patterns, and data modeling best practices"
---

# Database Modeling Specialist

## Overview

Design robust database schemas with proper normalization, ER diagrams, relationships, constraints, and data modeling best practices for both SQL and NoSQL.

## When to Use This Skill

- Use when designing database schemas
- Use when creating ER diagrams
- Use when normalizing/denormalizing data
- Use when choosing data models

## How It Works

### Step 1: ER Diagram Notation

```
ENTITY RELATIONSHIPS
├── One-to-One (1:1)
│   └── User ─── UserProfile
│
├── One-to-Many (1:N)
│   └── Customer ─<< Orders
│
├── Many-to-Many (M:N)
│   └── Students >>─<< Courses
│       (via Enrollment junction table)

CARDINALITY NOTATION
├── |     Exactly one
├── ||    One and only one
├── o|    Zero or one
├── |<    One or many
├── o<    Zero or many
└── ><    Many to many
```

### Step 2: Normalization

```sql
-- 1NF: Atomic values, no repeating groups
-- BAD: products = "Apple, Banana, Orange"
-- GOOD: Separate rows for each product

-- 2NF: No partial dependencies (full key → all columns)
-- BAD: OrderItem(order_id, product_id, product_name, quantity)
-- GOOD: Separate Product table

-- 3NF: No transitive dependencies
-- BAD: Employee(id, dept_id, dept_name, dept_location)
-- GOOD: 
CREATE TABLE departments (
    id INT PRIMARY KEY,
    name VARCHAR(100),
    location VARCHAR(100)
);

CREATE TABLE employees (
    id INT PRIMARY KEY,
    name VARCHAR(100),
    dept_id INT REFERENCES departments(id)
);

-- BCNF: Every determinant is a candidate key
-- Applied when 3NF still has anomalies
```

### Step 3: Schema Design Patterns

```sql
-- HIERARCHICAL DATA: Adjacency List
CREATE TABLE categories (
    id INT PRIMARY KEY,
    name VARCHAR(100),
    parent_id INT REFERENCES categories(id)
);

-- HIERARCHICAL DATA: Nested Sets
CREATE TABLE categories (
    id INT PRIMARY KEY,
    name VARCHAR(100),
    lft INT,
    rgt INT
);

-- POLYMORPHIC ASSOCIATIONS
-- Option 1: Single Table Inheritance
CREATE TABLE content (
    id INT PRIMARY KEY,
    type VARCHAR(20), -- 'post', 'video', 'image'
    title VARCHAR(200),
    body TEXT,        -- for posts
    url VARCHAR(500), -- for videos/images
    duration INT      -- for videos only
);

-- Option 2: Class Table Inheritance
CREATE TABLE content (
    id INT PRIMARY KEY,
    type VARCHAR(20),
    title VARCHAR(200)
);

CREATE TABLE posts (
    id INT PRIMARY KEY REFERENCES content(id),
    body TEXT
);

CREATE TABLE videos (
    id INT PRIMARY KEY REFERENCES content(id),
    url VARCHAR(500),
    duration INT
);

-- AUDIT/HISTORY: Event Sourcing
CREATE TABLE account_events (
    id SERIAL PRIMARY KEY,
    account_id INT,
    event_type VARCHAR(50),
    amount DECIMAL(15,2),
    balance_after DECIMAL(15,2),
    created_at TIMESTAMP DEFAULT NOW()
);
```

### Step 4: NoSQL Document Modeling

```javascript
// EMBEDDING vs REFERENCING

// Embed: Data accessed together, bounded size
{
  _id: "order_123",
  customer: {
    name: "John Doe",
    email: "john@example.com"
  },
  items: [
    { product: "Widget", price: 10, qty: 2 },
    { product: "Gadget", price: 25, qty: 1 }
  ],
  total: 45
}

// Reference: Large/unbounded data, independent access
{
  _id: "user_123",
  name: "John Doe",
  order_ids: ["order_1", "order_2", "order_3"]
}

// Bucket Pattern: Time-series data
{
  sensor_id: "temp_001",
  day: "2024-01-15",
  readings: [
    { time: "08:00", value: 22.5 },
    { time: "08:05", value: 22.7 },
    // ... up to N readings per document
  ]
}

// Computed Pattern: Pre-aggregated data
{
  _id: "product_123",
  name: "Widget",
  review_count: 150,
  avg_rating: 4.5,
  // Reviews stored in separate collection
}
```

## Best Practices

### ✅ Do This

- ✅ Start normalized, denormalize for perf
- ✅ Design for access patterns
- ✅ Use proper data types
- ✅ Add constraints (FK, NOT NULL, CHECK)
- ✅ Document your schema

### ❌ Avoid This

- ❌ Don't over-normalize
- ❌ Don't skip index planning
- ❌ Don't store calculated data (usually)
- ❌ Don't use generic column names

## Related Skills

- `@senior-database-engineer-sql` - SQL databases
- `@mongodb-developer` - MongoDB modeling
- `@uml-specialist` - ER diagrams

---
name: senior-database-engineer-sql
description: "Expert SQL database engineering including schema design, query optimization, indexing strategies, transactions, and PostgreSQL/MySQL administration"
---

# Senior Database Engineer (SQL)

## Overview

This skill transforms you into an experienced Senior Database Engineer specializing in relational databases. You'll design efficient schemas, write optimized queries, implement indexing strategies, and manage database performance.

## When to Use This Skill

- Use when designing database schemas
- Use when optimizing SQL queries
- Use when implementing indexes
- Use when managing transactions
- Use when troubleshooting performance

## How It Works

### Step 1: Schema Design Best Practices

```sql
-- Standard table structure
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email VARCHAR(255) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    status VARCHAR(20) DEFAULT 'active'
        CHECK (status IN ('active', 'inactive', 'suspended')),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    deleted_at TIMESTAMPTZ NULL  -- Soft delete
);

-- Always create indexes for foreign keys
CREATE INDEX idx_orders_user_id ON orders(user_id);

-- Partial indexes for common queries
CREATE INDEX idx_orders_pending 
ON orders(created_at) 
WHERE status = 'pending';
```

### Step 2: Query Optimization

```sql
-- Use EXPLAIN ANALYZE to understand performance
EXPLAIN ANALYZE SELECT * FROM orders WHERE status = 'pending';

-- Avoid SELECT * - only select needed columns
SELECT id, status, total FROM orders WHERE id = 123;

-- Use proper JOINs
SELECT o.id, u.email, o.total
FROM orders o
INNER JOIN users u ON o.user_id = u.id
WHERE o.status = 'completed';

-- Batch operations for performance
INSERT INTO logs (user_id, action, timestamp)
VALUES 
    (1, 'login', NOW()),
    (2, 'purchase', NOW()),
    (3, 'logout', NOW());
```

### Step 3: Indexing Strategy

```
INDEX TYPES
├── B-TREE (Default): Equality, range, sorting
├── HASH: Exact matches only
├── GIN: Arrays, JSONB, full-text
├── GiST: Geometric, range types
└── BRIN: Large tables with natural ordering
```

## Examples

### Example: Window Functions

```sql
-- Running total
SELECT 
    date,
    revenue,
    SUM(revenue) OVER (ORDER BY date) AS cumulative,
    AVG(revenue) OVER (ORDER BY date ROWS 7 PRECEDING) AS rolling_7d
FROM daily_sales;

-- Year-over-year growth
SELECT 
    DATE_TRUNC('month', order_date) AS month,
    SUM(amount) AS revenue,
    LAG(SUM(amount), 12) OVER (ORDER BY DATE_TRUNC('month', order_date)) AS revenue_ly
FROM orders
GROUP BY 1;
```

## Best Practices

### ✅ Do This

- ✅ Use UUIDs for distributed systems
- ✅ Always include created_at, updated_at
- ✅ Use soft delete for important data
- ✅ Create indexes based on query patterns
- ✅ Use parameterized queries

### ❌ Avoid This

- ❌ Don't use SELECT * in production
- ❌ Don't forget to index foreign keys
- ❌ Don't ignore NULL handling
- ❌ Don't skip EXPLAIN ANALYZE

## Related Skills

- `@senior-database-engineer-nosql` - For NoSQL databases
- `@senior-data-analyst` - For analytical queries

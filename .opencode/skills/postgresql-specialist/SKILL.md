---
name: postgresql-specialist
description: "Expert PostgreSQL including advanced queries, performance tuning, extensions, JSON support, and database administration"
---

# PostgreSQL Specialist

## Overview

Master PostgreSQL including advanced SQL, JSON/JSONB, full-text search, performance tuning, partitioning, and administration.

## When to Use This Skill

- Use when working with PostgreSQL
- Use when optimizing SQL queries
- Use when using PostgreSQL features
- Use when administering Postgres

## How It Works

### Step 1: Advanced Queries

```sql
-- Common Table Expressions (CTE)
WITH monthly_revenue AS (
    SELECT 
        DATE_TRUNC('month', created_at) AS month,
        SUM(total) AS revenue
    FROM orders
    WHERE created_at >= NOW() - INTERVAL '12 months'
    GROUP BY 1
),
growth AS (
    SELECT 
        month,
        revenue,
        LAG(revenue) OVER (ORDER BY month) AS prev_revenue
    FROM monthly_revenue
)
SELECT 
    month,
    revenue,
    ROUND((revenue - prev_revenue) / prev_revenue * 100, 2) AS growth_pct
FROM growth
ORDER BY month;

-- Recursive CTE (hierarchical data)
WITH RECURSIVE category_tree AS (
    SELECT id, name, parent_id, 0 AS depth, name AS path
    FROM categories
    WHERE parent_id IS NULL
    
    UNION ALL
    
    SELECT c.id, c.name, c.parent_id, ct.depth + 1,
           ct.path || ' > ' || c.name
    FROM categories c
    JOIN category_tree ct ON c.parent_id = ct.id
)
SELECT * FROM category_tree ORDER BY path;

-- Window functions
SELECT 
    order_id,
    customer_id,
    total,
    SUM(total) OVER (PARTITION BY customer_id ORDER BY created_at) AS running_total,
    ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY total DESC) AS rank_by_amount,
    NTILE(4) OVER (ORDER BY total) AS quartile
FROM orders;
```

### Step 2: JSON/JSONB

```sql
-- Create table with JSONB
CREATE TABLE products (
    id SERIAL PRIMARY KEY,
    name VARCHAR(200),
    attributes JSONB,
    created_at TIMESTAMP DEFAULT NOW()
);

-- Insert JSON data
INSERT INTO products (name, attributes) VALUES
('Laptop', '{"brand": "Dell", "specs": {"ram": 16, "storage": 512}, "colors": ["silver", "black"]}');

-- Query JSON
SELECT 
    name,
    attributes->>'brand' AS brand,
    attributes->'specs'->>'ram' AS ram,
    attributes->'colors'->>0 AS primary_color
FROM products
WHERE attributes->>'brand' = 'Dell';

-- JSONB operators
SELECT * FROM products
WHERE attributes @> '{"brand": "Dell"}';  -- Contains

SELECT * FROM products
WHERE attributes ? 'warranty';  -- Key exists

SELECT * FROM products
WHERE attributes->'specs'->>'ram' > '8';

-- GIN index for JSONB
CREATE INDEX idx_products_attributes ON products USING GIN (attributes);
```

### Step 3: Performance Tuning

```sql
-- Analyze query plan
EXPLAIN ANALYZE
SELECT * FROM orders
WHERE customer_id = 123
  AND created_at > '2024-01-01';

-- Create indexes
CREATE INDEX idx_orders_customer_date 
ON orders (customer_id, created_at DESC);

-- Partial index
CREATE INDEX idx_orders_pending 
ON orders (created_at)
WHERE status = 'pending';

-- Expression index
CREATE INDEX idx_users_email_lower 
ON users (LOWER(email));

-- Table statistics
ANALYZE orders;

-- Configuration tuning (postgresql.conf)
-- shared_buffers = 256MB
-- effective_cache_size = 1GB
-- work_mem = 64MB
-- maintenance_work_mem = 128MB
```

### Step 4: Partitioning

```sql
-- Range partitioning
CREATE TABLE orders (
    id SERIAL,
    customer_id INT,
    total DECIMAL(15,2),
    created_at TIMESTAMP
) PARTITION BY RANGE (created_at);

CREATE TABLE orders_2024_q1 PARTITION OF orders
    FOR VALUES FROM ('2024-01-01') TO ('2024-04-01');

CREATE TABLE orders_2024_q2 PARTITION OF orders
    FOR VALUES FROM ('2024-04-01') TO ('2024-07-01');

-- List partitioning
CREATE TABLE orders_by_region (
    id SERIAL,
    region VARCHAR(50),
    total DECIMAL(15,2)
) PARTITION BY LIST (region);

CREATE TABLE orders_asia PARTITION OF orders_by_region
    FOR VALUES IN ('ID', 'SG', 'MY', 'TH');
```

## Best Practices

### ✅ Do This

- ✅ Use EXPLAIN ANALYZE
- ✅ Create proper indexes
- ✅ Use JSONB over JSON
- ✅ Partition large tables
- ✅ Regular VACUUM/ANALYZE

### ❌ Avoid This

- ❌ Don't SELECT *
- ❌ Don't over-index
- ❌ Don't ignore query plans
- ❌ Don't skip backups

## Related Skills

- `@senior-database-engineer-sql` - SQL expertise
- `@database-modeling-specialist` - Schema design

---
name: postgresql-specialist
description: "Expert PostgreSQL including advanced queries, performance tuning, extensions, JSON support, and database administration"
---

# PostgreSQL Specialist

## Overview

This skill transforms you into a **PostgreSQL Expert**. You will move beyond basic `SELECT` and `INSERT` to mastering advanced indexing, rigorous query optimization, table partitioning strategies, JSONB at scale, concurrency control (MVCC), and high-availability configurations.

## When to Use This Skill

- Use when optimizing slow SQL queries (`EXPLAIN ANALYZE`)
- Use when designing schemas for high throughput
- Use when implementing full-text search or JSON storage
- Use when partitioning massive tables (100GB+)
- Use when configuring production servers (vacuum, WAL, checkpoints)

---

## Part 1: Advanced Indexing Strategies

Indexes are the primary tool for read performance, but they come with write cost.

### 1.1 Index Types & Use Cases

- **B-Tree**: Default. Good for `=`, `>`, `<`, `BETWEEN`, `ORDER BY`.
- **Hash**: O(1) lookups for equality only (`=`). Not crash-safe before PG10.
- **GIN (Generalized Inverted Index)**: Best for JSONB, Arrays, and Full-text Search.
- **GiST (Generalized Search Tree)**: Best for Geometry (PostGIS), Range types, and Nearest Neighbor search.
- **BRIN (Block Range Index)**: Very small. Good for huge, naturally ordered tables (e.g., timestamps).

### 1.2 Creating Specialized Indexes

```sql
-- 1. Partial Index (Index only a subset)
-- Reduces index size and maintenance cost.
CREATE INDEX idx_orders_unpaid 
ON orders (created_at) 
WHERE status = 'pending';

-- 2. Expression/Functional Index
-- Index the result of a function.
CREATE INDEX idx_users_lower_email 
ON users (LOWER(email));

-- 3. Covering Index (Index Only Scan)
-- sort by 'created_at' and include 'total' in the leaf nodes
-- Allows answering queries without visiting the heap (table)
CREATE INDEX idx_orders_covering 
ON orders (created_at) 
INCLUDE (total);

-- 4. GIN Index for JSONB
CREATE INDEX idx_products_attributes 
ON products USING GIN (attributes);
-- Query: WHERE attributes @> '{"color": "red"}'
```

---

## Part 2: Query Optimization & EXPLAIN

### 2.1 Reading EXPLAIN ANALYZE

`EXPLAIN` shows the plan. `EXPLAIN ANALYZE` executes it and shows actual times.

```sql
EXPLAIN (ANALYZE, BUFFERS, FORMAT JSON)
SELECT * FROM orders WHERE customer_id = 99;
```

**Key Metrics to Watch:**

1. **Seq Scan vs Index Scan**: Sequential scans on large tables are bad.
2. **Rows Removed by Filter**: If high (e.g., 1M rows scanned, 10 returned), you need a better index.
3. **Buffers**: `Shared Hit Blocks` (cache hit) vs `Read Blocks` (disk I/O). High reads = slow.
4. **Sort Method**: `external merge` means `work_mem` was too small (spilled to disk). `quicksort` (memory) is faster.

### 2.2 Optimizing Common Anti-Patterns

**Bad: `OR` conditions breaking indexes**

```sql
-- Often results in Seq Scan
SELECT * FROM users WHERE email = ? OR username = ?;

-- Better: UNION ALL
SELECT * FROM users WHERE email = ?
UNION ALL
SELECT * FROM users WHERE username = ?;
```

**Bad: `LIKE` starting with wildcard**

```sql
-- Cannot use B-Tree index
SELECT * FROM products WHERE name LIKE '%phone%';

-- Better: Use pg_trgm (Trigram) index or Full Text Search
CREATE EXTENSION pg_trgm;
CREATE INDEX idx_name_trgm ON products USING GIST (name gist_trgm_ops);
```

---

## Part 3: Table Partitioning

Essential for tables exceeding ~100GB to maintain performance and manageability (e.g., dropping old data instantly).

### 3.1 Declarative Partitioning (Range)

```sql
-- Parent table
CREATE TABLE logs (
    id UUID,
    event_time TIMESTAMPTZ NOT NULL,
    message TEXT
) PARTITION BY RANGE (event_time);

-- Partitions (Must create manually or automate)
CREATE TABLE logs_2024_01 PARTITION OF logs
    FOR VALUES FROM ('2024-01-01') TO ('2024-02-01');

CREATE TABLE logs_2024_02 PARTITION OF logs
    FOR VALUES FROM ('2024-02-01') TO ('2024-03-01');

-- Default partition (Catch-all)
CREATE TABLE logs_default PARTITION OF logs DEFAULT;

-- Maintenance: Dropping old data is instant (filesystem unlink) vs DELETE (expensive VACUUM)
DROP TABLE logs_2024_01;
```

### 3.2 List Partitioning (Multi-Tenant)

```sql
CREATE TABLE orders (
    id SERIAL,
    region_code VARCHAR(10),
    amount DECIMAL
) PARTITION BY LIST (region_code);

CREATE TABLE orders_us PARTITION OF orders FOR VALUES IN ('US', 'CA');
CREATE TABLE orders_eu PARTITION OF orders FOR VALUES IN ('UK', 'DE', 'FR');
```

---

## Part 4: Advanced JSONB Patterns

PostgreSQL is a fantastic NoSQL database.

```sql
-- 1. Indexing specific keys inside JSONB
CREATE INDEX idx_user_data_role 
ON users USING btree ((data->>'role'));

-- 2. Existence Operator (?)
-- Find rows where 'tags' array contains 'admin'
SELECT * FROM users WHERE data->'tags' ? 'admin';

-- 3. Updating deep JSON structures
-- Set data.preferences.theme = "dark"
UPDATE users 
SET data = jsonb_set(data, '{preferences,theme}', '"dark"', true)
WHERE id = 1;

-- 4. Aggregating to JSON
SELECT jsonb_agg(jsonb_build_object('id', id, 'name', name)) 
FROM users;
```

---

## Part 5: MVCC & Vacuum Optimization

Understanding Multi-Version Concurrency Control is key to preventing table bloat.

- **Dead Tuples**: Updates in PG are technically DELETE + INSERT. The old row (dead tuple) remains until VACUUM.
- **Autovacuum**: Runs automatically. If it lags, table size grows indefinitely (bloat).

**Tuning Autovacuum for Busy Tables:**

```sql
-- Make autovacuum more aggressive for specific high-churn table
ALTER TABLE queue_jobs SET (
  autovacuum_vacuum_scale_factor = 0.01,  -- Run when 1% of rows change (default 0.2/20%)
  autovacuum_vacuum_cost_limit = 1000     -- Allow it to work harder
);
```

---

## Part 6: Production Configuration (postgresql.conf)

Defaults are for low-memory machines. Tune these!

| Parameter | Recommended (Approx) | Description |
|-----------|----------------------|-------------|
| `shared_buffers` | 25% of RAM | Memory for caching data blocks. |
| `work_mem` | 10MB - 64MB | Memory per operation (sort/hash). Too high = OOM. |
| `maintenance_work_mem` | 1GB | Memory for VACUUM, CREATE INDEX. |
| `effective_cache_size` | 75% of RAM | Estimate of OS cache + shared_buffers. Helps planner choice. |
| `random_page_cost` | 1.1 (SSD) / 4.0 (HDD) | Cost of random I/O. Lower for SSDs to prefer Index Scans. |
| `effective_io_concurrency` | 200 (SSD) / 2 (HDD) | Concurrent I/O operations. |
| `wal_level` | `logical` | Required for replication / CDC (Debezium). |

---

## Part 7: Best Practices Checklist

### ✅ Do This

- ✅ **Use Connection Pooling** (PgBouncer). PG connections are expensive (process-based).
- ✅ **Use `TIMESTAMPTZ`**. Always store time with timezone (UTC).
- ✅ **Use UUIDv7** (or standard UUID). Avoid `SERIAL` (integers) for public IDs.
- ✅ **Backup Validation**. Regularly test `pg_restore`. Backups are useless if they don't restore.
- ✅ **Monitor Lock contention**. `SELECT * FROM pg_stat_activity WHERE wait_event_type = 'Lock';`

### ❌ Avoid This

- ❌ **`NOT IN (...)` query**. It fails if any value is NULL. Use `NOT EXISTS` instead.
- ❌ **Storing Large Files**. Store file path/URL, keep blob in S3.
- ❌ **Long Transactions**. They hold locks and prevent Vacuum from cleaning up dead tuples.
- ❌ **Select *** without Limit**.

---

## Related Skills

- `@database-modeling-specialist` - ERD & Normalization
- `@gis-specialist` - PostGIS spatial data
- `@backend-engineer-golang` - Go integration

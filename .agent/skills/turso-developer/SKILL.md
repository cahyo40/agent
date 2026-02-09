---
name: turso-developer
description: "Expert Turso development for edge SQLite databases including LibSQL, embedded replicas, multi-region deployment, and serverless database access"
---

# Turso Developer

## Overview

Build applications with Turso, the edge SQLite database that brings your data close to users worldwide. Turso uses LibSQL (SQLite fork) with features like embedded replicas, multi-region replication, and serverless-friendly connections.

## When to Use This Skill

- Use when deploying databases at the edge
- Use when building serverless applications
- Use when you need low-latency database access globally
- Use when using Cloudflare Workers, Vercel Edge, or Deno Deploy
- Use when migrating from SQLite to distributed architecture

## Templates Reference

| Template | Description |
|----------|-------------|
| [setup.md](templates/setup.md) | Turso CLI and database setup |
| [drizzle.md](templates/drizzle.md) | Integration with Drizzle ORM |
| [embedded-replica.md](templates/embedded-replica.md) | Embedded replica patterns |

## How It Works

### Step 1: CLI Setup

```bash
# Install Turso CLI
curl -sSfL https://get.tur.so/install.sh | bash

# Login
turso auth login

# Create database
turso db create my-database

# Get database URL
turso db show my-database --url

# Create auth token
turso db tokens create my-database
```

### Step 2: Client Setup

```bash
npm install @libsql/client
```

```typescript
// src/db/client.ts
import { createClient } from '@libsql/client'

export const turso = createClient({
  url: process.env.TURSO_DATABASE_URL!,
  authToken: process.env.TURSO_AUTH_TOKEN,
})

// Execute query
const result = await turso.execute('SELECT * FROM users')
console.log(result.rows)

// With parameters
const user = await turso.execute({
  sql: 'SELECT * FROM users WHERE id = ?',
  args: [1],
})

// Batch execution
const batch = await turso.batch([
  { sql: 'INSERT INTO users (name, email) VALUES (?, ?)', args: ['John', 'john@example.com'] },
  { sql: 'INSERT INTO users (name, email) VALUES (?, ?)', args: ['Jane', 'jane@example.com'] },
])

// Transaction
const transaction = await turso.transaction('write')
try {
  await transaction.execute({ sql: 'UPDATE users SET balance = balance - ? WHERE id = ?', args: [100, 1] })
  await transaction.execute({ sql: 'UPDATE users SET balance = balance + ? WHERE id = ?', args: [100, 2] })
  await transaction.commit()
} catch (e) {
  await transaction.rollback()
  throw e
}
```

### Step 3: With Drizzle ORM

```typescript
// src/db/schema.ts
import { sqliteTable, text, integer } from 'drizzle-orm/sqlite-core'

export const users = sqliteTable('users', {
  id: integer('id').primaryKey({ autoIncrement: true }),
  name: text('name').notNull(),
  email: text('email').notNull().unique(),
  createdAt: text('created_at').default('CURRENT_TIMESTAMP'),
})

export const posts = sqliteTable('posts', {
  id: integer('id').primaryKey({ autoIncrement: true }),
  title: text('title').notNull(),
  content: text('content'),
  authorId: integer('author_id').references(() => users.id),
  published: integer('published', { mode: 'boolean' }).default(false),
})
```

```typescript
// src/db/index.ts
import { drizzle } from 'drizzle-orm/libsql'
import { createClient } from '@libsql/client'
import * as schema from './schema'

const client = createClient({
  url: process.env.TURSO_DATABASE_URL!,
  authToken: process.env.TURSO_AUTH_TOKEN,
})

export const db = drizzle(client, { schema })

// Queries
const allUsers = await db.select().from(schema.users)

const userWithPosts = await db.query.users.findFirst({
  where: eq(schema.users.id, 1),
  with: {
    posts: true,
  },
})
```

### Step 4: Embedded Replicas

```typescript
// For edge/serverless with local replica
import { createClient } from '@libsql/client'

const client = createClient({
  url: 'file:local.db', // Local SQLite file
  syncUrl: process.env.TURSO_DATABASE_URL, // Remote Turso URL
  authToken: process.env.TURSO_AUTH_TOKEN,
  syncInterval: 60, // Sync every 60 seconds
})

// Manual sync
await client.sync()

// Read from local replica (fast)
const users = await client.execute('SELECT * FROM users')

// Write goes to remote, then syncs
await client.execute({
  sql: 'INSERT INTO users (name) VALUES (?)',
  args: ['New User'],
})
```

### Step 5: Multi-Region

```bash
# Add replica in another region
turso db replicas add my-database --region fra  # Frankfurt
turso db replicas add my-database --region sin  # Singapore

# List replicas
turso db show my-database

# Destroy replica
turso db replicas remove my-database fra
```

## Best Practices

### ✅ Do This

- ✅ Use embedded replicas for read-heavy workloads
- ✅ Place replicas close to your users
- ✅ Use Drizzle ORM for type safety
- ✅ Batch related queries together
- ✅ Use transactions for multiple writes

### ❌ Avoid This

- ❌ Don't store auth tokens in code
- ❌ Don't skip schema migrations
- ❌ Don't ignore sync intervals for replicas
- ❌ Don't use for very high write throughput

## Common Pitfalls

**Problem:** Sync conflicts with embedded replicas
**Solution:** Use write transactions and sync after writes

**Problem:** Connection timeouts on cold starts
**Solution:** Use connection pooling or keep-alive

**Problem:** Row limits exceeded on free tier
**Solution:** Monitor usage, upgrade plan, or optimize queries

## Related Skills

- `@drizzle-orm-specialist` - Drizzle ORM patterns
- `@cloudflare-developer` - Cloudflare Workers integration
- `@postgresql-specialist` - For comparison with PostgreSQL

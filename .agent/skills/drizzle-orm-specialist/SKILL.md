---
name: drizzle-orm-specialist
description: "Expert Drizzle ORM development including type-safe queries, migrations, PostgreSQL/MySQL/SQLite support, and modern TypeScript database patterns"
---

# Drizzle ORM Specialist

## Overview

Build type-safe database applications using Drizzle ORM. Drizzle provides a TypeScript-first approach to SQL with zero dependencies, lightweight footprint, and excellent developer experience including automatic type inference and SQL-like syntax.

## When to Use This Skill

- Use when building TypeScript applications that need database access
- Use when you want type-safe SQL queries
- Use when working with PostgreSQL, MySQL, or SQLite
- Use when deploying to edge environments (Cloudflare, Vercel Edge)
- Use when you need lightweight ORM without heavy runtime

## Templates Reference

| Template | Description |
|----------|-------------|
| [schema.md](templates/schema.md) | Schema definition patterns |
| [queries.md](templates/queries.md) | Query patterns and operations |
| [relations.md](templates/relations.md) | Table relations and joins |
| [migrations.md](templates/migrations.md) | Migration workflow |

## How It Works

### Step 1: Installation

```bash
# Core package
npm install drizzle-orm

# Database driver (choose one)
npm install @libsql/client     # Turso/LibSQL
npm install postgres           # PostgreSQL (node-postgres)
npm install @neondatabase/serverless  # Neon
npm install mysql2             # MySQL
npm install better-sqlite3     # SQLite

# Drizzle Kit (CLI for migrations)
npm install -D drizzle-kit
```

### Step 2: Schema Definition

```typescript
// src/db/schema.ts
import { pgTable, serial, text, timestamp, varchar, integer, boolean, pgEnum } from 'drizzle-orm/pg-core'
import { relations } from 'drizzle-orm'

// Enum
export const userRoleEnum = pgEnum('user_role', ['admin', 'user', 'guest'])

// Users table
export const users = pgTable('users', {
  id: serial('id').primaryKey(),
  email: varchar('email', { length: 255 }).unique().notNull(),
  name: text('name').notNull(),
  role: userRoleEnum('role').default('user'),
  isActive: boolean('is_active').default(true),
  createdAt: timestamp('created_at').defaultNow(),
  updatedAt: timestamp('updated_at').defaultNow(),
})

// Posts table
export const posts = pgTable('posts', {
  id: serial('id').primaryKey(),
  title: varchar('title', { length: 255 }).notNull(),
  content: text('content'),
  authorId: integer('author_id').references(() => users.id),
  published: boolean('published').default(false),
  createdAt: timestamp('created_at').defaultNow(),
})

// Relations
export const usersRelations = relations(users, ({ many }) => ({
  posts: many(posts),
}))

export const postsRelations = relations(posts, ({ one }) => ({
  author: one(users, {
    fields: [posts.authorId],
    references: [users.id],
  }),
}))
```

### Step 3: Database Connection

```typescript
// src/db/index.ts
import { drizzle } from 'drizzle-orm/node-postgres'
import { Pool } from 'pg'
import * as schema from './schema'

const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
})

export const db = drizzle(pool, { schema })

// For Turso/LibSQL
import { drizzle } from 'drizzle-orm/libsql'
import { createClient } from '@libsql/client'

const client = createClient({
  url: process.env.DATABASE_URL!,
  authToken: process.env.DATABASE_AUTH_TOKEN,
})

export const db = drizzle(client, { schema })
```

### Step 4: Basic Queries

```typescript
import { db } from './db'
import { users, posts } from './db/schema'
import { eq, and, or, like, desc, asc, count, sql } from 'drizzle-orm'

// Select all
const allUsers = await db.select().from(users)

// Select with where
const activeUsers = await db.select()
  .from(users)
  .where(eq(users.isActive, true))

// Select specific columns
const userEmails = await db.select({
  id: users.id,
  email: users.email,
}).from(users)

// Insert
const newUser = await db.insert(users).values({
  email: 'user@example.com',
  name: 'John Doe',
}).returning()

// Update
await db.update(users)
  .set({ name: 'Jane Doe', updatedAt: new Date() })
  .where(eq(users.id, 1))

// Delete
await db.delete(users).where(eq(users.id, 1))

// Complex where
const results = await db.select()
  .from(users)
  .where(
    and(
      eq(users.isActive, true),
      or(
        like(users.email, '%@gmail.com'),
        like(users.email, '%@company.com')
      )
    )
  )
  .orderBy(desc(users.createdAt))
  .limit(10)
```

### Step 5: Drizzle Config

```typescript
// drizzle.config.ts
import type { Config } from 'drizzle-kit'

export default {
  schema: './src/db/schema.ts',
  out: './drizzle',
  driver: 'pg',
  dbCredentials: {
    connectionString: process.env.DATABASE_URL!,
  },
} satisfies Config
```

## Best Practices

### ✅ Do This

- ✅ Define schemas in TypeScript for type safety
- ✅ Use migrations for production database changes
- ✅ Leverage relations for efficient joins
- ✅ Use prepared statements for repeated queries
- ✅ Keep schema and types in sync

### ❌ Avoid This

- ❌ Don't use raw SQL strings when Drizzle query builder works
- ❌ Don't skip migrations in production
- ❌ Don't ignore TypeScript errors from schema mismatches
- ❌ Don't hardcode database credentials

## Common Pitfalls

**Problem:** Types not inferring correctly
**Solution:** Ensure schema is exported and imported properly, use `InferModel<typeof table>`

**Problem:** Migrations not generating
**Solution:** Check drizzle.config.ts paths and run `drizzle-kit generate:pg`

**Problem:** Relations not working in queries
**Solution:** Use `db.query.tableName.findMany({ with: { relation: true } })`

## Related Skills

- `@postgresql-specialist` - PostgreSQL optimization
- `@turso-developer` - Edge SQLite with Turso
- `@senior-typescript-developer` - TypeScript patterns

---
name: cloudflare-developer
description: "Expert Cloudflare development including Workers, Pages, D1 database, R2 storage, KV, Durable Objects, and edge computing patterns"
---

# Cloudflare Developer

## Overview

Build scalable edge-first applications using Cloudflare's developer platform. This skill covers Workers for serverless compute, D1 for SQLite databases, R2 for object storage, KV for key-value data, and Durable Objects for stateful applications.

## When to Use This Skill

- Use when building serverless applications on Cloudflare Workers
- Use when deploying edge-first web applications
- Use when implementing D1 SQLite databases at the edge
- Use when needing R2 object storage (S3-compatible)
- Use when building real-time applications with Durable Objects
- Use when optimizing for global low-latency performance

## Templates Reference

| Template | Description |
|----------|-------------|
| [worker-basic.md](templates/worker-basic.md) | Basic Worker setup with routing |
| [d1-database.md](templates/d1-database.md) | D1 SQLite database operations |
| [r2-storage.md](templates/r2-storage.md) | R2 object storage patterns |
| [kv-cache.md](templates/kv-cache.md) | KV key-value caching |
| [durable-objects.md](templates/durable-objects.md) | Stateful Durable Objects |
| [pages-functions.md](templates/pages-functions.md) | Pages Functions deployment |

## How It Works

### Step 1: Project Setup

```bash
# Create new project
npm create cloudflare@latest my-app

# Project structure
my-app/
├── src/
│   └── index.ts          # Main worker entry
├── wrangler.toml         # Cloudflare config
├── package.json
└── tsconfig.json
```

### Step 2: Wrangler Configuration

```toml
# wrangler.toml
name = "my-app"
main = "src/index.ts"
compatibility_date = "2024-01-01"

# D1 Database
[[d1_databases]]
binding = "DB"
database_name = "my-database"
database_id = "xxx-xxx-xxx"

# R2 Bucket
[[r2_buckets]]
binding = "BUCKET"
bucket_name = "my-bucket"

# KV Namespace
[[kv_namespaces]]
binding = "KV"
id = "xxx-xxx-xxx"

# Environment variables
[vars]
API_KEY = "your-api-key"
```

### Step 3: Worker with Hono

```typescript
import { Hono } from 'hono'
import { cors } from 'hono/cors'

type Bindings = {
  DB: D1Database
  BUCKET: R2Bucket
  KV: KVNamespace
}

const app = new Hono<{ Bindings: Bindings }>()

app.use('*', cors())

app.get('/', (c) => c.json({ message: 'Hello from Edge!' }))

app.get('/users', async (c) => {
  const { results } = await c.env.DB.prepare(
    'SELECT * FROM users'
  ).all()
  return c.json(results)
})

app.post('/users', async (c) => {
  const { name, email } = await c.req.json()
  await c.env.DB.prepare(
    'INSERT INTO users (name, email) VALUES (?, ?)'
  ).bind(name, email).run()
  return c.json({ success: true }, 201)
})

export default app
```

## Best Practices

### ✅ Do This

- ✅ Use Hono for routing (lightweight, fast)
- ✅ Implement proper error handling with try-catch
- ✅ Use Workers AI for ML inference at edge
- ✅ Leverage caching with Cache API and KV
- ✅ Use Durable Objects for WebSocket connections
- ✅ Implement rate limiting with Durable Objects

### ❌ Avoid This

- ❌ Don't store secrets in code, use wrangler secrets
- ❌ Don't exceed CPU time limits (10-50ms free tier)
- ❌ Don't make blocking synchronous calls
- ❌ Don't ignore error responses from bindings
- ❌ Don't skip request validation

## Common Pitfalls

**Problem:** D1 queries timeout on large datasets
**Solution:** Use pagination with LIMIT/OFFSET, add indexes

**Problem:** R2 upload fails for large files
**Solution:** Use multipart upload for files > 5MB

**Problem:** Worker exceeds CPU time limit
**Solution:** Offload heavy computation to Durable Objects or Queue

## Related Skills

- `@hono-developer` - Edge-first web framework
- `@senior-typescript-developer` - TypeScript patterns
- `@vercel-developer` - Alternative edge platform

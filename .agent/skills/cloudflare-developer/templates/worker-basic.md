# Cloudflare Worker Basic Setup

## TypeScript Worker with Hono

```typescript
import { Hono } from 'hono'
import { cors } from 'hono/cors'
import { logger } from 'hono/logger'
import { prettyJSON } from 'hono/pretty-json'
import { secureHeaders } from 'hono/secure-headers'

type Bindings = {
  DB: D1Database
  BUCKET: R2Bucket
  KV: KVNamespace
  API_SECRET: string
}

type Variables = {
  user: { id: string; email: string }
}

const app = new Hono<{ Bindings: Bindings; Variables: Variables }>()

// Middleware
app.use('*', logger())
app.use('*', secureHeaders())
app.use('*', prettyJSON())
app.use('/api/*', cors({
  origin: ['https://example.com'],
  allowMethods: ['GET', 'POST', 'PUT', 'DELETE'],
  allowHeaders: ['Content-Type', 'Authorization'],
  credentials: true,
}))

// Health check
app.get('/health', (c) => c.json({ status: 'ok', timestamp: Date.now() }))

// API Routes
const api = app.basePath('/api/v1')

api.get('/users', async (c) => {
  try {
    const { results } = await c.env.DB.prepare('SELECT * FROM users').all()
    return c.json({ data: results })
  } catch (error) {
    return c.json({ error: 'Failed to fetch users' }, 500)
  }
})

api.get('/users/:id', async (c) => {
  const id = c.req.param('id')
  const { results } = await c.env.DB.prepare(
    'SELECT * FROM users WHERE id = ?'
  ).bind(id).all()
  
  if (results.length === 0) {
    return c.json({ error: 'User not found' }, 404)
  }
  
  return c.json({ data: results[0] })
})

api.post('/users', async (c) => {
  const body = await c.req.json<{ name: string; email: string }>()
  
  if (!body.name || !body.email) {
    return c.json({ error: 'Name and email required' }, 400)
  }
  
  const id = crypto.randomUUID()
  await c.env.DB.prepare(
    'INSERT INTO users (id, name, email, created_at) VALUES (?, ?, ?, ?)'
  ).bind(id, body.name, body.email, new Date().toISOString()).run()
  
  return c.json({ data: { id, ...body } }, 201)
})

// Error handler
app.onError((err, c) => {
  console.error('Error:', err)
  return c.json({ error: 'Internal Server Error' }, 500)
})

// 404 handler
app.notFound((c) => c.json({ error: 'Not Found' }, 404))

export default app
```

## Project Structure

```text
cloudflare-worker/
├── src/
│   ├── index.ts          # Main entry
│   ├── routes/
│   │   ├── users.ts
│   │   ├── posts.ts
│   │   └── auth.ts
│   ├── middleware/
│   │   ├── auth.ts
│   │   └── rateLimit.ts
│   ├── services/
│   │   ├── userService.ts
│   │   └── emailService.ts
│   └── types/
│       └── index.ts
├── wrangler.toml
├── package.json
└── tsconfig.json
```

## wrangler.toml Configuration

```toml
name = "my-worker"
main = "src/index.ts"
compatibility_date = "2024-01-01"
compatibility_flags = ["nodejs_compat"]

# Development settings
[dev]
port = 8787
local_protocol = "http"

# D1 Database
[[d1_databases]]
binding = "DB"
database_name = "production-db"
database_id = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"

# R2 Bucket
[[r2_buckets]]
binding = "BUCKET"
bucket_name = "my-bucket"

# KV Namespace
[[kv_namespaces]]
binding = "KV"
id = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"

# Secrets (set via wrangler secret put)
# API_SECRET, JWT_SECRET, etc.

# Environment variables
[vars]
ENVIRONMENT = "production"

# Cron triggers
[triggers]
crons = ["0 0 * * *"]  # Daily at midnight
```

## package.json

```json
{
  "name": "cloudflare-worker",
  "version": "1.0.0",
  "type": "module",
  "scripts": {
    "dev": "wrangler dev",
    "deploy": "wrangler deploy",
    "d1:create": "wrangler d1 create production-db",
    "d1:migrate": "wrangler d1 migrations apply production-db",
    "d1:migrate:local": "wrangler d1 migrations apply production-db --local"
  },
  "dependencies": {
    "hono": "^4.0.0"
  },
  "devDependencies": {
    "@cloudflare/workers-types": "^4.0.0",
    "typescript": "^5.0.0",
    "wrangler": "^3.0.0"
  }
}
```

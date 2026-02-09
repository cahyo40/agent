---
name: hono-developer
description: "Expert Hono development for edge-first web applications with ultrafast performance, middleware patterns, and multi-runtime support"
---

# Hono Developer

## Overview

Build ultrafast web applications using Hono, the lightweight web framework designed for edge computing. Hono works on Cloudflare Workers, Deno, Bun, Vercel, AWS Lambda, and Node.js with consistent APIs and excellent performance.

## When to Use This Skill

- Use when building APIs for edge environments (Cloudflare Workers, Deno Deploy)
- Use when you need an ultrafast, lightweight framework
- Use when building with Bun or Deno
- Use when creating serverless functions
- Use when you need framework-agnostic middleware

## Templates Reference

| Template | Description |
|----------|-------------|
| [basic-app.md](templates/basic-app.md) | Basic Hono application setup |
| [middleware.md](templates/middleware.md) | Middleware patterns |
| [validation.md](templates/validation.md) | Request validation with Zod |
| [authentication.md](templates/authentication.md) | Auth patterns (JWT, sessions) |

## How It Works

### Step 1: Installation

```bash
# For Cloudflare Workers
npm create hono@latest my-app
# Select cloudflare-workers template

# Manual installation
npm install hono

# With Bun
bun add hono

# With Deno (import directly)
import { Hono } from 'https://deno.land/x/hono/mod.ts'
```

### Step 2: Basic Application

```typescript
import { Hono } from 'hono'
import { cors } from 'hono/cors'
import { logger } from 'hono/logger'
import { prettyJSON } from 'hono/pretty-json'

const app = new Hono()

// Built-in middleware
app.use('*', logger())
app.use('*', prettyJSON())
app.use('/api/*', cors())

// Routes
app.get('/', (c) => c.text('Hello Hono!'))

app.get('/json', (c) => c.json({ message: 'Hello JSON!' }))

app.get('/html', (c) => c.html('<h1>Hello HTML!</h1>'))

app.get('/users/:id', (c) => {
  const id = c.req.param('id')
  return c.json({ userId: id })
})

// POST with body
app.post('/users', async (c) => {
  const body = await c.req.json()
  return c.json(body, 201)
})

export default app
```

### Step 3: Type-safe Routes with RPC

```typescript
import { Hono } from 'hono'
import { zValidator } from '@hono/zod-validator'
import { z } from 'zod'

const app = new Hono()

// Define schema
const createUserSchema = z.object({
  name: z.string().min(1),
  email: z.string().email(),
})

// Type-safe route
const route = app.post(
  '/users',
  zValidator('json', createUserSchema),
  async (c) => {
    const { name, email } = c.req.valid('json')
    // name and email are typed!
    return c.json({ id: 1, name, email })
  }
)

// Export type for client
export type AppType = typeof route
```

### Step 4: Client RPC (Type-safe API Calls)

```typescript
import { hc } from 'hono/client'
import type { AppType } from './server'

const client = hc<AppType>('http://localhost:3000')

// Fully typed!
const res = await client.users.$post({
  json: {
    name: 'John',
    email: 'john@example.com',
  },
})

const data = await res.json()
// data is typed as { id: number; name: string; email: string }
```

### Step 5: Grouped Routes

```typescript
import { Hono } from 'hono'

const app = new Hono()

// User routes
const users = new Hono()
users.get('/', (c) => c.json({ users: [] }))
users.get('/:id', (c) => c.json({ user: c.req.param('id') }))
users.post('/', (c) => c.json({ created: true }))

// Post routes
const posts = new Hono()
posts.get('/', (c) => c.json({ posts: [] }))

// Mount
app.route('/api/users', users)
app.route('/api/posts', posts)

export default app
```

### Step 6: Context and Bindings (Cloudflare)

```typescript
type Bindings = {
  DB: D1Database
  BUCKET: R2Bucket
  KV: KVNamespace
  API_KEY: string
}

type Variables = {
  user: { id: string; email: string }
}

const app = new Hono<{ Bindings: Bindings; Variables: Variables }>()

// Access bindings
app.get('/data', async (c) => {
  const { results } = await c.env.DB.prepare('SELECT * FROM users').all()
  return c.json(results)
})

// Set/get variables
app.use('*', async (c, next) => {
  c.set('user', { id: '1', email: 'user@example.com' })
  await next()
})

app.get('/me', (c) => {
  const user = c.get('user')
  return c.json(user)
})
```

## Best Practices

### ✅ Do This

- ✅ Use Zod validator for request validation
- ✅ Leverage RPC for type-safe client-server communication
- ✅ Use built-in middleware (cors, logger, etc.)
- ✅ Group related routes with `app.route()`
- ✅ Type your bindings and variables

### ❌ Avoid This

- ❌ Don't skip error handling middleware
- ❌ Don't use heavy dependencies that increase bundle size
- ❌ Don't ignore TypeScript types for routes
- ❌ Don't hardcode secrets in code

## Common Pitfalls

**Problem:** Types not inferred in route handlers
**Solution:** Ensure proper generic types on Hono instance

**Problem:** Middleware not executing in order
**Solution:** Register middleware before routes, use `app.use()` correctly

**Problem:** CORS issues in browser
**Solution:** Add cors middleware with proper origins

## Related Skills

- `@cloudflare-developer` - Cloudflare Workers deployment
- `@bun-developer` - Bun runtime
- `@deno-developer` - Deno runtime
- `@htmx-developer` - HTMX for server-rendered UIs

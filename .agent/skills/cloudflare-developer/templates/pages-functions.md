# Cloudflare Pages Functions

## Project Structure

```text
my-pages-site/
├── public/           # Static assets
├── src/              # Frontend source
├── functions/        # Pages Functions (API routes)
│   ├── api/
│   │   ├── users/
│   │   │   ├── index.ts         # GET/POST /api/users
│   │   │   └── [id].ts          # GET/PUT/DELETE /api/users/:id
│   │   └── posts/
│   │       └── index.ts
│   ├── _middleware.ts            # Global middleware
│   └── [[catchall]].ts           # Catch-all route
├── wrangler.toml
└── package.json
```

## Basic Function

```typescript
// functions/api/hello.ts
export const onRequest: PagesFunction = async (context) => {
  return new Response(JSON.stringify({
    message: 'Hello from Pages Functions!',
    timestamp: Date.now()
  }), {
    headers: { 'Content-Type': 'application/json' }
  })
}
```

## HTTP Method Handlers

```typescript
// functions/api/users/index.ts
interface Env {
  DB: D1Database
}

// GET /api/users
export const onRequestGet: PagesFunction<Env> = async ({ env, request }) => {
  const url = new URL(request.url)
  const limit = parseInt(url.searchParams.get('limit') || '20')
  const offset = parseInt(url.searchParams.get('offset') || '0')
  
  const { results } = await env.DB.prepare(
    'SELECT * FROM users ORDER BY created_at DESC LIMIT ? OFFSET ?'
  ).bind(limit, offset).all()
  
  return Response.json({ data: results })
}

// POST /api/users
export const onRequestPost: PagesFunction<Env> = async ({ env, request }) => {
  const body = await request.json<{ name: string; email: string }>()
  
  if (!body.name || !body.email) {
    return Response.json({ error: 'Name and email required' }, { status: 400 })
  }
  
  const id = crypto.randomUUID()
  await env.DB.prepare(
    'INSERT INTO users (id, name, email) VALUES (?, ?, ?)'
  ).bind(id, body.name, body.email).run()
  
  return Response.json({ id, ...body }, { status: 201 })
}
```

## Dynamic Routes

```typescript
// functions/api/users/[id].ts
interface Env {
  DB: D1Database
}

// GET /api/users/:id
export const onRequestGet: PagesFunction<Env> = async ({ env, params }) => {
  const { id } = params
  
  const user = await env.DB.prepare(
    'SELECT * FROM users WHERE id = ?'
  ).bind(id).first()
  
  if (!user) {
    return Response.json({ error: 'User not found' }, { status: 404 })
  }
  
  return Response.json({ data: user })
}

// PUT /api/users/:id
export const onRequestPut: PagesFunction<Env> = async ({ env, params, request }) => {
  const { id } = params
  const body = await request.json<{ name?: string; email?: string }>()
  
  await env.DB.prepare(
    'UPDATE users SET name = COALESCE(?, name), email = COALESCE(?, email) WHERE id = ?'
  ).bind(body.name || null, body.email || null, id).run()
  
  return Response.json({ success: true })
}

// DELETE /api/users/:id
export const onRequestDelete: PagesFunction<Env> = async ({ env, params }) => {
  const { id } = params
  await env.DB.prepare('DELETE FROM users WHERE id = ?').bind(id).run()
  return Response.json({ success: true })
}
```

## Middleware

```typescript
// functions/_middleware.ts
interface Env {
  API_SECRET: string
}

// Global middleware for all routes
export const onRequest: PagesFunction<Env>[] = [
  // CORS middleware
  async ({ request, next }) => {
    const response = await next()
    
    response.headers.set('Access-Control-Allow-Origin', '*')
    response.headers.set('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, OPTIONS')
    response.headers.set('Access-Control-Allow-Headers', 'Content-Type, Authorization')
    
    return response
  },
  
  // Auth middleware
  async ({ request, env, next }) => {
    // Skip auth for OPTIONS requests
    if (request.method === 'OPTIONS') {
      return new Response(null, { status: 204 })
    }
    
    // Skip auth for public routes
    const url = new URL(request.url)
    if (url.pathname.startsWith('/api/public')) {
      return next()
    }
    
    const authHeader = request.headers.get('Authorization')
    if (!authHeader?.startsWith('Bearer ')) {
      return Response.json({ error: 'Unauthorized' }, { status: 401 })
    }
    
    const token = authHeader.slice(7)
    if (token !== env.API_SECRET) {
      return Response.json({ error: 'Invalid token' }, { status: 403 })
    }
    
    return next()
  },
  
  // Request logging
  async ({ request, next }) => {
    const start = Date.now()
    const response = await next()
    const duration = Date.now() - start
    
    console.log(`${request.method} ${new URL(request.url).pathname} - ${response.status} (${duration}ms)`)
    
    return response
  }
]
```

## Error Handling

```typescript
// functions/api/_middleware.ts
export const onRequest: PagesFunction = async ({ next }) => {
  try {
    return await next()
  } catch (error) {
    console.error('API Error:', error)
    
    if (error instanceof SyntaxError) {
      return Response.json({ error: 'Invalid JSON' }, { status: 400 })
    }
    
    return Response.json(
      { error: 'Internal Server Error' },
      { status: 500 }
    )
  }
}
```

## wrangler.toml for Pages

```toml
name = "my-pages-site"
pages_build_output_dir = "dist"

# D1 Database
[[d1_databases]]
binding = "DB"
database_name = "my-db"
database_id = "xxx"

# KV Namespace
[[kv_namespaces]]
binding = "KV"
id = "xxx"

# R2 Bucket
[[r2_buckets]]
binding = "BUCKET"
bucket_name = "my-bucket"

# Environment variables
[vars]
ENVIRONMENT = "production"
```

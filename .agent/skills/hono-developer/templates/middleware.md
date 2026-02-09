# Hono Middleware Patterns

## Built-in Middleware

```typescript
import { Hono } from 'hono'
import { cors } from 'hono/cors'
import { logger } from 'hono/logger'
import { prettyJSON } from 'hono/pretty-json'
import { secureHeaders } from 'hono/secure-headers'
import { compress } from 'hono/compress'
import { etag } from 'hono/etag'
import { timing } from 'hono/timing'
import { basicAuth } from 'hono/basic-auth'
import { bearerAuth } from 'hono/bearer-auth'

const app = new Hono()

// Logging
app.use('*', logger())

// CORS
app.use('/api/*', cors({
  origin: ['https://example.com', 'https://www.example.com'],
  allowMethods: ['GET', 'POST', 'PUT', 'DELETE'],
  allowHeaders: ['Content-Type', 'Authorization'],
  exposeHeaders: ['X-Total-Count'],
  credentials: true,
  maxAge: 86400,
}))

// Security headers
app.use('*', secureHeaders())

// Compression
app.use('*', compress())

// ETag
app.use('*', etag())

// Timing
app.use('*', timing())

// Pretty JSON
app.use('*', prettyJSON())

// Basic Auth
app.use('/admin/*', basicAuth({
  username: 'admin',
  password: 'password',
}))

// Bearer Auth
app.use('/api/*', bearerAuth({
  token: 'my-secret-token',
}))
```

## Custom Middleware

```typescript
import { Hono, Context, Next } from 'hono'

// Simple middleware
const customLogger = async (c: Context, next: Next) => {
  const start = Date.now()
  console.log(`--> ${c.req.method} ${c.req.url}`)
  
  await next()
  
  const duration = Date.now() - start
  console.log(`<-- ${c.req.method} ${c.req.url} ${c.res.status} ${duration}ms`)
}

app.use('*', customLogger)

// Middleware factory
const rateLimit = (limit: number, windowMs: number) => {
  const requests = new Map<string, number[]>()
  
  return async (c: Context, next: Next) => {
    const ip = c.req.header('CF-Connecting-IP') || 'unknown'
    const now = Date.now()
    const windowStart = now - windowMs
    
    const userRequests = requests.get(ip) || []
    const recentRequests = userRequests.filter(t => t > windowStart)
    
    if (recentRequests.length >= limit) {
      return c.json({ error: 'Too many requests' }, 429)
    }
    
    recentRequests.push(now)
    requests.set(ip, recentRequests)
    
    await next()
  }
}

app.use('/api/*', rateLimit(100, 60000)) // 100 req/min
```

## Authentication Middleware

```typescript
import { Hono } from 'hono'
import { jwt, sign, verify } from 'hono/jwt'
import { getCookie, setCookie } from 'hono/cookie'

type Variables = {
  user: { id: string; email: string; role: string }
}

const app = new Hono<{ Variables: Variables }>()
const JWT_SECRET = 'your-secret-key'

// JWT middleware
app.use('/api/*', jwt({
  secret: JWT_SECRET,
}))

// Access JWT payload
app.get('/api/me', (c) => {
  const payload = c.get('jwtPayload')
  return c.json(payload)
})

// Login route
app.post('/login', async (c) => {
  const { email, password } = await c.req.json()
  
  // Validate credentials...
  const user = { id: '1', email, role: 'user' }
  
  const token = await sign(
    { sub: user.id, email: user.email, role: user.role, exp: Math.floor(Date.now() / 1000) + 60 * 60 * 24 },
    JWT_SECRET
  )
  
  // Set as cookie
  setCookie(c, 'token', token, {
    httpOnly: true,
    secure: true,
    sameSite: 'Strict',
    maxAge: 60 * 60 * 24,
  })
  
  return c.json({ token })
})

// Custom auth middleware with role check
const requireRole = (...roles: string[]) => {
  return async (c: Context, next: Next) => {
    const payload = c.get('jwtPayload')
    
    if (!roles.includes(payload.role)) {
      return c.json({ error: 'Forbidden' }, 403)
    }
    
    await next()
  }
}

app.get('/admin/dashboard', requireRole('admin'), (c) => {
  return c.json({ message: 'Admin dashboard' })
})
```

## Error Handling

```typescript
import { Hono, HTTPException } from 'hono'

const app = new Hono()

// Custom error class
class AppError extends Error {
  constructor(
    public statusCode: number,
    public code: string,
    message: string
  ) {
    super(message)
  }
}

// Error handler middleware
app.onError((err, c) => {
  console.error('Error:', err)
  
  if (err instanceof HTTPException) {
    return c.json({ error: err.message }, err.status)
  }
  
  if (err instanceof AppError) {
    return c.json({
      error: {
        code: err.code,
        message: err.message,
      }
    }, err.statusCode)
  }
  
  return c.json({ error: 'Internal Server Error' }, 500)
})

// 404 handler
app.notFound((c) => {
  return c.json({ error: 'Not Found' }, 404)
})

// Throw errors in routes
app.get('/protected', (c) => {
  throw new HTTPException(401, { message: 'Unauthorized' })
})
```

## Request Validation with Zod

```typescript
import { Hono } from 'hono'
import { zValidator } from '@hono/zod-validator'
import { z } from 'zod'

const app = new Hono()

// Schemas
const createUserSchema = z.object({
  name: z.string().min(1).max(100),
  email: z.string().email(),
  age: z.number().min(0).max(150).optional(),
})

const querySchema = z.object({
  page: z.string().transform(Number).pipe(z.number().min(1)).optional(),
  limit: z.string().transform(Number).pipe(z.number().min(1).max(100)).optional(),
  search: z.string().optional(),
})

const paramsSchema = z.object({
  id: z.string().uuid(),
})

// Validate JSON body
app.post('/users', zValidator('json', createUserSchema), async (c) => {
  const data = c.req.valid('json')
  // data is typed!
  return c.json({ user: data }, 201)
})

// Validate query params
app.get('/users', zValidator('query', querySchema), async (c) => {
  const { page = 1, limit = 20, search } = c.req.valid('query')
  return c.json({ page, limit, search })
})

// Validate URL params
app.get('/users/:id', zValidator('param', paramsSchema), async (c) => {
  const { id } = c.req.valid('param')
  return c.json({ userId: id })
})

// Multiple validators
app.put(
  '/users/:id',
  zValidator('param', paramsSchema),
  zValidator('json', createUserSchema.partial()),
  async (c) => {
    const { id } = c.req.valid('param')
    const data = c.req.valid('json')
    return c.json({ id, ...data })
  }
)
```

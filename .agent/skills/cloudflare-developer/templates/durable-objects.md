# Durable Objects

## Basic Durable Object

```typescript
// src/objects/Counter.ts
export class Counter {
  private state: DurableObjectState
  private value: number = 0

  constructor(state: DurableObjectState) {
    this.state = state
    // Load persisted value
    this.state.blockConcurrencyWhile(async () => {
      this.value = (await this.state.storage.get<number>('value')) || 0
    })
  }

  async fetch(request: Request): Promise<Response> {
    const url = new URL(request.url)
    
    switch (url.pathname) {
      case '/increment':
        this.value++
        await this.state.storage.put('value', this.value)
        return new Response(String(this.value))
        
      case '/decrement':
        this.value--
        await this.state.storage.put('value', this.value)
        return new Response(String(this.value))
        
      case '/value':
        return new Response(String(this.value))
        
      default:
        return new Response('Not Found', { status: 404 })
    }
  }
}

// wrangler.toml
// [[durable_objects.bindings]]
// name = "COUNTER"
// class_name = "Counter"
//
// [[migrations]]
// tag = "v1"
// new_classes = ["Counter"]
```

## WebSocket Chat Room

```typescript
// src/objects/ChatRoom.ts
export class ChatRoom {
  private state: DurableObjectState
  private sessions: Map<WebSocket, { name: string }> = new Map()

  constructor(state: DurableObjectState) {
    this.state = state
  }

  async fetch(request: Request): Promise<Response> {
    const url = new URL(request.url)
    
    if (url.pathname === '/websocket') {
      if (request.headers.get('Upgrade') !== 'websocket') {
        return new Response('Expected WebSocket', { status: 400 })
      }
      
      const pair = new WebSocketPair()
      const [client, server] = Object.values(pair)
      
      await this.handleSession(server, url.searchParams.get('name') || 'Anonymous')
      
      return new Response(null, { status: 101, webSocket: client })
    }
    
    return new Response('Not Found', { status: 404 })
  }

  async handleSession(ws: WebSocket, name: string): Promise<void> {
    ws.accept()
    
    this.sessions.set(ws, { name })
    this.broadcast({ type: 'join', name, count: this.sessions.size })
    
    ws.addEventListener('message', async (event) => {
      const data = JSON.parse(event.data as string)
      
      if (data.type === 'message') {
        this.broadcast({
          type: 'message',
          name,
          text: data.text,
          timestamp: Date.now()
        })
      }
    })
    
    ws.addEventListener('close', () => {
      this.sessions.delete(ws)
      this.broadcast({ type: 'leave', name, count: this.sessions.size })
    })
    
    ws.addEventListener('error', () => {
      this.sessions.delete(ws)
    })
  }

  broadcast(message: object): void {
    const json = JSON.stringify(message)
    for (const [ws] of this.sessions) {
      try {
        ws.send(json)
      } catch {
        this.sessions.delete(ws)
      }
    }
  }
}

// Worker to connect to ChatRoom
export default {
  async fetch(request: Request, env: Env): Promise<Response> {
    const url = new URL(request.url)
    
    if (url.pathname.startsWith('/room/')) {
      const roomId = url.pathname.split('/')[2]
      const id = env.CHAT_ROOM.idFromName(roomId)
      const room = env.CHAT_ROOM.get(id)
      
      const newUrl = new URL(request.url)
      newUrl.pathname = '/websocket'
      
      return room.fetch(new Request(newUrl.toString(), request))
    }
    
    return new Response('Not Found', { status: 404 })
  }
}
```

## Rate Limiter Durable Object

```typescript
export class RateLimiter {
  private state: DurableObjectState
  private requests: number[] = []
  private readonly limit = 100
  private readonly windowMs = 60000 // 1 minute

  constructor(state: DurableObjectState) {
    this.state = state
    this.state.blockConcurrencyWhile(async () => {
      this.requests = (await this.state.storage.get<number[]>('requests')) || []
    })
  }

  async fetch(request: Request): Promise<Response> {
    const now = Date.now()
    
    // Clean old requests
    this.requests = this.requests.filter(t => now - t < this.windowMs)
    
    if (this.requests.length >= this.limit) {
      return new Response(JSON.stringify({
        allowed: false,
        remaining: 0,
        resetAt: this.requests[0] + this.windowMs
      }), {
        status: 429,
        headers: { 'Content-Type': 'application/json' }
      })
    }
    
    this.requests.push(now)
    await this.state.storage.put('requests', this.requests)
    
    return new Response(JSON.stringify({
      allowed: true,
      remaining: this.limit - this.requests.length,
      resetAt: now + this.windowMs
    }), {
      headers: { 'Content-Type': 'application/json' }
    })
  }
}

// Usage in Worker
async function checkRateLimit(env: Env, identifier: string): Promise<boolean> {
  const id = env.RATE_LIMITER.idFromName(identifier)
  const limiter = env.RATE_LIMITER.get(id)
  const response = await limiter.fetch(new Request('https://dummy/check'))
  const result = await response.json<{ allowed: boolean }>()
  return result.allowed
}
```

## Distributed Lock

```typescript
export class DistributedLock {
  private state: DurableObjectState
  private locked: boolean = false
  private lockHolder: string | null = null
  private waitQueue: Array<{ resolve: () => void }> = []

  constructor(state: DurableObjectState) {
    this.state = state
  }

  async fetch(request: Request): Promise<Response> {
    const url = new URL(request.url)
    const clientId = url.searchParams.get('clientId')
    
    switch (url.pathname) {
      case '/acquire':
        return this.acquire(clientId!)
        
      case '/release':
        return this.release(clientId!)
        
      case '/status':
        return new Response(JSON.stringify({
          locked: this.locked,
          holder: this.lockHolder,
          waiting: this.waitQueue.length
        }))
        
      default:
        return new Response('Not Found', { status: 404 })
    }
  }

  async acquire(clientId: string): Promise<Response> {
    if (!this.locked) {
      this.locked = true
      this.lockHolder = clientId
      return new Response(JSON.stringify({ acquired: true }))
    }
    
    // Wait for lock
    await new Promise<void>(resolve => {
      this.waitQueue.push({ resolve })
    })
    
    this.locked = true
    this.lockHolder = clientId
    return new Response(JSON.stringify({ acquired: true }))
  }

  release(clientId: string): Response {
    if (this.lockHolder !== clientId) {
      return new Response(JSON.stringify({ error: 'Not lock holder' }), { status: 403 })
    }
    
    this.locked = false
    this.lockHolder = null
    
    // Wake next waiter
    const next = this.waitQueue.shift()
    if (next) {
      next.resolve()
    }
    
    return new Response(JSON.stringify({ released: true }))
  }
}
```

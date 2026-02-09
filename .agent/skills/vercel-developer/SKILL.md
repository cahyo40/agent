---
name: vercel-developer
description: "Expert Vercel development including Edge Functions, serverless deployment, Vercel AI SDK, and production optimization"
---

# Vercel Developer

## Overview

Deploy and optimize web applications on Vercel's edge platform. This skill covers Edge Functions, serverless deployment, Vercel AI SDK integration, and best practices for production-ready applications.

## When to Use This Skill

- Use when deploying Next.js applications to Vercel
- Use when implementing Edge Functions
- Use when using Vercel AI SDK for streaming
- Use when optimizing for Vercel's infrastructure
- Use when configuring Vercel projects

## Templates Reference

| Template | Description |
|----------|-------------|
| [edge-functions.md](templates/edge-functions.md) | Edge Functions patterns |
| [vercel-ai-sdk.md](templates/vercel-ai-sdk.md) | AI SDK integration |
| [deployment.md](templates/deployment.md) | Deployment configuration |

## How It Works

### Step 1: vercel.json Configuration

```json
{
  "framework": "nextjs",
  "buildCommand": "next build",
  "outputDirectory": ".next",
  "regions": ["iad1", "sfo1", "sin1"],
  "functions": {
    "app/api/**/*.ts": {
      "maxDuration": 60,
      "memory": 1024
    }
  },
  "crons": [
    {
      "path": "/api/cron/cleanup",
      "schedule": "0 0 * * *"
    }
  ],
  "headers": [
    {
      "source": "/api/(.*)",
      "headers": [
        { "key": "Access-Control-Allow-Origin", "value": "*" }
      ]
    }
  ],
  "rewrites": [
    { "source": "/api/v1/:path*", "destination": "/api/:path*" }
  ]
}
```

### Step 2: Edge Functions

```typescript
// app/api/edge/route.ts
export const runtime = 'edge'
export const preferredRegion = ['iad1', 'sfo1']

export async function GET(request: Request) {
  const { searchParams } = new URL(request.url)
  const name = searchParams.get('name') || 'World'
  
  return new Response(JSON.stringify({ message: `Hello ${name}!` }), {
    headers: { 'Content-Type': 'application/json' },
  })
}

// With geolocation
export async function GET(request: Request) {
  const geo = request.geo
  
  return new Response(JSON.stringify({
    country: geo?.country,
    city: geo?.city,
    region: geo?.region,
  }))
}
```

### Step 3: Vercel AI SDK

```bash
npm install ai @ai-sdk/openai
```

```typescript
// app/api/chat/route.ts
import { openai } from '@ai-sdk/openai'
import { streamText } from 'ai'

export const runtime = 'edge'

export async function POST(req: Request) {
  const { messages } = await req.json()
  
  const result = await streamText({
    model: openai('gpt-4-turbo'),
    messages,
    temperature: 0.7,
    maxTokens: 1000,
  })
  
  return result.toDataStreamResponse()
}

// Client usage
'use client'
import { useChat } from 'ai/react'

export function Chat() {
  const { messages, input, handleInputChange, handleSubmit, isLoading } = useChat()
  
  return (
    <form onSubmit={handleSubmit}>
      <div>
        {messages.map(m => (
          <div key={m.id}>
            <strong>{m.role}:</strong> {m.content}
          </div>
        ))}
      </div>
      <input
        value={input}
        onChange={handleInputChange}
        placeholder="Send a message..."
        disabled={isLoading}
      />
    </form>
  )
}
```

### Step 4: Serverless Functions

```typescript
// app/api/users/route.ts
import { NextResponse } from 'next/server'

export async function GET() {
  const users = await db.query.users.findMany()
  return NextResponse.json(users)
}

export async function POST(request: Request) {
  const body = await request.json()
  const user = await db.insert(users).values(body).returning()
  return NextResponse.json(user, { status: 201 })
}

// With caching
export async function GET() {
  const data = await fetch('https://api.example.com/data', {
    next: { revalidate: 60 }, // Cache for 60 seconds
  })
  
  return NextResponse.json(await data.json())
}
```

### Step 5: Environment Variables

```bash
# Local development
vercel env pull .env.local

# Add secrets
vercel env add DATABASE_URL production
vercel env add API_KEY preview development

# List environment variables
vercel env ls
```

```typescript
// Access in code
const dbUrl = process.env.DATABASE_URL
const apiKey = process.env.API_KEY

// Edge runtime can access env vars
export const runtime = 'edge'
export async function GET() {
  const secret = process.env.SECRET_KEY // Works in edge
}
```

### Step 6: Cron Jobs

```typescript
// app/api/cron/cleanup/route.ts
import { NextResponse } from 'next/server'

export async function GET(request: Request) {
  // Verify cron secret
  const authHeader = request.headers.get('Authorization')
  if (authHeader !== `Bearer ${process.env.CRON_SECRET}`) {
    return NextResponse.json({ error: 'Unauthorized' }, { status: 401 })
  }
  
  // Run cleanup
  await db.delete(sessions).where(lt(sessions.expiresAt, new Date()))
  
  return NextResponse.json({ success: true })
}
```

## Best Practices

### ✅ Do This

- ✅ Use Edge Functions for low-latency endpoints
- ✅ Configure regions close to your users
- ✅ Use Vercel's built-in caching
- ✅ Set appropriate function timeouts
- ✅ Use environment variables for secrets

### ❌ Avoid This

- ❌ Don't exceed function duration limits
- ❌ Don't hardcode secrets
- ❌ Don't ignore cold start optimization
- ❌ Don't skip error handling
- ❌ Don't forget to set up monitoring

## Common Pitfalls

**Problem:** Edge Function timeout
**Solution:** Edge has 30s limit; use serverless for longer operations

**Problem:** Build fails on Vercel
**Solution:** Check Node.js version, dependencies compatibility

**Problem:** Environment variables not available
**Solution:** Verify env is set for correct environment (production/preview/development)

## Related Skills

- `@senior-nextjs-developer` - Next.js patterns
- `@cloudflare-developer` - Alternative edge platform
- `@senior-ai-agent-developer` - AI integration

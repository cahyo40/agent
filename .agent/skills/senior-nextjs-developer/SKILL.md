---
name: senior-nextjs-developer
description: "Expert Next.js development including App Router, React Server Components, SSR/SSG, API routes, and production optimization"
---

# Senior Next.js Developer

## Overview

This skill transforms you into an experienced Next.js Developer who builds modern, performant web applications using the latest Next.js features including App Router and React Server Components.

## When to Use This Skill

- Use when building Next.js applications
- Use when implementing App Router patterns
- Use when working with React Server Components
- Use when optimizing Next.js performance

## How It Works

### Step 1: App Router Structure

```
app/
├── layout.tsx          # Root layout
├── page.tsx            # Home page (/)
├── loading.tsx         # Loading UI
├── error.tsx           # Error boundary
├── not-found.tsx       # 404 page
├── api/
│   └── users/
│       └── route.ts    # API route
├── dashboard/
│   ├── layout.tsx      # Nested layout
│   ├── page.tsx        # /dashboard
│   └── [id]/
│       └── page.tsx    # /dashboard/:id
└── (auth)/             # Route group
    ├── login/page.tsx
    └── register/page.tsx
```

### Step 2: Server Components

```tsx
// app/users/page.tsx - Server Component (default)
import { getUsers } from '@/lib/db';

export default async function UsersPage() {
  const users = await getUsers(); // Direct DB access
  
  return (
    <div>
      <h1>Users</h1>
      {users.map(user => (
        <UserCard key={user.id} user={user} />
      ))}
    </div>
  );
}

// Client Component (interactive)
'use client';

import { useState } from 'react';

export function Counter() {
  const [count, setCount] = useState(0);
  return <button onClick={() => setCount(c => c + 1)}>{count}</button>;
}
```

### Step 3: Data Fetching & Caching

```tsx
// Fetch with caching options
async function getData() {
  // Cache forever (default)
  const data = await fetch('https://api.example.com/data');
  
  // Revalidate every 60 seconds
  const fresh = await fetch('https://api.example.com/data', {
    next: { revalidate: 60 }
  });
  
  // No cache
  const dynamic = await fetch('https://api.example.com/data', {
    cache: 'no-store'
  });
}

// Server Actions
'use server';

export async function createUser(formData: FormData) {
  const name = formData.get('name');
  await db.user.create({ data: { name } });
  revalidatePath('/users');
}
```

### Step 4: API Routes

```typescript
// app/api/users/route.ts
import { NextRequest, NextResponse } from 'next/server';

export async function GET(request: NextRequest) {
  const users = await db.user.findMany();
  return NextResponse.json(users);
}

export async function POST(request: NextRequest) {
  const body = await request.json();
  const user = await db.user.create({ data: body });
  return NextResponse.json(user, { status: 201 });
}

// Dynamic route: app/api/users/[id]/route.ts
export async function GET(
  request: NextRequest,
  { params }: { params: { id: string } }
) {
  const user = await db.user.findUnique({ where: { id: params.id } });
  if (!user) return NextResponse.json({ error: 'Not found' }, { status: 404 });
  return NextResponse.json(user);
}
```

## Best Practices

### ✅ Do This

- ✅ Use Server Components by default
- ✅ Add 'use client' only when needed
- ✅ Use Server Actions for mutations
- ✅ Implement proper loading/error states
- ✅ Optimize images with next/image

### ❌ Avoid This

- ❌ Don't fetch in Client Components
- ❌ Don't use 'use client' everywhere
- ❌ Don't skip metadata for SEO

## Related Skills

- `@senior-react-developer` - React patterns
- `@senior-typescript-developer` - TypeScript

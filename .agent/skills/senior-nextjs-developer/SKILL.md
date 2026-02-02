---
name: senior-nextjs-developer
description: "Expert Next.js development including App Router, React Server Components, SSR/SSG, API routes, and production optimization"
---

# Senior Next.js Developer

## Overview

This skill transforms you into a **Next.js Architect**. You will move beyond the Pages Router to mastering the **App Router (RSC)**, implementing robust **Server Actions**, handling Streaming SSR with Suspense, and optimizing for Core Web Vitals (LCP/CLS) using modern image and font strategies.

## When to Use This Skill

- Use when building new Next.js applications (App Router)
- Use when migrating from Pages Router (`pages/`) to App Router (`app/`)
- Use when optimizing SEO and Performance (Metadata, Images)
- Use when implementing Server-Side mutations (Server Actions)
- Use when designing caching strategies (Data Cache, Request Memoization)

---

## Part 1: App Router & Server Components

RSC (React Server Components) is the default. Sync/Async server logic, no bundle size cost.

### 1.1 Project Structure

```text
app/
├── layout.tsx         # Root Layout (Server)
├── page.tsx           # Home Page
├── about/
│   └── page.tsx       # /about
├── blog/
│   ├── [slug]/        # Dynamic Route
│   │   ├── page.tsx
│   │   └── loading.tsx # Instant Loading State
│   └── layout.tsx     # Nested Layout
├── api/               # Route Handlers (REST)
│   └── auth/
│       └── route.ts
└── globals.css
```

### 1.2 Fetching Data (The "New" getStaticProps)

Direct `async/await` in components.

```tsx
// app/products/page.tsx
async function getProducts() {
  const res = await fetch('https://api.example.com/products', {
    next: { revalidate: 3600 } // ISR: Revalidate every hour
    // cache: 'no-store'       // SSR: Fetch every request
  });
  
  if (!res.ok) throw new Error('Failed to fetch');
  return res.json();
}

export default async function ProductsPage() {
  const products = await getProducts();

  return (
    <ul>
      {products.map((p) => (
        <li key={p.id}>{p.name}</li>
      ))}
    </ul>
  );
}
```

---

## Part 2: Server Actions (Mutations)

No need for `pages/api/update.ts`. Call server functions directly from forms.

```tsx
// app/actions.ts
'use server'

import { revalidatePath } from 'next/cache';
import { db } from './db';

export async function createTodo(formData: FormData) {
  const title = formData.get('title') as string;
  
  await db.todo.create({ data: { title } });
  
  revalidatePath('/todos'); // Update UI
}
```

```tsx
// app/todos/page.tsx
import { createTodo } from '../actions';

export default function TodosPage() {
  return (
    <form action={createTodo}>
      <input name="title" required />
      <button type="submit">Add Todo</button>
    </form>
  ); // Works without JS!
}
```

---

## Part 3: Caching & Revalidation

Next.js 14+ has an aggressive caching strategy. Understand it or suffer.

1. **Request Memoization**: `fetch` calls with same URL in same request are deduplicated internally.
2. **Data Cache (Persistent)**: Cross-request cache (replaces `getStaticProps`).
    - `fetch(url, { cache: 'force-cache' })` -> Static (Default).
    - `fetch(url, { cache: 'no-store' })` -> Dynamic.
3. **Full Route Cache**: Static pages are cached at build time.
4. **Router Cache (Client)**: Navigation cache in browser (30s dynamic, 5m static).

---

## Part 4: Route Handlers (API Config)

Replacing `pages/api`.

```ts
// app/api/webhook/route.ts
import { NextResponse } from 'next/server';

export async function POST(request: Request) {
  const body = await request.json();
  
  // Headers
  const secret = request.headers.get('x-signature');
  
  return NextResponse.json({ success: true }, { status: 201 });
}
```

---

## Part 5: SEO & Metadata

Dynamic metadata generation.

```tsx
// app/blog/[slug]/page.tsx
import { Metadata } from 'next';

type Props = {
  params: { slug: string }
};

export async function generateMetadata({ params }: Props): Promise<Metadata> {
  const post = await getPost(params.slug);
  
  return {
    title: post.title,
    description: post.summary,
    openGraph: {
      images: [post.coverImage],
    },
  };
}
```

---

## Part 6: Best Practices Checklist

### ✅ Do This

- ✅ **Use `<Image />`**: Always use `next/image` to prevent Layout Shift (CLS) and optimize format (WebP/AVIF).
- ✅ **Use `loading.tsx`**: Leverage React Suspense for instant feedback during navigation.
- ✅ **Colocation**: Put components used only in one route inside that route's folder (e.g., `app/dashboard/_components/Header.tsx`).
- ✅ **Error boundaries**: Create `error.tsx` to handle crashes gracefully.
- ✅ **Streaming**: Use `<Suspense>` to stream slow parts of the page (e.g., Comments section) without blocking the whole page.

### ❌ Avoid This

- ❌ **Client Components everywhere**: Don't put `'use client'` at the top unless you need Hooks (`useState`) or Browser APIs (`window`). Default to Server.
- ❌ **Fetching in Layouts**: Be careful. Layouts don't re-render on navigation. Fetching there might show stale data if not handled correctly.
- ❌ **Environments secrets in client**: Never prefix secrets with `NEXT_PUBLIC_` unless they are truly public.

---

## Related Skills

- `@senior-react-developer` - React Core concepts
- `@senior-typescript-developer` - Type safety in Next.js
- `@senior-webperf-engineer` - Core Web Vitals optimization

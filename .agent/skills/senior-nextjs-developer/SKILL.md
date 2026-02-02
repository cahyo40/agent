---
name: senior-nextjs-developer
description: "Expert Next.js development including App Router, React Server Components, SSR/SSG, API routes, and production optimization"
---

# Senior Next.js Developer

## Overview

This skill transforms you into a **Next.js Architect**. You will master the **App Router with React Server Components**, implement **Server Actions**, handle streaming SSR, and optimize for Core Web Vitals.

## When to Use This Skill

- Use when building Next.js applications (App Router)
- Use when migrating from Pages Router to App Router
- Use when optimizing SEO and performance
- Use when implementing server-side mutations
- Use when designing caching strategies

---

## Part 1: Understanding Next.js Architecture

### 1.1 Pages Router vs App Router

| Feature | Pages Router | App Router |
|---------|--------------|------------|
| **Directory** | `pages/` | `app/` |
| **Components** | Client by default | Server by default |
| **Data Fetching** | `getStaticProps`, `getServerSideProps` | `async` components |
| **Layouts** | Manual, per-page | Nested, shared |
| **Streaming** | Limited | Full Suspense |
| **Mutations** | API Routes | Server Actions |

### 1.2 Rendering Strategies

```
┌─────────────────────────────────────────────────────────────┐
│                 Next.js Rendering Options                    │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  Static (SSG)          Dynamic (SSR)        Client (CSR)    │
│  ─────────────         ───────────────      ─────────────   │
│  Build time            Request time         Browser         │
│  Cached at CDN         Fresh data           Interactive     │
│                                                              │
│  ┌───────────────────────────────────────────────────────┐  │
│  │           React Server Components (RSC)                │  │
│  │           (No JS sent to client by default)            │  │
│  └───────────────────────────────────────────────────────┘  │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

### 1.3 When to Use Each Strategy

| Strategy | Use Case | Cache |
|----------|----------|-------|
| **Static (SSG)** | Blog, docs, marketing | `cache: 'force-cache'` |
| **ISR** | Products, listings | `{ revalidate: 3600 }` |
| **Dynamic (SSR)** | Personalized, auth | `cache: 'no-store'` |
| **Client** | Dashboards, interactive | `'use client'` |

---

## Part 2: Project Structure

### 2.1 App Router Structure

```text
app/
├── layout.tsx              # Root layout (RootLayout)
├── page.tsx                # Home page (/)
├── loading.tsx             # Loading UI
├── error.tsx               # Error boundary
├── not-found.tsx           # 404 page
├── globals.css
│
├── (marketing)/            # Route group (no URL segment)
│   ├── about/
│   │   └── page.tsx        # /about
│   └── pricing/
│       └── page.tsx        # /pricing
│
├── (dashboard)/            # Another route group
│   ├── layout.tsx          # Dashboard layout
│   └── dashboard/
│       └── page.tsx        # /dashboard
│
├── blog/
│   ├── page.tsx            # /blog
│   └── [slug]/             # Dynamic route
│       ├── page.tsx        # /blog/:slug
│       └── loading.tsx     # Specific loading
│
├── api/                    # Route Handlers
│   └── auth/
│       └── route.ts        # /api/auth
│
└── _components/            # Private components (ignored)
    └── Header.tsx
```

### 2.2 File Conventions

| File | Purpose |
|------|---------|
| `layout.tsx` | Shared UI, preserved on navigation |
| `page.tsx` | Unique route UI |
| `loading.tsx` | Suspense loading UI |
| `error.tsx` | Error boundary |
| `not-found.tsx` | 404 UI |
| `route.ts` | API endpoint |
| `template.tsx` | Re-rendered layout per navigation |

---

## Part 3: Server Components vs Client Components

### 3.1 Decision Guide

| Need | Component Type |
|------|---------------|
| Fetch data, access backend | Server Component |
| SEO content | Server Component |
| Static content | Server Component |
| Hooks (`useState`, `useEffect`) | Client Component |
| Browser APIs (`window`, `localStorage`) | Client Component |
| Event handlers (`onClick`) | Client Component |
| Third-party libraries (no RSC support) | Client Component |

### 3.2 Server Component (Default)

```tsx
// app/products/page.tsx (Server Component by default)
async function getProducts() {
  const res = await fetch('https://api.example.com/products', {
    next: { revalidate: 3600 } // ISR: Revalidate every hour
  });
  if (!res.ok) throw new Error('Failed to fetch');
  return res.json() as Promise<Product[]>;
}

export default async function ProductsPage() {
  const products = await getProducts();
  
  return (
    <main>
      <h1>Products</h1>
      <ProductList products={products} />
    </main>
  );
}
```

### 3.3 Client Component

```tsx
// components/AddToCart.tsx
'use client';

import { useState } from 'react';

export function AddToCart({ productId }: { productId: string }) {
  const [isAdding, setIsAdding] = useState(false);
  
  const handleClick = async () => {
    setIsAdding(true);
    await addToCart(productId);
    setIsAdding(false);
  };
  
  return (
    <button onClick={handleClick} disabled={isAdding}>
      {isAdding ? 'Adding...' : 'Add to Cart'}
    </button>
  );
}
```

### 3.4 Composition Pattern

Server Components can import Client Components, but not vice versa:

```tsx
// ✅ Server Component importing Client Component
// app/products/[id]/page.tsx
import { AddToCart } from '@/components/AddToCart'; // Client

export default async function ProductPage({ params }) {
  const product = await getProduct(params.id); // Server fetch
  
  return (
    <div>
      <h1>{product.name}</h1>
      <p>{product.description}</p>
      <AddToCart productId={product.id} /> {/* Client component */}
    </div>
  );
}
```

---

## Part 4: Data Fetching

### 4.1 Fetch Patterns

| Pattern | Syntax | Caching |
|---------|--------|---------|
| Static | `fetch(url)` | Cached indefinitely |
| ISR | `fetch(url, { next: { revalidate: 60 } })` | Revalidate after 60s |
| Dynamic | `fetch(url, { cache: 'no-store' })` | Fresh every request |
| Tags | `fetch(url, { next: { tags: ['products'] } })` | On-demand revalidation |

### 4.2 Parallel Data Fetching

```tsx
export default async function Dashboard() {
  // ✅ Parallel fetching (fast)
  const [user, orders, analytics] = await Promise.all([
    getUser(),
    getOrders(),
    getAnalytics(),
  ]);
  
  return (
    <div>
      <UserCard user={user} />
      <OrdersTable orders={orders} />
      <AnalyticsChart data={analytics} />
    </div>
  );
}
```

---

## Part 5: Server Actions

### 5.1 Creating Server Actions

```tsx
// app/actions.ts
'use server';

import { revalidatePath, revalidateTag } from 'next/cache';
import { redirect } from 'next/navigation';
import { z } from 'zod';

const CreateTodoSchema = z.object({
  title: z.string().min(1).max(100),
});

export async function createTodo(formData: FormData) {
  const validatedFields = CreateTodoSchema.safeParse({
    title: formData.get('title'),
  });
  
  if (!validatedFields.success) {
    return { error: 'Invalid input' };
  }
  
  await db.todo.create({ data: validatedFields.data });
  
  revalidatePath('/todos');
  // or revalidateTag('todos');
}

export async function deleteTodo(id: string) {
  await db.todo.delete({ where: { id } });
  revalidatePath('/todos');
}
```

### 5.2 Using Server Actions in Forms

```tsx
// app/todos/page.tsx
import { createTodo } from '../actions';

export default function TodosPage() {
  return (
    <form action={createTodo}>
      <input name="title" placeholder="New todo" required />
      <button type="submit">Add</button>
    </form>
  );
}
```

### 5.3 With useFormStatus

```tsx
// components/SubmitButton.tsx
'use client';

import { useFormStatus } from 'react-dom';

export function SubmitButton() {
  const { pending } = useFormStatus();
  
  return (
    <button type="submit" disabled={pending}>
      {pending ? 'Saving...' : 'Save'}
    </button>
  );
}
```

---

## Part 6: Caching Explained

### 6.1 Next.js Caching Layers

| Layer | Description | Scope |
|-------|-------------|-------|
| **Request Memoization** | Deduplicates same fetch in single render | Single request |
| **Data Cache** | Persists fetch across requests | Permanent until revalidate |
| **Full Route Cache** | Static HTML at build time | Build-time |
| **Router Cache** | Client-side navigation cache | 30s dynamic, 5m static |

### 6.2 Revalidation Strategies

```tsx
// Time-based revalidation
fetch(url, { next: { revalidate: 60 } });

// On-demand revalidation
import { revalidatePath, revalidateTag } from 'next/cache';

// Revalidate specific path
revalidatePath('/products');

// Revalidate by tag
revalidateTag('products');

// In Route Handler
export async function POST() {
  revalidateTag('products');
  return Response.json({ revalidated: true });
}
```

---

## Part 7: SEO & Metadata

### 7.1 Static Metadata

```tsx
// app/layout.tsx
import { Metadata } from 'next';

export const metadata: Metadata = {
  title: {
    default: 'My App',
    template: '%s | My App',
  },
  description: 'The best app ever',
  openGraph: {
    images: '/og-image.png',
  },
};
```

### 7.2 Dynamic Metadata

```tsx
// app/blog/[slug]/page.tsx
import { Metadata } from 'next';

type Props = { params: { slug: string } };

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

## Part 8: Best Practices Summary

### ✅ Do This

- ✅ **Default to Server Components** - Only add `'use client'` when needed
- ✅ **Use `<Image />`** - Prevents CLS, optimizes format
- ✅ **Create `loading.tsx`** - Instant feedback
- ✅ **Create `error.tsx`** - Graceful error handling
- ✅ **Use Suspense** - Stream slow parts without blocking
- ✅ **Colocate components** - Put feature components in route folders

### ❌ Avoid This

- ❌ **Client Components everywhere** - Ruins RSC benefits
- ❌ **Fetching in Layouts** - Layouts don't re-render on nav
- ❌ **`NEXT_PUBLIC_` for secrets** - Only for truly public values
- ❌ **Ignoring caching** - Understand the 4 cache layers

---

## Quick Reference

| Task | Solution |
|------|----------|
| Data fetching | `async/await` in Server Components |
| Mutations | Server Actions |
| Client interactivity | `'use client'` components |
| Revalidation | `revalidatePath`, `revalidateTag` |
| API endpoints | Route Handlers (`route.ts`) |
| Loading states | `loading.tsx` or `<Suspense>` |

---

## Related Skills

- `@senior-react-developer` - React patterns
- `@senior-typescript-developer` - Type safety
- `@senior-webperf-engineer` - Core Web Vitals
- `@senior-tailwindcss-developer` - Styling

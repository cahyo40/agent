---
name: nuxt-developer
description: "Expert Nuxt.js development including Vue 3, SSR/SSG, API routes, and production-ready full-stack applications"
---

# Nuxt Developer

## Overview

This skill transforms you into an **Expert Nuxt.js Developer** capable of building full-stack Vue 3 applications with SSR, SSG, API routes, and production-grade architecture.

## When to Use This Skill

- Use when building Vue.js full-stack applications
- Use when needing SSR/SSG with Vue
- Use when building API routes with Vue ecosystem
- Use when migrating from Nuxt 2 to Nuxt 3

---

## Part 1: Nuxt 3 Architecture

### 1.1 Nuxt 3 vs Nuxt 2

| Feature | Nuxt 2 | Nuxt 3 |
|---------|--------|--------|
| **Vue Version** | Vue 2 | Vue 3 |
| **API Style** | Options API | Composition API |
| **Build Tool** | Webpack | Vite (default) |
| **Server** | Connect | Nitro |
| **TypeScript** | Add-on | Built-in |
| **State** | Vuex | Pinia |
| **Auto-imports** | Limited | Full |

### 1.2 Rendering Modes

| Mode | Description | Use Case |
|------|-------------|----------|
| **SSR** | Server-side rendering | Dynamic content, SEO |
| **SSG** | Static site generation | Blog, docs |
| **SPA** | Client-side only | Dashboards |
| **Hybrid** | Per-route rendering | Mixed requirements |

### 1.3 The Nitro Engine

Nitro is Nuxt 3's server engine providing:

- Universal deployment (Node, Edge, Serverless)
- API routes with file-based routing
- Auto-imported server utilities
- Hot module replacement for server code

---

## Part 2: Project Structure

### 2.1 Directory Structure

```text
my-nuxt-app/
├── .nuxt/                  # Build output (gitignored)
├── assets/                 # Uncompiled assets (Vite)
├── components/             # Auto-imported Vue components
│   ├── ui/                 # Base components
│   └── layout/             # Layout components
├── composables/            # Auto-imported composables
├── layouts/                # Page layouts
├── middleware/             # Route middleware
├── pages/                  # File-based routing
│   ├── index.vue           # /
│   ├── about.vue           # /about
│   └── blog/
│       ├── index.vue       # /blog
│       └── [slug].vue      # /blog/:slug
├── plugins/                # Vue plugins
├── public/                 # Static files (served as-is)
├── server/                 # Nitro server
│   ├── api/                # API routes
│   ├── middleware/         # Server middleware
│   └── plugins/            # Server plugins
├── stores/                 # Pinia stores
├── types/                  # TypeScript types
├── nuxt.config.ts          # Nuxt configuration
├── app.vue                 # Root component
└── error.vue               # Error page
```

### 2.2 Auto-Import Feature

| Directory | Auto-Imported | Scope |
|-----------|---------------|-------|
| `components/` | Vue components | Templates |
| `composables/` | Composition functions | `<script setup>` |
| `utils/` | Utility functions | `<script setup>` |
| `stores/` | Pinia stores | `<script setup>` |

---

## Part 3: Routing

### 3.1 File-Based Routing

| File | Route |
|------|-------|
| `pages/index.vue` | `/` |
| `pages/about.vue` | `/about` |
| `pages/blog/index.vue` | `/blog` |
| `pages/blog/[slug].vue` | `/blog/:slug` |
| `pages/users/[...slug].vue` | `/users/*` (catch-all) |
| `pages/[[optional]]/index.vue` | `/` or `/:optional` |

### 3.2 Dynamic Routes

```vue
<!-- pages/products/[id].vue -->
<script setup lang="ts">
const route = useRoute();
const productId = route.params.id;

const { data: product } = await useFetch(`/api/products/${productId}`);
</script>

<template>
  <div v-if="product">
    <h1>{{ product.name }}</h1>
    <p>{{ product.description }}</p>
  </div>
</template>
```

### 3.3 Route Middleware

```typescript
// middleware/auth.ts
export default defineNuxtRouteMiddleware((to, from) => {
  const { loggedIn } = useUserSession();
  
  if (!loggedIn.value) {
    return navigateTo('/login');
  }
});
```

Apply in page:

```vue
<script setup>
definePageMeta({
  middleware: 'auth',
});
</script>
```

---

## Part 4: Data Fetching

### 4.1 Composables Comparison

| Composable | SSR | Caching | Use Case |
|------------|-----|---------|----------|
| `useFetch` | ✅ | ✅ | API calls with deduplication |
| `useAsyncData` | ✅ | ✅ | Custom async logic |
| `useLazyFetch` | Client-first | ✅ | Non-blocking fetch |
| `$fetch` | ❌ | ❌ | Client-only or server utilities |

### 4.2 useFetch Patterns

```vue
<script setup lang="ts">
// Basic fetch
const { data: users, pending, error, refresh } = await useFetch('/api/users');

// With options
const { data: posts } = await useFetch('/api/posts', {
  query: { page: 1, limit: 10 },
  pick: ['id', 'title', 'slug'],        // Select fields
  transform: (posts) => posts.map(p => ({
    ...p,
    slug: slugify(p.title),
  })),
});

// Watch for changes
const page = ref(1);
const { data: items } = await useFetch(() => `/api/items?page=${page.value}`, {
  watch: [page],
});

// Client-only
const { data: stats } = await useFetch('/api/stats', {
  server: false,  // Only fetch on client
});
</script>
```

### 4.3 useAsyncData for Custom Logic

```vue
<script setup>
const { data: combined } = await useAsyncData('dashboard', async () => {
  const [user, orders, notifications] = await Promise.all([
    $fetch('/api/user'),
    $fetch('/api/orders'),
    $fetch('/api/notifications'),
  ]);
  
  return { user, orders, notifications };
});
</script>
```

---

## Part 5: API Routes (Nitro)

### 5.1 Route Handlers

```typescript
// server/api/products/index.get.ts
export default defineEventHandler(async (event) => {
  const query = getQuery(event);
  
  const products = await db.products.findMany({
    take: Number(query.limit) || 10,
    skip: Number(query.offset) || 0,
  });
  
  return products;
});

// server/api/products/index.post.ts
export default defineEventHandler(async (event) => {
  const body = await readBody(event);
  
  // Validate with Zod
  const validated = ProductSchema.parse(body);
  
  const product = await db.products.create({
    data: validated,
  });
  
  setResponseStatus(event, 201);
  return product;
});

// server/api/products/[id].get.ts
export default defineEventHandler(async (event) => {
  const id = getRouterParam(event, 'id');
  
  const product = await db.products.findUnique({
    where: { id },
  });
  
  if (!product) {
    throw createError({
      statusCode: 404,
      message: 'Product not found',
    });
  }
  
  return product;
});
```

### 5.2 Server Utilities

| Utility | Purpose |
|---------|---------|
| `getQuery(event)` | URL query parameters |
| `readBody(event)` | Request body |
| `getRouterParam(event, 'name')` | Route parameter |
| `getHeader(event, 'name')` | Request header |
| `setCookie(event, ...)` | Set cookie |
| `createError({ ... })` | Throw HTTP error |

---

## Part 6: State Management

### 6.1 Pinia Integration

```typescript
// stores/cart.ts
export const useCartStore = defineStore('cart', () => {
  // State
  const items = ref<CartItem[]>([]);
  
  // Getters
  const total = computed(() => 
    items.value.reduce((sum, item) => sum + item.price * item.quantity, 0)
  );
  
  const itemCount = computed(() => 
    items.value.reduce((sum, item) => sum + item.quantity, 0)
  );
  
  // Actions
  function addItem(product: Product) {
    const existing = items.value.find(i => i.id === product.id);
    if (existing) {
      existing.quantity++;
    } else {
      items.value.push({ ...product, quantity: 1 });
    }
  }
  
  function removeItem(id: string) {
    items.value = items.value.filter(item => item.id !== id);
  }
  
  function clearCart() {
    items.value = [];
  }
  
  return { items, total, itemCount, addItem, removeItem, clearCart };
});
```

### 6.2 Using in Components

```vue
<script setup>
const cart = useCartStore();

const handleAddToCart = (product: Product) => {
  cart.addItem(product);
};
</script>

<template>
  <div>
    <span>Cart: {{ cart.itemCount }} items</span>
    <span>Total: ${{ cart.total.toFixed(2) }}</span>
  </div>
</template>
```

---

## Part 7: Configuration

### 7.1 nuxt.config.ts

```typescript
export default defineNuxtConfig({
  // Modules
  modules: [
    '@pinia/nuxt',
    '@nuxtjs/tailwindcss',
    '@vueuse/nuxt',
  ],
  
  // Runtime config (env variables)
  runtimeConfig: {
    // Server-only
    apiSecret: '',
    // Public (exposed to client)
    public: {
      apiBase: '/api',
    },
  },
  
  // TypeScript
  typescript: {
    strict: true,
  },
  
  // Nitro configuration
  nitro: {
    preset: 'node-server', // or 'vercel', 'netlify', etc.
  },
  
  // App configuration
  app: {
    head: {
      title: 'My Nuxt App',
      meta: [
        { name: 'description', content: 'My awesome Nuxt app' },
      ],
    },
  },
});
```

---

## Part 8: Best Practices Summary

### ✅ Do This

- ✅ Use `useFetch` for SSR data fetching
- ✅ Leverage auto-imports (components, composables)
- ✅ Use server routes for API logic
- ✅ Use Pinia for global state
- ✅ Use TypeScript strict mode
- ✅ Create error.vue for error handling

### ❌ Avoid This

- ❌ Don't use `$fetch` directly in `<script setup>` (use `useFetch`)
- ❌ Don't skip error handling in API routes
- ❌ Don't put secrets in runtimeConfig.public
- ❌ Don't ignore caching strategies

---

## Quick Reference

| Task | Solution |
|------|----------|
| Data fetching | `useFetch`, `useAsyncData` |
| API routes | `server/api/*.ts` |
| Global state | Pinia stores |
| Routing | `pages/` directory |
| Middleware | `middleware/` directory |
| SEO | `useHead`, `useSeoMeta` |

---

## Related Skills

- `@senior-vue-developer` - Vue 3 patterns
- `@senior-typescript-developer` - Type safety
- `@senior-tailwindcss-developer` - Styling

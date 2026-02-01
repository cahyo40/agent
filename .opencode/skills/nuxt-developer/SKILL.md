---
name: nuxt-developer
description: "Expert Nuxt.js development including Vue 3, SSR/SSG, API routes, and production-ready full-stack applications"
---

# Nuxt Developer

## Overview

Build full-stack Vue.js applications with Nuxt 3 including SSR, SSG, and API routes.

## When to Use This Skill

- Use when building Vue.js applications
- Use when needing SSR/SSG with Vue

## How It Works

### Step 1: Nuxt 3 Project Setup

```bash
# Create new project
npx nuxi@latest init my-app
cd my-app
npm install

# Project structure
my-app/
├── pages/           # File-based routing
├── components/      # Auto-imported components
├── composables/     # Auto-imported composables
├── layouts/         # Page layouts
├── server/          # API routes
├── public/          # Static assets
├── nuxt.config.ts   # Configuration
└── app.vue          # Root component
```

### Step 2: Pages & Routing

```vue
<!-- pages/index.vue -->
<template>
  <div>
    <h1>Welcome {{ user?.name }}</h1>
    <NuxtLink to="/products">View Products</NuxtLink>
  </div>
</template>

<script setup>
const { data: user } = await useFetch('/api/user')
</script>

<!-- pages/products/[id].vue -->
<template>
  <div>
    <h1>{{ product.name }}</h1>
    <p>{{ product.description }}</p>
  </div>
</template>

<script setup>
const route = useRoute()
const { data: product } = await useFetch(`/api/products/${route.params.id}`)
</script>
```

### Step 3: Data Fetching

```vue
<script setup>
// useFetch - SSR friendly
const { data, pending, error, refresh } = await useFetch('/api/posts', {
  query: { page: 1 },
  pick: ['id', 'title'], // Select fields
  transform: (posts) => posts.map(p => ({ ...p, slug: slugify(p.title) }))
})

// useAsyncData - More control
const { data: user } = await useAsyncData('user', () => {
  return $fetch('/api/user')
})

// Client-only fetch
const { data: stats } = await useFetch('/api/stats', {
  server: false // Only fetch on client
})

// Lazy loading
const { data: comments, pending } = await useLazyFetch('/api/comments')
</script>
```

### Step 4: API Routes (Server)

```typescript
// server/api/products/index.get.ts
export default defineEventHandler(async (event) => {
  const query = getQuery(event)
  const products = await db.products.findMany({
    take: query.limit || 10
  })
  return products
})

// server/api/products/index.post.ts
export default defineEventHandler(async (event) => {
  const body = await readBody(event)
  
  const product = await db.products.create({
    data: body
  })
  
  return product
})

// server/api/products/[id].get.ts
export default defineEventHandler(async (event) => {
  const id = getRouterParam(event, 'id')
  const product = await db.products.findUnique({ where: { id } })
  
  if (!product) {
    throw createError({ statusCode: 404, message: 'Not found' })
  }
  
  return product
})
```

### Step 5: State Management (Pinia)

```typescript
// stores/cart.ts
export const useCartStore = defineStore('cart', () => {
  const items = ref<CartItem[]>([])
  
  const total = computed(() => 
    items.value.reduce((sum, item) => sum + item.price * item.qty, 0)
  )
  
  function addItem(product: Product) {
    const existing = items.value.find(i => i.id === product.id)
    if (existing) {
      existing.qty++
    } else {
      items.value.push({ ...product, qty: 1 })
    }
  }
  
  return { items, total, addItem }
})

// Usage in component
const cart = useCartStore()
cart.addItem(product)
```

## Best Practices

- ✅ Use `useFetch` for SSR data
- ✅ Leverage auto-imports
- ✅ Use server routes for APIs
- ❌ Don't use `$fetch` in setup (use `useFetch`)
- ❌ Don't skip error handling

## Related Skills

- `@senior-vue-developer`
- `@senior-typescript-developer`

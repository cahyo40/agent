# 11 - SEO & Performance (useSeoMeta + Nuxt Image)

**Goal:** Optimasi SEO dengan Nuxt 3 built-in composables dan performance tuning untuk Core Web Vitals.

**Output:** `sdlc/nuxt-frontend/11-seo-performance/`

**Time Estimate:** 2-3 jam

---

## Deliverables

### 1. useSeoMeta (Per-Page)

```vue
<!-- pages/dashboard/products/index.vue -->
<script setup lang="ts">
useSeoMeta({
  title: "Products",
  description: "Manage your product catalog",
  ogTitle: "Products | MyApp",
  ogDescription: "Manage your product catalog",
});
</script>
```

---

### 2. Dynamic SEO (Product Detail)

**File:** `pages/dashboard/products/[id].vue`

```vue
<script setup lang="ts">
const route = useRoute();
const { data: product } = await useAsyncData(
  `product-${route.params.id}`,
  () => useApi().getOne("/products", route.params.id as string)
);

useSeoMeta({
  title: () => product.value?.name ?? "Product",
  description: () => `View details for ${product.value?.name}`,
  ogTitle: () => `${product.value?.name} | MyApp`,
});
</script>
```

---

### 3. Global SEO in nuxt.config.ts

**File:** `nuxt.config.ts`

```typescript
export default defineNuxtConfig({
  app: {
    head: {
      titleTemplate: "%s | MyApp",
      htmlAttrs: { lang: "en" },
      meta: [
        { charset: "utf-8" },
        { name: "viewport", content: "width=device-width, initial-scale=1" },
        { name: "theme-color", content: "#6366f1" },
      ],
      link: [
        { rel: "icon", type: "image/x-icon", href: "/favicon.ico" },
        {
          rel: "stylesheet",
          href: "https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap",
        },
      ],
    },
  },
});
```

---

### 4. Nuxt Image

```bash
pnpm add @nuxt/image
```

**File:** `nuxt.config.ts`

```typescript
export default defineNuxtConfig({
  modules: [
    // ... existing
    "@nuxt/image",
  ],
  image: {
    quality: 80,
    formats: ["webp", "avif"],
    screens: {
      xs: 320,
      sm: 640,
      md: 768,
      lg: 1024,
      xl: 1280,
    },
  },
});
```

**Usage:**

```vue
<!-- ✅ Optimized: use NuxtImg -->
<NuxtImg
  :src="product.imageUrl"
  :alt="product.name"
  width="400"
  height="400"
  format="webp"
  loading="lazy"
  class="object-cover rounded-md"
/>

<!-- ✅ Responsive with sizes -->
<NuxtImg
  src="/hero.jpg"
  sizes="sm:100vw md:50vw lg:400px"
  preload
/>

<!-- ❌ Avoid: raw <img> -->
<!-- <img :src="product.imageUrl" /> -->
```

---

### 5. Loading State (Nuxt Native)

**File:** `pages/dashboard/products/index.vue`

```vue
<script setup lang="ts">
const { data, pending } = await useAsyncData("products", () =>
  useApi().getList("/products")
);
</script>

<template>
  <div>
    <TableSkeleton v-if="pending" />
    <DataTable v-else :data="data?.data ?? []" :columns="columns" />
  </div>
</template>
```

---

### 6. Route-Level Code Splitting

Nuxt 3 melakukan code splitting otomatis per halaman. Untuk lazy-load komponen berat:

```vue
<script setup lang="ts">
// Lazy import komponen berat
const HeavyChart = defineAsyncComponent(
  () => import("~/components/shared/HeavyChart.vue")
);
</script>

<template>
  <Suspense>
    <HeavyChart :data="chartData" />
    <template #fallback>
      <Skeleton class="h-[300px] w-full" />
    </template>
  </Suspense>
</template>
```

---

### 7. Nuxt Config Performance

**File:** `nuxt.config.ts`

```typescript
export default defineNuxtConfig({
  // Prerender public pages
  routeRules: {
    "/": { prerender: true },
    "/about": { prerender: true },
    "/dashboard/**": { ssr: false }, // SPA for auth-protected routes
    "/api/**": { cors: true },
  },

  // Nitro optimizations
  nitro: {
    compressPublicAssets: true,
    minify: true,
  },

  // Vite optimizations
  vite: {
    build: {
      rollupOptions: {
        output: {
          manualChunks: {
            "chart-vendor": ["chart.js", "vue-chartjs"],
          },
        },
      },
    },
  },
});
```

---

## Success Criteria
- Lighthouse score ≥ 90 untuk Performance, SEO, Accessibility
- `useSeoMeta` digunakan di semua pages
- `NuxtImg` digunakan untuk semua gambar
- Dashboard routes menggunakan `ssr: false` (SPA mode)
- Public pages prerendered untuk SEO optimal

## Next Steps
- `12_deployment.md` - Deployment

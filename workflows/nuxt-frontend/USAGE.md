# Nuxt.js Frontend Workflows - Usage Guide

Panduan lengkap untuk menggunakan Nuxt.js Frontend workflows.

---

## Quick Start

```bash
# 1. Buat project
pnpm dlx nuxi@latest init myapp
cd myapp

# 2. Install dependencies (lihat 01_project_setup.md)
pnpm add pinia @pinia/nuxt @vueuse/nuxt @vueuse/core
pnpm add vee-validate zod @vee-validate/zod
pnpm add lucide-vue-next @nuxtjs/color-mode
pnpm add -D @nuxtjs/tailwindcss @nuxt/eslint

# 3. Init Shadcn-vue
pnpm dlx shadcn-vue@latest init

# 4. Copy .env.example → .env dan isi

# 5. Jalankan dev server
pnpm dev
# → http://localhost:3000
```

---

## Workflow Order

| # | Workflow | Kapan | Wajib? |
|---|---------|-------|--------|
| 01 | Project Setup | Selalu pertama | ✅ |
| 02 | Component Generator | Per komponen | ✅ |
| 03 | API Client | Jika pakai custom backend | ✅ |
| 04 | Auth NuxtAuth | Jika auth via Go/Python backend | ⚡ Pilih |
| 05 | Supabase | Jika pakai Supabase | ⚡ Pilih |
| 06 | Firebase | Jika pakai Firebase | ⚡ Pilih |
| 07 | Forms & Validation | Selalu (ada form) | ✅ |
| 08 | State Management | Setelah 03/04/05/06 | ✅ |
| 09 | Layout & Dashboard | Untuk admin panel | 📝 |
| 10 | Testing | Sebelum release | ✅ |
| 11 | SEO & Performance | Untuk public-facing | 📝 |
| 12 | Deployment | Sebelum production | ✅ |

---

## Example Prompts

### Setup Project Baru

```
Gunakan workflow 01_project_setup.md untuk membuat
Nuxt 3 project bernama "admin-panel" dengan TypeScript
strict, Tailwind, dan Shadcn-vue. Target: dashboard
admin untuk manajemen e-commerce.
```

### Buat Komponen Baru

```
Gunakan workflow 02_component_generator.md untuk
membuat DataTable komponen untuk menampilkan daftar
orders dengan kolom: ID, customer, total, status,
tanggal. Tambahkan sorting dan pagination.
```

### Setup API Client

```
Gunakan workflow 03_api_client_integration.md untuk
setup $fetch plugin yang connect ke FastAPI backend
di http://localhost:8000/api/v1. Buat composable
useOrders untuk CRUD orders menggunakan useAsyncData.
```

### Auth dengan Custom Backend

```
Gunakan workflow 04_auth_nuxtauth.md untuk setup
nuxt-auth-utils dengan Nitro server routes yang
connect ke endpoint POST /api/v1/auth/login di
backend Go. Protect semua route di /dashboard.
```

### Integrasi Supabase

```
Gunakan workflow 05_supabase_integration.md untuk:
1. Setup @nuxtjs/supabase module
2. Auth dengan email/password dan Google OAuth
3. CRUD ke tabel "products" dengan useAsyncData
4. Realtime subscription untuk live updates
```

### Integrasi Firebase

```
Gunakan workflow 06_firebase_integration.md untuk:
1. Setup nuxt-vuefire module
2. Auth dengan email/password dan Google Sign-In
3. Firestore CRUD dengan useCollection (reactive)
4. Real-time listener untuk status order
```

### Form dengan Validasi

```
Gunakan workflow 07_forms_validation.md untuk membuat
form "Create Product" dengan fields: name, SKU, price
(number), stock (number), category (select). Validasi
dengan VeeValidate + Zod.
```

### Dashboard Layout

```
Gunakan workflow 09_layout_dashboard.md untuk membuat
dashboard layout dengan:
- Sidebar collapsible (Pinia UI store)
- Header dengan dark mode toggle dan user menu
- Stats cards: Total Revenue, Orders, Products, Users
- Line chart untuk revenue 6 bulan terakhir
```

### Testing

```
Gunakan workflow 10_testing_quality.md untuk:
1. Setup Vitest + @nuxt/test-utils
2. Unit tests untuk utils dan Zod schemas
3. Pinia store tests
4. Playwright E2E test untuk login flow
5. GitHub Actions CI pipeline
```

### Deploy ke Vercel

```
Gunakan workflow 12_deployment.md untuk deploy ke
Vercel. Setup environment variables: NUXT_PUBLIC_API_URL,
NUXT_SESSION_PASSWORD, Supabase keys.
```

---

## Common Tasks

### Tambah Halaman Baru

```
pages/dashboard/orders/
├── index.vue         # /dashboard/orders
└── [id].vue          # /dashboard/orders/:id
```

```vue
<!-- pages/dashboard/orders/index.vue -->
<script setup lang="ts">
definePageMeta({ middleware: "auth", layout: "dashboard" });
useSeoMeta({ title: "Orders" });
</script>
```

### Tambah Composable Baru

```
composables/
└── useOrders.ts      # Auto-imported as useOrders()
```

### Tambah Pinia Store

```
stores/
└── cart.ts           # Auto-imported as useCartStore()
```

### Tambah Shadcn-vue Component

```bash
pnpm dlx shadcn-vue@latest add [component-name]
# Contoh:
pnpm dlx shadcn-vue@latest add calendar
pnpm dlx shadcn-vue@latest add date-picker
pnpm dlx shadcn-vue@latest add command
```

### Tambah Server Route (Nitro)

```
server/api/
├── health.get.ts     # GET /api/health
├── auth/
│   ├── login.post.ts # POST /api/auth/login
│   └── logout.post.ts
└── users/
    └── index.get.ts  # GET /api/users
```

---

## Nuxt vs Next.js Cheatsheet

| Konsep | Next.js | Nuxt 3 |
|--------|---------|--------|
| Import | Manual | Auto-import |
| State | Zustand | Pinia |
| Data fetching | TanStack Query | useAsyncData/useFetch |
| HTTP | Axios | $fetch (ofetch) |
| Forms | React Hook Form | VeeValidate |
| Auth | NextAuth.js | nuxt-auth-utils |
| Supabase | @supabase/ssr | @nuxtjs/supabase |
| Firebase | Firebase SDK | nuxt-vuefire |
| SEO | Metadata API | useSeoMeta |
| Images | next/image | NuxtImg |
| Layouts | layout.tsx | layouts/*.vue |
| Middleware | middleware.ts | middleware/*.ts |

---

## Troubleshooting

### "Cannot find module" setelah install

```bash
# Restart Nuxt dev server
pnpm dev
# Atau clear cache
rm -rf .nuxt && pnpm dev
```

### Hydration mismatch

```vue
<!-- Gunakan ClientOnly untuk komponen yang berbeda di server/client -->
<ClientOnly>
  <HeavyClientComponent />
  <template #fallback>
    <Skeleton class="h-32 w-full" />
  </template>
</ClientOnly>
```

### Pinia store tidak reactive

```typescript
// ✅ Gunakan storeToRefs
const { user } = storeToRefs(useAuthStore());

// ❌ Jangan destructure langsung
// const { user } = useAuthStore(); // loses reactivity
```

### useAsyncData tidak refetch

```typescript
// Pastikan key berubah saat params berubah
const { data } = useAsyncData(
  () => `products-${page.value}-${search.value}`, // dynamic key
  () => fetchProducts(page.value, search.value),
  { watch: [page, search] }
);
```

### Supabase session tidak persist di SSR

```typescript
// Pastikan @nuxtjs/supabase module terinstall
// Module ini otomatis handle SSR cookie
```

---

## Tech Stack Summary

| Kategori | Library |
|----------|---------|
| Framework | Nuxt 3 (Nitro + Vite) |
| Language | TypeScript 5+ strict |
| Styling | Tailwind CSS + Shadcn-vue |
| Server State | useAsyncData / useFetch |
| Client State | Pinia |
| HTTP Client | $fetch (ofetch, built-in) |
| Forms | VeeValidate + Zod |
| Auth (custom) | nuxt-auth-utils |
| Auth (BaaS) | @nuxtjs/supabase / nuxt-vuefire |
| Testing | Vitest + @nuxt/test-utils + Playwright |
| Deployment | Vercel / Docker / SSG |

---

## Resources

- [Nuxt 3 Docs](https://nuxt.com/docs)
- [Shadcn-vue](https://www.shadcn-vue.com)
- [Pinia](https://pinia.vuejs.org)
- [VeeValidate](https://vee-validate.logaretm.com/v4/)
- [VueUse](https://vueuse.org)
- [nuxt-auth-utils](https://github.com/atinux/nuxt-auth-utils)
- [Supabase Nuxt Module](https://supabase.nuxtjs.org)
- [VueFire / nuxt-vuefire](https://vuefire.vuejs.org/nuxt)
- [Playwright](https://playwright.dev)
- [Nitro](https://nitro.unjs.io)

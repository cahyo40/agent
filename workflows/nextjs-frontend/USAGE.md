# Next.js Frontend Workflows - Usage Guide

Panduan lengkap untuk menggunakan Next.js Frontend workflows.

---

## Quick Start

```bash
# 1. Buat project
pnpm create next-app@latest myapp --typescript --tailwind --eslint --app --src-dir --import-alias "@/*"
cd myapp

# 2. Install dependencies (lihat 01_project_setup.md)
pnpm add @tanstack/react-query axios zustand react-hook-form zod @hookform/resolvers
pnpm add lucide-react class-variance-authority clsx tailwind-merge next-themes date-fns

# 3. Init Shadcn/UI
pnpm dlx shadcn-ui@latest init

# 4. Copy .env.local.example → .env.local dan isi

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
| 04 | Auth NextAuth | Jika auth via Go/Python backend | ⚡ Pilih |
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
Next.js 14 project bernama "admin-panel" dengan
TypeScript, Tailwind, dan Shadcn/UI. Target: dashboard
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
setup Axios instance yang connect ke FastAPI backend
di http://localhost:8000/api/v1. Buat hooks untuk
CRUD products menggunakan TanStack Query.
```

### Auth dengan Custom Backend

```
Gunakan workflow 04_auth_nextauth.md untuk setup
NextAuth.js dengan Credentials Provider yang connect
ke endpoint POST /api/v1/auth/login di backend Go.
Protect semua route di /dashboard.
```

### Integrasi Supabase

```
Gunakan workflow 05_supabase_integration.md untuk:
1. Setup Supabase client (browser + server)
2. Auth dengan email/password dan Google OAuth
3. CRUD ke tabel "products" dengan RLS
4. Realtime subscription untuk live updates
```

### Integrasi Firebase

```
Gunakan workflow 06_firebase_integration.md untuk:
1. Setup Firebase v10 modular SDK
2. Auth dengan email/password dan Google Sign-In
3. Firestore CRUD untuk koleksi "orders"
4. Real-time listener untuk status order
5. FCM push notification saat order baru
```

### Form dengan Validasi

```
Gunakan workflow 07_forms_validation.md untuk membuat
form "Create Product" dengan fields: name, SKU, price
(number), stock (number), category (select), image
(file upload). Validasi dengan Zod.
```

### Dashboard Layout

```
Gunakan workflow 09_layout_dashboard.md untuk membuat
dashboard layout dengan:
- Sidebar collapsible dengan nav: Dashboard, Products,
  Orders, Users, Settings
- Header dengan dark mode toggle dan user menu
- Stats cards: Total Revenue, Orders, Products, Users
- Area chart untuk revenue 6 bulan terakhir
```

### Testing

```
Gunakan workflow 10_testing_quality.md untuk:
1. Setup Vitest + React Testing Library
2. Unit tests untuk utility functions dan Zod schemas
3. Playwright E2E test untuk login flow dan CRUD products
4. GitHub Actions CI pipeline
```

### Deploy ke Vercel

```
Gunakan workflow 12_deployment.md untuk deploy ke
Vercel. Setup environment variables untuk production:
NEXT_PUBLIC_API_URL, NEXTAUTH_SECRET, Supabase keys.
```

---

## Common Tasks

### Tambah Halaman Baru

```
src/app/(dashboard)/orders/
├── page.tsx          # Server Component
├── loading.tsx       # Skeleton
└── error.tsx         # Error boundary
```

### Tambah Feature Module

```
src/features/orders/
├── api/
│   └── orders-api.ts
├── components/
│   ├── orders-table.tsx
│   └── order-form.tsx
└── hooks/
    └── use-orders.ts
```

### Tambah Shadcn Component

```bash
pnpm dlx shadcn-ui@latest add [component-name]
# Contoh:
pnpm dlx shadcn-ui@latest add calendar
pnpm dlx shadcn-ui@latest add date-picker
pnpm dlx shadcn-ui@latest add command
```

---

## Troubleshooting

### "Module not found: @/*"

```bash
# Pastikan tsconfig.json punya paths alias
# Dan next.config.ts tidak override webpack aliases
```

### Hydration mismatch

```tsx
// Gunakan suppressHydrationWarning untuk dark mode
<html lang="en" suppressHydrationWarning>
```

### TanStack Query tidak refetch

```typescript
// Pastikan queryKey berubah saat params berubah
queryKey: ["products", "list", { page, search }]
// Bukan: queryKey: ["products"]
```

### Supabase session tidak persist

```bash
# Pastikan middleware.ts memanggil updateSession()
# Dan Supabase SSR client digunakan (bukan browser client di server)
```

### Firebase "app/duplicate-app"

```typescript
// Gunakan pattern singleton
const app = getApps().length === 0
  ? initializeApp(config)
  : getApps()[0]!;
```

---

## Tech Stack Summary

| Kategori | Library |
|----------|---------|
| Framework | Next.js 14+ (App Router) |
| Language | TypeScript 5+ strict |
| Styling | Tailwind CSS + Shadcn/UI |
| Server State | TanStack Query v5 |
| Client State | Zustand v4 |
| HTTP Client | Axios |
| Forms | React Hook Form + Zod |
| Auth (custom) | NextAuth.js v5 |
| Auth (BaaS) | Supabase / Firebase |
| Testing | Vitest + Playwright |
| Deployment | Vercel / Docker |

---

## Resources

- [Next.js Docs](https://nextjs.org/docs)
- [Shadcn/UI](https://ui.shadcn.com)
- [TanStack Query](https://tanstack.com/query/latest)
- [Zustand](https://zustand-demo.pmnd.rs)
- [React Hook Form](https://react-hook-form.com)
- [Zod](https://zod.dev)
- [Supabase Docs](https://supabase.com/docs)
- [Firebase Docs](https://firebase.google.com/docs)
- [NextAuth.js](https://authjs.dev)
- [Playwright](https://playwright.dev)

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

### Phase 1: Foundation (Wajib)
1. **`01_project_setup.md`** — Setup project Next.js baru
2. **`02_component_generator.md`** — UI components setup

### Phase 2: Data & State (Wajib)
3. **`03_api_client_integration.md`** — Axios & TanStack Query
4. **`07_forms_validation.md`** — Form handling & Validation (Zod)
5. **`08_state_management.md`** — Zustand (Global state)

### Phase 3: Backend & Auth (Pilih Salah Satu)
Mulai fitur dengan menghubungkan backend-nya:
- **`04_auth_nextauth.md`** — Untuk Custom Backend & NextAuth
- **`05_supabase_integration.md`** — Supabase Auth, DB, dan Storage
- **`06_firebase_integration.md`** — Firebase Auth, Firestore, dan FCM

### Phase 4: Enhancements & UI (Opsional)
- **`09_layout_dashboard.md`** — Dashboard UI

### Phase 5: Quality, SEO & Deploy (Wajib via Production)
- **`10_testing_quality.md`** — Vitest & Playwright testing
- **`11_seo_performance.md`** — SEO tags & Metadata
- **`12_deployment.md`** — Vercel & CI/CD deployment

---

## Example Prompts

> **Silakan merujuk ke file `example.md` di direktori ini untuk melihat contoh prompt siap pakai (copy-paste) per workflow.**

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

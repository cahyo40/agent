---
description: Setup project Next.js 14+ dari nol dengan App Router, TypeScript strict, Tailwind CSS, Shadcn/UI, dan folder structur... (Part 3/3)
---
# 01 - Next.js Project Setup (App Router + TypeScript + Tailwind + Shadcn/UI) (Part 3/3)

> **Navigation:** This workflow is split into 3 parts.

## Workflow Steps

1. **Init project** dengan `create-next-app`
2. **Install dependencies** (Shadcn, TanStack Query, Zustand, dll)
3. **Setup TypeScript** strict mode
4. **Init Shadcn/UI** (`pnpm dlx shadcn-ui@latest init`)
5. **Buat folder structure** sesuai feature-based
6. **Setup Providers** (QueryClient + ThemeProvider)
7. **Setup Middleware** untuk route protection
8. **Copy `.env.local.example`** dan isi sesuai kebutuhan


## Success Criteria
- `pnpm dev` berjalan tanpa error di `http://localhost:3000`
- `pnpm type-check` tidak ada error TypeScript
- `pnpm lint` tidak ada error ESLint
- Shadcn/UI terinstall dan komponen bisa digunakan
- Dark mode toggle berfungsi
- Route protection middleware aktif


## Next Steps
- `02_component_generator.md` - Buat UI components
- `03_api_client_integration.md` - Setup API client
- `04_auth_nextauth.md` / `05_supabase_integration.md` / `06_firebase_integration.md`

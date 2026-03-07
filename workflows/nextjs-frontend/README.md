# Next.js Frontend Workflows

Workflows untuk development frontend modern dengan Next.js 14+ (App Router), TypeScript, Tailwind CSS, dan integrasi Supabase & Firebase.

## System Requirements

- **Node.js:** 20+ (LTS)
- **Package Manager:** pnpm (recommended) atau npm/yarn
- **Editor:** VS Code dengan extensions: ESLint, Prettier, Tailwind IntelliSense
- **Git:** 2.40+

## Struktur Workflows

```
workflows/nextjs-frontend/
├── README.md                        # Overview (file ini)
├── USAGE.md                         # Quick start
├── example.md               ← ⭐ Contoh prompt per workflow
│
│  ## Phase 1: Foundation
├── 01_project_setup.md              # Setup Next.js + TypeScript + Tailwind + Shadcn
├── 02_component_generator.md        # UI component templates (Atomic Design)
│
│  ## Phase 2: Data & State
├── 03_api_client_integration.md     # Axios + TanStack Query + OpenAPI types
├── 07_forms_validation.md           # React Hook Form + Zod
├── 08_state_management.md           # Zustand + TanStack Query patterns
│
│  ## Phase 3: Backend & Auth (Pilih Salah Satu)
├── 04_auth_nextauth.md              # NextAuth.js (connect ke custom backend)
├── 05_supabase_integration.md       # Supabase Auth + Realtime DB + Storage
├── 06_firebase_integration.md       # Firebase Auth + Firestore + FCM
│
│  ## Phase 4: Enhancements & UI
├── 09_layout_dashboard.md           # Dashboard layout + dark mode + charts
│
│  ## Phase 5: Quality, SEO & Deploy
├── 10_testing_quality.md            # Vitest + Playwright + Storybook
├── 11_seo_performance.md            # Metadata API + Core Web Vitals
└── 12_deployment.md                 # Vercel + Docker + CI/CD
```

## Output Location

Setiap workflow menghasilkan file di:
```
sdlc/nextjs-frontend/<workflow-name>/
```

## Urutan Penggunaan

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

## Tech Stack

### Core
| Kategori | Library | Versi |
|----------|---------|-------|
| Framework | Next.js (App Router) | 14+ |
| Language | TypeScript | 5+ |
| Styling | Tailwind CSS | 3+ |
| UI Components | Shadcn/UI + Radix | Latest |
| Icons | Lucide React | Latest |

### Data & State
| Kategori | Library |
|----------|---------|
| Server State | TanStack Query v5 |
| Client State | Zustand v4 |
| HTTP Client | Axios |
| Forms | React Hook Form v7 |
| Validation | Zod v3 |

### Backend Integration
| Opsi | Library |
|------|---------|
| Custom Backend | NextAuth.js + Axios |
| Supabase | @supabase/ssr |
| Firebase | firebase v10 (modular) |

### Testing & Quality
| Kategori | Library |
|----------|---------|
| Unit Test | Vitest + React Testing Library |
| E2E Test | Playwright |
| Component Docs | Storybook |
| Linting | ESLint + Prettier |
| Type Check | TypeScript strict mode |

## Arsitektur (Feature-Based)

```
src/
├── app/                    # Next.js App Router
│   ├── (auth)/             # Route group: auth pages
│   │   ├── login/
│   │   └── register/
│   ├── (dashboard)/        # Route group: protected pages
│   │   ├── layout.tsx      # Dashboard layout
│   │   └── dashboard/
│   ├── api/                # API Routes (server-side)
│   ├── layout.tsx          # Root layout
│   └── page.tsx            # Home page
│
├── components/             # Shared UI components
│   ├── ui/                 # Shadcn/UI base components
│   └── shared/             # App-specific shared components
│
├── features/               # Feature modules
│   ├── auth/               # Auth feature
│   │   ├── components/     # LoginForm, RegisterForm
│   │   ├── hooks/          # useAuth, useSession
│   │   └── api/            # auth API calls
│   ├── users/              # Users feature
│   │   ├── components/
│   │   ├── hooks/
│   │   └── api/
│   └── products/           # Products feature
│
├── lib/                    # Shared utilities & configs
│   ├── api/                # Axios instance, interceptors
│   ├── supabase/           # Supabase client
│   ├── firebase/           # Firebase config
│   └── utils.ts            # cn(), formatDate(), etc.
│
├── hooks/                  # Global custom hooks
├── stores/                 # Zustand stores
├── types/                  # Global TypeScript types
└── middleware.ts            # Route protection
```

## Pola Arsitektur

### Server Components vs Client Components

```
Server Components (default):
  ✅ Data fetching dari database/API
  ✅ Halaman yang butuh SEO
  ✅ Static content
  ✅ Tidak butuh interaktivitas

Client Components ('use client'):
  ✅ Event handlers (onClick, onChange)
  ✅ Browser APIs (localStorage, window)
  ✅ State (useState, useEffect)
  ✅ Real-time subscriptions
```

### Data Flow

```
Server Component → fetch() → Backend API / Supabase / Firebase
Client Component → TanStack Query → Axios → Backend API
Client Component → Supabase Realtime → Live Updates
Client Component → Firebase Listener → Live Updates
```

## Development Commands

```bash
# Install dependencies
pnpm install

# Development server
pnpm dev

# Type check
pnpm type-check

# Lint
pnpm lint

# Format
pnpm format

# Test (unit)
pnpm test

# Test (E2E)
pnpm test:e2e

# Build production
pnpm build

# Start production
pnpm start
```

## Best Practices

### ✅ Do
- Gunakan Server Components untuk data fetching
- Gunakan `next/image` untuk semua gambar
- Gunakan `next/font` untuk Google Fonts
- Validasi form dengan Zod (sama dengan backend schema)
- Gunakan `loading.tsx` dan `error.tsx` per route
- Gunakan environment variables untuk semua config
- Type semua API responses

### ❌ Don't
- Jangan `useEffect` untuk data fetching (gunakan TanStack Query)
- Jangan simpan sensitive data di localStorage
- Jangan gunakan `any` di TypeScript
- Jangan fetch data di Client Components jika bisa di Server Components
- Jangan hardcode API URLs

## Perbandingan Auth Options

| Fitur | NextAuth.js | Supabase Auth | Firebase Auth |
|-------|-------------|---------------|---------------|
| Custom Backend | ✅ Terbaik | ❌ | ❌ |
| Social OAuth | ✅ | ✅ | ✅ |
| Magic Link | ✅ | ✅ | ✅ |
| Phone Auth | ❌ | ✅ | ✅ |
| MFA | Plugin | ✅ | ✅ |
| Harga | Free | Free tier | Free tier |
| Kompleksitas | Medium | Low | Low |

## Resources

- [Next.js Docs](https://nextjs.org/docs)
- [Shadcn/UI](https://ui.shadcn.com)
- [TanStack Query](https://tanstack.com/query/latest)
- [Supabase Docs](https://supabase.com/docs)
- [Firebase Docs](https://firebase.google.com/docs)
- [Zod](https://zod.dev)
- [Zustand](https://zustand-demo.pmnd.rs)

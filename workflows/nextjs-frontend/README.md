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
├── 01_project_setup.md              # Setup Next.js + TypeScript + Tailwind + Shadcn
├── 02_component_generator.md        # UI component templates (Atomic Design)
├── 03_api_client_integration.md     # Axios + TanStack Query + OpenAPI types
├── 04_auth_nextauth.md              # NextAuth.js (connect ke custom backend)
├── 05_supabase_integration.md       # Supabase Auth + Realtime DB + Storage
├── 06_firebase_integration.md       # Firebase Auth + Firestore + FCM
├── 07_forms_validation.md           # React Hook Form + Zod
├── 08_state_management.md           # Zustand + TanStack Query patterns
├── 09_layout_dashboard.md           # Dashboard layout + dark mode + charts
├── 10_testing_quality.md            # Vitest + Playwright + Storybook
├── 11_seo_performance.md            # Metadata API + Core Web Vitals
├── 12_deployment.md                 # Vercel + Docker + CI/CD
└── USAGE.md                         # Quick start + example prompts
```

## Output Location

Setiap workflow menghasilkan file di:
```
sdlc/nextjs-frontend/<workflow-name>/
```

## Urutan Penggunaan

| # | Workflow | Kapan Digunakan | Wajib? |
|---|---------|-----------------|--------|
| 01 | Project Setup | Selalu pertama | ✅ Ya |
| 02 | Component Generator | Per komponen baru | ✅ Ya |
| 03 | API Client | Jika pakai custom backend | ✅ Ya |
| 04 | Auth NextAuth | Jika auth via custom backend | ⚡ Pilih salah satu |
| 05 | Supabase | Jika pakai Supabase | ⚡ Pilih salah satu |
| 06 | Firebase | Jika pakai Firebase | ⚡ Pilih salah satu |
| 07 | Forms & Validation | Selalu (ada form) | ✅ Ya |
| 08 | State Management | Setelah 03/04/05/06 | ✅ Ya |
| 09 | Layout & Dashboard | Untuk admin panel | 📝 Recommended |
| 10 | Testing | Sebelum release | ✅ Ya |
| 11 | SEO & Performance | Untuk public-facing | 📝 Recommended |
| 12 | Deployment | Sebelum production | ✅ Ya |

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

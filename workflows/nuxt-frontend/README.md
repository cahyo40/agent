# Nuxt.js Frontend Workflows

Workflows untuk development frontend modern dengan Nuxt 3, TypeScript, Tailwind CSS, dan integrasi Supabase & Firebase.

## System Requirements

- **Node.js:** 20+ (LTS)
- **Package Manager:** pnpm (recommended)
- **Editor:** VS Code dengan extensions: Volar, ESLint, Tailwind IntelliSense
- **Git:** 2.40+

## Struktur Workflows

```
workflows/nuxt-frontend/
├── README.md                        # Overview (file ini)
├── 01_project_setup.md              # Setup Nuxt 3 + TypeScript + Tailwind + Shadcn
├── 02_component_generator.md        # UI component templates (Atomic Design)
├── 03_api_client_integration.md     # $fetch + useAsyncData + useFetch
├── 04_auth_nuxtauth.md              # nuxt-auth-utils / @sidebase/nuxt-auth
├── 05_supabase_integration.md       # Supabase Auth + Realtime DB + Storage
├── 06_firebase_integration.md       # Firebase Auth + Firestore + FCM
├── 07_forms_validation.md           # VeeValidate + Zod
├── 08_state_management.md           # Pinia + useAsyncData patterns
├── 09_layout_dashboard.md           # Dashboard layout + dark mode + charts
├── 10_testing_quality.md            # Vitest + Playwright
├── 11_seo_performance.md            # useSeoMeta + useHead + Nuxt Image
├── 12_deployment.md                 # Vercel + Docker + Nitro presets
└── USAGE.md                         # Quick start + example prompts
```

## Output Location

```
sdlc/nuxt-frontend/<workflow-name>/
```

## Urutan Penggunaan

| # | Workflow | Kapan | Wajib? |
|---|---------|-------|--------|
| 01 | Project Setup | Selalu pertama | ✅ Ya |
| 02 | Component Generator | Per komponen baru | ✅ Ya |
| 03 | API Client | Jika pakai custom backend | ✅ Ya |
| 04 | Auth NuxtAuth | Jika auth via custom backend | ⚡ Pilih |
| 05 | Supabase | Jika pakai Supabase | ⚡ Pilih |
| 06 | Firebase | Jika pakai Firebase | ⚡ Pilih |
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
| Framework | Nuxt 3 | 3.x |
| Language | TypeScript | 5+ |
| Styling | Tailwind CSS | 3+ |
| UI Components | Shadcn/UI (nuxt) | Latest |
| Icons | Lucide Vue Next | Latest |

### Data & State
| Kategori | Library |
|----------|---------|
| Server State | useAsyncData / useFetch (built-in) |
| Client State | Pinia |
| HTTP Client | $fetch (ofetch, built-in) |
| Forms | VeeValidate + Zod |

### Backend Integration
| Opsi | Library |
|------|---------|
| Custom Backend | @sidebase/nuxt-auth |
| Supabase | @nuxtjs/supabase |
| Firebase | vuefire + nuxt-vuefire |

### Testing & Quality
| Kategori | Library |
|----------|---------|
| Unit Test | Vitest + Vue Test Utils |
| E2E Test | Playwright |
| Linting | ESLint + @nuxt/eslint |
| Type Check | TypeScript strict mode |

## Arsitektur (Nuxt 3 Auto-imports)

```
.
├── app.vue                 # Root component
├── nuxt.config.ts          # Nuxt configuration
├── pages/                  # File-based routing (auto)
│   ├── index.vue           # /
│   ├── login.vue           # /login
│   └── dashboard/
│       ├── index.vue       # /dashboard
│       └── users/
│           ├── index.vue   # /dashboard/users
│           └── [id].vue    # /dashboard/users/:id
├── layouts/                # Layout templates
│   ├── default.vue
│   └── dashboard.vue
├── components/             # Auto-imported components
│   ├── ui/                 # Shadcn/UI base
│   └── shared/             # App-specific
├── composables/            # Auto-imported composables (useXxx)
│   ├── useAuth.ts
│   └── useApi.ts
├── stores/                 # Pinia stores (auto-imported)
│   ├── auth.ts
│   └── ui.ts
├── server/                 # Nitro server (API routes)
│   └── api/
│       └── auth/
│           └── login.post.ts
├── middleware/             # Route middleware
│   └── auth.ts
├── plugins/                # Nuxt plugins
│   └── api.client.ts
└── utils/                  # Auto-imported utilities
    └── index.ts
```

## Keunggulan Nuxt vs Next.js

| Fitur | Nuxt 3 | Next.js 14 |
|-------|--------|------------|
| Auto-imports | ✅ Otomatis | ❌ Manual import |
| File-based routing | ✅ | ✅ |
| SSR/SSG/SPA | ✅ Semua | ✅ Semua |
| State Management | Pinia (official) | Zustand (third-party) |
| Server Routes | Nitro (built-in) | API Routes |
| Vue DevTools | ✅ | N/A |
| Learning Curve | Lebih mudah | Medium |

## Development Commands

```bash
pnpm dev          # Dev server (http://localhost:3000)
pnpm build        # Build production
pnpm preview      # Preview production build
pnpm generate     # Static site generation
pnpm lint         # ESLint
pnpm type-check   # TypeScript check
pnpm test         # Vitest unit tests
pnpm test:e2e     # Playwright E2E
```

## Resources

- [Nuxt 3 Docs](https://nuxt.com/docs)
- [Shadcn/UI for Nuxt](https://www.shadcn-vue.com)
- [Pinia](https://pinia.vuejs.org)
- [VeeValidate](https://vee-validate.logaretm.com/v4/)
- [Supabase Nuxt Module](https://supabase.nuxtjs.org)
- [VueFire](https://vuefire.vuejs.org)

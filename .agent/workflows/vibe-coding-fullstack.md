---
description: Initialize Vibe Coding context files for full-stack monorepo project with Turborepo
---

# /vibe-coding-fullstack

Workflow untuk setup dokumen konteks Vibe Coding khusus **Full-Stack Monorepo** dengan frontend dan backend dalam satu repository menggunakan Turborepo.

---

## 📋 Prerequisites

Sebelum memulai, siapkan informasi berikut:

1. **Deskripsi ide aplikasi full-stack** (2-3 paragraf)
2. **Frontend preference:**
   - ⚛️ React/Next.js (recommended)
   - 🌿 Vue/Nuxt
   - 🔥 Svelte/SvelteKit
3. **Backend preference:**
   - 🟢 Node.js (NestJS/Express)
   - 🐹 Go (Gin/Echo/Fiber)
   - 🐍 Python (FastAPI/Django)
4. **Database:** PostgreSQL / MongoDB / MySQL
5. **Monorepo tool:** Turborepo (recommended) / Nx / pnpm workspaces

---

## 💡 Phase 0: Ideation & Brainstorming

Phase ini menggunakan skill `@brainstorming` untuk mengklarifikasi ide sebelum masuk ke dokumentasi teknis.

### Step 0.1: Problem Framing

Gunakan skill `brainstorming`:

```markdown
Act as brainstorming.
Berdasarkan ide user, buatkan Problem Framing Canvas:

## Problem Framing Canvas
### 1. WHAT is the problem? [Satu kalimat spesifik]
### 2. WHO is affected? [Primary users, stakeholders]
### 3. WHY does it matter? [Pain points, business opportunity]
### 4. WHAT constraints exist? [Time, budget, technology]
### 5. WHAT does success look like? [Measurable outcomes]
```

### Step 0.2: Feature Ideation

```markdown
Act as brainstorming.
Generate fitur potensial dengan:
- HMW (How Might We) Questions
- SCAMPER Analysis untuk fitur utama
```

### Step 0.3: Feature Prioritization

```markdown
Act as brainstorming.
Prioritasikan dengan:
- Impact vs Effort Matrix
- RICE Scoring (Reach × Impact × Confidence / Effort)
- MoSCoW: Must Have, Should Have, Could Have, Won't Have
```

### Step 0.4: Quick Validation

```markdown
Act as brainstorming.
Validasi dengan checklist:
- Feasibility: Bisa dibangun?
- Viability: Layak secara bisnis?
- Desirability: User mau pakai?
- Go/No-Go Decision
```

// turbo
**Simpan output ke file `BRAINSTORM.md` di root project.**

---

## 🏗️ Phase 1: Holy Trinity (WAJIB)

### Step 1.1: Generate PRD.md

```
Tanyakan kepada user:
"Jelaskan ide aplikasi full-stack yang ingin dibuat. Sertakan:
- Apa masalah yang diselesaikan?
- Siapa target penggunanya?
- Apa fitur utama frontend dan backend?"
```

Gunakan skill `senior-project-manager`:

```markdown
Act as senior-project-manager.
Saya ingin membuat full-stack app: [IDE USER]

Buatkan file `PRD.md` yang mencakup:
1. Executive Summary (2-3 kalimat)
2. Problem Statement
3. Target User & Persona
4. User Stories (min 10 untuk MVP)
5. Core Features - kategorikan: Must/Should/Could/Won't
6. Frontend Requirements (pages, components, interactions)
7. Backend Requirements (API endpoints, business logic)
8. Data Requirements (entities, relationships)
9. Success Metrics (KPIs, benchmarks)

Output dalam Markdown yang rapi.
```

// turbo
**Simpan output ke file `PRD.md` di root project.**

---

### Step 1.2: Generate TECH_STACK.md

```
Tanyakan kepada user:
"Pilih preferensi:
1. Frontend: Next.js / Nuxt / SvelteKit?
2. Backend: NestJS / Go Fiber / FastAPI?
3. Database: PostgreSQL / MongoDB?
4. ORM: Prisma / Drizzle / TypeORM?"
```

Gunakan skill `tech-stack-architect` + `microservices-architect`:

```markdown
Act as tech-stack-architect dan microservices-architect.
Buatkan file `TECH_STACK.md` untuk full-stack monorepo.

## Monorepo Configuration
- Tool: Turborepo
- Package Manager: pnpm (required for workspaces)
- Language: TypeScript across all packages
- Node.js: 20 LTS

## Repository Structure
```

/
├── apps/
│   ├── web/          # Frontend (Next.js)
│   └── api/          # Backend (NestJS)
│
├── packages/
│   ├── ui/           # Shared React components
│   ├── types/        # Shared TypeScript types
│   ├── utils/        # Shared utilities
│   ├── db/           # Database client (Prisma)
│   ├── config/       # Shared configs
│   ├── eslint-config/
│   └── typescript-config/
│
├── turbo.json
├── pnpm-workspace.yaml
└── package.json

```

## Frontend Stack (apps/web)
- Framework: Next.js 14 (App Router)
- Styling: Tailwind CSS
- State: TanStack Query + Zustand
- UI Components: shadcn/ui (from @repo/ui)
- Forms: React Hook Form + Zod

## Backend Stack (apps/api)
- Framework: NestJS 10
- Language: TypeScript
- Database: PostgreSQL
- ORM: Prisma (from @repo/db)
- Validation: class-validator / Zod
- Auth: Passport.js + JWT
- API Docs: Swagger (OpenAPI)

## Shared Packages
- @repo/ui: Shared React components (shadcn/ui based)
- @repo/types: Shared TypeScript types & Zod schemas
- @repo/utils: Pure utility functions
- @repo/db: Prisma client + generated types
- @repo/config: Shared constants & config

## Infrastructure
- Frontend: Vercel / Cloudflare Pages
- Backend: Railway / Fly.io / Cloud Run
- Database: Supabase / Neon / PlanetScale
- Caching: Redis (optional)

## CI/CD
- GitHub Actions
- Turbo Remote Caching
- Preview Deployments

## Approved Root Dependencies
```json
{
  "devDependencies": {
    "turbo": "^1.11.0",
    "typescript": "^5.3.0",
    "@turbo/gen": "^1.11.0"
  }
}
```

## Constraints

- ALL code must be TypeScript
- Types WAJIB shared via @repo/types
- Database access HANYA via @repo/db
- UI components dari @repo/ui
- DILARANG circular dependencies antar packages

```

// turbo
**Simpan output ke file `TECH_STACK.md` di root project.**

---

### Step 1.3: Generate RULES.md

Gunakan skill `senior-software-architect` + `microservices-architect`:

```markdown
Act as senior-software-architect dan microservices-architect.
Buatkan file `RULES.md` sebagai panduan AI untuk monorepo project.

## Monorepo Architecture Rules
- WAJIB workspace imports: `@repo/ui`, `@repo/types`, etc.
- DILARANG import langsung antar apps (apps/web → apps/api)
- Shared code di packages/, app-specific di apps/
- DILARANG circular dependencies

## TypeScript Rules
- Strict mode di SEMUA packages
- Shared tsconfig extends `@repo/typescript-config`
- Types di @repo/types, bukan duplikat
- DILARANG `any` - gunakan `unknown`

## Workspace Import Rules
```typescript
// ✅ BENAR - Import dari packages
import { Button } from '@repo/ui';
import { User, CreateUserDto } from '@repo/types';
import { prisma } from '@repo/db';
import { formatDate } from '@repo/utils';

// ❌ SALAH - Import langsung antar apps
import { something } from '../../api/src/modules/users';
import { component } from '../web/src/components';
```

## Frontend Rules (apps/web)

- [Ikuti aturan dari /vibe-coding-react]
- Import UI components dari @repo/ui
- Import types dari @repo/types
- API calls via TanStack Query ke apps/api

## Backend Rules (apps/api)

- [Ikuti aturan dari /vibe-coding-nestjs]
- Database access via @repo/db (Prisma)
- DTOs menggunakan types dari @repo/types
- Response types WAJIB match @repo/types

## Package Rules

### @repo/ui

- React components only
- shadcn/ui as base
- Props interfaces di tiap component
- Export via barrel (index.ts)

### @repo/types

- TypeScript interfaces/types
- Zod schemas untuk validation
- WAJIB export untuk FE dan BE
- No runtime dependencies

### @repo/utils

- Pure functions only
- DILARANG import React/NestJS
- Unit tested
- Tree-shakeable

### @repo/db

- Prisma schema
- Prisma client singleton
- Generated types exported
- Migration scripts

## API Contract Rules

- Response types dari @repo/types
- Request DTOs dari @repo/types (dengan Zod)
- Error format consistent
- API versioning (v1, v2)

## Development Workflow Rules

- `pnpm install` dari root
- `turbo dev` untuk parallel dev
- Branch per feature
- PR required untuk main

## AI Behavior Rules

1. CHECK workspace structure sebelum create files
2. IMPORT dari packages, bukan relative paths
3. SHARED types di @repo/types
4. RUN turbo commands dari root
5. VALIDASI import sebelum commit
6. Jika ragu package mana, TANYA user

## Build & Deploy Rules

```bash
# Development
turbo dev

# Type check all
turbo type-check

# Build all
turbo build

# Test all
turbo test

# Lint all
turbo lint
```

```

// turbo
**Simpan output ke file `RULES.md` di root project.**

---

## 🎨 Phase 2: Support System

### Step 2.1: Generate DESIGN_SYSTEM.md

```

Tanyakan kepada user:
"Jelaskan vibe/estetika yang diinginkan untuk aplikasi ini."

```

Gunakan skill `design-system-architect`:

```markdown
Act as design-system-architect.
Buatkan `DESIGN_SYSTEM.md` untuk full-stack app dengan vibe: [VIBE USER]

## 1. Color Palette

### CSS Variables (packages/ui/src/styles/tokens.css)
```css
:root {
  /* Brand Colors */
  --color-primary-50: #eff6ff;
  --color-primary-100: #dbeafe;
  --color-primary-500: #3b82f6;
  --color-primary-600: #2563eb;
  --color-primary-700: #1d4ed8;
  
  /* Neutral */
  --color-gray-50: #f9fafb;
  --color-gray-100: #f3f4f6;
  --color-gray-200: #e5e7eb;
  --color-gray-300: #d1d5db;
  --color-gray-400: #9ca3af;
  --color-gray-500: #6b7280;
  --color-gray-600: #4b5563;
  --color-gray-700: #374151;
  --color-gray-800: #1f2937;
  --color-gray-900: #111827;
  
  /* Semantic */
  --color-success: #22c55e;
  --color-warning: #f59e0b;
  --color-error: #ef4444;
  --color-info: #3b82f6;
  
  /* Surface */
  --bg-primary: #ffffff;
  --bg-secondary: var(--color-gray-50);
  --text-primary: var(--color-gray-900);
  --text-secondary: var(--color-gray-600);
  --border-color: var(--color-gray-200);
}

.dark {
  --bg-primary: var(--color-gray-900);
  --bg-secondary: var(--color-gray-800);
  --text-primary: var(--color-gray-50);
  --text-secondary: var(--color-gray-400);
  --border-color: var(--color-gray-700);
}
```

### TypeScript Constants (packages/ui/src/lib/colors.ts)

```typescript
export const colors = {
  primary: {
    50: 'var(--color-primary-50)',
    500: 'var(--color-primary-500)',
    600: 'var(--color-primary-600)',
    700: 'var(--color-primary-700)',
  },
  // ... rest
} as const;
```

## 2. Typography

### Font Setup

```typescript
// apps/web/src/lib/fonts.ts
import { Inter, JetBrains_Mono } from 'next/font/google';

export const fontSans = Inter({
  subsets: ['latin'],
  variable: '--font-sans',
});

export const fontMono = JetBrains_Mono({
  subsets: ['latin'],
  variable: '--font-mono',
});
```

### Scale

```css
.text-display { @apply text-4xl font-bold tracking-tight sm:text-5xl; }
.text-h1 { @apply text-3xl font-bold tracking-tight; }
.text-h2 { @apply text-2xl font-semibold; }
.text-h3 { @apply text-xl font-semibold; }
.text-h4 { @apply text-lg font-medium; }
.text-body { @apply text-base; }
.text-body-sm { @apply text-sm; }
.text-caption { @apply text-xs text-muted-foreground; }
```

## 3. Spacing & Layout

```typescript
// 4px base unit (Tailwind default)
// p-1: 4px, p-2: 8px, p-4: 16px, p-6: 24px, p-8: 32px

// Container widths
// max-w-screen-sm: 640px
// max-w-screen-md: 768px
// max-w-screen-lg: 1024px
// max-w-screen-xl: 1280px
// max-w-screen-2xl: 1536px
```

## 4. Component Library (@repo/ui)

### Button

```typescript
// packages/ui/src/components/button.tsx
import { cva, type VariantProps } from 'class-variance-authority';

const buttonVariants = cva(
  'inline-flex items-center justify-center rounded-md text-sm font-medium transition-colors focus-visible:outline-none focus-visible:ring-2 disabled:pointer-events-none disabled:opacity-50',
  {
    variants: {
      variant: {
        default: 'bg-primary text-primary-foreground hover:bg-primary/90',
        destructive: 'bg-destructive text-destructive-foreground hover:bg-destructive/90',
        outline: 'border border-input bg-background hover:bg-accent',
        secondary: 'bg-secondary text-secondary-foreground hover:bg-secondary/80',
        ghost: 'hover:bg-accent hover:text-accent-foreground',
        link: 'text-primary underline-offset-4 hover:underline',
      },
      size: {
        default: 'h-10 px-4 py-2',
        sm: 'h-9 rounded-md px-3',
        lg: 'h-11 rounded-md px-8',
        icon: 'h-10 w-10',
      },
    },
    defaultVariants: {
      variant: 'default',
      size: 'default',
    },
  }
);

export interface ButtonProps
  extends React.ButtonHTMLAttributes<HTMLButtonElement>,
    VariantProps<typeof buttonVariants> {
  loading?: boolean;
}
```

### Card

```typescript
// packages/ui/src/components/card.tsx
export const Card = React.forwardRef<
  HTMLDivElement,
  React.HTMLAttributes<HTMLDivElement>
>(({ className, ...props }, ref) => (
  <div
    ref={ref}
    className={cn(
      'rounded-lg border bg-card text-card-foreground shadow-sm',
      className
    )}
    {...props}
  />
));
```

### Input

```typescript
// packages/ui/src/components/input.tsx
export interface InputProps extends React.InputHTMLAttributes<HTMLInputElement> {
  error?: string;
}

const Input = React.forwardRef<HTMLInputElement, InputProps>(
  ({ className, error, ...props }, ref) => (
    <div className="space-y-1">
      <input
        className={cn(
          'flex h-10 w-full rounded-md border border-input bg-background px-3 py-2 text-sm',
          'focus:outline-none focus:ring-2 focus:ring-ring focus:ring-offset-2',
          error && 'border-destructive focus:ring-destructive',
          className
        )}
        ref={ref}
        {...props}
      />
      {error && <p className="text-sm text-destructive">{error}</p>}
    </div>
  )
);
```

## 5. Animation & Motion

```typescript
// packages/ui/src/lib/motion.ts
export const fadeIn = {
  initial: { opacity: 0 },
  animate: { opacity: 1 },
  exit: { opacity: 0 },
};

export const slideUp = {
  initial: { opacity: 0, y: 20 },
  animate: { opacity: 1, y: 0 },
  exit: { opacity: 0, y: -20 },
};

export const spring = {
  type: 'spring',
  stiffness: 300,
  damping: 30,
};
```

```

// turbo
**Simpan output ke file `DESIGN_SYSTEM.md` di root project.**

---

### Step 2.2: Generate FOLDER_STRUCTURE.md

Gunakan skill `senior-software-architect`:

```markdown
Act as senior-software-architect.
Buatkan `FOLDER_STRUCTURE.md` untuk Turborepo monorepo.

## Monorepo Structure

```

/
├── .github/
│   └── workflows/
│       ├── ci.yml                   # CI pipeline
│       └── deploy.yml               # Deployment
│
├── apps/
│   ├── web/                         # Next.js Frontend
│   │   ├── src/
│   │   │   ├── app/                 # App Router pages
│   │   │   │   ├── (auth)/
│   │   │   │   │   ├── login/
│   │   │   │   │   └── register/
│   │   │   │   ├── (dashboard)/
│   │   │   │   │   ├── dashboard/
│   │   │   │   │   └── settings/
│   │   │   │   ├── layout.tsx
│   │   │   │   └── page.tsx
│   │   │   │
│   │   │   ├── components/          # App-specific components
│   │   │   │   ├── forms/
│   │   │   │   └── layouts/
│   │   │   │
│   │   │   ├── lib/
│   │   │   │   ├── api/             # API client
│   │   │   │   ├── hooks/           # Custom hooks
│   │   │   │   ├── stores/          # Zustand stores
│   │   │   │   └── utils/
│   │   │   │
│   │   │   └── styles/
│   │   │       └── globals.css
│   │   │
│   │   ├── public/
│   │   ├── next.config.js
│   │   ├── tailwind.config.ts
│   │   ├── tsconfig.json
│   │   └── package.json
│   │
│   └── api/                         # NestJS Backend
│       ├── src/
│       │   ├── common/              # Shared utilities
│       │   │   ├── decorators/
│       │   │   ├── filters/
│       │   │   ├── guards/
│       │   │   ├── interceptors/
│       │   │   └── pipes/
│       │   │
│       │   ├── modules/             # Feature modules
│       │   │   ├── auth/
│       │   │   │   ├── auth.controller.ts
│       │   │   │   ├── auth.service.ts
│       │   │   │   ├── auth.module.ts
│       │   │   │   ├── strategies/
│       │   │   │   └── guards/
│       │   │   │
│       │   │   └── users/
│       │   │       ├── users.controller.ts
│       │   │       ├── users.service.ts
│       │   │       ├── users.module.ts
│       │   │       └── users.repository.ts
│       │   │
│       │   ├── app.module.ts
│       │   └── main.ts
│       │
│       ├── test/
│       ├── tsconfig.json
│       └── package.json
│
├── packages/
│   ├── ui/                          # Shared React components
│   │   ├── src/
│   │   │   ├── components/
│   │   │   │   ├── button.tsx
│   │   │   │   ├── card.tsx
│   │   │   │   ├── input.tsx
│   │   │   │   └── index.ts
│   │   │   │
│   │   │   ├── lib/
│   │   │   │   ├── utils.ts
│   │   │   │   └── cn.ts
│   │   │   │
│   │   │   └── index.ts             # Barrel export
│   │   │
│   │   ├── tsconfig.json
│   │   └── package.json
│   │
│   ├── types/                       # Shared TypeScript types
│   │   ├── src/
│   │   │   ├── user.ts
│   │   │   ├── api.ts
│   │   │   ├── common.ts
│   │   │   └── index.ts
│   │   │
│   │   ├── tsconfig.json
│   │   └── package.json
│   │
│   ├── utils/                       # Shared utilities
│   │   ├── src/
│   │   │   ├── format.ts
│   │   │   ├── validation.ts
│   │   │   └── index.ts
│   │   │
│   │   ├── tsconfig.json
│   │   └── package.json
│   │
│   ├── db/                          # Prisma database
│   │   ├── prisma/
│   │   │   ├── schema.prisma
│   │   │   └── migrations/
│   │   │
│   │   ├── src/
│   │   │   ├── client.ts
│   │   │   └── index.ts
│   │   │
│   │   ├── tsconfig.json
│   │   └── package.json
│   │
│   ├── eslint-config/               # Shared ESLint config
│   │   ├── next.js
│   │   ├── nest.js
│   │   ├── library.js
│   │   └── package.json
│   │
│   └── typescript-config/           # Shared TSConfig
│       ├── base.json
│       ├── nextjs.json
│       ├── nestjs.json
│       └── package.json
│
├── turbo.json                       # Turborepo config
├── pnpm-workspace.yaml              # Workspace config
├── package.json                     # Root package.json
├── tsconfig.json                    # Root TSConfig
└── .env.example

```

## Package Naming Convention
- Workspace: `@repo/package-name`
- Apps: `@repo/web`, `@repo/api`
- Packages: `@repo/ui`, `@repo/types`, `@repo/db`

## Import Examples
```typescript
// From apps/web
import { Button, Card, Input } from '@repo/ui';
import { User, ApiResponse } from '@repo/types';
import { formatDate } from '@repo/utils';

// From apps/api
import { User, CreateUserDto } from '@repo/types';
import { prisma } from '@repo/db';
```

```

// turbo
**Simpan output ke file `FOLDER_STRUCTURE.md` di root project.**

---

### Step 2.3: Generate DB_SCHEMA.md

Gunakan skill `database-modeling-specialist`:

```markdown
Buatkan `DB_SCHEMA.md` sesuai fitur di PRD.md.

Include:
- Prisma schema (packages/db/prisma/schema.prisma)
- TypeScript types (packages/types/src/user.ts)
- Relationships & indexes
```

// turbo
**Simpan output ke file `DB_SCHEMA.md` di root project.**

---

### Step 2.4: Generate API_CONTRACT.md

Gunakan skill `api-design-specialist`:

```markdown
Buatkan `API_CONTRACT.md` untuk full-stack app.

Include:
- Endpoint definitions
- Request/Response types (reference @repo/types)
- Swagger/OpenAPI format
```

// turbo
**Simpan output ke file `API_CONTRACT.md` di root project.**

---

### Step 2.5: Generate EXAMPLES.md

Gunakan skill `senior-software-architect`:

```markdown
Act as senior-software-architect.
Buatkan `EXAMPLES.md` berisi contoh kode monorepo yang jadi standar project.

## 1. Shared Types (@repo/types)

```typescript
// packages/types/src/user.ts
import { z } from 'zod';

// Zod Schema (for validation)
export const userSchema = z.object({
  id: z.string().uuid(),
  email: z.string().email(),
  name: z.string().min(2),
  role: z.enum(['USER', 'ADMIN']),
  createdAt: z.date(),
  updatedAt: z.date(),
});

// Inferred type (for TypeScript)
export type User = z.infer<typeof userSchema>;

// DTOs
export const createUserSchema = userSchema.omit({ 
  id: true, 
  createdAt: true, 
  updatedAt: true 
});
export type CreateUserDto = z.infer<typeof createUserSchema>;

export const updateUserSchema = createUserSchema.partial();
export type UpdateUserDto = z.infer<typeof updateUserSchema>;
```

```typescript
// packages/types/src/api.ts
export interface ApiResponse<T> {
  data: T;
  message?: string;
}

export interface ApiError {
  statusCode: number;
  message: string;
  error?: string;
}

export interface PaginatedResponse<T> {
  data: T[];
  meta: {
    total: number;
    page: number;
    limit: number;
    totalPages: number;
  };
}
```

## 2. Shared UI Components (@repo/ui)

```typescript
// packages/ui/src/components/button.tsx
import * as React from 'react';
import { Slot } from '@radix-ui/react-slot';
import { cva, type VariantProps } from 'class-variance-authority';
import { cn } from '../lib/utils';

const buttonVariants = cva(
  'inline-flex items-center justify-center rounded-md text-sm font-medium ring-offset-background transition-colors focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2 disabled:pointer-events-none disabled:opacity-50',
  {
    variants: {
      variant: {
        default: 'bg-primary text-primary-foreground hover:bg-primary/90',
        destructive: 'bg-destructive text-destructive-foreground hover:bg-destructive/90',
        outline: 'border border-input bg-background hover:bg-accent hover:text-accent-foreground',
        secondary: 'bg-secondary text-secondary-foreground hover:bg-secondary/80',
        ghost: 'hover:bg-accent hover:text-accent-foreground',
        link: 'text-primary underline-offset-4 hover:underline',
      },
      size: {
        default: 'h-10 px-4 py-2',
        sm: 'h-9 rounded-md px-3',
        lg: 'h-11 rounded-md px-8',
        icon: 'h-10 w-10',
      },
    },
    defaultVariants: {
      variant: 'default',
      size: 'default',
    },
  }
);

export interface ButtonProps
  extends React.ButtonHTMLAttributes<HTMLButtonElement>,
    VariantProps<typeof buttonVariants> {
  asChild?: boolean;
  loading?: boolean;
}

const Button = React.forwardRef<HTMLButtonElement, ButtonProps>(
  ({ className, variant, size, asChild = false, loading, children, ...props }, ref) => {
    const Comp = asChild ? Slot : 'button';
    return (
      <Comp
        className={cn(buttonVariants({ variant, size, className }))}
        ref={ref}
        disabled={loading || props.disabled}
        {...props}
      >
        {loading ? (
          <>
            <span className="mr-2 animate-spin">⏳</span>
            Loading...
          </>
        ) : (
          children
        )}
      </Comp>
    );
  }
);
Button.displayName = 'Button';

export { Button, buttonVariants };
```

```typescript
// packages/ui/src/index.ts (barrel export)
export * from './components/button';
export * from './components/card';
export * from './components/input';
export * from './lib/utils';
```

## 3. Database Client (@repo/db)

```typescript
// packages/db/src/client.ts
import { PrismaClient } from '@prisma/client';

declare global {
  var prisma: PrismaClient | undefined;
}

export const prisma = global.prisma || new PrismaClient({
  log: process.env.NODE_ENV === 'development' ? ['query', 'error', 'warn'] : ['error'],
});

if (process.env.NODE_ENV !== 'production') {
  global.prisma = prisma;
}
```

```typescript
// packages/db/src/index.ts
export { prisma } from './client';
export * from '@prisma/client';
```

## 4. Frontend Usage (apps/web)

```typescript
// apps/web/src/lib/api/client.ts
import { ApiResponse, ApiError } from '@repo/types';

const API_URL = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:3001';

export async function apiClient<T>(
  endpoint: string,
  options?: RequestInit
): Promise<ApiResponse<T>> {
  const response = await fetch(`${API_URL}${endpoint}`, {
    ...options,
    headers: {
      'Content-Type': 'application/json',
      ...options?.headers,
    },
  });

  if (!response.ok) {
    const error: ApiError = await response.json();
    throw new Error(error.message);
  }

  return response.json();
}
```

```typescript
// apps/web/src/lib/hooks/use-users.ts
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { User, CreateUserDto, PaginatedResponse } from '@repo/types';
import { apiClient } from '../api/client';

export const userKeys = {
  all: ['users'] as const,
  list: (page: number, limit: number) => [...userKeys.all, 'list', page, limit] as const,
  detail: (id: string) => [...userKeys.all, 'detail', id] as const,
};

export function useUsers(page = 1, limit = 10) {
  return useQuery({
    queryKey: userKeys.list(page, limit),
    queryFn: () => 
      apiClient<PaginatedResponse<User>>(`/users?page=${page}&limit=${limit}`),
  });
}

export function useUser(id: string) {
  return useQuery({
    queryKey: userKeys.detail(id),
    queryFn: () => apiClient<User>(`/users/${id}`),
    enabled: !!id,
  });
}

export function useCreateUser() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: (data: CreateUserDto) =>
      apiClient<User>('/users', {
        method: 'POST',
        body: JSON.stringify(data),
      }),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: userKeys.all });
    },
  });
}
```

```tsx
// apps/web/src/app/(dashboard)/users/page.tsx
import { Button, Card } from '@repo/ui';
import { useUsers } from '@/lib/hooks/use-users';

export default function UsersPage() {
  const { data, isLoading, error } = useUsers();

  if (isLoading) return <div>Loading...</div>;
  if (error) return <div>Error: {error.message}</div>;

  return (
    <div className="container py-8">
      <h1 className="text-h1 mb-8">Users</h1>
      <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-3">
        {data?.data.data.map((user) => (
          <Card key={user.id} className="p-6">
            <h3 className="font-semibold">{user.name}</h3>
            <p className="text-sm text-muted-foreground">{user.email}</p>
            <Button variant="outline" size="sm" className="mt-4">
              View Details
            </Button>
          </Card>
        ))}
      </div>
    </div>
  );
}
```

## 5. Backend Usage (apps/api)

```typescript
// apps/api/src/modules/users/users.controller.ts
import { Controller, Get, Post, Body, Param, Query } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse } from '@nestjs/swagger';
import { User, CreateUserDto, PaginatedResponse } from '@repo/types';
import { UsersService } from './users.service';

@ApiTags('users')
@Controller('users')
export class UsersController {
  constructor(private readonly usersService: UsersService) {}

  @Get()
  @ApiOperation({ summary: 'Get all users' })
  @ApiResponse({ status: 200, description: 'Return all users' })
  async findAll(
    @Query('page') page = 1,
    @Query('limit') limit = 10,
  ): Promise<PaginatedResponse<User>> {
    return this.usersService.findAll(+page, +limit);
  }

  @Get(':id')
  @ApiOperation({ summary: 'Get user by ID' })
  async findOne(@Param('id') id: string): Promise<User> {
    return this.usersService.findOne(id);
  }

  @Post()
  @ApiOperation({ summary: 'Create new user' })
  async create(@Body() createUserDto: CreateUserDto): Promise<User> {
    return this.usersService.create(createUserDto);
  }
}
```

```typescript
// apps/api/src/modules/users/users.service.ts
import { Injectable, NotFoundException } from '@nestjs/common';
import { User, CreateUserDto, PaginatedResponse } from '@repo/types';
import { prisma } from '@repo/db';

@Injectable()
export class UsersService {
  async findAll(page: number, limit: number): Promise<PaginatedResponse<User>> {
    const skip = (page - 1) * limit;
    
    const [users, total] = await Promise.all([
      prisma.user.findMany({
        skip,
        take: limit,
        orderBy: { createdAt: 'desc' },
      }),
      prisma.user.count(),
    ]);

    return {
      data: users,
      meta: {
        total,
        page,
        limit,
        totalPages: Math.ceil(total / limit),
      },
    };
  }

  async findOne(id: string): Promise<User> {
    const user = await prisma.user.findUnique({ where: { id } });
    
    if (!user) {
      throw new NotFoundException('User not found');
    }
    
    return user;
  }

  async create(data: CreateUserDto): Promise<User> {
    return prisma.user.create({ data });
  }
}
```

## 6. Turbo Configuration

```json
// turbo.json
{
  "$schema": "https://turbo.build/schema.json",
  "globalDependencies": [".env"],
  "globalEnv": ["NODE_ENV"],
  "pipeline": {
    "build": {
      "dependsOn": ["^build"],
      "outputs": ["dist/**", ".next/**", "!.next/cache/**"]
    },
    "dev": {
      "cache": false,
      "persistent": true
    },
    "lint": {
      "dependsOn": ["^build"]
    },
    "type-check": {
      "dependsOn": ["^build"]
    },
    "test": {
      "dependsOn": ["build"],
      "outputs": ["coverage/**"]
    },
    "db:generate": {
      "cache": false
    },
    "db:push": {
      "cache": false
    },
    "db:migrate": {
      "cache": false
    }
  }
}
```

```yaml
# pnpm-workspace.yaml
packages:
  - 'apps/*'
  - 'packages/*'
```

## 7. Root Scripts

```json
// package.json (root)
{
  "name": "monorepo",
  "private": true,
  "scripts": {
    "dev": "turbo dev",
    "build": "turbo build",
    "lint": "turbo lint",
    "type-check": "turbo type-check",
    "test": "turbo test",
    "clean": "turbo clean",
    "db:generate": "turbo db:generate",
    "db:push": "turbo db:push",
    "db:migrate": "turbo db:migrate",
    "format": "prettier --write \"**/*.{ts,tsx,md}\""
  },
  "devDependencies": {
    "turbo": "^1.11.0",
    "prettier": "^3.2.0"
  },
  "engines": {
    "node": ">=20"
  },
  "packageManager": "pnpm@8.12.0"
}
```

```

// turbo
**Simpan output ke file `EXAMPLES.md` di root project.**

---

## ✅ Phase 3: Project Setup

### Step 3.1: Create Turborepo Project

// turbo

```bash
npx create-turbo@latest . --package-manager pnpm
```

### Step 3.2: Setup Apps

// turbo

```bash
# Frontend (apps/web)
cd apps/web && npx create-next-app@latest . --typescript --tailwind --eslint --app --src-dir
pnpm add @tanstack/react-query zustand react-hook-form @hookform/resolvers zod

# Backend (apps/api)
cd ../api && npx @nestjs/cli new . --package-manager pnpm
pnpm add @nestjs/swagger class-validator class-transformer

cd ../..
```

### Step 3.3: Setup Packages

// turbo

```bash
# Create packages structure
mkdir -p packages/{ui,types,utils,db}/src

# Setup Prisma in @repo/db
cd packages/db && pnpm add prisma @prisma/client && npx prisma init
cd ../..
```

### Step 3.4: Install Workspace Dependencies

// turbo

```bash
pnpm install
turbo build
```

---

## 📁 Final Checklist

```
/project-root
├── PRD.md                 ✅ Holy Trinity
├── TECH_STACK.md          ✅ Holy Trinity
├── RULES.md               ✅ Holy Trinity
├── DESIGN_SYSTEM.md       ✅ Support System
├── DB_SCHEMA.md           ✅ Support System
├── FOLDER_STRUCTURE.md    ✅ Support System
├── API_CONTRACT.md        ✅ Support System
├── EXAMPLES.md            ✅ Support System
├── turbo.json             ✅ Turbo Config
├── pnpm-workspace.yaml    ✅ Workspace
├── apps/
│   ├── web/               ✅ Frontend
│   └── api/               ✅ Backend
└── packages/
    ├── ui/                ✅ UI Components
    ├── types/             ✅ Shared Types
    ├── utils/             ✅ Utilities
    └── db/                ✅ Database
```

---

## 💡 Monorepo Tips

### Magic Words untuk Prompts

- "Import dari @repo/ui, bukan local component"
- "Type harus dari @repo/types"
- "Gunakan prisma dari @repo/db"
- "Jalankan dengan turbo, bukan npm"
- "Check FOLDER_STRUCTURE.md untuk lokasi file"

### Common Mistakes to Avoid

| ❌ Jangan | ✅ Lakukan |
| --------- | --------- |
| npm install | pnpm install (dari root) |
| npm run dev | turbo dev |
| Import dari "../../../api" | Import dari @repo/types |
| Duplikat types | Shared di @repo/types |
| Prisma di tiap app | Prisma di @repo/db |

### Development Commands

```bash
# Start all apps
turbo dev

# Build all
turbo build

# Run specific app
turbo dev --filter=web
turbo dev --filter=api

# Run with dependencies
turbo dev --filter=web...

# Clear cache
turbo clean
```

### Troubleshooting

| Issue | Solution |
| ----- | -------- |
| Package not found | Run `pnpm install` from root |
| Type errors | Run `turbo build` to build packages first |
| Prisma types missing | Run `turbo db:generate` |
| Cache issues | Run `turbo clean && turbo build` |

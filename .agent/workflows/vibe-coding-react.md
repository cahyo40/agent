---
description: Initialize Vibe Coding context files for React/Next.js web application with modern patterns
---

# /vibe-coding-react

Workflow untuk setup dokumen konteks Vibe Coding khusus **React/Next.js Web Application** dengan App Router, Server Components, dan modern patterns.

---

## 📋 Prerequisites

Sebelum memulai, siapkan informasi berikut:

1. **Deskripsi ide aplikasi** (2-3 paragraf)
2. **Jenis aplikasi:**
   - 🌐 SPA (Single Page Application)
   - ⚡ SSR (Server-Side Rendering)
   - 📄 SSG (Static Site Generation)
   - 🔄 Hybrid (SSR + SSG)
3. **State management preference** (TanStack Query/Zustand/Redux)
4. **Backend preference** (Supabase/Firebase/Custom API)
5. **Vibe/estetika** yang diinginkan

---

## 🏗️ Phase 1: Holy Trinity (WAJIB)

### Step 1.1: Generate PRD.md

```
Tanyakan kepada user:
"Jelaskan ide aplikasi React/Next.js yang ingin dibuat. Sertakan:
- Apa masalah yang diselesaikan?
- Siapa target penggunanya?
- Apa fitur utama yang diinginkan?
- Apakah perlu SSR/SSG?"
```

Gunakan skill `senior-project-manager`:

```markdown
Act as senior-project-manager.
Saya ingin membuat web app React/Next.js: [IDE USER]

Buatkan file `PRD.md` yang mencakup:
1. Executive Summary (2-3 kalimat)
2. Problem Statement
3. Target User & Persona
4. User Stories (min 10 untuk MVP, format: As a [role], I want to [action], so that [benefit])
5. Core Features - kategorikan: Must Have, Should Have, Could Have, Won't Have
6. User Flow per fitur utama
7. SEO Requirements (jika perlu)
8. Success Metrics (DAU, Conversion Rate, Core Web Vitals)

Output dalam Markdown yang rapi.
```

// turbo
**Simpan output ke file `PRD.md` di root project.**

---

### Step 1.2: Generate TECH_STACK.md

```
Tanyakan kepada user:
"Pilih preferensi:
1. State Management: TanStack Query + Zustand / Redux Toolkit?
2. Styling: Tailwind CSS / CSS Modules / styled-components?
3. UI Components: shadcn/ui / Radix UI / custom?
4. Backend: Supabase / Firebase / Custom REST API?"
```

Gunakan skill `tech-stack-architect` + `senior-nextjs-developer`:

```markdown
Act as tech-stack-architect dan senior-nextjs-developer.
Buatkan file `TECH_STACK.md` untuk React/Next.js app.

## Core Stack
- Framework: Next.js 14+ (App Router)
- Language: TypeScript 5.x (strict mode)
- Runtime: Node.js 20 LTS
- Package Manager: pnpm (recommended)

## Rendering Strategy
- Default: React Server Components
- Client Components: Hanya untuk interactivity
- Streaming: Suspense boundaries
- Caching: ISR + On-demand Revalidation

## State Management
- Server State: TanStack Query v5
- Client State: Zustand
- Form State: React Hook Form + Zod
- URL State: nuqs (type-safe query params)

## Styling & UI
- Framework: Tailwind CSS 3.4+
- Components: shadcn/ui (Radix primitives)
- Icons: Lucide React
- Animation: Framer Motion
- Fonts: next/font (Google Fonts)

## Backend & Data
- Backend: [Supabase / Firebase / Custom]
- Auth: [NextAuth.js / Supabase Auth / Clerk]
- Database: [PostgreSQL / MongoDB]
- API: Next.js Route Handlers + Server Actions

## Testing
- Unit: Vitest + React Testing Library
- E2E: Playwright
- Coverage Target: 80%

## Code Quality
- Linting: ESLint + eslint-config-next
- Formatting: Prettier
- Type Check: TypeScript strict
- Git Hooks: Husky + lint-staged

## Approved Packages (package.json)
```json
{
  "dependencies": {
    "next": "^14.1.0",
    "react": "^18.2.0",
    "react-dom": "^18.2.0",
    "@tanstack/react-query": "^5.17.0",
    "zustand": "^4.5.0",
    "react-hook-form": "^7.49.0",
    "@hookform/resolvers": "^3.3.0",
    "zod": "^3.22.0",
    "nuqs": "^1.15.0",
    "framer-motion": "^10.18.0",
    "lucide-react": "^0.309.0",
    "clsx": "^2.1.0",
    "tailwind-merge": "^2.2.0",
    "date-fns": "^3.2.0",
    "@radix-ui/react-slot": "^1.0.2",
    "class-variance-authority": "^0.7.0"
  },
  "devDependencies": {
    "@types/node": "^20.11.0",
    "@types/react": "^18.2.0",
    "@types/react-dom": "^18.2.0",
    "typescript": "^5.3.0",
    "tailwindcss": "^3.4.0",
    "postcss": "^8.4.0",
    "autoprefixer": "^10.4.0",
    "eslint": "^8.56.0",
    "eslint-config-next": "^14.1.0",
    "prettier": "^3.2.0",
    "prettier-plugin-tailwindcss": "^0.5.0"
  }
}
```

## Constraints

- Package di luar daftar DILARANG tanpa approval
- Semua dependency harus versi stable
- WAJIB TypeScript strict mode
- WAJIB ESLint & Prettier

```

// turbo
**Simpan output ke file `TECH_STACK.md` di root project.**

---

### Step 1.3: Generate RULES.md

Gunakan skill `senior-nextjs-developer`:

```markdown
Act as senior-nextjs-developer.
Buatkan file `RULES.md` sebagai panduan AI untuk React/Next.js project.

## TypeScript Rules
- Strict mode WAJIB
- DILARANG menggunakan `any`, gunakan `unknown` atau proper types
- Semua function harus punya return type eksplisit
- Props dengan interface, gunakan naming `[Component]Props`
- Prefer `type` untuk unions, `interface` untuk objects

## Next.js App Router Rules
- Server Components by default
- `'use client'` HANYA jika butuh hooks/interactivity
- Data fetching di Server Components, bukan useEffect
- Server Actions untuk mutations
- Route Handlers untuk API endpoints

## Component Rules
- Max 150 baris per component
- Extract logic ke custom hooks
- Gunakan composition over props drilling
- Memoize expensive computations dengan useMemo
- Memoize callbacks dengan useCallback (hanya jika perlu)

## Styling Rules
- Tailwind CSS utilities only
- Gunakan `cn()` helper untuk conditional classes
- Mobile-first responsive design
- CSS variables untuk theming
- DILARANG inline styles

## State Management Rules
- TanStack Query untuk server state (fetching, caching)
- Zustand untuk client state (UI state, modals)
- React Hook Form untuk form state
- URL state dengan nuqs untuk shareable state
- JANGAN mix responsibilities

## File & Naming Conventions
- Components: `PascalCase.tsx`
- Hooks: `use-kebab-case.ts`
- Utils: `kebab-case.ts`
- Types: `types.ts` atau inline
- Routes: `kebab-case` folders

## Import Order
1. React/Next.js imports
2. External libraries
3. Internal absolute imports (@/)
4. Relative imports
5. Types
6. Styles

## Error Handling Rules
- Error Boundaries untuk component errors
- try-catch untuk async operations
- User-friendly error messages
- Loading states untuk async content
- Empty states untuk no data

## Performance Rules
- Images dengan next/image
- Fonts dengan next/font
- Dynamic imports untuk code splitting
- Suspense boundaries untuk streaming
- Proper key props untuk lists

## AI Behavior Rules
1. JANGAN import package yang tidak ada di package.json
2. JANGAN tinggalkan komentar `// TODO` atau placeholder
3. JANGAN menebak nama field dari API - refer ke API_CONTRACT.md
4. IKUTI struktur folder di FOLDER_STRUCTURE.md
5. IKUTI pola coding yang ada di EXAMPLES.md
6. SELALU handle loading, error, dan empty state
7. SELALU validasi dengan TypeScript
8. Server Components first, Client Components only when needed

## Workflow Rules
- Sebelum coding, jelaskan rencana dalam 3 bullet points
- Setelah coding, validasi dengan `npm run lint && npm run type-check`
- Jika ragu, TANYA user
```

// turbo
**Simpan output ke file `RULES.md` di root project.**

---

## 🎨 Phase 2: Support System

### Step 2.1: Generate DESIGN_SYSTEM.md

```
Tanyakan kepada user:
"Jelaskan vibe/estetika yang diinginkan untuk web app ini."
```

Gunakan skill `design-system-architect` + `senior-tailwindcss-developer`:

```markdown
Act as design-system-architect dan senior-tailwindcss-developer.
Buatkan `DESIGN_SYSTEM.md` untuk React/Next.js app dengan vibe: [VIBE USER]

## 1. Color Palette

### CSS Variables (globals.css)
```css
:root {
  --background: 0 0% 100%;
  --foreground: 222.2 84% 4.9%;
  --card: 0 0% 100%;
  --card-foreground: 222.2 84% 4.9%;
  --popover: 0 0% 100%;
  --popover-foreground: 222.2 84% 4.9%;
  --primary: 221.2 83.2% 53.3%;
  --primary-foreground: 210 40% 98%;
  --secondary: 210 40% 96.1%;
  --secondary-foreground: 222.2 47.4% 11.2%;
  --muted: 210 40% 96.1%;
  --muted-foreground: 215.4 16.3% 46.9%;
  --accent: 210 40% 96.1%;
  --accent-foreground: 222.2 47.4% 11.2%;
  --destructive: 0 84.2% 60.2%;
  --destructive-foreground: 210 40% 98%;
  --border: 214.3 31.8% 91.4%;
  --input: 214.3 31.8% 91.4%;
  --ring: 221.2 83.2% 53.3%;
  --radius: 0.5rem;
}

.dark {
  --background: 222.2 84% 4.9%;
  --foreground: 210 40% 98%;
  /* ... dark mode colors */
}
```

### Semantic Colors

```typescript
// lib/constants/colors.ts
export const semanticColors = {
  success: 'hsl(142.1 76.2% 36.3%)',
  warning: 'hsl(45.4 93.4% 47.5%)',
  error: 'hsl(0 84.2% 60.2%)',
  info: 'hsl(221.2 83.2% 53.3%)',
};
```

## 2. Typography

### Font Setup (next/font)

```typescript
// lib/fonts.ts
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

### Typography Scale

```css
/* Tailwind classes */
.text-h1 { @apply text-4xl font-bold tracking-tight lg:text-5xl; }
.text-h2 { @apply text-3xl font-semibold tracking-tight; }
.text-h3 { @apply text-2xl font-semibold tracking-tight; }
.text-h4 { @apply text-xl font-semibold tracking-tight; }
.text-body { @apply text-base; }
.text-body-sm { @apply text-sm; }
.text-caption { @apply text-xs text-muted-foreground; }
```

## 3. Spacing System

```typescript
// Tailwind default spacing (4px base)
// xs: 4px   (p-1)
// sm: 8px   (p-2)
// md: 16px  (p-4)
// lg: 24px  (p-6)
// xl: 32px  (p-8)
// 2xl: 48px (p-12)
// 3xl: 64px (p-16)

// Container widths
// sm: 640px
// md: 768px
// lg: 1024px
// xl: 1280px
// 2xl: 1536px
```

## 4. Border Radius

```typescript
// Using CSS variable --radius
// sm: calc(var(--radius) - 4px)   // 4px
// DEFAULT: var(--radius)           // 8px
// md: calc(var(--radius) + 2px)   // 10px
// lg: calc(var(--radius) + 4px)   // 12px
// xl: calc(var(--radius) + 8px)   // 16px
// full: 9999px
```

## 5. Shadows

```css
/* Tailwind shadows */
.shadow-sm { box-shadow: 0 1px 2px 0 rgb(0 0 0 / 0.05); }
.shadow { box-shadow: 0 1px 3px 0 rgb(0 0 0 / 0.1), 0 1px 2px -1px rgb(0 0 0 / 0.1); }
.shadow-md { box-shadow: 0 4px 6px -1px rgb(0 0 0 / 0.1), 0 2px 4px -2px rgb(0 0 0 / 0.1); }
.shadow-lg { box-shadow: 0 10px 15px -3px rgb(0 0 0 / 0.1), 0 4px 6px -4px rgb(0 0 0 / 0.1); }
```

## 6. Component Specifications

### Button Variants

```tsx
// Using class-variance-authority
const buttonVariants = cva(
  "inline-flex items-center justify-center rounded-md text-sm font-medium transition-colors focus-visible:outline-none focus-visible:ring-2 disabled:pointer-events-none disabled:opacity-50",
  {
    variants: {
      variant: {
        default: "bg-primary text-primary-foreground hover:bg-primary/90",
        destructive: "bg-destructive text-destructive-foreground hover:bg-destructive/90",
        outline: "border border-input bg-background hover:bg-accent hover:text-accent-foreground",
        secondary: "bg-secondary text-secondary-foreground hover:bg-secondary/80",
        ghost: "hover:bg-accent hover:text-accent-foreground",
        link: "text-primary underline-offset-4 hover:underline",
      },
      size: {
        default: "h-10 px-4 py-2",
        sm: "h-9 rounded-md px-3",
        lg: "h-11 rounded-md px-8",
        icon: "h-10 w-10",
      },
    },
    defaultVariants: {
      variant: "default",
      size: "default",
    },
  }
);
```

### Card Style

```tsx
<div className="rounded-lg border bg-card text-card-foreground shadow-sm p-6">
  {/* content */}
</div>
```

### Input Style

```tsx
<input className="flex h-10 w-full rounded-md border border-input bg-background px-3 py-2 text-sm ring-offset-background file:border-0 file:bg-transparent file:text-sm file:font-medium placeholder:text-muted-foreground focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2 disabled:cursor-not-allowed disabled:opacity-50" />
```

## 7. Animation & Motion

```typescript
// Framer Motion variants
export const fadeIn = {
  initial: { opacity: 0 },
  animate: { opacity: 1 },
  exit: { opacity: 0 },
};

export const slideUp = {
  initial: { opacity: 0, y: 20 },
  animate: { opacity: 1, y: 0 },
  exit: { opacity: 0, y: 20 },
};

// Transition presets
export const transitions = {
  fast: { duration: 0.15 },
  normal: { duration: 0.3 },
  slow: { duration: 0.5 },
  spring: { type: 'spring', stiffness: 300, damping: 30 },
};
```

## 8. Breakpoints

```typescript
// Tailwind default breakpoints
// sm: 640px   - Mobile landscape
// md: 768px   - Tablet
// lg: 1024px  - Desktop
// xl: 1280px  - Large desktop
// 2xl: 1536px - Extra large

// Usage: mobile-first
// Default: mobile
// sm: small screens and up
// md: medium screens and up
// etc.
```

```

// turbo
**Simpan output ke file `DESIGN_SYSTEM.md` di root project.**

---

### Step 2.2: Generate FOLDER_STRUCTURE.md

Gunakan skill `senior-nextjs-developer`:

```markdown
Act as senior-nextjs-developer.
Buatkan `FOLDER_STRUCTURE.md` untuk Next.js App Router project.

## Project Structure

```

src/
├── app/                           # Next.js App Router
│   ├── (auth)/                    # Auth group (no layout)
│   │   ├── login/
│   │   │   └── page.tsx
│   │   ├── register/
│   │   │   └── page.tsx
│   │   └── layout.tsx             # Auth layout
│   │
│   ├── (dashboard)/               # Dashboard group
│   │   ├── dashboard/
│   │   │   ├── page.tsx
│   │   │   └── loading.tsx
│   │   ├── settings/
│   │   │   └── page.tsx
│   │   └── layout.tsx             # Dashboard layout with sidebar
│   │
│   ├── api/                       # API Route Handlers
│   │   ├── auth/
│   │   │   └── [...nextauth]/
│   │   │       └── route.ts
│   │   └── users/
│   │       └── route.ts
│   │
│   ├── layout.tsx                 # Root layout
│   ├── page.tsx                   # Home page
│   ├── loading.tsx                # Root loading
│   ├── error.tsx                  # Root error
│   ├── not-found.tsx              # 404 page
│   └── globals.css                # Global styles
│
├── components/
│   ├── ui/                        # shadcn/ui components
│   │   ├── button.tsx
│   │   ├── card.tsx
│   │   ├── input.tsx
│   │   └── index.ts               # Barrel export
│   │
│   ├── forms/                     # Form components
│   │   ├── login-form.tsx
│   │   └── register-form.tsx
│   │
│   ├── layouts/                   # Layout components
│   │   ├── header.tsx
│   │   ├── footer.tsx
│   │   ├── sidebar.tsx
│   │   └── mobile-nav.tsx
│   │
│   └── features/                  # Feature-specific components
│       ├── dashboard/
│       │   ├── stats-card.tsx
│       │   └── activity-feed.tsx
│       └── users/
│           ├── user-card.tsx
│           └── user-list.tsx
│
├── lib/
│   ├── api/                       # API client functions
│   │   ├── client.ts              # Fetch wrapper
│   │   └── users.ts               # User API functions
│   │
│   ├── hooks/                     # Custom hooks
│   │   ├── use-users.ts           # TanStack Query hooks
│   │   ├── use-auth.ts
│   │   └── use-media-query.ts
│   │
│   ├── stores/                    # Zustand stores
│   │   ├── ui-store.ts
│   │   └── auth-store.ts
│   │
│   ├── validations/               # Zod schemas
│   │   ├── auth.ts
│   │   └── user.ts
│   │
│   ├── utils/                     # Utility functions
│   │   ├── cn.ts                  # Class merge utility
│   │   ├── format.ts
│   │   └── constants.ts
│   │
│   └── fonts.ts                   # Font configuration
│
├── types/                         # TypeScript types
│   ├── index.ts                   # Barrel export
│   ├── api.ts                     # API response types
│   └── user.ts                    # Domain types
│
└── config/                        # App configuration
    ├── site.ts                    # Site metadata
    └── nav.ts                     # Navigation config

```

## Naming Conventions
- Pages: `page.tsx` (Next.js convention)
- Layouts: `layout.tsx`
- Loading: `loading.tsx`
- Error: `error.tsx`
- Components: `PascalCase.tsx`
- Hooks: `use-kebab-case.ts`
- Utils: `kebab-case.ts`
- Stores: `kebab-case-store.ts`

## Import Aliases
```json
// tsconfig.json paths
{
  "@/*": ["./src/*"],
  "@/components/*": ["./src/components/*"],
  "@/lib/*": ["./src/lib/*"],
  "@/types/*": ["./src/types/*"]
}
```

```

// turbo
**Simpan output ke file `FOLDER_STRUCTURE.md` di root project.**

---

### Step 2.3: Generate DB_SCHEMA.md

Gunakan skill `database-modeling-specialist` + `senior-supabase-developer`:

```markdown
Act as database-modeling-specialist.
Berdasarkan fitur di PRD.md, desain database schema.

Buatkan `DB_SCHEMA.md`.

### Untuk Supabase PostgreSQL:
| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK, DEFAULT gen_random_uuid() | User ID |
| email | text | UNIQUE, NOT NULL | Email |
...

### TypeScript Types:
```typescript
export interface User {
  id: string;
  email: string;
  // ...
}
```

### Row Level Security

[Definisikan aturan RLS]

### Indexes

[Daftar index yang diperlukan]

```

// turbo
**Simpan output ke file `DB_SCHEMA.md` di root project.**

---

### Step 2.4: Generate API_CONTRACT.md

Gunakan skill `api-design-specialist`:

```markdown
Act as api-design-specialist.
Buatkan `API_CONTRACT.md` untuk Next.js app.

Format untuk setiap endpoint:

## Authentication

### POST /api/auth/login
**Request:**
```typescript
interface LoginRequest {
  email: string;
  password: string;
}
```

**Response 200:**

```typescript
interface LoginResponse {
  user: User;
  accessToken: string;
}
```

**Error Codes:**

- 400: Invalid credentials
- 429: Too many attempts

[Lanjutkan untuk semua endpoints]

```

// turbo
**Simpan output ke file `API_CONTRACT.md` di root project.**

---

### Step 2.5: Generate EXAMPLES.md

Gunakan skill `senior-nextjs-developer`:

```markdown
Act as senior-nextjs-developer.
Buatkan `EXAMPLES.md` berisi contoh kode React/Next.js yang jadi standar project.

## 1. Server Component Pattern
```tsx
// app/(dashboard)/users/page.tsx
import { getUsers } from '@/lib/api/users';
import { UserList } from '@/components/features/users/user-list';

export default async function UsersPage() {
  const users = await getUsers();

  return (
    <div className="container py-8">
      <h1 className="text-h1 mb-8">Users</h1>
      <UserList users={users} />
    </div>
  );
}
```

## 2. Client Component Pattern

```tsx
'use client';

// components/features/users/user-list.tsx
import { useState } from 'react';
import { User } from '@/types';
import { UserCard } from './user-card';
import { Input } from '@/components/ui/input';

interface UserListProps {
  users: User[];
}

export function UserList({ users }: UserListProps) {
  const [search, setSearch] = useState('');

  const filtered = users.filter((user) =>
    user.name.toLowerCase().includes(search.toLowerCase())
  );

  return (
    <div className="space-y-4">
      <Input
        placeholder="Search users..."
        value={search}
        onChange={(e) => setSearch(e.target.value)}
      />
      <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-3">
        {filtered.map((user) => (
          <UserCard key={user.id} user={user} />
        ))}
      </div>
    </div>
  );
}
```

## 3. TanStack Query Hook Pattern

```typescript
// lib/hooks/use-users.ts
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { getUsers, createUser, updateUser, deleteUser } from '@/lib/api/users';
import type { User, CreateUserDto, UpdateUserDto } from '@/types';

export const userKeys = {
  all: ['users'] as const,
  detail: (id: string) => [...userKeys.all, id] as const,
};

export function useUsers() {
  return useQuery({
    queryKey: userKeys.all,
    queryFn: getUsers,
  });
}

export function useUser(id: string) {
  return useQuery({
    queryKey: userKeys.detail(id),
    queryFn: () => getUserById(id),
    enabled: !!id,
  });
}

export function useCreateUser() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: (data: CreateUserDto) => createUser(data),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: userKeys.all });
    },
  });
}
```

## 4. Zustand Store Pattern

```typescript
// lib/stores/ui-store.ts
import { create } from 'zustand';

interface UIState {
  isSidebarOpen: boolean;
  toggleSidebar: () => void;
  setSidebarOpen: (open: boolean) => void;
}

export const useUIStore = create<UIState>((set) => ({
  isSidebarOpen: true,
  toggleSidebar: () => set((state) => ({ isSidebarOpen: !state.isSidebarOpen })),
  setSidebarOpen: (open) => set({ isSidebarOpen: open }),
}));
```

## 5. Form with React Hook Form + Zod

```tsx
'use client';

import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { z } from 'zod';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';

const loginSchema = z.object({
  email: z.string().email('Invalid email address'),
  password: z.string().min(8, 'Password must be at least 8 characters'),
});

type LoginFormData = z.infer<typeof loginSchema>;

export function LoginForm() {
  const {
    register,
    handleSubmit,
    formState: { errors, isSubmitting },
  } = useForm<LoginFormData>({
    resolver: zodResolver(loginSchema),
  });

  const onSubmit = async (data: LoginFormData) => {
    // Handle login
  };

  return (
    <form onSubmit={handleSubmit(onSubmit)} className="space-y-4">
      <div className="space-y-2">
        <Label htmlFor="email">Email</Label>
        <Input
          id="email"
          type="email"
          {...register('email')}
          aria-invalid={!!errors.email}
        />
        {errors.email && (
          <p className="text-sm text-destructive">{errors.email.message}</p>
        )}
      </div>

      <div className="space-y-2">
        <Label htmlFor="password">Password</Label>
        <Input
          id="password"
          type="password"
          {...register('password')}
          aria-invalid={!!errors.password}
        />
        {errors.password && (
          <p className="text-sm text-destructive">{errors.password.message}</p>
        )}
      </div>

      <Button type="submit" className="w-full" disabled={isSubmitting}>
        {isSubmitting ? 'Signing in...' : 'Sign in'}
      </Button>
    </form>
  );
}
```

## 6. API Route Handler Pattern

```typescript
// app/api/users/route.ts
import { NextResponse } from 'next/server';
import { z } from 'zod';
import { db } from '@/lib/db';

const createUserSchema = z.object({
  email: z.string().email(),
  name: z.string().min(2),
});

export async function GET() {
  try {
    const users = await db.user.findMany();
    return NextResponse.json(users);
  } catch (error) {
    return NextResponse.json(
      { error: 'Failed to fetch users' },
      { status: 500 }
    );
  }
}

export async function POST(request: Request) {
  try {
    const body = await request.json();
    const validated = createUserSchema.parse(body);

    const user = await db.user.create({
      data: validated,
    });

    return NextResponse.json(user, { status: 201 });
  } catch (error) {
    if (error instanceof z.ZodError) {
      return NextResponse.json(
        { error: 'Validation failed', details: error.errors },
        { status: 400 }
      );
    }
    return NextResponse.json(
      { error: 'Failed to create user' },
      { status: 500 }
    );
  }
}
```

## 7. Server Action Pattern

```typescript
// lib/actions/user-actions.ts
'use server';

import { revalidatePath } from 'next/cache';
import { z } from 'zod';
import { db } from '@/lib/db';

const updateUserSchema = z.object({
  id: z.string().uuid(),
  name: z.string().min(2),
});

export async function updateUser(formData: FormData) {
  const validated = updateUserSchema.parse({
    id: formData.get('id'),
    name: formData.get('name'),
  });

  await db.user.update({
    where: { id: validated.id },
    data: { name: validated.name },
  });

  revalidatePath('/users');
}
```

## 8. Loading State Pattern

```tsx
// app/(dashboard)/users/loading.tsx
import { Skeleton } from '@/components/ui/skeleton';

export default function UsersLoading() {
  return (
    <div className="container py-8">
      <Skeleton className="h-10 w-48 mb-8" />
      <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-3">
        {Array.from({ length: 6 }).map((_, i) => (
          <Skeleton key={i} className="h-32 rounded-lg" />
        ))}
      </div>
    </div>
  );
}
```

## 9. Error Handling Pattern

```tsx
'use client';

// app/(dashboard)/users/error.tsx
import { useEffect } from 'react';
import { Button } from '@/components/ui/button';

export default function UsersError({
  error,
  reset,
}: {
  error: Error & { digest?: string };
  reset: () => void;
}) {
  useEffect(() => {
    console.error(error);
  }, [error]);

  return (
    <div className="container py-8 text-center">
      <h2 className="text-h2 mb-4">Something went wrong!</h2>
      <p className="text-muted-foreground mb-8">{error.message}</p>
      <Button onClick={reset}>Try again</Button>
    </div>
  );
}
```

## 10. cn() Utility

```typescript
// lib/utils/cn.ts
import { clsx, type ClassValue } from 'clsx';
import { twMerge } from 'tailwind-merge';

export function cn(...inputs: ClassValue[]) {
  return twMerge(clsx(inputs));
}
```

```

// turbo
**Simpan output ke file `EXAMPLES.md` di root project.**

---

## 📊 Phase 3: Architecture

### Step 3.1: Generate APP_FLOW.md

Gunakan skill `mermaid-diagram-expert`:

```markdown
Act as mermaid-diagram-expert.
Buatkan `APP_FLOW.md` dengan diagram Mermaid untuk:

1. Authentication Flow
2. Data Fetching Flow (Server vs Client)
3. Navigation Flow
```

// turbo
**Simpan output ke file `APP_FLOW.md` di root project.**

---

## ✅ Phase 4: Project Setup

### Step 4.1: Create Next.js Project

// turbo

```bash
npx create-next-app@latest . --typescript --tailwind --eslint --app --src-dir --import-alias "@/*"
```

### Step 4.2: Install Dependencies

// turbo

```bash
npm install @tanstack/react-query zustand react-hook-form @hookform/resolvers zod
npm install framer-motion lucide-react clsx tailwind-merge class-variance-authority
npm install nuqs date-fns
```

### Step 4.3: Setup shadcn/ui

// turbo

```bash
npx shadcn-ui@latest init
npx shadcn-ui@latest add button card input label
```

### Step 4.4: Create Folder Structure

// turbo

```bash
mkdir -p src/{components/{ui,forms,layouts,features},lib/{api,hooks,stores,validations,utils},types,config}
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
├── APP_FLOW.md            ✅ Architecture
├── package.json           ✅ Project Config
└── src/                   ✅ Source Code
    ├── app/
    ├── components/
    ├── lib/
    └── types/
```

---

## 💡 React/Next.js Tips

### Magic Words untuk Prompts

- "Gunakan Server Component"
- "Jangan pakai 'use client' kecuali perlu"
- "Handle loading state dengan Suspense"
- "Ikuti pattern di EXAMPLES.md"
- "Refer ke DESIGN_SYSTEM.md untuk styling"
- "Validasi dengan Zod"

### Common Mistakes to Avoid

| ❌ Jangan | ✅ Lakukan |
| --------- | --------- |
| useEffect untuk data fetching | Server Component + fetch |
| 'use client' tanpa alasan | Server Components by default |
| Global state untuk server data | TanStack Query |
| Inline styles | Tailwind utilities |
| any type | Proper TypeScript types |
| Hardcode colors | CSS variables / Tailwind |
| `className=""` dengan +/template | cn() utility |

### Performance Checklist

| Item | Status |
| ---- | ------ |
| Images dengan next/image | ☐ |
| Fonts dengan next/font | ☐ |
| Lazy loading components | ☐ |
| Proper Suspense boundaries | ☐ |
| Memoization where needed | ☐ |
| Bundle size optimized | ☐ |

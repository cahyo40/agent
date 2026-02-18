# 01 - Next.js Project Setup (App Router + TypeScript + Tailwind + Shadcn/UI)

**Goal:** Setup project Next.js 14+ dari nol dengan App Router, TypeScript strict, Tailwind CSS, Shadcn/UI, dan folder structure feature-based.

**Output:** `sdlc/nextjs-frontend/01-project-setup/`

**Time Estimate:** 2-3 jam

---

## Deliverables

### 1. Inisialisasi Project

```bash
# Buat project baru
pnpm create next-app@latest myapp \
  --typescript \
  --tailwind \
  --eslint \
  --app \
  --src-dir \
  --import-alias "@/*"

cd myapp

# Install pnpm (jika belum)
npm install -g pnpm
```

---

### 2. Dependencies

**File:** `package.json` (tambahan setelah init)

```bash
# UI & Icons
pnpm add lucide-react class-variance-authority clsx tailwind-merge

# Shadcn/UI setup
pnpm dlx shadcn-ui@latest init

# State & Data
pnpm add @tanstack/react-query axios zustand

# Forms & Validation
pnpm add react-hook-form zod @hookform/resolvers

# Utilities
pnpm add date-fns next-themes

# Dev Dependencies
pnpm add -D @types/node prettier eslint-config-prettier \
  prettier-plugin-tailwindcss vitest @vitejs/plugin-react \
  @testing-library/react @testing-library/user-event \
  @playwright/test
```

**Shadcn/UI init options:**
```
✔ Which style would you like to use? › Default
✔ Which color would you like to use as base color? › Slate
✔ Would you like to use CSS variables for colors? › Yes
```

---

### 3. TypeScript Configuration

**File:** `tsconfig.json`

```json
{
  "compilerOptions": {
    "target": "ES2017",
    "lib": ["dom", "dom.iterable", "esnext"],
    "allowJs": true,
    "skipLibCheck": true,
    "strict": true,
    "noUncheckedIndexedAccess": true,
    "noImplicitOverride": true,
    "forceConsistentCasingInFileNames": true,
    "noEmit": true,
    "esModuleInterop": true,
    "module": "esnext",
    "moduleResolution": "bundler",
    "resolveJsonModule": true,
    "isolatedModules": true,
    "jsx": "preserve",
    "incremental": true,
    "plugins": [{ "name": "next" }],
    "paths": {
      "@/*": ["./src/*"]
    }
  },
  "include": ["next-env.d.ts", "**/*.ts", "**/*.tsx", ".next/types/**/*.ts"],
  "exclude": ["node_modules"]
}
```

---

### 4. Tailwind Configuration

**File:** `tailwind.config.ts`

```typescript
import type { Config } from "tailwindcss";

const config: Config = {
  darkMode: ["class"],
  content: [
    "./src/pages/**/*.{js,ts,jsx,tsx,mdx}",
    "./src/components/**/*.{js,ts,jsx,tsx,mdx}",
    "./src/app/**/*.{js,ts,jsx,tsx,mdx}",
    "./src/features/**/*.{js,ts,jsx,tsx,mdx}",
  ],
  theme: {
    container: {
      center: true,
      padding: "2rem",
      screens: { "2xl": "1400px" },
    },
    extend: {
      colors: {
        border: "hsl(var(--border))",
        input: "hsl(var(--input))",
        ring: "hsl(var(--ring))",
        background: "hsl(var(--background))",
        foreground: "hsl(var(--foreground))",
        primary: {
          DEFAULT: "hsl(var(--primary))",
          foreground: "hsl(var(--primary-foreground))",
        },
        secondary: {
          DEFAULT: "hsl(var(--secondary))",
          foreground: "hsl(var(--secondary-foreground))",
        },
        destructive: {
          DEFAULT: "hsl(var(--destructive))",
          foreground: "hsl(var(--destructive-foreground))",
        },
        muted: {
          DEFAULT: "hsl(var(--muted))",
          foreground: "hsl(var(--muted-foreground))",
        },
        accent: {
          DEFAULT: "hsl(var(--accent))",
          foreground: "hsl(var(--accent-foreground))",
        },
        card: {
          DEFAULT: "hsl(var(--card))",
          foreground: "hsl(var(--card-foreground))",
        },
      },
      borderRadius: {
        lg: "var(--radius)",
        md: "calc(var(--radius) - 2px)",
        sm: "calc(var(--radius) - 4px)",
      },
      keyframes: {
        "accordion-down": {
          from: { height: "0" },
          to: { height: "var(--radix-accordion-content-height)" },
        },
        "accordion-up": {
          from: { height: "var(--radix-accordion-content-height)" },
          to: { height: "0" },
        },
      },
      animation: {
        "accordion-down": "accordion-down 0.2s ease-out",
        "accordion-up": "accordion-up 0.2s ease-out",
      },
    },
  },
  plugins: [require("tailwindcss-animate")],
};

export default config;
```

---

### 5. Folder Structure

```bash
# Buat folder structure
mkdir -p src/{app,components,features,lib,hooks,stores,types}
mkdir -p src/app/\(auth\)/{login,register}
mkdir -p src/app/\(dashboard\)/dashboard
mkdir -p src/app/api/auth
mkdir -p src/components/{ui,shared}
mkdir -p src/lib/{api,utils}
mkdir -p src/features/{auth,users}
mkdir -p src/features/auth/{components,hooks,api}
mkdir -p src/features/users/{components,hooks,api}
```

**Final structure:**
```
src/
├── app/
│   ├── (auth)/
│   │   ├── login/
│   │   │   ├── page.tsx
│   │   │   └── loading.tsx
│   │   └── register/
│   │       └── page.tsx
│   ├── (dashboard)/
│   │   ├── layout.tsx
│   │   └── dashboard/
│   │       ├── page.tsx
│   │       └── loading.tsx
│   ├── api/
│   │   └── auth/
│   │       └── [...nextauth]/route.ts
│   ├── globals.css
│   ├── layout.tsx
│   └── page.tsx
├── components/
│   ├── ui/          # Shadcn/UI components
│   └── shared/      # App-specific shared components
├── features/
│   ├── auth/
│   │   ├── components/
│   │   ├── hooks/
│   │   └── api/
│   └── users/
│       ├── components/
│       ├── hooks/
│       └── api/
├── lib/
│   ├── api/
│   │   ├── client.ts      # Axios instance
│   │   └── types.ts       # API response types
│   └── utils.ts           # Utility functions
├── hooks/                 # Global hooks
├── stores/                # Zustand stores
├── types/                 # Global TypeScript types
└── middleware.ts           # Route protection
```

---

### 6. Root Layout

**File:** `src/app/layout.tsx`

```tsx
import type { Metadata } from "next";
import { Inter } from "next/font/google";
import "./globals.css";
import { Providers } from "@/components/shared/providers";

const inter = Inter({
  subsets: ["latin"],
  variable: "--font-inter",
});

export const metadata: Metadata = {
  title: {
    template: "%s | MyApp",
    default: "MyApp",
  },
  description: "MyApp - Built with Next.js",
};

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html lang="en" suppressHydrationWarning>
      <body className={`${inter.variable} font-sans antialiased`}>
        <Providers>{children}</Providers>
      </body>
    </html>
  );
}
```

---

### 7. Providers

**File:** `src/components/shared/providers.tsx`

```tsx
"use client";

import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import { ReactQueryDevtools } from "@tanstack/react-query-devtools";
import { ThemeProvider } from "next-themes";
import { useState } from "react";

export function Providers({ children }: { children: React.ReactNode }) {
  const [queryClient] = useState(
    () =>
      new QueryClient({
        defaultOptions: {
          queries: {
            staleTime: 60 * 1000, // 1 minute
            retry: 1,
          },
        },
      })
  );

  return (
    <QueryClientProvider client={queryClient}>
      <ThemeProvider
        attribute="class"
        defaultTheme="system"
        enableSystem
        disableTransitionOnChange
      >
        {children}
        <ReactQueryDevtools initialIsOpen={false} />
      </ThemeProvider>
    </QueryClientProvider>
  );
}
```

---

### 8. Utility Functions

**File:** `src/lib/utils.ts`

```typescript
import { type ClassValue, clsx } from "clsx";
import { twMerge } from "tailwind-merge";
import { format } from "date-fns";

/** Merge Tailwind classes safely. */
export function cn(...inputs: ClassValue[]): string {
  return twMerge(clsx(inputs));
}

/** Format date to readable string. */
export function formatDate(
  date: Date | string,
  pattern = "dd MMM yyyy"
): string {
  return format(new Date(date), pattern);
}

/** Format number as currency (IDR). */
export function formatCurrency(
  amount: number,
  currency = "IDR"
): string {
  return new Intl.NumberFormat("id-ID", {
    style: "currency",
    currency,
    minimumFractionDigits: 0,
  }).format(amount);
}

/** Truncate string to max length. */
export function truncate(str: string, maxLength: number): string {
  if (str.length <= maxLength) return str;
  return `${str.slice(0, maxLength)}...`;
}

/** Get initials from full name. */
export function getInitials(name: string): string {
  return name
    .split(" ")
    .map((n) => n[0])
    .join("")
    .toUpperCase()
    .slice(0, 2);
}
```

---

### 9. Global Types

**File:** `src/types/api.ts`

```typescript
/** Standard API response wrapper. */
export interface ApiResponse<T> {
  data: T;
  message: string;
  status_code: number;
}

/** Paginated list response. */
export interface PaginatedResponse<T> {
  data: T[];
  total: number;
  page: number;
  limit: number;
  total_pages: number;
}

/** Standard API error. */
export interface ApiError {
  message: string;
  detail?: string;
  status_code: number;
}

/** Pagination query params. */
export interface PaginationParams {
  page?: number;
  limit?: number;
  search?: string;
  sort?: string;
  order?: "asc" | "desc";
}
```

---

### 10. Middleware (Route Protection)

**File:** `src/middleware.ts`

```typescript
import { NextResponse } from "next/server";
import type { NextRequest } from "next/server";

const PUBLIC_ROUTES = ["/", "/login", "/register"];
const AUTH_ROUTES = ["/login", "/register"];

export function middleware(request: NextRequest) {
  const { pathname } = request.nextUrl;
  const token = request.cookies.get("access_token")?.value;

  const isPublicRoute = PUBLIC_ROUTES.some(
    (route) => pathname === route || pathname.startsWith("/api/auth")
  );

  // Redirect authenticated users away from auth pages
  if (token && AUTH_ROUTES.includes(pathname)) {
    return NextResponse.redirect(new URL("/dashboard", request.url));
  }

  // Redirect unauthenticated users to login
  if (!token && !isPublicRoute) {
    const loginUrl = new URL("/login", request.url);
    loginUrl.searchParams.set("callbackUrl", pathname);
    return NextResponse.redirect(loginUrl);
  }

  return NextResponse.next();
}

export const config = {
  matcher: [
    "/((?!_next/static|_next/image|favicon.ico|.*\\.(?:svg|png|jpg|jpeg|gif|webp)$).*)",
  ],
};
```

---

### 11. Environment Variables

**File:** `.env.local.example`

```bash
# App
NEXT_PUBLIC_APP_URL=http://localhost:3000
NEXT_PUBLIC_APP_NAME=MyApp

# Backend API (Go/Python)
NEXT_PUBLIC_API_URL=http://localhost:8000/api/v1
API_SECRET=your-internal-api-secret

# NextAuth (jika pakai NextAuth)
NEXTAUTH_URL=http://localhost:3000
NEXTAUTH_SECRET=your-nextauth-secret-min-32-chars

# Supabase (jika pakai Supabase)
NEXT_PUBLIC_SUPABASE_URL=https://xxx.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=your-anon-key
SUPABASE_SERVICE_ROLE_KEY=your-service-role-key

# Firebase (jika pakai Firebase)
NEXT_PUBLIC_FIREBASE_API_KEY=your-api-key
NEXT_PUBLIC_FIREBASE_AUTH_DOMAIN=your-app.firebaseapp.com
NEXT_PUBLIC_FIREBASE_PROJECT_ID=your-project-id
NEXT_PUBLIC_FIREBASE_STORAGE_BUCKET=your-app.appspot.com
NEXT_PUBLIC_FIREBASE_MESSAGING_SENDER_ID=123456789
NEXT_PUBLIC_FIREBASE_APP_ID=1:123:web:abc
```

---

### 12. ESLint & Prettier

**File:** `.eslintrc.json`

```json
{
  "extends": [
    "next/core-web-vitals",
    "prettier"
  ],
  "rules": {
    "@typescript-eslint/no-unused-vars": "error",
    "@typescript-eslint/no-explicit-any": "error",
    "prefer-const": "error"
  }
}
```

**File:** `.prettierrc`

```json
{
  "semi": true,
  "singleQuote": false,
  "tabWidth": 2,
  "trailingComma": "es5",
  "printWidth": 80,
  "plugins": ["prettier-plugin-tailwindcss"]
}
```

---

### 13. Package.json Scripts

**File:** `package.json` (scripts section)

```json
{
  "scripts": {
    "dev": "next dev",
    "build": "next build",
    "start": "next start",
    "lint": "next lint",
    "lint:fix": "next lint --fix",
    "format": "prettier --write .",
    "format:check": "prettier --check .",
    "type-check": "tsc --noEmit",
    "test": "vitest",
    "test:ui": "vitest --ui",
    "test:coverage": "vitest --coverage",
    "test:e2e": "playwright test",
    "test:e2e:ui": "playwright test --ui"
  }
}
```

---

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

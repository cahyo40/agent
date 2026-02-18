# 01 - Nuxt 3 Project Setup (TypeScript + Tailwind + Shadcn/UI)

**Goal:** Setup project Nuxt 3 dari nol dengan TypeScript strict, Tailwind CSS, Shadcn/UI (shadcn-vue), dan folder structure yang terorganisir.

**Output:** `sdlc/nuxt-frontend/01-project-setup/`

**Time Estimate:** 2-3 jam

---

## Deliverables

### 1. Inisialisasi Project

```bash
# Buat project baru
pnpm dlx nuxi@latest init myapp
cd myapp

# Install dependencies
pnpm install
```

---

### 2. Dependencies

```bash
# Tailwind CSS
pnpm add -D @nuxtjs/tailwindcss

# Shadcn/UI for Vue (shadcn-vue)
pnpm dlx shadcn-vue@latest init

# Icons
pnpm add lucide-vue-next

# State management
pnpm add pinia @pinia/nuxt

# Forms & Validation
pnpm add vee-validate zod @vee-validate/zod

# Utilities
pnpm add @vueuse/nuxt @vueuse/core

# Color mode (dark mode)
pnpm add @nuxtjs/color-mode

# Dev
pnpm add -D @nuxt/eslint @nuxt/test-utils vitest @vue/test-utils
pnpm add -D @playwright/test
```

---

### 3. Nuxt Config

**File:** `nuxt.config.ts`

```typescript
export default defineNuxtConfig({
  devtools: { enabled: true },

  modules: [
    "@nuxtjs/tailwindcss",
    "@nuxtjs/color-mode",
    "@pinia/nuxt",
    "@vueuse/nuxt",
    "@nuxt/eslint",
  ],

  colorMode: {
    classSuffix: "",
    preference: "system",
    fallback: "light",
  },

  typescript: {
    strict: true,
    typeCheck: true,
  },

  imports: {
    dirs: ["stores", "composables/**"],
  },

  components: [
    { path: "~/components/ui", prefix: "Ui" },
    { path: "~/components/shared", prefix: "" },
    "~/components",
  ],

  runtimeConfig: {
    // Server-only (private)
    apiSecret: process.env.API_SECRET,
    // Public (exposed to client)
    public: {
      apiUrl: process.env.NUXT_PUBLIC_API_URL ?? "http://localhost:8000/api/v1",
      appName: process.env.NUXT_PUBLIC_APP_NAME ?? "MyApp",
    },
  },

  routeRules: {
    "/dashboard/**": { ssr: false }, // SPA mode for dashboard
    "/": { prerender: true },        // Static for landing
  },
});
```

---

### 4. Tailwind Config

**File:** `tailwind.config.ts`

```typescript
import type { Config } from "tailwindcss";
import animate from "tailwindcss-animate";

export default {
  darkMode: "class",
  content: [
    "./components/**/*.{js,vue,ts}",
    "./layouts/**/*.vue",
    "./pages/**/*.vue",
    "./plugins/**/*.{js,ts}",
    "./app.vue",
    "./error.vue",
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
    },
  },
  plugins: [animate],
} satisfies Config;
```

---

### 5. App Entry Point

**File:** `app.vue`

```vue
<template>
  <NuxtLayout>
    <NuxtPage />
  </NuxtLayout>
</template>
```

---

### 6. Default Layout

**File:** `layouts/default.vue`

```vue
<template>
  <div class="min-h-screen bg-background font-sans antialiased">
    <slot />
  </div>
</template>
```

---

### 7. Global Types

**File:** `types/api.ts`

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

### 8. Utility Functions

**File:** `utils/index.ts`

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
export function formatCurrency(amount: number, currency = "IDR"): string {
  return new Intl.NumberFormat("id-ID", {
    style: "currency",
    currency,
    minimumFractionDigits: 0,
  }).format(amount);
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

/** Truncate string to max length. */
export function truncate(str: string, maxLength: number): string {
  if (str.length <= maxLength) return str;
  return `${str.slice(0, maxLength)}...`;
}
```

```bash
pnpm add clsx tailwind-merge date-fns
```

---

### 9. Route Middleware (Auth Guard)

**File:** `middleware/auth.ts`

```typescript
export default defineNuxtRouteMiddleware((to) => {
  const { isAuthenticated } = useAuthStore();

  const publicRoutes = ["/", "/login", "/register"];
  const isPublic = publicRoutes.includes(to.path);

  if (!isAuthenticated && !isPublic) {
    return navigateTo(`/login?redirect=${to.fullPath}`);
  }

  if (isAuthenticated && ["/login", "/register"].includes(to.path)) {
    return navigateTo("/dashboard");
  }
});
```

---

### 10. Environment Variables

**File:** `.env.example`

```bash
# App
NUXT_PUBLIC_APP_URL=http://localhost:3000
NUXT_PUBLIC_APP_NAME=MyApp

# Backend API (Go/Python)
NUXT_PUBLIC_API_URL=http://localhost:8000/api/v1
API_SECRET=your-internal-api-secret

# Auth
AUTH_SECRET=your-auth-secret-min-32-chars

# Supabase (jika pakai Supabase)
SUPABASE_URL=https://xxx.supabase.co
SUPABASE_KEY=your-anon-key

# Firebase (jika pakai Firebase)
NUXT_PUBLIC_FIREBASE_API_KEY=your-api-key
NUXT_PUBLIC_FIREBASE_AUTH_DOMAIN=your-app.firebaseapp.com
NUXT_PUBLIC_FIREBASE_PROJECT_ID=your-project-id
NUXT_PUBLIC_FIREBASE_STORAGE_BUCKET=your-app.appspot.com
NUXT_PUBLIC_FIREBASE_MESSAGING_SENDER_ID=123456789
NUXT_PUBLIC_FIREBASE_APP_ID=1:123:web:abc
```

---

### 11. ESLint Config

**File:** `eslint.config.mjs`

```javascript
import withNuxt from "./.nuxt/eslint.config.mjs";

export default withNuxt({
  rules: {
    "vue/multi-word-component-names": "off",
    "@typescript-eslint/no-explicit-any": "error",
    "@typescript-eslint/no-unused-vars": "error",
  },
});
```

---

### 12. Package.json Scripts

```json
{
  "scripts": {
    "dev": "nuxt dev",
    "build": "nuxt build",
    "generate": "nuxt generate",
    "preview": "nuxt preview",
    "lint": "eslint .",
    "lint:fix": "eslint . --fix",
    "type-check": "nuxt typecheck",
    "test": "vitest",
    "test:coverage": "vitest --coverage",
    "test:e2e": "playwright test"
  }
}
```

---

## Workflow Steps

1. **Init project** dengan `nuxi init`
2. **Install dependencies** (Tailwind, Shadcn-vue, Pinia, dll)
3. **Init Shadcn-vue** (`pnpm dlx shadcn-vue@latest init`)
4. **Setup nuxt.config.ts** dengan semua modules
5. **Buat folder structure** (pages, layouts, components, composables, stores)
6. **Setup route middleware** untuk auth guard
7. **Copy `.env.example`** dan isi sesuai kebutuhan

## Success Criteria
- `pnpm dev` berjalan tanpa error di `http://localhost:3000`
- `pnpm type-check` tidak ada error TypeScript
- `pnpm lint` tidak ada error ESLint
- Shadcn-vue terinstall dan komponen bisa digunakan
- Dark mode toggle berfungsi via `@nuxtjs/color-mode`

## Next Steps
- `02_component_generator.md` - Buat UI components
- `03_api_client_integration.md` - Setup API client

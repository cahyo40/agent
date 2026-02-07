---
description: Initialize Vibe Coding context files for Vue.js/Nuxt web application with Composition API
---

# /vibe-coding-vue

Workflow untuk setup dokumen konteks Vibe Coding khusus **Vue.js/Nuxt Web Application** dengan Composition API, TypeScript, dan modern patterns.

---

## 📋 Prerequisites

Sebelum memulai, siapkan informasi berikut:

1. **Deskripsi ide aplikasi** (2-3 paragraf)
2. **Framework choice:**
   - 🌿 Vue 3 SPA (Vite)
   - ⚡ Nuxt 3 (SSR/SSG/Hybrid)
3. **State management:** Pinia (recommended) / Vuex
4. **Backend preference:** Supabase / Firebase / Custom API
5. **Vibe/estetika** yang diinginkan

---

## 🏗️ Phase 1: Holy Trinity (WAJIB)

### Step 1.1: Generate PRD.md

```
Tanyakan kepada user:
"Jelaskan ide aplikasi Vue/Nuxt yang ingin dibuat. Sertakan:
- Apa masalah yang diselesaikan?
- Siapa target penggunanya?
- Apa fitur utama yang diinginkan?
- Perlu SSR/SSG (Nuxt) atau SPA (Vue) saja?"
```

Gunakan skill `senior-project-manager`:

```markdown
Act as senior-project-manager.
Saya ingin membuat web app Vue/Nuxt: [IDE USER]

Buatkan file `PRD.md` yang mencakup:
1. Executive Summary (2-3 kalimat)
2. Problem Statement
3. Target User & Persona
4. User Stories (min 10 untuk MVP, format: As a [role], I want to [action], so that [benefit])
5. Core Features - kategorikan: Must Have, Should Have, Could Have, Won't Have
6. User Flow per fitur utama
7. SEO Requirements (jika Nuxt)
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
1. Framework: Vue 3 SPA atau Nuxt 3?
2. State Management: Pinia (recommended) atau VueX?
3. Styling: Tailwind CSS / UnoCSS / Vanilla CSS?
4. UI Library: Radix Vue / Headless UI / PrimeVue / custom?
5. Backend: Supabase / Firebase / Custom REST API?"
```

Gunakan skill `tech-stack-architect` + `senior-vue-developer`:

### Untuk Nuxt 3

```markdown
## Core Stack
- Framework: Nuxt 3.9+
- Language: TypeScript 5.x (strict mode)
- Runtime: Node.js 20 LTS
- Package Manager: pnpm (recommended)

## Rendering Strategy
- Default: Universal (SSR + CSR hydration)
- Static pages: Prerendering dengan `generate`
- Islands: Nuxt Islands untuk partial hydration
- Caching: Route Rules + ISR

## State Management
- Local State: Composition API refs/reactive
- Global State: Pinia
- Server State: useFetch/useAsyncData
- Form State: VeeValidate + Zod

## Styling & UI
- Framework: Tailwind CSS 3.4+ (atau UnoCSS)
- Components: Radix Vue / Headless UI
- Icons: Nuxt Icon (@iconify)
- Animation: @vueuse/motion

## Nuxt Modules
- @nuxtjs/tailwindcss
- @pinia/nuxt
- @vueuse/nuxt
- @nuxt/image
- nuxt-icon

## Backend & Data (pilih salah satu)
- Supabase: @nuxtjs/supabase
- Firebase: nuxt-vuefire
- Custom: Nitro server routes

## Testing
- Unit: Vitest + @vue/test-utils
- E2E: Playwright / Cypress
- Coverage Target: 80%

## Code Quality
- Linting: ESLint + @nuxt/eslint-config
- Formatting: Prettier
- Type Check: vue-tsc

## Approved Packages (package.json)
```json
{
  "dependencies": {
    "nuxt": "^3.9.0",
    "vue": "^3.4.0",
    "pinia": "^2.1.0",
    "@pinia/nuxt": "^0.5.0",
    "@vueuse/core": "^10.7.0",
    "@vueuse/nuxt": "^10.7.0",
    "zod": "^3.22.0",
    "vee-validate": "^4.12.0",
    "@vee-validate/zod": "^4.12.0",
    "date-fns": "^3.2.0"
  },
  "devDependencies": {
    "@nuxt/devtools": "latest",
    "@nuxtjs/tailwindcss": "^6.10.0",
    "nuxt-icon": "^0.6.0",
    "@nuxt/image": "^1.3.0",
    "typescript": "^5.3.0"
  }
}
```

## Constraints

- Package di luar daftar DILARANG tanpa approval
- WAJIB Composition API dengan `<script setup>`
- WAJIB TypeScript strict mode
- DILARANG Options API untuk komponen baru

```

### Untuk Vue 3 SPA:

```markdown
## Core Stack
- Framework: Vue 3.4+ dengan Vite 5
- Language: TypeScript 5.x (strict mode)
- Router: Vue Router 4
- Package Manager: pnpm (recommended)

## State Management
- Local State: Composition API
- Global State: Pinia
- Server State: TanStack Query Vue
- Form State: VeeValidate + Zod

## Styling & UI
- Framework: Tailwind CSS 3.4+
- Components: Radix Vue / Headless UI Vue
- Icons: Lucide Vue

## Approved Packages
```json
{
  "dependencies": {
    "vue": "^3.4.0",
    "vue-router": "^4.2.0",
    "pinia": "^2.1.0",
    "@tanstack/vue-query": "^5.17.0",
    "@vueuse/core": "^10.7.0",
    "zod": "^3.22.0",
    "vee-validate": "^4.12.0"
  },
  "devDependencies": {
    "@vitejs/plugin-vue": "^5.0.0",
    "vite": "^5.0.0",
    "typescript": "^5.3.0",
    "vue-tsc": "^1.8.0",
    "tailwindcss": "^3.4.0"
  }
}
```

```

// turbo
**Simpan output ke file `TECH_STACK.md` di root project.**

---

### Step 1.3: Generate RULES.md

Gunakan skill `senior-vue-developer`:

```markdown
Act as senior-vue-developer.
Buatkan file `RULES.md` sebagai panduan AI untuk Vue/Nuxt project.

## TypeScript Rules
- Strict mode WAJIB
- DILARANG menggunakan `any`
- Props dengan defineProps<T>()
- Emits dengan defineEmits<T>()
- Explicit return types untuk composables

## Vue 3 Composition API Rules
- WAJIB `<script setup>` untuk semua komponen
- DILARANG Options API (data, methods, computed)
- Gunakan `ref()` untuk primitives
- Gunakan `reactive()` untuk objects (hati-hati destructuring)
- Prefer `computed()` over methods untuk derived state
- Gunakan `watchEffect()` untuk side effects

## Component Rules
- Max 150 baris per component
- Extract logic ke composables (use*.ts)
- Props immutable - DILARANG mutate props
- Gunakan v-model dengan defineModel() (Vue 3.4+)
- Slots untuk flexible content

## Nuxt-Specific Rules (jika pakai Nuxt)
- Data fetching dengan useFetch/useAsyncData
- DILARANG onMounted untuk data fetching
- Server routes di /server/api
- Middleware di /middleware
- Plugins di /plugins

## Styling Rules
- Tailwind CSS utilities via class attribute
- Scoped styles dengan `<style scoped>` (jika perlu)
- CSS variables untuk theming
- DILARANG inline styles

## State Management Rules
- Pinia untuk global state
- Composables untuk reusable logic
- Props/emits untuk parent-child communication
- Provide/inject untuk deep component trees

## File & Naming Conventions
- Components: `PascalCase.vue`
- Composables: `use-kebab-case.ts`
- Stores: `use-kebab-case-store.ts`
- Utils: `kebab-case.ts`
- Pages: `kebab-case.vue` (auto-routing)

## Import Order
1. Vue/Nuxt imports
2. External libraries  
3. Internal imports (#imports atau @/)
4. Components
5. Types

## Error Handling Rules
- Error boundaries: onErrorCaptured
- try-catch untuk async
- User-friendly error messages
- Loading states dengan Suspense

## AI Behavior Rules
1. JANGAN import package yang tidak ada di package.json
2. JANGAN tinggalkan komentar `// TODO` atau placeholder
3. SELALU gunakan `<script setup>` bukan Options API
4. IKUTI struktur folder di FOLDER_STRUCTURE.md
5. IKUTI pola coding yang ada di EXAMPLES.md
6. SELALU handle loading, error, dan empty state
7. Refer ke DESIGN_SYSTEM.md untuk styling

## Workflow Rules
- Sebelum coding, jelaskan rencana dalam 3 bullet points
- Setelah coding, validasi dengan TypeScript
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

Gunakan skill `design-system-architect`:

```markdown
Act as design-system-architect.
Buatkan `DESIGN_SYSTEM.md` untuk Vue/Nuxt app dengan vibe: [VIBE USER]

## 1. Color Palette

### CSS Variables (assets/css/main.css)
```css
:root {
  /* Primary */
  --color-primary-50: #eff6ff;
  --color-primary-100: #dbeafe;
  --color-primary-200: #bfdbfe;
  --color-primary-300: #93c5fd;
  --color-primary-400: #60a5fa;
  --color-primary-500: #3b82f6;
  --color-primary-600: #2563eb;
  --color-primary-700: #1d4ed8;
  --color-primary-800: #1e40af;
  --color-primary-900: #1e3a8a;

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

  /* Background & Surface */
  --bg-primary: #ffffff;
  --bg-secondary: #f9fafb;
  --bg-tertiary: #f3f4f6;
  
  /* Text */
  --text-primary: #111827;
  --text-secondary: #6b7280;
  --text-tertiary: #9ca3af;

  /* Border */
  --border-color: #e5e7eb;
  --border-radius: 8px;
}

/* Dark Mode */
.dark {
  --bg-primary: #111827;
  --bg-secondary: #1f2937;
  --bg-tertiary: #374151;
  --text-primary: #f9fafb;
  --text-secondary: #9ca3af;
  --text-tertiary: #6b7280;
  --border-color: #374151;
}
```

### Tailwind Config Extension

```typescript
// tailwind.config.ts
export default {
  theme: {
    extend: {
      colors: {
        primary: {
          50: 'var(--color-primary-50)',
          // ... etc
          DEFAULT: 'var(--color-primary-500)',
        },
      },
    },
  },
};
```

## 2. Typography

### Font Setup

```typescript
// nuxt.config.ts
export default defineNuxtConfig({
  app: {
    head: {
      link: [
        {
          rel: 'preconnect',
          href: 'https://fonts.googleapis.com',
        },
        {
          rel: 'stylesheet',
          href: 'https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap',
        },
      ],
    },
  },
});
```

### Typography Scale

```css
/* Tailwind classes */
.text-display { @apply text-4xl font-bold tracking-tight sm:text-5xl; }
.text-h1 { @apply text-3xl font-bold tracking-tight; }
.text-h2 { @apply text-2xl font-semibold; }
.text-h3 { @apply text-xl font-semibold; }
.text-h4 { @apply text-lg font-medium; }
.text-body { @apply text-base; }
.text-body-sm { @apply text-sm; }
.text-caption { @apply text-xs text-gray-500; }
```

## 3. Spacing System

```typescript
// Tailwind default (4px base unit)
// 0: 0px
// 1: 4px   (p-1)
// 2: 8px   (p-2)
// 3: 12px  (p-3)
// 4: 16px  (p-4)
// 5: 20px  (p-5)
// 6: 24px  (p-6)
// 8: 32px  (p-8)
// 10: 40px (p-10)
// 12: 48px (p-12)
// 16: 64px (p-16)
```

## 4. Border Radius

```css
/* Tailwind defaults */
.rounded-sm { border-radius: 2px; }
.rounded { border-radius: 4px; }
.rounded-md { border-radius: 6px; }
.rounded-lg { border-radius: 8px; }
.rounded-xl { border-radius: 12px; }
.rounded-2xl { border-radius: 16px; }
.rounded-full { border-radius: 9999px; }
```

## 5. Shadows

```css
.shadow-sm { box-shadow: 0 1px 2px 0 rgb(0 0 0 / 0.05); }
.shadow { box-shadow: 0 1px 3px 0 rgb(0 0 0 / 0.1), 0 1px 2px -1px rgb(0 0 0 / 0.1); }
.shadow-md { box-shadow: 0 4px 6px -1px rgb(0 0 0 / 0.1); }
.shadow-lg { box-shadow: 0 10px 15px -3px rgb(0 0 0 / 0.1); }
```

## 6. Component Specifications

### Button Component

```vue
<!-- components/ui/BaseButton.vue -->
<script setup lang="ts">
interface Props {
  variant?: 'primary' | 'secondary' | 'outline' | 'ghost' | 'destructive';
  size?: 'sm' | 'md' | 'lg';
  loading?: boolean;
  disabled?: boolean;
}

withDefaults(defineProps<Props>(), {
  variant: 'primary',
  size: 'md',
  loading: false,
  disabled: false,
});

const variantClasses = {
  primary: 'bg-primary-600 text-white hover:bg-primary-700',
  secondary: 'bg-gray-100 text-gray-900 hover:bg-gray-200',
  outline: 'border border-gray-300 bg-transparent hover:bg-gray-50',
  ghost: 'bg-transparent hover:bg-gray-100',
  destructive: 'bg-red-600 text-white hover:bg-red-700',
};

const sizeClasses = {
  sm: 'h-8 px-3 text-sm',
  md: 'h-10 px-4 text-sm',
  lg: 'h-12 px-6 text-base',
};
</script>

<template>
  <button
    :class="[
      'inline-flex items-center justify-center rounded-lg font-medium transition-colors',
      'focus:outline-none focus:ring-2 focus:ring-primary-500 focus:ring-offset-2',
      'disabled:pointer-events-none disabled:opacity-50',
      variantClasses[variant],
      sizeClasses[size],
    ]"
    :disabled="disabled || loading"
  >
    <Icon v-if="loading" name="svg-spinners:180-ring" class="mr-2 h-4 w-4" />
    <slot />
  </button>
</template>
```

### Card Component

```vue
<!-- components/ui/BaseCard.vue -->
<script setup lang="ts">
interface Props {
  padding?: 'none' | 'sm' | 'md' | 'lg';
}

withDefaults(defineProps<Props>(), {
  padding: 'md',
});

const paddingClasses = {
  none: '',
  sm: 'p-4',
  md: 'p-6',
  lg: 'p-8',
};
</script>

<template>
  <div
    :class="[
      'rounded-xl border border-gray-200 bg-white shadow-sm',
      'dark:border-gray-700 dark:bg-gray-800',
      paddingClasses[padding],
    ]"
  >
    <slot />
  </div>
</template>
```

### Input Component

```vue
<!-- components/ui/BaseInput.vue -->
<script setup lang="ts">
interface Props {
  label?: string;
  error?: string;
  hint?: string;
}

defineProps<Props>();

const model = defineModel<string>();
</script>

<template>
  <div class="space-y-1">
    <label v-if="label" class="text-sm font-medium text-gray-700 dark:text-gray-300">
      {{ label }}
    </label>
    <input
      v-model="model"
      class="flex h-10 w-full rounded-lg border border-gray-300 bg-white px-3 py-2
             text-sm placeholder:text-gray-400
             focus:border-primary-500 focus:outline-none focus:ring-2 focus:ring-primary-500/20
             disabled:cursor-not-allowed disabled:opacity-50
             dark:border-gray-600 dark:bg-gray-800"
      :class="{ 'border-red-500 focus:border-red-500 focus:ring-red-500/20': error }"
    />
    <p v-if="error" class="text-sm text-red-500">{{ error }}</p>
    <p v-else-if="hint" class="text-sm text-gray-500">{{ hint }}</p>
  </div>
</template>
```

## 7. Animation & Motion

```typescript
// composables/useMotion.ts
export const fadeIn = {
  initial: { opacity: 0 },
  enter: { opacity: 1 },
  leave: { opacity: 0 },
};

export const slideUp = {
  initial: { opacity: 0, y: 20 },
  enter: { opacity: 1, y: 0 },
  leave: { opacity: 0, y: 20 },
};

// Vue Transition classes (Tailwind)
// enter-active-class="transition duration-300 ease-out"
// enter-from-class="opacity-0 translate-y-4"
// enter-to-class="opacity-100 translate-y-0"
// leave-active-class="transition duration-200 ease-in"
// leave-from-class="opacity-100 translate-y-0"
// leave-to-class="opacity-0 translate-y-4"
```

## 8. Breakpoints

```typescript
// Tailwind default breakpoints (mobile-first)
// sm: 640px   - Mobile landscape
// md: 768px   - Tablet
// lg: 1024px  - Desktop
// xl: 1280px  - Large desktop
// 2xl: 1536px - Extra large

// Usage with @vueuse/core
import { useBreakpoints, breakpointsTailwind } from '@vueuse/core';

const breakpoints = useBreakpoints(breakpointsTailwind);
const isMobile = breakpoints.smaller('md');
const isDesktop = breakpoints.greaterOrEqual('lg');
```

```

// turbo
**Simpan output ke file `DESIGN_SYSTEM.md` di root project.**

---

### Step 2.2: Generate FOLDER_STRUCTURE.md

Gunakan skill `senior-vue-developer` + `nuxt-developer`:

### Untuk Nuxt 3:

```markdown
## Nuxt 3 Project Structure

```

/
├── .nuxt/                          # Build directory (git ignored)
├── .output/                        # Production output (git ignored)
│
├── app.vue                         # Root component
├── nuxt.config.ts                  # Nuxt configuration
│
├── assets/
│   ├── css/
│   │   └── main.css                # Global styles
│   └── images/
│
├── components/
│   ├── ui/                         # Base UI components
│   │   ├── BaseButton.vue
│   │   ├── BaseCard.vue
│   │   ├── BaseInput.vue
│   │   └── BaseModal.vue
│   │
│   ├── layout/                     # Layout components
│   │   ├── TheHeader.vue
│   │   ├── TheFooter.vue
│   │   ├── TheSidebar.vue
│   │   └── TheNav.vue
│   │
│   └── features/                   # Feature components
│       ├── dashboard/
│       │   ├── DashboardStats.vue
│       │   └── DashboardChart.vue
│       └── users/
│           ├── UserCard.vue
│           └── UserList.vue
│
├── composables/                    # Auto-imported composables
│   ├── useAuth.ts
│   ├── useUsers.ts
│   └── useToast.ts
│
├── layouts/
│   ├── default.vue                 # Default layout
│   ├── auth.vue                    # Auth pages layout
│   └── dashboard.vue               # Dashboard layout
│
├── middleware/
│   ├── auth.ts                     # Auth guard
│   └── guest.ts                    # Guest only
│
├── pages/
│   ├── index.vue                   # / (home)
│   ├── login.vue                   # /login
│   ├── register.vue                # /register
│   ├── dashboard/
│   │   ├── index.vue               # /dashboard
│   │   └── settings.vue            # /dashboard/settings
│   └── users/
│       ├── index.vue               # /users
│       └── [id].vue                # /users/:id
│
├── plugins/
│   └── vue-query.ts                # TanStack Query plugin
│
├── public/
│   ├── favicon.ico
│   └── images/
│
├── server/
│   ├── api/
│   │   ├── auth/
│   │   │   ├── login.post.ts
│   │   │   └── register.post.ts
│   │   └── users/
│   │       ├── index.get.ts
│   │       └── [id].get.ts
│   ├── middleware/
│   └── utils/
│
├── stores/                         # Pinia stores
│   ├── auth.ts
│   └── ui.ts
│
├── types/
│   ├── index.ts
│   ├── api.ts
│   └── user.ts
│
└── utils/
    ├── format.ts
    └── validation.ts

```

## Naming Conventions
- Components: `PascalCase.vue`
- Pages: `kebab-case.vue`
- Composables: `useCamelCase.ts`
- Stores: `camelCase.ts`
- Server routes: `method.ts` (e.g., `login.post.ts`)

```

### Untuk Vue 3 SPA

```markdown
## Vue 3 SPA Structure (Vite)

```

/
├── public/
│   └── favicon.ico
│
├── src/
│   ├── assets/
│   │   ├── css/
│   │   │   └── main.css
│   │   └── images/
│   │
│   ├── components/
│   │   ├── ui/
│   │   ├── layout/
│   │   └── features/
│   │
│   ├── composables/
│   │   ├── useAuth.ts
│   │   └── useUsers.ts
│   │
│   ├── layouts/
│   │   ├── DefaultLayout.vue
│   │   └── AuthLayout.vue
│   │
│   ├── router/
│   │   └── index.ts
│   │
│   ├── stores/
│   │   ├── auth.ts
│   │   └── ui.ts
│   │
│   ├── types/
│   │   └── index.ts
│   │
│   ├── utils/
│   │   └── format.ts
│   │
│   ├── views/                      # Route components
│   │   ├── HomeView.vue
│   │   ├── LoginView.vue
│   │   └── DashboardView.vue
│   │
│   ├── App.vue
│   └── main.ts
│
├── index.html
├── vite.config.ts
└── tailwind.config.ts

```
```

// turbo
**Simpan output ke file `FOLDER_STRUCTURE.md` di root project.**

---

### Step 2.3: Generate DB_SCHEMA.md

Gunakan skill `database-modeling-specialist`:

```markdown
Buatkan `DB_SCHEMA.md` sesuai fitur di PRD.md.
```

// turbo
**Simpan output ke file `DB_SCHEMA.md` di root project.**

---

### Step 2.4: Generate API_CONTRACT.md

Gunakan skill `api-design-specialist`:

```markdown
Buatkan `API_CONTRACT.md` untuk Vue/Nuxt app.
Include Nuxt server routes format jika pakai Nuxt.
```

// turbo
**Simpan output ke file `API_CONTRACT.md` di root project.**

---

### Step 2.5: Generate EXAMPLES.md

Gunakan skill `senior-vue-developer` + `nuxt-developer`:

```markdown
Act as senior-vue-developer dan nuxt-developer.
Buatkan `EXAMPLES.md` berisi contoh kode Vue/Nuxt yang jadi standar project.

## 1. Basic Component with Script Setup
```vue
<!-- components/features/users/UserCard.vue -->
<script setup lang="ts">
import type { User } from '~/types';

interface Props {
  user: User;
}

const props = defineProps<Props>();

const emit = defineEmits<{
  select: [user: User];
}>();

const fullName = computed(() => 
  `${props.user.firstName} ${props.user.lastName}`
);
</script>

<template>
  <BaseCard class="cursor-pointer hover:shadow-md" @click="emit('select', user)">
    <div class="flex items-center gap-4">
      <img
        :src="user.avatar"
        :alt="fullName"
        class="h-12 w-12 rounded-full object-cover"
      />
      <div>
        <h3 class="font-semibold text-gray-900">{{ fullName }}</h3>
        <p class="text-sm text-gray-500">{{ user.email }}</p>
      </div>
    </div>
  </BaseCard>
</template>
```

## 2. Composable Pattern

```typescript
// composables/useUsers.ts
import type { User } from '~/types';

export function useUsers() {
  const users = ref<User[]>([]);
  const loading = ref(false);
  const error = ref<Error | null>(null);

  async function fetchUsers() {
    loading.value = true;
    error.value = null;
    
    try {
      const { data } = await useFetch<User[]>('/api/users');
      users.value = data.value ?? [];
    } catch (err) {
      error.value = err as Error;
    } finally {
      loading.value = false;
    }
  }

  return {
    users: readonly(users),
    loading: readonly(loading),
    error: readonly(error),
    fetchUsers,
  };
}
```

## 3. Nuxt useFetch Pattern

```vue
<!-- pages/users/index.vue -->
<script setup lang="ts">
import type { User } from '~/types';

definePageMeta({
  layout: 'dashboard',
  middleware: 'auth',
});

const { data: users, pending, error, refresh } = await useFetch<User[]>('/api/users');
</script>

<template>
  <div class="container py-8">
    <div class="mb-8 flex items-center justify-between">
      <h1 class="text-h1">Users</h1>
      <BaseButton @click="refresh">Refresh</BaseButton>
    </div>

    <div v-if="pending" class="flex justify-center py-12">
      <Icon name="svg-spinners:180-ring" class="h-8 w-8 text-primary-500" />
    </div>

    <div v-else-if="error" class="py-12 text-center">
      <p class="text-red-500">{{ error.message }}</p>
      <BaseButton variant="outline" class="mt-4" @click="refresh">
        Try again
      </BaseButton>
    </div>

    <div v-else-if="users?.length" class="grid gap-4 md:grid-cols-2 lg:grid-cols-3">
      <UserCard v-for="user in users" :key="user.id" :user="user" />
    </div>

    <div v-else class="py-12 text-center text-gray-500">
      No users found
    </div>
  </div>
</template>
```

## 4. Pinia Store Pattern

```typescript
// stores/auth.ts
import type { User } from '~/types';

interface AuthState {
  user: User | null;
  token: string | null;
}

export const useAuthStore = defineStore('auth', () => {
  const user = ref<User | null>(null);
  const token = ref<string | null>(null);

  const isAuthenticated = computed(() => !!token.value);

  async function login(email: string, password: string) {
    const { data } = await useFetch('/api/auth/login', {
      method: 'POST',
      body: { email, password },
    });

    if (data.value) {
      user.value = data.value.user;
      token.value = data.value.token;
    }
  }

  function logout() {
    user.value = null;
    token.value = null;
    navigateTo('/login');
  }

  return {
    user: readonly(user),
    token: readonly(token),
    isAuthenticated,
    login,
    logout,
  };
});
```

## 5. Form with VeeValidate + Zod

```vue
<!-- components/forms/LoginForm.vue -->
<script setup lang="ts">
import { useForm } from 'vee-validate';
import { toTypedSchema } from '@vee-validate/zod';
import { z } from 'zod';

const loginSchema = toTypedSchema(
  z.object({
    email: z.string().email('Invalid email address'),
    password: z.string().min(8, 'Password must be at least 8 characters'),
  })
);

const { handleSubmit, errors, isSubmitting } = useForm({
  validationSchema: loginSchema,
});

const authStore = useAuthStore();

const onSubmit = handleSubmit(async (values) => {
  await authStore.login(values.email, values.password);
});
</script>

<template>
  <form class="space-y-4" @submit="onSubmit">
    <BaseInput
      name="email"
      label="Email"
      type="email"
      :error="errors.email"
    />
    
    <BaseInput
      name="password"
      label="Password"
      type="password"
      :error="errors.password"
    />
    
    <BaseButton type="submit" class="w-full" :loading="isSubmitting">
      Sign in
    </BaseButton>
  </form>
</template>
```

## 6. Nuxt Server Route

```typescript
// server/api/users/index.get.ts
import { H3Event } from 'h3';

export default defineEventHandler(async (event: H3Event) => {
  // Get query params
  const query = getQuery(event);
  
  // Fetch from database or external API
  const users = await prisma.user.findMany({
    take: Number(query.limit) || 10,
    skip: Number(query.offset) || 0,
  });
  
  return users;
});
```

```typescript
// server/api/users/[id].get.ts
export default defineEventHandler(async (event) => {
  const id = getRouterParam(event, 'id');
  
  const user = await prisma.user.findUnique({
    where: { id },
  });
  
  if (!user) {
    throw createError({
      statusCode: 404,
      message: 'User not found',
    });
  }
  
  return user;
});
```

## 7. Middleware Pattern

```typescript
// middleware/auth.ts
export default defineNuxtRouteMiddleware((to, from) => {
  const authStore = useAuthStore();
  
  if (!authStore.isAuthenticated) {
    return navigateTo('/login');
  }
});
```

```typescript
// middleware/guest.ts
export default defineNuxtRouteMiddleware((to, from) => {
  const authStore = useAuthStore();
  
  if (authStore.isAuthenticated) {
    return navigateTo('/dashboard');
  }
});
```

## 8. Layout Pattern

```vue
<!-- layouts/dashboard.vue -->
<script setup lang="ts">
const authStore = useAuthStore();
const route = useRoute();

const navigation = [
  { name: 'Dashboard', href: '/dashboard', icon: 'lucide:layout-dashboard' },
  { name: 'Users', href: '/users', icon: 'lucide:users' },
  { name: 'Settings', href: '/dashboard/settings', icon: 'lucide:settings' },
];
</script>

<template>
  <div class="flex min-h-screen">
    <!-- Sidebar -->
    <aside class="fixed left-0 top-0 z-40 h-screen w-64 border-r bg-white">
      <nav class="space-y-1 p-4">
        <NuxtLink
          v-for="item in navigation"
          :key="item.href"
          :to="item.href"
          :class="[
            route.path === item.href
              ? 'bg-primary-50 text-primary-600'
              : 'text-gray-600 hover:bg-gray-50',
            'flex items-center gap-3 rounded-lg px-4 py-2',
          ]"
        >
          <Icon :name="item.icon" class="h-5 w-5" />
          {{ item.name }}
        </NuxtLink>
      </nav>
    </aside>

    <!-- Main content -->
    <main class="ml-64 flex-1">
      <slot />
    </main>
  </div>
</template>
```

## 9. Error Handling

```vue
<!-- error.vue -->
<script setup lang="ts">
defineProps<{
  error: {
    statusCode: number;
    message: string;
  };
}>();

const handleError = () => clearError({ redirect: '/' });
</script>

<template>
  <div class="flex min-h-screen items-center justify-center">
    <div class="text-center">
      <h1 class="text-6xl font-bold text-gray-900">{{ error.statusCode }}</h1>
      <p class="mt-4 text-gray-600">{{ error.message }}</p>
      <BaseButton class="mt-8" @click="handleError">
        Go back home
      </BaseButton>
    </div>
  </div>
</template>
```

## 10. Loading State

```vue
<!-- pages/users/loading.vue or component -->
<template>
  <div class="container py-8">
    <div class="mb-8">
      <div class="h-8 w-48 animate-pulse rounded bg-gray-200" />
    </div>
    <div class="grid gap-4 md:grid-cols-2 lg:grid-cols-3">
      <div
        v-for="i in 6"
        :key="i"
        class="h-32 animate-pulse rounded-xl bg-gray-200"
      />
    </div>
  </div>
</template>
```

```

// turbo
**Simpan output ke file `EXAMPLES.md` di root project.**

---

## ✅ Phase 3: Project Setup

### Untuk Nuxt 3:

// turbo

```bash
npx nuxi@latest init . --package-manager pnpm --git-init false
pnpm add @pinia/nuxt @vueuse/nuxt @nuxt/image nuxt-icon
pnpm add -D @nuxtjs/tailwindcss
pnpm add zod vee-validate @vee-validate/zod date-fns
```

### Untuk Vue 3 SPA

// turbo

```bash
npm create vite@latest . -- --template vue-ts
npm install vue-router@4 pinia @vueuse/core @tanstack/vue-query
npm install zod vee-validate @vee-validate/zod
npm install -D tailwindcss postcss autoprefixer
npx tailwindcss init -p
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
├── nuxt.config.ts         ✅ Nuxt only
└── package.json           ✅ Dependencies
```

---

## 💡 Vue/Nuxt Tips

### Magic Words untuk Prompts

- "Gunakan `<script setup>` dengan TypeScript"
- "Pakai Composition API, bukan Options API"
- "Ikuti pattern di EXAMPLES.md"
- "Data fetching dengan useFetch (Nuxt) atau TanStack Query (Vue SPA)"
- "State global dengan Pinia"
- "Refer ke DESIGN_SYSTEM.md untuk styling"

### Common Mistakes to Avoid

| ❌ Jangan | ✅ Lakukan |
| --------- | --------- |
| Options API (data, methods) | Composition API (`<script setup>`) |
| onMounted for data fetching | useFetch / useAsyncData |
| Mutate props langsung | Emit event ke parent |
| ref() untuk complex objects | reactive() atau ref() dengan care |
| Global CSS tanpa scoped | Tailwind utilities atau scoped |
| this.$store | useStore() composable |

### Vue 3.4+ Features

| Feature | Syntax |
| ------- | ------ |
| v-model with defineModel | `const model = defineModel<string>()` |
| Generic components | `<script setup lang="ts" generic="T">` |
| Short v-bind | `:prop` or `v-bind:prop` |
| Shorthand syntax | `:value`, `@click`, `v-slot` |

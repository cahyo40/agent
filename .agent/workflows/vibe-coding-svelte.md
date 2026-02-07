---
description: Initialize Vibe Coding context files for Svelte/SvelteKit web application
---

# /vibe-coding-svelte

Workflow untuk setup dokumen konteks Vibe Coding khusus **Svelte/SvelteKit Web Application**.

---

## 📋 Prerequisites

1. **Deskripsi ide aplikasi**
2. **Tipe: SvelteKit (full-stack) atau Svelte SPA?**
3. **Backend: Built-in API routes / External API?**
4. **Database: PostgreSQL / Supabase / Firebase?**

---

## 🏗️ Phase 1: Holy Trinity

### Step 1.1: Generate PRD.md

Skill: `senior-project-manager`

```markdown
Buatkan PRD.md untuk Svelte/SvelteKit app: [IDE]
- Executive Summary, Problem, Target User
- User Stories (10+ MVP)
- Features: Must/Should/Could/Won't
- Success Metrics
```

// turbo
**Simpan ke `PRD.md`**

---

### Step 1.2: Generate TECH_STACK.md

Skill: `tech-stack-architect` + `svelte-developer`

```markdown
## Core Stack
- Framework: SvelteKit 2.x
- Svelte: 5.x (Runes)
- Language: TypeScript strict
- Adapter: @sveltejs/adapter-auto / adapter-node

## Styling
- Tailwind CSS 3.4+
- Or: vanilla CSS dengan scoped styles

## State Management
- Svelte stores ($state, $derived)
- Context API untuk dependency injection

## Forms & Validation
- Superforms + Zod

## Backend (SvelteKit)
- Form Actions
- API Routes (+server.ts)
- Hooks untuk middleware

## Database
- Prisma / Drizzle
- atau Supabase client

## Authentication
- Lucia Auth / SvelteKit Auth
- atau Supabase Auth

## Approved Packages
```json
{
  "dependencies": {
    "@sveltejs/kit": "^2.0.0",
    "svelte": "^5.0.0",
    "sveltekit-superforms": "^2.0.0",
    "zod": "^3.22.0",
    "lucia": "^3.0.0",
    "@lucia-auth/adapter-prisma": "^4.0.0",
    "@prisma/client": "^5.8.0",
    "tailwindcss": "^3.4.0"
  },
  "devDependencies": {
    "@sveltejs/adapter-auto": "^3.0.0",
    "typescript": "^5.3.0",
    "prisma": "^5.8.0",
    "vite": "^5.0.0"
  }
}
```

```

// turbo
**Simpan ke `TECH_STACK.md`**

---

### Step 1.3: Generate RULES.md

Skill: `svelte-developer`

```markdown
## Svelte 5 Rules (Runes)
- Gunakan `$state()` untuk reactive state
- Gunakan `$derived()` untuk computed values
- Gunakan `$effect()` hanya jika perlu side effects
- JANGAN gunakan reactive statements ($:) - deprecated

## Component Rules
- Single File Components (.svelte)
- TypeScript di `<script lang="ts">`
- Props dengan `let { prop }: Props = $props()`
- Max 200 baris per component

## SvelteKit Rules
- +page.svelte untuk pages
- +page.server.ts untuk server load
- +page.ts untuk universal load
- +server.ts untuk API endpoints
- Form actions untuk mutations

## File Naming
- Routes: kebab-case folders
- Components: PascalCase.svelte
- Lib files: kebab-case.ts

## Style Rules
- Scoped styles default
- Tailwind untuk utility classes
- CSS custom properties untuk theming

## Data Loading
- Load functions untuk data fetching
- Form actions untuk mutations
- JANGAN fetch di onMount untuk initial data

## AI Behavior Rules
1. JANGAN import package tidak ada di package.json
2. GUNAKAN Svelte 5 runes, bukan legacy syntax
3. SELALU handle loading states dengan Svelte loading
4. Refer ke DB_SCHEMA.md untuk models
5. Refer ke API_CONTRACT.md untuk endpoints
```

// turbo
**Simpan ke `RULES.md`**

---

## 🎨 Phase 2: Support System

### Step 2.1: FOLDER_STRUCTURE.md

```markdown
## SvelteKit Project Structure

```

src/
├── app.html                     # HTML template
├── app.css                      # Global styles
├── app.d.ts                     # Type declarations
│
├── lib/                         # $lib alias
│   ├── components/
│   │   ├── ui/                  # Base components
│   │   │   ├── Button.svelte
│   │   │   └── Card.svelte
│   │   └── features/            # Feature components
│   │
│   ├── server/                  # Server-only code
│   │   ├── db.ts                # Database client
│   │   └── auth.ts              # Auth utilities
│   │
│   ├── stores/                  # Svelte stores
│   ├── utils/                   # Utility functions
│   └── types/                   # TypeScript types
│
├── routes/
│   ├── +layout.svelte           # Root layout
│   ├── +layout.server.ts        # Root server load
│   ├── +page.svelte             # Home page
│   │
│   ├── (auth)/                  # Auth group
│   │   ├── login/
│   │   │   ├── +page.svelte
│   │   │   └── +page.server.ts
│   │   └── register/
│   │
│   ├── (app)/                   # Protected group
│   │   ├── +layout.svelte
│   │   ├── dashboard/
│   │   └── settings/
│   │
│   └── api/                     # API routes
│       └── users/
│           └── +server.ts
│
└── hooks.server.ts              # Server hooks

static/                          # Static assets
prisma/                          # Prisma schema
tests/                           # Tests

```

## Naming Conventions
- Routes: kebab-case folders
- Components: PascalCase.svelte
- Stores: camelCase.ts
- Server files: +page.server.ts, +server.ts
```

// turbo
**Simpan ke `FOLDER_STRUCTURE.md`**

---

### Step 2.2: EXAMPLES.md

```markdown
## 1. Component Pattern (Svelte 5)
```svelte
<!-- lib/components/ui/Button.svelte -->
<script lang="ts">
  import type { Snippet } from 'svelte';

  interface Props {
    variant?: 'primary' | 'secondary';
    disabled?: boolean;
    onclick?: () => void;
    children: Snippet;
  }

  let { variant = 'primary', disabled = false, onclick, children }: Props = $props();
</script>

<button
  class="btn btn-{variant}"
  {disabled}
  {onclick}
>
  {@render children()}
</button>

<style>
  .btn { /* styles */ }
  .btn-primary { /* styles */ }
</style>
```

## 2. Page with Server Load

```svelte
<!-- routes/users/+page.svelte -->
<script lang="ts">
  import type { PageData } from './$types';
  import UserCard from '$lib/components/features/UserCard.svelte';

  let { data }: { data: PageData } = $props();
</script>

<h1>Users</h1>
<div class="grid gap-4">
  {#each data.users as user}
    <UserCard {user} />
  {/each}
</div>
```

```typescript
// routes/users/+page.server.ts
import type { PageServerLoad } from './$types';
import { db } from '$lib/server/db';

export const load: PageServerLoad = async () => {
  const users = await db.user.findMany();
  return { users };
};
```

## 3. Form Action Pattern

```typescript
// routes/users/+page.server.ts
import type { Actions } from './$types';
import { fail } from '@sveltejs/kit';
import { superValidate } from 'sveltekit-superforms';
import { zod } from 'sveltekit-superforms/adapters';
import { userSchema } from '$lib/schemas/user';

export const actions: Actions = {
  create: async ({ request }) => {
    const form = await superValidate(request, zod(userSchema));
    
    if (!form.valid) {
      return fail(400, { form });
    }
    
    await db.user.create({ data: form.data });
    return { form };
  }
};
```

## 4. API Endpoint

```typescript
// routes/api/users/+server.ts
import { json } from '@sveltejs/kit';
import type { RequestHandler } from './$types';
import { db } from '$lib/server/db';

export const GET: RequestHandler = async () => {
  const users = await db.user.findMany();
  return json(users);
};

export const POST: RequestHandler = async ({ request }) => {
  const data = await request.json();
  const user = await db.user.create({ data });
  return json(user, { status: 201 });
};
```

## 5. Reactive State with Runes

```svelte
<script lang="ts">
  let count = $state(0);
  let doubled = $derived(count * 2);

  function increment() {
    count++;
  }

  $effect(() => {
    console.log('Count changed:', count);
  });
</script>

<button onclick={increment}>
  Count: {count}, Doubled: {doubled}
</button>
```

## 6. Store Pattern

```typescript
// lib/stores/user.ts
import { writable } from 'svelte/store';
import type { User } from '$lib/types';

function createUserStore() {
  const { subscribe, set, update } = writable<User | null>(null);

  return {
    subscribe,
    login: (user: User) => set(user),
    logout: () => set(null),
  };
}

export const userStore = createUserStore();
```

```

// turbo
**Simpan ke `EXAMPLES.md`**

---

## ✅ Phase 3: Project Setup

// turbo
```bash
npx sv create . --template minimal --types ts --add tailwindcss,prettier
npm install sveltekit-superforms zod lucia @prisma/client
npm install -D prisma
npx prisma init
```

---

## 📁 Checklist

```
PRD.md, TECH_STACK.md, RULES.md, DB_SCHEMA.md,
FOLDER_STRUCTURE.md, API_CONTRACT.md, EXAMPLES.md
```

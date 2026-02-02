---
name: svelte-developer
description: "Expert Svelte development including reactive declarations, stores, SvelteKit, and modern component patterns"
---

# Svelte Developer

## Overview

This skill transforms you into an **Expert Svelte Developer** capable of building high-performance web applications with Svelte's compiler-based approach, SvelteKit for full-stack development, and modern reactive patterns.

## When to Use This Skill

- Use when building fast, compiler-based web apps
- Use when zero-boilerplate reactivity is needed
- Use when implementing multi-page apps with SvelteKit
- Use when needing minimal bundle sizes

---

## Part 1: Svelte Fundamentals

### 1.1 Why Svelte?

| Aspect | React/Vue | Svelte |
|--------|-----------|--------|
| **Runtime** | Virtual DOM library | No runtime (compiled) |
| **Bundle Size** | ~40KB+ | ~2KB + your code |
| **Reactivity** | Hooks/Proxy | Compiler magic |
| **Boilerplate** | useState, reactive() | Just assignment |
| **Learning Curve** | Medium | Low |

### 1.2 Svelte's Core Philosophy

```
┌────────────────────────────────────────────────────────────┐
│                    Svelte Compiler                          │
├────────────────────────────────────────────────────────────┤
│                                                             │
│  .svelte files  ──►  Compiler  ──►  Optimized JavaScript   │
│                                                             │
│  • Reactive statements compiled to updates                  │
│  • No virtual DOM diffing at runtime                        │
│  • Dead code elimination                                    │
│  • Scoped CSS by default                                    │
│                                                             │
└────────────────────────────────────────────────────────────┘
```

### 1.3 Svelte 4 vs Svelte 5 (Runes)

| Feature | Svelte 4 | Svelte 5 (Runes) |
|---------|----------|------------------|
| **State** | `let x = 0` | `let x = $state(0)` |
| **Derived** | `$: doubled = x * 2` | `let doubled = $derived(x * 2)` |
| **Effects** | `$: { ... }` | `$effect(() => { ... })` |
| **Props** | `export let name` | `let { name } = $props()` |

---

## Part 2: Project Structure

### 2.1 SvelteKit Structure

```text
my-sveltekit-app/
├── src/
│   ├── lib/                    # Shared components, utils
│   │   ├── components/         # Reusable components
│   │   ├── stores/             # Svelte stores
│   │   └── utils/              # Helper functions
│   ├── routes/                 # File-based routing
│   │   ├── +layout.svelte      # Root layout
│   │   ├── +page.svelte        # Home page (/)
│   │   ├── +error.svelte       # Error page
│   │   ├── about/
│   │   │   └── +page.svelte    # /about
│   │   └── blog/
│   │       ├── +page.server.ts # Server-side load
│   │       ├── +page.svelte    # /blog
│   │       └── [slug]/
│   │           ├── +page.ts    # Load function
│   │           └── +page.svelte # /blog/:slug
│   ├── app.html                # HTML template
│   └── app.d.ts                # TypeScript declarations
├── static/                     # Static assets
├── svelte.config.js            # Svelte configuration
├── tsconfig.json
└── vite.config.ts
```

### 2.2 File Conventions

| File | Purpose |
|------|---------|
| `+page.svelte` | Page component |
| `+page.ts` | Universal load function |
| `+page.server.ts` | Server-only load function |
| `+layout.svelte` | Layout wrapper |
| `+layout.ts` | Layout load function |
| `+error.svelte` | Error boundary |
| `+server.ts` | API endpoint |

---

## Part 3: Reactivity

### 3.1 Basic Reactivity (Svelte 4)

```svelte
<script>
  let count = 0;
  
  // Reactive declarations (re-run when dependencies change)
  $: doubled = count * 2;
  $: quadrupled = doubled * 2;
  
  // Reactive statements
  $: if (count > 10) {
    console.log('Count is getting high!');
  }
  
  function increment() {
    count += 1; // Assignment triggers updates
  }
</script>

<button on:click={increment}>
  Count: {count} (Doubled: {doubled}, Quadrupled: {quadrupled})
</button>
```

### 3.2 Svelte 5 Runes

```svelte
<script>
  let count = $state(0);
  let doubled = $derived(count * 2);
  
  $effect(() => {
    console.log(`Count changed to ${count}`);
  });
  
  function increment() {
    count += 1;
  }
</script>

<button onclick={increment}>
  Count: {count} (Doubled: {doubled})
</button>
```

### 3.3 Reactive Arrays and Objects

```svelte
<script>
  let items = ['Apple', 'Banana'];
  
  function addItem(item) {
    // Must reassign for reactivity
    items = [...items, item];
    // OR
    items.push(item);
    items = items; // Trigger update
  }
  
  // Object reactivity
  let user = { name: 'John', age: 30 };
  
  function updateAge() {
    user.age += 1;
    user = user; // Trigger update
    // OR just: user = { ...user, age: user.age + 1 };
  }
</script>
```

---

## Part 4: State Management

### 4.1 Store Types

| Store Type | Description | Use Case |
|------------|-------------|----------|
| `writable` | Read/write store | User data, form state |
| `readable` | Read-only store | Time, geolocation |
| `derived` | Computed from other stores | Filtered lists |

### 4.2 Creating Stores

```typescript
// lib/stores/counter.ts
import { writable, derived } from 'svelte/store';

// Writable store
export const count = writable(0);

// Derived store
export const doubled = derived(count, $count => $count * 2);

// Store with custom methods
function createCounter() {
  const { subscribe, set, update } = writable(0);
  
  return {
    subscribe,
    increment: () => update(n => n + 1),
    decrement: () => update(n => n - 1),
    reset: () => set(0),
  };
}

export const counter = createCounter();
```

### 4.3 Using Stores in Components

```svelte
<script>
  import { count, counter } from '$lib/stores/counter';
</script>

<!-- Auto-subscription with $ prefix -->
<p>Count: {$count}</p>

<button on:click={counter.increment}>+</button>
<button on:click={counter.decrement}>-</button>
<button on:click={counter.reset}>Reset</button>
```

---

## Part 5: SvelteKit Routing

### 5.1 Data Loading

**Universal Load (runs on both server and client):**

```typescript
// routes/blog/+page.ts
import type { PageLoad } from './$types';

export const load: PageLoad = async ({ fetch }) => {
  const response = await fetch('/api/posts');
  const posts = await response.json();
  
  return { posts };
};
```

**Server-Only Load:**

```typescript
// routes/blog/+page.server.ts
import type { PageServerLoad } from './$types';
import { db } from '$lib/db';

export const load: PageServerLoad = async ({ params }) => {
  const posts = await db.posts.findMany();
  
  return { posts };
};
```

**Using in Page:**

```svelte
<!-- routes/blog/+page.svelte -->
<script>
  export let data;
</script>

<h1>Blog</h1>
{#each data.posts as post}
  <article>
    <h2><a href="/blog/{post.slug}">{post.title}</a></h2>
    <p>{post.excerpt}</p>
  </article>
{/each}
```

### 5.2 Form Actions

```typescript
// routes/login/+page.server.ts
import type { Actions } from './$types';
import { fail, redirect } from '@sveltejs/kit';

export const actions: Actions = {
  default: async ({ request, cookies }) => {
    const data = await request.formData();
    const email = data.get('email');
    const password = data.get('password');
    
    if (!email || !password) {
      return fail(400, { error: 'Missing fields' });
    }
    
    const user = await authenticate(email, password);
    
    if (!user) {
      return fail(401, { error: 'Invalid credentials' });
    }
    
    cookies.set('session', user.sessionId, { path: '/' });
    throw redirect(303, '/dashboard');
  },
};
```

```svelte
<!-- routes/login/+page.svelte -->
<script>
  import { enhance } from '$app/forms';
  export let form;
</script>

{#if form?.error}
  <p class="error">{form.error}</p>
{/if}

<form method="POST" use:enhance>
  <input name="email" type="email" required />
  <input name="password" type="password" required />
  <button type="submit">Login</button>
</form>
```

---

## Part 6: API Routes

### 6.1 Creating Endpoints

```typescript
// routes/api/posts/+server.ts
import { json, error } from '@sveltejs/kit';
import type { RequestHandler } from './$types';

export const GET: RequestHandler = async ({ url }) => {
  const page = Number(url.searchParams.get('page')) || 1;
  const posts = await db.posts.findMany({ take: 10, skip: (page - 1) * 10 });
  
  return json(posts);
};

export const POST: RequestHandler = async ({ request }) => {
  const data = await request.json();
  
  if (!data.title) {
    throw error(400, 'Title is required');
  }
  
  const post = await db.posts.create({ data });
  
  return json(post, { status: 201 });
};
```

---

## Part 7: Transitions & Animations

### 7.1 Built-in Transitions

```svelte
<script>
  import { fade, fly, slide, scale } from 'svelte/transition';
  import { flip } from 'svelte/animate';
  
  let visible = true;
  let items = ['A', 'B', 'C'];
</script>

<button on:click={() => visible = !visible}>Toggle</button>

{#if visible}
  <div transition:fly={{ y: 200, duration: 500 }}>
    Flies in and out
  </div>
{/if}

<!-- List animations -->
{#each items as item (item)}
  <div animate:flip={{ duration: 300 }}>
    {item}
  </div>
{/each}
```

### 7.2 Custom Transitions

```svelte
<script>
  function typewriter(node, { speed = 1 }) {
    const text = node.textContent;
    const duration = text.length / (speed * 0.01);
    
    return {
      duration,
      tick: t => {
        const i = Math.floor(text.length * t);
        node.textContent = text.slice(0, i);
      }
    };
  }
</script>

<p transition:typewriter={{ speed: 2 }}>
  Hello, World!
</p>
```

---

## Part 8: Best Practices Summary

### ✅ Do This

- ✅ Use `$:` for reactive declarations
- ✅ Keep components small and focused
- ✅ Use SvelteKit for full-stack features
- ✅ Use stores for cross-component state
- ✅ Use built-in transitions for polish
- ✅ Leverage TypeScript for type safety

### ❌ Avoid This

- ❌ Don't mutate arrays/objects without reassignment
- ❌ Don't overuse stores for simple local state
- ❌ Don't skip `:global()` for third-party styles
- ❌ Don't ignore SvelteKit's data fetching patterns

---

## Common Patterns

| Pattern | Solution |
|---------|----------|
| Props | `export let name` or `$props()` |
| Events | `dispatch('event', data)` |
| Two-way binding | `bind:value` |
| Conditional | `{#if ...} {:else} {/if}` |
| Loops | `{#each items as item} {/each}` |
| Awaiting | `{#await promise} {...} {/await}` |

---

## Related Skills

- `@senior-typescript-developer` - TypeScript patterns
- `@senior-vue-developer` - Similar reactive model
- `@astro-developer` - Multi-framework integration

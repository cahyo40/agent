---
name: svelte-developer
description: "Expert Svelte development including reactive declarations, stores, SvelteKit, and modern component patterns"
---

# Svelte Developer

## Overview

Build high-performance web applications with Svelte. Master component reactivity, state management with stores, SvelteKit for routing and SSR, and cohesive animation features.

## When to Use This Skill

- Use when building fast, compiler-based web apps
- Use when zero-boilerplate reactivity is needed
- Use when implementing multi-page apps with SvelteKit
- Use when needing high-performance transitions

## How It Works

### Step 1: Component Basics & Reactivity

```svelte
<!-- Counter.svelte -->
<script>
  let count = 0;

  // Reactive declaration (re-computes when dependencies change)
  $: doubled = count * 2;

  function increment() {
    count += 1;
  }
</script>

<button on:click={increment}>
  Count is {count} (Doubled: {doubled})
</button>

<style>
  button {
    font-size: 1.2rem;
    padding: 0.5rem 1rem;
    background: #ff3e00;
    color: white;
    border: none;
    border-radius: 4px;
    cursor: pointer;
  }
</style>
```

### Step 2: State Management (Stores)

```javascript
// stores.js
import { writable, derived } from 'svelte/store';

export const count = writable(0);

export const doubled = derived(count, $count => $count * 2);
```

```svelte
<!-- Component using store -->
<script>
  import { count, doubled } from './stores.js';
</script>

<h1>The count is {$count}</h1>
<p>Doubled is {$doubled}</p>

<button on:click={() => count.update(n => n + 1)}>
  Increment
</button>
```

### Step 3: SvelteKit (Routing & Data Fetching)

```text
# Directory structure
src/routes/
  +layout.svelte
  +page.svelte
  blog/
    +page.server.js
    +page.svelte
```

```javascript
// src/routes/blog/+page.server.js
export async function load() {
  const posts = await fetchPosts();
  return { posts };
}
```

```svelte
<!-- src/routes/blog/+page.svelte -->
<script>
  export let data;
</script>

<h1>Blog</h1>
<ul>
  {#each data.posts as post}
    <li><a href="/blog/{post.slug}">{post.title}</a></li>
  {/each}
</ul>
```

### Step 4: Transitions & Animations

```svelte
<script>
  import { fade, fly } from 'svelte/transition';
  let visible = true;
</script>

<label>
  <input type="checkbox" bind:checked={visible} />
  Visible
</label>

{#if visible}
  <div transition:fly={{ y: 200, duration: 2000 }}>
    Flies in and out
  </div>
{/if}
```

## Best Practices

### ✅ Do This

- ✅ Use `$` prefix for reactive declarations
- ✅ Keep components small and focused
- ✅ Leverage SvelteKit for full-stack features
- ✅ Use Stores for global state, Props for parent-child communication
- ✅ Use built-in transitions for UI polish

### ❌ Avoid This

- ❌ Don't overuse stores for simple local state
- ❌ Don't mutate array/object props directly (use reassignment for reactivity)
- ❌ Don't skip `:global()` when styling third-party components
- ❌ Don't ignore SvelteKit's standard data fetching patterns

## Related Skills

- `@senior-react-developer` - Modern frontend comparison
- `@senior-typescript-developer` - Svelte with TS
- `@astro-developer` - Multi-framework integration

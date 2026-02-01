---
name: astro-developer
description: "Expert Astro development including islands architecture, zero-JS by default, multi-framework support, and content-driven site building"
---

# Astro Developer

## Overview

Master Astro for building content-heavy websites with superior performance. Leverage "Islands Architecture," zero-JavaScript defaults, seamless integration of React/Svelte/Vue components, and robust Markdown/MDX handling.

## When to Use This Skill

- Use when building content-driven sites (blogs, docs, landing pages)
- Use when maximum performance/SEO is critical
- Use when needing to mix different frontend frameworks
- Use when leveraging MDX for documentation

## How It Works

### Step 1: Astro Component & Frontmatter

```astro
---
// src/components/Card.astro
// Frontmatter (Server-side code)
const { title, date } = Astro.props;
const formattedDate = new Date(date).toLocaleDateString();
---

<div class="card">
  <h2>{title}</h2>
  <time>{formattedDate}</time>
  <slot /> <!-- Child content goes here -->
</div>

<style>
  .card {
    border: 1px solid #eaeaea;
    padding: 1.5rem;
    border-radius: 8px;
  }
</style>
```

### Step 2: Islands Architecture (Client Directives)

```astro
---
import MyReactButton from './MyReactButton.jsx';
import MySvelteCounter from './MySvelteCounter.svelte';
---

<!-- Zero-JS (Static HTML) -->
<MyReactButton title="Native Button" />

<!-- Hydrate on page load -->
<MySvelteCounter client:load />

<!-- Hydrate when visible -->
<MyReactButton client:visible title="Interactive Button" />

<!-- Hydrate only for mobile -->
<MySvelteCounter client:media="(max-width: 50rem)" />
```

### Step 3: Content Collections & Markdown

```text
# src/content/config.ts
import { defineCollection, z } from 'astro:content';

const blog = defineCollection({
  schema: z.object({
    title: z.string(),
    pubDate: z.date(),
    description: z.string(),
    tags: z.array(z.string()),
  }),
});

export const collections = { blog };
```

```astro
---
// src/pages/blog/[slug].astro
import { getCollection } from 'astro:content';

export async function getStaticPaths() {
  const posts = await getCollection('blog');
  return posts.map(entry => ({
    params: { slug: entry.slug }, props: { entry },
  }));
}

const { entry } = Astro.props;
const { Content } = await entry.render();
---

<h1>{entry.data.title}</h1>
<Content />
```

### Step 4: Routing & SSR vs. Static

```javascript
// astro.config.mjs
import { defineConfig } from 'astro/config';
import node from '@astrojs/node';

export default defineConfig({
  output: 'server', // or 'hybrid' or 'static' (default)
  adapter: node({
    mode: 'standalone',
  }),
});
```

## Best Practices

### ✅ Do This

- ✅ Use `client:*` directives sparingly (stay zero-JS except where needed)
- ✅ Use Content Collections for type-safe Markdown/YAML
- ✅ Leverage `.astro` for most UI logic before reaching for frameworks
- ✅ Use `<slot />` for flexible component composition
- ✅ Use Image component for automatic optimization

### ❌ Avoid This

- ❌ Don't use `client:load` for everything (breaks the performance benefit)
- ❌ Don't put client-side state in `.astro` components (they are server-only)
- ❌ Don't ignore the difference between `src/pages/` and `src/components/`
- ❌ Don't skip type safety with Content Collections

## Related Skills

- `@svelte-developer` - Svelte integration
- `@senior-react-developer` - React integration
- `@headless-cms-specialist` - Content architecture

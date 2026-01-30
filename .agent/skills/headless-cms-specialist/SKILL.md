---
name: headless-cms-specialist
description: "Expert headless CMS integration including Contentful, Sanity, Strapi, and content-driven architecture"
---

# Headless CMS Specialist

## Overview

This skill helps you integrate and manage headless CMS systems for content-driven websites and applications.

## When to Use This Skill

- Use when integrating headless CMS
- Use when building content-driven sites
- Use when working with Contentful/Sanity/Strapi
- Use when designing content models

## How It Works

### Step 1: CMS Comparison

```
HEADLESS CMS OPTIONS
├── SANITY
│   ├── Real-time collaboration
│   ├── Custom React components
│   └── GROQ query language
│
├── CONTENTFUL
│   ├── Enterprise-grade
│   ├── GraphQL API
│   └── Extensive ecosystem
│
├── STRAPI
│   ├── Self-hosted option
│   ├── Open source
│   └── Customizable backend
│
└── PRISMIC
    ├── Slice-based content
    ├── Easy previews
    └── Good for marketing sites
```

### Step 2: Sanity Integration

```typescript
// sanity/client.ts
import { createClient } from '@sanity/client';

export const client = createClient({
  projectId: 'your-project-id',
  dataset: 'production',
  apiVersion: '2024-01-01',
  useCdn: true
});

// Fetch posts with GROQ
const posts = await client.fetch(`
  *[_type == "post"] | order(publishedAt desc) {
    title,
    slug,
    "author": author->name,
    "category": category->title,
    mainImage {
      asset-> { url }
    }
  }
`);

// Schema definition (sanity/schemas/post.ts)
export default {
  name: 'post',
  title: 'Blog Post',
  type: 'document',
  fields: [
    { name: 'title', type: 'string' },
    { name: 'slug', type: 'slug', options: { source: 'title' } },
    { name: 'content', type: 'blockContent' },
    { name: 'author', type: 'reference', to: [{ type: 'author' }] }
  ]
};
```

### Step 3: Contentful Integration

```typescript
import { createClient } from 'contentful';

const client = createClient({
  space: process.env.CONTENTFUL_SPACE_ID,
  accessToken: process.env.CONTENTFUL_ACCESS_TOKEN
});

// Fetch entries
const entries = await client.getEntries({
  content_type: 'blogPost',
  order: '-sys.createdAt',
  limit: 10
});

// GraphQL query
const query = `
  query {
    blogPostCollection(limit: 10) {
      items {
        title
        slug
        content { json }
        author { name }
      }
    }
  }
`;
```

### Step 4: Content Modeling

```markdown
## Content Model Design

### Blog Post
- title (Text)
- slug (Slug, from title)
- excerpt (Text, max 200)
- content (Rich Text)
- featuredImage (Image)
- author (Reference → Author)
- categories (References → Category[])
- publishedAt (DateTime)
- seoTitle (Text)
- seoDescription (Text)

### Author
- name (Text)
- bio (Text)
- avatar (Image)
- social (Object: twitter, linkedin)

### Category
- name (Text)
- slug (Slug)
- description (Text)
```

## Best Practices

### ✅ Do This

- ✅ Plan content model before building
- ✅ Use references for relationships
- ✅ Implement preview mode
- ✅ Set up webhooks for revalidation
- ✅ Use CDN for production

### ❌ Avoid This

- ❌ Don't over-nest content
- ❌ Don't skip content validation
- ❌ Don't ignore SEO fields

## Related Skills

- `@senior-nextjs-developer` - Next.js integration
- `@senior-technical-writer` - Content strategy

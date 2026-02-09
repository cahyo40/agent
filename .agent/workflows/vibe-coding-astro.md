---
description: Initialize Vibe Coding context files for Astro static/hybrid website with content-first approach
---

# /vibe-coding-astro

Workflow untuk setup dokumen konteks Vibe Coding khusus **Astro Website** (static, SSR, atau hybrid) dengan fokus pada content-first, zero-JS by default, dan island architecture.

---

## 📋 Prerequisites

Sebelum memulai, siapkan informasi berikut:

1. **Deskripsi website/aplikasi** (2-3 paragraf)
2. **Tipe rendering:**
   - 📄 Static (default) - Build time generation
   - ⚡ SSR - Server-side rendering
   - 🔄 Hybrid - Mix static + SSR
3. **UI Islands preference:**
   - Astro only (zero JS)
   - React islands
   - Vue islands
   - Svelte islands
   - Solid islands
4. **Content strategy:**
   - Markdown/MDX (built-in)
   - Headless CMS (Sanity/Contentful/Strapi)
   - Database
5. **Vibe/estetika** yang diinginkan

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
"Jelaskan website Astro yang ingin dibuat. Sertakan:
- Apa tujuan website ini?
- Siapa target audiencenya?
- Halaman apa saja yang dibutuhkan?
- Apakah perlu SSR atau static saja?"
```

Gunakan skill `senior-project-manager`:

```markdown
Act as senior-project-manager.
Saya ingin membuat website Astro: [IDE USER]

Buatkan file `PRD.md` yang mencakup:
1. Executive Summary (2-3 kalimat)
2. Website Goals & Objectives
3. Target Audience
4. Sitemap & Page Structure
5. Content Requirements per halaman
6. SEO Requirements (keywords, meta, structured data)
7. Performance Requirements (Core Web Vitals targets)
8. Success Metrics (Traffic, Bounce Rate, Conversion)

Output dalam Markdown yang rapi.
```

// turbo
**Simpan output ke file `PRD.md` di root project.**

---

### Step 1.2: Generate TECH_STACK.md

```
Tanyakan kepada user:
"Pilih preferensi:
1. Rendering: Static / SSR / Hybrid?
2. UI Framework untuk islands: None / React / Vue / Svelte?
3. Styling: Tailwind CSS / UnoCSS / Vanilla CSS?
4. Content: Markdown / MDX / Headless CMS?
5. Deployment: Vercel / Netlify / Cloudflare Pages?"
```

Gunakan skill `tech-stack-architect` + `astro-developer`:

```markdown
Act as tech-stack-architect dan astro-developer.
Buatkan file `TECH_STACK.md` untuk Astro website.

## Core Stack
- Framework: Astro 4.x
- Language: TypeScript (strict mode)
- Package Manager: pnpm (recommended)
- Node.js: 20 LTS

## Rendering Strategy
- Default: Static (prerendered at build time)
- Dynamic routes: On-demand rendering (jika SSR)
- Hybrid: Route-level configuration

## Content Strategy
- Content Collections: Built-in typed content
- Markdown/MDX: First-class support
- Optional CMS: [Sanity/Contentful/Strapi]

## UI Framework (Islands)
- Default: .astro components (zero JS)
- Interactive: [React/Vue/Svelte] dengan client directives
  - client:load - Load immediately
  - client:idle - Load when main thread idle
  - client:visible - Load when visible (IntersectionObserver)
  - client:media - Load for specific media query
  - client:only - Skip SSR, client-only

## Styling
- Framework: Tailwind CSS 3.4+
- Scope: CSS within `<style>` tags (scoped by default)
- Typography: @tailwindcss/typography

## Integrations
- @astrojs/tailwind
- @astrojs/sitemap
- @astrojs/image (or astro:assets)
- @astrojs/mdx (if using MDX)
- @astrojs/react (if using React islands)

## SEO & Performance
- View Transitions: Built-in
- Prefetching: Built-in
- Image optimization: Built-in (astro:assets)
- Sitemap: Auto-generated

## Hosting
- Adapter: @astrojs/vercel / @astrojs/netlify / @astrojs/cloudflare
- Static: Any static host

## Approved Packages (package.json)
```json
{
  "dependencies": {
    "astro": "^4.2.0",
    "@astrojs/tailwind": "^5.1.0",
    "@astrojs/sitemap": "^3.0.0",
    "@astrojs/mdx": "^2.0.0",
    "@astrojs/react": "^3.0.0",
    "react": "^18.2.0",
    "react-dom": "^18.2.0",
    "tailwindcss": "^3.4.0",
    "@tailwindcss/typography": "^0.5.0"
  },
  "devDependencies": {
    "@types/react": "^18.2.0",
    "typescript": "^5.3.0",
    "sharp": "^0.33.0"
  }
}
```

## Constraints

- Zero JS by default - only ship what's needed
- Images WAJIB pakai astro:assets untuk optimization
- Content Collections untuk typed content
- SEO meta tags di setiap page

```

// turbo
**Simpan output ke file `TECH_STACK.md` di root project.**

---

### Step 1.3: Generate RULES.md

Gunakan skill `astro-developer`:

```markdown
Act as astro-developer.
Buatkan file `RULES.md` sebagai panduan AI untuk Astro project.

## Astro Component Rules
- Default: .astro components (zero JavaScript)
- TypeScript dalam frontmatter (---...---)
- Props dengan Astro.props
- Slots untuk composition

## Island Architecture Rules
- Static content → .astro components
- Interactive needs → Framework islands
- client:load - Critical interactivity (above fold)
- client:idle - Non-critical interactivity
- client:visible - Below the fold content
- JANGAN add client directive tanpa alasan jelas

## Content Collection Rules
- Blog/docs dalam /content folder
- Typed schema dengan Zod
- Frontmatter validation
- getCollection() untuk querying

## Performance Rules
- Zero JS by default
- Images dengan astro:assets atau Image component
- Lazy load images below the fold
- Prefetch untuk navigation
- View Transitions untuk smooth navigation

## SEO Rules
- WAJIB <title> dan <meta name="description">
- Open Graph tags untuk social sharing
- Structured data (JSON-LD) untuk rich snippets
- Canonical URLs
- Sitemap generated

## Styling Rules
- Tailwind utilities
- Scoped styles dalam <style> tags
- CSS variables untuk theming
- Mobile-first responsive design

## File Organization Rules
- Pages di /pages (file-based routing)
- Layouts di /layouts
- Components di /components
- Content di /content
- Public assets di /public

## TypeScript Rules
- Props interfaces dalam frontmatter
- Type annotations untuk functions
- Infer types dari Content Collections

## AI Behavior Rules
1. JANGAN add client directive tanpa kebutuhan interactivity
2. PREFER .astro components over framework islands
3. SELALU add SEO meta tags
4. GUNAKAN Content Collections untuk blog/docs
5. IKUTI struktur folder di FOLDER_STRUCTURE.md
6. Refer ke DESIGN_SYSTEM.md untuk styling
7. OPTIMIZE images dengan astro:assets

## Workflow Rules
- Sebelum coding, jelaskan rencana dalam 3 bullet points
- Validasi dengan npm run build (no errors/warnings)
- Lighthouse score target: 90+ semua kategori
```

// turbo
**Simpan output ke file `RULES.md` di root project.**

---

## 🎨 Phase 2: Support System

### Step 2.1: Generate DESIGN_SYSTEM.md

```
Tanyakan kepada user:
"Jelaskan vibe/estetika website ini. Contoh:
- Modern & Minimalist
- Bold & Colorful
- Professional & Corporate
- Creative & Playful"
```

Gunakan skill `design-system-architect`:

```markdown
Act as design-system-architect.
Buatkan `DESIGN_SYSTEM.md` untuk Astro website dengan vibe: [VIBE USER]

## 1. Color Palette

### CSS Custom Properties
```css
/* src/styles/global.css */
:root {
  /* Brand Colors */
  --color-primary: #3b82f6;
  --color-primary-dark: #1d4ed8;
  --color-primary-light: #60a5fa;
  
  /* Neutrals */
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
  
  /* Background */
  --bg-primary: #ffffff;
  --bg-secondary: var(--color-gray-50);
  
  /* Text */
  --text-primary: var(--color-gray-900);
  --text-secondary: var(--color-gray-600);
  --text-muted: var(--color-gray-400);
}

/* Dark Mode */
@media (prefers-color-scheme: dark) {
  :root {
    --bg-primary: var(--color-gray-900);
    --bg-secondary: var(--color-gray-800);
    --text-primary: var(--color-gray-50);
    --text-secondary: var(--color-gray-300);
  }
}

/* Manual Dark Mode Toggle */
.dark {
  --bg-primary: var(--color-gray-900);
  --bg-secondary: var(--color-gray-800);
  --text-primary: var(--color-gray-50);
  --text-secondary: var(--color-gray-300);
}
```

## 2. Typography

### Font Setup

```astro
---
// layouts/BaseLayout.astro
---
<head>
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
</head>

<style is:global>
  body {
    font-family: 'Inter', system-ui, sans-serif;
  }
</style>
```

### Typography Scale

```css
/* Typography classes */
.text-display { @apply text-4xl font-bold tracking-tight sm:text-5xl lg:text-6xl; }
.text-h1 { @apply text-3xl font-bold tracking-tight sm:text-4xl; }
.text-h2 { @apply text-2xl font-semibold tracking-tight sm:text-3xl; }
.text-h3 { @apply text-xl font-semibold; }
.text-h4 { @apply text-lg font-medium; }
.text-body { @apply text-base leading-relaxed; }
.text-body-sm { @apply text-sm; }
.text-caption { @apply text-xs text-gray-500; }

/* Prose for content (using @tailwindcss/typography) */
.prose { @apply prose-lg prose-gray max-w-none; }
.prose h1 { @apply text-h1; }
.prose h2 { @apply text-h2; }
.prose h3 { @apply text-h3; }
```

## 3. Spacing System

```css
/* Tailwind default spacing scale */
/* 0: 0px, 1: 4px, 2: 8px, 4: 16px, 6: 24px, 8: 32px, 12: 48px, 16: 64px */

/* Container */
.container {
  @apply mx-auto max-w-7xl px-4 sm:px-6 lg:px-8;
}

/* Section spacing */
.section { @apply py-16 sm:py-24; }
.section-sm { @apply py-8 sm:py-12; }
```

## 4. Component Specifications

### Button

```astro
---
// components/Button.astro
interface Props {
  variant?: 'primary' | 'secondary' | 'outline' | 'ghost';
  size?: 'sm' | 'md' | 'lg';
  href?: string;
}

const { variant = 'primary', size = 'md', href } = Astro.props;

const baseClasses = 'inline-flex items-center justify-center font-medium rounded-lg transition-colors focus:outline-none focus:ring-2 focus:ring-offset-2';

const variantClasses = {
  primary: 'bg-primary text-white hover:bg-primary-dark focus:ring-primary',
  secondary: 'bg-gray-100 text-gray-900 hover:bg-gray-200 focus:ring-gray-500',
  outline: 'border-2 border-gray-300 hover:border-gray-400 focus:ring-gray-500',
  ghost: 'hover:bg-gray-100 focus:ring-gray-500',
};

const sizeClasses = {
  sm: 'h-9 px-3 text-sm',
  md: 'h-11 px-5 text-base',
  lg: 'h-13 px-8 text-lg',
};

const classes = `${baseClasses} ${variantClasses[variant]} ${sizeClasses[size]}`;
const Tag = href ? 'a' : 'button';
---

<Tag class={classes} href={href}>
  <slot />
</Tag>

<style>
  .bg-primary { background-color: var(--color-primary); }
  .hover\:bg-primary-dark:hover { background-color: var(--color-primary-dark); }
</style>
```

### Card

```astro
---
// components/Card.astro
interface Props {
  title?: string;
  description?: string;
  href?: string;
  image?: string;
}

const { title, description, href, image } = Astro.props;
---

<article class="group rounded-xl border border-gray-200 bg-white shadow-sm transition hover:shadow-md dark:border-gray-700 dark:bg-gray-800">
  {image && (
    <img 
      src={image} 
      alt={title || ''} 
      class="aspect-video w-full rounded-t-xl object-cover"
      loading="lazy"
    />
  )}
  <div class="p-6">
    {title && (
      <h3 class="text-xl font-semibold text-gray-900 dark:text-white">
        {href ? (
          <a href={href} class="hover:text-primary">
            {title}
            <span class="absolute inset-0" />
          </a>
        ) : title}
      </h3>
    )}
    {description && (
      <p class="mt-2 text-gray-600 dark:text-gray-300">{description}</p>
    )}
    <slot />
  </div>
</article>
```

### Hero Section

```astro
---
// components/Hero.astro
interface Props {
  title: string;
  subtitle?: string;
  cta?: { text: string; href: string };
  secondaryCta?: { text: string; href: string };
}

const { title, subtitle, cta, secondaryCta } = Astro.props;
---

<section class="relative py-20 sm:py-32">
  <div class="container text-center">
    <h1 class="text-display text-gray-900 dark:text-white">{title}</h1>
    {subtitle && (
      <p class="mx-auto mt-6 max-w-2xl text-lg text-gray-600 dark:text-gray-300">
        {subtitle}
      </p>
    )}
    {(cta || secondaryCta) && (
      <div class="mt-10 flex flex-col items-center justify-center gap-4 sm:flex-row">
        {cta && (
          <Button href={cta.href} size="lg">{cta.text}</Button>
        )}
        {secondaryCta && (
          <Button href={secondaryCta.href} variant="outline" size="lg">
            {secondaryCta.text}
          </Button>
        )}
      </div>
    )}
  </div>
</section>
```

## 5. Animation & Motion

### View Transitions (Built-in)

```astro
---
// layouts/BaseLayout.astro
import { ViewTransitions } from 'astro:transitions';
---

<head>
  <ViewTransitions />
</head>

<!-- Named transitions -->
<h1 transition:name="page-title">{title}</h1>
<img transition:name="hero-image" src={image} />
```

### CSS Animations

```css
/* Fade in on scroll */
@keyframes fade-in-up {
  from {
    opacity: 0;
    transform: translateY(20px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

.animate-fade-in-up {
  animation: fade-in-up 0.6s ease-out forwards;
}

/* Staggered animations */
.stagger-1 { animation-delay: 100ms; }
.stagger-2 { animation-delay: 200ms; }
.stagger-3 { animation-delay: 300ms; }
```

## 6. Responsive Design

### Breakpoints (Tailwind default)

```css
/* sm: 640px, md: 768px, lg: 1024px, xl: 1280px, 2xl: 1536px */

/* Mobile-first approach */
.grid-cards {
  @apply grid gap-6 sm:grid-cols-2 lg:grid-cols-3;
}

.flex-responsive {
  @apply flex flex-col md:flex-row;
}
```

## 7. Dark Mode

```astro
---
// components/ThemeToggle.astro (React island for interactivity)
---

<button
  id="theme-toggle"
  class="rounded-lg p-2 hover:bg-gray-100 dark:hover:bg-gray-800"
  aria-label="Toggle theme"
>
  <svg class="h-5 w-5 fill-current" ... />
</button>

<script>
  const toggle = document.getElementById('theme-toggle');
  
  toggle?.addEventListener('click', () => {
    document.documentElement.classList.toggle('dark');
    localStorage.setItem(
      'theme',
      document.documentElement.classList.contains('dark') ? 'dark' : 'light'
    );
  });
  
  // Load saved theme
  if (
    localStorage.theme === 'dark' ||
    (!localStorage.theme && window.matchMedia('(prefers-color-scheme: dark)').matches)
  ) {
    document.documentElement.classList.add('dark');
  }
</script>
```

```

// turbo
**Simpan output ke file `DESIGN_SYSTEM.md` di root project.**

---

### Step 2.2: Generate FOLDER_STRUCTURE.md

Gunakan skill `astro-developer`:

```markdown
## Astro Project Structure

```

/
├── public/
│   ├── fonts/                      # Custom fonts
│   ├── images/                     # Unprocessed images
│   ├── favicon.ico
│   ├── robots.txt
│   └── og-image.jpg                # Default OG image
│
├── src/
│   ├── assets/                     # Processed images
│   │   └── images/
│   │       ├── hero.jpg
│   │       └── team/
│   │
│   ├── components/
│   │   ├── common/                 # Reusable UI components
│   │   │   ├── Button.astro
│   │   │   ├── Card.astro
│   │   │   ├── Icon.astro
│   │   │   └── Image.astro
│   │   │
│   │   ├── sections/               # Page sections
│   │   │   ├── Hero.astro
│   │   │   ├── Features.astro
│   │   │   ├── Pricing.astro
│   │   │   ├── Testimonials.astro
│   │   │   ├── CTA.astro
│   │   │   └── FAQ.astro
│   │   │
│   │   ├── blog/                   # Blog components
│   │   │   ├── PostCard.astro
│   │   │   ├── PostList.astro
│   │   │   └── TableOfContents.astro
│   │   │
│   │   └── react/                  # React islands
│   │       ├── Counter.tsx
│   │       ├── SearchDialog.tsx
│   │       └── ContactForm.tsx
│   │
│   ├── content/
│   │   ├── config.ts               # Content collections schema
│   │   ├── blog/                   # Blog posts (markdown)
│   │   │   ├── post-1.md
│   │   │   └── post-2.mdx
│   │   ├── docs/                   # Documentation
│   │   └── authors/                # Author data
│   │
│   ├── layouts/
│   │   ├── BaseLayout.astro        # Root HTML structure
│   │   ├── PageLayout.astro        # Standard page
│   │   ├── BlogLayout.astro        # Blog post layout
│   │   └── DocsLayout.astro        # Docs layout
│   │
│   ├── pages/
│   │   ├── index.astro             # Home /
│   │   ├── about.astro             # About /about
│   │   ├── pricing.astro           # Pricing /pricing
│   │   ├── contact.astro           # Contact /contact
│   │   ├── blog/
│   │   │   ├── index.astro         # Blog list /blog
│   │   │   └── [...slug].astro     # Blog post /blog/:slug
│   │   ├── docs/
│   │   │   └── [...slug].astro     # Docs /docs/:slug
│   │   ├── api/                    # API endpoints (SSR)
│   │   │   └── contact.ts
│   │   ├── 404.astro               # Custom 404
│   │   └── rss.xml.ts              # RSS feed
│   │
│   ├── styles/
│   │   └── global.css              # Global styles & CSS variables
│   │
│   ├── lib/                        # Utilities
│   │   ├── utils.ts
│   │   └── constants.ts
│   │
│   └── types/
│       └── index.ts
│
├── astro.config.mjs
├── tailwind.config.mjs
├── tsconfig.json
└── package.json

```

## File Naming Conventions
- Astro components: `PascalCase.astro`
- React/Vue islands: `PascalCase.tsx` / `.vue`
- Pages: `kebab-case.astro`
- Content files: `kebab-case.md`
- API routes: `kebab-case.ts`

## Import Aliases
```json
// tsconfig.json
{
  "compilerOptions": {
    "baseUrl": ".",
    "paths": {
      "@/*": ["src/*"],
      "@/components/*": ["src/components/*"],
      "@/layouts/*": ["src/layouts/*"],
      "@/content/*": ["src/content/*"]
    }
  }
}
```

```

// turbo
**Simpan output ke file `FOLDER_STRUCTURE.md` di root project.**

---

### Step 2.3: Generate EXAMPLES.md

Gunakan skill `astro-developer`:

```markdown
Act as astro-developer.
Buatkan `EXAMPLES.md` berisi contoh kode Astro yang jadi standar project.

## 1. Astro Component with Props
```astro
---
// components/common/Card.astro
interface Props {
  title: string;
  description: string;
  href?: string;
  image?: ImageMetadata;
}

const { title, description, href, image } = Astro.props;

import { Image } from 'astro:assets';
---

<article class="group relative rounded-xl border border-gray-200 bg-white shadow-sm transition hover:shadow-md">
  {image && (
    <Image
      src={image}
      alt={title}
      class="aspect-video w-full rounded-t-xl object-cover"
      width={400}
      height={225}
    />
  )}
  <div class="p-6">
    <h3 class="text-xl font-semibold text-gray-900">
      {href ? (
        <a href={href} class="hover:text-primary after:absolute after:inset-0">
          {title}
        </a>
      ) : (
        title
      )}
    </h3>
    <p class="mt-2 text-gray-600">{description}</p>
    <slot />
  </div>
</article>

<style>
  article:hover h3 {
    color: var(--color-primary);
  }
</style>
```

## 2. Base Layout with SEO

```astro
---
// layouts/BaseLayout.astro
import { ViewTransitions } from 'astro:transitions';
import '@/styles/global.css';

interface Props {
  title: string;
  description?: string;
  image?: string;
  canonicalURL?: URL;
}

const {
  title,
  description = 'Default site description',
  image = '/og-image.jpg',
  canonicalURL = new URL(Astro.url.pathname, Astro.site),
} = Astro.props;

const siteTitle = `${title} | My Site`;
---

<!doctype html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <link rel="icon" type="image/x-icon" href="/favicon.ico" />
    
    <!-- SEO -->
    <title>{siteTitle}</title>
    <meta name="description" content={description} />
    <link rel="canonical" href={canonicalURL} />
    
    <!-- Open Graph -->
    <meta property="og:type" content="website" />
    <meta property="og:url" content={canonicalURL} />
    <meta property="og:title" content={siteTitle} />
    <meta property="og:description" content={description} />
    <meta property="og:image" content={new URL(image, Astro.site)} />
    
    <!-- Twitter -->
    <meta name="twitter:card" content="summary_large_image" />
    <meta name="twitter:title" content={siteTitle} />
    <meta name="twitter:description" content={description} />
    <meta name="twitter:image" content={new URL(image, Astro.site)} />
    
    <!-- Fonts -->
    <link rel="preconnect" href="https://fonts.googleapis.com" />
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin />
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet" />
    
    <ViewTransitions />
  </head>
  <body class="bg-white text-gray-900 antialiased dark:bg-gray-900 dark:text-gray-100">
    <slot name="header">
      <Header />
    </slot>
    
    <main>
      <slot />
    </main>
    
    <slot name="footer">
      <Footer />
    </slot>
  </body>
</html>
```

## 3. Content Collection Config

```typescript
// content/config.ts
import { defineCollection, z } from 'astro:content';

const blogCollection = defineCollection({
  type: 'content',
  schema: ({ image }) => z.object({
    title: z.string(),
    description: z.string(),
    pubDate: z.coerce.date(),
    updatedDate: z.coerce.date().optional(),
    author: z.string().default('Anonymous'),
    tags: z.array(z.string()).default([]),
    image: image().optional(),
    draft: z.boolean().default(false),
  }),
});

const authorsCollection = defineCollection({
  type: 'data',
  schema: ({ image }) => z.object({
    name: z.string(),
    bio: z.string(),
    avatar: image(),
    twitter: z.string().optional(),
    github: z.string().optional(),
  }),
});

export const collections = {
  blog: blogCollection,
  authors: authorsCollection,
};
```

## 4. Dynamic Blog Post Page

```astro
---
// pages/blog/[...slug].astro
import { getCollection } from 'astro:content';
import BlogLayout from '@/layouts/BlogLayout.astro';
import { Image } from 'astro:assets';

export async function getStaticPaths() {
  const posts = await getCollection('blog', ({ data }) => !data.draft);
  
  return posts.map((post) => ({
    params: { slug: post.slug },
    props: { post },
  }));
}

const { post } = Astro.props;
const { Content, headings } = await post.render();
---

<BlogLayout title={post.data.title} description={post.data.description}>
  <article class="container py-12">
    {post.data.image && (
      <Image
        src={post.data.image}
        alt={post.data.title}
        class="aspect-video w-full rounded-xl object-cover"
        transition:name={`blog-image-${post.slug}`}
      />
    )}
    
    <header class="mt-8">
      <h1 class="text-h1" transition:name={`blog-title-${post.slug}`}>
        {post.data.title}
      </h1>
      <div class="mt-4 flex items-center gap-4 text-gray-500">
        <time datetime={post.data.pubDate.toISOString()}>
          {post.data.pubDate.toLocaleDateString('en-US', {
            year: 'numeric',
            month: 'long',
            day: 'numeric',
          })}
        </time>
        <span>•</span>
        <span>{post.data.author}</span>
      </div>
    </header>
    
    <div class="prose mt-8">
      <Content />
    </div>
  </article>
</BlogLayout>
```

## 5. Blog List Page

```astro
---
// pages/blog/index.astro
import { getCollection } from 'astro:content';
import PageLayout from '@/layouts/PageLayout.astro';
import PostCard from '@/components/blog/PostCard.astro';

const posts = await getCollection('blog', ({ data }) => !data.draft);

// Sort by date (newest first)
const sortedPosts = posts.sort(
  (a, b) => b.data.pubDate.valueOf() - a.data.pubDate.valueOf()
);
---

<PageLayout title="Blog" description="Latest articles and insights">
  <section class="container py-12">
    <h1 class="text-h1">Blog</h1>
    <p class="mt-4 text-lg text-gray-600">
      Latest articles and insights
    </p>
    
    <div class="mt-12 grid gap-8 md:grid-cols-2 lg:grid-cols-3">
      {sortedPosts.map((post) => (
        <PostCard
          title={post.data.title}
          description={post.data.description}
          href={`/blog/${post.slug}`}
          image={post.data.image}
          date={post.data.pubDate}
          transition:name={`blog-card-${post.slug}`}
        />
      ))}
    </div>
  </section>
</PageLayout>
```

## 6. React Island (Interactive)

```tsx
// components/react/ContactForm.tsx
import { useState } from 'react';

export default function ContactForm() {
  const [status, setStatus] = useState<'idle' | 'loading' | 'success' | 'error'>('idle');

  async function handleSubmit(e: React.FormEvent<HTMLFormElement>) {
    e.preventDefault();
    setStatus('loading');

    const formData = new FormData(e.currentTarget);

    try {
      const response = await fetch('/api/contact', {
        method: 'POST',
        body: formData,
      });

      if (!response.ok) throw new Error('Failed to submit');
      setStatus('success');
    } catch (error) {
      setStatus('error');
    }
  }

  if (status === 'success') {
    return <p className="text-green-600">Thank you! We'll be in touch.</p>;
  }

  return (
    <form onSubmit={handleSubmit} className="space-y-4">
      <div>
        <label htmlFor="name" className="block text-sm font-medium">
          Name
        </label>
        <input
          type="text"
          name="name"
          id="name"
          required
          className="mt-1 w-full rounded-lg border p-2"
        />
      </div>
      
      <div>
        <label htmlFor="email" className="block text-sm font-medium">
          Email
        </label>
        <input
          type="email"
          name="email"
          id="email"
          required
          className="mt-1 w-full rounded-lg border p-2"
        />
      </div>
      
      <div>
        <label htmlFor="message" className="block text-sm font-medium">
          Message
        </label>
        <textarea
          name="message"
          id="message"
          rows={4}
          required
          className="mt-1 w-full rounded-lg border p-2"
        />
      </div>
      
      <button
        type="submit"
        disabled={status === 'loading'}
        className="rounded-lg bg-blue-600 px-4 py-2 text-white hover:bg-blue-700 disabled:opacity-50"
      >
        {status === 'loading' ? 'Sending...' : 'Send Message'}
      </button>
      
      {status === 'error' && (
        <p className="text-red-600">Something went wrong. Please try again.</p>
      )}
    </form>
  );
}
```

```astro
---
// Usage in Astro page
import ContactForm from '@/components/react/ContactForm';
---

<section class="container py-12">
  <h2 class="text-h2">Contact Us</h2>
  <div class="mt-8 max-w-xl">
    <!-- Load when visible for performance -->
    <ContactForm client:visible />
  </div>
</section>
```

## 7. API Endpoint (SSR)

```typescript
// pages/api/contact.ts
import type { APIRoute } from 'astro';

export const POST: APIRoute = async ({ request }) => {
  const formData = await request.formData();
  const name = formData.get('name');
  const email = formData.get('email');
  const message = formData.get('message');

  // Validate
  if (!name || !email || !message) {
    return new Response(JSON.stringify({ error: 'Missing required fields' }), {
      status: 400,
      headers: { 'Content-Type': 'application/json' },
    });
  }

  // Send email / save to database
  try {
    // await sendEmail({ name, email, message });
    
    return new Response(JSON.stringify({ success: true }), {
      status: 200,
      headers: { 'Content-Type': 'application/json' },
    });
  } catch (error) {
    return new Response(JSON.stringify({ error: 'Failed to send message' }), {
      status: 500,
      headers: { 'Content-Type': 'application/json' },
    });
  }
};
```

## 8. RSS Feed

```typescript
// pages/rss.xml.ts
import rss from '@astrojs/rss';
import { getCollection } from 'astro:content';
import type { APIContext } from 'astro';

export async function GET(context: APIContext) {
  const posts = await getCollection('blog', ({ data }) => !data.draft);
  
  return rss({
    title: 'My Site Blog',
    description: 'Latest articles and insights',
    site: context.site!,
    items: posts.map((post) => ({
      title: post.data.title,
      pubDate: post.data.pubDate,
      description: post.data.description,
      link: `/blog/${post.slug}/`,
    })),
  });
}
```

## 9. Optimized Image Component

```astro
---
// components/common/OptimizedImage.astro
import { Image } from 'astro:assets';
import type { ImageMetadata } from 'astro';

interface Props {
  src: ImageMetadata;
  alt: string;
  class?: string;
  loading?: 'lazy' | 'eager';
  widths?: number[];
}

const { 
  src, 
  alt, 
  class: className,
  loading = 'lazy',
  widths = [400, 800, 1200],
} = Astro.props;
---

<Image
  src={src}
  alt={alt}
  class={className}
  loading={loading}
  widths={widths}
  sizes="(max-width: 640px) 400px, (max-width: 1024px) 800px, 1200px"
  format="webp"
/>
```

## 10. 404 Page

```astro
---
// pages/404.astro
import PageLayout from '@/layouts/PageLayout.astro';
---

<PageLayout title="Page Not Found">
  <section class="container flex min-h-[60vh] flex-col items-center justify-center text-center">
    <h1 class="text-display">404</h1>
    <p class="mt-4 text-xl text-gray-600">Page not found</p>
    <a
      href="/"
      class="mt-8 inline-flex items-center rounded-lg bg-primary px-6 py-3 text-white hover:bg-primary-dark"
    >
      Go back home
    </a>
  </section>
</PageLayout>
```

```

// turbo
**Simpan output ke file `EXAMPLES.md` di root project.**

---

## ✅ Phase 3: Project Setup

### Step 3.1: Create Astro Project

// turbo

```bash
npm create astro@latest . -- --template basics --typescript strict --git false
```

### Step 3.2: Add Integrations

// turbo

```bash
npx astro add tailwind sitemap react
npm install @tailwindcss/typography sharp
```

### Step 3.3: Setup Content Collections

// turbo

```bash
mkdir -p src/content/blog src/content/docs src/content/authors
```

---

## 📁 Final Checklist

```
/project-root
├── PRD.md                 ✅ Holy Trinity
├── TECH_STACK.md          ✅ Holy Trinity
├── RULES.md               ✅ Holy Trinity
├── DESIGN_SYSTEM.md       ✅ Support System
├── FOLDER_STRUCTURE.md    ✅ Support System
├── EXAMPLES.md            ✅ Support System
├── astro.config.mjs       ✅ Project Config
├── tailwind.config.mjs    ✅ Tailwind Config
└── src/
    ├── content/config.ts  ✅ Content Collections
    ├── layouts/           ✅ Layouts
    ├── components/        ✅ Components
    └── pages/             ✅ Routes
```

---

## 💡 Astro-Specific Tips

### Magic Words untuk Prompts

- "Gunakan .astro component, bukan React"
- "Zero JS - tidak perlu client directive"
- "Hanya client:visible jika perlu interactive"
- "Pakai Content Collections untuk blog/docs"
- "Optimize image dengan astro:assets"
- "Tambahkan View Transitions untuk smooth nav"

### Client Directive Cheatsheet

| Directive | Use Case | Priority |
| --------- | -------- | -------- |
| `client:load` | Critical interactivity | High |
| `client:idle` | Non-critical, after page load | Medium |
| `client:visible` | Below the fold content | Low/Performance |
| `client:media` | Specific viewport sizes | Conditional |
| `client:only` | Client-only, skip SSR | Special |

### Common Mistakes to Avoid

| ❌ Jangan | ✅ Lakukan |
| --------- | --------- |
| client:load untuk semua | client:visible untuk below fold |
| React untuk static content | .astro components |
| img tag biasa | astro:assets / Image component |
| Skip SEO meta tags | WAJIB title, description, og:* |
| Inline CSS | Scoped styles atau Tailwind |

### Performance Checklist

| Item | Target | Status |
| ---- | ------ | ------ |
| Lighthouse Performance | 90+ | ☐ |
| First Contentful Paint | < 1.5s | ☐ |
| Largest Contentful Paint | < 2.5s | ☐ |
| Total Blocking Time | < 200ms | ☐ |
| Cumulative Layout Shift | < 0.1 | ☐ |

### Build Commands

```bash
# Development
npm run dev

# Production build
npm run build

# Preview production build
npm run preview

# Check for issues
npx astro check
```

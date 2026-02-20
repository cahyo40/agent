---
name: stitch-react-components
description: Converts Stitch designs into modular Vite and React components using system-level networking and AST-based validation with TypeScript interfaces and design token consistency.
allowed-tools:
  - "stitch*:*"
  - "mcp_stitch*"
  - "Bash"
  - "run_command"
  - "Read"
  - "Write"
  - "read_url_content"
---

# Stitch to React Components

## Overview

This skill transforms you into a frontend engineer who converts Stitch-generated HTML designs into production-ready React components with modular architecture, TypeScript type safety, Tailwind CSS styling, data/logic separation, and design token consistency.

## When to Use This Skill

- Use when converting Stitch designs to React components
- Use when creating modular component architectures from HTML
- Use when adding TypeScript type safety to generated code
- Use when extracting design tokens and maintaining consistency

You are a frontend engineer focused on transforming designs into clean React code. You follow a modular approach and use automated tools to ensure code quality.

## Prerequisites

- Access to the Stitch MCP Server
- A Stitch project with designed screens
- Node.js environment for validation
- Vite + React + TypeScript project setup

## Retrieval and Networking

1. **Namespace discovery**: The Stitch tools use prefix `mcp_stitch_`

2. **Metadata fetch**: Call `mcp_stitch_get_screen` to retrieve the design JSON with:
   - `projectId`: The project ID
   - `screenId`: The screen ID to convert

3. **Asset download**:
   - Use `read_url_content` to fetch from `htmlCode.downloadUrl`
   - Save to `temp/source.html` for processing

4. **Visual audit**: Check `screenshot.downloadUrl` to confirm the design intent and layout details

---

## Architectural Rules

### Modular Components

Break the design into independent files. Avoid large, single-file outputs.

```
src/
├── components/
│   ├── Header/
│   │   ├── Header.tsx
│   │   ├── Header.types.ts
│   │   └── index.ts
│   ├── Hero/
│   ├── FeatureCard/
│   └── Footer/
├── hooks/
│   └── useScrollPosition.ts
├── data/
│   └── mockData.ts
└── App.tsx
```

### Logic Isolation

Move event handlers and business logic into custom hooks in `src/hooks/`:

```typescript
// src/hooks/useContactForm.ts
import { useState } from 'react';

export function useContactForm() {
  const [formData, setFormData] = useState({ name: '', email: '' });
  const [isSubmitting, setIsSubmitting] = useState(false);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setIsSubmitting(true);
    // Submit logic
  };

  return { formData, setFormData, isSubmitting, handleSubmit };
}
```

### Data Decoupling

Move all static text, image URLs, and lists into `src/data/mockData.ts`:

```typescript
// src/data/mockData.ts
export const heroContent = {
  title: "Build Amazing Products",
  subtitle: "The platform for modern teams",
  ctaText: "Get Started",
  ctaLink: "/signup"
};

export const features = [
  {
    id: 1,
    icon: "rocket",
    title: "Fast Performance",
    description: "Lightning-fast load times"
  },
  // ...
];

export const navLinks = [
  { label: "Home", href: "/" },
  { label: "Features", href: "/features" },
  { label: "Pricing", href: "/pricing" },
];
```

### Type Safety

Every component must include a `Readonly` TypeScript interface:

```typescript
// src/components/FeatureCard/FeatureCard.types.ts
export interface FeatureCardProps {
  readonly icon: string;
  readonly title: string;
  readonly description: string;
  readonly className?: string;
}
```

```typescript
// src/components/FeatureCard/FeatureCard.tsx
import type { FeatureCardProps } from './FeatureCard.types';

export function FeatureCard({ 
  icon, 
  title, 
  description, 
  className = '' 
}: Readonly<FeatureCardProps>) {
  return (
    <div className={`p-6 rounded-xl bg-white shadow-sm ${className}`}>
      <span className="text-3xl">{icon}</span>
      <h3 className="mt-4 text-lg font-semibold">{title}</h3>
      <p className="mt-2 text-gray-600">{description}</p>
    </div>
  );
}
```

### Style Mapping

Extract the Tailwind config from the HTML `<head>` and maintain consistency:

1. Parse `<script>` tags for Tailwind config
2. Extract custom colors, fonts, spacing
3. Use theme-mapped Tailwind classes instead of arbitrary hex codes

**Bad:**

```tsx
<div className="bg-[#2563eb] text-[#ffffff]">
```

**Good:**

```tsx
<div className="bg-primary text-white">
```

---

## Execution Steps

### 1. Environment Setup

If starting fresh, create a new Vite project:

```bash
npm create vite@latest my-app -- --template react-ts
cd my-app
npm install
```

If `node_modules` is missing, run:

```bash
npm install
```

### 2. Extract Design Tokens

From the Stitch HTML, extract and create `tailwind.config.js`:

```javascript
/** @type {import('tailwindcss').Config} */
export default {
  content: ['./index.html', './src/**/*.{js,ts,jsx,tsx}'],
  theme: {
    extend: {
      colors: {
        primary: '#2563eb',
        'primary-hover': '#1d4ed8',
        secondary: '#64748b',
        background: '#f8fafc',
        surface: '#ffffff',
      },
      fontFamily: {
        sans: ['Inter', 'system-ui', 'sans-serif'],
      },
      borderRadius: {
        'card': '12px',
        'button': '8px',
      },
    },
  },
  plugins: [],
}
```

### 3. Create Data Layer

Create `src/data/mockData.ts` based on the design content:

```typescript
// Extract all text content from the HTML
export const siteData = {
  brand: {
    name: "Acme Corp",
    logo: "/logo.svg",
  },
  hero: {
    title: "Welcome to Acme",
    subtitle: "Building the future, today",
    primaryCta: "Get Started",
    secondaryCta: "Learn More",
  },
  // ... more sections
};
```

### 4. Component Drafting

For each visual section, create a component following this pattern:

```typescript
// src/components/Hero/Hero.tsx
import type { HeroProps } from './Hero.types';
import { heroContent } from '../../data/mockData';

export function Hero({ 
  title = heroContent.title,
  subtitle = heroContent.subtitle,
  ctaText = heroContent.ctaText,
}: Readonly<HeroProps>) {
  return (
    <section className="py-20 px-4 text-center bg-gradient-to-b from-primary/10 to-transparent">
      <h1 className="text-5xl font-bold text-gray-900">{title}</h1>
      <p className="mt-4 text-xl text-gray-600 max-w-2xl mx-auto">{subtitle}</p>
      <button className="mt-8 px-8 py-3 bg-primary text-white font-medium rounded-button hover:bg-primary-hover transition-colors">
        {ctaText}
      </button>
    </section>
  );
}
```

### 5. Application Wiring

Update `src/App.tsx` to render the components:

```typescript
import { Header } from './components/Header';
import { Hero } from './components/Hero';
import { Features } from './components/Features';
import { Footer } from './components/Footer';

function App() {
  return (
    <div className="min-h-screen bg-background">
      <Header />
      <main>
        <Hero />
        <Features />
      </main>
      <Footer />
    </div>
  );
}

export default App;
```

### 6. Quality Check

Run validation for each component:

```bash
# TypeScript type checking
npx tsc --noEmit

# ESLint
npm run lint

# Start dev server for visual verification
npm run dev
```

---

## Component Template

Use this as a base for new components:

```typescript
// src/components/[ComponentName]/[ComponentName].types.ts
export interface [ComponentName]Props {
  readonly className?: string;
  // Add component-specific props
}

// src/components/[ComponentName]/[ComponentName].tsx
import type { [ComponentName]Props } from './[ComponentName].types';

export function [ComponentName]({ 
  className = '' 
}: Readonly<[ComponentName]Props>) {
  return (
    <div className={className}>
      {/* Component content */}
    </div>
  );
}

// src/components/[ComponentName]/index.ts
export { [ComponentName] } from './[ComponentName]';
export type { [ComponentName]Props } from './[ComponentName].types';
```

---

## Architecture Checklist

Before considering a conversion complete, verify:

### Component Structure

- [ ] Each visual section is a separate component
- [ ] Components are in their own folders with types
- [ ] Index files export components properly

### Data Separation

- [ ] All text content in `mockData.ts`
- [ ] All image URLs in `mockData.ts`
- [ ] No hardcoded strings in components

### Type Safety

- [ ] Every component has a Props interface
- [ ] Props use `Readonly<>` wrapper
- [ ] No `any` types

### Styling

- [ ] Using Tailwind theme colors (not arbitrary values)
- [ ] Design tokens extracted to `tailwind.config.js`
- [ ] Responsive classes applied

### Code Quality

- [ ] TypeScript compiles without errors
- [ ] ESLint passes
- [ ] Dev server renders correctly

---

## Troubleshooting

| Issue | Solution |
|-------|----------|
| Fetch errors | Ensure the URL is quoted correctly |
| Type errors | Check that Props interface matches usage |
| Validation errors | Review missing interfaces or hardcoded styles |
| Missing styles | Verify Tailwind config has all custom values |
| Layout broken | Compare with Stitch screenshot for reference |

---

## Common Patterns

### Responsive Navigation

```typescript
export function Header() {
  const [isMenuOpen, setIsMenuOpen] = useState(false);

  return (
    <header className="sticky top-0 bg-white/80 backdrop-blur-md border-b">
      <div className="max-w-7xl mx-auto px-4 py-4 flex items-center justify-between">
        <Logo />
        
        {/* Desktop nav */}
        <nav className="hidden md:flex items-center gap-6">
          {navLinks.map(link => (
            <a key={link.href} href={link.href}>{link.label}</a>
          ))}
        </nav>

        {/* Mobile menu button */}
        <button 
          className="md:hidden"
          onClick={() => setIsMenuOpen(!isMenuOpen)}
        >
          <MenuIcon />
        </button>
      </div>

      {/* Mobile nav */}
      {isMenuOpen && (
        <nav className="md:hidden px-4 pb-4">
          {navLinks.map(link => (
            <a key={link.href} href={link.href} className="block py-2">
              {link.label}
            </a>
          ))}
        </nav>
      )}
    </header>
  );
}
```

### Card Grid

```typescript
export function FeatureGrid({ features }: Readonly<{ features: Feature[] }>) {
  return (
    <section className="py-16 px-4">
      <div className="max-w-6xl mx-auto grid gap-6 md:grid-cols-2 lg:grid-cols-3">
        {features.map(feature => (
          <FeatureCard key={feature.id} {...feature} />
        ))}
      </div>
    </section>
  );
}
```

### Form with Validation

```typescript
export function ContactForm() {
  const { formData, setFormData, isSubmitting, handleSubmit, errors } = useContactForm();

  return (
    <form onSubmit={handleSubmit} className="space-y-4 max-w-md mx-auto">
      <div>
        <label className="block text-sm font-medium mb-1">Email</label>
        <input
          type="email"
          value={formData.email}
          onChange={e => setFormData({ ...formData, email: e.target.value })}
          className={`w-full px-4 py-2 border rounded-button ${
            errors.email ? 'border-red-500' : 'border-gray-300'
          }`}
        />
        {errors.email && (
          <p className="mt-1 text-sm text-red-500">{errors.email}</p>
        )}
      </div>
      <button
        type="submit"
        disabled={isSubmitting}
        className="w-full py-3 bg-primary text-white rounded-button disabled:opacity-50"
      >
        {isSubmitting ? 'Sending...' : 'Send Message'}
      </button>
    </form>
  );
}
```

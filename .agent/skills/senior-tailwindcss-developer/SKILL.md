---
name: senior-tailwindcss-developer
description: "Expert Tailwind CSS development including utility-first styling, custom design systems, responsive design, and component patterns"
---

# Senior Tailwind CSS Developer

## Overview

This skill transforms you into a **Tailwind Architect**. You will move beyond "class soup" to building **Design Systems** with configuration, writing **Custom Plugins** for complex needs, managing **Dark Mode** stragegies, and optimizing for **Production Bundle Size**.

## When to Use This Skill

- Use when setting up a new Project Design System (`tailwind.config.js`)
- Use when converting Figma Design Tokens to Tailwind Theme
- Use when implementing Dark Mode (Class vs Media)
- Use when styling complex components (Slots, Variants)
- Use when debugging "Styles not applying" (JIT / Safelist)

---

## Part 1: Architecture & Configuration

Don't use arbitrary values (`w-[123px]`). Define a Theme.

### 1.1 Design Tokens (The Config)

```javascript
// tailwind.config.js
/** @type {import('tailwindcss').Config} */
module.exports = {
  content: ["./src/**/*.{ts,tsx}"],
  theme: {
    // Extend preserves defaults. Overwriting 'colors' deletes default colors!
    extend: {
      colors: {
        primary: {
          50: '#f0f9ff',
          500: '#0ea5e9', // Brand Color
          900: '#0c4a6e',
        },
        surface: 'var(--color-surface)', // CSS Variable for runtime theming
      },
      fontFamily: {
        sans: ['Inter', 'sans-serif'],
      },
      spacing: {
        '128': '32rem', // Custom large spacing
      }
    },
  },
  plugins: [],
}
```

### 1.2 CSS Variables for Theming

If you need dynamic themes (e.g., User selects "Blue" or "Red" theme), use CSS Variables mapping.

```css
/* globals.css */
:root {
  --color-primary: 14 165 233; /* RGB values */
}
.theme-red {
  --color-primary: 239 68 68;
}
```

```javascript
// tailwind.config.js
colors: {
  primary: 'rgb(var(--color-primary) / <alpha-value>)',
}
```

---

## Part 2: Component Patterns (`cva`)

Avoid "Class Soup" logic in JSX. Use **Class Variance Authority (CVA)**.

```typescript
import { cva, type VariantProps } from "class-variance-authority";
import { cn } from "@/lib/utils"; // clsx + tailwind-merge

const buttonVariants = cva(
  // Base classes (Always applied)
  "inline-flex items-center justify-center rounded-md font-medium transition-colors focus-visible:outline-none focus-visible:ring-2 disabled:opacity-50",
  {
    variants: {
      variant: {
        default: "bg-primary-500 text-white hover:bg-primary-600",
        outline: "border border-slate-200 hover:bg-slate-100",
        ghost: "hover:bg-slate-100 text-slate-900",
      },
      size: {
        sm: "h-9 px-3 text-xs",
        md: "h-11 px-8 text-sm",
        lg: "h-14 px-10 text-base",
      },
    },
    defaultVariants: {
      variant: "default",
      size: "md",
    },
  }
);

interface ButtonProps extends React.ButtonHTMLAttributes<HTMLButtonElement>,
  VariantProps<typeof buttonVariants> {}

export function Button({ className, variant, size, ...props }: ButtonProps) {
  return (
    <button 
      className={cn(buttonVariants({ variant, size, className }))} 
      {...props} 
    />
  );
}
```

---

## Part 3: Advanced Responsive Design

Mobile First. Always.

- **Bad**: `w-full md:w-1/2 lg:w-1/3 xl:hidden` (Hard to read logic).
- **Good**: `grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3` (Layout logic).

### 3.1 Container Queries (`@tailwindcss/container`)

Use when a component needs to adapt to its *parent*, not the *viewport*.

```html
<!-- Parent config -->
<div class="@container">
  <!-- Child adapts -->
  <div class="flex flex-col @lg:flex-row">
    <div class="w-full @lg:w-1/3">Sidebar</div>
    <div class="w-full @lg:w-2/3">Content</div>
  </div>
</div>
```

---

## Part 4: Custom Plugins

Encapsulate complex CSS logic (e.g., Scrollbar hiding, Typography).

```javascript
// tailwind.config.js
const plugin = require('tailwindcss/plugin')

module.exports = {
  plugins: [
    plugin(function({ addUtilities, theme }) {
      addUtilities({
        '.no-scrollbar': {
          /* Chrome, Safari and Opera */
          '&::-webkit-scrollbar': {
            display: 'none',
          },
          /* IE and Edge */
          '-ms-overflow-style': 'none',
          /* Firefox */
          'scrollbar-width': 'none',
        },
        '.text-shadow': {
          textShadow: '2px 2px 4px rgba(0, 0, 0, 0.1)',
        }
      })
    })
  ]
}
```

---

## Part 5: Dark Mode Best Practices

### 5.1 Strategy: 'class'

Avoid `media` strategy (System pref) if you want a toggle button.

```javascript
// tailwind.config.js
module.exports = {
  darkMode: 'class', // Look for 'dark' class on HTML tag
}
```

### 5.2 Implementation

```tsx
<div className="bg-white text-slate-900 dark:bg-slate-900 dark:text-white">
  <h1>Automatic Dark Mode</h1>
</div>
```

**Pro Tip**: Use a `bg-surface` color token that changes automatically.
`bg-surface` -> maps to `white` in light, `slate-900` in dark.
Then you don't need `dark:` prefix everywhere.

---

## Part 6: Best Practices Checklist

### ✅ Do This

- ✅ **Use `clsx` or `cn`**: For conditional classes. Template literals `${isStart ? 'block' : 'hidden'}` get messy.
- ✅ **Use `tailwind-merge`**: To safely override classes. `<Button className="bg-red-500">` should win over base `bg-blue-500`.
- ✅ **Group variants**: `hover:bg-blue-500 hover:text-white` -> VS Code extension sorts this.
- ✅ **Extract Components**: Don't repeat `px-4 py-2 rounded bg-blue-500` 50 times. Make a `<Button>`.

### ❌ Avoid This

- ❌ **`@apply` abuse**: Don't just recreate CSS classes in `@layer components`. Use React/Vue components instead. `btn { @apply ... }` is an anti-pattern in modern frameworks.
- ❌ **Dynamic Class Names**: `bg-${color}-500`. Tailwind JIT **CANNOT** scan this. It won't generate the CSS. Always use full strings: `const map = { red: 'bg-red-500' }`.

---

## Related Skills

- `@senior-react-developer` - Integration with CVA
- `@senior-nextjs-developer` - Server Components styling
- `@senior-ui-ux-designer` - Design Tokens source

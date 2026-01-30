---
name: senior-tailwindcss-developer
description: "Expert Tailwind CSS development including utility-first styling, custom design systems, responsive design, and component patterns"
---

# Senior Tailwind CSS Developer

## Overview

This skill transforms you into an experienced Tailwind CSS Developer who creates beautiful, responsive interfaces using utility-first CSS with custom design systems.

## When to Use This Skill

- Use when styling with Tailwind CSS
- Use when creating design systems
- Use when building responsive layouts
- Use when optimizing CSS for production

## How It Works

### Step 1: Core Utilities

```html
<!-- Layout & Spacing -->
<div class="flex items-center justify-between gap-4 p-6">
  <div class="w-1/2">Half width</div>
  <div class="flex-1">Flex grow</div>
</div>

<!-- Typography -->
<h1 class="text-4xl font-bold text-gray-900 dark:text-white">
  Heading
</h1>
<p class="text-base text-gray-600 leading-relaxed">
  Paragraph text
</p>

<!-- Colors & Background -->
<div class="bg-gradient-to-r from-blue-500 to-purple-600 text-white">
  Gradient background
</div>

<!-- Borders & Shadows -->
<div class="rounded-2xl border border-gray-200 shadow-lg">
  Card with shadow
</div>
```

### Step 2: Responsive Design

```html
<!-- Mobile-first responsive -->
<div class="
  grid 
  grid-cols-1 
  md:grid-cols-2 
  lg:grid-cols-3 
  xl:grid-cols-4 
  gap-6
">
  <div class="p-4 md:p-6 lg:p-8">
    Responsive padding
  </div>
</div>

<!-- Hide/Show by breakpoint -->
<div class="hidden md:block">Desktop only</div>
<div class="block md:hidden">Mobile only</div>
```

### Step 3: Custom Design System

```javascript
// tailwind.config.js
module.exports = {
  theme: {
    extend: {
      colors: {
        primary: {
          50: '#f0f9ff',
          500: '#3b82f6',
          600: '#2563eb',
          700: '#1d4ed8',
        },
        secondary: {
          500: '#8b5cf6',
        },
      },
      fontFamily: {
        sans: ['Inter', 'sans-serif'],
        display: ['Outfit', 'sans-serif'],
      },
      spacing: {
        '18': '4.5rem',
        '88': '22rem',
      },
      borderRadius: {
        '4xl': '2rem',
      },
    },
  },
  plugins: [
    require('@tailwindcss/forms'),
    require('@tailwindcss/typography'),
  ],
};
```

### Step 4: Component Patterns

```tsx
// Button Component
const Button = ({ variant = 'primary', size = 'md', children }) => {
  const variants = {
    primary: 'bg-primary-600 hover:bg-primary-700 text-white',
    secondary: 'bg-gray-100 hover:bg-gray-200 text-gray-900',
    outline: 'border-2 border-primary-600 text-primary-600 hover:bg-primary-50',
  };
  
  const sizes = {
    sm: 'px-3 py-1.5 text-sm',
    md: 'px-4 py-2 text-base',
    lg: 'px-6 py-3 text-lg',
  };
  
  return (
    <button className={`
      ${variants[variant]}
      ${sizes[size]}
      rounded-lg font-medium
      transition-colors duration-200
      focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-primary-500
      disabled:opacity-50 disabled:cursor-not-allowed
    `}>
      {children}
    </button>
  );
};

// Card Component
const Card = ({ children }) => (
  <div className="
    bg-white dark:bg-gray-800
    rounded-2xl
    border border-gray-200 dark:border-gray-700
    shadow-sm hover:shadow-md
    transition-shadow duration-200
    p-6
  ">
    {children}
  </div>
);
```

## Best Practices

### ✅ Do This

- ✅ Use design tokens in config
- ✅ Extract repeated patterns to components
- ✅ Use `@apply` sparingly
- ✅ Enable dark mode support
- ✅ Purge unused CSS in production

### ❌ Avoid This

- ❌ Don't mix Tailwind with custom CSS
- ❌ Don't use arbitrary values excessively
- ❌ Don't forget responsive testing

## Related Skills

- `@senior-react-developer` - React components
- `@senior-ui-ux-designer` - Design principles

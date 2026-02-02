---
name: ui-kit-developer
description: "Expert UI component library development like Bootstrap, Material UI, and reusable component systems"
---

# UI Kit Developer

## Overview

This skill transforms you into a **Component Library Architect**. You will master **Component Design**, **Design Token Systems**, **Documentation**, and **Package Publishing** for building production-ready UI kits.

## When to Use This Skill

- Use when building reusable component libraries
- Use when creating design systems
- Use when publishing UI packages to npm
- Use when implementing design tokens
- Use when building internal UI frameworks

---

## Part 1: Component Library Architecture

### 1.1 Project Structure

```
ui-kit/
├── src/
│   ├── components/
│   │   ├── Button/
│   │   │   ├── Button.tsx
│   │   │   ├── Button.styles.ts
│   │   │   ├── Button.test.tsx
│   │   │   ├── Button.stories.tsx
│   │   │   └── index.ts
│   │   └── index.ts
│   ├── tokens/
│   │   ├── colors.ts
│   │   ├── spacing.ts
│   │   └── typography.ts
│   ├── hooks/
│   └── index.ts
├── package.json
├── tsconfig.json
├── rollup.config.js
└── .storybook/
```

### 1.2 Export Pattern

```typescript
// src/components/Button/index.ts
export { Button } from './Button';
export type { ButtonProps } from './Button';

// src/components/index.ts
export * from './Button';
export * from './Input';
export * from './Modal';

// src/index.ts (main entry)
export * from './components';
export * from './tokens';
export * from './hooks';
```

---

## Part 2: Design Tokens

### 2.1 Token Structure

```typescript
// tokens/colors.ts
export const colors = {
  primary: {
    50: '#eff6ff',
    100: '#dbeafe',
    500: '#3b82f6',
    600: '#2563eb',
    900: '#1e3a8a',
  },
  gray: {
    50: '#f9fafb',
    100: '#f3f4f6',
    500: '#6b7280',
    900: '#111827',
  },
  semantic: {
    success: '#22c55e',
    error: '#ef4444',
    warning: '#f59e0b',
    info: '#3b82f6',
  },
} as const;
```

### 2.2 Spacing & Typography

```typescript
// tokens/spacing.ts
export const spacing = {
  px: '1px',
  0: '0',
  1: '0.25rem',   // 4px
  2: '0.5rem',    // 8px
  4: '1rem',      // 16px
  8: '2rem',      // 32px
} as const;

// tokens/typography.ts
export const typography = {
  fontFamily: {
    sans: 'Inter, system-ui, sans-serif',
    mono: 'Fira Code, monospace',
  },
  fontSize: {
    xs: ['0.75rem', { lineHeight: '1rem' }],
    sm: ['0.875rem', { lineHeight: '1.25rem' }],
    base: ['1rem', { lineHeight: '1.5rem' }],
    lg: ['1.125rem', { lineHeight: '1.75rem' }],
  },
} as const;
```

---

## Part 3: Component Design

### 3.1 Button Component

```typescript
import { forwardRef, ButtonHTMLAttributes } from 'react';
import { cva, type VariantProps } from 'class-variance-authority';

const buttonVariants = cva(
  'inline-flex items-center justify-center rounded-md font-medium transition-colors focus-visible:outline-none focus-visible:ring-2',
  {
    variants: {
      variant: {
        primary: 'bg-primary-600 text-white hover:bg-primary-700',
        secondary: 'bg-gray-100 text-gray-900 hover:bg-gray-200',
        outline: 'border border-gray-300 bg-transparent hover:bg-gray-100',
        ghost: 'hover:bg-gray-100',
        destructive: 'bg-red-600 text-white hover:bg-red-700',
      },
      size: {
        sm: 'h-8 px-3 text-sm',
        md: 'h-10 px-4 text-sm',
        lg: 'h-12 px-6 text-base',
      },
    },
    defaultVariants: {
      variant: 'primary',
      size: 'md',
    },
  }
);

export interface ButtonProps
  extends ButtonHTMLAttributes<HTMLButtonElement>,
    VariantProps<typeof buttonVariants> {
  loading?: boolean;
}

export const Button = forwardRef<HTMLButtonElement, ButtonProps>(
  ({ className, variant, size, loading, children, disabled, ...props }, ref) => {
    return (
      <button
        ref={ref}
        className={buttonVariants({ variant, size, className })}
        disabled={disabled || loading}
        {...props}
      >
        {loading && <Spinner className="mr-2 h-4 w-4" />}
        {children}
      </button>
    );
  }
);

Button.displayName = 'Button';
```

### 3.2 Compound Components

```typescript
// Card with compound pattern
export const Card = ({ children, className }: CardProps) => (
  <div className={cn('rounded-lg border bg-white shadow-sm', className)}>
    {children}
  </div>
);

Card.Header = ({ children, className }: CardHeaderProps) => (
  <div className={cn('border-b px-6 py-4', className)}>{children}</div>
);

Card.Body = ({ children, className }: CardBodyProps) => (
  <div className={cn('px-6 py-4', className)}>{children}</div>
);

Card.Footer = ({ children, className }: CardFooterProps) => (
  <div className={cn('border-t px-6 py-4', className)}>{children}</div>
);

// Usage
<Card>
  <Card.Header>Title</Card.Header>
  <Card.Body>Content</Card.Body>
  <Card.Footer>Actions</Card.Footer>
</Card>
```

---

## Part 4: Storybook Documentation

### 4.1 Story File

```typescript
// Button.stories.tsx
import type { Meta, StoryObj } from '@storybook/react';
import { Button } from './Button';

const meta: Meta<typeof Button> = {
  title: 'Components/Button',
  component: Button,
  tags: ['autodocs'],
  argTypes: {
    variant: {
      control: 'select',
      options: ['primary', 'secondary', 'outline', 'ghost', 'destructive'],
    },
    size: {
      control: 'select',
      options: ['sm', 'md', 'lg'],
    },
  },
};

export default meta;
type Story = StoryObj<typeof Button>;

export const Primary: Story = {
  args: {
    children: 'Button',
    variant: 'primary',
  },
};

export const AllVariants: Story = {
  render: () => (
    <div className="flex gap-4">
      <Button variant="primary">Primary</Button>
      <Button variant="secondary">Secondary</Button>
      <Button variant="outline">Outline</Button>
      <Button variant="ghost">Ghost</Button>
      <Button variant="destructive">Destructive</Button>
    </div>
  ),
};
```

---

## Part 5: Package Publishing

### 5.1 package.json

```json
{
  "name": "@company/ui-kit",
  "version": "1.0.0",
  "main": "dist/index.js",
  "module": "dist/index.mjs",
  "types": "dist/index.d.ts",
  "exports": {
    ".": {
      "import": "./dist/index.mjs",
      "require": "./dist/index.js",
      "types": "./dist/index.d.ts"
    },
    "./styles.css": "./dist/styles.css"
  },
  "files": ["dist"],
  "sideEffects": ["*.css"],
  "peerDependencies": {
    "react": "^18.0.0",
    "react-dom": "^18.0.0"
  }
}
```

### 5.2 Build with Rollup

```javascript
// rollup.config.js
import resolve from '@rollup/plugin-node-resolve';
import typescript from '@rollup/plugin-typescript';
import postcss from 'rollup-plugin-postcss';

export default {
  input: 'src/index.ts',
  output: [
    { file: 'dist/index.js', format: 'cjs' },
    { file: 'dist/index.mjs', format: 'esm' },
  ],
  plugins: [
    resolve(),
    typescript(),
    postcss({
      extract: 'styles.css',
      minimize: true,
    }),
  ],
  external: ['react', 'react-dom'],
};
```

---

## Part 6: Best Practices Checklist

### ✅ Do This

- ✅ **Peer Dependencies**: React should be peer, not bundled.
- ✅ **Tree Shakeable**: Export individual components.
- ✅ **Accessible by Default**: ARIA, keyboard navigation.

### ❌ Avoid This

- ❌ **Bundling React**: Causes version conflicts.
- ❌ **Hard-coded Styles**: Use tokens/CSS variables.
- ❌ **Missing TypeScript Types**: Always include .d.ts.

---

## Related Skills

- `@design-system-architect` - Full design systems
- `@senior-react-developer` - React patterns
- `@accessibility-specialist` - A11y compliance

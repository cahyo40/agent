---
name: design-system-architect
description: "Expert design system architecture including component libraries, design tokens, Storybook, and scalable UI patterns"
---

# Design System Architect

## Overview

Build and maintain scalable design systems with component libraries, tokens, and documentation.

## When to Use This Skill

- Use when building component libraries
- Use when creating design tokens
- Use when setting up Storybook

## How It Works

### Step 1: Design Tokens

```javascript
// tokens/colors.js
export const colors = {
  // Primitives (raw values)
  blue: {
    50: '#eff6ff',
    100: '#dbeafe',
    500: '#3b82f6',
    600: '#2563eb',
    900: '#1e3a8a',
  },
  
  // Semantic tokens (meaning-based)
  primary: {
    default: '{colors.blue.600}',
    hover: '{colors.blue.700}',
    active: '{colors.blue.800}',
  },
  
  background: {
    default: '#ffffff',
    subtle: '#f9fafb',
    muted: '#f3f4f6',
  },
  
  text: {
    primary: '#111827',
    secondary: '#6b7280',
    muted: '#9ca3af',
  },
};

// tokens/spacing.js
export const spacing = {
  0: '0',
  1: '0.25rem',  // 4px
  2: '0.5rem',   // 8px
  3: '0.75rem',  // 12px
  4: '1rem',     // 16px
  6: '1.5rem',   // 24px
  8: '2rem',     // 32px
};
```

### Step 2: Component Architecture

```tsx
// components/Button/Button.tsx
import { cva, type VariantProps } from 'class-variance-authority';

const buttonVariants = cva(
  'inline-flex items-center justify-center rounded-md font-medium transition-colors focus-visible:outline-none focus-visible:ring-2',
  {
    variants: {
      variant: {
        primary: 'bg-primary-600 text-white hover:bg-primary-700',
        secondary: 'bg-gray-100 text-gray-900 hover:bg-gray-200',
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

interface ButtonProps extends VariantProps<typeof buttonVariants> {
  children: React.ReactNode;
  loading?: boolean;
  disabled?: boolean;
  onClick?: () => void;
}

export function Button({ variant, size, children, loading, disabled, ...props }: ButtonProps) {
  return (
    <button
      className={buttonVariants({ variant, size })}
      disabled={disabled || loading}
      {...props}
    >
      {loading && <Spinner className="mr-2" />}
      {children}
    </button>
  );
}
```

### Step 3: Storybook Setup

```tsx
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
      options: ['primary', 'secondary', 'ghost', 'destructive'],
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
      <Button variant="ghost">Ghost</Button>
      <Button variant="destructive">Destructive</Button>
    </div>
  ),
};
```

### Step 4: Component Library Structure

```text
design-system/
├── tokens/
│   ├── colors.ts
│   ├── spacing.ts
│   ├── typography.ts
│   └── index.ts
├── components/
│   ├── Button/
│   │   ├── Button.tsx
│   │   ├── Button.stories.tsx
│   │   ├── Button.test.tsx
│   │   └── index.ts
│   ├── Input/
│   └── Card/
├── hooks/
├── utils/
├── .storybook/
└── package.json
```

## Best Practices

- ✅ Use semantic token names
- ✅ Document all variants
- ✅ Write component tests
- ❌ Don't skip accessibility
- ❌ Don't create one-off components

## Related Skills

- `@senior-react-developer`
- `@senior-tailwindcss-developer`

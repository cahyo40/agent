---
name: ui-kit-developer
description: "Expert UI component library development like Bootstrap, Material UI, and reusable component systems"
---

# UI Kit Developer

## Overview

Build reusable UI component libraries and CSS frameworks like Bootstrap or Material UI.

## When to Use This Skill

- Use when creating component libraries
- Use when building UI frameworks

## How It Works

### Step 1: Component Architecture

```markdown
## UI Kit Structure

ui-kit/
├── src/
│   ├── components/
│   │   ├── Button/
│   │   │   ├── Button.tsx
│   │   │   ├── Button.styles.ts
│   │   │   ├── Button.test.tsx
│   │   │   └── index.ts
│   │   ├── Input/
│   │   ├── Card/
│   │   └── Modal/
│   ├── styles/
│   │   ├── variables.css
│   │   ├── reset.css
│   │   └── utilities.css
│   └── index.ts
├── dist/
└── package.json
```

### Step 2: Base Button Component

```tsx
// Button.tsx
import React from 'react';
import styled from 'styled-components';

type ButtonVariant = 'primary' | 'secondary' | 'outline' | 'ghost';
type ButtonSize = 'sm' | 'md' | 'lg';

interface ButtonProps extends React.ButtonHTMLAttributes<HTMLButtonElement> {
  variant?: ButtonVariant;
  size?: ButtonSize;
  fullWidth?: boolean;
  loading?: boolean;
  leftIcon?: React.ReactNode;
  rightIcon?: React.ReactNode;
}

const StyledButton = styled.button<ButtonProps>`
  display: inline-flex;
  align-items: center;
  justify-content: center;
  gap: 8px;
  border-radius: 8px;
  font-weight: 500;
  cursor: pointer;
  transition: all 0.2s;
  
  /* Size variants */
  padding: ${({ size }) => ({
    sm: '8px 16px',
    md: '12px 24px',
    lg: '16px 32px'
  }[size || 'md'])};
  
  font-size: ${({ size }) => ({
    sm: '14px',
    md: '16px',
    lg: '18px'
  }[size || 'md'])};
  
  /* Color variants */
  ${({ variant }) => {
    switch (variant) {
      case 'primary':
        return `
          background: #3b82f6;
          color: white;
          border: none;
          &:hover { background: #2563eb; }
        `;
      case 'secondary':
        return `
          background: #6b7280;
          color: white;
          border: none;
          &:hover { background: #4b5563; }
        `;
      case 'outline':
        return `
          background: transparent;
          color: #3b82f6;
          border: 2px solid #3b82f6;
          &:hover { background: #eff6ff; }
        `;
      case 'ghost':
        return `
          background: transparent;
          color: #3b82f6;
          border: none;
          &:hover { background: #f3f4f6; }
        `;
    }
  }}
  
  width: ${({ fullWidth }) => fullWidth ? '100%' : 'auto'};
  
  &:disabled {
    opacity: 0.5;
    cursor: not-allowed;
  }
`;

export const Button: React.FC<ButtonProps> = ({
  children,
  variant = 'primary',
  size = 'md',
  loading,
  leftIcon,
  rightIcon,
  disabled,
  ...props
}) => {
  return (
    <StyledButton
      variant={variant}
      size={size}
      disabled={disabled || loading}
      {...props}
    >
      {loading && <Spinner size={size} />}
      {!loading && leftIcon}
      {children}
      {!loading && rightIcon}
    </StyledButton>
  );
};
```

### Step 3: CSS Variables System

```css
/* variables.css */
:root {
  /* Colors */
  --color-primary-50: #eff6ff;
  --color-primary-100: #dbeafe;
  --color-primary-500: #3b82f6;
  --color-primary-600: #2563eb;
  --color-primary-700: #1d4ed8;
  
  --color-gray-50: #f9fafb;
  --color-gray-100: #f3f4f6;
  --color-gray-500: #6b7280;
  --color-gray-900: #111827;
  
  --color-success: #10b981;
  --color-warning: #f59e0b;
  --color-error: #ef4444;
  
  /* Spacing */
  --space-1: 4px;
  --space-2: 8px;
  --space-3: 12px;
  --space-4: 16px;
  --space-6: 24px;
  --space-8: 32px;
  
  /* Typography */
  --font-sans: 'Inter', system-ui, sans-serif;
  --font-size-sm: 14px;
  --font-size-base: 16px;
  --font-size-lg: 18px;
  --font-size-xl: 20px;
  
  /* Border Radius */
  --radius-sm: 4px;
  --radius-md: 8px;
  --radius-lg: 12px;
  --radius-full: 9999px;
  
  /* Shadows */
  --shadow-sm: 0 1px 2px rgba(0,0,0,0.05);
  --shadow-md: 0 4px 6px rgba(0,0,0,0.1);
  --shadow-lg: 0 10px 15px rgba(0,0,0,0.1);
}
```

### Step 4: Utility Classes

```css
/* utilities.css */

/* Flexbox */
.flex { display: flex; }
.flex-col { flex-direction: column; }
.items-center { align-items: center; }
.justify-center { justify-content: center; }
.justify-between { justify-content: space-between; }
.gap-2 { gap: var(--space-2); }
.gap-4 { gap: var(--space-4); }

/* Spacing */
.m-0 { margin: 0; }
.m-2 { margin: var(--space-2); }
.p-2 { padding: var(--space-2); }
.p-4 { padding: var(--space-4); }

/* Typography */
.text-sm { font-size: var(--font-size-sm); }
.text-lg { font-size: var(--font-size-lg); }
.font-bold { font-weight: 700; }
.text-center { text-align: center; }

/* Colors */
.text-primary { color: var(--color-primary-500); }
.bg-primary { background: var(--color-primary-500); }
```

### Step 5: NPM Package Setup

```json
{
  "name": "@myorg/ui-kit",
  "version": "1.0.0",
  "main": "dist/index.js",
  "module": "dist/index.esm.js",
  "types": "dist/index.d.ts",
  "files": ["dist"],
  "scripts": {
    "build": "rollup -c",
    "storybook": "storybook dev -p 6006"
  },
  "peerDependencies": {
    "react": "^18.0.0",
    "react-dom": "^18.0.0"
  }
}
```

## Best Practices

- ✅ Use CSS variables for theming
- ✅ Support all component states
- ✅ Write comprehensive docs
- ❌ Don't break API compatibility
- ❌ Don't skip accessibility

## Related Skills

- `@design-system-architect`
- `@senior-react-developer`

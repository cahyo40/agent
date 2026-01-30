---
name: illustration-creator
description: "Expert SVG illustration and icon design including vector graphics, icon systems, and illustration styles"
---

# Illustration Creator

## Overview

Create SVG illustrations, icon systems, and vector graphics for web and mobile.

## When to Use This Skill

- Use when creating custom icons
- Use when designing illustrations
- Use when building icon systems

## How It Works

### Step 1: Icon Design Principles

```markdown
## Icon Guidelines

### Grid System
- Canvas: 24x24px (standard)
- Safe area: 2px padding
- Stroke width: 1.5-2px
- Corner radius: 2px

### Consistency Rules
- Same stroke width throughout
- Consistent corner radius
- Optical alignment (not mathematical)
- Pixel-perfect alignment

### Icon Sizes
| Size | Use Case |
|------|----------|
| 16px | Inline text, dense UI |
| 20px | Buttons, inputs |
| 24px | Standard UI |
| 32px | Feature icons |
| 48px+ | Empty states |
```

### Step 2: SVG Icon Template

```svg
<!-- Optimized SVG Icon -->
<svg 
  width="24" 
  height="24" 
  viewBox="0 0 24 24" 
  fill="none" 
  xmlns="http://www.w3.org/2000/svg"
>
  <!-- Use currentColor for theming -->
  <path 
    d="M12 2L2 7l10 5 10-5-10-5z" 
    stroke="currentColor" 
    stroke-width="2" 
    stroke-linecap="round" 
    stroke-linejoin="round"
  />
</svg>
```

### Step 3: React Icon Component

```tsx
interface IconProps {
  size?: number;
  color?: string;
  className?: string;
}

export function HomeIcon({ size = 24, color = 'currentColor', className }: IconProps) {
  return (
    <svg
      width={size}
      height={size}
      viewBox="0 0 24 24"
      fill="none"
      className={className}
    >
      <path
        d="M3 9l9-7 9 7v11a2 2 0 01-2 2H5a2 2 0 01-2-2V9z"
        stroke={color}
        strokeWidth={2}
        strokeLinecap="round"
        strokeLinejoin="round"
      />
    </svg>
  );
}
```

### Step 4: Illustration Styles

```markdown
## Common Illustration Styles

### Flat Design
- No gradients or shadows
- Bold, solid colors
- Simple geometric shapes
- Clean outlines

### Isometric
- 30° angle perspective
- No vanishing point
- Consistent line weight
- 3D depth without perspective

### Hand-Drawn
- Organic, imperfect lines
- Texture overlays
- Warm, friendly feel
- Sketch-like quality

### Gradient/Modern
- Smooth color transitions
- Soft shadows
- Depth through layering
- Contemporary aesthetic
```

### Step 5: SVG Optimization

```javascript
// SVGO config
module.exports = {
  plugins: [
    'preset-default',
    'removeDimensions',
    {
      name: 'removeAttrs',
      params: { attrs: '(stroke-width|fill)' }
    },
    {
      name: 'addAttributesToSVGElement',
      params: {
        attributes: [{ fill: 'currentColor' }]
      }
    }
  ]
};
```

## Best Practices

- ✅ Use viewBox for scalability
- ✅ Use currentColor for theming
- ✅ Optimize SVG file size
- ❌ Don't use raster images
- ❌ Don't hardcode colors

## Related Skills

- `@generative-art-creator`
- `@brand-designer`

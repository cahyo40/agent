---
name: figma-specialist
description: "Expert Figma workflow including components, auto-layout, variants, plugins, and design-to-code handoff"
---

# Figma Specialist

## Overview

Master Figma for design systems, components, prototyping, and developer handoff.

## When to Use This Skill

- Use when creating Figma components
- Use when setting up design systems
- Use when preparing dev handoff

## How It Works

### Step 1: Component Structure

```markdown
## Component Naming Convention

### Layer Naming
Button / Primary / Default
Button / Primary / Hover
Button / Secondary / Default

### Variants Structure
Property: Variant

Example Button Variants:
- Variant: Primary, Secondary, Ghost
- Size: Small, Medium, Large
- State: Default, Hover, Disabled

### Auto-Layout Settings
- Horizontal padding: 16px
- Vertical padding: 12px
- Gap: 8px
- Alignment: Center
```

### Step 2: Design Tokens in Figma

```markdown
## Variables Setup

### Color Variables
Collection: Primitives
├── Blue/50: #eff6ff
├── Blue/500: #3b82f6
├── Blue/600: #2563eb
└── Gray/900: #111827

Collection: Semantic
├── Primary/Default: Blue/600
├── Primary/Hover: Blue/700
├── Background/Default: White
└── Text/Primary: Gray/900

### Spacing Variables
├── space-1: 4px
├── space-2: 8px
├── space-4: 16px
└── space-6: 24px

### Typography Variables
├── font-size-sm: 14px
├── font-size-base: 16px
├── font-size-lg: 18px
└── line-height-normal: 1.5
```

### Step 3: Auto-Layout Best Practices

```markdown
## Auto-Layout Patterns

### Card Component
Frame (Auto-layout: Vertical)
├── Image (Fixed height)
├── Content (Auto-layout: Vertical, Fill)
│   ├── Title (Hug)
│   ├── Description (Fill)
│   └── Actions (Auto-layout: Horizontal)
└── Padding: 16px, Gap: 12px

### Responsive Behavior
- Fixed: Icons, avatars
- Hug: Text, buttons with text
- Fill: Containers, flexible content

### Constraints
- Left & Right: Stretch horizontally
- Top & Bottom: Stretch vertically
- Center: Maintain position
```

### Step 4: Dev Handoff

```markdown
## Developer Handoff Checklist

### Before Handoff
- [ ] All layers named properly
- [ ] Components used consistently
- [ ] Variables applied (not hard-coded)
- [ ] Responsive behavior defined
- [ ] States documented

### Export Settings
- Icons: SVG, 1x
- Images: PNG, @1x @2x @3x
- Illustrations: SVG

### Documentation
- Component specs in description
- Interaction notes
- Animation specs
```

## Best Practices

- ✅ Use components, not copies
- ✅ Apply variables consistently
- ✅ Name layers meaningfully
- ❌ Don't use absolute positioning
- ❌ Don't skip variants

## Related Skills

- `@senior-ui-ux-designer`
- `@design-system-architect`

# Architecture Checklist for Stitch to React Conversion

Use this checklist to verify the quality of converted React components.

## Component Structure

### File Organization

- [ ] Each visual section is a separate component
- [ ] Components are in their own folders (`ComponentName/`)
- [ ] Each component folder contains:
  - [ ] `ComponentName.tsx` - Main component
  - [ ] `ComponentName.types.ts` - TypeScript interfaces
  - [ ] `index.ts` - Barrel export
- [ ] Related components are grouped logically

### Naming Conventions

- [ ] Component names are PascalCase
- [ ] File names match component names
- [ ] Props interfaces are named `{ComponentName}Props`
- [ ] Hook names start with `use`

---

## Data Separation

### Mock Data (`src/data/mockData.ts`)

- [ ] All text content extracted to data file
- [ ] All image URLs extracted to data file
- [ ] All navigation links extracted to data file
- [ ] Arrays properly typed with interfaces
- [ ] Data is organized by section/feature

### No Hardcoded Content

- [ ] No hardcoded strings in component JSX
- [ ] No inline image URLs
- [ ] Exception: Structural text like "Loading..." is acceptable

---

## Type Safety

### Props Interfaces

- [ ] Every component has a Props interface
- [ ] Props interface is in a separate `.types.ts` file
- [ ] Props use `Readonly<Props>` wrapper
- [ ] Optional props marked with `?`
- [ ] Default values provided for optional props

### Type Quality

- [ ] No `any` types used
- [ ] No `@ts-ignore` comments
- [ ] All event handlers properly typed
- [ ] Children prop uses `ReactNode` type

---

## Styling

### Tailwind Usage

- [ ] Using Tailwind theme colors (e.g., `bg-primary`)
- [ ] NOT using arbitrary values (e.g., `bg-[#2563eb]`)
- [ ] Design tokens extracted to `tailwind.config.js`
- [ ] Custom colors defined in theme extend

### Responsiveness

- [ ] Mobile breakpoints applied (`sm:`, `md:`, `lg:`)
- [ ] Layouts adapt appropriately
- [ ] Touch targets are adequate on mobile (min 44px)
- [ ] Text is readable at all sizes

### Consistency

- [ ] Spacing follows design system
- [ ] Border radius matches design tokens
- [ ] Typography weights are consistent
- [ ] Colors match the original design

---

## Code Quality

### Build Verification

- [ ] TypeScript compiles without errors (`npx tsc --noEmit`)
- [ ] ESLint passes (`npm run lint`)
- [ ] No console warnings in dev mode

### Visual Verification

- [ ] Dev server renders correctly (`npm run dev`)
- [ ] Layout matches Stitch screenshot
- [ ] Colors match original design
- [ ] Typography matches original design
- [ ] Spacing matches original design

### Best Practices

- [ ] Components are focused (single responsibility)
- [ ] Logic is isolated in hooks
- [ ] No unnecessary re-renders
- [ ] Keys provided for list items
- [ ] Semantic HTML elements used

---

## Logic Isolation

### Custom Hooks

- [ ] Form logic in custom hooks
- [ ] API calls in custom hooks
- [ ] State management in custom hooks
- [ ] Complex event handlers in hooks

### Hook Location

- [ ] Hooks are in `src/hooks/` directory
- [ ] Hook files named `use{HookName}.ts`
- [ ] Hooks are exported properly

---

## Accessibility

### Semantic HTML

- [ ] Using appropriate heading hierarchy
- [ ] Using `<button>` for buttons, not `<div>`
- [ ] Using `<a>` for links
- [ ] Using `<nav>` for navigation
- [ ] Using `<main>` for main content

### ARIA & Labels

- [ ] Interactive elements have accessible names
- [ ] Images have alt text
- [ ] Form inputs have labels
- [ ] Icons have aria-labels or sr-only text

### Keyboard Navigation

- [ ] All interactive elements focusable
- [ ] Focus indicators visible
- [ ] No keyboard traps

---

## Final Verification

### Before Delivery

- [ ] All checklist items above completed
- [ ] Visual diff against Stitch screenshot is acceptable
- [ ] Code is clean and readable
- [ ] No TODO comments left
- [ ] README updated if needed

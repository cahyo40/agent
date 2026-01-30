---
name: accessibility-specialist
description: "Expert web accessibility including WCAG compliance, a11y testing, screen reader compatibility, and inclusive design"
---

# Accessibility Specialist

## Overview

This skill helps you build accessible web applications that work for everyone, including users with disabilities.

## When to Use This Skill

- Use when building accessible interfaces
- Use when auditing for WCAG compliance
- Use when testing with screen readers
- Use when implementing inclusive design

## How It Works

### Step 1: WCAG Principles (POUR)

```
WCAG 2.1 PRINCIPLES
├── PERCEIVABLE
│   ├── Text alternatives for images
│   ├── Captions for videos
│   └── Sufficient color contrast
│
├── OPERABLE
│   ├── Keyboard accessible
│   ├── Enough time to interact
│   └── No seizure-inducing content
│
├── UNDERSTANDABLE
│   ├── Readable content
│   ├── Predictable navigation
│   └── Helpful error messages
│
└── ROBUST
    ├── Valid HTML
    ├── Compatible with assistive tech
    └── Proper ARIA usage
```

### Step 2: Semantic HTML

```html
<!-- ❌ Bad: Divs everywhere -->
<div class="header">
  <div class="nav">
    <div onclick="navigate()">Home</div>
  </div>
</div>

<!-- ✅ Good: Semantic elements -->
<header>
  <nav aria-label="Main navigation">
    <ul>
      <li><a href="/">Home</a></li>
      <li><a href="/about">About</a></li>
    </ul>
  </nav>
</header>

<!-- ✅ Good: Form accessibility -->
<form>
  <label for="email">Email address</label>
  <input 
    type="email" 
    id="email" 
    aria-describedby="email-hint"
    required
  />
  <p id="email-hint">We'll never share your email</p>
  
  <button type="submit">Subscribe</button>
</form>
```

### Step 3: ARIA Best Practices

```html
<!-- Landmarks -->
<main role="main" aria-label="Main content">
  <section aria-labelledby="section-heading">
    <h2 id="section-heading">Products</h2>
  </section>
</main>

<!-- Live regions (for dynamic content) -->
<div aria-live="polite" aria-atomic="true">
  {statusMessage}
</div>

<!-- Modal dialog -->
<div 
  role="dialog"
  aria-modal="true"
  aria-labelledby="dialog-title"
>
  <h2 id="dialog-title">Confirm Action</h2>
</div>

<!-- Custom components -->
<button
  aria-expanded={isOpen}
  aria-controls="dropdown-menu"
>
  Menu
</button>
<ul id="dropdown-menu" hidden={!isOpen}>
  ...
</ul>
```

### Step 4: Testing Checklist

```markdown
## Accessibility Testing Checklist

### Keyboard Navigation
- [ ] All interactive elements focusable
- [ ] Visible focus indicator
- [ ] Logical tab order
- [ ] No keyboard traps
- [ ] Esc closes modals

### Screen Reader
- [ ] Images have alt text
- [ ] Form fields have labels
- [ ] Headings are logical (h1→h2→h3)
- [ ] Links are descriptive
- [ ] Error messages announced

### Visual
- [ ] Color contrast ≥4.5:1 (text)
- [ ] Color contrast ≥3:1 (UI elements)
- [ ] Not relying on color alone
- [ ] Text resizable to 200%
- [ ] No horizontal scroll at 320px

### Tools
- axe DevTools (browser extension)
- WAVE (wave.webaim.org)
- Lighthouse accessibility audit
- VoiceOver (Mac) / NVDA (Windows)
```

## Best Practices

### ✅ Do This

- ✅ Start with semantic HTML
- ✅ Test with keyboard only
- ✅ Use real screen readers
- ✅ Add skip links
- ✅ Provide alt text

### ❌ Avoid This

- ❌ Don't use divs for buttons
- ❌ Don't disable focus outline
- ❌ Don't auto-play media
- ❌ Don't use ARIA incorrectly

## Related Skills

- `@senior-ui-ux-designer` - Inclusive design
- `@ux-writer` - Clear content

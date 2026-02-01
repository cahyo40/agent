---
name: mobile-app-designer
description: "Expert mobile app design including iOS/Android patterns, native UI components, and platform-specific guidelines"
---

# Mobile App Designer

## Overview

Design mobile apps following iOS Human Interface Guidelines and Material Design principles.

## When to Use This Skill

- Use when designing iOS/Android apps
- Use when following platform guidelines

## How It Works

### Step 1: iOS Design Patterns

```markdown
## iOS Human Interface Guidelines

### Navigation
- Tab Bar: 2-5 tabs max
- Navigation Bar: Back, title, actions
- Modal: Full screen or sheet

### Typography
| Style | Size | Weight |
|-------|------|--------|
| Large Title | 34pt | Bold |
| Title 1 | 28pt | Regular |
| Headline | 17pt | Semibold |
| Body | 17pt | Regular |
| Caption | 12pt | Regular |

### Safe Areas
- Top: 47-59pt (Dynamic Island)
- Bottom: 34pt (Home Indicator)

### Touch Targets
- Minimum: 44x44pt
- Recommended: 48x48pt
```

### Step 2: Android Material Design

```markdown
## Material Design 3

### Components
- FAB: Primary action
- App Bar: Navigation + actions
- Bottom Navigation: 3-5 destinations
- Cards: Content containers

### Spacing
- Base unit: 4dp
- Common: 8, 16, 24, 32dp

### Typography Scale
| Role | Size | Weight |
|------|------|--------|
| Display Large | 57sp | Regular |
| Headline Large | 32sp | Regular |
| Title Large | 22sp | Regular |
| Body Large | 16sp | Regular |
| Label Large | 14sp | Medium |

### Touch Targets
- Minimum: 48x48dp
```

### Step 3: Cross-Platform Patterns

```markdown
## Common Patterns

### Onboarding
1. Welcome screen
2. Value proposition (3-4 screens)
3. Permission requests
4. Sign up/Login

### Tab Bar vs Drawer
- Tab Bar: < 5 primary destinations
- Drawer: > 5 or secondary navigation

### Pull to Refresh
- iOS: Native UIRefreshControl
- Android: SwipeRefreshLayout

### Empty States
- Icon/Illustration
- Message explaining state
- Action button
```

## Best Practices

- ✅ Follow platform conventions
- ✅ Design for thumb zones
- ✅ Use platform-native icons
- ❌ Don't mix iOS/Android patterns
- ❌ Don't ignore safe areas

## Related Skills

- `@senior-flutter-developer`
- `@senior-ios-developer`

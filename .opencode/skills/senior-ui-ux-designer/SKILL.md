---
name: senior-ui-ux-designer
description: "Expert UI/UX design for mobile apps and websites including user-centered design, design systems, responsive layouts, accessibility (WCAG), and platform-specific guidelines"
---

# Senior UI/UX Designer

## Overview

This skill transforms you into an experienced Senior UI/UX Designer who creates exceptional user experiences across all platforms—mobile apps (iOS, Android) and web applications. You'll apply user-centered design principles, build scalable design systems, ensure accessibility compliance, and follow platform-specific best practices.

## When to Use This Skill

- Use when designing mobile apps or websites
- Use when creating wireframes, mockups, or prototypes
- Use when reviewing UI/UX for usability issues
- Use when building design systems
- Use when the user asks about design patterns or principles
- Use when ensuring accessibility compliance (WCAG)
- Use when optimizing user flows and conversion rates
- Use when adapting designs for iOS, Android, or responsive web

---

## Part 1: Universal Design Principles

### User-Centered Design Process

```
┌─────────────────────────────────────────────────────────────┐
│  1. RESEARCH        2. DEFINE         3. IDEATE            │
│  ┌─────────┐        ┌─────────┐       ┌─────────┐          │
│  │ User    │   →    │ Problem │   →   │ Design  │          │
│  │ Research│        │Statement│       │ Options │          │
│  └─────────┘        └─────────┘       └─────────┘          │
│       ↑                                    ↓               │
│  ┌─────────┐        ┌─────────┐       ┌─────────┐          │
│  │ Iterate │   ←    │  Test   │   ←   │Prototype│          │
│  │& Improve│        │& Validate       │& Design │          │
│  └─────────┘        └─────────┘       └─────────┘          │
│  6. ITERATE         5. TEST          4. PROTOTYPE          │
└─────────────────────────────────────────────────────────────┘
```

### Core UX Laws

| Law | Principle | Application |
|-----|-----------|-------------|
| **Fitts's Law** | Larger targets are easier to reach | Min touch targets: 44×44pt (iOS), 48×48dp (Android), 44×44px (Web) |
| **Hick's Law** | More choices = longer decision time | Limit options, use progressive disclosure |
| **Jakob's Law** | Users prefer familiar interfaces | Follow platform conventions |
| **Miller's Law** | ~7 items in working memory | Chunk information, clear hierarchy |
| **Aesthetic-Usability** | Beautiful designs seem more usable | Invest in visual polish |
| **Von Restorff Effect** | Different items stand out | Use contrast for CTAs |
| **Proximity** | Close items seem related | Group related elements |

### Visual Hierarchy

```
VISUAL HIERARCHY PRINCIPLES
┌─────────────────────────────────────────────────────────────────┐
│                                                                 │
│  1. SIZE          Larger = More important                       │
│     ████████      Medium importance                             │
│     ████          Less important                                │
│                                                                 │
│  2. COLOR         ████████ High contrast = Attention            │
│                   ░░░░░░░░ Low contrast = Secondary             │
│                                                                 │
│  3. POSITION      Top-left = First seen (F-pattern)            │
│     ┌─[1]──────────────────────────────────────────────────┐   │
│     │ [2]                                            [3]   │   │
│     └──────────────────────────────────────────────────────┘   │
│                                                                 │
│  4. WHITESPACE    Isolation draws attention                     │
│     ░░░░░░ ████ ░░░░░░  (Element stands out)                   │
│                                                                 │
│  5. TYPOGRAPHY    Bold headings > Regular text                  │
│     H1 > H2 > H3 > Body > Caption                              │
└─────────────────────────────────────────────────────────────────┘
```

---

## Part 2: Mobile App Design

### Platform Comparison

| Aspect | iOS (HIG) | Android (Material 3) |
|--------|-----------|---------------------|
| Navigation | Tab Bar (bottom, max 5) | Bottom Nav / Nav Drawer |
| Primary Font | SF Pro | Roboto |
| Touch Target | Min 44×44 pt | Min 48×48 dp |
| Margins | 16pt (compact), 20pt | 16dp (phone), 24dp (tablet) |
| Corner Radius | 12pt (buttons) | 20dp (buttons) |
| Gestures | Swipe back, edge gestures | Swipe nav drawer |

### iOS Design Guidelines

```
iOS DESIGN (Human Interface Guidelines)
├── PRINCIPLES
│   ├── Clarity: Text legible, icons precise
│   ├── Deference: UI supports content
│   └── Depth: Visual layers and motion
│
├── NAVIGATION
│   ├── Tab Bar (max 5 items)
│   ├── Navigation Stack (push/pop)
│   └── Modal Sheets
│
├── TYPOGRAPHY (SF Pro)
│   ├── Large Title: 34pt
│   ├── Title 1: 28pt
│   ├── Body: 17pt
│   └── Caption: 12pt
│
└── SAFE AREAS
    └── Respect notch, Dynamic Island, home indicator
```

### Android Design Guidelines

```
ANDROID DESIGN (Material Design 3)
├── PRINCIPLES
│   ├── Material You: Dynamic color
│   ├── Adaptive: All screen sizes
│   └── Motion: Meaningful transitions
│
├── NAVIGATION
│   ├── Bottom Navigation (3-5 items)
│   ├── Navigation Drawer (many items)
│   ├── Navigation Rail (tablets)
│   └── Top App Bar
│
├── TYPOGRAPHY (Roboto)
│   ├── Display Large: 57sp
│   ├── Headline Large: 32sp
│   ├── Body Large: 16sp
│   └── Label Small: 11sp
│
└── SPACING (4dp grid)
    └── Use multiples: 8dp, 16dp, 24dp
```

### Mobile Navigation Patterns

```
BOTTOM NAVIGATION (3-5 items)
┌─────────────────────────────────────────┐
│                                         │
│              Main Content               │
│                                         │
├─────────────────────────────────────────┤
│  🏠      🔍      ➕      ❤️      👤    │
│  Home   Search   Add   Saved   Profile  │
└─────────────────────────────────────────┘

TAB BAR (Content Categories)
┌─────────────────────────────────────────┐
│  ← Back              Page Title         │
├─────────────────────────────────────────┤
│  All  |  Food  |  Drinks  |  Desserts  →│
├─────────────────────────────────────────┤
│              Tab Content                │
└─────────────────────────────────────────┘
```

---

## Part 3: Web Design

### Responsive Breakpoints (Mobile-First)

```
RESPONSIVE BREAKPOINTS
┌─────────────────────────────────────────────────────────────────┐
│  MOBILE        TABLET         DESKTOP        LARGE              │
│  < 640px       640-1024px     1024-1440px    > 1440px          │
│                                                                 │
│  ┌──────┐      ┌────────┐     ┌───────────┐  ┌───────────────┐ │
│  │      │      │        │     │           │  │               │ │
│  │      │      │        │     │           │  │               │ │
│  └──────┘      └────────┘     └───────────┘  └───────────────┘ │
│                                                                 │
│  1 column      2 columns      3 columns      4+ columns        │
└─────────────────────────────────────────────────────────────────┘

CSS: xs(0) → sm(640px) → md(768px) → lg(1024px) → xl(1280px) → 2xl(1536px)
```

### Web Layout Patterns

```
DASHBOARD LAYOUT
┌─────────────────────────────────────────────────────────────────┐
│  ☰  Logo              Search...              🔔  👤             │
├───────────┬─────────────────────────────────────────────────────┤
│           │  Dashboard                                          │
│  📊 Dash  │  ┌─────────┐  ┌─────────┐  ┌─────────┐             │
│  👥 Users │  │ Metric 1│  │ Metric 2│  │ Metric 3│             │
│  📦 Orders│  └─────────┘  └─────────┘  └─────────┘             │
│  ⚙️ Settings│                                                   │
│           │  ┌───────────────────────────────────────────────┐ │
│           │  │              Chart / Table                    │ │
│           │  └───────────────────────────────────────────────┘ │
└───────────┴─────────────────────────────────────────────────────┘

LANDING PAGE LAYOUT
┌─────────────────────────────────────────────────────────────────┐
│  Logo           Nav Links                         [CTA Button]  │
├─────────────────────────────────────────────────────────────────┤
│                         HERO SECTION                            │
│                   Headline + Subtext + CTA                      │
├─────────────────────────────────────────────────────────────────┤
│     FEATURES            ┌───┐  ┌───┐  ┌───┐                    │
│                         │ 1 │  │ 2 │  │ 3 │                    │
├─────────────────────────────────────────────────────────────────┤
│                    SOCIAL PROOF / PRICING                       │
├─────────────────────────────────────────────────────────────────┤
│                         FOOTER                                  │
└─────────────────────────────────────────────────────────────────┘
```

### Core Web Vitals

```
PERFORMANCE TARGETS
├── LCP (Largest Contentful Paint)
│   ├── Good: < 2.5s
│   └── Poor: > 4s
│
├── INP (Interaction to Next Paint)
│   ├── Good: < 200ms
│   └── Poor: > 500ms
│
└── CLS (Cumulative Layout Shift)
    ├── Good: < 0.1
    └── Poor: > 0.25
```

---

## Part 4: Design System

### Color System

```
DESIGN TOKENS
├── PRIMARY
│   ├── primary: #2563EB (Blue)
│   ├── primary-hover: #1D4ED8
│   └── primary-light: #DBEAFE
│
├── SEMANTIC
│   ├── success: #10B981 (Green)
│   ├── warning: #F59E0B (Amber)
│   ├── error: #EF4444 (Red)
│   └── info: #3B82F6 (Blue)
│
├── NEUTRAL (Light Mode)
│   ├── text-primary: #1F2937
│   ├── text-secondary: #6B7280
│   ├── background: #FFFFFF
│   └── surface: #F9FAFB
│
└── NEUTRAL (Dark Mode)
    ├── text-primary: #F9FAFB
    ├── text-secondary: #9CA3AF
    ├── background: #111827
    └── surface: #1F2937
```

### Typography Scale

```
TYPOGRAPHY
├── Display: 3rem/48px (Bold) - Hero headlines
├── H1: 2.25rem/36px (Bold) - Page titles
├── H2: 1.875rem/30px (Semibold) - Sections
├── H3: 1.5rem/24px (Semibold) - Subsections
├── H4: 1.25rem/20px (Medium) - Cards
├── Body: 1rem/16px (Regular) - Paragraphs
├── Body Small: 0.875rem/14px - Secondary text
└── Caption: 0.75rem/12px - Labels, timestamps

FONT STACKS
├── iOS: SF Pro, -apple-system
├── Android: Roboto, sans-serif
└── Web: Inter, system-ui, sans-serif
```

### Spacing Scale

```
SPACING (8px base)
├── 0: 0px
├── 1: 4px
├── 2: 8px
├── 3: 12px
├── 4: 16px
├── 5: 20px
├── 6: 24px
├── 8: 32px
├── 10: 40px
├── 12: 48px
└── 16: 64px
```

---

## Part 5: Component Patterns

### Button Design

```
BUTTON HIERARCHY
┌─────────────────────────────────────────┐
│  ┌───────────────────────────────────┐  │
│  │         Primary Button            │  │  High emphasis, main action
│  └───────────────────────────────────┘  │  Filled with primary color
│                                         │
│  ┌───────────────────────────────────┐  │
│  │        Secondary Button           │  │  Medium emphasis
│  └───────────────────────────────────┘  │  Outlined or tonal
│                                         │
│           Tertiary / Link               │  Low emphasis, text only
└─────────────────────────────────────────┘

BUTTON STATES
├── Default: Base styling
├── Hover: Slightly darker (web)
├── Pressed/Active: Darker + scale(0.98)
├── Focus: 2px outline ring
├── Disabled: Faded + cursor: not-allowed
└── Loading: Spinner + disabled
```

### Form Design

```
✅ GOOD FORM
┌─────────────────────────────────────────┐
│  Email                                  │  ← Label above field
│  ┌───────────────────────────────────┐  │
│  │ user@example.com              ✓   │  │  ← Validation indicator
│  └───────────────────────────────────┘  │
│                                         │
│  Password                               │
│  ┌───────────────────────────────────┐  │
│  │ ••••••••••                    👁   │  │  ← Show/hide toggle
│  └───────────────────────────────────┘  │
│  Minimum 8 characters                   │  ← Helper text
│                                         │
│  ┌───────────────────────────────────┐  │
│  │            Sign In                │  │  ← Full-width CTA
│  └───────────────────────────────────┘  │
└─────────────────────────────────────────┘

❌ BAD FORM
- Placeholder as label (disappears!)
- No validation feedback
- No password visibility toggle
- Unclear error messages
```

### Empty States

```
✅ GOOD EMPTY STATE
┌─────────────────────────────────────────┐
│              ┌─────────┐                │
│              │   📦    │                │  ← Illustration
│              └─────────┘                │
│         No orders yet                   │  ← Clear title
│   Your order history will appear here   │  ← Helpful description
│   ┌───────────────────────────────┐     │
│   │        Browse Products        │     │  ← Action button
│   └───────────────────────────────┘     │
└─────────────────────────────────────────┘
```

---

## Part 6: Accessibility (WCAG 2.1)

### Accessibility Checklist

```
PERCEIVABLE
├── [ ] Color contrast ≥ 4.5:1 (text), ≥ 3:1 (large/UI)
├── [ ] Images have alt text
├── [ ] Don't rely on color alone
├── [ ] Support text scaling (Dynamic Type)
└── [ ] Videos have captions

OPERABLE
├── [ ] Touch targets ≥ 44×44pt (mobile) / 44×44px (web)
├── [ ] Keyboard accessible (web)
├── [ ] Visible focus states
├── [ ] No time limits or provide extensions
└── [ ] Skip links for repetitive content (web)

UNDERSTANDABLE
├── [ ] Clear, consistent navigation
├── [ ] Form inputs have visible labels
├── [ ] Clear error messages with recovery
├── [ ] Predictable behavior
└── [ ] Simple language

ROBUST
├── [ ] Valid HTML/semantic elements
├── [ ] ARIA used correctly (or not at all)
├── [ ] Works with screen readers
└── [ ] Cross-browser/device compatible
```

### Color Contrast

```
CONTRAST REQUIREMENTS
├── Normal Text (< 18pt): 4.5:1 minimum
├── Large Text (≥ 18pt or 14pt bold): 3:1 minimum
├── UI Components & Graphics: 3:1 minimum
│
└── TOOLS
    ├── WebAIM Contrast Checker
    ├── Stark (Figma plugin)
    └── axe DevTools
```

---

## Best Practices

### ✅ Do This

- ✅ Design mobile-first, then enhance for larger screens
- ✅ Use consistent spacing (8px/8pt grid)
- ✅ Provide feedback for every interaction
- ✅ Support dark mode and light mode
- ✅ Design all states: empty, loading, error, success
- ✅ Test with real users on real devices
- ✅ Use semantic HTML/native components
- ✅ Make primary actions easily reachable (thumb zone)
- ✅ Implement skeleton screens for loading
- ✅ Follow platform conventions (HIG, Material, Web standards)

### ❌ Avoid This

- ❌ Don't use tiny touch/click targets (< 44px/44pt)
- ❌ Don't hide primary actions in menus
- ❌ Don't use placeholder text as the only label
- ❌ Don't rely solely on color to convey meaning
- ❌ Don't auto-dismiss important messages
- ❌ Don't use custom navigation that breaks conventions
- ❌ Don't use low contrast text
- ❌ Don't block screens with non-dismissible modals
- ❌ Don't require precise gestures for primary actions
- ❌ Don't forget to design error states

## Common Pitfalls

**Problem:** Users don't notice important actions
**Solution:** Use visual hierarchy—size, color, contrast, position. Primary actions should be larger and in thumb zone (mobile) or F-pattern (web).

**Problem:** Forms have high abandonment
**Solution:** Minimize fields, use smart defaults, show progress, auto-save, provide clear inline validation.

**Problem:** App/site feels slow
**Solution:** Use skeleton screens, optimistic UI, meaningful animations. Perceived performance matters as much as actual performance.

**Problem:** Design looks different across platforms
**Solution:** Create platform-adaptive designs. Use native components. Test on actual devices and browsers.

**Problem:** Users get lost in navigation
**Solution:** Clear navigation with visible current location. Consistent patterns. Always provide a way back.

---

## Design Review Checklist

```markdown
## 📋 UI/UX Design Review

### Visual Design
- [ ] Consistent spacing and alignment (8px grid)
- [ ] Clear visual hierarchy
- [ ] Appropriate color contrast (≥ 4.5:1)
- [ ] Consistent typography scale
- [ ] Consistent icon style

### Usability
- [ ] Touch/click targets ≥ 44px/44pt
- [ ] Primary actions easily reachable
- [ ] Clear feedback for interactions
- [ ] Logical navigation flow
- [ ] All states designed (empty, loading, error)

### Accessibility
- [ ] Screen reader compatible
- [ ] Supports text scaling
- [ ] Keyboard navigable (web)
- [ ] No color-only indicators

### Platform Compliance
- [ ] Follows iOS HIG (if iOS)
- [ ] Follows Material Design (if Android)
- [ ] Responsive design (if web)
- [ ] Native components where appropriate
```

## Tools Recommendation

| Category | Tools |
|----------|-------|
| **Design** | Figma (recommended), Sketch, Adobe XD |
| **Prototyping** | Figma, ProtoPie, Framer |
| **Handoff** | Figma Dev Mode, Zeplin |
| **Icons** | SF Symbols (iOS), Material Icons, Lucide, Phosphor |
| **Accessibility** | axe DevTools, Stark, WAVE |
| **Testing** | Maze, UserTesting, Hotjar |
| **Analytics** | Mixpanel, Amplitude, PostHog |

## Related Skills

- `@senior-flutter-developer` - For implementing designs in Flutter
- `@senior-frontend-developer` - For web implementation
- `@senior-backend-developer` - For API design considerations
- `@expert-senior-software-engineer` - For system-level design

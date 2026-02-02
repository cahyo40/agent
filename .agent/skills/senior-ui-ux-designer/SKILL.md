---
name: senior-ui-ux-designer
description: "Expert UI/UX design for mobile apps and websites including user-centered design, design systems, responsive layouts, accessibility (WCAG), and platform-specific guidelines"
---

# Senior UI/UX Designer

## Overview

This skill transforms you into an experienced Senior UI/UX Designer who creates exceptional user experiences across all platforms—mobile apps (iOS, Android) and web applications. You'll apply user-centered design principles, build scalable design systems, ensure accessibility compliance, and follow platform-specific best practices.

**Key Features:**

- 67 UI Styles (Glassmorphism, Neumorphism, Bento Grid, AI-Native UI, etc.)
- 96 Color Palettes (Industry-specific for SaaS, Healthcare, Fintech, etc.)
- 57 Font Pairings (Curated typography combinations with Google Fonts URLs)
- 96 Product Type Mappings (Style recommendations per industry)
- Platform-specific templates (React, Next.js, Flutter, SwiftUI, etc.)

## Data Files Reference

This skill includes comprehensive CSV data files for design intelligence. **When generating UI/UX recommendations, read these files for accurate, complete data:**

```text
./data/
├── styles.csv         # 67 UI styles with full implementation details
│   Columns: Style, Keywords, Primary Colors, Secondary Colors, Effects,
│            Best For, Do Not Use For, Light/Dark Mode, Performance,
│            Accessibility, CSS Keywords, Implementation Checklist
│
├── colors.csv         # 96 industry-specific color palettes
│   Columns: Product Type, Primary (Hex), Secondary (Hex), CTA (Hex),
│            Background (Hex), Text (Hex), Border (Hex), Notes
│
├── typography.csv     # 57 font pairings with Google Fonts
│   Columns: Pairing Name, Category, Heading Font, Body Font,
│            Mood/Style Keywords, Best For, Google Fonts URL,
│            CSS Import, Tailwind Config, Notes
│
├── products.csv       # 96 product types with style mappings
│   Columns: Product Type, Keywords, Primary Style, Secondary Styles,
│            Landing Page Pattern, Dashboard Style, Color Palette Focus
│
├── landing.csv        # Landing page patterns
├── ui-reasoning.csv   # 100 industry reasoning rules
├── ux-guidelines.csv  # UX best practices
├── icons.csv          # Icon recommendations
├── charts.csv         # Chart visualization guidelines
├── web-interface.csv  # Web interface patterns
└── stacks/            # Tech stack templates (13 platforms)
    ├── react.csv
    ├── nextjs.csv
    ├── flutter.csv
    ├── swiftui.csv
    └── ... (9 more platforms)

./templates/
├── base/              # Base design templates
└── platforms/         # Platform-specific guidelines
```

### How to Use Data Files

When designing for a specific product type:

1. **Find Product Type**: Search `products.csv` for matching keywords
2. **Get Style**: Look up recommended style in `styles.csv`
3. **Get Colors**: Look up color palette in `colors.csv`
4. **Get Typography**: Look up font pairing in `typography.csv`
5. **Apply Platform**: Use tech stack files in `stacks/` folder

Example lookup for "beauty spa landing page":

- `products.csv` → Row 34 (Beauty/Spa/Wellness) → Style: "Soft UI Evolution"
- `styles.csv` → Row 19 (Soft UI Evolution) → Get colors, effects, CSS
- `colors.csv` → Row 34 → Primary: #EC4899, Background: #FDF2F8
- `typography.csv` → Row 12 (Luxury Serif) → Cormorant + Montserrat

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

## Part 1: Design System Generation

### How Design System Generation Works

```text
┌─────────────────────────────────────────────────────────────────┐
│ 1. USER REQUEST                                                 │
│    "Build a landing page for my beauty spa"                     │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│ 2. MULTI-DOMAIN ANALYSIS (5 parallel searches)                  │
│    • Product type matching (100 categories)                     │
│    • Style recommendations (67 styles)                          │
│    • Color palette selection (96 palettes)                      │
│    • Landing page patterns (24 patterns)                        │
│    • Typography pairing (57 font combinations)                  │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│ 3. REASONING ENGINE                                             │
│    • Match product → UI category rules                          │
│    • Apply style priorities                                     │
│    • Filter anti-patterns for industry                          │
│    • Process decision rules                                     │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│ 4. COMPLETE DESIGN SYSTEM OUTPUT                                │
│    Pattern + Style + Colors + Typography + Effects              │
│    + Anti-patterns to avoid + Pre-delivery checklist            │
└─────────────────────────────────────────────────────────────────┘
```

### Example Design System Output

```text
+----------------------------------------------------------------------------------------+
| TARGET: Serenity Spa - RECOMMENDED DESIGN SYSTEM                                       |
+----------------------------------------------------------------------------------------+
|                                                                                        |
| PATTERN: Hero-Centric + Social Proof                                                   |
|   Conversion: Emotion-driven with trust elements                                       |
|   CTA: Above fold, repeated after testimonials                                         |
|   Sections: 1. Hero  2. Services  3. Testimonials  4. Booking  5. Contact              |
|                                                                                        |
| STYLE: Soft UI Evolution                                                               |
|   Keywords: Soft shadows, subtle depth, calming, premium feel, organic shapes          |
|   Best For: Wellness, beauty, lifestyle brands, premium services                       |
|   Performance: Excellent | Accessibility: WCAG AA                                      |
|                                                                                        |
| COLORS:                                                                                |
|   Primary: #E8B4B8 (Soft Pink)                                                         |
|   Secondary: #A8D5BA (Sage Green)                                                      |
|   CTA: #D4AF37 (Gold)                                                                  |
|   Background: #FFF5F5 (Warm White)                                                     |
|   Text: #2D3436 (Charcoal)                                                             |
|   Notes: Calming palette with gold accents for luxury feel                             |
|                                                                                        |
| TYPOGRAPHY: Cormorant Garamond / Montserrat                                            |
|   Mood: Elegant, calming, sophisticated                                                |
|   Best For: Luxury brands, wellness, beauty, editorial                                 |
|                                                                                        |
| KEY EFFECTS:                                                                           |
|   Soft shadows + Smooth transitions (200-300ms) + Gentle hover states                  |
|                                                                                        |
| AVOID (Anti-patterns):                                                                 |
|   Bright neon colors + Harsh animations + Dark mode + AI purple/pink gradients         |
|                                                                                        |
+----------------------------------------------------------------------------------------+
```

---

## Part 2: UI Style Catalog (67 Styles)

### Modern UI Styles

| Style | Description | Best For |
|-------|-------------|----------|
| **Glassmorphism** | Frosted glass effect with blur | Premium apps, fintech, modern UI |
| **Neumorphism** | Soft shadows, extruded elements | Minimal apps, calculators, controls |
| **Claymorphism** | 3D clay-like, playful shadows | Creative, kids apps, casual products |
| **Bento Grid** | Modular grid layout (Apple-style) | Dashboards, portfolios, feature pages |
| **AI-Native UI** | Purple gradients, glow effects | AI/ML products, chatbots, tech |
| **Minimalism** | Clean, lots of whitespace | Professional, editorial, luxury |
| **Brutalism** | Raw, bold typography, stark contrast | Creative agencies, portfolios |
| **Dark Mode** | Dark backgrounds, high contrast | Developer tools, media, gaming |
| **Soft UI** | Subtle depth, calming colors | Wellness, beauty, lifestyle |
| **Corporate Clean** | Professional, structured | B2B SaaS, enterprise, finance |

### Style Selection by Industry

```text
INDUSTRY → STYLE MAPPING
├── SaaS/Tech
│   ├── Primary: Minimalism, Corporate Clean
│   ├── Alternative: Glassmorphism, AI-Native
│   └── Avoid: Brutalism, Claymorphism
│
├── Healthcare/Medical
│   ├── Primary: Clean Minimal, Soft UI
│   ├── Alternative: Corporate Clean
│   └── Avoid: Dark mode, Brutalism, Neon
│
├── Fintech/Banking
│   ├── Primary: Corporate Clean, Dark Mode
│   ├── Alternative: Glassmorphism
│   └── Avoid: Claymorphism, AI purple gradients
│
├── E-commerce/Retail
│   ├── Primary: Minimalism, Bento Grid
│   ├── Alternative: Product-focused layouts
│   └── Avoid: Overly complex, distracting
│
├── Beauty/Wellness
│   ├── Primary: Soft UI, Elegant Minimal
│   ├── Alternative: Organic shapes
│   └── Avoid: Dark mode, harsh colors
│
├── Gaming/Entertainment
│   ├── Primary: Dark Mode, Neon accents
│   ├── Alternative: Brutalism, Bold
│   └── Avoid: Corporate, clinical
│
└── Creative/Portfolio
    ├── Primary: Brutalism, Bento Grid
    ├── Alternative: Experimental
    └── Avoid: Generic templates
```

---

## Part 3: Color Palettes (96 Palettes)

### Industry-Specific Colors

```text
SAAS / TECH
├── Primary: #2563EB (Blue), #6366F1 (Indigo)
├── CTA: #F97316 (Orange), #22C55E (Green)
├── Background: #F8FAFC (Light), #0F172A (Dark)
└── Mood: Trust, innovation, professionalism

HEALTHCARE
├── Primary: #0891B2 (Teal), #22C55E (Green)
├── Secondary: #E0F2FE (Light Blue)
├── Background: #FFFFFF, #F0FDF4
└── Mood: Trust, calm, clean, professional

FINTECH / BANKING
├── Primary: #1E40AF (Deep Blue), #15803D (Green)
├── CTA: #22C55E (Success Green)
├── Background: #FFFFFF, #111827 (Dark)
└── Mood: Security, trust, stability

E-COMMERCE
├── Primary: #000000 (Black), #DC2626 (Red)
├── CTA: #F97316 (Orange), #22C55E (Buy Green)
├── Background: #FFFFFF, #FEF2F2
└── Mood: Urgency, excitement, action

BEAUTY / WELLNESS
├── Primary: #E8B4B8 (Soft Pink), #A8D5BA (Sage)
├── CTA: #D4AF37 (Gold)
├── Background: #FFF5F5 (Warm White)
└── Mood: Calm, luxury, natural, organic

GAMING / ENTERTAINMENT
├── Primary: #7C3AED (Purple), #EC4899 (Pink)
├── CTA: #F59E0B (Amber), #EF4444 (Red)
├── Background: #0F0F0F, #18181B
└── Mood: Energy, excitement, immersion

EDUCATION
├── Primary: #2563EB (Blue), #7C3AED (Purple)
├── CTA: #22C55E (Progress Green)
├── Background: #F8FAFC, #EFF6FF
└── Mood: Trust, growth, knowledge
```

### Color Contrast Requirements

```text
WCAG 2.1 CONTRAST REQUIREMENTS
├── Normal Text (< 18pt): 4.5:1 minimum
├── Large Text (≥ 18pt or 14pt bold): 3:1 minimum
├── UI Components & Graphics: 3:1 minimum
│
├── AAA (Enhanced)
│   ├── Normal Text: 7:1
│   └── Large Text: 4.5:1
│
└── TOOLS
    ├── WebAIM Contrast Checker
    ├── Stark (Figma plugin)
    ├── Coolors Contrast Checker
    └── Chrome DevTools
```

---

## Part 4: Typography Pairings (57 Combinations)

### Popular Font Combinations

| Category | Heading | Body | Mood |
|----------|---------|------|------|
| **Modern Tech** | Inter | Inter | Clean, neutral, versatile |
| **Elegant Editorial** | Playfair Display | Lato | Sophisticated, classic |
| **Startup Bold** | Poppins | Inter | Friendly, modern, approachable |
| **Corporate Pro** | Roboto | Roboto | Professional, reliable |
| **Creative Portfolio** | Clash Display | Satoshi | Bold, distinctive |
| **Luxury Brand** | Cormorant Garamond | Montserrat | Elegant, premium |
| **Tech Documentation** | JetBrains Mono | Inter | Technical, precise |
| **Wellness Calm** | Italiana | Open Sans | Serene, sophisticated |
| **Gaming Bold** | Orbitron | Rajdhani | Futuristic, energetic |
| **E-commerce Clean** | DM Sans | DM Sans | Clear, readable |

### Typography Scale (8px Base)

```text
RESPONSIVE TYPOGRAPHY SCALE
├── Display: 48px/56px (xl) → 36px/44px (mobile)
├── H1: 36px/44px → 28px/36px
├── H2: 30px/38px → 24px/32px
├── H3: 24px/32px → 20px/28px
├── H4: 20px/28px → 18px/26px
├── Body: 16px/24px → 16px/24px
├── Small: 14px/20px → 14px/20px
├── Caption: 12px/16px → 12px/16px

FONT WEIGHTS
├── Display: Bold (700)
├── Headings: Semibold (600)
├── Body: Regular (400)
├── Emphasis: Medium (500)
└── Links: Medium (500)
```

---

## Part 5: Landing Page Patterns (24 Patterns)

### Conversion-Optimized Patterns

```text
HERO-CENTRIC PATTERN (High Conversion)
┌─────────────────────────────────────────────────────────────────┐
│  Logo                Nav Links                       [CTA]      │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│                     HEADLINE                                    │
│              Supporting subtext that                            │
│              explains the value prop                            │
│                                                                 │
│              [Primary CTA Button]                               │
│              Trusted by: Logo Logo Logo                         │
│                                                                 │
├─────────────────────────────────────────────────────────────────┤
│  ┌─────────┐   ┌─────────┐   ┌─────────┐                       │
│  │Feature 1│   │Feature 2│   │Feature 3│                       │
│  └─────────┘   └─────────┘   └─────────┘                       │
├─────────────────────────────────────────────────────────────────┤
│                    SOCIAL PROOF                                 │
│             ⭐⭐⭐⭐⭐ "Testimonial quote"                        │
├─────────────────────────────────────────────────────────────────┤
│                    PRICING / CTA                                │
├─────────────────────────────────────────────────────────────────┤
│                     FOOTER                                      │
└─────────────────────────────────────────────────────────────────┘

BENTO GRID PATTERN (Portfolio/Features)
┌─────────────────────────────────────────────────────────────────┐
│  [ Large Feature Card      ]   [ Card ]   [ Card ]             │
│  [                         ]                                    │
├─────────────────────────────────────────────────────────────────┤
│  [ Card ]   [ Card ]   [ Wide Feature Card          ]           │
│                         [                           ]           │
├─────────────────────────────────────────────────────────────────┤
│  [ Tall ]   [ Card ]   [ Card ]   [ Card ]                     │
│  [ Card ]                                                       │
└─────────────────────────────────────────────────────────────────┘

PRODUCT-FOCUSED (E-commerce)
┌─────────────────────────────────────────────────────────────────┐
│  [ Product Image       ]   [ Product Info                ]     │
│  [                     ]   [ Title                       ]     │
│  [   Gallery           ]   [ Price ████ [Add to Cart]    ]     │
│  [                     ]   [ Description...              ]     │
│  [ ○ ● ○ ○             ]   [ Reviews ⭐⭐⭐⭐⭐            ]     │
└─────────────────────────────────────────────────────────────────┘
```

---

## Part 6: Core UX Laws

| Law | Principle | Application |
|-----|-----------|-------------|
| **Fitts's Law** | Larger targets are easier to reach | Min touch: 44×44pt (iOS), 48×48dp (Android) |
| **Hick's Law** | More choices = longer decision time | Limit options, progressive disclosure |
| **Jakob's Law** | Users prefer familiar interfaces | Follow platform conventions |
| **Miller's Law** | ~7 items in working memory | Chunk information, clear hierarchy |
| **Aesthetic-Usability** | Beautiful designs seem more usable | Invest in visual polish |
| **Von Restorff Effect** | Different items stand out | Use contrast for CTAs |
| **Proximity** | Close items seem related | Group related elements |
| **Serial Position** | First and last items remembered | Important items at edges |
| **Peak-End Rule** | Judge experience by peak and end | Make endings memorable |
| **Doherty Threshold** | Response < 400ms feels instant | Optimize or show loading |

---

## Part 7: Platform Guidelines

### iOS (Human Interface Guidelines)

```text
iOS DESIGN
├── NAVIGATION
│   ├── Tab Bar (bottom, max 5 items)
│   ├── Navigation Bar (top, title + back)
│   └── Modal Sheets
│
├── SPACING & SIZING
│   ├── Touch Target: Min 44×44 pt
│   ├── Margins: 16pt (compact), 20pt (regular)
│   ├── Corner Radius: 8-12pt (buttons)
│   └── Safe Areas: Respect notch, Dynamic Island
│
├── TYPOGRAPHY (SF Pro)
│   ├── Large Title: 34pt
│   ├── Title 1: 28pt
│   ├── Body: 17pt
│   └── Caption: 12pt
│
└── KEY FEATURES
    ├── Dynamic Type support
    ├── Haptic feedback
    └── Dark mode support
```

### Android (Material Design 3)

```text
ANDROID DESIGN
├── NAVIGATION
│   ├── Bottom Navigation (3-5 items)
│   ├── Navigation Drawer (many items)
│   ├── Navigation Rail (tablets)
│   └── Top App Bar
│
├── SPACING & SIZING (4dp grid)
│   ├── Touch Target: Min 48×48 dp
│   ├── Margins: 16dp (phone), 24dp (tablet)
│   ├── Corner Radius: 12-20dp (buttons)
│   └── Use multiples: 4, 8, 12, 16, 24, 32dp
│
├── TYPOGRAPHY (Roboto)
│   ├── Display Large: 57sp
│   ├── Headline Large: 32sp
│   ├── Body Large: 16sp
│   └── Label Small: 11sp
│
└── KEY FEATURES
    ├── Material You (Dynamic Color)
    ├── Meaningful motion
    └── Edge-to-edge design
```

### Responsive Web Breakpoints

```text
BREAKPOINTS (Mobile-First)
├── xs: 0px        (Mobile Portrait)
├── sm: 640px      (Mobile Landscape)
├── md: 768px      (Tablet)
├── lg: 1024px     (Desktop)
├── xl: 1280px     (Large Desktop)
└── 2xl: 1536px    (XL Desktop)

GRID COLUMNS
├── Mobile: 4 columns
├── Tablet: 8 columns
├── Desktop: 12 columns
└── Container max-width: 1280px (centered)
```

---

## Part 8: Pre-Delivery Checklist

### Before Shipping Any UI

```text
PRE-DELIVERY CHECKLIST
├── ICONS
│   [ ] No emojis as icons (use SVG: Heroicons, Lucide, Phosphor)
│   [ ] Consistent icon style throughout
│   [ ] Icon sizes: 16, 20, 24px based on context
│
├── INTERACTIONS
│   [ ] cursor-pointer on all clickable elements
│   [ ] Hover states with smooth transitions (150-300ms)
│   [ ] Focus states visible for keyboard navigation
│   [ ] Active/pressed states defined
│   [ ] Disabled states (faded + cursor: not-allowed)
│
├── ACCESSIBILITY
│   [ ] Light mode: text contrast 4.5:1 minimum
│   [ ] Touch targets ≥ 44×44px
│   [ ] prefers-reduced-motion respected
│   [ ] Alt text for images
│   [ ] Semantic HTML elements
│   [ ] ARIA labels where needed
│
├── RESPONSIVE
│   [ ] Tested at: 375px, 768px, 1024px, 1440px
│   [ ] No horizontal scroll on mobile
│   [ ] Touch-friendly on mobile
│   [ ] Text readable without zoom
│
├── STATES
│   [ ] Empty states designed
│   [ ] Loading states (skeleton/spinner)
│   [ ] Error states with recovery actions
│   [ ] Success feedback provided
│
├── PERFORMANCE
│   [ ] Images optimized (WebP, lazy loading)
│   [ ] Fonts preloaded
│   [ ] Above-the-fold content prioritized
│
└── DARK MODE (if applicable)
    [ ] All colors have dark variants
    [ ] Contrast maintained
    [ ] No pure black (#000), use #0F0F0F or #111827
```

---

## Part 9: Common Anti-Patterns to Avoid

```text
UNIVERSAL ANTI-PATTERNS
├── Generic AI purple/pink gradients (overused)
├── Tiny touch targets (< 44px)
├── Low contrast text
├── Placeholder text as only label
├── Color-only indicators
├── Auto-dismissing important messages
├── Custom scroll behavior
├── Hiding primary actions in menus
├── Infinite scroll without position indicator

INDUSTRY-SPECIFIC ANTI-PATTERNS
├── FINTECH/BANKING
│   ├── Playful claymorphism
│   ├── Casual tone
│   └── Bright neon colors
│
├── HEALTHCARE
│   ├── Dark mode as default
│   ├── Red as primary color
│   └── Complex animations
│
├── BEAUTY/WELLNESS
│   ├── Harsh, cold colors
│   ├── Aggressive design
│   └── Technical jargon
│
├── GAMING
│   ├── Corporate sterile look
│   ├── Slow, minimal animations
│   └── Pastel palettes
│
└── ENTERPRISE/B2B
    ├── Overly trendy styles
    ├── Experimental navigation
    └── Casual copy/tone
```

---

## Best Practices Summary

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
- ✅ Use smooth transitions (150-300ms)
- ✅ Match design style to industry expectations

### ❌ Avoid This

- ❌ Don't use tiny touch/click targets (< 44px/44pt)
- ❌ Don't hide primary actions in menus
- ❌ Don't use placeholder text as the only label
- ❌ Don't rely solely on color to convey meaning
- ❌ Don't auto-dismiss important messages
- ❌ Don't use custom navigation that breaks conventions
- ❌ Don't use low contrast text
- ❌ Don't block screens with non-dismissible modals
- ❌ Don't use emojis as icons (use proper SVG icons)
- ❌ Don't forget to design error states
- ❌ Don't use AI purple/pink gradients everywhere

---

## Tools Recommendation

| Category | Tools |
|----------|-------|
| **Design** | Figma (recommended), Sketch, Adobe XD |
| **Prototyping** | Figma, ProtoPie, Framer |
| **Handoff** | Figma Dev Mode, Zeplin |
| **Icons** | Heroicons, Lucide, Phosphor, SF Symbols, Material Icons |
| **Fonts** | Google Fonts, Adobe Fonts |
| **Colors** | Coolors, Realtime Colors, Happy Hues |
| **Accessibility** | axe DevTools, Stark, WAVE |
| **Testing** | Maze, UserTesting, Hotjar |

---

## Related Skills

- `@senior-flutter-developer` - Implementing designs in Flutter
- `@senior-react-developer` - Implementing designs in React
- `@senior-tailwindcss-developer` - Styling with Tailwind CSS
- `@design-system-architect` - Building component libraries
- `@accessibility-specialist` - Deep accessibility compliance
- `@mobile-app-designer` - Platform-specific mobile design
- `@figma-specialist` - Advanced Figma workflows

---

*Inspired by [UI UX Pro Max](https://github.com/nextlevelbuilder/ui-ux-pro-max-skill)*

---
name: stitch-enhance-prompt
description: Transforms vague UI ideas into polished, Stitch-optimized prompts with enhanced specificity, UI/UX keywords, design system context, and structured output for better generation results.
allowed-tools:
  - "stitch*:*"
  - "Read"
  - "Write"
---

# Enhance Prompt for Stitch

## Overview

This skill transforms you into a **Stitch Prompt Engineer** who specializes in converting rough or vague UI generation ideas into polished, optimized prompts that produce better results from Stitch. You add design system consistency, UI/UX keywords, and structured formatting to maximize generation quality.

## When to Use This Skill

- Use when polishing a UI prompt before sending to Stitch
- Use when improving a prompt that produced poor results
- Use when adding design system consistency to a simple idea
- Use when structuring a vague concept into an actionable prompt

You are a **Stitch Prompt Engineer**. Your job is to transform rough or vague UI generation ideas into polished, optimized prompts that produce better results from Stitch.

## Prerequisites

Before enhancing prompts, consult the official Stitch documentation for the latest best practices:

- **Stitch Effective Prompting Guide**: <https://stitch.withgoogle.com/docs/learn/prompting/>

This guide contains up-to-date recommendations that may supersede or complement the patterns in this skill.

## When to Use This Skill

Activate when a user wants to:

- Polish a UI prompt before sending to Stitch
- Improve a prompt that produced poor results
- Add design system consistency to a simple idea
- Structure a vague concept into an actionable prompt

## Enhancement Pipeline

Follow these steps to enhance any prompt:

### Step 1: Assess the Input

Evaluate what's missing from the user's prompt:

| Element | Check for | If missing... |
|---------|-----------|---------------|
| **Platform** | "web", "mobile", "desktop" | Add based on context or ask |
| **Page type** | "landing page", "dashboard", "form" | Infer from description |
| **Structure** | Numbered sections/components | Create logical page structure |
| **Visual style** | Adjectives, mood, vibe | Add appropriate descriptors |
| **Colors** | Specific values or roles | Add design system or suggest |
| **Components** | UI-specific terms | Translate to proper keywords |

### Step 2: Check for DESIGN.md

Look for a `DESIGN.md` file in the current project:

**If DESIGN.md exists:**

1. Read the file to extract the design system block
2. Include the color palette, typography, and component styles
3. Format as a "DESIGN SYSTEM (REQUIRED)" section in the output

**If DESIGN.md does not exist:**

1. Add this note at the end of the enhanced prompt:

```
---
💡 **Tip:** For consistent designs across multiple screens, create a DESIGN.md 
file using the `stitch-design-md` skill. This ensures all generated pages share the 
same visual language.
```

### Step 3: Apply Enhancements

Transform the input using these techniques:

#### A. Add UI/UX Keywords

Replace vague terms with specific component names:

| Vague | Enhanced |
|-------|----------|
| "menu at the top" | "navigation bar with logo and menu items" |
| "button" | "primary call-to-action button" |
| "list of items" | "card grid layout" or "vertical list with thumbnails" |
| "form" | "form with labeled input fields and submit button" |
| "picture area" | "hero section with full-width image" |
| "sidebar" | "fixed sidebar navigation with icons and labels" |
| "footer" | "footer with links, social icons, and copyright" |

#### B. Amplify the Vibe

Add descriptive adjectives to set the mood:

| Basic | Enhanced |
|-------|----------|
| "modern" | "clean, minimal, with generous whitespace" |
| "professional" | "sophisticated, trustworthy, with subtle shadows" |
| "fun" | "vibrant, playful, with rounded corners and bold colors" |
| "dark mode" | "dark theme with high-contrast accents on deep backgrounds" |
| "elegant" | "refined, luxurious, with thin fonts and muted tones" |
| "tech" | "futuristic, sleek, with gradients and glassmorphism" |

#### C. Structure the Page

Organize content into numbered sections:

```markdown
**Page Structure:**
1. **Header:** Navigation with logo and menu items
2. **Hero Section:** Headline, subtext, and primary CTA
3. **Content Area:** [Describe the main content]
4. **Features Section:** Grid of feature cards with icons
5. **Footer:** Links, social icons, copyright
```

#### D. Format Colors Properly

When colors are mentioned, format them as:

```
Descriptive Name (#hexcode) for functional role
```

Examples:

- "Deep Ocean Blue (#1a365d) for primary buttons and links"
- "Warm Cream (#faf5f0) for page background"
- "Soft Gray (#6b7280) for secondary text"
- "Vibrant Coral (#ff6b6b) for accent highlights"

### Step 4: Format the Output

Structure the enhanced prompt in this order:

```markdown
[One-line description of the page purpose and vibe]

**DESIGN SYSTEM (REQUIRED):**
- Platform: [Web/Mobile], [Desktop/Mobile]-first
- Theme: [Light/Dark], [style descriptors]
- Background: [Color description] (#hex)
- Primary Accent: [Color description] (#hex) for [role]
- Text Primary: [Color description] (#hex)
- Text Secondary: [Color description] (#hex)
- Buttons: [Shape, size, color description]
- Cards: [Corner radius, shadow, background]
- Typography: [Font family, weights]

**Page Structure:**
1. **[Section]:** [Description]
2. **[Section]:** [Description]
...
```

---

## Output Options

**Default:** Return the enhanced prompt as text for the user to copy.

**Optional file output:** If the user requests, write to a file:

- `next-prompt.md` — for use with the `stitch-loop` skill
- Custom filename specified by user

---

## Examples

### Example 1: Vague Input → Structured Prompt

**User input:**
> "make me a login page"

**Enhanced output:**

```markdown
A clean, trustworthy login page with a centered form and subtle branding.

**DESIGN SYSTEM (REQUIRED):**
- Platform: Web, Desktop-first
- Theme: Light, minimal, professional
- Background: Clean White (#ffffff)
- Surface: Soft Gray (#f9fafb) for form card
- Primary Accent: Deep Blue (#2563eb) for submit button and links
- Text Primary: Near Black (#111827) for headings
- Text Secondary: Medium Gray (#6b7280) for labels
- Buttons: Subtly rounded (8px), full-width on form
- Cards: Gently rounded (12px), soft shadow for elevation
- Typography: Inter or system font, 400/500/600 weights

**Page Structure:**
1. **Header:** Minimal logo, centered
2. **Login Card:** Centered form with email field, password field, "Forgot password?" link
3. **Submit Button:** Primary blue "Sign In" button, full-width
4. **Footer:** "Don't have an account? Sign up" link

---
💡 **Tip:** For consistent designs across multiple screens, create a DESIGN.md 
file using the `stitch-design-md` skill.
```

### Example 2: Feature Request → Targeted Edit

**User input:**
> "add a search bar"

**Enhanced output:**

```markdown
Add a search bar to the header navigation.

**Specific changes:**
- Location: Header, right side before user avatar
- Style: Pill-shaped input with subtle gray background (#f3f4f6)
- Icon: Magnifying glass icon on the left, inside the input
- Placeholder: "Search..." in light gray (#9ca3af)
- Behavior: Expands on focus with subtle shadow
- Width: 240px default, 320px on focus

**Context:** This is a targeted edit. Make only this change while preserving all existing elements.
```

### Example 3: Mobile App Screen

**User input:**
> "dashboard for fitness app"

**Enhanced output:**

```markdown
A vibrant, motivational fitness dashboard showing today's workout progress and health metrics.

**DESIGN SYSTEM (REQUIRED):**
- Platform: Mobile, iOS-style
- Theme: Light with colorful accents, energetic
- Background: Cool White (#f8fafc)
- Primary Accent: Electric Green (#22c55e) for progress and CTAs
- Secondary Accent: Warm Orange (#f97316) for calories/achievements
- Text Primary: Charcoal (#1f2937)
- Text Secondary: Cool Gray (#64748b)
- Cards: Large rounded (16px), white with soft shadows
- Typography: SF Pro Display style, bold headings

**Page Structure:**
1. **Header:** Greeting with user name, profile avatar, notification bell
2. **Today's Summary Card:** Circular progress ring (steps goal), calories burned, active minutes
3. **Current Workout:** Card with today's workout, duration, difficulty badge, "Start" button
4. **Weekly Stats:** Horizontal scrollable mini-cards showing daily activity
5. **Quick Actions:** Grid of action buttons (Log Meal, Add Workout, Track Water)
6. **Bottom Navigation:** Home, Workouts, Nutrition, Profile tabs
```

### Example 4: E-commerce Product Page

**User input:**
> "product page for sneakers"

**Enhanced output:**

```markdown
A premium, conversion-focused product page for sneakers with immersive imagery and compelling CTAs.

**DESIGN SYSTEM (REQUIRED):**
- Platform: Web, Mobile-first responsive
- Theme: Light, premium streetwear aesthetic
- Background: Pure White (#ffffff)
- Primary Accent: Bold Black (#0a0a0a) for primary buttons
- Secondary Accent: Vibrant Red (#ef4444) for sale price/urgency
- Text Primary: Rich Black (#171717)
- Text Secondary: Warm Gray (#525252)
- Cards: Subtle rounded (8px), minimal shadows
- Buttons: Pill-shaped, large touch targets
- Typography: Montserrat or similar, bold display headings

**Page Structure:**
1. **Breadcrumb Navigation:** Home > Sneakers > [Product Name]
2. **Product Gallery:** Large hero image with thumbnail carousel below
3. **Product Info:** Brand name, product title, star rating with review count
4. **Price Block:** Original price (strikethrough if sale), current price, "Limited Stock" badge
5. **Size Selector:** Grid of size buttons, "Size Guide" link
6. **Color Options:** Color swatches with labels
7. **Add to Cart Section:** Quantity selector, large "Add to Bag" button, wishlist icon
8. **Product Details:** Accordion with description, materials, shipping info
9. **Related Products:** Horizontal scroll of similar items
```

---

## Tips for Best Results

1. **Be specific early** — Vague inputs need more enhancement
2. **Match the user's intent** — Don't over-design if they want simple
3. **Keep it structured** — Numbered sections help Stitch understand hierarchy
4. **Include the design system** — Consistency is key for multi-page projects
5. **One change at a time for edits** — Don't bundle unrelated changes
6. **Use descriptive color names** — "Ocean Blue" is better than just "#1a365d"
7. **Consider the platform** — Mobile needs larger touch targets and simpler layouts

---

## Common Enhancement Patterns

### For Landing Pages

- Hero section with clear value proposition
- Social proof (testimonials, logos, stats)
- Feature highlights with icons
- Strong CTA above the fold
- Trust signals in footer

### For Dashboards

- Key metrics prominently displayed
- Data visualization (charts, graphs)
- Quick actions accessible
- Navigation clear and consistent
- Card-based layouts for sections

### For Forms

- Clear labels above inputs
- Logical field grouping
- Progress indicators for multi-step
- Validation feedback styling
- Prominent submit button

### For Mobile Apps

- Bottom navigation for primary actions
- Large touch targets (min 44pt)
- Swipeable carousels for content
- Pull-to-refresh patterns
- Floating action buttons for primary CTA

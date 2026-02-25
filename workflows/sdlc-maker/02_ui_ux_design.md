---
description: This workflow covers the UI/UX Design phase.
---
# Workflow: UI/UX Design

## Overview
This workflow covers the UI/UX Design phase. The goal is to design the user interface and experience to ensure usability and visual appeal.

## Output Location
**Base Folder:** `sdlc/02-ui-ux-design/`

**Output Files:**
- `user-flow-wireframes.md` - User Flow Documentation and Wireframes
- `high-fidelity-mockups.md` - High-Fidelity Mockups with Figma links
- `design-system.md` - Complete Design System and Style Guide

## Prerequisites
- Completed Requirement Analysis
- User personas defined
- Brand guidelines (if existing)
- Competitive analysis

## Deliverables

### 1. User Flow & Wireframes

**Description:** Visual path of the user through the application and basic layout.

**Recommended Skills:** `senior-ui-ux-designer`

**Instructions:**
1. Map user journeys based on personas
2. Create user flow diagrams showing:
   - Entry points
   - Decision points
   - Task completion paths
   - Error states
3. Design low-fidelity wireframes for key screens
4. Annotate wireframes with interaction notes

**Output Format:**
```markdown
## User Flow Documentation

### Flow 1: [Task Name]
**Entry Point:** [Where user starts]
**Steps:**
1. [Step 1]
2. [Step 2]
**Exit Point:** [Successful completion]
**Alternative Paths:**
- [Error scenario]
- [Alternative route]

## Wireframes
[Low-fidelity sketches or digital wireframes]
```

---

### 2. High-Fidelity Mockups

**Description:** Detailed visual design of the application screens.

**Recommended Skills:** `senior-ui-ux-designer`, `figma-specialist`

**Instructions:**
1. Create visual design system concepts
2. Design high-fidelity mockups for all key screens
3. Include:
   - Desktop views
   - Tablet views
   - Mobile responsive views
4. Create interactive prototype
5. Include micro-interactions and animations
6. Document design decisions

**Output Format:**
```markdown
## High-Fidelity Mockups

### Screen 1: [Screen Name]
**Purpose:** [What this screen does]
**Components:**
- [Component 1 with specs]
- [Component 2 with specs]
**Interactions:**
- [Interaction description]
**Responsive Behavior:**
- Desktop: [Layout]
- Mobile: [Layout]

[Link to Figma prototype]
```

---

### 3. Design System / Style Guide

**Description:** Consistent UI components, colors, and typography rules.

**Recommended Skills:** `design-system-architect`, `senior-ui-ux-designer`

**Instructions:**
1. Define color palette:
   - Primary colors
   - Secondary colors
   - Neutral/grayscale
   - Semantic colors (success, error, warning, info)
   - Dark mode variants (if applicable)
2. Create typography scale:
   - Font families
   - Heading hierarchy
   - Body text styles
   - Special text styles
3. Design component library:
   - Buttons (variants, states)
   - Form elements (input, select, checkbox, radio)
   - Cards and containers
   - Navigation elements
   - Icons
4. Define spacing system (8px grid recommended)
5. Create layout patterns
6. Document accessibility guidelines (WCAG compliance)

**Output Format:**
```markdown
# Design System

## Color Palette
### Primary
- Primary-500: #XXXXXX (Main brand color)
- Primary-100 to Primary-900: [Scale]

### Semantic Colors
- Success: #XXXXXX
- Error: #XXXXXX
- Warning: #XXXXXX
- Info: #XXXXXX

## Typography
### Font Families
- Primary: [Font name]
- Secondary: [Font name]

### Type Scale
- H1: 32px / Bold / Line-height 1.2
- H2: 24px / Bold / Line-height 1.3
- Body: 16px / Regular / Line-height 1.5

## Component Library
### Buttons
#### Primary Button
- Height: 44px
- Padding: 16px 24px
- Border-radius: 8px
- States: Default, Hover, Active, Disabled, Loading

[Component specifications continue...]

## Spacing System
- Base unit: 8px
- Scale: 4px, 8px, 16px, 24px, 32px, 48px, 64px
```

---

### 4. ASCII Wireframe Examples

**Description:** Low-fidelity text-based wireframes for quick visualization and iteration.

**Recommended Skills:** `senior-ui-ux-designer`

**Instructions:**
Create ASCII wireframes for key screens using consistent notation. These wireframes are useful for:
- Quick stakeholder reviews
- Documentation that renders in any markdown viewer
- AI-generated design drafts
- Version control friendly layouts

**Output Format:**

#### ASCII Notation Reference

| Symbol | Element | Example |
|--------|---------|---------|
| `┌─┐│└┘` | Container/border | `┌─────┐` |
| `[Text]` | Button/CTA | `[Submit]` |
| `(____)` | Text input | `(Enter email)` |
| `☐` | Checkbox (unchecked) | `☐ Agree` |
| `☑` | Checkbox (checked) | `☑ Agree` |
| `◉` | Radio (selected) | `◉ Option A` |
| `○` | Radio (unselected) | `○ Option B` |
| `>>>` | Link/Navigation | `>>> Details` |
| `===` | Divider/separator | `=== OR ===` |
| `*` | Required indicator | `Email *` |
| `✓` | Validation success | `✓ Valid` |
| `⚠` | Validation warning | `⚠ Too short` |
| `✗` | Validation error | `✗ Invalid` |
| `↓` | Dropdown/Select | `Country ↓` |
| `[X]` | Close/Dismiss | `[X]` |
| `☰` | Hamburger menu | `☰` |
| `🔍` | Search icon | `🔍` |
| `🛒` | Cart icon | `🛒` |
| `👤` | User/profile icon | `👤` |

---

#### Example 1: E-Commerce Homepage (Desktop)

```
┌─────────────────────────────────────────────────────────────────┐
│  [Logo]  Home  Products  Categories  About   🔍(Search...) 🛒 👤│  ← Navigation Bar
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│     🎉 BIG SALE - Up to 70% OFF!                                │
│     Discover amazing deals today                                │
│     [Shop Now]  [Learn More]                                    │
│                                                                 │  ← Hero Section
│                                                                 │
│                                                                 │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  Featured Products                                              │
│  ┌──────────────┐ ┌──────────────┐ ┌──────────────┐            │
│  │   [Image]    │ │   [Image]    │ │   [Image]    │            │
│  │ Product Name │ │ Product Name │ │ Product Name │            │
│  │    $99.99    │ │    $149.99   │ │    $79.99    │            │  ← Product Grid
│  │  ⭐⭐⭐⭐☆    │ │  ⭐⭐⭐⭐⭐    │ │  ⭐⭐⭐☆☆    │            │
│  │  [Add to Cart]│ │  [Add to Cart]│ │  [Add to Cart]│            │
│  └──────────────┘ └──────────────┘ └──────────────┘            │
│                                                                 │
│  [← Previous]  1  2  3  4  [Next →]                             │
│                                                                 │
├─────────────────────────────────────────────────────────────────┤
│  Categories                                                     │
│  [Electronics]  [Fashion]  [Home & Living]  [Sports]  [Books]  │
├─────────────────────────────────────────────────────────────────┤
│  Footer: About Us | Contact | Privacy Policy | Terms | © 2024   │
└─────────────────────────────────────────────────────────────────┘
```

---

#### Example 2: Login Screen

```
┌─────────────────────────────────────┐
│           Welcome Back              │
├─────────────────────────────────────┤
│                                     │
│   Email *                           │
│   (________________________________)│
│                                     │
│   Password *                        │
│   (________________________________)│
│                                     │
│   ☐ Remember me      >>> Forgot PW?│
│                                     │
│        [    Sign In    ]            │
│                                     │
│   ─────────── or ───────────        │
│                                     │
│   [Continue with Google]            │
│   [Continue with GitHub]            │
│                                     │
│   Don't have account? >>> Sign Up   │
│                                     │
└─────────────────────────────────────┘
```

---

#### Example 3: Registration Form with Validation

```
┌─────────────────────────────────────────────┐
│  Create Account                      [X]    │
├─────────────────────────────────────────────┤
│                                             │
│  Full Name *                                │
│  (John Doe______________________________)   │
│                                             │
│  Email *                                    │
│  (john@email.com________________________)   │
│  ✓ Valid email format                       │
│                                             │
│  Password *                                 │
│  (**********____________________________)   │
│  ⚠ Must contain 8+ characters               │
│  ⚠ Include uppercase, lowercase, number     │
│                                             │
│  Confirm Password *                         │
│  (**********____________________________)   │
│  ✗ Passwords do not match                   │
│                                             │
│  Phone Number                               │
│  (+62 ___-____-____)                        │
│                                             │
│  ☐ I agree to Terms & Conditions *          │
│  ☐ Subscribe to newsletter                  │
│                                             │
│       [  Create Account  ]                  │
│                                             │
│  Already have account? >>> Login            │
└─────────────────────────────────────────────┘
```

---

#### Example 4: Mobile Layout (Responsive)

```
┌─────────────────────┐
│ ☰  [Logo]    🛒 👤  │  ← Mobile Nav (Sticky)
├─────────────────────┤
│                     │
│   🎉 SALE 70% OFF   │
│   [Shop Now]        │  ← Hero Banner
│                     │
├─────────────────────┤
│  Categories         │
│  ┌───┐ ┌───┐ ┌───┐ │
│  │ 👕 │ │ 📱 │ │ 🏠 │ │
│  └───┘ └───┘ └───┘ │
├─────────────────────┤
│  Trending Products  │
│ ┌─────────────────┐ │
│ │    [Image]      │ │
│ │   Product Name  │ │
│ │     $99.99      │ │
│ │   [Add to Cart] │ │
│ └─────────────────┘ │
│ ┌─────────────────┐ │
│ │    [Image]      │ │
│ │   Product Name  │ │
│ │     $149.99     │ │
│ │   [Add to Cart] │ │
│ └─────────────────┘ │
├─────────────────────┤
│  🏠  🔍  🛒  👤     │  ← Bottom Tab Bar
└─────────────────────┘
```

---

#### Example 5: Dashboard Layout

```
┌─────────────────────────────────────────────────────────────────┐
│  [Logo]  Dashboard  Orders  Products  Customers  Analytics  👤  │
├────────┬────────────────────────────────────────────────────────┤
│        │                                                        │
│  MENU  │   Welcome back, John!                  🔔  📅  ⚙️      │
│        │                                                        │
│  ● Overview    │  ┌──────────┐ ┌──────────┐ ┌──────────┐       │
│  ● Orders      │  │  Revenue │ │  Orders  │ │ Customers│       │
│  ● Products    │  │  $12,450 │ │    245   │ │   1,234  │       │
│  ● Customers   │  │  ↑ 12%   │ │  ↑ 8%    │ │  ↑ 5%    │       │
│  ● Analytics   │  └──────────┘ └──────────┘ └──────────┘       │
│  ● Settings    │                                                │
│        │  Sales Overview                                         │
│  ────  │  ┌─────────────────────────────────────────────────┐   │
│  HELP  │  │         [Line Chart: Sales Trend]               │   │
│        │  │    J    F    M    A    M    J    J    A         │   │
│  [❓]  │  └─────────────────────────────────────────────────┘   │
│  [💬]  │                                                        │
│        │  Recent Orders                          [View All >>>]│
│        │  ┌────────────────────────────────────────────────┐   │
│        │  │ Order ID | Customer | Status  | Amount | Date  │   │
│        │  ├──────────┼──────────┼─────────┼────────┼───────┤   │
│        │  │ #ORD-001 │ John D.  │ ✓ Done  │ $150   │ Today │   │
│        │  │ #ORD-002 │ Jane S.  │ ⏳ Pending│ $89   │ Today │   │
│        │  │ #ORD-003 │ Bob W.   │ 🚚 Ship   │ $234  │ Yesterday│
│        │  └────────────────────────────────────────────────┘   │
└────────┴────────────────────────────────────────────────────────┘
```

---

#### Example 6: Data Table with Actions

```
┌─────────────────────────────────────────────────────────────────┐
│  Products Management                           [+ Add Product]  │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  🔍(Search products...)      [Filter ↓] [Sort ↓] [Export 📥]   │
│                                                                 │
│  ┌────────────────────────────────────────────────────────────┐│
│  │ ☐ │ Name │ Category │ Price │ Stock │ Status │ Actions    ││
│  ├───┼──────┼──────────┼───────┼───────┼────────┼────────────┤│
│  │ ☐ │ Prod │ Electronics│ $99  │  150  │ ✅ Active│ [✏️] [🗑️]││
│  │ ☐ │ Prod │ Fashion   │ $149 │   45  │ ✅ Active│ [✏️] [🗑️]││
│  │ ☐ │ Prod │ Home      │ $79  │    0  │ ⚠️ Low   │ [✏️] [🗑️]││
│  │ ☐ │ Prod │ Sports    │ $199 │   200 │ ✅ Active│ [✏️] [🗑️]││
│  │ ☐ │ Prod │ Books     │ $29  │   500 │ ✅ Active│ [✏️] [🗑️]││
│  └────────────────────────────────────────────────────────────┘│
│                                                                 │
│  Showing 1-5 of 50 entries                                      │
│  [← Previous]  [1] [2] [3] ... [10]  [Next →]                   │
│                                                                 │
│  Selected: 0 items  [Delete Selected 🗑️] [Export Selected 📥]  │
└─────────────────────────────────────────────────────────────────┘
```

---

#### Example 7: Modal/Dialog States

```
┌─────────────────────────────────────────────────────────────────┐
│                    (Background Page - Blurred)                  │
│                                                                 │
│         ┌─────────────────────────────────────────┐             │
│         │  ⚠️  Confirm Delete                     │             │
│         ├─────────────────────────────────────────┤             │
│         │                                         │             │
│         │  Are you sure you want to delete this   │             │
│         │  product? This action cannot be undone. │             │
│         │                                         │             │
│         │  Product: "Wireless Mouse"              │             │
│         │  SKU: PRD-00123                         │             │
│         │                                         │             │
│         │     [    Cancel    ] [Delete Permanently]             │
│         │                                         │             │
│         └─────────────────────────────────────────┘             │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘


Success Message (Toast):
┌─────────────────────────────────────────┐
│ ✓ Product saved successfully!     [X]   │
└─────────────────────────────────────────┘


Error Alert:
┌─────────────────────────────────────────┐
│ ✗ Error                               │
├─────────────────────────────────────────┤
│ ⚠️  Failed to process payment          │
│                                         │
│ Please check your card details and     │
│ try again. Error code: PAY-001         │
│                                         │
│        [  Try Again  ]  [  Cancel  ]    │
└─────────────────────────────────────────┘
```

---

#### Example 8: User Flow with Annotations

```
┌─────────────────┐
│   Landing Page  │
│   [Sign Up]     │
└────────┬────────┘
         │ Click Sign Up
         ▼
┌─────────────────┐
│  Register Form  │
│  - Email        │
│  - Password     │
│  [Create Acc]   │
└────────┬────────┘
         │ Submit
         ▼
    ┌─────────────┐
    │ Email Valid?│
    └──────┬──────┘
      Yes  │  No
           ▼
    ┌─────────────┐
    │ ✗ Error Msg │
    │ [Try Again] │
    └─────────────┘
           │
         Go Back
           │
           ▼
    ┌─────────────┐
    │ ✓ Success   │
    │ [Go to Login]│
    └─────────────┘
```

## Workflow Steps

1. **User Research** (Senior UI/UX Designer)
   - Review user personas
   - Analyze user needs and pain points
   - Study competitor designs

2. **Information Architecture** (Senior UI/UX Designer)
   - Create sitemap
   - Define navigation structure
   - Group related content

3. **User Flow Design** (Senior UI/UX Designer)
   - Map critical user journeys
   - Design flow diagrams
   - Identify edge cases

4. **ASCII Wireframe Creation** (Senior UI/UX Designer)
   - Create low-fidelity ASCII wireframes for all key screens
   - Use consistent notation (see ASCII Notation Reference)
   - Include desktop and mobile responsive layouts
   - Annotate with interaction notes and user flow arrows
   - Review with stakeholders for quick feedback

5. **Wireframing** (Senior UI/UX Designer)
   - Sketch initial layouts
   - Create digital low-fidelity wireframes (Figma/Balsamiq)
   - Reference ASCII wireframes as base structure
   - Review with stakeholders

6. **Visual Design** (Senior UI/UX Designer, Figma Specialist)
   - Create design system
   - Design high-fidelity mockups
   - Build interactive prototype

7. **Design System Creation** (Design System Architect)
   - Document all components
   - Create style guide
   - Prepare design tokens

8. **Usability Review**
   - Heuristic evaluation
   - Accessibility check (WCAG 2.1 AA)
   - Stakeholder presentation

## Success Criteria
- User flows cover all critical paths
- ASCII wireframes created for all key screens with consistent notation
- Wireframes approved by stakeholders
- Mockups are pixel-perfect and consistent
- Design system is comprehensive and reusable
- WCAG 2.1 AA accessibility compliance achieved
- Interactive prototype demonstrates all key flows

## Cross-References

- **Previous Phase** → `01_requirement_analysis.md`
- **Next Phase** → `02_ui_ux_design_part2.md` (for Stitch AI generation) or `03_system_detailed_design.md`
- **Related** → `06_data_modeling_estimation.md` (for UI-related data display)
- **SDLC Mapping** → `../../other/sdlc/SDLC_MAPPING.md`
- **Implementation** → `../flutter-bloc/`, `../flutter-getx/`, `../nextjs-frontend/`

## Tools & Templates
- Figma design files
- User flow diagram template
- Wireframe kit (digital)
- ASCII wireframe template (see examples above)
- ASCII notation reference card
- Design system documentation template
- Accessibility checklist

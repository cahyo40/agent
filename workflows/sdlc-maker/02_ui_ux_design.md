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

4. **Wireframing** (Senior UI/UX Designer)
   - Sketch initial layouts
   - Create low-fidelity wireframes
   - Review with stakeholders

5. **Visual Design** (Senior UI/UX Designer, Figma Specialist)
   - Create design system
   - Design high-fidelity mockups
   - Build interactive prototype

6. **Design System Creation** (Design System Architect)
   - Document all components
   - Create style guide
   - Prepare design tokens

7. **Usability Review**
   - Heuristic evaluation
   - Accessibility check (WCAG 2.1 AA)
   - Stakeholder presentation

## Success Criteria
- User flows cover all critical paths
- Wireframes approved by stakeholders
- Mockups are pixel-perfect and consistent
- Design system is comprehensive and reusable
- WCAG 2.1 AA accessibility compliance achieved
- Interactive prototype demonstrates all key flows

## Tools & Templates
- Figma design files
- User flow diagram template
- Wireframe kit
- Design system documentation template
- Accessibility checklist

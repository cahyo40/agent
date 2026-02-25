---
description: This workflow covers the translation of UI/UX designs into Stitch-optimized prompts and context.
---
# Workflow: Stitch Design Context & Prompts

## Overview
This workflow acts as the bridge between the **UI/UX Design** phase and the **Implementation** phase. It focuses on translating human-readable design systems, wireframes, and mockups into AI-optimized semantic formats (`DESIGN.md` and Stitch prompts) to ensure accurate, consistent, and high-quality UI generation by the Stitch AI.

## Output Location
**Base Folder:** `sdlc/02-ui-ux-design/stitch/`

**Output Files:**
- `stitch-design-context.md` - (Format `DESIGN.md` yang dikurasi khusus untuk Stitch)
- `stitch-screen-prompts.md` - (Kumpulan prompt siap-pakai untuk meng-generate layar demi layar)

## Prerequisites
- Completed `02_ui_ux_design.md` workflow.
- Approved User Flow & Wireframes (low-fidelity or ASCII).
- Approved Design System / Style Guide (color palette, typography, spacing, components).
- (Optional but recommended) High-Fidelity Mockups for exact visual reference.

## Deliverables

### 1. Stitch-Optimized Design System (`DESIGN.md`)

**Description:** Translating the visual Design System into semantic, natural language rules that the Stitch AI can understand and apply consistently across all generated screens.

**Recommended Skills:** `stitch-design-md`

**Instructions:**
1. Extract the core elements from the Design System (Colors, Typography, Spacing, Component rules).
2. Formulate these elements into semantic rules. Avoid relying solely on CSS values; use descriptive language (e.g., "Use Primary-500 (#XXXXXX) for all primary actions. Ensure minimum 44px touch targets for mobile interfaces.").
3. Document specific component behaviors and states (Hover, Active, Disabled).
4. Save the output as `stitch-design-context.md` (which will serve as the `DESIGN.md` during generation).

**Output Format Example:**
```markdown
# Design System Context for Stitch

## Core Philosophy
[Description of the overall vibe, e.g., "A clean, modern enterprise dashboard prioritizing data readability with a high-contrast minimalist aesthetic."]

## Color Tokens
- **Primary:** #3B82F6 (Blue) - Use for primary actions, active states, and key highlights.
- **Background:** #F9FAFB (Off-white) - Main app background.
- **Surface:** #FFFFFF (White) - Card and container backgrounds.
- **Text Primary:** #111827 (Dark Gray) - Main headings and body text.
- **Text Secondary:** #6B7280 (Medium Gray) - Subtitles, metadata, and placeholders.

## Typography
- **Font Family:** Inter (sans-serif)
- **Hierarchy:** Use bold, large fonts (24px+) for page titles. Use 14px-16px for standard body text.

## Component Rules
- **Buttons:** All buttons must have rounded corners (8px radius). Primary buttons use the Primary color background with white text.
- **Cards:** All cards must have a subtle drop shadow (`box-shadow: 0 1px 3px rgba(0,0,0,0.1)`) and 1px borders using #E5E7EB.
```

---

### 2. Stitch Screen Generation Prompts

**Description:** Writing highly detailed, specific prompts for each UI screen based on the approved user flows and wireframes. These prompts will act as the direct input for the `generate_screen_from_text` Stitch tool.

**Recommended Skills:** `stitch-enhance-prompt`

**Instructions:**
1. Review the User Flow and Wireframes for a specific screen.
2. Draft an initial description of the screen's purpose, layout, and required components.
3. Enhance the prompt to include specific structural instructions, layout patterns (e.g., CSS Grid/Flexbox expectations), and references to the `DESIGN.md` context.
4. Ensure the prompt clearly specifies interactive elements, empty states, and responsive behavior expectations.
5. Create a separate prompt for *every* unique screen defined in the wireframes.

**Output Format Example:**
```markdown
# Stitch Screen Prompts

## Screen: Login Page

**Base Wireframe Reference:**
[Link or ASCII representation of the login wireframe]

**Stitch Prompt:**
> Build a modern, responsive Login Page for the application. The layout should feature a centered authentication card on a subtle background gradient.
>
> **Structure:**
> - Top: Application Logo (centered).
> - Middle: A white card containing the login form. The form needs an Email input field, a Password input field (with an eye icon to toggle visibility), a "Remember Me" checkbox, and a "Forgot Password?" right-aligned link.
> - Action: A full-width Primary Button labeled "Sign In".
> - Bottom: A divider with the text "or continue with", followed by two outlined social login buttons for Google and GitHub. Include a "Don't have an account? Sign Up" link at the very bottom of the card.
>
> **Design Requirements (Refer to DESIGN.md):**
> Apply the primary color scheme. Ensure all inputs have a subtle focus ring. The card must have the standard drop shadow and border-radius.

## Screen: Dashboard Overview
... [Prompt for Dashboard]
```

## Workflow Steps

1. **Design System Translation** (`stitch-design-md`)
   - Analyze the output of the UI/UX Design phase (`design-system.md`).
   - Generate `stitch-design-context.md` focusing on semantic, AI-readable rules.

2. **Screen-by-Screen Prompt Drafting** (`stitch-enhance-prompt`)
   - Iterate through every screen defined in `user-flow-wireframes.md`.
   - Write a detailed, structural prompt for each screen.

3. **Prompt Refinement & Review**
   - Review drafts to ensure they explicitly reference patterns defined in `stitch-design-context.md`.
   - Verify that responsive behaviors and interactive states are mentioned in the prompts.
   - Finalize the `stitch-screen-prompts.md` document.

## Success Criteria
- A comprehensive `stitch-design-context.md` file exists and accurately reflects the visual design intent in semantic language.
- A `stitch-screen-prompts.md` file exists containing at least one highly detailed prompt for every screen defined in the wireframes.
- Prompts are specific enough that a generative AI can produce accurate, cohesive UIs without hallucinating components or styles.

## Cross-References
- **Previous Phase** → `02_ui_ux_design.md`
- **Next Phase** → Phase 03 / Implementation (where these prompts will be executed).
- **Related Tools** → Stitch API (`generate_screen_from_text`, `edit_screens`).

---
name: stitch-design-md
description: Analyzes Stitch projects and generates comprehensive DESIGN.md files documenting design systems in natural, semantic language optimized for Stitch screen generation.
allowed-tools:
  - "stitch*:*"
  - "mcp_stitch*"
  - "Read"
  - "Write"
  - "read_url_content"
  - "web_fetch"
---

# Stitch DESIGN.md Skill

You are an expert Design Systems Lead. Your goal is to analyze the provided technical assets and synthesize a "Semantic Design System" into a file named `DESIGN.md`.

## Overview

This skill helps you create `DESIGN.md` files that serve as the "source of truth" for prompting Stitch to generate new screens that align perfectly with existing design language. Stitch interprets design through "Visual Descriptions" supported by specific color values.

## Prerequisites

- Access to the Stitch MCP Server
- A Stitch project with at least one designed screen
- Access to the Stitch Effective Prompting Guide: <https://stitch.withgoogle.com/docs/learn/prompting/>

## The Goal

The `DESIGN.md` file will serve as the "source of truth" for prompting Stitch to generate new screens that align perfectly with the existing design language. Stitch interprets design through "Visual Descriptions" supported by specific color values.

## Retrieval and Networking

To analyze a Stitch project, you must retrieve screen metadata and design assets using the Stitch MCP Server tools:

1. **Namespace discovery**: Run `list_tools` to find the Stitch MCP prefix. Use this prefix (e.g., `mcp_stitch:`) for all subsequent calls.

2. **Project lookup** (if Project ID is not provided):
   - Call `mcp_stitch_list_projects` with `filter: "view=owned"` to retrieve all user projects
   - Identify the target project by title or URL pattern
   - Extract the Project ID from the `name` field (e.g., `projects/13534454087919359824`)

3. **Screen lookup** (if Screen ID is not provided):
   - Call `mcp_stitch_list_screens` with the `projectId` (just the numeric ID, not the full path)
   - Review screen titles to identify the target screen (e.g., "Home", "Landing Page")
   - Extract the Screen ID from the screen's `name` field

4. **Metadata fetch**:
   - Call `mcp_stitch_get_screen` with both `projectId` and `screenId` (both as numeric IDs only)
   - This returns the complete screen object including:
     - `screenshot.downloadUrl` - Visual reference of the design
     - `htmlCode.downloadUrl` - Full HTML/CSS source code
     - `width`, `height`, `deviceType` - Screen dimensions and target platform
     - Project metadata including `designTheme` with color and style information

5. **Asset download**:
   - Use `read_url_content` to download the HTML code from `htmlCode.downloadUrl`
   - Optionally download the screenshot from `screenshot.downloadUrl` for visual reference
   - Parse the HTML to extract Tailwind classes, custom CSS, and component patterns

6. **Project metadata extraction**:
   - Call `mcp_stitch_get_project` with the project `name` (full path: `projects/{id}`) to get:
     - `designTheme` object with color mode, fonts, roundness, custom colors
     - Project-level design guidelines and descriptions
     - Device type preferences and layout principles

---

## Analysis & Synthesis Instructions

### 1. Extract Project Identity (JSON)

- Locate the Project Title
- Locate the specific Project ID (e.g., from the `name` field in the JSON)

### 2. Define the Atmosphere (Image/HTML)

Evaluate the screenshot and HTML structure to capture the overall "vibe." Use evocative adjectives to describe the mood:

- "Airy" - lots of whitespace, light colors
- "Dense" - compact information, small gaps
- "Minimalist" - few elements, focused
- "Utilitarian" - functional over aesthetic
- "Luxurious" - premium feel, elegant typography
- "Playful" - rounded corners, vibrant colors
- "Corporate" - professional, structured
- "Futuristic" - gradients, glassmorphism, modern

### 3. Map the Color Palette (Tailwind Config/JSON)

Identify the key colors in the system. For each color, provide:

- A descriptive, natural language name that conveys its character (e.g., "Deep Muted Teal-Navy")
- The specific hex code in parentheses for precision (e.g., "#294056")
- Its specific functional role (e.g., "Used for primary actions")

**Color Categories:**

| Role | Description |
|------|-------------|
| Primary | Main brand color, CTAs |
| Secondary | Supporting accent |
| Background | Page/section backgrounds |
| Surface | Cards, modals, elevated elements |
| Text Primary | Headings, important text |
| Text Secondary | Body text, descriptions |
| Text Muted | Placeholders, hints |
| Border | Dividers, input borders |
| Success | Positive feedback |
| Warning | Caution states |
| Error | Error states |

### 4. Translate Geometry & Shape (CSS/Tailwind)

Convert technical `border-radius` and layout values into physical descriptions:

| Technical | Semantic Description |
|-----------|---------------------|
| `rounded-full` | "Pill-shaped, fully rounded" |
| `rounded-2xl` or `16px+` | "Generously rounded corners" |
| `rounded-lg` or `8px` | "Subtly rounded corners" |
| `rounded-md` or `6px` | "Gently softened edges" |
| `rounded-sm` or `4px` | "Barely rounded, almost square" |
| `rounded-none` or `0px` | "Sharp, squared-off edges" |

### 5. Describe Depth & Elevation

Explain how the UI handles layers. Describe the presence and quality of shadows:

| Style | Description |
|-------|-------------|
| Flat | "No shadows, completely flat design" |
| Subtle | "Whisper-soft diffused shadows for gentle lift" |
| Medium | "Moderate shadows creating clear hierarchy" |
| Heavy | "Strong, high-contrast drop shadows for drama" |
| Inset | "Inner shadows for pressed or recessed elements" |

---

## Output Guidelines

- **Language:** Use descriptive design terminology and natural language exclusively
- **Format:** Generate a clean Markdown file following the structure below
- **Precision:** Include exact hex codes for colors while using descriptive names
- **Context:** Explain the "why" behind design decisions, not just the "what"

## Output Format (DESIGN.md Structure)

```markdown
# Design System: [Project Title]

**Project ID:** [Insert Project ID Here]
**Device Type:** [Desktop/Mobile/Tablet]
**Last Updated:** [Date]

---

## 1. Visual Theme & Atmosphere

[Description of the mood, density, and aesthetic philosophy. Use evocative language.]

**Keywords:** [comma-separated mood keywords]

---

## 2. Color Palette & Roles

### Primary Colors
| Role | Name | Hex | Usage |
|------|------|-----|-------|
| Primary | [Descriptive Name] | #XXXXXX | [Usage description] |
| Secondary | [Descriptive Name] | #XXXXXX | [Usage description] |

### Neutral Colors
| Role | Name | Hex | Usage |
|------|------|-----|-------|
| Background | [Descriptive Name] | #XXXXXX | [Usage description] |
| Surface | [Descriptive Name] | #XXXXXX | [Usage description] |
| Text Primary | [Descriptive Name] | #XXXXXX | [Usage description] |
| Text Secondary | [Descriptive Name] | #XXXXXX | [Usage description] |

### Semantic Colors
| Role | Name | Hex | Usage |
|------|------|-----|-------|
| Success | [Descriptive Name] | #XXXXXX | [Usage description] |
| Warning | [Descriptive Name] | #XXXXXX | [Usage description] |
| Error | [Descriptive Name] | #XXXXXX | [Usage description] |

---

## 3. Typography Rules

**Primary Font:** [Font family name]
**Fallback:** [Fallback fonts]

| Element | Weight | Size | Usage |
|---------|--------|------|-------|
| Display | [Weight] | [Size] | [Usage] |
| Heading 1 | [Weight] | [Size] | [Usage] |
| Heading 2 | [Weight] | [Size] | [Usage] |
| Body | [Weight] | [Size] | [Usage] |
| Caption | [Weight] | [Size] | [Usage] |

**Character:** [Description of letter-spacing, line-height personality]

---

## 4. Component Stylings

### Buttons
- **Shape:** [Corner description]
- **Primary:** [Background color] with [text color], [hover behavior]
- **Secondary:** [Style description]
- **Ghost:** [Style description]

### Cards/Containers
- **Corners:** [Roundness description]
- **Background:** [Color assignment]
- **Shadow:** [Depth description]
- **Border:** [If any]

### Inputs/Forms
- **Style:** [Border or filled description]
- **Corners:** [Roundness]
- **Focus State:** [Description]
- **Labels:** [Position and style]

### Navigation
- **Style:** [Description]
- **Active State:** [How active items are indicated]

---

## 5. Layout Principles

- **Spacing System:** [Description of margin/padding patterns]
- **Grid:** [Column system if any]
- **Whitespace:** [Density description - airy, compact, balanced]
- **Alignment:** [Left, center, or mixed]

---

## 6. Design System Notes for Stitch Generation

**COPY THIS SECTION INTO YOUR STITCH PROMPTS**

```

**DESIGN SYSTEM (REQUIRED):**

- Theme: [Light/Dark], [mood keywords]
- Background: [Descriptive Name] (#hex)
- Surface: [Descriptive Name] (#hex) for cards and elevated elements
- Primary Accent: [Descriptive Name] (#hex) for buttons and links
- Text Primary: [Descriptive Name] (#hex) for headings
- Text Secondary: [Descriptive Name] (#hex) for body text
- Buttons: [Shape description], [color mapping]
- Cards: [Corner description], [shadow description]
- Typography: [Font family], [weight usage]
- Spacing: [Density description]

```
```

---

## Usage Example

To use this skill for analyzing a project:

1. **Ask me to analyze a Stitch project:**

   ```
   @stitch-design-md Analyze my "E-commerce Store" project and create a DESIGN.md
   ```

2. **I will retrieve and analyze:**
   - List all your Stitch projects
   - Find the specified project
   - Get screen details and HTML code
   - Extract all design tokens

3. **I will generate:**
   - Complete `DESIGN.md` file with semantic descriptions
   - Ready-to-use design system block for prompts

---

## Best Practices

- **Be Descriptive:** Avoid generic terms like "blue" or "rounded." Use "Ocean-deep Cerulean (#0077B6)" or "Gently curved edges"
- **Be Functional:** Always explain what each design element is used for
- **Be Consistent:** Use the same terminology throughout the document
- **Be Visual:** Help readers visualize the design through your descriptions
- **Be Precise:** Include exact values (hex codes, pixel values) in parentheses after natural language descriptions

## Tips for Success

1. **Start with the big picture:** Understand the overall aesthetic before diving into details
2. **Look for patterns:** Identify consistent spacing, sizing, and styling patterns
3. **Think semantically:** Name colors by their purpose, not just their appearance
4. **Consider hierarchy:** Document how visual weight and importance are communicated
5. **Reference the guide:** Use language and patterns from the Stitch Effective Prompting Guide

## Common Pitfalls to Avoid

- ❌ Using technical jargon without translation (e.g., "rounded-xl" instead of "generously rounded corners")
- ❌ Omitting color codes or using only descriptive names
- ❌ Forgetting to explain functional roles of design elements
- ❌ Being too vague in atmosphere descriptions
- ❌ Ignoring subtle design details like shadows or spacing patterns
- ❌ Not including the copy-paste block in Section 6

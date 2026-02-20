---
name: stitch-loop
description: Generates a complete multi-page website from a single prompt using Stitch, with automated file organization, navigation wiring, and baton-based iteration for continuous autonomous building.
allowed-tools:
  - "stitch*:*"
  - "mcp_stitch*"
  - "Bash"
  - "Read"
  - "Write"
  - "run_command"
  - "browser_subagent"
  - "read_url_content"
---

# Stitch Build Loop

## Overview

The Build Loop pattern enables continuous, autonomous website development through a "baton" system. Each iteration reads the current task from a baton file (`next-prompt.md`), generates a page using Stitch MCP tools, integrates the page into the site structure, and writes the next task to the baton file for the next iteration.

## When to Use This Skill

- Use when building multi-page websites iteratively with Stitch
- Use when automating website generation workflows
- Use when maintaining design consistency across multiple pages
- Use when implementing a continuous site-building loop

You are an **autonomous frontend builder** participating in an iterative site-building loop. Your goal is to generate a page using Stitch, integrate it into the site, and prepare instructions for the next iteration.

## Prerequisites

**Required:**

- Access to the Stitch MCP Server
- A Stitch project (existing or will be created)
- A `DESIGN.md` file (generate one using the `stitch-design-md` skill if needed)
- A `SITE.md` file documenting the site vision and roadmap

**Optional:**

- Browser tools — enables visual verification of generated pages

## The Baton System

The `next-prompt.md` file acts as a relay baton between iterations:

```markdown
---
page: about
---
A page describing how the product works.

**DESIGN SYSTEM (REQUIRED):**
[Copy from DESIGN.md Section 6]

**Page Structure:**
1. Header with navigation
2. Explanation of methodology
3. Team section with photos
4. Footer with links
```

**Critical rules:**

- The `page` field in YAML frontmatter determines the output filename
- The prompt content must include the design system block from `DESIGN.md`
- You MUST update this file before completing your work to continue the loop

---

## Execution Protocol

### Step 1: Read the Baton

Parse `next-prompt.md` to extract:

- **Page name** from the `page` frontmatter field
- **Prompt content** from the markdown body

### Step 2: Consult Context Files

Before generating, read these files:

| File | Purpose |
|------|---------|
| `SITE.md` | Site vision, **Stitch Project ID**, existing pages (sitemap), roadmap |
| `DESIGN.md` | Required visual style for Stitch prompts |

**Important checks:**

- Section 4 (Sitemap) — Do NOT recreate pages that already exist
- Section 5 (Roadmap) — Pick tasks from here if backlog exists
- Section 6 (Creative Freedom) — Ideas for new pages if roadmap is empty

### Step 3: Generate with Stitch

Use the Stitch MCP tools to generate the page:

1. **Discover namespace**: The Stitch tools use prefix `mcp_stitch_`

2. **Get or create project**:
   - If `stitch.json` exists, use the `projectId` from it
   - Otherwise, call `mcp_stitch_create_project` and save the ID to `stitch.json`

3. **Generate screen**: Call `mcp_stitch_generate_screen_from_text` with:
   - `projectId`: The project ID (numeric only)
   - `prompt`: The full prompt from the baton (including design system block)
   - `deviceType`: `DESKTOP` or `MOBILE` (as specified)

4. **Retrieve assets**: Call `mcp_stitch_get_screen` to get:
   - `htmlCode.downloadUrl` — Download and save as `queue/{page}.html`
   - `screenshot.downloadUrl` — Download and save as `queue/{page}.png`

### Step 4: Integrate into Site

1. Move generated HTML from `queue/{page}.html` to `site/public/{page}.html`
2. Fix any asset paths to be relative to the public folder
3. Update navigation:
   - Find existing placeholder links (e.g., `href="#"`) and wire them to the new page
   - Add the new page to the global navigation if appropriate
4. Ensure consistent headers/footers across all pages

### Step 4.5: Visual Verification (Optional)

If browser tools are available, verify the generated page:

1. **Start dev server**: Use Bash to start a local server (e.g., `npx serve site/public`)
2. **Navigate to page**: Use browser_subagent to open `http://localhost:3000/{page}.html`
3. **Capture screenshot**: Take a screenshot of the rendered page
4. **Visual comparison**: Compare against the Stitch screenshot (`queue/{page}.png`) for fidelity
5. **Stop server**: Terminate the dev server process

> **Note:** This step is optional. If browser tools are not available, skip to Step 5.

### Step 5: Update Site Documentation

Modify `SITE.md`:

- Add the new page to Section 4 (Sitemap) with `[x]`
- Remove any idea you consumed from Section 6 (Creative Freedom)
- Update Section 5 (Roadmap) if you completed a backlog item

### Step 6: Prepare the Next Baton (Critical)

**You MUST update `next-prompt.md` before completing.** This keeps the loop alive.

1. **Decide the next page**:
   - Check `SITE.md` Section 5 (Roadmap) for pending items
   - If empty, pick from Section 6 (Creative Freedom)
   - Or invent something new that fits the site vision

2. **Write the baton** with proper YAML frontmatter:

```markdown
---
page: achievements
---
A competitive achievements page showing developer badges and milestones.

**DESIGN SYSTEM (REQUIRED):**
[Copy the entire design system block from DESIGN.md]

**Page Structure:**
1. Header with title and navigation
2. Badge grid showing unlocked/locked states
3. Progress bars for milestone tracking
4. Footer with links
```

---

## File Structure Reference

```
project/
├── next-prompt.md      # The baton — current task
├── stitch.json         # Stitch project ID (persist this!)
├── DESIGN.md           # Visual design system (from stitch-design-md skill)
├── SITE.md             # Site vision, sitemap, roadmap
├── queue/              # Staging area for Stitch output
│   ├── {page}.html
│   └── {page}.png
└── site/public/        # Production pages
    ├── index.html
    └── {page}.html
```

---

## SITE.md Template

Create this file to define your site vision:

```markdown
# Site: [Project Name]

## 1. Vision
[One paragraph describing the site purpose and target audience]

## 2. Stitch Project
- **Project ID:** [From stitch.json after first generation]
- **Device Type:** Desktop / Mobile
- **Theme:** Light / Dark

## 3. Design Reference
See `DESIGN.md` for the complete design system.

## 4. Sitemap (Completed Pages)
- [x] index.html — Landing page
- [ ] about.html — About page
- [ ] pricing.html — Pricing page
- [ ] contact.html — Contact page

## 5. Roadmap (Next Up)
1. About page with team section
2. Pricing page with comparison table
3. Contact page with form

## 6. Creative Freedom (Future Ideas)
- Blog section
- Case studies
- Testimonials carousel
- FAQ accordion
```

---

## stitch.json Format

```json
{
  "projectId": "1234567890123456789",
  "projectName": "My Website",
  "createdAt": "2024-01-15T10:30:00Z",
  "screens": [
    {
      "screenId": "abc123def456",
      "pageName": "index",
      "generatedAt": "2024-01-15T10:35:00Z"
    }
  ]
}
```

---

## Orchestration Options

The loop can be driven by different orchestration layers:

| Method | How it works |
|--------|--------------|
| **CI/CD** | GitHub Actions triggers on `next-prompt.md` changes |
| **Human-in-loop** | Developer reviews each iteration before continuing |
| **Agent chains** | One agent dispatches to another |
| **Manual** | Developer runs the agent repeatedly with the same repo |

The skill is orchestration-agnostic — focus on the pattern, not the trigger mechanism.

---

## Design System Integration

This skill works best with the `stitch-design-md` skill:

1. **First time setup**: Generate `DESIGN.md` using the `stitch-design-md` skill from an existing Stitch screen
2. **Every iteration**: Copy Section 6 ("Design System Notes for Stitch Generation") into your baton prompt
3. **Consistency**: All generated pages will share the same visual language

---

## Common Pitfalls

- ❌ Forgetting to update `next-prompt.md` (breaks the loop)
- ❌ Recreating a page that already exists in the sitemap
- ❌ Not including the design system block in the prompt
- ❌ Leaving placeholder links (`href="#"`) instead of wiring real navigation
- ❌ Forgetting to persist `stitch.json` after creating a new project
- ❌ Not updating `SITE.md` after completing a page

---

## Troubleshooting

| Issue | Solution |
|-------|----------|
| Stitch generation fails | Check that the prompt includes the design system block |
| Inconsistent styles | Ensure DESIGN.md is up-to-date and copied correctly |
| Loop stalls | Verify `next-prompt.md` was updated with valid frontmatter |
| Navigation broken | Check all internal links use correct relative paths |
| Project not found | Verify `stitch.json` has correct projectId |

---

## Quick Start

1. **Initialize the project structure:**

   ```bash
   mkdir -p queue site/public
   ```

2. **Create SITE.md** with your vision

3. **Create or get DESIGN.md:**

   ```
   @stitch-design-md Analyze my existing Stitch project
   ```

   Or create manually following the template

4. **Create the first baton** (`next-prompt.md`):

   ```markdown
   ---
   page: index
   ---
   [Your landing page prompt with design system]
   ```

5. **Run the loop:**

   ```
   @stitch-loop Build the next page
   ```

6. **Repeat** — The agent will continue until the roadmap is empty

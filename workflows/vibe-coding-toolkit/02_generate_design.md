---
description: Generate DESIGN.md — Design system dalam format kode + Stitch UI/UX context dari sebuah PRD untuk vibe coding
version: 1.1.0
last_updated: 2026-03-14
skills:
  - vibe-coding-specialist
  - senior-ui-ux-designer
  - design-system-architect
  - stitch-design-md
  - stitch-enhance-prompt
---

// turbo-all

# Workflow: Generate DESIGN.md

## Agent Behavior

When executing this workflow, the agent MUST:
- Read PRD sections about UI/UX, colors, typography, spacing, and components
- Convert ALL design tokens from table/text format ke format KODE bahasa target
- Generate complete, copy-paste-ready code snippets
- Include helper methods (color selectors, formatters, etc.)
- Generate ThemeData / theme configuration
- Include widget composition examples (bukan hanya deskripsi)
- Include Screen layout template
- **Generate Stitch Design Context block** — semantic, natural-language design system optimized for Stitch AI screen generation
- **Generate Stitch Screen Prompts** — ready-to-use prompts for every screen in the PRD

## Overview

Generate file `DESIGN.md` dari sebuah PRD. File ini berisi:
1. **Design tokens dalam format kode** — langsung bisa di-copy AI ke source code
2. **Stitch Design Context** — semantic design system block yang bisa di-paste ke Stitch prompts
3. **Stitch Screen Prompts** — kumpulan prompt siap pakai untuk generate UI/UX setiap screen

## Input

- **PRD file** — Path ke Product Requirements Document
- **Output directory** — Folder tujuan output

## Output

- `{output_dir}/DESIGN.md` — Design tokens + Stitch context
- `{output_dir}/STITCH_PROMPTS.md` — Kumpulan prompt per screen untuk Stitch (optional, bisa digabung di DESIGN.md atau dipisah)

## Prerequisites

- PRD yang sudah mencakup:
  - Color palette (hex values)
  - Typography (font family, sizes, weights)
  - Spacing system (base unit, named spacings)
  - Component specs (buttons, cards, inputs, etc.)
  - Screen layouts / wireframes
  - Screen list dengan deskripsi masing-masing

## Steps

### Step 1: Extract Design Tokens dari PRD

Baca semua section UI/UX di PRD. Extract:
1. **Colors** — Primary, semantic, neutral, category-specific, status colors
2. **Typography** — Font family, text styles (headline, body, caption, etc.)
3. **Spacing** — Base unit, named spacings (xs, sm, md, lg, xl)
4. **Component specs** — Button height/radius, card elevation/radius, input height, etc.
5. **Animations** — Durations, curves, interaction types
6. **Category defaults** — Icons, colors per category (jika applicable)

### Step 2: Convert ke Format Kode

Untuk setiap token, convert ke format kode target:

**Flutter (Dart):**
```dart
// Warna: Color(0xFFHEXVAL)
static const Color primary = Color(0xFF1976D2);

// Typography: TextStyle(...)
static const TextStyle headline1 = TextStyle(fontSize: 32, fontWeight: FontWeight.w700);

// Spacing: double constants
static const double md = 16.0;
```

**React/Next.js (TypeScript):**
```typescript
// CSS Variables atau constants
export const colors = { primary: '#1976D2' } as const;
export const typography = { headline1: { fontSize: '32px', fontWeight: 700 } } as const;
```

**Vue/Nuxt:**
```typescript
// Similar to React, atau CSS custom properties
:root { --color-primary: #1976D2; }
```

### Step 3: Generate Code-Based Sections of DESIGN.md

Buat bagian code-based dari DESIGN.md:

```markdown
## 🎨 Color Palette
### AppColors Class
[Complete class dengan SEMUA warna dari PRD]

## 🔤 Typography
### AppTypography Class

## 📏 Spacing
### AppSpacing Class

## 🧩 Component Specifications
[Copy-paste-ready code untuk SETIAP component type]

## 🎬 Micro-Interactions
## 🎆 Theme Configuration
## 📱 Screen Layout Template
## 💰 Formatting Utilities
```

### Step 3b: Generate Stitch Design Context Block

Setelah code-based sections selesai, buat section khusus Stitch.

Gunakan prinsip dari skill `stitch-design-md`:
- **Bahasa semantik** — bukan hanya hex, tapi "Ocean Blue (#1976D2) for primary actions"
- **Deskriptif dan evocative** — describe vibe/atmosphere
- **Functional roles** — setiap warna punya role yang jelas
- **Component descriptions** — describe shape, depth, elevation secara natural

```markdown
## 🎯 Stitch Design Context

> **COPY SECTION INI KE SETIAP PROMPT STITCH UNTUK KONSISTENSI VISUAL**

### Visual Atmosphere
[Deskripsi mood/vibe keseluruhan app, contoh:]
"A clean, trustworthy personal finance app with a calming blue palette,
 generous whitespace, and soft card-based layouts. The design communicates
 stability and control over personal finances."

**Keywords:** [clean, modern, financial, trustworthy, card-based, soft shadows]

### Design System Block (Copy-Paste untuk Stitch)
\```
**DESIGN SYSTEM (REQUIRED):**
- Platform: [Mobile/Web], [device-first] orientation
- Theme: [Light/Dark], [mood keywords]
- Background: [Descriptive Name] (#hex) — [usage]
- Surface: [Descriptive Name] (#hex) — for cards and elevated elements
- Primary Accent: [Descriptive Name] (#hex) — for buttons, links, active states
- Secondary Accent: [Descriptive Name] (#hex) — for secondary actions
- Success: [Descriptive Name] (#hex) — for positive feedback, income
- Warning: [Descriptive Name] (#hex) — for caution states
- Error/Danger: [Descriptive Name] (#hex) — for errors, expense, budget exceeded
- Text Primary: [Descriptive Name] (#hex) — for headings and important text
- Text Secondary: [Descriptive Name] (#hex) — for body text and descriptions
- Text Muted: [Descriptive Name] (#hex) — for placeholders and hints
- Buttons: [Shape description, e.g. "subtly rounded (8px), full-width on forms"]
- Cards: [Corner description], [shadow description], [background]
- Inputs: [Style, e.g. "outlined with subtle gray border, rounded 8px"]
- Typography: [Font family], [weight hierarchy description]
- Spacing: [Density: airy/compact/balanced], [base unit]
- Icons: [Style, e.g. "Material Design outlined icons, 24px default"]
\```

### Color Palette Table (Stitch-Optimized)
| Role | Descriptive Name | Hex | Usage |
|------|-----------------|-----|-------|
| Primary | [e.g. "Calm Ocean Blue"] | #1976D2 | Primary actions, active states |
| Secondary | [e.g. "Soft Teal"] | #26A69A | Secondary actions, accents |
| Background | [e.g. "Cool Off-White"] | #F5F5F5 | Main app background |
| Surface | [e.g. "Pure White"] | #FFFFFF | Cards, sheets, dialogs |
| Text Primary | [e.g. "Deep Charcoal"] | #212121 | Headings, important text |
| ... | ... | ... | ... |

### Component Styling Guide (Stitch-Optimized)

#### Buttons
- **Primary:** [Descriptive, e.g. "Solid Ocean Blue background with white text, subtly rounded corners (8px), full-width on mobile forms"]
- **Secondary:** [e.g. "Outlined with Ocean Blue border and text, transparent background"]
- **Destructive:** [e.g. "Solid Coral Red background for delete/remove actions"]

#### Cards
- **Shape:** [e.g. "Generously rounded corners (12px), whisper-soft shadow for gentle lift"]
- **Background:** [e.g. "Pure White surface on Cool Off-White background"]
- **Interaction:** [e.g. "Subtle elevation increase on tap/hover"]

#### Navigation
- **Type:** [e.g. "Bottom navigation bar with 4-5 items"]
- **Active State:** [e.g. "Filled icon with Ocean Blue accent, label visible"]
- **Inactive State:** [e.g. "Outlined icon in Medium Gray, label hidden or muted"]

#### Inputs
- **Default:** [e.g. "Outlined with Light Gray border, rounded 8px, label floats above on focus"]
- **Focus:** [e.g. "Border color changes to Ocean Blue, subtle glow ring"]
- **Error:** [e.g. "Border changes to Coral Red, error text below in red"]

#### Lists/Tiles
- **Style:** [e.g. "Full-width card rows with leading icon, title, subtitle, and trailing amount"]
- **Divider:** [e.g. "Thin 1px light gray divider between items"]
- **Swipe:** [e.g. "Swipe left reveals red delete action"]
```

### Step 3c: Generate Stitch Screen Prompts

Untuk SETIAP screen yang ada di PRD, buat prompt yang sudah dioptimasi menggunakan prinsip dari skill `stitch-enhance-prompt`.

Setiap prompt harus:
1. Mulai dengan one-line description tentang purpose dan vibe
2. Include **DESIGN SYSTEM (REQUIRED)** block (copy dari Step 3b)
3. Include **Page Structure** yang numbered dan spesifik
4. Reference specific component styles
5. Sebutkan platform/device type

Format per screen:

```markdown
### Screen [#]: [Nama Screen]

**Route:** [route path]
**Device Type:** MOBILE / DESKTOP
**PRD Reference:** Section [X.Y]

**Stitch Prompt:**
> [One-line description, e.g. "A clean, organized personal finance dashboard
> showing account balance, recent transactions, and budget overview."]
>
> **DESIGN SYSTEM (REQUIRED):**
> [Paste design system block]
>
> **Page Structure:**
> 1. **Header:** [Description, e.g. "App bar with 'Yo Money' title on left, notification bell on right"]
> 2. **Balance Card:** [Description, e.g. "Large prominent card showing total balance in bold, with month indicator"]
> 3. **Quick Summary:** [Description, e.g. "Two side-by-side mini cards: green income card, red expense card"]
> 4. **Quick Actions:** [Description, e.g. "Row of 3 circular action buttons: Add Transaction, Scan Receipt, Budget"]
> 5. **Recent Transactions:** [Description, e.g. "Section title 'Recent' with 'See All' link, followed by 5 transaction tiles"]
> 6. **Bottom Navigation:** [Description, e.g. "4 tabs: Home(active), Transactions, Budget, Settings"]
>
> **Interactive Elements:**
> - [e.g. "Balance card tap → opens transaction history"]
> - [e.g. "FAB button for quick add transaction"]
>
> **Empty State:** [Description jika data kosong]
```

Buat prompt untuk SEMUA screens dari PRD, grouped by feature.

### Step 4: Compile DESIGN.md

Gabungkan semua sections menjadi satu file DESIGN.md:

```markdown
# 🎨 DESIGN.md — Design System & Stitch Prompts
# {Nama Project}

> **File ini berisi design tokens dalam format kode DAN Stitch-optimized prompts.**

---

## BAGIAN A: Design Tokens (Kode)

[Step 2-3 output: AppColors, AppTypography, AppSpacing, etc.]

---

## BAGIAN B: Stitch Design Context

[Step 3b output: atmosphere, design system block, component styling guide]

---

## BAGIAN C: Stitch Screen Prompts

[Step 3c output: prompt per screen]

---
```

**Alternatif:** Jika file terlalu panjang, pisahkan Stitch prompts ke file terpisah:
- `DESIGN.md` — Bagian A + B
- `STITCH_PROMPTS.md` — Bagian C saja

### Step 5: Validasi

Sebelum menyimpan, validasi:

**Code Tokens:**
- [ ] Semua warna dari PRD sudah diconvert ke kode
- [ ] Semua text styles dari PRD sudah diconvert
- [ ] Semua spacing values dari PRD sudah diconvert
- [ ] Component specs lengkap (button, card, input, dialog, tile)
- [ ] Theme configuration lengkap
- [ ] Code snippets valid syntax
- [ ] Helper methods included
- [ ] Screen template included

**Stitch Context:**
- [ ] Design System block lengkap (semua roles: primary, secondary, background, surface, text, etc.)
- [ ] Atmosphere/vibe description evocative dan accurate
- [ ] Color table menggunakan descriptive names + hex
- [ ] Component styling guide covers: buttons, cards, navigation, inputs, lists
- [ ] Keywords relevant dan membantu

**Stitch Prompts:**
- [ ] SETIAP screen dari PRD punya prompt
- [ ] Setiap prompt punya Page Structure yang numbered
- [ ] Setiap prompt include design system block reference
- [ ] Device type specified per screen
- [ ] Interactive elements dan empty states described
- [ ] Prompts cukup spesifik — Stitch tidak perlu menebak

### Step 6: Simpan File

Simpan ke `{output_dir}/DESIGN.md` (dan optionally `{output_dir}/STITCH_PROMPTS.md`)

## Quality Criteria

**Code Tokens:**
- Setiap token HARUS dalam format kode target (BUKAN tabel hex)
- Code HARUS copy-paste ready (langsung jadi file source code)
- Theme configuration HARUS menggabungkan semua tokens
- Component specs HARUS include actual widget code

**Stitch Context:**
- Design system block HARUS menggunakan bahasa semantik/deskriptif
- Warna HARUS punya descriptive name DAN hex code
- Component descriptions HARUS include shape, depth, interaction behavior
- Block HARUS bisa di-copy-paste langsung ke prompt Stitch

**Stitch Prompts:**
- Setiap prompt HARUS structured (numbered sections)
- Prompts HARUS specific enough untuk accurate generation tanpa guessing
- Prompts HARUS consistent — semuanya reference design system yang sama
- Total screen prompts HARUS match jumlah screens di PRD

## Example Prompts

### Generate Design + Stitch (Default)
```
Jalankan workflow vibe-coding-toolkit/02_generate_design.md

PRD: @agents/docs/plans/my-app-prd.md
Output: prd/my-app/DESIGN.md
Tech stack: Flutter (Dart)
```

### Generate Design + Stitch (File Terpisah)
```
Jalankan workflow vibe-coding-toolkit/02_generate_design.md

PRD: @agents/docs/plans/my-app-prd.md
Output: prd/my-app/
Tech stack: Flutter (Dart)
Pisahkan Stitch prompts ke file terpisah (STITCH_PROMPTS.md)
```

### Generate Stitch Prompts Saja (Jika DESIGN.md Sudah Ada)
```
Jalankan workflow vibe-coding-toolkit/02b_generate_stitch_prompts.md

PRD: @agents/docs/plans/my-app-prd.md
DESIGN.md: @prd/my-app/DESIGN.md
Output: prd/my-app/STITCH_PROMPTS.md
```

---

## Cara Menggunakan Stitch Prompts

### Generate UI di Stitch (Manual)
1. Buka Stitch project
2. Copy **Design System block** dari DESIGN.md Section B
3. Copy **Screen prompt** dari DESIGN.md Section C
4. Gabungkan dan paste ke Stitch generate_screen_from_text

### Generate UI di Stitch (via MCP)
```
Gunakan Stitch MCP tools untuk generate screen.

Project: [stitch project id]
Design Context: @prd/my-app/DESIGN.md (Section B: Stitch Design Context)
Screen Prompt: [copy dari DESIGN.md Section C, screen yang diinginkan]
Device Type: MOBILE
```

### Edit Existing Stitch Screen
```
Edit screen [screen_id] pada project [project_id].

Perubahan: [deskripsi perubahan]

Pastikan tetap mengikuti design system:
[paste design system block dari DESIGN.md]
```

---

## Cross-References

- **Sub-workflow:** `02b_generate_stitch_prompts.md` — generate Stitch prompts terpisah
- **Output digunakan oleh:** `03_generate_ai_instructions.md`, `05_generate_architecture.md`
- **Skills terkait:** `stitch-design-md`, `stitch-enhance-prompt`
- **Sumber data:** PRD (UI/UX guidelines, color palette, typography, component specs, screen list)

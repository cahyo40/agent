---
description: Phase 3 — Generate DESIGN.md (Stitch-optimized design system) dari evaluasi desain
version: 1.0.0
last_updated: 2026-04-11
skills:
  - senior-ui-ux-designer
  - stitch-design-md
  - design-system-architect
---

// turbo-all

# Workflow: Generate Design System (DESIGN.md)

## Agent Behavior

When executing this workflow, the agent MUST:
- Baca `evaluasi_desain.md` sebagai sumber utama
- Baca `input_user.md` untuk validasi bahwa design system sesuai keinginan user
- Gunakan skill `stitch-design-md` untuk format yang dioptimasi Stitch
- Generate DESIGN.md lengkap dengan **Section 6: Design System Notes** yang siap copy-paste ke prompt
- Validasi accessibility (WCAG AA contrast ratio ≥ 4.5:1 untuk text)
- Include SEMUA design tokens yang dibutuhkan: colors, typography, spacing, shapes, shadows, components

## Overview

Menghasilkan `DESIGN.md` — file design system yang menjadi "source of truth" untuk visual consistency. File ini berisi design tokens dalam format semantik yang dioptimasi untuk Stitch AI generation DAN untuk code conversion.

## Input

- **Evaluasi desain** — `ui-ux/{project-name}/evaluasi_desain.md`
- **Instruksi user** — `ui-ux/{project-name}/input_user.md`
- **Output directory** — `ui-ux/{project-name}/`

## Output

- `{output_dir}/DESIGN.md`

## Prerequisites

- Phase 2 sudah selesai (`evaluasi_desain.md` tersedia)
- Skill `stitch-design-md` accessible

## Steps

### Step 1: Extract Design Direction

Dari `evaluasi_desain.md` → section "Design Direction", extract:
1. Design style yang diputuskan
2. Color palette yang direkomendasikan
3. Typography pairing yang dipilih
4. Layout approach (sidebar vs top bar, grid system)
5. Component styling direction (glassmorphism, flat, material, dll)

### Step 2: Define Visual Theme & Atmosphere

Tulis deskripsi atmosfer visual dalam bahasa natural/evocative:

```markdown
## 1. Visual Theme & Atmosphere

**Theme Name:** "[Nama unik, contoh: The Digital Curator]"
**Style:** [Design style, contoh: Soft Glassmorphism]
**Mood:** [Descriptive, contoh: Premium, airy, spacious, trustworthy]
**Atmosphere:** [Paragraph, contoh: "A refined analytics workspace that
breathes — generous whitespace with frosted glass panels floating over
a cool lavender-gray canvas. Every element feels precise yet effortless."]
**Keywords:** [clean, modern, glassmorphism, spacious, premium, analytical]
```

### Step 3: Define Color Palette

Buat color palette lengkap dengan:
- **Descriptive name** — "Twilight Indigo" bukan hanya "#4F46E5"
- **Hex code** — Warna yang exact
- **Role** — Fungsi warna (primary action, background, text, dll)
- **Usage** — Kapan dan di mana dipakai

```markdown
## 2. Color Palette & Roles

| Role | Descriptive Name | Hex | Usage |
|------|-----------------|-----|-------|
| Primary | Deep Indigo | #4F46E5 | Buttons, active tabs, links |
| Secondary | Soft Violet | #7C3AED | Accents, secondary actions |
| Background | Cool Lavender-Gray | #F0EEFF | Main app background |
| Surface | Frosted White | #FFFFFF | Cards, panels (with opacity) |
| Text Primary | Midnight Slate | #1E293B | Headings, important text |
| Text Secondary | Cool Gray | #64748B | Body text, descriptions |
| Text Muted | Silver Gray | #94A3B8 | Placeholders, hints |
| Success | Fresh Emerald | #10B981 | Positive states, growth |
| Warning | Warm Amber | #F59E0B | Caution states |
| Error | Coral Red | #EF4444 | Errors, negative states |
| Info | Sky Blue | #3B82F6 | Informational badges |
```

### Step 4: Define Typography

```markdown
## 3. Typography

**Primary Font:** [Font family, contoh: Plus Jakarta Sans]
**Fallback:** [Fallback stack, contoh: sans-serif]

| Style | Size | Weight | Line Height | Usage |
|-------|------|--------|-------------|-------|
| Display | 32px | 800 ExtraBold | 1.2 | Page titles |
| Heading 1 | 24px | 700 Bold | 1.3 | Section headers |
| Heading 2 | 20px | 600 SemiBold | 1.3 | Sub-headers |
| Heading 3 | 16px | 600 SemiBold | 1.4 | Card titles |
| Body | 14px | 400 Regular | 1.6 | Body text |
| Caption | 12px | 500 Medium | 1.4 | Labels, captions |
| Overline | 11px | 600 SemiBold | 1.5 | Category labels |
```

### Step 5: Define Spacing & Layout

```markdown
## 4. Spacing & Layout

**Base Unit:** 4px
**Scale:** 4, 8, 12, 16, 20, 24, 32, 40, 48, 64

| Name | Value | Usage |
|------|-------|-------|
| xs | 4px | Tight inline gaps |
| sm | 8px | Related elements |
| md | 16px | Standard spacing |
| lg | 24px | Section spacing |
| xl | 32px | Between major sections |
| 2xl | 48px | Page-level spacing |

**Grid:** [Column count, gutter, margin]
**Navigation:** [Type: top bar / sidebar / bottom bar]
**Container:** [Max width, padding]
```

### Step 6: Define Component Styles

```markdown
## 5. Component Styling

### Buttons
- **Primary:** [Color, border-radius, padding, hover state]
- **Secondary:** [Outlined style description]
- **Ghost:** [Transparent style description]

### Cards
- **Standard:** [Background, border-radius, shadow, padding]
- **Glassmorphism (if applicable):** [Backdrop-filter, opacity, border]
- **Interactive:** [Hover state, click animation]

### Inputs
- **Default:** [Border, background, border-radius]
- **Focus:** [Border color, shadow/glow]
- **Error:** [Border color, error text placement]

### Badges/Tags
- **Success:** [Background, text color, border-radius]
- **Warning:** [Background, text color]
- **Error:** [Background, text color]

### Navigation
- **Active Item:** [Color, indicator style]
- **Inactive Item:** [Color, opacity]
- **Hover:** [Transition, background change]
```

### Step 7: Generate Section 6 — Design System Notes (KRUSIAL)

> **INI ADALAH BAGIAN PALING PENTING.** Section ini di-copy langsung ke setiap prompt Stitch.

```markdown
## 6. Design System Notes (Stitch Copy-Paste Block)

> **COPY BLOK DI BAWAH INI KE SETIAP PROMPT STITCH**

\```
DESIGN SYSTEM (REQUIRED):
- Platform: [Web/Mobile], [device] orientation
- Theme: [Light/Dark], [mood keywords]
- Background: [Name] (#hex) — [usage]
- Surface: [Name] (#hex) — for cards and elevated elements
- Primary Accent: [Name] (#hex) — for buttons, links, active states
- Secondary Accent: [Name] (#hex) — for secondary actions
- Success: [Name] (#hex) — positive feedback
- Warning: [Name] (#hex) — caution states
- Error: [Name] (#hex) — errors and danger
- Text Primary: [Name] (#hex) — headings
- Text Secondary: [Name] (#hex) — body text
- Text Muted: [Name] (#hex) — placeholders
- Buttons: [Shape and style description]
- Cards: [Corner, shadow, background description]
- Inputs: [Style description]
- Typography: [Font family], [weight hierarchy]
- Spacing: [Density], [base unit]
- Icons: [Style and default size]
\```
```

### Step 8: Compile DESIGN.md

Gabungkan semua sections:

```markdown
# 🎨 DESIGN.md — Design System
# {Project Name}

> **Source of Truth untuk semua keputusan visual.**

---

## 1. Visual Theme & Atmosphere
[Step 2 output]

## 2. Color Palette & Roles
[Step 3 output]

## 3. Typography
[Step 4 output]

## 4. Spacing & Layout
[Step 5 output]

## 5. Component Styling
[Step 6 output]

## 6. Design System Notes (Stitch Copy-Paste Block)
[Step 7 output — PALING PENTING]

---
```

### Step 9: Validasi

Sebelum menyimpan, validasi:
- [ ] Visual atmosphere deskriptif dan evocative
- [ ] SEMUA warna punya descriptive name + hex + role
- [ ] WCAG AA contrast check: text primary on background ≥ 4.5:1
- [ ] WCAG AA contrast check: text secondary on background ≥ 4.5:1
- [ ] Typography hierarchy lengkap (display → caption)
- [ ] Spacing scale konsisten (berbasis base unit)
- [ ] Component styles mencakup: buttons, cards, inputs, badges, navigation
- [ ] Section 6 lengkap dan siap copy-paste ke prompt Stitch
- [ ] Tidak ada warna/font yang undefined — semua punya role yang jelas

### Step 10: Update Progress

Update `progress.md`:
```
| 3. Design System | ✅ | [tanggal] | DESIGN.md created |
```

## Quality Criteria

- DESIGN.md HARUS self-contained — bisa dipahami tanpa referensi ke file lain
- Section 6 HARUS lengkap dan bisa langsung di-copy-paste ke prompt Stitch
- Warna HARUS punya descriptive names (bukan hanya hex)
- Accessibility HARUS divalidasi (WCAG AA minimum)
- Typography HARUS punya hierarchy yang jelas

## Example Prompt

```
Jalankan workflow ui-ux-generator/03_generate_design_system.md

Evaluasi: @ui-ux/dashboard-001/evaluasi_desain.md
Input: @ui-ux/dashboard-001/input_user.md
Output: ui-ux/dashboard-001/DESIGN.md
```

---

## Cross-References

- **Depends on:** `02_evaluasi_desain.md` (evaluasi_desain.md)
- **Output digunakan oleh:** `04_prompt_engineering.md`, `07_code_conversion.md`
- **Skills yang digunakan:** `senior-ui-ux-designer`, `stitch-design-md`, `design-system-architect`

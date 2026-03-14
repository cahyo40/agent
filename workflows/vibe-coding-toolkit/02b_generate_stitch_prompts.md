---
description: Generate STITCH_PROMPTS.md — Kumpulan prompt Stitch siap pakai untuk generate UI/UX setiap screen dari PRD
version: 1.0.0
last_updated: 2026-03-14
skills:
  - stitch-enhance-prompt
  - stitch-design-md
  - stitch-loop
  - senior-ui-ux-designer
---

// turbo-all

# Workflow: Generate Stitch Screen Prompts

## Agent Behavior

When executing this workflow, the agent MUST:
- Read PRD sections about screens, wireframes, dan UI specs
- Read DESIGN.md (jika ada) untuk extract Stitch Design Context
- Gunakan skill `stitch-enhance-prompt` untuk enhance setiap prompt
- Buat satu prompt per screen — SETIAP screen di PRD harus punya prompt
- Prompts HARUS spesifik: include Page Structure, Design System block, dan Interactive Elements
- Group prompts berdasarkan feature
- Bisa dieksekusi via Stitch MCP tools (`generate_screen_from_text`, `edit_screens`)

## Overview

Generate file `STITCH_PROMPTS.md` dari sebuah PRD. File ini berisi kumpulan prompt yang sudah di-enhance dan dioptimasi untuk Stitch AI screen generation. Setiap prompt siap di-copy-paste ke Stitch atau dijalankan via MCP tools.

**Kapan menggunakan workflow ini:**
- Saat DESIGN.md sudah ada dan Anda ingin generate prompts terpisah
- Saat ingin membuat UI/UX mockup di Stitch sebelum coding
- Saat ingin iterasi desain tanpa mempengaruhi file DESIGN.md

## Input

- **PRD file** — Path ke Product Requirements Document
- **DESIGN.md** — File design system (yang sudah ada Stitch Design Context block)
- **Output directory** — Folder tujuan output

## Output

- `{output_dir}/STITCH_PROMPTS.md`

## Prerequisites

- PRD yang mencakup daftar screens dan deskripsi per screen
- DESIGN.md yang sudah ada Stitch Design Context block (dari workflow 02)
- Jika DESIGN.md belum ada, jalankan `02_generate_design.md` dulu

## Steps

### Step 1: Extract Screen List dari PRD

Baca PRD dan buat list lengkap semua screens:

```
Contoh untuk Finance App:
| # | Screen | Route | Feature |
|---|--------|-------|---------|
| 1 | OnboardingScreen | /onboarding | onboarding |
| 2 | DashboardScreen | /dashboard | dashboard |
| 3 | TransactionsScreen | /transactions | transactions |
| ... | ... | ... | ... |
```

### Step 2: Extract Design System Block dari DESIGN.md

Ambil section **Stitch Design Context** > **Design System Block** dari DESIGN.md.

Block ini akan di-include ke setiap prompt sebagai **DESIGN SYSTEM (REQUIRED)**.

Jika DESIGN.md tidak ada atau tidak punya Stitch section:
1. Generate design context block langsung dari PRD (warna, typography, component specs)
2. Gunakan prinsip dari skill `stitch-design-md` (semantic naming, functional roles)

### Step 3: Enhance Prompts per Screen

Untuk setiap screen, apply enhancement pipeline dari `stitch-enhance-prompt`:

#### 3a. Assess & Fill Gaps
Untuk setiap screen, pastikan prompt mencakup:

| Element | Cek | Aksi jika missing |
|---------|-----|-------------------|
| Platform | "mobile", "web", "tablet" | Default dari PRD target platform |
| Page type | "dashboard", "form", "list" | Infer dari description |
| Structure | Numbered sections | Buat berdasarkan wireframe/PRD |
| Visual style | Mood descriptors | Ambil dari Design Context atmosphere |
| Colors | Reference ke design system | Include design system block |
| Components | Specific UI terms | Translate ke proper keywords |
| Empty state | Apa yang tampil jika data kosong | Tambahkan deskripsi |
| Interactive elements | Tap, swipe, scroll behavior | Tambahkan per element |

#### 3b. Apply UI/UX Keyword Enhancement

Replace vague terms dengan specific component names:

| Vague | Enhanced |
|-------|----------|
| "menu di atas" | "navigation bar with app title and action icons" |
| "tombol" | "primary call-to-action button, full-width" |
| "daftar item" | "vertical list with leading icon, title, subtitle, and trailing value" |
| "form input" | "outlined text field with floating label" |
| "grafik" | "line chart with gradient fill, interactive touch points" |
| "kartu" | "elevated card with rounded corners and soft shadow" |

#### 3c. Structure the Page (WAJIB)

Setiap prompt HARUS punya numbered Page Structure:

```
**Page Structure:**
1. **Header:** [specific description]
2. **[Section Name]:** [what it shows, how it looks]
3. **[Section Name]:** [components, layout, data]
...
N. **[Footer/Navigation]:** [description]
```

#### 3d. Format Final Prompt

```markdown
### Screen [#]: [Nama Screen]

**Route:** [route path]
**Device Type:** MOBILE / DESKTOP / TABLET
**PRD Reference:** Section [X.Y]
**Feature:** [feature category]

**Stitch Prompt:**
> [One-line purpose + vibe]
>
> **DESIGN SYSTEM (REQUIRED):**
> [Paste design system block]
>
> **Page Structure:**
> 1. **[Section]:** [Description]
> 2. **[Section]:** [Description]
> ...
>
> **Interactive Elements:**
> - [element → action]
>
> **States:**
> - **Loading:** [shimmer/skeleton description]
> - **Empty:** [empty state description]
> - **Error:** [error state description]
```

### Step 4: Group by Feature

Organize prompts berdasarkan feature/module:

```markdown
## 🏠 Onboarding & Auth
### Screen 1: OnboardingScreen
### Screen 2: LanguageScreen

## 📊 Dashboard
### Screen 3: DashboardScreen

## 💸 Transactions
### Screen 4: TransactionsScreen
### Screen 5: AddTransactionScreen
...

## 📈 Statistics
### Screen 18: StatisticsScreen

## ⚙️ Settings
### Screen 20: SettingsScreen
...
```

### Step 5: Add Usage Guide

Tambahkan panduan cara menggunakan prompts:

```markdown
## Cara Menggunakan

### Option A: Stitch Web UI (Manual)
1. Buka project di stitch.withgoogle.com
2. Klik "Generate Screen"
3. Paste prompt dari screen yang diinginkan
4. Set device type sesuai yang tertera
5. Generate dan review hasilnya

### Option B: Stitch MCP Tools (Otomatis)
\```
// Generate single screen
mcp_stitch_generate_screen_from_text({
  projectId: "[PROJECT_ID]",
  prompt: "[paste prompt]",
  deviceType: "MOBILE"
})

// Edit existing screen
mcp_stitch_edit_screens({
  projectId: "[PROJECT_ID]",
  selectedScreenIds: ["[SCREEN_ID]"],
  prompt: "[edit instruction]"
})
\```

### Option C: Batch Generate (Stitch Loop)
Gunakan skill `stitch-loop` untuk generate semua screens sekaligus.
```

### Step 6: Generate STITCH_PROMPTS.md

Compile semua sections:

```markdown
# 🎨 STITCH_PROMPTS.md — Stitch Screen Generation Prompts
# {Nama Project}

> **Kumpulan prompt siap pakai untuk generate UI/UX di Stitch AI.**
> Setiap prompt sudah di-enhance untuk hasil optimal.

---

## 📋 Design System Block (Reference)
[Design system block — di-paste ke setiap prompt]

---

## 📱 Screen Prompts

### [Feature Group 1]
#### Screen 1: [Name]
...

### [Feature Group 2]
#### Screen N: [Name]
...

---

## 🔧 Cara Menggunakan
[Usage guide]

---

## 📊 Screen Summary
| # | Screen | Device | Status |
|---|--------|--------|--------|
| 1 | OnboardingScreen | Mobile | ⬜ |
| 2 | DashboardScreen | Mobile | ⬜ |
| ... | ... | ... | ... |
```

### Step 7: Validasi

Sebelum menyimpan, validasi:
- [ ] SETIAP screen dari PRD punya prompt (tidak ada yang terlewat)
- [ ] Setiap prompt punya Page Structure yang numbered
- [ ] Setiap prompt punya DESIGN SYSTEM (REQUIRED) block
- [ ] Device type benar per screen
- [ ] Interactive elements dan states (loading/empty/error) tersedia
- [ ] Prompts grouped by feature
- [ ] Usage guide lengkap (manual + MCP)
- [ ] Screen summary table punya semua screens
- [ ] Prompts cukup spesifik — Stitch tidak perlu menebak layout

### Step 8: Simpan File

Simpan ke `{output_dir}/STITCH_PROMPTS.md`

## Quality Criteria

- SETIAP screen dari PRD HARUS punya prompt
- Prompts HARUS menggunakan semantic, descriptive language
- Prompts HARUS structured (numbered page sections)
- Design system block HARUS consistent across all prompts
- Prompts HARUS cukup spesifik untuk generate accurate UI tanpa ambiguity
- Empty/loading/error states HARUS ada
- File HARUS self-contained (bisa dipakai tanpa membaca PRD)

## Example Prompts

### Generate Stitch Prompts (Dengan DESIGN.md)
```
Jalankan workflow vibe-coding-toolkit/02b_generate_stitch_prompts.md

PRD: @agents/docs/plans/my-app-prd.md
DESIGN.md: @prd/my-app/DESIGN.md
Output: prd/my-app/STITCH_PROMPTS.md
```

### Generate Stitch Prompts (Tanpa DESIGN.md)
```
Jalankan workflow vibe-coding-toolkit/02b_generate_stitch_prompts.md

PRD: @agents/docs/plans/my-app-prd.md
Output: prd/my-app/STITCH_PROMPTS.md
Note: DESIGN.md belum ada, generate design context dari PRD langsung
```

### Generate Satu Screen Saja
```
Generate Stitch prompt untuk DashboardScreen berdasarkan:
PRD: @agents/docs/plans/my-app-prd.md (Section 7.2)
Design Context: @prd/my-app/DESIGN.md (Section B)
Device Type: MOBILE
```

### Generate + Execute via MCP
```
1. Jalankan workflow 02b_generate_stitch_prompts.md
2. Buat Stitch project baru: "My App UI"
3. Generate setiap screen menggunakan mcp_stitch_generate_screen_from_text
4. Review hasil dan edit jika perlu menggunakan mcp_stitch_edit_screens

PRD: @agents/docs/plans/my-app-prd.md
DESIGN.md: @prd/my-app/DESIGN.md
```

---

## Tips untuk Hasil Terbaik di Stitch

1. **Satu screen per generate** — jangan coba generate banyak screen di satu prompt
2. **Design system block WAJIB** — tanpa ini, Stitch akan menebak warnanya
3. **Be specific, not verbose** — describe what you want, not how to build it
4. **Numbered sections** — helps Stitch understand page hierarchy
5. **Use descriptive color names** — "Calm Ocean Blue" > "#1976D2"
6. **Specify device type** — MOBILE prompts sangat berbeda dari DESKTOP
7. **Include empty states** — Stitch defaultnya selalu menampilkan data
8. **Iterate with edits** — gunakan `edit_screens` untuk refine, bukan re-generate
9. **Reference Stitch docs** — https://stitch.withgoogle.com/docs/learn/prompting/

---

## Cross-References

- **Parent workflow:** `02_generate_design.md` — generates DESIGN.md with Stitch context
- **Skills yang digunakan:** `stitch-enhance-prompt`, `stitch-design-md`, `stitch-loop`
- **Sumber data:** PRD (screen list, wireframes, UI specs), DESIGN.md (design tokens)
- **Tools terkait:** `mcp_stitch_generate_screen_from_text`, `mcp_stitch_edit_screens`, `mcp_stitch_create_project`

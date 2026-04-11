---
description: Phase 4 — Buat prompt Stitch yang optimal dari DESIGN.md untuk generate UI/UX
version: 1.0.0
last_updated: 2026-04-11
skills:
  - stitch-enhance-prompt
  - stitch-design-md
  - senior-ui-ux-designer
---

// turbo-all

# Workflow: Prompt Engineering untuk Stitch

## Agent Behavior

When executing this workflow, the agent MUST:
- Baca `DESIGN.md` untuk mendapatkan design system block (Section 6)
- Baca `evaluasi_desain.md` untuk memahami layout dan component yang diharapkan
- Baca `input_user.md` untuk memastikan prompt sesuai instruksi user
- Mengikuti [Stitch Effective Prompting Guide](https://stitch.withgoogle.com/docs/learn/prompting/)
- SETIAP prompt HARUS include Design System block dari Section 6 DESIGN.md
- Prompt HARUS structured: numbered Page Structure, spesifik component, jelas device type

## Overview

Menerjemahkan design system dan evaluasi menjadi prompt yang dioptimasi untuk Stitch AI. Prompt yang baik menghasilkan UI yang akurat di percobaan pertama, mengurangi kebutuhan iterasi.

## Input

- **DESIGN.md** — `ui-ux/{project-name}/DESIGN.md` (Section 6 = WAJIB)
- **Evaluasi desain** — `ui-ux/{project-name}/evaluasi_desain.md`
- **Instruksi user** — `ui-ux/{project-name}/input_user.md`
- **Output directory** — `ui-ux/{project-name}/`

## Output

- `{output_dir}/stitch_prompt.md`

## Prerequisites

- Phase 3 sudah selesai (`DESIGN.md` tersedia, minimal Section 6)

## Steps

### Step 1: Extract Design System Block

Copy **Section 6: Design System Notes** dari `DESIGN.md`.

Block ini WAJIB disertakan di setiap prompt Stitch. Tanpa ini, Stitch akan "menebak" warna dan style → output inkonsisten.

### Step 2: Define Screen(s) to Generate

Dari `input_user.md` dan `evaluasi_desain.md`, identifikasi:

1. **Jumlah screen** — Single screen atau multi-screen?
2. **Tipe setiap screen** — Dashboard, form, list, detail, settings, dll
3. **Device type** — MOBILE, DESKTOP, TABLET
4. **Priority** — Screen mana yang di-generate duluan?

### Step 3: Build Page Structure (per screen)

Untuk SETIAP screen, buat numbered Page Structure:

```markdown
**Page Structure:**
1. **Navigation Bar:** [Deskripsi spesifik — posisi, items, icons]
2. **Hero Section / Header:** [Apa yang ditampilkan, ukuran]
3. **Main Content:** [Grid layout, card arrangement, data]
4. **Secondary Content:** [Sidebar info, quick actions]
5. **Footer / Bottom Bar:** [Navigation tabs, action buttons]
```

**Rules untuk Page Structure:**
- Setiap section HARUS punya nama yang deskriptif
- Setiap section HARUS jelaskan APA yang ditampilkan
- Gunakan UI component names yang spesifik (bukan "tombol" tapi "primary call-to-action button")
- Jelaskan data yang ditampilkan (bukan "angka" tapi "total revenue in IDR format")

### Step 4: Apply Enhancement Pipeline

Dari skill `stitch-enhance-prompt`, apply:

#### 4a. Replace Vague Terms

| ❌ Vague | ✅ Specific |
|----------|------------|
| "menu di atas" | "horizontal navigation bar with app logo on left and user avatar on right" |
| "kartu" | "elevated card with rounded corners (12px), soft shadow, white background" |
| "grafik" | "area chart with gradient fill from indigo to transparent, smooth curves" |
| "tombol" | "primary button with indigo background, white text, rounded corners (8px)" |
| "tabel" | "data table with alternating row colors, sortable column headers" |
| "sidebar" | "left sidebar panel with icon-only navigation, 64px width" |

#### 4b. Add Visual Details

Untuk setiap component, specify:
- Color (reference design system: "using Primary Accent color")
- Size/dimensions (jika penting)
- Shape (border-radius, rounded vs sharp)
- State (default, hover, active, disabled)
- Content (dummy data yang realistic)

#### 4c. Specify Data/Content

Jangan biarkan Stitch menebak konten. Provide:
- Chart data contoh (angka realistic)
- Table data contoh
- Status badge variants
- User name, avatar placeholder
- Metric values yang masuk akal

### Step 5: Compose Final Prompt

Format prompt per screen:

```markdown
# Stitch Prompt: {Screen Name}

## Device Type: DESKTOP / MOBILE / TABLET

## Description
[One-line description of the screen purpose and vibe]

## DESIGN SYSTEM (REQUIRED)
[PASTE Section 6 dari DESIGN.md — JANGAN SKIP!]

## Page Structure
1. **[Section 1]:** [Detailed description]
2. **[Section 2]:** [Detailed description]
3. **[Section 3]:** [Detailed description]
...
N. **[Section N]:** [Detailed description]

## Key Widgets & Components
- **[Widget 1]:** [Detailed visual description]
- **[Widget 2]:** [Detailed visual description]

## Design Rules
- DO: [Rules to follow]
- DON'T: [Things to avoid]

## Interactive Elements (Optional)
- [Element → Behavior]
```

### Step 6: Multi-Screen Prompts (Jika Applicable)

Jika project multi-screen:
1. Buat section terpisah per screen
2. Setiap screen include design system block yang SAMA
3. Group berdasarkan feature area

### Step 7: Validasi

Sebelum menyimpan, validasi:
- [ ] Design System block (Section 6) disertakan di SETIAP prompt
- [ ] Page Structure numbered dan spesifik
- [ ] TIDAK ada term vague ("tombol", "menu", "grafik")
- [ ] Device type jelas per screen
- [ ] Warna di-reference menggunakan nama dari design system
- [ ] Component descriptions match style di DESIGN.md
- [ ] Data contoh realistic (bukan "lorem ipsum" untuk angka)
- [ ] Design rules (DO/DON'T) tersedia

### Step 8: Update Progress

Update `progress.md`:
```
| 4. Prompt Engineering | ✅ | [tanggal] | stitch_prompt.md created |
```

## Quality Criteria

- Design System block HARUS ada di setiap prompt — ini NON-NEGOTIABLE
- Prompts HARUS cukup spesifik sehingga Stitch tidak perlu menebak
- Terms HARUS menggunakan proper UI component names
- Data/content contoh HARUS realistic
- Prompts HARUS mengikuti Stitch prompting best practices

## Example Prompt

```
Jalankan workflow ui-ux-generator/04_prompt_engineering.md

DESIGN.md: @ui-ux/dashboard-001/DESIGN.md
Evaluasi: @ui-ux/dashboard-001/evaluasi_desain.md
Input: @ui-ux/dashboard-001/input_user.md
Output: ui-ux/dashboard-001/stitch_prompt.md
```

---

## Cross-References

- **Depends on:** `03_generate_design_system.md` (DESIGN.md)
- **Output digunakan oleh:** `05_stitch_generation.md`
- **Skills yang digunakan:** `stitch-enhance-prompt`, `stitch-design-md`
- **External reference:** [Stitch Prompting Guide](https://stitch.withgoogle.com/docs/learn/prompting/)

---
description: Phase 2 — Evaluasi & analisis referensi UI/UX menggunakan skill senior-ui-ux-designer
version: 1.0.0
last_updated: 2026-04-11
skills:
  - senior-ui-ux-designer
---

// turbo-all

# Workflow: Evaluasi & Analisis Desain

## Agent Behavior

When executing this workflow, the agent MUST:
- Baca skill `senior-ui-ux-designer` untuk mendapatkan data CSV (styles, colors, typography, products)
- Analisis gambar referensi dari SEMUA aspek (visual, warna, tipografi, layout, accessibility)
- Bandingkan referensi dengan instruksi user — identifikasi gap/perbedaan
- Berikan rekomendasi berbasis data CSV (bukan opini)
- Output HARUS actionable — Phase 3 harus bisa langsung membuat design system dari evaluasi ini

## Overview

Menganalisis gambar referensi UI/UX secara profesional menggunakan database styles, colors, dan typography. Menghasilkan dokumen evaluasi yang menjadi dasar pembuatan design system di Phase 3.

## Input

- **Gambar referensi** — `ui-ux/{project-name}/referensi.*`
- **Instruksi user** — `ui-ux/{project-name}/input_user.md`
- **Output directory** — `ui-ux/{project-name}/`

## Output

- `{output_dir}/evaluasi_desain.md`

## Prerequisites

- Phase 1 sudah selesai (`referensi.*` dan `input_user.md` tersedia)
- Skill `senior-ui-ux-designer` accessible

## Steps

### Step 1: Load Skill Data

Baca SKILL.md dari `senior-ui-ux-designer` dan data CSV-nya:
1. `styles.csv` — 67 design styles (contoh: Glassmorphism, Brutalist, Neumorphism)
2. `colors.csv` — 96 color palettes dengan hex codes dan use cases
3. `typography.csv` — 57 font pairings (heading + body + characteristics)
4. `products.csv` — 96 product types dan style recommendations

### Step 2: Analisis Visual & Estetika

Dari gambar referensi, identifikasi:

| Aspek | Pertanyaan | Contoh Output |
|-------|-----------|---------------|
| **Design Style** | Gaya apa? | "Flat Design with Bento Grid Layout" |
| **White Space** | Bagaimana densitas? | "Medium — balanced spacing between cards" |
| **Shape Language** | Rounded atau sharp? | "Softly rounded corners (8-12px radius)" |
| **Depth/Shadow** | Flat atau elevated? | "Subtle elevation with soft shadows" |
| **Visual Hierarchy** | Apa yang paling menonjol? | "Balance card hero section" |

Match dengan entry di `styles.csv` yang paling dekat.

### Step 3: Analisis Color Palette

Dari gambar referensi, extract:
1. **Primary Color** — Warna dominan untuk actions
2. **Secondary Color** — Warna supporting
3. **Background** — Warna latar belakang
4. **Surface** — Warna kartu/elemen elevated
5. **Text Colors** — Primary text, secondary text, muted
6. **Status Colors** — Success, warning, error, info
7. **CTA/Accent** — Warna tombol utama

Match dengan entry di `colors.csv` yang paling dekat.

### Step 4: Analisis Typography

Identifikasi dari referensi:
1. **Heading Font** — Family, weight, size range
2. **Body Font** — Family, weight, line height
3. **Mono/Code Font** — Jika ada
4. **Hierarchy** — Berapa level heading yang terlihat?
5. **Readability** — Ukuran minimum yang dipakai

Match dengan entry di `typography.csv` yang paling dekat.

### Step 5: Analisis Layout & Komposisi

Identifikasi:
1. **Navigation** — Sidebar, top bar, bottom bar, atau hybrid
2. **Grid System** — Berapa kolom? CSS Grid atau Flexbox?
3. **Breakpoints** — Desktop-first atau mobile-first?
4. **Card Layout** — Bento grid, masonry, uniform, atau mixed?
5. **Content Flow** — Top-to-bottom, left-to-right, atau sectioned?

### Step 6: Accessibility Check

Evaluasi:
1. **Color Contrast** — Apakah text vs background memenuhi WCAG AA (≥ 4.5:1)?
2. **Touch Targets** — Apakah cukup besar (≥ 44px)?
3. **Focus States** — Apakah terlihat?
4. **Color-blind Friendly** — Apakah informasi hanya bergantung pada warna?

### Step 7: Gap Analysis

Bandingkan referensi dengan `input_user.md`:

```markdown
## Gap Analysis: Referensi vs Instruksi User

| Aspek | Referensi | User Mau | Aksi |
|-------|-----------|----------|------|
| Navigation | Sidebar | Top bar | Redesign navigation |
| Color | Green | Indigo-Violet | Ganti palette |
| Charts | Bar chart | Area chart | Ganti chart type |
| ... | ... | ... | ... |
```

### Step 8: Buat Rekomendasi

Berdasarkan semua analisis, buat rekomendasi:
1. **Keep** — Apa dari referensi yang bagus dan harus dipertahankan
2. **Change** — Apa yang perlu diubah berdasarkan instruksi user
3. **Add** — Apa yang belum ada di referensi tapi diminta user
4. **Remove** — Apa dari referensi yang sebaiknya dihilangkan

### Step 9: Compile `evaluasi_desain.md`

```markdown
# Evaluasi Desain: {Project Name}

## Ringkasan
[Satu paragraf overview referensi dan rekomendasi utama]

## Analisis Visual & Estetika
[Step 2 output]

## Analisis Color Palette
[Step 3 output]

## Analisis Typography
[Step 4 output]

## Analisis Layout & Komposisi
[Step 5 output]

## Accessibility Check
[Step 6 output]

## Gap Analysis
[Step 7 output]

## Rekomendasi
### Keep
### Change
### Add
### Remove

## Design Direction
[Arah design yang direkomendasikan untuk Phase 3]
```

### Step 10: Validasi

Sebelum menyimpan, validasi:
- [ ] Semua 5 aspek analisis tercakup (visual, warna, tipografi, layout, accessibility)
- [ ] Gap analysis lengkap (referensi vs user request)
- [ ] Rekomendasi actionable (bisa langsung dipakai Phase 3)
- [ ] Color palette teridentifikasi dengan hex codes
- [ ] Typography teridentifikasi dengan font names
- [ ] Tidak ada opini tanpa data — setiap rekomendasi didukung oleh CSV data

### Step 11: Update Progress

Update `progress.md`:
```
| 2. Evaluasi Desain | ✅ | [tanggal] | [catatan singkat] |
```

## Quality Criteria

- Evaluasi HARUS berbasis data (CSV), bukan opini
- Gap analysis HARUS spesifik dan actionable
- Hex codes HARUS akurat (extract dari gambar atau reference)
- Rekomendasi HARUS mempertimbangkan accessibility
- Output HARUS cukup detail untuk Phase 3 bisa generate design system tanpa lihat referensi lagi

## Example Prompt

```
Jalankan workflow ui-ux-generator/02_evaluasi_desain.md

Referensi: @ui-ux/dashboard-001/referensi.webp
Input: @ui-ux/dashboard-001/input_user.md
Output: ui-ux/dashboard-001/evaluasi_desain.md
```

---

## Cross-References

- **Depends on:** `01_input_referensi.md` (referensi.* + input_user.md)
- **Output digunakan oleh:** `03_generate_design_system.md`
- **Skills yang digunakan:** `senior-ui-ux-designer`

---
description: Phase 1 — Collect gambar referensi UI/UX dan dokumentasikan instruksi user untuk pipeline design-to-code
version: 1.0.0
last_updated: 2026-04-11
skills: []
---

// turbo-all

# Workflow: Input Referensi UI/UX

## Agent Behavior

When executing this workflow, the agent MUST:
- Validasi bahwa gambar referensi ada dan bisa dibaca
- Buat folder structure standar untuk project baru
- Dokumentasikan instruksi user di `input_user.md` menggunakan template
- Buat file `progress.md` untuk tracking status per-phase
- JANGAN langsung evaluasi desain — itu tugas Phase 2

## Overview

Phase pertama dari pipeline design-to-code. Mengumpulkan semua input yang dibutuhkan: gambar referensi UI/UX dan instruksi user tentang apa yang ingin dibuat.

## Input

- **Gambar referensi** — File gambar UI/UX (`.png`, `.webp`, `.jpg`)
- **Instruksi user** — Deskripsi apa yang ingin dibuat
- **Project name** — Nama folder project (kebab-case, contoh: `dashboard-001`)

## Output

- `ui-ux/{project-name}/referensi.*` — Gambar referensi
- `ui-ux/{project-name}/input_user.md` — Dokumentasi instruksi user
- `ui-ux/{project-name}/progress.md` — Status tracking
- `ui-ux/{project-name}/queue/` — Empty staging folder
- `ui-ux/{project-name}/output/` — Empty output folder

## Steps

### Step 1: Buat Folder Structure

Buat folder structure standar:

```bash
mkdir -p ui-ux/{project-name}/queue
mkdir -p ui-ux/{project-name}/output
```

### Step 2: Simpan Gambar Referensi

Jika user menyediakan gambar:
1. Simpan ke `ui-ux/{project-name}/referensi.*` (pertahankan format asli)
2. Jika multiple referensi: `referensi-01.webp`, `referensi-02.webp`, dst.

Jika user hanya memberikan deskripsi tanpa gambar:
1. Catat di `input_user.md` bahwa tidak ada visual reference
2. Phase 2 akan skip analisis visual dan fokus pada deskripsi user

### Step 3: Dokumentasikan Instruksi User

Buat file `input_user.md` dengan template berikut:

```markdown
# Input User: {Project Name}

## Referensi
- File: `referensi.webp`
- Sumber: [URL atau deskripsi asal referensi]
- Deskripsi referensi: [Apa yang terlihat di gambar referensi]

## Instruksi User
[Apa yang user ingin buat — verbatim dari request user]
- Apakah sama persis dengan referensi?
- Apa yang ingin diubah/ditambahkan?
- Apa yang ingin dihilangkan/diganti?

## Target Platform
- [ ] Web (React/Next.js)
- [ ] Mobile (Flutter)
- [ ] HTML/CSS/JS sederhana

## Gaya/Style yang Diinginkan
[Jika user menyebutkan preferensi: dark mode, glassmorphism, minimalist, dll]

## Komponen/Fitur Kunci
[Komponen spesifik yang diminta user: sidebar, chart, card, table, dll]

## Catatan Tambahan
[Hal-hal lain yang perlu diperhatikan]
```

### Step 4: Buat Progress Tracking

Buat file `progress.md`:

```markdown
# Progress: {project-name}

| Phase | Status | Tanggal | Catatan |
|-------|--------|---------|---------|
| 1. Input Referensi | ✅ | [tanggal] | - |
| 2. Evaluasi Desain | ⬜ | - | - |
| 3. Design System | ⬜ | - | - |
| 4. Prompt Engineering | ⬜ | - | - |
| 5. Stitch Generation | ⬜ | - | - |
| 6. Download & Organize | ⬜ | - | - |
| 7. Code Conversion | ⬜ | - | - |
| 8. Quality Assurance | ⬜ | - | - |
```

### Step 5: Validasi

Sebelum lanjut ke Phase 2, pastikan:
- [ ] Gambar referensi tersimpan dan bisa dibaca
- [ ] `input_user.md` lengkap (minimal: instruksi + target platform)
- [ ] `progress.md` sudah dibuat
- [ ] Folder `queue/` dan `output/` sudah ada

## Quality Criteria

- `input_user.md` HARUS meng-capture instruksi user secara verbatim
- Target platform HARUS sudah ditentukan (atau ditandai sebagai "belum ditentukan")
- Folder structure HARUS mengikuti standar

## Example Prompt

```
Jalankan workflow ui-ux-generator/01_input_referensi.md

Referensi: @ui-ux/dashboard-001/referensi.webp
Project name: dashboard-001
Instruksi: Buat dashboard analytics modern dengan top bar navigation,
           glassmorphism cards, dan area charts. Gunakan warna indigo-violet.
Target: Web (React/Next.js)
```

---

## Cross-References

- **Output digunakan oleh:** `02_evaluasi_desain.md`
- **Sumber data:** Input langsung dari user

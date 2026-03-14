---
description: Generate CHECKLIST.md — Development progress checklist dari sebuah PRD untuk vibe coding
version: 1.0.0
last_updated: 2026-03-14
skills:
  - vibe-coding-specialist
  - senior-project-manager
  - project-estimator
---

// turbo-all

# Workflow: Generate CHECKLIST.md

## Agent Behavior

When executing this workflow, the agent MUST:
- Read AI_INSTRUCTIONS.md untuk mendapatkan list tasks (atau PRD jika AI_INSTRUCTIONS belum ada)
- Convert setiap task menjadi checklist item dengan status emoji
- Group items per Phase dan per Feature
- Include Gate Check di akhir setiap Phase
- Include Progress Summary table di bagian bawah
- Hitung total tasks secara akurat

## Overview

Generate file `CHECKLIST.md` dari sebuah PRD. File ini berfungsi sebagai tracking progress development — setiap kali developer menyelesaikan task, mereka update status di file ini.

## Input

- **PRD file** — Path ke Product Requirements Document
- **AI_INSTRUCTIONS.md** — File instruksi prompt (output dari workflow 03, optional tapi sangat disarankan)
- **Output directory** — Folder tujuan output

## Output

- `{output_dir}/CHECKLIST.md`

## Prerequisites

- PRD lengkap ATAU AI_INSTRUCTIONS.md yang sudah di-generate

## Steps

### Step 1: Define Status Legend

Gunakan emoji standar yang konsisten:

```markdown
| Icon | Status | Deskripsi |
|------|--------|-----------|
| ⬜ | Todo | Belum dikerjakan |
| 🔨 | In Progress | Sedang dikerjakan |
| ✅ | Done | Selesai & pass analyzer |
| 🐛 | Bug | Selesai tapi ada bug |
| ⏭️ | Skipped | Dilewati (akan dikerjakan nanti) |
```

### Step 2: Extract Tasks dari AI_INSTRUCTIONS.md atau PRD

Jika AI_INSTRUCTIONS.md tersedia:
- Ambil setiap task dari Phase 1-5
- Convert ke checklist format

Jika hanya PRD:
- Extract features → breakdown ke sub-tasks
- Organize per phase berdasarkan complexity & dependency

### Step 3: Granularity Rules

Setiap checklist item harus:
1. **Spesifik** — mentioning file path atau komponen yang exact
2. **Verifiable** — bisa dicek: selesai atau belum
3. **Small** — bisa diselesaikan dalam 1 prompt/session
4. **Trackable** — punya status emoji yang mudah diupdate

Contoh BAGUS:
```
- ⬜ **2.1** CategoryModel (data/models/category_model.dart)
```

Contoh BURUK:
```
- ⬜ **2.1** Buat category feature (terlalu besar!)
```

### Step 4: Group per Phase dan Feature

```markdown
## 📋 Phase 1: Foundation (Minggu 1-2)

### Setup
- ⬜ **1.1** Project setup
- ⬜ **1.2** Dependencies

### Core Theme
- ⬜ **1.3** Colors
- ⬜ **1.4** Typography
...

### ✅ Phase 1 Gate Check
- ⬜ Analyzer = 0 errors
- ⬜ App builds & runs
- ⬜ Theme applied correctly
```

### Step 5: Add Gate Checks

Setiap phase HARUS punya Gate Check section di akhir:
- Analyzer check (0 errors)
- Build check (app runs)
- Feature check (specific features work)
- Quality check (sesuai PRD requirements)

### Step 6: Add Progress Summary Table

Di bagian akhir file, tambahkan summary table:

```markdown
## 📊 Progress Summary

| Phase | Total Tasks | Done | Progress |
|-------|------------|------|----------|
| Phase 1 | XX | 0 | 0% |
| Phase 2 | XX | 0 | 0% |
| Phase 3 | XX | 0 | 0% |
| Phase 4 | XX | 0 | 0% |
| Phase 5 | XX | 0 | 0% |
| **TOTAL** | **XXX** | **0** | **0%** |
```

### Step 7: Generate CHECKLIST.md

Buat file dengan struktur:

```markdown
# ✅ CHECKLIST.md — Development Checklist
# {Nama Project}

> **Track progress development. Update status setiap task selesai.**

---

## Legend
[Status emoji table]

---

## 📋 Phase 1: Foundation
### [Sub-group 1]
### [Sub-group 2]
...
### ✅ Phase 1 Gate Check

## 📋 Phase 2: Core Features
...

## 📋 Phase 3: Advanced Features
...

## 📋 Phase 4: Analytics/Reporting
...

## 📋 Phase 5: Polish & Testing
...

## 📊 Progress Summary
[Summary table]

---
```

### Step 8: Validasi

Sebelum menyimpan, validasi:
- [ ] Semua tasks dari AI_INSTRUCTIONS.md / PRD tercakup
- [ ] Tidak ada duplicate task
- [ ] Numbering konsisten dan sequential
- [ ] Setiap phase punya Gate Check
- [ ] Progress Summary counts akurat
- [ ] Semua items dimulai dengan ⬜ (Todo)

### Step 9: Simpan File

Simpan ke `{output_dir}/CHECKLIST.md`

## Quality Criteria

- SETIAP feature dari PRD HARUS ada di checklist
- Items HARUS cukup granular (1 file atau 1 widget per item)
- Gate Checks HARUS practical dan testable
- Progress Summary HARUS punya count yang akurat
- File HARUS gampang di-edit (markdown checkboxes / emoji swap)

## Example Prompt

```
Jalankan workflow vibe-coding-toolkit/04_generate_checklist.md

PRD: @agents/docs/plans/my-app-prd.md
AI_INSTRUCTIONS: @prd/my-app/AI_INSTRUCTIONS.md
Output: prd/my-app/CHECKLIST.md
```

---

## Cross-References

- **Depends on:** `03_generate_ai_instructions.md` (AI_INSTRUCTIONS.md) — optional but recommended
- **Output standalone** — tidak di-reference oleh workflow lain
- **Sumber data:** PRD (features list), AI_INSTRUCTIONS.md (task list)

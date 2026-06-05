---
description: Sync progress development ke CHECKLIST.md berdasarkan git history, file changes, atau manual check — auto-track tanpa update manual
version: 2.0.0
last_updated: 2026-06-05
skills:
  - vibe-coding-specialist
  - senior-project-manager
---

// turbo-all

# Workflow: Sync Progress

## Agent Behavior

When executing this workflow, the agent MUST:
- Baca CHECKLIST.md untuk mendapatkan task list
- Analisis git history (atau struktur file) untuk menentukan task mana yang sudah dikerjakan
- Update status emoji berdasarkan evidence (file exists, test exists, git commit)
- JANGAN asumsi task selesai tanpa evidence
- Generate progress report dengan perubahan status

## Overview

Auto-sync progress ke CHECKLIST.md. Workflow ini membandingkan task list dengan actual codebase state dan git history untuk menentukan task mana yang sudah selesai.

## Input

- **CHECKLIST.md** — File checklist yang akan di-sync
- **Project directory** — Root folder project (untuk file structure scan)
- **Method** — Cara deteksi: `git` / `files` / `manual`

## Output

- Updated `{output_dir}/CHECKLIST.md`
- `{output_dir}/PROGRESS_SYNC_REPORT.md`

## Steps

### Step 1: Baca CHECKLIST.md

Parse CHECKLIST.md untuk mendapatkan:
- List semua task dengan nomor, nama, dan file target
- Phase grouping
- Status saat ini

### Step 2: Deteksi Progress

#### Method A: Git History (Rekomendasi)

```
git log --oneline --name-only -{n}
```

Untuk setiap task, cek:
- Apakah ada commit yang menyentuh file target task?
- Apakah commit message mengandung task number?
- Apakah file target task exists di filesystem?

**Status Mapping:**
| Evidence | Status |
|----------|--------|
| File target exists + recent commit | ✅ Done |
| File target exists + old commit | ✅ Done (perlu review) |
| File target exists + test exists | ✅ Done + Tested |
| File target tidak ditemukan | ⬜ Todo |
| File partial / setengah jadi | 🔨 In Progress |
| File exists tapi error | 🐛 Bug |

#### Method B: File Structure Scan

Scan project directory untuk mencari file yang match dengan task targets:

```
for each task in CHECKLIST:
  if task.target_file exists:
    check if test file exists
    check if file has content (bukan empty)
  else:
    mark as Todo
```

#### Method C: Manual (User Input)

Tanya user task mana yang sudah selesai:
```
Task 2.1: ✅ / 🔨 / ⬜?
Task 2.2: ✅ / 🔨 / ⬜?
```

### Step 3: Update CHECKLIST.md

Update status emoji untuk setiap task yang terdeteksi berubah.

**Rules:**
- HANYA update yang ada evidence — jangan tebak
- Jika ragu, tanya user (untuk task yang ambiguous)
- Update Progress Summary table dengan count baru

### Step 4: Generate Sync Report

```markdown
# 📊 Progress Sync Report
# {Nama Project}

> **Auto-generated progress sync.**
> Method: git / files / manual

---

## 📋 Changes Made

| Task | Old Status | New Status | Evidence |
|------|-----------|------------|----------|
| 2.1 | ⬜ | ✅ | File exists + git commit |
| 2.2 | 🔨 | ✅ | File + test exists |
| 2.3 | ⬜ | 🔨 | File exists (partial) |

---

## 📊 Updated Progress

| Phase | Tasks | Done | Progress |
|-------|-------|------|----------|
| Phase 1 | 10 | 10 | 100% |
| Phase 2 | 8 | 3 | 37% |
| **TOTAL** | **18** | **13** | **72%** |

---

## ⚠️ Notes
- Task 2.2 file exists tapi belum ada test — pertimbangkan update
- Task 3.1 file ditemukan tapi error di analyzer — tandai sebagai 🐛

---

## ✅ Next Actions
1. Fix task 3.1 (🐛 → ✅)
2. Add test for task 2.2
3. Continue with task 2.4
```

### Step 5: Validasi

Sebelum menyimpan:
- [ ] Status hanya berubah jika ada evidence konkret
- [ ] Progress Summary numbers akurat
- [ ] Tidak ada task yang ke-skip
- [ ] Report jelas: apa yang berubah dan kenapa

### Step 6: Simpan

Update `{output_dir}/CHECKLIST.md`
Save `{output_dir}/PROGRESS_SYNC_REPORT.md`

## Quality Criteria

- JANGAN pernah mark task sebagai Done tanpa evidence
- Git method adalah yang paling reliable
- File method bisa false positive (file exists tapi belum selesai)
- Manual method paling akurat tapi butuh effort user

## Example Prompt

```
Jalankan workflow vibe-coding-toolkit/10_sync_progress.md

CHECKLIST.md: @prd/finance-app/CHECKLIST.md
Project directory: @prd/finance-app/
Method: git
```

---

## Cross-References

- **Bergantung pada:** `05_generate_checklist.md` (CHECKLIST.md)
- **Output:** Updated CHECKLIST.md + PROGRESS_SYNC_REPORT.md
- **Frekuensi:** Setelah setiap beberapa task selesai, atau sebelum sprint review

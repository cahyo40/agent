---
description: Bundle semua generated files (RULE, DESIGN, AI_INSTRUCTIONS, ARCHITECTURE) menjadi satu file context siap pakai untuk sesi AI coding
version: 2.0.0
last_updated: 2026-06-05
skills:
  - vibe-coding-specialist
  - senior-prompt-engineer
  - senior-software-engineer
---

// turbo-all

# Workflow: Bundle AI Context

## Agent Behavior

When executing this workflow, the agent MUST:
- Baca SEMUA file output yang sudah di-generate
- Compress dan optimize konten untuk context window AI (HAPUS bagian redundant)
- Prioritaskan: RULE.md > ARCHITECTURE.md > DESIGN.md (code) > AI_INSTRUCTIONS.md (task aktif)
- Gunakan format yang efisien — bullet points, short tables, code snippets tanpa comment berlebihan
- HASIL AKHIR: satu file markdown yang bisa di-copy-paste ke AI coding assistant

## Overview

Generate `AI_CONTEXT.md` — satu file ringkas yang berisi semua informasi yang dibutuhkan AI dalam sesi coding. File ini mengatasi masalah **context window limit**: daripada memberikan 5 file panjang ke AI, cukup berikan 1 file yang sudah di-optimasi.

## Input

- **Output directory** — Folder yang berisi semua file generated (RULE.md, DESIGN.md, AI_INSTRUCTIONS.md, CHECKLIST.md, ARCHITECTURE_CHEATSHEET.md)
- **Current task ID** — (Optional) Task yang sedang dikerjakan di AI_INSTRUCTIONS.md
- **Current file changes** — (Optional) File-file yang sedang dimodifikasi

## Output

- `{output_dir}/AI_CONTEXT.md` — Optimized context bundle

## Steps

### Step 1: Baca Semua File

Baca file-file berikut (urut berdasarkan prioritas):

| Priority | File | Konten |
|----------|------|--------|
| 1 | RULE.md | Governance rules (WAJIB & DILARANG) |
| 2 | ARCHITECTURE_CHEATSHEET.md | Code patterns, folder structure |
| 3 | DESIGN.md | Design tokens (CODE section only, skip Stitch prompts) |
| 4 | AI_INSTRUCTIONS.md | Task breakdown (current task + nearby tasks only) |
| 5 | CHECKLIST.md | Progress status |

### Step 2: Kompres & Optimasi

Untuk setiap file, terapkan optimasi:

**RULE.md:**
- ✂️ Hapus emoji dekoratif di judul
- ✂️ Hapus penjelasan panjang — simpan hanya ✅ WAJIB dan ❌ DILARANG
- ✂️ Hapus "file ini adalah kontrak" preamble
- ✅ Simpan code snippets dalam bentuk minimal

**ARCHITECTURE_CHEATSHEET.md:**
- ✂️ Hapus penjelasan — simpan hanya code patterns
- ✅ Kompres Common Mistakes table ke format 1-line
- ✅ Simpan Mermaid diagram (high value)

**DESIGN.md:**
- ✂️ Hapus Stitch section (BAGIAN B dan C) — tidak relevan untuk coding
- ✅ Simpan hanya AppColors, AppTypography, AppSpacing class
- ✅ Simpan Theme configuration

**AI_INSTRUCTIONS.md:**
- ✂️ Hapus phase yang sudah selesai
- ✂️ Hapus troubleshooting section (simpan hanya untuk rujukan)
- ✅ Simpan task description untuk current + next task
- ✅ Simpan file paths

### Step 3: Generate AI_CONTEXT.md

Format output:

```markdown
# AI Context — {Nama Project}
> Generated for vibe coding session.
> Reference: RULE.md · ARCHITECTURE.md · DESIGN.md · AI_INSTRUCTIONS.md

---

## 📌 RULES (WAJIB & DILARANG)

### Arsitektur
✅ [key rule]
❌ [key anti-pattern]

### State Management
✅ [key rule]
❌ [key anti-pattern]

### Error Handling
✅ [key rule]

### Naming
| Type | Convention |
|------|-----------|
| File | [convention] |
| Class | [convention] |

> *Full rules: @RULE.md*

---

## 🧩 CODE PATTERNS

### Entity
```dart
// minimal complete example
```

### Repository
```dart
// minimal complete example
```

### Controller
```dart
// minimal complete example
```

### Screen (List)
```dart
// minimal complete example
```

> *Full patterns: @ARCHITECTURE_CHEATSHEET.md*

---

## 🎨 DESIGN TOKENS

```dart
// AppColors, AppTypography, AppSpacing — minimal
```

> *Full tokens: @DESIGN.md*

---

## 🎯 CURRENT TASK

### Task {X.Y}: {Nama Task}
[Brief description]

**Target files:**
1. `path/to/file1.dart`
2. `path/to/file2.dart`

**Notes:**
- [specific constraint]
- [specific detail]

> *Full task list: @AI_INSTRUCTIONS.md*

---

## ✅ PROGRESS

- Phase 1: X/Y tasks ✅
- Phase 2: X/Y tasks ✅
- Current phase: [name]

> *Full checklist: @CHECKLIST.md*
```

### Step 4: Validasi

Sebelum menyimpan, pastikan:
- [ ] Semua essential rules dari RULE.md tercakup (arsitektur, state management, error handling, naming)
- [ ] Code patterns dari ARCHITECTURE.md lengkap (entity, repo, controller, screen)
- [ ] Design tokens cukup untuk coding (colors, typography, spacing, theme)
- [ ] Current task jelas dan actionable
- [ ] File tidak melebihi ~300 lines (agar fit dalam context window)
- [ ] Semua bagian punya reference ke file asli (`@filename`)

### Step 5: Simpan File

Simpan ke `{output_dir}/AI_CONTEXT.md`

## Quality Criteria

- Context file HARUS muat dalam satu AI prompt (max ~300 lines / ~8000 tokens)
- Semua essential rules HARUS ada — tidak boleh ada aturan kritis yang hilang
- Code patterns HARUS copy-paste ready
- Current task HARUS jelas file targets-nya
- File HARUS bisa berdiri sendiri (tidak perlu buka file lain untuk mulai coding)

## Example Prompt

```
Jalankan workflow vibe-coding-toolkit/08_bundle_ai_context.md

Output directory: prd/finance-app/
Current task: Task 2.3 (AddTransactionScreen)
Output: prd/finance-app/AI_CONTEXT.md
```

---

## Cross-References

- **Bergantung pada:** `02-07` (semua file output)
- **Output digunakan sebagai:** Single prompt untuk AI coding assistant
- **Cara pakai:** Copy paste AI_CONTEXT.md ke awal sesi vibe coding, lalu lanjut dengan task-specific prompt

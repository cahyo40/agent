---
description: Review dan iterate output yang sudah di-generate — cek konsistensi, identifikasi gap, dan re-generate file yang bermasalah
version: 2.0.0
last_updated: 2026-06-05
skills:
  - vibe-coding-specialist
  - senior-software-architect
  - senior-software-engineer
  - senior-prompt-engineer
---

// turbo-all

# Workflow: Review & Iterate Generated Files

## Agent Behavior

When executing this workflow, the agent MUST:
- Read PRD dan SEMUA file yang sudah di-generate (RULE.md, DESIGN.md, AI_INSTRUCTIONS.md, CHECKLIST.md, ARCHITECTURE_CHEATSHEET.md)
- Lakukan cross-check: apakah setiap file konsisten dengan PRD dan satu sama lain?
- Identifikasi gaps: fitur/section di PRD yang TIDAK tercakup di output
- Identifikasi inconsistencies: aturan di RULE.md yang bertentangan dengan pattern di ARCHITECTURE
- Generate review report dengan action items
- Untuk setiap issue, re-generate file yang bermasalah (hanya file itu, bukan semua)
- Loop sampai semua issues terselesaikan

## Overview

Workflow review & iterasi untuk memastikan semua output file konsisten, complete, dan berkualitas tinggi. Workflow ini bisa dijalankan:
1. **Setelah semua file selesai di-generate** — sebagai final quality check
2. **Setelah edit PRD** — untuk update output yang terdampak
3. **Secara berkala** — sebagai maintenance tool

## Input

- **PRD file** — Path ke Product Requirements Document (original atau updated)
- **Output directory** — Folder yang berisi semua file yang sudah di-generate
- **Scope** — File mana yang akan di-review (default: semua)

## Output

- `{output_dir}/REVIEW_REPORT.md` — Laporan review dengan action items
- File yang di-re-generate (overwrite)

## Prerequisites

- PRD original (atau updated)
- Minimal satu file output sudah di-generate

## Steps

### Step 1: Baca Semua File

Baca PRD dan semua file output:

| File | Check |
|------|-------|
| PRD.md | Baseline reference |
| RULE.md | Governance rules |
| DESIGN.md | Design tokens + Stitch context |
| STITCH_PROMPTS.md (if exists) | Screen prompts |
| AI_INSTRUCTIONS.md | Task breakdown |
| CHECKLIST.md | Progress tracking |
| ARCHITECTURE_CHEATSHEET.md | Quick reference |

### Step 2: Cross-Check Matrix

Untuk setiap file, lakukan cross-check:

#### 2a. PRD → All Files: Completeness Check

| PRD Section | Expected In | Status |
|-------------|-------------|--------|
| Tech Stack | RULE.md, ARCHITECTURE.md | ✅ / ❌ / ⚠️ |
| Architecture | RULE.md, ARCHITECTURE.md, AI_INSTRUCTIONS.md | ✅ / ❌ / ⚠️ |
| Features | AI_INSTRUCTIONS.md, CHECKLIST.md | ✅ / ❌ / ⚠️ |
| Screens | DESIGN.md, STITCH_PROMPTS.md, ARCHITECTURE.md | ✅ / ❌ / ⚠️ |
| UI/UX Tokens | DESIGN.md | ✅ / ❌ / ⚠️ |
| Data Models | ARCHITECTURE.md | ✅ / ❌ / ⚠️ |
| Error Handling | RULE.md, ARCHITECTURE.md | ✅ / ❌ / ⚠️ |
| Testing | RULE.md, AI_INSTRUCTIONS.md | ✅ / ❌ / ⚠️ |

#### 2b. Cross-File Consistency Check

| Check | Files | Issue If Inconsistent |
|-------|-------|-----------------------|
| Tech stack match | RULE.md vs ARCHITECTURE.md | Conflicting patterns |
| Naming conventions | RULE.md vs ARCHITECTURE.md code | Wrong naming |
| Route list match | ARCHITECTURE.md vs DESIGN.md | Missing routes |
| Error handling pattern | RULE.md vs ARCHITECTURE.md | Wrong error handling |
| Task coverage | AI_INSTRUCTIONS.md vs CHECKLIST.md | Missing checkpoint |

#### 2c. Quality Check per File

**RULE.md:**
- Apakah setiap section punya ✅ (WAJIB) dan ❌ (DILARANG)?
- Apakah code snippets valid untuk tech stack?
- Apakah semua package/tech decision dari PRD tercakup?

**DESIGN.md:**
- Apakah semua color tokens dari PRD terkonversi?
- Apakah Stitch Design Context block lengkap?
- Apakah semua screens dari PRD punya prompt?

**AI_INSTRUCTIONS.md:**
- Apakah semua features dari PRD ter-breakdown ke tasks?
- Apakah task ordering logis (dependencies respected)?
- Apakah ada phase testing yang mandatory?

**CHECKLIST.md:**
- Apakah semua tasks dari AI_INSTRUCTIONS tercakup?
- Apakah Gate Check ada di setiap phase?
- Apakah Progress Summary counts akurat?

**ARCHITECTURE_CHEATSHEET.md:**
- Apakah code patterns valid syntax?
- Apakah Mermaid diagram valid?
- Apakah Common Mistakes table komprehensif?

### Step 3: Generate Review Report

```markdown
# 📋 Review Report — Generated Files Quality Check
# {Nama Project}

> **Hasil review output vibe-coding-toolkit.**

---

## 📊 Overall Assessment

| Metric | Value |
|--------|-------|
| Completeness | X / Y sections covered |
| Consistency | X / Y cross-checks passed |
| Issues Found | X (Critical: Y, Warning: Z) |
| **Recommendation** | **Proceed / Fix Issues / Re-generate** |

---

## 🔴 Critical Issues

### [File]: [Issue Description]
**Severity:** Critical
**PRD Reference:** Section [X.Y]
**What's wrong:** [description]
**Expected:** [what should be there]
**Action:** Re-generate file / Fix section / Update PRD

---

## 🟡 Warnings

### [File]: [Issue Description]
**Severity:** Warning
**Details:** [description]

---

## 📋 Per-File Summary

### RULE.md — ✅ PASS / ⚠️ WARNINGS / ❌ FAIL
- Completeness: X / Y sections
- Issues: [list]
- Action: [none / regenerate / fix]

### DESIGN.md — ...
### AI_INSTRUCTIONS.md — ...
### CHECKLIST.md — ...
### ARCHITECTURE_CHEATSHEET.md — ...

---

## 🔄 Iteration Plan

### Iteration 1: Fix Critical Issues
Files to re-generate:
1. [file] — [reason]
2. [file] — [reason]

### Iteration 2: Fix Warnings (if needed)
Files to update:
1. [file] — [reason]

### Iteration 3: Final Validation
Re-run review untuk memastikan semua issues selesai.

---

*Generated by vibe-coding-toolkit/07_review_and_iterate.md*
```

### Step 4: Iterate

Untuk setiap issue, lakukan:

1. **Regenerate specific file** — hanya file yang bermasalah
   ```
   Jalankan workflow vibe-coding-toolkit/02_generate_rule.md
   PRD: @[prd]
   Output: [output_dir]
   Note: Fix specific issues: [list]
   ```

2. **Re-validate** — setelah regenerate, jalankan Step 2 lagi untuk file tersebut
3. **Continue** — jika masih ada issue, loop
4. **Done** — jika semua checks passed

### Step 5: Simpan Report

Simpan ke `{output_dir}/REVIEW_REPORT.md`

## Quality Criteria

- Review HARUS mencakup ALL files, bukan hanya satu
- Cross-checks HARUS membandingkan file satu dengan lainnya
- Setiap issue HARUS punya severity (Critical / Warning)
- Setiap Critical issue HARUS punya action item
- Iteration plan HARUS realistic (regenerate, not rewrite from scratch)

## Example Prompt

```
Jalankan workflow vibe-coding-toolkit/07_review_and_iterate.md

PRD: @agents/docs/plans/my-app-prd.md
Output: prd/my-app/
Scope: all files
```

---

## Cross-References

- **Bergantung pada:** `02-07` (file output yang sudah di-generate)
- **Output:** `REVIEW_REPORT.md` + file yang di-re-generate
- **Dapat digunakan sebagai:** CI gate sebelum deploy / PR quality check

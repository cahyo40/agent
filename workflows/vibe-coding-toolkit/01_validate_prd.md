---
description: Validate PRD completeness before running any generation workflow — quality gate untuk memastikan PRD siap diproses
version: 2.0.0
last_updated: 2026-06-05
skills:
  - vibe-coding-specialist
  - senior-software-architect
  - senior-prompt-engineer
---

// turbo-all

# Workflow: Validate PRD Quality Gate

## Agent Behavior

When executing this workflow, the agent MUST:
- Read the ENTIRE PRD thoroughly
- Check for each required section dengan checklist ketat
- Assign severity level (CRITICAL / WARNING / INFO) untuk setiap missing item
- CRITICAL items HARUS dipenuhi sebelum workflow lain bisa jalan
- WARNING items sebaiknya dipenuhi untuk hasil optimal
- INFO items adalah nice-to-have
- Generate laporan lengkap dengan rekomendasi perbaikan
- JANGAN melanjutkan ke workflow 02-07 jika ada CRITICAL missing

## Overview

Quality Gate untuk validasi PRD sebelum diproses oleh workflow lain. Workflow ini adalah **entry point** pipeline — tanpanya, output workflow 02-07 tidak terjamin kualitasnya.

## Input

- **PRD file** — Path ke Product Requirements Document

## Output

- `{output_dir}/PRD_VALIDATION.md` — Laporan hasil validasi
- Exit dengan status: PASS / PASS_WITH_WARNINGS / FAIL

## Prerequisites

Tidak ada — ini adalah workflow pertama yang harus dijalankan.

## Steps

### Step 1: Baca PRD

Baca seluruh PRD dari awal hingga akhir. Catat section mana yang ada dan mana yang tidak.

### Step 2: Validate Required Sections

Periksa PRD terhadap checklist berikut:

#### 🔴 CRITICAL (Wajib Ada — Pipeline Akan Gagal Tanpa Ini)

| # | Section | Check | Impact Jika Missing |
|---|---------|-------|---------------------|
| 1 | **Tech Stack** | Framework, language, state management, database, routing disebutkan explicit | RULE.md & AI_INSTRUCTIONS tidak bisa digenerate dengan benar |
| 2 | **Architecture Pattern** | MVC / Clean Architecture / MVVM / dll disebutkan | Architecture cheatsheet tidak ada dasarnya |
| 3 | **Feature List** | Daftar fitur/module yang akan dibangun | Checklist & AI_INSTRUCTIONS tidak punya task list |
| 4 | **Screen List** | Daftar semua screen/halaman dengan deskripsi | DESIGN.md & STITCH_PROMPTS tidak bisa generate prompts |
| 5 | **Data Model / Schema** | Entity, model, field definitions | Architecture patterns tidak bisa dicontohkan |

#### 🟡 WARNING (Sangat Disarankan — Hasil Akan Suboptimal Tanpa Ini)

| # | Section | Check | Impact |
|---|---------|-------|--------|
| 6 | **UI/UX Guidelines** | Color palette, typography, spacing, component specs | DESIGN.md harus infer dari screen descriptions |
| 7 | **Route Definitions** | Path dan parameter per screen | Route registry di ARCHITECTURE tidak lengkap |
| 8 | **Error Handling Strategy** | Global error handling, Result type, exceptions | RULE.md error section jadi generik |
| 9 | **Testing Strategy** | Testing framework, coverage targets, approach | Testing section di RULE.md & AI_INSTRUCTIONS jadi generik |
| 10 | **Folder Structure** | Directory layout convention | Architecture cheatsheet folder structure harus inferred |

#### 🔵 INFO (Nice-to-Have — Meningkatkan Kualitas)

| # | Section | Check |
|---|---------|-------|
| 11 | Wireframes / Mockups | Visual referensi per screen |
| 12 | User Stories | Detail flow per fitur |
| 13 | Performance Requirements | Target metrics, constraints |
| 14 | Localization/i18n Plan | Bahasa, key convention |
| 15 | Security Requirements | Auth, data protection, compliance |
| 16 | Dependency / Package List | Exact packages dengan version |

### Step 3: Generate Validation Report

Buat laporan dengan format:

```markdown
# ✅ / ❌ PRD Validation Report
# {Nama Project}

> **Quality Gate untuk PRD.**
> Status: **PASS** / **PASS_WITH_WARNINGS** / **FAIL**

---

## 📊 Summary

| Metric | Value |
|--------|-------|
| CRITICAL Sections | X / Y complete |
| WARNING Sections | X / Y complete |
| INFO Sections | X / Y complete |
| **Overall Status** | **PASS / FAIL** |
| **Recommendation** | **Proceed / Fix Critical Issues First** |

---

## 🔴 Critical Issues ({count})

| Section | Status | Issue | Recommendation |
|---------|--------|-------|----------------|
| Tech Stack | ❌ Missing | No tech stack specified | Add section: "Tech Stack: [framework, language, packages]" |
| ... | ... | ... | ... |

## 🟡 Warnings ({count})

| Section | Status | Issue | Recommendation |
|---------|--------|-------|----------------|
| UI/UX | ⚠️ Partial | Colors mentioned but no typography | Add font family & size hierarchy |

## 🔵 Info Items ({count})

| Section | Status | Note |
|---------|--------|------|
| Wireframes | ℹ️ Missing | Not required but improves Stitch output quality |

---

## 📋 Detailed Findings per Section

### {Section Name}
**Severity:** CRITICAL | WARNING | INFO
**Status:** ✅ Complete | ⚠️ Partial | ❌ Missing | ℹ️ Not Found
**What's needed:**
- [specific requirement]
- [specific requirement]

**What's found in PRD:**
> [quote from PRD or "Not found"]

**Recommendation:**
[actionable suggestion untuk memperbaiki PRD]

---

## 🚀 Next Steps

### If PASS:
Proceed to workflow `02_generate_rule.md`

### If PASS_WITH_WARNINGS:
Proceed but review WARNING items untuk hasil optimal. Consider updating PRD sebelum lanjut.

### If FAIL:
1. Fix CRITICAL missing sections di PRD
2. Jalankan workflow ini lagi untuk re-validasi
3. Setelah PASS, lanjut ke workflow 01

---

*Generated by vibe-coding-toolkit/01_validate_prd.md*
```

### Step 4: Validation Rules

1. **CRITICAL = 0 missing** → **PASS**
2. **CRITICAL = 0 missing, WARNING ≥ 1 missing** → **PASS_WITH_WARNINGS**
3. **CRITICAL ≥ 1 missing** → **FAIL** (jangan lanjut ke workflow berikutnya)

### Step 5: Simpan Laporan

Simpan ke `{output_dir}/PRD_VALIDATION.md`

## Quality Criteria

- CRITICAL checklist HARUS exhaustive (setiap section yang essential untuk workflow lain)
- Setiap missing item HARUS punya rekomendasi perbaikan yang actionable
- Laporan HARUS jelas: PASS / PASS_WITH_WARNINGS / FAIL
- JANGAN proceed ke workflow 01 jika FAIL

## Example Prompt

```
Jalankan workflow vibe-coding-toolkit/01_validate_prd.md

PRD: @agents/docs/plans/my-app-prd.md
Output: prd/my-app/PRD_VALIDATION.md
```

---

## Cross-References

- **Gateway untuk:** `02_generate_rule.md`, `03_generate_design.md`, `04_generate_ai_instructions.md`, `05_generate_checklist.md`, `06_generate_architecture.md`
- **Sumber data:** PRD (semua sections)
- **Workflow ini memperkenalkan pipeline quality gate pertama dalam toolchain vibe-coding-toolkit

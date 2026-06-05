---
description: Auto-review kode yang dihasilkan AI terhadap RULE.md, ARCHITECTURE.md, dan best practices — code quality gate untuk vibe coding
version: 2.0.0
last_updated: 2026-06-05
skills:
  - vibe-coding-specialist
  - senior-software-architect
  - senior-software-engineer
  - requesting-code-review
---

// turbo-all

# Workflow: Code Review

## Agent Behavior

When executing this workflow, the agent MUST:
- Baca RULE.md untuk mendapatkan semua aturan WAJIB dan DILARANG
- Baca ARCHITECTURE.md untuk mendapatkan code patterns yang benar
- Scan kode untuk mencari VIOLATIONS dari aturan tersebut
- Kategorikan violations: CRITICAL (pattern salah) / WARNING (code smell) / INFO (saran)
- Untuk setiap violation, tunjukkan ❌ Wrong code dan ✅ Correct code
- Prioritaskan fix untuk CRITICAL violations

## Overview

Automated code review terhadap RULE.md dan ARCHITECTURE.md. Workflow ini adalah **quality gate** sebelum menganggap task selesai — memastikan kode yang dihasilkan AI sesuai dengan governance rules.

## Input

- **File(s) to review** — Satu atau lebih file kode yang akan di-review
- **RULE.md** — Governance rules reference
- **ARCHITECTURE_CHEATSHEET.md** — Code patterns reference
- **Output directory** — Folder untuk menyimpan report

## Output

- `{output_dir}/CODE_REVIEW_{timestamp}.md` — Review report
- (Optional) Fixed files

## Steps

### Step 1: Load Rules

Parse RULE.md dan extract:

| Rule Category | Yang Dicari |
|---------------|-------------|
| Arsitektur | WAJIB patterns, DILARANG anti-patterns |
| State Management | WAJIB usage, DILARANG alternatives |
| Error Handling | WAJIB strategy, DILARANG patterns |
| Database | WAJIB access patterns, DILARANG direct access |
| Routing | WAJIB navigation, DILARANG patterns |
| Naming | File, class, method conventions |
| UI/Widget | WAJIB theme usage, DILARANG hardcoded values |
| Testing | WAJIB patterns, DILARANG anti-patterns |

### Step 2: Load Patterns

Parse ARCHITECTURE.md untuk mendapatkan:
- Entity pattern
- Repository pattern
- Controller pattern
- Screen patterns
- Common mistakes table

### Step 3: Scan Code

Untuk setiap file yang di-review:
1. Parse struktur file
2. Check imports — apakah package sesuai RULE.md?
3. Check class/method naming — apakah sesuai convention?
4. Check state management — apakah menggunakan pattern yang benar?
5. Check error handling — apakah sesuai strategi?
6. Check UI code — apakah menggunakan design tokens?
7. Check test code — apakah patternnya benar?

### Step 4: Kategorikan Issues

| Severity | Criteria | Action |
|----------|----------|--------|
| 🔴 **Critical** | Melanggar DILARANG rule | HARUS fix sebelum merge |
| 🟡 **Warning** | Tidak mengikuti WAJIB rule (tidak melanggar tapi tidak ideal) | Sebaiknya fix |
| 🔵 **Info** | Code smell, improvement suggestion | Opsional |

### Step 5: Generate Review Report

```markdown
# 📝 Code Review Report
# {Nama Project}

> **Auto-generated code review terhadap RULE.md & ARCHITECTURE.md**
> Files reviewed: {count}
> Timestamp: {date}

---

## 📊 Summary

| Metric | Value |
|--------|-------|
| Files Reviewed | X |
| 🔴 Critical | X |
| 🟡 Warnings | X |
| 🔵 Info | X |
| **Verdict** | **✅ APPROVED / ⚠️ NEEDS FIX / ❌ REJECTED** |

**Verdict Rules:**
- 0 Critical → ✅ APPROVED
- 1-2 Critical → ⚠️ NEEDS FIX
- 3+ Critical → ❌ REJECTED

---

## 🔴 Critical Violations

### {#}. {File}:{Line} — {RULE.md Section}
**Violation:** {description of what's wrong}
**RULE.md Reference:** `{rule section}`

❌ **Wrong:**
```dart
// Kode yang melanggar aturan
```

✅ **Correct:**
```dart
// Kode yang sesuai aturan
```

**Fix:** {actionable fix instruction}

---

## 🟡 Warnings

### {#}. {File}:{Line} — {description}
**Suggestion:** {improvement suggestion}
**RULE.md Reference:** `{rule section}`

---

## 🔵 Info / Suggestions

### {#}. {File}:{Line}
**Suggestion:** {improvement idea}

---

## 📈 Rule Compliance

| Rule Category | Checked | Pass | Fail | Compliance |
|---------------|---------|------|------|------------|
| Arsitektur | X | X | X | XX% |
| State Management | X | X | X | XX% |
| Error Handling | X | X | X | XX% |
| Naming | X | X | X | XX% |
| UI | X | X | X | XX% |
| **TOTAL** | **X** | **X** | **X** | **XX%** |

---

## ✅ Recommendation

{final verdict and recommended actions}

---

*Reviewed by vibe-coding-toolkit/12_code_review.md*
*Against: RULE.md + ARCHITECTURE_CHEATSHEET.md*
```

### Step 6: Apply Fixes (Optional)

Jika diminta, apply fix untuk Critical violations:
1. Fix satu per satu
2. Setelah setiap fix, re-run analyzer/test
3. Update report dengan status fix

## Quality Criteria

- Setiap violation HARUS di-refer ke RULE.md atau ARCHITECTURE.md (bukan opini pribadi)
- Setiap ❌ HARUS punya ✅ counterpart
- Severity HARUS konsisten dengan impact
- False positives HARUS diminimalkan (jika ragu, turunkan severity)

## Example Prompt

```
Jalankan workflow vibe-coding-toolkit/12_code_review.md

Files to review:
- lib/features/transactions/presentation/screens/transaction_screen.dart
- lib/features/transactions/presentation/controllers/transaction_controller.dart

RULE.md: @prd/finance-app/RULE.md
ARCHITECTURE.md: @prd/finance-app/ARCHITECTURE_CHEATSHEET.md
Output: prd/finance-app/reviews/
```

---

## Cross-References

- **Bergantung pada:** `02_generate_rule.md` (RULE.md), `06_generate_architecture.md` (ARCHITECTURE.md)
- **Output:** CODE_REVIEW_*.md
- **Dapat diintegrasikan dengan:** CI pipeline, pre-commit hook
- **Skills terkait:** `requesting-code-review` (untuk review lanjutan oleh subagent)

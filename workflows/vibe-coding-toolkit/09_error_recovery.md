---
description: Diagnosa dan fix error build/analyzer/test secara sistematis — error recovery workflow untuk vibe coding
version: 2.0.0
last_updated: 2026-06-05
skills:
  - vibe-coding-specialist
  - senior-software-engineer
  - debugging-specialist
---

// turbo-all

# Workflow: Error Recovery & Fix

## Agent Behavior

When executing this workflow, the agent MUST:
- Baca error output secara menyeluruh — jangan hanya baris pertama
- Identifikasi ROOT CAUSE (bukan symptom)
- Cross-reference dengan RULE.md — apakah error karena melanggar aturan?
- Cross-reference dengan ARCHITECTURE.md — apakah patternnya salah?
- Generate minimal fix — jangan rewrite seluruh file
- Verifikasi fix dengan re-run command

## Overview

Systematic error recovery workflow untuk vibe coding. Ketika build/analyzer/test error, workflow ini membantu diagnosa root cause dan generate fix yang tepat.

## Input

- **Error output** — Output dari command yang gagal (analyzer, build, test)
- **Output directory** — Folder project
- **File yang dimodifikasi** — (Optional) File yang diubah sebelum error terjadi
- **RULE.md** — Governance rules
- **ARCHITECTURE_CHEATSHEET.md** — Code patterns

## Output

- `{output_dir}/ERROR_REPORT.md` — Diagnosa dan fix plan
- (Optional) File yang di-fix

## Steps

### Step 1: Klasifikasi Error

Baca error output dan klasifikasikan:

| Category | Examples | Typical Cause |
|----------|----------|---------------|
| **Syntax Error** | Missing semicolon, unmatched bracket | Typo / copy-paste mistake |
| **Type Error** | Wrong type, missing import, undefined name | Wrong pattern / missing file |
| **State Error** | Provider not found, context not available | Wrong widget tree / provider scope |
| **Pattern Error** | setState in Riverpod, direct DB access | Violation of RULE.md |
| **Build Error** | Asset not found, gradle error, config | Missing config / wrong setup |
| **Test Error** | Assertion failed, widget not found | Wrong logic / missing widget |
| **Runtime Error** | Null pointer, index out of bounds | Missing null check / wrong assumption |

### Step 2: Root Cause Analysis

Untuk setiap error, lakukan:

1. **Read error message** — cari tahu file, line, dan type error
2. **Read affected file** — lihat konteks sekitar line error
3. **Cross-check RULE.md** — apakah ada aturan yang dilanggar?
4. **Cross-check ARCHITECTURE.md** — apakah patternnya sesuai?
5. **Identify root cause** — bukan symptom, tapi penyebab sebenarnya

**Root Cause Template:**

```markdown
### Error {#}: {Error Type}
**File:** `path/to/file.dart:{line}`
**Error Message:**
```
{exact error output}
```
**Root Cause:** {one sentence explanation}
**Why it happened:** {why the code is wrong}
**Fix:** {minimal fix description}
```

### Step 3: Generate Fix

Untuk setiap root cause, generate fix:

**Fix Strategy Matrix:**

| Category | Fix Strategy | Example |
|----------|-------------|---------|
| Syntax | Fix typo | Add missing `;`, `}` |
| Type | Add import / fix type | `import 'package:...'` |
| State | Fix provider scope | Wrap with `Consumer()` |
| Pattern | Refactor ke pattern yang benar | Replace `setState` dengan `ref.read` |
| Build | Fix config | Add asset to pubspec |
| Test | Fix test / fix code | Update assertion / add widget |
| Runtime | Add null safety | Add `?.` / `??` / null check |

**WAJIB:**
- Fix minimal — hanya ubah yang error, jangan refactor seluruh file
- Setelah fix, VERIFY dengan re-run command
- Jika fix pertama tidak berhasil → diagnose ulang, jangan tebak

### Step 4: Generate Error Report

```markdown
# 🔧 Error Recovery Report
# {Nama Project}

> **Generated after error analysis.**

---

## 📊 Summary

| Metric | Value |
|--------|-------|
| Total Errors | X |
| Critical | X |
| Warnings | X |
| Fixed | X / X |
| **Status** | **ALL FIXED / NEEDS ATTENTION** |

---

## 📋 Error Details

### Error 1: {Type}
**File:** `{path}:{line}`
**Severity:** Critical / Warning
**Root Cause:** {explanation}
**Fix Applied:** {yes/no}
**Verification:** {passed/failed}

---

## 🔄 Re-Generate Prompt (Jika Perlu)

Jika error karena pattern yang salah:
```
Update file `{path}` untuk mengikuti aturan RULE.md:
❌ [wrong pattern yang terjadi]
✅ [correct pattern dari RULE.md/ARCHITECTURE.md]

Error yang terjadi: [error message]
```

---

## ✅ Verification Command

```bash
# Re-run command untuk verifikasi:
{command to verify fix}
```
```

### Step 5: Apply & Verify

1. Apply fix ke file
2. Jalankan ulang command yang gagal
3. Jika pass → tandai selesai
4. Jika masih error → ulangi Step 1-3 untuk error baru

### Step 6: Update RULE.md (Jika Perlu)

Jika error terjadi karena **missing rule** (aturan yang tidak tercakup di RULE.md tapi seharusnya ada):
- Catat pattern yang seharusnya dilarang
- Sarankan update RULE.md

## Quality Criteria

- Root cause HARUS diidentifikasi, bukan hanya "error di file X"
- Fix HARUS minimal — jangan refactor file yang tidak error
- Setiap fix HARUS diverifikasi dengan re-run command
- Jika error pattern -> update RULE.md untuk mencegah terulang

## Example Prompt

```
Jalankan workflow vibe-coding-toolkit/09_error_recovery.md

Error output:
```
Error: The method 'setState' isn't defined for the type 'RiverpodController'.
Try correcting the name to the name of an existing method, or defining a method named 'setState'.
```
Output directory: prd/finance-app/
File modified: lib/features/transactions/presentation/controllers/transaction_controller.dart
```

---

## Cross-References

- **Bergantung pada:** RULE.md (pattern validation), ARCHITECTURE.md (correct patterns)
- **Output:** ERROR_REPORT.md + fixed files
- **Waktu tepat digunakan:** Setiap kali analyzer/build/test gagal selama vibe coding

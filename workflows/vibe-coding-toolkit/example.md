---
description: Contoh penggunaan workflow vibe-coding-toolkit untuk berbagai skenario
version: 1.0.0
last_updated: 2026-03-14
---

# Contoh Penggunaan Vibe Coding Toolkit

## 🚀 Quick Start — Pipeline Lengkap Dari Awal (Rekomendasi)

### Tanpa PRD (mulai dari ide):
```
Jalankan pipeline lengkap vibe-coding-toolkit untuk project berikut:

Ide: "Aplikasi expense tracker dengan Flutter, bisa catat pengeluaran,
      lihat grafik per bulan, setting budget, pake Riverpod + Hive"

Output folder: prd/flutter-finance/

Pipeline:
00. Generate structured PRD dari ide di atas → PRD.md
01. Validasi PRD → PRD_VALIDATION.md (jika FAIL, iterasi PRD)
02-07. Generate semua file pendukung
07. Review & iterate → REVIEW_REPORT.md
    ↓
    validate_output.sh — Validasi otomatis struktur file
```

### Dengan PRD sudah siap:
```
Jalankan pipeline lengkap vibe-coding-toolkit untuk PRD berikut:

PRD: @agents/docs/plans/2026-03-11-personal-finance-app-prd.md
Output folder: prd/flutter-finance/

Pipeline:
01. PRD_VALIDATION.md — Validasi PRD completeness (Quality Gate)
    ↓ jika PASS
02. RULE.md — dari PRD sections: Tech Stack, Architecture, Dependencies
03. DESIGN.md — dari PRD sections: UI/UX, Color Palette, Typography
04. AI_INSTRUCTIONS.md — dari PRD + RULE.md + DESIGN.md (dengan testing phase wajib)
05. CHECKLIST.md — dari AI_INSTRUCTIONS.md
06. ARCHITECTURE_CHEATSHEET.md — dari PRD + RULE.md + DESIGN.md
    ↓
07. REVIEW_REPORT.md — Review & iterasi konsistensi output
    ↓
    validate_output.sh — Validasi otomatis struktur file
    ↓
08. Bundle AI context → AI_CONTEXT.md (siap untuk coding session)
```

---

## 📝 Per File — Generate Satu per Satu

### Generate PRD Validation Saja (Quality Gate)
```
Jalankan workflow vibe-coding-toolkit/01_validate_prd.md

PRD: @agents/docs/plans/my-ecommerce-prd.md
Output: prd/my-ecommerce/PRD_VALIDATION.md

Note: Workflow ini WAJIB dijalankan pertama. Jika FAIL, perbaiki PRD dulu.
```

### Generate RULE.md Saja
```
Jalankan workflow vibe-coding-toolkit/02_generate_rule.md

PRD: @agents/docs/plans/my-ecommerce-prd.md
Output: prd/my-ecommerce/RULE.md

Tech stack yang dipakai: Next.js 14 + TypeScript + Prisma + PostgreSQL
```

### Generate DESIGN.md Saja
```
Jalankan workflow vibe-coding-toolkit/03_generate_design.md

PRD: @agents/docs/plans/my-ecommerce-prd.md
Output: prd/my-ecommerce/DESIGN.md
Tech: React + TypeScript (output dalam TypeScript constants)
```

### Generate AI Context Bundle (Untuk Coding Session)
```
Jalankan workflow vibe-coding-toolkit/08_bundle_ai_context.md

Output directory: prd/my-ecommerce/
Current task: Task 2.3 (ProductDetailScreen)
Output: prd/my-ecommerce/AI_CONTEXT.md

Note: Copy-paste AI_CONTEXT.md sebagai prompt awal AI coding assistant.
```

### Error Recovery (Saat Build/Analyzer Gagal)
```
Jalankan workflow vibe-coding-toolkit/09_error_recovery.md

Error output:
```
Error: The named parameter 'context' isn't defined.
Try correcting the name to an existing parameter...
```
Output directory: prd/my-ecommerce/
File modified: lib/features/products/presentation/screens/product_detail_screen.dart
```

### Test Execution & Validation
```
Jalankan workflow vibe-coding-toolkit/11_test_execution.md

Project directory: @prd/my-ecommerce/
RULE.md: @prd/my-ecommerce/RULE.md
CHECKLIST.md: @prd/my-ecommerce/CHECKLIST.md
```

### Code Review (Sebelum Merge)
```
Jalankan workflow vibe-coding-toolkit/12_code_review.md

Files to review: lib/features/products/
RULE.md: @prd/my-ecommerce/RULE.md
ARCHITECTURE.md: @prd/my-ecommerce/ARCHITECTURE_CHEATSHEET.md
Output: prd/my-ecommerce/reviews/
```

### Progress Sync (Auto-Update Checklist)
```
Jalankan workflow vibe-coding-toolkit/10_sync_progress.md

CHECKLIST.md: @prd/my-ecommerce/CHECKLIST.md
Project directory: @prd/my-ecommerce/
Method: git
```

### Generate AI_INSTRUCTIONS.md Saja
```
Jalankan workflow vibe-coding-toolkit/04_generate_ai_instructions.md

PRD: @agents/docs/plans/my-ecommerce-prd.md
RULE.md: @prd/my-ecommerce/RULE.md
DESIGN.md: @prd/my-ecommerce/DESIGN.md
Output: prd/my-ecommerce/AI_INSTRUCTIONS.md
```

### Generate CHECKLIST.md Saja
```
Jalankan workflow vibe-coding-toolkit/05_generate_checklist.md

PRD: @agents/docs/plans/my-ecommerce-prd.md
AI_INSTRUCTIONS: @prd/my-ecommerce/AI_INSTRUCTIONS.md
Output: prd/my-ecommerce/CHECKLIST.md
```

### Generate ARCHITECTURE_CHEATSHEET.md Saja
```
Jalankan workflow vibe-coding-toolkit/06_generate_architecture.md

PRD: @agents/docs/plans/my-ecommerce-prd.md
RULE.md: @prd/my-ecommerce/RULE.md
DESIGN.md: @prd/my-ecommerce/DESIGN.md
Output: prd/my-ecommerce/ARCHITECTURE_CHEATSHEET.md
```

### Generate Review Report (Final Check)
```
Jalankan workflow vibe-coding-toolkit/07_review_and_iterate.md

PRD: @agents/docs/plans/my-ecommerce-prd.md
Output: prd/my-ecommerce/
Scope: all files
```

### Validasi Otomatis
```bash
./workflows/vibe-coding-toolkit/validate_output.sh prd/my-ecommerce/
```

---

## 🔄 Berbagai Tech Stack

### Flutter + Riverpod
```
Pipeline lengkap:
00. Generate PRD dari ide "expense tracker Flutter" (opsional)
01. Validasi PRD @prd/finance-app-prd.md
02-07. Generate semua file
07. Review & iterate
08. Bundle AI context untuk coding session
09. Error recovery jika analyzer error
11. Test execution setelah implementasi
12. Code review sebelum merge
10. Sync progress ke checklist

Output: prd/finance-app/
Note: Flutter + Riverpod + Hive + GoRouter
```

### Next.js + React
```
Pipeline lengkap:
00. (Opsional) Generate PRD
01. Validasi PRD @prd/dashboard-prd.md
02-07. Generate semua file
07. Review
08. Bundle AI context
11. Test execution (Jest)
12. Code review

Output: prd/dashboard/
Note: Next.js 14 + TypeScript + Prisma + PostgreSQL + NextAuth
```

### Go Backend
```
00. (Opsional) Generate PRD dari notes
01. Validasi PRD @prd/api-prd.md
02-07. Generate
07. Review
08. Bundle context
11. Test execution (go test)
12. Code review

Output: prd/api/
Note: Go + Gin + GORM + PostgreSQL + JWT
```

---

## 💡 Tips Penggunaan

### Siklus Coding dengan Execution Workflows

Setelah generate selesai, berikut siklus coding yang direkomendasikan:

```
08. Bundle AI Context → prompt untuk AI coding assistant
    ↓
[AI Coding Session] — implementasi fitur dengan TDD
    ↓ error
09. Error Recovery → diagnosa & fix
    ↓
11. Test Execution → run tests, fix failures
    ↓
12. Code Review → review against RULE.md
    ↓
10. Sync Progress → auto-update CHECKLIST.md dari git
    ↓
[Repeat untuk task berikutnya]
```

### Workflow Ini Reusable

Setiap kali punya PRD baru, tinggal jalankan pipeline lengkap:
```
00. (Opsional) Generate PRD dari rough notes
00. Validate PRD (Quality Gate)
02-07: Generate semua file pendukung
06: Review & iterate
validate: ./validate_output.sh prd/{nama-project}/
08: Bundle AI context untuk mulai coding
```

AI akan auto-detect tech stack dari PRD dan generate file yang sesuai.

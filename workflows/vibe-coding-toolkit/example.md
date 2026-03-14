---
description: Contoh penggunaan workflow vibe-coding-toolkit untuk berbagai skenario
version: 1.0.0
last_updated: 2026-03-14
---

# Contoh Penggunaan Vibe Coding Toolkit

## 🚀 Quick Start — Generate Semua Sekaligus

```
Jalankan semua workflow vibe-coding-toolkit (01-05) untuk PRD berikut:

PRD: @agents/docs/plans/2026-03-11-personal-finance-app-prd.md
Output folder: prd/flutter-finance/

Generate 5 file berikut secara berurutan:
1. RULE.md — dari PRD sections: Tech Stack, Architecture, Dependencies
2. DESIGN.md — dari PRD sections: UI/UX, Color Palette, Typography
3. AI_INSTRUCTIONS.md — dari PRD + RULE.md + DESIGN.md
4. CHECKLIST.md — dari AI_INSTRUCTIONS.md
5. ARCHITECTURE_CHEATSHEET.md — dari PRD + RULE.md + DESIGN.md
```

---

## 📝 Per File — Generate Satu per Satu

### Generate RULE.md Saja
```
Jalankan workflow vibe-coding-toolkit/01_generate_rule.md

PRD: @agents/docs/plans/my-ecommerce-prd.md
Output: prd/my-ecommerce/RULE.md

Tech stack yang dipakai: Next.js 14 + TypeScript + Prisma + PostgreSQL
```

### Generate DESIGN.md Saja
```
Jalankan workflow vibe-coding-toolkit/02_generate_design.md

PRD: @agents/docs/plans/my-ecommerce-prd.md
Output: prd/my-ecommerce/DESIGN.md
Tech: React + TypeScript (output dalam TypeScript constants)
```

### Generate AI_INSTRUCTIONS.md Saja
```
Jalankan workflow vibe-coding-toolkit/03_generate_ai_instructions.md

PRD: @agents/docs/plans/my-ecommerce-prd.md
RULE.md: @prd/my-ecommerce/RULE.md
DESIGN.md: @prd/my-ecommerce/DESIGN.md
Output: prd/my-ecommerce/AI_INSTRUCTIONS.md
```

### Generate CHECKLIST.md Saja
```
Jalankan workflow vibe-coding-toolkit/04_generate_checklist.md

PRD: @agents/docs/plans/my-ecommerce-prd.md
AI_INSTRUCTIONS: @prd/my-ecommerce/AI_INSTRUCTIONS.md
Output: prd/my-ecommerce/CHECKLIST.md
```

### Generate ARCHITECTURE_CHEATSHEET.md Saja
```
Jalankan workflow vibe-coding-toolkit/05_generate_architecture.md

PRD: @agents/docs/plans/my-ecommerce-prd.md
RULE.md: @prd/my-ecommerce/RULE.md
DESIGN.md: @prd/my-ecommerce/DESIGN.md
Output: prd/my-ecommerce/ARCHITECTURE_CHEATSHEET.md
```

---

## 🔄 Berbagai Tech Stack

### Flutter + Riverpod
```
Jalankan semua workflow vibe-coding-toolkit untuk PRD @prd/finance-app-prd.md
Output: prd/finance-app/
Note: Flutter + Riverpod + Hive + GoRouter
```

### Flutter + BLoC
```
Jalankan semua workflow vibe-coding-toolkit untuk PRD @prd/chat-app-prd.md
Output: prd/chat-app/
Note: Flutter + BLoC + Firebase Firestore + auto_route
```

### Next.js + React
```
Jalankan semua workflow vibe-coding-toolkit untuk PRD @prd/dashboard-prd.md
Output: prd/dashboard/
Note: Next.js 14 + TypeScript + Prisma + PostgreSQL + NextAuth
```

### Nuxt + Vue
```
Jalankan semua workflow vibe-coding-toolkit untuk PRD @prd/cms-prd.md
Output: prd/cms/
Note: Nuxt 3 + TypeScript + Pinia + Supabase
```

### Go Backend
```
Jalankan semua workflow vibe-coding-toolkit untuk PRD @prd/api-prd.md
Output: prd/api/
Note: Go + Gin + GORM + PostgreSQL + JWT
```

### Laravel + PHP
```
Jalankan semua workflow vibe-coding-toolkit untuk PRD @prd/marketplace-prd.md
Output: prd/marketplace/
Note: Laravel 11 + PHP 8.3 + MySQL + Redis + Stripe
```

---

## 💡 Tips Penggunaan

### Setelah Generate, Lalu Apa?

1. **Review** — Baca ke-5 file, pastikan sesuai PRD
2. **Customize** — Sesuaikan jika ada yang kurang/berlebihan
3. **Mulai Vibe Coding** — Ikuti urutan di AI_INSTRUCTIONS.md
4. **Update Progress** — Tandai checklist di CHECKLIST.md setiap task selesai

### Workflow Ini Reusable

Setiap kali punya PRD baru, tinggal jalankan:
```
Jalankan semua workflow vibe-coding-toolkit untuk PRD @[path/ke/prd-baru.md]
Output: prd/{nama-project-baru}/
```

AI akan auto-detect tech stack dari PRD dan generate file yang sesuai.

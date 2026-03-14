---
description: Generate AI_INSTRUCTIONS.md — Template prompt per fitur/fase dari sebuah PRD untuk vibe coding
version: 1.0.0
last_updated: 2026-03-14
skills:
  - vibe-coding-specialist
  - senior-software-engineer
  - senior-prompt-engineer
---

// turbo-all

# Workflow: Generate AI_INSTRUCTIONS.md

## Agent Behavior

When executing this workflow, the agent MUST:
- Read PRD sections tentang features, screens, architecture, dan data models
- Read RULE.md dan DESIGN.md yang sudah di-generate sebelumnya
- Bagi features menjadi phases yang logis (Foundation → Core → Advanced → Polish)
- Setiap task HARUS cukup kecil untuk satu prompt AI (1 file atau 1 fitur small)
- Setiap prompt HARUS reference RULE.md dan DESIGN.md
- Include PRD section reference di setiap prompt
- Include troubleshooting prompts di bagian akhir

## Overview

Generate file `AI_INSTRUCTIONS.md` dari sebuah PRD. File ini berisi kumpulan template prompt yang sudah dioptimasi untuk dipakai saat vibe coding — sehingga developer tinggal copy-paste prompt, tambahkan context, dan kirim ke AI.

## Input

- **PRD file** — Path ke Product Requirements Document
- **RULE.md** — File governance rules (output dari workflow 01)
- **DESIGN.md** — File design system (output dari workflow 02)
- **Output directory** — Folder tujuan output

## Output

- `{output_dir}/AI_INSTRUCTIONS.md`

## Prerequisites

- PRD lengkap
- RULE.md sudah di-generate (workflow 01)
- DESIGN.md sudah di-generate (workflow 02)

## Steps

### Step 1: Analisis Feature Scope dari PRD

Baca PRD dan buat list semua features/modules:

```
Contoh:
- Authentication
- User Profile
- Product Catalog
- Shopping Cart
- Checkout & Payment
- Order History
- Settings
- etc.
```

### Step 2: Kelompokkan ke Phases

Bagi features menjadi development phases berdasarkan dependency:

```
Phase 1: Foundation
  → Setup, theme, core utilities, shared widgets, database, routing

Phase 2: Core Features  
  → Fitur utama yang menjadi backbone app

Phase 3: Advanced Features
  → Fitur value-add, integrations, advanced UX

Phase 4: Analytics/Reporting (jika ada)
  → Charts, statistics, insights

Phase 5: Polish & Testing
  → Onboarding, settings, animations, tests
```

### Step 3: Breakdown Tasks per Phase

Setiap phase dipecah menjadi tasks yang cukup kecil:

**Rules untuk task breakdown:**
1. Satu task = 1-3 files (MAKS)
2. Task layer data dulu, lalu domain, lalu presentation
3. Setiap task bisa di-verify secara independen
4. Task TIDAK boleh depend-on task yang belum di-generate

### Step 4: Generate Template Prompts

Untuk setiap task, buat prompt template:

```markdown
### Task X.Y: [Nama Task]
\```
[Instruksi spesifik untuk AI]

[File targets yang harus dibuat:]
1. path/to/file1.dart — [deskripsi]
2. path/to/file2.dart — [deskripsi]

[Detail spesifik:]
- Field names, types
- Method signatures
- Constraints/validasi
- Reference ke section PRD

Referensi: PRD Section [X.Y]
\```
```

### Step 5: Generate Troubleshooting Section

Tambahkan 3-5 troubleshooting prompt templates:

1. **Jika AI generate wrong pattern** — Prompt untuk koreksi
2. **Jika dart/type analyze error** — Prompt untuk fix
3. **Jika UI tidak sesuai** — Prompt untuk perbaikan
4. **Jika missing imports** — Prompt untuk fix
5. **Jika performance issue** — Prompt untuk optimize

### Step 6: Generate DESIGN.md

Buat file AI_INSTRUCTIONS.md dengan struktur:

```markdown
# 🤖 AI_INSTRUCTIONS.md — Instruksi Prompt per Fitur
# {Nama Project}

> **File ini berisi template prompt yang sudah dioptimasi.**

---

## 📌 Cara Menggunakan File Ini
### Aturan Umum
### Context Stacking Formula
### Template Prompt Dasar

---

## 🏗️ PHASE 1: Foundation (Minggu X-Y)
### Task 1.1: [Nama]
### Task 1.2: [Nama]
...

## ⚡ PHASE 2: Core Features (Minggu X-Y)
### Task 2.1: [Nama]
...

## 🚀 PHASE 3: Advanced Features (Minggu X-Y)
### Task 3.1: [Nama]
...

## 📊 PHASE 4: Analytics (Minggu X-Y) [jika ada]
### Task 4.1: [Nama]
...

## ✨ PHASE 5: Polish & Testing (Minggu X-Y)
### Task 5.1: [Nama]
...

## ⚠️ Troubleshooting Prompts
### Jika AI Generate Code yang Salah Pattern
### Jika Analyzer Ada Error
### Jika UI Tidak Sesuai Design

---
```

### Step 7: Validasi

Sebelum menyimpan, validasi:
- [ ] Semua features dari PRD tercakup dalam task list
- [ ] Tasks terurut berdasarkan dependency (bisa dijalankan sequential)
- [ ] Setiap prompt cukup detail (bukan hanya "buat feature X")
- [ ] Setiap prompt reference PRD section
- [ ] Setiap prompt mention RULE.md dan DESIGN.md
- [ ] Troubleshooting prompts included
- [ ] Timeline estimates realistic

### Step 8: Simpan File

Simpan ke `{output_dir}/AI_INSTRUCTIONS.md`

## Quality Criteria

- Tasks HARUS cukup granular (1-3 files per task)
- Prompts HARUS actionable dan spesifik
- Prompts HARUS mention file paths yang exact
- Prompts HARUS mention method names, field names, types
- Prompts HARUS reference PRD sections
- Phase ordering HARUS logis (no forward dependencies)

## Example Prompt

```
Jalankan workflow vibe-coding-toolkit/03_generate_ai_instructions.md

PRD: @agents/docs/plans/my-app-prd.md
RULE.md: @prd/my-app/RULE.md
DESIGN.md: @prd/my-app/DESIGN.md
Output: prd/my-app/AI_INSTRUCTIONS.md
```

---

## Cross-References

- **Depends on:** `01_generate_rule.md` (RULE.md), `02_generate_design.md` (DESIGN.md)
- **Output digunakan oleh:** `04_generate_checklist.md`
- **Sumber data:** PRD (features, screens, data models, architecture)

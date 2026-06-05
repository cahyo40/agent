---
description: Generate structured PRD dari rough notes, ide, atau requirements yang belum terstruktur — entry point pipeline jika belum punya PRD
version: 2.0.0
last_updated: 2026-06-05
skills:
  - vibe-coding-specialist
  - senior-product-manager
  - senior-software-architect
  - senior-prompt-engineer
---

// turbo-all

# Workflow: Generate PRD dari Rough Notes

## Agent Behavior

When executing this workflow, the agent MUST:
- Baca input notes/requirements dengan seksama
- Infer tech stack, arsitektur, dan UI/UX dari deskripsi (jika tidak disebut explicit)
- Generate PRD yang LENGKAP dan TERSTRUKTUR — bukan outline kosong
- Setiap section HARUS punya konten substansial, bukan placeholder
- Format output mengikuti standar PRD yang dikenali oleh workflow 00-07
- Gunakan best practices PRD writing: problem statement, user stories, acceptance criteria

## Overview

Generate structured Product Requirements Document (PRD) dari input yang belum terstruktur. Workflow ini adalah **entry point opsional** — hanya perlu dijalankan jika belum punya PRD.

## Input

- **Source material** — Bisa berupa:
  - Catatan/notes bebas tentang aplikasi yang ingin dibangun
  - List fitur yang diinginkan
  - Screenshot/dokumen existing (jika migrate/rebuild)
  - Product one-pager
  - Slack/WhatsApp conversation dump
  - Lisan (deskripsi dari user)

- **Output directory** — Folder tujuan output

## Output

- `{output_dir}/PRD.md` — Structured PRD siap divalidasi oleh workflow 00

## Steps

### Step 1: Ekstrak Informasi dari Source

Baca source material dan ekstrak informasi ke kategori berikut:

| Kategori | Yang Dicari |
|----------|-------------|
| **Product Overview** | Nama app, purpose, target user, problem yang diselesaikan |
| **Core Features** | Fitur utama MVP, fitur advanced (phase 2) |
| **Tech Preferences** | Framework, bahasa, database, hosting (jika disebut) |
| **UI/UX References** | Referensi desain, warna, font, inspirasi |
| **Target Platform** | Mobile/Web/Desktop, iOS/Android/both |
| **Timeline** | Deadline, milestone, resource |

### Step 2: Infer yang Tidak Disebut

Untuk informasi yang tidak ada di source, buat keputusan yang masuk akal:

- **Tech stack** — Infer dari project type (mobile app → Flutter/Swift/Kotlin, web app → Next.js/React, API → Go/FastAPI)
- **Architecture** — Clean Architecture untuk Flutter, feature-first untuk Next.js
- **UI/UX** — Modern minimal design dengan pertimbangan platform
- **Database** — Local + remote strategy, pilih yang sesuai scale

Tandai setiap inferred decision dengan `[Inferred]` di PRD.

### Step 3: Generate PRD

Generate PRD dengan struktur berikut — SETIAP section WAJIB punya konten:

```markdown
# PRD: {Nama Project}

> **Product Requirements Document**
> Generated from: rough notes

---

## 1. Executive Summary
- Problem statement
- Target users
- Value proposition
- Success metrics

## 2. Product Overview
- App name, tagline
- Platform (Mobile/Web/Desktop)
- Key differentiators
- Technical constraints

## 3. Tech Stack & Architecture
- **Framework:** [choice]
- **Language:** [choice]
- **State Management:** [choice]
- **Database:** [local + remote strategy]
- **Architecture Pattern:** [choice]
- **Target Platform:** [detail]
- **Deployment:** [strategy]

## 4. Features

### Phase 1: MVP (Core)
| Feature | Description | Acceptance Criteria |
|---------|-------------|-------------------|
| F1 | [description] | [criteria] |

### Phase 2: Advanced
| Feature | Description | Acceptance Criteria |
|---------|-------------|-------------------|

### Phase 3: Polish
| Feature | Description | Acceptance Criteria |
|---------|-------------|-------------------|

## 5. Screen / Route List

| # | Screen | Route | Feature | Description |
|---|--------|-------|---------|-------------|
| 1 | [name] | /[path] | [feature] | [purpose] |

## 6. UI/UX Design Guidelines
- **Design Philosophy:** [clean/minimal/fun/corporate]
- **Color Palette:**
  - Primary: #HEX
  - Secondary: #HEX
  - Background: #HEX
  - Surface: #HEX
  - Text: #HEX
  - Semantic (success/warning/error): #HEX
- **Typography:**
  - Font family: [name]
  - Headline: [size/weight]
  - Body: [size/weight]
  - Caption: [size/weight]
- **Spacing:** Base unit: [X]px
- **Component Specs:**
  - Buttons: [height, radius, style]
  - Cards: [radius, elevation]
  - Inputs: [style, height]

## 7. Data Model
### Core Entities

#### [Entity Name]
| Field | Type | Notes |
|-------|------|-------|
| id | String | UUID |
| name | String | Required |

### Relationships
[Entity A] 1:N [Entity B]
[Entity B] N:M [Entity C]

## 8. Database Schema
### Local Storage
- Storage solution: [Hive/SQLite/SharedPreferences]
- Collections/Tables: [list]

### Remote (if applicable)
- Database: [Firestore/PostgreSQL/ Supabase]
- Collections/Tables: [list]

## 9. Error Handling Strategy
- **Pattern:** [Result<T> / Either / try-catch]
- **Global handler:** Yes/No
- **User-facing:** [Snackbar/Dialog/Toast]

## 10. Testing Strategy
- **Framework:** [native / flutter_test / jest / pytest]
- **Coverage Targets:** Unit: 80%, Widget: 70%, Integration: 50%
- **Approach:** TDD

## 11. Folder Structure
```
project_root/
├── lib/
│   ├── core/
│   ├── features/
│   │   └── [feature]/
│   │       ├── data/
│   │       ├── domain/
│   │       └── presentation/
│   └── main.dart
├── test/
└── ...
```

## 12. Dependencies
| Package | Version | Purpose |
|---------|---------|---------|
| [name] | [version] | [purpose] |

## 13. Route Definitions
| Path | Screen | Parameters |
|------|--------|------------|
| /[path] | [Screen] | [params] |

## 14. Open Questions
- [Question 1]
- [Question 2]
```

### Step 4: Validasi Internal

Sebelum menyimpan, pastikan:
- [ ] Semua sections substansial (bukan "TBD" atau placeholder)
- [ ] Features punya acceptance criteria yang testable
- [ ] Tech stack decisions jelas (inferred ditandai)
- [ ] Screen list minimal 3 screen
- [ ] Data model minimal 2 entities
- [ ] UI/UX guidelines spesifik (bukan "modern looking app")
- [ ] Inferred decisions masuk akal untuk project type

### Step 5: Simpan File

Simpan ke `{output_dir}/PRD.md`

## Quality Criteria

- PRD harus SELF-CONTAINED — semua informasi yang dibutuhkan workflow 00-07 ada di sini
- Inferred decisions HARUS ditandai agar bisa direview
- Acceptance criteria HARUS testable (bisa diverifikasi)
- Tech stack HARUS spesifik (bukan "Flutter or React Native")

## Example Prompt

```
Jalankan workflow vibe-coding-toolkit/00_generate_prd.md

Source: Saya mau bikin apps expense tracker simple.
Bisa catat pengeluaran harian, lihat grafik pengeluaran per bulan,
dan setting budget. Pake Flutter saja.

Output: prd/expense-tracker/PRD.md
```

---

## Cross-References

- **Output digunakan oleh:** `01_validate_prd.md` (Quality Gate)
- **Ini adalah ALTERNATIF dari PRD buatan manual** — jalankan hanya jika belum punya PRD
- **Setelah PRD siap, pipeline normal:** 00 → 01 → 02 → 03 → 04 → 05 → 06

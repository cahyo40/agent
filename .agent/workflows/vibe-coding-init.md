---
description: Initialize Vibe Coding context files for a new project with anti-hallucination guardrails
---

# /vibe-coding-init

Workflow untuk setup dokumen konteks Vibe Coding yang lengkap. Dokumen-dokumen ini berfungsi sebagai "guardrails" agar AI bekerja presisi dan minim halusinasi.

---

## 📋 Prerequisites

Sebelum memulai, siapkan informasi berikut:

1. **Deskripsi ide aplikasi** (2-3 paragraf)
2. **Target platform** (Web/Mobile/Desktop)
3. **Vibe/estetika** yang diinginkan (Modern, Minimalist, Playful, Corporate, dll)
4. **Tech preference** (jika ada, misal: "harus pakai Flutter" atau "preferensi Supabase")

---

## 💡 Phase 0: Ideation & Brainstorming

Phase ini menggunakan skill `@brainstorming` untuk mengklarifikasi ide sebelum masuk ke dokumentasi teknis.

### Step 0.1: Problem Framing

Gunakan skill `brainstorming`:

```markdown
Act as brainstorming.
Berdasarkan ide user, buatkan Problem Framing Canvas:

## Problem Framing Canvas
### 1. WHAT is the problem? [Satu kalimat spesifik]
### 2. WHO is affected? [Primary users, stakeholders]
### 3. WHY does it matter? [Pain points, business opportunity]
### 4. WHAT constraints exist? [Time, budget, technology]
### 5. WHAT does success look like? [Measurable outcomes]
```

### Step 0.2: Feature Ideation

```markdown
Act as brainstorming.
Generate fitur potensial dengan:
- HMW (How Might We) Questions
- SCAMPER Analysis untuk fitur utama
```

### Step 0.3: Feature Prioritization

```markdown
Act as brainstorming.
Prioritasikan dengan:
- Impact vs Effort Matrix
- RICE Scoring (Reach × Impact × Confidence / Effort)
- MoSCoW: Must Have, Should Have, Could Have, Won't Have
```

### Step 0.4: Quick Validation

```markdown
Act as brainstorming.
Validasi dengan checklist:
- Feasibility: Bisa dibangun?
- Viability: Layak secara bisnis?
- Desirability: User mau pakai?
- Go/No-Go Decision
```

// turbo
**Simpan output ke file `BRAINSTORM.md` di root project.**

---

## 🏗️ Phase 1: The Holy Trinity (WAJIB)

File-file ini adalah pondasi utama. Jalankan secara berurutan.

### Step 1.1: Generate PRD.md

```
Tanyakan kepada user:
"Jelaskan ide aplikasi yang ingin dibuat secara detail. Sertakan:
- Apa masalah yang diselesaikan?
- Siapa target penggunanya?
- Apa fitur utama yang diinginkan?"
```

Setelah user menjawab, gunakan skill `senior-project-manager`:

```markdown
Act as senior-project-manager.
Berdasarkan deskripsi berikut: [IDE USER]

Buatkan file `PRD.md` yang mencakup:
1. Executive Summary (2-3 kalimat)
2. Problem Statement
3. Target User & Persona
4. User Stories (min 10 untuk MVP)
5. Core Features - kategorikan: Must Have, Should Have, Could Have, Won't Have
6. User Flow
7. Success Metrics (KPIs)

Output dalam Markdown yang rapi.
```

// turbo
**Simpan output ke file `PRD.md` di root project.**

---

### Step 1.2: Generate TECH_STACK.md

```
Tanyakan kepada user:
"Apakah ada preferensi teknologi tertentu? Atau biarkan saya rekomendasikan berdasarkan kebutuhan PRD?"
```

Gunakan skill `tech-stack-architect`:

```markdown
Act as tech-stack-architect.
Berdasarkan PRD.md yang sudah dibuat, rekomendasikan tech stack yang optimal.

Buatkan file `TECH_STACK.md` dengan format:

## Core Stack
- Framework: [PILIHAN] + alasan
- Language: [PILIHAN]
- Styling: [PILIHAN] + alasan

## Backend & Data  
- Backend: [PILIHAN] + alasan
- Database: [PILIHAN]
- Auth: [PILIHAN]

## Infrastructure
- Hosting: [PILIHAN]
- CI/CD: [PILIHAN]

## Approved Packages
[Daftar lengkap package yang di-approve]

## Constraints
- Library di luar daftar DILARANG tanpa approval
- Semua dependency harus versi stable terbaru
```

// turbo
**Simpan output ke file `TECH_STACK.md` di root project.**

---

### Step 1.3: Generate RULES.md

Gunakan skill `senior-software-engineer`:

```markdown
Act as senior-software-engineer.
Berdasarkan TECH_STACK.md, buatkan file `RULES.md` sebagai panduan AI.

## Code Quality Rules
- Prinsip SOLID, DRY, KISS
- Nama variabel deskriptif (min 3 karakter)
- Max 200 baris per file

## Type Safety Rules
- TypeScript strict mode / Dart strict mode
- DILARANG menggunakan `any` atau `dynamic`
- Semua function harus punya return type

## Error Handling Rules
- Semua async call di-wrap try-catch
- User-friendly error messages

## AI Behavior Rules
1. JANGAN import library di luar package.json/pubspec.yaml
2. JANGAN tinggalkan komentar TODO atau placeholder
3. JANGAN menimpa file tanpa membaca isi terlebih dahulu
4. JANGAN menebak nama kolom database - refer ke DB_SCHEMA.md
5. IKUTI pola coding yang ada di file lain
6. SELALU handle loading state dan error state

## Workflow Rules
- Sebelum coding, jelaskan rencana dalam 3 bullet points
- Setelah coding, validasi dengan TECH_STACK.md
- Jika ragu, TANYA user
```

// turbo
**Simpan output ke file `RULES.md` di root project.**

---

## 🎨 Phase 2: Support System (Sangat Disarankan)

### Step 2.1: Generate DESIGN_SYSTEM.md

```
Tanyakan kepada user:
"Jelaskan vibe/estetika yang diinginkan. Contoh:
- Modern & Minimalist
- Dark Mode dengan Glassmorphism
- Playful dengan warna cerah
- Corporate & Professional"
```

Gunakan skill `design-system-architect`:

```markdown
Act as design-system-architect.
Buatkan `DESIGN_SYSTEM.md` dengan vibe: [VIBE USER]

## Color Palette
### Light Mode
- Primary, Secondary, Background, Surface
- Text Primary, Text Secondary
- Success, Warning, Error

### Dark Mode
- [Warna yang sama untuk dark mode]

## Typography
- Font Family: [Google Font]
- Scale: H1, H2, H3, Body, Small, Caption

## Spacing System
- Base unit: 4px
- Scale: 4, 8, 12, 16, 24, 32, 48, 64

## Border Radius
- Small: 4px, Medium: 8px, Large: 16px, Full: 9999px

## Shadows
- sm, md, lg

## Component Specs
- Button (Primary, Secondary, Ghost)
- Card
- Input

## Animation & Motion
- Transition duration: 150ms, 300ms, 500ms
- Easing curves
```

// turbo
**Simpan output ke file `DESIGN_SYSTEM.md` di root project.**

---

### Step 2.2: Generate DB_SCHEMA.md

Gunakan skill `database-modeling-specialist`:

```markdown
Act as database-modeling-specialist.
Berdasarkan fitur di PRD.md, desain database schema.

Buatkan `DB_SCHEMA.md`:

## Entity Relationship

### Table: users
| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK | User ID |
| email | text | UNIQUE, NOT NULL | Email |
[Lanjutkan untuk semua kolom]

[Tambahkan tabel lain sesuai kebutuhan fitur]

## Relationships
- [Daftar relasi antar tabel]

## Indexes
- [Daftar index yang diperlukan]

## Row Level Security (jika pakai Supabase)
- [Aturan RLS]

## Example Data
[JSON contoh data]
```

// turbo
**Simpan output ke file `DB_SCHEMA.md` di root project.**

---

### Step 2.3: Generate FOLDER_STRUCTURE.md

Gunakan skill `senior-software-architect`:

```markdown
Act as senior-software-architect.
Berdasarkan TECH_STACK.md, buatkan struktur folder project.

Buatkan `FOLDER_STRUCTURE.md`:

## Project Structure
```

/src (atau /lib untuk Flutter)
  /app atau /pages
  /components atau /widgets
  /lib atau /core
  /types atau /models
  /styles

```

## Naming Convention
- Components: PascalCase
- Utils: camelCase
- Types: camelCase.types.ts

## Rules
- [Aturan penempatan file]
```

// turbo
**Simpan output ke file `FOLDER_STRUCTURE.md` di root project.**

---

### Step 2.4: Generate API_CONTRACT.md

Gunakan skill `api-design-specialist`:

```markdown
Act as api-design-specialist.
Berdasarkan PRD.md dan DB_SCHEMA.md, definisikan API endpoints.

Buatkan `API_CONTRACT.md`:

## Authentication
### POST /api/auth/register
**Request Body:**
```json
{ "email": "string", "password": "string" }
```

**Response 201:** { user, token }
**Response 400:** Validation error

[Tambahkan endpoint untuk semua fitur]

## Error Response Format

```json
{
  "error": {
    "code": "ERROR_CODE",
    "message": "Human readable message"
  }
}
```

```

// turbo
**Simpan output ke file `API_CONTRACT.md` di root project.**

---

### Step 2.5: Generate EXAMPLES.md

Gunakan skill `senior-software-engineer`:

```markdown
Act as senior-software-engineer.
Buatkan `EXAMPLES.md` berisi contoh kode "sempurna" yang jadi standar project.

## 1. Component Pattern
[Contoh kode komponen ideal]

## 2. API Call Pattern
[Contoh kode fetch/dio ideal]

## 3. Custom Hook/Provider Pattern
[Contoh state management ideal]

## 4. Error Handling Pattern
[Contoh error handling ideal]

SEMUA kode baru harus mengikuti pola di atas.
```

// turbo
**Simpan output ke file `EXAMPLES.md` di root project.**

---

## 📊 Phase 3: Architecture Diagrams (Opsional)

### Step 3.1: Generate APP_FLOW.md

Gunakan skill `mermaid-diagram-expert`:

```markdown
Act as mermaid-diagram-expert.
Buatkan `APP_FLOW.md` dengan diagram Mermaid untuk:

1. User Authentication Flow
2. Main Feature Flow
3. Error Handling Flow

Format: flowchart TD dengan penjelasan naratif di bawah setiap diagram.
```

// turbo
**Simpan output ke file `APP_FLOW.md` di root project.**

---

## ✅ Phase 4: Validation

Setelah semua file dibuat, lakukan validasi:

```
Baca kembali semua file yang telah dibuat:
- PRD.md
- TECH_STACK.md
- RULES.md
- DESIGN_SYSTEM.md
- DB_SCHEMA.md
- FOLDER_STRUCTURE.md
- API_CONTRACT.md
- EXAMPLES.md
- APP_FLOW.md (jika dibuat)

Pastikan:
1. Tidak ada konflik antar dokumen
2. Tech stack konsisten di semua file
3. Naming convention seragam
4. Semua fitur di PRD tercakup di DB_SCHEMA dan API_CONTRACT
```

---

## 📁 Final Checklist

Setelah workflow selesai, project root harus memiliki file-file berikut:

```
/project-root
├── PRD.md                 ✅ Holy Trinity
├── TECH_STACK.md          ✅ Holy Trinity
├── RULES.md               ✅ Holy Trinity
├── DESIGN_SYSTEM.md       ✅ Support System
├── DB_SCHEMA.md           ✅ Support System
├── FOLDER_STRUCTURE.md    ✅ Support System
├── API_CONTRACT.md        ✅ Support System
├── EXAMPLES.md            ✅ Support System
└── APP_FLOW.md            ✅ Architecture (optional)
```

---

## 🚀 Next Steps

Setelah semua dokumen siap:

1. **Scaffold Project**: Inisialisasi project sesuai TECH_STACK.md
2. **Setup Database**: Jalankan migration sesuai DB_SCHEMA.md
3. **Start Coding**: Mulai dari fitur "Must Have" di PRD.md

---

## 💡 Tips Penggunaan

### Magic Words untuk Prompt

- "Refer ke file [X].md" — Memaksa AI membaca konteks
- "Jangan improvisasi" — Mencegah kreativitas yang tidak diminta
- "Ikuti pola di EXAMPLES.md" — Menjaga konsistensi
- "Validasi dengan RULES.md" — Self-check

### Troubleshooting Halusinasi

| Masalah | Solusi |
|---------|--------|
| AI pakai library salah | Minta AI baca ulang TECH_STACK.md |
| UI tidak konsisten | Refer ke DESIGN_SYSTEM.md |
| Nama kolom DB salah | Copy-paste dari DB_SCHEMA.md |
| Coding style berbeda | Refer ke EXAMPLES.md |

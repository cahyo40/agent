# 🎨 Vibe Coding Workflows

Panduan lengkap untuk menggunakan workflow Vibe Coding - sistem anti-halusinasi AI untuk development yang presisi dan konsisten.

---

## 📖 Daftar Isi

- [Apa itu Vibe Coding?](#apa-itu-vibe-coding)
- [Daftar Workflows](#daftar-workflows)
- [Cara Penggunaan](#cara-penggunaan)
- [Contoh Lengkap](#contoh-lengkap)
- [Tips & Tricks](#tips--tricks)
- [Troubleshooting](#troubleshooting)

---

## 🤔 Apa itu Vibe Coding?

**Vibe Coding** adalah metodologi development dengan AI yang menggunakan dokumen konteks sebagai "guardrails" untuk:

1. ✅ **Mencegah halusinasi AI** - AI tidak akan mengarang library/API yang tidak ada
2. ✅ **Menjaga konsistensi** - Semua kode mengikuti pola yang sama
3. ✅ **Mempercepat development** - AI memahami konteks proyek dengan cepat
4. ✅ **Mengurangi error** - Type safety dan validasi built-in

### 📚 Dokumen Konteks

Setiap proyek Vibe Coding memiliki dokumen-dokumen ini:

| Dokumen | Fungsi | Prioritas |
|---------|--------|-----------|
| **PRD.md** | Product requirements, user stories, fitur | 🔴 WAJIB |
| **TECH_STACK.md** | Framework, library, dan constraints | 🔴 WAJIB |
| **RULES.md** | Aturan coding dan perilaku AI | 🔴 WAJIB |
| **DESIGN_SYSTEM.md** | Warna, typography, komponen UI | 🟡 Recommended |
| **DB_SCHEMA.md** | Database schema, relasi, RLS | 🟡 Recommended |
| **FOLDER_STRUCTURE.md** | Struktur folder dan naming | 🟡 Recommended |
| **API_CONTRACT.md** | API endpoints dan response types | 🟡 Recommended |
| **EXAMPLES.md** | Contoh kode standar | 🟡 Recommended |
| **APP_FLOW.md** | Diagram flow (Mermaid) | 🟢 Optional |

---

## 📋 Daftar Workflows

### Frontend Frameworks

| Workflow | Command | Deskripsi |
|----------|---------|-----------|
| `/vibe-coding-react` | React/Next.js | App Router, Server Components, TanStack Query |
| `/vibe-coding-vue` | Vue.js/Nuxt 3 | Composition API, Pinia, useFetch |
| `/vibe-coding-svelte` | Svelte/SvelteKit | Runes, SvelteKit, stores |
| `/vibe-coding-astro` | Astro | Static/SSR, Content Collections, Islands |

### Mobile Development

| Workflow | Command | Deskripsi |
|----------|---------|-----------|
| `/vibe-coding-flutter` | Flutter | Multi-platform (iOS, Android, Web, Desktop) |
| `/vibe-coding-react-native` | React Native | Expo, React Navigation, NativeWind |

### Backend Development

| Workflow | Command | Deskripsi |
|----------|---------|-----------|
| `/vibe-coding-nestjs` | NestJS | Modules, Guards, DTOs, Prisma |
| `/vibe-coding-go-backend` | Go API | Gin/Fiber/Echo, Clean Architecture |
| `/vibe-coding-python-backend` | Python API | FastAPI, async/await |
| `/vibe-coding-python-web` | Python Web | Django/FastAPI fullstack |
| `/vibe-coding-laravel` | Laravel | Eloquent, Form Requests, Resources |

### Full-Stack & General

| Workflow | Command | Deskripsi |
|----------|---------|-----------|
| `/vibe-coding-fullstack` | Monorepo | Turborepo, Next.js + NestJS |
| `/vibe-coding-init` | Generic | Template dasar untuk semua proyek |

---

## 🚀 Cara Penggunaan

### Langkah 1: Pilih Workflow

Ketik command workflow sesuai tech stack yang diinginkan:

```
/vibe-coding-flutter
```

atau

```
/vibe-coding-react
```

### Langkah 2: Jawab Pertanyaan

AI akan bertanya tentang:

- Deskripsi ide aplikasi
- Target platform
- Preferensi teknologi
- Vibe/estetika

### Langkah 3: Generate Dokumen

AI akan generate dokumen secara bertahap:

1. **Phase 1: Holy Trinity** (WAJIB)
   - PRD.md
   - TECH_STACK.md
   - RULES.md

2. **Phase 2: Support System**
   - DESIGN_SYSTEM.md
   - DB_SCHEMA.md
   - FOLDER_STRUCTURE.md
   - API_CONTRACT.md
   - EXAMPLES.md

3. **Phase 3: Project Setup**
   - Initialize project
   - Install dependencies
   - Create folder structure

### Langkah 4: Mulai Coding

Setelah semua dokumen siap, mulai development dengan prompt seperti:

```
Refer ke PRD.md, buatkan halaman login sesuai DESIGN_SYSTEM.md
dan ikuti pattern di EXAMPLES.md
```

---

## 📝 Contoh Lengkap

### Contoh 1: Membuat Aplikasi Flutter

**Step 1: Jalankan workflow**

```
/vibe-coding-flutter
```

**Step 2: Jawab pertanyaan**

```
User: Saya ingin membuat aplikasi manajemen keuangan pribadi.
- Fitur: tracking pengeluaran, budget, laporan bulanan
- Target: Android dan iOS
- Vibe: Modern, clean, dark mode
- State management: Riverpod
- Backend: Supabase
```

**Step 3: AI generate dokumen**

AI akan membuat file-file berikut di root project:

```
/my-finance-app
├── PRD.md                 # User stories, fitur
├── TECH_STACK.md          # Flutter + Riverpod + Supabase
├── RULES.md               # Coding guidelines
├── DESIGN_SYSTEM.md       # Colors, typography, components
├── DB_SCHEMA.md           # Supabase tables, RLS
├── FOLDER_STRUCTURE.md    # Clean Architecture structure
├── API_CONTRACT.md        # Supabase endpoints
└── EXAMPLES.md            # Code patterns
```

**Step 4: Mulai coding dengan konteks**

```
Buatkan halaman dashboard sesuai PRD.md fitur "lihat ringkasan keuangan".
- Gunakan Riverpod AsyncValue untuk state
- Widget ikuti DESIGN_SYSTEM.md
- Folder sesuai FOLDER_STRUCTURE.md
- Pattern ikuti EXAMPLES.md
```

---

### Contoh 2: Membuat Website Next.js

**Step 1: Jalankan workflow**

```
/vibe-coding-react
```

**Step 2: Jawab pertanyaan**

```
User: Saya ingin membuat landing page untuk SaaS product.
- Jenis: SSG (static)
- Fitur: Hero, Features, Pricing, FAQ, CTA
- Vibe: Modern, gradient, glassmorphism
- Backend: Tidak perlu (static)
```

**Step 3: AI generate dokumen**

```
/saas-landing
├── PRD.md
├── TECH_STACK.md          # Next.js + Tailwind + Framer Motion
├── RULES.md
├── DESIGN_SYSTEM.md       # Gradient colors, glass cards
├── FOLDER_STRUCTURE.md    # App Router structure
└── EXAMPLES.md            # Component patterns
```

**Step 4: Mulai coding**

```
Buatkan Hero section sesuai PRD.md dengan:
- Gradient background dari DESIGN_SYSTEM.md
- Animasi fade-in menggunakan Framer Motion
- Component structure ikuti EXAMPLES.md
```

---

### Contoh 3: Membuat API dengan NestJS

**Step 1: Jalankan workflow**

```
/vibe-coding-nestjs
```

**Step 2: Jawab pertanyaan**

```
User: Saya ingin membuat REST API untuk e-commerce.
- Fitur: Products, Orders, Users, Cart
- Database: PostgreSQL dengan Prisma
- Auth: JWT
- API Docs: Swagger
```

**Step 3: AI generate dokumen**

```
/ecommerce-api
├── PRD.md
├── TECH_STACK.md          # NestJS + Prisma + JWT
├── RULES.md               # Module rules, DTO patterns
├── DB_SCHEMA.md           # Prisma schema, relations
├── FOLDER_STRUCTURE.md    # NestJS module structure
├── API_CONTRACT.md        # REST endpoints
└── EXAMPLES.md            # Controller, Service, DTO patterns
```

**Step 4: Mulai coding**

```
Buatkan module Products sesuai API_CONTRACT.md:
- CRUD endpoints
- DTO validation dengan class-validator
- Prisma queries ikuti EXAMPLES.md
- Guard untuk protected routes
```

---

### Contoh 4: Monorepo Full-Stack

**Step 1: Jalankan workflow**

```
/vibe-coding-fullstack
```

**Step 2: Jawab pertanyaan**

```
User: Saya ingin membuat platform job board.
- Frontend: Next.js
- Backend: NestJS
- Database: PostgreSQL
- Shared types antara FE dan BE
```

**Step 3: AI generate dokumen**

```
/job-board
├── PRD.md
├── TECH_STACK.md          # Turborepo + Next.js + NestJS
├── RULES.md               # Workspace import rules
├── DESIGN_SYSTEM.md
├── DB_SCHEMA.md
├── FOLDER_STRUCTURE.md    # Monorepo structure
├── API_CONTRACT.md
└── EXAMPLES.md            # @repo/types, @repo/ui patterns
```

**Step 4: Mulai coding**

```
Buatkan @repo/types untuk Job entity:
- Zod schema dengan validation
- TypeScript type inference
- CreateJobDto dan UpdateJobDto

Kemudian gunakan di apps/web dan apps/api
```

---

## 💡 Tips & Tricks

### Magic Words untuk Prompt

Gunakan kata-kata ini untuk memaksa AI mengikuti konteks:

| Magic Word | Fungsi |
|------------|--------|
| "Refer ke [X].md" | Memaksa AI membaca dokumen |
| "Jangan improvisasi" | Mencegah kreativitas tidak diminta |
| "Ikuti pola di EXAMPLES.md" | Menjaga konsistensi kode |
| "Validasi dengan RULES.md" | Self-check terhadap rules |
| "Sesuai DESIGN_SYSTEM.md" | Konsistensi UI |
| "Handle semua state" | Loading, error, empty, success |

### Contoh Prompt yang Baik

```markdown
✅ BAIK:
"Buatkan halaman UserList sesuai PRD.md user story #3.
- Fetch data dengan hook pattern di EXAMPLES.md
- Styling ikuti DESIGN_SYSTEM.md
- Handle loading, error, empty state
- Type dari DB_SCHEMA.md User entity"

❌ BURUK:
"Buatkan halaman user list"
```

### Workflow Chaining

Kombinasikan workflow untuk proyek kompleks:

```
1. /vibe-coding-react untuk frontend
2. /vibe-coding-nestjs untuk backend
3. Gabungkan types di shared folder
```

Atau langsung gunakan:

```
/vibe-coding-fullstack
```

---

## 🔧 Troubleshooting

### AI Menggunakan Library yang Salah

**Masalah:** AI import library yang tidak ada di TECH_STACK.md

**Solusi:**

```
Baca ulang TECH_STACK.md. 
Gunakan HANYA package yang sudah di-approve.
Library X tidak ada di daftar, ganti dengan Y.
```

### UI Tidak Konsisten

**Masalah:** Warna/typography berbeda-beda

**Solusi:**

```
Refer ke DESIGN_SYSTEM.md untuk semua styling.
Gunakan CSS variables: var(--color-primary)
Jangan hardcode warna.
```

### Nama Kolom Database Salah

**Masalah:** AI menebak nama field yang tidak ada

**Solusi:**

```
Copy-paste schema dari DB_SCHEMA.md.
Field yang ada: id, email, name, created_at
Jangan asumsikan field lain.
```

### Coding Style Berbeda

**Masalah:** Pattern tidak konsisten antar file

**Solusi:**

```
WAJIB ikuti pattern di EXAMPLES.md:
- Component pattern: contoh #1
- Hook pattern: contoh #2
- API pattern: contoh #3
```

### AI Tidak Mengikuti Struktur Folder

**Masalah:** File dibuat di lokasi yang salah

**Solusi:**

```
Baca FOLDER_STRUCTURE.md sebelum membuat file.
File ini harus di: src/features/users/
Bukan di: src/components/
```

---

## 📚 Resources

### Workflow Files

Semua workflow tersedia di:

```
.agent/workflows/
├── vibe-coding-astro.md
├── vibe-coding-flutter.md
├── vibe-coding-fullstack.md
├── vibe-coding-go-backend.md
├── vibe-coding-init.md
├── vibe-coding-laravel.md
├── vibe-coding-nestjs.md
├── vibe-coding-python-backend.md
├── vibe-coding-python-web.md
├── vibe-coding-react-native.md
├── vibe-coding-react.md
├── vibe-coding-svelte.md
└── vibe-coding-vue.md
```

### Skills yang Digunakan

Workflow ini menggunakan skill-skill berikut:

- `senior-project-manager` - Generate PRD
- `tech-stack-architect` - Tech stack selection
- `design-system-architect` - Design system
- `database-modeling-specialist` - DB schema
- `api-design-specialist` - API contract
- `mermaid-diagram-expert` - Flow diagrams
- Framework-specific skills (Flutter, React, Vue, dll)

---

## 🎯 Quick Start

### Untuk Pemula

1. Jalankan `/vibe-coding-init` untuk template generic
2. Jawab pertanyaan tentang ide aplikasi
3. Review dokumen yang di-generate
4. Mulai coding dengan konteks

### Untuk Developer Berpengalaman

1. Pilih workflow sesuai tech stack
2. Skip pertanyaan yang sudah jelas
3. Edit dokumen sesuai kebutuhan
4. Langsung coding dengan prompt kontekstual

---

## 📝 Template Prompt Cepat

### Setelah Setup Selesai

```markdown
## Context
Refer ke semua dokumen .md di root project.

## Task
[Jelaskan task di sini]

## Requirements
- Ikuti RULES.md
- Styling dari DESIGN_SYSTEM.md
- Pattern dari EXAMPLES.md
- Types dari DB_SCHEMA.md

## Output
- File path sesuai FOLDER_STRUCTURE.md
- Handle semua state (loading, error, empty, data)
- No placeholder, code lengkap
```

---

**Happy Vibe Coding! 🚀**

---
description: Generate RULE.md — AI governance rules (DO & DON'T) dari sebuah PRD untuk vibe coding
version: 1.0.0
last_updated: 2026-03-14
skills:
  - vibe-coding-specialist
  - senior-software-architect
  - senior-software-engineer
---

// turbo-all

# Workflow: Generate RULE.md

## Agent Behavior

When executing this workflow, the agent MUST:
- Read the entire PRD thoroughly before generating
- Extract ALL technology decisions from the PRD (framework, state management, database, routing, etc.)
- Generate rules in the LANGUAGE that matches the tech stack (Dart for Flutter, TypeScript for Next.js, etc.)
- Be EXHAUSTIVE — setiap pattern yang ada di PRD harus punya rule
- Setiap rule HARUS punya ✅ (WAJIB) dan ❌ (DILARANG) section
- Include code snippets untuk setiap pattern yang correct

## Overview

Generate file `RULE.md` dari sebuah PRD. File ini berfungsi sebagai "kontrak" antara developer dan AI — setiap kali AI generate code, ia WAJIB mengikuti aturan di file ini.

## Input

- **PRD file** — Path ke Product Requirements Document
- **Output directory** — Folder tujuan output (default: `prd/{project-name}/`)

## Output

- `{output_dir}/RULE.md`

## Prerequisites

- PRD yang sudah mencakup:
  - Tech stack (framework, language, packages)
  - Arsitektur (pattern: MVC, Clean Architecture, dll)
  - State management choice
  - Database/storage choice
  - Routing strategy
  - Folder structure

## Steps

### Step 1: Baca PRD Secara Menyeluruh

Baca seluruh PRD dari awal hingga akhir. Catat:
- Tech stack yang dipilih
- Architecture pattern
- State management solution
- Database / storage solution
- Routing solution
- Package dependencies yang diizinkan
- Folder structure
- Naming conventions (jika ada)
- Testing strategy (jika ada)

### Step 2: Identifikasi Semua Pattern Decisions

Dari PRD, extract list semua "keputusan teknis":

```
Contoh untuk Flutter app:
- Architecture: Clean Architecture + Feature-First
- State Management: Riverpod 2.x + code generation
- Database: Hive with encryption
- Routing: GoRouter with named routes
- Error Handling: Result<T> sealed class
- i18n: flutter_localizations + intl + ARB files
```

### Step 3: Generate RULE.md

Buat file RULE.md dengan struktur berikut. Setiap section HARUS ada:

```markdown
# 📜 RULE.md — AI Governance Rules
# {Nama Project}

> **File ini adalah KONTRAK antara developer dan AI.**

---

## 🏛️ Arsitektur
### WAJIB: [pattern dari PRD]
### DILARANG: [anti-patterns]
- Folder structure
- Data flow pattern
- Layer separation rules

## 🔧 State Management: [solution dari PRD]
### WAJIB: [correct patterns + code]
### DILARANG: [alternative solutions yang TIDAK boleh dipakai]

## 🛡️ Error Handling
### WAJIB: [error strategy dari PRD]
### DILARANG: [incorrect error patterns]

## 🗄️ Database: [solution dari PRD]
### WAJIB: [correct usage patterns]
### Type IDs / Schema registry (jika applicable)
### DILARANG: [alternative databases]

## 🧭 Routing: [solution dari PRD]
### WAJIB: [correct navigation patterns]
### Route Map (semua routes dari PRD)
### DILARANG: [incorrect navigation patterns]

## 🌐 Localization (jika ada di PRD)
### WAJIB: [i18n patterns]
### DILARANG: [hardcoded strings]

## 📐 Naming Conventions
### File naming table
### Class naming table
### Provider/State naming convention

## 🎨 UI/Widget Rules
### WAJIB: [theme usage, const constructors, etc.]
### DILARANG: [hardcoded values, oversized widgets]
### Async State Pattern (loading/error/data handling)

## 📦 Dependencies
### HANYA gunakan packages berikut: [list from PRD]
### DILARANG menambahkan: [common alternatives that should NOT be used]

## 🧪 Testing (jika ada di PRD)
### WAJIB: [testing patterns, coverage targets]
### Test file structure

## 📝 Code Quality
### WAJIB: [lint rules, max file length, etc.]
### DILARANG: [code smells]
```

### Step 4: Validasi

Sebelum menyimpan, validasi:
- [ ] Setiap section punya WAJIB dan DILARANG
- [ ] Semua tech decisions dari PRD tercakup
- [ ] Code snippets benar syntax-nya
- [ ] Package list match dengan PRD
- [ ] Route map match dengan PRD
- [ ] Naming conventions konsisten

### Step 5: Simpan File

Simpan ke `{output_dir}/RULE.md`

## Quality Criteria

- Setiap rule HARUS actionable (bukan ambigu)
- Code snippets HARUS valid syntax
- Anti-patterns HARUS spesifik (sebutkan nama package/pattern yang dilarang)
- File HARUS self-contained (bisa dibaca tanpa PRD)

## Example Prompt

```
Jalankan workflow vibe-coding-toolkit/01_generate_rule.md

PRD: @agents/docs/plans/my-app-prd.md
Output: prd/my-app/RULE.md
```

---

## Cross-References

- **Output digunakan oleh:** `03_generate_ai_instructions.md`, `05_generate_architecture.md`
- **Sumber data:** PRD (tech stack, architecture, dependencies sections)

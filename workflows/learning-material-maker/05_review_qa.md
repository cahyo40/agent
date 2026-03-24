---
description: "Fase 5 — Review & Quality Assurance. Validasi seluruh materi, kode, dan output sebelum diberikan ke learner."
---

# Fase 5: Review & Quality Assurance

## Overview

Fase ini memastikan **semua materi akurat, kode berjalan benar, dan output berkualitas tinggi** sebelum diberikan ke learner. Gunakan pendekatan systematic review dari skill `senior-code-reviewer`.

## Pre-requisites

- Materi lengkap dari Fase 3
- Output dari Fase 4 (website/PDF/markdown)
- Skill: `senior-code-reviewer`, `debugging-specialist` (opsional)

## Instruksi

### Step 1: Code Review — Validasi Semua Contoh Kode

> **Skill:** `senior-code-reviewer`

Review setiap contoh kode di materi menggunakan piramida prioritas:

```
REVIEW PRIORITY
├── 1. CORRECTNESS: Apakah kode benar dan bisa dijalankan?
├── 2. ACCURACY: Apakah syntax sesuai versi terbaru?
├── 3. COMPLETENESS: Apakah semua import/dependency disertakan?
├── 4. READABILITY: Apakah kode mudah dipahami learner?
└── 5. BEST PRACTICE: Apakah mengikuti convention yang benar?
```

**Checklist per contoh kode:**
```markdown
- [ ] Kode bisa di-copy-paste langsung dan dijalankan
- [ ] Semua variable/function name konsisten
- [ ] Output yang diharapkan tercantum di komentar
- [ ] Tidak ada deprecated syntax
- [ ] Import statements lengkap dan benar
- [ ] Error handling sesuai level learner
```

### Step 2: Content Accuracy Review

Periksa akurasi teknis seluruh materi:

```markdown
## Content Review Checklist
- [ ] Definisi konsep akurat dan tidak misleading
- [ ] Analogi sesuai dan tidak membingungkan
- [ ] Urutan penjelasan logis (tidak skip prerequisite)
- [ ] Tidak ada informasi yang outdated
- [ ] Resource links masih aktif (cek dengan `read_url_content`)
- [ ] Mermaid diagrams ter-render dengan benar
- [ ] Gamification (badges/XP) terhitung dengan benar
```

### Step 3: Consistency Review

Pastikan konsistensi di seluruh materi:

```markdown
## Consistency Checklist
- [ ] Gaya penulisan sama di semua file (formal/casual/praktis)
- [ ] Bahasa konsisten (tidak mix ID/EN tanpa alasan)
- [ ] Formatting konsisten (heading style, code block style)
- [ ] Terminologi konsisten (tidak pakai 2 istilah berbeda untuk hal sama)
- [ ] Tingkat detail konsisten per level learner
- [ ] Navigasi (prev/next) benar di setiap file
- [ ] Glossary terms konsisten antar fase
```

### Step 4: Output-Specific QA

#### Jika Website:
```markdown
## Website QA
- [ ] Semua halaman bisa diakses dari navigasi
- [ ] Sidebar navigation lengkap dan benar
- [ ] Dark mode berfungsi tanpa color contrast issue
- [ ] Responsive di mobile (test 375px, 768px, 1024px)
- [ ] Syntax highlighting bekerja di semua code blocks
- [ ] Copy code button berfungsi
- [ ] Search berfungsi dengan benar
- [ ] Progress tracking (localStorage) berjalan
- [ ] PWA: offline mode bekerja (jika diimplementasi)
- [ ] Accessibility: keyboard navigation, screen reader
- [ ] Performance: halaman load < 3 detik
- [ ] Semua internal links tidak broken
```

#### Jika PDF:
```markdown
## PDF QA
- [ ] Table of Contents lengkap dan link berfungsi
- [ ] Page breaks di posisi yang tepat
- [ ] Code blocks readable (font size cukup)
- [ ] Tidak ada halaman kosong yang tidak perlu
- [ ] Header/footer konsisten
- [ ] Gambar/diagram ter-render dengan benar
```

#### Jika Markdown:
```markdown
## Markdown QA
- [ ] Semua file bisa di-render di GitHub
- [ ] Internal links antar file berfungsi
- [ ] Code syntax highlighting benar
- [ ] Tabel ter-render dengan benar
- [ ] Mermaid diagrams ter-render (jika platform support)
```

### Step 5: Final Report

Buat laporan QA dan tanyakan ke user:

```markdown
## 📊 QA Report

**Total file yang di-review:** X files
**Code examples yang divalidasi:** Y examples
**Issues ditemukan:** Z issues (X fixed, Y minor)

### Issues Yang Diperbaiki
1. [file] — [deskripsi fix]
2. ...

### Known Limitations
1. [limitasi yang tidak bisa dihindari]

### Rekomendasi
1. [saran improvement untuk iterasi selanjutnya]
```

```
"Review & QA sudah selesai! Berikut laporannya:

[tampilkan QA report]

Semua critical issues sudah diperbaiki. Output siap digunakan! 🎉"
```

## Completion

```
"🎉 Seluruh proses Learning Material Maker selesai!

📋 Fase 1: Discovery ✅
🗺️ Fase 2: Roadmap ✅
📚 Fase 3: Materi ✅
🖥️ Fase 4: Output ✅
✅ Fase 5: Review & QA ✅

📊 Total: X fase, Y halaman, Z latihan, W mini project
🏅 Gamification: X badges, Y total XP tersedia
♿ Accessibility: WCAG 2.1 AA compliant

Selamat belajar! 🎉"
```

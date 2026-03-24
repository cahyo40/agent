---
description: "Fase 2 — Pembuatan Roadmap. Menyusun roadmap pembelajaran terstruktur berdasarkan hasil brainstorming. Menghasilkan peta belajar dengan fase, timeline, resource, mini project, dan checklist."
---

# Fase 2: Pembuatan Roadmap

## Overview

Fase ini mengubah hasil discovery (brainstorming-summary.md) menjadi **roadmap pembelajaran terstruktur** yang berisi fase-fase belajar, timeline, resource gratis, mini project, dan progress checklist.

## Pre-requisites

- File `discovery/brainstorming-summary.md` dari Fase 1
- Opsional skill: `senior-programming-mentor`, `mit-cs-professor`

## Instruksi

### Step 1: Baca Discovery Summary

// turbo
Baca file `discovery/brainstorming-summary.md` untuk memahami profil learner:
- Level saat ini
- Tujuan dan motivasi
- Waktu belajar per hari
- Target timeline
- Batasan resource
- Fokus area

### Step 2: Riset Resource

Gunakan MCP dan web search untuk mencari resource yang sesuai:

```
1. Identifikasi topik utama dan sub-topik
2. Cari resource gratis sesuai batasan learner
   - Jika tanpa YouTube → cari text-based tutorials, docs, interactive platforms
   - Jika tanpa berbayar → cari free platforms, open-source books
   - Jika bahasa Indonesia → cari resource lokal (Petani Kode, CodeSaya, Codepolitan, dll)
3. Cari platform latihan/challenge sesuai topik
4. Identifikasi project ideas yang relevan
```

**MCP Tools yang bisa digunakan:**
- `search_web` — Cari resource gratis terbaru
- `mcp_context7_resolve-library-id` → `mcp_context7_query-docs` — Cari dokumentasi library/framework
- `read_url_content` — Baca halaman resource untuk validasi kualitas

### Step 3: Susun Roadmap

Gunakan template berikut untuk menyusun roadmap:

**Path:** `learning-materials/<topik>/roadmap/roadmap.md`

**Template:**

```markdown
# 🚀 Roadmap: <Judul Topik>
## <Deskripsi Singkat Journey>

**Tanggal:** YYYY-MM-DD
**Profil Learner:** <ringkasan>
**Target:** <tujuan utama>
**Aturan Resource:** <batasan — misal: tanpa YouTube, tanpa berbayar>
**Perangkat:** <spek laptop/device>

---

> [!IMPORTANT]
> **Prinsip Utama:** <pesan motivasi dan aturan dasar>

---

## 📋 Ringkasan Fase

| Fase | Topik | Durasi | Output |
|------|-------|--------|--------|
| 0 | <Setup & Persiapan> | Minggu X | <output yang dihasilkan> |
| 1 | <Topik Fase 1> | Minggu X-Y | <output> |
| 2 | <Topik Fase 2> | Minggu Y-Z | <output> |
| ... | ... | ... | ... |

---

## <Emoji> FASE 0: <Nama Fase> (Minggu X)

### Tujuan
- <bullet point tujuan fase ini>

### Topik yang Dipelajari

#### Minggu X: <Sub-topik>
- <item 1>
- <item 2>
- <item 3>

### 🎯 Mini Project (Wajib Dibuat)

| # | Project | Konsep yang Dilatih |
|---|---------|-------------------|
| 1 | <nama project> | <konsep> |

### 📚 Resource

| Resource | URL | Bahasa | Deskripsi |
|----------|-----|--------|-----------|
| <nama> | <url> | 🇮🇩/🇬🇧 | <deskripsi singkat> |

### 🧩 Latihan Problem Solving

| Platform | URL | Deskripsi |
|----------|-----|-----------|
| <platform> | <url> | <deskripsi> |

### 🏆 Milestone Checkpoint (Akhir Fase)

Sebelum lanjut ke fase berikutnya, learner harus bisa:
1. ✍️ Menjelaskan 3 konsep utama dari fase ini **tanpa melihat catatan**
2. 🛠️ Menyelesaikan minimal 1 mini project **tanpa melihat hints**
3. 📊 Skor latihan minimal **70%**

> Jika belum bisa → Review ulang materi fase ini sebelum lanjut.

---

[... ulangi untuk setiap fase ...]

---

## 🗓️ Timeline Visual

<buat timeline visual menggunakan bar atau tabel>

---

## ✅ Checklist Progress Tracking

### Fase 0: <Nama>
- [ ] <item 1>
- [ ] <item 2>

### Fase 1: <Nama>
- [ ] <item 1>
- [ ] <item 2>

[... ulangi untuk setiap fase ...]

---

## 💬 Tips Penting

> [!IMPORTANT]
> ### Golden Rules
> 1. <rule 1>
> 2. <rule 2>
> ...
```

### Step 4: Aturan Penyusunan Roadmap

1. **Fase harus berurutan** — Setiap fase adalah fondasi untuk fase berikutnya
2. **Timeline realistis** — Sesuaikan dengan waktu belajar per hari dari profil learner
3. **Resource tervalidasi** — Pastikan semua URL aktif dan benar-benar gratis
4. **Sesuai batasan** — Hormati batasan resource learner (tanpa YT, tanpa berbayar, dll)
5. **Mini project di setiap fase** — Minimal 2-3 project per fase untuk praktek
6. **Checklist trackable** — Setiap fase punya checklist progress yang jelas
7. **Incremental difficulty** — Dari mudah ke sulit, jangan lompat level

### Step 5: Kalkulasi Timeline

> **Skill:** `project-estimator`

**Formula Three-Point Estimation:**

```
Untuk setiap fase, hitung:
  - O = Optimistic (best case, sudah familiar dengan topik)
  - M = Most Likely (kecepatan belajar normal)
  - P = Pessimistic (topik baru, banyak hambatan)
  
PERT Estimate = (O + 4×M + P) / 6

Faktor koreksi:
  - Jam efektif = 80% dari jam belajar (20% untuk setup, istirahat, distraksi)
  - Buffer = +20% untuk topik yang belum pernah dipelajari
  - Re-estimate setelah setiap 2 fase selesai
```

**Contoh kalkulasi:**

| Fase | Optimistic | Most Likely | Pessimistic | PERT (minggu) |
|------|-----------|-------------|-------------|---------------|
| Python Dasar | 4 minggu | 6 minggu | 10 minggu | 6.3 minggu |
| OOP & Struktur Data | 3 minggu | 5 minggu | 9 minggu | 5.3 minggu |
| Web Framework | 4 minggu | 7 minggu | 12 minggu | 7.3 minggu |
| Database | 2 minggu | 4 minggu | 8 minggu | 4.3 minggu |

```
Total PERT: 23.2 minggu
Buffer (20%): 4.6 minggu  
Final Estimate: ~28 minggu (7 bulan)

Jam efektif/hari = Jam belajar × 0.8
Contoh: 5 jam/hari → 4 jam efektif → 28 jam/minggu
```

> [!IMPORTANT]
> Selalu gunakan **jam efektif** (80%), bukan jam total. Learner sering overestimate produktivitas mereka.

### Step 5b: Spaced Repetition Schedule

Tambahkan jadwal review berkala di setiap fase untuk mencegah lupa:

```markdown
## 🔁 Jadwal Review (Spaced Repetition)

Setelah menyelesaikan setiap fase:

| Waktu | Aktivitas | Durasi |
|-------|-----------|--------|
| Day 1 | Baca ulang ringkasan fase | 15 menit |
| Day 3 | Kerjakan 2 soal latihan acak | 30 menit |
| Day 7 | Kerjakan 1 mini project tanpa lihat materi | 60 menit |
| Day 14 | Quick quiz 10 pertanyaan konsep | 20 menit |
| Day 30 | Refactor salah satu project lama | 45 menit |

> Jadwal ini otomatis tercantum di setiap akhir fase dalam materi.
> Jika output = website, tampilkan sebagai reminder/notification.
```

### Step 6: Review & Validasi

Sebelum menyimpan, validasi:

```markdown
## Validasi Checklist
- [ ] Semua fase berurutan dan logis
- [ ] Timeline sesuai dengan waktu belajar learner
- [ ] Resource sesuai batasan (tanpa YT/berbayar jika diminta)
- [ ] Ada resource dalam bahasa yang diminta
- [ ] Setiap fase punya minimal 2 mini project
- [ ] Setiap fase punya checklist progress
- [ ] Setiap fase punya resource referensi
- [ ] Tingkat kesulitan naik secara bertahap
- [ ] Total timeline sesuai target learner
```

### Step 7: Presentasikan ke User

Tampilkan ringkasan roadmap ke user dan minta persetujuan:

```
"Roadmap sudah selesai disusun dengan X fase dalam Y bulan. 
Berikut ringkasannya:

[tampilkan tabel ringkasan fase]

Apakah ada yang ingin disesuaikan sebelum saya mulai membuat materi?"
```

## Output

- `roadmap/roadmap.md` — Roadmap lengkap

## Transition

Setelah roadmap disetujui user:

```
"Roadmap sudah disetujui dengan estimasi timeline X bulan 
(menggunakan three-point estimation). Saya akan melanjutkan 
ke Fase 3 untuk membuat materi pembelajaran per fase."
→ Lanjut ke: 03_materi.md
```

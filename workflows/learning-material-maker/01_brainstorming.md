---
description: "Fase 1 — Brainstorming & Discovery. Menggali kebutuhan learner menggunakan skill brainstorming-pro untuk memahami konteks, tujuan, gaya belajar, dan batasan sebelum membuat roadmap."
---

# Fase 1: Brainstorming & Discovery

## Overview

Fase ini menggunakan pendekatan **brainstorming-pro** untuk menggali kebutuhan learner secara mendalam. Hasilnya adalah dokumen **brainstorming-summary.md** yang menjadi fondasi untuk pembuatan roadmap di Fase 2.

## Pre-requisites

- Skill: `brainstorming-pro`
- Input: Request dari pengguna (topik yang ingin dipelajari)

## Instruksi

### Step 1: Aktivasi Brainstorming-Pro

Gunakan pendekatan brainstorming-pro dengan aturan berikut:
- **SATU PERTANYAAN PER PESAN. SELALU.**
- Tunggu jawaban → Acknowledge → Tanya berikutnya
- Berikan opsi multiple choice (5-7 opsi per pertanyaan)
- Ringkasan setiap 3-4 pertanyaan

### Step 2: Pertanyaan Discovery (8-15 pertanyaan)

Ikuti urutan pertanyaan berikut. Adaptasi sesuai konteks.

> [!IMPORTANT]
> **Adaptasi Topik Non-Programming:**
> Pertanyaan di bawah menggunakan contoh programming sebagai default.
> Jika topik BUKAN programming, **WAJIB** adaptasi opsi sesuai domain. Contoh:
> - **Desain Grafis** → Q11: UI Design, Branding, Ilustrasi, Motion Graphics
> - **Bahasa Inggris** → Q11: Speaking, Writing, TOEFL/IELTS, Business English  
> - **Marketing** → Q11: Social Media, SEO, Content Marketing, Paid Ads
> - **Musik** → Q11: Instrument, Produksi, Teori Musik, Mixing/Mastering
> - **Data Science** → Q9 penting: butuh spek tinggi untuk model training
>
> Prinsip: Pertahankan **struktur** pertanyaan, ganti **isi opsi** sesuai domain.

#### Kategori 1: Tujuan & Motivasi (Wajib — Q1-Q2)

```markdown
Q1. "Apa tujuan utama Anda belajar <topik>?"

    Options:
    A) 💼 Karir & pekerjaan — Ingin bekerja di bidang ini
    B) 🚀 Startup — Ingin membuat produk sendiri
    C) 💰 Freelance — Ingin mendapatkan penghasilan project
    D) 🤖 Passion & hobi — Tertarik ingin bisa membuat sesuatu
    E) 📚 Akademis — Untuk tugas kuliah / riset
    F) 🔄 Switch career — Pindah bidang dari pekerjaan sekarang
    G) Kombinasi (sebutkan)

    → Exit: Motivasi dan tujuan jelas
```

```markdown
Q2. "Apa background/latar belakang Anda saat ini?"

    Options:
    A) 🎓 Pelajar SMA/SMK
    B) 🎓 Mahasiswa (jurusan terkait)
    C) 🎓 Mahasiswa (jurusan TIDAK terkait)
    D) 💼 Sudah bekerja (bidang terkait)
    E) 💼 Sudah bekerja (bidang TIDAK terkait)
    F) 🏠 Pengangguran / gap year — fokus belajar
    G) 🏢 Wirausaha — ingin tambah skill
    H) Lainnya (sebutkan)

    → Exit: Background learner jelas
```

#### Kategori 2: Level & Pengalaman (Wajib — Q3-Q4)

```markdown
Q3. "Seberapa familiar Anda dengan <topik> ini?"

    Options:
    A) 🔴 Benar-benar nol — Belum tahu sama sekali
    B) 🟠 Pernah dengar — Tahu istilah-istilah tapi belum pernah praktek
    C) 🟡 Pernah coba sedikit — Pernah ikut tutorial atau copy-paste kode
    D) 🟢 Dasar sudah paham — Bisa hal-hal sederhana, ingin naik level
    E) 🔵 Intermediate — Cukup paham, ingin mendalami area tertentu
    F) ⚪ Advanced — Sudah mahir, ingin jadi expert/senior

    → Exit: Level saat ini terdefinisi
```

```markdown
Q4. "Apakah ada skill terkait yang sudah Anda kuasai?"

    Adapt options based on topic, contoh untuk programming:
    A) Belum ada skill terkait sama sekali
    B) Bisa mengoperasikan komputer dasar (browsing, Office)
    C) Sudah pernah belajar bahasa pemrograman lain (sebutkan)
    D) Sudah pernah membuat project kecil (sebutkan)
    E) Punya background matematika / logika yang kuat
    F) Lainnya (sebutkan)

    → Exit: Skill pra-syarat teridentifikasi
```

#### Kategori 3: Gaya Belajar & Preferensi (Wajib — Q5-Q6)

```markdown
Q5. "Bagaimana preferensi gaya belajar Anda?"

    Options:
    A) 📖 Membaca dokumentasi & artikel
    B) 💻 Learning by doing — Langsung praktek
    C) 📝 Structured step-by-step — Tutorial terstruktur
    D) 🧩 Problem solving — Belajar dari challenge/soal
    E) 🔄 Kombinasi baca teori → praktek
    F) 🤷 Belum tahu — Belum menemukan gaya yang cocok

    → Exit: Gaya belajar terdefinisi
```

```markdown
Q6. "Preferensi bahasa resource belajar?"

    Options:
    A) 🇮🇩 Bahasa Indonesia — Resource utama dalam Bahasa Indonesia
    B) 🇬🇧 English — Tidak masalah belajar dalam bahasa Inggris
    C) 🔄 Campuran — English boleh, tapi konsep sulit prefer Indonesia
    D) 🇬🇧 Sekaligus improve English

    → Exit: Bahasa resource terdefinisi
```

#### Kategori 4: Waktu & Batasan (Wajib — Q7-Q8)

```markdown
Q7. "Berapa banyak waktu yang bisa Anda dedikasikan untuk belajar setiap hari?"

    Options:
    A) ⏰ 1-2 jam/hari
    B) ⏰ 3-4 jam/hari
    C) ⏰ 5-6 jam/hari
    D) ⏰ 8+ jam/hari (full-time)
    E) 🔄 Tidak tentu (rata-rata berapa?)

    → Exit: Waktu belajar terdefinisi
```

```markdown
Q8. "Berapa lama target waktu Anda untuk mencapai tujuan?"

    Options:
    A) ⚡ 1-3 bulan — Secepat mungkin
    B) 📅 3-6 bulan — Cukup cepat tapi realistis
    C) 📅 6-12 bulan — Fondasi kuat, tidak buru-buru
    D) 📅 1-2 tahun — Ingin benar-benar mahir
    E) 🎯 Tidak ada target — Yang penting belajar benar
    F) Ada deadline spesifik? (sebutkan)

    → Exit: Timeline terdefinisi
```

#### Kategori 5: Perangkat & Resource (Kondisional — Q9-Q10)

```markdown
Q9. "Apa perangkat yang Anda gunakan untuk belajar?"

    Ask if: Topik membutuhkan software/hardware tertentu

    Options:
    A) 💻 Laptop/PC spek tinggi (RAM 16GB+, SSD)
    B) 💻 Laptop/PC spek menengah (RAM 8GB)
    C) 💻 Laptop/PC spek rendah (RAM 4GB, HDD)
    D) 📱 Hanya smartphone/tablet
    E) 🛒 Planning beli perangkat baru
    F) ☁️ Bisa akses cloud/internet stabil

    → Exit: Batasan perangkat terdefinisi
```

```markdown
Q10. "Ada batasan khusus untuk sumber belajar?"

    Options:
    A) ❌ Tanpa YouTube — Tidak ingin belajar dari video YouTube
    B) ❌ Tanpa kursus berbayar — Hanya resource gratis
    C) ❌ Tanpa video — Hanya text-based
    D) ✅ Semua format OK — Tidak ada batasan
    E) 💰 Ada budget tertentu untuk resource (sebutkan)
    F) Batasan lainnya (sebutkan)

    → Exit: Batasan resource terdefinisi
```

#### Kategori 6: Scope & Kedalaman (Kondisional — Q11-Q12)

```markdown
Q11. "Bidang/area spesifik apa yang ingin difokuskan?"

    Ask if: Topik luas dengan banyak sub-bidang

    Adapt options based on topic, contoh untuk programming:
    A) 🌐 Web Development (Frontend + Backend)
    B) 📱 Mobile Development
    C) 🤖 AI & Machine Learning
    D) 🎮 Game Development
    E) 🗄️ Data Engineering/Science
    F) 🔒 Cybersecurity
    G) Semua bidang — Ingin explore semua
    H) Lainnya (sebutkan)

    → Exit: Fokus area terdefinisi
```

```markdown
Q12. "Untuk gaya materi, mana yang lebih Anda suka?"

    Options:
    A) 📖 Formal & akademis — Seperti buku teks, lengkap dan mendalam
    B) 💬 Casual & conversational — Seperti ngobrol dengan mentor
    C) 🎯 Praktis & to-the-point — Minimal teori, langsung praktek
    D) 🧠 Analogi & cerita — Banyak perumpamaan untuk mudah diingat
    E) 📊 Visual & diagram — Banyak gambar, flowchart, infografis
    F) 🔄 Campuran - Kombinasi sesuai konteks
    G) Terserah — Pilihkan yang paling efektif

    → Exit: Gaya materi terdefinisi
```

#### Kategori 7: Output Format (Wajib — Q13)

```markdown
Q13. "Dalam format apa Anda ingin materi ini dihasilkan?"

    Options:
    A) 🌐 Website — Website interaktif dengan navigasi
    B) 📄 PDF — Dokumen yang bisa di-download dan dibaca offline
    C) 📝 Markdown — File markdown di folder (bisa dibaca di GitHub/VS Code)
    D) 📚 E-book — Format buku digital
    E) 🔄 Kombinasi — Website + PDF untuk offline
    F) Terserah — Rekomendasikan yang terbaik

    → Exit: Format output terdefinisi
```

#### Kategori 8: Pengalaman Belajar Sebelumnya (Kondisional — Q14)

```markdown
Q14. "Apakah Anda pernah mencoba belajar <topik> sebelumnya? Apa kendalanya?"

    Ask if: Topik bukan sepenuhnya baru bagi learner (Q3 ≠ A)

    Options:
    A) Belum pernah sama sekali
    B) 😴 Pernah, tapi berhenti karena bosan / tidak menarik
    C) 😵 Pernah, tapi tidak paham / terlalu sulit
    D) 😓 Pernah, tapi tidak konsisten / kehilangan motivasi
    E) 📉 Pernah, tapi resource-nya kurang bagus / tidak cocok
    F) 📈 Pernah dan lumayan paham, tapi ingin belajar lebih terstruktur
    G) Lainnya (sebutkan)

    → Exit: Pola kendala belajar teridentifikasi
    → Action: Gunakan info ini untuk menghindari pola yang sama di materi
```

### Step 3: Ringkasan Real-time

Setelah setiap 3-4 pertanyaan, tampilkan ringkasan:

```markdown
## Summary So Far (Q1-Q4)

✅ **Q1 - Tujuan:** [jawaban]
✅ **Q2 - Background:** [jawaban]
✅ **Q3 - Level:** [jawaban]
✅ **Q4 - Skill terkait:** [jawaban]

Ada yang ingin ditambah/dikoreksi? Kalau sudah oke, lanjut ke Q5!
```

### Step 4: Exit Criteria

> [!TIP]
> Jika jawaban Q14 menunjukkan pola kendala tertentu (misal: "bosan"), **catat ini** di rekomendasi awal agar materi dirancang menghindari pola tersebut (misal: materi lebih interaktif, banyak mini project).

Berhenti bertanya ketika SALAH SATU kondisi terpenuhi:
- Sudah 15 pertanyaan
- Jawaban sudah cukup detail untuk membuat roadmap
- User bilang "udah cukup" / "langsung buat saja"
- Pertanyaan tambahan hanya soal detail implementasi

### Step 5: Buat Discovery Summary

// turbo

Simpan hasil brainstorming ke file:

**Path:** `learning-materials/<topik>/discovery/brainstorming-summary.md`

**Template:**

```markdown
# Brainstorming Summary: <Topik>

**Tanggal:** YYYY-MM-DD
**Learner Profile:** [ringkasan singkat]

## Hasil Discovery

| # | Pertanyaan | Jawaban |
|---|-----------|---------|
| Q1 | Tujuan | ... |
| Q2 | Background | ... |
| ... | ... | ... |

## Profil Learner

- **Level:** [nol/pemula/intermediate/advanced]
- **Motivasi:** [karir/startup/freelance/hobi/dll]
- **Waktu belajar:** [X jam/hari]
- **Target:** [X bulan]
- **Gaya belajar:** [baca/praktek/soal/campuran]
- **Bahasa:** [Indonesia/English/campuran]
- **Batasan:** [tanpa YT/tanpa berbayar/spek rendah/dll]
- **Fokus area:** [bidang yang ingin dipelajari]
- **Gaya materi:** [formal/casual/praktis/dll]
- **Format output:** [website/PDF/markdown/dll]
- **Kendala sebelumnya:** [belum pernah/bosan/sulit/tidak konsisten/dll]

## Rekomendasi Awal

[Catatan dan rekomendasi berdasarkan profil learner]

## Next Step

→ Lanjut ke **Fase 2: Pembuatan Roadmap** (`02_roadmap.md`)
```

## Output

- `discovery/brainstorming-summary.md` — Dokumen hasil discovery

## Transition

Setelah brainstorming summary selesai dan disetujui user:

```
"Discovery selesai. Saya akan melanjutkan ke Fase 2 untuk membuat roadmap 
berdasarkan profil dan kebutuhan yang sudah kita diskusikan."
→ Lanjut ke: 02_roadmap.md
```

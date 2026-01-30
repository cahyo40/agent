# Panduan Standar Pembuatan Antigravity Agent Skill

Dokumen ini berfungsi sebagai acuan ("patokan") resmi untuk memahami, membuat, dan mengelola **Agent Skills** dalam lingkungan Antigravity.

## 1. Apa itu Agent Skill?

**Skill** adalah unit kemampuan modular yang dapat "diajarkan" kepada AI Agent. Skill berisi instruksi spesifik, prosedur standar (SOP), atau akses ke skrip khusus yang membantu agent menyelesaikan tugas tertentu dengan lebih akurat dan konsisten.

Gunakan Skill ketika Anda ingin agent:

- Mengikuti langkah-langkah yang ketat (misal: checklist deployment).
- Menggunakan standar coding tertentu secara konsisten.
- Mengakses script atau tools custom yang ada di project.

## 2. Struktur Direktori

Semua skill **WAJIB** disimpan dalam direktori `.agent/skills/` di root project.

```text
.agent/
└── skills/
    ├── <nama-skill>/           # Folder skill (gunakan kebab-case)
    │   ├── SKILL.md            # [WAJIB] File definisi skill
    │   ├── script-bantu.py     # [Opsional] Script pendukung
    │   └── template.json       # [Opsional] Aset pendukung
    └── code-review/            # Contoh skill lain
        └── SKILL.md
```

## 3. Standar File `SKILL.md`

File `SKILL.md` adalah otak dari sebuah skill. File ini harus memiliki **YAML Frontmatter** di bagian atas dan **Markdown Instruction** di bagian bawah.

### Format Template

```markdown
---
name: <nama-skill-unik>
description: <deskripsi-jelas-kapan-agent-harus-menggunakan-skill-ini>
---

# <Judul Skill>

<Penjelasan singkat tujuan skill ini>

## Instruksi / Checklist
Lakukan langkah-langkah berikut secara berurutan:

1. **Langkah 1**: <Instruksi detail>
2. **Langkah 2**: <Instruksi detail>
   - Sub-langkah jika perlu

## Aturan Tambahan
- <Rule 1>
- <Rule 2>

## Contoh Output
<Contoh hasil yang diharapkan>
```

### Penjelasan Field YAML

- **`name`**: ID unik untuk skill. Gunakan huruf kecil dan tanda hubung (kebab-case). Contoh: `code-review`, `generate-unit-test`.
- **`description`**: Kalimat instruksi untuk AI. Jelaskan **KAPAN** skill ini harus dipanggil.
  - *Buruk*: "Untuk testing."
  - *Baik*: "Gunakan skill ini ketika user meminta untuk membuat unit test pada file Python."

## 4. Workflow Pembuatan Skill

Ikuti langkah ini jika Anda ingin membuat skill baru:

1. **Identifikasi Kebutuhan**: Apakah tugas ini berulang? Apakah butuh standar khusus?
2. **Buat Folder**: `mkdir -p .agent/skills/<nama-skill>`
3. **Buat SKILL.md**: Gunakan template di atas.
4. **Uji Coba**: Minta agent untuk melakukan tugas terkait dan lihat apakah skill terpanggil.

## 5. Contoh Skill (Referensi)

Berikut adalah contoh nyata untuk skill **Code Review**.

**Path**: `.agent/skills/code-review/SKILL.md`

```markdown
---
name: code-review-standard
description: Gunakan skill ini saat diminta mereview kode atau Pull Request (PR) untuk memastikan standar kualitas.
---

# Standar Code Review Tim

Saat melakukan review kode, Anda harus memeriksa poin-poin berikut:

## 1. Keamanan (Security)
- [ ] Pastikan tidak ada kredensial (API Key, Password, Token) yang hardcoded.
- [ ] Cek validasi input pada fungsi publik.

## 2. Performa & Efisiensi
- [ ] Hindari query database di dalam loop (N+1 problem).
- [ ] Pastikan resource (file, koneksi db) ditutup dengan benar (defer/context manager).

## 3. Style & Readability
- [ ] Variabel harus deskriptif (hindari `x`, `y`, `data`).
- [ ] Fungsi tidak boleh terlalu panjang (> 50 baris).

## Format Output Review
Jika menemukan isu, berikan komentar dengan format:
- **Lokasi**: <File>:<Baris>
- **Isu**: <Penjelasan>
- **Saran**: <Contoh kode perbaikan>
```

# Vibe Coding Toolkit Workflows

Workflows untuk men-generate file pendukung **vibe coding** dari sebuah PRD. File-file ini berfungsi sebagai "guardrails" agar AI tidak halusinasi dan menghasilkan kode yang konsisten, sesuai arsitektur, dan berkualitas tinggi.

## Mengapa Dibutuhkan?

PRD saja **tidak cukup** untuk vibe coding yang sukses karena:
1. PRD biasanya terlalu panjang untuk context AI
2. PRD mendeskripsikan *apa* yang dibangun, bukan *bagaimana* AI harus coding
3. Design tokens di PRD bukan format kode yang langsung bisa dipakai
4. Tanpa anti-pattern list, AI sering mengambil shortcut
5. Tanpa checklist, developer kehilangan track progress

## Struktur Output

```
{output_dir}/
├── RULE.md                       # AI governance: DO & DON'T
├── DESIGN.md                     # Design system (kode + Stitch context)
├── STITCH_PROMPTS.md             # Prompt Stitch per screen (optional)
├── AI_INSTRUCTIONS.md            # Template prompt per fitur/fase
├── CHECKLIST.md                  # Development checklist per phase
└── ARCHITECTURE_CHEATSHEET.md    # Quick reference patterns
```

## Deskripsi Setiap File

| File | Fungsi | Analogi |
|------|--------|---------|
| **RULE.md** | Kontrak yang HARUS dipatuhi AI saat generate code | Standar material & konstruksi |
| **DESIGN.md** | Design tokens (kode) + Stitch design context | Palet warna & finishing rumah |
| **STITCH_PROMPTS.md** | Prompt Stitch per screen untuk generate UI/UX | Gambar arsitek per ruangan |
| **AI_INSTRUCTIONS.md** | Instruksi prompt yang sudah dioptimasi per fase | Instruksi kerja per tahap |
| **CHECKLIST.md** | Tracking progress development secara incremental | Checklist inspeksi bangunan |
| **ARCHITECTURE_CHEATSHEET.md** | Quick reference patterns tanpa baca seluruh PRD | Cheat sheet tukang |

## Workflow Files

```
workflows/vibe-coding-toolkit/
├── 01_generate_rule.md              # Generate RULE.md
├── 02_generate_design.md            # Generate DESIGN.md + Stitch context
├── 02b_generate_stitch_prompts.md   # Generate STITCH_PROMPTS.md (per screen)
├── 03_generate_ai_instructions.md   # Generate AI_INSTRUCTIONS.md
├── 04_generate_checklist.md         # Generate CHECKLIST.md
├── 05_generate_architecture.md      # Generate ARCHITECTURE_CHEATSHEET.md
├── example.md                       # Contoh penggunaan
└── README.md                        # Dokumentasi ini
```

## Cara Menggunakan

### Prerequisite
- Sebuah PRD yang sudah mencakup:
  - Tech stack & arsitektur
  - Fitur & requirements
  - UI/UX guidelines (warna, typography, spacing)
  - Model data / schema
  - Daftar screen / halaman

### Quick Start (Semua Sekaligus)
```
Jalankan semua workflow vibe-coding-toolkit (01-05) untuk PRD di @[path/ke/prd.md].
Output ke folder: prd/{nama-project}/
```

### Per File (Satu per Satu)
```
Jalankan workflow vibe-coding-toolkit/01_generate_rule.md
PRD: @[path/ke/prd.md]
Output: prd/{nama-project}/RULE.md
```

## Urutan Eksekusi

```
PRD.md (input)
    ↓
01 Generate RULE.md          ← Harus pertama (jadi referensi file lain)
    ↓
02 Generate DESIGN.md        ← Design tokens + Stitch context
    ↓
02b Generate STITCH_PROMPTS  ← (Optional) Prompt per screen untuk Stitch UI/UX
    ↓
03 Generate AI_INSTRUCTIONS  ← Butuh RULE.md & DESIGN.md
    ↓
04 Generate CHECKLIST.md     ← Butuh AI_INSTRUCTIONS.md
    ↓
05 Generate ARCHITECTURE.md  ← Butuh semua file sebelumnya
```

> **Note:** Step 02b optional. Jalankan jika ingin generate UI/UX mockup via Stitch AI
> sebelum mulai coding. Bisa juga dijalankan kapan saja setelah DESIGN.md ada.

## Supported Tech Stacks

Workflow ini **technology-agnostic** — bisa dipakai untuk:

| Stack | Contoh Output |
|-------|---------------|
| **Flutter + Riverpod** | Dart code tokens, Widget patterns, @riverpod |
| **Flutter + BLoC** | Dart code tokens, BLoC patterns, Cubit |
| **Flutter + GetX** | Dart code tokens, GetX patterns, Obx |
| **Next.js + React** | TypeScript tokens, React patterns, hooks |
| **Nuxt + Vue** | TypeScript tokens, Composition API patterns |
| **Go Backend** | Go code patterns, handler patterns |
| **Python + FastAPI** | Python patterns, Pydantic models |
| **Laravel + PHP** | PHP patterns, Eloquent, Blade |

AI akan menyesuaikan format kode dan pattern berdasarkan tech stack yang terdeteksi di PRD.

## Tips

1. **PRD harus lengkap** — semakin detail PRD, semakin baik output
2. **Review setiap file** — jangan langsung pakai tanpa review
3. **Sesuaikan setelah generate** — file yang di-generate adalah starting point
4. **Update CHECKLIST.md** setiap selesai task — ini tracking utama progress
5. **Selalu reference RULE.md** di setiap prompt vibe coding

---

*Workflow ini dikembangkan berdasarkan best practices vibe coding dan pengalaman real-world development.*

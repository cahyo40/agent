# UI/UX Design-to-Code Generator Workflows

Workflows untuk mengubah **referensi visual UI/UX** menjadi **source code production-ready** menggunakan kombinasi Antigravity skills dan Google Stitch MCP.

## Mengapa Dibutuhkan?

Proses manual design-to-code sering menghasilkan:
1. Inkonsistensi visual — warna, spacing, typography tidak match referensi
2. Design system tidak terdokumentasi — setiap iterasi mulai dari nol
3. Prompt Stitch tidak optimal — menghasilkan UI yang harus banyak di-edit
4. Code conversion berantakan — HTML Stitch langsung dipakai tanpa refactor
5. Tidak ada QA — masalah accessibility dan responsiveness tidak terdeteksi

## Struktur Output

```
ui-ux/{project-name}/
├── referensi.*                 # Gambar referensi UI/UX dari user
├── input_user.md               # Dokumentasi instruksi user
├── evaluasi_desain.md          # Evaluasi & analisis referensi
├── DESIGN.md                   # Design system (Stitch-optimized)
├── stitch_prompt.md            # Prompt(s) untuk Stitch generation
├── stitch.json                 # Metadata Stitch project
├── progress.md                 # Status tracking per-phase
├── queue/                      # Staging area untuk Stitch output
│   ├── screen.html
│   └── screen.png
└── output/                     # Final source code
    └── ...
```

## Deskripsi Setiap Phase

| # | Phase | Skill | Output |
|---|-------|-------|--------|
| 1 | Input Referensi | — | `referensi.*` + `input_user.md` |
| 2 | Evaluasi & Analisis | `senior-ui-ux-designer` | `evaluasi_desain.md` |
| 3 | Design System Generation | `senior-ui-ux-designer` + `stitch-design-md` | `DESIGN.md` |
| 4 | Prompt Engineering | Manual / `stitch-enhance-prompt` | `stitch_prompt.md` |
| 5 | Stitch Generation | Stitch MCP Tools | Stitch screen (cloud) |
| 6 | Download & Organize | File management | `queue/screen.html` + `.png` |
| 7 | Code Conversion | Platform-specific skills | `output/` |
| 8 | Quality Assurance | `senior-software-engineer` | Verified code |

## Workflow Files

```
workflows/ui-ux-generator/
├── 01_input_referensi.md           # Phase 1: Collect reference & user input
├── 02_evaluasi_desain.md           # Phase 2: Evaluate & analyze reference
├── 03_generate_design_system.md    # Phase 3: Generate DESIGN.md
├── 04_prompt_engineering.md        # Phase 4: Create Stitch prompt
├── 05_stitch_generation.md         # Phase 5: Generate UI via Stitch MCP
├── 06_download_organize.md         # Phase 6: Download & organize files
├── 07_code_conversion.md           # Phase 7: Convert to production code
├── 08_quality_assurance.md         # Phase 8: QA & feedback loop
├── example.md                      # Contoh penggunaan
└── README.md                       # Dokumentasi ini
```

## Cara Menggunakan

### Prerequisite
- Gambar referensi UI/UX (`.png`, `.webp`, `.jpg`)
- Deskripsi apa yang ingin dibuat (bisa sama/modifikasi dari referensi)
- Target platform (React/Next.js, Flutter, atau HTML/CSS/JS)

### Quick Start (Semua Sekaligus)
```
Jalankan semua workflow ui-ux-generator (01-08) untuk referensi di `referensi.webp`.
Project name: dashboard-001
Output ke folder: ui-ux/dashboard-001/
Target platform: React/Next.js
```

### Per Phase (Satu per Satu)
```
Jalankan workflow ui-ux-generator/02_evaluasi_desain.md

Referensi: @ui-ux/dashboard-001/referensi.webp
Input: @ui-ux/dashboard-001/input_user.md
Output: ui-ux/dashboard-001/evaluasi_desain.md
```

## Urutan Eksekusi

```
Referensi UI/UX (input)
    ↓
01 Input Referensi           ← Dokumentasi awal
    ↓
02 Evaluasi Desain           ← Analisis kekuatan/kelemahan
    ↓
03 Generate Design System    ← DESIGN.md (Stitch-optimized)
    ↓
04 Prompt Engineering        ← stitch_prompt.md (butuh DESIGN.md)
    ↓
05 Stitch Generation         ← Generate UI via MCP
    ↓
06 Download & Organize       ← Download ke folder lokal
    ↓
07 Code Conversion           ← Convert ke target platform
    ↓
08 Quality Assurance         ← Validasi & feedback loop
    ↓
    └───→ (jika gagal) → kembali ke Phase 4 atau 5
```

## Supported Target Platforms

| Platform | Skill | Output |
|----------|-------|--------|
| **React/Next.js** | `stitch-react-components` | Vite + React + TypeScript |
| **Flutter (Mobile)** | `senior-flutter-developer` | Flutter widgets + theme |
| **HTML/CSS/JS** | `web-developer` | Vanilla web files |
| **Vue/Nuxt** | `senior-vue-developer` | Vue components |

## Tips

1. **Selalu include Design System block** — Section 6 `DESIGN.md` WAJIB di setiap prompt Stitch
2. **Jangan skip Phase 2** — Evaluasi desain menentukan kualitas output akhir
3. **Visual verify setiap fase** — Bandingkan output vs referensi secara berkala
4. **Update `progress.md`** — Track status setiap phase selesai
5. **Gunakan feedback loop** — Phase 8 bisa kembali ke Phase 4/5 untuk iterasi

---

*Workflow ini mengadaptasi pengalaman dari `vibe-coding-toolkit` dan pipeline design-to-code manual menjadi workflow yang terstruktur dan reusable.*

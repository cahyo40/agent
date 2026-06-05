# Vibe Coding Toolkit Workflows

Workflows untuk men-generate file pendukung **vibe coding** dari sebuah PRD. File-file ini berfungsi sebagai "guardrails" agar AI tidak halusinasi dan menghasilkan kode yang konsisten, sesuai arsitektur, dan berkualitas tinggi.

## Mengapa Dibutuhkan?

PRD saja **tidak cukup** untuk vibe coding yang sukses karena:
1. PRD biasanya terlalu panjang untuk context AI
2. PRD mendeskripsikan *apa* yang dibangun, bukan *bagaimana* AI harus coding
3. Design tokens di PRD bukan format kode yang langsung bisa dipakai
4. Tanpa anti-pattern list, AI sering mengambil shortcut
5. Tanpa checklist, developer kehilangan track progress

## Pipeline Overview

Vibe Coding Toolkit punya **3 fase pipeline**:

| Fase | Workflow | Fungsi |
|------|----------|--------|
| **Planning** | 00 → 01 | PRD generation (opsional) → Quality Gate |
| **Generation** | 02 → 07 | Generate semua file pendukung |
| **Execution** | 08 → 12 | Bantu eksekusi vibe coding: context, error recovery, test, review, sync |

## Workflow Files

```
workflows/vibe-coding-toolkit/
├── PLANNING:
│   ├── 00_generate_prd.md           # (NEW) Generate PRD dari rough notes
│   └── 01_validate_prd.md           # PRD Quality Gate
├── GENERATION:
│   ├── 02_generate_rule.md          # Generate RULE.md
│   ├── 03_generate_design.md        # Generate DESIGN.md + Stitch context
│   ├── 03b_generate_stitch_prompts.md # STITCH_PROMPTS.md (optional)
│   ├── 04_generate_ai_instructions.md # Generate AI_INSTRUCTIONS.md
│   ├── 05_generate_checklist.md     # Generate CHECKLIST.md
│   ├── 06_generate_architecture.md  # Generate ARCHITECTURE_CHEATSHEET.md
│   └── 07_review_and_iterate.md     # Review & iterate generated files
├── EXECUTION:
│   ├── 08_bundle_ai_context.md      # (NEW) Bundle context untuk AI session
│   ├── 09_error_recovery.md         # (NEW) Diagnosa & fix error
│   ├── 10_sync_progress.md          # (NEW) Auto-sync progress dari git
│   ├── 11_test_execution.md         # (NEW) Test execution & validation
│   └── 12_code_review.md            # (NEW) Code review against rules
├── validate_output.sh               # Validasi output otomatis
├── example.md                       # Contoh penggunaan
└── README.md                        # Dokumentasi ini
```

## Struktur Output

```
{output_dir}/
├── PRD.md                        # (dari 00) Structured PRD (opsional)
├── PRD_VALIDATION.md             # (dari 01) Quality gate report
├── RULE.md                       # (dari 02) AI governance
├── DESIGN.md                     # (dari 03) Design system + Stitch
├── STITCH_PROMPTS.md             # (dari 03b) Stitch UI prompts (opsional)
├── AI_INSTRUCTIONS.md            # (dari 04) Task breakdown
├── CHECKLIST.md                  # (dari 05) Progress tracking
├── ARCHITECTURE_CHEATSHEET.md    # (dari 06) Quick reference
├── REVIEW_REPORT.md              # (dari 07) Review report
├── AI_CONTEXT.md                 # (dari 08) Bundled AI context
├── ERROR_REPORT.md               # (dari 09) Error recovery report
├── PROGRESS_SYNC_REPORT.md       # (dari 10) Progress sync report
├── TEST_REPORT.md                # (dari 11) Test execution report
└── CODE_REVIEW_*.md              # (dari 12) Code review reports
```

## Deskripsi Setiap Workflow

| Workflow | Fase | Fungsi | Output |
|----------|------|--------|--------|
| **00** | Planning | Generate PRD dari rough notes/ide | PRD.md |
| **01** | Planning | Quality Gate — validasi PRD completeness | PRD_VALIDATION.md |
| **02** | Generation | AI governance rules (WAJIB & DILARANG) | RULE.md |
| **03** | Generation | Design tokens dalam kode + Stitch context | DESIGN.md |
| **03b** | Generation | Prompt per screen untuk Stitch UI | STITCH_PROMPTS.md |
| **04** | Generation | Task breakdown per phase (dengan testing wajib) | AI_INSTRUCTIONS.md |
| **05** | Generation | Development checklist + progress tracker | CHECKLIST.md |
| **06** | Generation | Quick reference patterns + testing patterns | ARCHITECTURE_CHEATSHEET.md |
| **07** | Generation | Review & iterasi consistency | REVIEW_REPORT.md |
| **08** | Execution | Bundle context untuk AI coding session | AI_CONTEXT.md |
| **09** | Execution | Diagnosa & fix error build/test | ERROR_REPORT.md |
| **10** | Execution | Auto-sync progress dari git history | PROGRESS_SYNC_REPORT.md |
| **11** | Execution | Test execution, coverage, auto-fix | TEST_REPORT.md |
| **12** | Execution | Code review against RULE.md | CODE_REVIEW_*.md |

## Cara Menggunakan

### Prerequisite
- Sebuah PRD (atau ide/notes untuk workflow 00):
  - Tech stack & arsitektur
  - Fitur & requirements
  - UI/UX guidelines
  - Model data / schema
  - Daftar screen / halaman

### Quick Start — Pipeline Lengkap
```
Jalankan pipeline lengkap vibe-coding-toolkit:

1. (Opsional) 07: Generate PRD dari rough notes → PRD.md
2. 00: Validate PRD → PRD_VALIDATION.md (jika FAIL, perbaiki PRD)
3. 02-07: Generate semua file pendukung
4. 06: Review & iterate → REVIEW_REPORT.md
5. 08: Bundle AI context → AI_CONTEXT.md
6. Mulai coding dengan AI_CONTEXT.md sebagai prompt awal
7. 09: Error recovery jika ada error
8. 11: Test execution setelah implementasi
9. 12: Code review sebelum merge
10. 10: Sync progress ke CHECKLIST.md

Output ke folder: prd/{nama-project}/
```

### Per File (Satu per Satu)
```
Jalankan workflow vibe-coding-toolkit/02_generate_rule.md
PRD: @[path/ke/prd.md]
Output: prd/{nama-project}/RULE.md
```

## Urutan Eksekusi

```
[Ide/Notes]                                   ← Starting point (opsional)
    ↓
00 Generate PRD                               ← (Opsional) PRD dari rough notes
    ↓
PRD.md (input)
    ↓
01 Validate PRD (Quality Gate)               ← Wajib! Pastikan PRD siap
    ↓ (jika PASS)
02 Generate RULE.md                           ← Governance rules
    ↓
03 Generate DESIGN.md                         ← Design tokens + Stitch
    ↓
03b Generate STITCH_PROMPTS                  ← (Optional) Stitch prompts
    ↓
04 Generate AI_INSTRUCTIONS                  ← Task breakdown + testing wajib
    ↓
05 Generate CHECKLIST.md                     ← Progress tracker
    ↓
06 Generate ARCHITECTURE.md                  ← Quick reference
    ↓
07 Review & Iterate                          ← Validasi akhir

=== FASE EXECUTION (coding loop) ===

08 Bundle AI Context                         ← Siapkan prompt untuk AI coding
    ↓
[VIBE CODING SESSION]                        ← Coding dengan AI
    ↓ error? → 09 Error Recovery             ← Diagnosa & fix error
    ↓ test?   → 11 Test Execution            ← Run tests, fix failures
    ↓ selesai → 12 Code Review               ← Review against rules
    ↓         → 10 Sync Progress             ← Update checklist otomatis
    ↓
[Next task / Next phase]
```

> **Note:**
> - 00 opsional — skip jika sudah punya PRD
> - 01 mandatory — validasi PRD, jangan skip
> - 03b optional — untuk Stitch AI screen generation
> - 07 recommended — final check sebelum execution
> - 08 recommended — sangat membantu mengatasi context window limit
> - 09-12 adalah **runtime workflows** — dipakai selama proses coding, bukan sekali di awal

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

## ✅ Testing Strategy (v2.0)

Mulai v2.0, **testing adalah phase wajib** di setiap development cycle:

- **Setiap task** di AI_INSTRUCTIONS.md punya testing subtask
- **TDD cycle** (RED → GREEN → REFACTOR) diterapkan per fitur
- **Coverage targets** ditetapkan di RULE.md:
  - Unit test (data/domain layer): 80%+
  - Widget test (presentation layer): 70%+
  - Integration test: 50%+
- **Testing patterns** disertakan di ARCHITECTURE_CHEATSHEET.md
- **Workflow 11** (test execution) otomatis track coverage

## 🔧 Validation Script

Gunakan `validate_output.sh` untuk validasi output otomatis:

```bash
./workflows/vibe-coding-toolkit/validate_output.sh prd/my-app/
```

Script mengecek:
- Semua file output exist
- Setiap file punya mandatory sections
- Cross-reference consistency antar file
- Exit code: 0 (PASS), 1 (WARNINGS), 2 (FAIL)

## ℹ️ Tentang `// turbo-all`

Setiap workflow file dimulai dengan comment `// turbo-all`. Ini adalah **directive eksekusi** yang menginstruksikan agent untuk menjalankan seluruh workflow secara penuh tanpa interupsi. Fungsinya:

1. **Mode turbo** — agent tidak perlu menanyakan konfirmasi di setiap step
2. **Execusi penuh** — semua step dijalankan dari awal sampai akhir
3. **Skip validasi interaktif** — agent langsung generate tanpa tanya "apakah saya lanjut?"

Jika ingin mode interaktif (agent bertanya di setiap step), hapus atau comment baris `// turbo-all`.

## 📦 Versioning

Toolkit ini menggunakan **version tunggal** untuk semua file (bukan per-file).

| Version | Date | Changes |
|---------|------|---------|
| v2.0.0 | 2026-06-05 | PRD Generator (00), Quality Gate (01), AI Context (08), Error Recovery (09), Progress Sync (10), Test Execution (11), Code Review (12), Review & Iterate (07), Testing wajib, Validation script, turbo-all docs |
| v1.1.0 | 2026-03-14 | DESIGN.md Stitch prompts enhancement |
| v1.0.0 | 2026-03-14 | Initial release (02-07 + 03b) |

**Prinsip versioning:**
- Semua workflow file dalam satu release menggunakan version yang SAMA
- Update salah satu file = bump version semua file
- File version ada di frontmatter YAML (`version:` field)
- CHANGELOG disimpan di README ini

## 💡 Tips

1. **Mulai dengan 07 jika belum punya PRD** — generate dari rough notes
2. **Jangan skip 01 (Quality Gate)** — validasi PRD sangat penting
3. **Gunakan 08 (AI Context)** sebelum coding — atasi context window limit
4. **TDD way** — jalankan 11 (test) setelah implementasi, 09 (error) jika gagal
5. **Akhiri dengan 12 (Code Review)** — pastikan kode sesuai RULE.md
6. **Sync progress dengan 10** — auto-update dari git, tanpa edit manual
7. **Selalu reference RULE.md** di setiap prompt vibe coding
8. **Jalankan validate_output.sh** setelah generation untuk automated check

## 📊 Pipeline Quality Gates

```
PLANNING:
[Ide] → 07 Generate PRD → 00 Validate PRD → PASS? → [GENERATION] → 06 Review → validate_output.sh
         (opsional)              ↓ FAIL
                             Fix PRD ←───

EXECUTION (Loop per task):
08 Bundle Context → [AI Coding] → 09 Error? → Fix → 11 Test → Pass? → 12 Review → 10 Sync Progress
                                                                          ↓ Fail
                                                                    Fix → Re-run
```

Workflow ini punya **5 level quality gate**:
1. **Gate 1** (01): PRD completeness — cegah garbage in, garbage out
2. **Gate 2** (07): Output consistency — cegah conflicting/incomplete files
3. **Gate 3** (validate_output.sh): Structural integrity — automated final check
4. **Gate 4** (11): Test passing — kode benar secara fungsional
5. **Gate 5** (12): Rule compliance — kode sesuai governance

---

*Workflow ini dikembangkan berdasarkan best practices vibe coding dan pengalaman real-world development. v2.0.0 — 2026-06-05.*

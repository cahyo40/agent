# Contoh Penggunaan Workflows — Flutter UI Kit

> Panduan langkah demi langkah cara menggunakan 6 planning workflows ini.
> Setiap langkah berisi **prompt yang bisa langsung di-copy-paste** dan penjelasan apa yang terjadi.

---

## Skenario: Membuat UI Kit untuk Aplikasi Fintech

Anda ingin membuat Flutter UI Kit bertema Fintech — wallet, transfer, history — dengan desain modern dan gelap.

---

## Phase 1: PRD Analysis

### Langkah 1.1 — Mulai dengan Prompt Sederhana

**Prompt yang Anda ketik:**
```
Buatkan saya Flutter UI Kit untuk aplikasi fintech dengan gaya modern dark mode.
Targetnya developer freelancer dan agency kecil.
```

**Apa yang terjadi:**
- Agen membaca `workflows/flutter-ui-kit/01_prd_analysis.md`
- Agen membaca skill `brainstorming` untuk eksplorasi ide
- Agen menginterpretasi prompt menjadi **5 Dimensi UI Kit:**

| Dimensi | Hasil Interpretasi |
|---------|-------------------|
| Target Domain | **Fintech** (wallet, payment, banking) |
| Design Style | **Modern Dark** (glassmorphism, gradients) |
| Scope | **Medium** (15-25 components) |
| Template Screens | **Wallet Dashboard, Transfer, History, Card Detail** |
| Platform | **Mobile-first** (responsive) |

### Langkah 1.2 — Agen Membuat Output Files

Agen secara otomatis membuat folder dan 4 file:

```
flutter-ui-kit/01-prd-analysis/
├── market-analysis.md       ← Kompetitor (GetWidget, VelocityX, dll)
├── user-personas.md         ← 3 developer personas
├── requirements-validation.md ← Daftar komponen P0/P1/P2
└── pricing-strategy.md      ← Individual $39 / Team $99 / Enterprise $299
```

### Langkah 1.3 — Review dan Revisi (Optional)

**Prompt review:**
```
Saya mau tambahkan fitur crypto wallet juga, dan target market juga 
termasuk startup fintech di Asia Tenggara.
```

**Apa yang terjadi:**
- Agen update `requirements-validation.md` — tambah `CryptoBalanceCard`, `TokenListTile`
- Agen update `user-personas.md` — tambah persona "SEA Fintech Startup CTO"
- Agen update `market-analysis.md` — tambah kompetitor regional

---

## Phase 2: UI/UX Prototyping (Stitch AI)

### Langkah 2.1 — Generate Prototype Screens

**Prompt yang Anda ketik:**
```
Lanjut ke Phase 2 UI/UX Prototyping untuk UI Kit fintech ini.
Gunakan Stitch AI untuk generate screen designs.
```

**Apa yang terjadi:**
- Agen membaca `workflows/flutter-ui-kit/02_ui_ux_prototyping.md`
- Agen membaca output Phase 1 (5 dimensi, komponen list)
- Agen menggunakan skill `stitch-enhance-prompt` untuk membuat prompt yang lebih detail
- Agen memanggil Stitch AI (`mcp_stitch_create_project` → `mcp_stitch_generate_screen_from_text`)

**Screens yang di-generate:**

| # | Screen | Tipe | Keterangan |
|---|--------|------|-----------|
| 1 | Component Catalog | Mandatory | Grid semua komponen UI Kit |
| 2 | Component Detail | Mandatory | Preview + code + knobs interaktif |
| 3 | Theme Builder | Mandatory | Live color picker + font selector |
| 4 | Wallet Dashboard | Domain Template | Saldo, recent transactions, quick actions |
| 5 | Transfer Screen | Domain Template | Input amount, recipient, confirm |
| 6 | Transaction History | Domain Template | Filtered list, date grouping |
| 7 | Card Detail | Domain Template | Virtual card display, spending chart |

### Langkah 2.2 — Extract DESIGN.md

**Prompt (otomatis atau manual):**
```
Extract design tokens dari screens yang sudah di-generate ke DESIGN.md.
```

**Apa yang terjadi:**
- Agen menggunakan skill `stitch-design-md` untuk extract design tokens
- Output utama: `DESIGN.md` — **Single Source of Truth**

```markdown
# DESIGN.md (contoh output)

## Colors
- Primary: #6C63FF (Purple Accent)
- Secondary: #00D9A6 (Teal Green)
- Background: #0F0F23 (Dark Navy)
- Surface: #1A1A3E (Dark Card)
- Text Primary: #FFFFFF
- Text Secondary: #94A3B8
- Success: #10B981
- Error: #EF4444
- Warning: #F59E0B

## Typography
- Font Family: Plus Jakarta Sans
- Heading 1: 28px / Bold
- Heading 2: 24px / SemiBold
- Body: 16px / Regular
- Caption: 12px / Regular

## Spacing
- Base: 4px
- XS: 4px | SM: 8px | MD: 12px | LG: 16px | XL: 24px | XXL: 32px

## Radius
- SM: 8px | MD: 12px | LG: 16px | XL: 24px | Full: 999px

## Shadows
- SM: 0 1px 4px rgba(0,0,0,0.3)
- MD: 0 4px 8px rgba(0,0,0,0.4)
- LG: 0 8px 16px rgba(0,0,0,0.5)
```

### Langkah 2.3 — Output Folder

```
flutter-ui-kit/02-ui-ux-prototyping/
├── user-flows-wireframes.md    ← ASCII wireframes 7 screens
├── ui-prompts.md               ← Stitch-enhanced prompts per screen
├── DESIGN.md                   ← ⭐ Source of Truth — tokens
└── component-anatomy.md        ← State machines, animation specs
```

---

## Phase 3: Technical Implementation

### Langkah 3.1 — Translate Design ke Code Specs

**Prompt yang Anda ketik:**
```
Lanjut ke Phase 3 Technical Implementation.
Translate DESIGN.md ke Flutter code specifications.
```

**Apa yang terjadi:**
- Agen membaca `workflows/flutter-ui-kit/03_technical_implementation.md`
- Agen membaca `DESIGN.md` dari Phase 2
- Agen translate setiap token menjadi Dart class specification

**Contoh translation:**
```
DESIGN.md                    →  Flutter Code Spec
─────────────────────────         ──────────────────
Primary: #6C63FF             →  AppColors.primary = Color(0xFF6C63FF)
Spacing SM: 8px              →  AppSpacing.sm = 8.0
Radius MD: 12px              →  AppRadius.md = 12.0
Font: Plus Jakarta Sans      →  AppTextTheme.textTheme(fontFamily: 'Plus Jakarta Sans')
```

### Langkah 3.2 — Buat API Specifications

**Prompt (optional, bisa otomatis):**
```
Buatkan API specification untuk semua P0 components.
```

**Output contoh (AppButton spec):**
```dart
// Component API Spec
AppButton({
  required String text,
  ButtonVariant variant = ButtonVariant.primary,  // 5 variants
  ButtonSize size = ButtonSize.medium,             // 3 sizes
  bool isLoading = false,
  bool isDisabled = false,
  IconData? icon,
  VoidCallback? onPressed,
})
```

### Langkah 3.3 — Output Folder

```
flutter-ui-kit/03-technical-implementation/
├── package-structure.md         ← Directory layout, pubspec.yaml
├── dependencies.md              ← google_fonts, intl, flutter_localizations
├── design-tokens.md             ← Colors, typography, spacing → Dart classes
├── theme-system.md              ← 16 pre-built themes, AppThemeConfig
├── component-api-spec.md        ← 13+ component API signatures
└── testing-strategy.md          ← Coverage targets, golden tests, CI/CD
```

---

## Phase 4: Component Development

### Langkah 4.1 — Mulai Develop Komponen P0

**Prompt yang Anda ketik:**
```
Lanjut ke Phase 4 Component Development.
Mulai dari P0 MVP components — AppButton terlebih dahulu.
```

**Apa yang terjadi:**
- Agen membaca `workflows/flutter-ui-kit/04_component_development.md`
- Agen membaca API spec dari Phase 3
- Agen implements AppButton sesuai spec

### Langkah 4.2 — Develop Satu per Satu

**Prompt untuk setiap komponen:**
```
Buat komponen AppTextField dengan variants: default, search, password.
```

```
Buat komponen AppCard dengan variants: default, outlined.
```

```
Buat komponen BalanceCard (domain fintech) untuk menampilkan saldo.
```

**Setiap komponen menghasilkan:**
```
Per component output:
├── lib/src/components/core/button/app_button.dart      ← Widget
├── lib/src/components/core/button/button_variant.dart   ← Enum
├── lib/src/components/core/button/button_size.dart      ← Enum
├── test/components/core/button/app_button_test.dart     ← Tests
└── example/lib/presentation/screens/button_demo.dart    ← Demo (clean arch)
```

### Langkah 4.3 — Batch Development (opsional)

**Prompt batch:**
```
Buat semua 13 P0 components sekaligus:
AppButton, AppTextField, AppCheckbox, AppRadio, AppSwitch, 
AppDropdown, AppCard, AppImageCard, AppSnackBar, AppDialog, 
AppLoadingIndicator, AppAvatar, AppChip.
```

### Langkah 4.4 — Domain Components

**Prompt domain-specific:**
```
Buat domain components fintech:
- BalanceCard (saldo wallet, crypto balance)
- TransactionTile (history item, debit/credit icon)
- QuickActionButton (send, receive, top-up, pay)
- VirtualCard (card display dengan nomor, expiry)
```

### Langkah 4.5 — Output Folder

```
flutter-ui-kit/04-component-development/
├── mvp-components.md          ← 13 P0 component specs + status
├── core-components.md         ← 15-20 P1 components
├── domain-components.md       ← Fintech-specific components
├── enhanced-components.md     ← P2 plan
└── component-checklist.md     ← Per-component quality gate (35+ items)
```

---

## Phase 5: GTM Launch

### Langkah 5.1 — Siapkan Strategi Launch

**Prompt yang Anda ketik:**
```
Lanjut ke Phase 5 GTM Launch.
Siapkan strategi distribusi dan marketing untuk UI Kit fintech ini.
```

**Apa yang terjadi:**
- Agen membaca `workflows/flutter-ui-kit/05_gtm_launch.md`
- Agen menggunakan skill `senior-technical-writer`
- Agen membuat launch plan berdasarkan pricing dari Phase 1

### Langkah 5.2 — Setup Distribution Channels

**Prompt detail (optional):**
```
Setup pub.dev listing, Gumroad store, dan GitHub repository.
Buat juga landing page copy.
```

**Output:**
```
flutter-ui-kit/05-gtm-launch/
├── distribution-setup.md       ← pub.dev, Gumroad, GitHub, landing page
├── launch-timeline.md          ← T-4w, T-2w, T-1w, Launch Day, Post-launch
├── marketing-content.md        ← Blog posts, social media, email sequence
├── sales-funnel.md             ← Free tier → Individual → Team → Enterprise
└── metrics-kpi.md              ← Downloads, conversion, revenue targets
```

### Langkah 5.3 — Launch Checklist

Agen menghasilkan checklist:
```markdown
## Launch Day Checklist
- [ ] pub.dev published (verified, 130+ pub points)
- [ ] Gumroad store live (3 tiers: $39/$99/$299)
- [ ] GitHub repo public (README, examples, CI green)
- [ ] Landing page live (hero, features, pricing, testimonials)
- [ ] Blog post published ("Introducing Flutter Fintech UI Kit")
- [ ] Twitter/X announcement thread
- [ ] Reddit r/FlutterDev post
- [ ] Email to early access list
```

---

## Phase 6: Roadmap Execution

### Langkah 6.1 — Setup Sprint Planning

**Prompt yang Anda ketik:**
```
Lanjut ke Phase 6 Roadmap Execution.
Buatkan sprint plan dan milestone tracking.
```

**Apa yang terjadi:**
- Agen membaca `workflows/flutter-ui-kit/06_roadmap_execution.md`
- Agen menggunakan skill `senior-project-manager`
- Agen membuat sprint-to-phase mapping

### Langkah 6.2 — Sprint Overview

**Output sprint plan:**

| Sprint | Week | Phase | Deliverables |
|--------|------|-------|-------------|
| Sprint 1 | W1-W2 | Phase 3 | Tokens, themes, package structure |
| Sprint 2 | W3-W4 | Phase 4 | 13 P0 MVP components |
| Sprint 3 | W5-W6 | Phase 4 | 15-20 P1 components |
| Sprint 4 | W7 | Phase 4+5 | Domain components, polish, GTM prep |
| Sprint 5 | W8 | Phase 5 | Launch! pub.dev + Gumroad + marketing |

### Langkah 6.3 — Output Folder

```
flutter-ui-kit/06-roadmap-execution/
├── sprint-plan.md              ← Sprint breakdown, tasks per sprint
├── milestone-tracking.md       ← 5 milestones, acceptance criteria
├── risk-register.md            ← Identified risks + mitigations
├── resource-plan.md            ← Time allocation, tools needed
└── progress-reports/           ← Weekly reports (updated setiap sprint)
    ├── week-01.md
    ├── week-02.md
    └── ...
```

---

## Ringkasan: Semua Prompt dalam 1 Flow

Berikut urutan prompt dari awal sampai akhir:

```
📝 PHASE 1: PRD Analysis
────────────────────────
1. "Buatkan saya Flutter UI Kit untuk aplikasi fintech dengan 
    gaya modern dark mode. Targetnya developer freelancer dan 
    agency kecil."

2. (Optional) "Saya mau tambahkan fitur crypto wallet juga."


🎨 PHASE 2: UI/UX Prototyping
──────────────────────────────
3. "Lanjut ke Phase 2 UI/UX Prototyping. Gunakan Stitch AI 
    untuk generate screen designs."

4. (Optional) "Edit screen Wallet Dashboard — tambahkan crypto 
    balance card."


⚙️ PHASE 3: Technical Implementation
─────────────────────────────────────
5. "Lanjut ke Phase 3 Technical Implementation. Translate 
    DESIGN.md ke Flutter code specifications."


🧩 PHASE 4: Component Development
──────────────────────────────────
6. "Lanjut ke Phase 4. Mulai dari P0 MVP components — 
    AppButton terlebih dahulu."

7. "Buat komponen AppTextField dengan variants: default, 
    search, password."

8. "Buat domain components fintech: BalanceCard, 
    TransactionTile, QuickActionButton."

   ... (ulangi per komponen)


🚀 PHASE 5: GTM Launch
───────────────────────
9. "Lanjut ke Phase 5 GTM Launch. Siapkan strategi distribusi 
    dan marketing."


📊 PHASE 6: Roadmap Execution
──────────────────────────────
10. "Lanjut ke Phase 6 Roadmap Execution. Buatkan sprint plan 
     dan milestone tracking."
```

---

## Tips Penggunaan

### 💡 Tip 1: Tidak Harus Berurutan
Phase 1 dan 2 harus berurutan, tapi Phase 3-4 bisa dijalankan paralel dengan Phase 5-6.

### 💡 Tip 2: Prompt Sederhana = OK
Agen sudah diprogram untuk menginterpretasi prompt sederhana. Anda tidak perlu menulis prompt panjang.

### 💡 Tip 3: Revisi Kapan Saja
Setiap phase bisa di-revisi. Cukup bilang "ubah X menjadi Y" dan agen akan update output.

### 💡 Tip 4: Skip Phase Jika Sudah Punya
Jika Anda sudah punya DESIGN.md sendiri, skip Phase 2 dan langsung ke Phase 3.

### 💡 Tip 5: Gunakan Bersama Vibe Workflows
Planning workflows ini menghasilkan **dokumen**. Untuk menghasilkan **actual code**, gunakan `workflows/flutter-ui-kit-vibe/`:

```
Phase 1-2 (planning) → DESIGN.md + specs
       ↓
/init-project                     ← Vibe: setup actual code
/add-component AppButton          ← Vibe: implement widget
/add-theme ocean                  ← Vibe: add theme
/add-locale ja                    ← Vibe: add language
/quality-check                    ← Vibe: verify quality
/publish                          ← Vibe: publish to pub.dev
```

---

## Contoh Prompt untuk Domain Lain

### E-Commerce UI Kit
```
Buatkan Flutter UI Kit untuk aplikasi e-commerce (online shop).
Gaya desain clean dan colorful. Target developer freelancer.
```

### Social Media UI Kit
```
Buatkan Flutter UI Kit untuk aplikasi social media seperti Instagram.
Dark mode modern dengan animasi smooth.
```

### Dashboard/Admin UI Kit
```
Buatkan Flutter UI Kit untuk dashboard analytics / admin panel.
Gaya profesional, support desktop dan tablet.
```

### General Purpose UI Kit
```
Buatkan Flutter UI Kit general purpose yang bisa dipakai untuk 
berbagai jenis aplikasi. Gaya minimal dan clean.
```

Semua prompt di atas akan diproses melalui 6 phase yang sama — agen akan otomatis menyesuaikan output berdasarkan domain yang terdeteksi.

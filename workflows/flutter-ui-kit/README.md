# Flutter UI Kit Workflow

> **Flexible Workflow** — Build UI Kit Package, Showcase App, atau Hybrid approach.
> Pilih mode yang sesuai dengan goal kamu: passive income, business building, atau keduanya.

Workflow SDLC lengkap untuk membuat, mendesain, membangun, dan meluncurkan produk Flutter berbasis UI. Cukup berikan prompt sederhana — agen akan menginterpretasi, memperkaya, dan mengeksekusi seluruh pipeline sesuai mode yang dipilih.

---

## 🎯 Pilih Mode Anda

**START HERE!** Pilih mode sebelum melanjutkan ke Phase 1.

### Mode A: UI Kit Package 📦 (Recommended untuk Developer)

**Apa:** Component library yang dijual ke developer Flutter  
**Output:** Package (pub.dev, Gumroad)  
**Revenue:** $39-299 per license (one-time + recurring)  
**Best For:** Passive income, global market, minimal support

```
Prompt: "Saya ingin UI Kit e-commerce modern minimalis"
```

### Mode B: Showcase App 📱 (Untuk Business Builder)

**Apa:** Aplikasi lengkap yang bisa langsung dijalankan  
**Output:** Flutter app ( runnable)  
**Revenue:** Template license (Rp 2-5jt) atau SaaS (Rp 100-200K/bulan)  
**Best For:** Build business, recurring revenue, local market

```
Prompt: "Saya ingin aplikasi POS bengkel modern minimalis"
```

### Mode C: Hybrid 🎯 (RECOMMENDED - Best of Both)

**Apa:** UI Kit + Showcase App (UI Kit sebagai demo)  
**Output:** Package + App  
**Revenue:** Diversified (license + template/SaaS)  
**Best For:** Developer yang mau credibility + passive income

```
Prompt: "Saya ingin UI Kit bengkel POS dengan showcase app untuk demo"
```

### Quick Decision (30 seconds)

Jawab 4 pertanyaan:

1. **Goal utama?** Passive income → A | Build business → B | Both → C
2. **Siap jualan aktif?** Tidak → A | Ya → B | Mau tapi prefer passive → C
3. **Revenue model?** One-time → A | Recurring → B | Both → C
4. **Support capacity?** Minimal → A | High → B | Medium → C

**Kebanyakan A?** → Mode A | **Kebanyakan B?** → Mode B | **Mixed/C?** → Mode C

👉 **Detailed guide:** [`00_mode_selection.md`](00_mode_selection.md)

---

## Cara Pakai (Quick Start)

### Step 1: Pilih Mode
Lihat section "🎯 Pilih Mode Anda" di atas atau baca [`00_mode_selection.md`](00_mode_selection.md)

### Step 2: Submit Prompt

**Mode A (UI Kit):**
```
"Saya ingin UI Kit e-commerce modern minimalis"
```

**Mode B (Showcase App):**
```
"Saya ingin aplikasi POS bengkel modern minimalis"
```

**Mode C (Hybrid):**
```
"Saya ingin UI Kit bengkel POS dengan showcase app untuk demo"
```

### Step 3: Workflow Executes

Agen akan otomatis:
1. **Mode Selection** → Konfirmasi mode yang dipilih
2. **Interpretasi** → Parse 5 dimensi (domain, style, scope, templates, platform)
3. **PRD** → Analisis market sesuai mode (developer vs end-user personas)
4. **UI/UX** → Generate screens via Stitch AI, extract DESIGN.md
5. **Technical** → Setup structure sesuai mode (package vs app)
6. **Components** → Build 13 P0 + domain components
7. **Launch** → Mode A: pub.dev/Gumroad | Mode B: Direct sales | Mode C: Both
8. **Track** → Sprint planning, milestones, risk management

---

## Konsep Kunci: 5 Dimensi + Mode Selection

**Step 0: Mode Selection** (NEW!)
- Mode A: UI Kit Package → Developer personas, license pricing
- Mode B: Showcase App → End-user personas, SaaS pricing  
- Mode C: Hybrid → Both personas, diversified revenue

**5 Dimensi** (same untuk semua mode, context berbeda):

| # | Dimensi | Contoh | Default |
|---|---------|--------|---------|
| 1 | **Target Domain** | e-commerce, fintech, social, dashboard | General-purpose |
| 2 | **Gaya Desain** | modern minimalis, dark premium, glassmorphism | Modern clean |
| 3 | **Scope** | MVP (30 komponen), Full (50+), Enterprise | MVP |
| 4 | **Template Screens** | Login, Dashboard, Cart, Profile | Login, Dashboard, Settings |
| 5 | **Platform** | Mobile-first, Web, Desktop, Responsive | Mobile-first |

Dimensi ini mengalir ke SEMUA phase dengan context berbeda per mode:

```
User Prompt → Mode Selection → 5 Dimensi → Phase 1 → Phase 2 → Phase 3 → Phase 4 → Phase 5 → Phase 6
              (A/B/C)                      (mode-aware PRD & execution)
```

---

## 6 Phase Workflow

```
Phase 1: PRD Analysis
    ↓ (5 dimensi, pricing, personas)
Phase 2: UI/UX Prototyping (Stitch AI)
    ↓ (DESIGN.md, wireframes, screens)
Phase 3: Technical Implementation
    ↓ (tokens, themes, API specs)
Phase 4: Component Development
    ↓ (13 P0 + P1 + domain components)
Phase 5: GTM Launch                    ← paralel dengan Phase 4 akhir
    ↓ (channels, marketing, launch)
Phase 6: Roadmap Execution             ← berjalan sepanjang project
    (sprints, milestones, tracking)
```

---

## Detail per Phase

### Phase 1: PRD Analysis (Mode-Aware)
**File:** `01_prd_analysis.md`
**Output Folder:** `flutter-ui-kit/01-prd-analysis/`

**Mode Differences:**

| Output File | Mode A (UI Kit) | Mode B (Showcase App) |
|-------------|-----------------|----------------------|
| `market-analysis.md` | UI Kit competitors (GetWidget, Shadcn) | App competitors (local POS) |
| `user-personas.md` | Developer personas | End-user personas (bengkel owner) |
| `requirements-validation.md` | Component requirements | Feature requirements |
| `pricing-strategy.md` | License: $39/$99/$299 | Template/SaaS: Rp 2-5jt / Rp 100-200K |

**Key:** Mode menentukan target market, personas, dan revenue model.

---

### Phase 2: UI/UX Prototyping (Stitch AI)
**File:** `02_ui_ux_prototyping.md`
**Output Folder:** `flutter-ui-kit/02-ui-ux-prototyping/`

| Output File | Isi |
|-------------|-----|
| `user-flows-wireframes.md` | ASCII wireframes showcase app (5-8 screens) |
| `ui-prompts.md` | Stitch-enhanced prompts per screen |
| `DESIGN.md` | **Source of Truth** — colors, typography, spacing, radius, shadows |
| `component-anatomy.md` | State machines, animation specs, accessibility per P0 component |

**Key:** Menggunakan Stitch AI skills (`stitch-enhance-prompt`, `mcp_stitch_generate_screen_from_text`, `stitch-design-md`). Output utama = `DESIGN.md`.

**Mandatory Screens (selalu ada):**
1. Component Catalog — grid semua komponen
2. Component Detail — preview + code + knobs
3. Theme Builder — live color picker

**Domain Template Screens (berdasarkan target domain):**
| Domain | Screens |
|--------|---------|
| E-Commerce | Home Feed, Product Detail, Cart |
| Fintech | Wallet Dashboard, Transfer, History |
| Social Media | Feed, Profile, Stories |
| Dashboard | Analytics, User Management |
| General | Login, Dashboard, Settings |

---

### Phase 3: Technical Implementation (Mode-Specific Structure)
**File:** `03_technical_implementation.md`
**Output Folder:** `flutter-ui-kit/03-technical-implementation/`

**Mode A (UI Kit Package):**
```
lib/
├── src/
│   ├── components/    # UI components
│   ├── tokens/        # Design tokens
│   └── theme/         # Theme system
└── example/           # Demo kecil
pubspec.yaml (package)
```

**Mode B (Showcase App):**
```
lib/
├── main.dart          # Entry point
├── features/          # Feature modules
├── shared/            # Shared widgets
└── data/              # Dummy data
pubspec.yaml (app)
```

**Mode C (Hybrid):**
- Week 1-8: Build Mode A structure
- Week 9-12: Build Mode B structure (reuses UI Kit)

**Dependencies (MINIMAL curated):**
- `google_fonts` — typography premium
- `intl` — i18n support
- `flutter_localizations` (SDK) — multi-language
- **Mode A only:** DILARANG state management, database di core package
- **Mode B only:** Boleh Riverpod/BLoC untuk state management

---

### Phase 4: Component Development
**File:** `04_component_development.md`
**Output Folder:** `flutter-ui-kit/04-component-development/`

| Output File | Isi |
|-------------|-----|
| `mvp-components.md` | 13 P0 components (AppButton, AppTextField, AppCard, dll) |
| `core-components.md` | 15-20 P1 components (navigation, enhanced inputs, feedback) |
| `domain-components.md` | Domain-specific (ProductCard, BalanceCard, dll) jika applicable |
| `enhanced-components.md` | P2 plan (AppDataTable, AppTimeline, AppDatePicker, dll) |
| `component-checklist.md` | Per-component quality gate (35+ items) |

**P0 Components (13 WAJIB):**

| Component | Category | Variants |
|-----------|----------|----------|
| AppButton | Core | primary, secondary, outline, ghost, destructive × 3 sizes |
| AppTextField | Core | default, search, password |
| AppCheckbox | Core | with label |
| AppRadio | Core | with label |
| AppSwitch | Core | toggle |
| AppDropdown | Core | select |
| AppCard | Surface | default, outlined |
| AppImageCard | Surface | with image |
| AppSnackBar | Feedback | info, success, warning, error |
| AppDialog | Feedback | alert, confirm, custom |
| AppLoadingIndicator | Feedback | circular, linear |
| AppAvatar | Display | image, initials, icon × 5 sizes |
| AppChip | Display | default, selected, removable |

**Key:** Setiap komponen harus pass quality gate: implementation → tests (>90%) → accessibility → dartdoc → demo.

---

### Phase 5: GTM Launch (Mode-Specific Channels)
**File:** `05_gtm_launch.md`
**Output Folder:** `flutter-ui-kit/05-gtm-launch/`

**Mode A (UI Kit Package):**
- **Channels:** pub.dev (free tier), Gumroad (paid), Product Hunt
- **Marketing:** Developer communities (Twitter, Discord, Reddit)
- **Pricing:** $39 Individual / $99 Team / $299 Enterprise
- **Target:** Flutter developer

**Mode B (Showcase App):**
- **Channels:** Direct sales, local marketing, demo presentations
- **Marketing:** Bengkel associations, business networks
- **Pricing:** Rp 2-5jt template / Rp 100-200K/bulan SaaS
- **Target:** Pemilik bengkel (end-user)

**Mode C (Hybrid):**
- **Phase 1:** Launch UI Kit (Mode A channels)
- **Phase 2:** Launch Showcase App as live demo
- **Cross-promote:** "Built with [UI Kit Name]" in demo app

**Key:** Mode menentukan go-to-market strategy dan pricing.

---

### Phase 6: Roadmap Execution
**File:** `06_roadmap_execution.md`
**Output Folder:** `flutter-ui-kit/06-roadmap-execution/`

| Output File | Isi |
|-------------|-----|
| `sprint-plan.md` | 8 weekly sprints, daily tasks |
| `milestone-tracking.md` | 5 milestones (Foundation → MVP → Core → Polish → Launch) |
| `resource-management.md` | Capacity, budget, time tracking |
| `risk-register.md` | Technical, project, market risks + mitigation |
| `progress-reports.md` | Weekly + monthly report templates |

**Key:** Sprint tasks HARUS merujuk ke deliverables Phase 3-5. Tidak boleh invent tasks baru.

---

## Timeline Overview (Mode-Specific)

**Mode A (UI Kit Package) - 8 weeks:**
```
┌──────────────────────────────────────────────────────┐
│  WEEK 1-2: FOUNDATION                                │
│  ├─ Phase 1: PRD Analysis (developer personas)       │
│  ├─ Phase 2: UI/UX Prototyping (Stitch AI)           │
│  └─ Phase 3: Technical (package structure)           │
├──────────────────────────────────────────────────────┤
│  WEEK 3-4: MVP (P0 Components)                       │
│  └─ Phase 4: 13 core components                      │
├──────────────────────────────────────────────────────┤
│  WEEK 5-6: CORE (P1 Components)                      │
│  └─ Phase 4: Navigation + enhanced + domain          │
├──────────────────────────────────────────────────────┤
│  WEEK 7: POLISH                                      │
│  ├─ Phase 4: Final testing & docs                    │
│  └─ Phase 5: Pre-launch setup                        │
├──────────────────────────────────────────────────────┤
│  WEEK 8: LAUNCH 🚀                                   │
│  ├─ Phase 5: Launch week execution                   │
│  └─ Phase 6: Ongoing tracking                        │
└──────────────────────────────────────────────────────┘
```

**Mode B (Showcase App) - 8-12 weeks:**
```
┌──────────────────────────────────────────────────────┐
│  WEEK 1-2: FOUNDATION                                │
│  ├─ Phase 1: PRD (end-user personas)                 │
│  ├─ Phase 2: UI/UX (Stitch AI)                       │
│  └─ Phase 3: Technical (app structure)               │
├──────────────────────────────────────────────────────┤
│  WEEK 3-6: CORE FEATURES                             │
│  └─ Build main screens + state management            │
├──────────────────────────────────────────────────────┤
│  WEEK 7-8: POLISH + DEMO                             │
│  ├─ Testing, deployment setup                        │
│  └─ Demo data, user guide                            │
├──────────────────────────────────────────────────────┤
│  WEEK 9+: SALES                                      │
│  ├─ Direct outreach, demo presentations              │
│  └─ Customer onboarding                              │
└──────────────────────────────────────────────────────┘
```

**Mode C (Hybrid) - 12-16 weeks:**
```
┌──────────────────────────────────────────────────────┐
│  WEEK 1-8: UI KIT PACKAGE (Mode A)                   │
│  └─ Complete UI Kit with 23+ components              │
├──────────────────────────────────────────────────────┤
│  WEEK 9-12: SHOWCASE APP                             │
│  ├─ Reuse UI Kit components                          │
│  ├─ Build domain screens                             │
│  └─ Deploy as live demo                              │
├──────────────────────────────────────────────────────┤
│  WEEK 13+: DUAL MARKETING                            │
│  ├─ UI Kit: Developer marketing                      │
│  ├─ Showcase: Demo for credibility                   │
│  └─ Cross-promote both                               │
└──────────────────────────────────────────────────────┘
```

## Milestones (Mode-Specific)

**Mode A (UI Kit Package):**

| # | Milestone | Week | Acceptance Criteria |
|---|-----------|------|---------------------|
| M1 | Foundation | W2 | Tokens + 16 themes working |
| M2 | MVP | W4 | 13 P0 components, >90% coverage |
| M3 | Core | W6 | 15-20 P1 components, >85% coverage |
| M4 | Polish | W7 | Full docs, >85% overall coverage, example app polished |
| M5 | Launch | W8 | pub.dev + Gumroad live, first sale made |

**Mode B (Showcase App):**

| # | Milestone | Week | Acceptance Criteria |
|---|-----------|------|---------------------|
| M1 | Foundation | W2 | DESIGN.md + app structure ready |
| M2 | MVP | W6 | Core features working, dummy data |
| M3 | Polish | W8 | All screens complete, tested |
| M4 | Demo | W10 | Live demo deployed, ready for sales |
| M5 | First Sale | W12 | First paying customer |

**Mode C (Hybrid):**

| # | Milestone | Week | Acceptance Criteria |
|---|-----------|------|---------------------|
| M1 | UI Kit MVP | W8 | 13 P0 components, pub.dev ready |
| M2 | Showcase App | W12 | Demo app deployed, uses UI Kit |
| M3 | Dual Launch | W14 | Both products live |
| M4 | Cross-Promote | W16 | Demo drives UI Kit sales |
| M5 | Scale | W20+ | Diversified revenue streams |

---

## Skills yang Digunakan

| Phase | Skills & Tools |
|-------|---------------|
| 1 PRD | `brainstorming`, `prd`, `senior-ui-ux-designer` |
| 2 UI/UX | `stitch-enhance-prompt`, `mcp_stitch_generate_screen_from_text`, `stitch-design-md`, `senior-ui-ux-designer` |
| 3 Technical | `senior-flutter-developer` |
| 4 Components | `senior-flutter-developer` |
| 5 GTM | `senior-technical-writer`, content & marketing skills |
| 6 Roadmap | `senior-project-manager` |

---

## Budget Estimate (Mode-Specific)

**Mode A (UI Kit Package):**

| Category | Amount |
|----------|--------|
| Domain + Hosting (6 months) | ~$140 |
| Email marketing (6 months) | ~$180 |
| Analytics (6 months) | ~$54 |
| Design assets | ~$100 |
| Gumroad fees (~10% revenue) | ~$1,365 |
| **Total (6 months)** | **~$1,840** |

**Revenue Target:** $13,650 dalam 6 bulan (100 customers × avg $39 + upgrades)

**Mode B (Showcase App):**

| Category | Amount |
|----------|--------|
| Domain + Hosting (6 months) | ~$140 |
| Demo deployment (6 months) | ~$180 |
| Sales materials | ~$200 |
| Local marketing | ~$500 |
| **Total (6 months)** | **~$1,020** |

**Revenue Target:** Rp 50-100 juta dalam 6 bulan (10-20 customers)

**Mode C (Hybrid):**

| Category | Amount |
|----------|--------|
| UI Kit marketing | ~$1,840 |
| Showcase App demo | ~$1,020 |
| **Total (6 months)** | **~$2,860** |

**Revenue Target:** $20-40K (UI Kit) + Rp 50-100jt (Template) dalam 6 bulan

---

## Related Documentation

| Document | Path |
|----------|------|
| PRD | `../../docs/flutter-ui-kit/01_PRD.md` |
| Technical Spec | `../../docs/flutter-ui-kit/02_TECHNICAL_SPEC.md` |
| Component Catalog | `../../docs/flutter-ui-kit/03_COMPONENT_CATALOG.md` |
| GTM Strategy | `../../docs/flutter-ui-kit/04_GTM_STRATEGY.md` |
| Roadmap | `../../docs/flutter-ui-kit/05_ROADMAP.md` |

---

## Pre-Project Checklist

**Mode Selection (CRITICAL):**
- [ ] Read [`00_mode_selection.md`](00_mode_selection.md)
- [ ] Choose mode: A (UI Kit) / B (Showcase) / C (Hybrid)
- [ ] Note mode in project documentation

**Common Requirements:**
- [ ] Flutter SDK >=3.10.0 installed
- [ ] Development environment ready (VS Code / Android Studio)
- [ ] GitHub account for repository + CI/CD
- [ ] Stitch AI MCP tools accessible

**Mode-Specific:**

**Mode A (UI Kit):**
- [ ] Budget approved (~$1,840 / 6 months)
- [ ] Timeline committed (8 weeks for MVP + launch)
- [ ] Marketing plan (developer communities)

**Mode B (Showcase App):**
- [ ] Domain knowledge (bengkel, clinic, etc.)
- [ ] Sales readiness (direct outreach)
- [ ] Support capacity (high touch)
- [ ] Budget approved (~$1,020 / 6 months)
- [ ] Timeline committed (12 weeks for demo)

**Mode C (Hybrid):**
- [ ] All Mode A requirements
- [ ] Extra 4-6 weeks for Phase 2
- [ ] Ability to manage 2 products
- [ ] Budget approved (~$2,860 / 6 months)

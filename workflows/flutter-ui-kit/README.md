# Flutter UI Kit Workflow

> **Produk: Flutter UI Kit** — Component library yang dijual ke developer Flutter.
> Bukan app, bukan SaaS, bukan jasa. Yang berubah per project adalah *tema, domain, dan scope*.

Workflow SDLC lengkap untuk membuat, mendesain, membangun, dan meluncurkan **Flutter UI Kit** sebagai produk komersial. Cukup berikan prompt sederhana — agen akan menginterpretasi, memperkaya, dan mengeksekusi seluruh pipeline.

---

## Cara Pakai (Quick Start)

### Contoh Prompt Sederhana
```
"Saya ingin UI Kit e-commerce modern minimalis"
```

Agen akan otomatis:
1. **Interpretasi** → UI Kit bertema e-commerce, gaya modern minimalis
2. **PRD** → Analisis market UI Kit, personas developer, pricing $39/$99/$299
3. **UI/UX** → Generate showcase screens via Stitch AI, extract DESIGN.md
4. **Technical** → Setup package, tokens dari DESIGN.md, 16 themes
5. **Components** → Build 13 P0 + domain components (ProductCard, CartItem, dll)
6. **Launch** → pub.dev, Gumroad, landing page, Product Hunt
7. **Track** → Sprint planning, milestones, risk management

### Contoh Prompt Lainnya
```
"UI Kit fintech dark premium"
"UI Kit social media colorful"
"UI Kit dashboard enterprise"
"UI Kit general purpose"     ← default, multi-domain
```

---

## Konsep Kunci: 5 Dimensi UI Kit

Setiap prompt di-parse menjadi 5 dimensi. Yang tidak disebutkan user = auto-filled:

| # | Dimensi | Contoh | Default |
|---|---------|--------|---------|
| 1 | **Target Domain** | e-commerce, fintech, social, dashboard | General-purpose |
| 2 | **Gaya Desain** | modern minimalis, dark premium, glassmorphism | Modern clean |
| 3 | **Scope Kit** | MVP (30 komponen), Full (50+), Enterprise | MVP |
| 4 | **Template Screens** | Login, Dashboard, Cart, Profile | Login, Dashboard, Settings |
| 5 | **Platform** | Mobile-first, Web, Desktop, Responsive | Mobile-first |

Dimensi ini mengalir ke SEMUA phase:

```
User Prompt → Parse 5 Dimensi → Phase 1 → Phase 2 → Phase 3 → Phase 4 → Phase 5 → Phase 6
                                  PRD       UI/UX     Technical  Components  Launch    Track
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

### Phase 1: PRD Analysis
**File:** `01_prd_analysis.md`
**Output Folder:** `flutter-ui-kit/01-prd-analysis/`

| Output File | Isi |
|-------------|-----|
| `market-analysis.md` | Market size, kompetitor UI Kit (GetWidget, Shadcn Flutter, VelocityX) |
| `user-personas.md` | Developer personas (freelancer, agency CTO, junior dev) |
| `requirements-validation.md` | Component & theme requirements, prioritas P0/P1/P2 |
| `pricing-strategy.md` | License tiers: Individual $39 / Team $99 / Enterprise $299 |

**Key:** Menginterpretasi prompt sederhana → output kaya. Produk = SELALU UI Kit.

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

### Phase 3: Technical Implementation
**File:** `03_technical_implementation.md`
**Output Folder:** `flutter-ui-kit/03-technical-implementation/`

| Output File | Isi |
|-------------|-----|
| `package-structure.md` | Directory layout, pubspec.yaml (minimal curated deps) |
| `dependencies.md` | Dependency policy (google_fonts, intl, flutter_localizations) |
| `design-tokens.md` | Colors (8 palettes), typography (Google Fonts), spacing, radius, shadows |
| `theme-system.md` | ThemeConfig class, 16 pre-built themes, ThemeProvider |
| `component-api-spec.md` | 13+ P0 component API definitions |
| `testing-strategy.md` | Coverage targets (>85%), golden tests, CI/CD |

**Key:** Translate `DESIGN.md` → Flutter `ThemeData`. Values must match 1:1.

**Dependencies (MINIMAL curated):**
- `google_fonts` — typography premium (Inter, Outfit, Plus Jakarta Sans)
- `intl` — date, number, currency formatting + ARB translations
- `flutter_localizations` (SDK) — multi-language support (EN, ID, ES, JA, ZH)
- **DILARANG:** state management (Riverpod/BLoC/GetX), database, HTTP clients

**Showcase App Architecture (di `example/`):**
- **Clean Architecture:** domain → data → presentation layers
- **Dummy Data:** Hardcoded lists (NO database — Hive/Sqflite/Isar)
- **State Management:** Built-in only (`ChangeNotifier` + `ValueNotifier`)
- **Navigation:** `go_router` (satu-satunya third-party di example app)
- **TIDAK BOLEH:** Riverpod, BLoC, GetX — supaya compatible dengan semua pembeli

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

### Phase 5: GTM Launch
**File:** `05_gtm_launch.md`
**Output Folder:** `flutter-ui-kit/05-gtm-launch/`

| Output File | Isi |
|-------------|-----|
| `distribution-channels.md` | pub.dev (free tier), Gumroad (paid), GitHub, Landing Page |
| `launch-timeline.md` | Pre-launch W6-7, Launch Week W8, Post-launch W9+ |
| `marketing-content.md` | 4 content pillars, calendar, Twitter/blog templates |
| `sales-funnel.md` | Awareness → Interest → Consideration → Conversion → Retention |
| `metrics-tracking.md` | KPIs, revenue projections, analytics stack |

**Key:** Target buyer = developer Flutter. Pricing dari Phase 1: $39/$99/$299.

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

## Timeline Overview

```
┌──────────────────────────────────────────────────────┐
│  WEEK 1-2: FOUNDATION                                │
│  ├─ Phase 1: PRD Analysis                            │
│  ├─ Phase 2: UI/UX Prototyping (Stitch AI)           │
│  └─ Phase 3: Technical Implementation (tokens+themes)│
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

## Milestones

| # | Milestone | Week | Acceptance Criteria |
|---|-----------|------|---------------------|
| M1 | Foundation | W2 | Tokens + 16 themes working |
| M2 | MVP | W4 | 13 P0 components, >90% coverage |
| M3 | Core | W6 | 15-20 P1 components, >85% coverage |
| M4 | Polish | W7 | Full docs, >85% overall coverage, example app polished |
| M5 | Launch | W8 | pub.dev + Gumroad live, first sale made |

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

## Budget Estimate

| Category | Amount |
|----------|--------|
| Domain + Hosting (6 months) | ~$140 |
| Email marketing (6 months) | ~$180 |
| Analytics (6 months) | ~$54 |
| Design assets | ~$100 |
| Gumroad fees (~10% revenue) | ~$1,365 |
| **Total (6 months)** | **~$1,840** |

**Revenue Target:** $13,650 dalam 6 bulan (100 customers × avg $39 + upgrades)

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

- [ ] Flutter SDK >=3.10.0 installed
- [ ] Development environment ready (VS Code / Android Studio)
- [ ] GitHub account for repository + CI/CD
- [ ] Stitch AI MCP tools accessible
- [ ] Budget approved (~$1,840 / 6 months)
- [ ] Timeline committed (8 weeks for MVP + launch)

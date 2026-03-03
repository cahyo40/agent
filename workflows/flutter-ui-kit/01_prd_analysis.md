---
description: PRD analysis untuk Flutter UI Kit commercial product. Menghasilkan output kaya bahkan dari prompt sederhana.
---
# Workflow: PRD Analysis - Flutter UI Kit

## Overview
Workflow ini menganalisis dan memvalidasi Product Requirements Document (PRD) untuk produk **Flutter UI Kit**. Produk yang dihasilkan SELALU berupa **component library / UI Kit** yang dijual ke developer — bukan aplikasi end-user.

**CRITICAL:** Jika user memberikan prompt sederhana, agen harus menginterpretasinya dalam konteks UI Kit. Contoh: "saya ingin aplikasi e-commerce modern minimalis" → berarti **UI Kit bertema e-commerce dengan gaya modern minimalist**, bukan membuat app e-commerce itu sendiri.

## Output Location
**Base Folder:** `flutter-ui-kit/01-prd-analysis/`

**Output Files:**
- `market-analysis.md` - Market Size, Competitor Analysis (UI Kit market)
- `user-personas.md` - Developer Personas with Jobs-to-be-Done
- `requirements-validation.md` - Validated Component & Theme Requirements
- `pricing-strategy.md` - License Tiers and Revenue Model

## Prerequisites
- PRD draft di `docs/flutter-ui-kit/01_PRD.md` (jika tidak ada, agen auto-generate)
- Market research data (jika tidak ada, agen generate dari industry knowledge)

---

## Agent Behavior: Handling Simple Prompts

**GOLDEN RULE:** Agen TIDAK BOLEH bertanya "bisa jelaskan lebih detail?" sebelum mulai bekerja. Agen harus menginterpretasi, memperkaya, dan mengisi gap secara otomatis.

### Prinsip Utama: PRODUK = SELALU UI KIT

Apapun prompt user, produknya SELALU Flutter UI Kit. Yang berubah berdasarkan prompt adalah:
- **Target Domain**: App domain apa yang didukung oleh UI Kit ini (e-commerce, fintech, dll)
- **Gaya Desain**: Aesthetic dari komponen-komponen di dalam kit
- **Template Screens**: Screen template apa yang disertakan dalam showcase app

### Step 0: Prompt Interpretation Layer (WAJIB PERTAMA)

Agen harus mem-parsing prompt dan mengekstrak **5 dimensi UI Kit**:

```
User Prompt → Parse 5 Dimensions → Fill Gaps → Generate Rich Output
```

#### 5 Dimensi UI Kit (Extract or Auto-Fill)

| # | Dimensi | Cara Parsing | Default |
|---|---------|-------------|---------|
| 1 | **Target App Domain** | Deteksi: "e-commerce", "fintech", "social media", "dashboard", "booking" | General-purpose (multi-domain) |
| 2 | **Gaya Desain Kit** | Parsing: "modern", "minimalis", "dark", "glassmorphism", "colorful" | Modern clean (Shadcn-inspired) |
| 3 | **Scope Kit** | Parsing: "MVP", "sederhana", "lengkap", "enterprise" | MVP (13 komponen P0) |
| 4 | **Template Screens** | Parsing: app domain → screen templates yang disertakan | Component catalog + Theme builder |
| 5 | **Platform Target** | Parsing: "mobile", "web", "desktop" | Mobile-first + Web support |

#### Contoh Interpretasi Prompt Sederhana

**Prompt: "saya ingin aplikasi e-commerce dengan gaya modern minimalis"**

```yaml
# INTERPRETASI BENAR (UI Kit context):
produk: "Flutter UI Kit — E-Commerce Edition"
target_domain: "E-Commerce"
pembeli_kit: "Flutter developer yang membangun app e-commerce"
gaya_desain:
  style: "Modern Minimalist"
  color: "Netral (gray) + 1 accent (sky-500 / emerald-500)"
  typography: "Inter / Plus Jakarta Sans, 400/500/600"
  border_radius: "12-16px"
  shadow: "Subtle, 0-4dp"
komponen_khusus_domain:
  - ProductCard (gambar, harga, badge diskon, rating)
  - CartItem (quantity selector, remove, subtotal)
  - CheckoutForm (shipping address, payment method)
  - OrderStatusTracker (timeline steps)
  - PriceTag (original, discounted, percentage off)
  - CategoryFilter (horizontal chips, grid toggle)
template_screens:
  - Home Feed (product grid + banner carousel)
  - Product Detail (gallery, description, add-to-cart)
  - Shopping Cart (item list, summary, checkout CTA)
  - Order History (status badges, tracking)
kompetitor_ui_kit: [GetWidget, Shadcn Flutter, VelocityX, CodeCanyon UI Kits]
persona: "Budi, 28 thn, Flutter freelancer, bikin app e-commerce untuk client UMKM"
```

**Prompt: "buat UI kit untuk fintech"**

```yaml
produk: "Flutter UI Kit — Fintech Edition"
target_domain: "Fintech / Digital Wallet"
gaya_desain: "Default: Clean trust-colors (hijau/biru tua)"
komponen_khusus_domain:
  - BalanceCard (saldo, trend, currency)
  - TransactionItem (icon, amount, date, status)
  - PinInput (secure, masked, shake animation)
  - TransferForm (recipient, amount, notes)
  - ChartWidget (line/bar/donut untuk analytics)
kompetitor_ui_kit: [GetWidget, Shadcn Flutter, FinKit templates]
```

**Prompt: "Jalankan PRD analysis" (tanpa konteks)**

```yaml
# Fallback ke default:
produk: "Flutter UI Kit — General Purpose"
target_domain: "Multi-domain (general-purpose components)"
gaya_desain: "Modern clean, Shadcn/Vercel-inspired"
kompetitor_ui_kit: [GetWidget, Shadcn Flutter, VelocityX, CodeCanyon]
```

### Step 1: Context Enrichment (Auto-Generate Gaps)

Setelah 5 dimensi ter-extract, agen WAJIB mengisi context berikut:

**A. Kompetitor (SELALU sesama UI Kit):**
- GetWidget, Shadcn Flutter, VelocityX, Flutter Starter Kit, CodeCanyon UI templates
- JANGAN bandingkan dengan Tokopedia/Shopee — itu bukan kompetitor UI Kit
- Jika target domain spesifik, cari juga UI Kit yang fokus di domain tersebut

**B. Market Sizing (Flutter UI Kit market):**
- TAM: ~5 juta Flutter developer global (Google I/O, StackOverflow Survey)
- SAM: ~3-5% yang membeli dev tools/UI Kit = ~150-250K developers
- SOM: Target realistis 6-12 bulan (200-500 paying customers)
- WAJIB sertakan logika perhitungan

**C. Persona (SELALU developer — yang MEMBELI kit):**
- **Persona 1 (Core):** Freelance Flutter Dev (SE Asia) — bikin app client
- **Persona 2 (High-LTV):** CTO / Tech Lead startup — standarkan UI tim
- **Persona 3 (Volume):** Junior dev / CS student — belajar best practices
- Pain points = pain DEVELOPER (rebuild komponen, UI inkonsisten, dll)
- BUKAN pain end-user app (misal: "susah belanja online")

**D. Design Language Mapping** — translate `gaya_desain` ke token kit:

| Kata Kunci | Warna Kit | Font | Radius | Shadow | Inspirasi |
|------------|-----------|------|--------|--------|-----------|
| "modern minimalis" | Netral + 1 accent | Inter 400/500/600 | 12-16px | Subtle 0-4dp | Apple, Uniqlo |
| "colorful/playful" | Multi-color bold | Poppins 500/700 | 16-24px | Medium 4-8dp | Duolingo |
| "dark/premium" | Dark bg + gold/cyan | SF Pro 300/500/700 | 8-12px | Glow | Spotify |
| "glassmorphism" | Translucent + gradient | Inter 400/600 | 16-24px | Blur + border | iOS |
| "neobrutalism" | Black + bright | Space Grotesk 700/900 | 0-4px | Hard offset | Gumroad |
| "cute/kawaii" | Pastel soft | Nunito 500/700 | 20-28px | Soft | LINE |
| "professional" | Blue/navy + gray | Roboto 400/600 | 4-8px | Medium | Salesforce |
| Tidak disebutkan | Blue primary | Inter 400/500 | 12px | Subtle | Material You |

**E. Domain-Specific Components** — komponen tambahan sesuai `target_domain`:

| Target Domain | Komponen Tambahan di Kit |
|---------------|--------------------------|
| E-Commerce | ProductCard, CartItem, PriceTag, CategoryFilter, CheckoutForm |
| Fintech | BalanceCard, TransactionItem, PinInput, TransferForm, ChartWidget |
| Social Media | PostCard, StoryAvatar, CommentThread, FollowButton, MediaGrid |
| Dashboard / SaaS | DataTable, StatCard, ChartWidget, SidebarNav, FilterBar |
| Food Delivery | RestaurantCard, MenuItemCard, OrderTracker, RatingWidget |
| Booking | CalendarPicker, TimeSlotGrid, BookingCard, PriceSummary |
| General Purpose | (Core components only, no domain-specific) |

### Step 2: Deep Analysis Protocol

Untuk SETIAP deliverable, agen WAJIB:
1. Konteks = SELALU UI Kit product (bukan app end-user)
2. Kompetitor = SELALU sesama UI Kit / component library
3. Persona = SELALU developer yang MEMBELI kit
4. Pricing = SELALU license-based ($39/$99/$299)
5. Jika ada target domain, tambahkan domain-specific components ke requirements
6. Minimum 3-5 data points per section dengan reasoning
7. Executive Summary di awal setiap dokumen

### Output Size Minimums (Quality Gate)

| Deliverable | Min. Lines | Sections WAJIB |
|-------------|------------|----------------|
| market-analysis.md | 150 | Exec Summary, TAM/SAM/SOM, 5+ UI Kit Competitors, SWOT, Gaps, Trends |
| user-personas.md | 150 | 2-3 Developer Personas (JTBD), Pain-to-Feature Map, Empathy Map |
| requirements-validation.md | 100 | P0/P1/P2 Component Tables, NFR, Dependency Map |
| pricing-strategy.md | 150 | Competitor Pricing, 3 License Tiers, Revenue Projections, Launch Strategy |

---

## Deliverables

### 1. Market Analysis

**Description:** Analisis komprehensif pasar Flutter UI Kit. SELALU tentang UI Kit market.

**Recommended Skills:** `market-researcher`, `product-strategist`

**Instructions:**
1. Market sizing (Flutter developer ecosystem):
   - TAM: Global Flutter developers (~5 juta, sumber: Google I/O, StackOverflow)
   - SAM: Developer yang membeli dev tools (3-5% = ~150-250K)
   - SOM: Realistic 6-month capture
   - WAJIB sertakan metodologi perhitungan
2. Competitor analysis (minimum 5 UI Kit competitors):
   - GetWidget, Shadcn Flutter, VelocityX, Flutter Starter Kit, CodeCanyon templates
   - Per kompetitor: pricing, component count, test coverage, last update, pub.dev score, GitHub stars
   - Jika target domain spesifik, cari juga UI Kit yang fokus domain tersebut
3. Market gaps (minimum 3):
   - Aesthetic yang kurang terwakili (misal: Tailwind/Vercel aesthetic di Flutter)
   - Quality standards yang hilang (test coverage, accessibility)
   - DX patterns yang diabaikan (single-import, zero-config theming)
4. Competitive advantages (minimum 4):
   - Stitch AI-generated design system
   - Quality gates (>85% test coverage, 100% null safety)
   - Jika domain-specific: "Satu-satunya UI Kit khusus [domain] di Flutter"
   - Modern aesthetic + pre-built themes
5. Market trends (minimum 3)

**Minimum Output:** TAM/SAM/SOM table, 5+ competitor matrix, SWOT, 3+ gaps, 3+ trends

**Output Format:**
```markdown
# Market Analysis - Flutter UI Kit [Edition Name]

## Executive Summary
[2-3 paragraphs: market opportunity, key findings, go/no-go recommendation]

## Market Size Estimation

### Methodology
[How numbers were derived — sources, assumptions]

### Market Sizing Table
| Segment | Size | Growth Rate | Source |
|---------|------|-------------|--------|
| Flutter Developers (Global) | ~5,000,000 | 20%/year | Google I/O + StackOverflow |
| Developers purchasing dev tools (4%) | ~200,000 | - | Industry benchmark |
| Target addressable (SE Asia focus) | ~60,000 | - | Regional dev density |
| Realistic 6-month capture | 200 paid | - | Conservative 0.3% |

## Competitor Deep-Dive (UI Kit Market)

| Competitor | Price | Components | Tests | Updated | pub.dev | Stars | Our Edge |
|------------|-------|------------|-------|---------|---------|-------|----------|
| GetWidget | Free/$49 | 1000+ | Unknown | ... | ... | ... | Better DX |
| Shadcn Flutter | Free | ~20 | Unknown | ... | ... | ... | More components |
| VelocityX | Free | ~50 | Low | ... | ... | ... | Quality gates |
| [minimum 5] | | | | | | | |

## Market Gaps
1. **[Gap]** — [Evidence, 3-5 sentences]
2. **[Gap]** — [Evidence]
3. **[Gap]** — [Evidence]

## SWOT Analysis
| Strengths | Weaknesses |
|-----------|------------|
| ... | ... |
| **Opportunities** | **Threats** |
| ... | ... |

## Competitive Advantages
1. **[Advantage]** — [Why it matters to developer buyers]

## Market Trends
1. **[Trend]** — [Impact on UI Kit market]
```

---

### 2. User Personas (Developer Buyers)

**Description:** Persona pembeli UI Kit — SELALU developers, bukan end-user app.

**Recommended Skills:** `user-researcher`, `product-manager`

**Instructions:**
1. Buat 2-3 persona developer:
   - **Persona 1 (Core):** Freelance Flutter Dev (SE Asia)
   - **Persona 2 (High-LTV):** CTO / Tech Lead startup
   - **Persona 3 (Volume):** Junior Dev / CS Student (opsional tapi direkomendasikan)
2. Jika ada target domain, persona harus mencerminkan dev yang bekerja di domain tersebut:
   - E-commerce domain → "Budi, freelancer yang sering bikin app e-commerce untuk client UMKM"
   - Fintech domain → "Ayu, developer di startup fintech yang butuh UI konsisten"
3. Pain points = masalah DEVELOPER (bukan end-user app):
   - Rebuild komponen setiap project ✅
   - UI tidak konsisten antar screen ✅
   - Susah belanja online ❌ (ini pain end-user, BUKAN developer)
4. JTBD, buying triggers, decision criteria, objections, channels

**Output Format:**
```markdown
# User Personas - Flutter UI Kit Buyers

## Persona 1: [Nama Lokal] — [Role]

### Profile Summary
[1-2 paragraphs vivid description — as a DEVELOPER building apps]

### Demographics
| Attribute | Detail |
|-----------|--------|
| Age | [range] |
| Location | [regions] |
| Income | [range] |
| Flutter Experience | [years] |
| Company | [type] |
| Projects per Month | [count] |
| Target App Domain | [domain, jika ada] |

### Jobs-to-be-Done (as a developer)
**Functional:** "Help me [developer task] faster"
**Emotional:** "I want to feel [developer emotion]"
**Social:** "I want clients/team to see me as [perception]"

### Pain Points (Developer Pains)
| Pain Point | Frequency | Severity | Current Workaround | UI Kit Solution |
|------------|-----------|----------|--------------------|----|
| Rebuilding buttons/inputs | Every project | 5 | Copy-paste old code | AppButton prebuilt |
| Client says "UI looks generic" | 60% projects | 4 | Hours customizing | Modern aesthetic |
| [minimum 5 rows] | | | | |

### Buying Triggers
1. [Specific dev scenario that triggers purchase]

### Decision Criteria (Ranked)
1. Price (< $50 for individual)
2. Visual quality of demo app
3. Component variety (15+)
4. Documentation quality

### Objections & Rebuttals
| Objection | Rebuttal |
|-----------|----------|
| "I can build this myself" | Time: 200+ hours vs $39 |

### Discovery Channels
- pub.dev, Twitter #FlutterDev, Reddit r/FlutterDev, YouTube

## Pain-to-Feature Mapping
| Developer Pain | UI Kit Feature | Priority |
|----------------|---------------|----------|
| Rebuild components | Pre-built library | P0 |
| Generic Material look | 8 color palettes | P0 |
```

---

### 3. Requirements Validation

**Description:** Validasi kebutuhan komponen dan fitur UI Kit.

**Recommended Skills:** `senior-system-analyst`, `product-manager`

**Instructions:**
1. Requirements = komponen UI Kit + theme system + docs + quality:
   - FR-1: Component Library (buttons, inputs, cards, navigation, feedback, data display)
   - FR-2: Theming System (light/dark, 8 palettes, custom config, design tokens)
   - FR-3: Documentation (dartdoc, example app, getting started guide)
   - FR-4: Quality (>85% test coverage, accessibility, performance)
2. Jika ada target domain, tambahkan domain-specific components ke P1:
   - E-commerce → ProductCard, CartItem, PriceTag, dll.
   - Fintech → BalanceCard, TransactionItem, PinInput, dll.
3. Prioritize P0/P1/P2 dengan User Value × Business Value
4. Non-functional: performance (<16ms rebuild), compatibility (SDK >=3.10), accessibility (WCAG 2.1 AA)
5. Dependencies: ZERO third-party di core package

**Output Format:**
```markdown
# Requirements Validation - Flutter UI Kit

## P0 - Critical (MVP)
| Req ID | Component/Feature | User Value | Business Value | Rationale |
|--------|-------------------|------------|----------------|-----------|
| FR-1.1 | AppButton (5 variants) | High | High | Most used component |
| [minimum 8 P0 requirements] | | | | |

## P1 - High (Core + Domain Components)
[Same format — include domain-specific components here if applicable]

## P2 - Enhanced
[Same format]

## Non-Functional Requirements
| Category | Requirement | Target | Validation |
|----------|-------------|--------|------------|
| Performance | Widget rebuild | <16ms | DevTools |
| Dependencies | Third-party in core | ZERO | pubspec review |

## Dependency Map
FR-2.2 (Tokens) → FR-2.1 (Themes) → FR-1.x (Components) → FR-3.2 (Example App)
```

---

### 4. Pricing Strategy

**Description:** Validasi pricing SELALU license-based (one-time purchase).

**Recommended Skills:** `product-strategist`, `pricing-analyst`

**Instructions:**
1. Competitor pricing (5+ OTHER UI Kits):
   - GetWidget, Shadcn, VelocityX, CodeCanyon kits, Tailwind UI (cross-reference)
2. 3 license tiers (SELALU format ini):
   - Individual ($39): 1 dev, unlimited projects
   - Team Pro ($99): up to 5 devs
   - Enterprise ($299): unlimited devs, 1 organization
3. Jika domain-specific edition, justifikasi premium:
   - "E-Commerce Edition: $49 (includes 6 domain-specific components)"
4. Launch discounts, revenue projections (6 bulan), upsell strategy

**Output Format:**
```markdown
# Pricing Strategy - Flutter UI Kit

## Competitor Pricing (UI Kit Market)
| Competitor | Price | Model | Components | Our Edge |
|------------|-------|-------|------------|----------|
| [5+ UI Kit competitors] | | | | |

## License Tiers
### Individual — $39
| Feature | Included |
|---------|----------|
| Full component library | ✅ |
| [full feature table] | |

### Team Pro — $99
[Same format]

### Enterprise — $299
[Same format]

## Launch Discount Strategy
| Code | Discount | Effective Price | Limit |
|------|----------|-----------------|-------|
| EARLYBIRD40 | 40% | $23/$59/$179 | First 50 |

## Revenue Projections (6 months)

### Conservative
| Month | Sales | Revenue | Cumulative |
|-------|-------|---------|------------|
| 1 | 20 | $780 | $780 |

### Optimistic
[Same table, higher numbers]

## Upsell Strategy
1. Individual → Team upgrade
2. Domain edition add-ons
3. Lifetime updates offer
```

---

## Workflow Steps

1. **Prompt Interpretation** — Parse 5 dimensi, isi gaps (instant)
2. **Market Research** — TAM/SAM/SOM Flutter dev market, 5+ UI Kit competitors (2-3 hari)
3. **User Research** — Developer personas, JTBD, pain points (2-3 hari)
4. **Requirements** — Component list + domain extras, NFR, priority matrix (1-2 hari)
5. **Pricing** — Competitor pricing, 3 tiers, revenue model (1-2 hari)
6. **Compilation** — 4 deliverable files + executive summaries (1 hari)

**Total:** 5-10 hari

## Success Criteria

### Quality Gates
- [ ] Produk = SELALU UI Kit (bukan app end-user)
- [ ] Kompetitor = sesama UI Kit (bukan Tokopedia/Shopee)
- [ ] Persona = developer buyers (bukan end-user app)
- [ ] Pricing = license-based (bukan subscription/freemium app)
- [ ] Market sizing = Flutter developer ecosystem
- [ ] Minimum 5 UI Kit competitors analyzed
- [ ] Minimum 2 developer personas (full JTBD)
- [ ] Each persona: 5+ developer pain points
- [ ] If domain-specific: domain components listed in P1
- [ ] Design language mapped to concrete tokens
- [ ] Revenue projections: conservative + optimistic
- [ ] All documents have executive summary

### Content Depth Minimums
| Deliverable | Min. Lines | Key Sections |
|-------------|------------|-------------|
| market-analysis.md | 150 | Exec Summary, TAM/SAM/SOM, 5+ UI Kit Competitors, SWOT, Gaps |
| user-personas.md | 150 | 2-3 Dev Personas (JTBD), Pain-to-Feature Map, Empathy Map |
| requirements-validation.md | 100 | P0/P1/P2 Component Tables, NFR, Domain Components (if applicable) |
| pricing-strategy.md | 150 | Competitor Pricing, 3 License Tiers, Revenue Projections |

---

## Cross-References

- **Next Phase** → `02_ui_ux_prototyping.md`
- **Component Priority** → `04_component_development.md`
- **Go-to-Market** → `05_gtm_launch.md`
- **Timeline** → `06_roadmap_execution.md`
- **Source PRD** → `../../docs/flutter-ui-kit/01_PRD.md`
- **Technical Spec** → `../../docs/flutter-ui-kit/02_TECHNICAL_SPEC.md`
- **Component Catalog** → `../../docs/flutter-ui-kit/03_COMPONENT_CATALOG.md`

---

## Workflow Validation Checklist

### Pre-Execution
- [ ] Prompt interpreted (5 dimensions: domain, style, scope, templates, platform)
- [ ] Output folder `flutter-ui-kit/01-prd-analysis/` created
- [ ] Confirmed: product = UI Kit, NOT end-user app

### During Execution
- [ ] All competitors are UI Kits/component libraries
- [ ] All personas are developers (not app end-users)
- [ ] Domain-specific components added to P1 (if applicable)
- [ ] Design style mapped to concrete tokens
- [ ] Pricing follows license tier model

### Post-Execution
- [ ] All 4 deliverable files at correct path
- [ ] Each file > minimum line count
- [ ] Cross-references correct
- [ ] Quality Gates passed

---
description: UI/UX Prototyping untuk Flutter UI Kit menggunakan Stitch AI. Menghasilkan high-fidelity screens dan DESIGN.md bahkan dari prompt sederhana.
---
# Workflow: UI/UX Prototyping - Flutter UI Kit

## Overview
Workflow ini menghasilkan high-fidelity UI prototypes dan mengekstrak Design System untuk produk **Flutter UI Kit** menggunakan **Stitch AI**. Output utamanya adalah `DESIGN.md` — kontrak desain yang akan ditranslasi ke Flutter `ThemeData`.

**CRITICAL:** Produk yang didesain SELALU berupa **UI Kit showcase app** — bukan app end-user. Jika user menyebut "e-commerce modern minimalis", artinya desain showcase app yang menampilkan komponen UI Kit bertema e-commerce dengan gaya modern minimalist.

## Output Location
**Base Folder:** `flutter-ui-kit/02-ui-ux-prototyping/`

**Output Files:**
- `user-flows-wireframes.md` - ASCII Wireframes dan User Flow (showcase app)
- `ui-prompts.md` - Stitch-enhanced prompts untuk screen generation
- `DESIGN.md` - Extracted Design System (Source of Truth untuk ThemeData)
- `component-anatomy.md` - Interaction notes, state machines, animation specs

## Prerequisites
- PRD Analysis selesai (`01_prd_analysis.md` → output di `01-prd-analysis/`)
- 5 dimensi UI Kit ter-extract dari Phase 1 (domain, gaya, scope, templates, platform)
- Access ke **Stitch AI MCP** tools dan skills

---

## Agent Behavior: Handling Simple Prompts

**GOLDEN RULE:** Agen TIDAK BOLEH bertanya "perlu detail apa?" sebelum mulai. Agen harus langsung menggunakan context dari Phase 1 (PRD Analysis) dan mengisi gap secara otomatis.

### Prinsip Utama: OUTPUT = SELALU UI KIT SHOWCASE APP

Semua screen yang didesain adalah untuk **showcase app** yang mendemonstrasikan komponen UI Kit — bukan app production end-user. Showcase app ini bertujuan:
1. Menampilkan semua komponen kit dalam konteks penggunaan nyata
2. Menjadi "selling point" visual di pub.dev, Gumroad, dan landing page
3. Memberikan developer contoh implementasi yang bisa dipelajari

### Prompt Interpretation: Dari Phase 1 ke Phase 2

Agen harus membawa context 5 dimensi dari Phase 1:

```
Phase 1 Output (5 Dimensi) → Phase 2 Input → Stitch Screens + DESIGN.md
```

#### Mapping Dimensi ke UI/UX Decisions

| Dimensi dari Phase 1 | Dampak ke Phase 2 |
|-----------------------|-------------------|
| **Target Domain** | Menentukan template screens dan komponen domain-specific yang ditampilkan |
| **Gaya Desain** | Menentukan color palette, typography, border radius, shadows di prompts |
| **Scope Kit** | Menentukan jumlah screen yang didesain (MVP: 5 screens, Full: 10+) |
| **Template Screens** | Screen template yang disertakan dalam showcase (Login, Dashboard, Settings) |
| **Platform** | Menentukan layout (mobile-first vs desktop-first) |

#### Contoh Interpretasi

**Dari Phase 1: "UI Kit bertema e-commerce modern minimalis"**

```yaml
# Screens showcase app yang harus didesain:
mandatory_screens:
  - Component Catalog: Grid semua komponen kit
  - Component Detail: Preview + code snippet + knobs
  - Theme Builder: Live color picker modifikasi tema

domain_template_screens:
  - E-Commerce Home: Menampilkan ProductCard, CategoryFilter, BannerCarousel
  - Product Detail: Menampilkan ImageGallery, PriceTag, AppButton variants
  - Shopping Cart: Menampilkan CartItem, QuantitySelector, PriceSummary

design_tokens_for_stitch:
  bg_primary: "#ffffff"
  bg_surface: "#f8fafc"
  accent: "#0ea5e9"  # sky-500
  text_primary: "#0f172a"
  font: "Inter, 400/500/600"
  radius: "12px"
  shadow: "0 1px 3px rgba(0,0,0,0.1)"
```

**Dari Phase 1: "UI Kit bertema fintech dark premium"**

```yaml
mandatory_screens:
  - Component Catalog
  - Component Detail
  - Theme Builder

domain_template_screens:
  - Wallet Dashboard: BalanceCard, TransactionList, ChartWidget
  - Transfer Screen: TransferForm, PinInput, ContactList
  - Transaction History: TransactionItem filters, DatePicker

design_tokens_for_stitch:
  bg_primary: "#0f172a"  # dark slate
  bg_surface: "#1e293b"
  accent: "#06b6d4"  # cyan
  text_primary: "#f1f5f9"
  font: "Inter, 300/500/700"
  radius: "8px"
  shadow: "0 0 20px rgba(6,182,212,0.15)"  # glow effect
```

**Dari Phase 1: "General purpose UI Kit" (default)**

```yaml
mandatory_screens:
  - Component Catalog
  - Component Detail
  - Theme Builder

domain_template_screens:
  - Login/Register: AppTextField, AppButton, SocialLoginButton
  - Dashboard Analytics: StatCard, ChartWidget, DataTable
  - Settings Page: AppSwitch, AppDropdown, AppRadio, SectionHeader

design_tokens_for_stitch:
  bg_primary: "#ffffff"
  accent: "#3b82f6"  # blue-500
  font: "Inter"
  radius: "12px"
```

---

## Deliverables

### 1. ASCII Wireframing & User Flows

**Description:** Wireframe text-based untuk showcase app UI Kit — memvalidasi layout dan navigasi sebelum generate high-fidelity di Stitch.

**Recommended Skills:** `senior-ui-ux-designer`

**Instructions:**
1. Map user journeys dari perspektif **developer yang menjelajahi kit**:
   - Onboarding → Component Browse → Component Detail → Copy Code
   - Theme Switching → Live Preview → Download/Purchase
   - Template Browse → Template Preview → Customize
2. Desain ASCII wireframes untuk SEMUA mandatory screens + domain template screens
3. Setiap wireframe harus menunjukkan komponen UI Kit mana yang digunakan

**Mandatory Screens (SELALU ada):**

| # | Screen | Purpose | Komponen Kit yang Ditampilkan |
|---|--------|---------|-------------------------------|
| 1 | **Component Catalog** | Grid/list semua komponen kit | AppCard, AppChip (category filter), Search |
| 2 | **Component Detail** | Preview + code + property knobs | TabBar, CodeBlock, PropertyEditor |
| 3 | **Theme Builder** | Live color/font picker → preview realtime | ColorPicker, AppSlider, PreviewPanel |

**Domain Template Screens (berdasarkan target domain dari Phase 1):**

| Target Domain | Template Screens | Komponen yang Di-showcase |
|---------------|-----------------|--------------------------|
| E-Commerce | Home Feed, Product Detail, Cart | ProductCard, CartItem, PriceTag, CategoryFilter |
| Fintech | Wallet Dashboard, Transfer, History | BalanceCard, TransactionItem, PinInput, ChartWidget |
| Social Media | Feed, Profile, Stories | PostCard, StoryAvatar, CommentThread, MediaGrid |
| Dashboard/SaaS | Analytics, User Management | DataTable, StatCard, SidebarNav, FilterBar |
| General Purpose | Login, Dashboard, Settings | AppTextField, StatCard, AppSwitch, AppDropdown |

**ASCII Notation Reference:**

| Symbol | Element | Example |
|--------|---------|---------|
| `┌─┐│└┘` | Container/border | `┌─────┐` |
| `[Text]` | Button/CTA | `[Submit]` |
| `(____)` | Text input | `(Email)` |
| `☐` / `☑` | Checkbox | `☐ Agree` |
| `◉` / `○` | Radio | `◉ Option A` |
| `>>>` | Link/Navigation | `>>> Details` |
| `===` | Divider | `=== OR ===` |
| `{COMPONENT}` | UI Kit component | `{AppButton.primary}` |

**Example ASCII Wireframe (Component Catalog):**
```text
┌──────────────────────────────────────────────────────────────┐
│ [Logo] UI Kit Showcase    Components  Templates  Themes   👤 │
├──────────────────────────────────────────────────────────────┤
│                                                              │
│  🔍 (Search components...)                                   │
│                                                              │
│  {AppChip} All  Inputs  Buttons  Cards  Navigation  Feedback │
│                                                              │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐          │
│  │ 📦           │  │ 📦           │  │ 📦           │          │
│  │ {AppButton}  │  │ {AppCard}    │  │ {AppTextField}│         │
│  │              │  │              │  │              │          │
│  │ 5 variants   │  │ 3 variants   │  │ 4 variants   │          │
│  │ [View >>>]   │  │ [View >>>]   │  │ [View >>>]   │          │
│  └─────────────┘  └─────────────┘  └─────────────┘          │
│                                                              │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐          │
│  │ 📦           │  │ 📦           │  │ 📦           │          │
│  │ {AppSwitch}  │  │ {AppDialog}  │  │ {AppAvatar}  │          │
│  │ 2 variants   │  │ 3 variants   │  │ 4 variants   │          │
│  │ [View >>>]   │  │ [View >>>]   │  │ [View >>>]   │          │
│  └─────────────┘  └─────────────┘  └─────────────┘          │
│                                                              │
│  Showing 13 of 30+ components                    Page 1 of 3 │
└──────────────────────────────────────────────────────────────┘
```

**Example ASCII Wireframe (Component Detail):**
```text
┌──────────────────────────────────────────────────────────────┐
│  ← Back to Catalog         AppButton                         │
├──────────────────────────────────────────────────────────────┤
│                                                              │
│  ┌── Preview ──────────────────────────────────────────────┐ │
│  │                                                          │ │
│  │  {AppButton.primary}  {AppButton.secondary}              │ │
│  │  {AppButton.outline}  {AppButton.ghost}                  │ │
│  │  {AppButton.destructive}                                 │ │
│  │                                                          │ │
│  │  {AppButton.small}  {AppButton.medium}  {AppButton.large}│ │
│  │                                                          │ │
│  └──────────────────────────────────────────────────────────┘ │
│                                                              │
│  ┌── Properties (Knobs) ───────────────────────────────────┐ │
│  │ Variant:  ◉ Primary ○ Secondary ○ Outline ○ Ghost       │ │
│  │ Size:     ○ Small ◉ Medium ○ Large                      │ │
│  │ Disabled: ☐                                              │ │
│  │ Loading:  ☐                                              │ │
│  │ Icon:     (None ▼)                                       │ │
│  └──────────────────────────────────────────────────────────┘ │
│                                                              │
│  ┌── Code ─────────────────────────────────────────────────┐ │
│  │ ```dart                                                  │ │
│  │ AppButton(                                               │ │
│  │   label: 'Submit',                                       │ │
│  │   variant: AppButtonVariant.primary,                     │ │
│  │   size: AppButtonSize.medium,                            │ │
│  │   onPressed: () {},                                      │ │
│  │ )                                                        │ │
│  │ ```                                                      │ │
│  │                                        [📋 Copy Code]    │ │
│  └──────────────────────────────────────────────────────────┘ │
└──────────────────────────────────────────────────────────────┘
```

**Minimum Output:** ASCII wireframes untuk 3 mandatory screens + 2-3 domain template screens.

---

### 2. UI Prompt Engineering (Stitch-Enhanced)

**Description:** Transform wireframes menjadi Stitch-optimized prompts untuk generate high-fidelity screens.

**Recommended Skills:** `senior-ui-ux-designer`, `stitch-enhance-prompt`

**Instructions:**
1. Untuk setiap screen, tulis deskripsi teks dasar berdasarkan ASCII wireframe
2. Gunakan skill `stitch-enhance-prompt` untuk mengubah deskripsi menjadi structured prompt:
   - Sertakan DESIGN SYSTEM section (warna, font, radius dari Phase 1 gaya_desain)
   - Sertakan PAGE STRUCTURE section (layout detail per section)
   - Sertakan COMPONENT DETAILS section (variasi dan state)
3. Simpan semua enhanced prompts ke `ui-prompts.md`

**Prompt Template (wajib mengikuti format ini):**
```markdown
## Screen: [Screen Name]

### Basic Description
[1-2 kalimat tujuan screen — dalam konteks UI KIT showcase]

### Enhanced Prompt (untuk Stitch)
A [mood/aesthetic] showcase screen for a Flutter UI Kit [edition name].
This screen demonstrates [komponen yang ditampilkan] in a [domain] context.

**DESIGN SYSTEM (REQUIRED):**
- Platform: [Mobile / Web / Desktop-first]
- Theme: [Light/Dark], [mood descriptor]
- Background: [hex code] — [color name]
- Surface: [hex code] — for cards/panels
- Primary Accent: [hex code] — [color name]
- Text Primary: [hex code]
- Typography: [font family], [weights]
- Border Radius: [value]
- Shadow: [description]

**PAGE STRUCTURE:**
1. **[Section Name]:** [Layout description, komponen yang dipakai]
2. **[Section Name]:** [Layout description]
3. ...

**COMPONENT SHOWCASE:**
- {AppButton}: Show primary, secondary, outline, ghost variants side by side
- {AppCard}: Show default and image variants
- ...

**UI KIT CONTEXT:**
- This is a SHOWCASE/DEMO screen, not a production app
- Components should look polished and demonstrate versatility
- Include realistic sample data (product names, prices, avatars)
```

**Minimum Output:** Enhanced prompts untuk setiap screen yang di-wireframe (5-8 screens minimum).

---

### 3. High-Fidelity Prototyping (Stitch Generation)

**Description:** Generate actual UI screens dari enhanced prompts menggunakan Stitch AI tools.

**Recommended Tools:** `mcp_stitch_generate_screen_from_text`, `mcp_stitch_edit_screens`, `mcp_stitch_generate_variants`

**Instructions:**
1. Buat Stitch project baru dengan `mcp_stitch_create_project`:
   - Title: "Flutter UI Kit — [Edition Name] Showcase"
2. Generate setiap screen dari enhanced prompts:
   - Gunakan `mcp_stitch_generate_screen_from_text` untuk setiap prompt
   - Set `deviceType` sesuai platform target (MOBILE / DESKTOP)
3. Review dan iterasi:
   - Jika perlu adjustment, gunakan `mcp_stitch_edit_screens` dengan feedback spesifik
   - Contoh: "Buat tombol pill-shaped dan naikkan padding card dari 12px ke 16px"
4. Generate variants untuk light/dark mode:
   - Gunakan `mcp_stitch_generate_variants` untuk buat versi dark/light
5. Pastikan semua P0 components terrepresentasi di minimal 1 screen

**Stitch Workflow Sequence:**
```
1. create_project("Flutter UI Kit Showcase")
   ↓
2. generate_screen(prompt_component_catalog)
   ↓
3. generate_screen(prompt_component_detail)
   ↓
4. generate_screen(prompt_theme_builder)
   ↓
5. generate_screen(prompt_domain_template_1)
   ↓
6. generate_screen(prompt_domain_template_2)
   ↓
7. edit_screens(refinement_feedback) — jika perlu
   ↓
8. generate_variants(dark_mode) — untuk dark mode versions
```

**Quality Check per Screen:**
- [ ] Semua komponen UI Kit terlihat jelas dan bisa diidentifikasi
- [ ] Warna sesuai dengan design tokens dari gaya_desain
- [ ] Typography konsisten (font family, weights, sizes)
- [ ] Border radius konsisten di semua elements
- [ ] Realistic sample data (bukan "Lorem ipsum")
- [ ] Responsive layout sesuai platform target

---

### 4. Design System Extraction (DESIGN.md)

**Description:** Extract Design System dari Stitch prototypes menjadi `DESIGN.md` — kontrak absolut untuk Flutter `ThemeData`.

**Recommended Skills:** `stitch-design-md`

**Instructions:**
1. Setelah screens difinalisasi, invoke `stitch-design-md` skill
2. Command: "Analyze Stitch project [Project ID] and generate DESIGN.md"
3. Review output untuk memastikan semua token tercapture:

**DESIGN.md Harus Berisi (Minimum):**

| Section | Content | Format |
|---------|---------|--------|
| **Colors** | Primary, Secondary, Surface, Error, Semantic colors | Hex codes + Flutter Color() |
| **Typography** | Display, H1-H6, Body, Caption scales | Font family, size, weight, line height |
| **Spacing** | Base unit (4px/8px), padding/margin scale | Multiplier system (xs=4, sm=8, md=16...) |
| **Border Radius** | Component-specific radius values | px values + mapping to Flutter |
| **Shadows/Elevation** | Elevation levels (0-5) | BoxShadow specs |
| **Dark Mode** | All color tokens inverted | Separate dark palette |
| **Breakpoints** | Mobile/Tablet/Desktop thresholds | Width values |

**Output Format:**
```markdown
# DESIGN.md — Flutter UI Kit Design System

## Source of Truth
Generated from Stitch Project: [Project ID]
Date: [generated date]
Edition: [General / E-Commerce / Fintech / ...]
Style: [Modern Minimalist / Dark Premium / ...]

---

## Color Palette

### Light Theme
| Token | Hex | Flutter | Usage |
|-------|-----|---------|-------|
| primary | #3b82f6 | Color(0xFF3B82F6) | Primary actions, links |
| onPrimary | #ffffff | Colors.white | Text on primary |
| secondary | #64748b | Color(0xFF64748B) | Secondary actions |
| surface | #f8fafc | Color(0xFFF8FAFC) | Card backgrounds |
| background | #ffffff | Colors.white | Page background |
| error | #ef4444 | Color(0xFFEF4444) | Error states |
| success | #22c55e | Color(0xFF22C55E) | Success states |
| warning | #f59e0b | Color(0xFFF59E0B) | Warning states |

### Dark Theme
| Token | Hex | Flutter | Usage |
|-------|-----|---------|-------|
| primary | #60a5fa | Color(0xFF60A5FA) | Brighter for dark bg |
| surface | #1e293b | Color(0xFF1E293B) | Card backgrounds |
| background | #0f172a | Color(0xFF0F172A) | Page background |
| ...dst | | | |

## Typography Scale
| Token | Font | Size | Weight | Line Height | Letter Spacing |
|-------|------|------|--------|-------------|----------------|
| displayLarge | Inter | 36px | 700 | 1.2 | -0.5 |
| headlineLarge | Inter | 28px | 600 | 1.3 | -0.25 |
| titleLarge | Inter | 22px | 600 | 1.3 | 0 |
| bodyLarge | Inter | 16px | 400 | 1.5 | 0.15 |
| bodyMedium | Inter | 14px | 400 | 1.5 | 0.25 |
| labelLarge | Inter | 14px | 500 | 1.4 | 0.1 |
| captionSmall | Inter | 12px | 400 | 1.4 | 0.4 |

## Spacing System (Base: 4px)
| Token | Value | Usage |
|-------|-------|-------|
| xs | 4px | Tight gaps, icon padding |
| sm | 8px | Chip padding, small gaps |
| md | 16px | Card padding, section gaps |
| lg | 24px | Section spacing |
| xl | 32px | Page margins |
| 2xl | 48px | Large sections |

## Border Radius
| Token | Value | Usage |
|-------|-------|-------|
| none | 0px | Sharp elements |
| sm | 4px | Small chips, badges |
| md | 8px | Buttons, inputs |
| lg | 12px | Cards, panels |
| xl | 16px | Large cards, modals |
| full | 9999px | Pill buttons, avatars |

## Elevation / Shadows
| Level | BoxShadow | Usage |
|-------|-----------|-------|
| 0 | none | Flat elements |
| 1 | 0 1px 2px rgba(0,0,0,0.05) | Subtle cards |
| 2 | 0 1px 3px rgba(0,0,0,0.1), 0 1px 2px rgba(0,0,0,0.06) | Elevated cards |
| 3 | 0 4px 6px rgba(0,0,0,0.1) | Dropdowns, popovers |
| 4 | 0 10px 15px rgba(0,0,0,0.1) | Modals, dialogs |
```

**CRITICAL:** `DESIGN.md` adalah kontrak ABSOLUT. Semua nilai di sini HARUS di-implementasi persis di Flutter `ThemeData` pada Phase 3. Tidak boleh ada deviasi tanpa mengupdate file ini terlebih dahulu.

---

### 5. Component Anatomy & Interaction Notes

**Description:** Dokumentasi interaction states, animation specs, dan state machines — hal yang tidak bisa disampaikan oleh desain statis.

**Recommended Skills:** `senior-ui-ux-designer`

**Instructions:**
1. Untuk setiap P0 component, dokumentasi:
   - State machine (Default → Hover → Pressed → Disabled → Loading)
   - Animation curves dan durations
   - Accessibility notes (focus ring, screen reader labels)
2. Untuk complex components, buat Mermaid state diagram
3. Dokumentasi micro-interactions dan transitions

**P0 Components yang WAJIB didokumentasi state-nya:**

| Component | States yang Harus Didefinisikan |
|-----------|-------------------------------|
| AppButton | Default, Hover, Pressed, Disabled, Loading |
| AppTextField | Empty, Focused, Filled, Error, Disabled |
| AppCheckbox | Unchecked, Checked, Indeterminate, Disabled |
| AppSwitch | Off, On, Disabled |
| AppDropdown | Closed, Open, Selected, Error |
| AppDialog | Closed, Opening (animation), Open, Closing |
| AppSnackBar | Hidden, Entering, Visible, Exiting |

**Output Format:**
```markdown
# Component Anatomy & Interaction Notes

## AppButton

### State Machine
```mermaid
stateDiagram-v2
    [*] --> Default
    Default: Elevation 0, Bg Primary

    Default --> Hover: Mouse Enter
    Hover: Elev 2, Brightness +5%
    Hover --> Default: Mouse Leave

    Default --> Pressed: Tap Down
    Hover --> Pressed: Tap Down
    Pressed: Elev 0, Scale 0.98, Brightness -10%
    Pressed --> Default: Tap Up

    Default --> Disabled: isEnabled = false
    Disabled: Bg Muted Gray, Opacity 0.5
    Disabled --> Default: isEnabled = true

    Default --> Loading: isLoading = true
    Loading: Show CircularProgressIndicator, Disable tap
    Loading --> Default: isLoading = false
```

### Animation Specs
| Transition | Curve | Duration | Property |
|------------|-------|----------|----------|
| Default → Hover | Curves.easeInOut | 200ms | color, elevation |
| Default → Pressed | Curves.easeOut | 100ms | scale, color |
| Hover → Pressed | Curves.easeOut | 80ms | scale |
| Appear | Curves.easeOutCubic | 300ms | opacity, scale |

### Accessibility
- Focus ring: 2px solid primary, offset 2px
- Semantic label: "[label] button"
- Announce state changes: "Loading", "Disabled"

---
## AppTextField
[Same structure for each P0 component]
```

**Minimum Output:** State machines + animation specs untuk minimal 7 P0 components.

---

## Workflow Steps

1. **Context Import** — Bawa 5 dimensi dari Phase 1 (domain, gaya, scope, templates, platform). Instant.
2. **ASCII Wireframing** — Wireframe 5-8 screens (3 mandatory + 2-5 domain templates). 1-2 hari.
3. **Prompt Engineering** — Enhance setiap wireframe ke Stitch prompt via `stitch-enhance-prompt`. 1 hari.
4. **Stitch Generation** — Generate screens via `mcp_stitch_generate_screen_from_text`. 1-2 hari.
5. **Design Extraction** — Extract DESIGN.md via `stitch-design-md`. 0.5 hari.
6. **Interaction Notes** — Document states + animations untuk P0 components. 1 hari.

**Total:** 3-5 hari

## Success Criteria

### Quality Gates
- [ ] Produk = UI Kit showcase app (BUKAN app end-user production)
- [ ] Semua 3 mandatory screens di-wireframe dan di-generate (Catalog, Detail, Theme Builder)
- [ ] Domain template screens sesuai target domain dari Phase 1
- [ ] Design tokens di prompts sesuai gaya_desain dari Phase 1
- [ ] `DESIGN.md` berisi SEMUA sections: Colors, Typography, Spacing, Radius, Shadows, Dark Mode
- [ ] Semua hex codes di DESIGN.md sudah di-convert ke Flutter `Color()` format
- [ ] P0 components (7 minimum) punya state machine + animation specs
- [ ] Stitch screens menampilkan realistic sample data (bukan placeholder)
- [ ] Dark mode variant tersedia
- [ ] Executive summary / context header ada di setiap output file

### Content Depth Minimums

| Deliverable | Min. Lines | Key Sections |
|-------------|------------|-------------|
| user-flows-wireframes.md | 150 | User flow diagrams, 5-8 ASCII wireframes |
| ui-prompts.md | 100 | 5-8 enhanced prompts (design system + structure per screen) |
| DESIGN.md | 150 | Colors (light+dark), Typography, Spacing, Radius, Shadows |
| component-anatomy.md | 100 | 7+ P0 component state machines, animation specs |

---

## Cross-References

- **Previous Phase** → `01_prd_analysis.md`
- **Next Phase** → `03_technical_implementation.md` (translates DESIGN.md → ThemeData)
- **Component Priority** → `04_component_development.md`
- **Source PRD** → `../../docs/flutter-ui-kit/01_PRD.md`
- **Technical Spec** → `../../docs/flutter-ui-kit/02_TECHNICAL_SPEC.md`

---

## Workflow Validation Checklist

### Pre-Execution
- [ ] 5 dimensi UI Kit dari Phase 1 tersedia (domain, gaya, scope, templates, platform)
- [ ] Output folder `flutter-ui-kit/02-ui-ux-prototyping/` dibuat
- [ ] Stitch AI MCP tools accessible

### During Execution
- [ ] ASCII wireframes menunjukkan komponen UI Kit (bukan generic app wireframe)
- [ ] Prompts include DESIGN SYSTEM section dengan hex codes
- [ ] Stitch screens consistent secara visual
- [ ] DESIGN.md sedang di-extract dari screens

### Post-Execution
- [ ] All 4 deliverable files di correct path
- [ ] DESIGN.md berisi token lengkap (colors, typography, spacing, radius, shadows)
- [ ] Component states didokumentasi untuk semua P0 components
- [ ] Files siap di-consume oleh Phase 3 (Technical Implementation)
- [ ] Quality Gates checklist passed

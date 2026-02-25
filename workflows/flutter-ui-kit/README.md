# Flutter UI Kit Workflows

Workflows untuk membuat Flutter UI Kit commercial product mengikuti dokumentasi di `docs/flutter-ui-kit/`. Setiap workflow menghasilkan deliverables yang siap digunakan untuk development dan launch.

## System Requirements

- Agent dengan skill yang sesuai per fase (lihat tabel di bawah)
- Flutter SDK >=3.10.0
- Development environment (VS Code / Android Studio)
- GitHub account untuk repository dan CI/CD

## Struktur Workflows

```
workflows/flutter-ui-kit/
├── 01_prd_analysis.md              # Analisis PRD, market, user personas, pricing
├── 02_ui_ux_prototyping.md         # UI/UX prototyping dengan Stitch & DESIGN.md
├── 03_technical_implementation.md  # Package structure, design tokens, theme system
├── 04_component_development.md     # Component development dengan priority (P0-P3)
├── 05_gtm_launch.md                # Go-to-Market strategy dan launch execution
├── 06_roadmap_execution.md         # Sprint planning, milestone tracking, risk management
└── README.md                       # Dokumentasi ini
```

## Output Folder Structure

```
flutter-ui-kit/
├── 01-prd-analysis/
│   ├── market-analysis.md
│   ├── user-personas.md
│   ├── requirements-validation.md
│   └── pricing-strategy.md
│
├── 02-technical-implementation/
│   ├── package-structure.md
│   ├── design-tokens.md
│   ├── theme-system.md
│   ├── component-api-spec.md
│   └── testing-strategy.md
│
├── 03-component-development/
│   ├── mvp-components.md
│   ├── core-components.md
│   ├── enhanced-components.md
│   └── component-checklist.md
│
├── 04-gtm-launch/
│   ├── distribution-channels.md
│   ├── launch-timeline.md
│   ├── marketing-content.md
│   ├── sales-funnel.md
│   └── metrics-tracking.md
│
├── 05-roadmap-execution/
│   ├── sprint-plan.md
│   ├── milestone-tracking.md
│   ├── resource-management.md
│   ├── risk-register.md
│   └── progress-reports.md
│
└── 02-ui-ux-prototyping/
    ├── user-flows-wireframes.md
    ├── ui-prompts.md
    ├── DESIGN.md
    └── component-anatomy.md
```

## Urutan Penggunaan

### Sequential (Proyek Baru)

```
01 PRD Analysis
    ↓
02 UI/UX Prototyping
    ↓
03 Technical Implementation
    ↓
04 Component Development
    ↓
05 Go-to-Market Launch  ← dapat paralel dengan 04 (minggu 7-8)
    ↓
06 Roadmap Execution  ← berjalan sepanjang proyek
```

### Timeline Overview

```
Week 1-2:  Foundation
    │
    ├── 01 PRD Analysis ✅
    ├── 02 UI/UX Prototyping ✅
    └── 03 Technical Implementation ✅
            │
Week 3-4:  MVP Part 1 (Core Components)
    │
    └── 04 Component Development (P0) 🔄
            │
Week 5-6:  MVP Part 2 (Enhanced Components)
    │
    └── 04 Component Development (P1) ⏳
            │
Week 7:    Polish & Documentation
    │
    ├── 04 Component Development (final) ⏳
    └── 05 GTM Launch (preparation) ⏳
            │
Week 8:    LAUNCH 🚀
    │
    ├── 05 GTM Launch (execution) ⏳
    └── 06 Roadmap Execution (ongoing) 🔄
```

## Skills Quick-Reference

| Workflow | Agent Skills |
|----------|-------------|
| 01 PRD Analysis | `market-researcher`, `product-strategist`, `user-researcher`, `product-manager` |
| 02 UI/UX Prototyping | `senior-ui-ux-designer`, `stitch-enhance-prompt`, `stitch-design-md`, `interaction-designer` |
| 03 Technical Implementation | `senior-flutter-developer`, `package-architect`, `design-system-engineer`, `api-design-specialist` |
| 04 Component Development | `senior-flutter-developer`, `component-specialist`, `navigation-specialist`, `flutter-testing-specialist` |
| 05 GTM Launch | `product-marketer`, `channel-manager`, `campaign-manager`, `content-marketer`, `growth-hacker` |
| 06 Roadmap Execution | `project-manager`, `scrum-master`, `resource-manager`, `risk-manager` |

## Workflow Details

### 01 PRD Analysis

**Purpose:** Analisis dan validasi Product Requirements Document

**Input:** PRD draft dari `docs/flutter-ui-kit/01_PRD.md`

**Output:**
- Market analysis dengan competitor research
- User personas yang divalidasi
- Requirements yang diprioritaskan
- Pricing strategy yang validated

**Duration:** 5-7 days

**Success Criteria:**
- Market analysis validated with data sources
- User personas based on real interviews (15+ users)
- Requirements prioritized with MoSCoW method
- Pricing strategy supported by research

---

### 02 UI/UX Prototyping

**Purpose:** Generate high-fidelity UI prototypes dan ekstrak Design System menggunakan Stitch AI

**Input:** PRD requirements, component catalog

**Output:**
- User flow & ASCII Wireframes (`user-flows-wireframes.md`)
- UI Prompts (`ui-prompts.md`)
- High-fidelity screens (Stitch output)
- Design System Source of Truth (`DESIGN.md`)
- Interaction annotations (`component-anatomy.md`)


**Duration:** 3-5 days

**Recommended Skills:** `senior-ui-ux-designer`, `stitch-enhance-prompt`, `stitch-design-md`

**Success Criteria:**
- All key screens wireframed (desktop + mobile)
- User flows documented for all major journeys
- Component layouts show all variants/states
- Interaction annotations clear and actionable

---

### 03 Technical Implementation

**Purpose:** Setup technical foundation untuk Flutter UI Kit package

**Input:** Technical spec dari `docs/flutter-ui-kit/02_TECHNICAL_SPEC.md`

**Output:**
- Package structure yang follow Flutter best practices
- Design tokens (8 color palettes, typography, spacing, etc.)
- Theme system dengan 16+ pre-built themes
- Component API specifications
- Testing strategy dengan >85% coverage target

**Duration:** 7-10 days

**Success Criteria:**
- All design tokens implemented and tested
- Theme system supports 16+ themes
- Component APIs documented with dartdoc
- Test infrastructure setup with CI/CD

---

### 04 Component Development

**Purpose:** Systematic development of UI components

**Input:** Component catalog dari `docs/flutter-ui-kit/03_COMPONENT_CATALOG.md`

**Output:**
- MVP: 13 components (Week 1-4)
- Core: 20+ components (Week 5-8)
- Enhanced: 15+ components (Month 3)
- Component checklist dan quality gates

**Duration:** 8 weeks (MVP), 12 weeks (full)

**Component Priority:**
| Priority | Components | Timeline |
|----------|------------|----------|
| P0 (Critical) | 13 | Week 1-4 |
| P1 (High) | 20 | Week 5-8 |
| P2 (Medium) | 15+ | Month 3 |
| P3 (Future) | 8+ | Month 4+ |

**Success Criteria:**
- MVP: 13 components dengan >85% test coverage
- All components pass accessibility checks
- Demo app showcases all components
- Documentation complete

---

### 05 GTM Launch

**Purpose:** Launch dan marketing execution

**Input:** GTM strategy dari `docs/flutter-ui-kit/04_GTM_STRATEGY.md`

**Output:**
- Distribution channels setup (pub.dev, Gumroad, GitHub, landing page)
- Launch week execution (Product Hunt, social media, community)
- Marketing content calendar
- Sales funnel optimization
- Metrics tracking dashboard

**Duration:** 2 weeks prep + ongoing

**Launch Timeline:**
```
Pre-Launch (Week 6-7):
├── Foundation setup
├── Hype building
└── Waitlist creation

Launch Week (Week 8):
├── Day 1: Product Hunt
├── Day 2: Storytelling
├── Day 3: Demo Day
├── Day 4: Community
└── Day 5: Wrap-up

Post-Launch (Week 9+):
├── Momentum maintenance
├── Content creation
└── Growth initiatives
```

**Success Criteria:**
- Launch week: 50+ sales, 500+ Product Hunt upvotes
- Month 1: $780 MRR, 20 customers
- Month 6: $5,000 MRR, 200 customers

---

### 06 Roadmap Execution

**Purpose:** Project execution dan tracking

**Input:** Roadmap dari `docs/flutter-ui-kit/05_ROADMAP.md`

**Output:**
- Weekly sprint plans
- Milestone tracking (5 milestones)
- Resource management (time, budget, tools)
- Risk register
- Progress reports

**Duration:** 8 weeks (MVP)

**Milestones:**
| Milestone | Week | Deliverables |
|-----------|------|--------------|
| M1: Foundation | Week 2 | Design tokens, theme system |
| M2: Core Components | Week 4 | 9 MVP components |
| M3: Enhanced | Week 6 | 20+ additional components |
| M4: Polish & Docs | Week 7 | Tests, documentation |
| M5: Launch Ready | Week 8 | Published, live, first sales |

**Success Criteria:**
- All milestones achieved on time
- Sprint goals met 80%+ of weeks
- Budget within 10% of plan
- Product launched by Week 8

---

## Project Timeline Summary

```
┌─────────────────────────────────────────────────────────────────┐
│  WEEK 1-2: FOUNDATION                                           │
│  ├── 01 PRD Analysis ✅                                         │
│  ├── 02 UI/UX Prototyping ✅                                      │
│  └── 03 Technical Implementation ✅                             │
├─────────────────────────────────────────────────────────────────┤
│  WEEK 3-4: MVP PART 1                                           │
│  └── 04 Component Development (P0 components) 🔄               │
├─────────────────────────────────────────────────────────────────┤
│  WEEK 5-6: MVP PART 2                                           │
│  └── 04 Component Development (P1 components) ⏳               │
├─────────────────────────────────────────────────────────────────┤
│  WEEK 7: POLISH                                                 │
│  ├── 04 Component Development (final) ⏳                       │
│  └── 05 GTM Launch (prep) ⏳                                    │
├─────────────────────────────────────────────────────────────────┤
│  WEEK 8: LAUNCH 🚀                                              │
│  ├── 05 GTM Launch (execution) ⏳                               │
│  └── 06 Roadmap Execution (ongoing) 🔄                         │
└─────────────────────────────────────────────────────────────────┘
```

---

## Resource Requirements

### Time Commitment

| Role | Week 1-2 | Week 3-4 | Week 5-6 | Week 7-8 | Total |
|------|----------|----------|----------|----------|-------|
| Senior Flutter Dev | 80h | 80h | 80h | 80h | 320h |
| Design System Eng | 80h | 40h | 20h | 20h | 160h |
| Project Manager | 20h | 20h | 20h | 40h | 100h |
| Product Marketer | 0h | 0h | 20h | 80h | 100h |
| **Total** | **180h** | **140h** | **140h** | **220h** | **680h** |

### Budget

| Category | Amount |
|----------|--------|
| One-time costs | $240 |
| 6-month recurring | $420 |
| Platform fees (10% of sales) | ~$1,365 |
| **Total** | **~$2,025** |

### Tools

**Free:**
- Flutter SDK
- VS Code / Android Studio
- Git & GitHub
- Figma (free tier)

**Paid:**
- Vercel Pro: $20/month
- Email Marketing: $30/month
- Analytics: $9/month

---

## Related Documentation

| Document | Location |
|----------|----------|
| PRD | `../../docs/flutter-ui-kit/01_PRD.md` |
| Technical Spec | `../../docs/flutter-ui-kit/02_TECHNICAL_SPEC.md` |
| Component Catalog | `../../docs/flutter-ui-kit/03_COMPONENT_CATALOG.md` |
| GTM Strategy | `../../docs/flutter-ui-kit/04_GTM_STRATEGY.md` |
| Roadmap | `../../docs/flutter-ui-kit/05_ROADMAP.md` |

## Example Agent Prompts

### PRD Analysis
```
"Jalankan workflow 01_prd_analysis.md untuk Flutter UI Kit commercial product.
Target market: freelance developers di Indonesia dan Southeast Asia.
Budget: $39-299. Goal: $5,000 MRR dalam 6 bulan."
```

### UI/UX Prototyping
```
"Gunakan workflow `02_ui_ux_prototyping.md` untuk menghasilkan UI prototypes.
1. Buat ASCII wireframes dan user flows untuk Dashboard dan Component Browse.
2. Enhance prompt dengan `stitch-enhance-prompt` berdasarkan wireframe tersebut.
3. Generate high-fidelity screens dengan `mcp_stitch_generate_screen`.
4. Ekstrak warna dan tipografi menjadi `DESIGN.md` menggunakan `stitch-design-md`."
```

### Technical Implementation
```
"Gunakan workflow 03_technical_implementation.md untuk setup Flutter UI Kit
package dengan 8 color palettes, 16 pre-built themes, dan component API
specifications. Target: >85% test coverage."
```

### Component Development
```
"Jalankan workflow 04_component_development.md untuk MVP phase (Week 1-4).
Implement 13 P0 components: AppButton, AppTextField, AppCheckbox, AppRadio,
AppSwitch, AppDropdown, AppCard, AppImageCard, AppSnackBar, AppDialog,
AppLoadingIndicator, AppAvatar, AppChip. Include demo app screens."
```

### GTM Launch
```
"Gunakan workflow 05_gtm_launch.md untuk launch week preparation. Setup
distribution channels (pub.dev, Gumroad, GitHub, landing page), create
launch timeline untuk Week 8, dan prepare marketing content calendar."
```

### Roadmap Execution
```
"Jalankan workflow 06_roadmap_execution.md untuk 8-week sprint planning.
Create weekly sprint plans, setup milestone tracking (5 milestones),
dan prepare risk register dengan mitigation plans."
```

---

## Workflow Validation Checklist

### Pre-Project
- [ ] All source documentation reviewed
- [ ] Team assembled and roles assigned
- [ ] Development environment ready
- [ ] Budget approved
- [ ] Tools and accounts setup

### During Project
- [ ] Weekly sprints executed
- [ ] Milestone reviews conducted
- [ ] Progress reports submitted
- [ ] Risks monitored and mitigated
- [ ] Quality gates passed

### Post-Launch
- [ ] Product launched successfully
- [ ] First sales made
- [ ] Customer feedback collected
- [ ] Retrospective completed
- [ ] Lessons documented

---

**Note:** Workflows ini dirancang untuk technology-agnostic implementation. Untuk specific Flutter patterns dan best practices, refer to official Flutter documentation dan package guidelines.

---
description: Go-to-Market Launch untuk Flutter UI Kit commercial product. Distribution, marketing, launch execution, dan sales funnel.
---
# Workflow: Go-to-Market Launch - Flutter UI Kit

## Overview
Workflow ini memandu strategi Go-to-Market dan eksekusi launch untuk produk **Flutter UI Kit** komersial — dari setup channel distribusi hingga optimasi sales funnel.

**CRITICAL:** Yang dijual SELALU berupa **Flutter UI Kit package** (component library) — bukan app, bukan SaaS, bukan jasa. Target buyer adalah **developer Flutter** yang membeli license. Semua marketing content harus relevant untuk audience developer.

## Output Location
**Base Folder:** `flutter-ui-kit/05-gtm-launch/`

**Output Files:**
- `distribution-channels.md` - Sales Channels Setup (pub.dev, Gumroad, GitHub, Landing Page)
- `launch-timeline.md` - Pre-Launch → Launch Week → Post-Launch Schedule
- `marketing-content.md` - Content Strategy, Templates, Calendar
- `sales-funnel.md` - Conversion Funnel, Email Sequences, Optimization
- `metrics-tracking.md` - KPIs, Analytics, Revenue Projections

## Prerequisites
- Component development complete (`04_component_development.md` — minimal P0 13 components)
- Product ready (tested, documented, example app functional)
- Pricing strategy validated (dari `01_prd_analysis.md`: $39/$99/$299)
- DESIGN.md finalized (konsisten branding)
- Package publishable ke pub.dev

---

## Agent Behavior: Context Chain

**GOLDEN RULE:** Semua marketing content, pricing, dan messaging HARUS konsisten dengan output Phase 1 (PRD). Target buyer = developer Flutter. Kompetitor = UI Kit lain (GetWidget, Shadcn Flutter). Bukan kompetitor app.

### Input dari Phase Sebelumnya

```
Phase 1 (PRD) → Pricing tiers ($39/$99/$299), personas, competitors
Phase 2 (UI/UX) → DESIGN.md (brand visual, screenshots)
Phase 3 (Technical) → Package structure, pub.dev readiness
Phase 4 (Components) → MVP 13 components, component demos
                           ↓
Phase 5 (THIS) → Distribution, marketing, launch, sales
```

### Key Context Rules
- **Target Audience:** Developer Flutter (freelancer, agency, startup CTO, junior dev)
- **Product Type:** One-time license (bukan subscription)
- **Competitors:** GetWidget, Shadcn Flutter, VelocityX, Flutter Starter Kit, dll
- **Pricing dari Phase 1:** Individual $39, Team $99, Enterprise $299
- **Free Tier:** 5 basic components di pub.dev (upsell ke premium)
- **Domain Edition:** Jika Phase 1 mendeteksi domain, marketing menekankan domain tersebut

---

## Deliverables

### 1. Distribution Channels

**Description:** Setup semua channel penjualan dan distribusi.

**Instructions:**
1. Setup 4 primary channels:
   - **pub.dev** — Free tier (5 basic components, upsell links)
   - **Gumroad** — Paid tiers ($39/$99/$299)
   - **GitHub** — Open source presence, credibility
   - **Landing Page** — Central hub, documentation, conversions
2. Configure per channel: product listings, payment, delivery automation
3. Implement tracking: analytics, UTM, conversion events

**Channel Details:**

#### pub.dev (Free Tier — Discovery & Credibility)
```markdown
- Free components: AppButton (basic), AppTextField, AppCard, AppAvatar, AppChip
- README with installation guide + screenshots
- In-code upsell: "For advanced variants, visit flutteruikit.com/premium"
- Metrics: downloads, likes, pub points, popularity score
```

#### Gumroad (Paid Tiers — Revenue)
```markdown
### Individual — $39
- 30+ components (full library)
- Light & dark themes, 8 color palettes
- Documentation + example app
- 30-day email support, 1 developer license

### Team — $99
- Everything Individual + Figma design files
- Up to 5 developers, 90-day support

### Enterprise — $299
- Everything Team + unlimited developers
- Priority 1-year support, 2 custom components

### Launch Discounts
- EARLYBIRD40: 40% off (first 50 customers)
- LAUNCH25: 25% off (week 2-4)
```

#### GitHub (Open Source Presence)
```markdown
- Public repo with free tier components
- README badges: pub.dev score, coverage, license
- Issues & Discussions enabled
- Community response < 24 hours
```

#### Landing Page (Central Hub)
```markdown
URL: flutteruikit.com

Page Structure:
┌─────────────────────────────────────────┐
│  Hero: "Build Beautiful Apps 10x Faster"│
│  [View Components] [Buy Now]            │
├─────────────────────────────────────────┤
│  Component Showcase (interactive)       │
├─────────────────────────────────────────┤
│  Pricing Tiers (3 cards)                │
├─────────────────────────────────────────┤
│  Testimonials (3-5 developers)          │
├─────────────────────────────────────────┤
│  FAQ + Money-back guarantee             │
├─────────────────────────────────────────┤
│  Footer: Docs, GitHub, Social links     │
└─────────────────────────────────────────┘

Tech: Astro/Next.js + Vercel + Plausible Analytics
```

---

### 2. Launch Timeline

**Description:** Timeline detail dari pre-launch → launch week → post-launch.

**Instructions:**
1. Pre-launch (Week 6-7): Setup channels, build hype, collect waitlist
2. Launch week (Week 8): Product Hunt, social media blitz, live demo
3. Post-launch (Week 9+): Momentum, content engine, community growth

**Timeline Overview:**

#### Pre-Launch — Week 6: Foundation
- Day 1-2: Landing page live, Gumroad product configured, pub.dev published
- Day 3-4: Product images (5-10), demo video (3-5 min), launch content drafted
- Day 5-6: Email waitlist opened, beta tester outreach (10-20 devs)
- Day 7: Product Hunt submission, launch checklist final review

#### Pre-Launch — Week 7: Hype Building
- Monday: Teaser #1 — "Something big is coming for Flutter devs..."
- Wednesday: Build-in-public thread — development journey
- Friday: Beta tester testimonials collected, bugs fixed
- Weekend: Final prep, schedule social posts

#### Launch Week — Week 8
```
DAY 1 (Mon): PRODUCT HUNT 🚀
  00:01 — PH goes live
  09:00 — Email waitlist: "We're Live!"
  10:00 — Twitter announcement thread
  14:00 — Reddit r/FlutterDev post
  20:00 — Launch day recap

DAY 2 (Tue): STORYTELLING
  Twitter thread: "How I built a Flutter UI Kit" (10-12 tweets)
  LinkedIn article: professional angle + lessons learned

DAY 3 (Wed): DEMO DAY
  19:00 — Live coding: "Build login screen in 5 min with UI Kit"
  Share special offer during stream

DAY 4 (Thu): COMMUNITY
  Reddit AMA in r/FlutterDev
  Flutter Discord community visits

DAY 5 (Fri): WRAP-UP
  Launch recap blog, thank you on all channels, share metrics
```

**Launch Success Metrics:**
- Product Hunt: 500+ upvotes, Top 5 Product of the Day
- First week: 50+ sales, 100+ waitlist conversions
- Social: 10,000+ impressions

#### Post-Launch — Week 9-12+
- Week 9-10: Collect testimonials, ship v1.0.1 bug fixes, maintain velocity
- Week 11-12: Tutorial content series, YouTube deep-dives
- Month 3-6: Monthly releases, affiliate program, $5,000 MRR target

---

### 3. Marketing Content

**Description:** Content strategy, templates, dan calendar — fokus developer audience.

**Instructions:**
1. Define 4 content pillars
2. Create content calendar (first month)
3. Provide templates for repeatable content

**Content Pillars:**

| Pillar | % | Purpose | Example |
|--------|---|---------|---------|
| Educational | 40% | Establish expertise | "Build a Login Screen in 5 Minutes" |
| Build in Public | 30% | Build trust | "Week 4: Here's what broke..." |
| Social Proof | 20% | Credibility | "How @devjohn built his app 3x faster" |
| Product Updates | 10% | Keep engaged | "Introducing AppDataTable" |

**Content Calendar (Month 1):**

| Week | Twitter | LinkedIn | Blog | YouTube |
|------|---------|----------|------|---------|
| W8 (Launch) | Launch thread, story, demo reminder | Launch post, thank you | Launch recap | Live demo |
| W9 | Tutorial teaser, tip | Tutorial post | Tutorial #1 | — |
| W10 | User showcase, tip | — | — | Component deep-dive |
| W11 | Build in public | Lessons post | Tutorial #2 | — |

**Twitter Thread Template (Tutorial):**
```
Tweet 1 (Hook): "Want to build a beautiful login screen in Flutter?
Here's how in 5 minutes with a UI Kit 🧵"

Tweet 2 (Setup): "Step 1: flutter pub add flutter_ui_kit"

Tweet 3-6 (Steps): Code snippets with AppTextField, AppButton...

Tweet 7 (Result): GIF/video of final screen

Tweet 8 (CTA): "Get the full kit: [link]"
```

---

### 4. Sales Funnel

**Description:** Optimasi funnel dari awareness → conversion → retention.

**Instructions:**
1. Map funnel stages + target metrics
2. Create email sequences (welcome, nurture, offer)
3. Optimize conversion points (landing page, pricing, checkout)

**Funnel Overview:**
```
AWARENESS (10,000 impressions/month)
    │ 20% CTR
INTEREST (2,000 visitors/month)
    │ 25% signup
CONSIDERATION (500 email signups/month)
    │ 10% conversion
CONVERSION (50 purchases/month = ~$1,950)
    │ 80% satisfaction
RETENTION (4.8/5 stars, 30% referral)
```

**Email Welcome Sequence (5 emails):**

| # | Day | Subject | Purpose |
|---|-----|---------|---------|
| 1 | Day 0 | "Welcome! Here's your free Flutter UI Kit 🎁" | Deliver free tier, quick start |
| 2 | Day 2 | "Build your first screen in 5 minutes" | Show value (tutorial) |
| 3 | Day 5 | "See what others are building" | Social proof (showcases) |
| 4 | Day 7 | "Ready to unlock all components? 🚀" | Soft sell: 40% early bird |
| 5 | Day 13 | "Last chance for 40% off ⏰" | Urgency: discount expiring |

---

### 5. Metrics & KPIs

**Description:** Track performance across all touchpoints.

**North Star Metric:** Monthly Revenue
- Target: $5,000/month by Month 6

**Key Metrics:**

| Stage | Metric | Target |
|-------|--------|--------|
| Awareness | Social impressions | 10,000/month |
| Awareness | pub.dev downloads | 1,000/month |
| Awareness | GitHub stars | 500 total |
| Interest | Landing page visitors | 2,000/month |
| Consideration | Email signups | 500/month |
| Conversion | Purchases | 50/month |
| Conversion | Avg order value | $39 |
| Conversion | Refund rate | <5% |
| Retention | Satisfaction | 4.8/5 |
| Retention | Referral rate | 30% |

**6-Month Revenue Projection:**

| Month | Customers | Revenue | Cumulative |
|-------|-----------|---------|------------|
| 1 | 20 | $780 | $780 |
| 2 | 35 | $1,365 | $2,145 |
| 3 | 50 | $1,950 | $4,095 |
| 4 | 65 | $2,535 | $6,630 |
| 5 | 80 | $3,120 | $9,750 |
| 6 | 100 | $3,900 | $13,650 |

**Analytics Stack:** Google Analytics + Plausible (website), Gumroad Analytics (sales), ConvertKit (email), pub.dev + GitHub Insights.

---

## Workflow Steps

1. **Channel Setup** — pub.dev, Gumroad, GitHub, landing page. 3-4 hari.
2. **Content Creation** — Product images, demo video, launch content, email sequences. 5-7 hari.
3. **Launch Execution** — Product Hunt, social media, live demo, community. 5 hari.
4. **Post-Launch** — Testimonials, content calendar, funnel optimization. Ongoing.

**Total Launch Prep:** ~2 weeks (Week 6-7), then Launch Week 8.

## Success Criteria

### Quality Gates
- [ ] Produk yang dijual = Flutter UI Kit PACKAGE (bukan app, bukan SaaS)
- [ ] Target buyer = Developer Flutter (marketing language sesuai)
- [ ] Pricing sesuai Phase 1: $39/$99/$299
- [ ] Free tier di pub.dev (5 components + upsell links)
- [ ] Gumroad product page live dengan 3 tiers
- [ ] Landing page live dengan hero, showcase, pricing, FAQ
- [ ] Email welcome sequence (5 emails) written
- [ ] Launch week timeline planned (Product Hunt + social + live demo)
- [ ] Analytics tracking active di semua channels
- [ ] Post-launch content calendar (4 weeks minimum)
- [ ] Revenue projection documented

### Content Depth Minimums
| Deliverable | Min. Lines | Key Sections |
|-------------|------------|-------------|
| distribution-channels.md | 120 | 4 channels, pricing tiers, upsell strategy |
| launch-timeline.md | 100 | Pre-launch, launch week (day-by-day), post-launch |
| marketing-content.md | 100 | 4 pillars, calendar, templates |
| sales-funnel.md | 80 | Funnel stages, email sequence, optimization |
| metrics-tracking.md | 80 | KPIs per stage, revenue projection, analytics stack |

---

## Cross-References

- **Previous Phase** → `04_component_development.md` (product must be ready)
- **Next Phase** → `06_roadmap_execution.md` (sprint tracking for launch)
- **Pricing Source** → `flutter-ui-kit/01-prd-analysis/pricing-strategy.md`
- **Source Strategy** → `../../docs/flutter-ui-kit/04_GTM_STRATEGY.md`

## Tools & Templates
- Gumroad for sales + delivery
- pub.dev for package publishing
- Vercel/Netlify for landing page
- ConvertKit/Mailchimp for email
- Plausible/GA for analytics
- Buffer for social scheduling
- Canva/Figma for graphics
- Loom for demo videos

---

## Workflow Validation Checklist

### Pre-Execution
- [ ] MVP product complete (13 P0 + some P1 components)
- [ ] Package publishable (tests pass, docs complete)
- [ ] Pricing validated from Phase 1 ($39/$99/$299)
- [ ] Brand assets ready (logo, colors from DESIGN.md)
- [ ] Output folder `flutter-ui-kit/05-gtm-launch/` created

### During Execution
- [ ] All 4 channels configured and live
- [ ] Content calendar populated (4 weeks minimum)
- [ ] Email sequences written (5 welcome emails)
- [ ] Launch week executed per timeline
- [ ] Analytics events tracking correctly

### Post-Execution
- [ ] All 5 deliverable files at correct path
- [ ] Launch metrics documented
- [ ] Customer feedback collected
- [ ] Funnel optimization plan in place
- [ ] Content engine running (weekly cadence)
- [ ] Quality Gates passed

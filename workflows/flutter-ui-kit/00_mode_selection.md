---
description: Mode selection guide untuk Flutter UI Kit workflow. Membantu user memilih antara UI Kit Package, Showcase App, atau Hybrid approach.
---

# Workflow Mode Selection

## Overview

Workflow ini membantu kamu memilih mode yang tepat untuk project Flutter UI Kit berdasarkan **goal, preferensi revenue, dan kapasitas support**.

**CRITICAL:** Pilih mode di awal sebelum memulai Phase 1. Mode yang dipilih akan menentukan:
- Target personas (developer vs end-user)
- Output structure (package vs app)
- Revenue model (license vs SaaS)
- Marketing channels (developer communities vs local market)

---

## 3 Mode yang Tersedia

### Mode A: UI Kit Package 📦

**Apa itu:**
Component library yang dijual ke developer Flutter untuk mereka pakai di project mereka.

**Output:**
```
flutter_ui_kit/
├── lib/src/components/    # UI components
├── pubspec.yaml           # Package config
└── example/               # Demo kecil
```

**Target Buyer:**
- Freelance Flutter developer
- Agency CTO / Tech Lead
- Startup engineering team

**Revenue Model:**
- Individual License: $39 (one-time)
- Team License: $99/year (up to 10 devs)
- Enterprise License: $299/year (unlimited)

**Best For:**
- ✅ Developer yang mau passive income
- ✅ Tidak mau jualan aktif ke end-user
- ✅ Mau global market (tidak terbatas region)
- ✅ Bisa handle low-medium support
- ✅ Prefer one-time build, many sales

**Effort:**
- Build: 8-12 minggu
- Marketing: Ongoing (content, community)
- Support: Low-Medium (developer buyers)
- Maintenance: Monthly updates

**Revenue Potential:**
- Year 1: $15-30K (100-300 customers)
- Year 2: $30-50K (growth + renewals)

---

### Mode B: Showcase App 📱

**Apa itu:**
Aplikasi lengkap yang bisa langsung dijalankan, bisa dijual sebagai template atau SaaS ke end-user.

**Output:**
```
showcase_app/
├── lib/
│   ├── main.dart
│   ├── features/
│   ├── shared/
│   └── data/
└── pubspec.yaml  # App config
```

**Target Buyer:**
- Pemilik bisnis (end-user)
- Workshop bengkel
- Clinic, salon, retail

**Revenue Model:**
- Template License: Rp 2-5 juta (one-time)
- SaaS Subscription: Rp 100-200K/bulan
- Customization: Rp 5-10 juta + maintenance

**Best For:**
- ✅ Yang mau build business, bukan cuma product
- ✅ Siap jualan aktif ke end-user
- ✅ Mau recurring revenue (SaaS)
- ✅ Bisa handle high support
- ✅ Paham domain bisnis spesifik

**Effort:**
- Build: 8-12 minggu
- Sales: Ongoing (direct sales)
- Support: High (end-user buyers)
- Maintenance: Weekly (bugs + features)

**Revenue Potential:**
- Year 1: Rp 100-200 juta (20-50 customers)
- Year 2: Rp 300-500 juta (scale)

---

### Mode C: Hybrid 🎯 (RECOMMENDED)

**Apa itu:**
Build UI Kit Package sebagai product utama, lalu buat Showcase App sebagai live demo dan cross-promotion.

**Output:**
```
Phase 1: UI Kit Package (Week 1-8)
flutter_ui_kit/
├── lib/src/components/
└── example/

Phase 2: Showcase App (Week 9-12)
showcase_app/
├── lib/ (uses UI Kit)
└── pubspec.yaml
```

**Strategy:**
1. Build UI Kit dulu (8 minggu)
2. Extract Showcase App dari UI Kit (4 minggu)
3. Showcase App jadi live demo untuk UI Kit
4. Cross-promote: UI Kit → Demo, Demo → UI Kit

**Revenue Streams:**
- UI Kit License: $39-299 (primary)
- Template License: Rp 2-5jt (secondary)
- Customization: Optional

**Best For:**
- ✅ Developer yang mau passive income + credibility
- ✅ Mau showcase quality tanpa build dari nol
- ✅ Prefer diversified revenue
- ✅ Mau build authority di community

**Revenue Potential:**
- Year 1: $20-40K (UI Kit) + Rp 50-100jt (Template)
- Year 2: $40-60K + Rp 150-200jt

---

## Decision Framework

### Quick Decision (30 seconds)

Jawab 4 pertanyaan ini:

**1. Apa goal utama kamu?**
- A) Passive income, build once sell many → **Mode A**
- B) Build business, active revenue → **Mode B**
- C) Both (diversified) → **Mode C**

**2. Siapkah kamu jualan aktif?**
- A) Tidak, saya developer murni → **Mode A**
- B) Ya, saya siap jualan → **Mode B**
- C) Mau tapi prefer passive → **Mode C**

**3. Preferensi revenue model?**
- A) One-time license ($39-299) → **Mode A**
- B) Recurring SaaS (monthly) → **Mode B**
- C) Both → **Mode C**

**4. Berapa waktu untuk support?**
- A) Minimal (developer mandiri) → **Mode A**
- B) High (end-user butuh bantuan) → **Mode B**
- C) Medium → **Mode C**

**Kebanyakan A?** → Mode A (UI Kit Package)  
**Kebanyakan B?** → Mode B (Showcase App)  
**Mixed/C?** → Mode C (Hybrid) ← **RECOMMENDED**

---

### Detailed Scoring (5 minutes)

Score setiap kriteria (1-5):

| Criteria | Weight | Mode A Score | Mode B Score | Mode C Score |
|----------|--------|--------------|--------------|--------------|
| **Passive Income Potential** | 25% | 5 | 2 | 4 |
| **Revenue Ceiling** | 20% | 3 | 5 | 5 |
| **Support Load (lower=better)** | 20% | 5 | 2 | 4 |
| **Market Size** | 15% | 3 | 5 | 5 |
| **Competition** | 10% | 2 | 4 | 3 |
| **Technical Satisfaction** | 10% | 5 | 3 | 5 |

**Calculate:**
```
Mode A: (5×0.25) + (3×0.20) + (5×0.20) + (3×0.15) + (2×0.10) + (5×0.10) = 3.95
Mode B: (2×0.25) + (5×0.20) + (2×0.20) + (5×0.15) + (4×0.10) + (3×0.10) = 3.35
Mode C: (4×0.25) + (5×0.20) + (4×0.20) + (5×0.15) + (3×0.10) + (5×0.10) = 4.35
```

**Highest score wins!**

---

## Mode Comparison Matrix

| Aspect | Mode A: UI Kit | Mode B: Showcase App | Mode C: Hybrid |
|--------|---------------|---------------------|----------------|
| **Build Time** | 8-12 weeks | 8-12 weeks | 12-16 weeks |
| **Initial Revenue** | Week 8-10 | Week 8-10 | Week 8-10 (UI Kit) |
| **Revenue Type** | One-time + recurring | Recurring (SaaS) | Diversified |
| **Support Load** | Low-Medium | High | Medium |
| **Sales Effort** | Passive (marketing) | Active (direct sales) | Passive + demo |
| **Market** | Global (developers) | Local (businesses) | Both |
| **Competition** | High (free kits) | Low (niche) | Low (unique) |
| **Technical Depth** | High (general purpose) | Medium-High (specific) | High |
| **Scalability** | Very High | Medium | High |
| **Exit Potential** | Acqui-hire | Small exit | Big exit |
| **Best For** | Developer murni | Business builder | Best of both |

---

## User Personas per Mode

### Mode A: UI Kit Package

**Persona 1: Rizky - Freelance Developer**
- Age: 28, Location: Indonesia
- Income: $35-50K/year (freelance)
- Goal: Deliver projects faster
- Pain: Rebuild components every project
- Willing to pay: $39 for time-saving

**Persona 2: Sarah - Startup CTO**
- Age: 35, Location: Singapore
- Income: $80K/year (founder)
- Goal: Ship features 2x faster
- Pain: UI inconsistency, slow velocity
- Willing to pay: $99-299 for team

### Mode B: Showcase App

**Persona 1: Budi - Workshop Owner**
- Age: 42, Location: Jakarta
- Revenue: $8M/year (25 workshops)
- Goal: Digitalize operations
- Pain: Legacy system slow & buggy
- Willing to pay: Rp 100-200K/bulan

**Persona 2: Dr. Siti - Clinic Owner**
- Age: 38, Location: Surabaya
- Revenue: $500K/year
- Goal: Modern patient management
- Pain: Manual processes, lost records
- Willing to pay: Rp 150-300K/bulan

### Mode C: Hybrid

**Primary:** Developer personas (Mode A)  
**Secondary:** Business personas (Mode B)

---

## Path Recommendations

### Path A: UI Kit Package (8-12 weeks)

```
Week 1-2: PRD + UI/UX
├── Developer personas
├── UI Kit competitors
├── DESIGN.md (tokens, themes)
└── Component requirements

Week 3-6: Core Components
├── 13 P0 components
├── Theme system (16 themes)
├── Tests (>90% coverage)
└── Documentation

Week 7-8: Polish + Launch Prep
├── Example app
├── pub.dev listing
├── Marketing materials
└── Launch announcement

Week 9+: Marketing
├── Content marketing
├── Community engagement
├── Affiliate program
└── Continuous improvement
```

### Path B: Showcase App (8-12 weeks)

```
Week 1-2: PRD + UI/UX
├── End-user personas
├── Business competitors
├── DESIGN.md (tokens, themes)
└── Feature requirements

Week 3-6: Core Features
├── Main screens
├── State management
├── Dummy data
└── Basic testing

Week 7-8: Polish + Demo
├── Full testing
├── Deployment setup
├── Demo data
└── User guide

Week 9+: Sales
├── Direct outreach
├── Demo presentations
├── Customization requests
└── Customer onboarding
```

### Path C: Hybrid (12-16 weeks) ← RECOMMENDED

```
Week 1-8: UI Kit Package (same as Path A)
└── Complete UI Kit with 23+ components

Week 9-12: Showcase App
├── Reuse UI Kit components
├── Build domain screens
├── Add dummy data
└── Deploy as live demo

Week 13+: Dual Marketing
├── UI Kit: Developer marketing
├── Showcase: Demo for credibility
└── Cross-promote both
```

---

## Revenue Projection Comparison

### Mode A: UI Kit Package

| Month | Individual | Team | Enterprise | Total Revenue |
|-------|-----------|------|------------|---------------|
| 1-3 | 30 × $39 | 5 × $99 | 2 × $299 | $2,251 |
| 4-6 | 50 × $39 | 10 × $99 | 5 × $299 | $4,425 |
| 7-12 | 100 × $39 | 20 × $99 | 10 × $299 | $8,870 |
| **Year 1 Total** | | | | **$15,546** |

### Mode B: Showcase App (SaaS)

| Month | New Customers | MRR | ARR Equivalent |
|-------|--------------|-----|----------------|
| 1-3 | 5 × Rp 150K | Rp 750K | Rp 9jt |
| 4-6 | 10 × Rp 150K | Rp 1.5jt | Rp 18jt |
| 7-12 | 20 × Rp 150K | Rp 3jt | Rp 36jt |
| **Year 1 Total** | | | **Rp 63jt (~$4,100)** |

*Note: Mode B starts lower but compounds. Year 2-3 can exceed Mode A with 50-100 customers.*

### Mode C: Hybrid

| Revenue Stream | Year 1 | Year 2 |
|---------------|--------|--------|
| UI Kit Licenses | $20,000 | $40,000 |
| Template Sales | Rp 75jt ($4,800) | Rp 150jt ($9,600) |
| **Total** | **$24,800** | **$49,600** |

---

## Risk Assessment

### Mode A: UI Kit Package

| Risk | Probability | Impact | Mitigation |
|------|-------------|--------|------------|
| Free competition | High | Medium | Emphasize quality, domain expertise |
| Low initial sales | Medium | Medium | Content marketing, early bird pricing |
| Flutter breaking changes | Low | High | Active maintenance, clear deprecation |
| Burnout from maintenance | Medium | Medium | Set expectations, automate updates |

### Mode B: Showcase App

| Risk | Probability | Impact | Mitigation |
|------|-------------|--------|------------|
| Low adoption | High | High | Direct sales, demo-first approach |
| High churn | Medium | High | Excellent onboarding, continuous value |
| Customization overload | High | Medium | Clear scope, charge for custom work |
| Support burnout | High | High | Documentation, FAQ, tiered support |

### Mode C: Hybrid

| Risk | Probability | Impact | Mitigation |
|------|-------------|--------|------------|
| Context switching | Medium | Medium | Focus phases: UI Kit first, then App |
| Double effort | Low | Medium | Reuse components, efficient workflow |
| Marketing complexity | Medium | Low | Separate channels, clear messaging |

---

## Success Criteria

### Mode A: UI Kit Package

**Month 1-3:**
- [ ] 50+ customers
- [ ] 5+ public projects using UI Kit
- [ ] 3+ testimonials
- [ ] pub.dev score: 90+

**Month 4-6:**
- [ ] 150+ customers
- [ ] $3-5K MRR
- [ ] 10+ affiliate partners
- [ ] 500+ GitHub stars

**Year 1:**
- [ ] 500+ customers
- [ ] $15-30K revenue
- [ ] 1000+ GitHub stars
- [ ] Recognized in Flutter community

### Mode B: Showcase App

**Month 1-3:**
- [ ] 5-10 paying customers
- [ ] Rp 750K-1.5jt MRR
- [ ] 3+ case studies
- [ ] Product-market fit validated

**Month 4-6:**
- [ ] 20-30 customers
- [ ] Rp 3-4.5jt MRR
- [ ] 80%+ retention rate
- [ ] Referral program working

**Year 1:**
- [ ] 50-100 customers
- [ ] Rp 7.5-15jt MRR
- [ ] 70%+ gross margin
- [ ] Team of 2-3 for support

### Mode C: Hybrid

**Month 1-3:**
- [ ] UI Kit: 30+ customers
- [ ] Showcase: Live demo deployed
- [ ] Cross-promotion working

**Month 4-6:**
- [ ] UI Kit: 100+ customers
- [ ] Template: 5-10 sales
- [ ] Combined revenue: $5-8K

**Year 1:**
- [ ] UI Kit: 300+ customers
- [ ] Template: 20-30 sales
- [ ] Total: $25-40K revenue

---

## Decision Checklist

Before choosing, ensure you have:

**For Mode A:**
- [ ] Flutter development skills (2+ years)
- [ ] Understanding of developer needs
- [ ] Content marketing willingness
- [ ] Community engagement plan
- [ ] Long-term maintenance commitment

**For Mode B:**
- [ ] Domain knowledge (bengkel, clinic, etc.)
- [ ] Sales willingness (direct outreach)
- [ ] Support capacity (high touch)
- [ ] Local market connections
- [ ] Business mindset (not just product)

**For Mode C:**
- [ ] All Mode A requirements
- [ ] Extra 4-6 weeks for Phase 2
- [ ] Ability to manage 2 products
- [ ] Clear prioritization (UI Kit first)

---

## Next Steps

**After choosing mode:**

1. **Note your mode:** A / B / C
2. **Proceed to Phase 1:** `01_prd_analysis.md`
3. **Reference this file:** For persona, revenue, channel guidance
4. **Revisit if needed:** Can pivot mode later (cost: 2-4 weeks)

**Mode-Specific Paths:**

- **Mode A:** Continue to `01_prd_analysis.md` → Developer personas
- **Mode B:** Continue to `01_prd_analysis.md` → End-user personas
- **Mode C:** Continue to `01_prd_analysis.md` → Both personas (UI Kit priority)

---

## Pivot Strategy

**If you need to change mode later:**

**Mode A → Mode C:** (Recommended pivot)
- Cost: +4-6 weeks
- Action: Build Showcase App from UI Kit
- Benefit: Diversified revenue

**Mode B → Mode C:** (Complex pivot)
- Cost: +4-8 weeks refactor
- Action: Extract components to UI Kit
- Benefit: Passive income stream

**Mode A → Mode B:** (Not recommended)
- Cost: High (complete rebuild)
- Action: Build full app from scratch
- Better: Start Mode C instead

**Mode C → Mode A:** (Simplify)
- Cost: Low (stop Phase 2)
- Action: Focus on UI Kit only
- Reason: Overwhelmed, prefer focus

---

## FAQ

**Q: Can I start with Mode B and extract UI Kit later?**
A: Yes, but it's harder. Better to build UI Kit first (Mode C), then Showcase App.

**Q: What if I'm not sure about my choice?**
A: Choose Mode C. It's the most flexible and recommended for most developers.

**Q: Can I sell Showcase App as SaaS with Mode A?**
A: No, Mode A is UI Kit only. For SaaS, choose Mode B or C.

**Q: How do I know if Mode C is not too much work?**
A: Start with Mode A. If UI Kit gains traction, add Showcase App later (pivot to C).

**Q: What if I want to sell to both developers AND end-users?**
A: Mode C is designed for this. UI Kit for developers, Showcase App as proof-of-concept.

---

## Related Documents

- **Next:** `01_prd_analysis.md` - PRD based on chosen mode
- **Reference:** `03_technical_implementation.md` - Technical structure per mode
- **Launch:** `05_gtm_launch.md` - Go-to-market per mode
- **Timeline:** `06_roadmap_execution.md` - Execution plan per mode

---

**Mode Selection Date:** _______________

**Chosen Mode:** A / B / C (circle one)

**Reason:** _______________________________________________

**Review Date:** _______________ (revisit after 4-6 weeks)

---

*Version: 1.0 | Last Updated: March 2026*

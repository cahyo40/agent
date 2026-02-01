---
name: tech-trend-analyst
description: "Expert in identifying and analyzing technology trends using GitHub Trending, Technology Radar, StackOverflow surveys, and industry reports"
---

# Tech Trend Analyst

## Overview

Skill ini menjadikan AI Agent Anda sebagai analis tren teknologi profesional. Agent akan mampu mengidentifikasi teknologi yang sedang naik daun (*rising*), menganalisis adopsi industri, dan memberikan rekomendasi strategis berdasarkan data dari berbagai sumber terpercaya seperti GitHub Trending, ThoughtWorks Technology Radar, dan StackOverflow Developer Survey.

## When to Use This Skill

- Use when researching which technologies are gaining momentum in 2024-2025
- Use when evaluating whether to adopt a new framework or language
- Use when preparing technology reports for stakeholders
- Use when the user asks "What's trending in [technology domain]?"
- Use when comparing adoption rates between competing technologies

## How It Works

### Step 1: Identify Data Sources

Gunakan sumber-sumber berikut untuk analisis tren:

| Source | Data Type | Update Frequency |
|--------|-----------|------------------|
| GitHub Trending | Repository popularity, star velocity | Daily |
| ThoughtWorks Radar | Industry adoption stages | Quarterly |
| StackOverflow Survey | Developer preferences, salary data | Annual |
| State of JS/CSS/HTML | Framework adoption, satisfaction | Annual |
| npm/PyPI Downloads | Package usage statistics | Real-time |
| HackerNews/Reddit | Community sentiment | Continuous |

### Step 2: Categorize Technology Status

Klasifikasikan setiap teknologi ke dalam kategori berikut:

```text
┌─────────────────────────────────────────────────────────┐
│                    TECHNOLOGY RADAR                      │
├─────────────────────────────────────────────────────────┤
│  🚀 ADOPT      → Production-ready, widely recommended   │
│  🧪 TRIAL      → Worth pursuing, suitable for pilots    │
│  🔍 ASSESS     → Explore with understanding of risks    │
│  ⏸️ HOLD       → Proceed with caution, may be declining │
│  ☠️ SUNSET     → Actively being phased out              │
└─────────────────────────────────────────────────────────┘
```

### Step 3: Analyze Trend Indicators

Perhatikan indikator-indikator berikut:

1. **Star Velocity**: Pertumbuhan jumlah star GitHub per bulan
2. **Issue Resolution Rate**: Seberapa cepat bug diperbaiki
3. **Contributor Growth**: Pertumbuhan jumlah kontributor aktif
4. **Job Market Demand**: Jumlah lowongan kerja yang menyebut teknologi tersebut
5. **Corporate Backing**: Apakah didukung oleh perusahaan besar

### Step 4: Generate Trend Report

Format laporan analisis:

```markdown
# Technology Trend Report: [Technology Name]

## Current Status: [ADOPT/TRIAL/ASSESS/HOLD]

### Key Metrics
- GitHub Stars: XX,XXX (↑ XX% YoY)
- NPM Downloads: XX million/month
- Job Postings: XX,XXX active listings
- Community Size: XX,XXX members

### Adoption Curve Position
[Early Adopter / Early Majority / Late Majority / Laggard]

### Risk Assessment
- **Longevity Risk**: Low/Medium/High
- **Learning Curve**: Easy/Moderate/Steep
- **Migration Path**: Clear/Unclear

### Recommendation
[Strategic recommendation with reasoning]
```

## Examples

### Example 1: Analyzing a Rising Framework

**User Question:** "Apakah Bun sudah siap untuk production?"

**Agent Response:**

```markdown
# Technology Trend Report: Bun Runtime

## Current Status: 🧪 TRIAL

### Key Metrics
- GitHub Stars: 75,000+ (↑ 200% since 2023)
- Version: 1.1+ (Stable release achieved)
- Corporate Backing: Oven (VC-funded startup)

### Adoption Curve Position
Early Adopter → transitioning to Early Majority

### Risk Assessment
- **Longevity Risk**: Medium (Single company dependency)
- **Learning Curve**: Easy (Node.js compatible)
- **Migration Path**: Clear (Drop-in replacement for most cases)

### Recommendation
✅ TRIAL for new side projects and internal tools
⚠️ ASSESS for production workloads (monitor ecosystem maturity)
```

### Example 2: Identifying Declining Technologies

```markdown
# Sunset Alert: [Technology Name]

## Warning Signs Detected:
- ❌ Last major release: > 18 months ago
- ❌ Core maintainers moving to alternatives
- ❌ Job postings declining YoY
- ❌ Major companies announcing migration away

## Recommended Alternatives:
1. [Alternative A] - Migration path available
2. [Alternative B] - Better long-term prospects
```

## Best Practices

### ✅ Do This

- ✅ Always cite data sources and dates
- ✅ Distinguish between hype and genuine adoption
- ✅ Consider the user's specific context (startup vs enterprise)
- ✅ Provide actionable recommendations, not just data
- ✅ Acknowledge uncertainty in predictions

### ❌ Avoid This

- ❌ Don't declare a technology "dead" without evidence
- ❌ Don't ignore niche technologies that solve specific problems
- ❌ Don't confuse GitHub stars with production readiness
- ❌ Don't forget to check corporate backing and funding status

## Common Pitfalls

**Problem:** Confusing "trendy" with "production-ready"
**Solution:** Always separate popularity metrics from stability indicators. A technology can be trending on GitHub but still lack enterprise features.

**Problem:** Ignoring ecosystem maturity
**Solution:** Check the health of supporting libraries, tooling, and community resources—not just the core project.

## Related Skills

- `@emerging-tech-specialist` - For deep dives into cutting-edge technologies
- `@open-source-evaluator` - For assessing project health in detail
- `@startup-analyst` - For understanding market context
- `@senior-software-architect` - For integration recommendations

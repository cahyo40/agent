---
description: This workflow covers the Product Requirements Document (PRD) analysis for Flutter UI Kit commercial product.
---
# Workflow: PRD Analysis - Flutter UI Kit

## Overview
This workflow analyzes and validates the Product Requirements Document (PRD) for the Flutter UI Kit commercial product. The goal is to ensure clear product vision, target market definition, and success metrics.

## Output Location
**Base Folder:** `flutter-ui-kit/01-prd-analysis/`

**Output Files:**
- `market-analysis.md` - Market Size, Competitor Analysis, Target Segments
- `user-personas.md` - Detailed User Personas with Jobs-to-be-Done
- `requirements-validation.md` - Validated Functional & Non-Functional Requirements
- `pricing-strategy.md` - Pricing Tiers and Revenue Model Validation

## Prerequisites
- Initial PRD draft available
- Market research data (if existing)
- Access to potential user interviews
- Competitor product access (free tiers)

## Deliverables

### 1. Market Analysis

**Description:** Comprehensive analysis of the Flutter UI Kit market landscape.

**Recommended Skills:** `market-researcher`, `product-strategist`

**Instructions:**
1. Analyze market size and growth potential:
   - Total Addressable Market (TAM)
   - Serviceable Addressable Market (SAM)
   - Serviceable Obtainable Market (SOM)
2. Conduct competitor analysis:
   - Direct competitors (Flutter UI kits)
   - Indirect competitors (Material Design, custom designs)
   - Substitute solutions (design systems, templates)
3. Identify market gaps and opportunities
4. Document competitive advantages

**Output Format:**
```markdown
# Market Analysis

## Market Size
| Segment | Size | Growth Rate |
|---------|------|-------------|
| Flutter Developers (Global) | 5,000,000 | 15%/year |
| Paid Users (3%) | 150,000 | - |
| Target Revenue | $5,000 MRR | - |

## Competitor Analysis
| Competitor | Price | Strengths | Weaknesses | Our Edge |
|------------|-------|-----------|------------|----------|
| GetWidget | Free/$49 | Many components | Outdated docs | Better DX |
| Shadcn Flutter | Free | Modern | Limited | More components |

## Market Gaps
1. [Gap 1 with evidence]
2. [Gap 2 with evidence]

## Competitive Advantages
1. [Advantage 1]
2. [Advantage 2]
```

---

### 2. User Personas Validation

**Description:** Deep dive into target user personas with jobs-to-be-done framework.

**Recommended Skills:** `user-researcher`, `product-manager`

**Instructions:**
1. Validate existing personas with real user interviews (5-10 users per persona)
2. Define jobs-to-be-done for each persona:
   - Functional jobs (what they need to accomplish)
   - Emotional jobs (how they want to feel)
   - Social jobs (how they want to be perceived)
3. Map pain points to product features
4. Identify buying triggers and decision criteria
5. Create empathy maps for each persona

**Output Format:**
```markdown
# User Personas Validation

## Persona 1: Freelance Flutter Developer

### Demographics
- Age: 25-35
- Location: Indonesia, Southeast Asia, India
- Income: $2,000-8,000/month
- Experience: 2-5 years Flutter

### Jobs-to-be-Done
**Functional:**
- "Help me complete client projects faster so I can take on more work"
- "Help me create consistent UI across multiple projects"

**Emotional:**
- "Reduce my stress about meeting deadlines"
- "Give me confidence in my UI design decisions"

**Social:**
- "Help me look professional to clients"
- "Position me as a full-stack developer"

### Pain Points (Validated)
| Pain Point | Frequency | Severity | Current Solution |
|------------|-----------|----------|------------------|
| Rebuilding same components | Daily | High | Copy-paste old code |
| Inconsistent UI | Per project | Medium | Manual review |

### Buying Triggers
1. Started new client project with tight deadline
2. Frustrated after 3rd rebuild of button component
3. Saw impressive demo from competitor

### Decision Criteria
1. Price (<$50 for individual)
2. Component variety (>15 components)
3. Documentation quality
4. Demo app quality
```

---

### 3. Requirements Validation

**Description:** Validate functional and non-functional requirements with stakeholders and potential users.

**Recommended Skills:** `senior-system-analyst`, `product-manager`

**Instructions:**
1. Review functional requirements from PRD:
   - Component library requirements (FR-1)
   - Theming system requirements (FR-2)
   - Documentation requirements (FR-3)
   - Quality requirements (FR-4)
2. Validate with potential users (survey/interview):
   - Priority ranking of components
   - Must-have vs nice-to-have features
   - Willingness to pay for each feature
3. Review non-functional requirements:
   - Performance targets
   - Compatibility requirements
   - Accessibility standards
4. Create requirements priority matrix

**Output Format:**
```markdown
# Requirements Validation

## Functional Requirements Priority

### P0 - Critical (MVP)
| Req ID | Requirement | User Priority | Business Priority | Final |
|--------|-------------|---------------|-------------------|-------|
| FR-1.1 | Button components (5 variants) | High | High | P0 |
| FR-1.2 | Input components | High | High | P0 |
| FR-2.1 | Light & Dark theme | High | High | P0 |

### P1 - High (Core Product)
| Req ID | Requirement | User Priority | Business Priority | Final |
|--------|-------------|---------------|-------------------|-------|
| FR-1.4 | Navigation components | High | Medium | P1 |
| FR-3.2 | Example App | High | High | P1 |

## Non-Functional Requirements Validation

| Category | Requirement | Target | Validation Method |
|----------|-------------|--------|-------------------|
| Performance | Initial load | <2 seconds | Lighthouse test |
| Performance | Component rebuild | <16ms (60fps) | Flutter DevTools |
| Accessibility | WCAG compliance | 2.1 AA | Accessibility scanner |

## User Survey Results
- Surveyed: 50 Flutter developers
- Top 3 requested components: Button, Input, Card
- Willingness to pay: $30-50 average
- Must-have: Dark mode (95%), Documentation (90%)
```

---

### 4. Pricing Strategy Validation

**Description:** Validate pricing tiers and revenue model with market research.

**Recommended Skills:** `product-strategist`, `pricing-analyst`

**Instructions:**
1. Analyze competitor pricing:
   - Free tier offerings
   - Paid tier features and prices
   - Bundle options
2. Conduct willingness-to-pay research:
   - Van Westendorp Price Sensitivity Meter
   - Conjoint analysis for feature bundles
3. Define pricing tiers based on personas:
   - Individual (freelancers)
   - Team (startups)
   - Enterprise (agencies)
4. Model revenue projections:
   - Conversion rate assumptions (free → paid)
   - Customer acquisition cost estimates
   - Lifetime value calculations

**Output Format:**
```markdown
# Pricing Strategy Validation

## Competitor Pricing Analysis
| Competitor | Free Tier | Paid Tier | Price | Model |
|------------|-----------|-----------|-------|-------|
| GetWidget | Limited | Full | $49 | One-time |
| CodeCanyon | No | Full | $20-50 | One-time |

## Price Sensitivity Results (Van Westendorp)
| Price Point | Percentage |
|-------------|------------|
| Too Cheap | <$15 (5%) |
| Bargain | $25 (25%) |
| Expensive | $65 (75%) |
| Too Expensive | >$100 (95%) |

**Optimal Price Range:** $35-45

## Recommended Pricing Tiers

### Individual - $39
- Target: Freelance developers
- License: 1 developer, unlimited projects
- Features: Full component library, docs, 30-day support

### Team - $99
- Target: Startups (2-5 developers)
- License: Up to 5 developers
- Features: + Figma files, 90-day support

### Enterprise - $299
- Target: Agencies (unlimited developers)
- License: Unlimited developers
- Features: + Priority support, 2 custom components

## Revenue Model

### Conversion Assumptions
- Free → Paid conversion: 3-5%
- Individual → Team upgrade: 15%
- Team → Enterprise upgrade: 5%

### 6-Month Projection
| Month | Users | Paid | MRR | Cumulative |
|-------|-------|------|-----|------------|
| Month 1 | 500 | 20 | $780 | $780 |
| Month 3 | 2,000 | 50 | $1,950 | $4,095 |
| Month 6 | 5,000 | 100 | $3,900 | $13,650 |
```

## Workflow Steps

1. **Market Research** (Market Researcher)
   - Gather market size data
   - Identify competitors
   - Analyze trends
   - Duration: 2-3 days

2. **User Interviews** (User Researcher)
   - Recruit 15-30 interviewees (5-10 per persona)
   - Conduct 30-minute interviews
   - Synthesize findings
   - Duration: 5-7 days

3. **Requirements Workshop** (Product Manager)
   - Review PRD requirements
   - Prioritize with MoSCoW method
   - Validate with technical team
   - Duration: 1 day

4. **Pricing Analysis** (Pricing Analyst)
   - Competitor pricing research
   - Price sensitivity survey
   - Revenue modeling
   - Duration: 2-3 days

5. **Documentation** (Product Manager)
   - Compile all findings
   - Create final PRD analysis report
   - Present to stakeholders
   - Duration: 2 days

## Success Criteria
- Market analysis validated with data sources
- User personas based on real interviews (not assumptions)
- Requirements prioritized with clear rationale
- Pricing strategy supported by research
- PRD analysis approved by stakeholders
- Clear go/no-go decision for product development

## Tools & Templates
- User interview script template
- Survey tools (Typeform, Google Forms)
- Competitive analysis matrix
- Price sensitivity calculator
- Revenue projection model
- Miro/Mural for affinity mapping

---

## Cross-References

- **Next Phase** → `02_ascii_wireframe.md`
- **Component Priority** → `04_component_development.md`
- **Go-to-Market** → `05_gtm_launch.md`
- **Timeline** → `06_roadmap_execution.md`
- **Source PRD** → `../../docs/flutter-ui-kit/01_PRD.md`

---

## Workflow Validation Checklist

### Pre-Execution
- [ ] PRD draft reviewed and understood
- [ ] Stakeholders identified for interviews
- [ ] User interview recruitment started
- [ ] Output folder structure created

### During Execution
- [ ] Market research completed with data sources
- [ ] Minimum 15 user interviews conducted
- [ ] Requirements prioritized with MoSCoW
- [ ] Pricing research completed (Van Westendorp or similar)
- [ ] Revenue model created with clear assumptions

### Post-Execution
- [ ] All deliverables documented
- [ ] Stakeholder review completed
- [ ] PRD analysis approved
- [ ] Clear go/no-go decision made
- [ ] Documents version controlled

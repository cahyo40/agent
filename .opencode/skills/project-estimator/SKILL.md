---
name: project-estimator
description: "Expert project estimation including effort calculation, timeline planning, resource allocation, cost estimation, and sprint/milestone breakdown"
---

# Project Estimator

## Overview

This skill helps you accurately estimate software projects by calculating effort, creating realistic timelines, allocating resources, and determining project costs. You'll use proven estimation techniques to avoid under-scoping and over-promising.

## When to Use This Skill

- Use when estimating new project requirements
- Use when breaking down features into tasks
- Use when calculating development hours/days
- Use when planning sprints or milestones
- Use when determining team size and composition
- Use when creating project budgets

## How It Works

### Step 1: Estimation Techniques Overview

```text
ESTIMATION TECHNIQUES
├── STORY POINTS (Relative)
│   ├── Fibonacci: 1, 2, 3, 5, 8, 13, 21
│   ├── T-Shirt: XS, S, M, L, XL
│   └── Best for: Sprint planning, team velocity
│
├── TIME-BASED (Absolute)
│   ├── Hours/Days/Weeks
│   ├── Include buffer (20-30%)
│   └── Best for: Client proposals, contracts
│
├── THREE-POINT ESTIMATE
│   ├── Optimistic (O)
│   ├── Most Likely (M)
│   ├── Pessimistic (P)
│   └── Formula: (O + 4M + P) / 6
│
└── FUNCTION POINT ANALYSIS
    ├── Count inputs, outputs, queries
    ├── Apply complexity weights
    └── Best for: Large enterprise systems
```

### Step 2: Task Breakdown Structure

```markdown
## Feature: User Authentication

### Epic Breakdown
| Task | Complexity | Story Points | Hours (Est.) |
|------|------------|--------------|--------------|
| Database schema design | M | 3 | 4-6h |
| User model & migration | S | 2 | 2-3h |
| Registration endpoint | M | 3 | 4-6h |
| Login endpoint + JWT | M | 5 | 6-8h |
| Password reset flow | L | 8 | 10-14h |
| Email verification | M | 5 | 6-8h |
| Social login (Google) | L | 8 | 10-14h |
| Unit tests | M | 5 | 6-8h |
| Integration tests | M | 5 | 6-8h |
| Documentation | S | 2 | 2-3h |

**Total Story Points:** 46
**Total Hours:** 56-78h (avg: 67h)
**Buffer (25%):** 17h
**Final Estimate:** 84h (~10.5 working days)
```

### Step 3: Three-Point Estimation Template

```markdown
## Project: E-Commerce Backend

| Module | Optimistic | Most Likely | Pessimistic | PERT Estimate |
|--------|------------|-------------|-------------|---------------|
| Auth & Users | 5 days | 8 days | 14 days | 8.5 days |
| Product Catalog | 4 days | 6 days | 10 days | 6.3 days |
| Shopping Cart | 3 days | 5 days | 9 days | 5.3 days |
| Checkout & Payment | 6 days | 10 days | 18 days | 10.7 days |
| Order Management | 4 days | 7 days | 12 days | 7.3 days |
| Admin Dashboard | 5 days | 8 days | 15 days | 8.7 days |
| API Documentation | 2 days | 3 days | 5 days | 3.2 days |
| Testing & QA | 5 days | 8 days | 14 days | 8.5 days |
| Deployment & DevOps | 3 days | 5 days | 9 days | 5.3 days |

**Total PERT:** 63.8 days
**Contingency (20%):** 12.8 days
**Final Estimate:** 77 working days (~3.5 months)
```

### Step 4: Resource Allocation

```markdown
## Team Composition

| Role | Count | Rate/Hour | Allocation | Monthly Cost |
|------|-------|-----------|------------|--------------|
| Tech Lead | 1 | $75 | 100% | $12,000 |
| Senior Developer | 2 | $60 | 100% | $19,200 |
| Mid Developer | 2 | $45 | 100% | $14,400 |
| QA Engineer | 1 | $40 | 80% | $5,120 |
| DevOps | 1 | $55 | 50% | $4,400 |
| UI/UX Designer | 1 | $50 | 30% | $2,400 |
| Project Manager | 1 | $55 | 50% | $4,400 |

**Monthly Team Cost:** $61,920
**Project Duration:** 3.5 months
**Total Labor Cost:** $216,720
```

### Step 5: Sprint Planning Template

```markdown
## Sprint Planning - Project X

### Sprint 1 (Week 1-2)
**Goal:** Project setup & authentication foundation
**Capacity:** 80 story points (4 devs × 20 SP each)

| Task | Assignee | Points | Status |
|------|----------|--------|--------|
| Project scaffolding | Dev A | 3 | ⬜ |
| CI/CD pipeline setup | DevOps | 5 | ⬜ |
| Database design | Dev A | 5 | ⬜ |
| User registration | Dev B | 8 | ⬜ |
| Login + JWT | Dev B | 8 | ⬜ |
| Password reset | Dev C | 8 | ⬜ |
| Email service | Dev C | 5 | ⬜ |
| Unit tests (auth) | Dev D | 8 | ⬜ |

**Committed:** 50 SP | **Buffer:** 30 SP for unknowns

### Sprint 2 (Week 3-4)
**Goal:** Product catalog & search
...
```

### Step 6: Cost Calculation Formula

```markdown
## Project Cost Estimation

### Development Costs
| Component | Hours | Rate | Cost |
|-----------|-------|------|------|
| Backend Development | 400h | $55/h | $22,000 |
| Frontend Development | 320h | $50/h | $16,000 |
| Mobile Development | 280h | $55/h | $15,400 |
| UI/UX Design | 80h | $45/h | $3,600 |
| QA Testing | 120h | $40/h | $4,800 |
| DevOps & Infra | 60h | $60/h | $3,600 |
| Project Management | 80h | $50/h | $4,000 |

**Subtotal Development:** $69,400

### Additional Costs
| Item | Cost |
|------|------|
| Third-party APIs/Services | $2,000 |
| Cloud Infrastructure (3 months) | $1,500 |
| Design Assets/Icons | $500 |
| SSL & Domain | $200 |
| Miscellaneous | $800 |

**Subtotal Additional:** $5,000

### Final Calculation
| | Amount |
|--|--------|
| Development | $69,400 |
| Additional | $5,000 |
| **Subtotal** | $74,400 |
| Contingency (15%) | $11,160 |
| **Grand Total** | $85,560 |
```

## Estimation Checklist

```markdown
### Before Estimation
- [ ] Requirements document reviewed
- [ ] Stakeholder expectations clarified
- [ ] Technical constraints identified
- [ ] Third-party dependencies listed
- [ ] Similar past projects referenced

### During Estimation
- [ ] Features broken into tasks (max 1 day each)
- [ ] Dependencies between tasks mapped
- [ ] Complexity categorized (S/M/L/XL)
- [ ] Three-point estimates for unknowns
- [ ] Buffer added (15-30%)

### After Estimation
- [ ] Team reviewed estimates
- [ ] Assumptions documented
- [ ] Risks identified with mitigation
- [ ] Timeline visualized (Gantt)
- [ ] Client-ready proposal created
```

## Best Practices

### ✅ Do This

- ✅ Break tasks into ≤1 day chunks
- ✅ Include testing time in estimates
- ✅ Add 20-30% buffer for unknowns
- ✅ Use historical data from past projects
- ✅ Estimate with the team, not alone
- ✅ Document all assumptions
- ✅ Re-estimate when scope changes

### ❌ Avoid This

- ❌ Don't estimate under pressure
- ❌ Don't ignore deployment/DevOps time
- ❌ Don't forget meetings/communication overhead
- ❌ Don't assume perfect productivity (use 6h/day)
- ❌ Don't skip code review and testing time
- ❌ Don't promise dates without buffer

## Related Skills

- `@senior-project-manager` - Full project management
- `@freelance-business-manager` - Client pricing & invoicing
- `@senior-software-architect` - Technical scoping

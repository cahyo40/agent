---
name: senior-project-manager
description: "Expert project management including project briefs, PRD documents, timeline planning, stakeholder communication, and agile methodologies"
---

# Senior Project Manager

## Overview

This skill transforms you into an experienced Project Manager who creates comprehensive project documentation, manages timelines, and ensures successful project delivery through effective planning and communication.

## When to Use This Skill

- Use when creating project briefs
- Use when writing PRD documents
- Use when planning project timelines
- Use when managing stakeholder communication
- Use when the user asks about project planning

## How It Works

### Step 1: Project Brief Template

```markdown
# Project Brief: [Project Name]

## Executive Summary
One paragraph overview of the project, its goals, and expected outcomes.

## Problem Statement
What problem are we solving? Who is affected? What's the impact?

## Project Goals
1. **Primary Goal:** [Specific, measurable outcome]
2. **Secondary Goal:** [Supporting outcome]
3. **Success Metrics:** How will we measure success?

## Scope

### In Scope
- Feature/deliverable 1
- Feature/deliverable 2
- Feature/deliverable 3

### Out of Scope
- What we are NOT doing (important to clarify)

## Timeline

| Phase | Duration | Deliverables |
|-------|----------|--------------|
| Discovery | 1 week | Requirements doc |
| Design | 2 weeks | Wireframes, mockups |
| Development | 4 weeks | Working software |
| Testing | 1 week | QA sign-off |
| Launch | 1 week | Production deployment |

## Team & Resources

| Role | Person | Responsibility |
|------|--------|----------------|
| Project Manager | [Name] | Overall coordination |
| Tech Lead | [Name] | Technical decisions |
| Designer | [Name] | UI/UX design |
| Developer | [Name] | Implementation |

## Budget
Estimated budget: [Amount]
- Development: X%
- Design: X%
- Infrastructure: X%

## Risks & Mitigation

| Risk | Probability | Impact | Mitigation |
|------|-------------|--------|------------|
| Scope creep | High | High | Clear scope doc, change process |
| Resource unavailable | Medium | Medium | Cross-training, backup resources |

## Approval
- [ ] Stakeholder A
- [ ] Stakeholder B
- [ ] Budget approved
```

### Step 2: PRD (Product Requirements Document)

```markdown
# PRD: [Feature Name]

**Author:** [Name]  
**Last Updated:** [Date]  
**Status:** Draft | Review | Approved

---

## Overview

### Problem
Describe the user problem or business need.

### Solution
High-level description of the proposed solution.

### Goals
- Goal 1: [Measurable outcome]
- Goal 2: [Measurable outcome]

### Non-Goals
What this feature will NOT do (equally important).

---

## User Stories

### Epic: [Epic Name]

**As a** [user type]  
**I want** [functionality]  
**So that** [benefit]

#### Acceptance Criteria
- [ ] Criterion 1
- [ ] Criterion 2
- [ ] Criterion 3

---

## Requirements

### Functional Requirements

| ID | Requirement | Priority | Notes |
|----|-------------|----------|-------|
| FR-001 | User can create account | Must Have | Email verification required |
| FR-002 | User can reset password | Must Have | Link expires in 24h |
| FR-003 | User can enable 2FA | Should Have | Support TOTP apps |

### Non-Functional Requirements

| ID | Requirement | Target |
|----|-------------|--------|
| NFR-001 | Page load time | < 2 seconds |
| NFR-002 | Uptime | 99.9% |
| NFR-003 | Concurrent users | 10,000 |

---

## Design

### User Flow
[Link to Figma/design files]

### Wireframes
[Embed or link to wireframes]

---

## Technical Considerations

- API changes required
- Database schema updates
- Third-party integrations
- Security considerations

---

## Launch Plan

### Rollout Strategy
- [ ] Internal testing
- [ ] Beta users (10%)
- [ ] Gradual rollout (50%)
- [ ] Full launch (100%)

### Success Metrics
- Metric 1: [Target]
- Metric 2: [Target]

---

## Open Questions
1. Question that needs stakeholder input?
2. Technical decision pending?
```

### Step 3: Timeline & Milestones

```
PROJECT TIMELINE (Gantt-style)

Week 1-2: Discovery & Planning
├── Kickoff meeting
├── Requirements gathering
├── Technical assessment
└── 🎯 Milestone: Requirements signed off

Week 3-4: Design
├── Wireframes
├── UI mockups
├── Design review
└── 🎯 Milestone: Design approved

Week 5-8: Development
├── Sprint 1: Core features
├── Sprint 2: Integration
├── Sprint 3: Polish & testing
└── 🎯 Milestone: Feature complete

Week 9: QA & Testing
├── Integration testing
├── UAT
├── Bug fixes
└── 🎯 Milestone: QA sign-off

Week 10: Launch
├── Staging deployment
├── Production deployment
├── Monitoring setup
└── 🎯 Milestone: Go live ✅
```

### Step 4: Status Report Template

```markdown
# Weekly Status Report

**Project:** [Name]  
**Date:** [Date]  
**Status:** 🟢 On Track | 🟡 At Risk | 🔴 Blocked

## Summary
One paragraph summary of progress this week.

## Completed This Week
- ✅ Task 1
- ✅ Task 2
- ✅ Task 3

## In Progress
- 🔄 Task 4 (80% complete)
- 🔄 Task 5 (50% complete)

## Planned Next Week
- Task 6
- Task 7

## Blockers & Risks
| Issue | Impact | Owner | ETA |
|-------|--------|-------|-----|
| Waiting for API access | Delays integration | John | Jan 31 |

## Key Decisions Made
- Decision 1: [Rationale]

## Metrics
- Sprint velocity: X points
- Bugs open: X
- Test coverage: X%
```

## Best Practices

### ✅ Do This

- ✅ Define clear success metrics
- ✅ Document scope AND out-of-scope
- ✅ Regular status updates
- ✅ Identify risks early
- ✅ Get sign-offs in writing

### ❌ Avoid This

- ❌ Don't skip requirements phase
- ❌ Don't ignore stakeholder concerns
- ❌ Don't commit without team input
- ❌ Don't forget change management

## Related Skills

- `@senior-system-analyst` - For requirements
- `@senior-technical-writer` - For documentation

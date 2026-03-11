---
description: This workflow covers the structured handoff of a completed project to the client, operations team, or another development team.
version: 1.1.0
last_updated: 2026-03-11
skills:
  - senior-project-manager
  - senior-technical-writer
---

// turbo-all

# Workflow: Project Handoff

## Agent Behavior

When executing this workflow, the agent MUST:
- Use `senior-project-manager` for handoff checklist and acceptance documents
- Use `senior-technical-writer` for knowledge transfer materials
- Generate all 4 output files to `sdlc/07-project-handoff/`
- Never skip the Post-Launch Review — lessons learned are critical for future projects
- Document ALL credential transfers via password manager references, never plaintext

## Overview

This workflow covers the structured handoff of a completed project to the client, operations team,
or another development team. The goal is to ensure continuity, knowledge retention, and formal
acceptance.

## Output Location

**Base Folder:** `sdlc/07-project-handoff/`

**Output Files:**
- `handoff-checklist.md` - Comprehensive Handoff Checklist
- `knowledge-transfer-plan.md` - Knowledge Transfer Schedule & Materials
- `acceptance-signoff.md` - Formal Acceptance Document
- `post-launch-review.md` - Retrospective & Lessons Learned

## Prerequisites

- System deployed and stable in production
- All critical bugs resolved
- Documentation completed (`05_maintenance_operations.md`)
- Monitoring and alerting configured
- Stakeholder availability for sign-off

---

## Deliverables

### 1. Handoff Checklist

**Description:** Comprehensive checklist ensuring nothing is missed during project transition.

**Recommended Skills:** `senior-project-manager`, `senior-technical-writer`

**Instructions:**
1. Inventory all project assets
2. Verify each category is complete
3. Document access credentials and ownership
4. Confirm all environments are accessible
5. Validate backup and recovery procedures

**Output Format:**
```markdown
# Project Handoff Checklist


## Project Information
| Item | Value |
|------|-------|
| Project Name | [Name] |
| Handoff Date | [Date] |
| From | [Development Team] |
| To | [Client / Ops Team] |
| Handoff Lead | [Name] |

---


## 1. Source Code & Repository
- [ ] All code pushed to main branch
- [ ] No pending pull requests
- [ ] Branch protection rules configured
- [ ] README.md up-to-date with setup instructions
- [ ] .env.example contains all required variables
- [ ] License file included
- [ ] CHANGELOG.md updated to current version


## 2. Documentation
- [ ] Architecture documentation complete
- [ ] API documentation (Swagger/OpenAPI) generated
- [ ] Database schema documentation (ERD)
- [ ] Developer setup guide tested by non-author
- [ ] User manual / help documentation
- [ ] Operational runbooks
- [ ] Troubleshooting guide


## 3. Infrastructure & Deployment
- [ ] All environment configs documented
- [ ] CI/CD pipeline working and documented
- [ ] Docker images tagged and pushed
- [ ] SSL certificates documented (expiry dates)
- [ ] Domain and DNS records documented
- [ ] CDN configuration documented
- [ ] Backup schedule configured and tested


## 4. Access & Credentials
| Service | Owner | Access Granted To | Expiry |
|---------|-------|-------------------|--------|
| GitHub Repository | [Owner] | [Team] | N/A |
| Cloud Provider | [Owner] | [Team] | [Date] |
| Database (Prod) | [Owner] | [Team] | [Date] |
| Monitoring Dashboard | [Owner] | [Team] | N/A |
| Email Service (SMTP) | [Owner] | [Team] | [Date] |
| Payment Gateway | [Owner] | [Team] | [Date] |
| Domain Registrar | [Owner] | [Team] | [Date] |

> **SECURITY NOTE:** Use a password manager (1Password, Bitwarden)
> for credential sharing. Never share credentials via email or chat.


## 5. Testing & Quality
- [ ] All tests passing (unit, integration, e2e)
- [ ] Test coverage report generated
- [ ] Known issues documented with workarounds
- [ ] Performance test results documented
- [ ] Security scan results reviewed


## 6. Monitoring & Operations
- [ ] Health check endpoints working
- [ ] Alerting rules configured
- [ ] On-call rotation transferred
- [ ] Incident response playbook handed over
- [ ] Escalation contacts updated


## 7. Legal & Compliance
- [ ] Third-party license compliance verified
- [ ] Data privacy (GDPR/etc.) requirements documented
- [ ] Terms of service reviewed
- [ ] Security compliance checklist completed


## 8. Pending Items
| Item | Status | Owner | ETA |
|------|--------|-------|-----|
| [Pending task 1] | In Progress | [Name] | [Date] |
| [Pending task 2] | Blocked | [Name] | [Date] |


## Sign-off
| Role | Name | Signature | Date |
|------|------|-----------|------|
| Project Manager | | | |
| Tech Lead | | | |
| Client Representative | | | |
```

---

### 2. Knowledge Transfer Plan

**Description:** Structured plan for transferring project knowledge to the receiving team.

**Recommended Skills:** `senior-project-manager`, `senior-technical-writer`

**Instructions:**
1. Identify knowledge areas to transfer
2. Plan transfer sessions (live + recorded)
3. Create reference materials
4. Schedule shadowing period
5. Define competency checkpoints

**Output Format:**
```markdown
# Knowledge Transfer Plan


## Schedule Overview

| Session | Topic | Duration | Date | Presenter | Audience |
|---------|-------|----------|------|-----------|----------|
| KT-1 | Architecture & Tech Stack | 2 hours | [Date] | [Name] | All |
| KT-2 | Codebase Walkthrough | 3 hours | [Date] | [Name] | Devs |
| KT-3 | Database & Data Flow | 2 hours | [Date] | [Name] | Devs |
| KT-4 | CI/CD & Deployment | 1.5 hours | [Date] | [Name] | DevOps |
| KT-5 | Monitoring & Alerting | 1.5 hours | [Date] | [Name] | Ops |
| KT-6 | Business Logic Deep-dive | 2 hours | [Date] | [Name] | Devs |
| KT-7 | Admin & Operations | 1 hour | [Date] | [Name] | Ops |
| KT-8 | Q&A / Open Session | 2 hours | [Date] | [Name] | All |


## Session Details

### KT-1: Architecture & Tech Stack
**Objective:** Understand the overall system architecture, components, and technology choices.

**Topics:**
- System architecture diagram walkthrough (Mermaid)
- Technology stack rationale
- External service integrations
- Data flow overview
- Non-functional requirements recap

**Materials:**
- Architecture documentation
- System diagram (Mermaid)
- Technology decision records

**Recording:** [Link to recording]


## Reference Materials Checklist
- [ ] Architecture diagram (Mermaid)
- [ ] API documentation (Swagger)
- [ ] Database ERD
- [ ] Developer setup guide
- [ ] Deployment runbook
- [ ] Monitoring dashboard guide
- [ ] Session recordings uploaded
- [ ] FAQ document from Q&A session


## Shadowing Period
- **Duration:** 2 weeks after formal handoff
- **Availability:** Original team available via Slack/Teams
- **Escalation:** Original Tech Lead reachable for critical issues
- **Exit Criteria:**
  - Receiving team deploys independently
  - Receiving team resolves a P3 incident independently
  - All KT session action items completed


## Competency Checkpoints
| Checkpoint | Criteria | Verified By |
|------------|----------|-------------|
| Local setup | Can run app locally | Self-check |
| Code contribution | Submitted & merged a PR | Tech Lead |
| Deployment | Deployed to staging independently | DevOps Lead |
| Incident handling | Responded to alert w/o help | SRE Lead |
| Feature development | Delivered a small feature end-to-end | PM |
```

---

### 3. Acceptance & Sign-off

**Description:** Formal document for stakeholder acceptance of delivered project.

**Recommended Skills:** `senior-project-manager`

**Instructions:**
1. Summarize project scope and deliverables
2. Document acceptance criteria vs. actual results
3. List any deviations or scope changes
4. Include sign-off section
5. Define warranty/support terms

**Output Format:**
```markdown
# Project Acceptance & Sign-off


## Project Summary
| Item | Detail |
|------|--------|
| Project Name | [Name] |
| Start Date | [Date] |
| End Date | [Date] |
| Project Manager | [Name] |
| Client Contact | [Name] |


## Scope Delivery

### Delivered Features
| # | Feature | Status | Notes |
|---|---------|--------|-------|
| 1 | User Authentication | ✅ Delivered | JWT + OAuth |
| 2 | Product Catalog | ✅ Delivered | With search |
| 3 | Order Management | ✅ Delivered | |
| 4 | Payment Integration | ✅ Delivered | Midtrans |
| 5 | Admin Dashboard | ✅ Delivered | |
| 6 | Email Notifications | ⚠️ Partial | Welcome email only |
| 7 | Push Notifications | ❌ Deferred | Moved to Phase 2 |

### Scope Changes
| Change | Reason | Impact | Approved By |
|--------|--------|--------|-------------|
| Added OAuth login | Client request | +3 SP, +1 week | [Name], [Date] |
| Deferred Push Notif | Time constraint | Moved to Phase 2 | [Name], [Date] |


## Acceptance Criteria Results
| Criteria | Target | Actual | Status |
|----------|--------|--------|--------|
| Test Coverage | ≥ 80% | 85% | ✅ Pass |
| Performance (p95) | < 500ms | 320ms | ✅ Pass |
| Uptime (staging) | ≥ 99% | 99.7% | ✅ Pass |
| Security Scan | No critical | 0 critical | ✅ Pass |
| Accessibility | WCAG AA | Compliant | ✅ Pass |


## Known Issues
| # | Issue | Severity | Workaround | Fix ETA |
|---|-------|----------|------------|---------| 
| 1 | Slow search on 10K+ products | Low | Pagination | Phase 2 |
| 2 | PDF export timeout on large reports | Low | Limit date range | Phase 2 |


## Warranty & Support Terms
| Item | Detail |
|------|--------|
| Warranty Period | 30 days from acceptance date |
| Coverage | Bug fixes for delivered features |
| Response Time | P1: 4 hours, P2: 1 business day |
| Excluded | New features, scope changes, third-party issues |
| Support Channel | [Email / Slack channel] |
| Extended Support | Available as separate engagement |


## Formal Acceptance

By signing below, the parties acknowledge that the project has been delivered according to
the agreed scope (with documented deviations) and accept the deliverables.

| Role | Name | Signature | Date |
|------|------|-----------|------|
| Client Sponsor | | | |
| Client PM | | | |
| Delivery Lead | | | |
| Tech Lead | | | |
```

---

### 4. Post-Launch Review

**Description:** Retrospective analysis after project completion to capture lessons learned
and improvement areas.

**Recommended Skills:** `senior-project-manager`

**Instructions:**
1. Gather feedback from all team members
2. Analyze project metrics (timeline, budget, quality)
3. Document what went well and what didn't
4. Create actionable improvement items
5. Archive for future reference

**Output Format:**
```markdown
# Post-Launch Review / Retrospective


## Project Metrics
| Metric | Planned | Actual | Variance |
|--------|---------|--------|----------|
| Duration | 8 weeks | 9 weeks | +12.5% |
| Story Points | 120 SP | 115 SP | -4.2% |
| Budget | $XX,XXX | $XX,XXX | +X% |
| Test Coverage | 80% | 85% | +5% |
| Bugs in Production (30d) | < 5 | 3 | ✅ |
| Customer Satisfaction | 8/10 | 8.5/10 | ✅ |


## What Went Well 🎉
1. **Clean Architecture adoption** — made testing and onboarding easy
2. **Early CI/CD setup** — caught bugs before staging
3. **Daily standups** — kept everyone aligned
4. **Client communication** — weekly demos reduced rework


## What Could Be Improved 🔧
1. **Estimation accuracy** — underestimated payment integration
2. **Late design changes** — UI redesign in Sprint 3 caused delays
3. **Test environment parity** — staging didn't match prod config
4. **Documentation timing** — docs written too late in the cycle


## Action Items for Future Projects
| # | Action | Owner | Priority |
|---|--------|-------|----------|
| 1 | Add 30% buffer for third-party integrations | PM | High |
| 2 | Lock UI design before Sprint 2 starts | Designer | High |
| 3 | Use Docker Compose for staging parity | DevOps | Medium |
| 4 | Write docs incrementally with each sprint | Tech Writer | Medium |
| 5 | Add performance testing from Sprint 2 | QA | Medium |


## Team Kudos 🏆
- [Name] — outstanding API design
- [Name] — proactive bug hunting
- [Name] — excellent client communication

---

## Archive Location
- Repository: [GitHub URL]
- Documentation: [Confluence/Notion URL]
- Recordings: [Drive/Notion URL]
```

---

## Workflow Steps

1. **Handoff Preparation** (Project Manager, Tech Lead)
   - Inventory all project assets
   - Verify completion of all categories
   - Prepare credential transfer plan

2. **Knowledge Transfer Sessions** (All Team Leads)
   - Schedule and conduct KT sessions
   - Record all sessions
   - Create reference materials

3. **Acceptance Review** (Project Manager, Client)
   - Present delivered features vs. agreed scope
   - Document any deviations
   - Obtain formal sign-off

4. **Post-Launch Review** (Full Team)
   - Retrospective meeting
   - Document lessons learned
   - Create action items for future projects

---

## Workflow Validation Checklist

### Pre-Execution
- [ ] System deployed and stable in production
- [ ] All critical bugs resolved
- [ ] Documentation completed (`05_maintenance_operations.md`)
- [ ] Monitoring and alerting configured
- [ ] Stakeholder availability for sign-off confirmed
- [ ] Output folder structure created: `sdlc/07-project-handoff/`

### During Execution
- [ ] Handoff Checklist created and populated
- [ ] All project assets inventoried
- [ ] Access credentials documented (via password manager)
- [ ] All environments accessible to receiving team
- [ ] Knowledge Transfer Plan created
- [ ] KT sessions scheduled and recorded
- [ ] Shadowing period defined
- [ ] Competency checkpoints established
- [ ] Acceptance & Sign-off document prepared
- [ ] Scope delivery documented
- [ ] Known issues logged
- [ ] Post-Launch Review document created
- [ ] Project metrics analyzed (timeline, budget, quality)
- [ ] Lessons learned documented
- [ ] Action items created for future projects

### Post-Execution
- [ ] Handoff checklist 100% complete
- [ ] All KT sessions completed with recordings archived
- [ ] Receiving team passes competency checkpoints
- [ ] Formal acceptance signed by all parties
- [ ] Credentials transferred securely
- [ ] Support channels activated
- [ ] Post-Launch Review completed and archived
- [ ] Warranty period terms confirmed

---

## Cross-References

- **Previous Phase** → `05_maintenance_operations.md`
- **Related** → `01_requirement_analysis.md` (initial vs final scope comparison)
- **SDLC Mapping** → `../../other/sdlc/SDLC_MAPPING.md`
- **Archive Location:** Repository, Documentation, Recordings URLs documented

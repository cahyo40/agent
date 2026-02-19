---
description: This workflow covers the structured handoff of a completed project. (Sub-part 2/2)
---
### 4. Post-Launch Review

**Description:** Retrospective analysis after project completion to
capture lessons learned and improvement areas.

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


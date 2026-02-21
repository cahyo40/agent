---
description: This workflow handles change requests and scope modifications during project execution.
version: 1.0.0
last_updated: 2024-02-21
---
# Workflow: Change Request Management

## Overview
This workflow handles change requests and scope modifications that occur during project execution. The goal is to manage changes systematically, assess impact, and maintain project control.

## Output Location
**Base Folder:** `sdlc/08-change-request/`

**Output Files:**
- `change-request-log.md` - Master log of all change requests
- `change-request-form.md` - Individual change request documents
- `impact-analysis.md` - Impact assessment for each change
- `change-approval-workflow.md` - Approval process and decisions

## Prerequisites
- Baseline scope documented (`01_requirement_analysis.md`)
- Project estimation completed (`06_data_modeling_estimation.md`)
- Change request received from stakeholder
- Project manager assigned

## When to Use This Workflow

| Scenario | Use Change Request |
|----------|-------------------|
| New feature requested after scope approval | ✅ Yes |
| UI/UX modification that affects timeline | ✅ Yes |
| Technology stack change | ✅ Yes |
| Bug fix within original scope | ❌ No |
| Minor text/copy change | ❌ No |
| Performance optimization (within NFR) | ❌ No |

---

## Deliverables

### 1. Change Request Form

**Description:** Standardized form for documenting change requests.

**Recommended Skills:** `senior-project-manager`

**Instructions:**
1. Assign unique CR-ID (e.g., CR-001, CR-002)
2. Document requester information
3. Describe the change clearly
4. Justify the reason for change
5. Assess initial priority

**Output Format:**
```markdown
# Change Request Form

## CR-001: [Change Title]

### Basic Information
| Field | Value |
|-------|-------|
| CR-ID | CR-001 |
| Requested By | [Name/Role] |
| Date Submitted | [YYYY-MM-DD] |
| Project | [Project Name] |
| Status | Pending / Approved / Rejected / Deferred |

### Change Description
**Current State:**
[Describe how it works now]

**Requested Change:**
[Describe what should change]

**Expected Outcome:**
[What benefit will this bring]

### Justification
**Reason for Change:**
- [ ] Business requirement changed
- [ ] Regulatory/compliance requirement
- [ ] User feedback
- [ ] Technical constraint discovered
- [ ] Competitive pressure
- [ ] Other: [Specify]

**Priority:**
- [ ] Critical (Must have)
- [ ] High (Should have)
- [ ] Medium (Nice to have)
- [ ] Low (Future consideration)

### Attachments
- [ ] Mockups/wireframes
- [ ] Technical specifications
- [ ] Business case document
```

---

### 2. Impact Analysis

**Description:** Comprehensive assessment of change impact on project.

**Recommended Skills:** `senior-project-manager`, `senior-software-architect`, `project-estimator`

**Instructions:**
1. Analyze impact on timeline
2. Analyze impact on cost/budget
3. Analyze impact on resources
4. Analyze technical impact
5. Analyze risk implications
6. Document dependencies affected

**Output Format:**
```markdown
# Impact Analysis: CR-001

## Timeline Impact
| Item | Original | With Change | Variance |
|------|----------|-------------|----------|
| Sprint 3 | 2 weeks | 2.5 weeks | +0.5 weeks |
| Sprint 4 | 2 weeks | 2 weeks | - |
| **Total** | **8 weeks** | **8.5 weeks** | **+0.5 weeks** |

**New Milestones:**
- [Milestone 1]: [New date]
- [Milestone 2]: [New date]

## Cost Impact
| Category | Original | With Change | Variance |
|----------|----------|-------------|----------|
| Development | $XX,XXX | $XX,XXX | +$X,XXX |
| Testing | $X,XXX | $X,XXX | +$XXX |
| Infrastructure | $X,XXX | $X,XXX | - |
| **Total** | **$XX,XXX** | **$XX,XXX** | **+$X,XXX** |

**Additional Costs:**
- [Item 1]: $XXX (justification)
- [Item 2]: $XXX (justification)

## Resource Impact
| Role | Current Allocation | Additional Needed |
|------|-------------------|-------------------|
| Backend Developer | 2 FTE | +0.5 FTE for 2 weeks |
| Frontend Developer | 2 FTE | - |
| QA Engineer | 1 FTE | +0.5 FTE for 1 week |
| Designer | 0.5 FTE | +0.5 FTE for 1 week |

## Technical Impact
**Components Affected:**
- [ ] Frontend (React/Flutter)
- [ ] Backend API
- [ ] Database schema
- [ ] Third-party integrations
- [ ] Infrastructure
- [ ] Security

**Architecture Changes Required:**
[Describe any architectural modifications]

**Breaking Changes:**
- [ ] API contract changes
- [ ] Database migration required
- [ ] Client update required
- [ ] Documentation update required

## Risk Impact
| Risk | Original Rating | New Rating | Mitigation |
|------|----------------|------------|------------|
| [Risk 1] | 🟡 Medium | 🔴 High | [Mitigation plan] |
| [Risk 2] | 🟢 Low | 🟡 Medium | [Mitigation plan] |

**New Risks Introduced:**
1. [Risk description] - [Severity] - [Mitigation]

## Dependencies Affected
| Dependency | Impact | Action Required |
|------------|--------|-----------------|
| [Module A] | Interface change | Update API contract |
| [Module B] | Data format change | Migration script |
| [External API] | New endpoint needed | Integration work |

## Recommendation
**Suggested Decision:**
- [ ] Approve as requested
- [ ] Approve with modifications: [Specify]
- [ ] Defer to Phase 2
- [ ] Reject

**Rationale:**
[Explain reasoning]
```

---

### 3. Change Request Log

**Description:** Master tracker for all change requests.

**Recommended Skills:** `senior-project-manager`

**Instructions:**
1. Maintain single source of truth for all CRs
2. Update status regularly
3. Link to related documents
4. Track approval workflow

**Output Format:**
```markdown
# Change Request Log

## Summary
| CR-ID | Title | Requested By | Date | Status | Impact | Decision |
|-------|-------|--------------|------|--------|--------|----------|
| CR-001 | Add OAuth login | Product Owner | 2024-01-15 | ✅ Approved | +1 week, +$5K | Approved 2024-01-17 |
| CR-002 | Dark mode support | Client | 2024-01-20 | ⏳ Pending | TBD | - |
| CR-003 | Push notifications | Marketing | 2024-01-22 | ❌ Rejected | +2 weeks | Rejected 2024-01-25 |
| CR-004 | Export to PDF | Client | 2024-01-25 | 🔄 In Review | +3 days | - |
| CR-005 | Multi-language | Product Owner | 2024-02-01 | ⏸️ Deferred | +3 weeks | Deferred to Phase 2 |

## Status Legend
| Status | Meaning |
|--------|---------|
| ⏳ Pending | Awaiting impact analysis |
| 🔄 In Review | Under stakeholder review |
| ✅ Approved | Change approved for implementation |
| ❌ Rejected | Change rejected |
| ⏸️ Deferred | Deferred to future phase |
| 🚧 In Progress | Being implemented |
| ✅ Completed | Implemented and verified |

## CR-001 Details
- **Link to Form:** `change-request-form-cr-001.md`
- **Link to Impact Analysis:** `impact-analysis-cr-001.md`
- **Approval Date:** 2024-01-17
- **Approved By:** [Client Name]
- **Implementation Sprint:** Sprint 2
- **Status:** ✅ Completed

## CR-002 Details
[Continue for each CR...]
```

---

### 4. Change Approval Workflow

**Description:** Process for reviewing and approving change requests.

**Recommended Skills:** `senior-project-manager`

**Instructions:**
1. Define approval authority matrix
2. Document review process
3. Set SLA for decisions
4. Track approval trail

**Output Format:**
```markdown
# Change Approval Workflow

## Approval Authority Matrix

| Change Impact | Approval Required From | SLA |
|---------------|----------------------|-----|
| Low (< 3 days, < $2K) | Project Manager | 2 days |
| Medium (3-7 days, $2K-$10K) | PM + Client PM | 5 days |
| High (> 7 days, > $10K) | PM + Client PM + Sponsor | 7 days |
| Critical (Architecture/Budget > 20%) | Steering Committee | 10 days |

## Review Process

```plantuml
@startuml
start

:Change Request Submitted;
:PM assigns CR-ID;
:PM creates Impact Analysis;

if (Impact Level?) then (Low)
  :PM approves/rejects;
else (Medium)
  :Client PM reviews;
  :Client PM approves/rejects;
else (High/Critical)
  :Client PM reviews;
  :Sponsor reviews;
  :Steering Committee (if Critical);
endif

if (Approved?) then (yes)
  :Update Change Log;
  :Update Project Plan;
  :Notify stakeholders;
  :Implement change;
  :Verify implementation;
  :Close CR;
else (no)
  :Document rejection reason;
  :Notify requester;
  :Archive CR;
endif

stop
@enduml
```

## Approval Form Template

```markdown
## Approval Decision: CR-001

| Role | Name | Decision | Date | Signature |
|------|------|----------|------|-----------|
| Project Manager | [Name] | ✅ Recommended | 2024-01-16 | |
| Client PM | [Name] | ✅ Approved | 2024-01-17 | |
| Sponsor | [Name] | ✅ Approved | 2024-01-17 | |

**Conditions:**
- [ ] Budget approval confirmed
- [ ] Timeline adjustment accepted
- [ ] Resource allocation confirmed
- [ ] Stakeholders notified

**Next Steps:**
1. Update project plan by [Date]
2. Communicate to team by [Date]
3. Begin implementation [Date]
```
```

---

## Workflow Steps

1. **Change Request Received** (Senior Project Manager)
   - Log change request in CR Log
   - Assign CR-ID
   - Acknowledge receipt to requester

2. **Initial Assessment** (Senior Project Manager)
   - Determine if change is within scope or requires CR
   - If within scope, route to appropriate team
   - If out of scope, proceed with CR process

3. **Impact Analysis** (Senior Project Manager, Tech Lead, Architect)
   - Analyze timeline impact
   - Analyze cost impact
   - Analyze resource impact
   - Analyze technical impact
   - Analyze risk impact
   - Document findings

4. **Review & Decision** (Approvers per matrix)
   - Present impact analysis to approvers
   - Address questions/concerns
   - Obtain approval/rejection decision
   - Document decision trail

5. **Communication** (Senior Project Manager)
   - Notify requester of decision
   - Update Change Request Log
   - Communicate to project team
   - Update project documentation

6. **Implementation** (Development Team)
   - Update project plan
   - Update sprint backlog
   - Implement change
   - Test and verify

7. **Closure** (Senior Project Manager)
   - Verify implementation complete
   - Update CR status to Completed
   - Archive documentation
   - Update lessons learned

---

## Workflow Validation Checklist

### Pre-Execution
- [ ] Baseline scope documented
- [ ] Change request received in writing
- [ ] Project manager assigned
- [ ] Output folder created: `sdlc/08-change-request/`

### During Execution
- [ ] Change Request Form completed
- [ ] Impact Analysis documented (timeline, cost, resources, technical, risk)
- [ ] Approval Authority Matrix consulted
- [ ] Approvers identified and contacted
- [ ] Decision documented with signatures
- [ ] Change Request Log updated

### Post-Execution
- [ ] Decision communicated to all stakeholders
- [ ] Project plan updated (if approved)
- [ ] Sprint backlog updated (if approved)
- [ ] Implementation verified
- [ ] CR status updated to Completed
- [ ] Documentation archived

---

## Success Criteria
- All change requests documented with unique CR-ID
- Impact analysis completed for each CR
- Approval trail documented and auditable
- Stakeholders notified of decisions within SLA
- Project plan updated to reflect approved changes
- No scope creep (all changes tracked formally)

---

## Cross-References

- **Related** → `01_requirement_analysis.md` (Baseline scope)
- **Related** → `06_data_modeling_estimation.md` (Re-estimation if needed)
- **Related** → `07_project_handoff.md` (Scope verification at handoff)
- **SDLC Mapping** → `../../other/sdlc/SDLC_MAPPING.md`

---

## Tools & Templates
- Change Request Form template
- Impact Analysis template
- Change Request Log (spreadsheet/markdown)
- Approval workflow diagram
- Email/notification templates

---

## Example Agent Prompts

### Create Change Request
```
"Gunakan workflow 08_change_request.md untuk membuat change request form 
untuk fitur baru: 'Wishlist functionality'. Requested by: Product Owner, 
Date: 2024-02-21. Prioritas: High."
```

### Impact Analysis
```
"Jalankan impact analysis menggunakan workflow 08_change_request.md untuk 
CR-001 (Wishlist feature). Assess impact pada: timeline (+1 sprint?), 
cost (+$X?), resources (+1 frontend developer?), technical (database 
schema change?), dan risks."
```

### Update Change Log
```
"Update Change Request Log dengan CR-001 (Approved, +1 week), CR-002 
(Pending), CR-003 (Rejected). Include summary table dan status legend."
```

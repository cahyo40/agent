# Workflow: Requirement Analysis

## Overview
This workflow covers the first phase of SDLC: Requirement Analysis. The goal is to identify business needs and user requirements clearly.

## Output Location
**Base Folder:** `sdlc/01-requirement-analysis/`

**Output Files:**
- `functional-requirements.md` - Functional Requirements Document
- `non-functional-requirements.md` - Non-Functional Requirements Document  
- `user-stories-prd.md` - User Stories and Product Requirements Document

## Prerequisites
- Project charter or business case document
- Stakeholder identification
- Access to business domain experts

## Deliverables

### 1. Functional Requirements

**Description:** Detailed description of system features and capabilities.

**Recommended Skills:** `senior-system-analyst`

**Instructions:**
1. Conduct stakeholder interviews to understand business needs
2. Document functional requirements using the following structure:
   - FR-XXX: [Requirement ID]
   - Description: [What the system should do]
   - Priority: [High/Medium/Low]
   - Acceptance Criteria: [Measurable conditions]
3. Categorize requirements by feature modules
4. Validate requirements with stakeholders

**Output Format:**
```markdown
## Functional Requirements Document

### FR-001: [Feature Name]
**Description:** [Detailed description]
**Priority:** High/Medium/Low
**Acceptance Criteria:**
- Criteria 1
- Criteria 2
```

---

### 2. Non-Functional Requirements

**Description:** Operational constraints like performance, security, and scalability.

**Recommended Skills:** `senior-system-analyst`, `senior-software-architect`

**Instructions:**
1. Define performance requirements (response time, throughput)
2. Document security requirements (authentication, authorization, data protection)
3. Specify scalability requirements (concurrent users, data volume)
4. Outline availability and reliability targets (SLA)
5. Define compliance requirements (GDPR, HIPAA, etc.)

**Output Format:**
```markdown
## Non-Functional Requirements

### Performance
- Response time: < 2 seconds for 95% of requests
- Throughput: Support 1000 concurrent users

### Security
- Authentication: OAuth 2.0 / JWT
- Data encryption: AES-256

### Scalability
- Horizontal scaling capability
- Database sharding support

### Availability
- Uptime SLA: 99.9%
- RTO: 4 hours, RPO: 1 hour
```

---

### 3. User Stories & PRD

**Description:** Feature descriptions from user perspective with acceptance criteria.

**Recommended Skills:** `senior-project-manager`

**Instructions:**
1. Identify user personas
2. Write user stories in format: "As a [role], I want [feature], so that [benefit]"
3. Create Product Requirements Document (PRD) with:
   - Product vision and objectives
   - User personas
   - User stories organized by epics
   - Acceptance criteria for each story
   - Success metrics
4. Prioritize stories using MoSCoW method

**Output Format:**
```markdown
# Product Requirements Document (PRD)

## Product Vision
[Brief statement of product purpose]

## User Personas
### Persona 1: [Name]
- Role: [Job title]
- Goals: [What they want to achieve]
- Pain Points: [Current frustrations]

## User Stories

### Epic 1: [Epic Name]
**US-001:** As a [role], I want [action], so that [benefit]
- Acceptance Criteria:
  1. [Criteria 1]
  2. [Criteria 2]
- Priority: Must have
- Story Points: [Fibonacci number]

## Success Metrics
- Metric 1: [Target]
- Metric 2: [Target]
```

## Workflow Steps

1. **Stakeholder Analysis** (Senior System Analyst)
   - Identify all stakeholders
   - Schedule interview sessions
   - Document business context

2. **Requirements Gathering** (Senior System Analyst)
   - Conduct interviews
   - Review existing documentation
   - Analyze current system (if applicable)

3. **Requirements Documentation** (Senior System Analyst)
   - Write functional requirements
   - Define non-functional requirements with Architect
   - Create initial draft

4. **User Story Development** (Senior Project Manager)
   - Transform requirements into user stories
   - Create PRD document
   - Prioritize backlog

5. **Review & Validation**
   - Present to stakeholders
   - Gather feedback
   - Revise and finalize

## Success Criteria
- All functional requirements have clear acceptance criteria
- Non-functional requirements are measurable
- User stories follow INVEST principles
- PRD approved by stakeholders
- Requirements traceability matrix created

## Tools & Templates
- Requirements specification template
- User story mapping board
- Prioritization matrix
- Stakeholder register

---

## Additional Templates

### Stakeholder Register (RACI Matrix)

```markdown
## Stakeholder Register

| Stakeholder | Role | Interest Level | Influence | Communication |
|-------------|------|---------------|-----------|---------------|
| [Name] | Product Owner | High | High | Weekly review |
| [Name] | Tech Lead | High | High | Daily standup |
| [Name] | End User Rep | Medium | Medium | Sprint demo |
| [Name] | CTO | Low | High | Monthly report |

## RACI Matrix

| Activity | Product Owner | Tech Lead | Designer | Dev Team | QA |
|----------|:---:|:---:|:---:|:---:|:---:|
| Requirements approval | **A** | C | I | I | I |
| Architecture decision | C | **A** | I | R | I |
| UI/UX design | C | I | **A** | I | I |
| Sprint planning | **A** | R | C | R | C |
| Code review | I | **A** | - | R | I |
| Release approval | **A** | R | I | I | R |

> **R** = Responsible, **A** = Accountable, **C** = Consulted, **I** = Informed
```

### Requirements Traceability Matrix (RTM)

```markdown
## Requirements Traceability Matrix

| Req ID | Requirement | User Story | Design Doc | Test Case | Status |
|--------|-------------|-----------|-----------|-----------|--------|
| FR-001 | User login | US-001 | class-diagram.puml | TC-001, TC-002 | ✅ Implemented |
| FR-002 | Product CRUD | US-005 | sequence-diagram.puml | TC-010 | 🔄 In Progress |
| FR-003 | Payment | US-012 | api-specification.yaml | TC-020 | ⏳ Planned |
| NFR-001 | Response < 500ms | - | system-architecture.md | PERF-001 | ⏳ Planned |
| NFR-002 | 99.9% uptime | - | deployment-architecture.md | MON-001 | ⏳ Planned |

### RTM Coverage Summary
| Category | Total | Designed | Implemented | Tested |
|----------|------:|--------:|------------:|-------:|
| Functional | 25 | 20 (80%) | 15 (60%) | 12 (48%) |
| Non-Functional | 8 | 6 (75%) | 4 (50%) | 2 (25%) |
```

### Risk Register

```markdown
## Risk Register

| Risk ID | Description | Probability | Impact | Score | Mitigation | Owner | Status |
|---------|-------------|:-----------:|:------:|:-----:|------------|-------|--------|
| R-001 | Key developer leaves project | Medium | High | 🔴 | Cross-training, documentation | PM | Open |
| R-002 | Third-party API deprecation | Low | High | 🟡 | Adapter pattern, abstraction | Tech Lead | Open |
| R-003 | Scope creep from stakeholders | High | Medium | 🔴 | Strict change request process | PM | Monitoring |
| R-004 | Performance not meeting NFR | Medium | Medium | 🟡 | Early load testing (Sprint 2) | QA | Open |
| R-005 | Security vulnerability discovered | Low | High | 🟡 | Regular security scans, SAST | Security | Open |

### Risk Scoring
- **Probability:** Low (1) / Medium (2) / High (3)
- **Impact:** Low (1) / Medium (2) / High (3)
- **Score:** P × I → 🟢 1-2  🟡 3-4  🔴 6-9
```

---

## Cross-References

- **Estimation & Sprint Planning** → `06_data_modeling_estimation.md` (Project Estimation section)
- **UI/UX Design** → `02_ui_ux_design.md`
- **Technical Design** → `03_system_detailed_design.md`
- **SDLC Mapping** → `../../other/sdlc/SDLC_MAPPING.md`


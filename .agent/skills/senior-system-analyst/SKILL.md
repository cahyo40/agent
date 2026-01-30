---
name: senior-system-analyst
description: "Expert system analysis including requirements gathering, business process modeling, use case design, and bridging business needs with technical solutions"
---

# Senior System Analyst

## Overview

This skill transforms you into an experienced Senior System Analyst who bridges the gap between business stakeholders and technical teams. You'll gather and document requirements, model business processes, design solutions, and ensure that technical implementations align with business objectives.

## When to Use This Skill

- Use when gathering and documenting requirements
- Use when analyzing existing systems for improvements
- Use when modeling business processes
- Use when creating use cases and user stories
- Use when validating solutions against business needs
- Use when the user asks about requirements or specifications
- Use when creating functional specifications

## How It Works

### Step 1: Requirements Gathering

```
REQUIREMENTS GATHERING TECHNIQUES
┌─────────────────────────────────────────────────────────────────┐
│                                                                 │
│  1. INTERVIEWS              One-on-one with stakeholders       │
│     ├── Structured          Predefined questions               │
│     ├── Semi-structured     Guided but flexible                │
│     └── Unstructured        Open conversation                  │
│                                                                 │
│  2. WORKSHOPS               Group sessions                     │
│     ├── JAD                 Joint Application Development      │
│     ├── Brainstorming       Idea generation                   │
│     └── Focus Groups        Targeted discussions               │
│                                                                 │
│  3. OBSERVATION             Watch users work                   │
│     ├── Active              Ask questions while observing      │
│     └── Passive             Silent observation                 │
│                                                                 │
│  4. DOCUMENT ANALYSIS       Review existing materials          │
│     ├── Current system docs                                    │
│     ├── Business rules                                         │
│     └── Regulatory requirements                                │
│                                                                 │
│  5. PROTOTYPING            Validate with mockups               │
│     ├── Low-fidelity        Wireframes, sketches              │
│     └── High-fidelity       Interactive prototypes            │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### Step 2: Document Requirements

```
REQUIREMENTS TYPES
├── FUNCTIONAL REQUIREMENTS
│   ├── What the system should DO
│   ├── Features and capabilities
│   ├── Business rules and logic
│   └── Example: "System shall allow users to reset password"
│
├── NON-FUNCTIONAL REQUIREMENTS (Quality Attributes)
│   ├── Performance: Response time < 2 seconds
│   ├── Security: Support 2FA authentication
│   ├── Availability: 99.9% uptime
│   ├── Scalability: Support 10,000 concurrent users
│   └── Usability: Accessible (WCAG 2.1 AA)
│
├── CONSTRAINTS
│   ├── Technical: Must use existing Oracle database
│   ├── Business: Budget limit $500K
│   ├── Timeline: Launch by Q3 2026
│   └── Regulatory: GDPR compliance required
│
└── ASSUMPTIONS & DEPENDENCIES
    ├── Assumption: Users have internet access
    └── Dependency: Third-party payment gateway
```

### Step 3: Create Use Cases

```
USE CASE TEMPLATE
┌─────────────────────────────────────────────────────────────────┐
│ USE CASE: UC-001 User Registration                             │
├─────────────────────────────────────────────────────────────────┤
│ Actor:           End User                                       │
│ Precondition:    User has valid email address                  │
│ Trigger:         User clicks "Sign Up" button                  │
├─────────────────────────────────────────────────────────────────┤
│ MAIN FLOW:                                                      │
│ 1. User enters email and password                              │
│ 2. System validates input                                      │
│ 3. System checks email uniqueness                              │
│ 4. System creates account                                      │
│ 5. System sends verification email                             │
│ 6. User clicks verification link                               │
│ 7. System activates account                                    │
├─────────────────────────────────────────────────────────────────┤
│ ALTERNATIVE FLOWS:                                              │
│ 3a. Email exists → Show "email already registered"             │
│ 6a. Link expired → Allow resend verification                   │
├─────────────────────────────────────────────────────────────────┤
│ EXCEPTION FLOWS:                                                │
│ 2a. Invalid input → Show validation errors                     │
├─────────────────────────────────────────────────────────────────┤
│ Postcondition:   User account created and verified             │
└─────────────────────────────────────────────────────────────────┘
```

### Step 4: Model Business Processes

```
BPMN PROCESS EXAMPLE: Order Fulfillment
┌─────────────────────────────────────────────────────────────────┐
│                                                                 │
│  ○────▶[Receive Order]────▶◇ Payment OK? ────▶[Pack Items]     │
│  Start                     │                        │          │
│                        No  ▼                        ▼          │
│                    [Notify Customer]         [Ship Order]      │
│                            │                        │          │
│                            ▼                        ▼          │
│                           ◉                  [Update Status]   │
│                          End                        │          │
│                                                     ▼          │
│                                              [Send Tracking]   │
│                                                     │          │
│                                                     ▼          │
│                                                    ◉           │
│                                                   End          │
└─────────────────────────────────────────────────────────────────┘

LEGEND: ○ Start  ◉ End  [Task]  ◇ Gateway  ─▶ Flow
```

### Step 5: Write User Stories

```
USER STORY FORMAT
┌─────────────────────────────────────────────────────────────────┐
│ As a [ROLE]                                                     │
│ I want [ACTION/FEATURE]                                        │
│ So that [BENEFIT/VALUE]                                        │
├─────────────────────────────────────────────────────────────────┤
│ ACCEPTANCE CRITERIA (Given-When-Then):                         │
│                                                                 │
│ GIVEN I am logged in as a customer                             │
│ WHEN I add an item to cart                                     │
│ THEN I see cart counter increment                              │
│ AND item appears in cart list                                  │
│ AND cart total updates                                         │
├─────────────────────────────────────────────────────────────────┤
│ STORY POINTS: 5                                                │
│ PRIORITY: High                                                 │
│ DEPENDENCIES: User authentication (US-001)                     │
└─────────────────────────────────────────────────────────────────┘
```

## Examples

### Example 1: Requirements Specification Document

```markdown
# Software Requirements Specification (SRS)
## E-Commerce Platform v2.0

### 1. Introduction
#### 1.1 Purpose
This document specifies requirements for the e-commerce platform.

#### 1.2 Scope
Online shopping platform supporting B2C transactions.

### 2. Functional Requirements

#### FR-001: User Registration
- **Priority:** High
- **Description:** Users can create accounts with email/password
- **Acceptance Criteria:**
  - Valid email format required
  - Password min 8 chars with complexity
  - Email verification required
  - Duplicate email prevention

#### FR-002: Product Search
- **Priority:** High
- **Description:** Users can search products by keyword
- **Acceptance Criteria:**
  - Search by name, description, SKU
  - Results within 1 second
  - Pagination (20 items/page)
  - Filter by category, price, rating

### 3. Non-Functional Requirements

| ID | Category | Requirement | Measure |
|----|----------|-------------|---------|
| NFR-001 | Performance | Page load time | < 3 seconds |
| NFR-002 | Scalability | Concurrent users | 10,000 |
| NFR-003 | Availability | Uptime | 99.9% |
| NFR-004 | Security | Data encryption | AES-256 |
```

### Example 2: Gap Analysis

```
CURRENT STATE vs FUTURE STATE
┌─────────────────────────────────────────────────────────────────┐
│ AREA          │ CURRENT (AS-IS)    │ FUTURE (TO-BE)   │ GAP    │
├───────────────┼────────────────────┼──────────────────┼────────┤
│ Order Process │ Manual, 2 days     │ Automated, 2 hrs │ HIGH   │
│ Inventory     │ Excel spreadsheet  │ Real-time system │ HIGH   │
│ Reporting     │ Monthly, manual    │ Real-time, auto  │ MEDIUM │
│ Customer DB   │ Separate systems   │ Unified CRM      │ HIGH   │
│ Payments      │ Bank transfer only │ Multi-gateway    │ MEDIUM │
└───────────────┴────────────────────┴──────────────────┴────────┘
```

## Best Practices

### ✅ Do This

- ✅ Validate requirements with stakeholders regularly
- ✅ Use clear, unambiguous language
- ✅ Prioritize requirements (MoSCoW: Must/Should/Could/Won't)
- ✅ Trace requirements to business objectives
- ✅ Include acceptance criteria for testability
- ✅ Maintain requirements traceability matrix
- ✅ Document assumptions and constraints explicitly
- ✅ Use visual models (diagrams, mockups) to clarify

### ❌ Avoid This

- ❌ Don't assume you understand—verify
- ❌ Don't use technical jargon with business users
- ❌ Don't document solutions, document problems
- ❌ Don't skip non-functional requirements
- ❌ Don't create requirements in isolation
- ❌ Don't forget edge cases and exception flows

## Common Pitfalls

**Problem:** Scope creep during development
**Solution:** Freeze requirements after sign-off, use change control process.

**Problem:** Ambiguous requirements
**Solution:** Use acceptance criteria with concrete examples (Given-When-Then).

**Problem:** Missing stakeholder input
**Solution:** Identify and involve all stakeholders early with RACI matrix.

**Problem:** Requirements not testable
**Solution:** Each requirement should have measurable acceptance criteria.

## Related Skills

- `@senior-software-architect` - For technical solution design
- `@expert-senior-software-engineer` - For implementation planning
- `@senior-ui-ux-designer` - For user experience requirements

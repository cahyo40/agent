---
name: senior-project-manager
description: "Expert project management including project briefs, PRD documents, timeline planning, stakeholder communication, and agile methodologies"
---

# Senior Project Manager

## Overview

This skill transforms you into a **Technical Program Manager (TPM)**. You will move beyond "Jira Ticket Mover" to **Strategic Planning**. You will master **Agile Estimation (Points vs Hours)**, writing **Product Requirement Documents (PRDs)**, managing **Stakeholder Expectations**, and handling **Scope Creep**.

## When to Use This Skill

- Use when starting a new Feature/Epic (Planning)
- Use when the project is delayed (Risk Management)
- Use when requirements change mid-sprint (Agile Adaptation)
- Use when negotiating priorities with Stakeholders
- Use when defining "Done" (Definition of Done - DoD)

---

## Part 1: Product Requirement Document (PRD)

The Bible of the project. If it's not written down, it doesn't exist.

### 1.1 Key Sections

1. **Problem Statement**: Why are we doing this? (Business Value).
2. **User Stories**: "As a [User], I want to [Action], so that [Benefit]."
3. **Scope (In/Out)**: Explicitly state what we are *NOT* building.
4. **Success Metrics**: "Reduce login time by 20%".
5. **Technical Constraints**: "Must run on iOS 15+".

### 1.2 RFCs (Request for Comments)

For technical decisions, use RFCs before writing code.
"We propose using Redis for caching because..." -> Team comments -> Consensus.

---

## Part 2: Agile & Estimation

Stop lying about timelines.

### 2.1 Points vs Hours

- **Hours**: "This takes 4 hours". (Fragile. Interruptions happen).
- **Points (Complexity)**: "This is a 5-point story". (Robust. Velocity averages out).
  - 1: Typo fix.
  - 3: Standard feature.
  - 8: Risky/Unknowns. Needs breakdown.

### 2.2 Cone of Uncertainty

At the start, estimates are ±400% wrong. As you build, variance drops.
*Communication*: "We are 60% confident this will land in Q3." (Don't promise dates early).

---

## Part 3: Stakeholder Management

Managing upwards.

### 3.1 The "Iron Triangle"

Quality, Speed, Cost. Pick two.
"We can ship by Friday (Speed), but we have to cut the Reporting Feature (Scope/Cost), or risking bugs (Quality)."

### 3.2 Status Reports (Weekly)

Don't just list tasks. List Risks and Blockers.

- **Green**: On track.
- **Yellow**: Risk identified (e.g., API dependency delayed).
- **Red**: Blocked. Will miss deadline unless action taken.

---

## Part 4: Managing Scope Creep

Stakeholder: "Can we just add a small chat feature?"

**The Response:**
"Yes, we can add Chat. However, that adds 13 points to the scope. To keep the Deadline, we need to remove 13 points elsewhere. Which feature should we cut?"

**MoSCoW Method:**

- **Must Have**: Login, Payment.
- **Should Have**: Email Receipt.
- **Could Have**: Dark Mode.
- **Won't Have**: VR Support.

---

## Part 5: The Definition of Done (DoD)

Prevents "It's done but logic is broken" state.

**A ticket is DONE when:**

1. Code is merged to `main`.
2. Unit Tests pass.
3. QA verified on `staging`.
4. Feature Flag enabled.
5. Docs updated.

---

## Part 6: Best Practices Checklist

### ✅ Do This

- ✅ **Protect the Team**: Shield engineers from random external requests. "Put it in the backlog."
- ✅ **Facilitate, Don't Dictate**: In Retrospectives, let the team speak first.
- ✅ **Break it Down**: If a ticket is > 3 days, it's too big. Split it.
- ✅ **Communicate Bad News Early**: "We will be late" is forgiven if said 2 weeks prior. It's fatal if said on due day.

### ❌ Avoid This

- ❌ **Micromanagement**: Asking "Is it done?" every 2 hours. Trust the Daily Standup.
- ❌ **Output over Outcome**: Measuring "Lines of Code" or "Tickets Closed". Measure "User Value Delivered".
- ❌ **Endless Meetings**: If a meeting has no agenda, cancel it.

---

## Related Skills

- `@senior-software-architect` - Technical feasibility
- `@senior-technical-writer` - Documentation quality
- `@senior-code-reviewer` - Quality assurance

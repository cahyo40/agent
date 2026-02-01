---
name: senior-code-reviewer
description: "Expert code review including systematic review process, constructive feedback, PR best practices, and mentoring through reviews"
---

# Senior Code Reviewer

## Overview

This skill helps you conduct thorough, constructive code reviews that improve code quality and help developers grow.

## When to Use This Skill

- Use when reviewing pull requests
- Use when providing code feedback
- Use when mentoring through code
- Use when establishing review standards

## How It Works

### Step 1: Review Checklist

```
CODE REVIEW CHECKLIST
├── FUNCTIONALITY
│   ├── Does it work as intended?
│   ├── Edge cases handled?
│   └── Error handling present?
│
├── CODE QUALITY
│   ├── Readable and clear?
│   ├── DRY (no duplication)?
│   ├── Proper naming?
│   └── Functions small and focused?
│
├── ARCHITECTURE
│   ├── Right abstraction level?
│   ├── Follows project patterns?
│   └── Maintainable long-term?
│
├── SECURITY
│   ├── Input validation?
│   ├── No sensitive data exposed?
│   └── Proper authentication/authorization?
│
├── PERFORMANCE
│   ├── No obvious bottlenecks?
│   ├── Efficient algorithms?
│   └── No memory leaks?
│
└── TESTING
    ├── Tests included?
    ├── Tests meaningful?
    └── Edge cases covered?
```

### Step 2: Comment Types

```markdown
## Comment Prefixes

**[MUST]** - Required change, blocks merge
"[MUST] This SQL query is vulnerable to injection. Use parameterized queries."

**[SHOULD]** - Strong suggestion, discuss if disagree
"[SHOULD] Consider extracting this into a separate function for reusability."

**[NIT]** - Minor suggestion, optional
"[NIT] Typo in variable name: `recieve` → `receive`"

**[QUESTION]** - Need clarification
"[QUESTION] Why did we choose approach A over B here?"

**[PRAISE]** - Positive feedback
"[PRAISE] Great use of the strategy pattern here! 👏"
```

### Step 3: Constructive Feedback

```markdown
## Feedback Formula

### ❌ Bad Feedback
- "This is wrong"
- "Why did you do it this way?"
- "This code is messy"

### ✅ Good Feedback

**Structure:** Observation + Reason + Suggestion

"This function is 80 lines long, which makes it hard to test.
Consider breaking it into smaller functions:
- `validateInput()`
- `processData()`
- `formatOutput()`
This would improve testability and readability."

---

### Ask, Don't Tell
❌ "You should use map() here"
✅ "What do you think about using map() here? It might be more readable."

### Explain Why
❌ "Add null check"
✅ "Add null check here—this can be null when user hasn't completed onboarding"
```

### Step 4: PR Description Template

```markdown
## PR Title
feat(auth): add password reset functionality

## Description
Adds the ability for users to reset their password via email.

## Changes
- Added `PasswordResetService`
- Created new email template
- Added rate limiting (3 attempts/hour)

## Testing
- [x] Unit tests added
- [x] Tested on staging
- [x] Verified email delivery

## Screenshots
[If UI changes]

## Checklist
- [x] Self-reviewed
- [x] Tests pass
- [x] Docs updated
```

## Best Practices

### ✅ Do This

- ✅ Review within 24 hours
- ✅ Start with positive feedback
- ✅ Be specific and actionable
- ✅ Offer solutions, not just problems
- ✅ Use prefixes for severity

### ❌ Avoid This

- ❌ Don't make it personal
- ❌ Don't nitpick excessively
- ❌ Don't approve without reading
- ❌ Don't block on style preferences

## Related Skills

- `@senior-software-engineer` - Code quality
- `@senior-programming-mentor` - Teaching

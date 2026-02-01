---
name: open-source-evaluator
description: "Expert in evaluating open-source project health, comparing repositories, analyzing maintainer activity, and assessing licensing risks"
---

# Open Source Evaluator

## Overview

Skill ini menjadikan AI Agent Anda sebagai evaluator profesional untuk proyek open-source. Agent akan mampu menilai kesehatan repositori, membandingkan dua atau lebih proyek yang bersaing, menganalisis risiko lisensi, dan memberikan rekomendasi apakah sebuah library aman untuk digunakan dalam jangka panjang.

## When to Use This Skill

- Use when deciding between two competing open-source libraries
- Use when evaluating if a dependency is safe for production
- Use when conducting due diligence on third-party code
- Use when the user asks "Should I use [Library A] or [Library B]?"
- Use when assessing abandonment risk of a dependency

## How It Works

### Step 1: Gather Repository Metrics

Kumpulkan data dari repository:

```markdown
## Repository Health Metrics

| Metric | Description | Healthy Threshold |
|--------|-------------|-------------------|
| Stars | Popularity indicator | > 1,000 |
| Forks | Community engagement | > 100 |
| Open Issues | Unresolved problems | < 30% of total |
| Issue Close Rate | Maintainer responsiveness | > 70% within 30 days |
| Last Commit | Active development | < 30 days ago |
| Contributors | Bus factor indicator | > 5 active |
| Release Frequency | Stability indicator | Regular (monthly/quarterly) |
| Test Coverage | Code quality | > 70% |
```

### Step 2: Assess Maintainer Health

```text
┌─────────────────────────────────────────────────────────┐
│              MAINTAINER HEALTH INDICATORS               │
├─────────────────────────────────────────────────────────┤
│ 🟢 HEALTHY                                              │
│    - Multiple active maintainers                        │
│    - Corporate sponsorship or foundation backing        │
│    - Regular releases and communication                 │
│                                                         │
│ 🟡 CAUTION                                              │
│    - Single maintainer (bus factor = 1)                 │
│    - Irregular commit patterns                          │
│    - Slow issue response times                          │
│                                                         │
│ 🔴 AT RISK                                              │
│    - No commits in 6+ months                            │
│    - Maintainer announced stepping down                 │
│    - Security issues left unpatched                     │
└─────────────────────────────────────────────────────────┘
```

### Step 3: Analyze License Compatibility

```markdown
## License Matrix

| License | Commercial Use | Modification | Distribution | Patent Grant |
|---------|----------------|--------------|--------------|--------------|
| MIT | ✅ Yes | ✅ Yes | ✅ Yes | ❌ No |
| Apache 2.0 | ✅ Yes | ✅ Yes | ✅ Yes | ✅ Yes |
| GPL-3.0 | ✅ Yes | ✅ Yes | ⚠️ Copyleft | ✅ Yes |
| AGPL-3.0 | ⚠️ Careful | ✅ Yes | ⚠️ Network Copyleft | ✅ Yes |
| BSL/SSPL | ❌ Restricted | ✅ Yes | ⚠️ Varies | ❌ No |
```

### Step 4: Generate Evaluation Report

```markdown
# Open Source Evaluation: [Library Name]

## Overall Score: [X]/100

### Health Metrics
| Metric | Value | Score |
|--------|-------|-------|
| Activity | Last commit X days ago | ✅/⚠️/❌ |
| Community | X contributors | ✅/⚠️/❌ |
| Issues | X% close rate | ✅/⚠️/❌ |
| Releases | X releases/year | ✅/⚠️/❌ |

### Maintainer Analysis
- Bus Factor: X (🟢/🟡/🔴)
- Corporate Backing: Yes/No
- Foundation Member: Yes/No

### License Analysis
- License: [License Name]
- Commercial Safe: ✅/⚠️/❌
- Copyleft Risk: None/Moderate/High

### Security
- Known CVEs: X
- Security Policy: Exists/Missing
- Disclosure Process: Clear/Unclear

### Recommendation
[ADOPT / ADOPT WITH CAUTION / AVOID]

Reasoning: [Explanation]
```

## Examples

### Example 1: Comparing Two Libraries

**User Question:** "Lebih baik pakai Prisma atau Drizzle ORM?"

```markdown
# Head-to-Head Comparison: Prisma vs Drizzle ORM

## Quick Summary
| Aspect | Prisma | Drizzle |
|--------|--------|---------|
| GitHub Stars | 40K+ | 25K+ |
| Weekly Downloads | 1.5M | 300K |
| Age | 5+ years | 2+ years |
| Backing | VC-funded | Community |
| License | Apache 2.0 | Apache 2.0 |

## Health Scores
- **Prisma**: 92/100 (Mature, well-funded, large team)
- **Drizzle**: 78/100 (Growing fast, smaller team, newer)

## When to Choose Prisma
✅ Need maximum stability and support
✅ Working with complex relational schemas
✅ Team values extensive documentation

## When to Choose Drizzle
✅ Need TypeScript-first, type-safe queries
✅ Want SQL-like syntax familiarity
✅ Prioritize runtime performance over features

## Recommendation
- **Enterprise/Production**: Prisma (lower risk)
- **Greenfield/Performance-critical**: Drizzle (better DX for TS teams)
```

### Example 2: Dependency Risk Assessment

```markdown
# ⚠️ Dependency Risk Alert: [Library Name]

## Risk Level: HIGH

### Warning Signs Detected
- ❌ Last commit: 8 months ago
- ❌ 47 open security-related issues
- ❌ Primary maintainer inactive since March
- ❌ No response to critical bug reports

### Impact Assessment
- Your usage: [X files, Y imports]
- Breaking change risk: High
- Security exposure: 2 known CVEs unpatched

### Recommended Actions
1. **Immediate**: Pin version, avoid upgrades
2. **Short-term**: Evaluate alternatives ([Alt A], [Alt B])
3. **Medium-term**: Plan migration before EOL

### Alternatives to Consider
| Library | Health Score | Migration Effort |
|---------|--------------|------------------|
| Alternative A | 89/100 | Low (API similar) |
| Alternative B | 85/100 | Medium |
```

## Best Practices

### ✅ Do This

- ✅ Always check the LICENSE file, not just trust npm/PyPI
- ✅ Look at commit history, not just star count
- ✅ Check for active security policy (SECURITY.md)
- ✅ Verify corporate backing or foundation membership
- ✅ Consider the bus factor (number of active maintainers)

### ❌ Avoid This

- ❌ Don't assume high stars = production ready
- ❌ Don't ignore license implications for your use case
- ❌ Don't use libraries with no recent releases
- ❌ Don't skip checking transitive dependencies

## Common Pitfalls

**Problem:** Library looks healthy but has hidden license issues
**Solution:** Always run a license audit (e.g., `license-checker`, `fossa`) on full dependency tree.

**Problem:** Comparing apples to oranges (different scope libraries)
**Solution:** Clarify the exact use case before recommending—a library can be perfect for one scenario and terrible for another.

## Related Skills

- `@tech-trend-analyst` - For understanding adoption trends
- `@devsecops-specialist` - For security-focused analysis
- `@senior-software-architect` - For integration decisions
- `@open-source-maintainer` - For understanding maintainer perspective

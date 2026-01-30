---
name: git-commit-specialist
description: "Expert Git commit practices including conventional commits, semantic versioning, and commit message standards"
---

# Git Commit Specialist

## Overview

Write professional commit messages following conventions for clean git history.

## When to Use This Skill

- Use when writing commit messages
- Use when setting up commit standards

## How It Works

### Step 1: Conventional Commits

```markdown
## Format

<type>(<scope>): <subject>

<body>

<footer>

## Examples

feat(auth): add Google OAuth login
fix(cart): resolve quantity update bug
docs(readme): update installation guide
style(button): improve hover animation
refactor(api): extract validation logic
test(user): add registration tests
chore(deps): update dependencies
```

### Step 2: Commit Types

```markdown
## Types

| Type | Description | Example |
|------|-------------|---------|
| feat | New feature | feat: add dark mode |
| fix | Bug fix | fix: resolve login error |
| docs | Documentation | docs: update API docs |
| style | Formatting, no logic | style: fix indentation |
| refactor | Code restructure | refactor: simplify auth flow |
| test | Add/update tests | test: add unit tests |
| chore | Maintenance | chore: update deps |
| perf | Performance | perf: optimize query |
| ci | CI/CD changes | ci: add deploy workflow |
| build | Build system | build: update webpack |
| revert | Revert commit | revert: undo feat xyz |

## Scope Examples
- feat(auth): ...
- fix(cart): ...
- docs(api): ...
- style(header): ...
```

### Step 3: Good vs Bad Commits

```markdown
## ❌ Bad Commits

- "fixed stuff"
- "WIP"
- "update"
- "changes"
- "asdfgh"
- "final fix"
- "fix bug"

## ✅ Good Commits

- "feat(user): add email verification flow"
- "fix(checkout): handle empty cart edge case"
- "refactor(api): extract payment logic to service"
- "docs(readme): add Docker setup instructions"
- "test(auth): add login integration tests"
```

### Step 4: Commit Message Body

```markdown
## When to Add Body

- Complex changes
- Breaking changes
- Non-obvious decisions

## Format

feat(payment): integrate Stripe subscription billing

- Add subscription creation endpoint
- Implement webhook handler for payment events
- Add customer portal link generation
- Update user model with subscription fields

Closes #123
```

### Step 5: Git Hooks (Commitlint)

```javascript
// commitlint.config.js
module.exports = {
  extends: ['@commitlint/config-conventional'],
  rules: {
    'type-enum': [2, 'always', [
      'feat', 'fix', 'docs', 'style', 'refactor',
      'test', 'chore', 'perf', 'ci', 'build', 'revert'
    ]],
    'subject-max-length': [2, 'always', 72],
    'body-max-line-length': [2, 'always', 100]
  }
};

// package.json
{
  "husky": {
    "hooks": {
      "commit-msg": "commitlint -E HUSKY_GIT_PARAMS"
    }
  }
}
```

### Step 6: Semantic Versioning

```markdown
## Version Format: MAJOR.MINOR.PATCH

### PATCH (1.0.X)
- Bug fixes
- No new features
- Backward compatible

### MINOR (1.X.0)
- New features
- Backward compatible
- May deprecate features

### MAJOR (X.0.0)
- Breaking changes
- Incompatible API changes

## Commit → Version Mapping

| Commit Type | Version Bump |
|-------------|--------------|
| fix: ... | PATCH |
| feat: ... | MINOR |
| BREAKING CHANGE: | MAJOR |
```

## Best Practices

- ✅ Use present tense ("add" not "added")
- ✅ Keep subject under 72 chars
- ✅ Reference issues in footer
- ❌ Don't use vague messages
- ❌ Don't mix unrelated changes

## Related Skills

- `@git-workflow-specialist`
- `@senior-software-engineer`

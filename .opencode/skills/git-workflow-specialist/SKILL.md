---
name: git-workflow-specialist
description: "Expert Git workflow including branching strategies, PR best practices, release management, and version control mastery"
---

# Git Workflow Specialist

## Overview

This skill helps you master Git workflows, branching strategies, and release management for professional software development.

## When to Use This Skill

- Use when setting up Git workflows
- Use when managing branches
- Use when handling merge conflicts
- Use when planning releases

## How It Works

### Step 1: Branching Strategies

```
GITFLOW BRANCHING
├── main (production)
│   └── Always deployable
│
├── develop (integration)
│   └── Latest development changes
│
├── feature/* (from develop)
│   └── feature/user-authentication
│   └── feature/payment-integration
│
├── release/* (from develop)
│   └── release/v1.2.0
│
└── hotfix/* (from main)
    └── hotfix/critical-bug-fix

---

TRUNK-BASED DEVELOPMENT
├── main (single source of truth)
│   └── Short-lived feature branches
│   └── Merge within 1-2 days
│   └── Feature flags for incomplete work
```

### Step 2: Commit Messages

```markdown
## Conventional Commits

### Format:
<type>(<scope>): <subject>

<body>

<footer>

### Types:
- feat: New feature
- fix: Bug fix
- docs: Documentation
- style: Formatting
- refactor: Code restructuring
- test: Adding tests
- chore: Maintenance

### Examples:
feat(auth): add password reset functionality

Users can now reset their password via email.
Includes rate limiting (3 attempts/hour).

Closes #123
```

### Step 3: Common Git Operations

```bash
# Undo last commit (keep changes)
git reset --soft HEAD~1

# Discard local changes
git checkout -- .

# Stash changes
git stash
git stash pop

# Interactive rebase (clean up commits)
git rebase -i HEAD~3

# Cherry-pick specific commit
git cherry-pick abc123

# Find bug-introducing commit
git bisect start
git bisect bad HEAD
git bisect good v1.0.0

# View branch history as graph
git log --oneline --graph --all
```

### Step 4: Release Process

```bash
# Create release branch
git checkout develop
git checkout -b release/v1.2.0

# Version bump
npm version minor

# Merge to main
git checkout main
git merge release/v1.2.0
git tag -a v1.2.0 -m "Release v1.2.0"
git push origin main --tags

# Merge back to develop
git checkout develop
git merge release/v1.2.0
```

## Best Practices

### ✅ Do This

- ✅ Write meaningful commit messages
- ✅ Keep commits small and focused
- ✅ Pull before push
- ✅ Use feature branches
- ✅ Review your diff before committing

### ❌ Avoid This

- ❌ Don't commit directly to main
- ❌ Don't force push shared branches
- ❌ Don't commit secrets
- ❌ Don't commit generated files

## Related Skills

- `@senior-code-reviewer` - Code review
- `@senior-devops-engineer` - CI/CD

---
name: open-source-maintainer
description: "Expert open source project maintenance including community management, contribution guidelines, release processes, and sustainability"
---

# Open Source Maintainer

## Overview

This skill helps you maintain healthy open source projects with good documentation, community engagement, and sustainable practices.

## When to Use This Skill

- Use when creating OSS projects
- Use when managing contributions
- Use when growing community
- Use when planning releases

## How It Works

### Step 1: Project Documentation

```markdown
## Essential Files

### README.md
- Project name & logo
- One-sentence description
- Quick start guide
- Installation instructions
- Basic usage examples
- Links to docs, demo, community

### CONTRIBUTING.md
- How to set up dev environment
- How to submit issues
- How to submit PRs
- Code style guidelines
- Testing requirements

### CODE_OF_CONDUCT.md
- Expected behavior
- Unacceptable behavior
- Reporting process
- Enforcement guidelines

### CHANGELOG.md
- Version history
- Breaking changes
- New features
- Bug fixes

### LICENSE
- MIT, Apache 2.0, GPL, etc.
```

### Step 2: Issue Templates

```markdown
<!-- .github/ISSUE_TEMPLATE/bug_report.md -->
---
name: Bug Report
about: Report a bug to help us improve
---

## Bug Description
A clear description of the bug.

## Steps to Reproduce
1. Go to '...'
2. Click on '...'
3. See error

## Expected Behavior
What should happen?

## Actual Behavior
What actually happens?

## Environment
- OS: [e.g., macOS 14]
- Node version: [e.g., 20.0.0]
- Package version: [e.g., 2.1.0]

## Additional Context
Screenshots, logs, etc.
```

### Step 3: PR Review Process

```markdown
## Pull Request Checklist

### For Contributors
- [ ] Read CONTRIBUTING.md
- [ ] Branch from main
- [ ] Add/update tests
- [ ] Update documentation
- [ ] Follow code style
- [ ] Commits are atomic
- [ ] PR description explains changes

### For Maintainers
- [ ] Code quality acceptable
- [ ] Tests pass
- [ ] No breaking changes (or documented)
- [ ] Changelog updated
- [ ] Documentation updated
- [ ] Ready for release
```

### Step 4: Release Process

```bash
# Release workflow
# 1. Update version
npm version minor  # or patch, major

# 2. Update CHANGELOG
# Document what's new

# 3. Create release commit
git add .
git commit -m "chore: release v1.2.0"

# 4. Create git tag
git tag -a v1.2.0 -m "Release v1.2.0"

# 5. Push to remote
git push origin main --tags

# 6. Publish to npm
npm publish

# 7. Create GitHub release
gh release create v1.2.0 --notes-file RELEASE_NOTES.md
```

### Step 5: Community Health

```
COMMUNITY BUILDING
├── RESPONSIVENESS
│   ├── Acknowledge issues quickly
│   ├── Label issues appropriately
│   └── Set expectations for timelines
│
├── RECOGNITION
│   ├── Thank contributors
│   ├── Add to contributors list
│   └── Highlight in releases
│
├── COMMUNICATION
│   ├── Regular updates
│   ├── Roadmap visibility
│   └── Clear decision making
│
└── SUSTAINABILITY
    ├── Document bus factor risks
    ├── Onboard co-maintainers
    └── Consider funding (sponsors)
```

## Best Practices

### ✅ Do This

- ✅ Respond to issues quickly
- ✅ Label issues clearly
- ✅ Thank contributors
- ✅ Use semantic versioning
- ✅ Document breaking changes

### ❌ Avoid This

- ❌ Don't ghost contributors
- ❌ Don't merge without review
- ❌ Don't skip changelogs
- ❌ Don't ignore security issues

## Related Skills

- `@git-workflow-specialist` - Git practices
- `@senior-technical-writer` - Documentation

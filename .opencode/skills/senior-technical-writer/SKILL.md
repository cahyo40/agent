---
name: senior-technical-writer
description: "Expert technical writing including API documentation, user guides, README files, changelogs, and developer-focused content"
---

# Senior Technical Writer

## Overview

This skill transforms you into an experienced Technical Writer who creates clear, comprehensive documentation that developers and users love. You'll write API docs, user guides, tutorials, and maintain documentation systems.

## When to Use This Skill

- Use when writing API documentation
- Use when creating README files
- Use when documenting code or systems
- Use when writing user guides or tutorials
- Use when the user asks about documentation

## How It Works

### Step 1: Documentation Types

```
DOCUMENTATION TYPES
├── API REFERENCE
│   ├── Endpoint descriptions
│   ├── Request/Response examples
│   ├── Authentication guides
│   └── Error codes
│
├── USER GUIDES
│   ├── Getting started
│   ├── Installation
│   ├── Configuration
│   └── Troubleshooting
│
├── TUTORIALS
│   ├── Step-by-step guides
│   ├── Use case examples
│   └── Best practices
│
├── REFERENCE DOCS
│   ├── Architecture overview
│   ├── Data models
│   └── Glossary
│
└── CHANGELOGS
    ├── Version history
    ├── Breaking changes
    └── Migration guides
```

### Step 2: README Template

```markdown
# Project Name

Brief description of what this project does and who it's for.

## Features

- ✅ Feature 1 with brief explanation
- ✅ Feature 2 with brief explanation
- ✅ Feature 3 with brief explanation

## Installation

\`\`\`bash
npm install project-name
\`\`\`

## Quick Start

\`\`\`javascript
import { Client } from 'project-name';

const client = new Client({ apiKey: 'your-key' });
const result = await client.doSomething();
\`\`\`

## Configuration

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `apiKey` | string | - | Your API key (required) |
| `timeout` | number | 5000 | Request timeout in ms |

## API Reference

### `client.doSomething(options)`

Does something amazing.

**Parameters:**
- `options.param1` (string): Description of param1
- `options.param2` (number, optional): Description of param2

**Returns:** `Promise<Result>`

**Example:**
\`\`\`javascript
const result = await client.doSomething({ param1: 'value' });
\`\`\`

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

## License

MIT © [Your Name]
```

### Step 3: API Documentation

```markdown
## Create User

Creates a new user account.

### Endpoint

\`POST /api/v1/users\`

### Authentication

Requires Bearer token with `users:write` scope.

### Request

**Headers:**
| Header | Value |
|--------|-------|
| Authorization | Bearer {token} |
| Content-Type | application/json |

**Body:**
\`\`\`json
{
  "email": "user@example.com",
  "name": "John Doe",
  "role": "member"
}
\`\`\`

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| email | string | Yes | Valid email address |
| name | string | Yes | User's full name (2-100 chars) |
| role | string | No | One of: admin, member, guest |

### Response

**Success (201 Created):**
\`\`\`json
{
  "id": "usr_abc123",
  "email": "user@example.com",
  "name": "John Doe",
  "role": "member",
  "created_at": "2025-01-30T10:00:00Z"
}
\`\`\`

**Errors:**
| Code | Description |
|------|-------------|
| 400 | Invalid request body |
| 401 | Missing or invalid token |
| 409 | Email already exists |
```

### Step 4: Changelog Format

```markdown
# Changelog

All notable changes documented following [Keep a Changelog](https://keepachangelog.com/).

## [2.0.0] - 2025-01-30

### ⚠️ Breaking Changes
- Removed deprecated `oldMethod()` - use `newMethod()` instead
- Changed `config.timeout` from seconds to milliseconds

### Added
- New `client.stream()` method for real-time data
- Support for custom retry strategies

### Changed
- Improved error messages with more context
- Updated dependencies to latest versions

### Fixed
- Fixed memory leak in long-running connections
- Fixed race condition in concurrent requests

### Migration Guide
\`\`\`javascript
// Before (v1.x)
client.oldMethod({ timeout: 5 }); // seconds

// After (v2.x)
client.newMethod({ timeout: 5000 }); // milliseconds
\`\`\`
```

## Examples

### Example 1: Error Documentation

```markdown
## Error Handling

All errors follow this structure:

\`\`\`json
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Invalid email format",
    "details": [
      { "field": "email", "issue": "Must be valid email" }
    ]
  }
}
\`\`\`

### Common Error Codes

| Code | HTTP Status | Description | Resolution |
|------|-------------|-------------|------------|
| AUTH_REQUIRED | 401 | Missing auth token | Include Bearer token |
| RATE_LIMITED | 429 | Too many requests | Wait and retry with backoff |
| NOT_FOUND | 404 | Resource doesn't exist | Check resource ID |
```

## Best Practices

### ✅ Do This

- ✅ Use clear, concise language
- ✅ Include working code examples
- ✅ Keep docs up-to-date with code
- ✅ Use tables for structured data
- ✅ Add "copy" buttons to code blocks
- ✅ Include error scenarios

### ❌ Avoid This

- ❌ Don't use jargon without explanation
- ❌ Don't assume prior knowledge
- ❌ Don't leave placeholders
- ❌ Don't skip edge cases

## Common Pitfalls

**Problem:** Documentation out of sync with code
**Solution:** Generate docs from code comments, add docs to PR checklist.

**Problem:** Users can't find what they need
**Solution:** Good navigation, search, and clear headings.

## Tools

| Category | Tools |
|----------|-------|
| Static Site | Docusaurus, MkDocs, GitBook |
| API Docs | Swagger/OpenAPI, Redoc, Stoplight |
| README | readme.so, Make a README |

## Related Skills

- `@senior-software-engineer` - For code documentation
- `@senior-developer-advocate` - For tutorials

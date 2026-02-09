---
name: cursor-rules-engineer
description: "Expert AI IDE configuration specialist for Cursor, Windsurf, and GitHub Copilot custom rules and project-specific AI behavior"
---

# Cursor Rules Engineer

## Overview

Configure AI coding assistants to follow project-specific conventions, patterns, and best practices. This skill covers creating `.cursorrules`, `.windsurfrules`, and other AI configuration files that ensure consistent, project-aware code generation.

## When to Use This Skill

- Use when setting up Cursor rules for a new project
- Use when customizing AI assistant behavior for team conventions
- Use when creating project-specific coding standards for AI
- Use when optimizing AI code generation for specific frameworks
- Use when configuring Windsurf or GitHub Copilot

## Templates Reference

| Template | Description |
|----------|-------------|
| [cursorrules-react.md](templates/cursorrules-react.md) | React/Next.js project rules |
| [cursorrules-flutter.md](templates/cursorrules-flutter.md) | Flutter project rules |
| [cursorrules-backend.md](templates/cursorrules-backend.md) | Backend API rules |
| [general-patterns.md](templates/general-patterns.md) | Common rule patterns |

## How It Works

### Step 1: Create Rules File

```bash
# Cursor AI
touch .cursorrules

# Windsurf AI
touch .windsurfrules

# These files go in project root
```

### Step 2: Basic Structure

```markdown
# Project Rules

## Role
You are a senior developer working on [Project Name], a [description].

## Tech Stack
- Frontend: React 18, TypeScript, TailwindCSS
- Backend: Node.js, Express, PostgreSQL
- State: Zustand
- Testing: Vitest, Testing Library

## Code Style
- Use functional components with hooks
- Prefer named exports over default exports
- Use TypeScript strict mode
- Follow kebab-case for file names
- Use PascalCase for component names

## Patterns to Follow
1. All API calls go through `/lib/api.ts`
2. Use `useQuery` for data fetching
3. Components should be in `/components/{feature}/`
4. Shared utilities in `/lib/`

## Patterns to Avoid
- Do NOT use class components
- Do NOT use any type
- Do NOT use inline styles
- Do NOT create files over 300 lines
```

### Step 3: Framework-Specific Rules

```markdown
# Next.js App Router Project

## Directory Structure
```

app/
├── (auth)/           # Auth group
├── (dashboard)/      # Dashboard group
├── api/              # API routes
├── globals.css
└── layout.tsx
components/
├── ui/               # Reusable UI components
├── forms/            # Form components
└── layouts/          # Layout components
lib/
├── actions/          # Server actions
├── db/               # Database utilities
└── utils/            # Utility functions

```

## Server Components (default)
- Use for data fetching
- Use for SEO-critical content
- Use for static content

## Client Components ('use client')
- Use for interactivity
- Use for browser APIs
- Use for state management
- Always add 'use client' at TOP of file

## Data Fetching
ALWAYS use server components with async/await:
```tsx
// ✅ Good
async function Page() {
  const data = await fetchData()
  return <Component data={data} />
}

// ❌ Bad - don't use useEffect for data
'use client'
function Page() {
  useEffect(() => { fetchData() }, [])
}
```

## Server Actions

Use for mutations:

```tsx
'use server'
export async function createUser(formData: FormData) {
  const name = formData.get('name')
  await db.insert(users).values({ name })
  revalidatePath('/users')
}
```

```

### Step 4: Advanced Patterns

```markdown
# Advanced Configuration

## Error Handling
ALWAYS wrap async operations:
```typescript
try {
  const result = await operation()
  return { success: true, data: result }
} catch (error) {
  console.error('Operation failed:', error)
  return { success: false, error: 'Operation failed' }
}
```

## Type Safety

ALWAYS define types explicitly:

```typescript
// ✅ Good
interface User {
  id: string
  name: string
  email: string
}

function getUser(id: string): Promise<User> {}

// ❌ Bad
function getUser(id) { return fetch(...) }
```

## Testing Requirements

Every new function MUST have a test:

```typescript
// user.ts
export function calculateAge(birthDate: Date): number {}

// user.test.ts
describe('calculateAge', () => {
  it('should calculate age correctly', () => {})
  it('should handle future dates', () => {})
})
```

## Git Commit Format

Use conventional commits:

- feat: new feature
- fix: bug fix
- docs: documentation
- style: formatting
- refactor: code restructure
- test: adding tests
- chore: maintenance

```

## Best Practices

### ✅ Do This

- ✅ Be specific about patterns and conventions
- ✅ Include file structure expectations
- ✅ Provide code examples for preferred patterns
- ✅ List anti-patterns to avoid
- ✅ Keep rules updated with project evolution

### ❌ Avoid This

- ❌ Don't make rules too long (keep under 500 lines)
- ❌ Don't include sensitive information
- ❌ Don't contradict language/framework conventions
- ❌ Don't be too restrictive

## Common Pitfalls

**Problem:** AI ignores some rules
**Solution:** Put most important rules at the top, use clear headers

**Problem:** Rules conflict with each other
**Solution:** Review and consolidate rules, prioritize explicitly

**Problem:** Rules too generic
**Solution:** Add specific code examples and file paths

## Related Skills

- `@senior-software-engineer` - Code quality patterns
- `@senior-react-developer` - React conventions
- `@senior-flutter-developer` - Flutter conventions

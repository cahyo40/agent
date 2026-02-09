---
name: ai-coding-assistant
description: "Expert AI coding tool integration including Cursor, Windsurf, GitHub Copilot, Claude, and optimizing AI-assisted development workflows"
---

# AI Coding Assistant Integration

## Overview

Maximize productivity with AI coding assistants. This skill covers integrating and optimizing tools like Cursor, Windsurf, GitHub Copilot, and Claude for efficient development workflows, including prompt engineering for code generation and context management.

## When to Use This Skill

- Use when setting up AI coding tools for a project
- Use when optimizing AI code generation quality
- Use when creating effective prompts for code changes
- Use when managing context for AI assistants
- Use when integrating multiple AI tools

## Templates Reference

| Template | Description |
|----------|-------------|
| [cursor-setup.md](templates/cursor-setup.md) | Cursor IDE configuration |
| [copilot-tips.md](templates/copilot-tips.md) | GitHub Copilot optimization |
| [prompting.md](templates/prompting.md) | Effective prompting patterns |

## How It Works

### Step 1: Tool Selection

| Tool | Best For | Pricing |
|------|----------|---------|
| **Cursor** | Full IDE replacement, agentic coding | $20/mo Pro |
| **Windsurf** | VS Code-based, Cascade flows | $15/mo Pro |
| **GitHub Copilot** | Inline completions, chat | $10/mo |
| **Claude (API)** | Complex reasoning, long context | Pay per use |
| **Codeium** | Free alternative, completions | Free tier |

### Step 2: Cursor Configuration

```json
// .cursor/settings.json
{
  "cursor.ai.model": "claude-3-5-sonnet",
  "cursor.ai.contextLength": 128000,
  "cursor.ai.useGitHistory": true,
  "cursor.composer.enabled": true
}
```

Key Features:

- **Tab completion**: Accept suggestions with Tab
- **Cmd+K**: Inline code edits
- **Cmd+L**: Chat with codebase context
- **Composer**: Multi-file agentic edits
- **@ mentions**: Reference files, docs, code

### Step 3: Effective Prompting

```markdown
# Good Prompts

## Be Specific
❌ "Make this better"
✅ "Refactor this function to use async/await instead of callbacks, add error handling, and add TypeScript types"

## Provide Context
❌ "Add authentication"
✅ "Add JWT authentication using the existing auth service in /lib/auth.ts, protect all /api/admin/* routes"

## Use Examples
❌ "Create a form component"
✅ "Create a user registration form component similar to /components/forms/LoginForm.tsx, using React Hook Form and Zod validation with fields: name, email, password"

## Break Down Complex Tasks
Instead of: "Build a complete CRUD for users"
Use sequential prompts:
1. "Create TypeScript interfaces for User in /types/user.ts"
2. "Create API routes for users in /app/api/users"
3. "Create UserList component with pagination"
4. "Create CreateUserForm with validation"
```

### Step 4: Context Management

```markdown
## Cursor Context Tips

### @ Mentions
- @file - Reference specific file
- @folder - Include folder context
- @codebase - Search entire codebase
- @docs - Reference documentation
- @web - Search web
- @git - Git history context

### Effective Context Patterns
1. Start with project overview: "@file:README.md"
2. Include relevant types: "@file:types/index.ts"
3. Reference similar code: "@file:components/UserCard.tsx"
4. Include tests for pattern: "@folder:tests/"
```

### Step 5: Workflow Integration

```markdown
## AI-Assisted Development Workflow

### 1. Planning
- Use chat to discuss architecture
- Reference existing patterns
- Generate implementation plan

### 2. Scaffolding
- Use Composer for multi-file generation
- Generate folder structure
- Create type definitions first

### 3. Implementation
- Use inline edits (Cmd+K) for focused changes
- Use tab completion for boilerplate
- Chat for complex logic

### 4. Review & Refactor
- Ask AI to review code
- Suggest improvements
- Add documentation

### 5. Testing
- Generate test cases
- Add edge case coverage
- Fix failing tests
```

## Best Practices

### ✅ Do This

- ✅ Provide clear, specific prompts
- ✅ Reference existing code patterns
- ✅ Include relevant context files
- ✅ Review and understand generated code
- ✅ Use .cursorrules for consistency
- ✅ Break complex tasks into steps

### ❌ Avoid This

- ❌ Don't accept code blindly
- ❌ Don't use vague prompts
- ❌ Don't skip code review
- ❌ Don't ignore security in generated code
- ❌ Don't rely solely on AI for architecture decisions

## Common Pitfalls

**Problem:** AI generates outdated patterns
**Solution:** Reference up-to-date docs with @docs or @web

**Problem:** Inconsistent code style
**Solution:** Create .cursorrules with project conventions

**Problem:** AI hallucinates APIs or functions
**Solution:** Always reference actual file context, verify outputs

**Problem:** Context window exceeded
**Solution:** Be selective with context, focus on relevant files

## Related Skills

- `@cursor-rules-engineer` - Creating AI IDE rules
- `@senior-prompt-engineer` - Prompt engineering
- `@vibe-coding-specialist` - AI-assisted workflows

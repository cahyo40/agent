---
name: vibe-coding-specialist
description: "Expert AI-assisted development workflow focusing on rapid prototyping, iterative development, and leveraging AI for maximum productivity"
---

# Vibe Coding Specialist

## Overview

Master the art of "vibe coding" - a development approach that maximizes AI assistance for rapid prototyping and iterative development. This skill covers workflow optimization, context setup, and techniques for effective human-AI collaboration in coding.

## When to Use This Skill

- Use when rapidly prototyping new features
- Use when iterating quickly on ideas
- Use when learning new frameworks through building
- Use when maximizing development velocity
- Use when pair-programming with AI

## Templates Reference

| Template | Description |
|----------|-------------|
| [vibe-setup.md](templates/vibe-setup.md) | Project context setup |
| [iteration-flow.md](templates/iteration-flow.md) | Rapid iteration patterns |
| [context-files.md](templates/context-files.md) | Context management |

## How It Works

### Step 1: Vibe Coding Philosophy

```markdown
## Core Principles

1. **Start with Intent**: Describe what you want, not how to code it
2. **Iterate Rapidly**: Build → Review → Refine loops
3. **Trust but Verify**: Review AI output, understand the code
4. **Context is King**: Good context = good output
5. **Ship Fast**: Don't over-engineer, iterate later
```

### Step 2: Project Context Setup

Create these files in your project root:

```markdown
# PROJECT.md
## Overview
Brief description of what this project does.

## Tech Stack
- Frontend: React + TypeScript + TailwindCSS
- Backend: Node.js + Express
- Database: PostgreSQL + Drizzle

## Key Patterns
- Use functional components
- Server-side rendering for SEO pages
- REST API with OpenAPI spec

## Directory Structure
[Include your folder structure here]
```

```markdown
# CONVENTIONS.md
## Naming
- Files: kebab-case
- Components: PascalCase
- Functions: camelCase

## Code Style
- Max 200 lines per file
- Prefer composition over inheritance
- Extract reusable hooks

## Examples
[Include code snippets of preferred patterns]
```

### Step 3: Vibe Coding Workflow

```markdown
## Phase 1: Discovery (5-10 min)
"I want to build [X]. What's the best approach?"
- Discuss architecture
- Identify key components
- Plan file structure

## Phase 2: Scaffolding (10-20 min)
"Create the basic structure for [X]"
- Generate folder structure
- Create type definitions
- Set up configuration

## Phase 3: Core Implementation (30-60 min)
"Implement [specific feature] following @PROJECT.md"
- Build feature by feature
- Use specific, focused prompts
- Review and adjust

## Phase 4: Polish (15-30 min)
"Review this code for improvements"
- Add error handling
- Improve types
- Add documentation

## Phase 5: Testing (20-40 min)
"Generate tests for [component/function]"
- Unit tests
- Integration tests
- Edge cases
```

### Step 4: Effective Vibe Prompts

```markdown
## Scaffolding Prompts
"Create a new [feature] with:
- Types in /types/[feature].ts
- API routes in /api/[feature]/
- Components in /components/[feature]/
- Following patterns from @CONVENTIONS.md"

## Implementation Prompts
"Implement [specific function] that:
1. Takes [input]
2. Does [action]
3. Returns [output]
4. Handles errors by [strategy]
See similar: @file:[example]"

## Refinement Prompts
"Refactor this to:
- Improve type safety
- Add error handling
- Match the pattern in @file:[example]
Keep the same functionality"

## Debugging Prompts
"This code has issue: [describe]
Expected: [behavior]
Actual: [behavior]
Fix while keeping [constraint]"
```

### Step 5: Context Stacking

```markdown
## Layered Context Approach

### Layer 1: Project Level
- PROJECT.md - High-level overview
- CONVENTIONS.md - Coding standards
- .cursorrules - AI-specific rules

### Layer 2: Feature Level
- Relevant type definitions
- Similar existing features
- Related API contracts

### Layer 3: Task Level
- Specific file being modified
- Test file if exists
- Error logs if debugging
```

## Best Practices

### ✅ Do This

- ✅ Set up context files before starting
- ✅ Start with types and interfaces
- ✅ Use small, focused prompts
- ✅ Review generated code actively
- ✅ Refactor incrementally
- ✅ Keep momentum, iterate later

### ❌ Avoid This

- ❌ Don't copy-paste blindly
- ❌ Don't skip understanding the code
- ❌ Don't make prompts too long
- ❌ Don't fight the AI - guide it
- ❌ Don't over-engineer upfront

## Common Pitfalls

**Problem:** AI generates wrong architecture
**Solution:** Start with architecture discussion, provide examples

**Problem:** Losing context in long sessions
**Solution:** Reset and provide fresh context, use @file references

**Problem:** Code drift from conventions
**Solution:** Reference CONVENTIONS.md regularly, use .cursorrules

**Problem:** Spending too long on prompts
**Solution:** Keep prompts short, iterate with follow-ups

## Related Skills

- `@ai-coding-assistant` - Tool-specific configuration
- `@cursor-rules-engineer` - Rule file creation
- `@senior-prompt-engineer` - Prompt optimization

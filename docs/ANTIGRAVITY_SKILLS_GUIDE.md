# Anatomy of a Skill - Understanding the Structure

**Want to understand how skills work under the hood?** This guide breaks down every part of a skill file.

---

## 📁 Basic Folder Structure

Semua skill **WAJIB** disimpan dalam direktori `.agent/skills/` di root project.

```text
.agent/
└── skills/
    └── my-skill-name/
        ├── SKILL.md              ← Required: The main skill definition
        ├── examples/             ← Optional: Example files
        │   ├── example1.js
        │   └── example2.py
        ├── scripts/              ← Optional: Helper scripts
        │   └── helper.sh
        ├── templates/            ← Optional: Code templates
        │   └── template.tsx
        ├── references/           ← Optional: Reference documentation
        │   └── api-docs.md
        └── README.md             ← Optional: Additional documentation
```

**Key Rule:** Only `SKILL.md` is required. Everything else is optional!

---

## 🇮🇩 Language Guidelines

Skills dapat ditulis dalam Bahasa Inggris atau Indonesia, dengan panduan berikut:

| Bagian | Bahasa | Alasan |
|--------|--------|--------|
| **Frontmatter** (`name`, `description`) | English | Untuk konsistensi dan kompatibilitas |
| **Section Headers** | English | Mudah dikenali AI |
| **Content/Instructions** | English atau Indonesia | Sesuai preferensi pembuat |
| **Code Examples** | English variable names | Best practice programming |

**Contoh yang Baik:**

```markdown
---
name: api-integration
description: "REST API integration patterns with error handling and retry logic"
---

# API Integration Patterns

## Overview
Skill ini membantu Anda mengintegrasikan REST API dengan proper error handling...
```

---

## SKILL.md Structure

Every `SKILL.md` file has two main parts:

### 1. Frontmatter (Metadata)

### 2. Content (Instructions)

Let's break down each part:

---

## Part 1: Frontmatter

The frontmatter is at the very top, wrapped in `---`:

```markdown
---
name: my-skill-name
description: "Brief description of what this skill does"
---
```

### Required Fields

#### `name`

- **What it is:** The skill's identifier
- **Format:** lowercase-with-hyphens (kebab-case)
- **Must match:** The folder name exactly
- **Example:** `stripe-integration`, `senior-flutter-developer`

#### `description`

- **What it is:** One-sentence summary that helps AI know when to use this skill
- **Format:** String in quotes
- **Length:** Keep it under 150 characters
- **Tip:** Include key technologies or use cases
- **Example:** `"Professional Flutter development with clean architecture, Riverpod state management, and industry best practices"`

### Optional Fields

Some skills include additional metadata:

```markdown
---
name: my-skill-name
description: "Brief description"
risk: "safe"              # safe | risk | official
source: "community"       # community | official
tags: ["react", "typescript", "frontend"]
version: "1.0.0"
---
```

---

## Part 2: Content

After the frontmatter comes the actual skill content. Here's the **recommended structure**:

### Recommended Sections

#### 1. Title (H1)

```markdown
# Skill Title
```

- Use a clear, descriptive title
- Usually matches or expands on the skill name
- Example: `# Senior Flutter Mobile Developer`

#### 2. Overview

```markdown
## Overview

A brief explanation of what this skill does and why it exists.
2-4 sentences is perfect. Focus on the VALUE this skill provides.
```

**Example:**

```markdown
## Overview

This skill transforms you into an experienced Senior Flutter Developer who builds 
production-ready mobile applications. You'll write code following industry best 
practices, implement clean architecture, and ensure optimal performance.
```

#### 3. When to Use

```markdown
## When to Use This Skill

- Use when you need to [scenario 1]
- Use when working with [scenario 2]
- Use when the user asks about [scenario 3]
```

**Why this matters:** Helps the AI know exactly when to activate this skill

**Example:**

```markdown
## When to Use This Skill

- Use when building new Flutter applications from scratch
- Use when refactoring existing Flutter code to follow best practices
- Use when implementing complex features requiring proper architecture
- Use when the user asks about Flutter state management patterns
```

#### 4. Core Instructions

```markdown
## How It Works

### Step 1: [Action]

Detailed instructions...

### Step 2: [Action]

More instructions...
```

**This is the heart of your skill** - clear, actionable steps

**Example:**

```markdown
## How It Works

### Step 1: Apply Core Principles

Always follow these fundamental principles:
1. **Clean Architecture**: Separate code into Presentation, Domain, and Data layers
2. **SOLID Principles**: Apply all five principles consistently
3. **DRY**: Extract reusable components and utilities

### Step 2: Use Standard Project Structure

```text
lib/
├── core/
├── features/
└── shared/
```

```

#### 5. Examples

```markdown
## Examples

### Example 1: [Use Case]

\`\`\`javascript
// Example code with comments
\`\`\`

### Example 2: [Another Use Case]

\`\`\`javascript
// More code
\`\`\`
```

**Why examples matter:** They show the AI exactly what good output looks like

**Tips for good examples:**

- Include 2-3 realistic examples
- Show both ✅ correct and ❌ incorrect approaches
- Add comments explaining the "why"

#### 6. Best Practices

```markdown
## Best Practices

### ✅ Do This

- ✅ Use `const` constructor wherever possible
- ✅ Implement proper error handling
- ✅ Write unit tests for core functionality

### ❌ Avoid This

- ❌ Don't mix business logic in UI widgets
- ❌ Don't hardcode strings, use constants
- ❌ Don't skip error handling
```

#### 7. Common Pitfalls

```markdown
## Common Pitfalls

**Problem:** Widget rebuilds too frequently, causing performance issues
**Solution:** Use `select` on Riverpod providers to listen only to specific state changes.

**Problem:** Async state not handled properly
**Solution:** Always use `AsyncValue` pattern with `when()` to handle loading, error, and data states.
```

#### 8. Related Skills

```markdown
## Related Skills

- `@other-skill` - When to use this instead
- `@complementary-skill` - How this works together
```

**Example:**

```markdown
## Related Skills

- `@senior-backend-developer` - For backend-specific implementation patterns
- `@senior-programming-mentor` - For language-specific guidance
- `@expert-senior-software-engineer` - For system design and architecture
```

---

## Writing Effective Instructions

### Use Clear, Direct Language

**❌ Bad:**

```markdown
You might want to consider possibly checking if the user has authentication.
```

**✅ Good:**

```markdown
Check if the user is authenticated before proceeding.
```

### Use Action Verbs

**❌ Bad:**

```markdown
The file should be created...
```

**✅ Good:**

```markdown
Create the file...
```

### Be Specific

**❌ Bad:**

```markdown
Set up the database properly.
```

**✅ Good:**

```markdown
1. Create a PostgreSQL database
2. Run migrations: `npm run migrate`
3. Seed initial data: `npm run seed`
```

### Use Tables for Structured Information

**✅ Good:**

```markdown
| Code | Meaning | When to Use |
|------|---------|-------------|
| 200 | OK | Request successful |
| 201 | Created | Resource created |
| 400 | Bad Request | Invalid input |
```

---

## Optional Components

### Scripts Directory

If your skill needs helper scripts:

```
scripts/
├── setup.sh          ← Setup automation
├── validate.py       ← Validation tools
└── generate.js       ← Code generators
```

**Reference them in SKILL.md:**

```markdown
Run the setup script:
\`\`\`bash
bash scripts/setup.sh
\`\`\`
```

### Examples Directory

Real-world examples that demonstrate the skill:

```
examples/
├── basic-usage.js
├── advanced-pattern.ts
└── full-implementation/
    ├── index.js
    └── config.json
```

### Templates Directory

Reusable code templates:

```
templates/
├── component.tsx
├── test.spec.ts
└── config.json
```

**Reference in SKILL.md:**

```markdown
Use this template as a starting point:
\`\`\`typescript
{{#include templates/component.tsx}}
\`\`\`
```

### References Directory

External documentation or API references:

```
references/
├── api-docs.md
├── best-practices.md
└── troubleshooting.md
```

---

## Skill Size Guidelines

### Minimum Viable Skill

- **Frontmatter:** name + description
- **Content:** 100-200 words
- **Sections:** Overview + Instructions
- **Use case:** Simple, focused tasks

### Standard Skill

- **Frontmatter:** name + description
- **Content:** 300-800 words
- **Sections:** Overview + When to Use + Instructions + Examples
- **Use case:** Most common skills

### Comprehensive Skill

- **Frontmatter:** name + description + optional fields
- **Content:** 800-2000 words
- **Sections:** All recommended sections
- **Extras:** Scripts, examples, templates
- **Use case:** Complex domains (e.g., senior-flutter-developer, expert-web3-blockchain)

**Rule of thumb:** Start small, expand based on feedback

---

## Formatting Best Practices

### Use Markdown Effectively

#### Code Blocks

Always specify the language:

```markdown
\`\`\`javascript
const example = "code";
\`\`\`
```

#### Lists

Use consistent formatting:

```markdown
- Item 1
- Item 2
  - Sub-item 2.1
  - Sub-item 2.2
```

#### Emphasis

- **Bold** for important terms: `**important**`
- _Italic_ for emphasis: `*emphasis*`
- `Code` for commands/code: `` `code` ``

#### Links

```markdown
[Link text](https://example.com)
```

#### Emoji (Use Sparingly)

Good for visual scanning:

- 🎯 for goals/objectives
- ✅ for correct examples
- ❌ for incorrect examples
- ⚠️ for warnings
- 💡 for tips
- 🔥 for highlights

---

## ✅ Quality Checklist

Before finalizing your skill:

### Content Quality

- [ ] Instructions are clear and actionable
- [ ] Examples are realistic and helpful
- [ ] No typos or grammar errors
- [ ] Technical accuracy verified
- [ ] Both correct (✅) and incorrect (❌) examples shown

### Structure

- [ ] Frontmatter is valid YAML
- [ ] Name matches folder name (kebab-case)
- [ ] Sections are logically organized
- [ ] Headings follow hierarchy (H1 → H2 → H3)
- [ ] Tables used for structured data

### Completeness

- [ ] Overview explains the "why"
- [ ] "When to Use" section clearly defines activation triggers
- [ ] Instructions explain the "how" with steps
- [ ] Examples show the "what" with code
- [ ] Edge cases and pitfalls are addressed

### Usability

- [ ] A beginner could follow this
- [ ] An expert would find it useful
- [ ] The AI can parse it correctly
- [ ] It solves a real problem

---

## 🔍 Real-World Example Analysis

Let's analyze a well-structured skill: `senior-flutter-developer`

```markdown
---
name: senior-flutter-developer
description: "Professional Flutter development with clean architecture, Riverpod state management, and industry best practices for scalable mobile apps"
---
```

**Analysis:**

- ✅ Clear name (kebab-case)
- ✅ Description includes: role + architecture + state management + goal
- ✅ Description helps AI know when to activate

```markdown
# Senior Flutter Mobile Developer

## Overview

This skill transforms you into an experienced Senior Flutter Developer...
```

**Analysis:**

- ✅ Clear title that expands on name
- ✅ Overview explains transformation/value
- ✅ Sets expectations for output quality

```markdown
## When to Use This Skill

- Use when building new Flutter applications from scratch
- Use when refactoring existing Flutter code
- Use when the user asks about Flutter state management
```

**Analysis:**

- ✅ Clear activation triggers
- ✅ Specific scenarios, not vague
- ✅ AI knows exactly when to use this skill

---

## Advanced Patterns

### Conditional Logic

```markdown
## Instructions

If the user is working with React:
- Use functional components
- Prefer hooks over class components

If the user is working with Vue:
- Use Composition API
- Follow Vue 3 patterns
```

### Progressive Disclosure

```markdown
## Basic Usage

[Simple instructions for common cases]

## Advanced Usage

[Complex patterns for power users]
```

### Cross-References

```markdown
## Related Skills

1. First, use `@brainstorming` to design
2. Then, use `@writing-plans` to plan
3. Finally, use `@test-driven-development` to implement
```

### Checklists in Skills

```markdown
## Pre-Deployment Checklist

- [ ] All tests passing
- [ ] Security audit completed
- [ ] Documentation updated
- [ ] Rollback procedure documented
```

---

## Skill Effectiveness Metrics

How to know if your skill is good:

### Clarity Test

- Can someone unfamiliar with the topic follow it?
- Are there any ambiguous instructions?

### Completeness Test

- Does it cover the happy path?
- Does it handle edge cases?
- Are error scenarios addressed?

### Usefulness Test

- Does it solve a real problem?
- Would you use this yourself?
- Does it save time or improve quality?

---

## 💡 Pro Tips

1. **Start with the "When to Use" section** - This clarifies the skill's purpose
2. **Write examples first** - They help you understand what you're teaching
3. **Use tables for structured data** - Easier to scan than paragraphs
4. **Include both ✅ and ❌ examples** - Show what NOT to do
5. **Test with an AI** - See if it actually works before finalizing
6. **Get feedback** - Ask others to review your skill
7. **Iterate** - Skills improve over time based on usage

---

## Common Mistakes to Avoid

### ❌ Mistake 1: Too Vague

```markdown
## Instructions

Make the code better.
```

**✅ Fix:**

```markdown
## Instructions

1. Extract repeated logic into functions
2. Add error handling for edge cases
3. Write unit tests for core functionality
```

### ❌ Mistake 2: Too Complex

```markdown
## Instructions

[5000 words of dense technical jargon]
```

**✅ Fix:**
Break into multiple skills or use progressive disclosure

### ❌ Mistake 3: No Examples

```markdown
## Instructions

[Instructions without any code examples]
```

**✅ Fix:**
Add at least 2-3 realistic examples with ✅ correct and ❌ incorrect patterns

### ❌ Mistake 4: Outdated Information

```markdown
Use React class components...
```

**✅ Fix:**
Keep skills updated with current best practices

### ❌ Mistake 5: Missing "When to Use" Section

```markdown
# My Skill

## How It Works
...
```

**✅ Fix:**
Always include "When to Use This Skill" section so AI knows activation triggers

---

## 📚 Skill Template

Copy this template to create new skills:

```markdown
---
name: skill-name-here
description: "One-sentence description including key technologies and use cases"
---

# Skill Title

## Overview

2-4 sentences explaining what this skill does and the value it provides.

## When to Use This Skill

- Use when [scenario 1]
- Use when [scenario 2]
- Use when user asks about [topic]

## How It Works

### Step 1: [Action]

Detailed instructions...

### Step 2: [Action]

More instructions...

## Examples

### Example 1: [Use Case]

\`\`\`language
// Code example
\`\`\`

### Example 2: [Another Use Case]

\`\`\`language
// Code example
\`\`\`

## Best Practices

### ✅ Do This

- ✅ Best practice 1
- ✅ Best practice 2

### ❌ Avoid This

- ❌ Anti-pattern 1
- ❌ Anti-pattern 2

## Common Pitfalls

**Problem:** Description of common issue
**Solution:** How to solve it

## Related Skills

- `@related-skill` - When to use this instead
```

---

## 🎯 Next Steps

1. **Read 3-5 existing skills** in `.agent/skills/` to see different styles
2. **Copy the template** above to start your skill
3. **Create a simple skill** for something you know well
4. **Test it** by asking the AI to perform the skill's task
5. **Iterate** based on how well the AI follows your instructions

---

**Remember:** Every expert was once a beginner. Start simple, learn from feedback, and improve over time! 🚀

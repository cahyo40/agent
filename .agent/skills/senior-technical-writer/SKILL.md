---
name: senior-technical-writer
description: "Expert technical writing including API documentation, user guides, README files, changelogs, and developer-focused content"
---

# Senior Technical Writer

## Overview

This skill transforms you into a **Docs-as-Code Practitioner**. You will move beyond Word documents to treating documentation like software (Markdown, Git, CI/CD). You will master the **Diátaxis Framework**, write **OpenAPI** references, and create clear **Information Architecture**.

## When to Use This Skill

- Use when documenting a new API endpoint (Reference)
- Use when writing a "Getting Started" guide (Tutorial)
- Use when explaining a complex concept (Explanation)
- Use when creating a `README.md` for an Open Source project
- Use when maintaining a Changelog (`KEEP A CHANGELOG`)

---

## Part 1: The Diátaxis Framework

Structure your docs by *User Intent*.

1. **Tutorials** (Learning-oriented): "Getting Started". Step-by-step. specific goal. No choices. "Do this, then this."
2. **How-to Guides** (Problem-oriented): "How to configure CORS". User has a specific problem to solve. Steps + Context.
3. **Reference** (Information-oriented): "API Endpoint /users". Facts. Signatures. Types. No opinions.
4. **Explanations** (Understanding-oriented): "How Auth works". Architecture. Concepts. No code steps.

---

## Part 2: Docs-as-Code

Documentation lives with the code.

1. **Format**: Markdown (`.md`) or AsciiDoc (`.adoc`).
2. **Versioning**: Git. Branches match software versions.
3. **Testing**: CI pipeline checks for broken links (`markdown-link-check`) and spelling (`cspell`).
4. **Generation**: Static Site Generators (Docusaurus, MkDocs, Hugo).

### 2.1 Tooling

- **Docusaurus**: React-based. Standard for JS/TS projects.
- **MkDocs (Material)**: Python-based. Beautiful default theme.
- **Swagger UI**: For API references (OpenAPI).

---

## Part 3: API Documentation (OpenAPI/Swagger)

Don't write API docs manually. Generate them or write the Spec first.

```yaml
paths:
  /users:
    get:
      summary: List all users
      description: Returns a paginated list of users.
      parameters:
        - name: limit
          in: query
          description: Max number of results (default 10)
          schema:
            type: integer
      responses:
        '200':
          description: Success
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/UserList'
```

---

## Part 4: Writing Style Guide

### 4.1 Clarity & Conciseness

- **Bad**: "The user should ideally try to click the button in order to proceed."
- **Good**: "Click the button to proceed."

### 4.2 Voice & Tone

- **Voice**: Professional, Helpful, Authoritative.
- **Tone**: Varies.
  - *Error Message*: Calm, precise. "Payment failed." (Not: "Oops! You broke it.")
  - *Tutorial*: Encouraging. "Great! You built your first app."

### 4.3 Coding Standards in Docs

- All code blocks must specific the language (` ```python `).
- All code examples must be *copy-pasteable* and *working*.
- Use comments to explain the *why*, not the *what*.

---

## Part 5: The Perfect README

The "Home Page" of your repo.

1. **Title & One-Liner**: What is this?
2. **Badges**: CI Status, NPM Version, License.
3. **Features**: Bullet points.
4. **Installation**: `npm install my-lib`
5. **Usage**: minimal Example.
6. **Contributing**: Link to `.github/CONTRIBUTING.md`.

---

## Part 6: Best Practices Checklist

### ✅ Do This

- ✅ **Audience Analysis**: Who is reading this? Junior Dev? CTO? Adjust technical depth accordingly.
- ✅ **Use Visuals**: A Mermaid diagram is worth 1000 words.
- ✅ **Keep existing content up to date**: Stale docs are worse than no docs.
- ✅ **Use "You"**: Address the reader directly. "Run the command" (Imperative).

### ❌ Avoid This

- ❌ **Passive Voice**: "The button is clicked by the user". -> "Click the button".
- ❌ **Wall of Text**: Break it up with headers, lists, and code blocks.
- ❌ **Assuming Knowledge**: Link to prerequisites. Don't assume they know Docker.

---

## Related Skills

- `@senior-software-architect` - Source of Explanations
- `@senior-code-reviewer` - Reviewing the Markdown
- `@github-actions-specialist` - Automating Doc Builds

---
name: htmx-developer
description: "Expert HTMX development for hypermedia-driven applications with minimal JavaScript, server-side rendering, and progressive enhancement"
---

# HTMX Developer

## Overview

Build modern web applications using HTMX for hypermedia-driven interactions. HTMX allows you to access AJAX, CSS Transitions, WebSockets, and Server Sent Events directly in HTML, reducing the need for JavaScript while maintaining dynamic user experiences.

## When to Use This Skill

- Use when building server-rendered applications with dynamic updates
- Use when reducing JavaScript complexity is a priority
- Use when implementing progressive enhancement
- Use when building applications with any backend (Python, Go, Node, PHP, etc.)
- Use when you want simpler state management (server-side)

## Templates Reference

| Template | Description |
|----------|-------------|
| [basic-patterns.md](templates/basic-patterns.md) | Core HTMX attributes and patterns |
| [forms.md](templates/forms.md) | Form handling and validation |
| [tables.md](templates/tables.md) | Dynamic tables with pagination/search |
| [websockets.md](templates/websockets.md) | Real-time updates with SSE/WebSocket |

## How It Works

### Step 1: Include HTMX

```html
<script src="https://unpkg.com/htmx.org@1.9.10"></script>
```

### Step 2: Core Attributes

| Attribute | Description | Example |
|-----------|-------------|---------|
| `hx-get` | GET request to URL | `hx-get="/api/users"` |
| `hx-post` | POST request | `hx-post="/api/users"` |
| `hx-put` | PUT request | `hx-put="/api/users/1"` |
| `hx-delete` | DELETE request | `hx-delete="/api/users/1"` |
| `hx-target` | Where to put response | `hx-target="#result"` |
| `hx-swap` | How to swap content | `hx-swap="innerHTML"` |
| `hx-trigger` | When to trigger | `hx-trigger="click"` |
| `hx-indicator` | Loading indicator | `hx-indicator="#spinner"` |

### Step 3: Basic Example

```html
<!-- Button that loads content -->
<button 
  hx-get="/api/users" 
  hx-target="#users-list"
  hx-swap="innerHTML"
  hx-indicator="#loading"
>
  Load Users
</button>

<div id="loading" class="htmx-indicator">Loading...</div>
<div id="users-list"></div>
```

### Step 4: Form Submission

```html
<form 
  hx-post="/api/users" 
  hx-target="#result"
  hx-swap="outerHTML"
>
  <input name="name" required />
  <input name="email" type="email" required />
  <button type="submit">Create User</button>
</form>

<div id="result"></div>
```

### Step 5: Swap Strategies

| Value | Description |
|-------|-------------|
| `innerHTML` | Replace inner content (default) |
| `outerHTML` | Replace entire element |
| `beforebegin` | Insert before element |
| `afterbegin` | Insert at start of element |
| `beforeend` | Insert at end of element |
| `afterend` | Insert after element |
| `delete` | Delete the target element |
| `none` | No swap, just trigger events |

### Step 6: Triggers

```html
<!-- Click (default) -->
<button hx-get="/api/data">Click Me</button>

<!-- On load -->
<div hx-get="/api/data" hx-trigger="load">
  Loading...
</div>

<!-- Every 2 seconds -->
<div hx-get="/api/status" hx-trigger="every 2s">
  Status: checking...
</div>

<!-- On form change with debounce -->
<input 
  name="search" 
  hx-get="/api/search" 
  hx-trigger="keyup changed delay:500ms"
  hx-target="#results"
/>

<!-- Intersection observer -->
<div hx-get="/api/more" hx-trigger="revealed">
  Loading more...
</div>
```

## Best Practices

### ✅ Do This

- ✅ Return HTML fragments from server, not JSON
- ✅ Use `hx-boost` for progressive enhancement
- ✅ Implement proper loading indicators
- ✅ Use `hx-swap-oob` for updating multiple regions
- ✅ Handle errors with `hx-on::error`

### ❌ Avoid This

- ❌ Don't return full pages for partial updates
- ❌ Don't forget to set proper content-type
- ❌ Don't ignore accessibility with dynamic updates
- ❌ Don't skip server-side validation

## Common Pitfalls

**Problem:** Updates not working with JavaScript frameworks
**Solution:** Use `htmx.process(element)` after dynamic content insertion

**Problem:** CSRF token issues with forms
**Solution:** Include `hx-headers` or use `hx-include` to include token field

**Problem:** Browser back button breaks after HTMX navigation
**Solution:** Use `hx-push-url="true"` for history management

## Related Skills

- `@senior-backend-engineer-golang` - Go backend for HTMX
- `@python-flask-developer` - Flask backend for HTMX
- `@senior-laravel-developer` - Laravel backend for HTMX
- `@hono-developer` - Edge backend for HTMX

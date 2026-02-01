---
name: web-developer
description: "Foundational web development skills including HTML, CSS, JavaScript, responsive design, and modern web standards"
---

# Web Developer

## Overview

This skill provides foundational knowledge for building websites and web applications. Covers core technologies, best practices, and modern development workflows.

## When to Use This Skill

- Use when building websites from scratch
- Use when learning web development fundamentals
- Use when working with HTML, CSS, JavaScript
- Use when implementing responsive designs
- Use when debugging web pages

## How It Works

### Step 1: Web Development Stack

```text
WEB DEVELOPMENT LAYERS
├── Content Layer (HTML)
│   ├── Semantic elements
│   ├── Accessibility (ARIA)
│   └── SEO structure
├── Presentation Layer (CSS)
│   ├── Layout (Flexbox, Grid)
│   ├── Responsive design
│   └── Animations
├── Behavior Layer (JavaScript)
│   ├── DOM manipulation
│   ├── Event handling
│   └── Async programming
└── Tools & Workflow
    ├── Version control (Git)
    ├── Package managers (npm)
    └── Build tools (Vite)
```

### Step 2: HTML Structure

```html
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <meta name="description" content="Page description for SEO">
  <title>Page Title</title>
  <link rel="stylesheet" href="styles.css">
</head>
<body>
  <header>
    <nav aria-label="Main navigation">
      <ul>
        <li><a href="#home">Home</a></li>
        <li><a href="#about">About</a></li>
        <li><a href="#contact">Contact</a></li>
      </ul>
    </nav>
  </header>
  
  <main>
    <article>
      <h1>Main Heading</h1>
      <p>Content goes here...</p>
    </article>
  </main>
  
  <footer>
    <p>&copy; 2026 Company Name</p>
  </footer>
  
  <script src="script.js"></script>
</body>
</html>
```

### Step 3: CSS Modern Layout

```css
/* CSS Variables */
:root {
  --primary: #3b82f6;
  --background: #ffffff;
  --text: #1f2937;
  --spacing: 1rem;
}

/* Reset */
*, *::before, *::after {
  box-sizing: border-box;
  margin: 0;
  padding: 0;
}

/* Typography */
body {
  font-family: system-ui, -apple-system, sans-serif;
  line-height: 1.6;
  color: var(--text);
}

/* Flexbox Navigation */
nav ul {
  display: flex;
  gap: var(--spacing);
  list-style: none;
}

/* CSS Grid Layout */
.grid-container {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
  gap: var(--spacing);
}

/* Responsive Design */
@media (max-width: 768px) {
  nav ul {
    flex-direction: column;
  }
}
```

### Step 4: JavaScript Fundamentals

```javascript
// DOM Selection
const button = document.querySelector('#submit-btn');
const form = document.querySelector('#contact-form');

// Event Handling
button.addEventListener('click', handleClick);

function handleClick(event) {
  event.preventDefault();
  console.log('Button clicked!');
}

// Form Handling
form.addEventListener('submit', async (e) => {
  e.preventDefault();
  
  const formData = new FormData(form);
  const data = Object.fromEntries(formData);
  
  try {
    const response = await fetch('/api/submit', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(data)
    });
    
    if (!response.ok) throw new Error('Submit failed');
    
    const result = await response.json();
    console.log('Success:', result);
  } catch (error) {
    console.error('Error:', error);
  }
});

// DOM Manipulation
function addItem(text) {
  const list = document.querySelector('#item-list');
  const li = document.createElement('li');
  li.textContent = text;
  list.appendChild(li);
}
```

### Step 5: Project Structure

```text
project/
├── index.html
├── css/
│   ├── reset.css
│   ├── variables.css
│   ├── layout.css
│   └── components.css
├── js/
│   ├── main.js
│   └── utils.js
├── assets/
│   ├── images/
│   └── fonts/
└── README.md
```

## Best Practices

### ✅ Do This

- ✅ Use semantic HTML elements
- ✅ Make sites responsive (mobile-first)
- ✅ Optimize images (WebP, lazy loading)
- ✅ Ensure accessibility (ARIA, keyboard nav)
- ✅ Validate HTML/CSS
- ✅ Use CSS custom properties
- ✅ Keep JavaScript unobtrusive

### ❌ Avoid This

- ❌ Don't use tables for layout
- ❌ Don't skip meta viewport tag
- ❌ Don't inline all CSS/JS
- ❌ Don't ignore browser compatibility
- ❌ Don't forget alt text for images

## Related Skills

- `@senior-react-developer` - React applications
- `@senior-nextjs-developer` - Full-stack web
- `@senior-tailwindcss-developer` - Utility CSS
- `@senior-webperf-engineer` - Performance

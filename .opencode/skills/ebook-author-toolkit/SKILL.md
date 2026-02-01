---
name: ebook-author-toolkit
description: "Expert ebook creation including writing, formatting, PDF generation, and publishing"
---

# Ebook Author Toolkit

## Overview

Create professional ebooks from writing to publishing-ready PDF.

## When to Use This Skill

- Use when writing ebooks
- Use when creating PDF publications

## How It Works

### Step 1: Ebook Structure

```markdown
## Standard Ebook Layout

1. Cover Page
2. Title Page
3. Copyright/Legal
4. Table of Contents
5. Introduction/Preface
6. Chapters (main content)
7. Conclusion
8. Appendix (optional)
9. About the Author
10. Resources/References
```

### Step 2: Writing in Markdown

```markdown
# Chapter 1: Getting Started

## Introduction

Welcome to this comprehensive guide. In this chapter,
you'll learn the fundamentals.

> **Key Takeaway**: Always start with the basics before
> moving to advanced topics.

### Section 1.1: Prerequisites

Before we begin, make sure you have:

- [ ] Basic understanding of X
- [ ] Software Y installed
- [ ] A cup of coffee ☕

### Section 1.2: Your First Example

Here's a simple code example:

\```python
def hello_world():
    print("Hello, World!")
\```

---

## Summary

In this chapter, we covered:
1. Introduction to the topic
2. Prerequisites needed
3. Your first example
```

### Step 3: Convert Markdown to PDF (Python)

```python
# Using markdown + weasyprint
from markdown import markdown
from weasyprint import HTML, CSS

def create_ebook(chapters, output_file):
    # CSS for ebook styling
    css = CSS(string='''
        @page {
            size: A5;
            margin: 2cm;
            @top-center { content: "My Ebook Title"; }
            @bottom-center { content: counter(page); }
        }
        body {
            font-family: 'Georgia', serif;
            font-size: 12pt;
            line-height: 1.6;
        }
        h1 { 
            page-break-before: always;
            color: #2c3e50;
        }
        h2 { color: #34495e; margin-top: 24pt; }
        code {
            background: #f5f5f5;
            padding: 2px 6px;
            border-radius: 3px;
        }
        pre {
            background: #282c34;
            color: #abb2bf;
            padding: 16px;
            border-radius: 8px;
            overflow-x: auto;
        }
        blockquote {
            border-left: 4px solid #3498db;
            margin: 16px 0;
            padding-left: 16px;
            color: #555;
        }
    ''')
    
    # Combine all chapters
    html_content = '<html><body>'
    for chapter in chapters:
        html_content += markdown(chapter, extensions=['fenced_code', 'tables'])
    html_content += '</body></html>'
    
    # Generate PDF
    HTML(string=html_content).write_pdf(output_file, stylesheets=[css])
```

### Step 4: Cover Design

```markdown
## Cover Essentials

### Elements
- Title (large, readable)
- Subtitle (if applicable)
- Author name
- Cover image/illustration
- Brand colors

### Tools
- Canva (free templates)
- Figma (custom design)
- Book Brush (3D mockups)

### Specs
- Amazon KDP: 1600x2560 px
- Standard: 1400x2100 px (6x9 ratio)
- Format: JPEG or PDF
```

### Step 5: Table of Contents Generator

```python
import re

def generate_toc(markdown_content):
    """Generate TOC from markdown headers"""
    toc = []
    lines = markdown_content.split('\n')
    
    for line in lines:
        # Match headers
        match = re.match(r'^(#{1,3})\s+(.+)$', line)
        if match:
            level = len(match.group(1))
            title = match.group(2)
            slug = title.lower().replace(' ', '-')
            
            indent = '  ' * (level - 1)
            toc.append(f"{indent}- [{title}](#{slug})")
    
    return '\n'.join(toc)
```

### Step 6: Publishing Platforms

```markdown
## Self-Publishing

### Amazon KDP
- Kindle ebook + Paperback
- 70% royalty (ebook)
- Free to publish

### Gumroad
- 10% fee + processing
- Direct payments
- Good for niche

### Leanpub
- 80% royalty
- In-progress publishing
- Great for tech books

## Formats
| Platform | Format |
|----------|--------|
| Amazon | MOBI, EPUB, PDF |
| Apple | EPUB |
| Gumroad | PDF |
| Leanpub | PDF, EPUB, MOBI |
```

## Best Practices

- ✅ Outline before writing
- ✅ Professional cover design
- ✅ Proofread multiple times
- ❌ Don't skip editing
- ❌ Don't ignore formatting

## Related Skills

- `@digital-product-creator`
- `@copywriting`

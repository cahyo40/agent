---
name: book-cover-architect
description: "Specialist in AI-assisted book cover design across genres, focusing on composition, spill, and emotional resonance"
---

# Book Cover Architect

## Overview

Master the architecture of book covers. This skill focuses on translating literary themes into visual hooks, managing the "Cover-Spine-Back" layout, and using AI to generate high-fidelity imagery that resonates with specific reader demographics.

## When to Use This Skill

- Use when designing covers for self-publishing authors or commercial publishers
- Use for conceptualizing book series with consistent branding
- Use when you need to match a visual style to a specific genre (Thriller, Romance, Sci-Fi)
- Use for creating "Wraparound" covers (Front, Spine, and Back in one image)

## How It Works

### Step 1: Genre Synthesis

- **Sci-Fi/Fantasy**: High-contrast, wide-angle, epic scale, glowing elements.
- **Thriller/Mystery**: Low-key lighting, silhouettes, brooding colors, macro textures.
- **Non-Fiction**: Clean, bold typography, symbolic imagery, high negative space.

### Step 2: The "Hook" Composition

- **Central Motif**: Identifying a single object or character that represents the book's soul.
- **Depth & Dimension**: Using prompt keywords like "bokeh," "layered composition," or "isometric view."

### Step 3: Layout & Bleed

```text
PROMPT FOR WRAPAROUND:
"Ultra-wide panoramic fantasy landscape, enchanted forest, left side (back cover) is darker and simpler, center (spine) has vertical texture, right side (front cover) has main character, cinematically detailed, --ar 3:2"
```

### Step 4: Iterative Refinement

- Using "Inpainting" to fix specific details (like a character's eye color) without changing the overall cover art.

## Best Practices

### ✅ Do This

- ✅ Research top-selling books in the target genre for visual cues
- ✅ Use "Aspect Ratio" that matches the physical book size (e.g., 6x9 inch -> `--ar 2:3`)
- ✅ Prompt for a "Masterpiece," "Digital Art," or "Oil Painting" to avoid a "cheap stock photo" look
- ✅ Ensure the focal point is in the right-hand third (The Front Cover)
- ✅ Add keywords for emotional tone (e.g., "Melancholic," "Fast-paced," "Whimsical")

### ❌ Avoid This

- ❌ Don't place critical elements exactly in the center (The Spine area if wraparound)
- ❌ Avoid low-resolution generations—always upscale or generate at high quality
- ❌ Don't ignore the "Target Audience" visual preferences
- ❌ Avoid using too many colors—stick to a curated 3-color palette for impact

## Related Skills

- `@ai-poster-designer` - Compositional overlap
- `@illustration-creator` - Custom character/icon art
- `@copywriting` - Perfecting the blurb and taglines

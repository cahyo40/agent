---
name: ai-image-prompt-engineer
description: "Expert AI image prompt engineering for high-fidelity visual content using Midjourney v6, Flux, DALL-E 3, and Stable Diffusion XL"
---

# AI Image Prompt Engineer (Advanced)

## Overview

Master the science of AI image generation. This skill covers advanced prompt structures, lighting physics, camera optics, art history styles, and technical parameters for the world's most powerful AI models (Midjourney, Flux.1, Stable Diffusion XL, DALL-E 3).

## When to Use This Skill

- Use for any professional creative project requiring AI-generated visual assets
- Use for consistent character/style generation across multiple images
- Use when precision in lighting, angle, and texture is required
- Use for benchmarking and selecting the best AI model for a specific artistic task

## How It Works

### Step 1: Scientific Prompt Structure (The 5-Layer Model)

1. **Subject**: The core entity (Who/What).
2. **Action/Context**: What the subject is doing and where.
3. **Descriptor/Aesthetic**: Textures, materials, art styles (e.g., "Satin finish," "Surrealism").
4. **Lighting & Atmosphere**: Physics of light (e.g., "Volumetric lighting," "Chiaroscuro," "Global illumination").
5. **Camera & Technical**: Optics (e.g., "85mm lens," "f/1.8," "Shot on IMAX," "Shallow depth of field").

### Step 2: Lighting & Materials Physics

| Keyword | Effect | Best Use |
|---------|--------|----------|
| **Rembrandt Lighting** | High-contrast, moody, 45-degree angle | Portraits |
| **God Rays** | Beams of light through dust/fog | Nature, Spiritual |
| **Bioluminescence** | Glowing organic elements | Sci-fi, Fantasy |
| **Subsurface Scattering** | Light passing through wax/skin | Realism |
| **Iridescent** | Rainbow-like color shifts | Futuristic, Fashion |

### Step 3: Camera Optics & Composition

- **Focal Length**: `35mm` (Storytelling), `85mm` (Portraits), `14mm` (Aggressive wide).
- **Aperture**: `f/1.8` (Blurred background), `f/22` (Infinite focus).
- **Angles**: `Low angle` (Heroic), `Bird's eye` (Overview), `Dutch angle` (Tension).

### Step 4: Model Specific Parameters

```markdown
### Midjourney v6
--ar 16:9      (Aspect Ratio)
--stylize 250  (Aesthetics)
--chaos 10     (Variation)
--weird 50     (Unique vibes)
--cref [url]   (Character Reference)
--sref [url]   (Style Reference)

### Stable Diffusion / Flux
(Prompt Weighting): (subject:1.5)
Negative Prompt: (deformed, blurry, watermark, lowres:1.3)
```

## Best Practices

### ✅ Do This

- ✅ Describe the "Light Source" explicitly (e.g., "Sunlight through blinds")
- ✅ Use "Medium" descriptors (e.g., "Oil on canvas," "3D render," "Polaroid")
- ✅ Implement "Negative Prompting" to remove unwanted artifacts
- ✅ Leverage "Reference Images" (ID, SREF) to maintain consistency
- ✅ Keep prompts structured and avoid "Keyword Soup"

### ❌ Avoid This

- ❌ Don't use contradictory terms (e.g., "Minimalist high-detail")
- ❌ Avoid generic quality words like "Beautiful" or "Stunning"—be technical instead
- ❌ Don't ignore the importance of "Aspect Ratio" for composition
- ❌ Avoid over-weighting prompts which can lead to visual "deep-frying"

## Related Skills

- `@ai-poster-designer` - Layout focus
- `@digital-human-architect` - High-fidelity character focus
- `@generative-video-specialist` - Transition into motion

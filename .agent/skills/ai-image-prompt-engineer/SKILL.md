---
name: ai-image-prompt-engineer
description: "Expert AI image prompt engineering for high-fidelity visual content using Midjourney v6, Flux, DALL-E 3, and Stable Diffusion XL"
---

# AI Image Prompt Engineer

## Overview

This skill transforms you into an **AI Image Generation Expert**. You will master the **Prompt Syntax** for major platforms (Midjourney, FLUX, DALL-E 3, SDXL), understand **Model Strengths**, and craft prompts that produce professional-quality visuals consistently.

## When to Use This Skill

- Use when generating hero images for websites/thumbnails
- Use when creating concept art and storyboards
- Use when building consistent characters across images
- Use when understanding which model to use for which task
- Use when troubleshooting poor generation results

---

## Part 1: Model Comparison

| Model | Strength | Weakness | Best For |
|-------|----------|----------|----------|
| **Midjourney v6** | Aesthetics, composition | Less control | Art, marketing |
| **FLUX.1** | Photorealism, text-in-image | Slower | Product shots, photos |
| **DALL-E 3** | Prompt adherence, ChatGPT integration | Less artistic | Illustrations, concepts |
| **Stable Diffusion XL** | Control (LoRA, ControlNet) | Requires setup | Custom workflows |

---

## Part 2: Prompt Structure

### 2.1 The Formula

`[Subject] + [Action/Pose] + [Setting] + [Lighting] + [Style] + [Camera/Lens] + [Mood]`

**Example:**
`A young woman reading a book in a cozy cafe, warm afternoon sunlight through window, soft focus background, shot on Leica, nostalgic mood, 35mm film grain`

### 2.2 Specificity Wins

| Vague | Specific |
|-------|----------|
| "A dog" | "A golden retriever puppy sitting in a field of sunflowers" |
| "A city" | "Tokyo street at night, neon signs reflecting on wet pavement" |
| "Portrait" | "Portrait of a 30-year-old man, salt and pepper beard, kind eyes, studio lighting, white background" |

---

## Part 3: Style & Aesthetic Keywords

### 3.1 Art Styles

| Keyword | Effect |
|---------|--------|
| `photorealistic` | Like a photograph |
| `digital art` | Clean, modern illustration |
| `oil painting` | Textured, classical |
| `anime style` | Japanese animation |
| `watercolor` | Soft, transparent washes |
| `concept art` | Game/film pre-production look |

### 3.2 Photography Styles

| Keyword | Effect |
|---------|--------|
| `shot on Hasselblad` | Medium format look |
| `35mm film` | Grain, vintage color |
| `cinematic` | Movie still, widescreen |
| `studio lighting` | Clean, commercial |
| `golden hour` | Warm, soft shadows |

### 3.3 Mood Modifiers

`dramatic`, `serene`, `melancholic`, `joyful`, `mysterious`, `eerie`, `romantic`

---

## Part 4: Platform-Specific Syntax

### 4.1 Midjourney

```
/imagine prompt: A samurai in cherry blossom forest, dramatic lighting, oil painting style --ar 2:3 --v 6 --style raw --no text
```

**Parameters:**

- `--ar 2:3`: Aspect ratio (vertical).
- `--v 6`: Version 6 model.
- `--style raw`: Less Midjourney "beautification".
- `--no text`: Avoid accidental text in image.
- `--cref [url]`: Character reference (keep same face).

### 4.2 FLUX (via Replicate/ComfyUI)

FLUX follows prompts very literally. Be detailed about everything.

- Works great with long, descriptive prompts.
- Excellent at text-in-image.

### 4.3 DALL-E 3

Accessed via ChatGPT or API. Will "rewrite" your prompt for safety.

- Less control, but very good prompt understanding.
- Best for quick concepts.

---

## Part 5: Advanced Techniques

### 5.1 Negative Prompts (SDXL/Flux)

Tell the model what to avoid.
`Negative: blurry, low quality, distorted hands, extra fingers, watermark`

### 5.2 ControlNet (SDXL)

Control pose, composition, or depth with a reference image.

- **Pose**: Upload skeleton, generate character in that pose.
- **Depth**: Control foreground/background separation.
- **Canny Edge**: Maintain structure from line art.

### 5.3 LoRA (SDXL)

Small fine-tuned models to add specific styles or characters.

- "Pixar style LoRA", "Anime character LoRA".
- Combine with ControlNet for maximum control.

---

## Part 6: Best Practices Checklist

### ✅ Do This

- ✅ **Iterate**: Generate 4 images, refine prompt, repeat.
- ✅ **Study Winners**: Explore public galleries (Midjourney Explore, Civitai).
- ✅ **Use Reference Images**: Where supported (--cref, ControlNet).

### ❌ Avoid This

- ❌ **Overly Long Prompts (Midjourney)**: Keep under 150 words. Quality drops.
- ❌ **Conflicting Instructions**: "Dark and bright" confuses the model.
- ❌ **Expecting Consistent Hands**: Regenerate or inpaint.

---

## Related Skills

- `@thumbnail-designer` - Using generated images in thumbnails
- `@ai-poster-designer` - Poster composition
- `@generative-video-specialist` - Animating the output

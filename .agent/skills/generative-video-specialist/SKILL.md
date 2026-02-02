---
name: generative-video-specialist
description: "Expert in AI video generation tools and techniques including Sora-style prompting, AnimateDiff, and video-to-video translation"
---

# Generative Video Specialist

## Overview

This skill transforms you into a **Video Generation Expert**. You will master the technical details of **Runway Gen-3**, **Pika**, **Kling**, **AnimateDiff**, and **Sora-style prompting** to create professional-quality AI-generated video footage.

## When to Use This Skill

- Use when generating video clips from text prompts
- Use when animating still images (Image-to-Video)
- Use when extending existing footage (Video-to-Video)
- Use when creating consistent character motion
- Use when understanding video model limitations

---

## Part 1: Video Generation Fundamentals

### 1.1 How It Works

Most video models are "Diffusion Models" trained on video frames.

- Input: Text prompt (or image + text).
- Output: Short video clip (4-10 seconds typical).
- Process: Model generates each frame while maintaining temporal coherence.

### 1.2 Key Concepts

| Term | Meaning |
|------|---------|
| **Temporal Coherence** | Frames are consistent; no flickering |
| **Motion Fidelity** | Movement looks natural, follows physics |
| **Style Lock** | Visual style remains consistent |
| **Seed** | Random number that affects generation |

---

## Part 2: Tool Deep Dive

### 2.1 Runway Gen-3 Alpha

- **Strength**: Best motion, realistic physics.
- **Duration**: Up to 10 seconds.
- **Modes**: Text-to-Video, Image-to-Video.
- **Camera Control**: Built-in (dolly, pan, tilt).

**Prompting Tips:**

- Be specific about camera motion: "slow dolly forward".
- Describe lighting: "golden hour, soft shadows".
- Avoid complex multi-character interactions.

### 2.2 Kling AI

- **Strength**: Longer clips (up to 2 min), action scenes.
- **Access**: Web app (regional restrictions).
- **Best For**: Dynamic action, flowing motion.

### 2.3 Pika Labs

- **Strength**: Stylization, artistic looks.
- **Access**: Discord + Web app.
- **Best For**: Music videos, abstract visuals.

### 2.4 AnimateDiff (Open Source)

- **Strength**: Run locally, customize heavily.
- **Requires**: Stable Diffusion + Motion modules.
- **Best For**: Anime, stylized content, privacy.

---

## Part 3: Prompting Strategies

### 3.1 Structure

`[Camera Movement] + [Subject] + [Action] + [Setting] + [Atmosphere] + [Style]`

**Example:**
`Slow tracking shot following a woman walking through cherry blossoms, petals falling, soft sunlight, dreamlike atmosphere, cinematic film look`

### 3.2 Camera Motion Keywords

| Keyword | Effect |
|---------|--------|
| `static shot` | No camera movement |
| `dolly in/out` | Move toward/away from subject |
| `pan left/right` | Rotate camera horizontally |
| `tilt up/down` | Rotate camera vertically |
| `tracking shot` | Follow subject laterally |
| `drone rising` | Aerial lift upward |
| `handheld` | Subtle shake, documentary feel |

### 3.3 Style Modifiers

- `cinematic, anamorphic lens, film grain`
- `anime style, Studio Ghibli`
- `vintage 8mm film, light leaks`
- `cyberpunk, neon lighting, rain`

---

## Part 4: Image-to-Video (I2V)

Animate a still image.

### 4.1 Best Practices

1. **Use AI-generated images**: Midjourney/FLUX provide optimal quality.
2. **Choose "action-ready" poses**: Subject should look like they're about to move.
3. **Describe the motion**: "The woman turns her head and smiles".

### 4.2 Limitations

- Hands/fingers often distort.
- Complex clothing may warp.
- Background may shift unexpectedly.

---

## Part 5: Video-to-Video (V2V) & Extension

### 5.1 Style Transfer

Apply AI styles to existing footage.

- Upload reference video + style prompt.
- Output: Same motion, new visual style.

### 5.2 Video Extension

Extend existing clips beyond original length.

- Upload last frame + prompt for continuation.
- Useful for "what happens next" scenarios.

---

## Part 6: Best Practices Checklist

### ✅ Do This

- ✅ **Generate Multiple Takes**: Generate 5-10 versions, pick the best.
- ✅ **Fix in Post**: Composite good frames from multiple generations.
- ✅ **Use Negative Prompts**: "no distorted faces, no blurry motion".

### ❌ Avoid This

- ❌ **Complex Multi-Character Scenes**: AI struggles with interactions.
- ❌ **Fast Action**: Quick movements often cause artifacts.
- ❌ **Expecting 4K Immediately**: Most output 720p-1080p, upscale afterward.

---

## Related Skills

- `@ai-native-filmmaker` - Full pipeline integration
- `@ai-image-prompt-engineer` - Creating source images
- `@video-processing-specialist` - Post-processing the output

---
name: digital-human-architect
description: "Expert in creating realistic digital humans, virtual influencers, and AI avatars for media and interactive apps"
---

# Digital Human Architect

## Overview

This skill transforms you into a **Virtual Human Creator**. You will master **AI Avatar Generation**, **Deepfake Ethics**, **Virtual Influencer Design**, and **Real-time Avatar Animation** for creating believable digital humans.

## When to Use This Skill

- Use when creating virtual influencers (Social media personas)
- Use when building AI avatars for customer service
- Use when generating consistent character faces for content
- Use when animating digital humans with lip-sync
- Use when understanding deepfake detection and ethics

---

## Part 1: AI Face Generation

### 1.1 Photo-Realistic Faces

**Tools:**

- **Midjourney**: `portrait of a [age] [ethnicity] [gender], studio lighting, 8k --v 6`
- **FLUX.1**: Excellent skin texture, photorealistic.
- **StyleGAN (This Person Does Not Exist)**: Fully synthetic faces.

### 1.2 Consistency Across Images

The challenge: Keeping the same character across multiple images.

**Solutions:**

1. **Reference Image + IPAdapter**: Feed a base image to maintain likeness.
2. **LoRA Training**: Fine-tune on 10-20 images of your character (200 steps).
3. **Seed Locking**: Use same seed + similar prompts.

**Prompt Template:**
`[Consistent character name], [age], [ethnicity], [action/emotion], [setting], [lighting], consistent with reference --cref [image_url]`

---

## Part 2: Virtual Influencer Design

### 2.1 Character Bible

Before generating images, define:

- **Name**: e.g., "Ava Chen".
- **Age/Ethnicity**: 25-year-old Korean-American.
- **Personality**: Witty, tech-savvy, fashion-forward.
- **Visual Style**: Pastel colors, minimalist aesthetic.
- **Signature Look**: Always wears blue glasses.

### 2.2 Content Pillars

What does your virtual influencer post about?

- Tech reviews, fashion, travel, cooking, etc.

### 2.3 Case Studies

| Influencer | Followers | Notes |
|------------|-----------|-------|
| **Lil Miquela** | 2.5M IG | Hyperrealistic, music artist |
| **Imma** | 400K IG | Japanese, fashion focus |
| **Noonoouri** | 400K IG | Stylized CGI, luxury brands |

---

## Part 3: Lip-Sync & Animation

### 3.1 Audio-Driven Animation

**Tools:**

- **Sync Labs / HeyGen**: Upload image + audio, get talking video.
- **Hedra AI**: High-quality lip sync.
- **SadTalker (Open Source)**: Run locally, animate a face.

### 3.2 Full Body Motion

- **Move.ai**: Motion capture from video.
- **Unreal Engine MetaHuman**: Real-time 3D avatars.
- **Ready Player Me**: Cross-platform 3D avatars.

---

## Part 4: Deepfake Ethics & Detection

### 4.1 Ethical Guidelines

1. **Consent**: Never create fake content of real people without permission.
2. **Disclosure**: Label AI-generated content as synthetic.
3. **Malice Prevention**: Don't create misleading or harmful content.

### 4.2 Detection Tools

- **Microsoft Video Authenticator**: Detects manipulation.
- **Sensity AI**: Deepfake detection API.
- **C2PA Standard**: Provenance metadata (Adobe CAI).

---

## Part 5: Real-Time Avatars (Metaverse)

### 5.1 Platforms

- **Unreal MetaHuman**: Cinematic quality, requires high-end hardware.
- **Ready Player Me**: Cross-platform (VRChat, web, apps).
- **Codec Avatars (Meta)**: Research-grade photorealism.

### 5.2 Use Cases

- **Virtual Customer Support**: AI avatar answers queries.
- **Virtual Presenter**: Webinars, product demos.
- **Gaming NPCs**: Dynamic conversation-driven characters.

---

## Part 6: Best Practices Checklist

### ✅ Do This

- ✅ **Build a Consistent Aesthetic**: Same lighting, color grade across all images.
- ✅ **Use Multiple Poses/Expressions**: Create variety for social content.
- ✅ **Disclose AI Origin**: "This is a virtual influencer powered by AI."

### ❌ Avoid This

- ❌ **Uncanny Valley**: If skin looks waxy or eyes are dead, regenerate.
- ❌ **Inconsistent Features**: Changing nose shape or eye color breaks immersion.
- ❌ **Ignoring Legal Issues**: Consult IP lawyers for commercial virtual influencers.

---

## Related Skills

- `@ai-image-prompt-engineer` - Generating consistent faces
- `@generative-video-specialist` - Animating the avatar
- `@voice-assistant-developer` - Adding conversational AI

---
name: generative-video-specialist
description: "Expert in AI video generation tools and techniques including Sora-style prompting, AnimateDiff, and video-to-video translation"
---

# Generative Video Specialist

## Overview

Master the cutting-edge field of AI video generation. Expertise in Sora-style text-to-video prompting, AnimateDiff (Stable Diffusion), video-to-video stylization, temporal consistency, and high-fidelity video upscaling.

## When to Use This Skill

- Use when creating AI-generated marketing videos or cinematic clips
- Use when automating video animation from static images
- Use for consistent video-to-video style transfer
- Use when implementing AI video workflows in creative pipelines

## How It Works

### Step 1: Text-to-Video & Motion Control

- **Prompting for Motion**: Using descriptive keywords for camera movement (Tracking, Pan, Zoom) and subject action.
- **Motion LoRA**: Fine-tuned models for specific types of movement (Walking, Dancing).

### Step 2: AnimateDiff & ComfyUI Workflows

```text
COMFYUI WORKFLOW NODES:
- Checkpoint Loader (AnimateDiff optimized)
- Context Options (Window length for long videos)
- ControlNet (Depth/OpenPose for structural consistency)
- KSampler (Steps, CFG, Motion Scale)
```

### Step 3: Video-to-Video Stylization

- **Ebsynth**: Propagating style from keyframes across video frames.
- **ControlNet Video**: Using Canny or Softedge to guide AI generation based on existing video frames for perfect alignment.

### Step 4: Temporal Consistency & Upscaling

- **Flicker Reduction**: Using Deflicker tools or high-overlap sampling.
- **Upscaling**: Using Topaz Video AI or custom Real-ESRGAN/SwinIR models for 4K output.

## Best Practices

### ✅ Do This

- ✅ Use ControlNet for maintaining character and environment consistency
- ✅ Generate at lower resolutions first and upscale to save GPU time
- ✅ Use high CFG values for strong adherence to the prompt
- ✅ Balance motion scale to avoid "melting" artifacts
- ✅ Frame-by-frame post-processing for high-stakes clips

### ❌ Avoid This

- ❌ Don't expect perfect one-shot results; use iterative seed hunting
- ❌ Don't ignore the importance of motion consistency across long clips
- ❌ Don't use heavy prompts without negative prompts for artifact removal
- ❌ Don't skip secondary motion (hair, clothes) descriptions

## Related Skills

- `@video-processing-specialist` - Technical engineering
- `@ai-image-prompt-engineer` - Prompt foundation
- `@senior-ai-ml-engineer` - Model architecture

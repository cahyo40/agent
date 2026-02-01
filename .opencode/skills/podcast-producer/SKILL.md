---
name: podcast-producer
description: "Expert podcast production including recording, editing, and distribution"
---

# Podcast Producer

## Overview

Produce professional podcasts from recording to distribution.

## When to Use This Skill

- Use when starting a podcast
- Use when improving audio quality

## How It Works

### Step 1: Recording Setup

```markdown
## Equipment Recommendations

### Budget Setup
- Mic: Audio-Technica ATR2100x
- Interface: Built-in USB
- Software: Audacity (free)

### Pro Setup
- Mic: Shure SM7B
- Interface: Focusrite Scarlett
- Software: Adobe Audition / Logic

### Recording Tips
- Room with soft surfaces
- Consistent mic distance (6-12 inches)
- Record at -12dB to -6dB
- Always record backup
```

### Step 2: Audio Editing

```bash
# FFmpeg audio processing
# Normalize audio
ffmpeg -i input.wav -af "loudnorm=I=-16:LRA=11:TP=-1.5" output.wav

# Remove silence
ffmpeg -i input.wav -af "silenceremove=1:0:-50dB" output.wav

# Add noise reduction (using sox)
sox input.wav output.wav noisered noise.prof 0.21
```

### Step 3: Episode Structure

```markdown
## Standard Episode Format

0:00 - Cold open (hook/teaser)
0:30 - Intro music + welcome
1:00 - Episode overview
2:00 - Main content
     - Segment 1 (10-15min)
     - Segment 2 (10-15min)
40:00 - Listener Q&A / feedback
45:00 - Wrap-up + CTA
46:00 - Outro music

## Show Notes Template
- Episode title
- Guest bio (if applicable)
- Key timestamps
- Links mentioned
- Transcript
```

### Step 4: Distribution

```markdown
## Podcast Hosting
- Buzzsprout
- Anchor (free)
- Libsyn
- Transistor

## RSS Distribution
Submit to:
- Apple Podcasts
- Spotify
- Google Podcasts
- Amazon Music
- Stitcher
```

## Best Practices

- ✅ Consistent release schedule
- ✅ Quality audio over everything
- ✅ Engage with listeners
- ❌ Don't skip editing
- ❌ Don't ignore metadata

## Related Skills

- `@video-editor-automation`
- `@script-writer`

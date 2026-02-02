---
name: livestream-producer
description: "Expert livestream production including OBS, stream setup, and audience engagement"
---

# Livestream Producer

## Overview

This skill transforms you into a **Live Broadcast Specialist**. You will master **OBS Studio**, **Stream Setup**, **Engagement Techniques**, and **Multi-Platform Streaming** for professional live content production.

## When to Use This Skill

- Use when setting up live streaming infrastructure
- Use when producing live events (gaming, talks, webinars)
- Use when configuring OBS scenes and sources
- Use when optimizing stream quality
- Use when building audience engagement

---

## Part 1: Streaming Fundamentals

### 1.1 Key Components

| Component | Purpose |
|-----------|---------|
| **Encoder** | Converts video to stream (OBS, Streamlabs) |
| **RTMP Server** | Receives stream (YouTube, Twitch) |
| **CDN** | Distributes to viewers globally |
| **Chat** | Real-time audience interaction |

### 1.2 Streaming Flow

```
Camera/Screen -> Encoder (OBS) -> RTMP Ingest -> Platform CDN -> Viewers
```

---

## Part 2: OBS Studio Setup

### 2.1 Key Concepts

| Term | Meaning |
|------|---------|
| **Scene** | A layout of sources |
| **Source** | Camera, screen, image, text |
| **Profile** | Saved encoder settings |
| **Scene Collection** | Set of scenes |

### 2.2 Recommended Settings

| Setting | Value |
|---------|-------|
| **Resolution** | 1920x1080 |
| **FPS** | 30 (talks) or 60 (gaming) |
| **Bitrate** | 4500-6000 kbps |
| **Encoder** | NVENC (GPU) or x264 (CPU) |
| **Keyframe Interval** | 2 seconds |

### 2.3 Essential Sources

- **Video Capture Device**: Webcam.
- **Display Capture**: Screen share.
- **Browser Source**: Alerts, widgets, overlays.
- **Audio Input Capture**: Microphone.
- **Media Source**: Pre-recorded video/audio.

---

## Part 3: Audio Quality

### 3.1 Audio is 50% of Quality

Bad audio = viewers leave.

### 3.2 OBS Audio Filters

Apply in order:

1. **Noise Suppression**: Remove background noise (RNNoise).
2. **Gain**: Boost quiet mics.
3. **Compressor**: Even out loud/quiet parts.
4. **Limiter**: Prevent clipping.

### 3.3 Recommended Levels

- **Target**: -12 to -6 dB.
- **Peak**: Never exceed 0 dB.

---

## Part 4: Overlays & Alerts

### 4.1 Overlay Elements

| Element | Purpose |
|---------|---------|
| **Webcam Frame** | Branded border |
| **Lower Third** | Name, title |
| **Chat Box** | Show live chat on screen |
| **Alerts** | New follower, donation |
| **Goals** | Donation/follower progress bar |

### 4.2 Tools

- **StreamElements**: Free overlays, alerts.
- **Streamlabs**: Widgets, tips.
- **OWN3D**: Premium overlay packs.
- **Canva**: Custom graphics.

---

## Part 5: Engagement Techniques

### 5.1 Pre-Stream

- **Announce Schedule**: "Going live at 7 PM EST".
- **Countdown Timer**: Browser source OBS.

### 5.2 During Stream

| Technique | How |
|-----------|-----|
| **Acknowledge Chatters** | "Welcome @username!" |
| **Ask Questions** | "What do you think about X?" |
| **Polls** | Use platform polls feature |
| **Challenges** | "Hit 100 likes for a giveaway" |
| **Moderation** | Have mods to manage trolls |

### 5.3 Post-Stream

- **Clip Highlights**: Post to TikTok/Shorts.
- **Thank Supporters**: Public shoutout.
- **Analyze Stats**: Peak viewers, average watch time.

---

## Part 6: Multi-Platform Streaming

### 6.1 Why Multistream?

Reach audiences on YouTube, Twitch, and Facebook simultaneously.

### 6.2 Tools

| Tool | Notes |
|------|-------|
| **Restream.io** | Free tier, cloud-based |
| **Streamyard** | Browser-based, easy guests |
| **OBS + Multiple RTMP** | Manual but full control |

### 6.3 Platform Considerations

- **Twitch**: Community-focused, subs, bits.
- **YouTube**: Best discoverability, VOD.
- **Facebook**: Older demographic, groups.

---

## Part 7: Best Practices Checklist

### ✅ Do This

- ✅ **Test Before Going Live**: Run a private test stream.
- ✅ **Backup Internet**: Have mobile hotspot ready.
- ✅ **Engage Early**: First 5 minutes set the tone.

### ❌ Avoid This

- ❌ **Reading Every Comment**: Prioritize, don't get hijacked.
- ❌ **Overly Complex Scenes**: Keep it clean.
- ❌ **No Call to Action**: Ask for follows, subs, shares.

---

## Related Skills

- `@video-processing-specialist` - Post-production
- `@audio-processing-specialist` - Audio quality
- `@senior-youtube-content-creator` - Platform strategy

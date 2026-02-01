---
name: content-repurposer
description: "Expert content repurposing to transform one piece of content into multiple formats"
---

# Content Repurposer

## Overview

Transform one piece of content into multiple formats for maximum reach.

## When to Use This Skill

- Use when maximizing content ROI
- Use when building content systems

## How It Works

### Step 1: Repurposing Framework

```markdown
## 1 → 10 Content Strategy

### From 1 YouTube Video:
1. YouTube Long-form → Original
2. TikTok/Reels → 3-5 short clips
3. Twitter Thread → Key points
4. LinkedIn Post → Professional angle
5. Blog Post → Written version
6. Newsletter → Email digest
7. Carousel → Visual slides
8. Quote Graphics → Shareable images
9. Podcast Episode → Audio version
10. Pinterest Pins → Evergreen visuals
```

### Step 2: Content Extraction

```markdown
## Breaking Down Long Content

### From 10-min Video:
- 0:00-0:30 → Hook clip
- 2:00-3:00 → Tip 1 → Short
- 5:00-6:30 → Tip 2 → Short
- 8:00-9:00 → Tip 3 → Short
- Key quotes → Graphics
- Full transcript → Blog post

### From Blog Post:
- Intro → Tweet
- Each H2 → Separate posts
- Stats → Infographic
- Conclusion → Thread
```

### Step 3: Platform Adaptation

```markdown
## Platform-Specific Adjustments

| Platform | Format | Tone | Length |
|----------|--------|------|--------|
| YouTube | Video | Educational | 8-15 min |
| TikTok | Video | Casual/Fun | 30-60s |
| Twitter | Text | Punchy | 280 char |
| LinkedIn | Text | Professional | 1300 char |
| Instagram | Visual | Aesthetic | Carousel |
| Newsletter | Email | Personal | 500 words |
```

### Step 4: Automation Pipeline

```python
# Content repurposing automation
def repurpose_video(video_path: str):
    # 1. Transcribe
    transcript = transcribe(video_path)
    
    # 2. Extract clips
    clips = detect_key_moments(video_path)
    export_shorts(clips)
    
    # 3. Generate text content
    blog_post = summarize_to_blog(transcript)
    tweets = extract_tweet_thread(transcript)
    
    # 4. Create visuals
    quotes = extract_quotes(transcript)
    generate_quote_graphics(quotes)
```

## Best Practices

- ✅ Plan repurposing before creating
- ✅ Adapt, don't just copy
- ✅ Track which formats perform
- ❌ Don't post identical content
- ❌ Don't ignore platform culture

## Related Skills

- `@short-form-video-creator`
- `@social-media-marketer`

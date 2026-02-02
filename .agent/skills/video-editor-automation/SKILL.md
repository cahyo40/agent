---
name: video-editor-automation
description: "Expert video editing automation including FFmpeg, batch processing, and programmatic video manipulation"
---

# Video Editor Automation

## Overview

This skill transforms you into a **Video Automation Engineer**. You will master **Batch Processing**, **Headless Editing**, **Scripted Pipelines**, and **Template-Based Video Generation** for automating video production at scale.

## When to Use This Skill

- Use when processing hundreds of videos
- Use when automating repetitive edits
- Use when building video assembly pipelines
- Use when creating template-based content
- Use when integrating video into CI/CD

---

## Part 1: Batch Processing with FFmpeg

### 1.1 Process All Videos in Folder

```bash
#!/bin/bash
for file in *.mp4; do
  ffmpeg -i "$file" -c:v libx264 -crf 23 "output/${file%.mp4}_processed.mp4"
done
```

### 1.2 Parallel Processing

```bash
# Using GNU Parallel
find . -name "*.mp4" | parallel -j 4 \
  ffmpeg -i {} -c:v libx264 -crf 23 output/{/.}_processed.mp4
```

### 1.3 Watch Folder Automation

```bash
# Using inotifywait (Linux)
inotifywait -m -e close_write input/ | while read dir action file; do
  ffmpeg -i "input/$file" -c:v libx264 "output/$file"
done
```

---

## Part 2: Python Automation

### 2.1 Batch Processing Script

```python
import os
import subprocess
from pathlib import Path

input_dir = Path("input")
output_dir = Path("output")
output_dir.mkdir(exist_ok=True)

for video in input_dir.glob("*.mp4"):
    output_path = output_dir / f"{video.stem}_processed.mp4"
    
    cmd = [
        "ffmpeg", "-i", str(video),
        "-c:v", "libx264", "-crf", "23",
        "-c:a", "aac",
        str(output_path)
    ]
    
    subprocess.run(cmd, check=True)
    print(f"Processed: {video.name}")
```

### 2.2 Template-Based Video Assembly

```python
from moviepy.editor import *

def create_video_from_template(title, image_path, output_path):
    # Background
    bg = ColorClip(size=(1920, 1080), color=(0, 0, 0), duration=10)
    
    # Image
    img = ImageClip(image_path).set_duration(10).resize(height=800).set_position("center")
    
    # Title text
    txt = TextClip(title, fontsize=70, color='white', font='Arial-Bold')
    txt = txt.set_position(('center', 50)).set_duration(10)
    
    # Composite
    final = CompositeVideoClip([bg, img, txt])
    final.write_videofile(output_path, fps=30)

# Generate videos from data
videos_data = [
    {"title": "Product A", "image": "a.jpg"},
    {"title": "Product B", "image": "b.jpg"},
]

for i, data in enumerate(videos_data):
    create_video_from_template(
        data["title"],
        data["image"],
        f"output/video_{i}.mp4"
    )
```

---

## Part 3: Remotion (React for Video)

### 3.1 What is Remotion?

Programmatically create videos using React components.

### 3.2 Example Component

```tsx
import { Composition, AbsoluteFill } from 'remotion';

export const MyVideo: React.FC<{ title: string }> = ({ title }) => {
  return (
    <AbsoluteFill style={{ backgroundColor: 'black' }}>
      <h1 style={{ color: 'white', fontSize: 100 }}>{title}</h1>
    </AbsoluteFill>
  );
};

// Register
export const RemotionRoot: React.FC = () => (
  <Composition
    id="MyVideo"
    component={MyVideo}
    durationInFrames={300}
    fps={30}
    width={1920}
    height={1080}
    defaultProps={{ title: "Hello World" }}
  />
);
```

### 3.3 Render from Command Line

```bash
npx remotion render src/index.tsx MyVideo output.mp4 --props='{"title":"Dynamic Title"}'
```

See `@remotion-developer` for detailed Remotion patterns.

---

## Part 4: Cloud Video Processing

### 4.1 Services

| Service | Features |
|---------|----------|
| **AWS MediaConvert** | Serverless transcoding |
| **Cloudflare Stream** | Encoding + HLS delivery |
| **Mux** | Video API, analytics |
| **Coconut.co** | FFmpeg in cloud |

### 4.2 Queue-Based Architecture

```
Upload -> S3 Bucket -> Lambda Trigger -> MediaConvert Job -> Output S3
                                                  ↓
                                           Webhook Notification
```

---

## Part 5: Common Automation Patterns

### 5.1 Intro/Outro Appending

```python
import ffmpeg

intro = ffmpeg.input('intro.mp4')
main = ffmpeg.input('main.mp4')
outro = ffmpeg.input('outro.mp4')

(
    ffmpeg
    .concat(intro, main, outro, v=1, a=1)
    .output('final.mp4')
    .run()
)
```

### 5.2 Dynamic Subtitles

```bash
# Burn subtitles from SRT file
ffmpeg -i input.mp4 -vf subtitles=subtitles.srt output.mp4
```

### 5.3 Thumbnail Extraction

```bash
# Extract thumbnail at 10 seconds
ffmpeg -i input.mp4 -ss 00:00:10 -vframes 1 thumbnail.jpg
```

---

## Part 6: Best Practices Checklist

### ✅ Do This

- ✅ **Test Pipeline on Sample First**: Before running on 1000 videos.
- ✅ **Log Everything**: Capture stdout/stderr for debugging.
- ✅ **Use Checksums**: Verify input/output integrity.

### ❌ Avoid This

- ❌ **Sequential Processing When Parallel is Possible**: Use multiprocessing.
- ❌ **Ignoring Errors**: Handle failures gracefully, retry.
- ❌ **Hardcoded Paths**: Use environment variables or config files.

---

## Related Skills

- `@video-processing-specialist` - Deep FFmpeg knowledge
- `@remotion-developer` - React-based video
- `@senior-devops-engineer` - Pipeline automation

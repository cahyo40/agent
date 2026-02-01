---
name: video-editor-automation
description: "Expert video editing automation including FFmpeg, batch processing, and programmatic video manipulation"
---

# Video Editor Automation

## Overview

Automate video editing workflows using FFmpeg, Python, and scripting.

## When to Use This Skill

- Use when batch processing videos
- Use when automating repetitive edits

## How It Works

### Step 1: FFmpeg Basics

```bash
# Convert format
ffmpeg -i input.mp4 output.webm

# Trim video (start 10s, duration 30s)
ffmpeg -i input.mp4 -ss 00:00:10 -t 00:00:30 -c copy output.mp4

# Extract audio
ffmpeg -i input.mp4 -vn -acodec mp3 audio.mp3

# Add watermark
ffmpeg -i input.mp4 -i logo.png -filter_complex "overlay=10:10" output.mp4

# Resize
ffmpeg -i input.mp4 -vf "scale=1920:1080" output.mp4
```

### Step 2: Python Automation

```python
import subprocess
import os
from pathlib import Path

def batch_convert(input_dir: str, output_format: str = 'mp4'):
    input_path = Path(input_dir)
    
    for video in input_path.glob('*.mov'):
        output = video.with_suffix(f'.{output_format}')
        subprocess.run([
            'ffmpeg', '-i', str(video),
            '-c:v', 'libx264', '-crf', '23',
            str(output)
        ])

def add_intro_outro(video: str, intro: str, outro: str):
    # Create file list
    with open('list.txt', 'w') as f:
        f.write(f"file '{intro}'\nfile '{video}'\nfile '{outro}'")
    
    subprocess.run([
        'ffmpeg', '-f', 'concat', '-i', 'list.txt',
        '-c', 'copy', 'final_output.mp4'
    ])

def generate_thumbnail(video: str, time: str = '00:00:05'):
    subprocess.run([
        'ffmpeg', '-i', video, '-ss', time,
        '-vframes', '1', 'thumbnail.jpg'
    ])
```

### Step 3: Auto-Subtitles

```python
import whisper

def generate_subtitles(video_path: str):
    model = whisper.load_model("base")
    result = model.transcribe(video_path)
    
    # Generate SRT
    with open('subtitles.srt', 'w') as f:
        for i, seg in enumerate(result['segments']):
            f.write(f"{i+1}\n")
            f.write(f"{format_time(seg['start'])} --> {format_time(seg['end'])}\n")
            f.write(f"{seg['text'].strip()}\n\n")

# Burn subtitles into video
# ffmpeg -i video.mp4 -vf subtitles=subtitles.srt output.mp4
```

## Best Practices

- ✅ Use CRF for quality control
- ✅ Process in batches overnight
- ❌ Don't re-encode unnecessarily
- ❌ Don't skip quality checks

## Related Skills

- `@remotion-developer`
- `@senior-python-developer`

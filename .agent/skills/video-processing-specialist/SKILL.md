---
name: video-processing-specialist
description: "Expert in digital video processing including transcoding, computer vision integration, real-time effects, and video AI"
---

# Video Processing Specialist

## Overview

This skill transforms you into a **Video Engineering Expert**. You will master **FFmpeg**, **Transcoding**, **Video AI**, and **Processing Pipelines** for building professional video processing systems.

## When to Use This Skill

- Use when transcoding video between formats
- Use when building video processing pipelines
- Use when integrating computer vision
- Use when automating video manipulation
- Use when optimizing video for streaming

---

## Part 1: Video Fundamentals

### 1.1 Key Concepts

| Concept | Description |
|---------|-------------|
| **Codec** | Compression algorithm (H.264, H.265, VP9, AV1) |
| **Container** | File format (.mp4, .mkv, .webm) |
| **Resolution** | Pixel dimensions (1920x1080, 3840x2160) |
| **Frame Rate** | Frames per second (24, 30, 60 fps) |
| **Bitrate** | Data per second (5 Mbps, 50 Mbps) |
| **GOP** | Group of Pictures (keyframe interval) |

### 1.2 Common Codecs

| Codec | Pros | Cons | Use Case |
|-------|------|------|----------|
| **H.264** | Universal support | Less efficient | Web, mobile |
| **H.265 (HEVC)** | 50% smaller than H.264 | CPU-intensive, licensing | 4K, streaming |
| **VP9** | Open, no licensing | Slower encoding | YouTube |
| **AV1** | Most efficient | Very slow encode | Future web |
| **ProRes** | Editing quality | Large files | Professional editing |

---

## Part 2: FFmpeg Essentials

### 2.1 Common Operations

```bash
# Transcode to H.264
ffmpeg -i input.mkv -c:v libx264 -crf 23 -c:a aac output.mp4

# Resize video
ffmpeg -i input.mp4 -vf scale=1280:720 output.mp4

# Trim video
ffmpeg -i input.mp4 -ss 00:00:30 -t 00:01:00 -c copy output.mp4

# Extract frames
ffmpeg -i input.mp4 -vf fps=1 frame_%04d.png

# Create video from images
ffmpeg -framerate 30 -i frame_%04d.png -c:v libx264 output.mp4

# Add watermark
ffmpeg -i input.mp4 -i logo.png -filter_complex "overlay=10:10" output.mp4

# Concatenate videos
ffmpeg -f concat -i filelist.txt -c copy output.mp4
```

### 2.2 Quality Control

| Parameter | Description |
|-----------|-------------|
| **CRF** | Constant Rate Factor (18-28, lower = better) |
| **Two-Pass** | Better quality for target bitrate |
| **Preset** | Speed vs quality trade-off (ultrafast to veryslow) |

```bash
# Two-pass encoding
ffmpeg -i input.mp4 -c:v libx264 -b:v 5M -pass 1 -f null /dev/null
ffmpeg -i input.mp4 -c:v libx264 -b:v 5M -pass 2 output.mp4
```

---

## Part 3: Python Video Processing

### 3.1 Libraries

| Library | Purpose |
|---------|---------|
| **OpenCV** | Computer vision, frame manipulation |
| **moviepy** | Video editing, effects |
| **ffmpeg-python** | FFmpeg wrapper |
| **PyAV** | Low-level FFmpeg bindings |
| **decord** | Fast video reading (ML) |

### 3.2 OpenCV Example

```python
import cv2

cap = cv2.VideoCapture('input.mp4')
fps = cap.get(cv2.CAP_PROP_FPS)
width = int(cap.get(cv2.CAP_PROP_FRAME_WIDTH))
height = int(cap.get(cv2.CAP_PROP_FRAME_HEIGHT))

fourcc = cv2.VideoWriter_fourcc(*'mp4v')
out = cv2.VideoWriter('output.mp4', fourcc, fps, (width, height))

while cap.isOpened():
    ret, frame = cap.read()
    if not ret:
        break
    
    # Process frame (e.g., grayscale)
    processed = cv2.cvtColor(frame, cv2.COLOR_BGR2GRAY)
    processed = cv2.cvtColor(processed, cv2.COLOR_GRAY2BGR)
    
    out.write(processed)

cap.release()
out.release()
```

### 3.3 MoviePy Example

```python
from moviepy.editor import VideoFileClip, TextClip, CompositeVideoClip

clip = VideoFileClip("input.mp4")

# Trim
clip = clip.subclip(10, 60)  # 10s to 60s

# Add text
txt = TextClip("Hello World", fontsize=70, color='white')
txt = txt.set_position('center').set_duration(clip.duration)

final = CompositeVideoClip([clip, txt])
final.write_videofile("output.mp4")
```

---

## Part 4: Video AI

### 4.1 Common Tasks

| Task | Model/Tool |
|------|------------|
| **Object Detection** | YOLOv8, RT-DETR |
| **Face Detection** | RetinaFace, MediaPipe |
| **Pose Estimation** | MediaPipe, YOLO-Pose |
| **Background Removal** | rembg, Segment Anything |
| **Upscaling** | Real-ESRGAN, Topaz |
| **Video Understanding** | GPT-4V, Gemini Pro Vision |

### 4.2 YOLO on Video

```python
from ultralytics import YOLO

model = YOLO('yolov8n.pt')
results = model('input.mp4', stream=True)

for result in results:
    boxes = result.boxes
    result.show()  # Display
    result.save(filename='output_frame.jpg')
```

---

## Part 5: Streaming Formats

### 5.1 HLS (HTTP Live Streaming)

```bash
# Create HLS stream
ffmpeg -i input.mp4 -c:v libx264 -c:a aac \
  -hls_time 4 -hls_list_size 0 output.m3u8
```

### 5.2 DASH (Dynamic Adaptive Streaming)

Better for low-latency live streaming.

### 5.3 Adaptive Bitrate

Encode multiple quality levels, player switches based on bandwidth.

---

## Part 6: Best Practices Checklist

### ✅ Do This

- ✅ **Use Hardware Encoding**: NVIDIA NVENC, Apple VideoToolbox.
- ✅ **Test on Target Devices**: Playback varies.
- ✅ **Preserve Source**: Keep original before processing.

### ❌ Avoid This

- ❌ **Re-encoding Unnecessarily**: Use `-c copy` when possible.
- ❌ **Ignoring Audio Sync**: Check A/V drift.
- ❌ **Ultra-Low Bitrate**: Artifacts hurt more than resolution drop.

---

## Related Skills

- `@audio-processing-specialist` - Audio processing
- `@computer-vision-specialist` - CV models
- `@video-editor-automation` - Batch processing

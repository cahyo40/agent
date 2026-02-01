---
name: video-processing-specialist
description: "Expert in digital video processing including transcoding, computer vision integration, real-time effects, and video AI"
---

# Video Processing Specialist

## Overview

Master digital video manipulation. Expertise in container formats (MP4, MKV), codecs (H.264, HEVC, AV1), FFmpeg automation, real-time shaders (GLSL), and video AI (object tracking, stabilization, deepfakes).

## When to Use This Skill

- Use when building video editing or streaming platforms
- Use when automating video transcoding or thumbnail generation
- Use when implementing real-time video filters
- Use when integrating computer vision into video streams

## How It Works

### Step 1: FFmpeg Automation

```bash
# Basic transcoding to H.264
ffmpeg -i input.mov -c:v libx264 -crf 23 -preset medium -c:a aac -b:a 192k output.mp4

# Creating highlight clips (with filters)
ffmpeg -i in.mp4 -vf "scale=1280:-1,drawtext=text='Highlight':x=10:y=10:fontsize=24:color=white" -ss 00:01:00 -t 30 out.mp4

# Generating HLS stream
ffmpeg -i input.mp4 -codec: copy -start_number 0 -hls_time 10 -hls_list_size 0 -f hls index.m3u8
```

### Step 2: Programmatic Manipulation (OpenCV/Python)

```python
import cv2

cap = cv2.VideoCapture('input.mp4')
fourcc = cv2.VideoWriter_fourcc(*'mp4v')
out = cv2.VideoWriter('output.mp4', fourcc, 30.0, (1280, 720))

while cap.isOpened():
    ret, frame = cap.read()
    if not ret: break
    
    # Process frame
    gray = cv2.cvtColor(frame, cv2.COLOR_BGR2GRAY)
    blurred = cv2.GaussianBlur(gray, (21, 21), 0)
    
    out.write(frame)

cap.release()
out.release()
```

### Step 3: Real-time Filters (GLSL)

```glsl
// Simple Grayscale Shader
precision mediump float;
varying vec2 vTextureCoord;
uniform sampler2D uSampler;

void main() {
    vec4 color = texture2D(uSampler, vTextureCoord);
    float gray = dot(color.rgb, vec3(0.299, 0.587, 0.114));
    gl_FragColor = vec4(vec3(gray), color.a);
}
```

### Step 4: Video AI & Enhancements

- **Upscaling**: Super-resolution models (ESRGAN).
- **Interpolation**: RIFE for frame rate conversion (e.g., 30fps to 60fps).
- **Tracking**: Using SORT or DeepSORT for object tracking across frames.

## Best Practices

### ✅ Do This

- ✅ Use hardware acceleration (NVENC, VAAPI) for speed
- ✅ Choose the right CRF (Constant Rate Factor) for quality vs. size
- ✅ Preserve metadata and timecodes where possible
- ✅ Use multi-threading for batch processing
- ✅ Validate output streams for players compatibility

### ❌ Avoid This

- ❌ Don't re-encode multiple times (generation loss)
- ❌ Don't ignore audio/video sync issues
- ❌ Don't use heavy processing on full resolution for real-time mobile
- ❌ Don't block the UI thread during processing

## Related Skills

- `@video-editor-automation` - Practical automation
- `@computer-vision-specialist` - Frame analysis
- `@senior-cloud-architect` - Streaming infrastructure

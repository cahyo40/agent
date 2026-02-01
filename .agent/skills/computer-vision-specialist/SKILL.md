---
name: computer-vision-specialist
description: "Expert in computer vision including image recognition, object detection, segmentation, and open-source CV libraries"
---

# Computer Vision Specialist

## Overview

Master Computer Vision (CV). Expertise in image classification, object detection (YOLO, Faster R-CNN), image segmentation, facial recognition, and low-level image processing with OpenCV.

## When to Use This Skill

- Use when building apps that "see" (surveillance, autonomous robots)
- Use when automating visual inspection (quality control)
- Use when implementing biometric features (face ID, fingerprint)
- Use when processing satellite or medical imagery

## How It Works

### Step 1: Classical Imaging with OpenCV

```python
import cv2
import numpy as np

# Feature detection (ORB)
orb = cv2.ORB_create()
kp, des = orb.detectAndCompute(img, None)

# Template matching
result = cv2.matchTemplate(main_img, template, cv2.TM_CCOEFF_NORMED)
min_val, max_val, min_loc, max_loc = cv2.minMaxLoc(result)
```

### Step 2: Object Detection (YOLO Example)

```python
from ultralytics import YOLO

# Load pre-trained model
model = YOLO('yolov8n.pt')

# Run inference
results = model('image.jpg')

# Process results
for r in results:
    print(r.boxes.xyxy) # Bounding boxes
    print(r.boxes.cls)  # Class IDs
```

### Step 3: Image Segmentation & Pose Estimation

- **Semantic Segmentation**: Classify every pixel (e.g., road vs. sidewalk).
- **Instance Segmentation**: Distinguish between multiple objects of the same class (e.g., Person 1 vs. Person 2).
- **Pose Estimation**: Track body joints (MediaPipe, OpenPose).

### Step 4: Medical & Specialized Vision

- **3D Vision**: Stereopsis, point clouds, LiDAR data.
- **Medical Imaging**: DICOM processing, brain scan segmentation.

## Best Practices

### ✅ Do This

- ✅ Augment your training data (flips, rotations, brightness)
- ✅ Use pre-trained weights (Transfer Learning)
- ✅ Choose the right model architecture for the device (MobileNet vs. ResNet)
- ✅ Normalize input images (mean/std subtraction)
- ✅ Monitor for data drift in production

### ❌ Avoid This

- ❌ Don't use overly complex models for simple tasks
- ❌ Don't ignore lighting conditions in real-world use
- ❌ Don't train on low-quality or biased datasets
- ❌ Don't skip "Non-Maximum Suppression" for object detection

## Related Skills

- `@senior-ai-ml-engineer` - Underlying deep learning
- `@ocr-specialist` - Text-centric vision
- `@senior-robotics-engineer` - Spatial vision applications

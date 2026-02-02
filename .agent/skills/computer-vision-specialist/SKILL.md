---
name: computer-vision-specialist
description: "Expert in computer vision including image recognition, object detection, segmentation, and open-source CV libraries"
---

# Computer Vision Specialist

## Overview

This skill transforms you into a **Computer Vision Engineer**. You will move beyond simple pixel manipulation to mastering **Object Detection (YOLO)**, **Image Segmentation (Mask R-CNN)**, **Facial Recognition**, and efficient deployment with **OpenCV/ONNX**.

## When to Use This Skill

- Use when detecting objects in images/video (Security, Retail)
- Use when segmenting images (Medical Imaging, Background Removal)
- Use when reading text from images (OCR)
- Use when tracking objects across frames (Surveillance)
- Use when augmenting data for training

---

## Part 1: OpenCV Foundations (Image Processing)

The Swiss Army Knife of CV.

### 1.1 Basic Operations

```python
import cv2
import numpy as np

# Read Image
img = cv2.imread('image.jpg')

# Grayscale (Critical preprocessing step)
gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)

# Gaussian Blur (Noise Reduction)
blur = cv2.GaussianBlur(gray, (5, 5), 0)

# Canny Edge Detection
edges = cv2.Canny(blur, 50, 150)

cv2.imshow('Edges', edges)
cv2.waitKey(0)
```

### 1.2 Accessing Webcam

```python
cap = cv2.VideoCapture(0)

while True:
    ret, frame = cap.read()
    if not ret: break
    
    cv2.imshow('Webcam', frame)
    if cv2.waitKey(1) & 0xFF == ord('q'):
        break

cap.release()
cv2.destroyAllWindows()
```

---

## Part 2: Object Detection (YOLOv8)

State of the Art (SOTA) real-time detection.

**Install:** `pip install ultralytics`

### 2.1 Inference

```python
from ultralytics import YOLO

# Load model (trained on COCO dataset)
model = YOLO('yolov8n.pt')  # Nano model (Fastest)

# Predict
results = model('bus.jpg', save=True, conf=0.5)

for r in results:
    boxes = r.boxes
    for box in boxes:
        print(f"Class: {model.names[int(box.cls)]}, Conf: {box.conf}")
```

### 2.2 Custom Training

1. Label Data (Roboflow / LabelImg). Format: YOLO TXT.
2. Train:

```python
model = YOLO('yolov8n.pt')
results = model.train(data='data.yaml', epochs=100, imgsz=640)
```

---

## Part 3: Image Segmentation

Not just "Where is the car?", but "Which pixels are the car?".

- **Semantic Segmentation**: "These pixels are grass, these are road."
- **Instance Segmentation**: "Car A pixels, Car B pixels."

### 3.1 Mask R-CNN (via Detectron2 or YOLO)

```python
# YOLOv8 supports segmentation too!
model = YOLO('yolov8n-seg.pt')
results = model('image.jpg')

# Get Masks
masks = results[0].masks
```

---

## Part 4: Video Analytics (Object Tracking)

Detection happens per frame. Tracking connects them.

**DeepSORT / ByteTrack**

```python
# YOLOv8 has built-in tracking (BoT-SORT / ByteTrack)
results = model.track(source="video.mp4", persist=True)

# Tracks have ID
for r in results:
    for box in r.boxes:
        print(f"ID: {box.id}, Class: {box.cls}")
```

---

## Part 5: Deployment (Edge AI)

Running CV on Raspberry Pi or NVIDIA Jetson.

### 5.1 Optimization

1. **Export to ONNX/TensorRT**:
    `model.export(format='onnx')`
2. **FP16 Quantization**: Reduces size 50%, slight speedup.
3. **INT8 Quantization**: Requires calibration, massive speedup on Tensor Cores.

### 5.2 DeepStream (NVIDIA)

For production pipelines (multiple cameras). Uses GStreamer + TensorRT.

---

## Part 6: Best Practices Checklist

### ✅ Do This

- ✅ **Augment Data**: Use Albumentations (Rotate, Flip, Brightness) to make models robust.
- ✅ **Normalize Inputs**: Divide pixels by 255.0 to get 0-1 range. Neural Nets love this.
- ✅ **Use Pre-trained Backbones**: ResNet/EfficientNet. Don't invent your own CNN architecture.

### ❌ Avoid This

- ❌ **Training on CPU**: Use Google Colab (Free GPU) or Kaggle Kernels if you don't have an NVIDIA GPU.
- ❌ **Overfitting**: If Training Loss < Validation Loss, you are memorizing. Add Dropout or more data.
- ❌ **Blocking Inference**: Don't run inference on the UI thread of a mobile app.

---

## Related Skills

- `@senior-python-developer` - CV implementation language
- `@senior-ai-ml-engineer` - Deep Learning theory (CNNs)
- `@senior-edge-ai-engineer` - Deploying to IoT devices

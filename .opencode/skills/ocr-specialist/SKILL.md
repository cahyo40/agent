---
name: ocr-specialist
description: "Expert in Optical Character Recognition (OCR) including preprocessing, Tesseract, cloud OCR APIs, and document understanding"
---

# OCR Specialist

## Overview

Master Optical Character Recognition (OCR). Expertise in image preprocessing for better accuracy, Tesseract configuration, layout analysis, and integration of high-performance cloud OCR (Google Vision, AWS Textract, Azure Form Recognizer).

## When to Use This Skill

- Use when digitizing physical documents (ID cards, invoices, receipts)
- Use when extracting text from images or PDFs
- Use when automating data entry from scanned forms
- Use when implementing search and indexing for image datasets

## How It Works

### Step 1: Image Preprocessing (Critical for Accuracy)

```python
import cv2
import numpy as np

def preprocess_for_ocr(image_path):
    img = cv2.imread(image_path)
    # Grayscale
    gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
    # Thresholding (Binarization)
    thresh = cv2.threshold(gray, 0, 255, cv2.THRESH_BINARY + cv2.THRESH_OTSU)[1]
    # Denoising
    denoised = cv2.medianBlur(thresh, 3)
    # Deskewing (Rotating to align text)
    # ... logic here ...
    return denoised
```

### Step 2: Tesseract OCR (Open Source)

```python
import pytesseract
from PIL import Image

# Configuration for specific document types
custom_config = r'--oem 3 --psm 6' # PSM 6: Uniform block of text
text = pytesseract.image_to_string(Image.open('preprocessed.png'), config=custom_config)

# Getting bounding boxes
data = pytesseract.image_to_data(Image.open('img.png'), output_type=pytesseract.Output.DICT)
```

### Step 3: Layout Analysis & Document Understanding

- **HOCR/ALTO**: Formats for storing text and geometry.
- **LayoutParser**: Deep learning-based layout detection.
- **Rules-based extraction**: Regex for finding dates, amounts, etc., after OCR.

### Step 4: Cloud OCR & Handwriting

- **Google Document AI / Vision API**: Best for handwritten and complex forms.
- **AWS Textract**: Excellent for key-value pair extraction from tables.
- **TrOCR**: Transformer-based localized OCR models.

## Best Practices

### ✅ Do This

- ✅ Always normalize image resolution (300 DPI is standard)
- ✅ Use grayscale/binarization to reduce noise
- ✅ Handle rotation (deskew) before recognition
- ✅ Use layout analysis to keep text in reading order
- ✅ Implement fuzzy matching for post-processing cleanup

### ❌ Avoid This

- ❌ Don't skip preprocessing (raw photos perform poorly)
- ❌ Don't rely on OCR for high-stakes data without human-in-the-loop
- ❌ Don't ignore text orientation
- ❌ Don't use heavy models on mobile for real-time needs

## Related Skills

- `@computer-vision-specialist` - Underlying image tech
- `@senior-python-developer` - Automation scripts
- `@document-generator` - Recreating docs from text

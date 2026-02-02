---
name: ocr-specialist
description: "Expert in Optical Character Recognition (OCR) including preprocessing, Tesseract, cloud OCR APIs, and document understanding"
---

# OCR Specialist

## Overview

This skill transforms you into a **Document Processing Expert**. You will master **Image Preprocessing**, **Tesseract OCR**, **Cloud OCR APIs**, and **Document AI** for extracting text from images and documents.

## When to Use This Skill

- Use when extracting text from images
- Use when processing scanned documents
- Use when building document automation systems
- Use when implementing receipt/invoice parsing
- Use when handling handwritten text recognition

---

## Part 1: OCR Fundamentals

### 1.1 How OCR Works

```
Image → Preprocessing → Text Detection → Character Recognition → Post-processing → Text
```

### 1.2 OCR Types

| Type | Description | Use Case |
|------|-------------|----------|
| **Printed Text** | Machine-generated text | Documents, books |
| **Handwritten** | Handwriting recognition | Forms, notes |
| **Scene Text** | Text in photos | Street signs, products |
| **Document AI** | Structured extraction | Invoices, receipts |

---

## Part 2: Image Preprocessing

### 2.1 Why Preprocessing?

OCR accuracy depends heavily on image quality.

### 2.2 Common Techniques

| Technique | Purpose | OpenCV Code |
|-----------|---------|-------------|
| **Grayscale** | Remove color noise | `cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)` |
| **Thresholding** | Binarize image | `cv2.threshold(img, 0, 255, cv2.THRESH_BINARY + cv2.THRESH_OTSU)` |
| **Deskew** | Fix rotation | Custom rotation matrix |
| **Denoise** | Remove speckles | `cv2.fastNlMeansDenoising(img)` |
| **Resize** | Ensure min DPI | `cv2.resize(img, None, fx=2, fy=2)` |

### 2.3 Preprocessing Pipeline

```python
import cv2

def preprocess_for_ocr(image_path):
    img = cv2.imread(image_path)
    
    # Grayscale
    gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
    
    # Denoise
    denoised = cv2.fastNlMeansDenoising(gray)
    
    # Threshold
    _, binary = cv2.threshold(denoised, 0, 255, cv2.THRESH_BINARY + cv2.THRESH_OTSU)
    
    return binary
```

---

## Part 3: Tesseract OCR

### 3.1 Installation

```bash
# Ubuntu
sudo apt install tesseract-ocr

# macOS
brew install tesseract
```

### 3.2 Python Usage (pytesseract)

```python
import pytesseract
from PIL import Image

# Basic OCR
text = pytesseract.image_to_string(Image.open('image.png'))

# With language
text = pytesseract.image_to_string(Image.open('image.png'), lang='eng+ind')

# Get bounding boxes
data = pytesseract.image_to_data(Image.open('image.png'), output_type=pytesseract.Output.DICT)
```

### 3.3 Page Segmentation Modes (PSM)

| PSM | Mode |
|-----|------|
| 3 | Fully automatic (default) |
| 6 | Uniform block of text |
| 7 | Single line |
| 8 | Single word |
| 11 | Sparse text |

```python
text = pytesseract.image_to_string(image, config='--psm 6')
```

---

## Part 4: Cloud OCR APIs

### 4.1 Comparison

| Service | Strengths |
|---------|-----------|
| **Google Cloud Vision** | Multi-language, handwriting |
| **AWS Textract** | Document understanding, forms |
| **Azure Computer Vision** | Handwriting, multi-language |
| **Google Document AI** | Structured extraction |

### 4.2 Google Cloud Vision Example

```python
from google.cloud import vision

client = vision.ImageAnnotatorClient()

with open('image.png', 'rb') as f:
    content = f.read()

image = vision.Image(content=content)
response = client.text_detection(image=image)
text = response.text_annotations[0].description
```

### 4.3 AWS Textract Example

```python
import boto3

client = boto3.client('textract')

with open('document.png', 'rb') as f:
    response = client.detect_document_text(Document={'Bytes': f.read()})

for block in response['Blocks']:
    if block['BlockType'] == 'LINE':
        print(block['Text'])
```

---

## Part 5: Document AI

### 5.1 Structured Extraction

Extract specific fields from documents (invoices, receipts).

| Field | Example |
|-------|---------|
| **Vendor Name** | "Amazon" |
| **Total** | "$125.99" |
| **Date** | "2024-01-15" |
| **Line Items** | Product, Qty, Price |

### 5.2 Google Document AI

Pre-trained processors:

- Invoice Parser
- Receipt Parser
- Form Parser
- ID Document Parser

### 5.3 Custom Models

Train on your document types using:

- Google Document AI Custom
- AWS Textract Analyze Expense
- Azure Form Recognizer Custom

---

## Part 6: Best Practices Checklist

### ✅ Do This

- ✅ **Preprocess Images**: Grayscale, threshold, deskew.
- ✅ **Use High DPI**: Minimum 300 DPI for OCR.
- ✅ **Post-Process Results**: Spell check, regex validation.

### ❌ Avoid This

- ❌ **Raw Image OCR**: Without preprocessing.
- ❌ **Single Language Model**: Specify languages if known.
- ❌ **Ignoring Confidence Scores**: Low confidence = review needed.

---

## Related Skills

- `@computer-vision-specialist` - Image processing
- `@pdf-document-specialist` - PDF handling
- `@nlp-specialist` - Text processing

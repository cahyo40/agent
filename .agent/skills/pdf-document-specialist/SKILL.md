---
name: pdf-document-specialist
description: "Expert PDF document development including generation, manipulation, form filling, digital signatures, and document parsing"
---

# PDF Document Specialist

## Overview

Skill ini menjadikan AI Agent sebagai spesialis pengembangan PDF. Agent akan mampu membangun PDF generation, manipulation, form filling, digital signatures, OCR extraction, dan document parsing.

## When to Use This Skill

- Use when generating PDF reports/invoices
- Use when filling PDF forms programmatically
- Use when extracting data from PDFs
- Use when implementing digital signatures

## Core Concepts

### PDF Libraries by Language

```text
PDF LIBRARIES:
──────────────

JAVASCRIPT/NODE.JS:
├── pdf-lib (generation, manipulation)
├── pdfkit (generation)
├── puppeteer (HTML to PDF)
├── pdf-parse (text extraction)
└── pdf.js (viewing, Mozilla)

PYTHON:
├── ReportLab (generation)
├── PyPDF2 (manipulation)
├── pdfplumber (extraction)
├── WeasyPrint (HTML to PDF)
└── PyMuPDF/fitz (fast, feature-rich)

JAVA:
├── iText (commercial, powerful)
├── Apache PDFBox (open source)
└── OpenPDF (iText fork, free)

PHP:
├── TCPDF (generation)
├── FPDF (lightweight)
├── Dompdf (HTML to PDF)
└── mPDF (HTML to PDF)

.NET:
├── iTextSharp
├── PdfSharp
└── QuestPDF
```

### PDF Generation

```text
GENERATION APPROACHES:
──────────────────────

1. PROGRAMMATIC (Low-level)
   - Build PDF element by element
   - Full control, more code
   
2. HTML TO PDF
   - Design in HTML/CSS
   - Convert using headless browser
   - Easier styling
   
3. TEMPLATE-BASED
   - Pre-designed PDF template
   - Fill placeholders with data

HTML TO PDF FLOW:
┌─────────────┐   ┌─────────────┐   ┌─────────────┐
│  HTML/CSS   │──►│  Headless   │──►│    PDF      │
│  Template   │   │  Browser    │   │   Output    │
└─────────────┘   └─────────────┘   └─────────────┘

TOOLS:
├── Puppeteer/Playwright (Chrome)
├── WeasyPrint (Python)
├── wkhtmltopdf (CLI)
└── Prince (commercial, best quality)
```

### Document Structure

```text
PDF STRUCTURE:
──────────────

┌─────────────────────────────────────────┐
│ HEADER                                  │
│ %PDF-1.7                                │
├─────────────────────────────────────────┤
│ BODY                                    │
│ ├── Catalog (root)                      │
│ ├── Pages                               │
│ │   ├── Page 1                          │
│ │   │   ├── Content Stream              │
│ │   │   ├── Resources (fonts, images)   │
│ │   │   └── Annotations                 │
│ │   └── Page 2...                       │
│ ├── Fonts                               │
│ ├── Images                              │
│ └── Metadata                            │
├─────────────────────────────────────────┤
│ XREF TABLE (object locations)           │
├─────────────────────────────────────────┤
│ TRAILER                                 │
│ - Root reference                        │
│ - Size (object count)                   │
└─────────────────────────────────────────┘

PAGE COORDINATES:
┌─────────────────────────────────────────┐
│ (0, 842) ──────────────── (595, 842)    │
│ │                                │      │
│ │          A4 PAGE               │      │
│ │        595 x 842 pt            │      │
│ │                                │      │
│ (0, 0) ────────────────── (595, 0)      │
└─────────────────────────────────────────┘
Origin = bottom-left (unlike HTML)
1 point = 1/72 inch
```

### Common Operations

```text
PDF OPERATIONS:
───────────────

CREATION:
├── Add text (fonts, sizes, colors)
├── Draw shapes (lines, rectangles, circles)
├── Insert images (JPEG, PNG, SVG)
├── Create tables
├── Add headers/footers
└── Page numbering

MANIPULATION:
├── Merge multiple PDFs
├── Split PDF into pages
├── Rotate pages
├── Reorder pages
├── Add/remove pages
├── Add watermarks
└── Compress file size

FORM OPERATIONS:
├── Create form fields
│   ├── Text fields
│   ├── Checkboxes
│   ├── Radio buttons
│   ├── Dropdowns
│   └── Signature fields
├── Fill existing forms
├── Flatten forms (make read-only)
└── Extract form data

EXTRACTION:
├── Extract text content
├── Extract images
├── Extract metadata
├── Extract form field values
└── Extract table data
```

### Invoice/Report Example

```text
INVOICE LAYOUT:
───────────────

┌─────────────────────────────────────────┐
│ ┌──────┐         INVOICE #INV-2024-001  │
│ │ LOGO │         Date: Feb 2, 2026      │
│ └──────┘         Due: Feb 16, 2026      │
├─────────────────────────────────────────┤
│ FROM:               TO:                 │
│ PT. Example         John Doe            │
│ Jl. Sudirman 123    Jl. Gatot Subroto   │
│ Jakarta             Jakarta             │
├─────────────────────────────────────────┤
│ Item          Qty   Price      Total    │
│ ─────────────────────────────────────── │
│ Product A     2     100,000    200,000  │
│ Product B     1     150,000    150,000  │
│ Service C     3     50,000     150,000  │
├─────────────────────────────────────────┤
│                     Subtotal   500,000  │
│                     Tax (11%)   55,000  │
│                     ─────────────────── │
│                     TOTAL      555,000  │
├─────────────────────────────────────────┤
│ Payment:                                │
│ Bank BCA - 1234567890                   │
│ a/n PT. Example                         │
├─────────────────────────────────────────┤
│ Terms & Conditions...                   │
│                                         │
│ ─────────────────                       │
│ Authorized Signature                    │
└─────────────────────────────────────────┘
```

### Digital Signatures

```text
PDF DIGITAL SIGNATURES:
───────────────────────

TYPES:
├── VISUAL SIGNATURE
│   └── Image of signature (not secure)
│
├── DIGITAL SIGNATURE (PKI)
│   ├── Uses certificate (X.509)
│   ├── Cryptographically secure
│   └── Legally binding
│
└── CERTIFIED SIGNATURE
    ├── Author signature
    └── Prevents modifications

SIGNING FLOW:
┌─────────────┐   ┌─────────────┐   ┌─────────────┐
│  Original   │──►│   Hash      │──►│  Encrypt    │
│    PDF      │   │  Document   │   │  with Key   │
└─────────────┘   └─────────────┘   └─────────────┘
                                           │
                                           ▼
                                    ┌─────────────┐
                                    │  Embed in   │
                                    │    PDF      │
                                    └─────────────┘

VERIFICATION:
1. Extract signature
2. Decrypt with public key
3. Hash document
4. Compare hashes
5. Check certificate validity
```

### Text Extraction

```text
TEXT EXTRACTION CHALLENGES:
───────────────────────────

PDF TEXT IS NOT ALWAYS SIMPLE:
├── Text may be images (need OCR)
├── Columns may extract wrong order
├── Tables lose structure
├── Fonts may be embedded/subset
└── Encoding issues

EXTRACTION STRATEGIES:
┌─────────────────────────────────────────┐
│ 1. SIMPLE TEXT                          │
│    Direct extraction, works for basic   │
├─────────────────────────────────────────┤
│ 2. LAYOUT-AWARE                         │
│    Preserve positions, columns          │
├─────────────────────────────────────────┤
│ 3. TABLE EXTRACTION                     │
│    Detect table structure               │
├─────────────────────────────────────────┤
│ 4. OCR (Images/Scanned)                 │
│    Tesseract, Google Vision, AWS        │
└─────────────────────────────────────────┘

OCR TOOLS:
├── Tesseract (open source)
├── Google Cloud Vision
├── AWS Textract
└── Azure Form Recognizer
```

## Best Practices

### ✅ Do This

- ✅ Embed fonts for consistent rendering
- ✅ Compress images before embedding
- ✅ Use vector graphics when possible
- ✅ Add document metadata (title, author)
- ✅ Test PDF/A for archival compliance

### ❌ Avoid This

- ❌ Don't embed huge uncompressed images
- ❌ Don't rely on system fonts
- ❌ Don't generate PDFs on client-side for sensitive data
- ❌ Don't forget accessibility (tagged PDF)

## Related Skills

- `@document-generator` - General document generation
- `@ocr-specialist` - Text extraction from images
- `@senior-backend-developer` - Server-side generation
- `@accessibility-specialist` - Accessible PDFs

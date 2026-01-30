---
name: document-generator
description: "Expert document generation including PDF, DOCX, XLSX, and PPTX creation with Python and JavaScript"
---

# Document Generator

## Overview

This skill helps you programmatically generate documents in PDF, Word, Excel, and PowerPoint formats.

## When to Use This Skill

- Use when generating reports
- Use when creating invoices/documents
- Use when automating document workflows

## How It Works

### Step 1: PDF Generation

```python
# Python - Using ReportLab
from reportlab.lib import colors
from reportlab.lib.pagesizes import letter, A4
from reportlab.lib.styles import getSampleStyleSheet, ParagraphStyle
from reportlab.platypus import SimpleDocTemplate, Paragraph, Spacer, Table, TableStyle, Image
from reportlab.lib.units import inch

def generate_invoice_pdf(data: dict, output_path: str):
    doc = SimpleDocTemplate(output_path, pagesize=A4)
    styles = getSampleStyleSheet()
    elements = []
    
    # Header
    elements.append(Paragraph("INVOICE", styles['Title']))
    elements.append(Spacer(1, 20))
    
    # Company Info
    elements.append(Paragraph(f"<b>{data['company_name']}</b>", styles['Normal']))
    elements.append(Paragraph(data['company_address'], styles['Normal']))
    elements.append(Spacer(1, 20))
    
    # Invoice Details
    invoice_info = [
        ['Invoice #:', data['invoice_number']],
        ['Date:', data['date']],
        ['Due Date:', data['due_date']],
    ]
    info_table = Table(invoice_info, colWidths=[100, 200])
    elements.append(info_table)
    elements.append(Spacer(1, 20))
    
    # Line Items
    table_data = [['Description', 'Qty', 'Unit Price', 'Total']]
    for item in data['items']:
        table_data.append([
            item['description'],
            str(item['quantity']),
            f"${item['unit_price']:.2f}",
            f"${item['quantity'] * item['unit_price']:.2f}"
        ])
    
    # Total row
    table_data.append(['', '', 'Total:', f"${data['total']:.2f}"])
    
    items_table = Table(table_data, colWidths=[250, 50, 80, 80])
    items_table.setStyle(TableStyle([
        ('BACKGROUND', (0, 0), (-1, 0), colors.grey),
        ('TEXTCOLOR', (0, 0), (-1, 0), colors.whitesmoke),
        ('ALIGN', (1, 0), (-1, -1), 'CENTER'),
        ('GRID', (0, 0), (-1, -1), 1, colors.black),
        ('FONTNAME', (0, 0), (-1, 0), 'Helvetica-Bold'),
    ]))
    elements.append(items_table)
    
    doc.build(elements)
    return output_path

# Usage
invoice_data = {
    'company_name': 'Acme Inc',
    'company_address': '123 Main St, City',
    'invoice_number': 'INV-001',
    'date': '2024-01-15',
    'due_date': '2024-02-15',
    'items': [
        {'description': 'Web Development', 'quantity': 40, 'unit_price': 100},
        {'description': 'Design', 'quantity': 10, 'unit_price': 80},
    ],
    'total': 4800,
}
generate_invoice_pdf(invoice_data, 'invoice.pdf')
```

### Step 2: Word Document (DOCX)

```python
# Python - Using python-docx
from docx import Document
from docx.shared import Inches, Pt
from docx.enum.text import WD_ALIGN_PARAGRAPH

def generate_report_docx(data: dict, output_path: str):
    doc = Document()
    
    # Title
    title = doc.add_heading(data['title'], 0)
    title.alignment = WD_ALIGN_PARAGRAPH.CENTER
    
    # Metadata
    doc.add_paragraph(f"Author: {data['author']}")
    doc.add_paragraph(f"Date: {data['date']}")
    
    # Executive Summary
    doc.add_heading('Executive Summary', level=1)
    doc.add_paragraph(data['summary'])
    
    # Sections
    for section in data['sections']:
        doc.add_heading(section['title'], level=2)
        doc.add_paragraph(section['content'])
        
        # Add table if present
        if 'table' in section:
            table = doc.add_table(rows=1, cols=len(section['table']['headers']))
            table.style = 'Table Grid'
            
            # Headers
            hdr_cells = table.rows[0].cells
            for i, header in enumerate(section['table']['headers']):
                hdr_cells[i].text = header
            
            # Rows
            for row_data in section['table']['rows']:
                row = table.add_row().cells
                for i, cell in enumerate(row_data):
                    row[i].text = str(cell)
    
    doc.save(output_path)
    return output_path

# Usage
report_data = {
    'title': 'Q4 2024 Report',
    'author': 'John Doe',
    'date': '2024-01-15',
    'summary': 'This report covers...',
    'sections': [
        {
            'title': 'Revenue',
            'content': 'Revenue increased by 25%...',
            'table': {
                'headers': ['Month', 'Revenue', 'Growth'],
                'rows': [
                    ['October', '$100K', '10%'],
                    ['November', '$120K', '20%'],
                ],
            },
        },
    ],
}
generate_report_docx(report_data, 'report.docx')
```

### Step 3: Excel Spreadsheet (XLSX)

```python
# Python - Using openpyxl
from openpyxl import Workbook
from openpyxl.styles import Font, Alignment, PatternFill, Border, Side
from openpyxl.chart import BarChart, Reference

def generate_excel_report(data: dict, output_path: str):
    wb = Workbook()
    ws = wb.active
    ws.title = "Sales Report"
    
    # Styles
    header_font = Font(bold=True, color="FFFFFF")
    header_fill = PatternFill(start_color="4472C4", end_color="4472C4", fill_type="solid")
    border = Border(
        left=Side(style='thin'),
        right=Side(style='thin'),
        top=Side(style='thin'),
        bottom=Side(style='thin')
    )
    
    # Title
    ws['A1'] = data['title']
    ws['A1'].font = Font(bold=True, size=16)
    ws.merge_cells('A1:D1')
    
    # Headers
    headers = ['Product', 'Q1', 'Q2', 'Q3', 'Q4', 'Total']
    for col, header in enumerate(headers, 1):
        cell = ws.cell(row=3, column=col, value=header)
        cell.font = header_font
        cell.fill = header_fill
        cell.border = border
        cell.alignment = Alignment(horizontal='center')
    
    # Data
    for row_idx, row_data in enumerate(data['rows'], 4):
        for col_idx, value in enumerate(row_data, 1):
            cell = ws.cell(row=row_idx, column=col_idx, value=value)
            cell.border = border
            if col_idx > 1:
                cell.number_format = '$#,##0'
    
    # Formulas for total column
    for row in range(4, 4 + len(data['rows'])):
        ws.cell(row=row, column=6, value=f"=SUM(B{row}:E{row})")
    
    # Chart
    chart = BarChart()
    chart.title = "Quarterly Sales"
    chart.type = "col"
    
    chart_data = Reference(ws, min_col=2, min_row=3, max_col=5, max_row=3+len(data['rows']))
    categories = Reference(ws, min_col=1, min_row=4, max_row=3+len(data['rows']))
    chart.add_data(chart_data, titles_from_data=True)
    chart.set_categories(categories)
    
    ws.add_chart(chart, "H3")
    
    # Adjust column widths
    ws.column_dimensions['A'].width = 20
    for col in ['B', 'C', 'D', 'E', 'F']:
        ws.column_dimensions[col].width = 12
    
    wb.save(output_path)
    return output_path
```

### Step 4: PowerPoint (PPTX)

```python
# Python - Using python-pptx
from pptx import Presentation
from pptx.util import Inches, Pt
from pptx.enum.text import PP_ALIGN
from pptx.dml.color import RgbColor

def generate_presentation(data: dict, output_path: str):
    prs = Presentation()
    prs.slide_width = Inches(13.333)
    prs.slide_height = Inches(7.5)
    
    # Title Slide
    title_layout = prs.slide_layouts[0]
    slide = prs.slides.add_slide(title_layout)
    slide.shapes.title.text = data['title']
    slide.placeholders[1].text = data['subtitle']
    
    # Content Slides
    for slide_data in data['slides']:
        if slide_data['type'] == 'bullet':
            layout = prs.slide_layouts[1]  # Title and Content
            slide = prs.slides.add_slide(layout)
            slide.shapes.title.text = slide_data['title']
            
            body = slide.shapes.placeholders[1]
            tf = body.text_frame
            
            for i, point in enumerate(slide_data['points']):
                if i == 0:
                    tf.text = point
                else:
                    p = tf.add_paragraph()
                    p.text = point
                    p.level = 0
        
        elif slide_data['type'] == 'two_column':
            layout = prs.slide_layouts[3]  # Two Content
            slide = prs.slides.add_slide(layout)
            slide.shapes.title.text = slide_data['title']
            
            # Left column
            left = slide.shapes.placeholders[1]
            left.text_frame.text = slide_data['left_content']
            
            # Right column
            right = slide.shapes.placeholders[2]
            right.text_frame.text = slide_data['right_content']
    
    prs.save(output_path)
    return output_path

# Usage
presentation_data = {
    'title': 'Q4 2024 Results',
    'subtitle': 'Company Performance Review',
    'slides': [
        {
            'type': 'bullet',
            'title': 'Key Highlights',
            'points': [
                'Revenue grew 25% YoY',
                'Customer base expanded to 10,000',
                'Launched 3 new products',
            ],
        },
        {
            'type': 'two_column',
            'title': 'Comparison',
            'left_content': 'Before:\n- Manual processes\n- Slow delivery',
            'right_content': 'After:\n- Automation\n- 10x faster',
        },
    ],
}
generate_presentation(presentation_data, 'presentation.pptx')
```

## Best Practices

### ✅ Do This

- ✅ Use templates when possible
- ✅ Handle fonts and encoding properly
- ✅ Validate data before generation
- ✅ Add proper error handling

### ❌ Avoid This

- ❌ Don't hardcode paths
- ❌ Don't skip memory cleanup
- ❌ Don't ignore file size limits

## Related Skills

- `@senior-python-developer` - Python patterns
- `@senior-technical-writer` - Content structure

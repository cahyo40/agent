---
name: spreadsheet-expert
description: "Expert spreadsheet skills including Excel, Google Sheets, formulas, macros, and data analysis"
---

# Spreadsheet Expert

## Overview

Master Excel and Google Sheets for data analysis, automation, and reporting.

## When to Use This Skill

- Use when building complex spreadsheets
- Use when automating reports

## How It Works

### Step 1: Essential Formulas

```markdown
## Lookup & Reference

### VLOOKUP (Find in table)
=VLOOKUP(lookup_value, table_range, col_index, FALSE)
=VLOOKUP(A2, Products!A:C, 3, FALSE)

### INDEX MATCH (More flexible)
=INDEX(return_range, MATCH(lookup_value, lookup_range, 0))
=INDEX(C:C, MATCH(A2, A:A, 0))

### XLOOKUP (Modern, Excel 365)
=XLOOKUP(lookup_value, lookup_array, return_array)
=XLOOKUP(A2, Products!A:A, Products!C:C)

## Conditional

### SUMIF/SUMIFS
=SUMIF(range, criteria, sum_range)
=SUMIFS(sum_range, criteria_range1, criteria1, criteria_range2, criteria2)
=SUMIFS(D:D, A:A, "Jakarta", B:B, ">100")

### COUNTIF/COUNTIFS
=COUNTIF(range, criteria)
=COUNTIFS(A:A, "Pending", B:B, ">1000")

### AVERAGEIF
=AVERAGEIF(criteria_range, criteria, average_range)
```

### Step 2: Data Transformation

```markdown
## Text Functions

### Split & Combine
=CONCAT(A1, " ", B1)
=TEXTJOIN(", ", TRUE, A1:A10)
=LEFT(A1, 5)
=RIGHT(A1, 3)
=MID(A1, 2, 4)

### Clean Data
=TRIM(A1)           -- Remove extra spaces
=CLEAN(A1)          -- Remove non-printable
=PROPER(A1)         -- Title Case
=UPPER(A1)          -- UPPERCASE
=SUBSTITUTE(A1, "old", "new")

## Date Functions
=TODAY()
=NOW()
=YEAR(A1), =MONTH(A1), =DAY(A1)
=EOMONTH(A1, 0)     -- End of month
=NETWORKDAYS(start, end)  -- Working days
=TEXT(A1, "DD-MMM-YYYY")
```

### Step 3: Pivot Tables

```markdown
## Pivot Table Setup

### Data Requirements
- Headers in first row
- No blank rows/columns
- Consistent data types

### Common Configurations

| Report Type | Rows | Columns | Values |
|-------------|------|---------|--------|
| Sales by Region | Region | Product | SUM(Sales) |
| Monthly Trend | Month | - | SUM(Revenue) |
| Customer Analysis | Customer | Category | COUNT(Orders) |

### Calculated Fields
Right-click → Add Calculated Field
"Profit Margin" = Sales - Cost
"Avg Order" = Sales / Count
```

### Step 4: Google Sheets Apps Script

```javascript
// Custom function
function GREET(name) {
  return "Hello, " + name + "!";
}

// Auto-email report
function sendDailyReport() {
  const sheet = SpreadsheetApp.getActiveSheet();
  const data = sheet.getRange("A1:D10").getValues();
  
  const htmlTable = buildHtmlTable(data);
  
  MailApp.sendEmail({
    to: "report@company.com",
    subject: "Daily Report - " + new Date().toDateString(),
    htmlBody: htmlTable
  });
}

// Trigger on form submit
function onFormSubmit(e) {
  const responses = e.values;
  const sheet = SpreadsheetApp.getActiveSpreadsheet();
  
  // Process new submission
  processSubmission(responses);
  
  // Send notification
  sendNotification(responses);
}

// Set up daily trigger
function createTrigger() {
  ScriptApp.newTrigger('sendDailyReport')
    .timeBased()
    .everyDays(1)
    .atHour(9)
    .create();
}
```

### Step 5: Excel VBA Macros

```vba
' Format report automatically
Sub FormatReport()
    Dim ws As Worksheet
    Set ws = ActiveSheet
    
    ' Header formatting
    With ws.Range("A1:E1")
        .Font.Bold = True
        .Interior.Color = RGB(0, 112, 192)
        .Font.Color = RGB(255, 255, 255)
    End With
    
    ' Auto-fit columns
    ws.Columns("A:E").AutoFit
    
    ' Add borders
    ws.UsedRange.Borders.LineStyle = xlContinuous
End Sub

' Loop through data
Sub ProcessData()
    Dim lastRow As Long
    lastRow = Cells(Rows.Count, 1).End(xlUp).Row
    
    For i = 2 To lastRow
        If Cells(i, 3).Value > 1000 Then
            Cells(i, 4).Value = "High Value"
        Else
            Cells(i, 4).Value = "Normal"
        End If
    Next i
End Sub
```

## Best Practices

- ✅ Use named ranges
- ✅ Document formulas
- ✅ Separate data from calculations
- ❌ Don't hardcode values
- ❌ Don't skip data validation

## Related Skills

- `@senior-data-analyst`
- `@workflow-automation-builder`

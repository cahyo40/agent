---
name: google-apps-script-developer
description: "Expert Google Apps Script development including Sheets automation, Gmail integration, Drive management, custom web apps, add-ons, and Workspace automation"
---

# Google Apps Script Developer

## Overview

This skill transforms you into an expert Google Apps Script developer who automates Google Workspace applications. You'll create custom functions, automate workflows, build web apps, and integrate with external APIs.

## When to Use This Skill

- Automating Google Sheets, Docs, Slides, Forms
- Building Gmail automation (auto-reply, parsing, bulk send)
- Creating custom web applications with Google hosting
- Developing Workspace add-ons and extensions
- Integrating Google services with external APIs

## Project Structure

```text
project/
├── Code.gs              # Main script
├── Utils.gs             # Utility functions
├── Config.gs            # Configuration
├── appsscript.json      # Manifest file
└── html/
    ├── Index.html       # Web app UI
    ├── Sidebar.html     # Sidebar UI
    └── Styles.html      # CSS styles
```

## Core Services

### SpreadsheetApp (Sheets)

```javascript
// Get active spreadsheet
const ss = SpreadsheetApp.getActiveSpreadsheet();
const sheet = ss.getActiveSheet();

// Read data
const range = sheet.getRange('A1:D10');
const values = range.getValues(); // 2D array

// Write data
sheet.getRange('A1').setValue('Hello');
sheet.getRange('B1:D1').setValues([['One', 'Two', 'Three']]);

// Batch operations (faster)
const data = [];
for (let i = 0; i < 100; i++) {
  data.push([i, `Item ${i}`, new Date()]);
}
sheet.getRange(1, 1, data.length, 3).setValues(data);

// Formatting
range.setBackground('#f0f0f0');
range.setFontWeight('bold');
range.setBorder(true, true, true, true, true, true);

// Custom function (use in cell as =DOUBLE(5))
function DOUBLE(value) {
  return value * 2;
}
```

### GmailApp (Email)

```javascript
// Send email
GmailApp.sendEmail(
  'recipient@example.com',
  'Subject Line',
  'Plain text body',
  {
    htmlBody: '<h1>HTML Body</h1>',
    attachments: [blob],
    cc: 'cc@example.com',
    name: 'Sender Name'
  }
);

// Read inbox
const threads = GmailApp.getInboxThreads(0, 10);
threads.forEach(thread => {
  const messages = thread.getMessages();
  messages.forEach(msg => {
    Logger.log(`From: ${msg.getFrom()}`);
    Logger.log(`Subject: ${msg.getSubject()}`);
    Logger.log(`Body: ${msg.getPlainBody()}`);
  });
});

// Search emails
const results = GmailApp.search('from:boss@company.com is:unread');

// Create draft
GmailApp.createDraft('to@example.com', 'Draft Subject', 'Draft body');
```

### DriveApp (Files)

```javascript
// Create folder
const folder = DriveApp.createFolder('New Folder');

// Upload file
const blob = Utilities.newBlob('Content', 'text/plain', 'file.txt');
folder.createFile(blob);

// Find files
const files = DriveApp.getFilesByName('report.pdf');
while (files.hasNext()) {
  const file = files.next();
  Logger.log(file.getUrl());
}

// Copy file
const original = DriveApp.getFileById('FILE_ID');
const copy = original.makeCopy('Copy Name', folder);

// Share file
file.addEditor('user@example.com');
file.setSharing(DriveApp.Access.ANYONE_WITH_LINK, DriveApp.Permission.VIEW);
```

### CalendarApp

```javascript
// Get calendar
const calendar = CalendarApp.getDefaultCalendar();

// Create event
const event = calendar.createEvent(
  'Meeting Title',
  new Date('2026-02-10T10:00:00'),
  new Date('2026-02-10T11:00:00'),
  {
    description: 'Meeting notes',
    location: 'Room 101',
    guests: 'guest@example.com'
  }
);

// Get upcoming events
const now = new Date();
const nextWeek = new Date(now.getTime() + 7 * 24 * 60 * 60 * 1000);
const events = calendar.getEvents(now, nextWeek);
```

## Triggers

```javascript
// Time-driven trigger (run daily at 9 AM)
function createTimeTrigger() {
  ScriptApp.newTrigger('dailyReport')
    .timeBased()
    .atHour(9)
    .everyDays(1)
    .create();
}

// On edit trigger
function onEdit(e) {
  const range = e.range;
  const value = e.value;
  const sheet = e.source.getActiveSheet();
  
  if (sheet.getName() === 'Data' && range.getColumn() === 1) {
    range.offset(0, 1).setValue(new Date());
  }
}

// On form submit
function onFormSubmit(e) {
  const responses = e.values;
  const email = responses[1];
  GmailApp.sendEmail(email, 'Thank you!', 'Your submission received.');
}

// Installable trigger
function createOnEditTrigger() {
  ScriptApp.newTrigger('onEditHandler')
    .forSpreadsheet(SpreadsheetApp.getActive())
    .onEdit()
    .create();
}
```

## Web Apps

```javascript
// Code.gs
function doGet(e) {
  return HtmlService.createHtmlOutputFromFile('Index')
    .setTitle('My Web App')
    .setXFrameOptionsMode(HtmlService.XFrameOptionsMode.ALLOWALL);
}

function doPost(e) {
  const data = JSON.parse(e.postData.contents);
  // Process data
  return ContentService.createTextOutput(
    JSON.stringify({ success: true })
  ).setMimeType(ContentService.MimeType.JSON);
}

function getData() {
  const sheet = SpreadsheetApp.getActiveSpreadsheet().getSheetByName('Data');
  return sheet.getDataRange().getValues();
}
```

```html
<!-- Index.html -->
<!DOCTYPE html>
<html>
<head>
  <base target="_top">
  <?!= include('Styles'); ?>
</head>
<body>
  <div id="app">
    <h1>Dashboard</h1>
    <div id="data"></div>
  </div>
  
  <script>
    google.script.run
      .withSuccessHandler(displayData)
      .withFailureHandler(showError)
      .getData();
    
    function displayData(data) {
      document.getElementById('data').innerHTML = JSON.stringify(data);
    }
    
    function showError(error) {
      alert('Error: ' + error.message);
    }
  </script>
</body>
</html>
```

## Custom Menus & Sidebars

```javascript
function onOpen() {
  const ui = SpreadsheetApp.getUi();
  ui.createMenu('🔧 Custom Tools')
    .addItem('Generate Report', 'generateReport')
    .addItem('Send Emails', 'sendBulkEmails')
    .addSeparator()
    .addSubMenu(ui.createMenu('Settings')
      .addItem('Configure', 'openSettings'))
    .addToUi();
}

function showSidebar() {
  const html = HtmlService.createHtmlOutputFromFile('Sidebar')
    .setTitle('My Sidebar')
    .setWidth(300);
  SpreadsheetApp.getUi().showSidebar(html);
}

function showDialog() {
  const html = HtmlService.createHtmlOutputFromFile('Dialog')
    .setWidth(400)
    .setHeight(300);
  SpreadsheetApp.getUi().showModalDialog(html, 'Dialog Title');
}
```

## External API Integration

```javascript
// Fetch external API
function fetchExternalAPI() {
  const url = 'https://api.example.com/data';
  const options = {
    method: 'GET',
    headers: {
      'Authorization': 'Bearer ' + getApiKey(),
      'Content-Type': 'application/json'
    },
    muteHttpExceptions: true
  };
  
  const response = UrlFetchApp.fetch(url, options);
  const data = JSON.parse(response.getContentText());
  return data;
}

// POST request
function postData(payload) {
  const options = {
    method: 'POST',
    contentType: 'application/json',
    payload: JSON.stringify(payload)
  };
  return UrlFetchApp.fetch(url, options);
}

// Store API keys securely
function getApiKey() {
  return PropertiesService.getScriptProperties().getProperty('API_KEY');
}
```

## Best Practices

### ✅ Do This

- Use batch operations for Sheets (faster than cell-by-cell)
- Store secrets in Script Properties, not in code
- Use `Logger.log()` for debugging
- Add error handling with try-catch
- Use installable triggers for complex automations
- Cache frequently accessed data with CacheService

### ❌ Avoid

- Don't exceed quotas (email limits, execution time)
- Don't hardcode sensitive data
- Don't use `SpreadsheetApp.flush()` unnecessarily
- Don't create too many triggers (limit: 20 per user)

## Debugging

```javascript
// Logging
Logger.log('Debug message');
console.log('Also works');

// Execution transcript
// View > Executions in Apps Script editor

// Error handling
try {
  riskyOperation();
} catch (error) {
  Logger.log(`Error: ${error.message}`);
  // Send error notification
  GmailApp.sendEmail('admin@example.com', 'Script Error', error.stack);
}
```

## Related Skills

- `@spreadsheet-expert` - Advanced Excel/Sheets
- `@workflow-automation-builder` - Automation tools
- `@senior-typescript-developer` - clasp + TypeScript setup
- `@gmail-automation` - Email automation patterns

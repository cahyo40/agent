---
name: chrome-extension-developer
description: "Expert Chrome extension development including Manifest V3, content scripts, and browser APIs"
---

# Chrome Extension Developer

## Overview

Build Chrome extensions using Manifest V3 and browser APIs.

## When to Use This Skill

- Use when building browser extensions
- Use when automating browser tasks

## How It Works

### Step 1: Manifest V3 Structure

```json
// manifest.json
{
  "manifest_version": 3,
  "name": "My Extension",
  "version": "1.0",
  "description": "A helpful extension",
  "permissions": [
    "storage",
    "activeTab",
    "scripting"
  ],
  "host_permissions": [
    "https://*.example.com/*"
  ],
  "action": {
    "default_popup": "popup.html",
    "default_icon": {
      "16": "icons/icon16.png",
      "48": "icons/icon48.png",
      "128": "icons/icon128.png"
    }
  },
  "background": {
    "service_worker": "background.js"
  },
  "content_scripts": [
    {
      "matches": ["https://*.example.com/*"],
      "js": ["content.js"],
      "css": ["content.css"]
    }
  ]
}
```

### Step 2: Background Service Worker

```javascript
// background.js
chrome.runtime.onInstalled.addListener(() => {
  console.log('Extension installed');
  
  // Set default settings
  chrome.storage.sync.set({
    enabled: true,
    theme: 'light'
  });
});

// Listen for messages from content script
chrome.runtime.onMessage.addListener((request, sender, sendResponse) => {
  if (request.action === 'getData') {
    // Fetch data
    fetch('https://api.example.com/data')
      .then(res => res.json())
      .then(data => sendResponse({ data }));
    
    return true; // Keep channel open for async response
  }
});

// Context menu
chrome.contextMenus.create({
  id: 'myExtension',
  title: 'Process with My Extension',
  contexts: ['selection']
});

chrome.contextMenus.onClicked.addListener((info, tab) => {
  if (info.menuItemId === 'myExtension') {
    const selectedText = info.selectionText;
    // Process selected text
  }
});
```

### Step 3: Content Script

```javascript
// content.js - Runs on web pages
(function() {
  // Inject UI
  const button = document.createElement('button');
  button.textContent = 'My Extension';
  button.style.cssText = 'position:fixed;top:10px;right:10px;z-index:9999;';
  document.body.appendChild(button);

  button.addEventListener('click', async () => {
    // Get data from background
    const response = await chrome.runtime.sendMessage({ action: 'getData' });
    console.log(response.data);
  });

  // Modify page content
  const elements = document.querySelectorAll('.target-class');
  elements.forEach(el => {
    el.style.backgroundColor = 'yellow';
  });
})();
```

### Step 4: Popup UI

```html
<!-- popup.html -->
<!DOCTYPE html>
<html>
<head>
  <style>
    body { width: 300px; padding: 15px; font-family: Arial; }
    .toggle { margin: 10px 0; }
  </style>
</head>
<body>
  <h2>My Extension</h2>
  <div class="toggle">
    <label>
      <input type="checkbox" id="enabled"> Enabled
    </label>
  </div>
  <button id="action">Run Action</button>
  <script src="popup.js"></script>
</body>
</html>
```

```javascript
// popup.js
document.addEventListener('DOMContentLoaded', async () => {
  const checkbox = document.getElementById('enabled');
  const button = document.getElementById('action');

  // Load saved state
  const { enabled } = await chrome.storage.sync.get('enabled');
  checkbox.checked = enabled;

  // Save on change
  checkbox.addEventListener('change', () => {
    chrome.storage.sync.set({ enabled: checkbox.checked });
  });

  // Execute action on current tab
  button.addEventListener('click', async () => {
    const [tab] = await chrome.tabs.query({ active: true, currentWindow: true });
    
    await chrome.scripting.executeScript({
      target: { tabId: tab.id },
      func: () => alert('Hello from extension!')
    });
  });
});
```

## Best Practices

- ✅ Use Manifest V3 (required 2024+)
- ✅ Request minimal permissions
- ✅ Handle errors gracefully
- ❌ Don't inject on all sites
- ❌ Don't store sensitive data locally

## Related Skills

- `@senior-typescript-developer`
- `@browser-automation-expert`

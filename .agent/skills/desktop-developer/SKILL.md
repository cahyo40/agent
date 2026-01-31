---
name: desktop-developer
description: "Foundational desktop application development skills including Electron, native frameworks, and cross-platform desktop patterns"
---

# Desktop Developer

## Overview

This skill provides foundational knowledge for building desktop applications across Windows, macOS, and Linux. Covers framework options, architecture patterns, and platform-specific considerations.

## When to Use This Skill

- Use when building desktop applications
- Use when choosing desktop frameworks
- Use when porting web apps to desktop
- Use when implementing desktop UX patterns
- Use when working with system APIs

## How It Works

### Step 1: Desktop Development Options

```text
DESKTOP DEVELOPMENT LANDSCAPE
├── Web-Based (Cross-Platform)
│   ├── Electron (JS/TS)
│   │   └── VS Code, Slack, Discord
│   ├── Tauri (Rust + Web)
│   │   └── Lighter, more performant
│   └── Best for: Web developers
├── Native (Platform-Specific)
│   ├── Windows: WinUI 3, WPF (.NET)
│   ├── macOS: SwiftUI, AppKit
│   └── Linux: GTK, Qt
├── Cross-Platform Native
│   ├── Flutter Desktop
│   ├── Qt (C++)
│   └── .NET MAUI
└── Lightweight
    ├── Wails (Go + Web)
    └── Neutralino.js
```

### Step 2: Electron Quick Start

```javascript
// main.js - Main Process
const { app, BrowserWindow, ipcMain } = require('electron');
const path = require('path');

function createWindow() {
  const mainWindow = new BrowserWindow({
    width: 1200,
    height: 800,
    webPreferences: {
      preload: path.join(__dirname, 'preload.js'),
      contextIsolation: true,
      nodeIntegration: false
    }
  });

  mainWindow.loadFile('index.html');
  
  // Open DevTools in development
  if (process.env.NODE_ENV === 'development') {
    mainWindow.webContents.openDevTools();
  }
}

app.whenReady().then(createWindow);

app.on('window-all-closed', () => {
  if (process.platform !== 'darwin') {
    app.quit();
  }
});

// IPC Handler
ipcMain.handle('read-file', async (event, filePath) => {
  const fs = require('fs').promises;
  return await fs.readFile(filePath, 'utf-8');
});
```

```javascript
// preload.js - Bridge between main and renderer
const { contextBridge, ipcRenderer } = require('electron');

contextBridge.exposeInMainWorld('electronAPI', {
  readFile: (path) => ipcRenderer.invoke('read-file', path),
  onMenuClick: (callback) => ipcRenderer.on('menu-click', callback)
});
```

### Step 3: Project Structure

```text
desktop-app/
├── src/
│   ├── main/           # Main process (Node.js)
│   │   ├── main.js
│   │   ├── preload.js
│   │   └── ipc/
│   ├── renderer/       # Renderer (Web)
│   │   ├── index.html
│   │   ├── styles.css
│   │   └── app.js
│   └── shared/         # Shared types/utils
├── assets/
│   ├── icons/
│   └── images/
├── build/              # Build configuration
├── dist/               # Output bundles
├── package.json
└── electron-builder.yml
```

### Step 4: Desktop UX Patterns

```markdown
## Desktop-Specific Patterns

### Window Management
- Main window + child windows
- Modal dialogs
- System tray integration
- Menu bar (File, Edit, View, Help)

### Keyboard Shortcuts
- Ctrl/Cmd + S (Save)
- Ctrl/Cmd + Z (Undo)
- Ctrl/Cmd + Shift + Z (Redo)
- Ctrl/Cmd + O (Open)
- Ctrl/Cmd + W (Close)

### File System
- Open/Save file dialogs
- Recent files list
- Drag and drop files
- Auto-save with recovery

### Native Integration
- Notifications
- Clipboard
- Context menus
- File associations
```

### Step 5: Distribution

```yaml
# electron-builder.yml
appId: com.company.myapp
productName: My Desktop App
directories:
  output: dist

mac:
  category: public.app-category.productivity
  target:
    - dmg
    - zip

win:
  target:
    - nsis
    - portable

linux:
  target:
    - AppImage
    - deb
  category: Utility

publish:
  provider: github
  releaseType: release
```

## Best Practices

### ✅ Do This

- ✅ Follow OS-specific design guidelines
- ✅ Support keyboard navigation
- ✅ Implement undo/redo where applicable
- ✅ Handle window state (maximize, minimize)
- ✅ Auto-update mechanism
- ✅ Code signing for distribution
- ✅ Keep app bundle size reasonable

### ❌ Avoid This

- ❌ Don't ignore platform conventions
- ❌ Don't skip proper IPC security
- ❌ Don't enable nodeIntegration in renderer
- ❌ Don't forget to handle crashes
- ❌ Don't ignore memory usage

## Framework Comparison

| Framework | Language | Size | Performance | Native Feel |
|-----------|----------|------|-------------|-------------|
| Electron | JS/TS | ~150MB | Medium | Low |
| Tauri | Rust+Web | ~10MB | High | Medium |
| Flutter | Dart | ~30MB | High | Medium |
| Qt | C++ | ~50MB | High | High |
| .NET MAUI | C# | ~40MB | High | High (Win) |

## Related Skills

- `@electron-desktop-developer` - Electron apps
- `@senior-flutter-developer` - Flutter desktop
- `@senior-react-developer` - For Electron renderer

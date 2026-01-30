---
name: electron-desktop-developer
description: "Expert Electron development for cross-platform desktop applications using web technologies"
---

# Electron Desktop Developer

## Overview

This skill helps you build cross-platform desktop applications using Electron with web technologies (HTML, CSS, JavaScript/TypeScript).

## When to Use This Skill

- Use when building desktop apps with web tech
- Use when needing cross-platform support
- Use when porting web apps to desktop

## How It Works

### Step 1: Project Structure

```text
my-electron-app/
├── src/
│   ├── main/              # Main process (Node.js)
│   │   ├── main.ts
│   │   ├── preload.ts
│   │   └── ipc/
│   ├── renderer/          # Renderer process (Web)
│   │   ├── index.html
│   │   ├── App.tsx
│   │   └── components/
│   └── shared/            # Shared types
├── electron-builder.yml
├── package.json
└── tsconfig.json
```

### Step 2: Main Process

```typescript
// src/main/main.ts
import { app, BrowserWindow, ipcMain } from 'electron';
import path from 'path';

let mainWindow: BrowserWindow | null = null;

function createWindow() {
  mainWindow = new BrowserWindow({
    width: 1200,
    height: 800,
    webPreferences: {
      preload: path.join(__dirname, 'preload.js'),
      contextIsolation: true,
      nodeIntegration: false,
    },
  });

  if (process.env.NODE_ENV === 'development') {
    mainWindow.loadURL('http://localhost:3000');
    mainWindow.webContents.openDevTools();
  } else {
    mainWindow.loadFile(path.join(__dirname, '../renderer/index.html'));
  }
}

app.whenReady().then(createWindow);

app.on('window-all-closed', () => {
  if (process.platform !== 'darwin') app.quit();
});

// IPC Handlers
ipcMain.handle('read-file', async (_, filePath: string) => {
  const fs = await import('fs/promises');
  return fs.readFile(filePath, 'utf-8');
});

ipcMain.handle('save-file', async (_, filePath: string, content: string) => {
  const fs = await import('fs/promises');
  await fs.writeFile(filePath, content);
  return true;
});
```

### Step 3: Preload Script (Context Bridge)

```typescript
// src/main/preload.ts
import { contextBridge, ipcRenderer } from 'electron';

contextBridge.exposeInMainWorld('electronAPI', {
  readFile: (path: string) => ipcRenderer.invoke('read-file', path),
  saveFile: (path: string, content: string) => ipcRenderer.invoke('save-file', path, content),
  onMenuAction: (callback: (action: string) => void) => {
    ipcRenderer.on('menu-action', (_, action) => callback(action));
  },
  platform: process.platform,
});

// Type declaration for renderer
declare global {
  interface Window {
    electronAPI: {
      readFile: (path: string) => Promise<string>;
      saveFile: (path: string, content: string) => Promise<boolean>;
      onMenuAction: (callback: (action: string) => void) => void;
      platform: NodeJS.Platform;
    };
  }
}
```

### Step 4: Renderer (React)

```tsx
// src/renderer/App.tsx
import { useState, useEffect } from 'react';

function App() {
  const [content, setContent] = useState('');

  const handleOpen = async () => {
    const text = await window.electronAPI.readFile('/path/to/file.txt');
    setContent(text);
  };

  const handleSave = async () => {
    await window.electronAPI.saveFile('/path/to/file.txt', content);
  };

  useEffect(() => {
    window.electronAPI.onMenuAction((action) => {
      if (action === 'save') handleSave();
      if (action === 'open') handleOpen();
    });
  }, []);

  return (
    <div className="app">
      <textarea value={content} onChange={(e) => setContent(e.target.value)} />
      <button onClick={handleSave}>Save</button>
    </div>
  );
}
```

### Step 5: Build & Distribution

```yaml
# electron-builder.yml
appId: com.myapp.desktop
productName: MyApp
directories:
  output: dist
  buildResources: resources

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

publish:
  provider: github
  releaseType: release
```

## Best Practices

### ✅ Do This

- ✅ Always use contextIsolation
- ✅ Use preload scripts for IPC
- ✅ Handle app lifecycle properly
- ✅ Sign your application

### ❌ Avoid This

- ❌ Don't enable nodeIntegration
- ❌ Don't load remote content without validation
- ❌ Don't skip auto-updates

## Related Skills

- `@senior-react-developer` - React frontend
- `@senior-typescript-developer` - TypeScript patterns

---
name: flutter-desktop-developer
description: "Expert Flutter desktop development including macOS, Windows, Linux apps, platform channels, native integrations, and desktop-specific UI patterns"
---

# Flutter Desktop Developer

## Overview

This skill transforms you into a specialized Flutter Desktop Developer who builds production-ready applications for macOS, Windows, and Linux. You'll handle desktop-specific concerns like window management, native menus, system tray integration, and platform-specific APIs.

## When to Use This Skill

- Use when building Flutter applications for desktop platforms
- Use when porting mobile Flutter apps to desktop
- Use when implementing native desktop features (menus, system tray, file dialogs)
- Use when handling platform-specific code for desktop
- Use when optimizing Flutter desktop performance
- Use when packaging and distributing desktop applications

## How It Works

### Step 1: Desktop Project Setup

```bash
# Enable desktop support
flutter config --enable-macos-desktop
flutter config --enable-windows-desktop
flutter config --enable-linux-desktop

# Create new desktop app
flutter create --platforms=macos,windows,linux my_desktop_app

# Add desktop to existing project
flutter create --platforms=macos,windows,linux .
```

```yaml
# pubspec.yaml - Desktop dependencies
dependencies:
  flutter:
    sdk: flutter
  
  # Window management
  window_manager: ^0.3.7        # Window control (size, position, title)
  
  # System tray
  system_tray: ^2.0.5           # System tray icons and menus
  
  # File operations
  file_picker: ^6.1.1           # Native file dialogs
  path_provider: ^2.1.2         # System directories
  
  # Native menus
  menu_bar: ^0.5.3              # Native menu bar (macOS style)
  
  # Keyboard shortcuts
  hotkey_manager: ^0.2.0        # Global hotkeys
  
  # Updates
  auto_updater: ^1.0.0          # Auto-update mechanism
```

### Step 2: Window Management

```dart
// ════════════════════════════════════════════════════════════════════════════
// Window Configuration
// ════════════════════════════════════════════════════════════════════════════

import 'package:window_manager/window_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await windowManager.ensureInitialized();
  
  WindowOptions windowOptions = const WindowOptions(
    size: Size(1280, 720),
    minimumSize: Size(800, 600),
    center: true,
    backgroundColor: Colors.transparent,
    skipTaskbar: false,
    titleBarStyle: TitleBarStyle.hidden, // Custom title bar
    title: 'My Desktop App',
  );
  
  await windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });
  
  runApp(const MyApp());
}

// ════════════════════════════════════════════════════════════════════════════
// Custom Title Bar
// ════════════════════════════════════════════════════════════════════════════

class CustomTitleBar extends StatelessWidget {
  const CustomTitleBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      color: Theme.of(context).colorScheme.surface,
      child: Row(
        children: [
          // Draggable area
          Expanded(
            child: GestureDetector(
              onPanStart: (_) => windowManager.startDragging(),
              onDoubleTap: () async {
                if (await windowManager.isMaximized()) {
                  windowManager.unmaximize();
                } else {
                  windowManager.maximize();
                }
              },
              child: Container(
                color: Colors.transparent,
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: const Text('My App'),
              ),
            ),
          ),
          
          // Window controls
          _WindowButton(
            icon: Icons.remove,
            onPressed: () => windowManager.minimize(),
          ),
          _WindowButton(
            icon: Icons.crop_square,
            onPressed: () async {
              if (await windowManager.isMaximized()) {
                windowManager.unmaximize();
              } else {
                windowManager.maximize();
              }
            },
          ),
          _WindowButton(
            icon: Icons.close,
            onPressed: () => windowManager.close(),
            isClose: true,
          ),
        ],
      ),
    );
  }
}
```

### Step 3: Native Menus

```dart
// ════════════════════════════════════════════════════════════════════════════
// macOS-style Menu Bar
// ════════════════════════════════════════════════════════════════════════════

import 'package:flutter/services.dart';

class DesktopMenuBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return PlatformMenuBar(
      menus: [
        // App Menu (macOS only)
        PlatformMenu(
          label: 'My App',
          menus: [
            PlatformMenuItem(
              label: 'About My App',
              onSelected: () => _showAboutDialog(context),
            ),
            const PlatformMenuItemGroup(members: []),
            PlatformMenuItem(
              label: 'Settings...',
              shortcut: const SingleActivator(
                LogicalKeyboardKey.comma,
                meta: true,
              ),
              onSelected: () => _openSettings(context),
            ),
            const PlatformMenuItemGroup(members: []),
            PlatformMenuItem(
              label: 'Quit',
              shortcut: const SingleActivator(
                LogicalKeyboardKey.keyQ,
                meta: true,
              ),
              onSelected: () => windowManager.close(),
            ),
          ],
        ),
        
        // File Menu
        PlatformMenu(
          label: 'File',
          menus: [
            PlatformMenuItem(
              label: 'New',
              shortcut: const SingleActivator(
                LogicalKeyboardKey.keyN,
                meta: true,
              ),
              onSelected: () => _newFile(),
            ),
            PlatformMenuItem(
              label: 'Open...',
              shortcut: const SingleActivator(
                LogicalKeyboardKey.keyO,
                meta: true,
              ),
              onSelected: () => _openFile(),
            ),
            PlatformMenuItem(
              label: 'Save',
              shortcut: const SingleActivator(
                LogicalKeyboardKey.keyS,
                meta: true,
              ),
              onSelected: () => _saveFile(),
            ),
          ],
        ),
        
        // Edit Menu
        PlatformMenu(
          label: 'Edit',
          menus: [
            PlatformMenuItem(
              label: 'Undo',
              shortcut: const SingleActivator(
                LogicalKeyboardKey.keyZ,
                meta: true,
              ),
              onSelected: () => _undo(),
            ),
            PlatformMenuItem(
              label: 'Redo',
              shortcut: const SingleActivator(
                LogicalKeyboardKey.keyZ,
                meta: true,
                shift: true,
              ),
              onSelected: () => _redo(),
            ),
          ],
        ),
      ],
      child: const MyAppContent(),
    );
  }
}
```

### Step 4: System Tray Integration

```dart
// ════════════════════════════════════════════════════════════════════════════
// System Tray
// ════════════════════════════════════════════════════════════════════════════

import 'package:system_tray/system_tray.dart';

class SystemTrayManager {
  final SystemTray _systemTray = SystemTray();
  
  Future<void> init() async {
    await _systemTray.initSystemTray(
      title: 'My App',
      iconPath: _getTrayIconPath(),
      toolTip: 'My Desktop App',
    );
    
    final menu = Menu();
    await menu.buildFrom([
      MenuItemLabel(
        label: 'Show Window',
        onClicked: (menuItem) => windowManager.show(),
      ),
      MenuSeparator(),
      MenuItemLabel(
        label: 'Settings',
        onClicked: (menuItem) => _openSettings(),
      ),
      MenuSeparator(),
      MenuItemLabel(
        label: 'Quit',
        onClicked: (menuItem) => windowManager.close(),
      ),
    ]);
    
    await _systemTray.setContextMenu(menu);
    
    // Handle tray icon click
    _systemTray.registerSystemTrayEventHandler((eventName) {
      if (eventName == kSystemTrayEventClick) {
        windowManager.show();
      } else if (eventName == kSystemTrayEventRightClick) {
        _systemTray.popUpContextMenu();
      }
    });
  }
  
  String _getTrayIconPath() {
    if (Platform.isWindows) {
      return 'assets/icons/app_icon.ico';
    } else if (Platform.isMacOS) {
      return 'assets/icons/app_icon.png';
    }
    return 'assets/icons/app_icon.png';
  }
}
```

### Step 5: File Operations

```dart
// ════════════════════════════════════════════════════════════════════════════
// Native File Dialogs
// ════════════════════════════════════════════════════════════════════════════

import 'package:file_picker/file_picker.dart';

class FileOperations {
  // Open file dialog
  Future<File?> openFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['txt', 'md', 'json'],
      dialogTitle: 'Open File',
    );
    
    if (result != null && result.files.single.path != null) {
      return File(result.files.single.path!);
    }
    return null;
  }
  
  // Save file dialog
  Future<String?> saveFile(String content) async {
    final result = await FilePicker.platform.saveFile(
      dialogTitle: 'Save File',
      fileName: 'untitled.txt',
      type: FileType.custom,
      allowedExtensions: ['txt', 'md'],
    );
    
    if (result != null) {
      final file = File(result);
      await file.writeAsString(content);
      return result;
    }
    return null;
  }
  
  // Open folder dialog
  Future<String?> selectFolder() async {
    return await FilePicker.platform.getDirectoryPath(
      dialogTitle: 'Select Folder',
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// Drag and Drop
// ════════════════════════════════════════════════════════════════════════════

class DropZone extends StatefulWidget {
  @override
  State<DropZone> createState() => _DropZoneState();
}

class _DropZoneState extends State<DropZone> {
  bool _isDragging = false;

  @override
  Widget build(BuildContext context) {
    return DropTarget(
      onDragEntered: (_) => setState(() => _isDragging = true),
      onDragExited: (_) => setState(() => _isDragging = false),
      onDragDone: (details) {
        setState(() => _isDragging = false);
        for (final file in details.files) {
          _handleDroppedFile(file.path);
        }
      },
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: _isDragging ? Colors.blue : Colors.grey,
            width: 2,
          ),
        ),
        child: const Center(
          child: Text('Drop files here'),
        ),
      ),
    );
  }
}
```

### Step 6: Platform-Specific Code

```dart
// ════════════════════════════════════════════════════════════════════════════
// Platform Checks
// ════════════════════════════════════════════════════════════════════════════

import 'dart:io' show Platform;

class PlatformUtils {
  static bool get isDesktop =>
      Platform.isMacOS || Platform.isWindows || Platform.isLinux;
  
  static bool get isMacOS => Platform.isMacOS;
  static bool get isWindows => Platform.isWindows;
  static bool get isLinux => Platform.isLinux;
  
  // Platform-specific modifier key
  static bool get useMetaKey => Platform.isMacOS;
  static bool get useControlKey => !Platform.isMacOS;
  
  static String get platformName {
    if (Platform.isMacOS) return 'macOS';
    if (Platform.isWindows) return 'Windows';
    if (Platform.isLinux) return 'Linux';
    return 'Unknown';
  }
}

// ════════════════════════════════════════════════════════════════════════════
// Platform Channels (Native Code Integration)
// ════════════════════════════════════════════════════════════════════════════

class NativeIntegration {
  static const _channel = MethodChannel('com.myapp/native');
  
  // Call native code
  Future<String> getNativeInfo() async {
    try {
      final result = await _channel.invokeMethod<String>('getSystemInfo');
      return result ?? 'Unknown';
    } on PlatformException catch (e) {
      return 'Error: ${e.message}';
    }
  }
  
  // Listen to native events
  static const _eventChannel = EventChannel('com.myapp/events');
  
  Stream<dynamic> get nativeEvents {
    return _eventChannel.receiveBroadcastStream();
  }
}
```

### Step 7: Desktop UI Patterns

```dart
// ════════════════════════════════════════════════════════════════════════════
// Master-Detail Layout (Common Desktop Pattern)
// ════════════════════════════════════════════════════════════════════════════

class MasterDetailLayout extends StatefulWidget {
  @override
  State<MasterDetailLayout> createState() => _MasterDetailLayoutState();
}

class _MasterDetailLayoutState extends State<MasterDetailLayout> {
  int? _selectedIndex;
  
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Sidebar (Master)
        SizedBox(
          width: 250,
          child: ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              return ListTile(
                selected: _selectedIndex == index,
                title: Text(items[index].title),
                onTap: () => setState(() => _selectedIndex = index),
              );
            },
          ),
        ),
        
        const VerticalDivider(width: 1),
        
        // Content (Detail)
        Expanded(
          child: _selectedIndex != null
              ? DetailView(item: items[_selectedIndex!])
              : const Center(child: Text('Select an item')),
        ),
      ],
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// Keyboard Shortcuts
// ════════════════════════════════════════════════════════════════════════════

class KeyboardShortcuts extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Shortcuts(
      shortcuts: {
        // Save: Cmd+S (macOS) or Ctrl+S (Windows/Linux)
        SingleActivator(
          LogicalKeyboardKey.keyS,
          meta: PlatformUtils.isMacOS,
          control: !PlatformUtils.isMacOS,
        ): const SaveIntent(),
        
        // New: Cmd+N or Ctrl+N
        SingleActivator(
          LogicalKeyboardKey.keyN,
          meta: PlatformUtils.isMacOS,
          control: !PlatformUtils.isMacOS,
        ): const NewIntent(),
        
        // Find: Cmd+F or Ctrl+F
        SingleActivator(
          LogicalKeyboardKey.keyF,
          meta: PlatformUtils.isMacOS,
          control: !PlatformUtils.isMacOS,
        ): const FindIntent(),
      },
      child: Actions(
        actions: {
          SaveIntent: CallbackAction<SaveIntent>(
            onInvoke: (_) => _save(),
          ),
          NewIntent: CallbackAction<NewIntent>(
            onInvoke: (_) => _new(),
          ),
          FindIntent: CallbackAction<FindIntent>(
            onInvoke: (_) => _find(),
          ),
        },
        child: const MyAppContent(),
      ),
    );
  }
}
```

### Step 8: Packaging & Distribution

```yaml
# macOS - macos/Runner/Release.entitlements
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "...">
<plist version="1.0">
<dict>
  <key>com.apple.security.app-sandbox</key>
  <true/>
  <key>com.apple.security.network.client</key>
  <true/>
  <key>com.apple.security.files.user-selected.read-write</key>
  <true/>
</dict>
</plist>
```

```bash
# Build for each platform
flutter build macos --release
flutter build windows --release
flutter build linux --release

# macOS - Create DMG
hdiutil create -volname "My App" -srcfolder build/macos/Build/Products/Release/MyApp.app -ov -format UDZO MyApp.dmg

# Windows - Create installer (using Inno Setup)
# Create setup.iss and run:
iscc setup.iss

# Linux - Create AppImage
# Use appimagetool or flutter_distributor package
```

```yaml
# pubspec.yaml - flutter_distributor for automated packaging
dev_dependencies:
  flutter_distributor: ^0.0.2

# distribute_options.yaml
variables:
  appName: My App
  version: 1.0.0

releases:
  - name: release
    builds:
      - platform: macos
        target: dmg
      - platform: windows
        target: exe
      - platform: linux
        target: appimage
```

## Best Practices

### ✅ Do This

- ✅ Use custom title bar for consistent look across platforms
- ✅ Implement proper keyboard shortcuts (Cmd on macOS, Ctrl on Windows/Linux)
- ✅ Support drag & drop for files
- ✅ Save/restore window position and size
- ✅ Implement system tray for background apps
- ✅ Handle multi-window scenarios properly
- ✅ Test on all target platforms
- ✅ Sign your applications for distribution

### ❌ Avoid This

- ❌ Don't ignore platform conventions (menu bar on macOS vs hamburger menu)
- ❌ Don't forget proper file permissions (sandboxing on macOS)
- ❌ Don't skip keyboard accessibility
- ❌ Don't use mobile-only gestures (pinch, swipe)
- ❌ Don't ignore high DPI displays
- ❌ Don't hardcode paths (use path_provider)

## Common Pitfalls

**Problem:** Window state not persisted
**Solution:** Save window size/position to local storage on close, restore on launch

**Problem:** Keyboard shortcuts conflict with system
**Solution:** Follow platform conventions (Cmd on macOS, Ctrl on Windows/Linux)

**Problem:** App not signed, can't distribute
**Solution:** Sign with Apple Developer ID (macOS) or code signing certificate (Windows)

## Production Checklist

```markdown
### Pre-Release
- [ ] Custom title bar implemented
- [ ] Native menus working
- [ ] Keyboard shortcuts implemented
- [ ] File associations configured
- [ ] System tray (if applicable)
- [ ] Auto-updater integrated

### Platform-Specific
- [ ] macOS: Signed with Developer ID
- [ ] macOS: Notarized with Apple
- [ ] Windows: Code signed
- [ ] Windows: Installer created (MSI/EXE)
- [ ] Linux: AppImage/Snap/Flatpak created

### Testing
- [ ] Tested on macOS (Intel + Apple Silicon)
- [ ] Tested on Windows (10/11)
- [ ] Tested on Linux (Ubuntu/Fedora)
- [ ] Multi-monitor support verified
- [ ] High DPI displays tested
```

## Related Skills

- `@senior-flutter-developer` - Mobile Flutter patterns
- `@flutter-web-developer` - Web-specific Flutter
- `@electron-desktop-developer` - Alternative desktop framework
- `@desktop-developer` - General desktop concepts

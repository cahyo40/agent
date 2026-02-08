# Flutter Desktop Development

## Overview

Production-ready Flutter desktop for macOS, Windows, and Linux including window management, native menus, system tray, and platform-specific integrations.

## When to Use

- Building Flutter apps for desktop platforms
- Porting mobile Flutter apps to desktop
- Implementing native desktop features
- Packaging and distributing desktop apps

---

## Project Setup

```bash
# Enable desktop support
flutter config --enable-macos-desktop
flutter config --enable-windows-desktop
flutter config --enable-linux-desktop

# Create desktop app
flutter create --platforms=macos,windows,linux my_desktop_app
```

```yaml
# pubspec.yaml
dependencies:
  window_manager: ^0.3.7     # Window control
  system_tray: ^2.0.5        # System tray
  file_picker: ^6.1.1        # Native file dialogs
  hotkey_manager: ^0.2.0     # Global hotkeys
```

---

## Window Management

```dart
import 'package:window_manager/window_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();
  
  WindowOptions windowOptions = const WindowOptions(
    size: Size(1280, 720),
    minimumSize: Size(800, 600),
    center: true,
    titleBarStyle: TitleBarStyle.hidden,
    title: 'My Desktop App',
  );
  
  await windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });
  
  runApp(const MyApp());
}

// Custom Title Bar
class CustomTitleBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: (_) => windowManager.startDragging(),
      onDoubleTap: () async {
        if (await windowManager.isMaximized()) {
          windowManager.unmaximize();
        } else {
          windowManager.maximize();
        }
      },
      child: Container(
        height: 40,
        child: Row(children: [
          Expanded(child: Text('My App')),
          IconButton(icon: Icon(Icons.remove), onPressed: () => windowManager.minimize()),
          IconButton(icon: Icon(Icons.crop_square), onPressed: () async {
            await windowManager.isMaximized() 
                ? windowManager.unmaximize() 
                : windowManager.maximize();
          }),
          IconButton(icon: Icon(Icons.close), onPressed: () => windowManager.close()),
        ]),
      ),
    );
  }
}
```

---

## Native Menus

```dart
class DesktopMenuBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return PlatformMenuBar(
      menus: [
        PlatformMenu(
          label: 'File',
          menus: [
            PlatformMenuItem(
              label: 'New',
              shortcut: SingleActivator(LogicalKeyboardKey.keyN, meta: true),
              onSelected: () => _newFile(),
            ),
            PlatformMenuItem(
              label: 'Open...',
              shortcut: SingleActivator(LogicalKeyboardKey.keyO, meta: true),
              onSelected: () => _openFile(),
            ),
            PlatformMenuItem(
              label: 'Save',
              shortcut: SingleActivator(LogicalKeyboardKey.keyS, meta: true),
              onSelected: () => _saveFile(),
            ),
          ],
        ),
      ],
      child: const MyAppContent(),
    );
  }
}
```

---

## System Tray

```dart
import 'package:system_tray/system_tray.dart';

class SystemTrayManager {
  final SystemTray _systemTray = SystemTray();
  
  Future<void> init() async {
    await _systemTray.initSystemTray(
      title: 'My App',
      iconPath: Platform.isWindows ? 'assets/app_icon.ico' : 'assets/app_icon.png',
    );
    
    final menu = Menu();
    await menu.buildFrom([
      MenuItemLabel(label: 'Show Window', onClicked: (_) => windowManager.show()),
      MenuSeparator(),
      MenuItemLabel(label: 'Quit', onClicked: (_) => windowManager.close()),
    ]);
    
    await _systemTray.setContextMenu(menu);
  }
}
```

---

## File Operations

```dart
import 'package:file_picker/file_picker.dart';

class FileOperations {
  Future<File?> openFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['txt', 'md', 'json'],
    );
    
    if (result != null && result.files.single.path != null) {
      return File(result.files.single.path!);
    }
    return null;
  }
  
  Future<String?> saveFile(String content) async {
    final result = await FilePicker.platform.saveFile(
      fileName: 'untitled.txt',
      type: FileType.custom,
      allowedExtensions: ['txt', 'md'],
    );
    
    if (result != null) {
      await File(result).writeAsString(content);
      return result;
    }
    return null;
  }
}
```

---

## Keyboard Shortcuts

```dart
class KeyboardShortcuts extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Shortcuts(
      shortcuts: {
        SingleActivator(
          LogicalKeyboardKey.keyS,
          meta: Platform.isMacOS,
          control: !Platform.isMacOS,
        ): const SaveIntent(),
      },
      child: Actions(
        actions: {
          SaveIntent: CallbackAction<SaveIntent>(onInvoke: (_) => _save()),
        },
        child: const MyAppContent(),
      ),
    );
  }
}
```

---

## Packaging

```bash
# Build for each platform
flutter build macos --release
flutter build windows --release
flutter build linux --release

# macOS - Create DMG
hdiutil create -volname "My App" -srcfolder build/macos/Build/Products/Release/MyApp.app -ov -format UDZO MyApp.dmg
```

---

## Best Practices

### ✅ Do This

- ✅ Use custom title bar for consistent look
- ✅ Implement Cmd shortcuts on macOS, Ctrl on Windows/Linux
- ✅ Support drag & drop for files
- ✅ Save/restore window position and size
- ✅ Sign applications for distribution

### ❌ Avoid This

- ❌ Don't ignore platform conventions
- ❌ Don't skip keyboard accessibility
- ❌ Don't use mobile-only gestures
- ❌ Don't hardcode paths

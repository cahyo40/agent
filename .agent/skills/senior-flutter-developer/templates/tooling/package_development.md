# Flutter Package Development

## Overview

Creating high-quality, reusable Flutter packages for pub.dev with proper API design and documentation.

---

## Package Structure

```text
my_package/
├── lib/
│   ├── my_package.dart      # Main export
│   └── src/                 # Private implementation
├── example/                 # Example app (required!)
├── test/
├── analysis_options.yaml
├── pubspec.yaml
├── README.md
├── CHANGELOG.md
└── LICENSE
```

---

## pubspec.yaml

```yaml
name: my_awesome_package
description: A concise description of what your package does.
version: 1.0.0
homepage: https://github.com/username/my_awesome_package
repository: https://github.com/username/my_awesome_package

environment:
  sdk: '>=3.0.0 <4.0.0'
  flutter: '>=3.10.0'

dependencies:
  flutter:
    sdk: flutter

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.0

topics:
  - widgets
  - ui

screenshots:
  - description: 'Demo'
    path: screenshots/demo.png
```

---

## API Design

```dart
// lib/my_package.dart - Only export public API
library my_package;

export 'src/widgets/fancy_button.dart' show FancyButton, FancyButtonStyle;
export 'src/utils/helpers.dart' show formatDuration;

// DON'T export internal implementation
// export 'src/internal/private_utils.dart'; // ❌

// Sensible Defaults + Full Customization
class FancyButton extends StatelessWidget {
  const FancyButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.style,               // Optional, has default
    this.isLoading = false,   // Has default
    this.loadingWidget,       // Optional custom widget
  });

  final VoidCallback? onPressed;
  final Widget child;
  final FancyButtonStyle? style;
  final bool isLoading;
  final Widget? loadingWidget;

  @override
  Widget build(BuildContext context) {
    final effectiveStyle = style ?? FancyButtonStyle.defaultStyle(context);
    // ...
  }
}
```

---

## Platform Plugin

```dart
// Platform interface
abstract class MyPluginPlatform extends PlatformInterface {
  MyPluginPlatform() : super(token: _token);
  static final Object _token = Object();
  
  static MyPluginPlatform _instance = MethodChannelMyPlugin();
  static MyPluginPlatform get instance => _instance;

  Future<String?> getPlatformVersion();
}

// Method channel implementation
class MethodChannelMyPlugin extends MyPluginPlatform {
  final _channel = const MethodChannel('my_plugin');

  @override
  Future<String?> getPlatformVersion() async {
    return _channel.invokeMethod<String>('getPlatformVersion');
  }
}
```

---

## Publishing

```bash
# 1. Validate package
flutter pub publish --dry-run

# 2. Check score locally
pana .

# 3. Run tests
flutter test

# 4. Publish
flutter pub publish

# 5. Create GitHub release
git tag v1.0.0
git push origin v1.0.0
```

---

## Best Practices

### ✅ Do This

- ✅ Include comprehensive example app
- ✅ Write dartdoc for all public APIs
- ✅ Follow semantic versioning
- ✅ Support latest 2-3 Flutter versions
- ✅ Keep dependencies minimal

### ❌ Avoid This

- ❌ Don't expose internal implementation
- ❌ Don't have too many dependencies
- ❌ Don't skip tests
- ❌ Don't ignore pub.dev score

---
name: flutter-package-developer
description: "Expert Flutter package development including API design, platform channels, pub.dev publishing, and package maintenance"
---

# Flutter Package Developer

## Overview

This skill helps you create high-quality, reusable Flutter packages that other developers will love to use.

## When to Use This Skill

- Use when creating reusable Flutter packages
- Use when publishing to pub.dev
- Use when building platform plugins
- Use when designing package APIs

## How It Works

### Step 1: Package Structure

```text
my_package/
├── lib/
│   ├── my_package.dart          # Main export file
│   └── src/                     # Private implementation
│       ├── widgets/
│       ├── utils/
│       └── core/
├── example/                     # Example app (required!)
│   ├── lib/main.dart
│   └── pubspec.yaml
├── test/                        # Unit & widget tests
├── doc/                         # Additional documentation
├── analysis_options.yaml        # Strict linting
├── pubspec.yaml
├── README.md
├── CHANGELOG.md
├── LICENSE
└── .github/
    └── workflows/ci.yaml
```

### Step 2: pubspec.yaml Configuration

```yaml
name: my_awesome_package
description: A concise description of what your package does.
version: 1.0.0
homepage: https://github.com/username/my_awesome_package
repository: https://github.com/username/my_awesome_package
issue_tracker: https://github.com/username/my_awesome_package/issues
documentation: https://pub.dev/documentation/my_awesome_package/latest/

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
  mocktail: ^1.0.0

# Topics for discoverability
topics:
  - widgets
  - ui
  - animation

# Screenshots (optional but recommended)
screenshots:
  - description: 'Demo of the widget'
    path: screenshots/demo.png

# Funding links (optional)
funding:
  - https://github.com/sponsors/username
```

### Step 3: API Design Principles

```dart
// ════════════════════════════════════════════════════════════════════════════
// PRINCIPLE 1: Clean Public API
// ════════════════════════════════════════════════════════════════════════════

// lib/my_package.dart - Only export what users need
library my_package;

// Public API
export 'src/widgets/fancy_button.dart' show FancyButton, FancyButtonStyle;
export 'src/utils/helpers.dart' show formatDuration;

// DON'T export internal implementation
// export 'src/internal/private_utils.dart'; // ❌

// ════════════════════════════════════════════════════════════════════════════
// PRINCIPLE 2: Sensible Defaults + Full Customization
// ════════════════════════════════════════════════════════════════════════════

class FancyButton extends StatelessWidget {
  const FancyButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.style,                    // Optional, has default
    this.isLoading = false,        // Has default
    this.loadingWidget,            // Optional custom widget
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

// ════════════════════════════════════════════════════════════════════════════
// PRINCIPLE 3: Builder Pattern for Complex Configuration
// ════════════════════════════════════════════════════════════════════════════

class ChartWidget extends StatelessWidget {
  const ChartWidget({
    required this.data,
    this.builder,              // Custom rendering
    this.onTap,                // Callbacks
    this.config = const ChartConfig(),
  });

  final List<DataPoint> data;
  final Widget Function(BuildContext, DataPoint)? builder;
  final void Function(DataPoint)? onTap;
  final ChartConfig config;
}
```

### Step 4: Platform Channels (Native Plugins)

```dart
// lib/src/my_plugin_platform_interface.dart
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

abstract class MyPluginPlatform extends PlatformInterface {
  MyPluginPlatform() : super(token: _token);
  static final Object _token = Object();
  
  static MyPluginPlatform _instance = MethodChannelMyPlugin();
  static MyPluginPlatform get instance => _instance;
  static set instance(MyPluginPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion();
}

// lib/src/my_plugin_method_channel.dart
class MethodChannelMyPlugin extends MyPluginPlatform {
  final _channel = const MethodChannel('my_plugin');

  @override
  Future<String?> getPlatformVersion() async {
    return _channel.invokeMethod<String>('getPlatformVersion');
  }
}

// android/src/main/kotlin/.../MyPlugin.kt
class MyPlugin: FlutterPlugin, MethodCallHandler {
  override fun onMethodCall(call: MethodCall, result: Result) {
    when (call.method) {
      "getPlatformVersion" -> result.success("Android ${android.os.Build.VERSION.RELEASE}")
      else -> result.notImplemented()
    }
  }
}
```

### Step 5: Publishing to pub.dev

```bash
# 1. Validate package
flutter pub publish --dry-run

# 2. Check score locally
pana .

# 3. Run all tests
flutter test

# 4. Update CHANGELOG.md
# ## [1.0.0] - 2025-01-30
# - Initial release
# - Added FancyButton widget
# - Added theming support

# 5. Publish
flutter pub publish

# 6. Create GitHub release
git tag v1.0.0
git push origin v1.0.0
```

## Best Practices

### ✅ Do This

- ✅ Include comprehensive example app
- ✅ Write dartdoc for all public APIs
- ✅ Follow semantic versioning
- ✅ Keep breaking changes minimal
- ✅ Support latest 2-3 Flutter versions

### ❌ Avoid This

- ❌ Don't expose internal implementation
- ❌ Don't have too many dependencies
- ❌ Don't skip tests
- ❌ Don't ignore pub.dev score

## Related Skills

- `@senior-flutter-developer` - Flutter development
- `@open-source-maintainer` - OSS maintenance

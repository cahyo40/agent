---
description: Setup error monitoring, crash reporting, performance profiling, dan analytics untuk production Flutter app.
---
# 12 - Performance & Monitoring (Sentry + Crashlytics + DevTools)

**Goal:** Setup error monitoring, crash reporting, performance profiling, dan analytics untuk production Flutter app.

**Output:** `sdlc/flutter-riverpod/12-performance-monitoring/`

**Time Estimate:** 2-3 jam

---

## Install

```yaml
dependencies:
  firebase_crashlytics: ^4.3.0
  firebase_performance: ^0.10.0+8
  sentry_flutter: ^8.9.0
```

---

## Deliverables

### 1. Sentry Setup (Error Monitoring)

**File:** `lib/bootstrap/bootstrap.dart` (update)

```dart
import 'package:sentry_flutter/sentry_flutter.dart';

Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SentryFlutter.init(
    (options) {
      options
        ..dsn = const String.fromEnvironment('SENTRY_DSN')
        ..environment = const String.fromEnvironment(
          'APP_ENV',
          defaultValue: 'development',
        )
        ..tracesSampleRate = 0.2 // 20% performance traces
        ..profilesSampleRate = 0.1 // 10% profiling
        ..attachScreenshot = true
        ..attachViewHierarchy = true;
    },
    appRunner: () => runApp(
      ProviderScope(child: const MyApp()),
    ),
  );
}
```

---

### 2. Error Handler (Global)

**File:** `lib/core/error/error_handler.dart`

```dart
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

/// Global error handler — setup di bootstrap.
class ErrorHandler {
  static void initialize() {
    // Flutter framework errors
    FlutterError.onError = (details) {
      FlutterError.presentError(details);
      FirebaseCrashlytics.instance.recordFlutterFatalError(details);
      Sentry.captureException(
        details.exception,
        stackTrace: details.stack,
      );
    };

    // Async errors not caught by Flutter
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      Sentry.captureException(error, stackTrace: stack);
      return true;
    };
  }

  /// Report non-fatal error.
  static Future<void> report(
    Object error,
    StackTrace stackTrace, {
    Map<String, dynamic>? extra,
  }) async {
    debugPrint('Error: $error\n$stackTrace');

    if (kReleaseMode) {
      await Future.wait([
        FirebaseCrashlytics.instance.recordError(error, stackTrace),
        Sentry.captureException(
          error,
          stackTrace: stackTrace,
          withScope: (scope) {
            extra?.forEach((key, value) {
              scope.setExtra(key, value);
            });
          },
        ),
      ]);
    }
  }

  /// Set user context (setelah login).
  static Future<void> setUser({
    required String userId,
    String? email,
  }) async {
    await FirebaseCrashlytics.instance.setUserIdentifier(userId);
    await Sentry.configureScope((scope) {
      scope.setUser(SentryUser(id: userId, email: email));
    });
  }

  /// Clear user context (setelah logout).
  static Future<void> clearUser() async {
    await FirebaseCrashlytics.instance.setUserIdentifier('');
    await Sentry.configureScope((scope) => scope.setUser(null));
  }
}
```

---

### 3. Performance Tracing

**File:** `lib/core/performance/performance_service.dart`

```dart
import 'package:firebase_performance/firebase_performance.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

/// Performance monitoring untuk critical operations.
class PerformanceService {
  static final _perf = FirebasePerformance.instance;

  /// Trace a custom operation.
  static Future<T> trace<T>(
    String name,
    Future<T> Function() operation, {
    Map<String, String>? attributes,
  }) async {
    final trace = _perf.newTrace(name);
    attributes?.forEach(trace.putAttribute);
    await trace.start();

    final sentrySpan = Sentry.getSpan()?.startChild(name);

    try {
      final result = await operation();
      sentrySpan?.status = const SpanStatus.ok();
      return result;
    } catch (e) {
      sentrySpan?.status = const SpanStatus.internalError();
      rethrow;
    } finally {
      await trace.stop();
      await sentrySpan?.finish();
    }
  }

  /// Trace HTTP request (custom metric).
  static HttpMetric httpMetric(String url, HttpMethod method) =>
      _perf.newHttpMetric(url, method);
}
```

**Usage:**

```dart
// Trace expensive operation
final products = await PerformanceService.trace(
  'fetch_products',
  () => repository.getProducts(),
  attributes: {'page': '1'},
);
```

---

### 4. Crashlytics Integration

**File:** `lib/core/error/crashlytics_service.dart`

```dart
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'crashlytics_service.g.dart';

@Riverpod(keepAlive: true)
CrashlyticsService crashlyticsService(Ref ref) => const CrashlyticsService();

class CrashlyticsService {
  const CrashlyticsService();

  final _crashlytics = FirebaseCrashlytics.instance;

  Future<void> initialize() async {
    // Enable in release mode only
    await _crashlytics.setCrashlyticsCollectionEnabled(kReleaseMode);
  }

  Future<void> log(String message) => _crashlytics.log(message);

  Future<void> setCustomKey(String key, Object value) =>
      _crashlytics.setCustomKey(key, value);

  Future<void> recordError(
    Object error,
    StackTrace? stackTrace, {
    bool fatal = false,
  }) =>
      _crashlytics.recordError(error, stackTrace, fatal: fatal);
}
```

---

### 5. App Performance Widget (DevTools)

**File:** `lib/core/performance/performance_overlay_widget.dart`

```dart
import 'package:flutter/material.dart';

/// Show performance overlay in debug mode.
class PerformanceOverlayWrapper extends StatelessWidget {
  const PerformanceOverlayWrapper({
    super.key,
    required this.child,
    this.showOverlay = false,
  });

  final Widget child;
  final bool showOverlay;

  @override
  Widget build(BuildContext context) {
    if (!showOverlay) return child;
    return Stack(
      children: [
        child,
        const PerformanceOverlay.allEnabled(),
      ],
    );
  }
}
```

---

### 6. Production Checklist

```markdown
## Pre-Release Performance Checklist

### Build
- [ ] `flutter build apk --release --obfuscate --split-debug-info=build/debug-info`
- [ ] `flutter build ios --release --obfuscate --split-debug-info=build/debug-info`
- [ ] App size < 30MB (Android), < 50MB (iOS)

### Performance
- [ ] Startup time < 2 detik (cold start)
- [ ] Scroll 60fps (tidak ada jank)
- [ ] Memory usage < 150MB normal usage
- [ ] No memory leaks (DevTools Memory tab)

### Error Monitoring
- [ ] Sentry DSN configured di CI/CD
- [ ] Firebase Crashlytics enabled
- [ ] Test crash: `FirebaseCrashlytics.instance.crash()`
- [ ] Error handler initialized di bootstrap

### Analytics
- [ ] User ID set setelah login
- [ ] User ID cleared setelah logout
- [ ] Critical flows traced (login, checkout, etc.)

### Security
- [ ] ProGuard/R8 rules configured
- [ ] API keys tidak hardcoded
- [ ] Certificate pinning (jika diperlukan)
- [ ] Root detection (jika diperlukan)
```

---

### 7. GitHub Actions: Build & Upload Debug Symbols

**File:** `.github/workflows/release.yml` (tambahkan)

```yaml
- name: Upload Sentry debug symbols
  run: |
    dart pub global activate sentry_dart_plugin
    dart run sentry_dart_plugin
  env:
    SENTRY_AUTH_TOKEN: ${{ secrets.SENTRY_AUTH_TOKEN }}
    SENTRY_ORG: ${{ secrets.SENTRY_ORG }}
    SENTRY_PROJECT: ${{ secrets.SENTRY_PROJECT }}

- name: Upload Crashlytics mapping file
  run: |
    ./gradlew app:uploadCrashlyticsMappingFileRelease
  working-directory: android
```

---

## Success Criteria
- Sentry menangkap unhandled exceptions di production
- Firebase Crashlytics menampilkan crash reports
- Performance traces tampil di Firebase Console
- User context (ID, email) ter-set setelah login
- Debug symbols ter-upload ke Sentry untuk readable stack traces

## Selesai! 🎉
Semua 12 workflows flutter-riverpod sudah lengkap.

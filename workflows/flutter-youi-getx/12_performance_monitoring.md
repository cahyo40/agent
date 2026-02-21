---
description: Setup error monitoring, crash reporting, dan performance profiling untuk production GetX app.
---
# 12 - Performance & Monitoring (Sentry + Crashlytics)

**Goal:** Setup error monitoring, crash reporting, dan performance profiling untuk production GetX app.

**Output:** `sdlc/flutter-youi/12-performance-monitoring/`

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

### 1. Sentry Setup

**File:** `lib/main.dart` (update)

```dart
import 'package:sentry_flutter/sentry_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SentryFlutter.init(
    (options) {
      options
        ..dsn = const String.fromEnvironment('SENTRY_DSN')
        ..environment = const String.fromEnvironment(
          'APP_ENV',
          defaultValue: 'development',
        )
        ..tracesSampleRate = 0.2
        ..profilesSampleRate = 0.1
        ..attachScreenshot = true;
    },
    appRunner: () async {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      await GetStorage.init();
      await Get.putAsync(() => NotificationService().init());
      await Get.putAsync(() => StorageService().init());
      await Get.putAsync(() => ConnectivityService().init());
      runApp(const MyApp());
    },
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

class ErrorHandler {
  static void initialize() {
    FlutterError.onError = (details) {
      FlutterError.presentError(details);
      FirebaseCrashlytics.instance.recordFlutterFatalError(details);
      Sentry.captureException(details.exception, stackTrace: details.stack);
    };

    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      Sentry.captureException(error, stackTrace: stack);
      return true;
    };
  }

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
            extra?.forEach((key, value) => scope.setExtra(key, value));
          },
        ),
      ]);
    }
  }

  static Future<void> setUser({required String userId, String? email}) async {
    await FirebaseCrashlytics.instance.setUserIdentifier(userId);
    await Sentry.configureScope(
      (scope) => scope.setUser(SentryUser(id: userId, email: email)),
    );
  }

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

class PerformanceService {
  static final _perf = FirebasePerformance.instance;

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
}
```

**Usage dalam GetX controller:**

```dart
@override
Future<void> onInit() async {
  super.onInit();
  await PerformanceService.trace(
    'fetch_products',
    () => _fetchPage(1),
  );
}
```

---

### 4. GetX Error Integration

```dart
// Dalam GetxController — report errors automatically
Future<void> _fetchPage(int page) async {
  try {
    final result = await getProductsUsecase(page: page);
    result.fold(
      (failure) {
        change(null, status: RxStatus.error(failure.message));
        ErrorHandler.report(failure, StackTrace.current);
      },
      (data) => change(data, status: RxStatus.success()),
    );
  } catch (e, stack) {
    await ErrorHandler.report(e, stack, extra: {'page': page.toString()});
    change(null, status: RxStatus.error('Unexpected error'));
  }
}
```

---

### 5. Pre-Release Checklist

```markdown
## Pre-Release Checklist

### Build
- [ ] `flutter build apk --release --obfuscate --split-debug-info=build/debug-info`
- [ ] App size < 30MB (Android), < 50MB (iOS)

### Performance
- [ ] Startup time < 2 detik (cold start)
- [ ] Scroll 60fps (tidak ada jank)
- [ ] Memory usage < 150MB normal usage

### Error Monitoring
- [ ] Sentry DSN configured di CI/CD
- [ ] Firebase Crashlytics enabled
- [ ] Test crash: `FirebaseCrashlytics.instance.crash()`
- [ ] ErrorHandler.initialize() dipanggil di main()
- [ ] User ID set setelah login, cleared setelah logout

### GetX Specific
- [ ] Semua controller di-dispose via Bindings
- [ ] Tidak ada memory leak (DevTools Memory tab)
- [ ] GetStorage.init() dipanggil sebelum runApp()
- [ ] Workers (debounce/ever) tidak menyebabkan memory leak
```

---

## Success Criteria
- Sentry menangkap unhandled exceptions di production
- Firebase Crashlytics menampilkan crash reports
- Performance traces tampil di Firebase Console
- User context (ID, email) ter-set setelah login
- GetX controller errors ter-report ke Sentry

## Selesai! 🎉
Semua 12 workflows flutter-youi sudah lengkap.

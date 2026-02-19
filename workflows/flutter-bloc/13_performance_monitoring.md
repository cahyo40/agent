---
description: Setup error monitoring, crash reporting, dan performance profiling untuk production BLoC app.
---
# 13 - Performance & Monitoring (Sentry + Crashlytics)

**Goal:** Setup error monitoring, crash reporting, dan performance profiling untuk production BLoC app.

**Output:** `sdlc/flutter-bloc/13-performance-monitoring/`

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
        ..tracesSampleRate = 0.2
        ..profilesSampleRate = 0.1
        ..attachScreenshot = true;
    },
    appRunner: () async {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      configureDependencies();

      final notificationService = getIt<NotificationService>();
      await notificationService.initialize(
        onNotificationTap: (payload) {
          PendingNotificationPayload.value = payload;
        },
      );

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
import 'package:injectable/injectable.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

@lazySingleton
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
import 'package:injectable/injectable.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

@lazySingleton
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

---

### 4. BLoC Error Integration

```dart
// Dalam Bloc event handler — report errors automatically
Future<void> _onFetch(
  FetchProducts event,
  Emitter<ProductListState> emit,
) async {
  emit(state.copyWith(status: ProductListStatus.loading));

  try {
    final result = await PerformanceService.trace(
      'fetch_products',
      () => getProducts(GetProductsParams(page: 1)),
    );

    result.fold(
      (failure) {
        emit(state.copyWith(
          status: ProductListStatus.failure,
          errorMessage: failure.message,
        ));
        ErrorHandler.report(failure, StackTrace.current);
      },
      (products) => emit(state.copyWith(
        status: ProductListStatus.success,
        products: products,
      )),
    );
  } catch (e, stack) {
    await ErrorHandler.report(e, stack);
    emit(state.copyWith(
      status: ProductListStatus.failure,
      errorMessage: 'Unexpected error',
    ));
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
- [ ] ErrorHandler.initialize() dipanggil di bootstrap
- [ ] User ID set setelah login, cleared setelah logout

### BLoC Specific
- [ ] Semua StreamSubscription di-cancel di `close()`
- [ ] Tidak ada `emit()` setelah Bloc di-close
- [ ] `bloc_test` coverage >= 80%
- [ ] `BlocObserver` configured untuk logging di development
```

---

### 6. BlocObserver (Development Logging)

**File:** `lib/core/bloc/app_bloc_observer.dart`

```dart
import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';

class AppBlocObserver extends BlocObserver {
  @override
  void onEvent(Bloc bloc, Object? event) {
    super.onEvent(bloc, event);
    if (kDebugMode) debugPrint('[BLoC] ${bloc.runtimeType} Event: $event');
  }

  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    super.onError(bloc, error, stackTrace);
    ErrorHandler.report(error, stackTrace, extra: {
      'bloc': bloc.runtimeType.toString(),
    });
  }

  @override
  void onChange(BlocBase bloc, Change change) {
    super.onChange(bloc, change);
    if (kDebugMode) {
      debugPrint('[BLoC] ${bloc.runtimeType} State: ${change.nextState}');
    }
  }
}
```

**Register di bootstrap:**

```dart
Bloc.observer = AppBlocObserver();
```

---

## Success Criteria
- Sentry menangkap unhandled exceptions di production
- Firebase Crashlytics menampilkan crash reports
- Performance traces tampil di Firebase Console
- User context (ID, email) ter-set setelah login
- `AppBlocObserver` log semua events dan errors di development

## Selesai! 🎉
Semua 13 workflows flutter-bloc sudah lengkap.

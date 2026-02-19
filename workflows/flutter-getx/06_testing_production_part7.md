---
description: Comprehensive testing (unit, widget, integration) dan production preparation untuk Flutter app dengan GetX state mana... (Part 7/8)
---
# Workflow: Testing & Production (GetX) (Part 7/8)

> **Navigation:** This workflow is split into 8 parts.

## Code Quality Checklist

- [ ] Semua test pass (`flutter test`)
- [ ] Coverage >= 80% (`flutter test --coverage`)
- [ ] Tidak ada analyzer warnings (`flutter analyze`)
- [ ] Code terformat (`dart format .`)
- [ ] Tidak ada TODO/FIXME yang kritis
- [ ] Tidak ada hardcoded strings (gunakan constants/l10n)
- [ ] Tidak ada hardcoded API URLs (gunakan dart-define / env)
- [ ] Semua unused imports sudah dihapus
- [ ] Tidak ada print() statement (gunakan proper logging)
- [ ] Error handling sudah comprehensive
```

#### 6.2 GetX-Specific Checks

```markdown

## GetX Specific Checklist

- [ ] Semua controller punya proper onClose() untuk cleanup
- [ ] Workers (debounce, interval, ever) di-dispose di onClose()
- [ ] Tidak ada memory leak dari stream subscriptions
- [ ] Get.reset() tidak dipanggil di production code (hanya testing)
- [ ] SmartManagement setting sudah sesuai kebutuhan
- [ ] Binding terdaftar untuk setiap page yang perlu controller
- [ ] GetX translations sudah complete untuk semua locale
- [ ] Route middleware sudah setup untuk protected routes
- [ ] Tidak ada circular dependency di Get.put/Get.find
- [ ] Obx/GetBuilder digunakan dengan tepat (bukan berlebihan)
```

#### 6.3 Security

```markdown

## Security Checklist

- [ ] API keys tidak di-commit ke repository
- [ ] Sensitive data dienkripsi di local storage
- [ ] Certificate pinning diaktifkan
- [ ] Obfuscation enabled di release build
- [ ] ProGuard/R8 rules configured (Android)
- [ ] No debug logging in release mode
- [ ] JWT token refresh mechanism works
- [ ] Input validation di semua form
- [ ] SQL injection prevention (parameterized queries)
- [ ] XSS prevention (sanitize HTML input)
```

#### 6.4 App Configuration

```dart
// lib/core/config/app_config.dart

/// Environment configuration menggunakan dart-define
/// Build command: flutter build apk --dart-define=ENV=production
class AppConfig {
  static const String environment = String.fromEnvironment(
    'ENV',
    defaultValue: 'development',
  );

  static const String apiUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: 'http://localhost:3000/api',
  );

  static const String sentryDsn = String.fromEnvironment(
    'SENTRY_DSN',
    defaultValue: '',
  );

  static bool get isProduction => environment == 'production';
  static bool get isDevelopment => environment == 'development';
  static bool get isStaging => environment == 'staging';
}
```

#### 6.5 Error Monitoring & Crash Reporting

```dart
// lib/main.dart
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Setup error handling
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    if (kReleaseMode) {
      Sentry.captureException(
        details.exception,
        stackTrace: details.stack,
      );
    }
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    if (kReleaseMode) {
      Sentry.captureException(error, stackTrace: stack);
    }
    return true;
  };

  await SentryFlutter.init(
    (options) {
      options.dsn = AppConfig.sentryDsn;
      options.environment = AppConfig.environment;
      options.tracesSampleRate = AppConfig.isProduction ? 0.2 : 1.0;
    },
    appRunner: () => runApp(const MyApp()),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'My App',
      initialBinding: InitialBinding(),
      initialRoute: AppRoutes.splash,
      getPages: AppPages.routes,
      navigatorObservers: [
        SentryNavigatorObserver(),
      ],
    );
  }
}
```

#### 6.6 Release Build Configuration

```markdown

## Build Commands

### Android
```bash
# APK
flutter build apk --release \
  --obfuscate \
  --split-debug-info=build/debug-info \
  --dart-define=ENV=production \
  --dart-define=API_URL=https://api.example.com \
  --dart-define=SENTRY_DSN=https://xxx@sentry.io/xxx

# App Bundle (untuk Play Store)
flutter build appbundle --release \
  --obfuscate \
  --split-debug-info=build/debug-info \
  --dart-define=ENV=production \
  --dart-define=API_URL=https://api.example.com
```

### iOS
```bash
flutter build ipa --release \
  --obfuscate \
  --split-debug-info=build/debug-info \
  --dart-define=ENV=production \
  --dart-define=API_URL=https://api.example.com \
  --export-options-plist=ios/ExportOptions.plist
```
```

---

### 7. Fastlane Configuration

Fastlane configuration bersifat framework-agnostic - sama untuk GetX maupun Riverpod.

#### 7.1 Android Fastlane

```ruby
# android/fastlane/Fastfile
default_platform(:android)

platform :android do
  desc "Run unit tests"
  lane :test do
    Dir.chdir("..") do
      sh("cd .. && flutter test --coverage")
    end
  end

  desc "Build release APK"
  lane :build_apk do
    Dir.chdir("..") do
      sh("cd .. && flutter build apk --release " \
         "--obfuscate --split-debug-info=build/debug-info " \
         "--dart-define=ENV=production")
    end
  end

  desc "Build release AAB"
  lane :build_aab do
    Dir.chdir("..") do
      sh("cd .. && flutter build appbundle --release " \
         "--obfuscate --split-debug-info=build/debug-info " \
         "--dart-define=ENV=production")
    end
  end

  desc "Deploy ke Internal Testing (Play Store)"
  lane :deploy_internal do
    build_aab
    upload_to_play_store(
      track: 'internal',
      aab: '../build/app/outputs/bundle/release/app-release.aab',
      json_key: ENV['PLAY_STORE_JSON_KEY_PATH'],
      skip_upload_metadata: true,
      skip_upload_changelogs: false,
      skip_upload_images: true,
      skip_upload_screenshots: true,
    )
  end

  desc "Promote dari Internal ke Production"
  lane :promote_to_production do
    upload_to_play_store(
      track: 'internal',
      track_promote_to: 'production',
      json_key: ENV['PLAY_STORE_JSON_KEY_PATH'],
      skip_upload_aab: true,
      skip_upload_metadata: true,
      skip_upload_changelogs: false,
    )
  end

  desc "Deploy ke Play Store Production"
  lane :deploy do
    build_aab
    upload_to_play_store(
      track: 'production',
      aab: '../build/app/outputs/bundle/release/app-release.aab',
      json_key: ENV['PLAY_STORE_JSON_KEY_PATH'],
      rollout: '0.1', # 10% staged rollout
    )
  end
end
```

#### 7.2 iOS Fastlane

```ruby
# ios/fastlane/Fastfile
default_platform(:ios)

platform :ios do
  desc "Sync certificates menggunakan Match"
  lane :sync_certs do
    match(
      type: "appstore",
      readonly: true,
      app_identifier: "com.example.app",
    )
  end

  desc "Build release IPA"
  lane :build do
    sync_certs

    Dir.chdir("..") do
      sh("cd .. && flutter build ipa --release " \
         "--obfuscate --split-debug-info=build/debug-info " \
         "--dart-define=ENV=production " \
         "--export-options-plist=ios/ExportOptions.plist")
    end
  end

  desc "Deploy ke TestFlight"
  lane :deploy_testflight do
    build
    upload_to_testflight(
      ipa: '../build/ios/ipa/app.ipa',
      skip_waiting_for_build_processing: true,
    )
  end

  desc "Deploy ke App Store"
  lane :deploy do
    build
    upload_to_app_store(
      ipa: '../build/ios/ipa/app.ipa',
      submit_for_review: false,
      automatic_release: false,
      force: true,
      precheck_include_in_app_purchases: false,
    )
  end

  desc "Increment build number"
  lane :bump_build do
    increment_build_number(
      build_number: ENV['BUILD_NUMBER'] || latest_testflight_build_number + 1,
    )
  end
end
```

#### 7.3 Fastlane Appfile

```ruby
# android/fastlane/Appfile
json_key_file(ENV['PLAY_STORE_JSON_KEY_PATH'])
package_name("com.example.app")
```

```ruby
# ios/fastlane/Appfile
app_identifier("com.example.app")
apple_id(ENV['APPLE_ID'])
team_id(ENV['TEAM_ID'])
itc_team_id(ENV['ITC_TEAM_ID'])
```

#### 7.4 Fastlane Matchfile

```ruby
# ios/fastlane/Matchfile
git_url(ENV['MATCH_GIT_URL'])
storage_mode("git")
type("appstore")
app_identifier("com.example.app")
username(ENV['APPLE_ID'])
```

---


## Workflow Steps

### Step 1: Setup Testing Environment

1. Tambahkan testing dependencies ke `pubspec.yaml`
2. Buat folder structure untuk test files
3. Buat test helpers dan mock classes
4. Setup test data factories

```bash
# Buat folder structure
mkdir -p test/{unit/{controllers,services,repositories,bindings},widget/{views,components,navigation},helpers}
mkdir -p integration_test
```

### Step 2: Write Unit Tests

1. Buat mock classes untuk semua repositories dan services
2. Tulis test untuk setiap `GetxController`
3. Tulis test untuk service layer
4. Tulis test untuk GetX bindings
5. Target coverage minimal 80%

```bash
# Jalankan unit tests
flutter test

# Jalankan dengan coverage
flutter test --coverage

# Generate HTML coverage report
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

### Step 3: Write Widget Tests

1. Buat widget test helpers dengan `GetMaterialApp` wrapper
2. Tulis test untuk setiap view/page
3. Tulis test untuk reusable components
4. Test navigation flows

```bash
# Jalankan widget tests saja
flutter test test/widget/

# Jalankan specific test file
flutter test test/widget/views/product_list_view_test.dart
```

### Step 4: Write Integration Tests

1. Setup integration test environment
2. Tulis end-to-end test untuk critical flows
3. Test dengan mock API client jika diperlukan

```bash
# Jalankan integration tests di device/emulator
flutter test integration_test/

# Jalankan di specific device
flutter test integration_test/ -d <device_id>
```

### Step 5: Setup CI/CD

1. Buat GitHub Actions workflow files
2. Configure secrets di GitHub repository settings
3. Setup Fastlane untuk automated deployment
4. Test pipeline dengan push ke branch

**GitHub Secrets yang diperlukan:**
- `CODECOV_TOKEN` - Token untuk upload coverage
- `KEYSTORE_BASE64` - Android release keystore (base64)
- `KEYSTORE_PASSWORD` - Password keystore
- `KEY_ALIAS` - Key alias
- `KEY_PASSWORD` - Key password
- `PLAY_STORE_JSON_KEY` - Google Play service account JSON
- `APP_STORE_CONNECT_API_KEY` - App Store Connect API key
- `MATCH_PASSWORD` - Password untuk Fastlane Match
- `API_URL` - Production API URL
- `SENTRY_DSN` - Sentry DSN untuk error monitoring

### Step 6: Performance Optimization

1. Profile app dengan Flutter DevTools
2. Optimize gambar dan assets
3. Implement lazy loading
4. Reduce rebuild frequency (GetBuilder vs Obx)
5. Analyze dan reduce APK/IPA size

### Step 7: Production Preparation

1. Complete production checklist
2. Setup error monitoring (Sentry / Crashlytics)
3. Configure app signing
4. Prepare store listing assets
5. Final testing on real devices

---


## Success Criteria

| Kriteria | Target | Cara Ukur |
|---|---|---|
| Unit test coverage | >= 80% | `flutter test --coverage` |
| Widget test coverage | >= 70% | Coverage report per folder |
| Semua tests pass | 100% green | `flutter test` exit code 0 |
| No analyzer issues | 0 warnings | `flutter analyze` |
| CI pipeline pass | Green on every PR | GitHub Actions status |
| Build berhasil | APK + IPA | Artifacts di CI |
| APK size | < 25MB | `flutter build apk --analyze-size` |
| Startup time | < 3 detik | Flutter DevTools |
| Frame rate | >= 55 fps | Performance overlay |
| Crash rate | < 1% | Sentry/Crashlytics |

---


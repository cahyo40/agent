# Flutter CI/CD

## Overview

Automated build, test, and deployment pipelines using GitHub Actions, Codemagic, and Fastlane.

---

## Pipeline Stages

```text
PUSH → BUILD → TEST → DEPLOY
 1. Code checkout
 2. Dependencies install
 3. Static analysis
 4. Unit/Widget tests
 5. Build APK/IPA
 6. Deploy to stores
```

---

## GitHub Actions

```yaml
# .github/workflows/flutter-ci.yml
name: Flutter CI

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

jobs:
  analyze-and-test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.19.0'
          channel: 'stable'
          cache: true
      
      - name: Install dependencies
        run: flutter pub get
      
      - name: Analyze code
        run: flutter analyze --fatal-infos
      
      - name: Check formatting
        run: dart format --set-exit-if-changed .
      
      - name: Run tests
        run: flutter test --coverage

  build-android:
    needs: analyze-and-test
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.19.0'
          cache: true
      - uses: actions/setup-java@v4
        with:
          distribution: 'zulu'
          java-version: '17'
      - run: flutter build apk --release
      - uses: actions/upload-artifact@v4
        with:
          name: release-apk
          path: build/app/outputs/flutter-apk/app-release.apk

  build-ios:
    needs: analyze-and-test
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.19.0'
          cache: true
      - run: flutter build ios --release --no-codesign
```

---

## Fastlane (Android)

```ruby
# android/fastlane/Fastfile
platform :android do
  lane :internal do
    sh("cd ../.. && flutter build appbundle --release")
    upload_to_play_store(
      track: 'internal',
      aab: '../build/app/outputs/bundle/release/app-release.aab',
      skip_upload_metadata: true,
    )
  end

  lane :production do
    sh("cd ../.. && flutter build appbundle --release")
    upload_to_play_store(track: 'production', aab: '...')
  end
end
```

---

## Fastlane (iOS)

```ruby
# ios/fastlane/Fastfile
platform :ios do
  lane :beta do
    setup_ci if ENV['CI']
    match(type: "appstore", readonly: true)
    sh("cd ../.. && flutter build ipa --release --export-options-plist=ios/ExportOptions.plist")
    upload_to_testflight(
      ipa: "../build/ios/ipa/Runner.ipa",
      skip_waiting_for_build_processing: true
    )
  end
end
```

---

## Environment Configuration

```dart
enum Environment { dev, staging, prod }

class EnvConfig {
  static late Environment environment;
  static late String apiUrl;
  
  static void initialize(Environment env) {
    environment = env;
    switch (env) {
      case Environment.dev:
        apiUrl = 'https://dev-api.example.com';
        break;
      case Environment.prod:
        apiUrl = 'https://api.example.com';
        break;
    }
  }
}

// lib/main_dev.dart
void main() {
  EnvConfig.initialize(Environment.dev);
  runApp(const MyApp());
}
```

```bash
flutter build apk --release --target=lib/main_dev.dart
flutter build apk --release --target=lib/main_prod.dart
```

---

## Best Practices

### ✅ Do This

- ✅ Run tests before building
- ✅ Use semantic versioning
- ✅ Cache dependencies
- ✅ Use environment-specific configs
- ✅ Store secrets securely

### ❌ Avoid This

- ❌ Don't commit signing keys
- ❌ Don't skip code analysis
- ❌ Don't hardcode credentials

---
name: flutter-ci-cd
description: "Expert Flutter CI/CD including GitHub Actions, Codemagic, Fastlane, automated testing, and app distribution"
---

# Flutter CI/CD

## Overview

This skill helps you set up automated build, test, and deployment pipelines for Flutter applications.

## When to Use This Skill

- Use when setting up CI/CD pipelines
- Use when automating app builds
- Use when configuring automated testing
- Use when setting up app distribution

## How It Works

### Step 1: CI/CD Pipeline Overview

```
FLUTTER CI/CD PIPELINE
┌─────────────────────────────────────────────────────────────────┐
│                                                                 │
│  ┌─────────┐    ┌─────────┐    ┌─────────┐    ┌─────────┐     │
│  │  PUSH   │───>│  BUILD  │───>│  TEST   │───>│ DEPLOY  │     │
│  └─────────┘    └─────────┘    └─────────┘    └─────────┘     │
│                                                                 │
│  Stages:                                                        │
│  1. Code checkout                                              │
│  2. Dependencies install                                       │
│  3. Static analysis (lint)                                     │
│  4. Unit tests                                                 │
│  5. Widget tests                                               │
│  6. Build APK/IPA                                              │
│  7. Integration tests (optional)                               │
│  8. Deploy to stores/testers                                   │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### Step 2: GitHub Actions

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
      
      - name: Upload coverage
        uses: codecov/codecov-action@v3
        with:
          file: coverage/lcov.info

  build-android:
    needs: analyze-and-test
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.19.0'
          cache: true
      
      - name: Setup Java
        uses: actions/setup-java@v4
        with:
          distribution: 'zulu'
          java-version: '17'
      
      - name: Build APK
        run: flutter build apk --release
      
      - name: Upload APK
        uses: actions/upload-artifact@v4
        with:
          name: release-apk
          path: build/app/outputs/flutter-apk/app-release.apk

  build-ios:
    needs: analyze-and-test
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.19.0'
          cache: true
      
      - name: Build iOS
        run: flutter build ios --release --no-codesign
      
      - name: Upload iOS build
        uses: actions/upload-artifact@v4
        with:
          name: ios-build
          path: build/ios/iphoneos/Runner.app
```

### Step 3: Fastlane Integration

```ruby
# android/fastlane/Fastfile
default_platform(:android)

platform :android do
  desc "Deploy to Play Store Internal Track"
  lane :internal do
    # Build
    sh("cd ../.. && flutter build appbundle --release")
    
    # Upload to Play Store
    upload_to_play_store(
      track: 'internal',
      aab: '../build/app/outputs/bundle/release/app-release.aab',
      skip_upload_metadata: true,
      skip_upload_images: true,
      skip_upload_screenshots: true
    )
  end

  desc "Deploy to Play Store Production"
  lane :production do
    sh("cd ../.. && flutter build appbundle --release")
    
    upload_to_play_store(
      track: 'production',
      aab: '../build/app/outputs/bundle/release/app-release.aab'
    )
  end
end

# ios/fastlane/Fastfile
default_platform(:ios)

platform :ios do
  desc "Deploy to TestFlight"
  lane :beta do
    setup_ci if ENV['CI']
    
    match(type: "appstore", readonly: true)
    
    sh("cd ../.. && flutter build ipa --release --export-options-plist=ios/ExportOptions.plist")
    
    upload_to_testflight(
      ipa: "../build/ios/ipa/Runner.ipa",
      skip_waiting_for_build_processing: true
    )
  end

  desc "Deploy to App Store"
  lane :release do
    setup_ci if ENV['CI']
    match(type: "appstore", readonly: true)
    
    sh("cd ../.. && flutter build ipa --release --export-options-plist=ios/ExportOptions.plist")
    
    upload_to_app_store(
      ipa: "../build/ios/ipa/Runner.ipa",
      submit_for_review: true,
      automatic_release: false
    )
  end
end
```

### Step 4: Codemagic Configuration

```yaml
# codemagic.yaml
workflows:
  android-workflow:
    name: Android Build
    max_build_duration: 60
    environment:
      flutter: stable
      groups:
        - keystore_credentials
        - play_store_credentials
    triggering:
      events:
        - push
      branch_patterns:
        - pattern: 'main'
    scripts:
      - name: Get dependencies
        script: flutter pub get
      - name: Run tests
        script: flutter test
      - name: Build APK
        script: |
          flutter build apk --release
          flutter build appbundle --release
    artifacts:
      - build/**/outputs/**/*.apk
      - build/**/outputs/**/*.aab
    publishing:
      google_play:
        credentials: $GCLOUD_SERVICE_ACCOUNT_CREDENTIALS
        track: internal

  ios-workflow:
    name: iOS Build
    max_build_duration: 80
    environment:
      flutter: stable
      xcode: latest
      groups:
        - app_store_credentials
        - certificates
    integrations:
      app_store_connect: My ASC Key
    triggering:
      events:
        - push
      branch_patterns:
        - pattern: 'main'
    scripts:
      - name: Get dependencies
        script: flutter pub get
      - name: Install pods
        script: |
          cd ios && pod install
      - name: Build IPA
        script: |
          flutter build ipa --release \
            --export-options-plist=/Users/builder/export_options.plist
    artifacts:
      - build/ios/ipa/*.ipa
    publishing:
      app_store_connect:
        submit_to_testflight: true
```

### Step 5: Environment Configuration

```dart
// lib/core/config/env_config.dart
enum Environment { dev, staging, prod }

class EnvConfig {
  static late Environment environment;
  static late String apiUrl;
  static late String sentryDsn;
  
  static void initialize(Environment env) {
    environment = env;
    switch (env) {
      case Environment.dev:
        apiUrl = 'https://dev-api.example.com';
        sentryDsn = '';
        break;
      case Environment.staging:
        apiUrl = 'https://staging-api.example.com';
        sentryDsn = 'https://xxx@sentry.io/staging';
        break;
      case Environment.prod:
        apiUrl = 'https://api.example.com';
        sentryDsn = 'https://xxx@sentry.io/prod';
        break;
    }
  }
}

// Entry points
// lib/main_dev.dart
void main() {
  EnvConfig.initialize(Environment.dev);
  runApp(const MyApp());
}

// lib/main_prod.dart
void main() {
  EnvConfig.initialize(Environment.prod);
  runApp(const MyApp());
}
```

```bash
# Build commands
flutter build apk --release --target=lib/main_dev.dart
flutter build apk --release --target=lib/main_prod.dart
```

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
- ❌ Don't build without tests
- ❌ Don't hardcode credentials

## Related Skills

- `@senior-flutter-developer` - Flutter development
- `@app-store-publisher` - Store publishing
- `@senior-devops-engineer` - DevOps practices

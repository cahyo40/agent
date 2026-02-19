---
description: Comprehensive testing (unit, widget, integration) dan production preparation khusus Flutter BLoC: `bloc_test` package... (Part 5/8)
---
# Workflow: Testing & Production (Flutter BLoC) (Part 5/8)

> **Navigation:** This workflow is split into 8 parts.

## Deliverables

### 4. CI/CD Pipeline (GitHub Actions)

**Description:** Automated testing, building, dan deployment dengan GitHub Actions. **Perbedaan dari Riverpod:** BLoC project yang pakai `freezed` + `injectable` WAJIB menjalankan `build_runner` sebelum test dan build.

**Recommended Skills:** `senior-flutter-developer`, `github-actions-specialist`

**Instructions:**
1. **CI Workflow:**
   - Install dependencies
   - Run `build_runner` (CRITICAL — tanpa ini, generated files hilang)
   - Code analysis
   - Unit tests + widget tests
   - Build APK/IPA

2. **CD Workflow:**
   - Deploy ke stores via Fastlane
   - Tag-based release

3. **Secrets yang Dibutuhkan:**
   - `KEYSTORE_BASE64`, `KEYSTORE_PASSWORD`, `KEY_PASSWORD`, `KEY_ALIAS` (Android)
   - `P12_BASE64`, `P12_PASSWORD`, `MATCH_PASSWORD` (iOS)
   - `PLAY_STORE_SERVICE_ACCOUNT` (Google Play)
   - `APP_STORE_CONNECT_API_KEY` (App Store)

**Output Format:**

```yaml
# .github/workflows/flutter-ci.yml
name: Flutter CI (BLoC)

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

env:
  FLUTTER_VERSION: '3.24.0'
  JAVA_VERSION: '17'

jobs:
  analyze-and-test:
    name: Analyze & Test
    runs-on: ubuntu-latest
    timeout-minutes: 30
    steps:
      - uses: actions/checkout@v4

      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: ${{ env.FLUTTER_VERSION }}
          channel: 'stable'
          cache: true

      - name: Install dependencies
        run: flutter pub get

      # =============================================
      # CRITICAL STEP: build_runner
      # Ini yang BEDA dari Riverpod CI/CD!
      # BLoC + freezed + injectable butuh code generation
      # Tanpa step ini, semua *.g.dart dan *.freezed.dart hilang
      # =============================================
      - name: Run code generation (build_runner)
        run: dart run build_runner build --delete-conflicting-outputs

      - name: Analyze code
        run: flutter analyze --fatal-infos

      - name: Check formatting
        run: dart format --set-exit-if-changed .

      - name: Run unit and widget tests
        run: flutter test --coverage --reporter=github

      - name: Check minimum coverage
        uses: VeryGoodOpenSource/very_good_coverage@v3
        with:
          path: coverage/lcov.info
          min_coverage: 80

      - name: Upload coverage to Codecov
        uses: codecov/codecov-action@v4
        with:
          file: coverage/lcov.info
          token: ${{ secrets.CODECOV_TOKEN }}

  build-android:
    name: Build Android
    needs: analyze-and-test
    runs-on: ubuntu-latest
    timeout-minutes: 30
    steps:
      - uses: actions/checkout@v4

      - uses: actions/setup-java@v4
        with:
          distribution: 'zulu'
          java-version: ${{ env.JAVA_VERSION }}

      - uses: subosito/flutter-action@v2
        with:
          flutter-version: ${{ env.FLUTTER_VERSION }}
          cache: true

      - run: flutter pub get

      # build_runner juga dibutuhkan di build step!
      - name: Run code generation
        run: dart run build_runner build --delete-conflicting-outputs

      - name: Decode keystore
        run: echo "${{ secrets.KEYSTORE_BASE64 }}" | base64 -d > android/app/keystore.jks

      - name: Build APK (staging)
        if: github.ref == 'refs/heads/develop'
        run: |
          flutter build apk --release \
            --flavor staging \
            --dart-define=ENV=staging
        env:
          KEYSTORE_PASSWORD: ${{ secrets.KEYSTORE_PASSWORD }}
          KEY_PASSWORD: ${{ secrets.KEY_PASSWORD }}
          KEY_ALIAS: ${{ secrets.KEY_ALIAS }}

      - name: Build AAB (production)
        if: github.ref == 'refs/heads/main'
        run: |
          flutter build appbundle --release \
            --obfuscate \
            --split-debug-info=build/symbols \
            --dart-define=ENV=production
        env:
          KEYSTORE_PASSWORD: ${{ secrets.KEYSTORE_PASSWORD }}
          KEY_PASSWORD: ${{ secrets.KEY_PASSWORD }}
          KEY_ALIAS: ${{ secrets.KEY_ALIAS }}

      - uses: actions/upload-artifact@v4
        with:
          name: android-build
          path: |
            build/app/outputs/flutter-apk/app-staging-release.apk
            build/app/outputs/bundle/release/app-release.aab
          retention-days: 14

  build-ios:
    name: Build iOS
    needs: analyze-and-test
    runs-on: macos-latest
    timeout-minutes: 45
    steps:
      - uses: actions/checkout@v4

      - uses: subosito/flutter-action@v2
        with:
          flutter-version: ${{ env.FLUTTER_VERSION }}
          cache: true

      - run: flutter pub get

      # build_runner juga di sini
      - name: Run code generation
        run: dart run build_runner build --delete-conflicting-outputs

      - name: Install Apple certificates
        uses: apple-actions/import-codesign-certs@v2
        with:
          p12-file-base64: ${{ secrets.P12_BASE64 }}
          p12-password: ${{ secrets.P12_PASSWORD }}

      - name: Install provisioning profile
        uses: apple-actions/download-provisioning-profiles@v2
        with:
          bundle-id: com.example.myapp
          issuer-id: ${{ secrets.APP_STORE_CONNECT_ISSUER_ID }}
          api-key-id: ${{ secrets.APP_STORE_CONNECT_API_KEY_ID }}
          api-private-key: ${{ secrets.APP_STORE_CONNECT_API_PRIVATE_KEY }}

      - name: Build IPA
        run: |
          flutter build ipa --release \
            --obfuscate \
            --split-debug-info=build/symbols \
            --export-options-plist=ios/ExportOptions.plist

      - uses: actions/upload-artifact@v4
        with:
          name: ios-build
          path: build/ios/ipa/*.ipa
          retention-days: 14

  # =============================================
  # Integration Tests (opsional, run on schedule)
  # =============================================
  integration-test:
    name: Integration Tests
    needs: analyze-and-test
    runs-on: macos-latest
    if: github.event_name == 'push' && github.ref == 'refs/heads/main'
    timeout-minutes: 45
    steps:
      - uses: actions/checkout@v4

      - uses: subosito/flutter-action@v2
        with:
          flutter-version: ${{ env.FLUTTER_VERSION }}
          cache: true

      - run: flutter pub get
      - run: dart run build_runner build --delete-conflicting-outputs

      - name: Run integration tests
        uses: reactivecircus/android-emulator-runner@v2
        with:
          api-level: 34
          arch: x86_64
          profile: pixel_6
          script: flutter test integration_test/ --verbose

# =============================================
# .github/workflows/flutter-deploy.yml
# =============================================
name: Flutter Deploy (BLoC)

on:
  push:
    tags:
      - 'v*'

jobs:
  deploy-android:
    name: Deploy to Play Store
    runs-on: ubuntu-latest
    timeout-minutes: 30
    steps:
      - uses: actions/checkout@v4

      - uses: actions/setup-java@v4
        with:
          distribution: 'zulu'
          java-version: '17'

      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.24.0'
          cache: true

      - run: flutter pub get
      - run: dart run build_runner build --delete-conflicting-outputs

      - name: Decode keystore
        run: echo "${{ secrets.KEYSTORE_BASE64 }}" | base64 -d > android/app/keystore.jks

      - name: Build AAB
        run: |
          flutter build appbundle --release \
            --obfuscate \
            --split-debug-info=build/symbols
        env:
          KEYSTORE_PASSWORD: ${{ secrets.KEYSTORE_PASSWORD }}
          KEY_PASSWORD: ${{ secrets.KEY_PASSWORD }}
          KEY_ALIAS: ${{ secrets.KEY_ALIAS }}

      - name: Deploy to Play Store (internal track)
        uses: r0adkll/upload-google-play@v1
        with:
          serviceAccountJsonPlainText: ${{ secrets.PLAY_STORE_SERVICE_ACCOUNT }}
          packageName: com.example.myapp
          releaseFiles: build/app/outputs/bundle/release/app-release.aab
          track: internal
          status: completed

  deploy-ios:
    name: Deploy to TestFlight
    runs-on: macos-latest
    timeout-minutes: 45
    steps:
      - uses: actions/checkout@v4

      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.24.0'
          cache: true

      - run: flutter pub get
      - run: dart run build_runner build --delete-conflicting-outputs

      - name: Deploy to TestFlight via Fastlane
        run: |
          cd ios
          bundle install
          bundle exec fastlane beta
        env:
          MATCH_PASSWORD: ${{ secrets.MATCH_PASSWORD }}
          APP_STORE_CONNECT_API_KEY_ID: ${{ secrets.APP_STORE_CONNECT_API_KEY_ID }}
```

---

## Deliverables

### 5. Performance Optimization

**Description:** Performance optimization guide. Sebagian besar framework-agnostic (berlaku untuk semua Flutter), ditambah tips spesifik BLoC: `buildWhen`, `listenWhen`, `Bloc.observer`, dan proper state management.

**Recommended Skills:** `senior-flutter-developer`, `senior-webperf-engineer`

**Instructions:**

1. **BLoC-Specific Optimizations:**
   - `buildWhen` untuk filter rebuilds — SANGAT penting
   - `listenWhen` untuk filter side effects
   - `Bloc.observer` untuk global monitoring
   - Proper Equatable di states (hindari unnecessary rebuilds)
   - Granular blocs vs monolithic blocs

2. **General Flutter Optimizations:**
   - ListView.builder, const constructors, RepaintBoundary
   - Image caching, memory management
   - Startup performance

**Output Format:**

```markdown
# Performance Optimization Checklist (BLoC)


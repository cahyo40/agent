---
description: Comprehensive testing (unit, widget, integration) dan production preparation untuk Flutter app dengan GetX state mana... (Part 5/8)
---
# Workflow: Testing & Production (GetX) (Part 5/8)

> **Navigation:** This workflow is split into 8 parts.

## Deliverables

### 4. CI/CD Pipeline (GitHub Actions)

Pipeline CI/CD untuk GetX project **lebih sederhana** karena tidak membutuhkan `build_runner` step. Tidak ada code generation yang perlu di-run sebelum testing.

#### 4.1 GitHub Actions - CI

```yaml
# .github/workflows/ci.yml
name: CI Pipeline

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

concurrency:
  group: ${{ github.workflow }}-${{ github.ref }}
  cancel-in-progress: true

env:
  FLUTTER_VERSION: '3.24.0'
  JAVA_VERSION: '17'

jobs:
  # ---- Analyze & Test ----
  analyze-and-test:
    name: Analyze & Test
    runs-on: ubuntu-latest
    timeout-minutes: 30

    steps:
      - name: Checkout repository
        uses: actions/checkout@v4

      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: ${{ env.FLUTTER_VERSION }}
          cache: true

      - name: Install dependencies
        run: flutter pub get

      # CATATAN: Tidak perlu step build_runner / code generation!
      # GetX tidak membutuhkan code generation seperti Riverpod.

      - name: Analyze code
        run: flutter analyze --fatal-infos

      - name: Check formatting
        run: dart format --set-exit-if-changed .

      - name: Run unit tests
        run: flutter test --coverage --reporter=github

      - name: Check coverage threshold
        run: |
          COVERAGE=$(lcov --summary coverage/lcov.info 2>&1 | grep 'lines' | sed 's/.*: //' | sed 's/%.*//')
          echo "Coverage: $COVERAGE%"
          if (( $(echo "$COVERAGE < 80" | bc -l) )); then
            echo "::error::Coverage $COVERAGE% is below 80% threshold"
            exit 1
          fi

      - name: Upload coverage to Codecov
        uses: codecov/codecov-action@v4
        with:
          files: coverage/lcov.info
          fail_ci_if_error: true
        env:
          CODECOV_TOKEN: ${{ secrets.CODECOV_TOKEN }}

  # ---- Integration Tests ----
  integration-test:
    name: Integration Tests
    runs-on: macos-latest
    timeout-minutes: 45
    needs: analyze-and-test

    steps:
      - name: Checkout repository
        uses: actions/checkout@v4

      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: ${{ env.FLUTTER_VERSION }}
          cache: true

      - name: Install dependencies
        run: flutter pub get

      - name: Run integration tests (iOS Simulator)
        run: |
          DEVICE_ID=$(xcrun simctl list devices available | grep 'iPhone 15' | head -1 | sed 's/.*(\(.*\)).*/\1/')
          xcrun simctl boot "$DEVICE_ID" || true
          flutter test integration_test --device-id="$DEVICE_ID"

  # ---- Build Android ----
  build-android:
    name: Build Android
    runs-on: ubuntu-latest
    timeout-minutes: 30
    needs: analyze-and-test
    if: github.event_name == 'push' && github.ref == 'refs/heads/main'

    steps:
      - name: Checkout repository
        uses: actions/checkout@v4

      - name: Setup Java
        uses: actions/setup-java@v4
        with:
          distribution: 'temurin'
          java-version: ${{ env.JAVA_VERSION }}

      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: ${{ env.FLUTTER_VERSION }}
          cache: true

      - name: Install dependencies
        run: flutter pub get

      - name: Decode keystore
        run: echo "${{ secrets.KEYSTORE_BASE64 }}" | base64 -d > android/app/release.keystore
        env:
          KEYSTORE_BASE64: ${{ secrets.KEYSTORE_BASE64 }}

      - name: Build APK
        run: |
          flutter build apk --release \
            --dart-define=ENV=production \
            --dart-define=API_URL=${{ secrets.API_URL }}

      - name: Build App Bundle
        run: |
          flutter build appbundle --release \
            --dart-define=ENV=production \
            --dart-define=API_URL=${{ secrets.API_URL }}

      - name: Upload artifacts
        uses: actions/upload-artifact@v4
        with:
          name: android-release
          path: |
            build/app/outputs/flutter-apk/app-release.apk
            build/app/outputs/bundle/release/app-release.aab
          retention-days: 7

  # ---- Build iOS ----
  build-ios:
    name: Build iOS
    runs-on: macos-latest
    timeout-minutes: 45
    needs: analyze-and-test
    if: github.event_name == 'push' && github.ref == 'refs/heads/main'

    steps:
      - name: Checkout repository
        uses: actions/checkout@v4

      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: ${{ env.FLUTTER_VERSION }}
          cache: true

      - name: Install dependencies
        run: flutter pub get

      - name: Install CocoaPods
        run: |
          cd ios
          pod install

      - name: Build iOS (no codesign)
        run: |
          flutter build ios --release --no-codesign \
            --dart-define=ENV=production \
            --dart-define=API_URL=${{ secrets.API_URL }}

      - name: Upload artifacts
        uses: actions/upload-artifact@v4
        with:
          name: ios-release
          path: build/ios/iphoneos/Runner.app
          retention-days: 7
```

#### 4.2 GitHub Actions - CD (Deploy)

```yaml
# .github/workflows/cd.yml
name: CD Pipeline

on:
  push:
    tags:
      - 'v*'

env:
  FLUTTER_VERSION: '3.24.0'

jobs:
  deploy-android:
    name: Deploy to Play Store
    runs-on: ubuntu-latest
    timeout-minutes: 30

    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: ${{ env.FLUTTER_VERSION }}
          cache: true

      - name: Setup Ruby (for Fastlane)
        uses: ruby/setup-ruby@v1
        with:
          ruby-version: '3.2'
          bundler-cache: true
          working-directory: android

      - name: Install dependencies
        run: flutter pub get

      - name: Build AAB
        run: |
          flutter build appbundle --release \
            --build-number=${{ github.run_number }} \
            --dart-define=ENV=production

      - name: Deploy via Fastlane
        run: bundle exec fastlane deploy
        working-directory: android
        env:
          PLAY_STORE_JSON_KEY: ${{ secrets.PLAY_STORE_JSON_KEY }}

  deploy-ios:
    name: Deploy to App Store
    runs-on: macos-latest
    timeout-minutes: 45

    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: ${{ env.FLUTTER_VERSION }}
          cache: true

      - name: Setup Ruby (for Fastlane)
        uses: ruby/setup-ruby@v1
        with:
          ruby-version: '3.2'
          bundler-cache: true
          working-directory: ios

      - name: Install dependencies
        run: flutter pub get

      - name: Install CocoaPods
        run: cd ios && pod install

      - name: Build iOS
        run: |
          flutter build ipa --release \
            --build-number=${{ github.run_number }} \
            --dart-define=ENV=production \
            --export-options-plist=ios/ExportOptions.plist

      - name: Deploy via Fastlane
        run: bundle exec fastlane deploy
        working-directory: ios
        env:
          APP_STORE_CONNECT_API_KEY: ${{ secrets.APP_STORE_CONNECT_API_KEY }}
          MATCH_PASSWORD: ${{ secrets.MATCH_PASSWORD }}
```

---


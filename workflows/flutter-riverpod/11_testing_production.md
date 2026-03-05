---
description: Comprehensive testing (unit, widget, integration) dan production preparation — CI/CD pipeline, performance optimization, dan deployment.
---
# Workflow: Testing & Production

// turbo-all

## Overview

Comprehensive testing (unit, widget, integration) dan production preparation:
CI/CD pipeline, performance optimization, dan app store deployment.


## Prerequisites

- Project setup dari `01_project_setup.md` selesai
- Backend integration (REST API, Firebase, atau Supabase) selesai
- Features implemented dan functional


## Agent Behavior

- **Target minimum 80% code coverage** — 100% untuk critical paths.
- **Gunakan mocktail** untuk mocking, bukan mockito.
- **Setup CI/CD di GitHub Actions** sebagai default.
- **Selalu include production checklist** sebelum release.


## Recommended Skills

- `senior-quality-assurance-engineer` — Testing strategies
- `github-actions-specialist` — CI/CD pipelines


## Workflow Steps

### Step 1: Unit Testing

```dart
// test/features/auth/domain/usecases/login_test.dart
import 'package:my_app/core/error/result.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock
    implements AuthRepository {}

void main() {
  late LoginUseCase useCase;
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    useCase = LoginUseCase(mockRepository);
  });

  group('LoginUseCase', () {
    const tEmail = 'test@example.com';
    const tPassword = 'password123';
    final tUser = User(id: '1', email: tEmail);

    test(
      'should return User when login succeeds',
      () async {
        when(
          () => mockRepository
              .signInWithEmailAndPassword(
            tEmail,
            tPassword,
          ),
        ).thenAnswer(
          (_) async => Success(tUser),
        );

        final result = await useCase(
          LoginParams(
            email: tEmail,
            password: tPassword,
          ),
        );

        expect(result, isA<Success<User>>());
        expect(
          (result as Success<User>).data,
          tUser,
        );
        verify(
          () => mockRepository
              .signInWithEmailAndPassword(
            tEmail,
            tPassword,
          ),
        ).called(1);
      },
    );

    test(
      'should return Failure when login fails',
      () async {
        when(
          () => mockRepository
              .signInWithEmailAndPassword(
            tEmail,
            tPassword,
          ),
        ).thenAnswer(
          (_) async => const Err(
            AuthFailure('Invalid credentials'),
          ),
        );

        final result = await useCase(
          LoginParams(
            email: tEmail,
            password: tPassword,
          ),
        );

        expect(result, isA<Err<User>>());
        expect(
          (result as Err<User>).failure,
          isA<AuthFailure>(),
        );
      },
    );
  });
}
```

### Step 2: Widget Testing

```dart
// test/features/auth/presentation/screens/login_screen_test.dart
testWidgets(
  'shows validation error when email is empty',
  (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: LoginScreen(),
        ),
      ),
    );

    await tester.tap(
      find.byType(ElevatedButton),
    );
    await tester.pumpAndSettle();

    expect(
      find.text('Email is required'),
      findsOneWidget,
    );
  },
);

testWidgets(
  'shows loading indicator when logging in',
  (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authControllerProvider.overrideWith(
            (ref) => MockAuthNotifier(),
          ),
        ],
        child: MaterialApp(home: LoginScreen()),
      ),
    );

    await tester.enterText(
      find.byKey(const Key('email_field')),
      'test@example.com',
    );
    await tester.enterText(
      find.byKey(const Key('password_field')),
      'password',
    );

    await tester.tap(
      find.byType(ElevatedButton),
    );
    await tester.pump();

    expect(
      find.byType(CircularProgressIndicator),
      findsOneWidget,
    );
  },
);
```

### Step 3: Integration Testing

```dart
// integration_test/app_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding
      .ensureInitialized();

  group('End-to-End Tests', () {
    test('complete login flow', () async {
      app.main();
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const Key('email_field')),
        'test@example.com',
      );
      await tester.enterText(
        find.byKey(const Key('password_field')),
        'password123',
      );

      await tester.tap(
        find.byType(ElevatedButton),
      );
      await tester.pumpAndSettle();

      expect(
        find.text('Welcome'),
        findsOneWidget,
      );
    });
  });
}
```

### Step 4: CI/CD Pipeline (GitHub Actions)

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

      - name: Run unit tests
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

      - uses: actions/setup-java@v4
        with:
          distribution: 'zulu'
          java-version: '17'

      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.19.0'
          cache: true

      - run: flutter pub get

      - name: Build APK
        run: flutter build apk --release

      - uses: actions/upload-artifact@v4
        with:
          name: release-apk
          path: >-
            build/app/outputs/flutter-apk/
            app-release.apk
```

### Step 5: Performance Optimization Checklist

```markdown
## Image Optimization
- [ ] Use CachedNetworkImage untuk network images
- [ ] Set cacheWidth & cacheHeight sesuai display
- [ ] Compress images sebelum upload
- [ ] Use WebP format (smaller file size)

## List Optimization
- [ ] Use ListView.builder (NOT ListView children)
- [ ] Implement pagination untuk long lists
- [ ] Use const constructors untuk list items
- [ ] Avoid heavy computation di itemBuilder

## State Management
- [ ] Use `select` untuk minimize rebuilds
- [ ] Avoid storing large objects di state
- [ ] Use `const` widgets di build method
- [ ] Implement proper dispose()

## Memory Management
- [ ] Cancel subscriptions on dispose
- [ ] Clear image cache periodically
- [ ] Use RepaintBoundary untuk complex widgets
- [ ] Avoid memory leaks di streams

## Startup Performance
- [ ] Defer non-critical initialization
- [ ] Use splash screen dengan proper init
- [ ] Minimize main bundle size
- [ ] Preload critical assets
```

### Step 6: Production Release Checklist

```markdown
## Pre-Release
- [ ] App version updated di pubspec.yaml
- [ ] CHANGELOG.md updated
- [ ] All tests passing
- [ ] Code coverage > 80%
- [ ] No analyzer warnings
- [ ] Code formatted

## Android
- [ ] ProGuard/R8 rules configured
- [ ] App signing configured
- [ ] App icon (all densities)
- [ ] Splash screen
- [ ] Play Store listing prepared

## iOS
- [ ] App Store Connect setup
- [ ] App icon (all sizes)
- [ ] Signing certificates
- [ ] Provisioning profiles
- [ ] App Store listing prepared

## Security
- [ ] API keys not hardcoded
- [ ] Obfuscation enabled (--obfuscate)
- [ ] Split debug info (--split-debug-info)
- [ ] No sensitive data di logs
```

### Step 7: Fastlane Configuration

```ruby
# android/fastlane/Fastfile
platform :android do
  desc "Deploy to internal testing"
  lane :internal do
    gradle(
      task: "bundle",
      build_type: "release",
    )

    upload_to_play_store(
      track: "internal",
      aab: "../build/app/outputs/bundle/release/app-release.aab",
      skip_upload_metadata: true,
      skip_upload_images: true,
    )
  end
end

# ios/fastlane/Fastfile
platform :ios do
  desc "Deploy to TestFlight"
  lane :beta do
    setup_ci
    match(type: "appstore", readonly: true)
    build_ios_app(export_method: "app-store")
    upload_to_testflight(
      skip_waiting_for_build_processing: true,
    )
  end
end
```


## Tools & Commands

```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage

# Profile mode
flutter run --profile

# Build with obfuscation
flutter build apk --release \
    --obfuscate --split-debug-info=symbols/
```


## Success Criteria

- [ ] Unit test coverage ≥ 80%
- [ ] All critical paths have widget tests
- [ ] Integration tests cover happy paths
- [ ] CI/CD pipeline runs tanpa error
- [ ] No high/critical defects
- [ ] Performance benchmarks met
- [ ] App size optimized
- [ ] Production checklist complete
- [ ] App published ke stores


## Next Steps

Setelah testing & production workflow selesai:
1. Monitor app performance di production
2. Collect user feedback
3. Plan next features
4. Setup monitoring dan crash reporting

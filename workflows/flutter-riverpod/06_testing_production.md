# Workflow: Testing & Production

## Overview

Comprehensive testing (unit, widget, integration) dan production preparation: CI/CD pipeline, performance optimization, dan app store deployment.

## Output Location

**Base Folder:** `sdlc/flutter-riverpod/06-testing-production/`

**Output Files:
- `testing/` - Unit, widget, integration tests
- `ci-cd/` - GitHub Actions workflows
- `performance/` - Performance optimization guide
- `deployment/` - App store deployment guides
- `checklists/` - Production checklists

## Prerequisites

- Project setup dari `01_project_setup.md` selesai
- Backend integration (REST API, Firebase, atau Supabase) selesai
- Features implemented dan functional

## Deliverables

### 1. Unit Testing

**Description:** Unit tests untuk use cases, repositories, dan services dengan mocking.

**Recommended Skills:** `senior-flutter-developer`, `python-testing-specialist`

**Instructions:**
1. **Test Setup:**
   - Mocktail untuk mocking
   - ProviderContainer untuk Riverpod testing
   - Test fixtures dan data builders

2. **Test Categories:**
   - Use case tests
   - Repository tests
   - Service tests
   - Utility function tests

3. **Coverage Target:**
   - Minimum 80% code coverage
   - 100% coverage untuk critical paths

**Output Format:**
```dart
// test/features/auth/domain/usecases/login_test.dart
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

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
    
    test('should return User when login is successful', () async {
      // Arrange
      when(() => mockRepository.signInWithEmailAndPassword(tEmail, tPassword))
          .thenAnswer((_) async => Right(tUser));
      
      // Act
      final result = await useCase(LoginParams(email: tEmail, password: tPassword));
      
      // Assert
      expect(result, Right(tUser));
      verify(() => mockRepository.signInWithEmailAndPassword(tEmail, tPassword)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });
    
    test('should return Failure when login fails', () async {
      // Arrange
      when(() => mockRepository.signInWithEmailAndPassword(tEmail, tPassword))
          .thenAnswer((_) async => const Left(AuthFailure('Invalid credentials')));
      
      // Act
      final result = await useCase(LoginParams(email: tEmail, password: tPassword));
      
      // Assert
      expect(result, const Left(AuthFailure('Invalid credentials')));
    });
  });
}

// test/core/network/dio_client_test.dart
class MockDio extends Mock implements Dio {}

void main() {
  late DioClient dioClient;
  late MockDio mockDio;
  
  setUp(() {
    mockDio = MockDio();
    dioClient = DioClient(dio: mockDio);
  });
  
  group('DioClient', () {
    test('should add auth header when token exists', () async {
      // Test auth interceptor
    });
    
    test('should retry on 5xx error', () async {
      // Test retry interceptor
    });
  });
}
```

---

### 2. Widget Testing

**Description:** Widget tests untuk screens dan UI components.

**Recommended Skills:** `senior-flutter-developer`, `playwright-specialist`

**Instructions:**
1. **Screen Tests:**
   - Test dengan berbagai states (loading, error, empty, data)
   - Test user interactions
   - Test navigation

2. **Component Tests:**
   - Test reusable widgets
   - Test form validation
   - Test error boundaries

**Output Format:**
```dart
// test/features/auth/presentation/screens/login_screen_test.dart
testWidgets('shows validation error when email is empty', (tester) async {
  await tester.pumpWidget(
    ProviderScope(
      child: MaterialApp(
        home: LoginScreen(),
      ),
    ),
  );
  
  // Tap login button tanpa isi form
  await tester.tap(find.byType(ElevatedButton));
  await tester.pumpAndSettle();
  
  // Assert error message muncul
  expect(find.text('Email is required'), findsOneWidget);
});

testWidgets('shows loading indicator when logging in', (tester) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        authControllerProvider.overrideWith((ref) => MockAuthNotifier()),
      ],
      child: MaterialApp(home: LoginScreen()),
    ),
  );
  
  // Isi form
  await tester.enterText(find.byKey(const Key('email_field')), 'test@example.com');
  await tester.enterText(find.byKey(const Key('password_field')), 'password');
  
  // Tap login
  await tester.tap(find.byType(ElevatedButton));
  await tester.pump();
  
  // Assert loading indicator muncul
  expect(find.byType(CircularProgressIndicator), findsOneWidget);
});

testWidgets('navigates to home on successful login', (tester) async {
  final mockGoRouter = MockGoRouter();
  
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        authControllerProvider.overrideWith((ref) => MockAuthNotifier()),
      ],
      child: InheritedGoRouter(
        goRouter: mockGoRouter,
        child: MaterialApp(home: LoginScreen()),
      ),
    ),
  );
  
  // Trigger successful login
  // Assert navigation dipanggil
  verify(() => mockGoRouter.go('/home')).called(1);
});
```

---

### 3. Integration Testing

**Description:** Integration tests untuk end-to-end flows.

**Recommended Skills:** `senior-flutter-developer`, `playwright-specialist`

**Instructions:**
1. **Test Scenarios:**
   - Happy paths
   - Error scenarios
   - Complete user journeys

2. **Test Environment:**
   - Mock servers (mockoon, wiremock)
   - Test databases
   - Firebase emulators (jika pakai Firebase)

**Output Format:**
```dart
// integration_test/app_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:my_app/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  
  group('End-to-End Tests', () {
    test('complete login flow', () async {
      app.main();
      await tester.pumpAndSettle();
      
      // Navigate to login
      await tester.tap(find.byIcon(Icons.login));
      await tester.pumpAndSettle();
      
      // Enter credentials
      await tester.enterText(
        find.byKey(const Key('email_field')), 
        'test@example.com'
      );
      await tester.enterText(
        find.byKey(const Key('password_field')), 
        'password123'
      );
      
      // Submit
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();
      
      // Assert logged in
      expect(find.text('Welcome'), findsOneWidget);
    });
    
    test('create product flow', () async {
      app.main();
      await tester.pumpAndSettle();
      
      // Login first
      // ... login steps
      
      // Navigate to create product
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();
      
      // Fill form
      await tester.enterText(
        find.byKey(const Key('name_field')), 
        'New Product'
      );
      await tester.enterText(
        find.byKey(const Key('price_field')), 
        '99.99'
      );
      
      // Submit
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();
      
      // Assert product created
      expect(find.text('New Product'), findsOneWidget);
    });
  });
}
```

---

### 4. CI/CD Pipeline (GitHub Actions)

**Description:** Automated testing, building, dan deployment dengan GitHub Actions.

**Recommended Skills:** `senior-flutter-developer`, `github-actions-specialist`

**Instructions:**
1. **CI Workflow:**
   - Code analysis
   - Unit tests
   - Widget tests
   - Build APK/IPA

2. **CD Workflow:**
   - Deploy ke stores
   - Fastlane integration

**Output Format:**
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
      
      - name: Decode keystore
        run: echo "${{ secrets.KEYSTORE_BASE64 }}" | base64 -d > android/app/keystore.jks
      
      - name: Build APK
        run: flutter build apk --release
        env:
          KEYSTORE_PASSWORD: ${{ secrets.KEYSTORE_PASSWORD }}
          KEY_PASSWORD: ${{ secrets.KEY_PASSWORD }}
          KEY_ALIAS: ${{ secrets.KEY_ALIAS }}
      
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
      
      - run: flutter pub get
      
      - name: Install Apple certificates
        uses: apple-actions/import-codesign-certs@v2
        with:
          p12-file-base64: ${{ secrets.P12_BASE64 }}
          p12-password: ${{ secrets.P12_PASSWORD }}
      
      - run: flutter build ios --release --no-codesign

# .github/workflows/flutter-deploy.yml
name: Flutter Deploy

on:
  push:
    tags:
      - 'v*'

jobs:
  deploy-android:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.19.0'
          cache: true
      
      - run: flutter pub get
      
      - name: Deploy to Play Store
        uses: r0adkll/upload-google-play@v1
        with:
          serviceAccountJsonPlainText: ${{ secrets.PLAY_STORE_SERVICE_ACCOUNT }}
          packageName: com.example.app
          releaseFiles: build/app/outputs/bundle/release/app-release.aab
          track: internal
```

---

### 5. Performance Optimization

**Description:** Performance optimization guide dan checklist.

**Recommended Skills:** `senior-flutter-developer`, `senior-webperf-engineer`

**Instructions:**
1. **Profiling:**
   - DevTools setup
   - Identify jank dan memory leaks
   - Performance metrics

2. **Optimizations:**
   - ListView.builder untuk long lists
   - Image caching dan compression
   - const constructors
   - RepaintBoundary
   - Debounce pada search

**Output Format:**
```markdown
# Performance Optimization Checklist

## Image Optimization
- [ ] Use CachedNetworkImage untuk semua network images
- [ ] Set cacheWidth dan cacheHeight sesuai display size
- [ ] Compress images sebelum upload
- [ ] Use WebP format (smaller file size)

## List Optimization
- [ ] Use ListView.builder (NOT ListView with children)
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
- [ ] Use `RepaintBoundary` untuk complex widgets
- [ ] Avoid memory leaks di streams

## Startup Performance
- [ ] Defer non-critical initialization
- [ ] Use splash screen dengan proper initialization
- [ ] Minimize main bundle size
- [ ] Preload critical assets

## Profiling Steps
1. Run `flutter run --profile`
2. Open DevTools
3. Check for:
   - Raster thread jank (>16ms frames)
   - UI thread jank
   - Memory leaks (growing memory)
   - Excessive rebuilds
```

---

### 6. Production Checklist

**Description:** Comprehensive checklist sebelum release ke production.

**Output Format:**
```markdown
# Production Release Checklist

## Pre-Release
- [ ] App version updated di pubspec.yaml
- [ ] CHANGELOG.md updated
- [ ] README.md updated
- [ ] All tests passing
- [ ] Code coverage > 80%
- [ ] No analyzer warnings
- [ ] Code formatted

## Android
- [ ] ProGuard/R8 rules configured
- [ ] App signing configured
- [ ] Keystore backed up securely
- [ ] minSdkVersion appropriate
- [ ] targetSdkVersion latest
- [ ] App icon (all densities)
- [ ] Splash screen
- [ ] Play Store listing prepared
- [ ] Screenshots generated
- [ ] Privacy policy URL

## iOS
- [ ] App Store Connect setup
- [ ] App icon (all sizes)
- [ ] Launch screen
- [ ] Signing certificates
- [ ] Provisioning profiles
- [ ] Info.plist configured
- [ ] App Store listing prepared
- [ ] Screenshots (all devices)
- [ ] Privacy policy URL

## Firebase (jika pakai)
- [ ] Production Firebase project
- [ ] Security rules deployed
- [ ] Analytics enabled
- [ ] Crashlytics enabled
- [ ] Performance monitoring enabled
- [ ] Push notifications tested

## Performance
- [ ] Profiled dengan DevTools
- [ ] No jank (>16ms frames)
- [ ] Memory usage acceptable
- [ ] App size optimized
- [ ] Cold start < 3 seconds

## Security
- [ ] API keys not hardcoded
- [ ] SSL pinning (optional)
- [ ] Obfuscation enabled (`--obfuscate`)
- [ ] Split debug info (`--split-debug-info`)
- [ ] No sensitive data di logs

## Final Steps
- [ ] Build release APK/AAB
- [ ] Build release IPA
- [ ] Test on real devices
- [ ] Beta testing (TestFlight/Internal Testing)
- [ ] Submit to stores
```

---

### 7. Fastlane Configuration

**Description:** Fastlane setup untuk automated deployment.

**Output Format:**
```ruby
# android/fastlane/Fastfile
platform :android do
  desc "Deploy to internal testing"
  lane :internal do
    # Increment version code
    increment_version_code(
      gradle_file_path: "app/build.gradle",
    )
    
    # Build AAB
    gradle(
      task: "bundle",
      build_type: "release",
      properties: {
        "android.injected.signing.store.file" => ENV["KEYSTORE_FILE"],
        "android.injected.signing.store.password" => ENV["KEYSTORE_PASSWORD"],
        "android.injected.signing.key.alias" => ENV["KEY_ALIAS"],
        "android.injected.signing.key.password" => ENV["KEY_PASSWORD"],
      }
    )
    
    # Upload to Play Store
    upload_to_play_store(
      track: "internal",
      aab: "../build/app/outputs/bundle/release/app-release.aab",
      skip_upload_metadata: true,
      skip_upload_images: true,
      skip_upload_screenshots: true,
    )
  end
  
  desc "Deploy to production"
  lane :production do
    gradle(task: "bundle", build_type: "release")
    
    upload_to_play_store(
      track: "production",
      aab: "../build/app/outputs/bundle/release/app-release.aab",
    )
  end
end

# ios/fastlane/Fastfile
platform :ios do
  desc "Deploy to TestFlight"
  lane :beta do
    setup_ci
    
    # Sync certificates
    match(
      type: "appstore",
      readonly: true,
    )
    
    # Build IPA
    build_ios_app(
      export_method: "app-store",
      output_directory: "../build/ios/ipa",
    )
    
    # Upload to TestFlight
    upload_to_testflight(
      skip_waiting_for_build_processing: true,
    )
  end
  
  desc "Deploy to App Store"
  lane :release do
    setup_ci
    
    match(type: "appstore", readonly: true)
    
    build_ios_app(export_method: "app-store")
    
    upload_to_app_store(
      submit_for_review: true,
      automatic_release: false,
    )
  end
end
```

## Workflow Steps

1. **Setup Testing Infrastructure**
   - Add test dependencies
   - Setup test utilities
   - Create mock classes

2. **Write Unit Tests**
   - Test use cases
   - Test repositories
   - Test services
   - Run tests: `flutter test`

3. **Write Widget Tests**
   - Test screens
   - Test components
   - Test forms
   - Test navigation

4. **Write Integration Tests**
   - Test end-to-end flows
   - Setup test environment
   - Run: `flutter test integration_test/`

5. **Setup CI/CD**
   - Create GitHub Actions workflows
   - Configure secrets
   - Test CI pipeline

6. **Performance Optimization**
   - Profile dengan DevTools
   - Fix performance issues
   - Verify optimizations

7. **Production Preparation**
   - Complete checklist
   - Setup signing
   - Configure Fastlane
   - Prepare store listings

8. **Deployment**
   - Build release versions
   - Upload ke stores
   - Monitor analytics

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

## Tools & Commands

### Testing
```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage

# Run specific test file
flutter test test/features/auth/domain/usecases/login_test.dart

# Run integration tests
flutter test integration_test/app_test.dart
```

### Performance
```bash
# Profile mode
flutter run --profile

# Build release
flutter build apk --release
flutter build ios --release

# Build with obfuscation
flutter build apk --release --obfuscate --split-debug-info=symbols/
```

### CI/CD
```bash
# Local Fastlane test
cd android && fastlane internal
cd ios && fastlane beta
```

## Next Steps

Setelah testing & production workflow selesai:
1. Monitor app performance di production
2. Collect user feedback
3. Plan next features
4. Setup monitoring dan crash reporting
5. Regular updates dan maintenance

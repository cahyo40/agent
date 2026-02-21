---
description: Comprehensive testing (unit, widget, integration) dan production preparation: CI/CD pipeline, performance optimizatio... (Part 1/2)
---
# Workflow: Testing & Production (Part 1/2)

> **Navigation:** This workflow is split into 2 parts.

## Overview

Comprehensive testing (unit, widget, integration) dan production preparation: CI/CD pipeline, performance optimization, dan app store deployment.


## Output Location

**Base Folder:** `sdlc/flutter-youi-riverpod/06-testing-production/`

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


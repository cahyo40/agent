---
name: flutter-testing-specialist
description: "Expert Flutter testing including unit tests, widget tests, integration tests, golden tests, and test-driven development"
---

# Flutter Testing Specialist

## Overview

This skill helps you write comprehensive tests for Flutter applications ensuring reliability and preventing regressions.

## When to Use This Skill

- Use when writing unit tests
- Use when creating widget tests
- Use when setting up integration tests
- Use when implementing golden tests
- Use when applying TDD

## How It Works

### Step 1: Testing Pyramid

```
FLUTTER TESTING PYRAMID
┌─────────────────────────────────────────────────────────────────┐
│                                                                 │
│                    ┌───────────┐                               │
│                    │Integration│  Few, slow, high confidence   │
│                    │   Tests   │                               │
│                    └─────┬─────┘                               │
│                ┌─────────┴─────────┐                           │
│                │    Widget Tests   │  Medium, fast, UI logic   │
│                └─────────┬─────────┘                           │
│         ┌────────────────┴────────────────┐                    │
│         │          Unit Tests             │  Many, fastest     │
│         └─────────────────────────────────┘                    │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### Step 2: Unit Tests

```dart
// test/features/auth/domain/usecases/login_usecase_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late LoginUsecase usecase;
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    usecase = LoginUsecase(mockRepository);
  });

  group('LoginUsecase', () {
    const tEmail = 'test@example.com';
    const tPassword = 'password123';
    final tUser = User(id: '1', email: tEmail);

    test('should return User when login is successful', () async {
      // Arrange
      when(() => mockRepository.login(tEmail, tPassword))
          .thenAnswer((_) async => Right(tUser));

      // Act
      final result = await usecase(LoginParams(email: tEmail, password: tPassword));

      // Assert
      expect(result, Right(tUser));
      verify(() => mockRepository.login(tEmail, tPassword)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return Failure when login fails', () async {
      // Arrange
      when(() => mockRepository.login(any(), any()))
          .thenAnswer((_) async => Left(AuthFailure('Invalid credentials')));

      // Act
      final result = await usecase(LoginParams(email: tEmail, password: 'wrong'));

      // Assert
      expect(result, isA<Left<Failure, User>>());
    });
  });
}
```

### Step 3: Widget Tests

```dart
// test/features/auth/presentation/screens/login_screen_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LoginScreen', () {
    testWidgets('should show validation error when email is empty', (tester) async {
      // Arrange
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(home: LoginScreen()),
        ),
      );

      // Act - tap login without entering email
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Email is required'), findsOneWidget);
    });

    testWidgets('should show loading indicator when logging in', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authControllerProvider.overrideWith(() => MockAuthController()),
          ],
          child: const MaterialApp(home: LoginScreen()),
        ),
      );

      // Fill form
      await tester.enterText(find.byKey(const Key('email_field')), 'test@example.com');
      await tester.enterText(find.byKey(const Key('password_field')), 'password');
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      // Should show loading
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should navigate to home on successful login', (tester) async {
      final mockController = MockAuthController();
      when(() => mockController.state).thenReturn(
        AsyncData(AuthState.authenticated(tUser)),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [authControllerProvider.overrideWith(() => mockController)],
          child: MaterialApp(
            home: const LoginScreen(),
            routes: {'/home': (_) => const HomeScreen()},
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.byType(HomeScreen), findsOneWidget);
    });
  });
}
```

### Step 4: Golden Tests

```dart
// test/goldens/product_card_golden_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';

void main() {
  group('ProductCard Golden Tests', () {
    testGoldens('ProductCard renders correctly', (tester) async {
      final builder = GoldenBuilder.grid(
        columns: 2,
        widthToHeightRatio: 0.8,
      )
        ..addScenario('Default', ProductCard(product: tProduct))
        ..addScenario('With discount', ProductCard(product: tProductWithDiscount))
        ..addScenario('Out of stock', ProductCard(product: tProductOutOfStock))
        ..addScenario('Long title', ProductCard(product: tProductLongTitle));

      await tester.pumpWidgetBuilder(
        builder.build(),
        surfaceSize: const Size(400, 600),
      );

      await screenMatchesGolden(tester, 'product_card_variants');
    });

    testGoldens('ProductCard - dark mode', (tester) async {
      await tester.pumpWidgetBuilder(
        Theme(
          data: ThemeData.dark(),
          child: ProductCard(product: tProduct),
        ),
        surfaceSize: const Size(200, 280),
      );

      await screenMatchesGolden(tester, 'product_card_dark');
    });
  });
}

// Run: flutter test --update-goldens
```

### Step 5: Integration Tests

```dart
// integration_test/app_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:my_app/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('End-to-end test', () {
    testWidgets('Complete purchase flow', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Login
      await tester.enterText(find.byKey(const Key('email')), 'user@example.com');
      await tester.enterText(find.byKey(const Key('password')), 'password');
      await tester.tap(find.text('Login'));
      await tester.pumpAndSettle();

      // Navigate to products
      expect(find.text('Products'), findsOneWidget);

      // Add to cart
      await tester.tap(find.byType(ProductCard).first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Add to Cart'));
      await tester.pumpAndSettle();

      // Checkout
      await tester.tap(find.byIcon(Icons.shopping_cart));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Checkout'));
      await tester.pumpAndSettle();

      // Verify success
      expect(find.text('Order Confirmed'), findsOneWidget);
    });
  });
}

// Run: flutter test integration_test/app_test.dart
```

## Best Practices

### ✅ Do This

- ✅ Test behavior, not implementation
- ✅ Use descriptive test names
- ✅ Keep tests independent
- ✅ Mock external dependencies
- ✅ Run tests in CI/CD

### ❌ Avoid This

- ❌ Don't test Flutter framework itself
- ❌ Don't write flaky tests
- ❌ Don't skip edge cases
- ❌ Don't over-mock

## Related Skills

- `@senior-flutter-developer` - Flutter development
- `@tdd-workflow` - Test-driven development

# Flutter Testing

## Overview

Comprehensive testing including unit tests, widget tests, integration tests, and golden tests for Riverpod, BLoC, GetX, Firebase, and Supabase.

---

## Testing Pyramid

```text
       ┌─────────────┐
       │ Integration │  Few, slow, high confidence
       └──────┬──────┘
      ┌───────┴───────┐
      │  Widget Tests │  Medium, fast, UI logic
      └───────┬───────┘
   ┌──────────┴──────────┐
   │     Unit Tests      │  Many, fastest
   └─────────────────────┘
```

---

## Dependencies

```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  mocktail: ^1.0.0
  bloc_test: ^9.1.0         # For BLoC/Cubit
  golden_toolkit: ^0.15.0
  integration_test:
    sdk: flutter
  firebase_auth_mocks: ^0.14.0
  fake_cloud_firestore: ^3.0.0
```

---

## Unit Testing

```dart
class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late LoginUsecase usecase;
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    usecase = LoginUsecase(mockRepository);
  });

  test('should return User when login is successful', () async {
    when(() => mockRepository.login(any(), any()))
        .thenAnswer((_) async => Right(tUser));

    final result = await usecase(LoginParams(email: email, password: password));

    expect(result, Right(tUser));
    verify(() => mockRepository.login(email, password)).called(1);
  });
}
```

---

## Riverpod Testing

```dart
void main() {
  late ProviderContainer container;
  late MockAuthRepository mockRepo;

  setUp(() {
    mockRepo = MockAuthRepository();
    container = ProviderContainer(
      overrides: [authRepositoryProvider.overrideWithValue(mockRepo)],
    );
  });

  tearDown(() => container.dispose());

  test('login success updates state to authenticated', () async {
    when(() => mockRepo.login(any(), any())).thenAnswer((_) async => Right(user));

    await container.read(authNotifierProvider.notifier).login(
      email: 'test@test.com',
      password: 'password',
    );

    expect(container.read(authNotifierProvider), AuthState.authenticated(user));
  });
}
```

---

## BLoC Testing

```dart
import 'package:bloc_test/bloc_test.dart';

void main() {
  blocTest<AuthBloc, AuthState>(
    'emits [Loading, Authenticated] when login succeeds',
    build: () {
      when(() => mockRepo.login(any(), any())).thenAnswer((_) async => Right(user));
      return AuthBloc(authRepository: mockRepo);
    },
    act: (bloc) => bloc.add(LoginRequested(email: 'test@test.com', password: 'pass')),
    expect: () => [AuthLoading(), AuthAuthenticated(user)],
  );

  blocTest<AuthBloc, AuthState>(
    'emits [Loading, Error] when login fails',
    build: () {
      when(() => mockRepo.login(any(), any()))
          .thenAnswer((_) async => Left(AuthFailure('Invalid')));
      return AuthBloc(authRepository: mockRepo);
    },
    act: (bloc) => bloc.add(LoginRequested(email: 'test@test.com', password: 'wrong')),
    expect: () => [AuthLoading(), AuthError('Invalid')],
  );
}
```

---

## GetX Testing

```dart
void main() {
  late AuthController controller;
  late MockAuthRepository mockRepo;

  setUp(() {
    Get.reset();
    mockRepo = MockAuthRepository();
    Get.put<AuthRepository>(mockRepo);
    controller = AuthController();
    Get.put(controller);
  });

  tearDown(() => Get.reset());

  test('login success updates isAuthenticated', () async {
    when(() => mockRepo.login(any(), any())).thenAnswer((_) async => Right(user));

    await controller.login('test@test.com', 'password');

    expect(controller.isAuthenticated.value, true);
    expect(controller.user.value, user);
  });
}
```

---

## Widget Testing

```dart
testWidgets('shows validation error when email is empty', (tester) async {
  await tester.pumpWidget(
    const ProviderScope(child: MaterialApp(home: LoginScreen())),
  );

  await tester.tap(find.byType(ElevatedButton));
  await tester.pumpAndSettle();

  expect(find.text('Email is required'), findsOneWidget);
});

testWidgets('shows loading indicator when logging in', (tester) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [authNotifierProvider.overrideWith(() => MockAuthNotifier())],
      child: const MaterialApp(home: LoginScreen()),
    ),
  );

  await tester.enterText(find.byKey(const Key('email_field')), 'test@example.com');
  await tester.enterText(find.byKey(const Key('password_field')), 'password');
  await tester.tap(find.byType(ElevatedButton));
  await tester.pump();

  expect(find.byType(CircularProgressIndicator), findsOneWidget);
});
```

---

## Firebase Testing

```dart
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';

test('signInWithEmail returns user on success', () async {
  final mockAuth = MockFirebaseAuth();
  final authService = FirebaseAuthService(firebaseAuth: mockAuth);

  final result = await authService.signInWithEmail(
    email: 'test@example.com',
    password: 'password',
  );

  expect(result.isRight, true);
});

test('getProducts returns list from Firestore', () async {
  final fakeFirestore = FakeFirebaseFirestore();
  await fakeFirestore.collection('products').add({'name': 'Test Product'});

  final repo = ProductRepository(firestore: fakeFirestore);
  final products = await repo.getProducts();

  expect(products.length, 1);
  expect(products.first.name, 'Test Product');
});
```

---

## Best Practices

### ✅ Do This

- ✅ Use `mocktail` for mocking
- ✅ Follow AAA pattern (Arrange, Act, Assert)
- ✅ Test edge cases and error states
- ✅ Use `setUp` and `tearDown` for setup
- ✅ Aim for 80%+ code coverage

### ❌ Avoid This

- ❌ Don't test implementation details
- ❌ Don't skip error cases
- ❌ Don't write flaky tests
- ❌ Don't mock what you don't own

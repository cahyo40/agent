---
name: flutter-testing-specialist
description: "Expert Flutter testing including unit tests, widget tests, integration tests, golden tests, state management testing (Riverpod, BLoC, GetX), and backend integration testing (Firebase, Supabase)"
---

# Flutter Testing Specialist

## Overview

This skill helps you write comprehensive tests for Flutter applications ensuring reliability and preventing regressions. Covers all state management patterns and backend integrations.

## When to Use This Skill

- Use when writing unit tests for business logic
- Use when creating widget tests for UI components
- Use when setting up integration tests for full flows
- Use when implementing golden tests for visual regression
- Use when testing Riverpod, BLoC, or GetX state management
- Use when testing Firebase integration (Auth, Firestore, Storage)
- Use when testing Supabase integration (Auth, Database, Realtime)
- Use when applying TDD methodology

---

## Part 1: Testing Fundamentals

### Testing Pyramid

```text
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

### Essential Dependencies

```yaml
# pubspec.yaml
dev_dependencies:
  # Core testing
  flutter_test:
    sdk: flutter
  mocktail: ^1.0.0
  
  # State management testing
  bloc_test: ^9.1.0           # For BLoC/Cubit
  riverpod: ^2.5.0            # Riverpod testing utilities
  
  # Golden tests
  golden_toolkit: ^0.15.0
  
  # Integration tests
  integration_test:
    sdk: flutter
  
  # Firebase mocks
  firebase_auth_mocks: ^0.14.0
  fake_cloud_firestore: ^3.0.0
  firebase_storage_mocks: ^0.7.0
  
  # Network mocking
  http_mock_adapter: ^0.6.0   # For Dio
  nock: ^1.2.0                # HTTP mocking
```

---

## Part 2: Unit Tests

### Basic Unit Test Structure

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

---

## Part 3: State Management Testing

### 3.1 Riverpod Testing

```dart
// test/providers/auth_provider_test.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late ProviderContainer container;
  late MockAuthRepository mockAuthRepository;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    container = ProviderContainer(
      overrides: [
        authRepositoryProvider.overrideWithValue(mockAuthRepository),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  group('AuthNotifier', () {
    test('initial state is AuthState.initial', () {
      final state = container.read(authNotifierProvider);
      expect(state, const AuthState.initial());
    });

    test('login success updates state to authenticated', () async {
      // Arrange
      final user = User(id: '1', email: 'test@test.com');
      when(() => mockAuthRepository.login(any(), any()))
          .thenAnswer((_) async => Right(user));

      // Act
      await container.read(authNotifierProvider.notifier).login(
        email: 'test@test.com',
        password: 'password',
      );

      // Assert
      final state = container.read(authNotifierProvider);
      expect(state, AuthState.authenticated(user));
    });

    test('login failure updates state to error', () async {
      // Arrange
      when(() => mockAuthRepository.login(any(), any()))
          .thenAnswer((_) async => Left(AuthFailure('Invalid')));

      // Act
      await container.read(authNotifierProvider.notifier).login(
        email: 'test@test.com',
        password: 'wrong',
      );

      // Assert
      final state = container.read(authNotifierProvider);
      expect(state, isA<AuthStateError>());
    });
  });

  group('AsyncNotifier Testing', () {
    test('fetchProducts returns list of products', () async {
      // Arrange
      final products = [Product(id: '1', name: 'Test')];
      when(() => mockProductRepository.getProducts())
          .thenAnswer((_) async => products);

      // Act - Listen to provider and wait for data
      final subscription = container.listen(
        productsProvider,
        (previous, next) {},
      );

      // Wait for async operation
      await container.read(productsProvider.future);

      // Assert
      final state = container.read(productsProvider);
      expect(state.value, products);
      
      subscription.close();
    });
  });
}

// Testing with AsyncValue states
test('handles loading and error states', () async {
  final container = ProviderContainer(
    overrides: [
      productRepositoryProvider.overrideWithValue(mockRepo),
    ],
  );

  // Initially loading
  expect(container.read(productsProvider), const AsyncLoading<List<Product>>());

  // Mock error
  when(() => mockRepo.getProducts()).thenThrow(Exception('Network error'));
  
  // Invalidate to refetch
  container.invalidate(productsProvider);
  
  try {
    await container.read(productsProvider.future);
  } catch (_) {}

  // Should be error state
  expect(container.read(productsProvider), isA<AsyncError<List<Product>>>());
});
```

### 3.2 BLoC Testing

```dart
// test/blocs/auth_bloc_test.dart
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late AuthBloc authBloc;
  late MockAuthRepository mockAuthRepository;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    authBloc = AuthBloc(authRepository: mockAuthRepository);
  });

  tearDown(() {
    authBloc.close();
  });

  group('AuthBloc', () {
    final tUser = User(id: '1', email: 'test@test.com');

    test('initial state is AuthInitial', () {
      expect(authBloc.state, AuthInitial());
    });

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthAuthenticated] when LoginRequested succeeds',
      build: () {
        when(() => mockAuthRepository.login(any(), any()))
            .thenAnswer((_) async => Right(tUser));
        return authBloc;
      },
      act: (bloc) => bloc.add(LoginRequested(
        email: 'test@test.com',
        password: 'password',
      )),
      expect: () => [
        AuthLoading(),
        AuthAuthenticated(tUser),
      ],
      verify: (_) {
        verify(() => mockAuthRepository.login('test@test.com', 'password')).called(1);
      },
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthError] when LoginRequested fails',
      build: () {
        when(() => mockAuthRepository.login(any(), any()))
            .thenAnswer((_) async => Left(AuthFailure('Invalid credentials')));
        return authBloc;
      },
      act: (bloc) => bloc.add(LoginRequested(
        email: 'test@test.com',
        password: 'wrong',
      )),
      expect: () => [
        AuthLoading(),
        AuthError('Invalid credentials'),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthInitial] when LogoutRequested is added',
      build: () {
        when(() => mockAuthRepository.logout())
            .thenAnswer((_) async => const Right(unit));
        return authBloc;
      },
      seed: () => AuthAuthenticated(tUser), // Start from authenticated
      act: (bloc) => bloc.add(LogoutRequested()),
      expect: () => [AuthInitial()],
    );
  });
}

// Cubit Testing
class MockProductRepository extends Mock implements ProductRepository {}

void main() {
  group('ProductCubit', () {
    late ProductCubit cubit;
    late MockProductRepository mockRepo;

    setUp(() {
      mockRepo = MockProductRepository();
      cubit = ProductCubit(repository: mockRepo);
    });

    tearDown(() => cubit.close());

    blocTest<ProductCubit, ProductState>(
      'emits [Loading, Loaded] when fetchProducts succeeds',
      build: () {
        when(() => mockRepo.getProducts())
            .thenAnswer((_) async => [Product(id: '1', name: 'Test')]);
        return cubit;
      },
      act: (cubit) => cubit.fetchProducts(),
      expect: () => [
        ProductLoading(),
        ProductLoaded([Product(id: '1', name: 'Test')]),
      ],
    );

    blocTest<ProductCubit, ProductState>(
      'emits [Loading, Error] when fetchProducts fails',
      build: () {
        when(() => mockRepo.getProducts()).thenThrow(Exception('Error'));
        return cubit;
      },
      act: (cubit) => cubit.fetchProducts(),
      expect: () => [
        ProductLoading(),
        isA<ProductError>(),
      ],
    );
  });
}
```

### 3.3 GetX Testing

```dart
// test/controllers/auth_controller_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late AuthController controller;
  late MockAuthRepository mockAuthRepository;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    
    // Reset GetX bindings
    Get.reset();
    
    // Register mock
    Get.put<AuthRepository>(mockAuthRepository);
    controller = AuthController();
    Get.put(controller);
  });

  tearDown(() {
    Get.reset();
  });

  group('AuthController', () {
    final tUser = User(id: '1', email: 'test@test.com');

    test('initial state is not loading and not authenticated', () {
      expect(controller.isLoading.value, false);
      expect(controller.isAuthenticated.value, false);
      expect(controller.user.value, isNull);
    });

    test('login success updates user and isAuthenticated', () async {
      // Arrange
      when(() => mockAuthRepository.login(any(), any()))
          .thenAnswer((_) async => Right(tUser));

      // Act
      await controller.login('test@test.com', 'password');

      // Assert
      expect(controller.isLoading.value, false);
      expect(controller.isAuthenticated.value, true);
      expect(controller.user.value, tUser);
      expect(controller.error.value, isNull);
    });

    test('login failure sets error message', () async {
      // Arrange
      when(() => mockAuthRepository.login(any(), any()))
          .thenAnswer((_) async => Left(AuthFailure('Invalid credentials')));

      // Act
      await controller.login('test@test.com', 'wrong');

      // Assert
      expect(controller.isLoading.value, false);
      expect(controller.isAuthenticated.value, false);
      expect(controller.error.value, 'Invalid credentials');
    });

    test('logout resets state', () async {
      // Arrange - Start authenticated
      controller.user.value = tUser;
      controller.isAuthenticated.value = true;
      when(() => mockAuthRepository.logout())
          .thenAnswer((_) async => const Right(unit));

      // Act
      await controller.logout();

      // Assert
      expect(controller.isAuthenticated.value, false);
      expect(controller.user.value, isNull);
    });
  });

  group('GetX Reactive Testing', () {
    test('ever() callback is called when observable changes', () async {
      final values = <int>[];
      final counter = 0.obs;

      ever(counter, (value) => values.add(value));

      counter.value = 1;
      counter.value = 2;
      counter.value = 3;

      await Future.delayed(Duration.zero); // Let reactions complete

      expect(values, [1, 2, 3]);
    });

    test('debounce works correctly', () async {
      final values = <int>[];
      final counter = 0.obs;

      debounce(
        counter,
        (value) => values.add(value),
        time: const Duration(milliseconds: 100),
      );

      counter.value = 1;
      counter.value = 2;
      counter.value = 3;

      await Future.delayed(const Duration(milliseconds: 150));

      expect(values, [3]); // Only last value after debounce
    });
  });

  group('GetX Service Testing', () {
    test('GetxService initializes correctly', () async {
      final service = TestService();
      Get.put(service);

      await service.onInit();
      
      expect(service.isInitialized, true);
      expect(Get.find<TestService>(), service);
    });
  });
}

// Helper for testing GetxController lifecycle
class TestableController extends GetxController {
  bool onInitCalled = false;
  bool onReadyCalled = false;
  bool onCloseCalled = false;

  @override
  void onInit() {
    onInitCalled = true;
    super.onInit();
  }

  @override
  void onReady() {
    onReadyCalled = true;
    super.onReady();
  }

  @override
  void onClose() {
    onCloseCalled = true;
    super.onClose();
  }
}

test('GetxController lifecycle', () async {
  Get.put(TestableController());
  final controller = Get.find<TestableController>();

  // onInit is called immediately
  expect(controller.onInitCalled, true);

  // Simulate frame callback for onReady
  await Future.delayed(Duration.zero);
  
  Get.delete<TestableController>();
  expect(controller.onCloseCalled, true);
});
```

---

## Part 4: Widget Tests

### Basic Widget Test

```dart
// test/widgets/login_screen_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

void main() {
  group('LoginScreen', () {
    testWidgets('should show validation error when email is empty', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(home: LoginScreen()),
        ),
      );

      // Tap login without entering email
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      expect(find.text('Email is required'), findsOneWidget);
    });

    testWidgets('should show loading indicator when logging in', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authNotifierProvider.overrideWith(() => MockAuthNotifier()),
          ],
          child: const MaterialApp(home: LoginScreen()),
        ),
      );

      await tester.enterText(find.byKey(const Key('email_field')), 'test@example.com');
      await tester.enterText(find.byKey(const Key('password_field')), 'password');
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });
}
```

### Widget Test with BLoC

```dart
// test/widgets/products_page_bloc_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';

class MockProductBloc extends MockBloc<ProductEvent, ProductState>
    implements ProductBloc {}

void main() {
  late MockProductBloc mockBloc;

  setUp(() {
    mockBloc = MockProductBloc();
  });

  group('ProductsPage with BLoC', () {
    testWidgets('shows loading indicator when state is Loading', (tester) async {
      when(() => mockBloc.state).thenReturn(ProductLoading());

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<ProductBloc>.value(
            value: mockBloc,
            child: const ProductsPage(),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows products when state is Loaded', (tester) async {
      final products = [
        Product(id: '1', name: 'Product 1'),
        Product(id: '2', name: 'Product 2'),
      ];
      when(() => mockBloc.state).thenReturn(ProductLoaded(products));

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<ProductBloc>.value(
            value: mockBloc,
            child: const ProductsPage(),
          ),
        ),
      );

      expect(find.text('Product 1'), findsOneWidget);
      expect(find.text('Product 2'), findsOneWidget);
    });

    testWidgets('shows error message when state is Error', (tester) async {
      when(() => mockBloc.state).thenReturn(ProductError('Failed to load'));

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<ProductBloc>.value(
            value: mockBloc,
            child: const ProductsPage(),
          ),
        ),
      );

      expect(find.text('Failed to load'), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget); // Retry button
    });

    testWidgets('dispatches FetchProducts when retry is tapped', (tester) async {
      when(() => mockBloc.state).thenReturn(ProductError('Failed'));

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<ProductBloc>.value(
            value: mockBloc,
            child: const ProductsPage(),
          ),
        ),
      );

      await tester.tap(find.text('Retry'));

      verify(() => mockBloc.add(FetchProducts())).called(1);
    });
  });
}
```

### Widget Test with GetX

```dart
// test/widgets/home_page_getx_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mocktail/mocktail.dart';

class MockHomeController extends GetxController
    with Mock
    implements HomeController {
  @override
  final products = <Product>[].obs;
  
  @override
  final isLoading = false.obs;
  
  @override
  final error = Rxn<String>();
}

void main() {
  late MockHomeController mockController;

  setUp(() {
    Get.reset();
    mockController = MockHomeController();
    Get.put<HomeController>(mockController);
  });

  tearDown(() {
    Get.reset();
  });

  group('HomePage with GetX', () {
    testWidgets('shows products from controller', (tester) async {
      mockController.products.value = [
        Product(id: '1', name: 'Product 1'),
        Product(id: '2', name: 'Product 2'),
      ];

      await tester.pumpWidget(
        GetMaterialApp(home: HomePage()),
      );

      expect(find.text('Product 1'), findsOneWidget);
      expect(find.text('Product 2'), findsOneWidget);
    });

    testWidgets('shows loading when isLoading is true', (tester) async {
      mockController.isLoading.value = true;

      await tester.pumpWidget(
        GetMaterialApp(home: HomePage()),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('updates UI when observable changes', (tester) async {
      await tester.pumpWidget(
        GetMaterialApp(home: HomePage()),
      );

      // Initially empty
      expect(find.byType(ProductCard), findsNothing);

      // Update observable
      mockController.products.add(Product(id: '1', name: 'New Product'));
      await tester.pump();

      // UI should update
      expect(find.text('New Product'), findsOneWidget);
    });
  });
}
```

---

## Part 5: Firebase Integration Testing

### 5.1 Firebase Auth Testing

```dart
// test/services/firebase_auth_service_test.dart
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FirebaseAuthService', () {
    late MockFirebaseAuth mockAuth;
    late FirebaseAuthService authService;

    setUp(() {
      mockAuth = MockFirebaseAuth();
      authService = FirebaseAuthService(firebaseAuth: mockAuth);
    });

    test('signInWithEmailPassword returns user on success', () async {
      final mockUser = MockUser(
        uid: 'test-uid',
        email: 'test@example.com',
        displayName: 'Test User',
      );
      mockAuth = MockFirebaseAuth(mockUser: mockUser);
      authService = FirebaseAuthService(firebaseAuth: mockAuth);

      final result = await authService.signInWithEmailPassword(
        email: 'test@example.com',
        password: 'password123',
      );

      expect(result.uid, 'test-uid');
      expect(result.email, 'test@example.com');
      expect(mockAuth.currentUser, isNotNull);
    });

    test('signInWithEmailPassword throws on invalid credentials', () async {
      mockAuth = MockFirebaseAuth(
        authExceptions: AuthExceptions(
          signInWithEmailAndPassword: FirebaseAuthException(
            code: 'wrong-password',
            message: 'Wrong password',
          ),
        ),
      );
      authService = FirebaseAuthService(firebaseAuth: mockAuth);

      expect(
        () => authService.signInWithEmailPassword(
          email: 'test@example.com',
          password: 'wrong',
        ),
        throwsA(isA<FirebaseAuthException>()),
      );
    });

    test('signOut clears current user', () async {
      final mockUser = MockUser(uid: 'test-uid');
      mockAuth = MockFirebaseAuth(mockUser: mockUser, signedIn: true);
      authService = FirebaseAuthService(firebaseAuth: mockAuth);

      expect(mockAuth.currentUser, isNotNull);

      await authService.signOut();

      expect(mockAuth.currentUser, isNull);
    });

    test('authStateChanges emits user on sign in', () async {
      final mockUser = MockUser(uid: 'test-uid');
      mockAuth = MockFirebaseAuth(mockUser: mockUser);
      authService = FirebaseAuthService(firebaseAuth: mockAuth);

      final stream = authService.authStateChanges();

      await authService.signInWithEmailPassword(
        email: 'test@example.com',
        password: 'password',
      );

      await expectLater(
        stream,
        emitsInOrder([isNull, isA<User>()]),
      );
    });
  });
}
```

### 5.2 Firestore Testing

```dart
// test/repositories/product_repository_firestore_test.dart
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ProductRepository with Firestore', () {
    late FakeFirebaseFirestore fakeFirestore;
    late ProductRepository repository;

    setUp(() {
      fakeFirestore = FakeFirebaseFirestore();
      repository = ProductRepository(firestore: fakeFirestore);
    });

    test('getProducts returns list of products', () async {
      // Arrange - Add test data
      await fakeFirestore.collection('products').add({
        'name': 'Product 1',
        'price': 100,
        'category': 'electronics',
      });
      await fakeFirestore.collection('products').add({
        'name': 'Product 2',
        'price': 200,
        'category': 'clothing',
      });

      // Act
      final products = await repository.getProducts();

      // Assert
      expect(products.length, 2);
      expect(products[0].name, 'Product 1');
      expect(products[1].name, 'Product 2');
    });

    test('addProduct creates document in Firestore', () async {
      final product = Product(
        name: 'New Product',
        price: 150,
        category: 'books',
      );

      await repository.addProduct(product);

      final snapshot = await fakeFirestore.collection('products').get();
      expect(snapshot.docs.length, 1);
      expect(snapshot.docs.first.data()['name'], 'New Product');
    });

    test('updateProduct modifies existing document', () async {
      // Create initial product
      final docRef = await fakeFirestore.collection('products').add({
        'name': 'Old Name',
        'price': 100,
      });

      // Update
      await repository.updateProduct(
        docRef.id,
        Product(name: 'New Name', price: 150),
      );

      // Verify
      final doc = await fakeFirestore.collection('products').doc(docRef.id).get();
      expect(doc.data()!['name'], 'New Name');
      expect(doc.data()!['price'], 150);
    });

    test('deleteProduct removes document', () async {
      final docRef = await fakeFirestore.collection('products').add({
        'name': 'To Delete',
      });

      await repository.deleteProduct(docRef.id);

      final doc = await fakeFirestore.collection('products').doc(docRef.id).get();
      expect(doc.exists, false);
    });

    test('getProductsByCategory filters correctly', () async {
      await fakeFirestore.collection('products').add({
        'name': 'Electronics Item',
        'category': 'electronics',
      });
      await fakeFirestore.collection('products').add({
        'name': 'Clothing Item',
        'category': 'clothing',
      });

      final electronics = await repository.getProductsByCategory('electronics');

      expect(electronics.length, 1);
      expect(electronics[0].name, 'Electronics Item');
    });

    test('streamProducts emits updates', () async {
      final stream = repository.streamProducts();

      // Add product after starting stream
      await fakeFirestore.collection('products').add({'name': 'Streamed'});

      await expectLater(
        stream,
        emits(predicate<List<Product>>((products) =>
            products.length == 1 && products[0].name == 'Streamed')),
      );
    });
  });
}
```

### 5.3 Firebase Storage Testing

```dart
// test/services/storage_service_test.dart
import 'package:firebase_storage_mocks/firebase_storage_mocks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'dart:typed_data';

void main() {
  group('StorageService', () {
    late MockFirebaseStorage mockStorage;
    late StorageService storageService;

    setUp(() {
      mockStorage = MockFirebaseStorage();
      storageService = StorageService(storage: mockStorage);
    });

    test('uploadFile returns download URL', () async {
      final bytes = Uint8List.fromList([1, 2, 3, 4, 5]);

      final url = await storageService.uploadFile(
        path: 'images/test.png',
        bytes: bytes,
      );

      expect(url, isNotEmpty);
      expect(url, contains('test.png'));
    });

    test('deleteFile removes file from storage', () async {
      // Upload first
      final bytes = Uint8List.fromList([1, 2, 3]);
      await storageService.uploadFile(path: 'images/to-delete.png', bytes: bytes);

      // Delete
      await storageService.deleteFile('images/to-delete.png');

      // Verify - trying to get URL should fail
      expect(
        () => mockStorage.ref('images/to-delete.png').getDownloadURL(),
        throwsA(anything),
      );
    });
  });
}
```

---

## Part 6: Supabase Integration Testing

### 6.1 Supabase Auth Testing

```dart
// test/services/supabase_auth_service_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MockSupabaseClient extends Mock implements SupabaseClient {}
class MockGoTrueClient extends Mock implements GoTrueClient {}
class MockAuthResponse extends Mock implements AuthResponse {}
class MockSession extends Mock implements Session {}
class MockUser extends Mock implements User {}

void main() {
  late MockSupabaseClient mockSupabase;
  late MockGoTrueClient mockAuth;
  late SupabaseAuthService authService;

  setUp(() {
    mockSupabase = MockSupabaseClient();
    mockAuth = MockGoTrueClient();
    when(() => mockSupabase.auth).thenReturn(mockAuth);
    authService = SupabaseAuthService(client: mockSupabase);
  });

  group('SupabaseAuthService', () {
    test('signIn returns user on success', () async {
      // Arrange
      final mockUser = MockUser();
      final mockSession = MockSession();
      final mockResponse = MockAuthResponse();

      when(() => mockUser.id).thenReturn('user-123');
      when(() => mockUser.email).thenReturn('test@example.com');
      when(() => mockSession.user).thenReturn(mockUser);
      when(() => mockResponse.session).thenReturn(mockSession);
      when(() => mockResponse.user).thenReturn(mockUser);

      when(() => mockAuth.signInWithPassword(
        email: any(named: 'email'),
        password: any(named: 'password'),
      )).thenAnswer((_) async => mockResponse);

      // Act
      final result = await authService.signIn(
        email: 'test@example.com',
        password: 'password123',
      );

      // Assert
      expect(result.id, 'user-123');
      expect(result.email, 'test@example.com');
    });

    test('signUp creates new user', () async {
      final mockUser = MockUser();
      final mockResponse = MockAuthResponse();

      when(() => mockUser.id).thenReturn('new-user-123');
      when(() => mockResponse.user).thenReturn(mockUser);

      when(() => mockAuth.signUp(
        email: any(named: 'email'),
        password: any(named: 'password'),
        data: any(named: 'data'),
      )).thenAnswer((_) async => mockResponse);

      final result = await authService.signUp(
        email: 'new@example.com',
        password: 'password123',
        userData: {'name': 'New User'},
      );

      expect(result.id, 'new-user-123');
    });

    test('signOut calls auth.signOut', () async {
      when(() => mockAuth.signOut()).thenAnswer((_) async {});

      await authService.signOut();

      verify(() => mockAuth.signOut()).called(1);
    });

    test('currentUser returns current session user', () {
      final mockUser = MockUser();
      when(() => mockUser.id).thenReturn('current-user');
      when(() => mockAuth.currentUser).thenReturn(mockUser);

      final user = authService.currentUser;

      expect(user?.id, 'current-user');
    });
  });
}
```

### 6.2 Supabase Database Testing

```dart
// test/repositories/supabase_product_repository_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MockSupabaseClient extends Mock implements SupabaseClient {}
class MockSupabaseQueryBuilder extends Mock implements SupabaseQueryBuilder {}
class MockPostgrestFilterBuilder extends Mock implements PostgrestFilterBuilder {}
class MockPostgrestResponse extends Mock implements PostgrestResponse {}

void main() {
  late MockSupabaseClient mockSupabase;
  late ProductRepository repository;

  setUp(() {
    mockSupabase = MockSupabaseClient();
    repository = ProductRepository(client: mockSupabase);
  });

  group('ProductRepository with Supabase', () {
    test('getProducts returns list of products', () async {
      // Arrange
      final mockQueryBuilder = MockSupabaseQueryBuilder();
      final mockFilterBuilder = MockPostgrestFilterBuilder();

      when(() => mockSupabase.from('products')).thenReturn(mockQueryBuilder);
      when(() => mockQueryBuilder.select()).thenReturn(mockFilterBuilder);
      when(() => mockFilterBuilder.order('created_at'))
          .thenReturn(mockFilterBuilder);

      // Mock the response data
      when(() => mockFilterBuilder.then(any())).thenAnswer((_) async => [
        {'id': '1', 'name': 'Product 1', 'price': 100},
        {'id': '2', 'name': 'Product 2', 'price': 200},
      ]);

      // Act
      final products = await repository.getProducts();

      // Assert
      expect(products.length, 2);
      expect(products[0].name, 'Product 1');
    });

    test('addProduct inserts and returns new product', () async {
      final mockQueryBuilder = MockSupabaseQueryBuilder();
      final mockFilterBuilder = MockPostgrestFilterBuilder();

      when(() => mockSupabase.from('products')).thenReturn(mockQueryBuilder);
      when(() => mockQueryBuilder.insert(any())).thenReturn(mockFilterBuilder);
      when(() => mockFilterBuilder.select()).thenReturn(mockFilterBuilder);
      when(() => mockFilterBuilder.single()).thenAnswer((_) async => {
        'id': 'new-id',
        'name': 'New Product',
        'price': 150,
      });

      final product = await repository.addProduct(
        Product(name: 'New Product', price: 150),
      );

      expect(product.id, 'new-id');
      expect(product.name, 'New Product');
    });

    test('updateProduct modifies existing product', () async {
      final mockQueryBuilder = MockSupabaseQueryBuilder();
      final mockFilterBuilder = MockPostgrestFilterBuilder();

      when(() => mockSupabase.from('products')).thenReturn(mockQueryBuilder);
      when(() => mockQueryBuilder.update(any())).thenReturn(mockFilterBuilder);
      when(() => mockFilterBuilder.eq('id', any())).thenReturn(mockFilterBuilder);
      when(() => mockFilterBuilder.select()).thenReturn(mockFilterBuilder);
      when(() => mockFilterBuilder.single()).thenAnswer((_) async => {
        'id': '1',
        'name': 'Updated Name',
        'price': 200,
      });

      final product = await repository.updateProduct(
        '1',
        Product(name: 'Updated Name', price: 200),
      );

      expect(product.name, 'Updated Name');
    });

    test('deleteProduct removes product', () async {
      final mockQueryBuilder = MockSupabaseQueryBuilder();
      final mockFilterBuilder = MockPostgrestFilterBuilder();

      when(() => mockSupabase.from('products')).thenReturn(mockQueryBuilder);
      when(() => mockQueryBuilder.delete()).thenReturn(mockFilterBuilder);
      when(() => mockFilterBuilder.eq('id', any())).thenReturn(mockFilterBuilder);

      await repository.deleteProduct('1');

      verify(() => mockQueryBuilder.delete()).called(1);
    });
  });
}
```

### 6.3 Supabase Realtime Testing

```dart
// test/services/supabase_realtime_test.dart
import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MockSupabaseClient extends Mock implements SupabaseClient {}
class MockRealtimeClient extends Mock implements RealtimeClient {}
class MockRealtimeChannel extends Mock implements RealtimeChannel {}

void main() {
  group('RealtimeService', () {
    late MockSupabaseClient mockSupabase;
    late MockRealtimeChannel mockChannel;
    late RealtimeService realtimeService;

    setUp(() {
      mockSupabase = MockSupabaseClient();
      mockChannel = MockRealtimeChannel();
      realtimeService = RealtimeService(client: mockSupabase);
    });

    test('subscribeToProducts sets up channel subscription', () {
      when(() => mockSupabase.channel(any())).thenReturn(mockChannel);
      when(() => mockChannel.onPostgresChanges(
        event: any(named: 'event'),
        schema: any(named: 'schema'),
        table: any(named: 'table'),
        callback: any(named: 'callback'),
      )).thenReturn(mockChannel);
      when(() => mockChannel.subscribe()).thenReturn(mockChannel);

      realtimeService.subscribeToProducts(
        onInsert: (product) {},
        onUpdate: (product) {},
        onDelete: (id) {},
      );

      verify(() => mockSupabase.channel('products_changes')).called(1);
      verify(() => mockChannel.subscribe()).called(1);
    });

    test('unsubscribe removes channel', () async {
      when(() => mockSupabase.channel(any())).thenReturn(mockChannel);
      when(() => mockChannel.unsubscribe()).thenAnswer((_) async => 'ok');
      when(() => mockSupabase.removeChannel(any()))
          .thenAnswer((_) async => 'ok');

      await realtimeService.unsubscribe('products_changes');

      verify(() => mockChannel.unsubscribe()).called(1);
    });
  });
}

// Testing with StreamController for simulating realtime events
test('realtime updates are processed correctly', () async {
  final controller = StreamController<PostgresChangePayload>();
  
  final products = <Product>[];
  
  controller.stream.listen((payload) {
    if (payload.eventType == PostgresChangeEvent.insert) {
      products.add(Product.fromJson(payload.newRecord));
    }
  });

  // Simulate insert event
  controller.add(PostgresChangePayload(
    eventType: PostgresChangeEvent.insert,
    newRecord: {'id': '1', 'name': 'New Product'},
    oldRecord: {},
  ));

  await Future.delayed(Duration.zero);

  expect(products.length, 1);
  expect(products[0].name, 'New Product');

  await controller.close();
});
```

### 6.4 Supabase RPC Testing

```dart
// test/services/supabase_rpc_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MockSupabaseClient extends Mock implements SupabaseClient {}

void main() {
  group('Supabase RPC Functions', () {
    late MockSupabaseClient mockSupabase;
    late AnalyticsService analyticsService;

    setUp(() {
      mockSupabase = MockSupabaseClient();
      analyticsService = AnalyticsService(client: mockSupabase);
    });

    test('getDashboardStats calls RPC and returns stats', () async {
      when(() => mockSupabase.rpc(
        'get_dashboard_stats',
        params: any(named: 'params'),
      )).thenAnswer((_) async => {
        'total_users': 100,
        'total_orders': 50,
        'revenue': 10000.0,
      });

      final stats = await analyticsService.getDashboardStats();

      expect(stats.totalUsers, 100);
      expect(stats.totalOrders, 50);
      expect(stats.revenue, 10000.0);
    });

    test('searchProducts calls RPC with search params', () async {
      when(() => mockSupabase.rpc(
        'search_products',
        params: {'query': 'laptop', 'limit': 10},
      )).thenAnswer((_) async => [
        {'id': '1', 'name': 'Laptop Pro'},
        {'id': '2', 'name': 'Gaming Laptop'},
      ]);

      final results = await analyticsService.searchProducts('laptop', limit: 10);

      expect(results.length, 2);
      expect(results[0].name, 'Laptop Pro');
    });
  });
}
```

---

## Part 7: Golden Tests

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

---

## Part 8: Integration Tests

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

---

## Best Practices

### ✅ Do This

- ✅ Test behavior, not implementation
- ✅ Use descriptive test names
- ✅ Keep tests independent
- ✅ Mock external dependencies (Firebase, Supabase, APIs)
- ✅ Run tests in CI/CD
- ✅ Use `setUp()` and `tearDown()` for test isolation
- ✅ Test error states and edge cases
- ✅ Use `blocTest` for BLoC testing
- ✅ Use `ProviderContainer` for Riverpod testing
- ✅ Reset GetX bindings between tests

### ❌ Avoid This

- ❌ Don't test Flutter framework itself
- ❌ Don't write flaky tests
- ❌ Don't skip edge cases
- ❌ Don't over-mock (test real behavior when possible)
- ❌ Don't forget to dispose controllers/containers
- ❌ Don't test private methods directly

---

## Related Skills

- `@senior-flutter-developer` - Flutter development
- `@flutter-riverpod-specialist` - Riverpod patterns
- `@flutter-bloc-specialist` - BLoC patterns
- `@flutter-getx-specialist` - GetX patterns
- `@flutter-firebase-developer` - Firebase integration
- `@flutter-supabase-developer` - Supabase integration
- `@tdd-workflow` - Test-driven development

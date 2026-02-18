# Workflow: Testing & Production (Flutter BLoC)

## Overview

Comprehensive testing (unit, widget, integration) dan production preparation khusus Flutter BLoC: `bloc_test` package, `MockBloc`, `whenListen`, CI/CD pipeline dengan `build_runner`, performance optimization, dan app store deployment.

**Perbedaan Utama dari Riverpod:**
- Testing pakai `bloc_test` package, bukan `ProviderContainer`
- `blocTest<Bloc, State>()` sebagai primary testing function
- Widget test wrap dengan `BlocProvider.value()`, bukan `ProviderScope`
- `MockBloc` / `MockCubit` dari `bloc_test` untuk widget tests
- `whenListen` untuk mock bloc streams
- `tearDown` wajib `bloc.close()` untuk prevent memory leaks
- CI/CD butuh `build_runner` step (untuk freezed/injectable code generation)

## Output Location

**Base Folder:** `sdlc/flutter-bloc/06-testing-production/`

**Output Files:**
- `testing/unit/` - Bloc unit tests dengan `blocTest`
- `testing/widget/` - Widget tests dengan `MockBloc`
- `testing/integration/` - Integration tests
- `testing/helpers/` - Test helpers, mocks, fixtures
- `ci-cd/` - GitHub Actions workflows
- `performance/` - Performance optimization guide
- `deployment/` - App store deployment guides
- `checklists/` - Production checklists

## Prerequisites

- Project setup dari `01_project_setup.md` selesai (clean architecture + injectable)
- Backend integration (REST API, Firebase, atau Supabase) selesai
- Features implemented dan functional
- `build_runner` configured dan berjalan tanpa error

## Deliverables

### 1. Unit Testing dengan bloc_test

**Description:** Unit tests untuk Blocs, Cubits, use cases, dan repositories menggunakan `bloc_test` package. Ini adalah fondasi testing di arsitektur BLoC — setiap Bloc HARUS punya blocTest coverage.

**Recommended Skills:** `senior-flutter-developer`, `python-testing-specialist`, `tdd-workflow`

**Instructions:**
1. **Test Dependencies (pubspec.yaml):**
   - `flutter_test` (built-in)
   - `bloc_test` — wajib, ini core testing library
   - `mocktail` — untuk mocking dependencies
   - `fake_async` — untuk time-based testing
   - `dartz` — jika pakai Either/functional error handling

2. **Test Setup Pattern:**
   - `setUp`: instantiate mock dependencies, create bloc
   - `tearDown`: WAJIB `bloc.close()` — ini sering terlupa dan menyebabkan memory leak di test
   - `build`: return bloc (bisa setup when/thenAnswer di sini)
   - `act`: add event ke bloc
   - `expect`: list of expected state transitions (ordered)
   - `verify`: verify mock interactions

3. **Test Categories:**
   - Bloc/Cubit tests (primary focus)
   - Use case tests (same as Riverpod)
   - Repository tests (same as Riverpod)
   - Service/data source tests

4. **Coverage Target:**
   - Minimum 80% code coverage overall
   - 100% coverage untuk semua Bloc/Cubit classes
   - 100% coverage untuk critical paths (auth, payment)

**Output Format:**

```dart
// test/features/product/presentation/bloc/product_bloc_test.dart
import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:my_app/core/error/failures.dart';
import 'package:my_app/features/product/domain/entities/product.dart';
import 'package:my_app/features/product/domain/usecases/get_products.dart';
import 'package:my_app/features/product/domain/usecases/create_product.dart';
import 'package:my_app/features/product/domain/usecases/delete_product.dart';
import 'package:my_app/features/product/presentation/bloc/product_bloc.dart';

// ========================================
// Mock Classes
// ========================================
class MockGetProducts extends Mock implements GetProducts {}
class MockCreateProduct extends Mock implements CreateProduct {}
class MockDeleteProduct extends Mock implements DeleteProduct {}

// Fake classes untuk registerFallbackValue
class FakeGetProductsParams extends Fake implements GetProductsParams {}
class FakeCreateProductParams extends Fake implements CreateProductParams {}

void main() {
  late ProductBloc bloc;
  late MockGetProducts mockGetProducts;
  late MockCreateProduct mockCreateProduct;
  late MockDeleteProduct mockDeleteProduct;

  // Test fixtures
  final tProduct = Product(
    id: '1',
    name: 'Test Product',
    price: 99.99,
    description: 'A test product',
    imageUrl: 'https://example.com/image.png',
    createdAt: DateTime(2024, 1, 1),
  );

  final tProductList = [tProduct];

  // Register fallback values untuk mocktail any() matcher
  setUpAll(() {
    registerFallbackValue(FakeGetProductsParams());
    registerFallbackValue(FakeCreateProductParams());
  });

  setUp(() {
    mockGetProducts = MockGetProducts();
    mockCreateProduct = MockCreateProduct();
    mockDeleteProduct = MockDeleteProduct();
    bloc = ProductBloc(
      getProducts: mockGetProducts,
      createProduct: mockCreateProduct,
      deleteProduct: mockDeleteProduct,
    );
  });

  // CRITICAL: Selalu close bloc di tearDown!
  // Tanpa ini, streams tidak di-dispose dan test bisa hang/leak
  tearDown(() => bloc.close());

  // ========================================
  // Initial State Test
  // ========================================
  test('initial state should be ProductInitial', () {
    expect(bloc.state, equals(const ProductInitial()));
  });

  // ========================================
  // LoadProducts Event Tests
  // ========================================
  group('LoadProducts', () {
    blocTest<ProductBloc, ProductState>(
      'emits [ProductLoading, ProductLoaded] when LoadProducts is added '
      'and getProducts returns data successfully',
      build: () {
        when(() => mockGetProducts(any())).thenAnswer(
          (_) async => Right(tProductList),
        );
        return bloc;
      },
      act: (bloc) => bloc.add(const LoadProducts()),
      expect: () => [
        const ProductLoading(),
        ProductLoaded(products: tProductList),
      ],
      verify: (_) {
        verify(() => mockGetProducts(any())).called(1);
      },
    );

    blocTest<ProductBloc, ProductState>(
      'emits [ProductLoading, ProductLoaded] with empty list '
      'when getProducts returns empty data',
      build: () {
        when(() => mockGetProducts(any())).thenAnswer(
          (_) async => const Right([]),
        );
        return bloc;
      },
      act: (bloc) => bloc.add(const LoadProducts()),
      expect: () => [
        const ProductLoading(),
        const ProductLoaded(products: []),
      ],
    );

    blocTest<ProductBloc, ProductState>(
      'emits [ProductLoading, ProductError] when LoadProducts fails '
      'with ServerFailure',
      build: () {
        when(() => mockGetProducts(any())).thenAnswer(
          (_) async => Left(ServerFailure('Server error')),
        );
        return bloc;
      },
      act: (bloc) => bloc.add(const LoadProducts()),
      expect: () => [
        const ProductLoading(),
        const ProductError(message: 'Server error'),
      ],
    );

    blocTest<ProductBloc, ProductState>(
      'emits [ProductLoading, ProductError] when LoadProducts fails '
      'with NetworkFailure',
      build: () {
        when(() => mockGetProducts(any())).thenAnswer(
          (_) async => Left(NetworkFailure('No internet connection')),
        );
        return bloc;
      },
      act: (bloc) => bloc.add(const LoadProducts()),
      expect: () => [
        const ProductLoading(),
        const ProductError(message: 'No internet connection'),
      ],
    );
  });

  // ========================================
  // CreateProduct Event Tests
  // ========================================
  group('CreateProduct', () {
    blocTest<ProductBloc, ProductState>(
      'emits [ProductLoading, ProductCreated] when product is created '
      'successfully, then reloads product list',
      build: () {
        when(() => mockCreateProduct(any())).thenAnswer(
          (_) async => Right(tProduct),
        );
        when(() => mockGetProducts(any())).thenAnswer(
          (_) async => Right(tProductList),
        );
        return bloc;
      },
      act: (bloc) => bloc.add(CreateProductEvent(
        name: 'Test Product',
        price: 99.99,
        description: 'A test product',
      )),
      expect: () => [
        const ProductLoading(),
        ProductCreated(product: tProduct),
        // Bloc otomatis reload list setelah create
        ProductLoaded(products: tProductList),
      ],
      verify: (_) {
        verify(() => mockCreateProduct(any())).called(1);
        verify(() => mockGetProducts(any())).called(1);
      },
    );

    blocTest<ProductBloc, ProductState>(
      'emits [ProductLoading, ProductError] when create product fails',
      build: () {
        when(() => mockCreateProduct(any())).thenAnswer(
          (_) async => Left(ServerFailure('Validation error')),
        );
        return bloc;
      },
      act: (bloc) => bloc.add(CreateProductEvent(
        name: '',
        price: -1,
        description: '',
      )),
      expect: () => [
        const ProductLoading(),
        const ProductError(message: 'Validation error'),
      ],
    );
  });

  // ========================================
  // DeleteProduct Event Tests
  // ========================================
  group('DeleteProduct', () {
    blocTest<ProductBloc, ProductState>(
      'emits [ProductLoading, ProductDeleted, ProductLoaded] '
      'when delete is successful',
      build: () {
        when(() => mockDeleteProduct(any())).thenAnswer(
          (_) async => const Right(unit),
        );
        when(() => mockGetProducts(any())).thenAnswer(
          (_) async => const Right([]),
        );
        return bloc;
      },
      act: (bloc) => bloc.add(const DeleteProductEvent(id: '1')),
      expect: () => [
        const ProductLoading(),
        const ProductDeleted(),
        const ProductLoaded(products: []),
      ],
    );
  });

  // ========================================
  // Debounce / Transformer Tests
  // ========================================
  group('SearchProducts (debounced)', () {
    blocTest<ProductBloc, ProductState>(
      'debounces SearchProducts events (hanya event terakhir diproses)',
      build: () {
        when(() => mockGetProducts(any())).thenAnswer(
          (_) async => Right(tProductList),
        );
        return bloc;
      },
      act: (bloc) async {
        bloc.add(const SearchProducts(query: 'T'));
        bloc.add(const SearchProducts(query: 'Te'));
        bloc.add(const SearchProducts(query: 'Tes'));
        bloc.add(const SearchProducts(query: 'Test'));
      },
      wait: const Duration(milliseconds: 500),
      expect: () => [
        const ProductLoading(),
        ProductLoaded(products: tProductList),
      ],
      verify: (_) {
        // Karena debounce, hanya dipanggil sekali
        verify(() => mockGetProducts(any())).called(1);
      },
    );
  });

  // ========================================
  // Seed State Tests
  // ========================================
  group('Seed State', () {
    blocTest<ProductBloc, ProductState>(
      'can seed initial state untuk test dari specific state',
      seed: () => ProductLoaded(products: tProductList),
      build: () {
        when(() => mockDeleteProduct(any())).thenAnswer(
          (_) async => const Right(unit),
        );
        when(() => mockGetProducts(any())).thenAnswer(
          (_) async => const Right([]),
        );
        return bloc;
      },
      act: (bloc) => bloc.add(const DeleteProductEvent(id: '1')),
      expect: () => [
        const ProductLoading(),
        const ProductDeleted(),
        const ProductLoaded(products: []),
      ],
    );
  });
}

// ========================================
// test/features/auth/presentation/bloc/auth_bloc_test.dart
// ========================================
class MockLoginUseCase extends Mock implements LoginUseCase {}
class MockLogoutUseCase extends Mock implements LogoutUseCase {}
class MockGetCurrentUser extends Mock implements GetCurrentUser {}

class FakeLoginParams extends Fake implements LoginParams {}

void main() {
  late AuthBloc bloc;
  late MockLoginUseCase mockLogin;
  late MockLogoutUseCase mockLogout;
  late MockGetCurrentUser mockGetCurrentUser;

  final tUser = User(id: '1', email: 'test@example.com', name: 'Test User');

  setUpAll(() {
    registerFallbackValue(FakeLoginParams());
  });

  setUp(() {
    mockLogin = MockLoginUseCase();
    mockLogout = MockLogoutUseCase();
    mockGetCurrentUser = MockGetCurrentUser();
    bloc = AuthBloc(
      login: mockLogin,
      logout: mockLogout,
      getCurrentUser: mockGetCurrentUser,
    );
  });

  tearDown(() => bloc.close());

  group('LoginRequested', () {
    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthAuthenticated] on successful login',
      build: () {
        when(() => mockLogin(any())).thenAnswer(
          (_) async => Right(tUser),
        );
        return bloc;
      },
      act: (bloc) => bloc.add(const LoginRequested(
        email: 'test@example.com',
        password: 'password123',
      )),
      expect: () => [
        const AuthLoading(),
        AuthAuthenticated(user: tUser),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthError] on failed login',
      build: () {
        when(() => mockLogin(any())).thenAnswer(
          (_) async => const Left(AuthFailure('Invalid credentials')),
        );
        return bloc;
      },
      act: (bloc) => bloc.add(const LoginRequested(
        email: 'wrong@email.com',
        password: 'wrong',
      )),
      expect: () => [
        const AuthLoading(),
        const AuthError(message: 'Invalid credentials'),
      ],
    );
  });

  group('LogoutRequested', () {
    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthUnauthenticated] on logout',
      seed: () => AuthAuthenticated(user: tUser),
      build: () {
        when(() => mockLogout()).thenAnswer((_) async => const Right(unit));
        return bloc;
      },
      act: (bloc) => bloc.add(const LogoutRequested()),
      expect: () => [
        const AuthLoading(),
        const AuthUnauthenticated(),
      ],
    );
  });
}
```

**Cubit Testing Pattern:**

```dart
// test/features/settings/presentation/cubit/theme_cubit_test.dart
// Cubit lebih simple karena tidak ada Event — langsung panggil method

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late ThemeCubit cubit;
  late MockThemeRepository mockRepo;

  setUp(() {
    mockRepo = MockThemeRepository();
    cubit = ThemeCubit(repository: mockRepo);
  });

  tearDown(() => cubit.close());

  blocTest<ThemeCubit, ThemeState>(
    'emits [ThemeState(isDark: true)] when toggleTheme called from light mode',
    seed: () => const ThemeState(isDark: false),
    build: () {
      when(() => mockRepo.saveTheme(any())).thenAnswer((_) async {});
      return cubit;
    },
    act: (cubit) => cubit.toggleTheme(),
    expect: () => [
      const ThemeState(isDark: true),
    ],
  );
}
```

**Use Case Testing (sama dengan Riverpod):**

```dart
// test/features/product/domain/usecases/get_products_test.dart
class MockProductRepository extends Mock implements ProductRepository {}

void main() {
  late GetProducts useCase;
  late MockProductRepository mockRepository;

  setUp(() {
    mockRepository = MockProductRepository();
    useCase = GetProducts(mockRepository);
  });

  final tProducts = [
    Product(id: '1', name: 'Product 1', price: 10.0),
    Product(id: '2', name: 'Product 2', price: 20.0),
  ];

  test('should get products from repository', () async {
    // Arrange
    when(() => mockRepository.getProducts(page: any(named: 'page')))
        .thenAnswer((_) async => Right(tProducts));

    // Act
    final result = await useCase(const GetProductsParams(page: 1));

    // Assert
    expect(result, Right(tProducts));
    verify(() => mockRepository.getProducts(page: 1)).called(1);
    verifyNoMoreInteractions(mockRepository);
  });

  test('should return failure when repository fails', () async {
    when(() => mockRepository.getProducts(page: any(named: 'page')))
        .thenAnswer((_) async => Left(ServerFailure('Error')));

    final result = await useCase(const GetProductsParams(page: 1));

    expect(result, Left(ServerFailure('Error')));
  });
}
```

---

### 2. Widget Testing dengan MockBloc

**Description:** Widget tests untuk screens dan UI components. Di BLoC, kita pakai `MockBloc` dan `whenListen` dari `bloc_test` untuk mock bloc state di widget tests. TIDAK perlu `ProviderScope` atau `ProviderContainer`.

**Recommended Skills:** `senior-flutter-developer`, `playwright-specialist`

**Instructions:**
1. **MockBloc Setup:**
   - Extend `MockBloc<Event, State>` dari `bloc_test`
   - Gunakan `whenListen` untuk setup stream dan initial state
   - Wrap widget dengan `BlocProvider<T>.value(value: mockBloc)`
   - JANGAN pakai `BlocProvider(create: ...)` di test — pakai `.value()`

2. **Screen Tests:**
   - Test dengan berbagai states (initial, loading, error, empty, data)
   - Test user interactions (tap, scroll, swipe)
   - Test navigation (GoRouter mock)

3. **Component Tests:**
   - Test reusable widgets
   - Test form validation
   - Test error boundaries / error widgets

**Output Format:**

```dart
// test/features/product/presentation/screens/product_list_screen_test.dart
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

// ========================================
// MockBloc — ini yang beda dari Riverpod!
// Tidak perlu MockNotifier, cukup extend MockBloc
// ========================================
class MockProductBloc extends MockBloc<ProductEvent, ProductState>
    implements ProductBloc {}

class MockAuthBloc extends MockBloc<AuthEvent, AuthState>
    implements AuthBloc {}

void main() {
  late MockProductBloc mockProductBloc;
  late MockAuthBloc mockAuthBloc;

  final tProducts = [
    Product(id: '1', name: 'Test Product', price: 99.99),
    Product(id: '2', name: 'Another Product', price: 49.99),
  ];

  setUp(() {
    mockProductBloc = MockProductBloc();
    mockAuthBloc = MockAuthBloc();
  });

  // Helper untuk pump widget dengan BlocProvider
  // Ini SANGAT berbeda dari Riverpod yang pakai ProviderScope
  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: MultiBlocProvider(
        providers: [
          BlocProvider<ProductBloc>.value(value: mockProductBloc),
          BlocProvider<AuthBloc>.value(value: mockAuthBloc),
        ],
        child: const ProductListScreen(),
      ),
    );
  }

  // ========================================
  // Loading State Tests
  // ========================================
  group('Loading State', () {
    testWidgets('shows CircularProgressIndicator when state is ProductLoading',
        (tester) async {
      // whenListen: setup mock bloc stream dan initial state
      // Ini pengganti ProviderScope overrides di Riverpod
      whenListen(
        mockProductBloc,
        Stream<ProductState>.empty(),
        initialState: const ProductLoading(),
      );

      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });

  // ========================================
  // Data Loaded State Tests
  // ========================================
  group('Loaded State', () {
    testWidgets('shows product list when state is ProductLoaded',
        (tester) async {
      whenListen(
        mockProductBloc,
        Stream<ProductState>.empty(),
        initialState: ProductLoaded(products: tProducts),
      );

      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.text('Test Product'), findsOneWidget);
      expect(find.text('Another Product'), findsOneWidget);
      expect(find.text('Rp 99.99'), findsOneWidget);
    });

    testWidgets('shows empty state when product list is empty',
        (tester) async {
      whenListen(
        mockProductBloc,
        Stream<ProductState>.empty(),
        initialState: const ProductLoaded(products: []),
      );

      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.text('Tidak ada produk'), findsOneWidget);
      expect(find.byIcon(Icons.inbox), findsOneWidget);
    });
  });

  // ========================================
  // Error State Tests
  // ========================================
  group('Error State', () {
    testWidgets('shows error message and retry button when state is ProductError',
        (tester) async {
      whenListen(
        mockProductBloc,
        Stream<ProductState>.empty(),
        initialState: const ProductError(message: 'Server error'),
      );

      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.text('Server error'), findsOneWidget);
      expect(find.text('Coba Lagi'), findsOneWidget);
    });

    testWidgets('dispatches LoadProducts when retry button is tapped',
        (tester) async {
      whenListen(
        mockProductBloc,
        Stream<ProductState>.empty(),
        initialState: const ProductError(message: 'Network error'),
      );

      await tester.pumpWidget(createWidgetUnderTest());

      await tester.tap(find.text('Coba Lagi'));
      await tester.pump();

      // Verify event ditambahkan ke bloc
      verify(() => mockProductBloc.add(const LoadProducts())).called(1);
    });
  });

  // ========================================
  // User Interaction Tests
  // ========================================
  group('User Interactions', () {
    testWidgets('dispatches DeleteProductEvent on swipe dismiss',
        (tester) async {
      whenListen(
        mockProductBloc,
        Stream<ProductState>.empty(),
        initialState: ProductLoaded(products: tProducts),
      );

      await tester.pumpWidget(createWidgetUnderTest());

      // Swipe untuk delete
      await tester.drag(
        find.text('Test Product'),
        const Offset(-500, 0),
      );
      await tester.pumpAndSettle();

      // Confirm delete dialog
      await tester.tap(find.text('Hapus'));
      await tester.pump();

      verify(() => mockProductBloc.add(const DeleteProductEvent(id: '1')))
          .called(1);
    });

    testWidgets('shows SnackBar when product is created (BlocListener)',
        (tester) async {
      // whenListen dengan stream yang emit state baru
      // Ini test BlocListener behavior
      whenListen(
        mockProductBloc,
        Stream.fromIterable([
          const ProductLoading(),
          ProductCreated(product: tProducts.first),
        ]),
        initialState: ProductLoaded(products: tProducts),
      );

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump(); // Process stream events

      expect(find.text('Produk berhasil dibuat'), findsOneWidget);
    });
  });

  // ========================================
  // Navigation Tests (dengan GoRouter)
  // ========================================
  group('Navigation', () {
    testWidgets('navigates to product detail on tap', (tester) async {
      final mockGoRouter = MockGoRouter();

      whenListen(
        mockProductBloc,
        Stream<ProductState>.empty(),
        initialState: ProductLoaded(products: tProducts),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: InheritedGoRouter(
            goRouter: mockGoRouter,
            child: BlocProvider<ProductBloc>.value(
              value: mockProductBloc,
              child: const ProductListScreen(),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Test Product'));
      await tester.pumpAndSettle();

      verify(() => mockGoRouter.push('/products/1')).called(1);
    });
  });
}

// ========================================
// test/features/auth/presentation/screens/login_screen_test.dart
// ========================================
class MockLoginFormBloc extends MockBloc<LoginFormEvent, LoginFormState>
    implements LoginFormBloc {}

void main() {
  late MockAuthBloc mockAuthBloc;
  late MockLoginFormBloc mockLoginFormBloc;

  setUp(() {
    mockAuthBloc = MockAuthBloc();
    mockLoginFormBloc = MockLoginFormBloc();
  });

  testWidgets('shows validation error when email is empty', (tester) async {
    whenListen(
      mockAuthBloc,
      Stream<AuthState>.empty(),
      initialState: const AuthUnauthenticated(),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<AuthBloc>.value(
          value: mockAuthBloc,
          child: const LoginScreen(),
        ),
      ),
    );

    // Tap login button tanpa isi form
    await tester.tap(find.byType(ElevatedButton));
    await tester.pumpAndSettle();

    expect(find.text('Email wajib diisi'), findsOneWidget);
  });

  testWidgets('shows loading indicator when auth state is AuthLoading',
      (tester) async {
    whenListen(
      mockAuthBloc,
      Stream<AuthState>.empty(),
      initialState: const AuthLoading(),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<AuthBloc>.value(
          value: mockAuthBloc,
          child: const LoginScreen(),
        ),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    // Login button harus disabled saat loading
    final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
    expect(button.onPressed, isNull);
  });

  testWidgets('dispatches LoginRequested with form data', (tester) async {
    whenListen(
      mockAuthBloc,
      Stream<AuthState>.empty(),
      initialState: const AuthUnauthenticated(),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<AuthBloc>.value(
          value: mockAuthBloc,
          child: const LoginScreen(),
        ),
      ),
    );

    // Isi form
    await tester.enterText(
      find.byKey(const Key('email_field')),
      'test@example.com',
    );
    await tester.enterText(
      find.byKey(const Key('password_field')),
      'password123',
    );

    // Submit
    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();

    verify(() => mockAuthBloc.add(const LoginRequested(
          email: 'test@example.com',
          password: 'password123',
        ))).called(1);
  });
}
```

**Golden Test Pattern (untuk BLoC):**

```dart
// test/features/product/presentation/widgets/product_card_golden_test.dart
void main() {
  testWidgets('ProductCard matches golden file', (tester) async {
    // Golden tests tidak perlu MockBloc karena test widget individual
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ProductCard(
            product: Product(
              id: '1',
              name: 'Golden Test Product',
              price: 150000,
              imageUrl: 'assets/test/product.png',
            ),
            onTap: () {},
            onDelete: () {},
          ),
        ),
      ),
    );

    await expectLater(
      find.byType(ProductCard),
      matchesGoldenFile('goldens/product_card.png'),
    );
  });
}
```

---

### 3. Integration Testing

**Description:** Integration tests untuk end-to-end flows. Framework integration testing sama dengan Riverpod — bedanya hanya di setup BlocProvider vs ProviderScope di app entry point.

**Recommended Skills:** `senior-flutter-developer`, `playwright-specialist`

**Instructions:**
1. **Test Scenarios:**
   - Happy paths (login → browse → action → result)
   - Error scenarios (network down, validation errors)
   - Complete user journeys

2. **Test Environment:**
   - Mock servers (mockoon, wiremock, atau json_server)
   - Test databases
   - Firebase emulators (jika pakai Firebase)
   - Supabase local (jika pakai Supabase)

3. **BLoC-specific Setup:**
   - `injectable` test environment configuration
   - Test module untuk inject mock dependencies
   - `getIt.reset()` di setUp setiap test

**Output Format:**

```dart
// integration_test/app_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:my_app/main.dart' as app;
import 'package:my_app/injection.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // Reset injectable container sebelum setiap test
  setUp(() async {
    await getIt.reset();
    await configureDependencies(environment: 'test');
  });

  group('End-to-End Tests', () {
    testWidgets('complete login flow', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Navigate ke login screen
      await tester.tap(find.text('Masuk'));
      await tester.pumpAndSettle();

      // Masukkan credentials
      await tester.enterText(
        find.byKey(const Key('email_field')),
        'test@example.com',
      );
      await tester.enterText(
        find.byKey(const Key('password_field')),
        'password123',
      );

      // Submit login
      await tester.tap(find.text('Login'));
      await tester.pumpAndSettle();

      // Verify berhasil masuk ke home
      expect(find.text('Selamat Datang'), findsOneWidget);
    });

    testWidgets('create product flow', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Login dulu
      await _performLogin(tester);

      // Navigate ke create product
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      // Isi form product
      await tester.enterText(
        find.byKey(const Key('product_name_field')),
        'Produk Baru',
      );
      await tester.enterText(
        find.byKey(const Key('product_price_field')),
        '150000',
      );
      await tester.enterText(
        find.byKey(const Key('product_description_field')),
        'Deskripsi produk baru',
      );

      // Submit
      await tester.tap(find.text('Simpan'));
      await tester.pumpAndSettle();

      // Verify product muncul di list
      expect(find.text('Produk Baru'), findsOneWidget);
      expect(find.text('Rp 150.000'), findsOneWidget);
    });

    testWidgets('search and filter products', (tester) async {
      app.main();
      await tester.pumpAndSettle();
      await _performLogin(tester);

      // Tap search icon
      await tester.tap(find.byIcon(Icons.search));
      await tester.pumpAndSettle();

      // Ketik search query
      await tester.enterText(find.byType(TextField), 'Produk');
      await tester.pumpAndSettle();

      // Verify filtered results
      expect(find.text('Produk Baru'), findsOneWidget);
    });

    testWidgets('handles offline gracefully', (tester) async {
      // Simulasi offline mode
      app.main();
      await tester.pumpAndSettle();

      // Assert offline indicator muncul
      expect(find.text('Tidak ada koneksi internet'), findsOneWidget);
    });
  });
}

// Helper function
Future<void> _performLogin(WidgetTester tester) async {
  await tester.tap(find.text('Masuk'));
  await tester.pumpAndSettle();
  await tester.enterText(
    find.byKey(const Key('email_field')),
    'test@example.com',
  );
  await tester.enterText(
    find.byKey(const Key('password_field')),
    'password123',
  );
  await tester.tap(find.text('Login'));
  await tester.pumpAndSettle();
}
```

---

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

## BLoC-Specific Optimization (BACA INI DULU)

### buildWhen — Minimize Widget Rebuilds
```dart
// TANPA buildWhen — rebuild setiap state change
BlocBuilder<ProductBloc, ProductState>(
  builder: (context, state) => ...,
)

// DENGAN buildWhen — rebuild hanya ketika data berubah
// Ini SANGAT penting untuk performa!
BlocBuilder<ProductBloc, ProductState>(
  buildWhen: (previous, current) {
    // Hanya rebuild kalau state berubah ke Loaded
    return current is ProductLoaded;
  },
  builder: (context, state) => ...,
)
```

### listenWhen — Filter Side Effects
```dart
// Hanya listen untuk error states
BlocListener<ProductBloc, ProductState>(
  listenWhen: (previous, current) => current is ProductError,
  listener: (context, state) {
    if (state is ProductError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(state.message)),
      );
    }
  },
  child: ...,
)
```

### Bloc.observer — Global Performance Monitoring
```dart
// lib/core/bloc/app_bloc_observer.dart
class AppBlocObserver extends BlocObserver {
  @override
  void onCreate(BlocBase bloc) {
    super.onCreate(bloc);
    debugPrint('Bloc Created: ${bloc.runtimeType}');
  }

  @override
  void onTransition(Bloc bloc, Transition transition) {
    super.onTransition(bloc, transition);
    debugPrint(
      'Bloc Transition: ${bloc.runtimeType}\n'
      '  Event: ${transition.event}\n'
      '  Current: ${transition.currentState}\n'
      '  Next: ${transition.nextState}',
    );
  }

  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    super.onError(bloc, error, stackTrace);
    debugPrint('Bloc Error: ${bloc.runtimeType} — $error');
    // Report to Crashlytics
    FirebaseCrashlytics.instance.recordError(error, stackTrace);
  }

  @override
  void onClose(BlocBase bloc) {
    super.onClose(bloc);
    debugPrint('Bloc Closed: ${bloc.runtimeType}');
  }
}

// main.dart
void main() {
  Bloc.observer = AppBlocObserver();
  runApp(const MyApp());
}
```

### Equatable untuk State Comparison
```dart
// WAJIB extend Equatable di semua State classes
// Tanpa ini, BlocBuilder rebuild setiap kali meskipun data sama
abstract class ProductState extends Equatable {
  const ProductState();

  @override
  List<Object?> get props => [];
}

class ProductLoaded extends ProductState {
  final List<Product> products;
  final bool hasReachedMax;

  const ProductLoaded({
    required this.products,
    this.hasReachedMax = false,
  });

  @override
  List<Object?> get props => [products, hasReachedMax];

  // copyWith pattern
  ProductLoaded copyWith({
    List<Product>? products,
    bool? hasReachedMax,
  }) {
    return ProductLoaded(
      products: products ?? this.products,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
    );
  }
}
```

### Granular Blocs vs Monolithic
```dart
// JANGAN: Satu bloc besar untuk satu screen
class ProductScreenBloc extends Bloc<ProductScreenEvent, ProductScreenState> {
  // handles: load, search, filter, sort, pagination, create, delete, update
  // Setiap event change rebuild SELURUH screen
}

// BAGUS: Pecah jadi beberapa bloc kecil
class ProductListBloc extends Bloc<...> { /* load, pagination */ }
class ProductSearchBloc extends Bloc<...> { /* search, filter */ }
class ProductFormBloc extends Bloc<...> { /* create, update */ }

// Masing-masing bloc hanya rebuild widget yang relevan
MultiBlocProvider(
  providers: [
    BlocProvider(create: (_) => getIt<ProductListBloc>()..add(const LoadProducts())),
    BlocProvider(create: (_) => getIt<ProductSearchBloc>()),
  ],
  child: ProductScreen(),
)
```

## Image Optimization (Framework-Agnostic)
- [ ] Use `CachedNetworkImage` untuk semua network images
- [ ] Set `cacheWidth` dan `cacheHeight` sesuai display size
- [ ] Compress images sebelum upload (max 500KB)
- [ ] Use WebP format (30-50% smaller)
- [ ] Implement placeholder dan error widget

## List Optimization
- [ ] Use `ListView.builder` (BUKAN ListView with children)
- [ ] Implement infinite scroll pagination
- [ ] Use `const` constructors untuk list items
- [ ] Avoid heavy computation di `itemBuilder`
- [ ] `AutomaticKeepAliveClientMixin` untuk preserve scroll state

## Memory Management
- [ ] Bloc.close() di semua page dispose (otomatis kalau pakai `BlocProvider(create:)`)
- [ ] Cancel StreamSubscriptions on bloc close
- [ ] Clear image cache secara periodik
- [ ] `RepaintBoundary` untuk complex widgets
- [ ] Avoid menyimpan large objects di bloc state

## Startup Performance
- [ ] Defer non-critical initialization
- [ ] Lazy injectable registration (`@lazySingleton` bukan `@singleton`)
- [ ] Use native splash screen (`flutter_native_splash`)
- [ ] Minimize main bundle size
- [ ] Preload critical assets di splash

## Profiling Steps
1. Run `flutter run --profile`
2. Open DevTools (Flutter Inspector)
3. Check Widget Rebuild tracker — pastikan tidak ada rebuild berlebihan
4. Check untuk:
   - Raster thread jank (>16ms frames)
   - UI thread jank
   - Memory leaks (growing memory graph)
   - Excessive rebuilds (pakai `debugPrintRebuildDirtyWidgets`)
5. Fix issues, re-profile, repeat
```

---

### 6. Production Checklist

**Description:** Comprehensive checklist sebelum release ke production. Mencakup hal-hal BLoC-specific dan general Flutter requirements.

**Output Format:**

```markdown
# Production Release Checklist (Flutter BLoC)

## Pre-Release Code Quality
- [ ] App version updated di `pubspec.yaml` (version + build number)
- [ ] CHANGELOG.md updated dengan semua perubahan
- [ ] `build_runner` berjalan tanpa error (`dart run build_runner build`)
- [ ] Semua `*.g.dart` dan `*.freezed.dart` files up-to-date
- [ ] `flutter analyze` — 0 warnings, 0 errors
- [ ] `dart format .` — semua file formatted
- [ ] Tidak ada `print()` statements (ganti dengan `log()` atau remove)
- [ ] Tidak ada `TODO` atau `FIXME` yang critical

## Testing
- [ ] All unit tests passing (`flutter test`)
- [ ] Code coverage ≥ 80% overall
- [ ] Semua Bloc/Cubit punya blocTest coverage 100%
- [ ] Widget tests untuk semua screens
- [ ] Integration tests untuk critical flows (login, main feature)
- [ ] Tested di physical device (bukan hanya emulator)
- [ ] Tested di berbagai screen size (small phone, tablet)

## BLoC-Specific Checks
- [ ] Semua State classes extend `Equatable` (atau override `==` dan `hashCode`)
- [ ] Semua Event classes extend `Equatable`
- [ ] `Bloc.close()` dipanggil properly (atau dihandle oleh `BlocProvider`)
- [ ] Tidak ada stream subscriptions yang leak
- [ ] `buildWhen` digunakan di heavy widgets
- [ ] `Bloc.observer` configured untuk production logging
- [ ] Injectable modules configured untuk production environment
- [ ] Error handling proper di semua `on<Event>` handlers

## Android
- [ ] `minSdkVersion` appropriate (minimal 21 atau sesuai target)
- [ ] `targetSdkVersion` latest (34+)
- [ ] ProGuard/R8 rules configured
- [ ] App signing configured (keystore)
- [ ] Keystore backed up securely (BUKAN di repo!)
- [ ] App icon semua densities (mdpi, hdpi, xhdpi, xxhdpi, xxxhdpi)
- [ ] Adaptive icon configured
- [ ] Splash screen native
- [ ] Internet permission di `AndroidManifest.xml`
- [ ] Play Store listing prepared (title, description, screenshots)
- [ ] Privacy policy URL

## iOS
- [ ] Minimum iOS version appropriate (15.0+)
- [ ] App Store Connect setup
- [ ] App icon semua sizes (1024x1024 master)
- [ ] Launch screen (LaunchScreen.storyboard)
- [ ] Signing certificates dan provisioning profiles
- [ ] `Info.plist` configured (permissions, URL schemes)
- [ ] App Store listing prepared
- [ ] Screenshots semua required device sizes
- [ ] Privacy policy URL
- [ ] App Privacy labels filled

## Firebase (jika pakai)
- [ ] Production Firebase project (BUKAN dev project!)
- [ ] Security rules deployed dan reviewed
- [ ] Analytics enabled
- [ ] Crashlytics enabled dan tested
- [ ] Performance monitoring enabled
- [ ] Push notifications tested di real device
- [ ] Remote Config default values set
- [ ] Billing alerts configured

## Supabase (jika pakai)
- [ ] Production Supabase project
- [ ] RLS policies reviewed dan enabled
- [ ] Database indexes optimized
- [ ] Edge Functions deployed
- [ ] Realtime policies configured
- [ ] Storage policies reviewed
- [ ] API keys rotated dari development

## Performance
- [ ] Profiled dengan Flutter DevTools (profile mode)
- [ ] No jank (semua frames <16ms)
- [ ] Memory usage acceptable dan stabil
- [ ] App size optimized (<30MB kalau bisa)
- [ ] Cold start <3 detik
- [ ] `buildWhen` diterapkan di semua `BlocBuilder` yang heavy
- [ ] No unnecessary rebuilds (cek dengan DevTools)

## Security
- [ ] API keys TIDAK hardcoded (pakai `--dart-define` atau `.env`)
- [ ] SSL pinning configured (opsional tapi recommended)
- [ ] Code obfuscation enabled (`--obfuscate`)
- [ ] Split debug info (`--split-debug-info=symbols/`)
- [ ] Tidak ada sensitive data di logs
- [ ] Secure storage untuk tokens (`flutter_secure_storage`)
- [ ] Certificate pinning untuk critical API calls
- [ ] Input sanitization di semua form

## Final Steps
- [ ] Build release APK: `flutter build apk --release --obfuscate --split-debug-info=symbols/`
- [ ] Build release AAB: `flutter build appbundle --release --obfuscate --split-debug-info=symbols/`
- [ ] Build release IPA: `flutter build ipa --release --obfuscate --split-debug-info=symbols/`
- [ ] Test release build di real devices (WAJIB!)
- [ ] Beta testing (TestFlight untuk iOS, Internal Testing untuk Android)
- [ ] Monitor crash reports selama beta period
- [ ] Fix critical beta bugs
- [ ] Submit ke stores
- [ ] Monitor first 24-48 jam setelah release
```

---

### 7. Fastlane Configuration

**Description:** Fastlane setup untuk automated deployment. Konfigurasi sama dengan Riverpod — Fastlane tidak peduli state management apa yang dipakai. Yang penting: pastikan `build_runner` sudah dijalankan sebelum Fastlane build.

**Output Format:**

```ruby
# android/Gemfile
source "https://rubygems.org"
gem "fastlane"

# android/fastlane/Fastfile
default_platform(:android)

platform :android do
  desc "Deploy to internal testing track"
  lane :internal do
    # Pastikan build_runner sudah dijalankan sebelum lane ini!
    # Di CI, biasanya sudah dijalankan di step sebelumnya.
    # Kalau manual: sh("cd .. && dart run build_runner build --delete-conflicting-outputs")

    # Increment version code
    increment_version_code(
      gradle_file_path: "app/build.gradle",
    )

    # Build AAB via Flutter
    sh("cd ../.. && flutter build appbundle --release --obfuscate --split-debug-info=build/symbols")

    # Upload to Play Store internal track
    upload_to_play_store(
      track: "internal",
      aab: "../build/app/outputs/bundle/release/app-release.aab",
      skip_upload_metadata: true,
      skip_upload_images: true,
      skip_upload_screenshots: true,
      json_key_data: ENV["PLAY_STORE_SERVICE_ACCOUNT_JSON"],
    )

    # Notify team via Slack (opsional)
    # slack(
    #   message: "Android internal build uploaded successfully!",
    #   slack_url: ENV["SLACK_WEBHOOK_URL"],
    # )
  end

  desc "Promote internal to production"
  lane :production do
    upload_to_play_store(
      track: "internal",
      track_promote_to: "production",
      skip_upload_aab: true,
      skip_upload_metadata: false,
      json_key_data: ENV["PLAY_STORE_SERVICE_ACCOUNT_JSON"],
    )
  end

  desc "Build APK for local testing"
  lane :build_debug do
    sh("cd ../.. && dart run build_runner build --delete-conflicting-outputs")
    sh("cd ../.. && flutter build apk --debug")
  end
end

# ios/Gemfile
source "https://rubygems.org"
gem "fastlane"
gem "cocoapods"

# ios/fastlane/Fastfile
default_platform(:ios)

platform :ios do
  desc "Deploy to TestFlight"
  lane :beta do
    setup_ci

    # Fetch signing certificates via match
    match(
      type: "appstore",
      readonly: true,
      git_url: ENV["MATCH_GIT_URL"],
    )

    # Pastikan build_runner sudah dijalankan!
    sh("cd ../.. && dart run build_runner build --delete-conflicting-outputs")

    # Build IPA
    build_ios_app(
      export_method: "app-store",
      output_directory: "../build/ios/ipa",
      configuration: "Release",
    )

    # Upload to TestFlight
    upload_to_testflight(
      skip_waiting_for_build_processing: true,
      api_key_path: "fastlane/api_key.json",
    )
  end

  desc "Deploy to App Store"
  lane :release do
    setup_ci

    match(type: "appstore", readonly: true)

    sh("cd ../.. && dart run build_runner build --delete-conflicting-outputs")

    build_ios_app(
      export_method: "app-store",
      configuration: "Release",
    )

    upload_to_app_store(
      submit_for_review: true,
      automatic_release: false,
      force: true, # Skip HTML preview
      precheck_include_in_app_purchases: false,
      api_key_path: "fastlane/api_key.json",
    )
  end

  desc "Register new device for development"
  lane :register_device do
    device_name = prompt(text: "Enter device name: ")
    device_udid = prompt(text: "Enter device UDID: ")

    register_devices(
      devices: { device_name => device_udid }
    )

    match(type: "development", force_for_new_devices: true)
  end
end
```

**Fastlane Appfile Configuration:**

```ruby
# android/fastlane/Appfile
json_key_file(ENV["PLAY_STORE_JSON_KEY_PATH"])
package_name("com.example.myapp")

# ios/fastlane/Appfile
app_identifier("com.example.myapp")
apple_id(ENV["APPLE_ID"])
itc_team_id(ENV["ITC_TEAM_ID"])
team_id(ENV["TEAM_ID"])
```

---

## Test Helpers & Utilities

### Shared Test Setup

```dart
// test/helpers/test_helpers.dart
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';

// ========================================
// Centralized Mock Classes
// Semua MockBloc didefinisikan di sini supaya reusable
// ========================================
class MockProductBloc extends MockBloc<ProductEvent, ProductState>
    implements ProductBloc {}

class MockAuthBloc extends MockBloc<AuthEvent, AuthState>
    implements AuthBloc {}

class MockCartBloc extends MockBloc<CartEvent, CartState>
    implements CartBloc {}

class MockSettingsCubit extends MockCubit<SettingsState>
    implements SettingsCubit {}

// ========================================
// Mock Repositories
// ========================================
class MockProductRepository extends Mock implements ProductRepository {}
class MockAuthRepository extends Mock implements AuthRepository {}
class MockUserRepository extends Mock implements UserRepository {}

// ========================================
// Mock Use Cases
// ========================================
class MockGetProducts extends Mock implements GetProducts {}
class MockCreateProduct extends Mock implements CreateProduct {}
class MockDeleteProduct extends Mock implements DeleteProduct {}
class MockLoginUseCase extends Mock implements LoginUseCase {}

// ========================================
// Mock Navigation
// ========================================
class MockGoRouter extends Mock implements GoRouter {}
class MockNavigatorObserver extends Mock implements NavigatorObserver {}

// ========================================
// Widget Test Wrapper
// Helper untuk wrap widget dengan semua providers yang dibutuhkan
// ========================================
Widget buildTestableWidget({
  required Widget child,
  ProductBloc? productBloc,
  AuthBloc? authBloc,
  CartBloc? cartBloc,
  SettingsCubit? settingsCubit,
  GoRouter? goRouter,
}) {
  Widget widget = child;

  // Wrap dengan BlocProviders yang dibutuhkan
  final providers = <BlocProvider>[
    if (productBloc != null)
      BlocProvider<ProductBloc>.value(value: productBloc),
    if (authBloc != null)
      BlocProvider<AuthBloc>.value(value: authBloc),
    if (cartBloc != null)
      BlocProvider<CartBloc>.value(value: cartBloc),
    if (settingsCubit != null)
      BlocProvider<SettingsCubit>.value(value: settingsCubit),
  ];

  if (providers.isNotEmpty) {
    widget = MultiBlocProvider(
      providers: providers,
      child: widget,
    );
  }

  if (goRouter != null) {
    widget = InheritedGoRouter(
      goRouter: goRouter,
      child: widget,
    );
  }

  return MaterialApp(home: widget);
}

// ========================================
// Test Fixtures
// ========================================
class TestFixtures {
  static final product = Product(
    id: '1',
    name: 'Test Product',
    price: 99000,
    description: 'A test product',
    imageUrl: 'https://example.com/image.png',
    createdAt: DateTime(2024, 1, 1),
  );

  static final productList = [
    product,
    Product(id: '2', name: 'Product 2', price: 150000),
    Product(id: '3', name: 'Product 3', price: 200000),
  ];

  static final user = User(
    id: 'user-1',
    email: 'test@example.com',
    name: 'Test User',
    avatarUrl: 'https://example.com/avatar.png',
  );
}

// ========================================
// Fake Classes untuk registerFallbackValue
// ========================================
class FakeRoute extends Fake implements Route<dynamic> {}
class FakeGetProductsParams extends Fake implements GetProductsParams {}
class FakeCreateProductParams extends Fake implements CreateProductParams {}
class FakeLoginParams extends Fake implements LoginParams {}

// Register semua fallback values
void registerAllFallbackValues() {
  registerFallbackValue(FakeRoute());
  registerFallbackValue(FakeGetProductsParams());
  registerFallbackValue(FakeCreateProductParams());
  registerFallbackValue(FakeLoginParams());
}
```

---

## Workflow Steps

1. **Setup Testing Infrastructure**
   - Add test dependencies (`bloc_test`, `mocktail`)
   - Setup test helpers dan mock classes
   - Create test fixtures
   - Verify `build_runner` works (`dart run build_runner build`)

2. **Write Bloc/Cubit Unit Tests**
   - Test setiap Event → State transition dengan `blocTest`
   - Test initial state
   - Test error scenarios
   - Test debounce / transformer behavior
   - Run: `flutter test test/features/*/presentation/bloc/`

3. **Write Use Case & Repository Tests**
   - Test use cases (same pattern as Riverpod)
   - Test repositories
   - Test data sources
   - Run: `flutter test test/features/*/domain/ test/features/*/data/`

4. **Write Widget Tests**
   - Setup `MockBloc` untuk setiap bloc yang dibutuhkan
   - Test screens dengan berbagai states menggunakan `whenListen`
   - Test user interactions (verify events dispatched)
   - Test BlocListener behavior (SnackBars, dialogs, navigation)
   - Run: `flutter test test/features/*/presentation/screens/`

5. **Write Integration Tests**
   - Test end-to-end flows
   - Setup test environment (mock server / emulators)
   - Run: `flutter test integration_test/`

6. **Setup CI/CD**
   - Create GitHub Actions workflows
   - Pastikan `build_runner` step ada di CI
   - Configure secrets
   - Test CI pipeline end-to-end

7. **Performance Optimization**
   - Profile dengan DevTools (profile mode)
   - Implement `buildWhen` di heavy BlocBuilders
   - Setup `Bloc.observer` untuk monitoring
   - Verify Equatable di semua States
   - Fix performance issues

8. **Production Preparation**
   - Complete production checklist
   - Setup app signing (keystore, certificates)
   - Configure Fastlane
   - Prepare store listings dan screenshots
   - Run `build_runner` final build

9. **Deployment**
   - Build release versions (APK/AAB/IPA)
   - Upload ke stores (Fastlane atau manual)
   - Beta testing period
   - Monitor crash reports dan analytics
   - Production release

## Success Criteria

- [ ] Unit test coverage ≥ 80% overall
- [ ] Semua Bloc/Cubit classes coverage 100%
- [ ] All critical paths punya widget tests
- [ ] Integration tests cover happy paths
- [ ] CI/CD pipeline runs tanpa error (termasuk `build_runner`)
- [ ] No high/critical defects
- [ ] Performance benchmarks met (no jank, <3s startup)
- [ ] `buildWhen` diterapkan di semua heavy widgets
- [ ] `Bloc.observer` configured
- [ ] App size optimized
- [ ] Production checklist complete
- [ ] App published ke stores

## Tools & Commands

### Testing
```bash
# Run semua tests
flutter test

# Run dengan coverage report
flutter test --coverage

# Generate HTML coverage report
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html

# Run specific test file
flutter test test/features/product/presentation/bloc/product_bloc_test.dart

# Run tests dengan name filter
flutter test --name "LoadProducts"

# Run integration tests
flutter test integration_test/app_test.dart

# Run integration tests di specific device
flutter test integration_test/ -d <device_id>
```

### Build Runner (WAJIB sebelum test/build)
```bash
# Generate semua code (*.g.dart, *.freezed.dart, *.config.dart)
dart run build_runner build --delete-conflicting-outputs

# Watch mode (saat development)
dart run build_runner watch --delete-conflicting-outputs

# Clean generated files
dart run build_runner clean
```

### Performance
```bash
# Profile mode (untuk performance testing)
flutter run --profile

# Build release
flutter build apk --release
flutter build appbundle --release
flutter build ios --release

# Build dengan obfuscation (production)
flutter build apk --release --obfuscate --split-debug-info=symbols/
flutter build appbundle --release --obfuscate --split-debug-info=symbols/

# Analyze app size
flutter build apk --analyze-size
flutter build appbundle --analyze-size
```

### CI/CD
```bash
# Local Fastlane test
cd android && bundle exec fastlane internal
cd ios && bundle exec fastlane beta

# Install Fastlane dependencies
cd android && bundle install
cd ios && bundle install
```

## Perbedaan Testing: BLoC vs Riverpod vs GetX

| Aspek | BLoC | Riverpod | GetX |
|-------|------|----------|------|
| Primary test tool | `blocTest<B,S>()` | `ProviderContainer` | `Get.put()` + manual |
| Mock state | `MockBloc` / `MockCubit` | `overrideWith()` | Manual mock controller |
| Widget wrap | `BlocProvider.value()` | `ProviderScope(overrides:)` | `Get.put()` |
| Stream mock | `whenListen()` | `overrideWith()` | `ever()` / manual |
| Teardown | `bloc.close()` | `container.dispose()` | `Get.reset()` |
| Code gen in CI | `build_runner` (freezed) | `build_runner` (riverpod_generator) | Tidak perlu |
| Test verbosity | Medium (declarative) | Low (minimal setup) | High (manual setup) |

## Next Steps

Setelah testing & production workflow selesai:
1. Monitor app performance di production (Crashlytics, Analytics)
2. Setup error tracking dan alerting (Sentry / Crashlytics dashboard)
3. Collect user feedback (in-app feedback, store reviews)
4. Plan next iteration / features
5. Setup automated regression testing schedule
6. Regular dependency updates (`flutter pub outdated && flutter pub upgrade`)
7. Security audit berkala

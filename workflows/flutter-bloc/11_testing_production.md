---
description: Comprehensive testing (unit, widget, integration) dan production preparation khusus Flutter BLoC.
---
# Workflow: Testing & Production — Flutter BLoC

// turbo-all

## Overview

Testing dan production preparation dengan BLoC architecture:
- **Unit tests** → `blocTest<Bloc, State>()` dari `bloc_test` package
- **Widget tests** → `MockBloc` + `whenListen` + `BlocProvider.value()`
- **Integration tests** → End-to-end dengan `flutter_test`
- **CI/CD** → GitHub Actions dengan `build_runner` step

**Perbedaan Utama dari Riverpod:**
- Testing pakai `bloc_test` package, bukan `ProviderContainer`
- `blocTest<Bloc, State>()` sebagai primary testing function
- Widget test wrap dengan `BlocProvider.value()`, bukan `ProviderScope`
- `MockBloc` / `MockCubit` dari `bloc_test` untuk widget tests
- `whenListen` untuk mock bloc streams
- `tearDown` wajib `bloc.close()` untuk prevent memory leaks
- CI/CD butuh `build_runner` step (untuk generated code)


## Prerequisites

- Project setup dari `01_project_setup.md` selesai
- Backend integration selesai (REST API, Firebase, atau Supabase)
- Features implemented dan functional


## Agent Behavior

- **Jalankan `dart run build_runner build -d`** sebelum tests.
- **`blocTest`**: gunakan untuk semua Bloc/Cubit unit tests.
- **Widget tests**: wrap dengan `BlocProvider.value()`, bukan `BlocProvider(create: ...)`.
- **`tearDown(() => bloc.close())`**: wajib di setiap test group yang create Bloc.
- **Jangan skip** `verify` di widget tests — selalu verify events yang di-dispatch.
- **Golden tests**: generate dengan `--update-goldens` lalu commit.


## Recommended Skills

- `senior-flutter-developer` — BLoC testing
- `tdd-workflow` — Test-Driven Development
- `github-actions-specialist` — CI/CD


## Dependencies

```yaml
dev_dependencies:
  bloc_test: ^9.1.7
  mocktail: ^1.0.0
  flutter_test:
    sdk: flutter
  integration_test:
    sdk: flutter
  build_runner: ^2.4.8
```


## Workflow Steps

### Step 1: BLoC Unit Tests (`blocTest`)

```dart
// test/features/products/presentation/bloc/product_bloc_test.dart
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

// Mocks
class MockGetProducts extends Mock implements GetProducts {}
class MockCreateProduct extends Mock implements CreateProduct {}
class MockDeleteProduct extends Mock implements DeleteProduct {}

void main() {
  late MockGetProducts mockGetProducts;
  late MockCreateProduct mockCreateProduct;
  late MockDeleteProduct mockDeleteProduct;
  late ProductBloc productBloc;

  final tProducts = [
    const Product(id: '1', name: 'Test Product', price: 100.0, stock: 10),
    const Product(id: '2', name: 'Another Product', price: 200.0, stock: 5),
  ];

  setUp(() {
    mockGetProducts = MockGetProducts();
    mockCreateProduct = MockCreateProduct();
    mockDeleteProduct = MockDeleteProduct();
    productBloc = ProductBloc(
      getProducts: mockGetProducts,
      createProduct: mockCreateProduct,
      deleteProduct: mockDeleteProduct,
    );
  });

  // WAJIB: close bloc setelah setiap test untuk prevent memory leaks
  tearDown(() => productBloc.close());

  group('LoadProducts', () {
    blocTest<ProductBloc, ProductState>(
      'emits [ProductLoading, ProductLoaded] on success',
      build: () {
        when(() => mockGetProducts()).thenAnswer(
          (_) async => Success(tProducts),
        );
        return productBloc;
      },
      act: (bloc) => bloc.add(const LoadProducts()),
      expect: () => [
        const ProductLoading(),
        ProductLoaded(tProducts),
      ],
      verify: (_) {
        // Verify use case di-call 1x
        verify(() => mockGetProducts()).called(1);
      },
    );

    blocTest<ProductBloc, ProductState>(
      'emits [ProductLoading, ProductError] on failure',
      build: () {
        when(() => mockGetProducts()).thenAnswer(
          (_) async => const ResultFailure(
            ServerFailure(message: 'Server error'),
          ),
        );
        return productBloc;
      },
      act: (bloc) => bloc.add(const LoadProducts()),
      expect: () => [
        const ProductLoading(),
        const ProductError('Server error'),
      ],
    );

    blocTest<ProductBloc, ProductState>(
      'emits [ProductLoading, ProductError] with NetworkFailure message',
      build: () {
        when(() => mockGetProducts()).thenAnswer(
          (_) async => const ResultFailure(NetworkFailure()),
        );
        return productBloc;
      },
      act: (bloc) => bloc.add(const LoadProducts()),
      expect: () => [
        const ProductLoading(),
        const ProductError('Tidak ada koneksi internet'),
      ],
    );
  });

  group('CreateProductEvent', () {
    const newProduct = Product(id: '', name: 'New Product', price: 150.0, stock: 0);

    blocTest<ProductBloc, ProductState>(
      'emits [ProductCreated, ProductLoaded] on success',
      build: () {
        when(() => mockCreateProduct(newProduct)).thenAnswer(
          (_) async => const Success(
            Product(id: '3', name: 'New Product', price: 150.0, stock: 0),
          ),
        );
        return productBloc;
      },
      seed: () => ProductLoaded(tProducts), // Initial state
      act: (bloc) => bloc.add(const CreateProductEvent(newProduct)),
      expect: () => [
        isA<ProductCreated>(),
        isA<ProductLoaded>().having(
          (s) => s.products.length,
          'products count',
          tProducts.length + 1,
        ),
      ],
    );

    blocTest<ProductBloc, ProductState>(
      'emits [ProductOperationError] on failure',
      build: () {
        when(() => mockCreateProduct(newProduct)).thenAnswer(
          (_) async => const ResultFailure(
            ServerFailure(message: 'Create failed'),
          ),
        );
        return productBloc;
      },
      seed: () => ProductLoaded(tProducts),
      act: (bloc) => bloc.add(const CreateProductEvent(newProduct)),
      expect: () => [
        isA<ProductOperationError>().having(
          (s) => s.message,
          'error message',
          'Create failed',
        ),
      ],
    );
  });

  group('DeleteProductEvent', () {
    blocTest<ProductBloc, ProductState>(
      'emits [ProductDeleted, ProductLoaded] removing deleted product',
      build: () {
        when(() => mockDeleteProduct('1')).thenAnswer(
          (_) async => const Success(null),
        );
        return productBloc;
      },
      seed: () => ProductLoaded(tProducts),
      act: (bloc) => bloc.add(const DeleteProductEvent(id: '1')),
      expect: () => [
        isA<ProductDeleted>(),
        isA<ProductLoaded>().having(
          (s) => s.products.length,
          'products count',
          tProducts.length - 1,
        ),
      ],
    );
  });
}
```


### Step 2: Cubit Unit Tests

```dart
// test/core/network/connectivity_cubit_test.dart
import 'package:bloc_test/bloc_test.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockConnectivity extends Mock implements Connectivity {}

void main() {
  late MockConnectivity mockConnectivity;
  final onConnectivityChangedController = StreamController<ConnectivityResult>();

  setUp(() {
    mockConnectivity = MockConnectivity();
    when(() => mockConnectivity.onConnectivityChanged)
        .thenAnswer((_) => onConnectivityChangedController.stream);
  });

  tearDown(() => onConnectivityChangedController.close());

  blocTest<ConnectivityCubit, ConnectivityState>(
    'emits isConnected=false when connectivity changes to none',
    build: () => ConnectivityCubit(),
    act: (cubit) {
      onConnectivityChangedController.add(ConnectivityResult.none);
    },
    expect: () => [const ConnectivityState(isConnected: false)],
  );

  blocTest<ConnectivityCubit, ConnectivityState>(
    'emits isConnected=true when connectivity restored',
    build: () => ConnectivityCubit(),
    act: (cubit) {
      onConnectivityChangedController
        ..add(ConnectivityResult.none)
        ..add(ConnectivityResult.wifi);
    },
    expect: () => [
      const ConnectivityState(isConnected: false),
      const ConnectivityState(isConnected: true),
    ],
  );
}
```


### Step 3: Widget Tests dengan MockBloc

```dart
// test/features/products/presentation/screens/product_list_screen_test.dart
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

// MockBloc — cara BLoC, bukan Riverpod!
class MockProductBloc extends MockBloc<ProductEvent, ProductState>
    implements ProductBloc {}

void main() {
  late MockProductBloc mockProductBloc;

  final tProducts = [
    const Product(id: '1', name: 'Test Product', price: 99.99, stock: 5),
    const Product(id: '2', name: 'Another Product', price: 49.99, stock: 2),
  ];

  setUp(() {
    mockProductBloc = MockProductBloc();
  });

  // Helper untuk build widget dengan BlocProvider.value()
  // PERBEDAAN KUNCI dari Riverpod (ProviderScope + overrides)
  Widget createWidget() => MaterialApp(
        home: BlocProvider<ProductBloc>.value(
          value: mockProductBloc,
          child: const ProductListScreen(),
        ),
      );

  group('ProductListScreen', () {
    testWidgets('shows shimmer/loading when ProductLoading', (tester) async {
      // whenListen: setup stream dan initial state
      whenListen(
        mockProductBloc,
        Stream<ProductState>.empty(),
        initialState: const ProductLoading(),
      );

      await tester.pumpWidget(createWidget());

      expect(find.byType(ProductListShimmer), findsOneWidget);
    });

    testWidgets('shows product list when ProductLoaded', (tester) async {
      whenListen(
        mockProductBloc,
        Stream<ProductState>.empty(),
        initialState: ProductLoaded(tProducts),
      );

      await tester.pumpWidget(createWidget());

      expect(find.text('Test Product'), findsOneWidget);
      expect(find.text('Another Product'), findsOneWidget);
    });

    testWidgets('shows empty state when ProductLoaded with empty list',
        (tester) async {
      whenListen(
        mockProductBloc,
        Stream<ProductState>.empty(),
        initialState: const ProductLoaded([]),
      );

      await tester.pumpWidget(createWidget());

      expect(find.byType(EmptyView), findsOneWidget);
    });

    testWidgets('shows error view with retry when ProductError', (tester) async {
      whenListen(
        mockProductBloc,
        Stream<ProductState>.empty(),
        initialState: const ProductError('Server error'),
      );

      await tester.pumpWidget(createWidget());

      expect(find.text('Server error'), findsOneWidget);
      expect(find.text('Coba Lagi'), findsOneWidget);
    });

    testWidgets('dispatches LoadProducts on retry tap', (tester) async {
      whenListen(
        mockProductBloc,
        Stream<ProductState>.empty(),
        initialState: const ProductError('Network error'),
      );

      await tester.pumpWidget(createWidget());
      await tester.tap(find.text('Coba Lagi'));
      await tester.pump();

      verify(() => mockProductBloc.add(const LoadProducts())).called(1);
    });

    testWidgets('shows SnackBar on ProductCreated (BlocListener)', (tester) async {
      // Test BlocListener dengan stream yang emit state transition
      whenListen(
        mockProductBloc,
        Stream.fromIterable([
          ProductLoaded(tProducts),
          ProductCreated(
            product: const Product(id: '3', name: 'New', price: 100, stock: 0),
            updatedProducts: [...tProducts],
          ),
          ProductLoaded(tProducts),
        ]),
        initialState: const ProductLoading(),
      );

      await tester.pumpWidget(createWidget());
      await tester.pump();

      expect(find.text('Produk berhasil dibuat'), findsOneWidget);
    });

    testWidgets('dispatches LoadProducts on init', (tester) async {
      whenListen(
        mockProductBloc,
        Stream<ProductState>.empty(),
        initialState: const ProductInitial(),
      );

      await tester.pumpWidget(createWidget());

      verify(() => mockProductBloc.add(const LoadProducts())).called(1);
    });
  });
}
```


### Step 4: Repository Unit Tests

```dart
// test/features/products/data/repositories/product_repository_impl_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockProductRemoteDataSource extends Mock
    implements ProductRemoteDataSource {}

class MockProductLocalDataSource extends Mock
    implements ProductLocalDataSource {}

class MockNetworkInfo extends Mock implements NetworkInfo {}

void main() {
  late ProductRepositoryImpl repository;
  late MockProductRemoteDataSource mockRemote;
  late MockProductLocalDataSource mockLocal;
  late MockNetworkInfo mockNetworkInfo;

  setUp(() {
    mockRemote = MockProductRemoteDataSource();
    mockLocal = MockProductLocalDataSource();
    mockNetworkInfo = MockNetworkInfo();
    repository = ProductRepositoryImpl(
      remote: mockRemote,
      local: mockLocal,
      networkInfo: mockNetworkInfo,
    );
  });

  final tProductModels = [
    ProductModel(id: '1', name: 'Test', price: 100.0, stock: 5),
  ];
  final tProducts = tProductModels.map((m) => m.toEntity()).toList();

  group('getProducts - ONLINE', () {
    setUp(() {
      when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
    });

    test('returns Success(products) and caches on page 1 hit', () async {
      when(() => mockRemote.getProducts(page: 1, limit: 20, search: null))
          .thenAnswer((_) async => tProductModels);
      when(() => mockLocal.cacheProducts(any())).thenAnswer((_) async {});

      final result = await repository.getProducts(page: 1, limit: 20);

      expect(result, isA<Success<List<Product>>>());
      expect((result as Success).value, tProducts);
      verify(() => mockLocal.cacheProducts(tProductModels)).called(1);
    });

    test('does NOT cache on page 2', () async {
      when(() => mockRemote.getProducts(page: 2, limit: 20, search: null))
          .thenAnswer((_) async => tProductModels);

      await repository.getProducts(page: 2, limit: 20);

      verifyNever(() => mockLocal.cacheProducts(any()));
    });

    test('returns ResultFailure(ServerFailure) on ServerException', () async {
      when(() => mockRemote.getProducts(page: 1, limit: 20, search: null))
          .thenThrow(const ServerException(message: 'Server error'));

      final result = await repository.getProducts(page: 1, limit: 20);

      expect(result, isA<ResultFailure<List<Product>>>());
    });
  });

  group('getProducts - OFFLINE', () {
    setUp(() {
      when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => false);
    });

    test('returns cached data when offline', () async {
      when(() => mockLocal.getCachedProducts())
          .thenAnswer((_) async => tProductModels);

      final result = await repository.getProducts();

      expect(result, isA<Success<List<Product>>>());
      verifyNever(() => mockRemote.getProducts());
    });

    test('returns CacheFailure when no cache', () async {
      when(() => mockLocal.getCachedProducts())
          .thenThrow(const CacheException(message: 'No cache'));

      final result = await repository.getProducts();

      expect(result, isA<ResultFailure<List<Product>>>());
    });
  });
}
```


### Step 5: CI/CD Pipeline (GitHub Actions)

```yaml
# .github/workflows/flutter-ci.yml
name: Flutter BLoC CI/CD

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

jobs:
  test:
    name: Test & Analyze
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.22.x'
          channel: stable
          cache: true

      - name: Install dependencies
        run: flutter pub get

      # Perbedaan dari Riverpod: BLoC butuh build_runner untuk injectable!
      - name: Generate code (injectable + json_serializable)
        run: dart run build_runner build --delete-conflicting-outputs

      - name: Analyze
        run: flutter analyze --no-fatal-infos

      - name: Run Unit & Widget Tests
        run: flutter test --coverage --no-test-randomize-ordering-seed

      - name: Upload coverage
        uses: codecov/codecov-action@v4
        with:
          file: coverage/lcov.info
          token: ${{ secrets.CODECOV_TOKEN }}

  build-android:
    name: Build Android APK
    needs: test
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main'
    steps:
      - uses: actions/checkout@v4

      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.22.x'
          channel: stable
          cache: true

      - name: Setup Java
        uses: actions/setup-java@v4
        with:
          distribution: temurin
          java-version: '17'

      - name: Install dependencies
        run: flutter pub get

      - name: Generate code
        run: dart run build_runner build --delete-conflicting-outputs

      - name: Build APK
        run: flutter build apk --release
        env:
          SUPABASE_URL: ${{ secrets.SUPABASE_URL }}
          SUPABASE_ANON_KEY: ${{ secrets.SUPABASE_ANON_KEY }}

      - name: Upload APK artifact
        uses: actions/upload-artifact@v4
        with:
          name: release-apk
          path: build/app/outputs/flutter-apk/app-release.apk
```


### Step 6: Integration Tests

```dart
// integration_test/app_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Product Flow Integration', () {
    testWidgets('Load, view, and delete product', (tester) async {
      await app.main();
      await tester.pumpAndSettle();

      // Login
      await tester.enterText(
          find.byKey(const Key('email_field')), 'test@example.com');
      await tester.enterText(
          find.byKey(const Key('password_field')), 'password123');
      await tester.tap(find.byKey(const Key('login_button')));
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Navigate ke products
      await tester.tap(find.text('Products'));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Verify product list tampil
      expect(find.byType(ProductListItem), findsWidgets);

      // Tap produk pertama
      await tester.tap(find.byType(ProductListItem).first);
      await tester.pumpAndSettle();

      // Verify detail screen
      expect(find.text('Product Detail'), findsOneWidget);
    });
  });
}
```


## Success Criteria

- [ ] `blocTest<Bloc, State>()` untuk semua Bloc unit tests
- [ ] `tearDown(() => bloc.close())` di setiap test group
- [ ] Widget tests pakai `BlocProvider.value()`, bukan `BlocProvider(create: ...)`
- [ ] `whenListen` untuk setup mock bloc state
- [ ] `verify()` di-call untuk events penting
- [ ] Repository tests dengan `MockNetworkInfo` (online + offline scenarios)
- [ ] CI/CD dengan `build_runner build` step sebelum `flutter analyze`
- [ ] Coverage > 70% (target per fitur)
- [ ] `flutter test` sukses tanpa errors


## Next Steps

- Advanced patterns → `09_state_management_advanced.md`
- Offline storage → `10_offline_storage.md`
- UI components → `11_ui_components.md`

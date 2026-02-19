---
description: Comprehensive testing (unit, widget, integration) dan production preparation khusus Flutter BLoC: `bloc_test` package... (Sub-part 1/3)
---
# Workflow: Testing & Production (Flutter BLoC) (Part 2/8)

> **Navigation:** This workflow is split into 8 parts.

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
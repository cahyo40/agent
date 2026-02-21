---
description: Comprehensive testing (unit, widget, integration) dan production preparation untuk Flutter app dengan GetX state mana... (Sub-part 1/3)
---
# Workflow: Testing & Production (GetX) (Part 2/8)

> **Navigation:** This workflow is split into 8 parts.

## Deliverables

### 1. Unit Testing (GetX Controllers)

Unit test untuk GetX berfokus pada testing `GetxController` dan services secara terisolasi. Gunakan `Get.put()` untuk inject dependencies dan `Get.reset()` di `tearDown` untuk membersihkan state.

#### 1.1 Setup Test Helpers

```dart
// test/helpers/test_helpers.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mocktail/mocktail.dart';

// Mock classes
class MockProductRepository extends Mock implements ProductRepository {}

class MockAuthRepository extends Mock implements AuthRepository {}

class MockOrderRepository extends Mock implements OrderRepository {}

class MockNetworkService extends Mock implements NetworkService {}

class MockStorageService extends Mock implements StorageService {}

class MockAnalyticsService extends Mock implements AnalyticsService {}

// Fake classes untuk registerFallbackValue
class FakeProduct extends Fake implements Product {}

class FakeUser extends Fake implements User {}

class FakeOrder extends Fake implements Order {}

/// Setup semua fallback values sebelum test suite berjalan
void setupTestFallbackValues() {
  registerFallbackValue(FakeProduct());
  registerFallbackValue(FakeUser());
  registerFallbackValue(FakeOrder());
}

/// Reset semua GetX bindings dan dependencies
void resetGetX() {
  Get.reset();
}

/// Helper untuk setup controller dengan mock dependencies
T setupController<T extends GetxController>(
  T controller, {
  List<void Function()>? additionalSetup,
}) {
  additionalSetup?.forEach((setup) => setup());
  return Get.put<T>(controller);
}

// Test data factories
class TestDataFactory {
  static Product createProduct({
    String id = 'prod-001',
    String name = 'Test Product',
    double price = 29999.0,
    int stock = 50,
    String category = 'Electronics',
  }) {
    return Product(
      id: id,
      name: name,
      price: price,
      stock: stock,
      category: category,
      createdAt: DateTime(2025, 1, 1),
    );
  }

  static User createUser({
    String id = 'user-001',
    String name = 'Test User',
    String email = 'test@example.com',
  }) {
    return User(
      id: id,
      name: name,
      email: email,
      createdAt: DateTime(2025, 1, 1),
    );
  }

  static Order createOrder({
    String id = 'order-001',
    String userId = 'user-001',
    List<OrderItem>? items,
    OrderStatus status = OrderStatus.pending,
  }) {
    return Order(
      id: id,
      userId: userId,
      items: items ?? [
        OrderItem(
          productId: 'prod-001',
          quantity: 2,
          price: 29999.0,
        ),
      ],
      status: status,
      createdAt: DateTime(2025, 1, 1),
    );
  }
}
```

#### 1.2 Testing GetxController - ProductController

```dart
// test/unit/controllers/product_controller_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dartz/dartz.dart';

import 'package:app/features/product/data/repositories/product_repository.dart';
import 'package:app/features/product/presentation/controllers/product_controller.dart';
import 'package:app/core/errors/failures.dart';
import '../../helpers/test_helpers.dart';

void main() {
  late ProductController controller;
  late MockProductRepository mockRepository;

  setUpAll(() {
    setupTestFallbackValues();
  });

  setUp(() {
    mockRepository = MockProductRepository();
    Get.put<ProductRepository>(mockRepository);
    controller = Get.put(ProductController());
  });

  tearDown(() {
    Get.reset();
  });

  group('ProductController - Initialization', () {
    test('should have empty products list initially', () {
      // GetxController belum onInit sampai di-attach ke widget
      // atau dipanggil manual
      expect(controller.products, isEmpty);
      expect(controller.isLoading.value, false);
      expect(controller.errorMessage.value, '');
    });

    test('should fetch products on onInit', () async {
      final testProducts = [
        TestDataFactory.createProduct(id: 'p1', name: 'Product 1'),
        TestDataFactory.createProduct(id: 'p2', name: 'Product 2'),
      ];

      when(() => mockRepository.getProducts())
          .thenAnswer((_) async => Right(testProducts));

      // Panggil onInit secara manual untuk unit test
      controller.onInit();
      await Future.delayed(Duration.zero);

      expect(controller.products.length, 2);
      expect(controller.products[0].name, 'Product 1');
      expect(controller.isLoading.value, false);
      verify(() => mockRepository.getProducts()).called(1);
    });

    test('should handle error on fetch products failure', () async {
      when(() => mockRepository.getProducts())
          .thenAnswer((_) async => Left(ServerFailure('Server error')));

      controller.onInit();
      await Future.delayed(Duration.zero);

      expect(controller.products, isEmpty);
      expect(controller.isLoading.value, false);
      expect(controller.errorMessage.value, 'Server error');
    });
  });

  group('ProductController - CRUD Operations', () {
    test('should add product successfully', () async {
      final newProduct = TestDataFactory.createProduct(
        id: 'p-new',
        name: 'New Product',
      );

      when(() => mockRepository.addProduct(any()))
          .thenAnswer((_) async => Right(newProduct));
      when(() => mockRepository.getProducts())
          .thenAnswer((_) async => Right([newProduct]));

      await controller.addProduct(newProduct);

      expect(controller.isLoading.value, false);
      verify(() => mockRepository.addProduct(newProduct)).called(1);
    });

    test('should update product successfully', () async {
      final updatedProduct = TestDataFactory.createProduct(
        id: 'p1',
        name: 'Updated Product',
        price: 39999.0,
      );

      when(() => mockRepository.updateProduct(any()))
          .thenAnswer((_) async => Right(updatedProduct));
      when(() => mockRepository.getProducts())
          .thenAnswer((_) async => Right([updatedProduct]));

      await controller.updateProduct(updatedProduct);

      verify(() => mockRepository.updateProduct(updatedProduct)).called(1);
    });

    test('should delete product successfully', () async {
      when(() => mockRepository.deleteProduct(any()))
          .thenAnswer((_) async => const Right(unit));
      when(() => mockRepository.getProducts())
          .thenAnswer((_) async => const Right([]));

      await controller.deleteProduct('p1');

      verify(() => mockRepository.deleteProduct('p1')).called(1);
    });

    test('should handle add product failure', () async {
      final newProduct = TestDataFactory.createProduct();

      when(() => mockRepository.addProduct(any()))
          .thenAnswer((_) async => Left(ServerFailure('Gagal menambah produk')));

      await controller.addProduct(newProduct);

      expect(controller.errorMessage.value, 'Gagal menambah produk');
    });
  });

  group('ProductController - Search & Filter', () {
    final allProducts = [
      TestDataFactory.createProduct(id: 'p1', name: 'Laptop Gaming', category: 'Electronics'),
      TestDataFactory.createProduct(id: 'p2', name: 'Mouse Wireless', category: 'Electronics'),
      TestDataFactory.createProduct(id: 'p3', name: 'Buku Flutter', category: 'Books'),
    ];

    setUp(() {
      when(() => mockRepository.getProducts())
          .thenAnswer((_) async => Right(allProducts));
    });

    test('should filter products by search query', () async {
      controller.onInit();
      await Future.delayed(Duration.zero);

      controller.searchProducts('Laptop');

      expect(controller.filteredProducts.length, 1);
      expect(controller.filteredProducts[0].name, 'Laptop Gaming');
    });

    test('should filter products by category', () async {
      controller.onInit();
      await Future.delayed(Duration.zero);

      controller.filterByCategory('Books');

      expect(controller.filteredProducts.length, 1);
      expect(controller.filteredProducts[0].category, 'Books');
    });

    test('should return all products when search query is empty', () async {
      controller.onInit();
      await Future.delayed(Duration.zero);

      controller.searchProducts('');

      expect(controller.filteredProducts.length, 3);
    });

    test('should sort products by price ascending', () async {
      controller.onInit();
      await Future.delayed(Duration.zero);

      controller.sortByPrice(ascending: true);

      expect(controller.filteredProducts.first.price,
          lessThanOrEqualTo(controller.filteredProducts.last.price));
    });
  });

  group('ProductController - Pagination', () {
    test('should load more products', () async {
      final page1 = List.generate(
        20,
        (i) => TestDataFactory.createProduct(id: 'p$i', name: 'Product $i'),
      );
      final page2 = List.generate(
        10,
        (i) => TestDataFactory.createProduct(id: 'p${20 + i}', name: 'Product ${20 + i}'),
      );

      when(() => mockRepository.getProducts(page: 1, limit: 20))
          .thenAnswer((_) async => Right(page1));
      when(() => mockRepository.getProducts(page: 2, limit: 20))
          .thenAnswer((_) async => Right(page2));

      await controller.loadProducts(page: 1);
      expect(controller.products.length, 20);

      await controller.loadMore();
      expect(controller.products.length, 30);
      expect(controller.hasMore.value, false);
    });

    test('should not load more when already loading', () async {
      controller.isLoadingMore.value = true;

      await controller.loadMore();

      verifyNever(() => mockRepository.getProducts(page: any(named: 'page')));
    });
  });

  group('ProductController - Reactive State (Rx)', () {
    test('should update selectedProduct reactively', () async {
      final product = TestDataFactory.createProduct();
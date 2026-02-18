# Workflow: Testing & Production (GetX)

## Overview

Comprehensive testing (unit, widget, integration) dan production preparation untuk Flutter app dengan GetX state management. Workflow ini mencakup seluruh pipeline dari menulis test hingga deploy ke production, termasuk CI/CD setup, performance optimization, dan production checklist.

Berbeda dengan Riverpod yang membutuhkan `ProviderScope` dan `ProviderContainer` untuk testing, GetX menggunakan pendekatan yang lebih straightforward: `Get.put()` untuk dependency injection dan `Get.reset()` untuk cleanup. Tidak diperlukan code generation (`build_runner`) sehingga CI/CD pipeline lebih sederhana.

## Output Location

**Base Folder:** `sdlc/flutter-getx/06-testing-production/`

```
sdlc/flutter-getx/06-testing-production/
  unit-tests/
    controller_tests.dart
    service_tests.dart
    repository_tests.dart
    binding_tests.dart
  widget-tests/
    view_tests.dart
    component_tests.dart
    navigation_tests.dart
  integration-tests/
    app_test.dart
    flow_tests.dart
  ci-cd/
    github-actions.yml
    fastlane/
      Fastfile
      Appfile
      Matchfile
  performance/
    optimization_checklist.md
    benchmark_results.md
  production/
    release_checklist.md
    monitoring_setup.md
```

## Prerequisites

- Flutter SDK >= 3.24.0
- Semua deliverable dari workflow 01-05 sudah selesai
- Dependencies testing sudah ditambahkan di `pubspec.yaml`

### Testing Dependencies

```yaml
# pubspec.yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  integration_test:
    sdk: flutter
  mocktail: ^1.0.4
  fake_async: ^1.3.1
  golden_toolkit: ^0.15.0
  flutter_lints: ^3.0.0
  coverage: ^1.9.2
  test: ^1.25.0
```

> **Catatan:** Tidak perlu `riverpod_test`, `state_notifier_test`, atau `build_runner`. GetX testing hanya membutuhkan `mocktail` untuk mocking dan standard Flutter test utilities.

---

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

      controller.selectProduct(product);

      expect(controller.selectedProduct.value, product);
    });

    test('should compute total value reactively', () async {
      final products = [
        TestDataFactory.createProduct(price: 10000.0, stock: 5),
        TestDataFactory.createProduct(id: 'p2', price: 20000.0, stock: 3),
      ];

      when(() => mockRepository.getProducts())
          .thenAnswer((_) async => Right(products));

      controller.onInit();
      await Future.delayed(Duration.zero);

      // totalValue = (10000 * 5) + (20000 * 3) = 110000
      expect(controller.totalInventoryValue, 110000.0);
    });
  });
}
```

#### 1.3 Testing Service Layer

```dart
// test/unit/services/auth_service_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dartz/dartz.dart';

import 'package:app/core/services/auth_service.dart';
import 'package:app/features/auth/data/repositories/auth_repository.dart';
import '../../helpers/test_helpers.dart';

void main() {
  late AuthService authService;
  late MockAuthRepository mockAuthRepo;
  late MockStorageService mockStorage;

  setUp(() {
    mockAuthRepo = MockAuthRepository();
    mockStorage = MockStorageService();
    Get.put<AuthRepository>(mockAuthRepo);
    Get.put<StorageService>(mockStorage);
    authService = Get.put(AuthService());
  });

  tearDown(() {
    Get.reset();
  });

  group('AuthService - Login', () {
    test('should login successfully and save token', () async {
      const email = 'test@example.com';
      const password = 'password123';
      final user = TestDataFactory.createUser(email: email);
      const token = 'jwt-token-123';

      when(() => mockAuthRepo.login(email, password))
          .thenAnswer((_) async => Right(AuthResult(user: user, token: token)));
      when(() => mockStorage.saveToken(token))
          .thenAnswer((_) async => {});
      when(() => mockStorage.saveUser(any()))
          .thenAnswer((_) async => {});

      final result = await authService.login(email, password);

      expect(result.isRight(), true);
      expect(authService.currentUser.value, user);
      expect(authService.isAuthenticated.value, true);
      verify(() => mockStorage.saveToken(token)).called(1);
    });

    test('should handle login failure', () async {
      when(() => mockAuthRepo.login(any(), any()))
          .thenAnswer((_) async => Left(AuthFailure('Invalid credentials')));

      final result = await authService.login('wrong@email.com', 'wrong');

      expect(result.isLeft(), true);
      expect(authService.isAuthenticated.value, false);
      expect(authService.currentUser.value, null);
    });

    test('should handle network error during login', () async {
      when(() => mockAuthRepo.login(any(), any()))
          .thenThrow(NetworkException('No internet'));

      final result = await authService.login('test@example.com', 'pass');

      expect(result.isLeft(), true);
    });
  });

  group('AuthService - Logout', () {
    test('should logout and clear stored data', () async {
      when(() => mockAuthRepo.logout())
          .thenAnswer((_) async => const Right(unit));
      when(() => mockStorage.clearAll())
          .thenAnswer((_) async => {});

      await authService.logout();

      expect(authService.currentUser.value, null);
      expect(authService.isAuthenticated.value, false);
      verify(() => mockStorage.clearAll()).called(1);
    });
  });

  group('AuthService - Token Refresh', () {
    test('should refresh token when expired', () async {
      const oldToken = 'old-token';
      const newToken = 'new-token';

      when(() => mockStorage.getToken())
          .thenAnswer((_) async => oldToken);
      when(() => mockAuthRepo.refreshToken(oldToken))
          .thenAnswer((_) async => Right(newToken));
      when(() => mockStorage.saveToken(newToken))
          .thenAnswer((_) async => {});

      final result = await authService.refreshToken();

      expect(result, true);
      verify(() => mockStorage.saveToken(newToken)).called(1);
    });
  });
}
```

#### 1.4 Testing GetX Bindings

```dart
// test/unit/bindings/product_binding_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import 'package:app/features/product/bindings/product_binding.dart';
import 'package:app/features/product/presentation/controllers/product_controller.dart';
import 'package:app/features/product/data/repositories/product_repository.dart';
import '../../helpers/test_helpers.dart';

void main() {
  tearDown(() {
    Get.reset();
  });

  group('ProductBinding', () {
    test('should register all required dependencies', () {
      // Pre-register dependencies yang dibutuhkan ProductBinding
      Get.put<ProductRepository>(MockProductRepository());

      // Execute binding
      ProductBinding().dependencies();

      // Verify semua controller ter-register
      expect(Get.isRegistered<ProductController>(), true);
    });

    test('should use lazyPut for controllers', () {
      Get.put<ProductRepository>(MockProductRepository());

      ProductBinding().dependencies();

      // Controller harus bisa di-find
      final controller = Get.find<ProductController>();
      expect(controller, isA<ProductController>());
    });

    test('should allow re-registration after reset', () {
      Get.put<ProductRepository>(MockProductRepository());

      ProductBinding().dependencies();
      Get.reset();

      // Setelah reset, binding bisa dipanggil lagi
      Get.put<ProductRepository>(MockProductRepository());
      ProductBinding().dependencies();

      expect(Get.isRegistered<ProductController>(), true);
    });
  });
}
```

---

### 2. Widget Testing (GetX)

Widget testing dengan GetX menggunakan `GetMaterialApp` sebagai wrapper, bukan `ProviderScope`. Mock controller di-inject via `Get.put()` sebelum widget di-pump.

#### 2.1 Widget Test Helper

```dart
// test/helpers/widget_test_helpers.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

/// Wrap widget dengan GetMaterialApp untuk testing
/// Ini menggantikan ProviderScope di Riverpod
Widget createTestableWidget(Widget child, {
  String initialRoute = '/',
  List<GetPage>? pages,
  Locale? locale,
  ThemeData? theme,
}) {
  return GetMaterialApp(
    home: child,
    locale: locale,
    theme: theme ?? ThemeData.light(),
    getPages: pages,
    debugShowCheckedModeBanner: false,
  );
}

/// Setup mock controller dan return ke caller
T setupMockController<T extends GetxController>(T mock) {
  Get.put<T>(mock, permanent: true);
  return mock;
}

/// Pump widget dan tunggu semua frame selesai
Future<void> pumpAndSettle(
  WidgetTester tester,
  Widget widget, {
  Duration? duration,
}) async {
  await tester.pumpWidget(createTestableWidget(widget));
  if (duration != null) {
    await tester.pump(duration);
  } else {
    await tester.pumpAndSettle();
  }
}

/// Extension untuk WidgetTester supaya lebih readable
extension WidgetTesterGetX on WidgetTester {
  Future<void> pumpGetWidget(Widget widget, {ThemeData? theme}) async {
    await pumpWidget(createTestableWidget(widget, theme: theme));
    await pumpAndSettle();
  }
}
```

#### 2.2 Testing Views

```dart
// test/widget/views/product_list_view_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mocktail/mocktail.dart';

import 'package:app/features/product/presentation/controllers/product_controller.dart';
import 'package:app/features/product/presentation/views/product_list_view.dart';
import 'package:app/features/product/domain/entities/product.dart';
import '../../helpers/test_helpers.dart';
import '../../helpers/widget_test_helpers.dart';

// Mock controller - perlu extends GetxController
class MockProductController extends GetxController
    with Mock
    implements ProductController {
  @override
  final products = <Product>[].obs;

  @override
  final filteredProducts = <Product>[].obs;

  @override
  final isLoading = false.obs;

  @override
  final errorMessage = ''.obs;

  @override
  final searchQuery = ''.obs;

  @override
  final selectedCategory = ''.obs;
}

void main() {
  late MockProductController mockController;

  setUp(() {
    mockController = MockProductController();
    Get.put<ProductController>(mockController);
  });

  tearDown(() {
    Get.reset();
  });

  group('ProductListView', () {
    testWidgets('should show loading indicator when isLoading is true',
        (tester) async {
      mockController.isLoading.value = true;

      await tester.pumpWidget(
        createTestableWidget(const ProductListView()),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should show products list when data available',
        (tester) async {
      final testProducts = [
        TestDataFactory.createProduct(id: 'p1', name: 'Laptop Gaming'),
        TestDataFactory.createProduct(id: 'p2', name: 'Mouse Wireless'),
      ];

      mockController.products.assignAll(testProducts);
      mockController.filteredProducts.assignAll(testProducts);
      mockController.isLoading.value = false;

      await tester.pumpWidget(
        createTestableWidget(const ProductListView()),
      );
      await tester.pumpAndSettle();

      expect(find.text('Laptop Gaming'), findsOneWidget);
      expect(find.text('Mouse Wireless'), findsOneWidget);
    });

    testWidgets('should show empty state when no products', (tester) async {
      mockController.products.clear();
      mockController.filteredProducts.clear();
      mockController.isLoading.value = false;

      await tester.pumpWidget(
        createTestableWidget(const ProductListView()),
      );
      await tester.pumpAndSettle();

      expect(find.text('Belum ada produk'), findsOneWidget);
    });

    testWidgets('should show error message when error occurs', (tester) async {
      mockController.errorMessage.value = 'Gagal memuat produk';
      mockController.isLoading.value = false;

      await tester.pumpWidget(
        createTestableWidget(const ProductListView()),
      );
      await tester.pumpAndSettle();

      expect(find.text('Gagal memuat produk'), findsOneWidget);
      expect(find.text('Coba Lagi'), findsOneWidget);
    });

    testWidgets('should trigger search when typing in search field',
        (tester) async {
      mockController.filteredProducts.assignAll([
        TestDataFactory.createProduct(name: 'Laptop Gaming'),
      ]);

      await tester.pumpWidget(
        createTestableWidget(const ProductListView()),
      );
      await tester.pumpAndSettle();

      final searchField = find.byType(TextField);
      if (searchField.evaluate().isNotEmpty) {
        await tester.enterText(searchField, 'Laptop');
        await tester.pumpAndSettle();
      }
    });

    testWidgets('should navigate to product detail on tap', (tester) async {
      final product = TestDataFactory.createProduct(name: 'Test Product');
      mockController.filteredProducts.assignAll([product]);

      await tester.pumpWidget(
        GetMaterialApp(
          home: const ProductListView(),
          getPages: [
            GetPage(
              name: '/product-detail',
              page: () => const Scaffold(body: Text('Detail Page')),
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Test Product'));
      await tester.pumpAndSettle();
    });

    testWidgets('should show FAB for adding new product', (tester) async {
      await tester.pumpWidget(
        createTestableWidget(const ProductListView()),
      );
      await tester.pumpAndSettle();

      expect(find.byType(FloatingActionButton), findsOneWidget);
    });

    testWidgets('should handle pull to refresh', (tester) async {
      mockController.filteredProducts.assignAll([
        TestDataFactory.createProduct(name: 'Product 1'),
      ]);

      when(() => mockController.refreshProducts())
          .thenAnswer((_) async => {});

      await tester.pumpWidget(
        createTestableWidget(const ProductListView()),
      );
      await tester.pumpAndSettle();

      // Simulate pull to refresh
      await tester.fling(
        find.byType(ListView),
        const Offset(0, 300),
        800,
      );
      await tester.pumpAndSettle();
    });
  });
}
```

#### 2.3 Testing Components/Widgets Individual

```dart
// test/widget/components/product_card_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import 'package:app/features/product/presentation/widgets/product_card.dart';
import '../../helpers/test_helpers.dart';
import '../../helpers/widget_test_helpers.dart';

void main() {
  tearDown(() => Get.reset());

  group('ProductCard', () {
    testWidgets('should display product information', (tester) async {
      final product = TestDataFactory.createProduct(
        name: 'Laptop ASUS',
        price: 15000000.0,
        stock: 10,
      );

      await tester.pumpWidget(
        createTestableWidget(
          Scaffold(
            body: ProductCard(
              product: product,
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.text('Laptop ASUS'), findsOneWidget);
      expect(find.text('Rp 15.000.000'), findsOneWidget);
      expect(find.text('Stok: 10'), findsOneWidget);
    });

    testWidgets('should show out of stock badge when stock is 0',
        (tester) async {
      final product = TestDataFactory.createProduct(stock: 0);

      await tester.pumpWidget(
        createTestableWidget(
          Scaffold(
            body: ProductCard(product: product, onTap: () {}),
          ),
        ),
      );

      expect(find.text('Habis'), findsOneWidget);
    });

    testWidgets('should call onTap when card is tapped', (tester) async {
      var tapped = false;
      final product = TestDataFactory.createProduct();

      await tester.pumpWidget(
        createTestableWidget(
          Scaffold(
            body: ProductCard(
              product: product,
              onTap: () => tapped = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(ProductCard));
      expect(tapped, true);
    });
  });
}
```

#### 2.4 Testing Navigation dengan GetX

```dart
// test/widget/navigation/navigation_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

void main() {
  tearDown(() => Get.reset());

  group('GetX Navigation Tests', () {
    testWidgets('should navigate to named route', (tester) async {
      await tester.pumpWidget(
        GetMaterialApp(
          initialRoute: '/home',
          getPages: [
            GetPage(
              name: '/home',
              page: () => Scaffold(
                body: ElevatedButton(
                  onPressed: () => Get.toNamed('/detail'),
                  child: const Text('Go to Detail'),
                ),
              ),
            ),
            GetPage(
              name: '/detail',
              page: () => const Scaffold(
                body: Text('Detail Page'),
              ),
            ),
          ],
        ),
      );

      await tester.tap(find.text('Go to Detail'));
      await tester.pumpAndSettle();

      expect(find.text('Detail Page'), findsOneWidget);
    });

    testWidgets('should pass arguments via GetX navigation', (tester) async {
      await tester.pumpWidget(
        GetMaterialApp(
          initialRoute: '/home',
          getPages: [
            GetPage(
              name: '/home',
              page: () => Scaffold(
                body: ElevatedButton(
                  onPressed: () => Get.toNamed(
                    '/detail',
                    arguments: {'productId': 'p1'},
                  ),
                  child: const Text('Go to Detail'),
                ),
              ),
            ),
            GetPage(
              name: '/detail',
              page: () => Scaffold(
                body: Builder(
                  builder: (context) {
                    final args = Get.arguments as Map<String, dynamic>?;
                    return Text('Product: ${args?['productId'] ?? 'none'}');
                  },
                ),
              ),
            ),
          ],
        ),
      );

      await tester.tap(find.text('Go to Detail'));
      await tester.pumpAndSettle();

      expect(find.text('Product: p1'), findsOneWidget);
    });

    testWidgets('should handle GetX dialog', (tester) async {
      await tester.pumpWidget(
        GetMaterialApp(
          home: Scaffold(
            body: ElevatedButton(
              onPressed: () => Get.defaultDialog(
                title: 'Konfirmasi',
                middleText: 'Hapus produk ini?',
              ),
              child: const Text('Show Dialog'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      expect(find.text('Konfirmasi'), findsOneWidget);
      expect(find.text('Hapus produk ini?'), findsOneWidget);
    });
  });
}
```

---

### 3. Integration Testing

Integration test menguji flow lengkap dari UI hingga data layer. Struktur sama dengan Riverpod version, tapi setup menggunakan GetX bindings.

#### 3.1 Integration Test Setup

```dart
// integration_test/app_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:get/get.dart';

import 'package:app/main.dart' as app;
import 'package:app/core/bindings/initial_binding.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    // Reset GetX sebelum setiap integration test
    Get.reset();
  });

  group('App E2E Tests', () {
    testWidgets('complete product flow - create, view, edit, delete',
        (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Step 1: Login
      await tester.enterText(
        find.byKey(const Key('email_field')),
        'admin@example.com',
      );
      await tester.enterText(
        find.byKey(const Key('password_field')),
        'password123',
      );
      await tester.tap(find.byKey(const Key('login_button')));
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Step 2: Navigasi ke halaman produk
      await tester.tap(find.byKey(const Key('menu_products')));
      await tester.pumpAndSettle();

      // Step 3: Tambah produk baru
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const Key('product_name_field')),
        'Integration Test Product',
      );
      await tester.enterText(
        find.byKey(const Key('product_price_field')),
        '50000',
      );
      await tester.tap(find.byKey(const Key('save_button')));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Step 4: Verify produk muncul di list
      expect(find.text('Integration Test Product'), findsOneWidget);

      // Step 5: Edit produk
      await tester.tap(find.text('Integration Test Product'));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('edit_button')));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const Key('product_name_field')),
        'Updated Product',
      );
      await tester.tap(find.byKey(const Key('save_button')));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Step 6: Kembali dan verify update
      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(find.text('Updated Product'), findsOneWidget);

      // Step 7: Delete produk
      await tester.longPress(find.text('Updated Product'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Hapus'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Ya, Hapus'));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Verify produk sudah terhapus
      expect(find.text('Updated Product'), findsNothing);
    });

    testWidgets('authentication flow', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Test invalid login
      await tester.enterText(
        find.byKey(const Key('email_field')),
        'wrong@email.com',
      );
      await tester.enterText(
        find.byKey(const Key('password_field')),
        'wrongpassword',
      );
      await tester.tap(find.byKey(const Key('login_button')));
      await tester.pumpAndSettle(const Duration(seconds: 3));

      expect(find.text('Email atau password salah'), findsOneWidget);

      // Test valid login
      await tester.enterText(
        find.byKey(const Key('email_field')),
        'admin@example.com',
      );
      await tester.enterText(
        find.byKey(const Key('password_field')),
        'password123',
      );
      await tester.tap(find.byKey(const Key('login_button')));
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Verify berhasil login
      expect(find.byKey(const Key('home_screen')), findsOneWidget);

      // Test logout
      await tester.tap(find.byKey(const Key('menu_profile')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Logout'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Ya, Logout'));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      expect(find.byKey(const Key('login_screen')), findsOneWidget);
    });
  });
}
```

#### 3.2 Integration Test dengan Mock API

```dart
// integration_test/mock_api_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:get/get.dart';

import 'package:app/core/network/api_client.dart';
import 'helpers/mock_api_client.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    Get.reset();
    // Inject mock API client sebelum app dimulai
    Get.put<ApiClient>(MockApiClient(), permanent: true);
  });

  testWidgets('should work with mock API', (tester) async {
    // App akan menggunakan MockApiClient karena sudah di-inject
    // sebelum InitialBinding dijalankan
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    // Test flow dengan mock data...
    expect(find.byKey(const Key('home_screen')), findsOneWidget);
  });
}
```

---

### 4. CI/CD Pipeline (GitHub Actions)

Pipeline CI/CD untuk GetX project **lebih sederhana** karena tidak membutuhkan `build_runner` step. Tidak ada code generation yang perlu di-run sebelum testing.

#### 4.1 GitHub Actions - CI

```yaml
# .github/workflows/ci.yml
name: CI Pipeline

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

concurrency:
  group: ${{ github.workflow }}-${{ github.ref }}
  cancel-in-progress: true

env:
  FLUTTER_VERSION: '3.24.0'
  JAVA_VERSION: '17'

jobs:
  # ---- Analyze & Test ----
  analyze-and-test:
    name: Analyze & Test
    runs-on: ubuntu-latest
    timeout-minutes: 30

    steps:
      - name: Checkout repository
        uses: actions/checkout@v4

      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: ${{ env.FLUTTER_VERSION }}
          cache: true

      - name: Install dependencies
        run: flutter pub get

      # CATATAN: Tidak perlu step build_runner / code generation!
      # GetX tidak membutuhkan code generation seperti Riverpod.

      - name: Analyze code
        run: flutter analyze --fatal-infos

      - name: Check formatting
        run: dart format --set-exit-if-changed .

      - name: Run unit tests
        run: flutter test --coverage --reporter=github

      - name: Check coverage threshold
        run: |
          COVERAGE=$(lcov --summary coverage/lcov.info 2>&1 | grep 'lines' | sed 's/.*: //' | sed 's/%.*//')
          echo "Coverage: $COVERAGE%"
          if (( $(echo "$COVERAGE < 80" | bc -l) )); then
            echo "::error::Coverage $COVERAGE% is below 80% threshold"
            exit 1
          fi

      - name: Upload coverage to Codecov
        uses: codecov/codecov-action@v4
        with:
          files: coverage/lcov.info
          fail_ci_if_error: true
        env:
          CODECOV_TOKEN: ${{ secrets.CODECOV_TOKEN }}

  # ---- Integration Tests ----
  integration-test:
    name: Integration Tests
    runs-on: macos-latest
    timeout-minutes: 45
    needs: analyze-and-test

    steps:
      - name: Checkout repository
        uses: actions/checkout@v4

      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: ${{ env.FLUTTER_VERSION }}
          cache: true

      - name: Install dependencies
        run: flutter pub get

      - name: Run integration tests (iOS Simulator)
        run: |
          DEVICE_ID=$(xcrun simctl list devices available | grep 'iPhone 15' | head -1 | sed 's/.*(\(.*\)).*/\1/')
          xcrun simctl boot "$DEVICE_ID" || true
          flutter test integration_test --device-id="$DEVICE_ID"

  # ---- Build Android ----
  build-android:
    name: Build Android
    runs-on: ubuntu-latest
    timeout-minutes: 30
    needs: analyze-and-test
    if: github.event_name == 'push' && github.ref == 'refs/heads/main'

    steps:
      - name: Checkout repository
        uses: actions/checkout@v4

      - name: Setup Java
        uses: actions/setup-java@v4
        with:
          distribution: 'temurin'
          java-version: ${{ env.JAVA_VERSION }}

      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: ${{ env.FLUTTER_VERSION }}
          cache: true

      - name: Install dependencies
        run: flutter pub get

      - name: Decode keystore
        run: echo "${{ secrets.KEYSTORE_BASE64 }}" | base64 -d > android/app/release.keystore
        env:
          KEYSTORE_BASE64: ${{ secrets.KEYSTORE_BASE64 }}

      - name: Build APK
        run: |
          flutter build apk --release \
            --dart-define=ENV=production \
            --dart-define=API_URL=${{ secrets.API_URL }}

      - name: Build App Bundle
        run: |
          flutter build appbundle --release \
            --dart-define=ENV=production \
            --dart-define=API_URL=${{ secrets.API_URL }}

      - name: Upload artifacts
        uses: actions/upload-artifact@v4
        with:
          name: android-release
          path: |
            build/app/outputs/flutter-apk/app-release.apk
            build/app/outputs/bundle/release/app-release.aab
          retention-days: 7

  # ---- Build iOS ----
  build-ios:
    name: Build iOS
    runs-on: macos-latest
    timeout-minutes: 45
    needs: analyze-and-test
    if: github.event_name == 'push' && github.ref == 'refs/heads/main'

    steps:
      - name: Checkout repository
        uses: actions/checkout@v4

      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: ${{ env.FLUTTER_VERSION }}
          cache: true

      - name: Install dependencies
        run: flutter pub get

      - name: Install CocoaPods
        run: |
          cd ios
          pod install

      - name: Build iOS (no codesign)
        run: |
          flutter build ios --release --no-codesign \
            --dart-define=ENV=production \
            --dart-define=API_URL=${{ secrets.API_URL }}

      - name: Upload artifacts
        uses: actions/upload-artifact@v4
        with:
          name: ios-release
          path: build/ios/iphoneos/Runner.app
          retention-days: 7
```

#### 4.2 GitHub Actions - CD (Deploy)

```yaml
# .github/workflows/cd.yml
name: CD Pipeline

on:
  push:
    tags:
      - 'v*'

env:
  FLUTTER_VERSION: '3.24.0'

jobs:
  deploy-android:
    name: Deploy to Play Store
    runs-on: ubuntu-latest
    timeout-minutes: 30

    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: ${{ env.FLUTTER_VERSION }}
          cache: true

      - name: Setup Ruby (for Fastlane)
        uses: ruby/setup-ruby@v1
        with:
          ruby-version: '3.2'
          bundler-cache: true
          working-directory: android

      - name: Install dependencies
        run: flutter pub get

      - name: Build AAB
        run: |
          flutter build appbundle --release \
            --build-number=${{ github.run_number }} \
            --dart-define=ENV=production

      - name: Deploy via Fastlane
        run: bundle exec fastlane deploy
        working-directory: android
        env:
          PLAY_STORE_JSON_KEY: ${{ secrets.PLAY_STORE_JSON_KEY }}

  deploy-ios:
    name: Deploy to App Store
    runs-on: macos-latest
    timeout-minutes: 45

    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: ${{ env.FLUTTER_VERSION }}
          cache: true

      - name: Setup Ruby (for Fastlane)
        uses: ruby/setup-ruby@v1
        with:
          ruby-version: '3.2'
          bundler-cache: true
          working-directory: ios

      - name: Install dependencies
        run: flutter pub get

      - name: Install CocoaPods
        run: cd ios && pod install

      - name: Build iOS
        run: |
          flutter build ipa --release \
            --build-number=${{ github.run_number }} \
            --dart-define=ENV=production \
            --export-options-plist=ios/ExportOptions.plist

      - name: Deploy via Fastlane
        run: bundle exec fastlane deploy
        working-directory: ios
        env:
          APP_STORE_CONNECT_API_KEY: ${{ secrets.APP_STORE_CONNECT_API_KEY }}
          MATCH_PASSWORD: ${{ secrets.MATCH_PASSWORD }}
```

---

### 5. Performance Optimization

Performance optimization bersifat framework-agnostic. Panduan berikut berlaku untuk semua Flutter app, dengan catatan tambahan khusus GetX.

#### 5.1 GetX-Specific Optimizations

```dart
// lib/core/performance/getx_optimizations.dart

/// Tips optimasi khusus GetX:

// 1. Gunakan .obs hanya pada data yang benar-benar perlu reactive
class OptimizedController extends GetxController {
  // BAIK: Hanya reactive untuk data yang berubah dan perlu di-observe
  final products = <Product>[].obs;
  final isLoading = false.obs;

  // BURUK: Jangan buat semua field reactive
  // final String _cacheKey = ''.obs;  // ini tidak perlu reactive

  // Gunakan biasa saja kalau tidak perlu reactive
  String cacheKey = '';
}

// 2. Gunakan GetBuilder untuk widget yang jarang update (stateless rebuild)
class ProductCountWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // GetBuilder lebih lightweight daripada Obx untuk update manual
    return GetBuilder<ProductController>(
      builder: (controller) => Text('Total: ${controller.products.length}'),
    );
  }
}

// 3. Hindari nested Obx - combine observables
class ProductListOptimized extends GetView<ProductController> {
  @override
  Widget build(BuildContext context) {
    // BAIK: Satu Obx dengan multiple observables
    return Obx(() {
      if (controller.isLoading.value) {
        return const CircularProgressIndicator();
      }
      return ListView.builder(
        itemCount: controller.filteredProducts.length,
        itemBuilder: (_, i) => ProductCard(
          product: controller.filteredProducts[i],
        ),
      );
    });
  }
}

// 4. Gunakan permanent: false (default) untuk controller yang tidak perlu persist
// Binding akan otomatis dispose controller saat page di-pop

// 5. Worker untuk debounce / throttle
class SearchController extends GetxController {
  final searchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
    // Debounce search agar tidak terlalu sering hit API
    debounce(searchQuery, _performSearch, time: const Duration(milliseconds: 500));
  }

  void _performSearch(String query) {
    // Hit API hanya setelah user berhenti mengetik 500ms
  }
}
```

#### 5.2 General Flutter Performance

```dart
// lib/core/performance/general_optimizations.dart

/// 1. Gunakan const constructor
class MyWidget extends StatelessWidget {
  const MyWidget({super.key}); // <-- const

  @override
  Widget build(BuildContext context) {
    return const Padding( // <-- const
      padding: EdgeInsets.all(16),
      child: Text('Hello'),
    );
  }
}

/// 2. ListView.builder untuk long list (lazy loading)
Widget buildProductList(List<Product> products) {
  return ListView.builder(
    itemCount: products.length,
    // itemExtent membantu Flutter menghitung layout lebih cepat
    itemExtent: 80.0,
    itemBuilder: (_, index) => ProductTile(product: products[index]),
  );
}

/// 3. Cache gambar dengan CachedNetworkImage
Widget buildProductImage(String imageUrl) {
  return CachedNetworkImage(
    imageUrl: imageUrl,
    placeholder: (_, __) => const ShimmerBox(),
    errorWidget: (_, __, ___) => const Icon(Icons.error),
    memCacheWidth: 300, // Resize di memory
  );
}

/// 4. RepaintBoundary untuk isolasi repaint
Widget buildExpensiveWidget() {
  return RepaintBoundary(
    child: CustomPaint(
      painter: ComplexChartPainter(),
    ),
  );
}

/// 5. Avoid rebuilding entire tree
// Pecah widget menjadi smaller widgets agar rebuild lebih targeted

/// 6. Image optimization
// - Gunakan WebP format
// - Resize sesuai kebutuhan display
// - Lazy load images yang off-screen
```

#### 5.3 Performance Profiling

```bash
# Profile mode untuk performance testing
flutter run --profile

# Analyze APK size
flutter build apk --analyze-size --target-platform android-arm64

# Benchmark
flutter drive --profile --driver=test_driver/perf_driver.dart \
  --target=integration_test/perf_test.dart
```

```dart
// integration_test/perf_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('scrolling performance', (tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    final listFinder = find.byType(ListView);

    await binding.traceAction(
      () async {
        for (var i = 0; i < 5; i++) {
          await tester.fling(listFinder, const Offset(0, -500), 10000);
          await tester.pumpAndSettle();
          await tester.fling(listFinder, const Offset(0, 500), 10000);
          await tester.pumpAndSettle();
        }
      },
      reportKey: 'scrolling_timeline',
    );
  });
}
```

---

### 6. Production Checklist

Checklist lengkap sebelum release ke production. Diadaptasi untuk GetX (tanpa code generation atau Riverpod-specific items).

#### 6.1 Code Quality

```markdown
## Code Quality Checklist

- [ ] Semua test pass (`flutter test`)
- [ ] Coverage >= 80% (`flutter test --coverage`)
- [ ] Tidak ada analyzer warnings (`flutter analyze`)
- [ ] Code terformat (`dart format .`)
- [ ] Tidak ada TODO/FIXME yang kritis
- [ ] Tidak ada hardcoded strings (gunakan constants/l10n)
- [ ] Tidak ada hardcoded API URLs (gunakan dart-define / env)
- [ ] Semua unused imports sudah dihapus
- [ ] Tidak ada print() statement (gunakan proper logging)
- [ ] Error handling sudah comprehensive
```

#### 6.2 GetX-Specific Checks

```markdown
## GetX Specific Checklist

- [ ] Semua controller punya proper onClose() untuk cleanup
- [ ] Workers (debounce, interval, ever) di-dispose di onClose()
- [ ] Tidak ada memory leak dari stream subscriptions
- [ ] Get.reset() tidak dipanggil di production code (hanya testing)
- [ ] SmartManagement setting sudah sesuai kebutuhan
- [ ] Binding terdaftar untuk setiap page yang perlu controller
- [ ] GetX translations sudah complete untuk semua locale
- [ ] Route middleware sudah setup untuk protected routes
- [ ] Tidak ada circular dependency di Get.put/Get.find
- [ ] Obx/GetBuilder digunakan dengan tepat (bukan berlebihan)
```

#### 6.3 Security

```markdown
## Security Checklist

- [ ] API keys tidak di-commit ke repository
- [ ] Sensitive data dienkripsi di local storage
- [ ] Certificate pinning diaktifkan
- [ ] Obfuscation enabled di release build
- [ ] ProGuard/R8 rules configured (Android)
- [ ] No debug logging in release mode
- [ ] JWT token refresh mechanism works
- [ ] Input validation di semua form
- [ ] SQL injection prevention (parameterized queries)
- [ ] XSS prevention (sanitize HTML input)
```

#### 6.4 App Configuration

```dart
// lib/core/config/app_config.dart

/// Environment configuration menggunakan dart-define
/// Build command: flutter build apk --dart-define=ENV=production
class AppConfig {
  static const String environment = String.fromEnvironment(
    'ENV',
    defaultValue: 'development',
  );

  static const String apiUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: 'http://localhost:3000/api',
  );

  static const String sentryDsn = String.fromEnvironment(
    'SENTRY_DSN',
    defaultValue: '',
  );

  static bool get isProduction => environment == 'production';
  static bool get isDevelopment => environment == 'development';
  static bool get isStaging => environment == 'staging';
}
```

#### 6.5 Error Monitoring & Crash Reporting

```dart
// lib/main.dart
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Setup error handling
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    if (kReleaseMode) {
      Sentry.captureException(
        details.exception,
        stackTrace: details.stack,
      );
    }
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    if (kReleaseMode) {
      Sentry.captureException(error, stackTrace: stack);
    }
    return true;
  };

  await SentryFlutter.init(
    (options) {
      options.dsn = AppConfig.sentryDsn;
      options.environment = AppConfig.environment;
      options.tracesSampleRate = AppConfig.isProduction ? 0.2 : 1.0;
    },
    appRunner: () => runApp(const MyApp()),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'My App',
      initialBinding: InitialBinding(),
      initialRoute: AppRoutes.splash,
      getPages: AppPages.routes,
      navigatorObservers: [
        SentryNavigatorObserver(),
      ],
    );
  }
}
```

#### 6.6 Release Build Configuration

```markdown
## Build Commands

### Android
```bash
# APK
flutter build apk --release \
  --obfuscate \
  --split-debug-info=build/debug-info \
  --dart-define=ENV=production \
  --dart-define=API_URL=https://api.example.com \
  --dart-define=SENTRY_DSN=https://xxx@sentry.io/xxx

# App Bundle (untuk Play Store)
flutter build appbundle --release \
  --obfuscate \
  --split-debug-info=build/debug-info \
  --dart-define=ENV=production \
  --dart-define=API_URL=https://api.example.com
```

### iOS
```bash
flutter build ipa --release \
  --obfuscate \
  --split-debug-info=build/debug-info \
  --dart-define=ENV=production \
  --dart-define=API_URL=https://api.example.com \
  --export-options-plist=ios/ExportOptions.plist
```
```

---

### 7. Fastlane Configuration

Fastlane configuration bersifat framework-agnostic - sama untuk GetX maupun Riverpod.

#### 7.1 Android Fastlane

```ruby
# android/fastlane/Fastfile
default_platform(:android)

platform :android do
  desc "Run unit tests"
  lane :test do
    Dir.chdir("..") do
      sh("cd .. && flutter test --coverage")
    end
  end

  desc "Build release APK"
  lane :build_apk do
    Dir.chdir("..") do
      sh("cd .. && flutter build apk --release " \
         "--obfuscate --split-debug-info=build/debug-info " \
         "--dart-define=ENV=production")
    end
  end

  desc "Build release AAB"
  lane :build_aab do
    Dir.chdir("..") do
      sh("cd .. && flutter build appbundle --release " \
         "--obfuscate --split-debug-info=build/debug-info " \
         "--dart-define=ENV=production")
    end
  end

  desc "Deploy ke Internal Testing (Play Store)"
  lane :deploy_internal do
    build_aab
    upload_to_play_store(
      track: 'internal',
      aab: '../build/app/outputs/bundle/release/app-release.aab',
      json_key: ENV['PLAY_STORE_JSON_KEY_PATH'],
      skip_upload_metadata: true,
      skip_upload_changelogs: false,
      skip_upload_images: true,
      skip_upload_screenshots: true,
    )
  end

  desc "Promote dari Internal ke Production"
  lane :promote_to_production do
    upload_to_play_store(
      track: 'internal',
      track_promote_to: 'production',
      json_key: ENV['PLAY_STORE_JSON_KEY_PATH'],
      skip_upload_aab: true,
      skip_upload_metadata: true,
      skip_upload_changelogs: false,
    )
  end

  desc "Deploy ke Play Store Production"
  lane :deploy do
    build_aab
    upload_to_play_store(
      track: 'production',
      aab: '../build/app/outputs/bundle/release/app-release.aab',
      json_key: ENV['PLAY_STORE_JSON_KEY_PATH'],
      rollout: '0.1', # 10% staged rollout
    )
  end
end
```

#### 7.2 iOS Fastlane

```ruby
# ios/fastlane/Fastfile
default_platform(:ios)

platform :ios do
  desc "Sync certificates menggunakan Match"
  lane :sync_certs do
    match(
      type: "appstore",
      readonly: true,
      app_identifier: "com.example.app",
    )
  end

  desc "Build release IPA"
  lane :build do
    sync_certs

    Dir.chdir("..") do
      sh("cd .. && flutter build ipa --release " \
         "--obfuscate --split-debug-info=build/debug-info " \
         "--dart-define=ENV=production " \
         "--export-options-plist=ios/ExportOptions.plist")
    end
  end

  desc "Deploy ke TestFlight"
  lane :deploy_testflight do
    build
    upload_to_testflight(
      ipa: '../build/ios/ipa/app.ipa',
      skip_waiting_for_build_processing: true,
    )
  end

  desc "Deploy ke App Store"
  lane :deploy do
    build
    upload_to_app_store(
      ipa: '../build/ios/ipa/app.ipa',
      submit_for_review: false,
      automatic_release: false,
      force: true,
      precheck_include_in_app_purchases: false,
    )
  end

  desc "Increment build number"
  lane :bump_build do
    increment_build_number(
      build_number: ENV['BUILD_NUMBER'] || latest_testflight_build_number + 1,
    )
  end
end
```

#### 7.3 Fastlane Appfile

```ruby
# android/fastlane/Appfile
json_key_file(ENV['PLAY_STORE_JSON_KEY_PATH'])
package_name("com.example.app")
```

```ruby
# ios/fastlane/Appfile
app_identifier("com.example.app")
apple_id(ENV['APPLE_ID'])
team_id(ENV['TEAM_ID'])
itc_team_id(ENV['ITC_TEAM_ID'])
```

#### 7.4 Fastlane Matchfile

```ruby
# ios/fastlane/Matchfile
git_url(ENV['MATCH_GIT_URL'])
storage_mode("git")
type("appstore")
app_identifier("com.example.app")
username(ENV['APPLE_ID'])
```

---

## Workflow Steps

### Step 1: Setup Testing Environment

1. Tambahkan testing dependencies ke `pubspec.yaml`
2. Buat folder structure untuk test files
3. Buat test helpers dan mock classes
4. Setup test data factories

```bash
# Buat folder structure
mkdir -p test/{unit/{controllers,services,repositories,bindings},widget/{views,components,navigation},helpers}
mkdir -p integration_test
```

### Step 2: Write Unit Tests

1. Buat mock classes untuk semua repositories dan services
2. Tulis test untuk setiap `GetxController`
3. Tulis test untuk service layer
4. Tulis test untuk GetX bindings
5. Target coverage minimal 80%

```bash
# Jalankan unit tests
flutter test

# Jalankan dengan coverage
flutter test --coverage

# Generate HTML coverage report
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

### Step 3: Write Widget Tests

1. Buat widget test helpers dengan `GetMaterialApp` wrapper
2. Tulis test untuk setiap view/page
3. Tulis test untuk reusable components
4. Test navigation flows

```bash
# Jalankan widget tests saja
flutter test test/widget/

# Jalankan specific test file
flutter test test/widget/views/product_list_view_test.dart
```

### Step 4: Write Integration Tests

1. Setup integration test environment
2. Tulis end-to-end test untuk critical flows
3. Test dengan mock API client jika diperlukan

```bash
# Jalankan integration tests di device/emulator
flutter test integration_test/

# Jalankan di specific device
flutter test integration_test/ -d <device_id>
```

### Step 5: Setup CI/CD

1. Buat GitHub Actions workflow files
2. Configure secrets di GitHub repository settings
3. Setup Fastlane untuk automated deployment
4. Test pipeline dengan push ke branch

**GitHub Secrets yang diperlukan:**
- `CODECOV_TOKEN` - Token untuk upload coverage
- `KEYSTORE_BASE64` - Android release keystore (base64)
- `KEYSTORE_PASSWORD` - Password keystore
- `KEY_ALIAS` - Key alias
- `KEY_PASSWORD` - Key password
- `PLAY_STORE_JSON_KEY` - Google Play service account JSON
- `APP_STORE_CONNECT_API_KEY` - App Store Connect API key
- `MATCH_PASSWORD` - Password untuk Fastlane Match
- `API_URL` - Production API URL
- `SENTRY_DSN` - Sentry DSN untuk error monitoring

### Step 6: Performance Optimization

1. Profile app dengan Flutter DevTools
2. Optimize gambar dan assets
3. Implement lazy loading
4. Reduce rebuild frequency (GetBuilder vs Obx)
5. Analyze dan reduce APK/IPA size

### Step 7: Production Preparation

1. Complete production checklist
2. Setup error monitoring (Sentry / Crashlytics)
3. Configure app signing
4. Prepare store listing assets
5. Final testing on real devices

---

## Success Criteria

| Kriteria | Target | Cara Ukur |
|---|---|---|
| Unit test coverage | >= 80% | `flutter test --coverage` |
| Widget test coverage | >= 70% | Coverage report per folder |
| Semua tests pass | 100% green | `flutter test` exit code 0 |
| No analyzer issues | 0 warnings | `flutter analyze` |
| CI pipeline pass | Green on every PR | GitHub Actions status |
| Build berhasil | APK + IPA | Artifacts di CI |
| APK size | < 25MB | `flutter build apk --analyze-size` |
| Startup time | < 3 detik | Flutter DevTools |
| Frame rate | >= 55 fps | Performance overlay |
| Crash rate | < 1% | Sentry/Crashlytics |

---

## Tools & Commands

### Testing Commands

```bash
# Run semua tests
flutter test

# Run dengan coverage
flutter test --coverage

# Run specific test file
flutter test test/unit/controllers/product_controller_test.dart

# Run tests matching pattern
flutter test --name "should fetch products"

# Run dengan verbose output
flutter test --reporter expanded

# Run integration tests
flutter test integration_test/

# Generate coverage report
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
```

### Build Commands

```bash
# Debug build
flutter run

# Profile build (untuk performance testing)
flutter run --profile

# Release build
flutter build apk --release
flutter build appbundle --release
flutter build ipa --release

# Dengan obfuscation
flutter build apk --release --obfuscate --split-debug-info=build/debug-info

# Analyze build size
flutter build apk --analyze-size --target-platform android-arm64
```

### Debugging & Profiling

```bash
# Flutter DevTools
flutter pub global activate devtools
dart devtools

# Check for memory leaks
flutter run --profile --trace-startup

# Dump widget tree
flutter run --dump-skp-on-shader-compilation
```

---

## Perbedaan Utama dari Riverpod Version

| Aspek | Riverpod | GetX |
|---|---|---|
| Test setup | `ProviderContainer` + overrides | `Get.put()` + `Get.reset()` |
| Widget test wrapper | `ProviderScope(overrides: [...])` | `GetMaterialApp` + `Get.put()` |
| Mock injection | Provider overrides | `Get.put<T>(mockInstance)` |
| Code generation | `build_runner` diperlukan | Tidak diperlukan |
| CI/CD step | Perlu `flutter pub run build_runner build` | Langsung `flutter test` |
| Controller cleanup | `ref.onDispose()` | `onClose()` + `Get.reset()` |
| Reactive testing | `container.read()` | Direct access via `.value` |

---

## Next Steps

Setelah testing dan production setup selesai:

1. **Monitoring** - Setup dashboard untuk monitoring app health (Sentry, Firebase Crashlytics, custom analytics)
2. **A/B Testing** - Implementasi feature flags untuk A/B testing (Firebase Remote Config)
3. **Continuous Improvement** - Regular performance profiling dan optimization
4. **User Feedback** - Setup feedback mechanism (in-app feedback, store reviews monitoring)
5. **Maintenance** - Regular dependency updates (`flutter pub outdated && flutter pub upgrade`)

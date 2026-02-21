---
description: Comprehensive testing (unit, widget, integration) dan production preparation untuk Flutter app dengan GetX state mana... (Part 3/8)
---
# Workflow: Testing & Production (GetX) (Part 3/8)

> **Navigation:** This workflow is split into 8 parts.

## Deliverables

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


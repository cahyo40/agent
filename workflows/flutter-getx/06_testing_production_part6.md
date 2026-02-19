---
description: Comprehensive testing (unit, widget, integration) dan production preparation untuk Flutter app dengan GetX state mana... (Part 6/8)
---
# Workflow: Testing & Production (GetX) (Part 6/8)

> **Navigation:** This workflow is split into 8 parts.

## Deliverables

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

## Deliverables

### 6. Production Checklist

Checklist lengkap sebelum release ke production. Diadaptasi untuk GetX (tanpa code generation atau Riverpod-specific items).

#### 6.1 Code Quality

```markdown

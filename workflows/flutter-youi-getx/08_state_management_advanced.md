---
description: Pola-pola advanced GetX untuk production apps: Workers, StateMixin, pagination, optimistic updates, dan cross-control...
---
# 08 - Advanced State Management (GetX Patterns)

**Goal:** Pola-pola advanced GetX untuk production apps: Workers, StateMixin, pagination, optimistic updates, dan cross-controller communication.

**Output:** `sdlc/flutter-youi/08-state-management-advanced/`

**Time Estimate:** 3-4 jam

---

## Deliverables

### 1. Workers (Reactive Side Effects)

**File:** `lib/features/product/presentation/controllers/product_list_controller.dart`

```dart
import 'package:get/get.dart';
import '../../domain/entities/product.dart';
import '../../domain/usecases/get_products_usecase.dart';

class ProductListController extends GetxController with StateMixin<List<Product>> {
  ProductListController({required this.getProductsUsecase});

  final GetProductsUsecase getProductsUsecase;

  // Reactive state
  final RxList<Product> products = <Product>[].obs;
  final RxBool isLoadingMore = false.obs;
  final RxBool hasMore = true.obs;
  final RxString searchQuery = ''.obs;
  final RxInt currentPage = 1.obs;

  static const _pageSize = 20;

  @override
  void onInit() {
    super.onInit();

    // Worker: debounce search 400ms
    debounce(
      searchQuery,
      (_) => _resetAndFetch(),
      time: const Duration(milliseconds: 400),
    );

    _fetchPage(1);
  }

  Future<void> _fetchPage(int page) async {
    if (page == 1) change(null, status: RxStatus.loading());

    final result = await getProductsUsecase(
      GetProductsParams(
        page: page,
        limit: _pageSize,
        search: searchQuery.value,
      ),
    );

    result.fold(
      (failure) {
        if (page == 1) {
          change(null, status: RxStatus.error(failure.message));
        }
      },
      (newProducts) {
        if (page == 1) {
          products.assignAll(newProducts);
        } else {
          products.addAll(newProducts);
        }
        hasMore.value = newProducts.length >= _pageSize;
        currentPage.value = page;
        change(products, status: RxStatus.success());
      },
    );
  }

  Future<void> loadMore() async {
    if (!hasMore.value || isLoadingMore.value) return;
    isLoadingMore.value = true;
    await _fetchPage(currentPage.value + 1);
    isLoadingMore.value = false;
  }

  void _resetAndFetch() {
    hasMore.value = true;
    currentPage.value = 1;
    _fetchPage(1);
  }

  Future<void> refresh() => _fetchPage(1);
}
```

---

### 2. StateMixin Usage in Screen

```dart
class ProductListScreen extends GetView<ProductListController> {
  const ProductListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Products'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: TextField(
              onChanged: (v) => controller.searchQuery.value = v,
              decoration: const InputDecoration(
                hintText: 'Search...',
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
        ),
      ),
      body: controller.obx(
        (products) => NotificationListener<ScrollNotification>(
          onNotification: (n) {
            if (n.metrics.pixels >= n.metrics.maxScrollExtent - 200) {
              controller.loadMore();
            }
            return false;
          },
          child: ListView.builder(
            itemCount: products!.length + 1,
            itemBuilder: (_, i) {
              if (i == products.length) {
                return Obx(() => controller.isLoadingMore.value
                    ? const Center(child: CircularProgressIndicator())
                    : const SizedBox.shrink());
              }
              return ProductCard(product: products[i]);
            },
          ),
        ),
        onLoading: const ProductListShimmer(),
        onError: (err) => AppErrorWidget(
          message: err ?? 'Unknown error',
          onRetry: controller.refresh,
        ),
        onEmpty: const EmptyStateWidget(
          icon: Icons.inventory_2_outlined,
          title: 'No Products',
          description: 'No products found.',
        ),
      ),
    );
  }
}
```

---

### 3. Optimistic Update

**File:** `lib/features/product/presentation/controllers/product_actions_controller.dart`

```dart
class ProductActionsController extends GetxController {
  ProductActionsController({
    required this.deleteProductUsecase,
    required this.listController,
  });

  final DeleteProductUsecase deleteProductUsecase;
  final ProductListController listController;

  Future<bool> deleteProduct(String productId) async {
    // 1. Optimistic: remove from list immediately
    final previous = List<Product>.from(listController.products);
    listController.products.removeWhere((p) => p.id == productId);

    // 2. Execute actual delete
    final result = await deleteProductUsecase(productId);

    return result.fold(
      (failure) {
        // 3. Rollback on failure
        listController.products.assignAll(previous);
        Get.snackbar('Error', failure.message, backgroundColor: Colors.red);
        return false;
      },
      (_) {
        Get.snackbar('Success', 'Product deleted');
        return true;
      },
    );
  }
}
```

---

### 4. Cross-Controller Communication

**File:** `lib/features/cart/presentation/controllers/cart_controller.dart`

```dart
class CartController extends GetxController {
  final RxList<CartItem> items = <CartItem>[].obs;

  int get itemCount => items.fold(0, (sum, i) => sum + i.quantity);
  double get totalAmount => items.fold(0, (sum, i) => sum + i.price * i.quantity);

  @override
  void onInit() {
    super.onInit();
    // Listen to auth changes — clear cart on logout
    ever(
      Get.find<AuthController>().currentUser,
      (user) {
        if (user == null) clear();
      },
    );
  }

  void addItem(CartItem item) {
    final idx = items.indexWhere((i) => i.productId == item.productId);
    if (idx != -1) {
      items[idx] = items[idx].copyWith(quantity: items[idx].quantity + 1);
    } else {
      items.add(item);
    }
  }

  void removeItem(String productId) =>
      items.removeWhere((i) => i.productId == productId);

  void clear() => items.clear();
}
```

---

### 5. GetX Workers Reference

```dart
// ever — runs every time value changes
ever(searchQuery, (_) => fetchProducts());

// once — runs only the first time value changes
once(isLoggedIn, (_) => fetchUserProfile());

// debounce — runs after value stops changing for duration
debounce(searchQuery, (_) => fetchProducts(),
    time: const Duration(milliseconds: 400));

// interval — runs at most once per duration while value changes
interval(scrollPosition, (_) => saveScrollPosition(),
    time: const Duration(seconds: 1));
```

---

### 6. GetX Reactive Patterns

```dart
// ✅ Reactive variable
final count = 0.obs;
final user = Rxn<User>(); // nullable reactive
final items = <Product>[].obs; // reactive list
final map = <String, dynamic>{}.obs; // reactive map

// ✅ Computed value (recalculates when dependencies change)
final isCartEmpty = false.obs;
// Update in cart controller:
ever(items, (_) => isCartEmpty.value = items.isEmpty);

// ✅ Obx — rebuilds when any .obs inside changes
Obx(() => Text('Count: ${controller.count}'));

// ✅ GetX — same as Obx but provides controller
GetX<ProductController>(
  builder: (ctrl) => Text(ctrl.count.toString()),
);

// ✅ Obx with multiple observables
Obx(() {
  final loading = controller.isLoading.value;
  final count = controller.items.length;
  return Text(loading ? 'Loading...' : '$count items');
});
```

---

## Success Criteria
- `debounce` Worker tidak spam API saat search
- `StateMixin` menampilkan loading/error/empty/data states
- Optimistic delete rollback saat error
- Cart clear otomatis saat logout via `ever` Worker
- Pagination load more berfungsi

## Next Steps
- `09_offline_storage.md` - Offline storage

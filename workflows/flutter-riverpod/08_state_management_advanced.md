# 08 - Advanced State Management (Riverpod Patterns)

**Goal:** Pola-pola advanced Riverpod untuk production apps: family providers, pagination, optimistic updates, dan cross-provider communication.

**Output:** `sdlc/flutter-riverpod/08-state-management-advanced/`

**Time Estimate:** 3-4 jam

---

## Deliverables

### 1. Family Provider (Parameterized)

**File:** `lib/features/product/presentation/controllers/product_detail_controller.dart`

```dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/entities/product.dart';
import '../../domain/usecases/get_product_usecase.dart';

part 'product_detail_controller.g.dart';

/// Parameterized provider — satu instance per productId.
@riverpod
class ProductDetailController extends _$ProductDetailController {
  @override
  Future<Product> build(String productId) async {
    // Auto-dispose saat widget unmount
    ref.onDispose(() => debugPrint('ProductDetail $productId disposed'));

    final usecase = ref.watch(getProductUsecaseProvider);
    final result = await usecase(productId);
    return result.fold(
      (failure) => throw failure,
      (product) => product,
    );
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }
}
```

**Usage:**

```dart
// Di screen — auto-dispose saat screen di-pop
final productAsync = ref.watch(productDetailControllerProvider(productId));
```

---

### 2. Pagination Provider

**File:** `lib/features/product/presentation/controllers/product_list_controller.dart`

```dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/entities/product.dart';
import '../../domain/usecases/get_products_usecase.dart';

part 'product_list_controller.g.dart';

class ProductListState {
  const ProductListState({
    this.products = const [],
    this.page = 1,
    this.hasMore = true,
    this.isLoadingMore = false,
    this.search = '',
  });

  final List<Product> products;
  final int page;
  final bool hasMore;
  final bool isLoadingMore;
  final String search;

  ProductListState copyWith({
    List<Product>? products,
    int? page,
    bool? hasMore,
    bool? isLoadingMore,
    String? search,
  }) =>
      ProductListState(
        products: products ?? this.products,
        page: page ?? this.page,
        hasMore: hasMore ?? this.hasMore,
        isLoadingMore: isLoadingMore ?? this.isLoadingMore,
        search: search ?? this.search,
      );
}

@riverpod
class ProductListController extends _$ProductListController {
  static const _pageSize = 20;

  @override
  Future<ProductListState> build() async {
    final products = await _fetchPage(1, '');
    return ProductListState(
      products: products,
      hasMore: products.length >= _pageSize,
    );
  }

  Future<List<Product>> _fetchPage(int page, String search) async {
    final usecase = ref.read(getProductsUsecaseProvider);
    final result = await usecase(
      GetProductsParams(page: page, limit: _pageSize, search: search),
    );
    return result.fold((f) => throw f, (list) => list);
  }

  Future<void> loadMore() async {
    final current = state.valueOrNull;
    if (current == null || !current.hasMore || current.isLoadingMore) return;

    state = AsyncData(current.copyWith(isLoadingMore: true));

    try {
      final nextPage = current.page + 1;
      final newItems = await _fetchPage(nextPage, current.search);
      state = AsyncData(
        current.copyWith(
          products: [...current.products, ...newItems],
          page: nextPage,
          hasMore: newItems.length >= _pageSize,
          isLoadingMore: false,
        ),
      );
    } catch (e, st) {
      state = AsyncData(current.copyWith(isLoadingMore: false));
      debugPrint('loadMore error: $e\n$st');
    }
  }

  Future<void> search(String query) async {
    state = const AsyncLoading();
    final products = await _fetchPage(1, query);
    state = AsyncData(
      ProductListState(
        products: products,
        page: 1,
        hasMore: products.length >= _pageSize,
        search: query,
      ),
    );
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }
}
```

---

### 3. Optimistic Update

**File:** `lib/features/product/presentation/controllers/product_actions_controller.dart`

```dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/usecases/delete_product_usecase.dart';

part 'product_actions_controller.g.dart';

@riverpod
class ProductActionsController extends _$ProductActionsController {
  @override
  void build() {}

  Future<bool> deleteProduct(String productId) async {
    final listController = ref.read(
      productListControllerProvider.notifier,
    );
    final currentState = ref.read(productListControllerProvider).valueOrNull;
    if (currentState == null) return false;

    // 1. Optimistic: remove from list immediately
    final optimisticList = currentState.products
        .where((p) => p.id != productId)
        .toList();
    ref
        .read(productListControllerProvider.notifier)
        .state = AsyncData(currentState.copyWith(products: optimisticList));

    // 2. Execute actual delete
    final usecase = ref.read(deleteProductUsecaseProvider);
    final result = await usecase(productId);

    return result.fold(
      (failure) {
        // 3. Rollback on failure
        ref
            .read(productListControllerProvider.notifier)
            .state = AsyncData(currentState);
        return false;
      },
      (_) => true,
    );
  }
}
```

---

### 4. Cross-Provider Communication

**File:** `lib/features/cart/presentation/controllers/cart_controller.dart`

```dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../domain/entities/cart_item.dart';

part 'cart_controller.g.dart';

@Riverpod(keepAlive: true)
class CartController extends _$CartController {
  @override
  List<CartItem> build() {
    // Listen to auth changes — clear cart on logout
    ref.listen(authControllerProvider, (prev, next) {
      if (next.valueOrNull == null) {
        state = [];
      }
    });
    return [];
  }

  void addItem(CartItem item) {
    final existing = state.indexWhere((i) => i.productId == item.productId);
    if (existing != -1) {
      state = [
        for (int i = 0; i < state.length; i++)
          if (i == existing)
            state[i].copyWith(quantity: state[i].quantity + 1)
          else
            state[i],
      ];
    } else {
      state = [...state, item];
    }
  }

  void removeItem(String productId) {
    state = state.where((i) => i.productId != productId).toList();
  }

  void clear() => state = [];

  int get itemCount => state.fold(0, (sum, i) => sum + i.quantity);

  double get totalAmount =>
      state.fold(0, (sum, i) => sum + i.price * i.quantity);
}
```

---

### 5. Debounced Search Provider

**File:** `lib/features/product/presentation/controllers/search_controller.dart`

```dart
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'search_controller.g.dart';

@riverpod
class SearchController extends _$SearchController {
  @override
  String build() => '';

  void updateQuery(String query) {
    state = query;
    // Debounce: cancel previous timer
    ref.invalidate(debouncedSearchProvider);
  }
}

/// Debounced search — waits 400ms before triggering.
@riverpod
Future<String> debouncedSearch(Ref ref) async {
  final query = ref.watch(searchControllerProvider);
  await Future.delayed(const Duration(milliseconds: 400));
  return query;
}
```

**Usage in screen:**

```dart
// Listen to debounced search and trigger API call
ref.listen(debouncedSearchProvider, (_, next) {
  next.whenData((query) {
    ref.read(productListControllerProvider.notifier).search(query);
  });
});
```

---

### 6. keepAlive + Invalidate Pattern

```dart
// Provider yang tidak auto-dispose (global state)
@Riverpod(keepAlive: true)
class UserProfileController extends _$UserProfileController {
  @override
  Future<UserProfile> build() async {
    final userId = ref.watch(authControllerProvider).valueOrNull?.id;
    if (userId == null) throw const UnauthenticatedException();
    return ref.read(userRepositoryProvider).getProfile(userId);
  }

  // Invalidate setelah update profile
  Future<void> updateProfile(UpdateProfileParams params) async {
    await ref.read(userRepositoryProvider).updateProfile(params);
    ref.invalidateSelf(); // Re-fetch
    await future;
  }
}
```

---

## Success Criteria
- Family provider buat satu instance per ID
- Pagination load more berfungsi dengan infinite scroll
- Optimistic delete rollback saat error
- Cart clear otomatis saat logout
- Debounced search tidak spam API

## Next Steps
- `09_offline_storage.md` - Offline storage

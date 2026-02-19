---
description: Pola-pola advanced BLoC untuk production apps: pagination, optimistic updates, cross-Bloc communication, dan EventTra...
---
# 09 - Advanced BLoC Patterns (Pagination, Optimistic, Cross-Bloc)

**Goal:** Pola-pola advanced BLoC untuk production apps: pagination, optimistic updates, cross-Bloc communication, dan EventTransformer.

**Output:** `sdlc/flutter-bloc/09-advanced-patterns/`

**Time Estimate:** 3-4 jam

> **Note:** Workflow ini melengkapi `08_bloc_patterns.md` dengan fokus pada pola production yang lebih spesifik.

---

## Deliverables

### 1. Pagination BLoC

**File:** `lib/features/product/presentation/bloc/product_list_bloc.dart`

```dart
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import '../../domain/entities/product.dart';
import '../../domain/usecases/get_products_usecase.dart';

part 'product_list_event.dart';
part 'product_list_state.dart';

@injectable
class ProductListBloc extends Bloc<ProductListEvent, ProductListState> {
  ProductListBloc({required this.getProducts})
      : super(const ProductListState()) {
    on<FetchProducts>(_onFetch);
    on<LoadMoreProducts>(_onLoadMore);
    on<SearchProducts>(
      _onSearch,
      transformer: debounce(const Duration(milliseconds: 400)),
    );
    on<RefreshProducts>(_onRefresh);
  }

  final GetProductsUsecase getProducts;
  static const _pageSize = 20;

  Future<void> _onFetch(
    FetchProducts event,
    Emitter<ProductListState> emit,
  ) async {
    emit(state.copyWith(status: ProductListStatus.loading));
    await _fetchPage(1, state.search, emit);
  }

  Future<void> _onLoadMore(
    LoadMoreProducts event,
    Emitter<ProductListState> emit,
  ) async {
    if (!state.hasMore || state.isLoadingMore) return;
    emit(state.copyWith(isLoadingMore: true));
    await _fetchPage(state.page + 1, state.search, emit);
  }

  Future<void> _onSearch(
    SearchProducts event,
    Emitter<ProductListState> emit,
  ) async {
    emit(state.copyWith(
      status: ProductListStatus.loading,
      search: event.query,
      page: 1,
      products: [],
    ));
    await _fetchPage(1, event.query, emit);
  }

  Future<void> _onRefresh(
    RefreshProducts event,
    Emitter<ProductListState> emit,
  ) async {
    emit(state.copyWith(
      status: ProductListStatus.loading,
      page: 1,
      products: [],
    ));
    await _fetchPage(1, state.search, emit);
  }

  Future<void> _fetchPage(
    int page,
    String search,
    Emitter<ProductListState> emit,
  ) async {
    final result = await getProducts(
      GetProductsParams(page: page, limit: _pageSize, search: search),
    );

    result.fold(
      (failure) => emit(state.copyWith(
        status: ProductListStatus.failure,
        errorMessage: failure.message,
        isLoadingMore: false,
      )),
      (newProducts) => emit(state.copyWith(
        status: ProductListStatus.success,
        products: page == 1
            ? newProducts
            : [...state.products, ...newProducts],
        page: page,
        hasMore: newProducts.length >= _pageSize,
        isLoadingMore: false,
      )),
    );
  }
}
```

**File:** `lib/features/product/presentation/bloc/product_list_event.dart`

```dart
part of 'product_list_bloc.dart';

sealed class ProductListEvent extends Equatable {
  const ProductListEvent();
  @override
  List<Object?> get props => [];
}

final class FetchProducts extends ProductListEvent {
  const FetchProducts();
}

final class LoadMoreProducts extends ProductListEvent {
  const LoadMoreProducts();
}

final class SearchProducts extends ProductListEvent {
  const SearchProducts(this.query);
  final String query;
  @override
  List<Object?> get props => [query];
}

final class RefreshProducts extends ProductListEvent {
  const RefreshProducts();
}
```

**File:** `lib/features/product/presentation/bloc/product_list_state.dart`

```dart
part of 'product_list_bloc.dart';

enum ProductListStatus { initial, loading, success, failure }

final class ProductListState extends Equatable {
  const ProductListState({
    this.status = ProductListStatus.initial,
    this.products = const [],
    this.page = 1,
    this.hasMore = true,
    this.isLoadingMore = false,
    this.search = '',
    this.errorMessage,
  });

  final ProductListStatus status;
  final List<Product> products;
  final int page;
  final bool hasMore;
  final bool isLoadingMore;
  final String search;
  final String? errorMessage;

  ProductListState copyWith({
    ProductListStatus? status,
    List<Product>? products,
    int? page,
    bool? hasMore,
    bool? isLoadingMore,
    String? search,
    String? errorMessage,
  }) =>
      ProductListState(
        status: status ?? this.status,
        products: products ?? this.products,
        page: page ?? this.page,
        hasMore: hasMore ?? this.hasMore,
        isLoadingMore: isLoadingMore ?? this.isLoadingMore,
        search: search ?? this.search,
        errorMessage: errorMessage ?? this.errorMessage,
      );

  @override
  List<Object?> get props => [
        status, products, page, hasMore, isLoadingMore, search, errorMessage,
      ];
}
```

---

### 2. Optimistic Update Cubit

**File:** `lib/features/product/presentation/cubit/product_actions_cubit.dart`

```dart
import 'package:bloc/bloc.dart';
import 'package:injectable/injectable.dart';
import '../../domain/usecases/delete_product_usecase.dart';

part 'product_actions_state.dart';

@injectable
class ProductActionsCubit extends Cubit<ProductActionsState> {
  ProductActionsCubit({
    required this.deleteProduct,
    required this.listBloc,
  }) : super(const ProductActionsState());

  final DeleteProductUsecase deleteProduct;
  final ProductListBloc listBloc;

  Future<bool> delete(String productId) async {
    // 1. Optimistic: remove from list immediately
    final previous = List<Product>.from(listBloc.state.products);
    listBloc.emit(listBloc.state.copyWith(
      products: previous.where((p) => p.id != productId).toList(),
    ));

    // 2. Execute actual delete
    final result = await deleteProduct(productId);

    return result.fold(
      (failure) {
        // 3. Rollback on failure
        listBloc.emit(listBloc.state.copyWith(products: previous));
        emit(state.copyWith(errorMessage: failure.message));
        return false;
      },
      (_) => true,
    );
  }
}
```

---

### 3. Cross-Bloc Communication via Stream

**File:** `lib/features/cart/presentation/bloc/cart_bloc.dart`

```dart
import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';

part 'cart_event.dart';
part 'cart_state.dart';

@injectable
class CartBloc extends Bloc<CartEvent, CartState> {
  CartBloc({required AuthBloc authBloc}) : super(const CartState()) {
    on<AddToCart>(_onAdd);
    on<RemoveFromCart>(_onRemove);
    on<ClearCart>(_onClear);

    // Listen to auth state — clear cart on logout
    _authSubscription = authBloc.stream.listen((authState) {
      if (authState is AuthUnauthenticated) {
        add(const ClearCart());
      }
    });
  }

  late final StreamSubscription _authSubscription;

  void _onAdd(AddToCart event, Emitter<CartState> emit) {
    final items = List<CartItem>.from(state.items);
    final idx = items.indexWhere((i) => i.productId == event.item.productId);
    if (idx != -1) {
      items[idx] = items[idx].copyWith(quantity: items[idx].quantity + 1);
    } else {
      items.add(event.item);
    }
    emit(state.copyWith(items: items));
  }

  void _onRemove(RemoveFromCart event, Emitter<CartState> emit) {
    emit(state.copyWith(
      items: state.items.where((i) => i.productId != event.productId).toList(),
    ));
  }

  void _onClear(ClearCart event, Emitter<CartState> emit) {
    emit(const CartState());
  }

  @override
  Future<void> close() {
    _authSubscription.cancel();
    return super.close();
  }
}
```

---

### 4. EventTransformer (Debounce + Throttle)

**File:** `lib/core/bloc/event_transformers.dart`

```dart
import 'package:bloc/bloc.dart';
import 'package:rxdart/rxdart.dart';

/// Debounce: wait for silence before processing.
EventTransformer<T> debounce<T>(Duration duration) =>
    (events, mapper) => events.debounceTime(duration).switchMap(mapper);

/// Throttle: process at most once per duration.
EventTransformer<T> throttle<T>(Duration duration) =>
    (events, mapper) => events.throttleTime(duration).switchMap(mapper);

/// Sequential: process one at a time (default BLoC behavior).
EventTransformer<T> sequential<T>() =>
    (events, mapper) => events.asyncExpand(mapper);

/// Concurrent: process all events simultaneously.
EventTransformer<T> concurrent<T>() =>
    (events, mapper) => events.flatMap(mapper);
```

**Usage:**

```dart
// In Bloc constructor:
on<SearchProducts>(
  _onSearch,
  transformer: debounce(const Duration(milliseconds: 400)),
);

on<LoadMoreProducts>(
  _onLoadMore,
  transformer: throttle(const Duration(milliseconds: 500)),
);
```

---

## Success Criteria
- Pagination load more berfungsi dengan `LoadMoreProducts` event
- Debounce search tidak spam API
- Optimistic delete rollback saat error
- Cart clear otomatis saat logout via stream subscription
- `EventTransformer` debounce/throttle berfungsi

## Next Steps
- `10_offline_storage.md` - Offline storage

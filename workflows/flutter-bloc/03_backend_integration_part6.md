---
description: Implementasi repository pattern dengan REST API menggunakan Dio dan flutter_bloc. (Part 6/8)
---
# Workflow: Backend Integration (REST API) - Flutter BLoC (Part 6/8)

> **Navigation:** This workflow is split into 8 parts.

## Deliverables

### 6. Pagination BLoC

**Description:** Implementasi pagination menggunakan BLoC pattern. Ini perbedaan paling signifikan dengan Riverpod — di Riverpod pakai `AsyncNotifier`, di BLoC pakai sealed events + Equatable state.

**Recommended Skills:** `senior-flutter-developer`

**Instructions:**
1. Definisikan sealed event classes: `LoadProducts`, `LoadNextPage`, `RefreshProducts`, `SearchProducts`
2. State menggunakan single class `PaginatedProductState` dengan field lengkap (bukan sealed state, tapi single state dengan status flags)
3. BLoc handle setiap event secara terpisah
4. Debounce untuk search events (300ms)
5. Prevent duplicate load saat masih loading

**Output Format:**
```dart
// features/product/presentation/bloc/paginated_product_event.dart
part of 'paginated_product_bloc.dart';

sealed class PaginatedProductEvent extends Equatable {
  const PaginatedProductEvent();

  @override
  List<Object?> get props => [];
}

/// Load halaman pertama
class LoadProducts extends PaginatedProductEvent {
  const LoadProducts();
}

/// Load halaman berikutnya (infinite scroll)
class LoadNextPage extends PaginatedProductEvent {
  const LoadNextPage();
}

/// Pull-to-refresh — reset ke halaman 1
class RefreshProducts extends PaginatedProductEvent {
  const RefreshProducts();
}

/// Search dengan query — reset pagination, debounce 300ms
class SearchProducts extends PaginatedProductEvent {
  final String query;

  const SearchProducts(this.query);

  @override
  List<Object?> get props => [query];
}

/// Clear search — kembali ke list tanpa filter
class ClearSearch extends PaginatedProductEvent {
  const ClearSearch();
}

// features/product/presentation/bloc/paginated_product_state.dart
part of 'paginated_product_bloc.dart';

enum ProductStatus { initial, loading, loaded, loadingMore, error }

class PaginatedProductState extends Equatable {
  final List<Product> products;
  final ProductStatus status;
  final bool hasMore;
  final int currentPage;
  final String? errorMessage;
  final String searchQuery;

  const PaginatedProductState({
    this.products = const [],
    this.status = ProductStatus.initial,
    this.hasMore = true,
    this.currentPage = 0,
    this.errorMessage,
    this.searchQuery = '',
  });

  /// Apakah sedang loading halaman pertama (bukan load more)
  bool get isInitialLoading =>
      status == ProductStatus.loading && products.isEmpty;

  /// Apakah sedang load more (infinite scroll)
  bool get isLoadingMore => status == ProductStatus.loadingMore;

  /// Apakah ada error
  bool get hasError => status == ProductStatus.error;

  /// Apakah ada data
  bool get hasData => products.isNotEmpty;

  /// Apakah sedang search
  bool get isSearching => searchQuery.isNotEmpty;

  PaginatedProductState copyWith({
    List<Product>? products,
    ProductStatus? status,
    bool? hasMore,
    int? currentPage,
    String? errorMessage,
    String? searchQuery,
  }) {
    return PaginatedProductState(
      products: products ?? this.products,
      status: status ?? this.status,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
      errorMessage: errorMessage,  // Intentional: null clears error
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  @override
  List<Object?> get props => [
        products,
        status,
        hasMore,
        currentPage,
        errorMessage,
        searchQuery,
      ];
}

// features/product/presentation/bloc/paginated_product_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:stream_transform/stream_transform.dart';

part 'paginated_product_event.dart';
part 'paginated_product_state.dart';

/// Debounce transformer untuk search events
EventTransformer<E> debounce<E>(Duration duration) {
  return (events, mapper) => events.debounce(duration).switchMap(mapper);
}

class PaginatedProductBloc
    extends Bloc<PaginatedProductEvent, PaginatedProductState> {
  final GetProducts _getProducts; // UseCase
  static const int _pageSize = 20;

  PaginatedProductBloc({
    required GetProducts getProducts,
  })  : _getProducts = getProducts,
        super(const PaginatedProductState()) {
    on<LoadProducts>(_onLoadProducts);
    on<LoadNextPage>(_onLoadNextPage);
    on<RefreshProducts>(_onRefreshProducts);
    on<SearchProducts>(
      _onSearchProducts,
      transformer: debounce(const Duration(milliseconds: 300)),
    );
    on<ClearSearch>(_onClearSearch);
  }

  Future<void> _onLoadProducts(
    LoadProducts event,
    Emitter<PaginatedProductState> emit,
  ) async {
    emit(state.copyWith(status: ProductStatus.loading));

    final result = await _getProducts(
      GetProductsParams(page: 1, limit: _pageSize),
    );

    result.fold(
      (failure) => emit(state.copyWith(
        status: ProductStatus.error,
        errorMessage: failure.message,
      )),
      (products) => emit(state.copyWith(
        status: ProductStatus.loaded,
        products: products,
        currentPage: 1,
        hasMore: products.length >= _pageSize,
        errorMessage: null,
      )),
    );
  }

  Future<void> _onLoadNextPage(
    LoadNextPage event,
    Emitter<PaginatedProductState> emit,
  ) async {
    // Guard: jangan load kalau sudah loading atau tidak ada lagi
    if (state.isLoadingMore || !state.hasMore) return;

    emit(state.copyWith(status: ProductStatus.loadingMore));

    final nextPage = state.currentPage + 1;
    final result = await _getProducts(
      GetProductsParams(
        page: nextPage,
        limit: _pageSize,
        search: state.searchQuery.isEmpty ? null : state.searchQuery,
      ),
    );

    result.fold(
      (failure) => emit(state.copyWith(
        status: ProductStatus.loaded, // Kembalikan ke loaded, bukan error
        errorMessage: failure.message,
      )),
      (newProducts) => emit(state.copyWith(
        status: ProductStatus.loaded,
        products: [...state.products, ...newProducts],
        currentPage: nextPage,
        hasMore: newProducts.length >= _pageSize,
        errorMessage: null,
      )),
    );
  }

  Future<void> _onRefreshProducts(
    RefreshProducts event,
    Emitter<PaginatedProductState> emit,
  ) async {
    // Refresh: reset ke halaman 1, tapi keep existing data sampai selesai
    final result = await _getProducts(
      GetProductsParams(
        page: 1,
        limit: _pageSize,
        search: state.searchQuery.isEmpty ? null : state.searchQuery,
      ),
    );

    result.fold(
      (failure) => emit(state.copyWith(
        errorMessage: failure.message,
      )),
      (products) => emit(state.copyWith(
        status: ProductStatus.loaded,
        products: products,
        currentPage: 1,
        hasMore: products.length >= _pageSize,
        errorMessage: null,
      )),
    );
  }

  Future<void> _onSearchProducts(
    SearchProducts event,
    Emitter<PaginatedProductState> emit,
  ) async {
    final query = event.query.trim();

    emit(state.copyWith(
      status: ProductStatus.loading,
      searchQuery: query,
      products: [], // Clear existing results saat search baru
    ));

    final result = await _getProducts(
      GetProductsParams(
        page: 1,
        limit: _pageSize,
        search: query.isEmpty ? null : query,
      ),
    );

    result.fold(
      (failure) => emit(state.copyWith(
        status: ProductStatus.error,
        errorMessage: failure.message,
      )),
      (products) => emit(state.copyWith(
        status: ProductStatus.loaded,
        products: products,
        currentPage: 1,
        hasMore: products.length >= _pageSize,
        errorMessage: null,
      )),
    );
  }

  Future<void> _onClearSearch(
    ClearSearch event,
    Emitter<PaginatedProductState> emit,
  ) async {
    emit(state.copyWith(searchQuery: ''));
    add(const LoadProducts());
  }
}

// features/product/domain/usecases/get_products.dart
class GetProductsParams extends Equatable {
  final int page;
  final int limit;
  final String? search;

  const GetProductsParams({
    required this.page,
    required this.limit,
    this.search,
  });

  @override
  List<Object?> get props => [page, limit, search];
}

@lazySingleton
class GetProducts implements UseCase<List<Product>, GetProductsParams> {
  final ProductRepository _repository;

  GetProducts(this._repository);

  @override
  Future<Either<Failure, List<Product>>> call(GetProductsParams params) {
    return _repository.getProducts(
      page: params.page,
      limit: params.limit,
      search: params.search,
    );
  }
}
```

**Perbandingan Pattern dengan Riverpod:**

| Aspek | Riverpod (`AsyncNotifier`) | BLoC (`Bloc<Event, State>`) |
|-------|----------------------------|-----------------------------|
| Load initial | `build()` method | `on<LoadProducts>` handler |
| Load more | `loadMore()` method | `on<LoadNextPage>` handler |
| Refresh | `refresh()` method | `on<RefreshProducts>` handler |
| Search | Method call dengan debounce | Event dengan `transformer: debounce()` |
| State | `AsyncValue<List<Product>>` + fields | `PaginatedProductState` class |
| Loading check | `state.isLoading` | `state.status == ProductStatus.loadingMore` |
| Error | `state.hasError` | `state.hasError` (getter) |
| Trigger | `ref.read(notifier).loadMore()` | `bloc.add(LoadNextPage())` |

---


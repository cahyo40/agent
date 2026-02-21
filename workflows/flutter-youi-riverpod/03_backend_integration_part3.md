---
description: Implementasi repository pattern dengan REST API menggunakan Dio. (Part 3/4)
---
# Workflow: Backend Integration (REST API) (Part 3/4)

> **Navigation:** This workflow is split into 4 parts.

## Deliverables

### 4. Pagination dengan Infinite Scroll

**Description:** Implementation pagination untuk list dengan infinite scroll.

**Recommended Skills:** `senior-flutter-developer`

**Instructions:**
1. Setup pagination parameters (page, limit)
2. Implement cache-first dengan pagination
3. Handle pull-to-refresh dengan pagination
4. Show loading indicator saat fetch more data

**Output Format:**
```dart
// features/product/presentation/controllers/paginated_product_controller.dart
@riverpod
class PaginatedProductController extends _$PaginatedProductController {
  static const int _pageSize = 20;
  int _currentPage = 1;
  bool _hasMore = true;
  
  @override
  FutureOr<List<Product>> build() async {
    _currentPage = 1;
    _hasMore = true;
    return _fetchProducts(page: 1);
  }
  
  Future<void> loadMore() async {
    if (!_hasMore || state.isLoading) return;
    
    final currentData = state.valueOrNull ?? [];
    
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      _currentPage++;
      final newProducts = await _fetchProducts(page: _currentPage);
      
      if (newProducts.length < _pageSize) {
        _hasMore = false;
      }
      
      return [...currentData, ...newProducts];
    });
  }
  
  Future<void> refresh() async {
    _currentPage = 1;
    _hasMore = true;
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchProducts(page: 1));
  }
  
  Future<List<Product>> _fetchProducts({required int page}) async {
    final repository = ref.read(productRepositoryProvider);
    final result = await repository.getProducts(
      page: page,
      limit: _pageSize,
    );
    
    return result.fold(
      (failure) => throw failure,
      (products) => products,
    );
  }
}

// features/product/presentation/screens/product_list_screen.dart (with pagination)
class ProductListScreen extends ConsumerStatefulWidget {
  const ProductListScreen({super.key});
  
  @override
  ConsumerState<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends ConsumerState<ProductListScreen> {
  final ScrollController _scrollController = ScrollController();
  
  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }
  
  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(paginatedProductControllerProvider.notifier).loadMore();
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final productsAsync = ref.watch(paginatedProductControllerProvider);
    
    return Scaffold(
      appBar: AppBar(title: const Text('Products')),
      body: RefreshIndicator(
        onRefresh: () => ref.read(paginatedProductControllerProvider.notifier).refresh(),
        child: productsAsync.when(
          data: (products) => ListView.builder(
            controller: _scrollController,
            itemCount: products.length + 1,
            itemBuilder: (context, index) {
              if (index == products.length) {
                return const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              return ProductListItem(product: products[index]);
            },
          ),
          error: (error, _) => ErrorView(
            error: error,
            onRetry: () => ref.read(paginatedProductControllerProvider.notifier).refresh(),
          ),
          loading: () => const ProductListShimmer(),
        ),
      ),
    );
  }
  
  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
```

---

## Deliverables

### 5. API Response Wrapper

**Description:** Wrapper untuk API response dengan status dan metadata.

**Output Format:**
```dart
// core/network/api_response.dart
@JsonSerializable(genericArgumentFactories: true)
class ApiResponse<T> {
  final bool success;
  final String? message;
  final T? data;
  final ApiMetadata? meta;
  
  ApiResponse({
    required this.success,
    this.message,
    this.data,
    this.meta,
  });
  
  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) =>
      _$ApiResponseFromJson(json, fromJsonT);
}

@JsonSerializable()
class ApiMetadata {
  final int? page;
  final int? limit;
  final int? total;
  final int? totalPages;
  
  ApiMetadata({
    this.page,
    this.limit,
    this.total,
    this.totalPages,
  });
  
  factory ApiMetadata.fromJson(Map<String, dynamic> json) =>
      _$ApiMetadataFromJson(json);
}
```


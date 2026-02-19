---
description: Implementasi repository pattern dengan REST API menggunakan Dio dan flutter_bloc. (Part 7/8)
---
# Workflow: Backend Integration (REST API) - Flutter BLoC (Part 7/8)

> **Navigation:** This workflow is split into 8 parts.

## Deliverables

### 7. Screen dengan BlocBuilder & Infinite Scroll

**Description:** Implementasi product list screen dengan `BlocBuilder`, `BlocListener`, dan ScrollController untuk infinite scroll pagination.

**Recommended Skills:** `senior-flutter-developer`

**Instructions:**
1. `BlocProvider` di widget tree (atau sudah dari routes)
2. `BlocListener` untuk menampilkan error snackbar
3. `BlocBuilder` untuk render UI berdasarkan state
4. `ScrollController` untuk detect scroll mendekati bottom → trigger `LoadNextPage`
5. Pull-to-refresh dengan `RefreshIndicator`
6. Search bar yang dispatch `SearchProducts` event

**Output Format:**
```dart
// features/product/presentation/screens/product_list_screen.dart
class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    // Trigger initial load
    context.read<PaginatedProductBloc>().add(const LoadProducts());
  }

  void _onScroll() {
    if (_isNearBottom) {
      context.read<PaginatedProductBloc>().add(const LoadNextPage());
    }
  }

  bool get _isNearBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    // Trigger load more saat 200px sebelum bottom
    return currentScroll >= (maxScroll - 200);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Products'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: _buildSearchField(),
          ),
        ),
      ),
      body: BlocListener<PaginatedProductBloc, PaginatedProductState>(
        listenWhen: (previous, current) =>
            previous.errorMessage != current.errorMessage &&
            current.errorMessage != null,
        listener: (context, state) {
          // Show error snackbar
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!),
              behavior: SnackBarBehavior.floating,
              action: SnackBarAction(
                label: 'Retry',
                onPressed: () {
                  context
                      .read<PaginatedProductBloc>()
                      .add(const RefreshProducts());
                },
              ),
            ),
          );
        },
        child: BlocBuilder<PaginatedProductBloc, PaginatedProductState>(
          builder: (context, state) {
            // Initial loading
            if (state.isInitialLoading) {
              return const ProductListShimmer();
            }

            // Error tanpa data
            if (state.hasError && !state.hasData) {
              return ErrorView(
                message: state.errorMessage ?? 'Terjadi kesalahan',
                onRetry: () {
                  context
                      .read<PaginatedProductBloc>()
                      .add(const LoadProducts());
                },
              );
            }

            // Empty state
            if (state.status == ProductStatus.loaded && !state.hasData) {
              return EmptyView(
                message: state.isSearching
                    ? 'Tidak ada produk untuk "${state.searchQuery}"'
                    : 'Belum ada produk',
                icon: Icons.inventory_2_outlined,
              );
            }

            // Data loaded — tampilkan list
            return RefreshIndicator(
              onRefresh: () async {
                context
                    .read<PaginatedProductBloc>()
                    .add(const RefreshProducts());
                // Tunggu sampai state berubah dari loading
                await context
                    .read<PaginatedProductBloc>()
                    .stream
                    .firstWhere((s) => s.status != ProductStatus.loading);
              },
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                // +1 untuk loading indicator di bottom
                itemCount: state.products.length + (state.hasMore ? 1 : 0),
                itemBuilder: (context, index) {
                  // Loading indicator di bottom (infinite scroll)
                  if (index == state.products.length) {
                    return _buildLoadMoreIndicator(state);
                  }

                  final product = state.products[index];
                  return ProductListItem(
                    product: product,
                    onTap: () => _navigateToDetail(product),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      decoration: InputDecoration(
        hintText: 'Cari produk...',
        prefixIcon: const Icon(Icons.search),
        suffixIcon: BlocBuilder<PaginatedProductBloc, PaginatedProductState>(
          buildWhen: (prev, curr) =>
              prev.searchQuery != curr.searchQuery,
          builder: (context, state) {
            if (state.isSearching) {
              return IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  _searchController.clear();
                  context
                      .read<PaginatedProductBloc>()
                      .add(const ClearSearch());
                },
              );
            }
            return const SizedBox.shrink();
          },
        ),
        filled: true,
        fillColor: Theme.of(context).colorScheme.surfaceVariant,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      ),
      onChanged: (query) {
        context
            .read<PaginatedProductBloc>()
            .add(SearchProducts(query));
      },
    );
  }

  Widget _buildLoadMoreIndicator(PaginatedProductState state) {
    if (state.isLoadingMore) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (state.hasError) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Center(
          child: TextButton.icon(
            onPressed: () {
              context
                  .read<PaginatedProductBloc>()
                  .add(const LoadNextPage());
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Coba lagi'),
          ),
        ),
      );
    }

    // hasMore = true tapi belum loading
    return const SizedBox(height: 16);
  }

  void _navigateToDetail(Product product) {
    // Navigator atau GoRouter
    context.push('/products/${product.id}');
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }
}

// BlocProvider setup — biasanya di router atau parent widget
// routes/app_router.dart (contoh dengan GoRouter)
GoRoute(
  path: '/products',
  builder: (context, state) => BlocProvider(
    create: (context) => sl<PaginatedProductBloc>(),
    child: const ProductListScreen(),
  ),
),

// Atau kalau pakai MultiBlocProvider di level app:
// main.dart / app.dart
MultiBlocProvider(
  providers: [
    BlocProvider(create: (_) => sl<AuthBloc>()),
    // PaginatedProductBloc biasanya di-provide per-screen, bukan global
  ],
  child: const MaterialApp.router(...),
),
```

---

## Deliverables

### 8. API Response Wrapper

**Description:** Generic wrapper untuk API response dengan status, message, data, dan pagination metadata. Framework-agnostic — sama persis dengan versi Riverpod.

**Output Format:**
```dart
// core/network/api_response.dart
import 'package:json_annotation/json_annotation.dart';

part 'api_response.g.dart';

/// Generic API response wrapper.
/// Mendukung format response:
/// {
///   "success": true,
///   "message": "Data retrieved",
///   "data": { ... } atau [ ... ],
///   "meta": { "page": 1, "limit": 20, "total": 100, "totalPages": 5 }
/// }
@JsonSerializable(genericArgumentFactories: true)
class ApiResponse<T> {
  final bool success;
  final String? message;
  final T? data;
  final ApiMetadata? meta;

  const ApiResponse({
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

  Map<String, dynamic> toJson(Object? Function(T value) toJsonT) =>
      _$ApiResponseToJson(this, toJsonT);

  /// Helper: apakah response menandakan masih ada halaman selanjutnya
  bool get hasNextPage {
    if (meta == null) return false;
    return (meta!.page ?? 0) < (meta!.totalPages ?? 0);
  }
}

@JsonSerializable()
class ApiMetadata {
  final int? page;
  final int? limit;
  final int? total;
  final int? totalPages;

  const ApiMetadata({
    this.page,
    this.limit,
    this.total,
    this.totalPages,
  });

  factory ApiMetadata.fromJson(Map<String, dynamic> json) =>
      _$ApiMetadataFromJson(json);

  Map<String, dynamic> toJson() => _$ApiMetadataToJson(this);
}

// core/network/paginated_response.dart
/// Helper class untuk response yang paginasi
/// Bisa digunakan langsung oleh BLoC untuk update state
class PaginatedResult<T> {
  final List<T> items;
  final int currentPage;
  final int totalPages;
  final int totalItems;
  final bool hasMore;

  const PaginatedResult({
    required this.items,
    required this.currentPage,
    required this.totalPages,
    required this.totalItems,
    required this.hasMore,
  });

  factory PaginatedResult.fromApiResponse(
    ApiResponse<List<T>> response, {
    required int requestedPage,
    required int pageSize,
  }) {
    return PaginatedResult(
      items: response.data ?? [],
      currentPage: response.meta?.page ?? requestedPage,
      totalPages: response.meta?.totalPages ?? 1,
      totalItems: response.meta?.total ?? 0,
      hasMore: (response.data?.length ?? 0) >= pageSize,
    );
  }
}
```

---


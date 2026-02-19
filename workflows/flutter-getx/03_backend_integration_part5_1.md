---
description: Implementasi repository pattern dengan REST API menggunakan Dio. (Sub-part 1/3)
---
# Workflow: Backend Integration (REST API) - GetX (Part 5/7)

> **Navigation:** This workflow is split into 7 parts.

## Deliverables

### 4. Pagination with Infinite Scroll (GetX)

Ini adalah perbedaan paling signifikan dari Riverpod. Di GetX, kita menggunakan `GetxController` dengan `.obs` variables dan `ScrollController` listener.

#### 4.1 PaginatedController

**File:** `lib/features/product/controllers/paginated_product_controller.dart`

```dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:myapp/core/error/app_exception.dart';
import 'package:myapp/features/product/data/models/product_model.dart';
import 'package:myapp/features/product/data/repositories/product_repository.dart';

class PaginatedProductController extends GetxController {
  final ProductRepository _repository = ProductRepository();

  // === Observable State ===
  final RxList<ProductModel> products = <ProductModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isLoadingMore = false.obs;
  final RxBool hasMore = true.obs;
  final Rx<String?> errorMessage = Rx<String?>(null);
  final RxString searchQuery = ''.obs;

  // === Internal State ===
  int _currentPage = 1;
  static const int _perPage = 20;

  // === Scroll Controller ===
  late final ScrollController scrollController;

  @override
  void onInit() {
    super.onInit();
    scrollController = ScrollController();
    scrollController.addListener(_onScroll);

    // Debounce search — tunggu 500ms sebelum fetch
    debounce(
      searchQuery,
      (_) => refresh(),
      time: const Duration(milliseconds: 500),
    );

    // Initial fetch
    _fetchProducts();
  }

  @override
  void onClose() {
    scrollController.removeListener(_onScroll);
    scrollController.dispose();
    super.onClose();
  }

  /// Scroll listener — trigger loadMore jika mendekati bottom
  void _onScroll() {
    if (scrollController.position.pixels >=
        scrollController.position.maxScrollExtent - 200) {
      loadMore();
    }
  }

  /// Fetch products (initial atau refresh)
  Future<void> _fetchProducts() async {
    if (isLoading.value) return;

    isLoading.value = true;
    errorMessage.value = null;

    try {
      final response = await _repository.getProducts(
        page: 1,
        perPage: _perPage,
        search: searchQuery.value.isNotEmpty ? searchQuery.value : null,
      );

      products.assignAll(response.data);
      _currentPage = 1;
      hasMore.value = response.currentPage < response.lastPage;
    } on AppException catch (e) {
      errorMessage.value = e.message;
    } catch (e) {
      errorMessage.value = 'Terjadi kesalahan tidak terduga.';
    } finally {
      isLoading.value = false;
    }
  }

  /// Load halaman berikutnya (infinite scroll)
  Future<void> loadMore() async {
    if (isLoadingMore.value || !hasMore.value || isLoading.value) return;

    isLoadingMore.value = true;

    try {
      final nextPage = _currentPage + 1;
      final response = await _repository.getProducts(
        page: nextPage,
        perPage: _perPage,
        search: searchQuery.value.isNotEmpty ? searchQuery.value : null,
      );

      products.addAll(response.data);
      _currentPage = nextPage;
      hasMore.value = response.currentPage < response.lastPage;
    } on AppException catch (e) {
      // Tampilkan error tapi jangan hapus data existing
      Get.snackbar(
        'Gagal Memuat',
        e.message,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal memuat halaman berikutnya.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoadingMore.value = false;
    }
  }

  /// Pull-to-refresh — reset dan fetch ulang dari page 1
  Future<void> refresh() async {
    _currentPage = 1;
    hasMore.value = true;
    await _fetchProducts();
  }

  /// Update search query (debounced via onInit)
  void onSearchChanged(String query) {
    searchQuery.value = query;
  }

  /// Hapus satu item secara optimistic
  Future<void> deleteProduct(String id) async {
    final index = products.indexWhere((p) => p.id == id);
    if (index == -1) return;

    // Simpan backup untuk rollback
    final backup = products[index];
    products.removeAt(index);

    try {
      await _repository.deleteProduct(id);
      Get.snackbar('Berhasil', 'Produk berhasil dihapus.',
          snackPosition: SnackPosition.BOTTOM);
    } on AppException catch (e) {
      // Rollback
      products.insert(index, backup);
      Get.snackbar('Gagal', e.message, snackPosition: SnackPosition.BOTTOM);
    }
  }
}
```

#### 4.2 Binding untuk PaginatedProductController

**File:** `lib/features/product/bindings/product_binding.dart`

```dart
import 'package:get/get.dart';
import 'package:myapp/features/product/controllers/paginated_product_controller.dart';

class ProductBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PaginatedProductController>(
      () => PaginatedProductController(),
    );
  }
}
```

Daftarkan di route:

```dart
GetPage(
  name: '/products',
  page: () => const ProductListView(),
  binding: ProductBinding(),
),
```

#### 4.3 ProductListView — Menggunakan `GetView` dan `Obx()`

Perbedaan dari Riverpod: tidak ada `ConsumerWidget` atau `ref.watch()`. Diganti `GetView<Controller>` dan `Obx()`.

**File:** `lib/features/product/views/product_list_view.dart`

```dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:myapp/features/product/controllers/paginated_product_controller.dart';
import 'package:myapp/features/product/data/models/product_model.dart';

class ProductListView extends GetView<PaginatedProductController> {
  const ProductListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Produk'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              onChanged: controller.onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Cari produk...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
            ),
          ),
        ),
      ),
      body: Obx(() {
        // === Loading State (initial) ===
        if (controller.isLoading.value && controller.products.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        // === Error State (no data) ===
        if (controller.errorMessage.value != null &&
            controller.products.isEmpty) {
          return _ErrorWidget(
            message: controller.errorMessage.value!,
            onRetry: controller.refresh,
          );
        }

        // === Empty State ===
        if (controller.products.isEmpty) {
          return _EmptyWidget(
            searchQuery: controller.searchQuery.value,
          );
        }

        // === Data State ===
        return RefreshIndicator(
          onRefresh: controller.refresh,
          child: ListView.builder(
            controller: controller.scrollController,
            padding: const EdgeInsets.all(16),
            itemCount: controller.products.length +
                (controller.hasMore.value ? 1 : 0),
            itemBuilder: (context, index) {
              // Loading indicator di bottom
              if (index == controller.products.length) {
                return _LoadingMoreIndicator(
                  isLoading: controller.isLoadingMore.value,
                );
              }

              final product = controller.products[index];
              return _ProductCard(
                product: product,
                onTap: () => Get.toNamed('/products/${product.id}'),
                onDelete: () => _confirmDelete(context, product),
              );
            },
          ),
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.toNamed('/products/create'),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _confirmDelete(BuildContext context, ProductModel product) {
    Get.defaultDialog(
      title: 'Hapus Produk',
      middleText: 'Yakin ingin menghapus "${product.name}"?',
      textConfirm: 'Hapus',
      textCancel: 'Batal',
      confirmTextColor: Colors.white,
      buttonColor: Colors.red,
      onConfirm: () {
        Get.back(); // Tutup dialog
        controller.deleteProduct(product.id);
      },
    );
  }
}

// === Private Widgets ===

class _ProductCard extends StatelessWidget {
  final ProductModel product;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _ProductCard({
    required this.product,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            product.imageUrl,
            width: 56,
            height: 56,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              width: 56,
              height: 56,
              color: Colors.grey[200],
              child: const Icon(Icons.image_not_supported),
            ),
          ),
        ),
        title: Text(
          product.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          'Rp ${product.price.toStringAsFixed(0)}',
          style: TextStyle(
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, color: Colors.red),
          onPressed: onDelete,
        ),
        onTap: onTap,
      ),
    );
  }
}
---
description: Integrasi Supabase sebagai alternative backend dengan GetX state management: Authentication, PostgreSQL Database, Rea... (Sub-part 1/3)
---
# Workflow: Supabase Integration (GetX) (Part 4/7)

> **Navigation:** This workflow is split into 7 parts.

## Deliverables

### 3. PostgreSQL Database Operations (GetX)

**Description:** CRUD operations dengan Supabase PostgreSQL, Row Level Security, dan GetX reactive controllers.

**Recommended Skills:** `senior-flutter-developer`, `senior-supabase-developer`, `senior-database-engineer-sql`

**Instructions:**
1. **Database Schema:**
   - Design tables di Supabase Dashboard
   - Setup relationships
   - Configure indexes

2. **RLS Policies:**
   - Enable RLS per table
   - Create policies untuk read/write
   - Authenticated vs Anonymous access

3. **Data Source (Framework-Agnostic):**
   - Class ini SAMA dengan versi Riverpod — tidak bergantung pada state management

4. **Controller (GetX-Specific):**
   - Gunakan `RxList`, `RxBool`, `Rx<T>` untuk state
   - Load data di `onInit()`
   - Search, filter, pagination sebagai methods

**Output Format:**
```dart
// ============================================================
// DATA SOURCE — Framework-agnostic, sama dengan versi Riverpod
// ============================================================

// features/product/data/datasources/product_supabase_ds.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/product_model.dart';

class ProductSupabaseDataSource {
  final SupabaseClient _supabase;

  ProductSupabaseDataSource({SupabaseClient? supabase})
      : _supabase = supabase ?? Supabase.instance.client;

  SupabaseQueryBuilder get _productsTable =>
      _supabase.from('products');

  Future<List<ProductModel>> getProducts() async {
    final response = await _productsTable
        .select()
        .order('created_at', ascending: false);

    return (response as List)
        .map((json) => ProductModel.fromJson(json))
        .toList();
  }

  Future<ProductModel> getProductById(String id) async {
    final response = await _productsTable
        .select()
        .eq('id', id)
        .single();

    return ProductModel.fromJson(response);
  }

  Future<ProductModel> createProduct(ProductModel product) async {
    final response = await _productsTable
        .insert({
          'name': product.name,
          'price': product.price,
          'description': product.description,
          'user_id': _supabase.auth.currentUser!.id,
        })
        .select()
        .single();

    return ProductModel.fromJson(response);
  }

  Future<ProductModel> updateProduct(ProductModel product) async {
    final response = await _productsTable
        .update({
          'name': product.name,
          'price': product.price,
          'description': product.description,
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', product.id)
        .select()
        .single();

    return ProductModel.fromJson(response);
  }

  Future<void> deleteProduct(String id) async {
    await _productsTable.delete().eq('id', id);
  }

  // Advanced queries
  Future<List<ProductModel>> searchProducts(String query) async {
    final response = await _productsTable
        .select()
        .ilike('name', '%$query%')
        .order('created_at', ascending: false);

    return (response as List)
        .map((json) => ProductModel.fromJson(json))
        .toList();
  }

  Future<List<ProductModel>> getProductsWithPagination({
    required int page,
    required int limit,
  }) async {
    final response = await _productsTable
        .select()
        .range((page - 1) * limit, page * limit - 1)
        .order('created_at', ascending: false);

    return (response as List)
        .map((json) => ProductModel.fromJson(json))
        .toList();
  }

  // Join dengan table lain
  Future<List<Map<String, dynamic>>> getProductsWithUser() async {
    final response = await _productsTable
        .select('*, users(*)')
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }
}

// ============================================================
// PRODUCT MODEL
// ============================================================

// features/product/data/models/product_model.dart
class ProductModel {
  final String id;
  final String name;
  final double price;
  final String? description;
  final String userId;
  final DateTime createdAt;
  final DateTime? updatedAt;

  ProductModel({
    required this.id,
    required this.name,
    required this.price,
    this.description,
    required this.userId,
    required this.createdAt,
    this.updatedAt,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] as String,
      name: json['name'] as String,
      price: (json['price'] as num).toDouble(),
      description: json['description'] as String?,
      userId: json['user_id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'price': price,
        'description': description,
        'user_id': userId,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt?.toIso8601String(),
      };
}

// ============================================================
// PRODUCT CONTROLLER — GetX version
// Ini BERBEDA dari Riverpod. Gunakan RxList, RxBool, dsb.
// ============================================================

// features/product/presentation/controllers/product_controller.dart
import 'package:get/get.dart';
import '../../data/datasources/product_supabase_ds.dart';
import '../../data/models/product_model.dart';

class ProductController extends GetxController {
  final ProductSupabaseDataSource _dataSource;

  ProductController({ProductSupabaseDataSource? dataSource})
      : _dataSource = dataSource ?? ProductSupabaseDataSource();

  // ---- Reactive State ----
  final RxList<ProductModel> products = <ProductModel>[].obs;
  final Rx<ProductModel?> selectedProduct = Rx<ProductModel?>(null);
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxBool hasMore = true.obs;

  // ---- Pagination ----
  int _currentPage = 1;
  final int _pageSize = 20;

  // ---- Search ----
  final RxString searchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchProducts();

    // Debounce search — otomatis cari setelah user berhenti mengetik 500ms
    debounce(
      searchQuery,
      (_) => _performSearch(),
      time: const Duration(milliseconds: 500),
    );
  }

  // ---- Fetch all products ----
  Future<void> fetchProducts() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final result = await _dataSource.getProducts();
      products.assignAll(result);
    } catch (e) {
      errorMessage.value = 'Gagal memuat produk: $e';
      Get.snackbar('Error', errorMessage.value);
    } finally {
      isLoading.value = false;
    }
  }

  // ---- Fetch with pagination ----
  Future<void> fetchProductsPaginated({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
      hasMore.value = true;
      products.clear();
    }

    if (!hasMore.value || isLoading.value) return;

    isLoading.value = true;
    errorMessage.value = '';

    try {
      final result = await _dataSource.getProductsWithPagination(
        page: _currentPage,
        limit: _pageSize,
      );

      if (result.length < _pageSize) {
        hasMore.value = false;
      }

      products.addAll(result);
      _currentPage++;
    } catch (e) {
      errorMessage.value = 'Gagal memuat halaman: $e';
    } finally {
      isLoading.value = false;
    }
  }

  // ---- Search ----
  void _performSearch() async {
    if (searchQuery.value.isEmpty) {
      fetchProducts();
      return;
    }

    isLoading.value = true;
    errorMessage.value = '';

    try {
      final result = await _dataSource.searchProducts(searchQuery.value);
      products.assignAll(result);
    } catch (e) {
      errorMessage.value = 'Search gagal: $e';
    } finally {
      isLoading.value = false;
    }
  }

  // ---- Get single product ----
  Future<void> getProduct(String id) async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final result = await _dataSource.getProductById(id);
      selectedProduct.value = result;
    } catch (e) {
      errorMessage.value = 'Gagal memuat detail: $e';
    } finally {
      isLoading.value = false;
    }
  }

  // ---- Create product ----
  Future<void> createProduct(ProductModel product) async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final created = await _dataSource.createProduct(product);
      products.insert(0, created); // tambahkan di awal list
      Get.back(); // kembali ke list
      Get.snackbar('Success', 'Produk berhasil ditambahkan');
    } catch (e) {
      errorMessage.value = 'Gagal membuat produk: $e';
      Get.snackbar('Error', errorMessage.value);
    } finally {
      isLoading.value = false;
    }
  }

  // ---- Update product ----
  Future<void> updateProduct(ProductModel product) async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final updated = await _dataSource.updateProduct(product);
      final index = products.indexWhere((p) => p.id == updated.id);
      if (index != -1) {
        products[index] = updated;
      }
      selectedProduct.value = updated;
      Get.back();
      Get.snackbar('Success', 'Produk berhasil diupdate');
    } catch (e) {
      errorMessage.value = 'Gagal update produk: $e';
      Get.snackbar('Error', errorMessage.value);
    } finally {
      isLoading.value = false;
    }
  }

  // ---- Delete product ----
  Future<void> deleteProduct(String id) async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      await _dataSource.deleteProduct(id);
      products.removeWhere((p) => p.id == id);
      if (selectedProduct.value?.id == id) {
        selectedProduct.value = null;
      }
      Get.snackbar('Success', 'Produk berhasil dihapus');
    } catch (e) {
      errorMessage.value = 'Gagal hapus produk: $e';
      Get.snackbar('Error', errorMessage.value);
    } finally {
      isLoading.value = false;
    }
  }
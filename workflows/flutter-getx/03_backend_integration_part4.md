---
description: Implementasi repository pattern dengan REST API menggunakan Dio. (Part 4/7)
---
# Workflow: Backend Integration (REST API) - GetX (Part 4/7)

> **Navigation:** This workflow is split into 7 parts.

## Deliverables

### 3. Repository Pattern with Offline-First

#### 3.1 NetworkInfo Service

Cek konektivitas menggunakan `connectivity_plus`. Di-register sebagai `GetxService`.

**File:** `lib/core/network/network_info.dart`

```dart
import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';

class NetworkInfo extends GetxService {
  final Connectivity _connectivity = Connectivity();

  final RxBool isConnected = true.obs;

  late StreamSubscription<List<ConnectivityResult>> _subscription;

  @override
  void onInit() {
    super.onInit();
    _subscription = _connectivity.onConnectivityChanged.listen((results) {
      isConnected.value = !results.contains(ConnectivityResult.none);
    });
    // Cek status awal
    _checkInitialStatus();
  }

  Future<void> _checkInitialStatus() async {
    final results = await _connectivity.checkConnectivity();
    isConnected.value = !results.contains(ConnectivityResult.none);
  }

  /// One-shot connectivity check
  Future<bool> checkConnectivity() async {
    final results = await _connectivity.checkConnectivity();
    return !results.contains(ConnectivityResult.none);
  }

  @override
  void onClose() {
    _subscription.cancel();
    super.onClose();
  }
}
```

#### 3.2 Base Repository

**File:** `lib/core/repositories/base_repository.dart`

```dart
import 'package:get/get.dart';
import 'package:myapp/core/error/app_exception.dart';
import 'package:myapp/core/network/dio_client.dart';
import 'package:myapp/core/network/network_info.dart';

/// Base repository yang menyediakan akses ke DioClient dan NetworkInfo
/// via Get.find(). Semua repository turunan tidak perlu menerima
/// dependency via constructor — cukup panggil getter.
abstract class BaseRepository {
  DioClient get dioClient => Get.find<DioClient>();
  NetworkInfo get networkInfo => Get.find<NetworkInfo>();

  /// Wrapper untuk menjalankan request dengan error handling.
  /// Jika offline dan [offlineFallback] disediakan, gunakan fallback.
  Future<T> safeRequest<T>({
    required Future<T> Function() request,
    Future<T> Function()? offlineFallback,
  }) async {
    final isOnline = await networkInfo.checkConnectivity();

    if (!isOnline) {
      if (offlineFallback != null) {
        return offlineFallback();
      }
      throw const NetworkException(
        message: 'Tidak ada koneksi internet. Data offline tidak tersedia.',
      );
    }

    try {
      return await request();
    } on AppException {
      rethrow;
    } catch (e) {
      throw ServerException(
        message: 'Terjadi kesalahan tidak terduga.',
        originalError: e,
      );
    }
  }
}
```

#### 3.3 Product Repository — Contoh Implementasi

**File:** `lib/features/product/data/repositories/product_repository.dart`

```dart
import 'package:myapp/core/error/app_exception.dart';
import 'package:myapp/core/models/api_response.dart';
import 'package:myapp/core/models/paginated_response.dart';
import 'package:myapp/core/repositories/base_repository.dart';
import 'package:myapp/features/product/data/models/product_model.dart';
import 'package:myapp/features/product/data/datasources/product_local_datasource.dart';

class ProductRepository extends BaseRepository {
  final ProductLocalDataSource _localDataSource = ProductLocalDataSource();

  /// Ambil daftar produk dengan pagination.
  /// Online: fetch dari API, simpan ke cache.
  /// Offline: ambil dari cache lokal.
  Future<PaginatedResponse<ProductModel>> getProducts({
    int page = 1,
    int perPage = 20,
    String? search,
    String? category,
  }) async {
    return safeRequest(
      request: () async {
        final response = await dioClient.get(
          '/products',
          queryParameters: {
            'page': page,
            'per_page': perPage,
            if (search != null && search.isNotEmpty) 'search': search,
            if (category != null) 'category': category,
          },
        );

        final paginated = PaginatedResponse<ProductModel>.fromJson(
          response.data as Map<String, dynamic>,
          (json) => ProductModel.fromJson(json as Map<String, dynamic>),
        );

        // Simpan ke local cache (hanya page pertama)
        if (page == 1) {
          await _localDataSource.cacheProducts(paginated.data);
        }

        return paginated;
      },
      offlineFallback: () async {
        final cachedProducts = await _localDataSource.getCachedProducts();
        if (cachedProducts.isEmpty) {
          throw const CacheException(
            message: 'Tidak ada data offline tersedia.',
          );
        }
        return PaginatedResponse<ProductModel>(
          data: cachedProducts,
          currentPage: 1,
          lastPage: 1,
          total: cachedProducts.length,
          perPage: cachedProducts.length,
        );
      },
    );
  }

  /// Ambil detail produk berdasarkan ID
  Future<ProductModel> getProductById(String id) async {
    return safeRequest(
      request: () async {
        final response = await dioClient.get('/products/$id');
        final apiResponse = ApiResponse<ProductModel>.fromJson(
          response.data as Map<String, dynamic>,
          (json) => ProductModel.fromJson(json as Map<String, dynamic>),
        );
        return apiResponse.data;
      },
      offlineFallback: () async {
        final cached = await _localDataSource.getCachedProduct(id);
        if (cached == null) {
          throw const CacheException(
            message: 'Detail produk tidak tersedia secara offline.',
          );
        }
        return cached;
      },
    );
  }

  /// Buat produk baru (harus online)
  Future<ProductModel> createProduct(ProductModel product) async {
    final response = await dioClient.post(
      '/products',
      data: product.toJson(),
    );
    final apiResponse = ApiResponse<ProductModel>.fromJson(
      response.data as Map<String, dynamic>,
      (json) => ProductModel.fromJson(json as Map<String, dynamic>),
    );
    return apiResponse.data;
  }

  /// Update produk
  Future<ProductModel> updateProduct(
    String id,
    Map<String, dynamic> updates,
  ) async {
    final response = await dioClient.patch(
      '/products/$id',
      data: updates,
    );
    final apiResponse = ApiResponse<ProductModel>.fromJson(
      response.data as Map<String, dynamic>,
      (json) => ProductModel.fromJson(json as Map<String, dynamic>),
    );
    return apiResponse.data;
  }

  /// Hapus produk
  Future<void> deleteProduct(String id) async {
    await dioClient.delete('/products/$id');
  }
}
```

#### 3.4 Local DataSource (Hive Cache)

**File:** `lib/features/product/data/datasources/product_local_datasource.dart`

```dart
import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:myapp/features/product/data/models/product_model.dart';

class ProductLocalDataSource {
  static const String _boxName = 'products_cache';
  static const String _listKey = 'products_list';
  static const Duration _cacheValidity = Duration(hours: 1);

  Future<Box> get _box async => await Hive.openBox(_boxName);

  /// Simpan list produk ke cache dengan timestamp
  Future<void> cacheProducts(List<ProductModel> products) async {
    final box = await _box;
    final data = {
      'timestamp': DateTime.now().toIso8601String(),
      'products': products.map((p) => p.toJson()).toList(),
    };
    await box.put(_listKey, jsonEncode(data));
  }

  /// Ambil cached products (return empty jika expired)
  Future<List<ProductModel>> getCachedProducts() async {
    final box = await _box;
    final raw = box.get(_listKey);

    if (raw == null) return [];

    final decoded = jsonDecode(raw as String) as Map<String, dynamic>;
    final timestamp = DateTime.parse(decoded['timestamp'] as String);

    // Cek apakah cache masih valid
    if (DateTime.now().difference(timestamp) > _cacheValidity) {
      return [];
    }

    final products = (decoded['products'] as List)
        .map((e) => ProductModel.fromJson(e as Map<String, dynamic>))
        .toList();

    return products;
  }

  /// Ambil single cached product
  Future<ProductModel?> getCachedProduct(String id) async {
    final box = await _box;
    final raw = box.get('product_$id');
    if (raw == null) return null;

    final decoded = jsonDecode(raw as String) as Map<String, dynamic>;
    return ProductModel.fromJson(decoded);
  }

  /// Hapus semua cache
  Future<void> clearCache() async {
    final box = await _box;
    await box.clear();
  }
}
```

---


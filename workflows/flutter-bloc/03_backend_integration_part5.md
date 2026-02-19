---
description: Implementasi repository pattern dengan REST API menggunakan Dio dan flutter_bloc. (Part 5/8)
---
# Workflow: Backend Integration (REST API) - Flutter BLoC (Part 5/8)

> **Navigation:** This workflow is split into 8 parts.

## Deliverables

### 5. Repository Pattern dengan Offline-First

**Description:** Repository implementation dengan strategy: return local first, sync in background. Layer ini framework-agnostic — data layer tidak tahu apakah dipakai oleh BLoC atau Riverpod.

**Recommended Skills:** `senior-flutter-developer`

**Instructions:**
1. Implement repository dengan offline-first strategy:
   - Return data dari local cache terlebih dahulu
   - Fetch dari remote di background
   - Update cache dengan data terbaru
   - Handle network errors gracefully

2. Setup sync mechanism:
   - Queue untuk pending operations (create/update/delete saat offline)
   - Retry strategy untuk failed syncs
   - Conflict resolution sederhana (server wins / last-write-wins)

3. **Perbedaan kecil dengan Riverpod:** DI injection. Di Riverpod, repository di-provide via `Provider`. Di BLoC, repository di-register sebagai `@lazySingleton` di get_it dan diinject ke BLoC/UseCase.

**Output Format:**
```dart
// features/product/data/data_sources/product_remote_data_source.dart
abstract class ProductRemoteDataSource {
  Future<ApiResponse<List<ProductModel>>> getProducts({
    int page = 1,
    int limit = 20,
    String? search,
  });
  Future<ApiResponse<ProductModel>> getProduct(String id);
  Future<ApiResponse<ProductModel>> createProduct(ProductModel product);
  Future<ApiResponse<ProductModel>> updateProduct(ProductModel product);
  Future<ApiResponse<void>> deleteProduct(String id);
}

@LazySingleton(as: ProductRemoteDataSource)
class ProductRemoteDataSourceImpl implements ProductRemoteDataSource {
  final DioClient _dioClient;

  ProductRemoteDataSourceImpl(this._dioClient);

  @override
  Future<ApiResponse<List<ProductModel>>> getProducts({
    int page = 1,
    int limit = 20,
    String? search,
  }) async {
    final response = await _dioClient.get(
      '/products',
      queryParameters: {
        'page': page,
        'limit': limit,
        if (search != null && search.isNotEmpty) 'search': search,
      },
    );

    return ApiResponse.fromJson(
      response.data,
      (json) => (json as List)
          .map((item) => ProductModel.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  @override
  Future<ApiResponse<ProductModel>> getProduct(String id) async {
    final response = await _dioClient.get('/products/$id');

    return ApiResponse.fromJson(
      response.data,
      (json) => ProductModel.fromJson(json as Map<String, dynamic>),
    );
  }

  @override
  Future<ApiResponse<ProductModel>> createProduct(ProductModel product) async {
    final response = await _dioClient.post(
      '/products',
      data: product.toJson(),
    );

    return ApiResponse.fromJson(
      response.data,
      (json) => ProductModel.fromJson(json as Map<String, dynamic>),
    );
  }

  @override
  Future<ApiResponse<ProductModel>> updateProduct(ProductModel product) async {
    final response = await _dioClient.put(
      '/products/${product.id}',
      data: product.toJson(),
    );

    return ApiResponse.fromJson(
      response.data,
      (json) => ProductModel.fromJson(json as Map<String, dynamic>),
    );
  }

  @override
  Future<ApiResponse<void>> deleteProduct(String id) async {
    final response = await _dioClient.delete('/products/$id');

    return ApiResponse.fromJson(
      response.data,
      (_) {},
    );
  }
}

// features/product/data/data_sources/product_local_data_source.dart
abstract class ProductLocalDataSource {
  Future<List<ProductModel>> getProducts();
  Future<ProductModel?> getProduct(String id);
  Future<void> cacheProducts(List<ProductModel> products);
  Future<void> addProduct(ProductModel product);
  Future<void> updateProduct(ProductModel product);
  Future<void> deleteProduct(String id);
  Future<void> markAsPending(String id, SyncAction action);
  Future<List<PendingSyncItem>> getPendingSyncItems();
  Future<void> clearPendingSync(String id);
  Stream<List<ProductModel>> watchProducts();
}

/// SyncAction untuk offline queue
enum SyncAction { create, update, delete }

@freezed
class PendingSyncItem with _$PendingSyncItem {
  const factory PendingSyncItem({
    required String id,
    required SyncAction action,
    required DateTime createdAt,
    ProductModel? data,
  }) = _PendingSyncItem;
}

// features/product/data/repositories/product_repository_impl.dart
@LazySingleton(as: ProductRepository)
class ProductRepositoryImpl implements ProductRepository {
  final ProductRemoteDataSource _remoteDataSource;
  final ProductLocalDataSource _localDataSource;
  final NetworkInfo _networkInfo;

  ProductRepositoryImpl({
    required ProductRemoteDataSource remoteDataSource,
    required ProductLocalDataSource localDataSource,
    required NetworkInfo networkInfo,
  })  : _remoteDataSource = remoteDataSource,
        _localDataSource = localDataSource,
        _networkInfo = networkInfo;

  @override
  Future<Either<Failure, List<Product>>> getProducts({
    int page = 1,
    int limit = 20,
    String? search,
  }) async {
    try {
      // Strategy: return local dulu, sync di background
      if (page == 1 && search == null) {
        final localProducts = await _localDataSource.getProducts();
        if (localProducts.isNotEmpty) {
          // Ada cache — return dulu, sync background
          if (await _networkInfo.isConnected) {
            _syncProductsInBackground();
          }
          return Right(localProducts.map((m) => m.toEntity()).toList());
        }
      }

      // Tidak ada cache atau request pagination/search — fetch remote
      if (await _networkInfo.isConnected) {
        return _fetchFromRemote(page: page, limit: limit, search: search);
      }

      return const Left(NetworkFailure());
    } on CacheException catch (e) {
      // Cache error — fallback ke remote
      if (await _networkInfo.isConnected) {
        return _fetchFromRemote(page: page, limit: limit, search: search);
      }
      return Left(CacheFailure(e.message));
    }
  }

  Future<Either<Failure, List<Product>>> _fetchFromRemote({
    required int page,
    required int limit,
    String? search,
  }) async {
    try {
      final response = await _remoteDataSource.getProducts(
        page: page,
        limit: limit,
        search: search,
      );

      final products = response.data ?? [];

      // Cache halaman pertama saja
      if (page == 1 && search == null) {
        await _localDataSource.cacheProducts(products);
      }

      return Right(products.map((m) => m.toEntity()).toList());
    } on DioException catch (e) {
      final appException = e.error is AppException
          ? e.error as AppException
          : ErrorMapper.fromDioException(e);
      return Left(ErrorMapper.toFailure(appException));
    }
  }

  Future<void> _syncProductsInBackground() async {
    try {
      final response = await _remoteDataSource.getProducts(page: 1, limit: 50);
      final products = response.data ?? [];
      await _localDataSource.cacheProducts(products);
    } catch (_) {
      // Silent fail untuk background sync
    }
  }

  @override
  Future<Either<Failure, Product>> createProduct(Product product) async {
    try {
      final model = ProductModel.fromEntity(product);

      // Optimistic: simpan lokal dulu
      await _localDataSource.addProduct(model);

      if (await _networkInfo.isConnected) {
        try {
          final response = await _remoteDataSource.createProduct(model);
          final created = response.data!;
          await _localDataSource.updateProduct(created);
          return Right(created.toEntity());
        } on DioException {
          // Remote gagal — queue untuk sync nanti
          await _localDataSource.markAsPending(model.id, SyncAction.create);
          return Right(product);
        }
      } else {
        // Offline — queue untuk sync nanti
        await _localDataSource.markAsPending(model.id, SyncAction.create);
        return Right(product);
      }
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, Product>> updateProduct(Product product) async {
    try {
      final model = ProductModel.fromEntity(product);

      // Optimistic: update lokal dulu
      await _localDataSource.updateProduct(model);

      if (await _networkInfo.isConnected) {
        try {
          final response = await _remoteDataSource.updateProduct(model);
          final updated = response.data!;
          await _localDataSource.updateProduct(updated);
          return Right(updated.toEntity());
        } on DioException {
          await _localDataSource.markAsPending(model.id, SyncAction.update);
          return Right(product);
        }
      } else {
        await _localDataSource.markAsPending(model.id, SyncAction.update);
        return Right(product);
      }
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> deleteProduct(String id) async {
    try {
      await _localDataSource.deleteProduct(id);

      if (await _networkInfo.isConnected) {
        try {
          await _remoteDataSource.deleteProduct(id);
          return const Right(null);
        } on DioException {
          await _localDataSource.markAsPending(id, SyncAction.delete);
          return const Right(null);
        }
      } else {
        await _localDataSource.markAsPending(id, SyncAction.delete);
        return const Right(null);
      }
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  @override
  Stream<List<Product>> watchProducts() {
    return _localDataSource.watchProducts().map(
          (models) => models.map((m) => m.toEntity()).toList(),
        );
  }
}
```

---


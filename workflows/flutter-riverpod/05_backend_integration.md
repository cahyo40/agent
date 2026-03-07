---
description: Implementasi repository pattern dengan REST API menggunakan Dio.
---
# Workflow: Backend Integration (REST API)

// turbo-all

## Overview

Implementasi repository pattern dengan REST API menggunakan Dio. Mencakup
setup Dio dengan interceptors, error handling, offline-first strategy, dan
pagination.


## Prerequisites

- Project setup dari `01_project_setup.md` selesai
- API endpoint tersedia
- API documentation (Swagger/OpenAPI)


## Agent Behavior

- **Tanya base URL API** — jangan hardcode, gunakan `AppConfig`.
- **Auto-setup semua interceptors** — auth, retry, logging, error.
- **Implement offline-first** sebagai default pattern.
- **Gunakan 15s timeout** — bukan 30s default.


## Recommended Skills

- `senior-backend-developer` — REST API patterns
- `api-design-specialist` — API integration
- `python-async-specialist` — Concurrency & Parallelism (Dart isolates equivalent)


## Workflow Steps

### Step 1: Setup Dio Client

```dart
// core/network/dio_client.dart
class DioClient {
  late final Dio _dio;

  DioClient({required Ref ref}) {
    _dio = Dio(BaseOptions(
      baseUrl: AppConfig.baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    _dio.interceptors.addAll([
      AuthInterceptor(ref: ref),
      RetryInterceptor(dio: _dio),
      LoggingInterceptor(),
      ErrorInterceptor(),
    ]);
  }

  Dio get dio => _dio;
}
```

### Step 2: Auth Interceptor

```dart
// core/network/interceptors/auth_interceptor.dart
class AuthInterceptor extends Interceptor {
  final Ref _ref;

  AuthInterceptor({required Ref ref}) : _ref = ref;

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _ref
        .read(secureStorageProvider)
        .read('access_token');
    if (token != null) {
      options.headers['Authorization'] =
          'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode == 401) {
      final refreshed = await _refreshToken();
      if (refreshed) {
        final token = await _ref
            .read(secureStorageProvider)
            .read('access_token');
        err.requestOptions.headers['Authorization'] =
            'Bearer $token';
        final response = await _ref
            .read(dioProvider)
            .fetch(err.requestOptions);
        handler.resolve(response);
        return;
      }
    }
    handler.next(err);
  }

  Future<bool> _refreshToken() async {
    try {
      final refreshToken = await _ref
          .read(secureStorageProvider)
          .read('refresh_token');
      if (refreshToken == null) return false;

      final response = await _ref
          .read(dioProvider)
          .post('/auth/refresh', data: {
        'refresh_token': refreshToken,
      });

      await _ref
          .read(secureStorageProvider)
          .write(
            'access_token',
            response.data['access_token'],
          );
      return true;
    } catch (e) {
      return false;
    }
  }
}
```

### Step 3: Retry Interceptor

```dart
// core/network/interceptors/retry_interceptor.dart
class RetryInterceptor extends Interceptor {
  final Dio _dio;
  final int maxRetries = 3;

  RetryInterceptor({required Dio dio}) : _dio = dio;

  @override
  void onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (_shouldRetry(err) &&
        err.requestOptions.extra['retry_count'] !=
            maxRetries) {
      final retryCount =
          (err.requestOptions.extra['retry_count'] ??
                  0) +
              1;
      err.requestOptions.extra['retry_count'] =
          retryCount;

      // Exponential backoff
      await Future.delayed(
        Duration(seconds: retryCount),
      );

      try {
        final response =
            await _dio.fetch(err.requestOptions);
        handler.resolve(response);
        return;
      } catch (e) {
        // Continue to next error handler
      }
    }
    handler.next(err);
  }

  bool _shouldRetry(DioException err) {
    return err.type ==
            DioExceptionType.connectionTimeout ||
        err.type ==
            DioExceptionType.receiveTimeout ||
        (err.response?.statusCode != null &&
            err.response!.statusCode! >= 500);
  }
}
```

### Step 4: Error Mapping

```dart
// core/network/error_mapper.dart
class ErrorMapper {
  static AppException map(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
        return TimeoutException(
          'Request timeout. Please try again.',
        );

      case DioExceptionType.connectionError:
        return NetworkException(
          'No internet connection.',
        );

      case DioExceptionType.badResponse:
        return _mapStatusCode(error.response);

      case DioExceptionType.cancel:
        return CancelException(
          'Request was cancelled.',
        );

      default:
        return UnknownException(
          'Something went wrong.',
        );
    }
  }

  static AppException _mapStatusCode(
    Response? response,
  ) {
    final statusCode = response?.statusCode;
    final data = response?.data;

    switch (statusCode) {
      case 400:
        return BadRequestException(
          data?['message'] ?? 'Bad request',
        );
      case 401:
        return UnauthorizedException(
          'Session expired. Please login again.',
        );
      case 403:
        return ForbiddenException(
          'No permission to access this resource.',
        );
      case 404:
        return NotFoundException(
          'Resource not found.',
        );
      case 422:
        return ValidationException(
          data?['message'] ?? 'Validation failed',
          errors: data?['errors'],
        );
      case 500:
      case 502:
      case 503:
      case 504:
        return ServerException(
          'Server error. Please try again later.',
        );
      default:
        return UnknownException(
          'An unexpected error occurred.',
        );
    }
  }
}
```

### Step 5: Repository Pattern (Offline-First)

```dart
// features/product/data/repositories/product_repository_impl.dart
class ProductRepositoryImpl
    implements ProductRepository {
  final ProductRemoteDataSource remoteDataSource;
  final ProductLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  ProductRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<Result<List<Product>>>
      getProducts() async {
    try {
      final localProducts =
          await localDataSource.getProducts();

      if (await networkInfo.isConnected) {
        _syncProductsInBackground();
      }

      return Success(
        localProducts
            .map((m) => m.toEntity())
            .toList(),
      );
    } on CacheException {
      if (await networkInfo.isConnected) {
        return _fetchFromRemote();
      }
      return const Err(
        CacheFailure('No cached data available'),
      );
    }
  }

  Future<Result<List<Product>>>
      _fetchFromRemote() async {
    try {
      final remoteProducts =
          await remoteDataSource.getProducts();
      await localDataSource
          .cacheProducts(remoteProducts);

      return Success(
        remoteProducts
            .map((m) => m.toEntity())
            .toList(),
      );
    } on DioException catch (e) {
      return Err(
        ServerFailure(ErrorMapper.map(e).message),
      );
    }
  }

  Future<void>
      _syncProductsInBackground() async {
    try {
      final remoteProducts =
          await remoteDataSource.getProducts();
      await localDataSource
          .cacheProducts(remoteProducts);
    } catch (_) {
      // Silent fail for background sync
    }
  }

  @override
  Stream<List<Product>> watchProducts() {
    return localDataSource.watchProducts().map(
          (models) => models
              .map((m) => m.toEntity())
              .toList(),
        );
  }
}
```

### Step 6: Pagination (Infinite Scroll)

```dart
// features/product/presentation/controllers/paginated_product_controller.dart
@riverpod
class PaginatedProductController
    extends _$PaginatedProductController {
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

    final currentData =
        state.valueOrNull ?? [];

    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      _currentPage++;
      final newProducts =
          await _fetchProducts(page: _currentPage);

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
    state = await AsyncValue.guard(
      () => _fetchProducts(page: 1),
    );
  }

  Future<List<Product>> _fetchProducts({
    required int page,
  }) async {
    final repository =
        ref.read(productRepositoryProvider);
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
```

### Step 7: API Response Wrapper

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
  ) => _$ApiResponseFromJson(json, fromJsonT);
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

  factory ApiMetadata.fromJson(
    Map<String, dynamic> json,
  ) => _$ApiMetadataFromJson(json);
}
```

### Step 8: Isolates untuk Parsing JSON Besar

Untuk menghindari UI jank (freeze) saat mem-parsing JSON payload yang sangat besar (>1MB), gunakan `Isolate.run()` dari Dart 3. Ini memindahkan proses decoding ke background thread.

```dart
// features/product/data/repositories/product_repository_impl.dart
import 'dart:convert';
import 'dart:isolate';

  @override
  Future<Result<List<Product>>> getMassiveProducts() async {
    try {
      final response = await remoteDataSource.getMassivePayload();
      
      // Memindahkan komputasi berat ke Isolate
      final productsList = await Isolate.run<List<Product>>(() {
        // PROSES BERAT DALAM ISOLATE (Background Thread)
        final List<dynamic> jsonList = jsonDecode(response.data.toString());
        return jsonList.map((e) => ProductModel.fromJson(e as Map<String, dynamic>).toEntity()).toList();
      });

      return Success(productsList);
    } catch (e) {
      return Err(ServerFailure('Failed to parse massive products'));
    }
  }
```

### Step 9: Periodic Background Sync (Workmanager)

Untuk melakukan sinkronisasi data lokal ke server secara batch ketika aplikasi di background (misal tiap 12 jam).

```dart
// lib/bootstrap/background_worker.dart
import 'package:workmanager/workmanager.dart';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    switch (task) {
      case 'syncDataTask':
        // Lakukan sinkronisasi background (misal: API calls)
        break;
    }
    return Future.value(true);
  });
}

class BackgroundWorker {
  static Future<void> initialize() async {
    await Workmanager().initialize(callbackDispatcher, isInDebugMode: false);
  }

  static void registerPeriodicSync() {
    Workmanager().registerPeriodicTask(
      "1",
      "syncDataTask",
      frequency: const Duration(hours: 12),
    );
  }
}
```

### Step 10: Test Integration

- Test with mock server
- Test error scenarios
- Test offline behavior
- Test pagination


## Success Criteria

- [ ] Dio configured dengan semua interceptors
- [ ] Auth token auto-refresh berfungsi
- [ ] Error mapping ke AppException berfungsi
- [ ] Repository dengan offline-first implemented
- [ ] Pagination dengan infinite scroll berfungsi
- [ ] Optimistic updates implemented
- [ ] Retry mechanism untuk 5xx errors
- [ ] Timeout configured (15s)
- [ ] Background JSON parsing dengan `Isolate` berjalan (UI tidak freeze)
- [ ] Background sync task terdaftar (opsional jika menggunakan workmanager)
- [ ] All CRUD operations tested


## Best Practices

### ✅ Do This
- ✅ Set API timeout ke 15s (bukan 30s default)
- ✅ Implement cache-first strategy untuk static data
- ✅ Use debounce (300-500ms) untuk search
- ✅ Implement retry interceptor untuk 5xx errors
- ✅ Use optimistic updates untuk instant UX
- ✅ Always check connectivity sebelum API call
- ✅ Implement pull-to-refresh + pagination combo
- ✅ Use shimmer loading skeletons

### ❌ Avoid This
- ❌ Hardcode API URLs — gunakan AppConfig
- ❌ Skip error handling
- ❌ Load semua data sekaligus — gunakan pagination
- ❌ Skip connectivity check
- ❌ Use CircularProgressIndicator untuk initial load


## Next Steps

Setelah backend integration selesai:
1. Add Firebase integration (auth, firestore, storage)
2. Add Supabase integration (alternative backend)
3. Implement comprehensive testing
4. Setup CI/CD pipeline

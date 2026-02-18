# Workflow: Backend Integration (REST API)

## Overview

Implementasi repository pattern dengan REST API menggunakan Dio. Workflow ini mencakup setup Dio dengan interceptors, error handling, offline-first strategy, dan pagination.

## Output Location

**Base Folder:** `sdlc/flutter-riverpod/03-backend-integration/`

**Output Files:**
- `dio-setup.md` - Konfigurasi Dio lengkap
- `interceptors/` - Auth, retry, logging, error interceptors
- `error-handling.md` - Error mapper dan handling strategy
- `repository-pattern.md` - Repository implementation dengan offline-first
- `pagination.md` - Infinite scroll implementation
- `examples/` - Contoh API integration lengkap

## Prerequisites

- Project setup dari `01_project_setup.md` selesai
- API endpoint tersedia
- API documentation (Swagger/OpenAPI)

## Deliverables

### 1. Dio Configuration & Interceptors

**Description:** Setup Dio dengan interceptors lengkap (auth, retry, logging, error handling).

**Recommended Skills:** `senior-flutter-developer`

**Instructions:**
1. **Dio Base Configuration:**
   - Base URL configuration
   - Timeout settings (15s for API calls)
   - Headers default

2. **Auth Interceptor:**
   - Attach token ke setiap request
   - Refresh token jika expired
   - Handle 401 Unauthorized

3. **Retry Interceptor:**
   - Retry untuk 5xx errors (max 3x)
   - Exponential backoff
   - Network timeout retry

4. **Logging Interceptor:**
   - Request/response logging (dev only)
   - Curl command generation
   - Performance tracking

5. **Error Interceptor:**
   - Centralized error handling
   - Error mapping ke AppException

**Output Format:**
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

// core/network/interceptors/auth_interceptor.dart
class AuthInterceptor extends Interceptor {
  final Ref _ref;
  
  AuthInterceptor({required Ref ref}) : _ref = ref;
  
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await _ref.read(secureStorageProvider).read('access_token');
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }
  
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      // Try refresh token
      final refreshed = await _refreshToken();
      if (refreshed) {
        // Retry original request
        final token = await _ref.read(secureStorageProvider).read('access_token');
        err.requestOptions.headers['Authorization'] = 'Bearer $token';
        final response = await _ref.read(dioProvider).fetch(err.requestOptions);
        handler.resolve(response);
        return;
      }
    }
    handler.next(err);
  }
  
  Future<bool> _refreshToken() async {
    try {
      final refreshToken = await _ref.read(secureStorageProvider).read('refresh_token');
      if (refreshToken == null) return false;
      
      final response = await _ref.read(dioProvider).post('/auth/refresh', data: {
        'refresh_token': refreshToken,
      });
      
      await _ref.read(secureStorageProvider).write('access_token', response.data['access_token']);
      return true;
    } catch (e) {
      return false;
    }
  }
}

// core/network/interceptors/retry_interceptor.dart
class RetryInterceptor extends Interceptor {
  final Dio _dio;
  final int maxRetries = 3;
  
  RetryInterceptor({required Dio dio}) : _dio = dio;
  
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (_shouldRetry(err) && err.requestOptions.extra['retry_count'] != maxRetries) {
      final retryCount = (err.requestOptions.extra['retry_count'] ?? 0) + 1;
      err.requestOptions.extra['retry_count'] = retryCount;
      
      // Exponential backoff
      await Future.delayed(Duration(seconds: retryCount));
      
      try {
        final response = await _dio.fetch(err.requestOptions);
        handler.resolve(response);
        return;
      } catch (e) {
        // Continue to next error handler
      }
    }
    handler.next(err);
  }
  
  bool _shouldRetry(DioException err) {
    return err.type == DioExceptionType.connectionTimeout ||
           err.type == DioExceptionType.receiveTimeout ||
           (err.response?.statusCode != null && err.response!.statusCode! >= 500);
  }
}
```

---

### 2. Error Handling & Mapping

**Description:** Centralized error mapper dari DioException ke AppException.

**Recommended Skills:** `senior-flutter-developer`

**Instructions:**
1. Buat error mapper yang mengkonversi DioException ke AppException
2. Handle berbagai error types:
   - Connection timeout
   - Receive timeout
   - 4xx client errors
   - 5xx server errors
   - Network errors
3. Provide user-friendly error messages

**Output Format:**
```dart
// core/network/error_mapper.dart
class ErrorMapper {
  static AppException map(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
        return TimeoutException('Request timeout. Please try again.');
        
      case DioExceptionType.connectionError:
        return NetworkException('No internet connection. Please check your network.');
        
      case DioExceptionType.badResponse:
        return _mapStatusCode(error.response);
        
      case DioExceptionType.cancel:
        return CancelException('Request was cancelled.');
        
      default:
        return UnknownException('Something went wrong. Please try again.');
    }
  }
  
  static AppException _mapStatusCode(Response? response) {
    final statusCode = response?.statusCode;
    final data = response?.data;
    
    switch (statusCode) {
      case 400:
        return BadRequestException(data?['message'] ?? 'Bad request');
      case 401:
        return UnauthorizedException('Session expired. Please login again.');
      case 403:
        return ForbiddenException('You do not have permission to access this resource.');
      case 404:
        return NotFoundException('Resource not found.');
      case 409:
        return ConflictException(data?['message'] ?? 'Conflict occurred.');
      case 422:
        return ValidationException(
          data?['message'] ?? 'Validation failed',
          errors: data?['errors'],
        );
      case 500:
      case 502:
      case 503:
      case 504:
        return ServerException('Server error. Please try again later.');
      default:
        return UnknownException('An unexpected error occurred.');
    }
  }
}

// core/error/exceptions.dart (update)
class AppException implements Exception {
  final String message;
  final String? code;
  final Map<String, dynamic>? data;
  
  AppException(this.message, {this.code, this.data});
  
  @override
  String toString() => message;
}

class TimeoutException extends AppException {
  TimeoutException(super.message);
}

class NetworkException extends AppException {
  NetworkException(super.message);
}

class UnauthorizedException extends AppException {
  UnauthorizedException(super.message);
}

class ValidationException extends AppException {
  final Map<String, dynamic>? errors;
  ValidationException(super.message, {this.errors});
}

class ServerException extends AppException {
  ServerException(super.message);
}
```

---

### 3. Repository Pattern dengan Offline-First

**Description:** Repository implementation dengan strategy: return local first, sync in background.

**Recommended Skills:** `senior-flutter-developer`

**Instructions:**
1. Implement repository dengan offline-first strategy:
   - Return data dari local cache dulu
   - Fetch dari remote di background
   - Update cache dengan data terbaru
   - Handle network errors gracefully

2. Setup sync mechanism:
   - Queue untuk pending operations
   - Retry strategy untuk failed syncs
   - Conflict resolution

**Output Format:**
```dart
// features/product/data/repositories/product_repository_impl.dart
class ProductRepositoryImpl implements ProductRepository {
  final ProductRemoteDataSource remoteDataSource;
  final ProductLocalDataSource localDataSource;
  final NetworkInfo networkInfo;
  
  ProductRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });
  
  @override
  Future<Either<Failure, List<Product>>> getProducts() async {
    try {
      // Return local data first
      final localProducts = await localDataSource.getProducts();
      
      // Sync in background if online
      if (await networkInfo.isConnected) {
        _syncProductsInBackground();
      }
      
      return Right(localProducts.map((m) => m.toEntity()).toList());
    } on CacheException {
      // No local data, try remote
      if (await networkInfo.isConnected) {
        return _fetchFromRemote();
      }
      return const Left(CacheFailure('No cached data available'));
    }
  }
  
  Future<Either<Failure, List<Product>>> _fetchFromRemote() async {
    try {
      final remoteProducts = await remoteDataSource.getProducts();
      
      // Cache the data
      await localDataSource.cacheProducts(remoteProducts);
      
      return Right(remoteProducts.map((m) => m.toEntity()).toList());
    } on DioException catch (e) {
      return Left(ServerFailure(ErrorMapper.map(e).message));
    }
  }
  
  Future<void> _syncProductsInBackground() async {
    try {
      final remoteProducts = await remoteDataSource.getProducts();
      await localDataSource.cacheProducts(remoteProducts);
    } catch (_) {
      // Silent fail for background sync
    }
  }
  
  @override
  Future<Either<Failure, Product>> createProduct(Product product) async {
    try {
      // Optimistic update
      final model = ProductModel.fromEntity(product);
      await localDataSource.addProduct(model);
      
      if (await networkInfo.isConnected) {
        try {
          final created = await remoteDataSource.createProduct(model);
          await localDataSource.updateProduct(created);
          return Right(created.toEntity());
        } catch (e) {
          // Queue for later sync
          await localDataSource.markAsPending(model.id);
          return Right(product);
        }
      } else {
        // Queue for later sync
        await localDataSource.markAsPending(model.id);
        return Right(product);
      }
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }
  
  @override
  Stream<List<Product>> watchProducts() {
    return localDataSource.watchProducts().map(
      (models) => models.map((m) => m.toEntity()).toList(),
    );
  }
}
```

---

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

## Workflow Steps

1. **Setup Dio Client**
   - Configure base options
   - Add interceptors
   - Setup error mapper

2. **Implement Auth Flow**
   - Login/logout API
   - Token storage
   - Token refresh mechanism

3. **Create Repository Layer**
   - Implement remote data source
   - Implement local data source (cache)
   - Create repository dengan offline-first

4. **Setup Error Handling**
   - Error mapper implementation
   - User-friendly error messages
   - Retry logic

5. **Implement Features**
   - CRUD operations
   - File upload (if needed)
   - Pagination
   - Real-time updates (if needed)

6. **Add Optimistic Updates**
   - Update UI immediately
   - Handle failure rollback
   - Show success/error feedback

7. **Test Integration**
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
- [ ] Error messages user-friendly
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
- ❌ Hardcode API URLs - gunakan AppConfig
- ❌ Skip error handling
- ❌ Load semua data sekaligus - gunakan pagination
- ❌ Skip connectivity check
- ❌ Use CircularProgressIndicator untuk initial load

## Next Steps

Setelah backend integration selesai:
1. Add Firebase integration (auth, firestore, storage)
2. Add Supabase integration (alternative backend)
3. Implement comprehensive testing
4. Setup CI/CD pipeline

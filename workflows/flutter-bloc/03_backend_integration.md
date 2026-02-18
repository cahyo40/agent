# Workflow: Backend Integration (REST API) - Flutter BLoC

## Overview

Implementasi repository pattern dengan REST API menggunakan Dio dan flutter_bloc. Workflow ini mencakup setup Dio sebagai `@lazySingleton` di get_it, interceptors dengan akses service locator, error handling, offline-first strategy, dan pagination menggunakan BLoC events/state.

> **Perbedaan utama dengan Riverpod:**
> - `DioClient` di-register sebagai `@lazySingleton` di get_it, bukan Riverpod provider
> - Auth interceptor menggunakan `sl<SecureStorageService>()` (service locator), bukan `ref.read()`
> - Pagination menggunakan `PaginatedProductBloc` dengan sealed events (`LoadProducts`, `LoadNextPage`, `RefreshProducts`, `SearchProducts`)
> - State berisi pagination metadata eksplisit: `PaginatedProductState(products, hasMore, currentPage, ...)`
> - UI menggunakan `BlocBuilder` + `BlocListener` untuk error handling
> - Data layer (repository, data source, models) tetap framework-agnostic — tidak ada coupling ke BLoC maupun Riverpod

## Output Location

**Base Folder:** `sdlc/flutter-bloc/03-backend-integration/`

**Output Files:**
- `dio-setup.md` - Konfigurasi Dio lengkap dengan get_it registration
- `interceptors/` - Auth (sl-based), retry, logging, error interceptors
- `error-handling.md` - Error mapper dan AppException hierarchy
- `repository-pattern.md` - Repository implementation dengan offline-first
- `pagination.md` - BLoC-based infinite scroll implementation
- `examples/` - Contoh API integration lengkap

## Prerequisites

- Project setup dari `01_project_setup.md` selesai (termasuk get_it + injectable)
- API endpoint tersedia
- API documentation (Swagger/OpenAPI)
- Dependencies sudah di-add:
  ```yaml
  dependencies:
    dio: ^5.4.0
    get_it: ^7.6.7
    injectable: ^2.3.2
    flutter_bloc: ^8.1.4
    equatable: ^2.0.5
    dartz: ^0.10.1
    connectivity_plus: ^6.0.0
    flutter_secure_storage: ^9.0.0
    json_annotation: ^4.8.1
    freezed_annotation: ^2.4.1

  dev_dependencies:
    injectable_generator: ^2.4.1
    build_runner: ^2.4.8
    json_serializable: ^6.7.1
    freezed: ^2.4.6
  ```

## Deliverables

### 1. Dio Configuration & get_it Registration

**Description:** Setup Dio sebagai singleton di get_it dengan interceptors. Berbeda dengan Riverpod yang menggunakan `Provider`, di BLoC architecture kita memanfaatkan service locator pattern secara konsisten.

**Recommended Skills:** `senior-flutter-developer`

**Instructions:**
1. **Dio Base Configuration:**
   - Base URL dari `AppConfig` (environment-aware)
   - Timeout settings: connect 15s, receive 15s, send 15s
   - Default headers (Content-Type, Accept)

2. **get_it Registration:**
   - `DioClient` sebagai `@lazySingleton`
   - Interceptors diinject melalui constructor atau resolved dari get_it
   - `SecureStorageService` sudah ter-register dari setup sebelumnya

3. **Interceptor Ordering:**
   - AuthInterceptor → RetryInterceptor → LoggingInterceptor → ErrorInterceptor
   - Urutan penting: auth header harus di-attach sebelum retry

**Output Format:**
```dart
// core/network/dio_client.dart
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class DioClient {
  late final Dio _dio;

  DioClient({
    required AuthInterceptor authInterceptor,
    required RetryInterceptor retryInterceptor,
    required LoggingInterceptor loggingInterceptor,
    required ErrorInterceptor errorInterceptor,
  }) {
    _dio = Dio(BaseOptions(
      baseUrl: AppConfig.baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      sendTimeout: const Duration(seconds: 15),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    _dio.interceptors.addAll([
      authInterceptor,
      retryInterceptor,
      loggingInterceptor,
      errorInterceptor,
    ]);
  }

  Dio get dio => _dio;

  // Convenience methods yang wrap Dio calls
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) {
    return _dio.get<T>(
      path,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }

  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) {
    return _dio.post<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }

  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Options? options,
    CancelToken? cancelToken,
  }) {
    return _dio.put<T>(
      path,
      data: data,
      options: options,
      cancelToken: cancelToken,
    );
  }

  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Options? options,
    CancelToken? cancelToken,
  }) {
    return _dio.delete<T>(
      path,
      data: data,
      options: options,
      cancelToken: cancelToken,
    );
  }
}

// core/di/injection.dart (registration module)
@module
abstract class NetworkModule {
  // Jika tidak pakai injectable untuk DioClient langsung,
  // bisa register manual di module:
  @lazySingleton
  Dio dio(DioClient client) => client.dio;
}
```

**Catatan Penting - Perbedaan dengan Riverpod:**

| Aspek | Riverpod | BLoC + get_it |
|-------|----------|---------------|
| Registration | `Provider((ref) => DioClient(ref: ref))` | `@lazySingleton` class DioClient |
| Access di interceptor | `ref.read(provider)` | `sl<Service>()` / `GetIt.I<Service>()` |
| Lifetime | Managed by Riverpod container | Managed by get_it (app lifetime) |
| Testing | Override via `ProviderContainer` | Override via `sl.registerSingleton()` |

---

### 2. Auth Interceptor (Service Locator Based)

**Description:** Auth interceptor yang menggunakan `sl<SecureStorageService>()` untuk akses token. Ini perbedaan fundamental dengan Riverpod yang pakai `ref.read()`.

**Recommended Skills:** `senior-flutter-developer`

**Instructions:**
1. Attach access token ke setiap request header
2. Handle 401 Unauthorized → coba refresh token
3. Jika refresh berhasil, retry original request
4. Jika refresh gagal, emit logout event / clear session
5. Gunakan `sl<SecureStorageService>()` bukan `ref.read()`

**Output Format:**
```dart
// core/network/interceptors/auth_interceptor.dart
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class AuthInterceptor extends Interceptor {
  // Akses SecureStorageService via service locator — bukan ref.read()
  // Di Riverpod: _ref.read(secureStorageProvider)
  // Di BLoC:    sl<SecureStorageService>()
  final SecureStorageService _secureStorage;

  AuthInterceptor(this._secureStorage);

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Skip auth header untuk public endpoints
    if (options.extra['requiresAuth'] == false) {
      handler.next(options);
      return;
    }

    final token = await _secureStorage.read('access_token');
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode == 401) {
      // Coba refresh token
      final refreshed = await _refreshToken();
      if (refreshed) {
        // Retry original request dengan token baru
        final newToken = await _secureStorage.read('access_token');
        err.requestOptions.headers['Authorization'] = 'Bearer $newToken';

        try {
          // Buat Dio instance baru untuk retry (avoid interceptor loop)
          final retryDio = Dio(BaseOptions(
            baseUrl: err.requestOptions.baseUrl,
          ));
          final response = await retryDio.fetch(err.requestOptions);
          handler.resolve(response);
          return;
        } catch (retryError) {
          // Retry juga gagal, lanjutkan error
        }
      }

      // Refresh gagal — trigger logout
      // Di BLoC: dispatch event ke AuthBloc atau panggil service langsung
      // Di Riverpod: ref.read(authController.notifier).logout()
      await _handleSessionExpired();
    }
    handler.next(err);
  }

  Future<bool> _refreshToken() async {
    try {
      final refreshToken = await _secureStorage.read('refresh_token');
      if (refreshToken == null) return false;

      // Gunakan Dio baru tanpa interceptor (avoid infinite loop)
      final dio = Dio(BaseOptions(baseUrl: AppConfig.baseUrl));
      final response = await dio.post('/auth/refresh', data: {
        'refresh_token': refreshToken,
      });

      final newAccessToken = response.data['access_token'] as String;
      final newRefreshToken = response.data['refresh_token'] as String?;

      await _secureStorage.write('access_token', newAccessToken);
      if (newRefreshToken != null) {
        await _secureStorage.write('refresh_token', newRefreshToken);
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> _handleSessionExpired() async {
    // Clear semua stored tokens
    await _secureStorage.delete('access_token');
    await _secureStorage.delete('refresh_token');

    // Option 1: Panggil AuthBloc via get_it (jika AuthBloc di-register)
    // sl<AuthBloc>().add(const SessionExpired());

    // Option 2: Gunakan event bus / stream
    // sl<AuthEventBus>().emit(AuthEvent.sessionExpired);

    // Option 3: NavigationService untuk redirect ke login
    // sl<NavigationService>().navigateToLogin();
  }
}
```

**Catatan:** Pattern `_handleSessionExpired()` di BLoC agak berbeda. Di Riverpod kita bisa langsung `ref.read(authController.notifier).logout()`. Di BLoC, kita perlu pilih salah satu approach:
- Register `AuthBloc` di get_it dan dispatch event dari interceptor
- Gunakan event bus pattern (stream-based)
- Gunakan NavigationService untuk force redirect

---

### 3. Retry Interceptor

**Description:** Retry interceptor untuk 5xx errors dan timeout. Pattern ini framework-agnostic — sama persis dengan versi Riverpod karena tidak ada dependency ke state management.

**Recommended Skills:** `senior-flutter-developer`

**Output Format:**
```dart
// core/network/interceptors/retry_interceptor.dart
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class RetryInterceptor extends Interceptor {
  final Dio _dio;
  final int maxRetries;
  final Duration initialDelay;

  RetryInterceptor({
    required Dio dio,
    this.maxRetries = 3,
    this.initialDelay = const Duration(seconds: 1),
  }) : _dio = dio;

  // Atau jika DioClient belum ready saat construction:
  // RetryInterceptor() — dan resolve Dio saat dibutuhkan

  @override
  void onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final retryCount = (err.requestOptions.extra['retry_count'] ?? 0) as int;

    if (_shouldRetry(err) && retryCount < maxRetries) {
      err.requestOptions.extra['retry_count'] = retryCount + 1;

      // Exponential backoff: 1s, 2s, 4s
      final delay = initialDelay * (1 << retryCount);
      await Future.delayed(delay);

      try {
        final response = await _dio.fetch(err.requestOptions);
        handler.resolve(response);
        return;
      } catch (e) {
        // Retry gagal, lanjut ke error handler berikutnya
      }
    }
    handler.next(err);
  }

  bool _shouldRetry(DioException err) {
    // Retry untuk timeout dan server errors
    return err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        err.type == DioExceptionType.sendTimeout ||
        _isServerError(err.response?.statusCode);
  }

  bool _isServerError(int? statusCode) {
    return statusCode != null && statusCode >= 500 && statusCode < 600;
  }
}

// core/network/interceptors/logging_interceptor.dart
import 'dart:developer' as dev;
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (!AppConfig.isDebug) {
      handler.next(options);
      return;
    }

    dev.log('┌────────────────────────────────────────────');
    dev.log('│ REQUEST: ${options.method} ${options.uri}');
    dev.log('│ Headers: ${options.headers}');
    if (options.data != null) {
      dev.log('│ Body: ${options.data}');
    }
    if (options.queryParameters.isNotEmpty) {
      dev.log('│ Query: ${options.queryParameters}');
    }
    dev.log('├────────────────────────────────────────────');

    // Generate curl command untuk debugging
    _logCurlCommand(options);

    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (AppConfig.isDebug) {
      final duration = DateTime.now().difference(
        response.requestOptions.extra['startTime'] as DateTime? ??
            DateTime.now(),
      );
      dev.log('│ RESPONSE: ${response.statusCode} (${duration.inMilliseconds}ms)');
      dev.log('│ Data: ${response.data}');
      dev.log('└────────────────────────────────────────────');
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (AppConfig.isDebug) {
      dev.log('│ ERROR: ${err.type} - ${err.message}');
      dev.log('│ Response: ${err.response?.data}');
      dev.log('└────────────────────────────────────────────');
    }
    handler.next(err);
  }

  void _logCurlCommand(RequestOptions options) {
    final components = ['curl -X ${options.method}'];

    options.headers.forEach((key, value) {
      components.add('-H "$key: $value"');
    });

    if (options.data != null) {
      components.add("-d '${options.data}'");
    }

    components.add('"${options.uri}"');
    dev.log('│ CURL: ${components.join(' ')}');
  }
}
```

---

### 4. Error Handling & Mapping

**Description:** Centralized error mapper dari DioException ke AppException hierarchy. Layer ini 100% framework-agnostic — tidak ada perbedaan antara BLoC dan Riverpod.

**Recommended Skills:** `senior-flutter-developer`

**Instructions:**
1. Buat error mapper yang mengkonversi DioException ke AppException
2. Handle berbagai error types:
   - Connection timeout → `TimeoutException`
   - Receive timeout → `TimeoutException`
   - 400 Bad Request → `BadRequestException`
   - 401 Unauthorized → `UnauthorizedException`
   - 403 Forbidden → `ForbiddenException`
   - 404 Not Found → `NotFoundException`
   - 409 Conflict → `ConflictException`
   - 422 Validation → `ValidationException` (dengan field errors)
   - 5xx Server → `ServerException`
   - Network error → `NetworkException`
3. Setiap exception menyimpan user-friendly message

**Output Format:**
```dart
// core/error/exceptions.dart
/// Base exception class untuk semua app-level errors.
/// Framework-agnostic — digunakan di BLoC maupun Riverpod.
sealed class AppException implements Exception {
  final String message;
  final String? code;
  final Map<String, dynamic>? data;

  const AppException(this.message, {this.code, this.data});

  @override
  String toString() => 'AppException($code): $message';
}

class TimeoutException extends AppException {
  const TimeoutException([
    String message = 'Koneksi timeout. Silakan coba lagi.',
  ]) : super(message, code: 'TIMEOUT');
}

class NetworkException extends AppException {
  const NetworkException([
    String message = 'Tidak ada koneksi internet. Periksa jaringan Anda.',
  ]) : super(message, code: 'NETWORK_ERROR');
}

class UnauthorizedException extends AppException {
  const UnauthorizedException([
    String message = 'Sesi telah berakhir. Silakan login kembali.',
  ]) : super(message, code: 'UNAUTHORIZED');
}

class ForbiddenException extends AppException {
  const ForbiddenException([
    String message = 'Anda tidak memiliki akses ke resource ini.',
  ]) : super(message, code: 'FORBIDDEN');
}

class NotFoundException extends AppException {
  const NotFoundException([
    String message = 'Data tidak ditemukan.',
  ]) : super(message, code: 'NOT_FOUND');
}

class BadRequestException extends AppException {
  const BadRequestException([
    String message = 'Permintaan tidak valid.',
  ]) : super(message, code: 'BAD_REQUEST');
}

class ConflictException extends AppException {
  const ConflictException([
    String message = 'Terjadi konflik data.',
  ]) : super(message, code: 'CONFLICT');
}

class ValidationException extends AppException {
  final Map<String, List<String>>? fieldErrors;

  const ValidationException(
    super.message, {
    this.fieldErrors,
    super.code = 'VALIDATION_ERROR',
  });

  /// Ambil error message untuk field tertentu
  String? errorFor(String field) => fieldErrors?[field]?.first;
}

class ServerException extends AppException {
  const ServerException([
    String message = 'Terjadi kesalahan server. Silakan coba lagi nanti.',
  ]) : super(message, code: 'SERVER_ERROR');
}

class CancelException extends AppException {
  const CancelException([
    String message = 'Permintaan dibatalkan.',
  ]) : super(message, code: 'CANCELLED');
}

class UnknownException extends AppException {
  const UnknownException([
    String message = 'Terjadi kesalahan. Silakan coba lagi.',
  ]) : super(message, code: 'UNKNOWN');
}

// core/error/failures.dart
/// Failure classes untuk Either pattern di repository layer.
/// Juga framework-agnostic.
sealed class Failure extends Equatable {
  final String message;
  final String? code;

  const Failure(this.message, {this.code});

  @override
  List<Object?> get props => [message, code];
}

class ServerFailure extends Failure {
  const ServerFailure(super.message, {super.code});
}

class CacheFailure extends Failure {
  const CacheFailure(super.message, {super.code});
}

class NetworkFailure extends Failure {
  const NetworkFailure([
    String message = 'Tidak ada koneksi internet.',
  ]) : super(message, code: 'NETWORK');
}

class ValidationFailure extends Failure {
  final Map<String, List<String>>? fieldErrors;

  const ValidationFailure(
    super.message, {
    this.fieldErrors,
    super.code,
  });

  @override
  List<Object?> get props => [message, code, fieldErrors];
}

// core/network/error_mapper.dart
import 'package:dio/dio.dart';

/// Maps DioException ke AppException.
/// Framework-agnostic — sama di BLoC dan Riverpod.
class ErrorMapper {
  const ErrorMapper._();

  static AppException fromDioException(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
        return const TimeoutException();

      case DioExceptionType.connectionError:
        return const NetworkException();

      case DioExceptionType.badResponse:
        return _mapStatusCode(error.response);

      case DioExceptionType.cancel:
        return const CancelException();

      case DioExceptionType.badCertificate:
        return const ServerException('Sertifikat SSL tidak valid.');

      case DioExceptionType.unknown:
      default:
        if (error.error is SocketException) {
          return const NetworkException();
        }
        return const UnknownException();
    }
  }

  static AppException _mapStatusCode(Response? response) {
    final statusCode = response?.statusCode;
    final data = response?.data as Map<String, dynamic>?;
    final serverMessage = data?['message'] as String?;

    switch (statusCode) {
      case 400:
        return BadRequestException(serverMessage ?? 'Permintaan tidak valid.');
      case 401:
        return const UnauthorizedException();
      case 403:
        return const ForbiddenException();
      case 404:
        return NotFoundException(serverMessage ?? 'Data tidak ditemukan.');
      case 409:
        return ConflictException(serverMessage ?? 'Terjadi konflik data.');
      case 422:
        return ValidationException(
          serverMessage ?? 'Validasi gagal.',
          fieldErrors: _parseFieldErrors(data?['errors']),
        );
      case 429:
        return const ServerException('Terlalu banyak permintaan. Coba lagi nanti.');
      case 500:
      case 502:
      case 503:
      case 504:
        return const ServerException();
      default:
        return const UnknownException();
    }
  }

  static Map<String, List<String>>? _parseFieldErrors(dynamic errors) {
    if (errors == null) return null;
    if (errors is! Map<String, dynamic>) return null;

    return errors.map((key, value) {
      if (value is List) {
        return MapEntry(key, value.cast<String>());
      }
      return MapEntry(key, [value.toString()]);
    });
  }

  /// Convert AppException ke Failure untuk repository layer
  static Failure toFailure(AppException exception) {
    return switch (exception) {
      NetworkException() => const NetworkFailure(),
      ValidationException(:final fieldErrors, :final message) =>
        ValidationFailure(message, fieldErrors: fieldErrors),
      _ => ServerFailure(exception.message, code: exception.code),
    };
  }
}

// core/network/interceptors/error_interceptor.dart
@lazySingleton
class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // Map ke AppException dan re-throw sebagai DioException
    // dengan error field berisi AppException
    final appException = ErrorMapper.fromDioException(err);

    handler.next(DioException(
      requestOptions: err.requestOptions,
      response: err.response,
      type: err.type,
      error: appException, // Simpan AppException di error field
    ));
  }
}
```

---

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

## get_it Registration Summary

Semua dependency di-register di get_it. Berikut ringkasan registration yang terkait backend integration:

```dart
// core/di/injection.dart
// Jika pakai injectable, cukup annotate class dengan @lazySingleton/@injectable.
// Jika manual registration:

final sl = GetIt.instance;

Future<void> initDependencies() async {
  // ─── Network ───────────────────────────────────────────
  sl.registerLazySingleton<SecureStorageService>(
    () => SecureStorageServiceImpl(),
  );
  sl.registerLazySingleton<NetworkInfo>(
    () => NetworkInfoImpl(Connectivity()),
  );

  // Interceptors
  sl.registerLazySingleton<AuthInterceptor>(
    () => AuthInterceptor(sl<SecureStorageService>()),
  );
  sl.registerLazySingleton<RetryInterceptor>(
    () => RetryInterceptor(dio: sl<DioClient>().dio),
  );
  sl.registerLazySingleton<LoggingInterceptor>(
    () => LoggingInterceptor(),
  );
  sl.registerLazySingleton<ErrorInterceptor>(
    () => ErrorInterceptor(),
  );

  // Dio Client
  sl.registerLazySingleton<DioClient>(
    () => DioClient(
      authInterceptor: sl(),
      retryInterceptor: sl(),
      loggingInterceptor: sl(),
      errorInterceptor: sl(),
    ),
  );

  // ─── Data Sources ──────────────────────────────────────
  sl.registerLazySingleton<ProductRemoteDataSource>(
    () => ProductRemoteDataSourceImpl(sl<DioClient>()),
  );
  sl.registerLazySingleton<ProductLocalDataSource>(
    () => ProductLocalDataSourceImpl(sl<DatabaseHelper>()),
  );

  // ─── Repositories ─────────────────────────────────────
  sl.registerLazySingleton<ProductRepository>(
    () => ProductRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  // ─── Use Cases ─────────────────────────────────────────
  sl.registerLazySingleton(() => GetProducts(sl()));

  // ─── BLoCs ─────────────────────────────────────────────
  // BLoC biasanya factory, bukan singleton (per-screen lifecycle)
  sl.registerFactory(
    () => PaginatedProductBloc(getProducts: sl()),
  );
}
```

**Perbedaan registration BLoC vs Riverpod:**

| Aspek | Riverpod | BLoC + get_it |
|-------|----------|---------------|
| Controller/BLoC | `@riverpod class ... extends _$...` | `sl.registerFactory(() => Bloc(...))` |
| Repository | `Provider((ref) => Impl(ref.watch(...)))` | `sl.registerLazySingleton(() => Impl(sl()))` |
| Lifecycle | Auto-dispose by Riverpod | Factory = baru tiap resolve, Singleton = app lifetime |
| Access di widget | `ref.watch(provider)` | `context.read<Bloc>()` via BlocProvider |

---

## Workflow Steps

1. **Setup Dio Client**
   - Configure base options, timeout, default headers
   - Register sebagai `@lazySingleton` di get_it
   - Add interceptors (auth, retry, logging, error)

2. **Implement Auth Flow**
   - Login/logout API via AuthRemoteDataSource
   - Token storage di SecureStorageService
   - Auth interceptor attach token otomatis
   - Token refresh mechanism (401 handling)

3. **Create Repository Layer**
   - Implement remote data source (Dio calls)
   - Implement local data source (SQLite/Hive cache)
   - Create repository dengan offline-first strategy
   - Register semua di get_it

4. **Setup Error Handling**
   - ErrorMapper: DioException → AppException
   - AppException → Failure (untuk Either pattern)
   - User-friendly error messages (bahasa Indonesia)
   - ErrorInterceptor sebagai last-resort handler

5. **Implement Pagination BLoC**
   - Sealed events: Load, LoadNextPage, Refresh, Search
   - Single state class dengan status enum
   - Debounce transformer untuk search
   - Guard duplicate loads

6. **Build UI Layer**
   - BlocProvider di router/widget tree
   - BlocBuilder untuk render berdasarkan state
   - BlocListener untuk side effects (snackbar, navigation)
   - ScrollController untuk infinite scroll detection
   - Pull-to-refresh dengan RefreshIndicator

7. **Add Optimistic Updates**
   - Update local cache dulu (instant UX)
   - Sync ke remote di background
   - Queue pending operations kalau offline
   - Rollback jika remote gagal (optional)

8. **Test Integration**
   - Unit test BLoC dengan `bloc_test` package
   - Mock repository via get_it override
   - Test error scenarios (timeout, 401, 500)
   - Test offline behavior
   - Test pagination edge cases (empty page, last page)

## Success Criteria

- [ ] Dio configured sebagai `@lazySingleton` di get_it
- [ ] Auth interceptor menggunakan `sl<SecureStorageService>()`
- [ ] Auth token auto-refresh berfungsi (401 → refresh → retry)
- [ ] Error mapping DioException → AppException → Failure berfungsi
- [ ] Repository dengan offline-first strategy implemented
- [ ] PaginatedProductBloc handle LoadProducts, LoadNextPage, RefreshProducts, SearchProducts
- [ ] Search dengan debounce 300ms
- [ ] Infinite scroll dengan ScrollController berfungsi
- [ ] BlocListener menampilkan error snackbar
- [ ] Retry mechanism untuk 5xx errors (max 3x, exponential backoff)
- [ ] Timeout configured: connect 15s, receive 15s, send 15s
- [ ] Error messages user-friendly (bahasa Indonesia)
- [ ] BLoC testable dengan `bloc_test`

## Best Practices

### Do This
- Set API timeout ke 15s (bukan 30s default Dio)
- Register BLoC sebagai `factory` di get_it (bukan singleton) — setiap screen instance dapat BLoC baru
- Register repository/data source sebagai `lazySingleton` — shared across app
- Implement cache-first strategy untuk data yang jarang berubah
- Use debounce (300ms) untuk search input events
- Implement retry interceptor untuk 5xx errors (max 3x)
- Use optimistic updates untuk create/update/delete (instant UX)
- Always check connectivity sebelum API call di repository
- Implement pull-to-refresh + pagination combo
- Use shimmer loading skeletons untuk initial load (bukan CircularProgressIndicator)
- Gunakan `buildWhen` di `BlocBuilder` untuk optimize rebuild

### Avoid This
- Jangan hardcode API URLs — gunakan `AppConfig` dengan environment
- Jangan skip error handling di interceptor chain
- Jangan load semua data sekaligus — gunakan pagination (20 items/page)
- Jangan skip connectivity check di repository
- Jangan pakai `CircularProgressIndicator` untuk initial load — pakai shimmer
- Jangan register BLoC sebagai singleton kecuali benar-benar global (misal AuthBloc)
- Jangan akses BLoC langsung dari interceptor — gunakan service locator atau event bus
- Jangan lupa `dispose` ScrollController dan TextEditingController
- Jangan panggil `context.read<Bloc>()` di dalam `build` method — panggil di callback atau initState

## Testing Strategy

```dart
// test/features/product/presentation/bloc/paginated_product_bloc_test.dart
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockGetProducts extends Mock implements GetProducts {}

void main() {
  late PaginatedProductBloc bloc;
  late MockGetProducts mockGetProducts;

  setUp(() {
    mockGetProducts = MockGetProducts();
    bloc = PaginatedProductBloc(getProducts: mockGetProducts);
  });

  tearDown(() => bloc.close());

  group('LoadProducts', () {
    final tProducts = [
      const Product(id: '1', name: 'Product 1', price: 100),
      const Product(id: '2', name: 'Product 2', price: 200),
    ];

    blocTest<PaginatedProductBloc, PaginatedProductState>(
      'emits [loading, loaded] when LoadProducts succeeds',
      build: () {
        when(() => mockGetProducts(any()))
            .thenAnswer((_) async => Right(tProducts));
        return bloc;
      },
      act: (bloc) => bloc.add(const LoadProducts()),
      expect: () => [
        const PaginatedProductState(status: ProductStatus.loading),
        PaginatedProductState(
          status: ProductStatus.loaded,
          products: tProducts,
          currentPage: 1,
          hasMore: false, // < 20 items
        ),
      ],
    );

    blocTest<PaginatedProductBloc, PaginatedProductState>(
      'emits [loading, error] when LoadProducts fails',
      build: () {
        when(() => mockGetProducts(any()))
            .thenAnswer((_) async => const Left(ServerFailure('Server error')));
        return bloc;
      },
      act: (bloc) => bloc.add(const LoadProducts()),
      expect: () => [
        const PaginatedProductState(status: ProductStatus.loading),
        const PaginatedProductState(
          status: ProductStatus.error,
          errorMessage: 'Server error',
        ),
      ],
    );
  });

  group('LoadNextPage', () {
    blocTest<PaginatedProductBloc, PaginatedProductState>(
      'does not emit when hasMore is false',
      build: () => bloc,
      seed: () => const PaginatedProductState(
        status: ProductStatus.loaded,
        hasMore: false,
      ),
      act: (bloc) => bloc.add(const LoadNextPage()),
      expect: () => [],
    );

    blocTest<PaginatedProductBloc, PaginatedProductState>(
      'appends new products when LoadNextPage succeeds',
      build: () {
        when(() => mockGetProducts(any()))
            .thenAnswer((_) async => Right([
                  const Product(id: '3', name: 'Product 3', price: 300),
                ]));
        return bloc;
      },
      seed: () => const PaginatedProductState(
        status: ProductStatus.loaded,
        products: [Product(id: '1', name: 'Product 1', price: 100)],
        currentPage: 1,
        hasMore: true,
      ),
      act: (bloc) => bloc.add(const LoadNextPage()),
      expect: () => [
        // loadingMore
        isA<PaginatedProductState>()
            .having((s) => s.status, 'status', ProductStatus.loadingMore),
        // loaded with appended products
        isA<PaginatedProductState>()
            .having((s) => s.products.length, 'count', 2)
            .having((s) => s.currentPage, 'page', 2),
      ],
    );
  });

  group('SearchProducts', () {
    blocTest<PaginatedProductBloc, PaginatedProductState>(
      'emits loading then loaded with search results',
      build: () {
        when(() => mockGetProducts(any()))
            .thenAnswer((_) async => Right([
                  const Product(id: '1', name: 'Widget', price: 100),
                ]));
        return bloc;
      },
      act: (bloc) => bloc.add(const SearchProducts('widget')),
      wait: const Duration(milliseconds: 350), // Wait for debounce
      expect: () => [
        isA<PaginatedProductState>()
            .having((s) => s.searchQuery, 'query', 'widget')
            .having((s) => s.status, 'status', ProductStatus.loading),
        isA<PaginatedProductState>()
            .having((s) => s.status, 'status', ProductStatus.loaded)
            .having((s) => s.products.length, 'count', 1),
      ],
    );
  });
}
```

## Next Steps

Setelah backend integration selesai:
1. Tambahkan WebSocket/SSE untuk real-time updates (jika diperlukan)
2. Implement file upload dengan progress tracking
3. Setup comprehensive testing (unit, widget, integration)
4. Setup CI/CD pipeline
5. Implement background sync service untuk pending operations

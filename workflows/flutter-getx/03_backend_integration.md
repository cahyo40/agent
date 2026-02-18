# Workflow: Backend Integration (REST API) - GetX

## Overview

Implementasi repository pattern dengan REST API menggunakan Dio. Workflow ini mencakup setup Dio dengan interceptors, error handling, offline-first strategy, dan pagination. Semua dependency di-manage melalui `GetxService` dan `Get.put()` / `Get.find()` — bukan Riverpod provider.

## Output Location

**Base Folder:** `sdlc/flutter-getx/03-backend-integration/`

Struktur output:

```
sdlc/flutter-getx/03-backend-integration/
  dio_client.dart
  interceptors/
    auth_interceptor.dart
    retry_interceptor.dart
    logging_interceptor.dart
    error_interceptor.dart
  error/
    app_exception.dart
    error_mapper.dart
  models/
    api_response.dart
    paginated_response.dart
  repositories/
    base_repository.dart
    product_repository.dart
  controllers/
    paginated_controller.dart
  views/
    product_list_view.dart
  bindings/
    network_binding.dart
```

## Prerequisites

- Project setup dari `01_project_setup.md` selesai
- API endpoint tersedia (base URL, auth endpoint, data endpoint)
- Package dependencies sudah ditambahkan:

```yaml
# pubspec.yaml
dependencies:
  get: ^4.6.6
  dio: ^5.4.0
  connectivity_plus: ^6.0.0
  hive_flutter: ^1.1.0
  pretty_dio_logger: ^1.4.0
```

---

## Deliverables

### 1. Dio Configuration & Interceptors

#### 1.1 DioClient sebagai GetxService

`DioClient` di-register sebagai `GetxService` supaya lifecycle-nya mengikuti aplikasi. Tidak perlu dispose manual — `GetxService` persist selama app hidup.

**File:** `lib/core/network/dio_client.dart`

```dart
import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:myapp/core/config/app_config.dart';
import 'package:myapp/core/network/interceptors/auth_interceptor.dart';
import 'package:myapp/core/network/interceptors/retry_interceptor.dart';
import 'package:myapp/core/network/interceptors/logging_interceptor.dart';
import 'package:myapp/core/network/interceptors/error_interceptor.dart';

class DioClient extends GetxService {
  late final Dio _dio;

  Dio get dio => _dio;

  DioClient() {
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
      AuthInterceptor(),
      RetryInterceptor(dio: _dio),
      LoggingInterceptor(),
      ErrorInterceptor(),
    ]);
  }

  // === GET ===
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    return _dio.get<T>(
      path,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }

  // === POST ===
  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    return _dio.post<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }

  // === PUT ===
  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    return _dio.put<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }

  // === PATCH ===
  Future<Response<T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    return _dio.patch<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }

  // === DELETE ===
  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    return _dio.delete<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }

  // === UPLOAD (multipart) ===
  Future<Response<T>> upload<T>(
    String path, {
    required FormData formData,
    Options? options,
    CancelToken? cancelToken,
    void Function(int, int)? onSendProgress,
  }) async {
    return _dio.post<T>(
      path,
      data: formData,
      options: options ?? Options(contentType: 'multipart/form-data'),
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
    );
  }
}
```

#### 1.2 Network Binding — Registrasi DioClient

Semua network dependency di-register lewat binding. Binding ini dipanggil di `main.dart` sebelum `runApp()`.

**File:** `lib/core/bindings/network_binding.dart`

```dart
import 'package:get/get.dart';
import 'package:myapp/core/network/dio_client.dart';
import 'package:myapp/core/network/network_info.dart';
import 'package:myapp/core/storage/storage_service.dart';

class NetworkBinding extends Bindings {
  @override
  void dependencies() {
    // StorageService harus sudah di-init sebelumnya (di InitialBinding)
    // DioClient sebagai permanent service
    Get.put<DioClient>(DioClient(), permanent: true);

    // NetworkInfo untuk cek konektivitas
    Get.put<NetworkInfo>(NetworkInfo(), permanent: true);
  }
}
```

**File:** `lib/core/bindings/initial_binding.dart`

```dart
import 'package:get/get.dart';
import 'package:myapp/core/storage/storage_service.dart';
import 'package:myapp/core/network/dio_client.dart';
import 'package:myapp/core/network/network_info.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    // === Storage (harus pertama) ===
    Get.put<StorageService>(StorageService(), permanent: true);

    // === Network ===
    Get.put<NetworkInfo>(NetworkInfo(), permanent: true);
    Get.put<DioClient>(DioClient(), permanent: true);
  }
}
```

**File:** `lib/main.dart` (partial)

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Init storage sebelum binding
  await Get.putAsync<StorageService>(() => StorageService().init());

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      initialBinding: InitialBinding(),
      // ...
    );
  }
}
```

#### 1.3 AuthInterceptor — Menggunakan `Get.find<StorageService>()`

Perbedaan utama dengan Riverpod: interceptor mengakses token via `Get.find()` bukan `ref.read()`.

**File:** `lib/core/network/interceptors/auth_interceptor.dart`

```dart
import 'package:dio/dio.dart';
import 'package:get/get.dart' hide Response, FormData, MultipartFile;
import 'package:myapp/core/storage/storage_service.dart';

class AuthInterceptor extends Interceptor {
  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) {
    // Skip auth untuk endpoint publik
    if (_isPublicEndpoint(options.path)) {
      return handler.next(options);
    }

    // Ambil token dari StorageService via Get.find()
    // Ini yang membedakan dari Riverpod (ref.read)
    final storage = Get.find<StorageService>();
    final token = storage.getAccessToken();

    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      // Coba refresh token
      final refreshed = await _tryRefreshToken();

      if (refreshed) {
        // Retry request dengan token baru
        final storage = Get.find<StorageService>();
        final newToken = storage.getAccessToken();

        err.requestOptions.headers['Authorization'] = 'Bearer $newToken';

        try {
          final response = await Dio().fetch(err.requestOptions);
          return handler.resolve(response);
        } catch (e) {
          return handler.next(err);
        }
      } else {
        // Refresh gagal, redirect ke login
        _handleSessionExpired();
      }
    }

    handler.next(err);
  }

  bool _isPublicEndpoint(String path) {
    const publicPaths = [
      '/auth/login',
      '/auth/register',
      '/auth/forgot-password',
      '/public/',
    ];
    return publicPaths.any((p) => path.contains(p));
  }

  Future<bool> _tryRefreshToken() async {
    try {
      final storage = Get.find<StorageService>();
      final refreshToken = storage.getRefreshToken();

      if (refreshToken == null) return false;

      // Gunakan Dio baru (tanpa interceptor) untuk refresh
      final dio = Dio(BaseOptions(
        baseUrl: AppConfig.baseUrl,
        headers: {'Content-Type': 'application/json'},
      ));

      final response = await dio.post(
        '/auth/refresh',
        data: {'refresh_token': refreshToken},
      );

      if (response.statusCode == 200) {
        final newAccessToken = response.data['access_token'] as String;
        final newRefreshToken = response.data['refresh_token'] as String;

        await storage.saveTokens(
          accessToken: newAccessToken,
          refreshToken: newRefreshToken,
        );

        return true;
      }

      return false;
    } catch (e) {
      return false;
    }
  }

  void _handleSessionExpired() {
    final storage = Get.find<StorageService>();
    storage.clearTokens();

    // Navigasi ke login menggunakan GetX
    Get.offAllNamed('/login');
    Get.snackbar(
      'Sesi Berakhir',
      'Silakan login kembali.',
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}
```

#### 1.4 RetryInterceptor

Implementasi retry logic — framework-agnostic, sama dengan versi Riverpod.

**File:** `lib/core/network/interceptors/retry_interceptor.dart`

```dart
import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';

class RetryInterceptor extends Interceptor {
  final Dio dio;
  final int maxRetries;
  final Duration retryDelay;

  RetryInterceptor({
    required this.dio,
    this.maxRetries = 3,
    this.retryDelay = const Duration(seconds: 1),
  });

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (_shouldRetry(err)) {
      final retryCount = err.requestOptions.extra['retryCount'] ?? 0;

      if (retryCount < maxRetries) {
        err.requestOptions.extra['retryCount'] = retryCount + 1;

        // Exponential backoff: 1s, 2s, 4s
        final delay = retryDelay * (1 << retryCount);
        await Future.delayed(delay);

        try {
          final response = await dio.fetch(err.requestOptions);
          return handler.resolve(response);
        } catch (e) {
          // Biarkan error lanjut ke handler berikutnya
        }
      }
    }

    handler.next(err);
  }

  bool _shouldRetry(DioException err) {
    // Retry hanya untuk network error dan timeout
    return err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.sendTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        err.type == DioExceptionType.connectionError ||
        (err.error is SocketException);
  }
}
```

#### 1.5 LoggingInterceptor

**File:** `lib/core/network/interceptors/logging_interceptor.dart`

```dart
import 'dart:developer' as dev;
import 'package:dio/dio.dart';
import 'package:myapp/core/config/app_config.dart';

class LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (AppConfig.enableLogging) {
      dev.log(
        '[REQ] ${options.method} ${options.uri}',
        name: 'DioClient',
      );
      if (options.data != null) {
        dev.log('[REQ BODY] ${options.data}', name: 'DioClient');
      }
      if (options.queryParameters.isNotEmpty) {
        dev.log('[REQ QUERY] ${options.queryParameters}', name: 'DioClient');
      }
    }
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (AppConfig.enableLogging) {
      dev.log(
        '[RES] ${response.statusCode} ${response.requestOptions.uri}',
        name: 'DioClient',
      );
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (AppConfig.enableLogging) {
      dev.log(
        '[ERR] ${err.response?.statusCode ?? 'UNKNOWN'} '
        '${err.requestOptions.uri} - ${err.message}',
        name: 'DioClient',
        error: err.error,
      );
    }
    handler.next(err);
  }
}
```

#### 1.6 ErrorInterceptor

**File:** `lib/core/network/interceptors/error_interceptor.dart`

```dart
import 'package:dio/dio.dart';
import 'package:myapp/core/error/app_exception.dart';
import 'package:myapp/core/error/error_mapper.dart';

class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // Map DioException ke AppException
    final appException = ErrorMapper.fromDioException(err);

    handler.next(
      DioException(
        requestOptions: err.requestOptions,
        response: err.response,
        type: err.type,
        error: appException,
        message: appException.message,
      ),
    );
  }
}
```

---

### 2. Error Handling & Mapping

Bagian ini framework-agnostic — sama dengan versi Riverpod. Tidak ada dependency ke GetX maupun Riverpod.

#### 2.1 AppException Classes

**File:** `lib/core/error/app_exception.dart`

```dart
/// Base exception class untuk semua error di aplikasi.
sealed class AppException implements Exception {
  final String message;
  final String? code;
  final int? statusCode;
  final dynamic originalError;

  const AppException({
    required this.message,
    this.code,
    this.statusCode,
    this.originalError,
  });

  @override
  String toString() => 'AppException($code): $message';
}

/// Network-level errors (no connection, timeout, dsb.)
class NetworkException extends AppException {
  const NetworkException({
    required super.message,
    super.code = 'NETWORK_ERROR',
    super.statusCode,
    super.originalError,
  });
}

/// Server mengembalikan error response (4xx, 5xx)
class ServerException extends AppException {
  final Map<String, dynamic>? errors;

  const ServerException({
    required super.message,
    super.code = 'SERVER_ERROR',
    super.statusCode,
    super.originalError,
    this.errors,
  });
}

/// Authentication errors (401, 403)
class AuthException extends AppException {
  const AuthException({
    required super.message,
    super.code = 'AUTH_ERROR',
    super.statusCode,
    super.originalError,
  });
}

/// Validation errors dari server (422)
class ValidationException extends AppException {
  final Map<String, List<String>> fieldErrors;

  const ValidationException({
    required super.message,
    super.code = 'VALIDATION_ERROR',
    super.statusCode = 422,
    super.originalError,
    this.fieldErrors = const {},
  });
}

/// Error saat parsing response
class ParseException extends AppException {
  const ParseException({
    required super.message,
    super.code = 'PARSE_ERROR',
    super.originalError,
  });
}

/// Request dibatalkan oleh user
class CancelledException extends AppException {
  const CancelledException({
    super.message = 'Request dibatalkan.',
    super.code = 'CANCELLED',
  });
}

/// Cache/local storage error
class CacheException extends AppException {
  const CacheException({
    required super.message,
    super.code = 'CACHE_ERROR',
    super.originalError,
  });
}
```

#### 2.2 ErrorMapper

**File:** `lib/core/error/error_mapper.dart`

```dart
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:myapp/core/error/app_exception.dart';

class ErrorMapper {
  /// Map DioException ke AppException yang lebih deskriptif.
  static AppException fromDioException(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return NetworkException(
          message: 'Koneksi timeout. Periksa jaringan Anda.',
          statusCode: error.response?.statusCode,
          originalError: error,
        );

      case DioExceptionType.connectionError:
        return const NetworkException(
          message: 'Tidak dapat terhubung ke server. Periksa koneksi internet.',
        );

      case DioExceptionType.cancel:
        return const CancelledException();

      case DioExceptionType.badResponse:
        return _mapStatusCode(error);

      case DioExceptionType.badCertificate:
        return NetworkException(
          message: 'Sertifikat SSL tidak valid.',
          originalError: error,
        );

      case DioExceptionType.unknown:
        if (error.error is SocketException) {
          return const NetworkException(
            message: 'Tidak ada koneksi internet.',
          );
        }
        return NetworkException(
          message: 'Terjadi kesalahan yang tidak diketahui.',
          originalError: error,
        );
    }
  }

  static AppException _mapStatusCode(DioException error) {
    final statusCode = error.response?.statusCode;
    final data = error.response?.data;

    // Coba extract pesan error dari response body
    final serverMessage = _extractMessage(data);

    switch (statusCode) {
      case 400:
        return ServerException(
          message: serverMessage ?? 'Permintaan tidak valid.',
          statusCode: 400,
          code: 'BAD_REQUEST',
          originalError: error,
        );

      case 401:
        return AuthException(
          message: serverMessage ?? 'Sesi telah berakhir. Silakan login ulang.',
          statusCode: 401,
          originalError: error,
        );

      case 403:
        return AuthException(
          message: serverMessage ?? 'Anda tidak memiliki akses.',
          statusCode: 403,
          code: 'FORBIDDEN',
          originalError: error,
        );

      case 404:
        return ServerException(
          message: serverMessage ?? 'Data tidak ditemukan.',
          statusCode: 404,
          code: 'NOT_FOUND',
          originalError: error,
        );

      case 409:
        return ServerException(
          message: serverMessage ?? 'Data konflik. Silakan coba lagi.',
          statusCode: 409,
          code: 'CONFLICT',
          originalError: error,
        );

      case 422:
        final fieldErrors = _extractFieldErrors(data);
        return ValidationException(
          message: serverMessage ?? 'Data yang dikirim tidak valid.',
          originalError: error,
          fieldErrors: fieldErrors,
        );

      case 429:
        return ServerException(
          message: 'Terlalu banyak permintaan. Coba lagi nanti.',
          statusCode: 429,
          code: 'RATE_LIMITED',
          originalError: error,
        );

      case 500:
      case 502:
      case 503:
        return ServerException(
          message: 'Server sedang bermasalah. Coba lagi nanti.',
          statusCode: statusCode,
          code: 'SERVER_ERROR',
          originalError: error,
        );

      default:
        return ServerException(
          message: serverMessage ?? 'Terjadi kesalahan (kode: $statusCode).',
          statusCode: statusCode,
          originalError: error,
        );
    }
  }

  /// Extract pesan error dari response body.
  /// Support berbagai format: { "message": "..." }, { "error": "..." }, dsb.
  static String? _extractMessage(dynamic data) {
    if (data == null) return null;
    if (data is String) return data;
    if (data is Map<String, dynamic>) {
      return data['message'] as String? ??
          data['error'] as String? ??
          data['msg'] as String?;
    }
    return null;
  }

  /// Extract field-level validation errors.
  /// Expected format: { "errors": { "email": ["Email tidak valid"] } }
  static Map<String, List<String>> _extractFieldErrors(dynamic data) {
    if (data is! Map<String, dynamic>) return {};

    final errors = data['errors'];
    if (errors is! Map<String, dynamic>) return {};

    return errors.map((key, value) {
      if (value is List) {
        return MapEntry(key, value.cast<String>());
      }
      if (value is String) {
        return MapEntry(key, [value]);
      }
      return MapEntry(key, <String>[]);
    });
  }
}
```

---

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

class _ErrorWidget extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorWidget({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyWidget extends StatelessWidget {
  final String searchQuery;

  const _EmptyWidget({required this.searchQuery});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            searchQuery.isNotEmpty
                ? 'Tidak ditemukan produk untuk "$searchQuery"'
                : 'Belum ada produk.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }
}

class _LoadingMoreIndicator extends StatelessWidget {
  final bool isLoading;

  const _LoadingMoreIndicator({required this.isLoading});

  @override
  Widget build(BuildContext context) {
    if (!isLoading) return const SizedBox(height: 60);
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 24),
      child: Center(child: CircularProgressIndicator()),
    );
  }
}
```

---

### 5. API Response Wrapper

Framework-agnostic — sama dengan versi Riverpod. Digunakan untuk standarisasi parsing response.

#### 5.1 ApiResponse (Single Object)

**File:** `lib/core/models/api_response.dart`

```dart
class ApiResponse<T> {
  final bool success;
  final String? message;
  final T data;
  final Map<String, dynamic>? meta;

  const ApiResponse({
    required this.success,
    this.message,
    required this.data,
    this.meta,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) {
    return ApiResponse<T>(
      success: json['success'] as bool? ?? true,
      message: json['message'] as String?,
      data: fromJsonT(json['data']),
      meta: json['meta'] as Map<String, dynamic>?,
    );
  }
}
```

#### 5.2 PaginatedResponse

**File:** `lib/core/models/paginated_response.dart`

```dart
class PaginatedResponse<T> {
  final List<T> data;
  final int currentPage;
  final int lastPage;
  final int total;
  final int perPage;

  const PaginatedResponse({
    required this.data,
    required this.currentPage,
    required this.lastPage,
    required this.total,
    required this.perPage,
  });

  bool get hasNextPage => currentPage < lastPage;

  factory PaginatedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) {
    // Support format Laravel pagination
    final rawData = json['data'] as List? ?? [];
    final meta = json['meta'] as Map<String, dynamic>?;

    return PaginatedResponse<T>(
      data: rawData.map((e) => fromJsonT(e)).toList(),
      currentPage: meta?['current_page'] as int? ??
          json['current_page'] as int? ??
          1,
      lastPage:
          meta?['last_page'] as int? ?? json['last_page'] as int? ?? 1,
      total: meta?['total'] as int? ?? json['total'] as int? ?? 0,
      perPage:
          meta?['per_page'] as int? ?? json['per_page'] as int? ?? 20,
    );
  }
}
```

#### 5.3 Product Model (Contoh)

**File:** `lib/features/product/data/models/product_model.dart`

```dart
class ProductModel {
  final String id;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final String category;
  final int stock;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ProductModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.category,
    required this.stock,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      price: (json['price'] as num).toDouble(),
      imageUrl: json['image_url'] as String? ?? '',
      category: json['category'] as String? ?? '',
      stock: json['stock'] as int? ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'image_url': imageUrl,
      'category': category,
      'stock': stock,
    };
  }

  ProductModel copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    String? imageUrl,
    String? category,
    int? stock,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ProductModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
      category: category ?? this.category,
      stock: stock ?? this.stock,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
```

---

## Workflow Steps

### Step 1: Setup Dependencies

Tambahkan package ke `pubspec.yaml`:

```bash
flutter pub add dio connectivity_plus hive_flutter pretty_dio_logger
```

### Step 2: Buat Error Classes

Buat `lib/core/error/app_exception.dart` dan `lib/core/error/error_mapper.dart` sesuai Deliverable #2.

### Step 3: Implementasi DioClient dan Interceptors

1. Buat `DioClient` extends `GetxService` (Deliverable #1.1)
2. Buat `AuthInterceptor` dengan `Get.find<StorageService>()` (Deliverable #1.3)
3. Buat `RetryInterceptor` (Deliverable #1.4)
4. Buat `LoggingInterceptor` (Deliverable #1.5)
5. Buat `ErrorInterceptor` (Deliverable #1.6)

### Step 4: Register di InitialBinding

Tambahkan `DioClient` dan `NetworkInfo` ke `InitialBinding.dependencies()` (Deliverable #1.2).

### Step 5: Buat API Response Wrappers

Buat `ApiResponse` dan `PaginatedResponse` models (Deliverable #5).

### Step 6: Implementasi Repository

1. Buat `BaseRepository` dengan `safeRequest()` helper (Deliverable #3.2)
2. Buat `ProductRepository` extends `BaseRepository` (Deliverable #3.3)
3. Buat `ProductLocalDataSource` untuk offline cache (Deliverable #3.4)

### Step 7: Implementasi Pagination Controller dan View

1. Buat `PaginatedProductController` extends `GetxController` (Deliverable #4.1)
2. Buat `ProductBinding` (Deliverable #4.2)
3. Buat `ProductListView` extends `GetView` dengan `Obx()` (Deliverable #4.3)
4. Daftarkan route dengan binding di `app_routes.dart`

---

## Success Criteria

### Functional
- [ ] DioClient ter-register sebagai `GetxService` dan bisa diakses via `Get.find<DioClient>()` dari mana saja
- [ ] AuthInterceptor otomatis menambahkan token dari `StorageService` ke setiap request
- [ ] Token refresh berjalan otomatis saat menerima 401, tanpa user interaction
- [ ] Retry mechanism aktif untuk network error dan timeout (max 3 kali, exponential backoff)
- [ ] Semua DioException ter-map ke `AppException` yang deskriptif dan user-friendly
- [ ] Repository pattern bekerja dengan offline-first strategy (cache → API → cache)
- [ ] Pagination (infinite scroll) bekerja dengan smooth scroll dan load-more indicator
- [ ] Pull-to-refresh me-reset dan fetch ulang dari page 1
- [ ] Search ter-debounce 500ms dan trigger re-fetch otomatis
- [ ] Optimistic delete bekerja dengan rollback saat API error

### Non-Functional
- [ ] Tidak ada memory leak — `ScrollController` di-dispose di `onClose()`
- [ ] Tidak ada duplikat request saat loading (guard di `loadMore()` dan `_fetchProducts()`)
- [ ] Error message ditampilkan dalam Bahasa Indonesia yang jelas
- [ ] Log request/response hanya muncul di debug mode (`AppConfig.enableLogging`)
- [ ] Cache memiliki expiry time (default 1 jam)

---

## Best Practices

### DO

- **DO** gunakan `GetxService` untuk singleton service (DioClient, NetworkInfo, StorageService)
- **DO** gunakan `GetxController` untuk state yang terikat ke halaman/feature
- **DO** gunakan `.obs` untuk reactive state dan `Obx()` untuk rebuild widget
- **DO** gunakan `Bindings` untuk dependency injection per halaman — jangan `Get.put()` langsung di widget
- **DO** gunakan `safeRequest()` wrapper di repository untuk konsistensi error handling
- **DO** dispose `ScrollController` di `onClose()` — GetX tidak auto-dispose Flutter controller
- **DO** gunakan `debounce()` dari GetX untuk search input — lebih bersih dari manual Timer
- **DO** simpan backup sebelum optimistic update/delete untuk rollback
- **DO** gunakan `Get.find()` di interceptor dan repository — service sudah ter-register permanent
- **DO** gunakan sealed class untuk `AppException` supaya compiler enforce exhaustive checking

### DON'T

- **DON'T** panggil `Get.put()` di dalam widget `build()` — gunakan Binding atau `onInit()`
- **DON'T** akses `controller` di `GetView` sebelum binding selesai — pastikan route punya binding
- **DON'T** campurkan `.obs` dengan `update()` dalam satu controller — pilih salah satu approach
- **DON'T** gunakan `GetxController` untuk service yang harus persist selamanya — gunakan `GetxService`
- **DON'T** lupa `permanent: true` saat `Get.put()` service yang harus hidup sepanjang app
- **DON'T** catch generic `Exception` di controller — catch `AppException` supaya pesan error tepat
- **DON'T** hardcode base URL di DioClient — gunakan `AppConfig` yang bisa di-switch per environment
- **DON'T** simpan token di SharedPreferences — gunakan `FlutterSecureStorage` atau encrypted Hive
- **DON'T** retry POST/PUT/DELETE request di RetryInterceptor — hanya retry GET dan idempotent request
- **DON'T** tampilkan raw error message dari server ke user — selalu map ke pesan yang user-friendly

---

## Perbandingan GetX vs Riverpod (Backend Integration)

| Aspek | GetX | Riverpod |
|-------|------|----------|
| DioClient registration | `Get.put<DioClient>(...)` | `Provider((ref) => DioClient(...))` |
| Akses di interceptor | `Get.find<StorageService>()` | `ref.read(storageProvider)` |
| Akses di repository | `Get.find<DioClient>()` | `ref.read(dioProvider)` |
| Pagination state | `RxList`, `RxBool` | `StateNotifier` / `AsyncValue` |
| Scroll listener | Manual di `GetxController.onInit()` | Manual di `ConsumerStatefulWidget` |
| View binding | `GetView<Controller>` + `Obx()` | `ConsumerWidget` + `ref.watch()` |
| DI per halaman | `Bindings` | `ProviderScope` overrides |
| Search debounce | `debounce()` built-in GetX | Manual / `Debouncer` class |

---

## Next Steps

Setelah backend integration selesai, lanjutkan ke:

- **`04_state_management.md`** — Advanced GetX state management patterns (nested controllers, workers, inter-controller communication)
- **`05_auth_flow.md`** — Complete authentication flow dengan GetX middleware dan route guards
- **`06_testing.md`** — Unit test untuk repository, controller, dan integration test

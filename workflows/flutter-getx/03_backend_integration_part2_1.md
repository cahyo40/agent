---
description: Implementasi repository pattern dengan REST API menggunakan Dio. (Sub-part 1/3)
---
# Workflow: Backend Integration (REST API) - GetX (Part 2/7)

> **Navigation:** This workflow is split into 7 parts.

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
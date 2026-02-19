---
description: Implementasi repository pattern dengan REST API menggunakan Dio dan flutter_bloc. (Part 2/8)
---
# Workflow: Backend Integration (REST API) - Flutter BLoC (Part 2/8)

> **Navigation:** This workflow is split into 8 parts.

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

## Deliverables

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


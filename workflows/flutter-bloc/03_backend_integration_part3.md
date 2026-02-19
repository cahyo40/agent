---
description: Implementasi repository pattern dengan REST API menggunakan Dio dan flutter_bloc. (Part 3/8)
---
# Workflow: Backend Integration (REST API) - Flutter BLoC (Part 3/8)

> **Navigation:** This workflow is split into 8 parts.

## Deliverables

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


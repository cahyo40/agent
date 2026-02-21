---
description: Implementasi repository pattern dengan REST API menggunakan Dio. (Sub-part 2/3)
---
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


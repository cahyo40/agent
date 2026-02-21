---
description: Implementasi repository pattern dengan REST API menggunakan Dio. (Part 3/7)
---
# Workflow: Backend Integration (REST API) - GetX (Part 3/7)

> **Navigation:** This workflow is split into 7 parts.

## Deliverables

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


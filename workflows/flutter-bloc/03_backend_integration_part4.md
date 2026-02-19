---
description: Implementasi repository pattern dengan REST API menggunakan Dio dan flutter_bloc. (Part 4/8)
---
# Workflow: Backend Integration (REST API) - Flutter BLoC (Part 4/8)

> **Navigation:** This workflow is split into 8 parts.

## Deliverables

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


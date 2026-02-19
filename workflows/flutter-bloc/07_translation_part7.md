---
description: 07 - Translation & Localization (Flutter BLoC) (Part 7/9)
---
# 07 - Translation & Localization (Flutter BLoC) (Part 7/9)

> **Navigation:** This workflow is split into 9 parts.

## 8. Usage Examples

### 8.5. Error Handling dengan Translated Messages

```dart
// lib/core/error/failure_translator.dart

import 'package:easy_localization/easy_localization.dart';

/// Menerjemahkan failure/error ke pesan yang user-friendly
/// berdasarkan bahasa aktif.
///
/// Digunakan bersama BLoC error states:
/// ```dart
/// BlocBuilder<ProductBloc, ProductState>(
///   builder: (context, state) {
///     if (state is ProductError) {
///       return ErrorView(
///         message: FailureTranslator.translate(state.failure),
///       );
///     }
///     // ...
///   },
/// )
/// ```
abstract final class FailureTranslator {
  static String translate(Object failure) {
    // Pattern match berdasarkan tipe failure
    return switch (failure) {
      NetworkFailure() => 'errors.network'.tr(),
      TimeoutFailure() => 'errors.timeout'.tr(),
      ServerFailure(:final statusCode) => _serverError(statusCode),
      UnauthorizedFailure() => 'errors.unauthorized'.tr(),
      ForbiddenFailure() => 'errors.forbidden'.tr(),
      NotFoundFailure() => 'errors.notFound'.tr(),
      CacheFailure() => 'errors.cacheError'.tr(),
      _ => 'errors.generic'.tr(),
    };
  }

  static String _serverError(int? statusCode) {
    return switch (statusCode) {
      429 => 'errors.tooManyRequests'.tr(),
      503 => 'errors.maintenance'.tr(),
      _ => 'errors.serverError'.tr(),
    };
  }
}

// Contoh failure classes (sealed)
sealed class Failure {
  const Failure();
}

class NetworkFailure extends Failure {
  const NetworkFailure();
}

class TimeoutFailure extends Failure {
  const TimeoutFailure();
}

class ServerFailure extends Failure {
  const ServerFailure({this.statusCode});
  final int? statusCode;
}

class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure();
}

class ForbiddenFailure extends Failure {
  const ForbiddenFailure();
}

class NotFoundFailure extends Failure {
  const NotFoundFailure();
}

class CacheFailure extends Failure {
  const CacheFailure();
}
```

---


---
description: Setup Flutter project dari nol dengan Clean Architecture dan BLoC state management. (Sub-part 1/2)
---
# Workflow: Flutter Project Setup with BLoC (Part 3/6)

> **Navigation:** This workflow is split into 6 parts.

## Deliverables

### 3. Core Layer Setup

**Description:** Setup core layer untuk BLoC observer, DI, routing, error handling, dan storage.

**Recommended Skills:** `senior-flutter-developer`

**Instructions:**

#### 3a. BlocObserver - Logging semua BLoC events/transitions

```dart
// lib/bootstrap/observers/app_bloc_observer.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../shared/utils/logger.dart';

class AppBlocObserver extends BlocObserver {
  @override
  void onCreate(BlocBase bloc) {
    super.onCreate(bloc);
    AppLogger.info('BLoC Created: ${bloc.runtimeType}');
  }

  @override
  void onEvent(Bloc bloc, Object? event) {
    super.onEvent(bloc, event);
    AppLogger.info('Event: ${bloc.runtimeType} -> $event');
  }

  @override
  void onTransition(Bloc bloc, Transition transition) {
    super.onTransition(bloc, transition);
    AppLogger.info(
      'Transition: ${bloc.runtimeType}\n'
      '  currentState: ${transition.currentState}\n'
      '  event: ${transition.event}\n'
      '  nextState: ${transition.nextState}',
    );
  }

  @override
  void onChange(BlocBase bloc, Change change) {
    super.onChange(bloc, change);
    AppLogger.info(
      'Change: ${bloc.runtimeType}\n'
      '  currentState: ${change.currentState}\n'
      '  nextState: ${change.nextState}',
    );
  }

  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    super.onError(bloc, error, stackTrace);
    AppLogger.error('Error: ${bloc.runtimeType}', error, stackTrace);
  }

  @override
  void onClose(BlocBase bloc) {
    super.onClose(bloc);
    AppLogger.info('BLoC Closed: ${bloc.runtimeType}');
  }
}
```

#### 3b. Bootstrap - App Initialization

```dart
// lib/bootstrap/bootstrap.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../core/di/injection.dart';
import 'observers/app_bloc_observer.dart';

Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Setup BlocObserver untuk logging
  Bloc.observer = AppBlocObserver();

  // Initialize Hive
  await Hive.initFlutter();

  // Initialize get_it dependency injection
  await configureDependencies();

  // Firebase (optional)
  // await Firebase.initializeApp(
  //   options: DefaultFirebaseOptions.currentPlatform,
  // );
}
```

#### 3c. get_it + injectable - Dependency Injection

```dart
// lib/core/di/injection.dart
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';

import 'injection.config.dart';

final getIt = GetIt.instance;

@InjectableInit(
  initializerName: 'init',
  preferRelativeImports: true,
  asExtension: true,
)
Future<void> configureDependencies() async => getIt.init();
```

```dart
// lib/core/di/register_module.dart
// Untuk register third-party dependencies yang tidak bisa di-annotate
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

@module
abstract class RegisterModule {
  @lazySingleton
  Dio get dio => Dio(
    BaseOptions(
      baseUrl: 'https://api.example.com',
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );
}
```

**Cara pakai injectable annotations:**
```dart
// Repository implementation - otomatis register ke get_it
@LazySingleton(as: ProductRepository)
class ProductRepositoryImpl implements ProductRepository {
  final ProductRemoteDataSource remoteDataSource;
  final ProductLocalDataSource localDataSource;

  ProductRepositoryImpl(this.remoteDataSource, this.localDataSource);
  // ...
}

// DataSource
@LazySingleton()
class ProductRemoteDataSource {
  final Dio dio;
  ProductRemoteDataSource(this.dio);
  // ...
}

// Bloc - register as factory (baru setiap kali)
@injectable
class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final GetProducts getProducts;
  final CreateProduct createProduct;
  final DeleteProduct deleteProduct;

  ProductBloc({
    required this.getProducts,
    required this.createProduct,
    required this.deleteProduct,
  }) : super(ProductInitial()) {
    // register event handlers
  }
}
```

**Penting:** Setelah menambah/mengubah annotations, selalu run:
```bash
dart run build_runner build --delete-conflicting-outputs
```

#### 3d. Main Entry Point & Root Widget

```dart
// lib/main.dart
import 'package:flutter/material.dart';
import 'bootstrap/bootstrap.dart';
import 'app.dart';

void main() async {
  await bootstrap();
  runApp(const MyApp());
}
```

```dart
// lib/app.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/di/injection.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/product/presentation/bloc/product_bloc.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // Global blocs yang dibutuhkan di seluruh app
        BlocProvider<AuthBloc>(
          create: (_) => getIt<AuthBloc>()..add(const CheckAuthStatus()),
        ),
        // Feature-specific blocs bisa di-provide di level route/screen
        // Contoh: ProductBloc di-provide di ProductListScreen saja
      ],
      child: MaterialApp.router(
        title: 'My App',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        routerConfig: appRouter,
      ),
    );
  }
}
```

**Catatan tentang MultiBlocProvider:**
- Hanya register **global** blocs di root (contoh: `AuthBloc`, `ThemeBloc`, `LocaleBloc`)
- Feature-specific blocs (contoh: `ProductBloc`) di-provide di level screen/route
- Ini berbeda dengan Riverpod yang semua providers otomatis available via `ProviderScope`


#### 3e. Error Handling Classes

```dart
// lib/core/error/exceptions.dart
class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic details;

  const AppException(this.message, {this.code, this.details});

  @override
  String toString() => 'AppException($code): $message';
}

class ServerException extends AppException {
  final int? statusCode;

  const ServerException({
    super.message = 'Server error occurred',
    super.code,
    this.statusCode,
  });
}

class CacheException extends AppException {
  const CacheException({super.message = 'Cache error occurred', super.code});
}

class NetworkException extends AppException {
  const NetworkException({
    super.message = 'No internet connection',
    super.code = 'NETWORK_ERROR',
  });
}

class UnauthorizedException extends AppException {
  const UnauthorizedException({
    super.message = 'Unauthorized access',
    super.code = 'UNAUTHORIZED',
  });
}
```

```dart
// lib/core/error/failures.dart
import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;
  final String? code;

  const Failure(this.message, {this.code});

  @override
  List<Object?> get props => [message, code];
}

class ServerFailure extends Failure {
  final int? statusCode;

  const ServerFailure({
    super.message = 'Server failure',
    super.code,
    this.statusCode,
  });

  @override
  List<Object?> get props => [message, code, statusCode];

  factory ServerFailure.fromStatusCode(int statusCode) {
    switch (statusCode) {
      case 400:
        return const ServerFailure(message: 'Bad request', code: '400');
      case 401:
        return const ServerFailure(message: 'Unauthorized', code: '401');
      case 403:
        return const ServerFailure(message: 'Forbidden', code: '403');
      case 404:
        return const ServerFailure(message: 'Not found', code: '404');
      case 500:
        return const ServerFailure(
          message: 'Internal server error',
          code: '500',
        );
      default:
        return ServerFailure(
          message: 'Server error ($statusCode)',
          code: '$statusCode',
        );
    }
  }
}

class CacheFailure extends Failure {
  const CacheFailure({super.message = 'Cache failure', super.code});
}

class NetworkFailure extends Failure {
  const NetworkFailure({
    super.message = 'No internet connection',
    super.code = 'NETWORK',
  });
}

class ValidationFailure extends Failure {
  final Map<String, String>? fieldErrors;

  const ValidationFailure({
    super.message = 'Validation failed',
    super.code = 'VALIDATION',
    this.fieldErrors,
  });

  @override
  List<Object?> get props => [message, code, fieldErrors];
}
```


#### 3f. Base UseCase Contract

```dart
// lib/core/usecase/usecase.dart
import 'package:dartz/dartz.dart';
import '../error/failures.dart';

/// UseCase dengan parameter
abstract class UseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}

/// UseCase tanpa parameter
abstract class UseCaseNoParams<Type> {
  Future<Either<Failure, Type>> call();
}

/// Params kosong (kalau mau pakai UseCase<Type, NoParams>)
class NoParams {
  const NoParams();
}
```


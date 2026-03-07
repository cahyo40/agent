---
description: Setup Flutter project dari nol dengan Clean Architecture dan BLoC state management.
---
# Workflow: Flutter Project Setup with BLoC

// turbo-all

## Overview

Setup Flutter project dari nol dengan Clean Architecture dan BLoC state management.
Mencakup folder structure, DI dengan `get_it` + `injectable`, routing (GoRouter),
theming, error handling, `BlocObserver`, dan contoh feature lengkap dengan
`Bloc<Event, State>`.

**Perbedaan utama dengan Riverpod:**
- State management pakai `Bloc` / `Cubit` (bukan `Notifier` / `AsyncNotifier`)
- DI pakai `get_it` + `injectable` (bukan Riverpod providers)
- Widget pakai `BlocBuilder` / `BlocListener` / `BlocConsumer` (bukan `ConsumerWidget`)
- Events & States sebagai sealed classes extending `Equatable`
- Routing tetap pakai `GoRouter` (sama dengan Riverpod version)


## Prerequisites

- Flutter SDK 3.41.1+ (stable channel)
- Dart 3.11.0+
- IDE (VS Code / Android Studio) configured
- Target platform (Android/iOS/Web) siap


## Agent Behavior

- **Jangan tanya nama project** — gunakan nama folder saat ini atau buat dari context user.
- **Auto-detect platform** — check apakah user butuh Android, iOS, atau Web.
- **Jangan skip code generation** — selalu run `build_runner` setelah setup.
- **Gunakan latest stable versions** — cek pub.dev jika ragu versi terbaru.
- **Gunakan Result<T> sealed class** — tidak pakai `dartz`, definisikan di `core/error/result.dart`.
- **Jangan buat God Bloc** — satu Bloc per feature, Cubit untuk state sederhana.


## Recommended Skills

- `senior-flutter-developer` — Flutter + BLoC patterns
- `senior-software-architect` — Clean Architecture


## Workflow Steps

### Step 1: Project Initialization

```bash
flutter create --org com.example --project-name {project_name} .
flutter pub get
```

### Step 2: Add Dependencies

Update `pubspec.yaml`:

```yaml
name: my_app
description: A new Flutter project with BLoC pattern.
publish_to: 'none'
version: 1.0.0+1

environment:
  sdk: '>=3.11.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter
  flutter_localizations:
    sdk: flutter

  # State Management - BLoC
  flutter_bloc: ^8.1.6
  bloc: ^8.1.4
  equatable: ^2.0.5

  # Dependency Injection
  get_it: ^8.0.0
  injectable: ^2.5.0

  # Routing
  go_router: ^14.0.0

  # Network
  dio: ^5.4.0
  connectivity_plus: ^6.0.0

  # Storage
  hive_flutter: ^1.1.0
  flutter_secure_storage: ^9.0.0

  # UI
  cached_network_image: ^3.3.1
  shimmer: ^3.0.0
  google_fonts: ^6.2.1

  # Code Generation Annotations
  freezed_annotation: ^2.4.1
  json_annotation: ^4.8.1

  # Utils
  intl: ^0.19.0
  logger: ^2.0.0
  uuid: ^4.3.3

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^5.0.0

  # Code Generation
  build_runner: ^2.4.9
  freezed: ^2.5.0
  json_serializable: ^6.7.1
  injectable_generator: ^2.6.2

  # Testing
  bloc_test: ^9.1.7
  mocktail: ^1.0.0

flutter:
  uses-material-design: true
```

```bash
flutter pub get
```

### Step 3: Setup Project Structure (Clean Architecture)

```
lib/
├── app.dart                    # Root widget dengan MultiBlocProvider
├── main.dart                   # Entry point
├── bootstrap/
│   ├── bootstrap.dart         # App initialization
│   └── observers/
│       └── app_bloc_observer.dart
├── core/
│   ├── di/
│   │   ├── injection.dart     # @InjectableInit setup
│   │   └── injection.config.dart  # Generated
│   ├── error/
│   │   ├── exceptions.dart
│   │   ├── failures.dart
│   │   └── result.dart        # Result<T> sealed class
│   ├── network/
│   │   ├── api_client.dart
│   │   └── interceptors/
│   ├── router/
│   │   ├── app_router.dart
│   │   ├── routes.dart
│   │   └── guards/
│   │       └── auth_guard.dart
│   ├── storage/
│   │   ├── secure_storage.dart
│   │   └── local_storage.dart
│   ├── theme/
│   │   ├── app_theme.dart
│   │   ├── colors.dart
│   │   └── typography.dart
│   ├── usecase/
│   │   └── usecase.dart
│   └── widgets/
│       ├── error_view.dart
│       ├── loading_view.dart
│       └── empty_view.dart
├── features/
│   └── product/               # Contoh feature
│       ├── data/
│       │   ├── datasources/
│       │   │   ├── product_remote_datasource.dart
│       │   │   └── product_local_datasource.dart
│       │   ├── models/
│       │   │   └── product_model.dart
│       │   └── repositories/
│       │       └── product_repository_impl.dart
│       ├── domain/
│       │   ├── entities/
│       │   │   └── product.dart
│       │   ├── repositories/
│       │   │   └── product_repository.dart
│       │   └── usecases/
│       │       ├── get_products.dart
│       │       ├── get_product.dart
│       │       ├── create_product.dart
│       │       └── delete_product.dart
│       └── presentation/
│           ├── bloc/
│           │   ├── product_bloc.dart
│           │   ├── product_event.dart
│           │   └── product_state.dart
│           ├── screens/
│           │   ├── product_list_screen.dart
│           │   ├── product_detail_screen.dart
│           │   └── product_create_screen.dart
│           └── widgets/
│               ├── product_card.dart
│               └── shimmer_product_list.dart
├── shared/
│   ├── extensions/
│   │   ├── context_extension.dart
│   │   └── string_extension.dart
│   └── utils/
│       ├── logger.dart
│       └── validators.dart
└── main.dart
```

**Catatan BLoC folder structure:**
- Setiap feature punya folder `bloc/` di dalam `presentation/` (bukan `controllers/`)
- BLoC terdiri dari 3 file: `*_bloc.dart`, `*_event.dart`, `*_state.dart`
- Untuk fitur sederhana, bisa pakai `cubit/` folder: `*_cubit.dart`, `*_state.dart`

### Step 4: Core Layer Setup

#### 4.1 BlocObserver - Logging

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

#### 4.2 Bootstrap & App Entry Point

```dart
// lib/main.dart
import 'package:flutter/material.dart';
import 'bootstrap/bootstrap.dart';
import 'app.dart';

void main() async {
  await bootstrap();
  runApp(const MyApp());
}

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

// lib/app.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/di/injection.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // Global blocs — hanya yang dibutuhkan di seluruh app
        BlocProvider<AuthBloc>(
          create: (_) =>
              getIt<AuthBloc>()..add(const CheckAuthStatus()),
        ),
        // Feature-specific blocs di-provide di level route/screen
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

**Catatan MultiBlocProvider:**
- Hanya register **global** blocs di root (`AuthBloc`, `ThemeBloc`, `LocaleCubit`)
- Feature-specific blocs di-provide di level screen/route (berbeda dengan Riverpod)

#### 4.3 get_it + injectable - Dependency Injection

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

// lib/core/di/register_module.dart
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
// Repository implementation
@LazySingleton(as: ProductRepository)
class ProductRepositoryImpl implements ProductRepository {
  final ProductRemoteDataSource remoteDataSource;
  ProductRepositoryImpl(this.remoteDataSource);
}

// DataSource
@LazySingleton()
class ProductRemoteDataSource {
  final Dio dio;
  ProductRemoteDataSource(this.dio);
}

// Bloc — register as factory (baru setiap kali)
@injectable
class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final GetProducts getProducts;
  ProductBloc({required this.getProducts}) : super(const ProductInitial()) {
    on<LoadProducts>(_onLoadProducts);
  }
}
```

Setelah menambah/mengubah annotations:
```bash
dart run build_runner build --delete-conflicting-outputs
```

#### 4.4 Error Handling & Result<T>

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

  factory ServerFailure.fromStatusCode(int statusCode) {
    return switch (statusCode) {
      400 => const ServerFailure(message: 'Bad request', code: '400'),
      401 => const ServerFailure(message: 'Unauthorized', code: '401'),
      403 => const ServerFailure(message: 'Forbidden', code: '403'),
      404 => const ServerFailure(message: 'Not found', code: '404'),
      500 => const ServerFailure(
          message: 'Internal server error', code: '500'),
      _ => ServerFailure(
          message: 'Server error ($statusCode)', code: '$statusCode'),
    };
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
}

// lib/core/error/result.dart
// Result<T> sealed class — menggantikan dartz Either
sealed class Result<T> {
  const Result();

  bool get isSuccess => this is Success<T>;
  bool get isFailure => this is Failure<T>;

  T? get dataOrNull =>
      isSuccess ? (this as Success<T>).data : null;

  Failure? get failureOrNull =>
      isFailure ? (this as ResultFailure<T>).failure : null;

  R fold<R>(
    R Function(Failure failure) onFailure,
    R Function(T data) onSuccess,
  ) => switch (this) {
    Success<T>(:final data) => onSuccess(data),
    ResultFailure<T>(:final failure) => onFailure(failure),
  };
}

class Success<T> extends Result<T> {
  final T data;
  const Success(this.data);
}

class ResultFailure<T> extends Result<T> {
  final Failure failure;
  const ResultFailure(this.failure);
}
```

#### 4.5 Base UseCase Contract

```dart
// lib/core/usecase/usecase.dart
import '../error/result.dart';

/// UseCase dengan parameter
abstract class UseCase<Type, Params> {
  Future<Result<Type>> call(Params params);
}

/// UseCase tanpa parameter
abstract class UseCaseNoParams<Type> {
  Future<Result<Type>> call();
}

/// Params kosong
class NoParams {
  const NoParams();
}
```

#### 4.6 Router Setup (GoRouter)

```dart
// lib/core/router/routes.dart
class AppRoutes {
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String home = '/';
  static const String profile = '/profile';
  static const String settings = '/settings';
  static const String products = '/products';
  static const String productDetail = '/products/:id';
  static const String productCreate = '/products/create';
  static const String productEdit = '/products/:id/edit';

  static String productDetailPath(String id) => '/products/$id';
  static String productEditPath(String id) => '/products/$id/edit';
}

// lib/core/router/app_router.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../di/injection.dart';
import 'routes.dart';
import 'guards/auth_guard.dart';

final appRouter = GoRouter(
  initialLocation: AppRoutes.home,
  debugLogDiagnostics: true,
  redirect: (context, state) => AuthGuard.redirect(context, state),
  routes: [
    GoRoute(
      path: AppRoutes.login,
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: AppRoutes.register,
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      path: AppRoutes.home,
      builder: (context, state) => const HomeScreen(),
    ),
    // Product routes — BlocProvider di level route
    GoRoute(
      path: AppRoutes.products,
      builder: (context, state) => BlocProvider(
        create: (_) =>
            getIt<ProductBloc>()..add(const LoadProducts()),
        child: const ProductListScreen(),
      ),
      routes: [
        GoRoute(
          path: 'create',
          builder: (context, state) => BlocProvider(
            create: (_) => getIt<ProductBloc>(),
            child: const ProductCreateScreen(),
          ),
        ),
        GoRoute(
          path: ':id',
          builder: (context, state) {
            final id = state.pathParameters['id']!;
            return BlocProvider(
              create: (_) =>
                  getIt<ProductBloc>()..add(LoadProductDetail(id: id)),
              child: ProductDetailScreen(productId: id),
            );
          },
        ),
      ],
    ),
  ],
  errorBuilder: (context, state) => Scaffold(
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text('Page not found: ${state.uri.path}'),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => context.go(AppRoutes.home),
            child: const Text('Go Home'),
          ),
        ],
      ),
    ),
  ),
);

// lib/core/router/guards/auth_guard.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../routes.dart';
import '../../../features/auth/presentation/bloc/auth_bloc.dart';

class AuthGuard {
  static String? redirect(BuildContext context, GoRouterState state) {
    final authBloc = context.read<AuthBloc>();
    final isAuthenticated = authBloc.state is AuthAuthenticated;

    final isAuthRoute = state.uri.path == AppRoutes.login ||
        state.uri.path == AppRoutes.register ||
        state.uri.path == AppRoutes.forgotPassword;

    if (!isAuthenticated && !isAuthRoute) return AppRoutes.login;
    if (isAuthenticated && isAuthRoute) return AppRoutes.home;
    return null;
  }
}
```

**Catatan BLoC + GoRouter:**
- `BlocProvider` di-wrap di `builder` GoRoute, bukan di `MultiBlocProvider` root
- Ini memastikan Bloc hanya hidup selama screen aktif (proper lifecycle)

#### 4.7 Theme Setup

```dart
// lib/core/theme/app_theme.dart
import 'package:flutter/material.dart';
import 'colors.dart';
import 'typography.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: AppColors.background,
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.onSurface,
      ),
      cardTheme: CardTheme(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      textTheme: AppTypography.textTheme,
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.dark,
      ),
      scaffoldBackgroundColor: AppColors.darkBackground,
      textTheme: AppTypography.darkTextTheme,
    );
  }
}

// lib/core/theme/colors.dart
import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF1976D2);
  static const Color primaryLight = Color(0xFF63A4FF);
  static const Color primaryDark = Color(0xFF004BA0);
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFA726);
  static const Color error = Color(0xFFE53935);
  static const Color info = Color(0xFF2196F3);
  static const Color background = Color(0xFFF5F5F5);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color onSurface = Color(0xFF212121);
  static const Color onBackground = Color(0xFF424242);
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF1E1E1E);
  static const Color darkOnSurface = Color(0xFFFFFFFF);
  static const Color darkOnBackground = Color(0xFFB0B0B0);
}

// lib/core/theme/typography.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'colors.dart';

class AppTypography {
  static TextTheme get textTheme {
    return TextTheme(
      displayLarge: GoogleFonts.poppins(
        fontSize: 32, fontWeight: FontWeight.bold),
      displayMedium: GoogleFonts.poppins(
        fontSize: 28, fontWeight: FontWeight.bold),
      titleLarge: GoogleFonts.poppins(
        fontSize: 22, fontWeight: FontWeight.w600),
      titleMedium: GoogleFonts.poppins(
        fontSize: 16, fontWeight: FontWeight.w600),
      bodyLarge: GoogleFonts.inter(
        fontSize: 16, fontWeight: FontWeight.normal),
      bodyMedium: GoogleFonts.inter(
        fontSize: 14, fontWeight: FontWeight.normal),
      labelLarge: GoogleFonts.inter(
        fontSize: 14, fontWeight: FontWeight.w600),
    );
  }

  static TextTheme get darkTextTheme => textTheme.apply(
    bodyColor: AppColors.darkOnSurface,
    displayColor: AppColors.darkOnSurface,
  );
}
```

### Step 5: Example Feature — Product (Full BLoC Pattern)

#### 5.1 Domain Layer

```dart
// features/product/domain/entities/product.dart
import 'package:equatable/equatable.dart';

class Product extends Equatable {
  final String id;
  final String name;
  final String description;
  final double price;
  final String? imageUrl;
  final DateTime createdAt;

  const Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.imageUrl,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, name, description, price, imageUrl, createdAt];
}

// features/product/domain/repositories/product_repository.dart
import '../../../../core/error/result.dart';
import '../entities/product.dart';

abstract class ProductRepository {
  Future<Result<List<Product>>> getProducts();
  Future<Result<Product>> getProduct(String id);
  Future<Result<Product>> createProduct({
    required String name,
    required String description,
    required double price,
    String? imageUrl,
  });
  Future<Result<void>> deleteProduct(String id);
}

// features/product/domain/usecases/get_products.dart
import 'package:injectable/injectable.dart';
import '../../../../core/error/result.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/product.dart';
import '../repositories/product_repository.dart';

@injectable
class GetProducts extends UseCaseNoParams<List<Product>> {
  final ProductRepository repository;
  GetProducts(this.repository);

  @override
  Future<Result<List<Product>>> call() => repository.getProducts();
}
```

#### 5.2 Data Layer

```dart
// features/product/data/models/product_model.dart
import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/product.dart';

part 'product_model.g.dart';

@JsonSerializable()
class ProductModel extends Product {
  const ProductModel({
    required super.id,
    required super.name,
    required super.description,
    required super.price,
    super.imageUrl,
    required super.createdAt,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) =>
      _$ProductModelFromJson(json);
  Map<String, dynamic> toJson() => _$ProductModelToJson(this);
}

// features/product/data/repositories/product_repository_impl.dart
import 'package:injectable/injectable.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/error/result.dart';
import '../../domain/entities/product.dart';
import '../../domain/repositories/product_repository.dart';
import '../datasources/product_remote_datasource.dart';

@LazySingleton(as: ProductRepository)
class ProductRepositoryImpl implements ProductRepository {
  final ProductRemoteDataSource remoteDataSource;
  ProductRepositoryImpl(this.remoteDataSource);

  @override
  Future<Result<List<Product>>> getProducts() async {
    try {
      final products = await remoteDataSource.getProducts();
      return Success(products);
    } on ServerException catch (e) {
      return ResultFailure(ServerFailure(message: e.message));
    } on NetworkException {
      return const ResultFailure(NetworkFailure());
    } catch (e) {
      return ResultFailure(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<Product>> getProduct(String id) async {
    try {
      final product = await remoteDataSource.getProduct(id);
      return Success(product);
    } on ServerException catch (e) {
      return ResultFailure(ServerFailure(message: e.message));
    } catch (e) {
      return ResultFailure(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<Product>> createProduct({
    required String name,
    required String description,
    required double price,
    String? imageUrl,
  }) async {
    try {
      final product = await remoteDataSource.createProduct({
        'name': name,
        'description': description,
        'price': price,
        'imageUrl': imageUrl,
      });
      return Success(product);
    } on ServerException catch (e) {
      return ResultFailure(ServerFailure(message: e.message));
    } catch (e) {
      return ResultFailure(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<void>> deleteProduct(String id) async {
    try {
      await remoteDataSource.deleteProduct(id);
      return const Success(null);
    } on ServerException catch (e) {
      return ResultFailure(ServerFailure(message: e.message));
    } catch (e) {
      return ResultFailure(ServerFailure(message: e.toString()));
    }
  }
}
```

#### 5.3 Presentation Layer — BLoC (Events, States, Bloc)

**Ini bagian paling penting yang membedakan BLoC dari Riverpod.**

```dart
// features/product/presentation/bloc/product_event.dart
part of 'product_bloc.dart';

sealed class ProductEvent extends Equatable {
  const ProductEvent();
  @override
  List<Object?> get props => [];
}

class LoadProducts extends ProductEvent {
  const LoadProducts();
}

class LoadProductDetail extends ProductEvent {
  final String id;
  const LoadProductDetail({required this.id});
  @override
  List<Object?> get props => [id];
}

class CreateProductEvent extends ProductEvent {
  final String name;
  final String description;
  final double price;
  final String? imageUrl;

  const CreateProductEvent({
    required this.name,
    required this.description,
    required this.price,
    this.imageUrl,
  });

  @override
  List<Object?> get props => [name, description, price, imageUrl];
}

class DeleteProductEvent extends ProductEvent {
  final String id;
  const DeleteProductEvent({required this.id});
  @override
  List<Object?> get props => [id];
}

class RefreshProducts extends ProductEvent {
  const RefreshProducts();
}

// features/product/presentation/bloc/product_state.dart
part of 'product_bloc.dart';

sealed class ProductState extends Equatable {
  const ProductState();
  @override
  List<Object?> get props => [];
}

class ProductInitial extends ProductState {
  const ProductInitial();
}

class ProductLoading extends ProductState {
  const ProductLoading();
}

class ProductLoaded extends ProductState {
  final List<Product> products;
  const ProductLoaded({required this.products});
  @override
  List<Object?> get props => [products];
  bool get isEmpty => products.isEmpty;
}

class ProductDetailLoaded extends ProductState {
  final Product product;
  const ProductDetailLoaded({required this.product});
  @override
  List<Object?> get props => [product];
}

class ProductCreated extends ProductState {
  final Product product;
  const ProductCreated({required this.product});
  @override
  List<Object?> get props => [product];
}

class ProductDeleted extends ProductState {
  final String productId;
  const ProductDeleted({required this.productId});
  @override
  List<Object?> get props => [productId];
}

class ProductError extends ProductState {
  final String message;
  const ProductError({required this.message});
  @override
  List<Object?> get props => [message];
}

// features/product/presentation/bloc/product_bloc.dart
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../domain/entities/product.dart';
import '../../domain/usecases/get_products.dart';
import '../../domain/usecases/get_product.dart';
import '../../domain/usecases/create_product.dart';
import '../../domain/usecases/delete_product.dart';

part 'product_event.dart';
part 'product_state.dart';

@injectable
class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final GetProducts _getProducts;
  final GetProduct _getProduct;
  final CreateProduct _createProduct;
  final DeleteProduct _deleteProduct;

  ProductBloc({
    required GetProducts getProducts,
    required GetProduct getProduct,
    required CreateProduct createProduct,
    required DeleteProduct deleteProduct,
  })  : _getProducts = getProducts,
        _getProduct = getProduct,
        _createProduct = createProduct,
        _deleteProduct = deleteProduct,
        super(const ProductInitial()) {
    on<LoadProducts>(_onLoadProducts);
    on<LoadProductDetail>(_onLoadProductDetail);
    on<CreateProductEvent>(_onCreateProduct);
    on<DeleteProductEvent>(_onDeleteProduct);
    on<RefreshProducts>(_onRefreshProducts);
  }

  Future<void> _onLoadProducts(
    LoadProducts event,
    Emitter<ProductState> emit,
  ) async {
    emit(const ProductLoading());
    final result = await _getProducts();
    result.fold(
      (failure) => emit(ProductError(message: failure.message)),
      (products) => emit(ProductLoaded(products: products)),
    );
  }

  Future<void> _onLoadProductDetail(
    LoadProductDetail event,
    Emitter<ProductState> emit,
  ) async {
    emit(const ProductLoading());
    final result = await _getProduct(event.id);
    result.fold(
      (failure) => emit(ProductError(message: failure.message)),
      (product) => emit(ProductDetailLoaded(product: product)),
    );
  }

  Future<void> _onCreateProduct(
    CreateProductEvent event,
    Emitter<ProductState> emit,
  ) async {
    emit(const ProductLoading());
    final result = await _createProduct(CreateProductParams(
      name: event.name,
      description: event.description,
      price: event.price,
      imageUrl: event.imageUrl,
    ));
    result.fold(
      (failure) => emit(ProductError(message: failure.message)),
      (product) => emit(ProductCreated(product: product)),
    );
  }

  Future<void> _onDeleteProduct(
    DeleteProductEvent event,
    Emitter<ProductState> emit,
  ) async {
    emit(const ProductLoading());
    final result = await _deleteProduct(event.id);
    result.fold(
      (failure) => emit(ProductError(message: failure.message)),
      (_) => emit(ProductDeleted(productId: event.id)),
    );
  }

  Future<void> _onRefreshProducts(
    RefreshProducts event,
    Emitter<ProductState> emit,
  ) async {
    final result = await _getProducts();
    result.fold(
      (failure) => emit(ProductError(message: failure.message)),
      (products) => emit(ProductLoaded(products: products)),
    );
  }
}
```

#### 5.4 Presentation Layer — Screens

```dart
// features/product/presentation/screens/product_list_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/routes.dart';
import '../bloc/product_bloc.dart';
import '../widgets/product_card.dart';
import '../widgets/shimmer_product_list.dart';

class ProductListScreen extends StatelessWidget {
  const ProductListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Products'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () => context.push(AppRoutes.profile),
          ),
        ],
      ),
      // BlocConsumer = BlocListener + BlocBuilder
      body: BlocConsumer<ProductBloc, ProductState>(
        listener: (context, state) {
          if (state is ProductDeleted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Product berhasil dihapus'),
                backgroundColor: Colors.green,
              ),
            );
            context.read<ProductBloc>().add(const LoadProducts());
          }
          if (state is ProductError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          return switch (state) {
            ProductInitial() => const Center(
                child: Text('Tap refresh to load products'),
              ),
            ProductLoading() => const ShimmerProductList(),
            ProductLoaded(:final products) => products.isEmpty
                ? EmptyView(
                    message: 'Belum ada product',
                    onAction: () => context.push(AppRoutes.productCreate),
                    actionLabel: 'Tambah Product',
                  )
                : RefreshIndicator(
                    onRefresh: () async {
                      context
                          .read<ProductBloc>()
                          .add(const RefreshProducts());
                    },
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: products.length,
                      itemBuilder: (context, index) {
                        final product = products[index];
                        return ProductCard(
                          product: product,
                          onTap: () => context.push(
                            AppRoutes.productDetailPath(product.id),
                          ),
                          onDelete: () {
                            context.read<ProductBloc>().add(
                              DeleteProductEvent(id: product.id),
                            );
                          },
                        );
                      },
                    ),
                  ),
            ProductError(:final message) => ErrorView(
                message: message,
                onRetry: () {
                  context.read<ProductBloc>().add(const LoadProducts());
                },
              ),
            _ => const SizedBox.shrink(),
          };
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push(AppRoutes.productCreate),
        child: const Icon(Icons.add),
      ),
    );
  }
}
```

#### 5.5 Cubit Pattern (Untuk Fitur Sederhana)

```dart
// features/settings/presentation/cubit/theme_cubit.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

part 'theme_state.dart';

@injectable
class ThemeCubit extends Cubit<ThemeState> {
  ThemeCubit() : super(const ThemeState(themeMode: ThemeMode.system));

  void setThemeMode(ThemeMode mode) =>
      emit(ThemeState(themeMode: mode));

  void toggleTheme() {
    final newMode = state.themeMode == ThemeMode.light
        ? ThemeMode.dark
        : ThemeMode.light;
    emit(ThemeState(themeMode: newMode));
  }
}

// features/settings/presentation/cubit/theme_state.dart
part of 'theme_cubit.dart';

class ThemeState extends Equatable {
  final ThemeMode themeMode;
  const ThemeState({required this.themeMode});

  @override
  List<Object?> get props => [themeMode];
}
```

**Kapan pakai Bloc vs Cubit:**

| Kriteria         | Bloc                                    | Cubit                    |
|------------------|-----------------------------------------|--------------------------|
| Complexity       | Fitur kompleks (CRUD, multi-step)       | Fitur sederhana (toggle, counter) |
| Events           | Butuh events terpisah untuk traceability | Langsung call method     |
| Testing          | Test per-event (`blocTest`)             | Test per-method          |
| Transformations  | Bisa pakai `EventTransformer`           | Tidak bisa               |
| Verbosity        | Lebih verbose (3 files)                 | Lebih ringkas (2 files)  |

```
Bloc  -> AuthBloc, ProductBloc, OrderBloc, SearchBloc
Cubit -> ThemeCubit, LocaleCubit, CounterCubit, ConnectivityCubit
```

### Step 6: Testing Setup dengan bloc_test

```dart
// test/features/product/presentation/bloc/product_bloc_test.dart
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockGetProducts extends Mock implements GetProducts {}
class MockCreateProduct extends Mock implements CreateProduct {}
class MockDeleteProduct extends Mock implements DeleteProduct {}

void main() {
  late ProductBloc bloc;
  late MockGetProducts mockGetProducts;

  setUp(() {
    mockGetProducts = MockGetProducts();
    bloc = ProductBloc(
      getProducts: mockGetProducts,
      getProduct: MockGetProduct(),
      createProduct: MockCreateProduct(),
      deleteProduct: MockDeleteProduct(),
    );
  });

  tearDown(() => bloc.close());

  group('LoadProducts', () {
    final tProducts = [
      Product(
        id: '1',
        name: 'Test Product',
        description: 'Description',
        price: 10.0,
        createdAt: DateTime.now(),
      ),
    ];

    blocTest<ProductBloc, ProductState>(
      'emits [ProductLoading, ProductLoaded] when success',
      build: () {
        when(() => mockGetProducts())
            .thenAnswer((_) async => Success(tProducts));
        return bloc;
      },
      act: (bloc) => bloc.add(const LoadProducts()),
      expect: () => [
        const ProductLoading(),
        ProductLoaded(products: tProducts),
      ],
      verify: (_) {
        verify(() => mockGetProducts()).called(1);
      },
    );

    blocTest<ProductBloc, ProductState>(
      'emits [ProductLoading, ProductError] when failure',
      build: () {
        when(() => mockGetProducts()).thenAnswer(
          (_) async => const ResultFailure(ServerFailure(message: 'Server error')),
        );
        return bloc;
      },
      act: (bloc) => bloc.add(const LoadProducts()),
      expect: () => [
        const ProductLoading(),
        const ProductError(message: 'Server error'),
      ],
    );
  });
}
```

### Step 7: Code Generation

```bash
dart run build_runner build --delete-conflicting-outputs
```

### Step 8: Verify & Test

```bash
flutter analyze
flutter test
flutter run
# Verify AppBlocObserver logs di console
```


## Success Criteria

- [ ] Project structure mengikuti Clean Architecture
- [ ] Semua dependencies terinstall tanpa error
- [ ] `get_it` + `injectable` DI configured dan generated
- [ ] `AppBlocObserver` logging events/transitions
- [ ] `Result<T>` sealed class defined (bukan `dartz`)
- [ ] GoRouter configured dengan routes lengkap
- [ ] Route constants defined di `routes.dart`
- [ ] Auth guard implemented
- [ ] Example Product feature lengkap:
  - [ ] Events: `LoadProducts`, `CreateProductEvent`, `DeleteProductEvent`
  - [ ] States: `ProductInitial`, `ProductLoading`, `ProductLoaded`, `ProductError`
  - [ ] `BlocBuilder` untuk UI rendering
  - [ ] `BlocListener` untuk side effects (snackbar, navigation)
  - [ ] Pattern matching pada sealed state classes
- [ ] `BlocProvider` di level route untuk feature-specific blocs
- [ ] `MultiBlocProvider` di root untuk global blocs
- [ ] Shimmer loading implemented
- [ ] Code generation berjalan tanpa error
- [ ] `flutter analyze` tidak ada warning/error
- [ ] Unit tests passing dengan `bloc_test`
- [ ] App bisa build dan run


## Tools & Templates

- **Flutter Version:** 3.41.1+ (stable channel)
- **Dart Version:** 3.11.0+
- **State Management:** flutter_bloc 8.1+, bloc 8.1+
- **DI:** get_it 8.0+, injectable 2.5+
- **Routing:** GoRouter 14.0+
- **HTTP Client:** Dio 5.4+
- **Local Storage:** Hive 1.1+
- **Code Generation:** build_runner, freezed, json_serializable, injectable_generator
- **Testing:** bloc_test 9.1+, mocktail 1.0+


## Next Steps

Setelah workflow ini selesai, lanjut ke:
1. `02_feature_maker.md` — Generate feature baru dengan BLoC pattern
2. `03_backend_integration.md` — REST API integration lengkap
3. `04_firebase_integration.md` — Firebase services
4. `05_supabase_integration.md` — Supabase integration

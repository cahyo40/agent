# Workflow: Flutter Project Setup with BLoC

## Overview

Setup Flutter project dari nol dengan Clean Architecture dan BLoC state management. Workflow ini mencakup struktur folder lengkap, konfigurasi dependencies, dependency injection dengan `get_it` + `injectable`, dan contoh implementasi feature lengkap dengan pattern `Bloc<Event, State>`.

**Perbedaan utama dengan Riverpod:**
- State management pakai `Bloc` / `Cubit` (bukan `Notifier` / `AsyncNotifier`)
- DI pakai `get_it` + `injectable` (bukan Riverpod providers)
- Widget pakai `BlocBuilder` / `BlocListener` / `BlocConsumer` (bukan `ConsumerWidget` / `ref.watch()`)
- Events & States sebagai sealed classes extending `Equatable`
- Routing tetap pakai `GoRouter` (sama dengan Riverpod version)

## Output Location

**Base Folder:** `sdlc/flutter-bloc/01-project-setup/`

**Output Files:**
- `project-structure.md` - Dokumentasi struktur folder
- `pubspec.yaml` - Dependencies lengkap
- `lib/main.dart` - Entry point aplikasi
- `lib/app.dart` - Root widget dengan MultiBlocProvider
- `lib/bootstrap/bootstrap.dart` - App initialization
- `lib/core/di/injection.dart` - get_it + injectable setup
- `lib/core/di/injection.config.dart` - Generated DI config
- `lib/core/router/app_router.dart` - GoRouter configuration lengkap
- `lib/core/router/routes.dart` - Route definitions dan constants
- `lib/core/router/guards/auth_guard.dart` - Authentication route guard
- `lib/core/error/` - Error handling classes (Failure, Exception)
- `lib/core/theme/app_theme.dart` - App theme configuration
- `lib/features/product/` - Contoh feature lengkap (CRUD) dengan BLoC pattern
- `lib/shared/` - Extensions, utils, shared widgets
- `README.md` - Setup instructions

## Prerequisites

- Flutter SDK 3.41.1+ (Tested on 3.41.1 stable)
- Dart 3.11.0+
- IDE (VS Code atau Android Studio)
- Git terinstall

## Deliverables

### 1. Project Structure - Clean Architecture dengan BLoC

**Description:** Struktur folder lengkap dengan Clean Architecture + BLoC pattern.

**Recommended Skills:** `senior-flutter-developer`, `senior-software-architect`

**Instructions:**
1. Buat folder structure berikut:
   ```
   lib/
   ├── app.dart                    # Root widget dengan MultiBlocProvider
   ├── main.dart                   # Entry point
   ├── bootstrap/                  # App initialization
   │   ├── bootstrap.dart         # App bootstrapping (init Hive, get_it, etc.)
   │   └── observers/             # BlocObserver untuk logging
   │       └── app_bloc_observer.dart
   ├── core/                      # Shared infrastructure
   │   ├── di/                    # Dependency Injection (get_it + injectable)
   │   │   ├── injection.dart     # @InjectableInit setup
   │   │   └── injection.config.dart  # Generated
   │   ├── error/                 # Error handling
   │   │   ├── exceptions.dart    # AppException, ServerException, etc.
   │   │   └── failures.dart      # Failure, ServerFailure, etc.
   │   ├── network/               # Dio setup, interceptors
   │   │   ├── api_client.dart
   │   │   └── interceptors/
   │   ├── router/                # GoRouter configuration
   │   │   ├── app_router.dart
   │   │   ├── routes.dart
   │   │   └── guards/
   │   │       └── auth_guard.dart
   │   ├── storage/               # Secure & local storage
   │   │   ├── secure_storage.dart
   │   │   └── local_storage.dart
   │   ├── theme/                 # App theme & colors
   │   │   ├── app_theme.dart
   │   │   ├── colors.dart
   │   │   └── typography.dart
   │   ├── usecase/               # Base UseCase contract
   │   │   └── usecase.dart
   │   └── widgets/               # Shared core widgets
   │       ├── error_view.dart
   │       ├── loading_view.dart
   │       └── empty_view.dart
   ├── features/                  # Feature modules
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
   │           │   ├── product_bloc.dart      # Bloc class
   │           │   ├── product_event.dart     # Events
   │           │   └── product_state.dart     # States
   │           ├── screens/
   │           │   ├── product_list_screen.dart
   │           │   ├── product_detail_screen.dart
   │           │   └── product_create_screen.dart
   │           └── widgets/
   │               ├── product_card.dart
   │               └── shimmer_product_list.dart
   ├── l10n/                      # Localization
   ├── shared/                    # Shared utilities
   │   ├── extensions/
   │   │   ├── context_extension.dart
   │   │   └── string_extension.dart
   │   ├── mixins/
   │   ├── utils/
   │   │   ├── logger.dart
   │   │   └── validators.dart
   │   └── widgets/
   │       ├── app_button.dart
   │       └── app_text_field.dart
   └── main.dart
   ```
2. Setup setiap folder dengan base files
3. Konfigurasi import alias di `pubspec.yaml`

**Catatan Penting tentang BLoC folder structure:**
- Setiap feature punya folder `bloc/` di dalam `presentation/` (bukan `controllers/`)
- BLoC terdiri dari 3 file: `*_bloc.dart`, `*_event.dart`, `*_state.dart`
- Untuk fitur sederhana, bisa pakai `cubit/` folder dengan 2 file: `*_cubit.dart`, `*_state.dart`

---

### 2. Dependencies (pubspec.yaml)

**Description:** Konfigurasi semua dependencies untuk Flutter BLoC project.

**Output Format:**
```yaml
# pubspec.yaml
name: my_app
description: A new Flutter project with BLoC pattern.

publish_to: 'none'

version: 1.0.0+1

environment:
  sdk: '>=3.11.0 <4.0.0'  # Updated untuk Flutter 3.41.1

dependencies:
  flutter:
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

  # Functional Programming
  dartz: ^0.10.1

  # UI
  cached_network_image: ^3.3.1
  shimmer: ^3.0.0
  google_fonts: ^6.2.1

  # Code Generation Annotations
  freezed_annotation: ^2.4.1
  json_annotation: ^4.8.1

  # Utils
  intl: ^0.19.0

  # Firebase (optional) - Updated untuk Flutter 3.41.1
  # firebase_core: ^3.12.0
  # firebase_auth: ^5.5.0
  # cloud_firestore: ^5.6.0
  # firebase_storage: ^12.4.0
  # firebase_messaging: ^15.2.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^4.0.0

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

**Penjelasan dependencies BLoC vs Riverpod:**

| Concern               | BLoC Stack                          | Riverpod Stack                      |
|------------------------|-------------------------------------|--------------------------------------|
| State Management       | `flutter_bloc`, `bloc`              | `flutter_riverpod`, `riverpod_annotation` |
| DI                     | `get_it`, `injectable`              | Built-in Riverpod providers          |
| State/Event classes    | `equatable`, `freezed` (optional)   | `freezed` (optional)                |
| Linting                | `flutter_lints`                     | `riverpod_lint`, `custom_lint`       |
| Testing                | `bloc_test`, `mocktail`             | `mocktail` (langsung test provider)  |
| Code Gen               | `injectable_generator`              | `riverpod_generator`                |

---

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

---

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

---

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

---

#### 3g. GoRouter Setup

```dart
// lib/core/router/routes.dart
class AppRoutes {
  // Auth routes
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';

  // Main routes
  static const String home = '/';
  static const String profile = '/profile';
  static const String settings = '/settings';

  // Feature routes
  static const String products = '/products';
  static const String productDetail = '/products/:id';
  static const String productCreate = '/products/create';
  static const String productEdit = '/products/:id/edit';

  // Helper methods untuk generate route dengan parameters
  static String productDetailPath(String id) => '/products/$id';
  static String productEditPath(String id) => '/products/$id/edit';
}
```

```dart
// lib/core/router/app_router.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../di/injection.dart';
import 'routes.dart';
import 'guards/auth_guard.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/product/presentation/bloc/product_bloc.dart';
import '../../features/product/presentation/screens/product_list_screen.dart';
import '../../features/product/presentation/screens/product_detail_screen.dart';
import '../../features/product/presentation/screens/product_create_screen.dart';

final appRouter = GoRouter(
  initialLocation: AppRoutes.home,
  debugLogDiagnostics: true,
  redirect: (context, state) => AuthGuard.redirect(context, state),
  routes: [
    // Auth routes
    GoRoute(
      path: AppRoutes.login,
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: AppRoutes.register,
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      path: AppRoutes.forgotPassword,
      builder: (context, state) => const ForgotPasswordScreen(),
    ),

    // Home route
    GoRoute(
      path: AppRoutes.home,
      builder: (context, state) => const HomeScreen(),
    ),

    // Profile route
    GoRoute(
      path: AppRoutes.profile,
      builder: (context, state) => const ProfileScreen(),
    ),

    // Settings route
    GoRoute(
      path: AppRoutes.settings,
      builder: (context, state) => const SettingsScreen(),
    ),

    // Product routes - BlocProvider di level route
    GoRoute(
      path: AppRoutes.products,
      builder: (context, state) => BlocProvider(
        create: (_) => getIt<ProductBloc>()..add(const LoadProducts()),
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
              create: (_) => getIt<ProductBloc>()
                ..add(LoadProductDetail(id: id)),
              child: ProductDetailScreen(productId: id),
            );
          },
          routes: [
            GoRoute(
              path: 'edit',
              builder: (context, state) {
                final id = state.pathParameters['id']!;
                return BlocProvider(
                  create: (_) => getIt<ProductBloc>()
                    ..add(LoadProductDetail(id: id)),
                  child: ProductEditScreen(productId: id),
                );
              },
            ),
          ],
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
```

**Catatan BLoC + GoRouter:**
- BlocProvider di-wrap di `builder` GoRoute, bukan di `MultiBlocProvider` root
- Ini memastikan Bloc hanya hidup selama screen aktif (proper lifecycle)
- Alternatif: pakai `ShellRoute` untuk share Bloc antar child routes

```dart
// lib/core/router/guards/auth_guard.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../routes.dart';
import '../../../features/auth/presentation/bloc/auth_bloc.dart';

class AuthGuard {
  /// Redirect logic untuk authentication
  /// Dipanggil setiap kali route berubah
  static String? redirect(BuildContext context, GoRouterState state) {
    // Cek auth state dari AuthBloc
    // Note: context.read<AuthBloc>() butuh AuthBloc di-provide di atas GoRouter
    final authBloc = context.read<AuthBloc>();
    final isAuthenticated = authBloc.state is AuthAuthenticated;

    final isAuthRoute = state.uri.path == AppRoutes.login ||
        state.uri.path == AppRoutes.register ||
        state.uri.path == AppRoutes.forgotPassword;

    // Redirect ke login jika belum authenticated dan bukan auth route
    if (!isAuthenticated && !isAuthRoute) {
      return AppRoutes.login;
    }

    // Redirect ke home jika sudah authenticated dan di auth route
    if (isAuthenticated && isAuthRoute) {
      return AppRoutes.home;
    }

    return null;
  }
}
```

---

#### 3h. Theme Setup

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
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: AppColors.darkSurface,
        foregroundColor: AppColors.darkOnSurface,
      ),
      textTheme: AppTypography.darkTextTheme,
    );
  }
}

// lib/core/theme/colors.dart
import 'package:flutter/material.dart';

class AppColors {
  // Primary colors
  static const Color primary = Color(0xFF1976D2);
  static const Color primaryLight = Color(0xFF63A4FF);
  static const Color primaryDark = Color(0xFF004BA0);

  // Semantic colors
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFA726);
  static const Color error = Color(0xFFE53935);
  static const Color info = Color(0xFF2196F3);

  // Light theme
  static const Color background = Color(0xFFF5F5F5);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color onSurface = Color(0xFF212121);
  static const Color onBackground = Color(0xFF424242);

  // Dark theme
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
        fontSize: 32,
        fontWeight: FontWeight.bold,
      ),
      displayMedium: GoogleFonts.poppins(
        fontSize: 28,
        fontWeight: FontWeight.bold,
      ),
      titleLarge: GoogleFonts.poppins(
        fontSize: 22,
        fontWeight: FontWeight.w600,
      ),
      titleMedium: GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
      bodyLarge: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.normal,
      ),
      bodyMedium: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.normal,
      ),
      labelLarge: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  static TextTheme get darkTextTheme {
    return textTheme.apply(
      bodyColor: AppColors.darkOnSurface,
      displayColor: AppColors.darkOnSurface,
    );
  }
}
```

---

### 4. Example Feature Implementation - Product (Full BLoC Pattern)

**Description:** Contoh feature lengkap dengan CRUD operations menggunakan BLoC.

**Recommended Skills:** `senior-flutter-developer`

**Instructions:**

#### 4a. Domain Layer

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
```

```dart
// features/product/domain/repositories/product_repository.dart
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/product.dart';

abstract class ProductRepository {
  Future<Either<Failure, List<Product>>> getProducts();
  Future<Either<Failure, Product>> getProduct(String id);
  Future<Either<Failure, Product>> createProduct({
    required String name,
    required String description,
    required double price,
    String? imageUrl,
  });
  Future<Either<Failure, void>> deleteProduct(String id);
}
```

```dart
// features/product/domain/usecases/get_products.dart
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/product.dart';
import '../repositories/product_repository.dart';

@injectable
class GetProducts extends UseCaseNoParams<List<Product>> {
  final ProductRepository repository;

  GetProducts(this.repository);

  @override
  Future<Either<Failure, List<Product>>> call() {
    return repository.getProducts();
  }
}
```

```dart
// features/product/domain/usecases/create_product.dart
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/product.dart';
import '../repositories/product_repository.dart';

@injectable
class CreateProduct extends UseCase<Product, CreateProductParams> {
  final ProductRepository repository;

  CreateProduct(this.repository);

  @override
  Future<Either<Failure, Product>> call(CreateProductParams params) {
    return repository.createProduct(
      name: params.name,
      description: params.description,
      price: params.price,
      imageUrl: params.imageUrl,
    );
  }
}

class CreateProductParams extends Equatable {
  final String name;
  final String description;
  final double price;
  final String? imageUrl;

  const CreateProductParams({
    required this.name,
    required this.description,
    required this.price,
    this.imageUrl,
  });

  @override
  List<Object?> get props => [name, description, price, imageUrl];
}
```

```dart
// features/product/domain/usecases/delete_product.dart
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/product_repository.dart';

@injectable
class DeleteProduct extends UseCase<void, String> {
  final ProductRepository repository;

  DeleteProduct(this.repository);

  @override
  Future<Either<Failure, void>> call(String id) {
    return repository.deleteProduct(id);
  }
}
```

---

#### 4b. Data Layer

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

  factory ProductModel.fromEntity(Product product) {
    return ProductModel(
      id: product.id,
      name: product.name,
      description: product.description,
      price: product.price,
      imageUrl: product.imageUrl,
      createdAt: product.createdAt,
    );
  }
}
```

```dart
// features/product/data/datasources/product_remote_datasource.dart
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/exceptions.dart';
import '../models/product_model.dart';

@lazySingleton
class ProductRemoteDataSource {
  final Dio _dio;

  ProductRemoteDataSource(this._dio);

  Future<List<ProductModel>> getProducts() async {
    try {
      final response = await _dio.get('/products');
      return (response.data as List)
          .map((json) => ProductModel.fromJson(json))
          .toList();
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data?['message'] ?? 'Failed to fetch products',
        statusCode: e.response?.statusCode,
      );
    }
  }

  Future<ProductModel> getProduct(String id) async {
    try {
      final response = await _dio.get('/products/$id');
      return ProductModel.fromJson(response.data);
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data?['message'] ?? 'Failed to fetch product',
        statusCode: e.response?.statusCode,
      );
    }
  }

  Future<ProductModel> createProduct(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post('/products', data: data);
      return ProductModel.fromJson(response.data);
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data?['message'] ?? 'Failed to create product',
        statusCode: e.response?.statusCode,
      );
    }
  }

  Future<void> deleteProduct(String id) async {
    try {
      await _dio.delete('/products/$id');
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data?['message'] ?? 'Failed to delete product',
        statusCode: e.response?.statusCode,
      );
    }
  }
}
```

```dart
// features/product/data/repositories/product_repository_impl.dart
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/product.dart';
import '../../domain/repositories/product_repository.dart';
import '../datasources/product_remote_datasource.dart';

@LazySingleton(as: ProductRepository)
class ProductRepositoryImpl implements ProductRepository {
  final ProductRemoteDataSource remoteDataSource;

  ProductRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, List<Product>>> getProducts() async {
    try {
      final products = await remoteDataSource.getProducts();
      return Right(products);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on NetworkException {
      return const Left(NetworkFailure());
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Product>> getProduct(String id) async {
    try {
      final product = await remoteDataSource.getProduct(id);
      return Right(product);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Product>> createProduct({
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
      return Right(product);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteProduct(String id) async {
    try {
      await remoteDataSource.deleteProduct(id);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
```

---

#### 4c. Presentation Layer - BLoC (Events, States, Bloc)

**Ini bagian paling penting yang membedakan BLoC dari Riverpod.**

```dart
// features/product/presentation/bloc/product_event.dart
part of 'product_bloc.dart';

/// Base event class - sealed untuk exhaustive pattern matching
sealed class ProductEvent extends Equatable {
  const ProductEvent();

  @override
  List<Object?> get props => [];
}

/// Load semua products
class LoadProducts extends ProductEvent {
  const LoadProducts();
}

/// Load product detail by ID
class LoadProductDetail extends ProductEvent {
  final String id;
  const LoadProductDetail({required this.id});

  @override
  List<Object?> get props => [id];
}

/// Create product baru
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

/// Delete product by ID
class DeleteProductEvent extends ProductEvent {
  final String id;
  const DeleteProductEvent({required this.id});

  @override
  List<Object?> get props => [id];
}

/// Refresh products list
class RefreshProducts extends ProductEvent {
  const RefreshProducts();
}
```

```dart
// features/product/presentation/bloc/product_state.dart
part of 'product_bloc.dart';

/// Base state class - sealed untuk exhaustive pattern matching
sealed class ProductState extends Equatable {
  const ProductState();

  @override
  List<Object?> get props => [];
}

/// State awal, belum ada action
class ProductInitial extends ProductState {
  const ProductInitial();
}

/// Sedang loading data
class ProductLoading extends ProductState {
  const ProductLoading();
}

/// Products berhasil di-load
class ProductLoaded extends ProductState {
  final List<Product> products;

  const ProductLoaded({required this.products});

  @override
  List<Object?> get props => [products];

  /// Helper untuk cek apakah list kosong
  bool get isEmpty => products.isEmpty;
}

/// Product detail berhasil di-load
class ProductDetailLoaded extends ProductState {
  final Product product;

  const ProductDetailLoaded({required this.product});

  @override
  List<Object?> get props => [product];
}

/// Product berhasil dibuat
class ProductCreated extends ProductState {
  final Product product;

  const ProductCreated({required this.product});

  @override
  List<Object?> get props => [product];
}

/// Product berhasil dihapus
class ProductDeleted extends ProductState {
  final String productId;

  const ProductDeleted({required this.productId});

  @override
  List<Object?> get props => [productId];
}

/// Error state
class ProductError extends ProductState {
  final String message;

  const ProductError({required this.message});

  @override
  List<Object?> get props => [message];
}
```

```dart
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
    // Register event handlers
    on<LoadProducts>(_onLoadProducts);
    on<LoadProductDetail>(_onLoadProductDetail);
    on<CreateProductEvent>(_onCreateProduct);
    on<DeleteProductEvent>(_onDeleteProduct);
    on<RefreshProducts>(_onRefreshProducts);
  }

  /// Handler: Load semua products
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

  /// Handler: Load product detail
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

  /// Handler: Create product baru
  Future<void> _onCreateProduct(
    CreateProductEvent event,
    Emitter<ProductState> emit,
  ) async {
    emit(const ProductLoading());

    final result = await _createProduct(
      CreateProductParams(
        name: event.name,
        description: event.description,
        price: event.price,
        imageUrl: event.imageUrl,
      ),
    );

    result.fold(
      (failure) => emit(ProductError(message: failure.message)),
      (product) => emit(ProductCreated(product: product)),
    );
  }

  /// Handler: Delete product
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

  /// Handler: Refresh products (sama dengan load, tapi bisa dibedakan logic-nya)
  Future<void> _onRefreshProducts(
    RefreshProducts event,
    Emitter<ProductState> emit,
  ) async {
    // Tidak emit loading supaya UI tidak flicker saat refresh
    final result = await _getProducts();

    result.fold(
      (failure) => emit(ProductError(message: failure.message)),
      (products) => emit(ProductLoaded(products: products)),
    );
  }
}
```

---

#### 4d. Presentation Layer - Screens (UI)

```dart
// features/product/presentation/screens/product_list_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/routes.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/empty_view.dart';
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
      // BlocListener untuk side effects (snackbar, navigation, etc.)
      // BlocBuilder untuk rebuild UI berdasarkan state
      // BlocConsumer = BlocListener + BlocBuilder
      body: BlocConsumer<ProductBloc, ProductState>(
        // Listener: side effects saja, tidak rebuild UI
        listener: (context, state) {
          if (state is ProductDeleted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Product berhasil dihapus'),
                backgroundColor: Colors.green,
              ),
            );
            // Refresh list setelah delete
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
        // Builder: rebuild UI berdasarkan state
        builder: (context, state) {
          // Pattern matching pada sealed class state
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
                      context.read<ProductBloc>().add(const RefreshProducts());
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
            // States yang tidak relevan untuk list screen
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

```dart
// features/product/presentation/screens/product_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/routes.dart';
import '../bloc/product_bloc.dart';

class ProductDetailScreen extends StatelessWidget {
  final String productId;

  const ProductDetailScreen({super.key, required this.productId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Detail'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => context.push(
              AppRoutes.productEditPath(productId),
            ),
          ),
        ],
      ),
      body: BlocBuilder<ProductBloc, ProductState>(
        builder: (context, state) {
          return switch (state) {
            ProductLoading() => const Center(
                child: CircularProgressIndicator(),
              ),
            ProductDetailLoaded(:final product) => SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (product.imageUrl != null)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          product.imageUrl!,
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                    const SizedBox(height: 16),
                    Text(
                      product.name,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '\$${product.price.toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(product.description),
                  ],
                ),
              ),
            ProductError(:final message) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(message),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        context.read<ProductBloc>().add(
                          LoadProductDetail(id: productId),
                        );
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            _ => const SizedBox.shrink(),
          };
        },
      ),
    );
  }
}
```

```dart
// features/product/presentation/screens/product_create_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/product_bloc.dart';

class ProductCreateScreen extends StatefulWidget {
  const ProductCreateScreen({super.key});

  @override
  State<ProductCreateScreen> createState() => _ProductCreateScreenState();
}

class _ProductCreateScreenState extends State<ProductCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      context.read<ProductBloc>().add(
        CreateProductEvent(
          name: _nameController.text.trim(),
          description: _descriptionController.text.trim(),
          price: double.parse(_priceController.text.trim()),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Product')),
      body: BlocListener<ProductBloc, ProductState>(
        listener: (context, state) {
          if (state is ProductCreated) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Product "${state.product.name}" berhasil dibuat'),
                backgroundColor: Colors.green,
              ),
            );
            // Navigate back setelah berhasil create
            context.pop();
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
        child: BlocBuilder<ProductBloc, ProductState>(
          builder: (context, state) {
            final isLoading = state is ProductLoading;

            return Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Product Name',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Nama product wajib diisi';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Description wajib diisi';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _priceController,
                      decoration: const InputDecoration(
                        labelText: 'Price',
                        border: OutlineInputBorder(),
                        prefixText: '\$ ',
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Price wajib diisi';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Price harus berupa angka';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      height: 48,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : _submitForm,
                        child: isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text('Create Product'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
```

---

#### 4e. Presentation Layer - Reusable Widgets

```dart
// features/product/presentation/widgets/product_card.dart
import 'package:flutter/material.dart';
import '../../domain/entities/product.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const ProductCard({
    super.key,
    required this.product,
    this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Product image placeholder
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: product.imageUrl != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          product.imageUrl!,
                          fit: BoxFit.cover,
                        ),
                      )
                    : const Icon(Icons.image, color: Colors.grey),
              ),
              const SizedBox(width: 16),
              // Product info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: Theme.of(context).textTheme.titleMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '\$${product.price.toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              // Delete button
              if (onDelete != null)
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Hapus Product?'),
                        content: Text(
                          'Yakin ingin menghapus "${product.name}"?',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx),
                            child: const Text('Batal'),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(ctx);
                              onDelete!();
                            },
                            child: const Text(
                              'Hapus',
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}
```

```dart
// features/product/presentation/widgets/shimmer_product_list.dart
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerProductList extends StatelessWidget {
  const ShimmerProductList({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 6,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 16,
                          width: double.infinity,
                          color: Colors.white,
                        ),
                        const SizedBox(height: 8),
                        Container(
                          height: 14,
                          width: 80,
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
```

---

#### 4f. Shared Core Widgets

```dart
// lib/core/widgets/error_view.dart
import 'package:flutter/material.dart';

class ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const ErrorView({
    super.key,
    required this.message,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Coba Lagi'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// lib/core/widgets/empty_view.dart
import 'package:flutter/material.dart';

class EmptyView extends StatelessWidget {
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final IconData icon;

  const EmptyView({
    super.key,
    required this.message,
    this.actionLabel,
    this.onAction,
    this.icon = Icons.inbox_outlined,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.grey,
              ),
            ),
            if (onAction != null && actionLabel != null) ...[
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: onAction,
                child: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
```

---

### 5. Cubit Pattern (Untuk Fitur Sederhana)

**Description:** Untuk fitur yang tidak butuh events terpisah, pakai `Cubit` yang lebih sederhana.

```dart
// Contoh: ThemeCubit (toggle light/dark mode)
// features/settings/presentation/cubit/theme_cubit.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

part 'theme_state.dart';

@injectable
class ThemeCubit extends Cubit<ThemeState> {
  ThemeCubit() : super(const ThemeState(themeMode: ThemeMode.system));

  void setThemeMode(ThemeMode mode) {
    emit(ThemeState(themeMode: mode));
  }

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
| Testing          | Bisa test per-event                     | Test per-method          |
| Transformations  | Bisa pakai `EventTransformer` (debounce, throttle) | Tidak bisa |
| Verbosity        | Lebih verbose (3 files)                 | Lebih ringkas (2 files)  |

---

### 6. Testing Setup dengan bloc_test

**Description:** Setup unit testing untuk BLoC.

```dart
// test/features/product/presentation/bloc/product_bloc_test.dart
import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

// Mocks
class MockGetProducts extends Mock implements GetProducts {}
class MockGetProduct extends Mock implements GetProduct {}
class MockCreateProduct extends Mock implements CreateProduct {}
class MockDeleteProduct extends Mock implements DeleteProduct {}

void main() {
  late ProductBloc bloc;
  late MockGetProducts mockGetProducts;
  late MockGetProduct mockGetProduct;
  late MockCreateProduct mockCreateProduct;
  late MockDeleteProduct mockDeleteProduct;

  setUp(() {
    mockGetProducts = MockGetProducts();
    mockGetProduct = MockGetProduct();
    mockCreateProduct = MockCreateProduct();
    mockDeleteProduct = MockDeleteProduct();

    bloc = ProductBloc(
      getProducts: mockGetProducts,
      getProduct: mockGetProduct,
      createProduct: mockCreateProduct,
      deleteProduct: mockDeleteProduct,
    );
  });

  tearDown(() {
    bloc.close();
  });

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
      'emits [ProductLoading, ProductLoaded] when LoadProducts is added '
      'and getProducts returns success',
      build: () {
        when(() => mockGetProducts())
            .thenAnswer((_) async => Right(tProducts));
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
      'emits [ProductLoading, ProductError] when LoadProducts is added '
      'and getProducts returns failure',
      build: () {
        when(() => mockGetProducts()).thenAnswer(
          (_) async => const Left(ServerFailure(message: 'Server error')),
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

  group('DeleteProductEvent', () {
    blocTest<ProductBloc, ProductState>(
      'emits [ProductLoading, ProductDeleted] when delete succeeds',
      build: () {
        when(() => mockDeleteProduct('1'))
            .thenAnswer((_) async => const Right(null));
        return bloc;
      },
      act: (bloc) => bloc.add(const DeleteProductEvent(id: '1')),
      expect: () => [
        const ProductLoading(),
        const ProductDeleted(productId: '1'),
      ],
    );
  });
}
```

---

### 7. Perbandingan Pattern: BLoC vs Riverpod

**Quick Reference** untuk developer yang sudah familiar dengan salah satu pattern.

#### State Management Comparison

| Aspect                    | BLoC Pattern                                      | Riverpod Pattern                              |
|---------------------------|---------------------------------------------------|-----------------------------------------------|
| **State class**           | `sealed class ProductState extends Equatable`     | `AsyncValue<List<Product>>` (built-in)        |
| **Event dispatch**        | `bloc.add(LoadProducts())`                        | `ref.read(provider.notifier).load()`          |
| **State listen (UI)**     | `BlocBuilder<ProductBloc, ProductState>`          | `ref.watch(productProvider)`                  |
| **Side effects**          | `BlocListener<ProductBloc, ProductState>`         | `ref.listen(provider, ...)`                   |
| **Combined**              | `BlocConsumer` (Builder + Listener)               | `ConsumerWidget` + `ref.listen` in build      |
| **DI**                    | `get_it` + `injectable` + `BlocProvider`          | Built-in `Provider` / `@riverpod`             |
| **Global state**          | `MultiBlocProvider` di root                       | `ProviderScope` di root                       |
| **Scoped state**          | `BlocProvider` di level screen/route              | `ProviderScope` overrides                     |
| **Code generation**       | `injectable_generator` (DI), `freezed` (optional) | `riverpod_generator`, `freezed` (optional)    |
| **Testing**               | `bloc_test` package                               | Override providers di test                    |
| **Debugging**             | `BlocObserver` (global)                           | `ProviderObserver` (global)                   |

#### Code Mapping (Side by Side)

**Riverpod way:**
```dart
// Provider
@riverpod
class ProductController extends _$ProductController {
  @override
  FutureOr<List<Product>> build() async {
    final repo = ref.watch(productRepositoryProvider);
    final result = await repo.getProducts();
    return result.fold((f) => throw f, (data) => data);
  }
}

// UI
class ProductScreen extends ConsumerWidget {
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(productControllerProvider);
    return state.when(
      data: (products) => ListView(...),
      loading: () => ShimmerList(),
      error: (e, _) => ErrorView(error: e),
    );
  }
}
```

**BLoC way:**
```dart
// Bloc
class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final GetProducts _getProducts;
  ProductBloc(this._getProducts) : super(ProductInitial()) {
    on<LoadProducts>((event, emit) async {
      emit(ProductLoading());
      final result = await _getProducts();
      result.fold(
        (f) => emit(ProductError(message: f.message)),
        (data) => emit(ProductLoaded(products: data)),
      );
    });
  }
}

// UI
class ProductScreen extends StatelessWidget {
  Widget build(BuildContext context) {
    return BlocBuilder<ProductBloc, ProductState>(
      builder: (context, state) {
        return switch (state) {
          ProductLoaded(:final products) => ListView(...),
          ProductLoading() => ShimmerList(),
          ProductError(:final message) => ErrorView(message: message),
          _ => SizedBox.shrink(),
        };
      },
    );
  }
}
```

#### Kapan Pilih BLoC vs Riverpod

| Pilih BLoC jika...                                | Pilih Riverpod jika...                        |
|----------------------------------------------------|-----------------------------------------------|
| Tim sudah familiar dengan BLoC                     | Tim lebih suka functional/declarative style   |
| Butuh strict event-driven architecture             | Ingin less boilerplate                        |
| Perlu event transformations (debounce, throttle)   | Ingin DI built-in tanpa get_it               |
| Enterprise project dengan banyak developer         | Project kecil-menengah, butuh cepat           |
| Butuh clear separation events & states             | Prefer `AsyncValue` built-in loading/error    |
| Ingin `BlocObserver` untuk centralized logging     | Prefer granular provider-level control        |

---

## Workflow Steps

1. **Project Initialization**
   - Create Flutter project: `flutter create --empty my_app`
   - Add dependencies ke pubspec.yaml (lihat section 2)
   - Run `flutter pub get`
   - Setup folder structure (lihat section 1)

2. **Core Layer Setup**
   - Implement error handling classes (Failure, Exception)
   - Setup `get_it` + `injectable` DI
   - Setup `BlocObserver` untuk logging
   - Setup router dengan GoRouter
   - Configure secure storage (Hive)
   - Setup app theme

3. **Code Generation (DI)**
   - Run `dart run build_runner build --delete-conflicting-outputs`
   - Verify `injection.config.dart` generated

4. **Example Feature Implementation**
   - Create domain layer (entity, repository contract, use cases)
   - Create data layer (model, repository impl, data sources)
   - Create presentation layer:
     - Define Events (`product_event.dart`)
     - Define States (`product_state.dart`)
     - Implement Bloc (`product_bloc.dart`)
     - Create screens dengan `BlocBuilder` / `BlocConsumer`
   - Implement all states (initial, loading, loaded, error)
   - Handle side effects dengan `BlocListener`

5. **Root Widget Setup**
   - Setup `MultiBlocProvider` di `app.dart` untuk global blocs
   - Setup feature-specific `BlocProvider` di level route

6. **Testing Setup**
   - Write unit tests dengan `bloc_test`
   - Test setiap event handler
   - Verify state transitions

7. **Verification**
   - Run `flutter analyze` - pastikan clean
   - Run `flutter test` - pastikan passing
   - Run app dan test navigation manual
   - Verify BlocObserver logs di console

## Success Criteria

- [ ] Project structure mengikuti Clean Architecture
- [ ] Semua dependencies terinstall tanpa error
- [ ] `get_it` + `injectable` DI configured dan generated
- [ ] `BlocObserver` logging events/transitions
- [ ] **GoRouter configured dengan routes lengkap**
- [ ] **Route constants defined di routes.dart**
- [ ] **Auth guard implemented**
- [ ] Example Product feature lengkap:
  - [ ] Events: `LoadProducts`, `CreateProductEvent`, `DeleteProductEvent`
  - [ ] States: `ProductInitial`, `ProductLoading`, `ProductLoaded`, `ProductError`
  - [ ] `BlocBuilder` untuk UI rendering
  - [ ] `BlocListener` untuk side effects (snackbar, navigation)
  - [ ] Pattern matching pada sealed state classes
- [ ] `BlocProvider` di level route untuk feature-specific blocs
- [ ] `MultiBlocProvider` di root untuk global blocs
- [ ] Shimmer loading implemented
- [ ] **Navigation antar screens berfungsi**
- [ ] Code generation berjalan tanpa error
- [ ] `flutter analyze` tidak ada warning/error
- [ ] Unit tests passing dengan `bloc_test`
- [ ] App bisa build dan run

## Tools & Templates

- **Flutter Version:** 3.41.1+ (Tested on stable channel)
- **Dart Version:** 3.11.0+
- **State Management:** flutter_bloc 8.1+, bloc 8.1+
- **DI:** get_it 8.0+, injectable 2.5+
- **Routing:** GoRouter 14.0+
- **HTTP Client:** Dio 5.4+
- **Local Storage:** Hive 1.1+
- **Firebase:** Core 3.12+, Auth 5.5+, Firestore 5.6+ (Untuk Flutter 3.41.1)
- **Code Generation:** build_runner, freezed, json_serializable, injectable_generator
- **Testing:** bloc_test 9.1+, mocktail 1.0+

## Next Steps

Setelah workflow ini selesai, lanjut ke:
1. `02_feature_maker.md` - Untuk generate feature baru dengan BLoC pattern
2. `03_backend_integration.md` - Untuk API integration lengkap
3. `04_firebase_integration.md` - Untuk Firebase services
4. `05_supabase_integration.md` - Untuk Supabase integration

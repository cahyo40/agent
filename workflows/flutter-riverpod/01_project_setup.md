---
description: Setup Flutter project dari nol dengan Clean Architecture dan Riverpod state management.
---
# Workflow: Flutter Project Setup with Riverpod

// turbo-all

## Overview

Setup Flutter project dari nol dengan Clean Architecture pattern dan Riverpod
untuk state management. Mencakup folder structure, routing (GoRouter), theming,
error handling, DI, dan example feature implementation.


## Prerequisites

- Flutter SDK 3.41.1+ terinstall
- Dart SDK 3.11.0+
- IDE (VS Code / Android Studio) configured
- Target platform (Android/iOS/Web) siap


## Agent Behavior

- **Jangan tanya nama project** — gunakan nama folder saat ini atau buat dari
  context user.
- **Auto-detect platform** — check apakah user butuh Android, iOS, atau Web.
- **Jangan skip code generation** — selalu run `build_runner` setelah setup.
- **Gunakan latest stable versions** — cek pub.dev jika ragu versi terbaru.


## Recommended Skills

- `senior-flutter-developer` — Flutter + Riverpod patterns
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
dependencies:
  flutter:
    sdk: flutter
  flutter_localizations:
    sdk: flutter

  # State Management
  flutter_riverpod: ^2.5.1
  riverpod_annotation: ^2.3.5

  # Router
  go_router: ^14.0.0

  # Network
  dio: ^5.4.0
  connectivity_plus: ^6.0.0

  # Storage
  hive: ^4.0.0
  hive_flutter: ^1.1.0
  flutter_secure_storage: ^9.2.0

  # UI
  shimmer: ^3.0.0
  google_fonts: ^6.2.0
  cached_network_image: ^3.3.1

  # Utilities
  equatable: ^2.0.5
  intl: ^0.19.0
  logger: ^2.0.0
  uuid: ^4.3.3

  # Code Generation (runtime)
  freezed_annotation: ^2.4.1
  json_annotation: ^4.9.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^5.0.0

  # Code Generation
  build_runner: ^2.4.9
  riverpod_generator: ^2.4.0
  freezed: ^2.5.2
  json_serializable: ^6.8.0

  # Testing
  mocktail: ^1.0.3
```

```bash
flutter pub get
```

### Step 3: Setup Project Structure (Clean Architecture)

```
lib/
├── main.dart
├── bootstrap/
│   ├── bootstrap.dart
│   └── app.dart
├── core/
│   ├── config/
│   │   └── app_config.dart
│   ├── di/
│   │   └── providers.dart
│   ├── error/
│   │   ├── exceptions.dart
│   │   └── failures.dart
│   ├── network/
│   │   ├── dio_client.dart
│   │   └── network_info.dart
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
│   ├── utils/
│   │   └── extensions.dart
│   └── widgets/
│       └── (reusable widgets)
└── features/
    └── {feature_name}/
        ├── data/
        │   ├── datasources/
        │   ├── models/
        │   └── repositories/
        ├── domain/
        │   ├── entities/
        │   ├── repositories/
        │   └── usecases/
        └── presentation/
            ├── controllers/
            ├── screens/
            └── widgets/
```

### Step 4: Core Layer Setup

#### 4.1 Error Handling

```dart
// lib/core/error/exceptions.dart
class AppException implements Exception {
  final String message;
  final String? code;

  AppException(this.message, {this.code});
}

class ServerException extends AppException {
  ServerException([super.message = 'Server error']);
}

class CacheException extends AppException {
  CacheException([super.message = 'Cache error']);
}

// lib/core/error/failures.dart
abstract class Failure {
  final String message;
  const Failure(this.message);
}

class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Server failure']);
}

class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Cache failure']);
}

class NetworkFailure extends Failure {
  const NetworkFailure(
    [super.message = 'No internet connection'],
  );
}
```

#### 4.2 Router Setup (GoRouter)

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

  // Helper methods
  static String productDetailPath(String id) =>
      '/products/$id';
  static String productEditPath(String id) =>
      '/products/$id/edit';
}

// lib/core/router/app_router.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'routes.dart';
import 'guards/auth_guard.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final authGuard = AuthGuard(ref);

  return GoRouter(
    initialLocation: AppRoutes.home,
    debugLogDiagnostics: true,
    redirect: (context, state) =>
        authGuard.redirect(context, state),
    routes: [
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.register,
        builder: (context, state) =>
            const RegisterScreen(),
      ),
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: AppRoutes.products,
        builder: (context, state) =>
            const ProductListScreen(),
        routes: [
          GoRoute(
            path: 'create',
            builder: (context, state) =>
                const ProductCreateScreen(),
          ),
          GoRoute(
            path: ':id',
            builder: (context, state) {
              final id = state.pathParameters['id']!;
              return ProductDetailScreen(productId: id);
            },
            routes: [
              GoRoute(
                path: 'edit',
                builder: (context, state) {
                  final id =
                      state.pathParameters['id']!;
                  return ProductEditScreen(
                    productId: id,
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
        child: Text(
          'Page not found: ${state.uri.path}',
        ),
      ),
    ),
  );
});

// lib/core/router/guards/auth_guard.dart
class AuthGuard {
  final Ref _ref;

  AuthGuard(this._ref);

  String? redirect(
    BuildContext context,
    GoRouterState state,
  ) {
    final authState =
        _ref.read(authControllerProvider);
    final isAuthenticated =
        authState.valueOrNull != null;

    final isAuthRoute =
        state.uri.path == AppRoutes.login ||
            state.uri.path == AppRoutes.register ||
            state.uri.path == AppRoutes.forgotPassword;

    if (!isAuthenticated && !isAuthRoute) {
      return AppRoutes.login;
    }

    if (isAuthenticated && isAuthRoute) {
      return AppRoutes.home;
    }

    return null;
  }
}
```

#### 4.3 Theme Setup

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
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 12,
          ),
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
      scaffoldBackgroundColor:
          AppColors.darkBackground,
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
  static const Color primary = Color(0xFF1976D2);
  static const Color primaryLight =
      Color(0xFF63A4FF);
  static const Color primaryDark =
      Color(0xFF004BA0);

  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFA726);
  static const Color error = Color(0xFFE53935);
  static const Color info = Color(0xFF2196F3);

  static const Color background = Color(0xFFF5F5F5);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color onSurface = Color(0xFF212121);
  static const Color onBackground =
      Color(0xFF424242);

  static const Color darkBackground =
      Color(0xFF121212);
  static const Color darkSurface =
      Color(0xFF1E1E1E);
  static const Color darkOnSurface =
      Color(0xFFFFFFFF);
  static const Color darkOnBackground =
      Color(0xFFB0B0B0);
}

// lib/core/theme/typography.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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

#### 4.4 Bootstrap & App Entry Point

```dart
// lib/main.dart
import 'package:flutter/material.dart';
import 'bootstrap/bootstrap.dart';

void main() async {
  await bootstrap();
}

// lib/bootstrap/bootstrap.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';

Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    ProviderScope(child: const MyApp()),
  );
}

// lib/bootstrap/app.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/router/app_router.dart';
import '../core/theme/app_theme.dart';

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'My App',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: router,
    );
  }
}
```

### Step 5: Example Feature Implementation

```dart
// features/product/domain/entities/product.dart
class Product extends Equatable {
  final String id;
  final String name;
  final double price;

  const Product({
    required this.id,
    required this.name,
    required this.price,
  });

  @override
  List<Object?> get props => [id, name, price];
}

// features/product/domain/repositories/product_repository.dart
abstract class ProductRepository {
  Future<Result<List<Product>>> getProducts();
  Future<Result<Product>> getProduct(
    String id,
  );
}

// features/product/presentation/controllers/product_controller.dart
@riverpod
class ProductController extends _$ProductController {
  @override
  FutureOr<List<Product>> build() async {
    final repository =
        ref.watch(productRepositoryProvider);
    final result = await repository.getProducts();

    return result.fold(
      (failure) => throw failure,
      (products) => products,
    );
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository =
          ref.read(productRepositoryProvider);
      final result = await repository.getProducts();
      return result.dataOrNull ?? [];
    });
  }
}

// features/product/presentation/screens/product_list_screen.dart
class ProductListScreen extends ConsumerWidget {
  const ProductListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync =
        ref.watch(productControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Products'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () =>
                context.push(AppRoutes.profile),
          ),
        ],
      ),
      body: productsAsync.when(
        data: (products) => products.isEmpty
            ? const EmptyProductView()
            : ListView.builder(
                itemCount: products.length,
                itemBuilder: (context, index) {
                  final product = products[index];
                  return ListTile(
                    title: Text(product.name),
                    subtitle:
                        Text('\$${product.price}'),
                    onTap: () => context.push(
                      AppRoutes.productDetailPath(
                        product.id,
                      ),
                    ),
                  );
                },
              ),
        error: (error, _) => ErrorView(
          error: error,
          onRetry: () => ref
              .read(
                productControllerProvider.notifier,
              )
              .refresh(),
        ),
        loading: () => const ShimmerProductList(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () =>
            context.push(AppRoutes.productCreate),
        child: const Icon(Icons.add),
      ),
    );
  }
}
```

### Step 6: Dependency Injection Setup

```dart
// core/di/providers.dart
part 'providers.g.dart';

// API Client
@riverpod
Dio dio(DioRef ref) {
  final dio = Dio(BaseOptions(
    baseUrl: 'https://api.example.com',
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 15),
  ));

  dio.interceptors.addAll([
    AuthInterceptor(ref),
    LoggingInterceptor(),
  ]);

  return dio;
}

// Repositories
@riverpod
ProductRepository productRepository(
  ProductRepositoryRef ref,
) {
  return ProductRepositoryImpl(
    remoteDataSource:
        ref.watch(productRemoteDataSourceProvider),
    localDataSource:
        ref.watch(productLocalDataSourceProvider),
    networkInfo: ref.watch(networkInfoProvider),
  );
}
```

### Step 7: Code Generation

```bash
dart run build_runner build -d
```

### Step 8: Verify & Test

```bash
flutter analyze
flutter test
flutter run
```


## Success Criteria

- [ ] Project structure mengikuti Clean Architecture
- [ ] Semua dependencies terinstall tanpa error
- [ ] GoRouter configured dengan routes lengkap
- [ ] Route constants defined di `routes.dart`
- [ ] Auth guard implemented
- [ ] Example feature berjalan dengan semua states
- [ ] Navigation antar screens berfungsi
- [ ] Code generation berjalan tanpa error
- [ ] `flutter analyze` tidak ada warning/error
- [ ] App bisa build dan run
- [ ] Shimmer loading implemented


## Tools & Templates

- **Flutter Version:** 3.41.1+ (stable channel)
- **Dart Version:** 3.11.0+
- **State Management:** Riverpod 2.5+ dengan code generation
- **Routing:** GoRouter 14.0+
- **HTTP Client:** Dio 5.4+
- **Local Storage:** Hive 4.0+
- **Code Generation:** build_runner, freezed, riverpod_generator


## Next Steps

Setelah workflow ini selesai, lanjut ke:
1. `02_feature_maker.md` — Generate feature baru
2. `03_backend_integration.md` — API integration lengkap
3. `04_firebase_integration.md` — Firebase services
4. `05_supabase_integration.md` — Supabase integration

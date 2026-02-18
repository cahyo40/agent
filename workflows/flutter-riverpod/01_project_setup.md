# Workflow: Flutter Project Setup with Riverpod

## Overview

Setup Flutter project dari nol dengan Clean Architecture dan Riverpod state management. Workflow ini mencakup struktur folder lengkap, konfigurasi dependencies, dan contoh implementasi feature.

## Output Location

**Base Folder:** `sdlc/flutter-riverpod/01-project-setup/`

**Output Files:**
- `project-structure.md` - Dokumentasi struktur folder
- `pubspec.yaml` - Dependencies lengkap
- `lib/main.dart` - Entry point aplikasi
- `lib/bootstrap/app.dart` - Root widget dengan MaterialApp
- `lib/bootstrap/bootstrap.dart` - App initialization
- `lib/core/router/app_router.dart` - GoRouter configuration lengkap
- `lib/core/router/routes.dart` - Route definitions dan constants
- `lib/core/router/guards/auth_guard.dart` - Authentication route guard
- `lib/core/di/providers.dart` - Dependency injection providers
- `lib/core/error/` - Error handling classes
- `lib/core/theme/app_theme.dart` - App theme configuration
- `lib/features/example/` - Contoh feature lengkap (CRUD) dengan routing
- `lib/shared/` - Extensions, utils, shared widgets
- `README.md` - Setup instructions

## Prerequisites

- Flutter SDK 3.41.1+ (Tested on 3.41.1 stable)
- Dart 3.11.0+
- IDE (VS Code atau Android Studio)
- Git terinstall

## Deliverables

### 1. Project Structure Clean Architecture

**Description:** Struktur folder lengkap dengan Clean Architecture pattern.

**Recommended Skills:** `senior-flutter-developer`, `senior-ui-ux-designer`

**Instructions:**
1. Buat folder structure berikut:
   ```
   lib/
   ├── bootstrap/              # App initialization
   │   ├── app.dart           # Root widget
   │   ├── bootstrap.dart     # App bootstrapping
   │   └── observers/         # Riverpod observers
   ├── core/                  # Shared infrastructure
   │   ├── di/               # Dependency injection
   │   ├── error/            # Error handling
   │   ├── network/          # Dio setup, interceptors
   │   ├── router/           # GoRouter configuration
   │   ├── storage/          # Secure & local storage
   │   └── theme/            # App theme & colors
   ├── features/             # Feature modules
   │   └── example/          # Contoh feature
   │       ├── data/         # Data layer
   │       ├── domain/       # Domain layer
   │       └── presentation/ # Presentation layer
   ├── l10n/                 # Localization
   ├── shared/               # Shared utilities
   │   ├── extensions/
   │   ├── mixins/
   │   ├── utils/
   │   └── widgets/
   └── main.dart
   ```
2. Setup setiap folder dengan base files
3. Konfigurasi import alias di `pubspec.yaml`

**Output Format:**
```yaml
# pubspec.yaml
name: my_app
description: A new Flutter project.

publish_to: 'none'

version: 1.0.0+1

environment:
  sdk: '>=3.11.0 <4.0.0'  # Updated untuk Flutter 3.41.1

dependencies:
  flutter:
    sdk: flutter
  
  # State Management
  flutter_riverpod: ^2.5.1
  riverpod_annotation: ^2.3.5
  
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
  flutter_screenutil: ^5.9.0
  google_fonts: ^6.2.1
  
  # Utils
  freezed_annotation: ^2.4.1
  json_annotation: ^4.8.1
  intl: ^0.19.0
  equatable: ^2.0.5
  dartz: ^0.10.1
  
  # Firebase (optional) - Updated untuk Flutter 3.41.1
  # firebase_core: ^3.12.0
  # firebase_auth: ^5.5.0
  # cloud_firestore: ^5.6.0
  # firebase_storage: ^12.4.0
  # firebase_messaging: ^15.2.0
  
  # Supabase (optional)
  # supabase_flutter: ^2.8.0
  
dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^4.0.0
  build_runner: ^2.4.9
  freezed: ^2.5.0
  json_serializable: ^6.7.1
  riverpod_generator: ^2.4.0
  custom_lint: ^0.6.4
  riverpod_lint: ^2.3.10

flutter:
  uses-material-design: true
```

---

### 2. Core Layer Setup

**Description:** Setup core layer untuk DI, routing, error handling, dan storage.

**Recommended Skills:** `senior-flutter-developer`

**Instructions:**
1. **Error Handling:**
   - Buat `AppException` base class
   - Buat `Failure` classes (ServerFailure, CacheFailure, NetworkFailure)
   - Setup global error handler

2. **Router Setup dengan GoRouter:**
   - Konfigurasi GoRouter dengan routes
   - Setup route guards untuk authentication
   - Define route constants di `routes.dart`
   - Deep linking configuration
   - Error page untuk unknown routes

3. **Storage Setup:**
   - Secure storage untuk sensitive data
   - Local storage dengan Hive

4. **Theme Setup:**
   - Color palette
   - Typography scale
   - Component themes
   - Light & Dark theme support

**Output Format:**

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
  
  // Initialize dependencies
  // - Firebase/Supabase (if needed)
  // - Local storage
  // - etc.
  
  runApp(
    ProviderScope(
      child: const MyApp(),
    ),
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

// lib/core/router/app_router.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'routes.dart';
import 'guards/auth_guard.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/products/presentation/screens/product_list_screen.dart';
import '../../features/products/presentation/screens/product_detail_screen.dart';
import '../../features/products/presentation/screens/product_create_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final authGuard = AuthGuard(ref);
  
  return GoRouter(
    initialLocation: AppRoutes.home,
    debugLogDiagnostics: true,
    redirect: (context, state) => authGuard.redirect(context, state),
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
      
      // Product routes
      GoRoute(
        path: AppRoutes.products,
        builder: (context, state) => const ProductListScreen(),
        routes: [
          GoRoute(
            path: 'create',
            builder: (context, state) => const ProductCreateScreen(),
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
                  final id = state.pathParameters['id']!;
                  return ProductEditScreen(productId: id);
                },
              ),
            ],
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Page not found: ${state.uri.path}'),
      ),
    ),
  );
});

// lib/core/router/guards/auth_guard.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../routes.dart';
import '../../../features/auth/presentation/controllers/auth_controller.dart';

class AuthGuard {
  final Ref _ref;
  
  AuthGuard(this._ref);
  
  String? redirect(BuildContext context, GoRouterState state) {
    final authState = _ref.read(authControllerProvider);
    final isAuthenticated = authState.valueOrNull != null;
    
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
```dart
// core/error/exceptions.dart
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

// core/error/failures.dart
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
  const NetworkFailure([super.message = 'No internet connection']);
}
```

---

### 3. Example Feature Implementation

**Description:** Contoh feature lengkap dengan CRUD operations menggunakan Riverpod.

**Recommended Skills:** `senior-flutter-developer`

**Instructions:**
1. **Domain Layer:**
   - Buat `Product` entity
   - Buat `ProductRepository` abstract contract
   - Buat `GetProducts` use case

2. **Data Layer:**
   - Buat `ProductModel` dengan JSON serialization
   - Implement `ProductRepositoryImpl`
   - Setup remote & local data sources

3. **Presentation Layer:**
   - Buat `ProductController` dengan Riverpod
   - Buat `ProductListScreen` dengan states
   - Implement loading, error, empty, dan data states
   - **Implement navigation menggunakan GoRouter**

**Output Format:**
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
  Future<Either<Failure, List<Product>>> getProducts();
  Future<Either<Failure, Product>> getProduct(String id);
}

// features/product/presentation/controllers/product_controller.dart
@riverpod
class ProductController extends _$ProductController {
  @override
  FutureOr<List<Product>> build() async {
    final repository = ref.watch(productRepositoryProvider);
    final result = await repository.getProducts();
    
    return result.fold(
      (failure) => throw failure,
      (products) => products,
    );
  }
  
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(productRepositoryProvider);
      final result = await repository.getProducts();
      return result.getOrElse(() => []);
    });
  }
}

// features/product/presentation/screens/product_list_screen.dart
import 'package:go_router/go_router.dart';
import '../../../../core/router/routes.dart';

class ProductListScreen extends ConsumerWidget {
  const ProductListScreen({super.key});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(productControllerProvider);
    
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
      body: productsAsync.when(
        data: (products) => products.isEmpty
            ? const EmptyProductView()
            : ListView.builder(
                itemCount: products.length,
                itemBuilder: (context, index) {
                  final product = products[index];
                  return ListTile(
                    title: Text(product.name),
                    subtitle: Text('\$${product.price}'),
                    onTap: () => context.push(AppRoutes.productDetailPath(product.id)),
                  );
                },
              ),
        error: (error, _) => ErrorView(
          error: error,
          onRetry: () => ref.read(productControllerProvider.notifier).refresh(),
        ),
        loading: () => const ShimmerProductList(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push(AppRoutes.productCreate),
        child: const Icon(Icons.add),
      ),
    );
  }
}

// features/product/presentation/screens/product_detail_screen.dart
class ProductDetailScreen extends ConsumerWidget {
  final String productId;
  
  const ProductDetailScreen({super.key, required this.productId});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Detail'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => context.push(AppRoutes.productEditPath(productId)),
          ),
        ],
      ),
      body: Center(child: Text('Product ID: $productId')),
    );
  }
}
```

---

### 4. Dependencies Injection Setup

**Description:** Setup dependency injection dengan Riverpod.

**Recommended Skills:** `senior-flutter-developer`

**Instructions:**
1. Setup providers untuk:
   - API client (Dio)
   - Repositories
   - Use cases
   - Storage
   - Network info

2. Implement provider overrides untuk testing

**Output Format:**
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
  
  // Add interceptors
  dio.interceptors.addAll([
    AuthInterceptor(ref),
    LoggingInterceptor(),
  ]);
  
  return dio;
}

// Repositories
@riverpod
ProductRepository productRepository(ProductRepositoryRef ref) {
  return ProductRepositoryImpl(
    remoteDataSource: ref.watch(productRemoteDataSourceProvider),
    localDataSource: ref.watch(productLocalDataSourceProvider),
    networkInfo: ref.watch(networkInfoProvider),
  );
}
```

## Workflow Steps

1. **Project Initialization**
   - Create Flutter project
   - Add dependencies ke pubspec.yaml
   - Run `flutter pub get`
   - Setup folder structure

2. **Core Layer Setup**
   - Implement error handling classes
   - Setup router dengan GoRouter
   - Configure secure storage
   - Setup app theme

3. **Example Feature Implementation**
   - Create domain layer (entity, repository contract)
   - Create data layer (model, repository impl, data sources)
   - Create presentation layer (controller, screen, widgets)
   - Implement all states (loading, error, empty, data)

4. **DI Configuration**
   - Setup all providers
   - Configure interceptors
   - Setup repository injection

5. **Code Generation**
   - Run `dart run build_runner build -d`
   - Verify generated files

6. **Testing Setup**
   - Verify app runs without error
   - Test navigation
   - Test example feature

## Success Criteria

- [ ] Project structure mengikuti Clean Architecture
- [ ] Semua dependencies terinstall tanpa error
- [ ] **GoRouter configured dengan routes lengkap**
- [ ] **Route constants defined di routes.dart**
- [ ] **Auth guard implemented**
- [ ] Example feature berjalan dengan semua states (loading, error, empty, data)
- [ ] **Navigation antar screens berfungsi**
- [ ] **Deeplinking configured (optional)**
- [ ] Code generation berjalan tanpa error
- [ ] `flutter analyze` tidak ada warning/error
- [ ] App bisa build dan run
- [ ] Shimmer loading implemented

## Tools & Templates

- **Flutter Version:** 3.41.1+ (Tested on stable channel)
- **Dart Version:** 3.11.0+
- **State Management:** Riverpod 2.5+ dengan code generation
- **Routing:** GoRouter 14.0+
- **HTTP Client:** Dio 5.4+
- **Local Storage:** Hive 1.1+
- **Firebase:** Core 3.12+, Auth 5.5+, Firestore 5.6+ (Untuk Flutter 3.41.1)
- **Code Generation:** build_runner, freezed, riverpod_generator

## Next Steps

Setelah workflow ini selesai, lanjut ke:
1. `02_feature_maker.md` - Untuk generate feature baru
2. `03_backend_integration.md` - Untuk API integration lengkap
3. `04_firebase_integration.md` - Untuk Firebase services
4. `05_supabase_integration.md` - Untuk Supabase integration

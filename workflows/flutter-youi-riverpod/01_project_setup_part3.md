---
description: Setup Flutter project dari nol dengan Clean Architecture, Riverpod, dan YoUI. (Part 3/5)
---
# Workflow: Flutter Project Setup with Riverpod + YoUI + YoUI (Part 3/5)

> **Navigation:** This workflow is split into 5 parts.

## Deliverables

### 2. Core Layer Setup

**Description:** Setup core layer untuk DI, routing, error handling, storage, dan YoUI theme.

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

4. **YoUI Theme Setup:**
   - Integrasi YoUI design tokens
   - Color palette via YoUI
   - Typography scale via YoUI
   - Component themes (YoButton, YoCard, YoTextField)
   - Light & Dark theme support

**Output Format:**

```dart
// lib/core/theme/app_theme.dart
import 'package:flutter/material.dart';
import 'package:youi/youi.dart';
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
  // - Hive local storage
  // - Firebase/Supabase (if needed)
  // - Secure storage
  
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
    final isAuthenticated =
        authState.valueOrNull != null;
    
    final isAuthRoute =
        state.uri.path == AppRoutes.login ||
        state.uri.path == AppRoutes.register ||
        state.uri.path == AppRoutes.forgotPassword;
    
    // Redirect ke login jika belum authenticated
    if (!isAuthenticated && !isAuthRoute) {
      return AppRoutes.login;
    }
    
    // Redirect ke home jika sudah authenticated
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

class NetworkException extends AppException {
  NetworkException([super.message = 'No internet']);
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
  const NetworkFailure(
    [super.message = 'No internet connection'],
  );
}
```

---

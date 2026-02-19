---
description: Setup Flutter project dari nol dengan Clean Architecture dan BLoC state management. (Sub-part 2/2)
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




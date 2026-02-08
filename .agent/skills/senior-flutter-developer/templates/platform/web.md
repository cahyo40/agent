# Flutter Web Development

## Overview

Production-ready Flutter Web including responsive layouts, web renderers, SEO optimization, PWA configuration, and deployment.

## When to Use

- Building Flutter applications for web browsers
- Creating responsive layouts for desktop/tablet/mobile web
- Implementing PWA features (offline, installable)
- SEO optimization for Flutter web apps

---

## Web Renderers

```text
HTML Renderer          CanvasKit Renderer
├── Smaller (~1MB)     ├── Larger (~2.5MB)
├── Better SEO         ├── Pixel-perfect
├── Selectable text    ├── Consistent rendering
└── Text-heavy apps    └── Graphics-heavy apps
```

```bash
# Build with specific renderer
flutter build web --web-renderer html
flutter build web --web-renderer canvaskit
flutter run -d chrome --web-renderer html
```

---

## Responsive Layout

```dart
// Breakpoint System
abstract class Breakpoints {
  static const double mobile = 600;
  static const double tablet = 900;
  static const double desktop = 1200;
}

extension ResponsiveExtension on BuildContext {
  double get screenWidth => MediaQuery.sizeOf(this).width;
  bool get isMobile => screenWidth < Breakpoints.mobile;
  bool get isTablet => screenWidth >= Breakpoints.mobile && screenWidth < Breakpoints.desktop;
  bool get isDesktop => screenWidth >= Breakpoints.desktop;
  
  T responsive<T>({required T mobile, T? tablet, T? desktop}) {
    if (isDesktop) return desktop ?? tablet ?? mobile;
    if (isTablet) return tablet ?? mobile;
    return mobile;
  }
}

// Adaptive Layout Widget
class AdaptiveLayout extends StatelessWidget {
  final Widget mobileLayout;
  final Widget? tabletLayout;
  final Widget? desktopLayout;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= Breakpoints.desktop) {
          return desktopLayout ?? tabletLayout ?? mobileLayout;
        }
        if (constraints.maxWidth >= Breakpoints.mobile) {
          return tabletLayout ?? mobileLayout;
        }
        return mobileLayout;
      },
    );
  }
}
```

---

## URL Routing

```dart
import 'package:url_strategy/url_strategy.dart';

void main() {
  setPathUrlStrategy(); // Remove # from URLs
  runApp(const MyApp());
}

final appRouter = GoRouter(
  initialLocation: '/',
  errorBuilder: (context, state) => NotFoundScreen(path: state.uri.toString()),
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/products/:id',
      builder: (context, state) {
        final productId = state.pathParameters['id']!;
        return ProductDetailScreen(productId: productId);
      },
    ),
    GoRoute(
      path: '/search',
      builder: (context, state) {
        final query = state.uri.queryParameters['q'] ?? '';
        return SearchScreen(query: query);
      },
    ),
  ],
);
```

---

## SEO Optimization

```html
<!-- web/index.html -->
<head>
  <meta name="description" content="Your app description">
  <meta property="og:title" content="Your App Title">
  <meta property="og:description" content="Your app description">
  <meta property="og:image" content="https://yoursite.com/og-image.png">
</head>
```

```dart
// Dynamic meta tags per route
import 'package:seo_renderer/seo_renderer.dart';

class ProductDetailScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Seo.head(
      tags: [
        MetaTag(name: 'title', content: product.name),
        MetaTag(name: 'description', content: product.description),
      ],
      child: Scaffold(body: ProductContent(product: product)),
    );
  }
}

// Use SelectableText for SEO-important content
SelectableText('This text can be indexed by search engines')
```

---

## PWA Configuration

```json
// web/manifest.json
{
  "name": "My Flutter Web App",
  "short_name": "MyApp",
  "display": "standalone",
  "background_color": "#ffffff",
  "theme_color": "#2196F3",
  "icons": [
    {"src": "icons/Icon-192.png", "sizes": "192x192", "type": "image/png"},
    {"src": "icons/Icon-512.png", "sizes": "512x512", "type": "image/png"}
  ]
}
```

---

## Performance Optimization

```dart
// Deferred Loading for Large Components
import 'package:my_app/features/admin/admin_screen.dart' deferred as admin;

class AdminRoute extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: admin.loadLibrary(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return admin.AdminScreen();
        }
        return const CircularProgressIndicator();
      },
    );
  }
}
```

```bash
# Minimize bundle size
flutter build web --release --tree-shake-icons
flutter build web --release --split-debug-info=build/debug-info
```

---

## Deployment

```bash
# Firebase Hosting
flutter build web --release
firebase deploy --only hosting

# GitHub Pages
flutter build web --release --base-href /repo-name/
```

---

## Best Practices

### ✅ Do This

- ✅ Use `setPathUrlStrategy()` for clean URLs
- ✅ Implement responsive layouts with breakpoints
- ✅ Use `SelectableText` for SEO content
- ✅ Use deferred loading for large features
- ✅ Test on Chrome, Firefox, Safari, Edge

### ❌ Avoid This

- ❌ Don't use `dart:io` directly
- ❌ Don't ignore keyboard navigation
- ❌ Don't forget hover states for desktop
- ❌ Don't skip browser back button handling

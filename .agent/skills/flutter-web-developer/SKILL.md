---
name: flutter-web-developer
description: "Expert Flutter Web development including responsive layouts, web-specific rendering, PWA configuration, SEO optimization, and production deployment"
---

# Flutter Web Developer

## Overview

This skill transforms you into a specialized Flutter Web Developer who builds production-ready web applications using Flutter. You'll handle web-specific concerns like responsive layouts, SEO, PWA configuration, and optimal rendering strategies that differ significantly from mobile development.

## When to Use This Skill

- Use when building Flutter applications specifically for web
- Use when converting mobile Flutter apps to work on web
- Use when implementing responsive/adaptive layouts for desktop and web
- Use when configuring PWA features (service workers, manifest)
- Use when optimizing Flutter Web performance
- Use when deploying Flutter Web to hosting platforms
- Use when the user asks about Flutter web-specific issues

## How It Works

### Step 1: Web-Specific Project Configuration

```yaml
# pubspec.yaml - Web-optimized dependencies
name: my_web_app
description: Flutter Web Application

environment:
  sdk: '>=3.0.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter
  
  # Web-specific packages
  url_strategy: ^0.3.0          # Clean URLs (remove #)
  universal_html: ^2.2.4         # Web-safe HTML access
  flutter_web_plugins:
    sdk: flutter
  
  # Responsive layout
  responsive_framework: ^1.1.1   # Responsive breakpoints
  
  # SEO & Meta
  seo_renderer: ^0.8.1           # SEO for Flutter Web

dev_dependencies:
  flutter_test:
    sdk: flutter
  build_runner: ^2.4.6
```

### Step 2: Web Renderer Selection

```text
FLUTTER WEB RENDERERS
├── HTML Renderer
│   ├── Smaller download size (~1MB)
│   ├── Better text rendering
│   ├── Better SEO (text is selectable)
│   ├── Limited visual fidelity
│   └── Best for: Text-heavy apps, blogs, documentation
│
├── CanvasKit Renderer
│   ├── Larger download size (~2.5MB)
│   ├── Pixel-perfect rendering
│   ├── Consistent across browsers
│   ├── Better for complex graphics
│   └── Best for: Games, data viz, design tools
│
└── Auto (Default)
    └── Flutter chooses based on device
```

```bash
# Build with specific renderer
flutter build web --web-renderer html
flutter build web --web-renderer canvaskit
flutter build web --web-renderer auto  # default

# Run with specific renderer
flutter run -d chrome --web-renderer html
flutter run -d chrome --web-renderer canvaskit
```

### Step 3: Responsive Layout Architecture

```dart
// ════════════════════════════════════════════════════════════════════════════
// PATTERN 1: Breakpoint System
// ════════════════════════════════════════════════════════════════════════════

abstract class Breakpoints {
  static const double mobile = 600;
  static const double tablet = 900;
  static const double desktop = 1200;
  static const double largeDesktop = 1800;
}

extension ResponsiveExtension on BuildContext {
  double get screenWidth => MediaQuery.sizeOf(this).width;
  
  bool get isMobile => screenWidth < Breakpoints.mobile;
  bool get isTablet => screenWidth >= Breakpoints.mobile && screenWidth < Breakpoints.desktop;
  bool get isDesktop => screenWidth >= Breakpoints.desktop;
  
  T responsive<T>({
    required T mobile,
    T? tablet,
    T? desktop,
  }) {
    if (isDesktop) return desktop ?? tablet ?? mobile;
    if (isTablet) return tablet ?? mobile;
    return mobile;
  }
}

// ════════════════════════════════════════════════════════════════════════════
// PATTERN 2: Adaptive Layout Widget
// ════════════════════════════════════════════════════════════════════════════

class AdaptiveLayout extends StatelessWidget {
  const AdaptiveLayout({
    super.key,
    required this.mobileLayout,
    this.tabletLayout,
    this.desktopLayout,
  });

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

// ════════════════════════════════════════════════════════════════════════════
// PATTERN 3: Responsive Grid
// ════════════════════════════════════════════════════════════════════════════

class ResponsiveGrid extends StatelessWidget {
  const ResponsiveGrid({
    super.key,
    required this.children,
    this.mobileColumns = 1,
    this.tabletColumns = 2,
    this.desktopColumns = 4,
    this.spacing = 16,
  });

  final List<Widget> children;
  final int mobileColumns;
  final int tabletColumns;
  final int desktopColumns;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    final columns = context.responsive(
      mobile: mobileColumns,
      tablet: tabletColumns,
      desktop: desktopColumns,
    );

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        crossAxisSpacing: spacing,
        mainAxisSpacing: spacing,
        childAspectRatio: 1,
      ),
      itemCount: children.length,
      itemBuilder: (context, index) => children[index],
    );
  }
}
```

### Step 4: URL Routing for Web

```dart
// ════════════════════════════════════════════════════════════════════════════
// Clean URLs (Remove # from URL)
// ════════════════════════════════════════════════════════════════════════════

// main.dart
import 'package:url_strategy/url_strategy.dart';

void main() {
  // Remove # from URLs
  setPathUrlStrategy();
  runApp(const MyApp());
}

// ════════════════════════════════════════════════════════════════════════════
// GoRouter Configuration for Web
// ════════════════════════════════════════════════════════════════════════════

final appRouter = GoRouter(
  initialLocation: '/',
  debugLogDiagnostics: true,
  
  // Handle unknown routes
  errorBuilder: (context, state) => NotFoundScreen(
    path: state.uri.toString(),
  ),
  
  routes: [
    GoRoute(
      path: '/',
      name: 'home',
      builder: (context, state) => const HomeScreen(),
    ),
    
    // Dynamic route with URL parameter
    GoRoute(
      path: '/products/:id',
      name: 'product-detail',
      builder: (context, state) {
        final productId = state.pathParameters['id']!;
        return ProductDetailScreen(productId: productId);
      },
    ),
    
    // Query parameters
    GoRoute(
      path: '/search',
      name: 'search',
      builder: (context, state) {
        final query = state.uri.queryParameters['q'] ?? '';
        final category = state.uri.queryParameters['category'];
        return SearchScreen(query: query, category: category);
      },
    ),
    
    // Nested routes (shell route for persistent layout)
    ShellRoute(
      builder: (context, state, child) {
        return DashboardShell(child: child);
      },
      routes: [
        GoRoute(
          path: '/dashboard',
          name: 'dashboard',
          builder: (context, state) => const DashboardHome(),
          routes: [
            GoRoute(
              path: 'settings',
              name: 'settings',
              builder: (context, state) => const SettingsScreen(),
            ),
            GoRoute(
              path: 'profile',
              name: 'profile',
              builder: (context, state) => const ProfileScreen(),
            ),
          ],
        ),
      ],
    ),
  ],
  
  // Redirect logic
  redirect: (context, state) {
    final isLoggedIn = /* check auth state */;
    final isLoginRoute = state.matchedLocation == '/login';
    
    if (!isLoggedIn && !isLoginRoute) {
      return '/login?redirect=${state.uri}';
    }
    if (isLoggedIn && isLoginRoute) {
      return '/dashboard';
    }
    return null;
  },
);

// ════════════════════════════════════════════════════════════════════════════
// Navigation with URL updates
// ════════════════════════════════════════════════════════════════════════════

// Push new route (adds to history)
context.push('/products/123');

// Go to route (replaces current)
context.go('/dashboard');

// Navigate with query params
context.goNamed(
  'search',
  queryParameters: {'q': 'flutter', 'category': 'web'},
);

// Pop with result
context.pop(result);
```

### Step 5: SEO Optimization

```dart
// ════════════════════════════════════════════════════════════════════════════
// Meta Tags for SEO
// ════════════════════════════════════════════════════════════════════════════

// web/index.html - Base meta tags
/*
<head>
  <base href="$FLUTTER_BASE_HREF">
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  
  <!-- SEO Meta Tags -->
  <meta name="description" content="Your app description here">
  <meta name="keywords" content="flutter, web, app">
  <meta name="author" content="Your Name">
  
  <!-- Open Graph for Social Sharing -->
  <meta property="og:title" content="Your App Title">
  <meta property="og:description" content="Your app description">
  <meta property="og:image" content="https://yoursite.com/og-image.png">
  <meta property="og:url" content="https://yoursite.com">
  <meta property="og:type" content="website">
  
  <!-- Twitter Card -->
  <meta name="twitter:card" content="summary_large_image">
  <meta name="twitter:title" content="Your App Title">
  <meta name="twitter:description" content="Your app description">
  <meta name="twitter:image" content="https://yoursite.com/twitter-image.png">
  
  <title>Your App Title</title>
</head>
*/

// ════════════════════════════════════════════════════════════════════════════
// Dynamic Meta Tags per Route
// ════════════════════════════════════════════════════════════════════════════

import 'package:seo_renderer/seo_renderer.dart';

class ProductDetailScreen extends StatelessWidget {
  final Product product;

  @override
  Widget build(BuildContext context) {
    return Seo.head(
      tags: [
        MetaTag(name: 'title', content: product.name),
        MetaTag(name: 'description', content: product.description),
        MetaTag(property: 'og:title', content: product.name),
        MetaTag(property: 'og:description', content: product.description),
        MetaTag(property: 'og:image', content: product.imageUrl),
      ],
      child: Scaffold(
        body: ProductContent(product: product),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// Semantic HTML for Accessibility & SEO
// ════════════════════════════════════════════════════════════════════════════

Semantics(
  header: true, // This is a heading
  label: 'Product Title',
  child: Text(
    product.name,
    style: Theme.of(context).textTheme.headlineLarge,
  ),
)

// Use SelectableText for selectable/indexable content
SelectableText(
  'This text can be selected and indexed by search engines',
  style: TextStyle(fontSize: 16),
)
```

### Step 6: PWA Configuration

```json
// web/manifest.json
{
  "name": "My Flutter Web App",
  "short_name": "MyApp",
  "description": "A Flutter Web Application",
  "start_url": "/",
  "display": "standalone",
  "background_color": "#ffffff",
  "theme_color": "#2196F3",
  "orientation": "any",
  "icons": [
    {
      "src": "icons/Icon-192.png",
      "sizes": "192x192",
      "type": "image/png"
    },
    {
      "src": "icons/Icon-512.png",
      "sizes": "512x512",
      "type": "image/png"
    },
    {
      "src": "icons/Icon-maskable-192.png",
      "sizes": "192x192",
      "type": "image/png",
      "purpose": "maskable"
    },
    {
      "src": "icons/Icon-maskable-512.png",
      "sizes": "512x512",
      "type": "image/png",
      "purpose": "maskable"
    }
  ]
}
```

```javascript
// web/flutter_service_worker.js is auto-generated
// For custom caching, modify web/index.html:

<script>
  // Service Worker registration
  if ('serviceWorker' in navigator) {
    window.addEventListener('flutter-first-frame', function () {
      navigator.serviceWorker.register('flutter_service_worker.js?v=' + serviceWorkerVersion);
    });
  }
</script>
```

### Step 7: Platform Detection & Conditional Code

```dart
// ════════════════════════════════════════════════════════════════════════════
// Platform Detection
// ════════════════════════════════════════════════════════════════════════════

import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;

class PlatformUtils {
  static bool get isWeb => kIsWeb;
  
  static bool get isMobileWeb {
    if (!kIsWeb) return false;
    // Check user agent for mobile
    final userAgent = window.navigator.userAgent.toLowerCase();
    return userAgent.contains('mobile') || userAgent.contains('android');
  }
  
  static bool get isDesktopWeb {
    if (!kIsWeb) return false;
    return !isMobileWeb;
  }
}

// ════════════════════════════════════════════════════════════════════════════
// Conditional Imports (Web vs Mobile)
// ════════════════════════════════════════════════════════════════════════════

// file_picker_stub.dart
FilePickerResult? pickFile() => throw UnimplementedError();

// file_picker_web.dart
import 'dart:html' as html;

Future<FilePickerResult?> pickFile() async {
  final input = html.FileUploadInputElement();
  input.click();
  await input.onChange.first;
  return FilePickerResult(input.files!);
}

// file_picker_mobile.dart
import 'package:file_picker/file_picker.dart';

Future<FilePickerResult?> pickFile() async {
  return FilePicker.platform.pickFiles();
}

// file_picker.dart (conditional export)
export 'file_picker_stub.dart'
    if (dart.library.html) 'file_picker_web.dart'
    if (dart.library.io) 'file_picker_mobile.dart';
```

### Step 8: Web Performance Optimization

```dart
// ════════════════════════════════════════════════════════════════════════════
// Deferred Loading for Large Components
// ════════════════════════════════════════════════════════════════════════════

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
        return const Center(child: CircularProgressIndicator());
      },
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// Image Optimization for Web
// ════════════════════════════════════════════════════════════════════════════

Image.network(
  imageUrl,
  // Lazy loading
  loadingBuilder: (context, child, loadingProgress) {
    if (loadingProgress == null) return child;
    return Center(
      child: CircularProgressIndicator(
        value: loadingProgress.expectedTotalBytes != null
            ? loadingProgress.cumulativeBytesLoaded /
                loadingProgress.expectedTotalBytes!
            : null,
      ),
    );
  },
  // Error handling
  errorBuilder: (context, error, stackTrace) {
    return const Icon(Icons.error);
  },
  // Cache hints
  cacheWidth: 800, // Resize for memory efficiency
  cacheHeight: 600,
)

// ════════════════════════════════════════════════════════════════════════════
// Minimize Initial Bundle Size
// ════════════════════════════════════════════════════════════════════════════

// flutter build web --release --tree-shake-icons
// This removes unused icons from the bundle

// Use --split-debug-info for smaller main.dart.js
// flutter build web --release --split-debug-info=build/debug-info
```

### Step 9: Web Deployment

```yaml
# Firebase Hosting - firebase.json
{
  "hosting": {
    "public": "build/web",
    "ignore": [
      "firebase.json",
      "**/.*",
      "**/node_modules/**"
    ],
    "rewrites": [
      {
        "source": "**",
        "destination": "/index.html"
      }
    ],
    "headers": [
      {
        "source": "**/*.@(js|css)",
        "headers": [
          {
            "key": "Cache-Control",
            "value": "max-age=31536000"
          }
        ]
      }
    ]
  }
}
```

```bash
# Build and deploy to Firebase
flutter build web --release --web-renderer canvaskit
firebase deploy --only hosting

# Deploy to Vercel
# vercel.json
{
  "rewrites": [
    { "source": "/(.*)", "destination": "/index.html" }
  ],
  "headers": [
    {
      "source": "/(.*).js",
      "headers": [{ "key": "Cache-Control", "value": "max-age=31536000" }]
    }
  ]
}

# Deploy to GitHub Pages
# .github/workflows/deploy.yml
name: Deploy to GitHub Pages
on:
  push:
    branches: [main]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.x'
      - run: flutter pub get
      - run: flutter build web --release --base-href /repo-name/
      - uses: peaceiris/actions-gh-pages@v3
        with:
          github_token: ${{ secrets.GITHUB_TOKEN }}
          publish_dir: ./build/web
```

### Step 10: Web-Specific Testing

```dart
// ════════════════════════════════════════════════════════════════════════════
// Integration Tests for Web
// ════════════════════════════════════════════════════════════════════════════

// integration_test/web_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Navigation works correctly', (tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    // Verify initial route
    expect(find.text('Home'), findsOneWidget);

    // Navigate to products
    await tester.tap(find.text('Products'));
    await tester.pumpAndSettle();

    expect(find.text('Product List'), findsOneWidget);
  });

  testWidgets('Responsive layout adapts', (tester) async {
    // Test mobile layout
    tester.binding.window.physicalSizeTestValue = const Size(400, 800);
    tester.binding.window.devicePixelRatioTestValue = 1.0;

    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    expect(find.byType(MobileNavigation), findsOneWidget);

    // Test desktop layout
    tester.binding.window.physicalSizeTestValue = const Size(1400, 900);
    await tester.pumpAndSettle();

    expect(find.byType(DesktopSidebar), findsOneWidget);

    // Reset
    tester.binding.window.clearPhysicalSizeTestValue();
  });
}

// Run web tests
// flutter drive --driver=test_driver/integration_test.dart \
//   --target=integration_test/web_test.dart -d chrome
```

## Best Practices

### ✅ Do This

- ✅ Use `setPathUrlStrategy()` for clean URLs (no #)
- ✅ Implement responsive layouts with breakpoints
- ✅ Use `SelectableText` for SEO-important content
- ✅ Configure proper meta tags for social sharing
- ✅ Use deferred loading for large features
- ✅ Test on multiple browsers (Chrome, Firefox, Safari, Edge)
- ✅ Implement proper 404 handling for direct URL access
- ✅ Use semantic widgets for accessibility
- ✅ Cache static assets with proper headers
- ✅ Choose renderer based on use case (HTML vs CanvasKit)

### ❌ Avoid This

- ❌ Don't use `dart:io` directly (use conditional imports)
- ❌ Don't ignore keyboard navigation (Tab, Enter, Escape)
- ❌ Don't forget hover states for desktop users
- ❌ Don't skip right-click context menu handling
- ❌ Don't use fixed sizes (use responsive units)
- ❌ Don't load all features upfront (use code splitting)
- ❌ Don't forget browser back button handling
- ❌ Don't ignore text scaling for accessibility

## Common Pitfalls

**Problem:** App shows blank screen on direct URL access
**Solution:** Configure server rewrites to serve index.html for all routes

**Problem:** Images not loading on web
**Solution:** Ensure CORS is configured on your image server, or use proxy

**Problem:** Text not selectable on web
**Solution:** Use `SelectableText` instead of `Text` for important content

**Problem:** Slow initial load
**Solution:** Use HTML renderer for text apps, implement code splitting, optimize images

**Problem:** Different behavior across browsers
**Solution:** Test on all major browsers, use CanvasKit for consistent rendering

## Production Checklist

```markdown
### Pre-Launch
- [ ] Clean URLs configured (no #)
- [ ] SEO meta tags configured
- [ ] Open Graph images created (1200x630)
- [ ] Favicon and PWA icons generated
- [ ] manifest.json configured
- [ ] Service worker tested

### Performance
- [ ] Appropriate renderer selected (HTML/CanvasKit)
- [ ] Deferred loading for large features
- [ ] Images optimized and lazy-loaded
- [ ] Bundle size analyzed
- [ ] Lighthouse score > 90

### Compatibility
- [ ] Tested on Chrome, Firefox, Safari, Edge
- [ ] Tested on mobile browsers
- [ ] Keyboard navigation works
- [ ] Screen reader compatible
- [ ] Works with browser extensions

### Deployment
- [ ] Server rewrites configured
- [ ] HTTPS enabled
- [ ] Caching headers configured
- [ ] 404 page implemented
- [ ] Analytics integrated
```

## Related Skills

- `@senior-flutter-developer` - For mobile-specific Flutter patterns
- `@pwa-developer` - For advanced PWA features
- `@senior-webperf-engineer` - For web performance optimization
- `@senior-seo-auditor` - For comprehensive SEO strategy
- `@senior-web-deployment-specialist` - For advanced deployment configurations

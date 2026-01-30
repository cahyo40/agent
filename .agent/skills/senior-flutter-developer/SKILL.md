---
name: senior-flutter-developer
description: "Expert Flutter development with clean architecture, advanced Riverpod patterns, performance optimization, and production-ready mobile applications"
---

# Senior Flutter Developer

## Overview

This skill transforms you into a Staff-level Flutter Developer who architects and builds enterprise-grade mobile applications. You'll design scalable architectures, implement advanced state management patterns, optimize performance, and lead technical decisions.

## When to Use This Skill

- Use when architecting Flutter applications from scratch
- Use when implementing complex state management
- Use when optimizing app performance
- Use when reviewing code and mentoring
- Use when debugging complex issues
- Use when implementing advanced features

## How It Works

### Step 1: Enterprise Project Architecture

```text
lib/
├── bootstrap/                 # App initialization
│   ├── app.dart               # Root widget
│   ├── bootstrap.dart         # App bootstrapping
│   └── observers/             # Bloc/Provider observers
├── core/
│   ├── di/                    # Dependency injection setup
│   ├── error/
│   │   ├── exceptions.dart    # Custom exceptions
│   │   ├── failures.dart      # Domain failures
│   │   └── error_handler.dart # Global error handling
│   ├── network/
│   │   ├── api_client.dart    # Dio setup
│   │   ├── interceptors/      # Auth, logging, retry
│   │   └── network_info.dart  # Connectivity
│   ├── router/
│   │   ├── app_router.dart    # GoRouter config
│   │   ├── guards/            # Route guards
│   │   └── routes.dart        # Route definitions
│   ├── storage/
│   │   ├── secure_storage.dart
│   │   └── local_storage.dart
│   └── theme/
│       ├── app_theme.dart
│       ├── colors.dart
│       └── typography.dart
├── features/
│   └── <feature>/
│       ├── data/
│       │   ├── datasources/
│       │   │   ├── <feature>_remote_ds.dart
│       │   │   └── <feature>_local_ds.dart
│       │   ├── models/
│       │   │   └── <entity>_model.dart
│       │   └── repositories/
│       │       └── <feature>_repository_impl.dart
│       ├── domain/
│       │   ├── entities/
│       │   ├── repositories/  # Abstract contracts
│       │   └── usecases/
│       └── presentation/
│           ├── controllers/   # Riverpod controllers
│           ├── screens/
│           └── widgets/
├── l10n/                      # Localization
│   ├── app_en.arb
│   └── app_id.arb
├── shared/
│   ├── extensions/
│   ├── mixins/
│   ├── utils/
│   └── widgets/
└── main.dart
```

### Step 2: Advanced Riverpod Patterns

```dart
// ════════════════════════════════════════════════════════════════════════════
// PATTERN 1: Family Providers with Caching
// ════════════════════════════════════════════════════════════════════════════

@riverpod
class ProductDetail extends _$ProductDetail {
  @override
  Future<Product> build(String productId) async {
    // Auto-dispose after 5 minutes of inactivity
    ref.keepAlive();
    final timer = Timer(const Duration(minutes: 5), ref.invalidateSelf);
    ref.onDispose(timer.cancel);

    return ref.read(productRepositoryProvider).getProduct(productId);
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(productRepositoryProvider).getProduct(arg),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// PATTERN 2: Computed Providers with Select
// ════════════════════════════════════════════════════════════════════════════

@riverpod
int cartItemCount(CartItemCountRef ref) {
  return ref.watch(cartControllerProvider.select((cart) => cart.items.length));
}

@riverpod
double cartTotal(CartTotalRef ref) {
  final items = ref.watch(cartControllerProvider.select((c) => c.items));
  return items.fold(0, (sum, item) => sum + (item.price * item.quantity));
}

// Usage in widget (only rebuilds when count changes)
Consumer(
  builder: (context, ref, _) {
    final count = ref.watch(cartItemCountProvider);
    return Badge(label: Text('$count'));
  },
)

// ════════════════════════════════════════════════════════════════════════════
// PATTERN 3: AsyncNotifier with Optimistic Updates
// ════════════════════════════════════════════════════════════════════════════

@riverpod
class TodoList extends _$TodoList {
  @override
  Future<List<Todo>> build() async {
    return ref.read(todoRepositoryProvider).getTodos();
  }

  Future<void> toggleComplete(Todo todo) async {
    final updatedTodo = todo.copyWith(isComplete: !todo.isComplete);
    
    // Optimistic update
    state = AsyncData([
      for (final t in state.valueOrNull ?? [])
        if (t.id == todo.id) updatedTodo else t,
    ]);

    try {
      await ref.read(todoRepositoryProvider).updateTodo(updatedTodo);
    } catch (e) {
      // Rollback on failure
      state = AsyncData([
        for (final t in state.valueOrNull ?? [])
          if (t.id == todo.id) todo else t,
      ]);
      rethrow;
    }
  }
}

// ════════════════════════════════════════════════════════════════════════════
// PATTERN 4: Multi-Provider Composition
// ════════════════════════════════════════════════════════════════════════════

@riverpod
Future<DashboardData> dashboard(DashboardRef ref) async {
  // Parallel fetching with error handling per request
  final results = await Future.wait([
    ref.watch(userProfileProvider.future).then((v) => ('user', v, null))
        .catchError((e) => ('user', null, e)),
    ref.watch(recentOrdersProvider.future).then((v) => ('orders', v, null))
        .catchError((e) => ('orders', null, e)),
    ref.watch(notificationsProvider.future).then((v) => ('notifs', v, null))
        .catchError((e) => ('notifs', null, e)),
  ]);

  return DashboardData(
    user: results[0].$2 as UserProfile?,
    orders: results[1].$2 as List<Order>?,
    notifications: results[2].$2 as List<Notification>?,
    errors: results.where((r) => r.$3 != null).map((r) => r.$1).toList(),
  );
}
```

### Step 3: Repository Pattern with Offline-First

```dart
// ════════════════════════════════════════════════════════════════════════════
// Abstract Repository Contract (Domain Layer)
// ════════════════════════════════════════════════════════════════════════════

abstract interface class ProductRepository {
  Future<Either<Failure, List<Product>>> getProducts();
  Future<Either<Failure, Product>> getProduct(String id);
  Stream<List<Product>> watchProducts();
}

// ════════════════════════════════════════════════════════════════════════════
// Implementation with Offline-First Strategy (Data Layer)
// ════════════════════════════════════════════════════════════════════════════

class ProductRepositoryImpl implements ProductRepository {
  ProductRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
    required this.syncQueue,
  });

  final ProductRemoteDataSource remoteDataSource;
  final ProductLocalDataSource localDataSource;
  final NetworkInfo networkInfo;
  final SyncQueue syncQueue;

  @override
  Future<Either<Failure, List<Product>>> getProducts() async {
    // Strategy: Return local first, sync in background
    try {
      final localProducts = await localDataSource.getProducts();
      
      // Background sync if online
      if (await networkInfo.isConnected) {
        _syncInBackground();
      }

      return Right(localProducts.map((m) => m.toEntity()).toList());
    } on CacheException catch (e) {
      // No local data, try remote
      if (await networkInfo.isConnected) {
        return _fetchFromRemote();
      }
      return Left(CacheFailure(e.message));
    }
  }

  Future<void> _syncInBackground() async {
    try {
      final remoteProducts = await remoteDataSource.getProducts();
      await localDataSource.cacheProducts(remoteProducts);
    } catch (_) {
      // Silent fail for background sync
    }
  }

  @override
  Stream<List<Product>> watchProducts() {
    return localDataSource.watchProducts().map(
      (models) => models.map((m) => m.toEntity()).toList(),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// Either Pattern for Error Handling
// ════════════════════════════════════════════════════════════════════════════

sealed class Either<L, R> {
  const Either();
  
  T fold<T>(T Function(L) onLeft, T Function(R) onRight);
  Either<L, T> map<T>(T Function(R) f);
  Future<Either<L, T>> mapAsync<T>(Future<T> Function(R) f);
}

class Left<L, R> extends Either<L, R> { ... }
class Right<L, R> extends Either<L, R> { ... }

// Usage in Controller
Future<void> loadProducts() async {
  state = const AsyncLoading();
  final result = await ref.read(productRepositoryProvider).getProducts();
  
  state = result.fold(
    (failure) => AsyncError(failure, StackTrace.current),
    (products) => AsyncData(products),
  );
}
```

### Step 4: Performance Optimization

```dart
// ════════════════════════════════════════════════════════════════════════════
// OPTIMIZATION 1: Slivers for Complex Scrolling
// ════════════════════════════════════════════════════════════════════════════

class ProductListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        const SliverAppBar(
          floating: true,
          title: Text('Products'),
        ),
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.7,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) => ProductCard(product: products[index]),
              childCount: products.length,
            ),
          ),
        ),
      ],
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// OPTIMIZATION 2: RepaintBoundary for Complex Widgets
// ════════════════════════════════════════════════════════════════════════════

class ExpensiveWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: CustomPaint(
        painter: ComplexChartPainter(data: chartData),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// OPTIMIZATION 3: Isolate for Heavy Computation
// ════════════════════════════════════════════════════════════════════════════

Future<List<ProcessedData>> processLargeDataset(List<RawData> data) async {
  return compute(_processInBackground, data);
}

List<ProcessedData> _processInBackground(List<RawData> data) {
  return data
      .where((d) => d.isValid)
      .map((d) => ProcessedData.fromRaw(d))
      .toList()
    ..sort((a, b) => b.score.compareTo(a.score));
}

// ════════════════════════════════════════════════════════════════════════════
// OPTIMIZATION 4: Image Caching & Precaching
// ════════════════════════════════════════════════════════════════════════════

class OptimizedImage extends StatelessWidget {
  const OptimizedImage({required this.url, this.width, this.height});
  
  final String url;
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: url,
      width: width,
      height: height,
      memCacheWidth: width?.toInt(),
      memCacheHeight: height?.toInt(),
      fadeInDuration: const Duration(milliseconds: 200),
      placeholder: (_, __) => const ShimmerPlaceholder(),
      errorWidget: (_, __, ___) => const Icon(Icons.error),
    );
  }
}

// Precache images in initState or provider
Future<void> precacheProductImages(List<Product> products) async {
  final context = navigatorKey.currentContext!;
  await Future.wait(
    products.take(10).map((p) => 
      precacheImage(CachedNetworkImageProvider(p.imageUrl), context)
    ),
  );
}
```

### Step 5: Testing Strategy

```dart
// ════════════════════════════════════════════════════════════════════════════
// Unit Test: Repository with Mocks
// ════════════════════════════════════════════════════════════════════════════

@GenerateMocks([ProductRemoteDataSource, ProductLocalDataSource, NetworkInfo])
void main() {
  late ProductRepositoryImpl repository;
  late MockProductRemoteDataSource mockRemote;
  late MockProductLocalDataSource mockLocal;
  late MockNetworkInfo mockNetworkInfo;

  setUp(() {
    mockRemote = MockProductRemoteDataSource();
    mockLocal = MockProductLocalDataSource();
    mockNetworkInfo = MockNetworkInfo();
    
    repository = ProductRepositoryImpl(
      remoteDataSource: mockRemote,
      localDataSource: mockLocal,
      networkInfo: mockNetworkInfo,
      syncQueue: MockSyncQueue(),
    );
  });

  group('getProducts', () {
    test('should return cached data when local data exists', () async {
      // Arrange
      when(mockLocal.getProducts()).thenAnswer((_) async => [tProductModel]);
      when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);

      // Act
      final result = await repository.getProducts();

      // Assert
      expect(result, isA<Right<Failure, List<Product>>>());
      verify(mockLocal.getProducts()).called(1);
    });

    test('should fetch remote when cache is empty and online', () async {
      // Arrange
      when(mockLocal.getProducts()).thenThrow(CacheException('Empty'));
      when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(mockRemote.getProducts()).thenAnswer((_) async => [tProductModel]);

      // Act
      final result = await repository.getProducts();

      // Assert
      expect(result, isA<Right<Failure, List<Product>>>());
      verify(mockRemote.getProducts()).called(1);
    });
  });
}

// ════════════════════════════════════════════════════════════════════════════
// Widget Test: Screen with Provider Overrides
// ════════════════════════════════════════════════════════════════════════════

void main() {
  testWidgets('ProductListScreen shows products', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          productsControllerProvider.overrideWith(
            () => MockProductsController(),
          ),
        ],
        child: const MaterialApp(home: ProductListScreen()),
      ),
    );

    // Loading state
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.pumpAndSettle();

    // Data state
    expect(find.byType(ProductCard), findsNWidgets(3));
    expect(find.text('Product 1'), findsOneWidget);
  });
}

// ════════════════════════════════════════════════════════════════════════════
// Golden Test: Visual Regression
// ════════════════════════════════════════════════════════════════════════════

void main() {
  testWidgets('ProductCard matches golden', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 200,
              child: ProductCard(product: tProduct),
            ),
          ),
        ),
      ),
    );

    await expectLater(
      find.byType(ProductCard),
      matchesGoldenFile('goldens/product_card.png'),
    );
  });
}
```

## Best Practices

### ✅ Do This

- ✅ Design for testability from the start
- ✅ Use dependency injection consistently
- ✅ Implement proper error boundaries
- ✅ Use `select` to minimize rebuilds
- ✅ Profile with DevTools before optimization
- ✅ Implement feature flags for gradual rollout
- ✅ Use code generation (freezed, riverpod_generator)
- ✅ Write migration strategy for breaking changes

### ❌ Avoid This

- ❌ Don't over-engineer simple features
- ❌ Don't ignore memory leaks in streams
- ❌ Don't skip integration tests
- ❌ Don't hardcode environment values
- ❌ Don't use BuildContext after async gaps
- ❌ Don't block UI thread with heavy computation

## Production Checklist

```markdown
### Pre-Release
- [ ] ProGuard/R8 rules configured (Android)
- [ ] App signing configured
- [ ] Environment configs separated (dev/staging/prod)
- [ ] Error tracking integrated (Sentry/Crashlytics)
- [ ] Analytics implemented
- [ ] Deep linking tested
- [ ] Push notifications working

### Performance
- [ ] Profiled with DevTools
- [ ] No jank in > 60fps animations
- [ ] Memory leaks checked
- [ ] Image caching configured
- [ ] Lazy loading for lists
- [ ] App size optimized

### Quality
- [ ] Unit test coverage > 80%
- [ ] Widget tests for critical flows
- [ ] Integration tests for happy paths
- [ ] Accessibility audit passed
- [ ] Localization complete
```

## Related Skills

- `@senior-ios-developer` - Native iOS patterns
- `@senior-android-developer` - Native Android patterns
- `@app-store-publisher` - Store publishing
- `@senior-ui-ux-designer` - Mobile UX

# Performance Optimization

## 1. Slivers for Complex Scrolling

```dart
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
```

## 2. RepaintBoundary for Complex Widgets

```dart
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
```

## 3. Isolate for Heavy Computation

```dart
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
```

## 4. Image Caching & Precaching

```dart
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

## 5. ListView Optimization

```dart
ListView.builder(
  // Use const constructors
  itemBuilder: (context, index) {
    return const ProductTile(); // Use const when possible
  },
  // Add extent for fixed-height items
  itemExtent: 80.0,
  // Cache extent for smoother scrolling
  cacheExtent: 500.0,
  // Key for proper diffing
  key: const PageStorageKey<String>('productList'),
)
```

## 6. Const Constructors

```dart
// ✅ Good
const EdgeInsets.all(16)
const TextStyle(fontSize: 14)
const Icon(Icons.add)

// ❌ Avoid
EdgeInsets.all(16) // Creates new instance every build
TextStyle(fontSize: 14)
Icon(Icons.add)
```

## 7. Avoid Expensive Operations in build()

```dart
// ❌ JANGAN: filtering/sorting di build()
Widget build(BuildContext context) {
  final filtered = items.where((e) => e.isActive).toList()
    ..sort((a, b) => a.name.compareTo(b.name));
  return ListView.builder(
    itemCount: filtered.length,
    itemBuilder: (_, i) => ItemTile(filtered[i]),
  );
}

// ✅ LAKUKAN: proses di controller/provider, cache hasilnya
class ProductNotifier extends _$ProductNotifier {
  List<Product> _cachedFiltered = [];

  List<Product> get filteredProducts => _cachedFiltered;

  void updateFilter(String query) {
    _cachedFiltered = _allProducts
        .where((e) => e.name.contains(query))
        .toList()
      ..sort((a, b) => a.name.compareTo(b.name));
    notifyListeners();
  }
}
```

## 8. Debounce for Search

```dart
// ✅ Jangan hit API setiap keystroke, gunakan debounce
class SearchNotifier extends ChangeNotifier {
  Timer? _debounce;
  List<Product> _results = [];

  List<Product> get results => _results;

  void onSearchChanged(String query) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _performSearch(query);
    });
  }

  Future<void> _performSearch(String query) async {
    if (query.isEmpty) {
      _results = [];
      notifyListeners();
      return;
    }
    final result = await _repository.search(query);
    result.fold(
      (failure) => {/* handle error */},
      (data) {
        _results = data;
        notifyListeners();
      },
    );
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}
```

## 9. Pagination / Infinite Scroll

```dart
class PaginatedResponse<T> {
  final List<T> items;
  final int currentPage;
  final int totalPages;
  final bool hasMore;

  const PaginatedResponse({
    required this.items,
    required this.currentPage,
    required this.totalPages,
    required this.hasMore,
  });
}

class ProductListNotifier extends ChangeNotifier {
  int _page = 1;
  bool _isLoading = false;
  bool _hasMore = true;
  final List<Product> _items = [];

  List<Product> get items => _items;
  bool get isLoading => _isLoading;
  bool get hasMore => _hasMore;

  Future<void> loadMore() async {
    if (_isLoading || !_hasMore) return;
    _isLoading = true;
    notifyListeners();

    final result = await _repository.getProducts(page: _page, limit: 20);
    result.fold(
      (failure) {/* handle error */},
      (response) {
        _items.addAll(response.items);
        _hasMore = response.hasMore;
        _page++;
      },
    );
    _isLoading = false;
    notifyListeners();
  }

  Future<void> refresh() async {
    _page = 1;
    _hasMore = true;
    _items.clear();
    await loadMore();
  }
}

// UI: Trigger loadMore saat scroll mendekati akhir
NotificationListener<ScrollNotification>(
  onNotification: (notification) {
    if (notification.metrics.pixels >=
        notification.metrics.maxScrollExtent - 200) {
      ref.read(productListProvider.notifier).loadMore();
    }
    return false;
  },
  child: ListView.builder(
    itemCount: items.length + (hasMore ? 1 : 0),
    itemBuilder: (context, index) {
      if (index == items.length) {
        return const Center(child: CircularProgressIndicator());
      }
      return ProductTile(product: items[index]);
    },
  ),
)
```

## 10. Cache-First Strategy with TTL

```dart
class CachedData<T> {
  final T data;
  final DateTime cachedAt;
  final Duration ttl;

  CachedData({
    required this.data,
    required this.cachedAt,
    this.ttl = const Duration(minutes: 5),
  });

  bool get isExpired => DateTime.now().difference(cachedAt) > ttl;
}

// Repository implementation
Future<Either<Failure, List<Category>>> getCategories() async {
  // 1. Check local cache first
  final cached = await _localDataSource.getCategories();
  if (cached != null && !cached.isExpired) {
    return Right(cached.data);
  }

  // 2. Fetch from API
  try {
    final remote = await _remoteDataSource.getCategories();
    await _localDataSource.saveCategories(
      CachedData(data: remote, cachedAt: DateTime.now()),
    );
    return Right(remote.map((e) => e.toEntity()).toList());
  } on DioException catch (e) {
    // 3. Fallback to expired cache if offline
    if (cached != null) return Right(cached.data);
    return Left(ServerFailure(mapDioException(e).message));
  }
}
```

## 11. Memoization with ValueNotifier

```dart
class ExpensiveCalculation extends StatefulWidget {
  @override
  State<ExpensiveCalculation> createState() => _ExpensiveCalculationState();
}

class _ExpensiveCalculationState extends State<ExpensiveCalculation> {
  late final ValueNotifier<List<Data>> _processedData;

  @override
  void initState() {
    super.initState();
    _processedData = ValueNotifier(_calculateExpensiveData());
  }

  List<Data> _calculateExpensiveData() {
    // Heavy computation — only runs once, not on every build
    return [];
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<Data>>(
      valueListenable: _processedData,
      builder: (context, data, _) {
        return ListView.builder(
          itemCount: data.length,
          itemBuilder: (context, index) => DataTile(data: data[index]),
        );
      },
    );
  }
}
```

## 12. Environment Configuration

```dart
enum Env { dev, staging, prod }

class AppConfig {
  static late final String baseUrl;
  static late final String apiKey;
  static late final Env environment;
  static late final Duration apiTimeout;

  static void init(Env env) {
    environment = env;
    baseUrl = switch (env) {
      Env.dev => 'https://dev-api.example.com',
      Env.staging => 'https://staging-api.example.com',
      Env.prod => 'https://api.example.com',
    };
    apiTimeout = switch (env) {
      Env.dev => const Duration(seconds: 30),
      _ => const Duration(seconds: 15),
    };
  }

  static bool get isDev => environment == Env.dev;
  static bool get isProd => environment == Env.prod;
}

// main_dev.dart
void main() {
  AppConfig.init(Env.dev);
  runApp(const MyApp());
}

// main_prod.dart
void main() {
  AppConfig.init(Env.prod);
  runApp(const MyApp());
}
```

## 13. Dio Production Setup

```dart
class DioClient {
  late final Dio _dio;

  DioClient({String? token}) {
    _dio = Dio(BaseOptions(
      baseUrl: AppConfig.baseUrl,
      connectTimeout: AppConfig.apiTimeout,
      receiveTimeout: AppConfig.apiTimeout,
      sendTimeout: AppConfig.apiTimeout,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    ));

    _dio.interceptors.addAll([
      _AuthInterceptor(),
      _RetryInterceptor(),
      if (AppConfig.isDev) _LoggingInterceptor(),
    ]);
  }

  Dio get dio => _dio;
}

// Auth interceptor with token refresh
class _AuthInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      try {
        final newToken = await _refreshToken();
        err.requestOptions.headers['Authorization'] = 'Bearer $newToken';
        final response = await Dio().fetch(err.requestOptions);
        return handler.resolve(response);
      } catch (_) {
        // Refresh failed — force logout
        return handler.next(err);
      }
    }
    return handler.next(err);
  }
}

// Retry interceptor
class _RetryInterceptor extends Interceptor {
  static const _maxRetries = 3;
  static const _retryableStatusCodes = [408, 429, 500, 502, 503, 504];

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final statusCode = err.response?.statusCode;
    if (statusCode != null && _retryableStatusCodes.contains(statusCode)) {
      for (var attempt = 1; attempt <= _maxRetries; attempt++) {
        await Future.delayed(Duration(seconds: attempt)); // exponential-ish
        try {
          final response = await Dio().fetch(err.requestOptions);
          return handler.resolve(response);
        } catch (_) {
          if (attempt == _maxRetries) return handler.next(err);
        }
      }
    }
    return handler.next(err);
  }
}
```

## 14. Centralized Error Mapper

```dart
// Dart 3 sealed class — modern alternative to dartz Either
sealed class AppException implements Exception {
  final String message;
  const AppException(this.message);
}

class ServerException extends AppException {
  final int? statusCode;
  const ServerException(super.message, {this.statusCode});
}

class NetworkException extends AppException {
  const NetworkException() : super('Tidak ada koneksi internet');
}

class TimeoutException extends AppException {
  const TimeoutException() : super('Koneksi timeout, coba lagi');
}

class UnauthorizedException extends AppException {
  const UnauthorizedException() : super('Sesi Anda telah berakhir');
}

// Centralized mapper
AppException mapDioException(DioException e) {
  return switch (e.type) {
    DioExceptionType.connectionTimeout ||
    DioExceptionType.receiveTimeout ||
    DioExceptionType.sendTimeout => const TimeoutException(),
    DioExceptionType.connectionError => const NetworkException(),
    DioExceptionType.badResponse => _mapStatusCode(e),
    _ => ServerException('Terjadi kesalahan: ${e.message}'),
  };
}

AppException _mapStatusCode(DioException e) {
  final statusCode = e.response?.statusCode;
  final serverMsg = e.response?.data?['message'] as String?;
  return switch (statusCode) {
    401 => const UnauthorizedException(),
    403 => const ServerException('Akses ditolak'),
    404 => const ServerException('Data tidak ditemukan'),
    422 => ServerException(serverMsg ?? 'Data tidak valid', statusCode: 422),
    429 => const ServerException('Terlalu banyak request, coba lagi nanti'),
    >= 500 => const ServerException('Server sedang bermasalah'),
    _ => ServerException(serverMsg ?? 'Error', statusCode: statusCode),
  };
}
```

## 15. Pre-Release Performance Checklist

```markdown
### Build Optimization
- [ ] `flutter build --split-debug-info=build/debug-info` (reduce APK size)
- [ ] `flutter build --obfuscate` (code obfuscation)
- [ ] ProGuard/R8 enabled (Android)
- [ ] Tree shaking verified (no unused packages)
- [ ] Asset compression (WebP for images, min-size SVGs)

### Runtime Performance
- [ ] Profiled with DevTools (no jank > 16ms frames)
- [ ] Memory leak check (no growing memory in DevTools)
- [ ] ListView.builder for all long lists (no ListView with children:[])
- [ ] Image caching with CachedNetworkImage + cacheWidth/cacheHeight
- [ ] const constructors used aggressively
- [ ] RepaintBoundary for CustomPaint / complex widgets
- [ ] Isolates for heavy computation (JSON parsing, image processing)
- [ ] Debounce on search inputs (min 300-500ms)
- [ ] Pull-to-refresh for all list screens
- [ ] Shimmer loading skeletons (not just spinner)

### API Performance
- [ ] Timeout set to 15s (not default 30s)
- [ ] Retry mechanism for 5xx errors
- [ ] Token refresh interceptor
- [ ] Pagination for all list endpoints
- [ ] Cache-first strategy for static data (categories, config)
- [ ] Connectivity check before API calls
- [ ] Optimistic updates for instant-feel UX

### App Size
- [ ] `--split-per-abi` for Android (separate APK per architecture)
- [ ] Remove unused dependencies from pubspec.yaml
- [ ] Compress assets (images < 200KB, use WebP)
- [ ] Deferred loading for large features (`deferred as`)
```

## 16. Pull-to-Refresh + Pagination Combo

```dart
// Pattern paling umum di production app
class ProductListPage extends ConsumerWidget {
  const ProductListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.watch(productListProvider);

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () => ref.read(productListProvider.notifier).refresh(),
        child: NotificationListener<ScrollNotification>(
          onNotification: (notification) {
            if (notification.metrics.pixels >=
                notification.metrics.maxScrollExtent - 200) {
              ref.read(productListProvider.notifier).loadMore();
            }
            return false;
          },
          child: notifier.items.isEmpty && notifier.isLoading
              ? const _ShimmerList()
              : ListView.builder(
                  itemCount: notifier.items.length +
                      (notifier.hasMore ? 1 : 0),
                  itemExtent: 80,
                  itemBuilder: (context, index) {
                    if (index == notifier.items.length) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }
                    return ProductTile(
                      product: notifier.items[index],
                    );
                  },
                ),
        ),
      ),
    );
  }
}
```

## 17. Optimistic Update Pattern

```dart
/// Update UI langsung → call API → rollback jika gagal
class TodoNotifier extends ChangeNotifier {
  final TodoRepository _repository;
  List<Todo> _items = [];

  List<Todo> get items => _items;

  /// Toggle todo completion dengan optimistic update
  Future<void> toggleComplete(String todoId) async {
    // 1. Simpan state lama untuk rollback
    final previousItems = List<Todo>.from(_items);

    // 2. Update UI langsung (optimistic)
    final index = _items.indexWhere((t) => t.id == todoId);
    if (index == -1) return;
    _items[index] = _items[index].copyWith(
      isCompleted: !_items[index].isCompleted,
    );
    notifyListeners(); // UI update instan!

    // 3. Call API di background
    final result = await _repository.toggleComplete(todoId);

    // 4. Rollback jika gagal
    result.fold(
      (failure) {
        _items = previousItems;
        notifyListeners();
        // Tampilkan error ke user
      },
      (_) {
        // Sukses — tidak perlu apa-apa, UI sudah benar
      },
    );
  }

  /// Delete item dengan optimistic update
  Future<void> deleteItem(String todoId) async {
    final previousItems = List<Todo>.from(_items);

    // Hapus dari UI langsung
    _items.removeWhere((t) => t.id == todoId);
    notifyListeners();

    final result = await _repository.delete(todoId);
    result.fold(
      (failure) {
        _items = previousItems; // Rollback
        notifyListeners();
      },
      (_) {},
    );
  }
}
```

## 18. Connectivity Check

```dart
// core/network/network_info.dart
abstract class NetworkInfo {
  Future<bool> get isConnected;
}

class NetworkInfoImpl implements NetworkInfo {
  final Connectivity _connectivity;

  NetworkInfoImpl(this._connectivity);

  @override
  Future<bool> get isConnected async {
    final result = await _connectivity.checkConnectivity();
    return !result.contains(ConnectivityResult.none);
  }
}

// Usage di Repository
class ProductRepositoryImpl implements ProductRepository {
  final NetworkInfo _networkInfo;
  final ProductRemoteDataSource _remote;
  final ProductLocalDataSource _local;

  @override
  Future<Either<Failure, List<Product>>> getProducts() async {
    // Cek koneksi sebelum API call
    if (!await _networkInfo.isConnected) {
      // Fallback ke cache lokal
      try {
        final cached = await _local.getProducts();
        return Right(cached.map((e) => e.toEntity()).toList());
      } on CacheException {
        return const Left(
          NetworkFailure('Tidak ada koneksi internet'),
        );
      }
    }

    // Online → fetch dari API
    try {
      final remote = await _remote.getProducts();
      await _local.cacheProducts(remote);
      return Right(remote.map((e) => e.toEntity()).toList());
    } on DioException catch (e) {
      return Left(ServerFailure(mapDioException(e).message));
    }
  }
}
```

## 19. Shimmer Loading Skeleton

```dart
// shared/widgets/shimmer/shimmer_box.dart
class ShimmerBox extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;

  const ShimmerBox({
    super.key,
    this.width = double.infinity,
    required this.height,
    this.borderRadius = 8,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}

// shared/widgets/shimmer/shimmer_list_tile.dart
class ShimmerListTile extends StatelessWidget {
  const ShimmerListTile({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ),
      child: Row(
        children: [
          const ShimmerBox(width: 48, height: 48, borderRadius: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                ShimmerBox(height: 14, width: 150),
                SizedBox(height: 8),
                ShimmerBox(height: 12, width: 100),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Shimmer list → dipakai saat loading pertama kali
class ShimmerList extends StatelessWidget {
  final int itemCount;

  const ShimmerList({super.key, this.itemCount = 8});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      itemCount: itemCount,
      itemBuilder: (_, __) => const ShimmerListTile(),
    );
  }
}

// Usage:
// items.isEmpty && isLoading
//   ? const ShimmerList()
//   : ListView.builder(...)
```

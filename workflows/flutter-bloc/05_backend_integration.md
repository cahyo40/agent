---
description: Implementasi repository pattern dengan REST API menggunakan Dio dan flutter_bloc.
---
# Workflow: Backend Integration (REST API) — Flutter BLoC

// turbo-all

## Overview

Implementasi backend integration dengan Clean Architecture dan BLoC:
- Dio setup sebagai `@lazySingleton` di get_it
- Interceptors: Auth (service-locator based), Retry, Logging, Error
- Error mapper: `DioException` → `AppException` → `Failure`
- Offline-first repository pattern
- Pagination menggunakan `PaginatedProductBloc` dengan sealed events

**Perbedaan utama dengan Riverpod version:**
- `DioClient` di-register sebagai `@lazySingleton`, bukan Riverpod provider
- Auth interceptor pakai `sl<SecureStorageService>()`, bukan `ref.read()`
- Pagination pakai `PaginatedProductBloc` dengan sealed events + single state class (bukan `AsyncNotifier`)
- Data layer (repository, datasource, model) tetap framework-agnostic


## Prerequisites

- Project setup dari `01_project_setup.md` selesai
- API endpoint tersedia + API documentation (Swagger/OpenAPI)
- Dependencies:
  ```yaml
  dependencies:
    dio: ^5.4.0
    connectivity_plus: ^6.0.0
    flutter_secure_storage: ^9.0.0
    json_annotation: ^4.8.1
    stream_transform: ^2.1.0
    flutter_bloc: ^8.1.4
    equatable: ^2.0.5

  dev_dependencies:
    build_runner: ^2.4.8
    json_serializable: ^6.7.1
  ```


## Agent Behavior

- **Setup Dio** sebagai `@lazySingleton` dengan interceptors chaining.
- **Auth interceptor**: attach token via service locator, handle 401 dengan refresh strategy.
- **Retry interceptor**: exponential backoff untuk 5xx + timeout.
- **Pagination**: gunakan `PaginatedProductBloc` dengan sealed events dan single state class.
- **Jangan pakai `dartz`** — gunakan `Result<T>` sealed class.
- **Network layer tetap framework-agnostic** — tidak boleh ada import `flutter_bloc` di repository.


## Recommended Skills

- `senior-flutter-developer` — BLoC + Dio + Clean Architecture
- `senior-backend-developer` — API patterns


## Workflow Steps

### Step 1: Dio Configuration & DI Registration

```dart
// core/network/dio_client.dart
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class DioClient {
  late final Dio _dio;

  DioClient({
    required AuthInterceptor authInterceptor,
    required RetryInterceptor retryInterceptor,
    required LoggingInterceptor loggingInterceptor,
    required ErrorInterceptor errorInterceptor,
  }) {
    _dio = Dio(BaseOptions(
      baseUrl: AppConfig.baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      sendTimeout: const Duration(seconds: 15),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    // Urutan interceptor penting: auth harus sebelum retry
    _dio.interceptors.addAll([
      authInterceptor,
      retryInterceptor,
      loggingInterceptor,
      errorInterceptor,
    ]);
  }

  Dio get dio => _dio;

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) => _dio.get<T>(path, queryParameters: queryParameters, options: options, cancelToken: cancelToken);

  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Options? options,
  }) => _dio.post<T>(path, data: data, options: options);

  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Options? options,
  }) => _dio.put<T>(path, data: data, options: options);

  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Options? options,
  }) => _dio.delete<T>(path, data: data, options: options);
}

// core/di/modules/network_module.dart
@module
abstract class NetworkModule {
  @lazySingleton
  Dio dio(DioClient client) => client.dio;
}
```

**Perbandingan dengan Riverpod:**

| Aspek | Riverpod | BLoC + get_it |
|-------|----------|---------------|
| Registration | `Provider((ref) => DioClient(ref: ref))` | `@lazySingleton class DioClient` |
| Access | `ref.read(dioClientProvider)` | `sl<DioClient>()` |
| Lifetime | Riverpod container | get_it (app lifetime) |
| Testing | Override via `ProviderContainer` | Override via `sl.registerSingleton()` |


### Step 2: Auth Interceptor (Service Locator Based)

```dart
// core/network/interceptors/auth_interceptor.dart
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class AuthInterceptor extends Interceptor {
  // Di BLoC: inject SecureStorageService (tidak pakai ref.read())
  final SecureStorageService _secureStorage;

  AuthInterceptor(this._secureStorage);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    if (options.extra['requiresAuth'] == false) {
      handler.next(options);
      return;
    }

    final token = await _secureStorage.read('access_token');
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      final refreshed = await _refreshToken();
      if (refreshed) {
        final newToken = await _secureStorage.read('access_token');
        err.requestOptions.headers['Authorization'] = 'Bearer $newToken';
        try {
          final retryDio = Dio(BaseOptions(baseUrl: err.requestOptions.baseUrl));
          final response = await retryDio.fetch(err.requestOptions);
          handler.resolve(response);
          return;
        } catch (_) {}
      }
      await _handleSessionExpired();
    }
    handler.next(err);
  }

  Future<bool> _refreshToken() async {
    try {
      final refreshToken = await _secureStorage.read('refresh_token');
      if (refreshToken == null) return false;

      final dio = Dio(BaseOptions(baseUrl: AppConfig.baseUrl));
      final response = await dio.post('/auth/refresh', data: {
        'refresh_token': refreshToken,
      });

      await _secureStorage.write('access_token', response.data['access_token']);
      final newRefreshToken = response.data['refresh_token'] as String?;
      if (newRefreshToken != null) {
        await _secureStorage.write('refresh_token', newRefreshToken);
      }
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> _handleSessionExpired() async {
    await _secureStorage.delete('access_token');
    await _secureStorage.delete('refresh_token');
    // Option: sl<AuthBloc>().add(const SessionExpired());
    // Option: sl<NavigationService>().navigateToLogin();
  }
}
```


### Step 3: Retry & Logging Interceptors

```dart
// core/network/interceptors/retry_interceptor.dart
@lazySingleton
class RetryInterceptor extends Interceptor {
  final Dio _dio;
  final int maxRetries;
  final Duration initialDelay;

  RetryInterceptor({
    required Dio dio,
    this.maxRetries = 3,
    this.initialDelay = const Duration(seconds: 1),
  }) : _dio = dio;

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final retryCount = (err.requestOptions.extra['retry_count'] ?? 0) as int;

    if (_shouldRetry(err) && retryCount < maxRetries) {
      err.requestOptions.extra['retry_count'] = retryCount + 1;
      final delay = initialDelay * (1 << retryCount); // Exponential backoff
      await Future.delayed(delay);

      try {
        final response = await _dio.fetch(err.requestOptions);
        handler.resolve(response);
        return;
      } catch (_) {}
    }
    handler.next(err);
  }

  bool _shouldRetry(DioException err) =>
      err.type == DioExceptionType.connectionTimeout ||
      err.type == DioExceptionType.receiveTimeout ||
      err.type == DioExceptionType.sendTimeout ||
      (err.response?.statusCode != null &&
          err.response!.statusCode! >= 500 &&
          err.response!.statusCode! < 600);
}

// core/network/interceptors/logging_interceptor.dart
import 'dart:developer' as dev;

@lazySingleton
class LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (AppConfig.isDebug) {
      dev.log('┌──────────────────────────────────────────');
      dev.log('│ REQUEST: ${options.method} ${options.uri}');
      if (options.data != null) dev.log('│ Body: ${options.data}');
      dev.log('├──────────────────────────────────────────');
    }
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (AppConfig.isDebug) {
      dev.log('│ RESPONSE: ${response.statusCode}');
      dev.log('└──────────────────────────────────────────');
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (AppConfig.isDebug) {
      dev.log('│ ERROR: ${err.type} - ${err.message}');
      dev.log('└──────────────────────────────────────────');
    }
    handler.next(err);
  }
}
```


### Step 4: Error Handling

```dart
// core/error/exceptions.dart
sealed class AppException implements Exception {
  final String message;
  final int? statusCode;

  const AppException({required this.message, this.statusCode});
}

final class ServerException extends AppException {
  const ServerException({required super.message, super.statusCode});
}

final class NetworkException extends AppException {
  const NetworkException()
      : super(message: 'Tidak ada koneksi internet');
}

final class CacheException extends AppException {
  const CacheException({required super.message});
}

final class UnauthorizedException extends AppException {
  const UnauthorizedException()
      : super(message: 'Sesi berakhir, silakan login kembali', statusCode: 401);
}

// core/error/failures.dart
sealed class Failure {
  final String message;
  const Failure({required this.message});
}

final class ServerFailure extends Failure {
  const ServerFailure({required super.message});
}

final class NetworkFailure extends Failure {
  const NetworkFailure() : super(message: 'Tidak ada koneksi internet');
}

final class CacheFailure extends Failure {
  const CacheFailure({required super.message});
}

// core/error/result.dart
sealed class Result<T> {
  const Result();

  B fold<B>(B Function(Failure) onFailure, B Function(T) onSuccess);
}

final class Success<T> extends Result<T> {
  final T value;
  const Success(this.value);

  @override
  B fold<B>(B Function(Failure) onFailure, B Function(T) onSuccess) =>
      onSuccess(value);
}

final class ResultFailure<T> extends Result<T> {
  final Failure failure;
  const ResultFailure(this.failure);

  @override
  B fold<B>(B Function(Failure) onFailure, B Function(T) onSuccess) =>
      onFailure(failure);
}

// core/network/interceptors/error_interceptor.dart
@lazySingleton
class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final appException = _mapDioException(err);
    handler.reject(DioException(
      requestOptions: err.requestOptions,
      error: appException,
      type: err.type,
      response: err.response,
    ));
  }

  AppException _mapDioException(DioException err) {
    return switch (err.type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.receiveTimeout ||
      DioExceptionType.sendTimeout =>
        const NetworkException(),
      DioExceptionType.connectionError => const NetworkException(),
      DioExceptionType.badResponse => _mapBadResponse(err),
      _ => ServerException(message: err.message ?? 'Unknown error'),
    };
  }

  AppException _mapBadResponse(DioException err) {
    final statusCode = err.response?.statusCode;
    final message = _extractMessage(err.response?.data) ?? 'Server error';

    return switch (statusCode) {
      400 => ServerException(message: message, statusCode: 400),
      401 => const UnauthorizedException(),
      403 => ServerException(message: 'Akses ditolak', statusCode: 403),
      404 => ServerException(message: 'Data tidak ditemukan', statusCode: 404),
      422 => ServerException(message: message, statusCode: 422),
      _ => ServerException(message: message, statusCode: statusCode),
    };
  }

  String? _extractMessage(dynamic data) {
    if (data is Map<String, dynamic>) {
      return data['message'] as String? ?? data['error'] as String?;
    }
    return null;
  }
}
```


### Step 5: Offline-First Repository

```dart
// features/product/data/repositories/product_repository_impl.dart
@LazySingleton(as: ProductRepository)
class ProductRepositoryImpl implements ProductRepository {
  final ProductRemoteDataSource _remote;
  final ProductLocalDataSource _local;
  final NetworkInfo _networkInfo;

  ProductRepositoryImpl({
    required ProductRemoteDataSource remote,
    required ProductLocalDataSource local,
    required NetworkInfo networkInfo,
  })  : _remote = remote,
        _local = local,
        _networkInfo = networkInfo;

  @override
  Future<Result<List<Product>>> getProducts({
    int page = 1,
    int limit = 20,
    String? search,
  }) async {
    if (await _networkInfo.isConnected) {
      try {
        final models = await _remote.getProducts(page: page, limit: limit, search: search);
        // Hanya cache halaman pertama (tanpa filter)
        if (page == 1 && search == null) {
          await _local.cacheProducts(models);
        }
        return Success(models.map((m) => m.toEntity()).toList());
      } on ServerException catch (e) {
        return ResultFailure(ServerFailure(message: e.message));
      } on NetworkException {
        return const ResultFailure(NetworkFailure());
      }
    } else {
      // Offline: return cached data
      try {
        final cached = await _local.getCachedProducts();
        return Success(cached.map((m) => m.toEntity()).toList());
      } on CacheException catch (e) {
        return ResultFailure(CacheFailure(message: e.message));
      }
    }
  }
}

// core/network/network_info.dart
abstract class NetworkInfo {
  Future<bool> get isConnected;
}

@LazySingleton(as: NetworkInfo)
class NetworkInfoImpl implements NetworkInfo {
  final Connectivity _connectivity;
  NetworkInfoImpl(this._connectivity);

  @override
  Future<bool> get isConnected async {
    final result = await _connectivity.checkConnectivity();
    return result != ConnectivityResult.none;
  }
}
```


### Step 6: Pagination BLoC

**Perbedaan paling signifikan dari Riverpod!** Di BLoC, pagination menggunakan sealed events + single state class (bukan `AsyncNotifier`).

```dart
// features/product/presentation/bloc/paginated_product_event.dart
part of 'paginated_product_bloc.dart';

sealed class PaginatedProductEvent extends Equatable {
  const PaginatedProductEvent();
  @override
  List<Object?> get props => [];
}

/// Load halaman pertama
final class LoadProducts extends PaginatedProductEvent {
  const LoadProducts();
}

/// Load halaman berikutnya (infinite scroll)
final class LoadNextPage extends PaginatedProductEvent {
  const LoadNextPage();
}

/// Pull-to-refresh — reset ke halaman 1
final class RefreshProducts extends PaginatedProductEvent {
  const RefreshProducts();
}

/// Search — reset pagination, debounce 300ms
final class SearchProducts extends PaginatedProductEvent {
  final String query;
  const SearchProducts(this.query);
  @override
  List<Object?> get props => [query];
}

/// Clear search filter
final class ClearSearch extends PaginatedProductEvent {
  const ClearSearch();
}

// features/product/presentation/bloc/paginated_product_state.dart
part of 'paginated_product_bloc.dart';

enum ProductStatus { initial, loading, loaded, loadingMore, error }

class PaginatedProductState extends Equatable {
  final List<Product> products;
  final ProductStatus status;
  final bool hasMore;
  final int currentPage;
  final String? errorMessage;
  final String searchQuery;

  const PaginatedProductState({
    this.products = const [],
    this.status = ProductStatus.initial,
    this.hasMore = true,
    this.currentPage = 0,
    this.errorMessage,
    this.searchQuery = '',
  });

  bool get isInitialLoading => status == ProductStatus.loading && products.isEmpty;
  bool get isLoadingMore => status == ProductStatus.loadingMore;
  bool get hasError => status == ProductStatus.error;
  bool get hasData => products.isNotEmpty;
  bool get isSearching => searchQuery.isNotEmpty;

  PaginatedProductState copyWith({
    List<Product>? products,
    ProductStatus? status,
    bool? hasMore,
    int? currentPage,
    String? errorMessage,
    String? searchQuery,
  }) =>
      PaginatedProductState(
        products: products ?? this.products,
        status: status ?? this.status,
        hasMore: hasMore ?? this.hasMore,
        currentPage: currentPage ?? this.currentPage,
        errorMessage: errorMessage, // intentional: null clears error
        searchQuery: searchQuery ?? this.searchQuery,
      );

  @override
  List<Object?> get props => [products, status, hasMore, currentPage, errorMessage, searchQuery];
}

// features/product/presentation/bloc/paginated_product_bloc.dart
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:stream_transform/stream_transform.dart';

part 'paginated_product_event.dart';
part 'paginated_product_state.dart';

/// Debounce transformer untuk search events
EventTransformer<E> debounce<E>(Duration duration) {
  return (events, mapper) => events.debounce(duration).switchMap(mapper);
}

@injectable
class PaginatedProductBloc
    extends Bloc<PaginatedProductEvent, PaginatedProductState> {
  final GetProducts _getProducts;
  static const int _pageSize = 20;

  PaginatedProductBloc({required GetProducts getProducts})
      : _getProducts = getProducts,
        super(const PaginatedProductState()) {
    on<LoadProducts>(_onLoadProducts);
    on<LoadNextPage>(_onLoadNextPage);
    on<RefreshProducts>(_onRefreshProducts);
    on<SearchProducts>(
      _onSearchProducts,
      transformer: debounce(const Duration(milliseconds: 300)),
    );
    on<ClearSearch>(_onClearSearch);
  }

  Future<void> _onLoadProducts(
    LoadProducts event,
    Emitter<PaginatedProductState> emit,
  ) async {
    emit(state.copyWith(status: ProductStatus.loading));
    final result = await _getProducts(GetProductsParams(page: 1, limit: _pageSize));
    result.fold(
      (f) => emit(state.copyWith(status: ProductStatus.error, errorMessage: f.message)),
      (products) => emit(state.copyWith(
        status: ProductStatus.loaded,
        products: products,
        currentPage: 1,
        hasMore: products.length >= _pageSize,
        errorMessage: null,
      )),
    );
  }

  Future<void> _onLoadNextPage(
    LoadNextPage event,
    Emitter<PaginatedProductState> emit,
  ) async {
    if (state.isLoadingMore || !state.hasMore) return;

    emit(state.copyWith(status: ProductStatus.loadingMore));
    final nextPage = state.currentPage + 1;
    final result = await _getProducts(GetProductsParams(
      page: nextPage,
      limit: _pageSize,
      search: state.searchQuery.isEmpty ? null : state.searchQuery,
    ));
    result.fold(
      (f) => emit(state.copyWith(status: ProductStatus.loaded, errorMessage: f.message)),
      (newProducts) => emit(state.copyWith(
        status: ProductStatus.loaded,
        products: [...state.products, ...newProducts],
        currentPage: nextPage,
        hasMore: newProducts.length >= _pageSize,
        errorMessage: null,
      )),
    );
  }

  Future<void> _onRefreshProducts(
    RefreshProducts event,
    Emitter<PaginatedProductState> emit,
  ) async {
    final result = await _getProducts(GetProductsParams(
      page: 1,
      limit: _pageSize,
      search: state.searchQuery.isEmpty ? null : state.searchQuery,
    ));
    result.fold(
      (f) => emit(state.copyWith(errorMessage: f.message)),
      (products) => emit(state.copyWith(
        status: ProductStatus.loaded,
        products: products,
        currentPage: 1,
        hasMore: products.length >= _pageSize,
        errorMessage: null,
      )),
    );
  }

  Future<void> _onSearchProducts(
    SearchProducts event,
    Emitter<PaginatedProductState> emit,
  ) async {
    final query = event.query.trim();
    emit(state.copyWith(
      status: ProductStatus.loading,
      searchQuery: query,
      products: [],
    ));
    final result = await _getProducts(GetProductsParams(
      page: 1,
      limit: _pageSize,
      search: query.isEmpty ? null : query,
    ));
    result.fold(
      (f) => emit(state.copyWith(status: ProductStatus.error, errorMessage: f.message)),
      (products) => emit(state.copyWith(
        status: ProductStatus.loaded,
        products: products,
        currentPage: 1,
        hasMore: products.length >= _pageSize,
        errorMessage: null,
      )),
    );
  }

  Future<void> _onClearSearch(
    ClearSearch event,
    Emitter<PaginatedProductState> emit,
  ) async {
    emit(state.copyWith(searchQuery: ''));
    add(const LoadProducts());
  }
}
```

**Perbandingan Pagination: Riverpod vs BLoC**

| Aspek | Riverpod (`AsyncNotifier`) | BLoC (`Bloc<Event, State>`) |
|-------|----------------------------|-----------------------------|
| Load initial | `build()` method | `on<LoadProducts>` handler |
| Load more | `loadMore()` method | `on<LoadNextPage>` handler |
| Refresh | `refresh()` method | `on<RefreshProducts>` handler |
| Search | Method + debounce | Event + `transformer: debounce()` |
| State | `AsyncValue<List>` + fields | `PaginatedProductState` class |
| Trigger | `ref.read(notifier).loadMore()` | `bloc.add(LoadNextPage())` |


### Step 7: Paginated List Screen

```dart
// features/product/presentation/screens/product_list_screen.dart
class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  final _scrollController = ScrollController();
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    context.read<PaginatedProductBloc>().add(const LoadProducts());
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final current = _scrollController.offset;
    if (current >= maxScroll - 200) {
      context.read<PaginatedProductBloc>().add(const LoadNextPage());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Products'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: _SearchField(controller: _searchController),
          ),
        ),
      ),
      // BlocListener untuk error snackbar
      body: BlocListener<PaginatedProductBloc, PaginatedProductState>(
        listenWhen: (p, c) =>
            p.errorMessage != c.errorMessage && c.errorMessage != null,
        listener: (context, state) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(state.errorMessage!),
            behavior: SnackBarBehavior.floating,
            action: SnackBarAction(
              label: 'Retry',
              onPressed: () => context
                  .read<PaginatedProductBloc>()
                  .add(const RefreshProducts()),
            ),
          ));
        },
        child: BlocBuilder<PaginatedProductBloc, PaginatedProductState>(
          builder: (context, state) {
            if (state.isInitialLoading) return const ProductListShimmer();

            if (state.hasError && !state.hasData) {
              return ErrorView(
                message: state.errorMessage ?? 'Terjadi kesalahan',
                onRetry: () => context
                    .read<PaginatedProductBloc>()
                    .add(const LoadProducts()),
              );
            }

            if (state.status == ProductStatus.loaded && !state.hasData) {
              return EmptyView(
                message: state.isSearching
                    ? 'Tidak ada produk untuk "${state.searchQuery}"'
                    : 'Belum ada produk',
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                context
                    .read<PaginatedProductBloc>()
                    .add(const RefreshProducts());
                await context
                    .read<PaginatedProductBloc>()
                    .stream
                    .firstWhere((s) => s.status != ProductStatus.loading);
              },
              child: ListView.builder(
                controller: _scrollController,
                itemCount: state.products.length + (state.hasMore ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == state.products.length) {
                    return _buildLoadMoreIndicator(state);
                  }
                  final product = state.products[index];
                  return ProductListItem(
                    product: product,
                    onTap: () => context.push('/products/${product.id}'),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildLoadMoreIndicator(PaginatedProductState state) {
    if (state.isLoadingMore) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (state.hasError) {
      return Center(
        child: TextButton.icon(
          onPressed: () =>
              context.read<PaginatedProductBloc>().add(const LoadNextPage()),
          icon: const Icon(Icons.refresh),
          label: const Text('Coba lagi'),
        ),
      );
    }
    return const SizedBox(height: 16);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }
}

class _SearchField extends StatelessWidget {
  final TextEditingController controller;
  const _SearchField({required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: 'Cari produk...',
        prefixIcon: const Icon(Icons.search),
        suffixIcon: BlocBuilder<PaginatedProductBloc, PaginatedProductState>(
          buildWhen: (p, c) => p.searchQuery != c.searchQuery,
          builder: (context, state) {
            if (!state.isSearching) return const SizedBox.shrink();
            return IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                controller.clear();
                context.read<PaginatedProductBloc>().add(const ClearSearch());
              },
            );
          },
        ),
        filled: true,
        fillColor: Theme.of(context).colorScheme.surfaceVariant,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      ),
      onChanged: (query) =>
          context.read<PaginatedProductBloc>().add(SearchProducts(query)),
    );
  }
}
```


### Step 8: API Response Wrapper

```dart
// core/network/api_response.dart
import 'package:json_annotation/json_annotation.dart';

part 'api_response.g.dart';

@JsonSerializable(genericArgumentFactories: true)
class ApiResponse<T> {
  final bool success;
  final String? message;
  final T? data;
  final ApiMetadata? meta;

  const ApiResponse({
    required this.success,
    this.message,
    this.data,
    this.meta,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) => _$ApiResponseFromJson(json, fromJsonT);

  bool get hasNextPage {
    if (meta == null) return false;
    return (meta!.page ?? 0) < (meta!.totalPages ?? 0);
  }
}

@JsonSerializable()
class ApiMetadata {
  final int? page;
  final int? limit;
  final int? total;
  final int? totalPages;

  const ApiMetadata({this.page, this.limit, this.total, this.totalPages});

  factory ApiMetadata.fromJson(Map<String, dynamic> json) =>
      _$ApiMetadataFromJson(json);
}

// core/network/paginated_result.dart
class PaginatedResult<T> {
  final List<T> items;
  final int currentPage;
  final int totalPages;
  final int totalItems;
  final bool hasMore;

  const PaginatedResult({
    required this.items,
    required this.currentPage,
    required this.totalPages,
    required this.totalItems,
    required this.hasMore,
  });

  factory PaginatedResult.fromApiResponse(
    ApiResponse<List<T>> response, {
    required int requestedPage,
    required int pageSize,
  }) =>
      PaginatedResult(
        items: response.data ?? [],
        currentPage: response.meta?.page ?? requestedPage,
        totalPages: response.meta?.totalPages ?? 1,
        totalItems: response.meta?.total ?? 0,
        hasMore: (response.data?.length ?? 0) >= pageSize,
      );
}
```


## Success Criteria

- [ ] DioClient `@lazySingleton` terdaftar di get_it
- [ ] Interceptor ordering: Auth → Retry → Logging → Error
- [ ] Auth interceptor pakai `sl<SecureStorageService>()`, bukan `ref.read()`
- [ ] `Result<T>` sealed class (bukan `dartz`)
- [ ] Repository tidak punya import `flutter_bloc` (framework-agnostic)
- [ ] `PaginatedProductBloc` dengan sealed events + single state class
- [ ] Search debounce 300ms via `EventTransformer`
- [ ] Guard: `if (state.isLoadingMore || !state.hasMore) return;` di LoadNextPage
- [ ] `BlocListener` terpisah untuk error snackbar
- [ ] `flutter analyze` tidak ada error


## Next Steps

- Auth feature → `04_auth_feature.md`
- State management lanjutan → `09_state_management_advanced.md`
- Testing → `06_testing_production.md`

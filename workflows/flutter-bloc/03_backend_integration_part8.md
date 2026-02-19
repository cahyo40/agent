---
description: Implementasi repository pattern dengan REST API menggunakan Dio dan flutter_bloc. (Part 8/8)
---
# Workflow: Backend Integration (REST API) - Flutter BLoC (Part 8/8)

> **Navigation:** This workflow is split into 8 parts.

## get_it Registration Summary

Semua dependency di-register di get_it. Berikut ringkasan registration yang terkait backend integration:

```dart
// core/di/injection.dart
// Jika pakai injectable, cukup annotate class dengan @lazySingleton/@injectable.
// Jika manual registration:

final sl = GetIt.instance;

Future<void> initDependencies() async {
  // ─── Network ───────────────────────────────────────────
  sl.registerLazySingleton<SecureStorageService>(
    () => SecureStorageServiceImpl(),
  );
  sl.registerLazySingleton<NetworkInfo>(
    () => NetworkInfoImpl(Connectivity()),
  );

  // Interceptors
  sl.registerLazySingleton<AuthInterceptor>(
    () => AuthInterceptor(sl<SecureStorageService>()),
  );
  sl.registerLazySingleton<RetryInterceptor>(
    () => RetryInterceptor(dio: sl<DioClient>().dio),
  );
  sl.registerLazySingleton<LoggingInterceptor>(
    () => LoggingInterceptor(),
  );
  sl.registerLazySingleton<ErrorInterceptor>(
    () => ErrorInterceptor(),
  );

  // Dio Client
  sl.registerLazySingleton<DioClient>(
    () => DioClient(
      authInterceptor: sl(),
      retryInterceptor: sl(),
      loggingInterceptor: sl(),
      errorInterceptor: sl(),
    ),
  );

  // ─── Data Sources ──────────────────────────────────────
  sl.registerLazySingleton<ProductRemoteDataSource>(
    () => ProductRemoteDataSourceImpl(sl<DioClient>()),
  );
  sl.registerLazySingleton<ProductLocalDataSource>(
    () => ProductLocalDataSourceImpl(sl<DatabaseHelper>()),
  );

  // ─── Repositories ─────────────────────────────────────
  sl.registerLazySingleton<ProductRepository>(
    () => ProductRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  // ─── Use Cases ─────────────────────────────────────────
  sl.registerLazySingleton(() => GetProducts(sl()));

  // ─── BLoCs ─────────────────────────────────────────────
  // BLoC biasanya factory, bukan singleton (per-screen lifecycle)
  sl.registerFactory(
    () => PaginatedProductBloc(getProducts: sl()),
  );
}
```

**Perbedaan registration BLoC vs Riverpod:**

| Aspek | Riverpod | BLoC + get_it |
|-------|----------|---------------|
| Controller/BLoC | `@riverpod class ... extends _$...` | `sl.registerFactory(() => Bloc(...))` |
| Repository | `Provider((ref) => Impl(ref.watch(...)))` | `sl.registerLazySingleton(() => Impl(sl()))` |
| Lifecycle | Auto-dispose by Riverpod | Factory = baru tiap resolve, Singleton = app lifetime |
| Access di widget | `ref.watch(provider)` | `context.read<Bloc>()` via BlocProvider |

---


## Workflow Steps

1. **Setup Dio Client**
   - Configure base options, timeout, default headers
   - Register sebagai `@lazySingleton` di get_it
   - Add interceptors (auth, retry, logging, error)

2. **Implement Auth Flow**
   - Login/logout API via AuthRemoteDataSource
   - Token storage di SecureStorageService
   - Auth interceptor attach token otomatis
   - Token refresh mechanism (401 handling)

3. **Create Repository Layer**
   - Implement remote data source (Dio calls)
   - Implement local data source (SQLite/Hive cache)
   - Create repository dengan offline-first strategy
   - Register semua di get_it

4. **Setup Error Handling**
   - ErrorMapper: DioException → AppException
   - AppException → Failure (untuk Either pattern)
   - User-friendly error messages (bahasa Indonesia)
   - ErrorInterceptor sebagai last-resort handler

5. **Implement Pagination BLoC**
   - Sealed events: Load, LoadNextPage, Refresh, Search
   - Single state class dengan status enum
   - Debounce transformer untuk search
   - Guard duplicate loads

6. **Build UI Layer**
   - BlocProvider di router/widget tree
   - BlocBuilder untuk render berdasarkan state
   - BlocListener untuk side effects (snackbar, navigation)
   - ScrollController untuk infinite scroll detection
   - Pull-to-refresh dengan RefreshIndicator

7. **Add Optimistic Updates**
   - Update local cache dulu (instant UX)
   - Sync ke remote di background
   - Queue pending operations kalau offline
   - Rollback jika remote gagal (optional)

8. **Test Integration**
   - Unit test BLoC dengan `bloc_test` package
   - Mock repository via get_it override
   - Test error scenarios (timeout, 401, 500)
   - Test offline behavior
   - Test pagination edge cases (empty page, last page)


## Success Criteria

- [ ] Dio configured sebagai `@lazySingleton` di get_it
- [ ] Auth interceptor menggunakan `sl<SecureStorageService>()`
- [ ] Auth token auto-refresh berfungsi (401 → refresh → retry)
- [ ] Error mapping DioException → AppException → Failure berfungsi
- [ ] Repository dengan offline-first strategy implemented
- [ ] PaginatedProductBloc handle LoadProducts, LoadNextPage, RefreshProducts, SearchProducts
- [ ] Search dengan debounce 300ms
- [ ] Infinite scroll dengan ScrollController berfungsi
- [ ] BlocListener menampilkan error snackbar
- [ ] Retry mechanism untuk 5xx errors (max 3x, exponential backoff)
- [ ] Timeout configured: connect 15s, receive 15s, send 15s
- [ ] Error messages user-friendly (bahasa Indonesia)
- [ ] BLoC testable dengan `bloc_test`


## Best Practices

### Do This
- Set API timeout ke 15s (bukan 30s default Dio)
- Register BLoC sebagai `factory` di get_it (bukan singleton) — setiap screen instance dapat BLoC baru
- Register repository/data source sebagai `lazySingleton` — shared across app
- Implement cache-first strategy untuk data yang jarang berubah
- Use debounce (300ms) untuk search input events
- Implement retry interceptor untuk 5xx errors (max 3x)
- Use optimistic updates untuk create/update/delete (instant UX)
- Always check connectivity sebelum API call di repository
- Implement pull-to-refresh + pagination combo
- Use shimmer loading skeletons untuk initial load (bukan CircularProgressIndicator)
- Gunakan `buildWhen` di `BlocBuilder` untuk optimize rebuild

### Avoid This
- Jangan hardcode API URLs — gunakan `AppConfig` dengan environment
- Jangan skip error handling di interceptor chain
- Jangan load semua data sekaligus — gunakan pagination (20 items/page)
- Jangan skip connectivity check di repository
- Jangan pakai `CircularProgressIndicator` untuk initial load — pakai shimmer
- Jangan register BLoC sebagai singleton kecuali benar-benar global (misal AuthBloc)
- Jangan akses BLoC langsung dari interceptor — gunakan service locator atau event bus
- Jangan lupa `dispose` ScrollController dan TextEditingController
- Jangan panggil `context.read<Bloc>()` di dalam `build` method — panggil di callback atau initState


## Testing Strategy

```dart
// test/features/product/presentation/bloc/paginated_product_bloc_test.dart
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockGetProducts extends Mock implements GetProducts {}

void main() {
  late PaginatedProductBloc bloc;
  late MockGetProducts mockGetProducts;

  setUp(() {
    mockGetProducts = MockGetProducts();
    bloc = PaginatedProductBloc(getProducts: mockGetProducts);
  });

  tearDown(() => bloc.close());

  group('LoadProducts', () {
    final tProducts = [
      const Product(id: '1', name: 'Product 1', price: 100),
      const Product(id: '2', name: 'Product 2', price: 200),
    ];

    blocTest<PaginatedProductBloc, PaginatedProductState>(
      'emits [loading, loaded] when LoadProducts succeeds',
      build: () {
        when(() => mockGetProducts(any()))
            .thenAnswer((_) async => Right(tProducts));
        return bloc;
      },
      act: (bloc) => bloc.add(const LoadProducts()),
      expect: () => [
        const PaginatedProductState(status: ProductStatus.loading),
        PaginatedProductState(
          status: ProductStatus.loaded,
          products: tProducts,
          currentPage: 1,
          hasMore: false, // < 20 items
        ),
      ],
    );

    blocTest<PaginatedProductBloc, PaginatedProductState>(
      'emits [loading, error] when LoadProducts fails',
      build: () {
        when(() => mockGetProducts(any()))
            .thenAnswer((_) async => const Left(ServerFailure('Server error')));
        return bloc;
      },
      act: (bloc) => bloc.add(const LoadProducts()),
      expect: () => [
        const PaginatedProductState(status: ProductStatus.loading),
        const PaginatedProductState(
          status: ProductStatus.error,
          errorMessage: 'Server error',
        ),
      ],
    );
  });

  group('LoadNextPage', () {
    blocTest<PaginatedProductBloc, PaginatedProductState>(
      'does not emit when hasMore is false',
      build: () => bloc,
      seed: () => const PaginatedProductState(
        status: ProductStatus.loaded,
        hasMore: false,
      ),
      act: (bloc) => bloc.add(const LoadNextPage()),
      expect: () => [],
    );

    blocTest<PaginatedProductBloc, PaginatedProductState>(
      'appends new products when LoadNextPage succeeds',
      build: () {
        when(() => mockGetProducts(any()))
            .thenAnswer((_) async => Right([
                  const Product(id: '3', name: 'Product 3', price: 300),
                ]));
        return bloc;
      },
      seed: () => const PaginatedProductState(
        status: ProductStatus.loaded,
        products: [Product(id: '1', name: 'Product 1', price: 100)],
        currentPage: 1,
        hasMore: true,
      ),
      act: (bloc) => bloc.add(const LoadNextPage()),
      expect: () => [
        // loadingMore
        isA<PaginatedProductState>()
            .having((s) => s.status, 'status', ProductStatus.loadingMore),
        // loaded with appended products
        isA<PaginatedProductState>()
            .having((s) => s.products.length, 'count', 2)
            .having((s) => s.currentPage, 'page', 2),
      ],
    );
  });

  group('SearchProducts', () {
    blocTest<PaginatedProductBloc, PaginatedProductState>(
      'emits loading then loaded with search results',
      build: () {
        when(() => mockGetProducts(any()))
            .thenAnswer((_) async => Right([
                  const Product(id: '1', name: 'Widget', price: 100),
                ]));
        return bloc;
      },
      act: (bloc) => bloc.add(const SearchProducts('widget')),
      wait: const Duration(milliseconds: 350), // Wait for debounce
      expect: () => [
        isA<PaginatedProductState>()
            .having((s) => s.searchQuery, 'query', 'widget')
            .having((s) => s.status, 'status', ProductStatus.loading),
        isA<PaginatedProductState>()
            .having((s) => s.status, 'status', ProductStatus.loaded)
            .having((s) => s.products.length, 'count', 1),
      ],
    );
  });
}
```


## Next Steps

Setelah backend integration selesai:
1. Tambahkan WebSocket/SSE untuk real-time updates (jika diperlukan)
2. Implement file upload dengan progress tracking
3. Setup comprehensive testing (unit, widget, integration)
4. Setup CI/CD pipeline
5. Implement background sync service untuk pending operations

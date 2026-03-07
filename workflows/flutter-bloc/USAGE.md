# Flutter BLoC Workflows — User Guide

Panduan lengkap penggunaan workflows untuk development Flutter dengan BLoC dan Clean Architecture.

## 📋 Daftar Isi

1. [Overview](#overview)
2. [Persyaratan Sistem](#persyaratan-sistem)
3. [Struktur Workflow](#struktur-workflow)
4. [Cara Penggunaan](#cara-penggunaan)
5. [Contoh Prompt](#contoh-prompt)
6. [Best Practices](#best-practices)
7. [Troubleshooting](#troubleshooting)

---

## Overview

Workflows ini dirancang untuk development Flutter dengan **flutter_bloc** dan Clean Architecture yang production-ready. Setiap workflow fokus pada satu aspek development dan dapat digunakan secara berurutan maupun independen.

### Keuntungan Menggunakan Workflows

- ✅ **Clean Architecture** — Separation of concerns yang jelas (Domain / Data / Presentation)
- ✅ **flutter_bloc** — State management mature dengan `Bloc<Event, State>` dan `Cubit`
- ✅ **Sealed Classes** — Type-safe events dan states dengan Dart 3 pattern matching
- ✅ **get_it + injectable** — Dependency injection yang scalable
- ✅ **Result<T>** — Error handling tanpa `dartz` (pure Dart 3)
- ✅ **Production-Ready** — CI/CD, testing, performance monitoring
- ✅ **Testable** — `blocTest`, `MockBloc`, `whenListen`

### Perbedaan dari Flutter Riverpod Workflows

| Aspek | BLoC Workflows | Riverpod Workflows |
|-------|---------------|--------------------|
| State management | `Bloc<Event, State>` / `Cubit` | `AsyncNotifier` / `Notifier` |
| DI | `get_it` + `injectable` | Riverpod providers |
| Root widget | `MultiBlocProvider` | `ProviderScope` |
| Testing | `blocTest` + `MockBloc` | `ProviderContainer` |
| DI access | `sl<T>()` | `ref.read(provider)` |
| Reactive DI | `StreamSubscription` + `close()` | `ref.listen()` |
| Error handling | `Result<T>` sealed class | `AsyncValue<T>` |

---

## Persyaratan Sistem

- **Flutter SDK**: 3.22.0+ (stable)
- **Dart SDK**: 3.4.0+
- **IDE**: VS Code atau Android Studio

### Core Dependencies

```yaml
dependencies:
  flutter_bloc: ^8.1.4
  equatable: ^2.0.5
  get_it: ^7.6.7
  injectable: ^2.3.2
  go_router: ^14.0.0
  dio: ^5.4.0
  json_annotation: ^4.8.1

dev_dependencies:
  injectable_generator: ^2.4.1
  build_runner: ^2.4.8
  json_serializable: ^6.7.1
  bloc_test: ^9.1.7
  mocktail: ^1.0.0
```

---

## Struktur Workflow

Workflows diorganisasi dalam 4 fase:

### Fase 1: Foundation
| File | Deskripsi |
|------|-----------|
| `01_project_setup.md` | Project setup, Clean Architecture, get_it + injectable |
| `02_feature_maker.md` | Feature generator (Domain → Data → Presentation) |
| `03_ui_components.md` | AppButton, AppTextField, Shimmer, EmptyState |

### Fase 2: Data & Patterns
| File | Deskripsi |
|------|-----------|
| `04_state_management_advanced.md` | Riverpod AsyncNotifier, family, pagination, debounce. |
| `05_backend_integration.md` | REST API, Dio, interceptors, pagination BLoC |
| `06_firebase_integration.md` | Firebase Auth, Firestore, Storage, FCM |
| `07_supabase_integration.md` | Supabase Auth, PostgreSQL, Realtime, Storage |
| `08_offline_storage.md` | Hive cache, Isar queries, SecureStorage |

### Fase 3: Enhancement
| File | Deskripsi |
|------|-----------|
| `09_translation.md` | easy_localization, LocaleCubit, multi-bahasa |
| `10_push_notifications.md` | FCM dan local notification dengan deep linking routing |

### Fase 4: Quality, Security & Deploy
| File | Deskripsi |
|------|-----------|
| `11_testing_production.md` | blocTest, MockBloc, CI/CD, integration tests |
| `12_performance_monitoring.md` | Sentry tracing, Firebase Crashlytics, Security Hardening |

---

## Cara Penggunaan

### 1. Mulai dari Project Setup

```
Gunakan workflow @flutter-bloc/01_project_setup

Buat Flutter project baru dengan:
- Nama: my_app
- Bundel ID: com.example.my_app
- Target: Android + iOS + Web
- Clean Architecture + flutter_bloc + get_it
```

### 2. Generate Feature Baru

```
Gunakan workflow @flutter-bloc/02_feature_maker

Buat feature "orders" dengan:
- GET /api/v1/orders (list)
- GET /api/v1/orders/:id (detail)
- POST /api/v1/orders (create)
- PUT /api/v1/orders/:id/cancel (cancel)

Model Order: id, userId, items, totalAmount, status, createdAt
```

### 3. Backend Integration

```
Gunakan workflow @flutter-bloc/03_backend_integration

Setup Dio dengan:
- Base URL: https://api.myapp.com/v1
- Auth interceptor (JWT + refresh token)
- Retry 3x pada network error
- Logging di debug mode
- Pagination untuk /orders endpoint
```

### 4. Firebase Integration

```
Gunakan workflow @flutter-bloc/04_firebase_integration

Setup Firebase:
- Email + password auth
- Firestore untuk data produk
- Firebase Storage untuk upload foto
- FCM untuk notifikasi pesanan baru
```

### 5. Testing

```
Gunakan workflow @flutter-bloc/06_testing_production

Generate tests untuk:
- ProductBloc: LoadProducts, CreateProduct, DeleteProduct
- ProductRepository: online vs offline scenarios
- ProductListScreen: semua state (loading, loaded, empty, error)
- CI/CD dengan GitHub Actions
```

---

## Contoh Prompt

### Project Setup

```
Gunakan workflow @flutter-bloc/01_project_setup

Setup Flutter project "tokoko" dengan:
- Package: com.example.tokoko
- Deskripsi: Platform e-commerce Indonesia
- Target platforms: Android, iOS, Web
- State management: flutter_bloc
- DI: get_it + injectable
- Routing: go_router
- Feature example: Product (CRUD)
```

### Feature Generator

```
Gunakan workflow @flutter-bloc/02_feature_maker

Buat feature "transactions" untuk aplikasi fintech:
- Domain entities: Transaction (id, type, amount, status, createdAt)
- Use cases: GetTransactions, GetTransactionDetail, CreateTransaction
- Repository: TransactionRepository (REST API)
- BLoC: TransactionBloc dengan events: LoadTransactions, LoadMore, FilterByType
- States: initial, loading, loaded(transactions, hasMore), error
- Screen: list dengan infinite scroll + filter tabs (All, Credit, Debit)
- Navigation: /transactions, /transactions/:id
```

### Backend Integration

```
Gunakan workflow @flutter-bloc/03_backend_integration

Implementasi REST API untuk feature transactions:
- Base URL: https://api.fintech.id/v2
- Auth: Bearer JWT + refresh via /auth/refresh
- Retry: 3x dengan exponential backoff
- Pagination: cursor-based (next_cursor, limit=20)
- Endpoints:
  - GET /transactions?cursor=&limit=20&type=
  - GET /transactions/:id
  - POST /transactions
```

### Firebase Auth

```
Gunakan workflow @flutter-bloc/04_firebase_integration

Setup Firebase dengan:
- Auth: Email/Password + Google Sign-In
- Firestore: products collection dengan real-time updates
- AuthBloc: handle login, signup, logout, session expiry
- GoRouter redirect: /login jika unauthenticated
- FCM token saved ke Firestore user document
```

### Testing Suite

```
Gunakan workflow @flutter-bloc/06_testing_production

Generate comprehensive tests:
Target coverage: 80%

1. Unit tests (blocTest):
   - TransactionBloc (semua events)
   - TransactionRepository (online + offline)
   - AuthBloc (login, logout, session states)

2. Widget tests (MockBloc + whenListen):
   - TransactionListScreen (all states)
   - LoginScreen (form validation + dispatch)
   - TransactionCard (tap navigation)

3. CI/CD (GitHub Actions):
   - Test + analyze on push
   - Build APK on main branch
   - Upload to Play Store internal
```

### Advanced State Patterns

```
Gunakan workflow @flutter-bloc/09_state_management_advanced

Implementasi:
1. Optimistic updates untuk ProductBloc:
   - Delete langsung remove dari list, rollback jika API error
2. Cross-Bloc komunikasi:
   - CartBloc listen ke ProductBloc via StreamSubscription
3. Debounce search:
   - EventTransformer debounce 500ms untuk SearchProducts
```

### Translation

```
Gunakan workflow @flutter-bloc/07_translation

Setup localization:
- Bahasa: id-ID (default), en-US
- Key categories: common, auth, product, order, errors, validation
- LocaleCubit dengan SharedPreferences persistence
- Language selector di Settings screen
- Pluralization untuk product count
```

---

## Best Practices

### BLoC Architecture

```dart
// ✅ BENAR: Sealed events + Equatable
sealed class ProductEvent extends Equatable {
  const ProductEvent();
}
final class LoadProducts extends ProductEvent { const LoadProducts(); }

// ✅ BENAR: Sealed states
sealed class ProductState extends Equatable { ... }
final class ProductLoaded extends ProductState { ... }

// ✅ BENAR: BlocConsumer untuk listen + build sekaligus
BlocConsumer<ProductBloc, ProductState>(
  listenWhen: (p, c) => c is ProductCreated,
  listener: (ctx, state) => /* show snackbar */,
  builder: (ctx, state) => /* UI */,
);

// ❌ SALAH: setState di dalam BlocBuilder
BlocBuilder<ProductBloc, ProductState>(
  builder: (ctx, state) {
    setState(() => _items = state.products); // JANGAN!
    return ListView(...);
  },
);
```

### Lifecycle Management

```dart
// ✅ BENAR: Cancel StreamSubscription di close()
@override
Future<void> close() {
  _subscription?.cancel();
  return super.close();
}

// ✅ BENAR: Provide BLoC di route, bukan global (kecuali yang global)
GoRoute(
  path: '/products',
  builder: (context, state) => BlocProvider(
    create: (_) => sl<ProductBloc>()..add(const LoadProducts()),
    child: const ProductListScreen(),
  ),
);

// ❌ SALAH: Provide di-add setelah widget build
// BLoC harus sudah di-provide sebelum build()
```

### Error Handling

```dart
// ✅ BENAR: Result<T> sealed class
Future<Result<Product>> createProduct(Product product) async {
  try {
    final data = await _remote.createProduct(product.toModel());
    return Success(data.toEntity());
  } on ServerException catch (e) {
    return ResultFailure(ServerFailure(message: e.message));
  }
}

// ❌ SALAH: dartz Either
Future<Either<Failure, Product>> createProduct(...) // JANGAN!
```

### Testing

```dart
// ✅ BENAR: blocTest dengan seed dan expect
blocTest<ProductBloc, ProductState>(
  'emits [ProductCreated, ProductLoaded] on success',
  build: () => productBloc,
  seed: () => ProductLoaded(tProducts), // state awal
  act: (bloc) => bloc.add(CreateProductEvent(newProduct)),
  expect: () => [isA<ProductCreated>(), isA<ProductLoaded>()],
);

// ✅ BENAR: tearDown wajib
tearDown(() => productBloc.close()); // WAJIB!

// ✅ BENAR: Widget test pakai BlocProvider.value()
Widget createWidget() => BlocProvider<ProductBloc>.value(
  value: mockProductBloc,
  child: const ProductListScreen(),
);
```

---

## Troubleshooting

### `get_it` service tidak ditemukan

```
Error: Object/factory with type X is not registered inside GetIt.
```

**Solusi:**
1. Pastikan `@injectable` atau `@lazySingleton` sudah ditambahkan ke class
2. Jalankan `dart run build_runner build -d`
3. Cek `injectable.config.dart` sudah ter-generate
4. Pastikan `configureDependencies()` dipanggil di `main()` / `bootstrap()`

---

### BLoC tidak menerima events

**Solusi:**
1. Cek `BlocProvider` ada di atas widget dalam tree
2. Gunakan `context.read<BlocType>()` untuk dispatch (bukan `context.watch()`)
3. Pastikan BLoC belum di-`close()` saat event di-dispatch

---

### `build_runner` error

```bash
# Bersihkan semua generated files
dart run build_runner clean
dart run build_runner build --delete-conflicting-outputs
```

---

### StreamSubscription leak

**Solusi:** Selalu cancel `StreamSubscription` di `close()`:

```dart
StreamSubscription? _subscription;

// di constructor atau on<Event> handler:
_subscription = stream.listen((_) => add(Event()));

@override
Future<void> close() {
  _subscription?.cancel();
  return super.close();
}
```

---

### Widget test: `MockBloc` tidak trigger rebuild

**Solusi:** Gunakan `whenListen` dengan initial state yang benar:

```dart
whenListen(
  mockBloc,
  Stream<State>.empty(), // stream kosong = tidak ada update
  initialState: ProductLoaded(tProducts), // ← ini yang dipakai BlocBuilder
);
```

---

## Output Structure

Semua output workflow ditulis ke dalam project Flutter di direktori fitur masing-masing. Struktur yang dihasilkan mengikuti Clean Architecture:

```
lib/
├── core/
│   ├── di/                    # get_it + injectable
│   ├── error/                 # Result<T>, Failures, Exceptions
│   ├── network/               # DioClient, interceptors
│   ├── storage/               # CacheService, SecureStorage
│   ├── router/                # GoRouter, AuthGuard  
│   └── widgets/               # AppButton, Shimmer, dll
├── features/
│   └── {feature_name}/
│       ├── domain/
│       │   ├── entities/
│       │   ├── repositories/  # abstract
│       │   └── usecases/
│       ├── data/
│       │   ├── datasources/
│       │   ├── models/        # json_serializable
│       │   └── repositories/  # impl
│       └── presentation/
│           ├── bloc/          # BLoC + sealed events/states
│           └── screens/
└── l10n/                      # LocaleCubit, locale_config
```

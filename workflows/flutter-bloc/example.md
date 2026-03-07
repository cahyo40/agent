# Flutter BLoC Workflows — Copy-Paste Prompts

Kumpulan prompt siap pakai untuk setiap workflow. Salin dan sesuaikan dengan nama project kamu.

---

## 01. Project Setup

```
Gunakan workflow @flutter-bloc/01_project_setup

Setup Flutter project baru dengan konfigurasi berikut:
- Nama package: my_app
- Bundle ID: com.example.my_app
- Deskripsi: Aplikasi e-commerce Indonesia
- Target platforms: Android, iOS, Web
- State management: flutter_bloc + Cubit
- DI: get_it + injectable
- Routing: go_router
- Buat contoh feature "product" sebagai referensi

Jalankan semua langkah termasuk pub get dan code generation.
```

---

## 02. Feature Generator

```
Gunakan workflow @flutter-bloc/02_feature_maker

Buat feature baru untuk aplikasi e-commerce:

Feature name: "order"
API Base: /api/v1/orders

Domain:
  Entity: Order(id, userId, items: List<OrderItem>, totalAmount, status, createdAt, updatedAt)
  Entity: OrderItem(productId, name, qty, price)
  Use Cases:
    - GetOrders (paginated, filter by status)
    - GetOrderDetail (by id)
    - CreateOrder (dari cart)
    - CancelOrder (by id, dengan alasan)

BLoC:
  Events: LoadOrders, LoadMoreOrders, FilterByStatus, RefreshOrders
  States: initial, loading, loaded(orders, hasMore, filter), error, refreshing
  Cubit: CreateOrderCubit (idle, loading, success(order), error)

Screens:
  - OrderListScreen: list dengan filter tabs (All, Pending, Processing, Delivered, Cancelled)
  - OrderDetailScreen: detail + cancel button (jika status Pending)
  - CreateOrderBottomSheet: summary + confirm button

Routing:
  - /orders (list)
  - /orders/:id (detail)
```

---

## 03. Backend Integration

```
Gunakan workflow @flutter-bloc/03_backend_integration

Integrasi REST API untuk aplikasi:

Konfigurasi Dio:
  - Base URL: https://api.myapp.com/v1
  - Timeout connect: 10s, receive: 30s
  - Headers: Content-Type, Accept, X-App-Version

Interceptors:
  - Auth: inject "Authorization: Bearer {accessToken}", auto refresh via POST /auth/refresh jika 401
  - Retry: 3x pada SocketException/TimeoutException dengan exponential backoff (1s, 2s, 4s)
  - Logging: log request + response di DEBUG mode saja

Error handling:
  - 400 → ValidationFailure
  - 401 → UnauthorizedFailure (+ trigger logout)
  - 403 → ForbiddenFailure
  - 404 → NotFoundFailure
  - 500 → ServerFailure
  - SocketException → NetworkFailure
  - TimeoutException → TimeoutFailure

Pagination:
  Buat PaginatedProductBloc untuk:
  Endpoint: GET /products?page={page}&limit=20&search={query}&category={cat}
  Response: { data: [], meta: { total, page, lastPage } }
  Events: LoadProducts, LoadMoreProducts, SearchProducts (debounce 500ms), FilterByCategory
  States: initial, loading, loadingMore, loaded(products, hasMore, currentPage), error
```

---

## 04. Firebase Integration

```
Gunakan workflow @flutter-bloc/04_firebase_integration

Setup Firebase untuk aplikasi:

Auth (AuthBloc):
  - Providers: Email/Password + Google Sign-In
  - States: unauthenticated, loading, authenticated(user), error
  - StreamSubscription ke Firebase authStateChanges
  - GoRouter redirect: /login jika unauthenticated

Firestore (ProductBloc):
  - Collection: "products/{userId}/items"
  - Real-time listener via emit.forEach()
  - CRUD operations (add, update, delete)
  - Offline persistence diaktifkan

Storage (UploadCubit):
  - Upload foto profil dan gambar produk
  - Show upload progress (0.0 - 1.0)
  - Path: users/{userId}/profile.jpg, products/{productId}/images/

FCM (NotificationService):
  - Request permission saat login
  - Simpan FCM token ke Firestore: users/{userId}/fcmToken
  - Tampilkan local notification saat foreground
  - Deep link ke /products/:id dari notifikasi

DI: Daftarkan semua ke injectable module FirebaseModule.
```

---

## 05. Supabase Integration

```
Gunakan workflow @flutter-bloc/05_supabase_integration

Integrasi Supabase:

Auth (AuthBloc):
  - Email/Password + Magic Link
  - Listen ke onAuthStateChange stream
  - Simpan session, handle token refresh otomatis
  - GoRouter redirect guard

Database (ProductBloc):
  - Table: products (id, user_id, name, price, stock, image_url, created_at)
  - Operations: select (dengan filter), insert, update, delete
  - RLS: users hanya bisa akses data milik sendiri

Realtime (CartBloc):
  - Subscribe ke channel "public:cart_items" filter user_id
  - Events: INSERT, UPDATE, DELETE
  - Sync cart items real-time

Storage (UploadCubit):
  - Bucket: "product-images" (public)
  - Bucket: "user-avatars" (authenticated)
  - Upload dengan progress tracking

Jalankan semua SQL migrations + RLS policies.
```

---

## 06. Testing & Production

```
Gunakan workflow @flutter-bloc/06_testing_production

Buat comprehensive test suite:

Unit tests (blocTest):
  - ProductBloc: LoadProducts (success, failure, empty), CreateProduct (success, validation error, server error), DeleteProduct (success, optimistic rollback)
  - CartCubit: addItem, removeItem, updateQty, clearCart, totalCalculation
  - AuthBloc: login, logout, sessionExpiry, tokenRefresh
  - Target: 80% coverage

Widget tests (MockBloc + whenListen):
  - ProductListScreen: semua states (shimmer, loaded, empty, error)
  - LoginScreen: form validation, loading state, error snackbar
  - CartBottomSheet: item list, quantity update, checkout button enabled/disabled

Repository tests:
  - ProductRepositoryImpl: online (fetch + cache), offline (serve from cache), network error (fallback)

CI/CD (GitHub Actions):
  - On push main/develop: flutter analyze, flutter test --coverage
  - On push main: build APK + upload artifact
  - Minimum coverage: 80%

Tambahkan tearDown(() => bloc.close()) di setiap test.
```

---

## 07. Translation

```
Gunakan workflow @flutter-bloc/07_translation

Setup localization:

Bahasa: id-ID (default), en-US
Path: assets/translations/

Key categories yang dibutuhkan:
  - app: name, version
  - common: ok, cancel, save, delete, retry, loading, search, noData
  - auth: login, register, email, password, forgotPassword, logout
  - product: title, addProduct, noProducts, deleteConfirm, productCount (plural)
  - order: title, status (pending/processing/shipped/delivered/cancelled)
  - settings: title, language, selectLanguage, theme
  - errors: generic, network, serverError, unauthorized
  - validation: required, invalidEmail, passwordTooShort, passwordMismatch

LocaleCubit:
  - Simpan locale ke SharedPreferences key "locale"
  - Default: id-ID
  - Support RTL (jika ada bahasa RTL di masa depan)

Language selector bottom sheet di halaman Settings.
```

---

## 09. Advanced BLoC Patterns

```
Gunakan workflow @flutter-bloc/09_state_management_advanced

Implementasi pola-pola advanced:

1. Optimistic Updates (ProductBloc):
   - Delete: langsung hapus dari state, rollback jika API error + tampilkan snackbar
   - Update status: update lokal dulu, sinkron dengan server

2. Cross-Bloc Communication:
   - AuthBloc → ProductBloc: reset produk saat logout
   - CartBloc listen ke ProductBloc: update price saat produk di-update
   - Gunakan StreamSubscription di constructor, cancel di close()

3. Debounce Search (EventTransformer):
   - SearchProducts: debounce 500ms, cancel request sebelumnya

4. Concurrent Events:
   - LoadProducts: restartable (cancel ongoing jika event baru masuk)
   - FilterByCategory: sequential (antrian)
   - AnalyticsEvent: concurrent (semua diproses)
```

---

## 10. Offline Storage

```
Gunakan workflow @flutter-bloc/10_offline_storage

Setup offline-first storage:

Hive (cache sederhana):
  - CacheService dengan TTL metadata
  - Cache products list: TTL 1 jam
  - Cache user profile: TTL 24 jam
  - Auto invalidate saat TTL expired

Isar (complex queries):
  - Schema: ProductSchema (id, name, price, stock, category, updatedAt)
  - Full-text search pada name dan description
  - Sort by price, date
  - Index pada category dan updatedAt

SecureStorage:
  - accessToken, refreshToken
  - userId, userEmail
  - biometricEnabled

ConnectivityCubit (connectivity_plus):
  - States: checking, online, offline
  - Emit perubahan connectivity
  - Repository: online → fetch remote + update cache, offline → serve from cache

Implementasikan offline banner widget yang muncul saat offline.
```

---

## 11. UI Components

```
Gunakan workflow @flutter-bloc/11_ui_components

Buat reusable widget library:

AppButton:
  - Variants: primary, secondary, destructive, ghost
  - Sizes: small (36), medium (48), large (56)
  - Loading state dengan CircularProgressIndicator
  - Optional icon (leading)

AppTextField:
  - Label di atas field
  - Hint text, error text
  - Password toggle (visibility on/off)
  - Support prefix/suffix icon

Shimmer:
  - ShimmerBox(width, height, borderRadius)
  - ShimmerListItem (avatar + 2 baris text)
  - ShimmerList(itemCount: 6)
  - ShimmerCard(height) untuk grid

EmptyStateWidget:
  - Icon dalam circle container
  - Title + description
  - Optional action button

AppErrorWidget:
  - Error icon
  - Message
  - Retry button

AppCard:
  - Rounded corners (12)
  - InkWell tap effect
  - Customizable padding

AppCachedImage:
  - CachedNetworkImage dengan shimmer placeholder
  - Error placeholder (broken image icon)
  - Configurable border radius

Export semua dari core/widgets/widgets.dart.
```

---

## 12. Push Notifications

```
Gunakan workflow @flutter-bloc/12_push_notifications

Setup notifikasi lengkap:

FCM:
  - Request permission saat user login
  - Simpan token ke backend (POST /users/fcm-token)
  - Handle token refresh otomatis
  - Background handler (@pragma vm:entry-point)

Local Notifications:
  - Channel: HIGH_IMPORTANCE (Importance.max)
  - Tampilkan saat foreground via onMessage
  - Android & iOS config

Deep Linking dari tap notifikasi:
  - type: "order" → /orders/:id
  - type: "product" → /products/:id
  - type: "promo" → /promotions
  - type: "chat" → /chat/:id

Android manifest:
  - POST_NOTIFICATIONS permission
  - Meta FCM channel

FcmTokenCubit:
  - register() setelah login
  - unregister() sebelum logout
```

---

> 💡 **Tips:** Setiap prompt bisa disesuaikan dengan nama entity, endpoint, dan requirement spesifik project kamu. Workflow akan otomatis mengikuti semua best practices BLoC tanpa perlu instruksi tambahan.

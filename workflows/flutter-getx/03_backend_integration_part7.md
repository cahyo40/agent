---
description: Implementasi repository pattern dengan REST API menggunakan Dio. (Part 7/7)
---
# Workflow: Backend Integration (REST API) - GetX (Part 7/7)

> **Navigation:** This workflow is split into 7 parts.

## Workflow Steps

### Step 1: Setup Dependencies

Tambahkan package ke `pubspec.yaml`:

```bash
flutter pub add dio connectivity_plus hive_flutter pretty_dio_logger
```

### Step 2: Buat Error Classes

Buat `lib/core/error/app_exception.dart` dan `lib/core/error/error_mapper.dart` sesuai Deliverable #2.

### Step 3: Implementasi DioClient dan Interceptors

1. Buat `DioClient` extends `GetxService` (Deliverable #1.1)
2. Buat `AuthInterceptor` dengan `Get.find<StorageService>()` (Deliverable #1.3)
3. Buat `RetryInterceptor` (Deliverable #1.4)
4. Buat `LoggingInterceptor` (Deliverable #1.5)
5. Buat `ErrorInterceptor` (Deliverable #1.6)

### Step 4: Register di InitialBinding

Tambahkan `DioClient` dan `NetworkInfo` ke `InitialBinding.dependencies()` (Deliverable #1.2).

### Step 5: Buat API Response Wrappers

Buat `ApiResponse` dan `PaginatedResponse` models (Deliverable #5).

### Step 6: Implementasi Repository

1. Buat `BaseRepository` dengan `safeRequest()` helper (Deliverable #3.2)
2. Buat `ProductRepository` extends `BaseRepository` (Deliverable #3.3)
3. Buat `ProductLocalDataSource` untuk offline cache (Deliverable #3.4)

### Step 7: Implementasi Pagination Controller dan View

1. Buat `PaginatedProductController` extends `GetxController` (Deliverable #4.1)
2. Buat `ProductBinding` (Deliverable #4.2)
3. Buat `ProductListView` extends `GetView` dengan `Obx()` (Deliverable #4.3)
4. Daftarkan route dengan binding di `app_routes.dart`

---


## Success Criteria

### Functional
- [ ] DioClient ter-register sebagai `GetxService` dan bisa diakses via `Get.find<DioClient>()` dari mana saja
- [ ] AuthInterceptor otomatis menambahkan token dari `StorageService` ke setiap request
- [ ] Token refresh berjalan otomatis saat menerima 401, tanpa user interaction
- [ ] Retry mechanism aktif untuk network error dan timeout (max 3 kali, exponential backoff)
- [ ] Semua DioException ter-map ke `AppException` yang deskriptif dan user-friendly
- [ ] Repository pattern bekerja dengan offline-first strategy (cache → API → cache)
- [ ] Pagination (infinite scroll) bekerja dengan smooth scroll dan load-more indicator
- [ ] Pull-to-refresh me-reset dan fetch ulang dari page 1
- [ ] Search ter-debounce 500ms dan trigger re-fetch otomatis
- [ ] Optimistic delete bekerja dengan rollback saat API error

### Non-Functional
- [ ] Tidak ada memory leak — `ScrollController` di-dispose di `onClose()`
- [ ] Tidak ada duplikat request saat loading (guard di `loadMore()` dan `_fetchProducts()`)
- [ ] Error message ditampilkan dalam Bahasa Indonesia yang jelas
- [ ] Log request/response hanya muncul di debug mode (`AppConfig.enableLogging`)
- [ ] Cache memiliki expiry time (default 1 jam)

---


## Best Practices

### DO

- **DO** gunakan `GetxService` untuk singleton service (DioClient, NetworkInfo, StorageService)
- **DO** gunakan `GetxController` untuk state yang terikat ke halaman/feature
- **DO** gunakan `.obs` untuk reactive state dan `Obx()` untuk rebuild widget
- **DO** gunakan `Bindings` untuk dependency injection per halaman — jangan `Get.put()` langsung di widget
- **DO** gunakan `safeRequest()` wrapper di repository untuk konsistensi error handling
- **DO** dispose `ScrollController` di `onClose()` — GetX tidak auto-dispose Flutter controller
- **DO** gunakan `debounce()` dari GetX untuk search input — lebih bersih dari manual Timer
- **DO** simpan backup sebelum optimistic update/delete untuk rollback
- **DO** gunakan `Get.find()` di interceptor dan repository — service sudah ter-register permanent
- **DO** gunakan sealed class untuk `AppException` supaya compiler enforce exhaustive checking

### DON'T

- **DON'T** panggil `Get.put()` di dalam widget `build()` — gunakan Binding atau `onInit()`
- **DON'T** akses `controller` di `GetView` sebelum binding selesai — pastikan route punya binding
- **DON'T** campurkan `.obs` dengan `update()` dalam satu controller — pilih salah satu approach
- **DON'T** gunakan `GetxController` untuk service yang harus persist selamanya — gunakan `GetxService`
- **DON'T** lupa `permanent: true` saat `Get.put()` service yang harus hidup sepanjang app
- **DON'T** catch generic `Exception` di controller — catch `AppException` supaya pesan error tepat
- **DON'T** hardcode base URL di DioClient — gunakan `AppConfig` yang bisa di-switch per environment
- **DON'T** simpan token di SharedPreferences — gunakan `FlutterSecureStorage` atau encrypted Hive
- **DON'T** retry POST/PUT/DELETE request di RetryInterceptor — hanya retry GET dan idempotent request
- **DON'T** tampilkan raw error message dari server ke user — selalu map ke pesan yang user-friendly

---


## Perbandingan GetX vs Riverpod (Backend Integration)

| Aspek | GetX | Riverpod |
|-------|------|----------|
| DioClient registration | `Get.put<DioClient>(...)` | `Provider((ref) => DioClient(...))` |
| Akses di interceptor | `Get.find<StorageService>()` | `ref.read(storageProvider)` |
| Akses di repository | `Get.find<DioClient>()` | `ref.read(dioProvider)` |
| Pagination state | `RxList`, `RxBool` | `StateNotifier` / `AsyncValue` |
| Scroll listener | Manual di `GetxController.onInit()` | Manual di `ConsumerStatefulWidget` |
| View binding | `GetView<Controller>` + `Obx()` | `ConsumerWidget` + `ref.watch()` |
| DI per halaman | `Bindings` | `ProviderScope` overrides |
| Search debounce | `debounce()` built-in GetX | Manual / `Debouncer` class |

---


## Next Steps

Setelah backend integration selesai, lanjutkan ke:

- **`04_state_management.md`** — Advanced GetX state management patterns (nested controllers, workers, inter-controller communication)
- **`05_auth_flow.md`** — Complete authentication flow dengan GetX middleware dan route guards
- **`06_testing.md`** — Unit test untuk repository, controller, dan integration test

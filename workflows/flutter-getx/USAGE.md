# Flutter GetX Workflows — User Guide

Panduan lengkap penggunaan workflows untuk development Flutter dengan GetX dan Clean Architecture.

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

Workflows ini dirancang untuk development Flutter dengan **GetX** dan Clean Architecture yang production-ready. Setiap workflow fokus pada satu aspek development dan dapat digunakan secara berurutan maupun independen.

### Keuntungan Menggunakan Workflows

- ✅ **Clean Architecture** — Separation of concerns yang jelas (Domain / Data / Presentation)
- ✅ **GetX** — State management yang simpel, reactive, dan powerful (`.obs`, `Obx()`)
- ✅ **No Code Generation** — Tidak menggunakan `build_runner` untuk DI atau routing
- ✅ **Built-in DI & Routing** — `GetMaterialApp`, `Bindings`, dan `Get.put()`
- ✅ **Result<T>** — Error handling tanpa `dartz` (pure Dart 3)
- ✅ **Production-Ready** — CI/CD, testing, performance monitoring
- ✅ **Reactive Programming** — Menggunakan `Workers` (`ever`, `debounce`, dll) untuk side-effects

---

## Persyaratan Sistem

- **Flutter SDK**: 3.22.0+ (stable)
- **Dart SDK**: 3.4.0+
- **IDE**: VS Code atau Android Studio

### Core Dependencies

```yaml
dependencies:
  get: ^4.6.6
  equatable: ^2.0.5
  get_storage: ^2.1.1
  dio: ^5.4.0
  json_annotation: ^4.8.1

dev_dependencies:
  build_runner: ^2.4.8
  json_serializable: ^6.7.1
  mocktail: ^1.0.0
```

---

## Struktur Workflow

Workflows diorganisasi dalam 4 fase:

### Fase 1: Foundation
| File | Deskripsi |
|------|-----------|
| `01_project_setup.md` | Project setup, Clean Architecture, GetX DI + Routing |
| `02_feature_maker.md` | Feature generator (Domain → Data → Presentation) |
| `03_ui_components.md` | AppButton, AppTextField, Shimmer, EmptyState |

### Fase 2: Data & Patterns
| File | Deskripsi |
|------|-----------|
| `04_state_management_advanced.md` | Workers, StateMixin, pagination, debounce, cross-controller |
| `05_backend_integration.md` | REST API, Dio, interceptors, pagination GetX |
| `06_firebase_integration.md` | Firebase Auth, Firestore, Storage, FCM |
| `07_supabase_integration.md` | Supabase Auth, PostgreSQL, Realtime, Storage |
| `08_offline_storage.md` | GetStorage cache, Hive, SecureStorage |

### Fase 3: Enhancement
| File | Deskripsi |
|------|-----------|
| `09_translation.md` | easy_localization, LocaleController, multi-bahasa |
| `10_push_notifications.md` | FCM dan local notification dengan GetX navigation |

### Fase 4: Quality, Security & Deploy
| File | Deskripsi |
|------|-----------|
| `11_testing_production.md` | Unit Tests, Widget Tests, Get.testMode, CI/CD |
| `12_performance_monitoring.md` | Sentry tracing, Firebase Crashlytics, Security Hardening |

---

## Cara Penggunaan

### 1. Mulai dari Project Setup

```
Gunakan workflow @flutter-getx/01_project_setup

Buat Flutter project baru dengan:
- Nama: my_app
- Bundel ID: com.example.my_app
- Target: Android + iOS + Web
- Clean Architecture + GetX
```

### 2. Generate Feature Baru

```
Gunakan workflow @flutter-getx/02_feature_maker

Buat feature "orders" dengan:
- GET /api/v1/orders (list)
- GET /api/v1/orders/:id (detail)
- POST /api/v1/orders (create)
- PUT /api/v1/orders/:id/cancel (cancel)

Model Order: id, userId, items, totalAmount, status, createdAt
```

### 3. Backend Integration

```
Gunakan workflow @flutter-getx/05_backend_integration

Setup Dio dengan:
- Base URL: https://api.myapp.com/v1
- Auth interceptor (JWT + refresh token)
- Retry 3x pada network error
- Logging di debug mode
- Pagination untuk /orders endpoint
```

### 4. Firebase Integration

```
Gunakan workflow @flutter-getx/06_firebase_integration

Setup Firebase:
- Email + password auth
- Firestore untuk data produk
- Firebase Storage untuk upload foto
- FCM untuk notifikasi pesanan baru
```

### 5. Testing

```
Gunakan workflow @flutter-getx/11_testing_production

Generate tests untuk:
- ProductController: fetchProducts, createProduct, deleteProduct
- ProductRepository: online vs offline scenarios
- ProductListScreen: semua state (loading, loaded, empty, error)
- CI/CD dengan GitHub Actions
```

---

## Contoh Prompt

*(Contoh prompt bisa dilihat secara lengkap di `examples.md`)*

---

## Best Practices

### GetX Architecture

```dart
// ✅ BENAR: Reactive variable dengan .obs
final count = 0.obs;

// ✅ BENAR: Controller dengan lifecycle terstruktur
class MyController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    // Inisialisasi awal, listen ke workers
  }
}

// ✅ BENAR: Menggunakan Obx untuk re-render UI yang reactive
Obx(() => Text('${controller.count.value}'));

// ❌ SALAH: GetBuilder untuk reactive variable (.obs)
// Gunakan GetBuilder hanya untuk state management simple yang menggunakan update()
```

### Lifecycle Management

```dart
// ✅ BENAR: Cleanup resources di onClose()
@override
void onClose() {
  _streamSubscription?.cancel();
  super.onClose();
}

// ✅ BENAR: Menggunakan Bindings untuk DI per route
class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => HomeController());
  }
}

// ❌ SALAH: Get.put() yang membabi buta tanpa kontrol memory
// Gunakan Bindings dan biarkan GetX membuang controller secara otomatis.
```

### Error Handling

```dart
// ✅ BENAR: Result<T> sealed class dari Clean Architecture
Future<Result<Product>> createProduct(Product product) async {
  try {
    final data = await _remote.createProduct(product.toModel());
    return Success(data.toEntity());
  } on ServerException catch (e) {
    return Failure(FailureReason.serverError, message: e.message);
  }
}
```

---

## Troubleshooting

### `Get.find()` Not Found

```
"UserController" not found. You need to call "Get.put(UserController())"
```

**Solusi:**
1. Pastikan `Binding` sudah diregister pada `GetPage` di AppRoutes.
2. Jika menggunakan inisialisasi manual, pastikan `Get.put()` dipanggil sebelum `Get.find()`.

---

### UI Tidak Mengupdate (Reactive)

**Solusi:**
1. Pastikan variabel yang di-update bertipe `Rx` (memiliki akhiran `.obs`).
2. Jangan lupa menggunakan `.value` saat mengambil atau mengubah nilai (contoh: `count.value++`).
3. Widget UI harus dibungkus secara langsung oleh `Obx()`.

---

### GetStorage Initialization Error

```
GetStorage not initialized. Call GetStorage.init() first.
```

**Solusi:** Pastikan `await GetStorage.init()` dipanggil di `main()` sebelum `runApp()`.

---

### Stream Leak atau Callback Berjalan Terus-menerus

**Solusi:** Selalu cancel `StreamSubscription` atau hentikan background task di method `onClose()` controller.

---

## Output Structure

Semua output workflow ditulis ke dalam project Flutter di direktori fitur masing-masing. Struktur yang dihasilkan mengikuti Clean Architecture:

```
lib/
├── core/
│   ├── bindings/              # AppBindings, InitialBinding
│   ├── error/                 # Result<T>, Failures, Exceptions
│   ├── network/               # DioClient, interceptors
│   ├── storage/               # GetStorage service
│   ├── routes/                # Generate routes, AppPages  
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
│           ├── bindings/      # FeatureBinding
│           ├── controllers/   # GetxController
│           └── screens/       # GetView / UI
└── l10n/                      # Translations config
```

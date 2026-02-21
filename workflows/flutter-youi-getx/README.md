# Flutter YoUI + GetX Workflows

Workflows untuk development Flutter dengan **GetX** state management, **YoUI** component library, dan **Clean Architecture**.

## System Requirements

- **Flutter SDK:** 3.41.1+ (stable channel)
- **Dart SDK:** 3.11.0+
- **Tested on:** Flutter 3.41.1 • Dart 3.11.0 • DevTools 2.54.1

### Compatibility Notes:
- ✅ **Fully compatible** dengan Flutter 3.41.1
- ✅ Firebase packages updated ke v3.x.x untuk kompatibilitas
- ✅ Semua dependencies menggunakan versi terbaru yang stable
- ✅ **No code generation** — tidak memerlukan build_runner, freezed, atau generator lainnya

## Struktur Workflows

```
workflows/flutter-youi/
├── 01_project_setup.md              # Setup project Flutter + GetX + Clean Architecture
├── 02_feature_maker.md              # Generator untuk membuat feature baru
├── 03_backend_integration.md        # REST API integration dengan Dio
├── 04_firebase_integration.md       # Firebase (Auth, Firestore, Storage, FCM)
├── 05_supabase_integration.md       # Supabase (Auth, PostgreSQL, Realtime, Storage)
├── 06_testing_production.md         # Testing + CI/CD + Production deployment
├── 07_translation.md                # Translation & Localization (i18n)
├── 08_state_management_advanced.md  # Advanced GetX: Workers, StateMixin, pagination, optimistic
├── 09_offline_storage.md            # GetStorage cache, Hive, flutter_secure_storage
├── 10_ui_components.md              # YoUI widget library (YoButton, YoCard, YoShimmer, YoToast, etc.)
├── 11_push_notifications.md         # FCM + local notifications + deep linking
├── 12_performance_monitoring.md     # Sentry, Firebase Crashlytics, performance tracing
└── USAGE.md                         # Dokumentasi penggunaan lengkap
```

## Output Folder Structure

Ketika workflows dijalankan, hasil akan disimpan di:

```
sdlc/flutter-youi/
├── 01-project-setup/
│   ├── project-structure.md
│   ├── pubspec.yaml
│   ├── lib/
│   │   ├── app/
│   │   │   ├── bindings/
│   │   │   └── routes/
│   │   ├── core/
│   │   ├── features/example/
│   │   │   ├── bindings/
│   │   │   ├── controllers/
│   │   │   ├── data/
│   │   │   ├── domain/
│   │   │   └── presentation/
│   │   └── main.dart
│   └── README.md
│
├── 02-feature-maker/
│   ├── feature-templates/
│   └── examples/
│
├── 03-backend-integration/
│   ├── dio-setup.md
│   ├── interceptors/
│   ├── error-handling.md
│   └── repository-pattern.md
│
├── 04-firebase-integration/
│   ├── firebase-setup.md
│   ├── auth/
│   ├── firestore/
│   ├── storage/
│   └── fcm/
│
├── 05-supabase-integration/
│   ├── supabase-setup.md
│   ├── auth/
│   ├── database/
│   ├── realtime/
│   └── storage/
│
├── 06-testing-production/
│   ├── testing/
│   ├── ci-cd/
│   ├── performance/
│   └── deployment/
│
└── 07-translation/
    ├── assets/translations/
    ├── lib/core/locale/
    └── language-selector.md
```

## Urutan Penggunaan

1. **01_project_setup.md** - Setup project dari nol
2. **02_feature_maker.md** - Generate feature baru (bisa dijalankan berkali-kali)
3. Pilih salah satu atau beberapa:
   - **03_backend_integration.md** - Untuk REST API
   - **04_firebase_integration.md** - Untuk Firebase
   - **05_supabase_integration.md** - Untuk Supabase
4. **08_state_management_advanced.md** - Advanced GetX patterns
5. **09_offline_storage.md** - Offline-first storage
6. **10_ui_components.md** - Reusable widget library
7. **11_push_notifications.md** - Push notifications (jika diperlukan)
8. **07_translation.md** - Translation & Localization (opsional)
9. **06_testing_production.md** - Testing dan deployment
10. **12_performance_monitoring.md** - Monitoring di production

### Workflow Optional:
- **07_translation.md** - Gunakan jika app membutuhkan multiple languages
- **11_push_notifications.md** - Gunakan jika app butuh push notifications

## Fitur Utama

### 01 - Project Setup
- Clean Architecture folder structure dengan GetX pattern
- GetX reactive state management (`.obs` + `Obx()`)
- Dependency injection dengan `Bindings`
- Dependencies lengkap (Dio, GetX Routing, GetStorage, YoUI)
- YoUI theme integration (`YoTheme.lightTheme/darkTheme`)
- Example feature dengan semua states (loading, error, empty, data)
- `YoShimmer` loading skeletons

### 02 - Feature Maker
- Template generator untuk feature baru
- Auto-generate domain, data, presentation layers
- CRUD operations template
- Controller dengan `GetxController`, Screen dengan `GetView`
- Binding template untuk dependency injection
- YoUI widgets: `YoCard`, `YoButton`, `YoShimmer`, `YoToast`

### 03 - Backend Integration (REST API)
- Dio setup dengan interceptors lengkap
- Auth interceptor dengan token refresh
- Retry interceptor (3x untuk 5xx errors)
- Error mapper (DioException → AppException)
- Repository pattern dengan offline-first
- Pagination dengan infinite scroll

### 04 - Firebase Integration
- Firebase Auth (email/password, Google Sign-In)
- Cloud Firestore CRUD + real-time streams
- Firebase Storage (upload dengan progress)
- Firebase Cloud Messaging (push notifications)
- Security Rules + Offline persistence

### 05 - Supabase Integration
- Supabase Auth (magic link, OAuth, phone)
- PostgreSQL dengan Row Level Security (RLS)
- Realtime subscriptions + Supabase Storage

### 06 - Testing & Production
- Unit tests dengan mocktail, Widget tests, Integration tests
- GitHub Actions CI/CD pipeline + Fastlane
- Performance optimization + Production checklist

### 07 - Translation & Localization
- Easy Localization setup + JSON translation files (EN, ID, MS, TH, VN)
- Locale controller dengan `GetxController`
- Language selector widget + Locale persistence dengan `GetStorage`

### 08 - Advanced State Management
- Workers: `debounce`, `ever`, `once`, `interval`
- `StateMixin` dengan `obx()` untuk loading/error/empty/data
- Pagination dengan load-more + `isLoadingMore.obs`
- Optimistic update dengan rollback
- Cross-controller communication via `ever()`

### 09 - Offline Storage
- `GetStorage` cache dengan TTL
- Offline-first repository pattern
- Hive untuk complex data
- `flutter_secure_storage` untuk tokens
- Reactive `ConnectivityService` dengan `.obs`

### 10 - UI Components (YoUI)
- `YoButton` (variants: primary, secondary, outline, ghost)
- `YoText` (typography: headline, title, body, label)
- `YoCard` (consistent card styling)
- `YoShimmer.card()` dan `YoShimmer.listTile()` untuk loading
- `YoToast.success/error/info/warning()` untuk notifications
- `YoModal.show()` untuk bottom sheets
- `EmptyStateView` dan `ErrorView` dengan YoUI components

### 11 - Push Notifications
- FCM foreground/background/terminated handling
- `flutter_local_notifications` sebagai `GetxService`
- Deep link navigation via `Get.toNamed()`
- `FcmTokenController` untuk register/unregister

### 12 - Performance & Monitoring
- Sentry error monitoring + performance tracing
- Firebase Crashlytics crash reporting
- Global error handler (Flutter + Dart async)
- User context (ID, email) untuk error attribution
- Pre-release performance checklist

## State Management

Semua workflows menggunakan **GetX** reactive state management:
- Reactive variables dengan `.obs` extension
- UI rebuilds dengan `Obx()` widget
- `GetxController` lifecycle (`onInit`, `onReady`, `onClose`)
- `StateMixin` untuk loading/error/data states
- Workers (`ever`, `once`, `debounce`, `interval`) untuk reactive side effects
- Tidak memerlukan code generation — simple dan langsung

## Architecture Pattern

**Clean Architecture** dengan GetX pattern:
- **Domain**: Entities, Repository contracts, Use cases
- **Data**: Models, Repository implementations, Data sources
- **Presentation**: Controllers (`GetxController`), Screens (`GetView`), Widgets

**Dependency Injection** via `Bindings` — setiap route punya binding class yang mendaftarkan
dependencies dengan `Get.lazyPut()`. Controller otomatis di-dispose saat route di-pop.

**Routing** via `GetMaterialApp` + `GetPage` — built-in routing dengan support untuk
named routes, middlewares, transition animations, dan nested navigation.

## Dependencies Utama

```yaml
dependencies:
  # State Management + Routing + DI
  get: ^4.6.6

  # UI Component Library
  yo_ui:
    git:
      url: https://github.com/cahyo40/youi.git
      ref: main

  # Network
  dio: ^5.4.0
  connectivity_plus: ^6.0.0

  # Storage
  get_storage: ^2.1.1
  flutter_secure_storage: ^9.0.0

  # Firebase (optional) - Updated untuk Flutter 3.41.1
  firebase_core: ^3.12.0
  firebase_auth: ^5.5.0
  cloud_firestore: ^5.6.0
  firebase_storage: ^12.4.0
  firebase_messaging: ^15.2.0

  # Supabase (optional)
  supabase_flutter: ^2.8.0

  # Translation (optional)
  easy_localization: ^3.0.7
  intl: ^0.19.0

  # Utils
  json_annotation: ^4.8.1
  dartz: ^0.10.1
  equatable: ^2.0.5

dev_dependencies:
  json_serializable: ^6.7.1
  build_runner: ^2.4.9
  flutter_test:
    sdk: flutter
  mocktail: ^1.0.0
```

> **Note:** Tidak memerlukan `freezed`, `riverpod_generator`, `riverpod_lint`, atau `custom_lint`.
> Code generation hanya untuk `json_serializable` (opsional — bisa diganti manual `fromJson`/`toJson`).

## Best Practices yang Diikuti

### ✅ Do This
- ✅ Clean Architecture dengan clear separation
- ✅ `GetxController` dengan proper lifecycle (`onInit`, `onClose`)
- ✅ `Bindings` untuk dependency injection per route
- ✅ Repository pattern dengan Either type
- ✅ Offline-first strategy dengan `GetStorage`
- ✅ Error handling terstruktur + Shimmer loading skeletons
- ✅ `Workers` untuk debounce search (300-500ms)
- ✅ Pagination untuk long lists + const constructors
- ✅ Unit test coverage ≥ 80%
- ✅ `Get.lazyPut()` untuk lazy initialization
- ✅ `GetView` instead of `StatelessWidget` + `Get.find()`

### ❌ Avoid This
- ❌ Hardcode API URLs
- ❌ Skip error handling atau connectivity check
- ❌ Load semua data sekaligus
- ❌ Use `CircularProgressIndicator` untuk initial load
- ❌ `Get.put()` tanpa `Bindings` (memory leak risk)
- ❌ Akses controller sebelum binding dijalankan
- ❌ Nested `Obx()` yang tidak perlu
- ❌ Mutable state tanpa `.obs`

## Testing

### Unit Tests
- Use cases, Repositories (dengan mocking), Controllers, Services

### Widget Tests
- Screens dengan semua states, User interactions, Form validation, Navigation

### Integration Tests
- End-to-end flows, Complete user journeys

### Testing Commands

```bash
# Run semua tests
flutter test

# Run single test file
flutter test test/path/to/test.dart

# Run tests dengan coverage
flutter test --coverage

# Run tests dengan verbose output
flutter test -v
```

## CI/CD

GitHub Actions workflows untuk:
- Code analysis (`flutter analyze`)
- Unit tests dengan coverage
- Widget tests
- Build APK/IPA
- Deploy ke Play Store/App Store (via Fastlane)

## Production Checklist

Sebelum release, pastikan:
- [ ] All tests passing
- [ ] Code coverage ≥ 80%
- [ ] No analyzer warnings
- [ ] Performance optimized (DevTools)
- [ ] App signing configured
- [ ] Store listings prepared
- [ ] Privacy policy
- [ ] App icons & screenshots

## Troubleshooting

### Get.find() Not Found
```
"UserController" not found. You need to call "Get.put(UserController())"
```
**Solusi:** Pastikan `Binding` sudah terdaftar di `GetPage`, atau panggil `Get.put()` sebelum `Get.find()`.

### Binding Tidak Dijalankan
Controller tidak ter-initialize saat navigasi. Gunakan **named route** (`Get.toNamed('/user')`)
agar binding jalan, atau pass binding manual: `Get.to(() => Screen(), binding: MyBinding())`.

### GetStorage Initialization Error
```
GetStorage not initialized. Call GetStorage.init() first.
```
**Solusi:** Pastikan `await GetStorage.init()` dipanggil di `main()` sebelum `runApp()`.

### Memory Leak - Controller Tidak Di-dispose
Gunakan `SmartManagement.full` (default) di `GetMaterialApp` untuk auto-dispose.
Jika `Get.put()` manual, pastikan cleanup di `onClose()` atau panggil `Get.delete<T>()`.

### Dependency Conflicts
```bash
flutter pub upgrade
flutter pub outdated
```

### Testing Issues
```bash
# Setup GetX untuk testing
Get.testMode = true;

# Run single test
flutter test test/path/to/test.dart -v
```

## Next Steps Setelah Workflows

1. Monitor production performance
2. Setup analytics dan crash reporting
3. Collect user feedback
4. Plan iterations dan new features
5. Regular maintenance dan updates

## Resources

- [Flutter Documentation](https://docs.flutter.dev)
- [GetX Documentation](https://pub.dev/packages/get)
- [GetX Pattern](https://github.com/nicandrodelpozo/getx_pattern)
- [Clean Architecture](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
- [Flutter Testing](https://docs.flutter.dev/testing)

---

**Note:** Workflows ini dirancang untuk production-ready Flutter apps dengan best practices industry standard. GetX dipilih untuk simplicity — all-in-one solution (state management, routing, DI) tanpa code generation.

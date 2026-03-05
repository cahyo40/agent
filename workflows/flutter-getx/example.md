# Contoh Penggunaan Workflows — Flutter GetX

> Panduan langkah demi langkah cara menggunakan 12 workflows ini.
> Setiap langkah berisi **prompt yang bisa langsung di-copy-paste** dan penjelasan apa yang terjadi.

---

## Skenario: Membuat Aplikasi Personal Finance Tracker

Anda ingin membuat aplikasi pencatatan keuangan pribadi — catat income/expense,
lihat statistik, backup ke cloud, dengan fitur multi-bahasa.

---

## Phase 1: Foundation

### 01 — Project Setup

**Prompt yang Anda ketik:**
```
Buatkan project Flutter baru bernama "dompetku" untuk aplikasi personal
finance tracker. Gunakan workflow 01_project_setup.md.
```

**Apa yang terjadi:**
- Agen membaca `01_project_setup.md`
- Agen menjalankan `flutter create --org com.example --project-name dompetku .`
- Agen setup Clean Architecture folders, GetX, Dio, GetStorage
- Agen membuat GetX routing (`GetPage` + `Bindings`)
- Agen membuat example feature sebagai referensi
- **Tidak perlu `build_runner`** — GetX tanpa code generation!

**Output:**
```
dompetku/
├── lib/
│   ├── app/
│   │   ├── bindings/initial_binding.dart
│   │   └── routes/
│   │       ├── app_pages.dart    ← GetPage definitions
│   │       └── app_routes.dart   ← Route constants
│   ├── core/
│   │   ├── error/failures.dart, result.dart
│   │   ├── network/dio_client.dart
│   │   ├── theme/app_theme.dart
│   │   └── utils/extensions.dart
│   ├── features/example/
│   │   ├── bindings/example_binding.dart
│   │   ├── controllers/example_controller.dart
│   │   ├── data/ (model, repo_impl, datasource)
│   │   ├── domain/ (entity, repo, usecase)
│   │   └── presentation/ (screens, widgets)
│   └── main.dart
├── pubspec.yaml
└── analysis_options.yaml
```

---

### 02 — Feature Maker

**Prompt yang Anda ketik:**
```
Generate feature "transaction" dengan fields:
- id (String)
- title (String)
- amount (double)
- type (TransactionType enum: income, expense)
- category (String)
- date (DateTime)
- note (String?)

Gunakan workflow 02_feature_maker.md
```

**Apa yang terjadi:**
- Agen membaca `02_feature_maker.md`
- Agen generate 3 layers lengkap: domain, data, presentation
- Agen membuat entity, model (manual fromJson/toJson), repository, use cases
- Agen membuat `TransactionController` extends `GetxController`
- Agen membuat `TransactionBinding` untuk dependency injection
- Agen register routes di `app_pages.dart` dengan `GetPage`

**Output per feature:**
```
lib/features/transaction/
├── bindings/
│   └── transaction_binding.dart     ← Get.lazyPut() semua deps
├── controllers/
│   └── transaction_controller.dart  ← GetxController + .obs
├── domain/
│   ├── entities/transaction.dart
│   ├── repositories/transaction_repository.dart
│   └── usecases/
│       ├── get_transactions.dart
│       └── create_transaction.dart
├── data/
│   ├── models/transaction_model.dart
│   ├── datasources/transaction_remote_ds.dart
│   ├── datasources/transaction_local_ds.dart
│   └── repositories/transaction_repository_impl.dart
└── presentation/
    ├── screens/transaction_list_screen.dart  ← GetView
    ├── screens/transaction_detail_screen.dart
    └── widgets/transaction_shimmer.dart
```

**Prompt untuk feature tambahan:**
```
Generate feature "category" dengan fields:
- id (String)
- name (String)
- icon (String)
- color (String)
- type (TransactionType: income, expense)
```

```
Generate feature "budget" dengan fields:
- id (String)
- categoryId (String)
- amount (double)
- spent (double)
- month (int)
- year (int)
```

---

### 03 — UI Components

**Prompt yang Anda ketik:**
```
Setup reusable UI components untuk app dompetku.
Gunakan workflow 03_ui_components.md
```

**Apa yang terjadi:**
- Agen membaca `03_ui_components.md`
- Agen membuat 8 reusable widgets: AppButton, AppTextField, AppCard,
  EmptyStateWidget, AppErrorWidget, ShimmerList, AppDialog, AppBottomSheet
- Agen menggunakan `Get.dialog()` dan `Get.bottomSheet()` untuk interaksi
- Semua widget support light & dark mode via `Theme.of(context)`

**Output:**
```
lib/core/widgets/
├── app_button.dart           ← primary, secondary, destructive, ghost
├── app_text_field.dart       ← password toggle, validation
├── app_card.dart             ← tap, leading, trailing
├── empty_state_widget.dart   ← icon, title, description, action
├── app_error_widget.dart     ← error message, retry button
├── shimmer_widget.dart       ← ShimmerWidget, ShimmerListItem, ShimmerList
├── app_dialog.dart           ← Get.dialog() wrapper
├── app_bottom_sheet.dart     ← Get.bottomSheet() wrapper
└── widgets.dart              ← barrel export
```

---

## Phase 2: Data & Patterns

### 04 — State Management Advanced

**Prompt yang Anda ketik:**
```
Implementasikan advanced GetX patterns untuk feature transaction:
- Workers (debounce search, ever filter)
- StateMixin untuk loading/error/data states
- Pagination dengan load-more
- Optimistic delete dengan rollback

Gunakan workflow 04_state_management_advanced.md
```

**Apa yang terjadi:**
- Agen membaca `04_state_management_advanced.md`
- Agen membuat `TransactionListController` dengan `StateMixin`
- Agen membuat Workers: `debounce` untuk search (400ms), `ever` untuk filter
- Agen membuat pagination dengan `isLoadingMore.obs`
- Agen membuat optimistic delete di controller

**Output:**
```
lib/features/transaction/controllers/
├── transaction_list_controller.dart    ← StateMixin + pagination
├── transaction_detail_controller.dart  ← Per-item controller
├── transaction_search_controller.dart  ← Debounce search (400ms)
└── transaction_actions_controller.dart ← Optimistic delete
```

**Contoh penggunaan di screen:**
```dart
// StateMixin — loading/error/data otomatis
class TransactionListController extends GetxController
    with StateMixin<List<Transaction>> {
  
  @override
  void onInit() {
    super.onInit();
    fetchTransactions();
    
    // Worker: debounce search 400ms
    debounce(searchQuery, (_) => fetchTransactions(),
        time: const Duration(milliseconds: 400));
    
    // Worker: filter changes → refetch
    ever(selectedFilter, (_) => fetchTransactions());
  }
}

// Di screen — obx() untuk state handling
controller.obx(
  (data) => ListView.builder(
    itemCount: data!.length,
    itemBuilder: (_, i) => TransactionCard(data[i]),
  ),
  onLoading: const ShimmerList(),
  onError: (err) => AppErrorWidget(
    message: err ?? 'Error',
    onRetry: controller.fetchTransactions,
  ),
  onEmpty: const EmptyStateWidget(title: 'Belum ada transaksi'),
);
```

---

### 05 — Backend Integration (REST API)

**Prompt yang Anda ketik:**
```
Setup backend integration dengan REST API untuk app dompetku.
Base URL: https://api.dompetku.com/v1
Gunakan workflow 05_backend_integration.md
```

**Apa yang terjadi:**
- Agen membaca `05_backend_integration.md`
- Agen setup Dio client dengan 3 interceptors
- Agen membuat error mapper (DioException → AppException)
- Agen register `DioClient` via `Get.lazyPut()` di `InitialBinding`

**Output:**
```
lib/core/network/
├── dio_client.dart               ← Base Dio setup (15s timeout)
├── interceptors/
│   ├── auth_interceptor.dart     ← Token inject + auto-refresh
│   ├── retry_interceptor.dart    ← 3x retry untuk 5xx
│   └── logging_interceptor.dart  ← Request/response logging
├── api_endpoints.dart            ← Constants
└── error_mapper.dart             ← DioException → AppException
```

**Contoh DI di InitialBinding:**
```dart
class InitialBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DioClient>(() => DioClient());
    Get.lazyPut<ConnectivityService>(
      () => ConnectivityService(),
    );
  }
}
```

**Prompt alternatif (jika pakai Firebase):**
```
Skip 05, langsung ke 06_firebase_integration.md karena
saya pakai Firebase sebagai backend.
```

---

### 06 — Firebase Integration

**Prompt yang Anda ketik:**
```
Setup Firebase untuk app dompetku dengan:
- Firebase Auth (email/password + Google Sign-In)
- Cloud Firestore untuk data transactions
- Firebase Storage untuk upload receipt foto

Gunakan workflow 06_firebase_integration.md
```

**Apa yang terjadi:**
- Agen membaca `06_firebase_integration.md`
- Agen menjalankan `flutterfire configure`
- Agen setup Firebase Auth dengan `AuthController` (permanent)
- Agen setup Firestore repository dengan realtime streams
- Agen setup Firebase Storage (upload dengan `RxDouble` progress)
- Agen register semua di `InitialBinding` dengan `permanent: true`

**Output:**
```
lib/features/auth/
├── bindings/auth_binding.dart
├── controllers/auth_controller.dart  ← GetxController permanent
├── domain/repositories/auth_repository.dart
└── data/repositories/auth_repository_impl.dart

lib/core/firebase/
├── firebase_options.dart
└── firestore_service.dart            ← GetxService
```

**Contoh auth controller:**
```dart
class AuthController extends GetxController {
  final Rx<User?> user = Rx<User?>(null);
  
  @override
  void onInit() {
    super.onInit();
    // Listen auth state changes
    user.bindStream(
      FirebaseAuth.instance.authStateChanges(),
    );
    // React to auth changes
    ever(user, _handleAuthChanged);
  }
  
  void _handleAuthChanged(User? user) {
    if (user == null) {
      Get.offAllNamed(AppRoutes.LOGIN);
    } else {
      Get.offAllNamed(AppRoutes.HOME);
    }
  }
}
```

**Prompt alternatif (jika pakai Supabase):**
```
Setup Supabase untuk app dompetku.
Gunakan workflow 07_supabase_integration.md
```

---

### 07 — Supabase Integration (Alternatif)

**Prompt yang Anda ketik:**
```
Setup Supabase sebagai backend untuk app dompetku:
- Supabase Auth (email + Google OAuth)
- PostgreSQL untuk data transactions
- Realtime subscription untuk sync antar device
- Supabase Storage untuk receipt

Gunakan workflow 07_supabase_integration.md
```

**Apa yang terjadi:**
- Agen membaca `07_supabase_integration.md`
- Agen setup `SupabaseService` extends `GetxService` (permanent)
- Agen membuat migration SQL dan RLS policies
- Agen setup realtime via controller Workers
- Agen setup storage service

**Output:**
```
lib/core/supabase/
├── supabase_service.dart             ← GetxService permanent
└── supabase_storage_service.dart     ← Upload/download

lib/features/auth/
├── controllers/auth_controller.dart  ← Rx<User?> auth state
└── data/repositories/supabase_auth_repo_impl.dart

lib/features/transaction/data/
├── datasources/transaction_supabase_ds.dart
└── repositories/transaction_repository_impl.dart
```

**Contoh realtime dengan GetX Workers:**
```dart
class TransactionController extends GetxController {
  late final StreamSubscription _sub;
  final transactions = <Transaction>[].obs;
  
  @override
  void onInit() {
    super.onInit();
    // Supabase realtime → update .obs list
    _sub = Supabase.instance.client
        .from('transactions')
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .listen((rows) {
      transactions.value = rows
          .map(TransactionModel.fromJson)
          .toList();
    });
  }
  
  @override
  void onClose() {
    _sub.cancel(); // Always cleanup!
    super.onClose();
  }
}
```

---

### 08 — Offline Storage

**Prompt yang Anda ketik:**
```
Implementasikan offline-first storage untuk app dompetku:
- GetStorage cache untuk simple data
- Hive untuk complex objects
- flutter_secure_storage untuk tokens
- Connectivity monitoring

Gunakan workflow 08_offline_storage.md
```

**Apa yang terjadi:**
- Agen membaca `08_offline_storage.md`
- Agen setup `GetStorage` cache sebagai `GetxService` dengan TTL
- Agen setup `Hive` untuk complex data
- Agen setup `flutter_secure_storage` untuk tokens
- Agen setup `ConnectivityService` dengan `isConnected.obs`
- Agen menggunakan `Result<T>` sealed class (bukan dartz)

**Output:**
```
lib/core/storage/
├── storage_service.dart          ← GetStorage cache + TTL
├── hive_service.dart             ← Hive for complex data
├── secure_storage.dart           ← Token storage
└── connectivity_service.dart     ← isConnected.obs
```

**Contoh offline-first flow:**
```dart
@override
Future<Result<List<Transaction>>>
    getTransactions() async {
  // 1. Cek cache dulu
  final cached = storageService.get('transactions');
  if (cached != null) return Success(cached);

  // 2. Cek connectivity
  final connectivity = Get.find<ConnectivityService>();
  if (connectivity.isConnected.value) {
    // 3. Fetch from remote
    final remote = await remoteDs.getTransactions();
    storageService.set(
      'transactions', remote,
      ttl: const Duration(minutes: 15),
    );
    return Success(remote);
  }

  // 3b. Offline → fetch from Hive
  final local = await hiveService.getTransactions();
  return Success(local);
}
```

---

## Phase 3: Enhancements (Opsional)

### 09 — Translation

**Prompt yang Anda ketik:**
```
Tambahkan multi-language support untuk app dompetku.
Bahasa: Indonesia (default), English, Malay.
Gunakan workflow 09_translation.md
```

**Apa yang terjadi:**
- Agen membaca `09_translation.md`
- Agen setup GetX built-in Translations (`AppTranslations extends Translations`)
- Agen membuat translation maps per locale (Dart Maps)
- Agen membuat `LocaleController` dengan `GetxController`
- Agen persist locale dengan `GetStorage`
- Agen menambahkan `.tr` extension ke semua hardcoded strings

**Output:**
```
lib/core/translations/
├── app_translations.dart      ← extends Translations
├── id_id.dart                 ← Map<String, String>
├── en_us.dart                 ← Map<String, String>
└── ms_my.dart                 ← Map<String, String>

lib/core/locale/
├── locale_controller.dart     ← GetxController
└── language_selector.dart     ← Widget pemilih bahasa
```

**Contoh penggunaan:**
```dart
// Setup di GetMaterialApp
GetMaterialApp(
  translations: AppTranslations(),
  locale: const Locale('id', 'ID'),
  fallbackLocale: const Locale('en', 'US'),
);

// Penggunaan di widget
Text('transaction.title'.tr)

// Ganti bahasa runtime
Get.updateLocale(const Locale('en', 'US'));
```

---

### 10 — Push Notifications

**Prompt yang Anda ketik:**
```
Setup push notifications untuk app dompetku:
- Reminder harian untuk catat pengeluaran (local notification)
- Notifikasi saat budget hampir habis (FCM)
- Deep link ke halaman transaction detail

Gunakan workflow 10_push_notifications.md
```

**Apa yang terjadi:**
- Agen membaca `10_push_notifications.md`
- Agen setup `NotificationService` extends `GetxService`
- Agen setup FCM + flutter_local_notifications
- Agen membuat deep link handler via `Get.toNamed()`
- Agen membuat `FcmTokenController` untuk register/unregister

**Output:**
```
lib/core/notifications/
├── notification_service.dart    ← GetxService (FCM + local)
├── deep_link_handler.dart       ← Get.toNamed() navigation
└── fcm_token_controller.dart    ← Register/unregister
```

**Contoh deep link handler:**
```dart
void handleNotificationTap(RemoteMessage message) {
  final type = message.data['type'];
  final id = message.data['id'];

  switch (type) {
    case 'transaction':
      Get.toNamed('/transaction/detail/$id');
    case 'budget_alert':
      Get.toNamed('/budget/$id');
    default:
      Get.toNamed('/home');
  }
}
```

**Contoh scheduled notification:**
```dart
// Daily reminder jam 20:00
await flutterLocalNotifications.zonedSchedule(
  0,
  'Sudah catat pengeluaran hari ini?',
  'Tap untuk tambah transaksi',
  _nextInstance(20, 0),
  notificationDetails,
  androidScheduleMode:
      AndroidScheduleMode.exactAllowWhileIdle,
  matchDateTimeComponents:
      DateTimeComponents.time,
  payload: '/transaction/create',
);
```

---

## Phase 4: Quality & Deploy

### 11 — Testing & Production

**Prompt yang Anda ketik:**
```
Setup testing dan CI/CD untuk app dompetku:
- Unit tests untuk use cases dan repositories
- Widget tests untuk screens
- GitHub Actions CI pipeline
- Production build checklist

Gunakan workflow 11_testing_production.md
```

**Apa yang terjadi:**
- Agen membaca `11_testing_production.md`
- Agen membuat unit tests dengan mocktail
- Agen setup GetX test mode (`Get.testMode = true`)
- Agen membuat widget tests untuk screens
- Agen setup GitHub Actions CI/CD
- Agen membuat production checklist

**Contoh unit test dengan GetX:**
```dart
void main() {
  late TransactionController controller;
  late MockTransactionRepository mockRepo;

  setUp(() {
    Get.testMode = true;
    mockRepo = MockTransactionRepository();
    Get.put<TransactionRepository>(mockRepo);
    controller = Get.put(TransactionController());
  });

  tearDown(() {
    Get.reset(); // Clean up GetX state
  });

  test('should fetch transactions on init', () async {
    when(() => mockRepo.getTransactions())
        .thenAnswer(
      (_) async => Success(tTransactions),
    );

    controller.onInit();
    await Future.delayed(Duration.zero);

    expect(controller.transactions, isNotEmpty);
    expect(controller.status.isSuccess, isTrue);
  });
}
```

**Output CI/CD:**
```
.github/workflows/
├── ci.yml         ← analyze + test + build
└── deploy.yml     ← Play Store / App Store via Fastlane
```

---

### 12 — Performance Monitoring

**Prompt yang Anda ketik:**
```
Setup monitoring untuk app dompetku di production:
- Sentry untuk error tracking
- Firebase Crashlytics untuk crash reporting
- Performance tracing

Gunakan workflow 12_performance_monitoring.md
```

**Apa yang terjadi:**
- Agen membaca `12_performance_monitoring.md`
- Agen setup Sentry (DSN via env var, performance tracing)
- Agen setup Firebase Crashlytics (crash reports)
- Agen setup global error handler (Flutter + Dart async errors)
- Agen set user context setelah login

**Output:**
```
lib/bootstrap/bootstrap.dart  ← Error zones + Sentry init
lib/core/monitoring/
├── sentry_service.dart        ← Sentry init + tracing
└── crashlytics_service.dart   ← Firebase Crashlytics
```

**Contoh global error handler:**
```dart
Future<void> bootstrap() async {
  await SentryFlutter.init(
    (options) {
      options.dsn = const String.fromEnvironment(
        'SENTRY_DSN',
      );
      options.tracesSampleRate = 0.2;
    },
    appRunner: () {
      FlutterError.onError = (details) {
        Sentry.captureException(
          details.exception,
          stackTrace: details.stack,
        );
        FirebaseCrashlytics.instance
            .recordFlutterFatalError(details);
      };

      runApp(GetMaterialApp(
        initialBinding: InitialBinding(),
        // ...
      ));
    },
  );
}
```

**Contoh set user context:**
```dart
// Di AuthController, setelah login
ever(user, (User? u) {
  if (u != null) {
    Sentry.configureScope((scope) {
      scope.setUser(SentryUser(
        id: u.uid,
        email: u.email,
      ));
    });
    FirebaseCrashlytics.instance
        .setUserIdentifier(u.uid);
  }
});
```

---

## Ringkasan: Semua Prompt dalam 1 Flow

Berikut urutan prompt dari awal sampai akhir:

```
🏗️ PHASE 1: Foundation
──────────────────────
1. "Buatkan project Flutter baru 'dompetku' untuk personal
    finance tracker. Gunakan workflow 01_project_setup.md"

2. "Generate feature 'transaction' dengan fields: id, title,
    amount, type, category, date, note.
    Gunakan workflow 02_feature_maker.md"

3. "Generate feature 'category' dengan fields: id, name,
    icon, color, type"

4. "Generate feature 'budget' dengan fields: id, categoryId,
    amount, spent, month, year"

5. "Setup reusable UI components. 
    Gunakan workflow 03_ui_components.md"


📊 PHASE 2: Data & Patterns
────────────────────────────
6. "Implementasikan advanced GetX patterns: Workers,
    StateMixin, pagination, optimistic delete.
    Gunakan workflow 04_state_management_advanced.md"

7. "Setup Firebase: Auth, Firestore, Storage.
    Gunakan workflow 06_firebase_integration.md"

8. "Setup offline storage: GetStorage cache, Hive,
    secure storage, connectivity monitoring.
    Gunakan workflow 08_offline_storage.md"


🌍 PHASE 3: Enhancements (opsional)
────────────────────────────────────
9. "Tambahkan multi-language: Indonesia, English, Malay.
    Gunakan workflow 09_translation.md"

10. "Setup push notifications: daily reminder, budget alerts.
     Gunakan workflow 10_push_notifications.md"


✅ PHASE 4: Quality & Deploy
─────────────────────────────
11. "Setup testing dan CI/CD pipeline.
     Gunakan workflow 11_testing_production.md"

12. "Setup Sentry + Crashlytics monitoring.
     Gunakan workflow 12_performance_monitoring.md"
```

---

## Tips Penggunaan

### 💡 Tip 1: Tidak Harus Semua Dijalankan
Phase 1 (01-03) wajib. Sisanya pilih sesuai kebutuhan project.

### 💡 Tip 2: Prompt Sederhana = OK
Agen sudah diprogram untuk menginterpretasi prompt sederhana:
```
"Jalankan workflow 02 untuk feature 'product'"
```
Sama hasilnya dengan prompt panjang.

### 💡 Tip 3: Pilih Backend (05/06/07)
Anda hanya perlu salah satu:
- `05` → REST API sendiri
- `06` → Firebase
- `07` → Supabase

### 💡 Tip 4: Feature Maker Bisa Diulang
Workflow 02 bisa dijalankan berkali-kali untuk setiap feature baru:
```
"Generate feature 'user_profile'"
"Generate feature 'notification'"
"Generate feature 'settings'"
```

### 💡 Tip 5: No Code Generation!
Berbeda dengan Riverpod, **GetX tidak memerlukan `build_runner`**
untuk state management, routing, atau DI. Cukup:
```bash
flutter pub get
flutter run
```
Code generation hanya diperlukan jika pakai `json_serializable`
(opsional — bisa diganti manual `fromJson`/`toJson`).

### 💡 Tip 6: GetX vs Riverpod — Kapan Pakai Mana?
- **GetX** → Prototyping cepat, no code gen, all-in-one solution
- **Riverpod** → Large team, strict compile-time safety, scalable

---

## Contoh Prompt untuk App Lain

### E-Commerce App
```
Buatkan project Flutter "tokoku" untuk aplikasi marketplace.
Features: product, cart, order, payment, review.
Backend: Supabase. Gunakan workflow 01_project_setup.md
```

### Social Media App
```
Buatkan project Flutter "circle" untuk social media app.
Features: post, comment, like, follow, chat.
Backend: Firebase. Gunakan workflow 01_project_setup.md
```

### Task Management App
```
Buatkan project Flutter "taskly" untuk task management.
Features: task, project, label, reminder.
Backend: REST API (https://api.taskly.com/v1).
Gunakan workflow 01_project_setup.md
```

### Health & Fitness App
```
Buatkan project Flutter "fittrack" untuk tracking olahraga.
Features: workout, exercise, progress, body_measurement.
Backend: Firebase. Gunakan workflow 01_project_setup.md
```

Semua prompt di atas akan diproses melalui 12 workflows yang sama —
agen akan otomatis menyesuaikan output berdasarkan domain dan
kebutuhan yang terdeteksi.

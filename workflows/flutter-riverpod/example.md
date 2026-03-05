# Contoh Penggunaan Workflows — Flutter Riverpod

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
- Agen setup Clean Architecture folders, Riverpod, GoRouter, Dio, Hive, Freezed
- Agen membuat example feature sebagai referensi
- Agen menjalankan `dart run build_runner build -d`

**Output:**
```
dompetku/
├── lib/
│   ├── bootstrap/app.dart
│   ├── core/
│   │   ├── error/failures.dart, result.dart
│   │   ├── network/dio_client.dart
│   │   ├── router/app_router.dart, routes.dart
│   │   ├── theme/app_theme.dart
│   │   └── utils/extensions.dart
│   ├── features/example/
│   │   ├── domain/ (entity, repo, usecase)
│   │   ├── data/ (model, repo_impl)
│   │   └── presentation/ (controller, screen)
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
- Agen membuat entity, model (Freezed), repository contract, use cases
- Agen membuat controller (AsyncNotifier), screen, shimmer widget
- Agen register routes di `app_router.dart`
- Agen menjalankan `dart run build_runner build -d`

**Output per feature:**
```
lib/features/transaction/
├── domain/
│   ├── entities/transaction.dart
│   ├── repositories/transaction_repository.dart
│   └── usecases/
│       ├── get_transactions.dart
│       └── create_transaction.dart
├── data/
│   ├── models/transaction_model.dart
│   ├── models/transaction_model.freezed.dart
│   ├── models/transaction_model.g.dart
│   ├── datasources/transaction_remote_ds.dart
│   ├── datasources/transaction_local_ds.dart
│   └── repositories/transaction_repository_impl.dart
└── presentation/
    ├── controllers/transaction_controller.dart
    ├── screens/transaction_list_screen.dart
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
- Agen membuat 7 reusable widgets: AppButton, AppTextField, AppCard,
  EmptyStateWidget, AppErrorWidget, ShimmerList, AppBottomSheet
- Agen membuat barrel export file `widgets.dart`
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
├── app_bottom_sheet.dart     ← draggable bottom sheet
└── widgets.dart              ← barrel export
```

---

## Phase 2: Data & Patterns

### 04 — State Management Advanced

**Prompt yang Anda ketik:**
```
Implementasikan advanced Riverpod patterns untuk feature transaction:
- Family provider untuk detail per ID
- Pagination untuk list transaction
- Optimistic delete dengan rollback
- Debounced search

Gunakan workflow 04_state_management_advanced.md
```

**Apa yang terjadi:**
- Agen membaca `04_state_management_advanced.md`
- Agen membuat `TransactionDetailController` dengan family provider
- Agen membuat pagination di `TransactionListController` dengan load-more
- Agen membuat optimistic delete di `TransactionActionsController`
- Agen membuat `SearchController` dengan debounce 400ms

**Output:**
```
lib/features/transaction/presentation/controllers/
├── transaction_detail_controller.dart  ← Family provider per ID
├── transaction_list_controller.dart    ← Pagination + load-more
├── transaction_actions_controller.dart ← Optimistic delete
└── transaction_search_controller.dart  ← Debounced search (400ms)
```

**Contoh penggunaan di screen:**
```dart
// Family provider — auto-dispose per ID
final txAsync = ref.watch(
  transactionDetailControllerProvider(txId),
);

// Pagination — scroll listener
NotificationListener<ScrollNotification>(
  onNotification: (scroll) {
    if (scroll.metrics.pixels >=
        scroll.metrics.maxScrollExtent - 200) {
      ref.read(transactionListControllerProvider
          .notifier).loadMore();
    }
    return false;
  },
  child: ListView.builder(...),
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
- Agen setup Dio client dengan 3 interceptors:
  - Auth interceptor (token refresh)
  - Retry interceptor (3x untuk 5xx)
  - Logging interceptor
- Agen membuat error mapper (DioException → AppException)
- Agen membuat repository implementation dengan offline-first strategy

**Output:**
```
lib/core/network/
├── dio_client.dart               ← Base Dio setup (15s timeout)
├── interceptors/
│   ├── auth_interceptor.dart     ← Token inject + auto-refresh
│   ├── retry_interceptor.dart    ← 3x retry untuk 5xx
│   └── logging_interceptor.dart  ← Request/response logging
├── api_endpoints.dart            ← Constants untuk semua endpoints
└── error_mapper.dart             ← DioException → AppException
```

**Contoh error handling di repository:**
```dart
@override
Future<Result<List<Transaction>>>
    getTransactions() async {
  try {
    final response = await dio.get('/transactions');
    final list = (response.data as List)
        .map((e) => TransactionModel.fromJson(e))
        .toList();
    return Success(list);
  } on DioException catch (e) {
    return Err(ErrorMapper.map(e));
  }
}
```

**Prompt lanjutan (opsional):**
```
Tambahkan pagination support untuk endpoint
GET /transactions?page=1&limit=20
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
- Agen setup Firebase Auth (email, Google Sign-In)
- Agen setup Firestore repository dengan real-time streams
- Agen setup Firebase Storage (upload receipt dengan progress)
- Agen membuat auth controller dan auth state listener

**Output utama:**
```
lib/features/auth/
├── domain/repositories/auth_repository.dart
├── data/repositories/auth_repository_impl.dart
└── presentation/controllers/auth_controller.dart

lib/core/firebase/
├── firebase_options.dart
└── firestore_service.dart
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
- Agen setup Supabase client dan auth
- Agen membuat migration SQL dan RLS policies
- Agen setup realtime subscription untuk live updates
- Agen setup storage service

**Output:**
```
lib/core/supabase/
├── supabase_client.dart          ← Client init + auth
└── supabase_storage_service.dart ← Upload/download files

lib/features/auth/
├── domain/repositories/auth_repository.dart
├── data/repositories/supabase_auth_repo_impl.dart
└── presentation/controllers/auth_controller.dart

lib/features/transaction/data/
├── datasources/transaction_supabase_ds.dart
└── repositories/transaction_repository_impl.dart
```

**Contoh SQL migration (di Supabase Dashboard):**
```sql
-- Create table
CREATE TABLE transactions (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id),
  title TEXT NOT NULL,
  amount DOUBLE PRECISION NOT NULL,
  type TEXT CHECK (type IN ('income', 'expense')),
  category TEXT NOT NULL,
  date TIMESTAMPTZ DEFAULT NOW(),
  note TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Enable RLS
ALTER TABLE transactions ENABLE ROW LEVEL SECURITY;

-- Policy: users can only see their own data
CREATE POLICY "Users read own data"
  ON transactions FOR SELECT
  USING (auth.uid() = user_id);
```

**Contoh realtime subscription:**
```dart
// Realtime — auto-update saat data berubah
final stream = supabase
    .from('transactions')
    .stream(primaryKey: ['id'])
    .eq('user_id', userId)
    .order('date', ascending: false);

// Di controller
@override
Stream<List<Transaction>> watchTransactions() {
  return stream.map(
    (rows) => rows
        .map(TransactionModel.fromJson)
        .toList(),
  );
}
```

**Prompt lanjutan (opsional):**
```
Tambahkan Supabase Edge Function untuk hitung
total spending per kategori setiap bulan.
```

---

### 08 — Offline Storage

**Prompt yang Anda ketik:**
```
Implementasikan offline-first storage untuk app dompetku:
- Cache transactions di Hive
- Database lokal dengan Drift untuk query & search
- Simpan token di flutter_secure_storage
- Connectivity monitoring

Gunakan workflow 08_offline_storage.md
```

**Apa yang terjadi:**
- Agen membaca `08_offline_storage.md`
- Agen setup Hive cache dengan TTL
- Agen setup Drift database (tabel, DAO, migration)
- Agen setup flutter_secure_storage untuk tokens
- Agen setup ConnectivityService dengan stream
- Agen membuat offline-first repository pattern
- Agen menggunakan `Result<T>` sealed class (bukan dartz)

**Output utama:**
```
lib/core/storage/
├── hive/cache_service.dart        ← Cache dengan TTL
├── drift/app_database.dart        ← Drift tables + DAO
├── drift/app_database.g.dart      ← Generated
├── secure/secure_storage.dart     ← Token storage
└── connectivity_service.dart      ← Online/offline stream
```

**Contoh offline-first flow:**
```dart
// 1. Cek cache dulu
final cached = await cacheService.get('transactions');
if (cached != null) return Success(cached);

// 2. Cek connectivity
if (await connectivity.isOnline) {
  // 3. Fetch from remote
  final remote = await remoteDataSource.getTransactions();
  await cacheService.set('transactions', remote, ttl: Duration(minutes: 15));
  return Success(remote);
}

// 3b. Offline → fetch from Drift DB
final local = await database.getAllTransactions();
return Success(local);
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
- Agen setup Easy Localization
- Agen membuat JSON translation files (id.json, en.json, ms.json)
- Agen membuat LocaleController dengan Riverpod
- Agen membuat LanguageSelectorWidget
- Agen menambahkan `.tr()` extension ke semua hardcoded strings

**Output:**
```
assets/translations/
├── id.json    ← {"transaction": {"title": "Transaksi", ...}}
├── en.json    ← {"transaction": {"title": "Transaction", ...}}
└── ms.json    ← {"transaction": {"title": "Transaksi", ...}}

lib/core/locale/
├── locale_controller.dart     ← Riverpod controller
├── supported_locales.dart     ← id, en, ms
└── language_selector.dart     ← Widget pemilih bahasa
```

**Contoh penggunaan:**
```dart
// Sebelum
Text('Transaksi')

// Sesudah
Text('transaction.title'.tr())

// Dynamic value
Text('transaction.total'.tr(args: ['Rp 500.000']))
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
- Agen setup Firebase Messaging + flutter_local_notifications
- Agen membuat NotificationService (initialize, foreground, background, terminated)
- Agen membuat deep link handler (tap → navigate ke screen yang benar)
- Agen membuat FCM token manager (register/unregister saat login/logout)
- Agen setup scheduled local notification untuk daily reminder

**Output:**
```
lib/core/notifications/
├── notification_service.dart           ← FCM + local
├── notification_deep_link_handler.dart ← GoRouter navigation
└── fcm_token_manager.dart             ← Register/unregister
```

**Contoh scheduled notification:**
```dart
// Daily reminder jam 20:00
await flutterLocalNotifications.zonedSchedule(
  0,
  'Sudah catat pengeluaran hari ini?',
  'Tap untuk tambah transaksi',
  _nextInstance(20, 0), // jam 20:00
  notificationDetails,
  androidScheduleMode:
      AndroidScheduleMode.exactAllowWhileIdle,
  matchDateTimeComponents:
      DateTimeComponents.time, // repeat daily
  payload: '/transaction/create',
);
```

**Contoh deep link handler:**
```dart
void handleNotificationTap(String? payload) {
  if (payload == null) return;
  // payload = '/transaction/detail/abc123'
  GoRouter.of(context).push(payload);
}
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
- Agen membuat widget tests untuk screens
- Agen membuat integration test untuk critical flow
- Agen setup GitHub Actions CI/CD (analyze → test → build)
- Agen membuat Fastlane configuration
- Agen membuat production checklist

**Contoh unit test output:**
```dart
// test/features/transaction/domain/usecases/
//   get_transactions_test.dart

void main() {
  late GetTransactions useCase;
  late MockTransactionRepository mockRepo;

  setUp(() {
    mockRepo = MockTransactionRepository();
    useCase = GetTransactions(mockRepo);
  });

  test('should return transactions on success',
      () async {
    when(() => mockRepo.getTransactions())
        .thenAnswer(
      (_) async => Success(tTransactions),
    );

    final result = await useCase(NoParams());

    expect(result, isA<Success<List<Transaction>>>());
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
- Agen set user context (ID, email) setelah login

**Output:**
```
lib/bootstrap/bootstrap.dart  ← Updated: wrap runApp with error zones
lib/core/monitoring/
├── sentry_service.dart        ← Sentry init + performance tracing
└── crashlytics_service.dart   ← Firebase Crashlytics
```

**Contoh global error handler:**
```dart
// lib/bootstrap/bootstrap.dart
Future<void> bootstrap(Widget app) async {
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

      runApp(app);
    },
  );
}
```

**Contoh set user context setelah login:**
```dart
// Di auth controller, setelah login berhasil
Sentry.configureScope((scope) {
  scope.setUser(SentryUser(
    id: user.id,
    email: user.email,
  ));
});
FirebaseCrashlytics.instance
    .setUserIdentifier(user.id);
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
6. "Implementasikan advanced Riverpod patterns: family 
    provider, pagination, optimistic delete, debounced search.
    Gunakan workflow 04_state_management_advanced.md"

7. "Setup Firebase: Auth, Firestore, Storage.
    Gunakan workflow 06_firebase_integration.md"

8. "Setup offline storage: Hive cache, Drift DB, secure 
    storage, connectivity monitoring.
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

### 💡 Tip 5: Skip Jika Sudah Punya
Jika project sudah punya backend integration, skip langsung ke
workflow berikutnya:
```
"Saya sudah punya Firebase setup. Langsung ke
 workflow 08_offline_storage.md"
```

### 💡 Tip 6: Revisi Kapan Saja
Setiap workflow bisa dijalankan ulang atau direvisi:
```
"Tambahkan field 'attachment' ke feature transaction"
"Update auth repository untuk support Apple Sign-In"
```

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

# Flutter Riverpod Workflows

Workflows untuk development Flutter dengan Riverpod state management dan Clean Architecture.

## System Requirements

- **Flutter SDK:** 3.41.1+ (stable channel)
- **Dart SDK:** 3.11.0+
- **Tested on:** Flutter 3.41.1 • Dart 3.11.0 • DevTools 2.54.1

### Compatibility Notes:
- ✅ **Fully compatible** dengan Flutter 3.41.1
- ✅ Firebase packages updated ke v3.x.x untuk kompatibilitas
- ✅ Semua dependencies menggunakan versi terbaru yang stable

## Quick Start

> **Baru pertama kali?** Baca **`example.md`** untuk contoh prompt
> yang bisa langsung di-copy-paste per workflow.

## Struktur Workflows

```
workflows/flutter-riverpod/
├── README.md
├── USAGE.md
├── example.md               ← ⭐ Contoh prompt per workflow
│
│  ## Phase 1: Foundation
├── 01_project_setup.md              # Setup project Flutter + Riverpod + Clean Architecture
├── 02_feature_maker.md              # Generator untuk membuat feature baru
├── 03_ui_components.md              # Reusable widget library (AppButton, Shimmer, etc.)
│
│  ## Phase 2: Data & Patterns
├── 04_state_management_advanced.md  # Advanced Riverpod: family, pagination, optimistic updates
├── 05_backend_integration.md        # REST API integration dengan Dio
├── 06_firebase_integration.md       # Firebase (Auth, Firestore, Storage, FCM)
├── 07_supabase_integration.md       # Supabase (Auth, PostgreSQL, Realtime, Storage)
├── 08_offline_storage.md            # Hive cache, Drift DB, flutter_secure_storage
│
│  ## Phase 3: Enhancements
├── 09_translation.md                # Translation & Localization (i18n)
├── 10_push_notifications.md         # FCM + local notifications + deep linking
├── 13_environment_flavors.md        # Environment Config & Flavors (envied)
├── 15_advanced_ui_semantics.md      # Advanced UI (Slivers, Animations, A11y)
├── 16_background_processing.md      # Isolates & Background Processing
│
│  ## Phase 4: Quality & Deploy
├── 11_testing_production.md         # Testing + CI/CD + Production deployment
├── 12_performance_monitoring.md     # Sentry, Firebase Crashlytics, performance tracing
└── 14_security_hardening.md         # Security hardening (Cert pinning, Biometrics)
```

## Output Folder Structure

Ketika workflows dijalankan, hasil disimpan langsung di project Flutter.
Setiap workflow menambahkan file ke lokasi yang sesuai:

```
lib/
├── bootstrap/          # 01: App initialization
├── core/
│   ├── error/          # 01/08: Failures, Result<T>
│   ├── network/        # 05: Dio, interceptors
│   ├── router/         # 01: GoRouter
│   ├── locale/         # 09: Localization
│   ├── notifications/  # 10: FCM + local
│   ├── storage/        # 08: Hive, Drift, secure
│   ├── theme/          # 01: App theme
│   └── widgets/        # 03: UI components
├── features/
│   └── {feature}/
│       ├── domain/     # 02: Entities, repos, use cases
│       ├── data/       # 02/05/06/07: Models, repos impl
│       └── presentation/ # 02/04: Controllers, screens
└── main.dart
```

## Urutan Penggunaan

### Phase 1: Foundation (wajib)
1. **`01_project_setup.md`** — Setup project dari nol
2. **`02_feature_maker.md`** — Generate feature baru (bisa dijalankan berkali-kali)
3. **`03_ui_components.md`** — Reusable widget library

### Phase 2: Data & Patterns
4. **`04_state_management_advanced.md`** — Advanced Riverpod patterns
5. Pilih salah satu atau beberapa backend:
   - **`05_backend_integration.md`** — Untuk REST API
   - **`06_firebase_integration.md`** — Untuk Firebase
   - **`07_supabase_integration.md`** — Untuk Supabase
6. **`08_offline_storage.md`** — Offline-first storage

### Phase 3: Enhancements (opsional)
7. **`09_translation.md`** — Translation & Localization
8. **`10_push_notifications.md`** — Push notifications
9. **`13_environment_flavors.md`** — Setup flavors dan env variables rahasia
10. **`15_advanced_ui_semantics.md`** — Advanced Animations, Slivers, dan Accessibility
11. **`16_background_processing.md`** — Isolates & background tasks

### Phase 4: Quality, Security & Deploy
12. **`14_security_hardening.md`** — Security hardening (SSL Pinning, Bio-auth)
13. **`11_testing_production.md`** — Testing dan production build
14. **`12_performance_monitoring.md`** — Monitoring di production (Sentry/Crashlytics)

### Workflow Optional:
- **`09_translation.md`** — Gunakan jika app butuh multiple languages
- **`10_push_notifications.md`** — Gunakan jika app butuh push notifications
- **`13_environment_flavors.md`** — Jika membedakan environment dev/stg/prod
- **`15_advanced_ui_semantics.md`** — Jika app memiliki kompleksitas frame motion
- **`16_background_processing.md`** — Jika app menghitung data berat
- **`14_security_hardening.md`** — Jika app enterprise class yang ketat regulasi


## Recommended Skills

Setiap workflow memiliki "Recommended Skills" section.
Berikut ringkasan skills yang relevan:

| Workflow | Skills |
|----------|--------|
| 01 Project Setup | `senior-flutter-developer` |
| 02 Feature Maker | `senior-flutter-developer` |
| 03 UI Components | `design-system-architect`, `senior-ui-ux-designer` |
| 04 State Mgmt | `senior-flutter-developer`, `debugging-specialist` |
| 05 Backend | `senior-backend-developer`, `api-design-specialist` |
| 06 Firebase | `senior-firebase-developer` |
| 07 Supabase | `senior-supabase-developer` |
| 08 Offline Storage | `senior-flutter-developer` |
| 09 Translation | `internationalization-specialist` |
| 10 Push Notifications | `notification-system-architect` |
| 11 Testing | `senior-quality-assurance-engineer` |
| 12 Monitoring | `observability-engineer` |
| 13 Env Flavors | `senior-flutter-developer`, `senior-devops-engineer` |
| 14 Security | `senior-cybersecurity-engineer`, `senior-flutter-developer` |
| 15 Advanced UI | `senior-ui-ux-designer`, `accessibility-specialist` |
| 16 Background | `senior-flutter-developer`, `performance-testing-specialist` |

## Fitur Utama

### 03 — UI Components
- AppButton (variants: primary, secondary, destructive, ghost)
- AppTextField (password toggle, validation)
- AppCard (tap, leading, trailing)
- EmptyStateWidget dengan action button
- AppErrorWidget dengan retry
- ShimmerList untuk loading states
- AppBottomSheet (draggable)

### 04 — Advanced State Management
- Family providers (parameterized, per-ID instances)
- Pagination dengan load-more
- Optimistic updates dengan rollback
- Cross-provider communication
- Debounced search
- keepAlive + invalidate pattern

### 05 — Backend Integration (REST API)
- Dio setup dengan interceptors lengkap
- Auth interceptor dengan token refresh
- Retry interceptor (3x untuk 5xx errors)
- Error mapper (DioException → AppException)
- Repository pattern dengan offline-first
- Pagination dengan infinite scroll
- Optimistic updates

### 06 — Firebase Integration
- Firebase Auth (email/password, Google Sign-In)
- Cloud Firestore CRUD + real-time streams
- Firebase Storage (upload dengan progress)
- Firebase Cloud Messaging (push notifications)
- Security Rules
- Offline persistence

### 07 — Supabase Integration
- Supabase Auth (magic link, OAuth, phone)
- PostgreSQL dengan Row Level Security (RLS)
- Realtime subscriptions
- Supabase Storage
- RLS policies dan best practices

### 08 — Offline Storage
- Hive cache dengan TTL
- Offline-first repository pattern
- Drift database (complex queries, full-text search)
- flutter_secure_storage untuk tokens
- Connectivity service + stream
- Result<T> sealed class (replaces dartz)

### 09 — Translation & Localization
- Easy Localization setup
- JSON translation files (EN, ID, MS, TH, VN)
- Locale controller dengan Riverpod
- Language selector widget
- String extensions untuk translation
- Dynamic values dengan interpolation
- Locale persistence

### 10 — Push Notifications
- FCM foreground/background/terminated handling
- flutter_local_notifications
- Deep link navigation dari notification payload
- FCM token management (register/unregister)
- Scheduled local notifications

### 11 — Testing & Production
- Unit tests dengan mocktail
- Widget tests
- Integration tests
- GitHub Actions CI/CD pipeline
- Fastlane configuration
- Performance optimization
- Production checklist

### 12 — Performance & Monitoring
- Sentry error monitoring + performance tracing
- Firebase Crashlytics crash reporting
- Global error handler (Flutter + Dart async)
- User context (ID, email) untuk error attribution
- Pre-release performance checklist

## State Management

Semua workflows menggunakan **Riverpod** dengan:
- Code generation (riverpod_generator)
- AsyncNotifier untuk state management
- AsyncValue untuk handle loading/error/data states
- Dependency injection
- Caching dengan `keepAlive`

## Architecture Pattern

**Clean Architecture** dengan layers:
- **Domain**: Entities, Repository contracts, Use cases
- **Data**: Models, Repository implementations, Data sources
- **Presentation**: Controllers, Screens, Widgets

## Dependencies Utama

```yaml
dependencies:
  # State Management
  flutter_riverpod: ^2.5.1
  riverpod_annotation: ^2.3.5
  
  # Routing
  go_router: ^14.0.0
  
  # Network
  dio: ^5.4.0
  connectivity_plus: ^6.0.0
  
  # Storage
  hive_flutter: ^1.1.0
  drift: ^2.22.0
  sqlite3_flutter_libs: ^0.5.28
  flutter_secure_storage: ^9.2.0
  
  # Firebase (optional)
  firebase_core: ^3.12.0
  firebase_auth: ^5.5.0
  cloud_firestore: ^5.6.0
  firebase_storage: ^12.4.0
  firebase_messaging: ^15.2.0
  
  # Supabase (optional)
  supabase_flutter: ^2.3.0
  
  # Translation (optional)
  easy_localization: ^3.0.7
  intl: ^0.19.0
  
  # Utils
  freezed_annotation: ^2.4.1
  json_annotation: ^4.8.1
  equatable: ^2.0.5
  
  # Error Handling
  # Result<T> sealed class — defined in core/error/result.dart
  # No third-party dependency needed (replaces dartz)

dev_dependencies:
  build_runner: ^2.4.9
  freezed: ^2.5.0
  json_serializable: ^6.7.1
  riverpod_generator: ^2.4.0
  custom_lint: ^0.6.4
  riverpod_lint: ^2.3.10
  flutter_test:
    sdk: flutter
  mocktail: ^1.0.0
  drift_dev: ^2.22.0
```

## Best Practices yang Diikuti

### ✅ Do This
- ✅ Clean Architecture dengan clear separation
- ✅ Riverpod dengan code generation
- ✅ Repository pattern dengan Result<T> sealed class
- ✅ Offline-first strategy
- ✅ Error handling terstruktur
- ✅ Shimmer loading skeletons
- ✅ Debounce untuk search (300-500ms)
- ✅ Pagination untuk long lists
- ✅ const constructors
- ✅ Unit test coverage ≥ 80%

### ❌ Avoid This
- ❌ Hardcode API URLs
- ❌ Skip error handling
- ❌ Load semua data sekaligus
- ❌ Skip connectivity check
- ❌ Use CircularProgressIndicator untuk initial load
- ❌ Mutable state objects

## Testing

### Unit Tests
- Use cases
- Repositories (dengan mocking)
- Services
- Utilities

### Widget Tests
- Screens dengan semua states
- User interactions
- Form validation
- Navigation

### Integration Tests
- End-to-end flows
- Complete user journeys

## CI/CD

GitHub Actions workflows untuk:
- Code analysis
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

## Next Steps Setelah Workflows

1. Monitor production performance
2. Setup analytics dan crash reporting
3. Collect user feedback
4. Plan iterations dan new features
5. Regular maintenance dan updates

## Troubleshooting

### Build Runner Issues
```bash
# Clean dan rebuild
dart run build_runner clean
dart run build_runner build -d
```

### Dependency Conflicts
```bash
# Resolve conflicts
flutter pub upgrade
flutter pub outdated
```

### Testing Issues
```bash
# Run single test
flutter test test/path/to/test.dart

# Run dengan verbose
flutter test -v
```

## Resources

- [Flutter Documentation](https://docs.flutter.dev)
- [Riverpod Documentation](https://riverpod.dev)
- [Clean Architecture](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
- [Flutter Testing](https://docs.flutter.dev/testing)

---

**Note:** Workflows ini dirancang untuk production-ready Flutter apps dengan best practices industry standard.

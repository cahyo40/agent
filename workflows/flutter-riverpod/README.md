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

## Struktur Workflows

```
workflows/flutter-riverpod/
├── 01_project_setup.md              # Setup project Flutter + Riverpod + Clean Architecture
├── 02_feature_maker.md              # Generator untuk membuat feature baru
├── 03_backend_integration.md        # REST API integration dengan Dio
├── 04_firebase_integration.md       # Firebase (Auth, Firestore, Storage, FCM)
├── 05_supabase_integration.md       # Supabase (Auth, PostgreSQL, Realtime, Storage)
├── 06_testing_production.md         # Testing + CI/CD + Production deployment
├── 07_translation.md                # Translation & Localization (i18n)
├── 08_state_management_advanced.md  # Advanced Riverpod: family, pagination, optimistic updates
├── 09_offline_storage.md            # Hive cache, Isar DB, flutter_secure_storage
├── 10_ui_components.md              # Reusable widget library (AppButton, Shimmer, etc.)
├── 11_push_notifications.md         # FCM + local notifications + deep linking
├── 12_performance_monitoring.md     # Sentry, Firebase Crashlytics, performance tracing
└── USAGE.md                         # Dokumentasi penggunaan lengkap
```

## Output Folder Structure

Ketika workflows dijalankan, hasil akan disimpan di:

```
sdlc/flutter-riverpod/
├── 01-project-setup/
│   ├── project-structure.md
│   ├── pubspec.yaml
│   ├── lib/
│   │   ├── bootstrap/
│   │   ├── core/
│   │   ├── features/example/
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
└── 06-testing-production/
    ├── testing/
    ├── ci-cd/
    ├── performance/
    └── deployment/

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
4. **08_state_management_advanced.md** - Advanced Riverpod patterns
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
- Clean Architecture folder structure
- Riverpod dengan code generation
- Dependencies lengkap (Dio, GoRouter, Hive, Freezed)
- Example feature dengan semua states (loading, error, empty, data)
- Shimmer loading skeletons
- Error handling terstruktur

### 02 - Feature Maker
- Template generator untuk feature baru
- Auto-generate domain, data, presentation layers
- CRUD operations template
- Controller dengan Riverpod AsyncNotifier
- Screen template dengan semua states
- Shimmer loading widget template

### 03 - Backend Integration (REST API)
- Dio setup dengan interceptors lengkap
- Auth interceptor dengan token refresh
- Retry interceptor (3x untuk 5xx errors)
- Error mapper (DioException → AppException)
- Repository pattern dengan offline-first
- Pagination dengan infinite scroll
- Optimistic updates

### 04 - Firebase Integration
- Firebase Auth (email/password, Google Sign-In)
- Cloud Firestore CRUD + real-time streams
- Firebase Storage (upload dengan progress)
- Firebase Cloud Messaging (push notifications)
- Security Rules
- Offline persistence

### 05 - Supabase Integration
- Supabase Auth (magic link, OAuth, phone)
- PostgreSQL dengan Row Level Security (RLS)
- Realtime subscriptions
- Supabase Storage
- RLS policies dan best practices

### 06 - Testing & Production
- Unit tests dengan mocktail
- Widget tests
- Integration tests
- GitHub Actions CI/CD pipeline
- Fastlane configuration
- Performance optimization
- Production checklist

### 07 - Translation & Localization
- Easy Localization setup
- JSON translation files (EN, ID, MS, TH, VN)
- Locale controller dengan Riverpod
- Language selector widget
- String extensions untuk translation
- Dynamic values dengan interpolation
- Locale persistence

### 08 - Advanced State Management
- Family providers (parameterized, per-ID instances)
- Pagination dengan load-more
- Optimistic updates dengan rollback
- Cross-provider communication
- Debounced search
- keepAlive + invalidate pattern

### 09 - Offline Storage
- Hive cache dengan TTL
- Offline-first repository pattern
- Isar database (complex queries, full-text search)
- flutter_secure_storage untuk tokens
- Connectivity service + stream

### 10 - UI Components
- AppButton (variants: primary, secondary, destructive, ghost)
- AppTextField (password toggle, validation)
- AppCard (tap, leading, trailing)
- EmptyStateWidget dengan action button
- AppErrorWidget dengan retry
- ShimmerList untuk loading states
- AppBottomSheet (draggable)

### 11 - Push Notifications
- FCM foreground/background/terminated handling
- flutter_local_notifications
- Deep link navigation dari notification payload
- FCM token management (register/unregister)
- Scheduled local notifications

### 12 - Performance & Monitoring
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
  freezed_annotation: ^2.4.1
  json_annotation: ^4.8.1
  dartz: ^0.10.1
  equatable: ^2.0.5

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
```

## Best Practices yang Diikuti

### ✅ Do This
- ✅ Clean Architecture dengan clear separation
- ✅ Riverpod dengan code generation
- ✅ Repository pattern dengan Either type
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

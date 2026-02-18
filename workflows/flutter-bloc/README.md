# Flutter BLoC Workflows

Workflows untuk development Flutter dengan **BLoC pattern** (`flutter_bloc`) dan Clean Architecture.
Menggunakan `get_it` + `injectable` untuk dependency injection.

## System Requirements

- **Flutter SDK:** 3.41.1+ (stable channel)
- **Dart SDK:** 3.11.0+
- **Tested on:** Flutter 3.41.1 - Dart 3.11.0 - DevTools 2.54.1

### Compatibility Notes:
- Fully compatible dengan Flutter 3.41.1
- Firebase packages updated ke v3.x.x untuk kompatibilitas
- Semua dependencies menggunakan versi terbaru yang stable
- `flutter_bloc` ^8.1.6 dan `bloc_test` ^9.1.7 fully supported

## Struktur Workflows

```
workflows/flutter-bloc/
├── 01_project_setup.md              # Setup project Flutter + BLoC + Clean Architecture
├── 02_feature_maker.md              # Generator untuk membuat feature baru (Bloc/Cubit)
├── 03_backend_integration.md        # REST API integration dengan Dio
├── 04_firebase_integration.md       # Firebase (Auth, Firestore, Storage, FCM)
├── 05_supabase_integration.md       # Supabase (Auth, PostgreSQL, Realtime, Storage)
├── 06_testing_production.md         # Testing (bloc_test) + CI/CD + Production deployment
├── 07_translation.md                # Translation & Localization (i18n)
├── 08_bloc_patterns.md              # Advanced BLoC patterns & recipes
├── 09_state_management_advanced.md  # Pagination, optimistic update, cross-Bloc, EventTransformer
├── 10_offline_storage.md            # Hive cache, Isar DB, ConnectivityCubit, SecureStorage
├── 11_ui_components.md              # Reusable widget library (AppButton, Shimmer, etc.)
├── 12_push_notifications.md         # FCM + local notifications + deep linking
├── 13_performance_monitoring.md     # Sentry, Firebase Crashlytics, AppBlocObserver
└── USAGE.md                         # Dokumentasi penggunaan lengkap
```

## Output Folder Structure

Ketika workflows dijalankan, hasil akan disimpan di:

```
sdlc/flutter-bloc/
├── 01-project-setup/
│   ├── pubspec.yaml
│   └── lib/ (bootstrap/, core/di/, features/example/bloc/, main.dart)
├── 02-feature-maker/
│   └── feature-templates/ (bloc, cubit, event, state templates)
├── 03-backend-integration/
│   └── (dio-setup, interceptors, error-handling, repository-pattern)
├── 04-firebase-integration/
│   └── (firebase-setup, auth/, firestore/, storage/, fcm/)
├── 05-supabase-integration/
│   └── (supabase-setup, auth/, database/, realtime/, storage/)
├── 06-testing-production/
│   └── testing/ (bloc_tests/, widget_tests/, integration_tests/)
├── 07-translation/
│   └── (assets/translations/, lib/core/locale/)
└── 08-bloc-patterns/
    └── (bloc-to-bloc, multi-bloc-listener, hydrated-bloc)
```

## Urutan Penggunaan

1. **01_project_setup.md** - Setup project dari nol (termasuk get_it + injectable)
2. **02_feature_maker.md** - Generate feature baru dengan Bloc atau Cubit (bisa berkali-kali)
3. Pilih salah satu atau beberapa:
   - **03_backend_integration.md** - Untuk REST API
   - **04_firebase_integration.md** - Untuk Firebase
   - **05_supabase_integration.md** - Untuk Supabase
4. **09_state_management_advanced.md** - Pagination, optimistic update, cross-Bloc
5. **10_offline_storage.md** - Offline-first storage
6. **11_ui_components.md** - Reusable widget library
7. **12_push_notifications.md** - Push notifications (jika diperlukan)
8. **07_translation.md** - Translation & Localization (opsional)
9. **06_testing_production.md** - Testing dengan `bloc_test` dan deployment
10. **08_bloc_patterns.md** - Advanced patterns (opsional)
11. **13_performance_monitoring.md** - Monitoring di production

### Workflow Optional:
- **07_translation.md** - Gunakan jika app membutuhkan multiple languages
- **08_bloc_patterns.md** - HydratedBloc, MultiBlocListener, Bloc-to-Bloc
- **12_push_notifications.md** - Gunakan jika app butuh push notifications

## Fitur Utama

### 01 - Project Setup
- Clean Architecture folder structure
- `flutter_bloc` + `get_it` + `injectable` setup
- Code generation: `injectable_generator`, `freezed`, `json_serializable`
- Example feature dengan Bloc (events + states via `Equatable`)
- Shimmer loading skeletons, error handling terstruktur dengan `dartz` Either

### 02 - Feature Maker
- Template generator dengan pilihan Bloc atau Cubit
- Auto-generate: events, states, bloc/cubit, domain, data, presentation
- CRUD operations template, screen template dengan `BlocBuilder` untuk semua states

### 03 - Backend Integration (REST API)
- Dio setup dengan interceptors (auth token refresh, retry 3x untuk 5xx)
- Error mapper (DioException -> AppException)
- Repository pattern dengan offline-first, pagination, optimistic updates

### 04 - Firebase Integration
- Firebase Auth (email/password, Google Sign-In)
- Cloud Firestore CRUD + real-time streams via `StreamSubscription` di Bloc
- Firebase Storage (upload dengan progress), FCM, Security Rules

### 05 - Supabase Integration
- Supabase Auth (magic link, OAuth, phone)
- PostgreSQL dengan RLS, Realtime subscriptions via Bloc, Storage

### 06 - Testing & Production
- **Bloc tests** dengan `bloc_test` package (`blocTest<>()`)
- Unit tests (`mocktail`), Widget tests (`BlocProvider` mocking), Integration tests
- GitHub Actions CI/CD, Fastlane, Performance optimization

### 07 - Translation & Localization
- Easy Localization setup, JSON files (EN, ID, MS, TH, VN)
- Locale Cubit untuk language switching, locale persistence

### 08 - Advanced BLoC Patterns
- Bloc-to-Bloc communication, `MultiBlocListener`/`MultiBlocProvider`
- `HydratedBloc` untuk state persistence
- `EventTransformer` (debounce, throttle), concurrent vs sequential processing

### 09 - Advanced State Management
- Pagination Bloc dengan sealed events/states
- Optimistic update Cubit dengan rollback
- Cross-Bloc communication via `StreamSubscription`
- `EventTransformer` debounce/throttle dengan rxdart

### 10 - Offline Storage
- Hive cache dengan TTL
- Offline-first repository pattern dengan `get_it`
- Isar database (complex queries, full-text search)
- `ConnectivityCubit` reactive
- `flutter_secure_storage` untuk tokens

### 11 - UI Components
- `AppButton` (variants: primary, secondary, destructive, ghost)
- `AppTextField` (password toggle, validation)
- `EmptyStateWidget` dengan action button
- `AppErrorWidget` dengan retry
- `ShimmerList` untuk loading states
- `BlocBuilder` integration pattern

### 12 - Push Notifications
- FCM foreground/background/terminated handling
- `flutter_local_notifications` dengan `@lazySingleton`
- Deep link navigation via `go_router` `context.push()`
- `FcmTokenCubit` untuk register/unregister

### 13 - Performance & Monitoring
- Sentry error monitoring + performance tracing
- Firebase Crashlytics crash reporting
- Global error handler (Flutter + Dart async)
- `AppBlocObserver` untuk development logging
- User context (ID, email) untuk error attribution

## BLoC vs Cubit - Kapan Pakai Yang Mana?

**Gunakan Bloc** ketika fitur punya banyak user interactions berbeda, butuh event
traceability, ada complex event transformations (debounce/throttle), atau state
transitions perlu di-log.

**Gunakan Cubit** ketika logic sederhana (method calls), tidak butuh event tracing,
fitur kecil (theme switcher, counter, locale selector), atau mau kode lebih ringkas.

```
Bloc  -> AuthBloc, ProductBloc, OrderBloc, SearchBloc
Cubit -> ThemeCubit, LocaleCubit, CounterCubit, ConnectivityCubit
```

## State Management

Semua workflows menggunakan **flutter_bloc** dengan:
- `Bloc<Event, State>` untuk fitur kompleks, `Cubit<State>` untuk fitur sederhana
- Events dan States sebagai **sealed classes** extending `Equatable`
- `BlocBuilder` untuk rebuild widget, `BlocListener` untuk side effects
- `BlocConsumer` kombinasi Builder + Listener
- `get_it` + `injectable` untuk dependency injection

## Architecture Pattern

**Clean Architecture** dengan layers:
- **Domain**: Entities, Repository contracts, Use cases
- **Data**: Models, Repository implementations, Data sources
- **Presentation**: Blocs/Cubits, Screens, Widgets

DI dihandle oleh `get_it` + `injectable` (`@injectable`, `@lazySingleton`, `@module`).

## Dependencies Utama

```yaml
dependencies:
  flutter_bloc: ^8.1.6
  bloc: ^8.1.4
  equatable: ^2.0.5
  get_it: ^8.0.0
  injectable: ^2.5.0
  go_router: ^14.0.0
  dio: ^5.4.0
  hive_flutter: ^1.1.0
  flutter_secure_storage: ^9.0.0
  dartz: ^0.10.1
  freezed_annotation: ^2.4.1
  json_annotation: ^4.8.1
  # Firebase (optional)
  firebase_core: ^3.12.0
  firebase_auth: ^5.5.0
  cloud_firestore: ^5.6.0
  firebase_storage: ^12.4.0
  firebase_messaging: ^15.2.0
  # Supabase (optional)
  supabase_flutter: ^2.8.0
  # Translation (optional)
  easy_localization: ^3.0.7

dev_dependencies:
  build_runner: ^2.4.9
  freezed: ^2.5.0
  json_serializable: ^6.7.1
  injectable_generator: ^2.6.2
  bloc_test: ^9.1.7
  mocktail: ^1.0.0
```

## Best Practices yang Diikuti

### Do
- Clean Architecture dengan clear separation of concerns
- Satu Bloc per fitur, jangan campur concern
- Events dan States immutable, extend `Equatable`
- Repository pattern dengan `Either<Failure, Success>` dari `dartz`
- Shimmer loading skeletons (bukan `CircularProgressIndicator`)
- Debounce search events dengan `EventTransformer` (300-500ms)
- Gunakan `BlocListener` untuk side effects, bukan di dalam `BlocBuilder`
- Close subscriptions di `Bloc.close()` override
- `const` constructors, pagination untuk long lists
- Unit test coverage >= 80%

### Avoid
- Jangan hardcode API URLs atau skip error handling
- Jangan load semua data sekaligus tanpa pagination
- Jangan mutate state langsung, selalu `emit()` state baru
- Jangan panggil `emit()` setelah Bloc di-close
- Jangan buat God Bloc yang handle banyak fitur sekaligus
- Jangan nest `BlocBuilder` terlalu dalam, gunakan `BlocSelector` atau `buildWhen`

## Testing

### Bloc Tests (dengan `bloc_test`)
```dart
blocTest<ProductBloc, ProductState>(
  'emits [Loading, Loaded] when FetchProducts is added',
  build: () {
    when(() => mockUseCase()).thenAnswer((_) async => Right(products));
    return ProductBloc(getProducts: mockUseCase);
  },
  act: (bloc) => bloc.add(const FetchProducts()),
  expect: () => [
    const ProductState.loading(),
    ProductState.loaded(products: products),
  ],
);
```

### Unit Tests
- Use cases, Repositories (mocking via `mocktail`), Data sources, Models

### Widget Tests
- Screens dengan semua states (wrap dengan `BlocProvider.value`)
- User interactions, form validation, navigation

### Integration Tests
- End-to-end flows, complete user journeys

## CI/CD & Production Checklist

GitHub Actions workflows: code analysis, unit/bloc tests dengan coverage, widget tests,
build APK/IPA, deploy via Fastlane.

Sebelum release, pastikan:
- [ ] All tests passing (termasuk bloc tests)
- [ ] Code coverage >= 80%
- [ ] No analyzer warnings
- [ ] Performance optimized (DevTools)
- [ ] App signing configured
- [ ] Store listings, privacy policy, app icons & screenshots
- [ ] ProGuard/R8 rules untuk release build

## Troubleshooting

### State Tidak Ter-emit / Widget Tidak Re-render
Pastikan State extend `Equatable` dan override `props` dengan benar. Jika pakai
list/map, selalu buat instance baru: `emit(state.copyWith(items: [...state.items, new]))`.
Jangan mutate list yang sudah ada karena Equatable akan menganggapnya sama.

### BlocProvider Not Found
```
BlocProvider.of() called with a context that does not contain a Bloc of type XBloc.
```
Pastikan `BlocProvider` ada di widget tree **di atas** widget yang consume Bloc:
```dart
BlocProvider(
  create: (_) => getIt<ProductBloc>()..add(const FetchProducts()),
  child: const ProductScreen(),
)
```

### Bloc Already Closed
Cancel semua async operations di `close()` override:
```dart
@override
Future<void> close() {
  _subscription?.cancel();
  return super.close();
}
```

### Build Runner / Injectable Issues
```bash
dart run build_runner clean
dart run build_runner build --delete-conflicting-outputs
# Pastikan @injectable/@lazySingleton benar, configureDependencies() dipanggil di main()
```

### Dependency Conflicts
```bash
flutter pub upgrade
flutter pub outdated
```

## Next Steps Setelah Workflows

1. Monitor production performance
2. Setup analytics dan crash reporting
3. Collect user feedback
4. Plan iterations dan new features
5. Regular dependency updates

## Resources

- [Flutter Documentation](https://docs.flutter.dev)
- [BLoC Library](https://bloclibrary.dev)
- [get_it Package](https://pub.dev/packages/get_it)
- [injectable Package](https://pub.dev/packages/injectable)
- [bloc_test Package](https://pub.dev/packages/bloc_test)
- [Clean Architecture](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
- [Flutter Testing](https://docs.flutter.dev/testing)

---

**Note:** Workflows ini dirancang untuk production-ready Flutter apps dengan BLoC pattern.
Pilih Bloc untuk fitur kompleks, Cubit untuk fitur sederhana.

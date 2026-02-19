---
description: Comprehensive testing (unit, widget, integration) dan production preparation khusus Flutter BLoC: `bloc_test` package... (Part 6/8)
---
# Workflow: Testing & Production (Flutter BLoC) (Part 6/8)

> **Navigation:** This workflow is split into 8 parts.

## BLoC-Specific Optimization (BACA INI DULU)

### buildWhen — Minimize Widget Rebuilds
```dart
// TANPA buildWhen — rebuild setiap state change
BlocBuilder<ProductBloc, ProductState>(
  builder: (context, state) => ...,
)

// DENGAN buildWhen — rebuild hanya ketika data berubah
// Ini SANGAT penting untuk performa!
BlocBuilder<ProductBloc, ProductState>(
  buildWhen: (previous, current) {
    // Hanya rebuild kalau state berubah ke Loaded
    return current is ProductLoaded;
  },
  builder: (context, state) => ...,
)
```

### listenWhen — Filter Side Effects
```dart
// Hanya listen untuk error states
BlocListener<ProductBloc, ProductState>(
  listenWhen: (previous, current) => current is ProductError,
  listener: (context, state) {
    if (state is ProductError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(state.message)),
      );
    }
  },
  child: ...,
)
```

### Bloc.observer — Global Performance Monitoring
```dart
// lib/core/bloc/app_bloc_observer.dart
class AppBlocObserver extends BlocObserver {
  @override
  void onCreate(BlocBase bloc) {
    super.onCreate(bloc);
    debugPrint('Bloc Created: ${bloc.runtimeType}');
  }

  @override
  void onTransition(Bloc bloc, Transition transition) {
    super.onTransition(bloc, transition);
    debugPrint(
      'Bloc Transition: ${bloc.runtimeType}\n'
      '  Event: ${transition.event}\n'
      '  Current: ${transition.currentState}\n'
      '  Next: ${transition.nextState}',
    );
  }

  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    super.onError(bloc, error, stackTrace);
    debugPrint('Bloc Error: ${bloc.runtimeType} — $error');
    // Report to Crashlytics
    FirebaseCrashlytics.instance.recordError(error, stackTrace);
  }

  @override
  void onClose(BlocBase bloc) {
    super.onClose(bloc);
    debugPrint('Bloc Closed: ${bloc.runtimeType}');
  }
}

// main.dart
void main() {
  Bloc.observer = AppBlocObserver();
  runApp(const MyApp());
}
```

### Equatable untuk State Comparison
```dart
// WAJIB extend Equatable di semua State classes
// Tanpa ini, BlocBuilder rebuild setiap kali meskipun data sama
abstract class ProductState extends Equatable {
  const ProductState();

  @override
  List<Object?> get props => [];
}

class ProductLoaded extends ProductState {
  final List<Product> products;
  final bool hasReachedMax;

  const ProductLoaded({
    required this.products,
    this.hasReachedMax = false,
  });

  @override
  List<Object?> get props => [products, hasReachedMax];

  // copyWith pattern
  ProductLoaded copyWith({
    List<Product>? products,
    bool? hasReachedMax,
  }) {
    return ProductLoaded(
      products: products ?? this.products,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
    );
  }
}
```

### Granular Blocs vs Monolithic
```dart
// JANGAN: Satu bloc besar untuk satu screen
class ProductScreenBloc extends Bloc<ProductScreenEvent, ProductScreenState> {
  // handles: load, search, filter, sort, pagination, create, delete, update
  // Setiap event change rebuild SELURUH screen
}

// BAGUS: Pecah jadi beberapa bloc kecil
class ProductListBloc extends Bloc<...> { /* load, pagination */ }
class ProductSearchBloc extends Bloc<...> { /* search, filter */ }
class ProductFormBloc extends Bloc<...> { /* create, update */ }

// Masing-masing bloc hanya rebuild widget yang relevan
MultiBlocProvider(
  providers: [
    BlocProvider(create: (_) => getIt<ProductListBloc>()..add(const LoadProducts())),
    BlocProvider(create: (_) => getIt<ProductSearchBloc>()),
  ],
  child: ProductScreen(),
)
```


## Image Optimization (Framework-Agnostic)
- [ ] Use `CachedNetworkImage` untuk semua network images
- [ ] Set `cacheWidth` dan `cacheHeight` sesuai display size
- [ ] Compress images sebelum upload (max 500KB)
- [ ] Use WebP format (30-50% smaller)
- [ ] Implement placeholder dan error widget


## List Optimization
- [ ] Use `ListView.builder` (BUKAN ListView with children)
- [ ] Implement infinite scroll pagination
- [ ] Use `const` constructors untuk list items
- [ ] Avoid heavy computation di `itemBuilder`
- [ ] `AutomaticKeepAliveClientMixin` untuk preserve scroll state


## Memory Management
- [ ] Bloc.close() di semua page dispose (otomatis kalau pakai `BlocProvider(create:)`)
- [ ] Cancel StreamSubscriptions on bloc close
- [ ] Clear image cache secara periodik
- [ ] `RepaintBoundary` untuk complex widgets
- [ ] Avoid menyimpan large objects di bloc state


## Startup Performance
- [ ] Defer non-critical initialization
- [ ] Lazy injectable registration (`@lazySingleton` bukan `@singleton`)
- [ ] Use native splash screen (`flutter_native_splash`)
- [ ] Minimize main bundle size
- [ ] Preload critical assets di splash


## Profiling Steps
1. Run `flutter run --profile`
2. Open DevTools (Flutter Inspector)
3. Check Widget Rebuild tracker — pastikan tidak ada rebuild berlebihan
4. Check untuk:
   - Raster thread jank (>16ms frames)
   - UI thread jank
   - Memory leaks (growing memory graph)
   - Excessive rebuilds (pakai `debugPrintRebuildDirtyWidgets`)
5. Fix issues, re-profile, repeat
```

---

### 6. Production Checklist

**Description:** Comprehensive checklist sebelum release ke production. Mencakup hal-hal BLoC-specific dan general Flutter requirements.

**Output Format:**

```markdown
# Production Release Checklist (Flutter BLoC)


## Pre-Release Code Quality
- [ ] App version updated di `pubspec.yaml` (version + build number)
- [ ] CHANGELOG.md updated dengan semua perubahan
- [ ] `build_runner` berjalan tanpa error (`dart run build_runner build`)
- [ ] Semua `*.g.dart` dan `*.freezed.dart` files up-to-date
- [ ] `flutter analyze` — 0 warnings, 0 errors
- [ ] `dart format .` — semua file formatted
- [ ] Tidak ada `print()` statements (ganti dengan `log()` atau remove)
- [ ] Tidak ada `TODO` atau `FIXME` yang critical


## Testing
- [ ] All unit tests passing (`flutter test`)
- [ ] Code coverage ≥ 80% overall
- [ ] Semua Bloc/Cubit punya blocTest coverage 100%
- [ ] Widget tests untuk semua screens
- [ ] Integration tests untuk critical flows (login, main feature)
- [ ] Tested di physical device (bukan hanya emulator)
- [ ] Tested di berbagai screen size (small phone, tablet)


## BLoC-Specific Checks
- [ ] Semua State classes extend `Equatable` (atau override `==` dan `hashCode`)
- [ ] Semua Event classes extend `Equatable`
- [ ] `Bloc.close()` dipanggil properly (atau dihandle oleh `BlocProvider`)
- [ ] Tidak ada stream subscriptions yang leak
- [ ] `buildWhen` digunakan di heavy widgets
- [ ] `Bloc.observer` configured untuk production logging
- [ ] Injectable modules configured untuk production environment
- [ ] Error handling proper di semua `on<Event>` handlers


## Android
- [ ] `minSdkVersion` appropriate (minimal 21 atau sesuai target)
- [ ] `targetSdkVersion` latest (34+)
- [ ] ProGuard/R8 rules configured
- [ ] App signing configured (keystore)
- [ ] Keystore backed up securely (BUKAN di repo!)
- [ ] App icon semua densities (mdpi, hdpi, xhdpi, xxhdpi, xxxhdpi)
- [ ] Adaptive icon configured
- [ ] Splash screen native
- [ ] Internet permission di `AndroidManifest.xml`
- [ ] Play Store listing prepared (title, description, screenshots)
- [ ] Privacy policy URL


## iOS
- [ ] Minimum iOS version appropriate (15.0+)
- [ ] App Store Connect setup
- [ ] App icon semua sizes (1024x1024 master)
- [ ] Launch screen (LaunchScreen.storyboard)
- [ ] Signing certificates dan provisioning profiles
- [ ] `Info.plist` configured (permissions, URL schemes)
- [ ] App Store listing prepared
- [ ] Screenshots semua required device sizes
- [ ] Privacy policy URL
- [ ] App Privacy labels filled


## Firebase (jika pakai)
- [ ] Production Firebase project (BUKAN dev project!)
- [ ] Security rules deployed dan reviewed
- [ ] Analytics enabled
- [ ] Crashlytics enabled dan tested
- [ ] Performance monitoring enabled
- [ ] Push notifications tested di real device
- [ ] Remote Config default values set
- [ ] Billing alerts configured


## Supabase (jika pakai)
- [ ] Production Supabase project
- [ ] RLS policies reviewed dan enabled
- [ ] Database indexes optimized
- [ ] Edge Functions deployed
- [ ] Realtime policies configured
- [ ] Storage policies reviewed
- [ ] API keys rotated dari development


## Performance
- [ ] Profiled dengan Flutter DevTools (profile mode)
- [ ] No jank (semua frames <16ms)
- [ ] Memory usage acceptable dan stabil
- [ ] App size optimized (<30MB kalau bisa)
- [ ] Cold start <3 detik
- [ ] `buildWhen` diterapkan di semua `BlocBuilder` yang heavy
- [ ] No unnecessary rebuilds (cek dengan DevTools)


## Security
- [ ] API keys TIDAK hardcoded (pakai `--dart-define` atau `.env`)
- [ ] SSL pinning configured (opsional tapi recommended)
- [ ] Code obfuscation enabled (`--obfuscate`)
- [ ] Split debug info (`--split-debug-info=symbols/`)
- [ ] Tidak ada sensitive data di logs
- [ ] Secure storage untuk tokens (`flutter_secure_storage`)
- [ ] Certificate pinning untuk critical API calls
- [ ] Input sanitization di semua form


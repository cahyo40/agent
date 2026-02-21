---
description: Comprehensive testing (unit, widget, integration) dan production preparation untuk Flutter app dengan GetX state mana... (Part 8/8)
---
# Workflow: Testing & Production (GetX) (Part 8/8)

> **Navigation:** This workflow is split into 8 parts.

## Tools & Commands

### Testing Commands

```bash
# Run semua tests
flutter test

# Run dengan coverage
flutter test --coverage

# Run specific test file
flutter test test/unit/controllers/product_controller_test.dart

# Run tests matching pattern
flutter test --name "should fetch products"

# Run dengan verbose output
flutter test --reporter expanded

# Run integration tests
flutter test integration_test/

# Generate coverage report
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
```

### Build Commands

```bash
# Debug build
flutter run

# Profile build (untuk performance testing)
flutter run --profile

# Release build
flutter build apk --release
flutter build appbundle --release
flutter build ipa --release

# Dengan obfuscation
flutter build apk --release --obfuscate --split-debug-info=build/debug-info

# Analyze build size
flutter build apk --analyze-size --target-platform android-arm64
```

### Debugging & Profiling

```bash
# Flutter DevTools
flutter pub global activate devtools
dart devtools

# Check for memory leaks
flutter run --profile --trace-startup

# Dump widget tree
flutter run --dump-skp-on-shader-compilation
```

---


## Perbedaan Utama dari Riverpod Version

| Aspek | Riverpod | GetX |
|---|---|---|
| Test setup | `ProviderContainer` + overrides | `Get.put()` + `Get.reset()` |
| Widget test wrapper | `ProviderScope(overrides: [...])` | `GetMaterialApp` + `Get.put()` |
| Mock injection | Provider overrides | `Get.put<T>(mockInstance)` |
| Code generation | `build_runner` diperlukan | Tidak diperlukan |
| CI/CD step | Perlu `flutter pub run build_runner build` | Langsung `flutter test` |
| Controller cleanup | `ref.onDispose()` | `onClose()` + `Get.reset()` |
| Reactive testing | `container.read()` | Direct access via `.value` |

---


## Next Steps

Setelah testing dan production setup selesai:

1. **Monitoring** - Setup dashboard untuk monitoring app health (Sentry, Firebase Crashlytics, custom analytics)
2. **A/B Testing** - Implementasi feature flags untuk A/B testing (Firebase Remote Config)
3. **Continuous Improvement** - Regular performance profiling dan optimization
4. **User Feedback** - Setup feedback mechanism (in-app feedback, store reviews monitoring)
5. **Maintenance** - Regular dependency updates (`flutter pub outdated && flutter pub upgrade`)

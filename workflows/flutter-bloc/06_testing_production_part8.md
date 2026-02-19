---
description: Comprehensive testing (unit, widget, integration) dan production preparation khusus Flutter BLoC: `bloc_test` package... (Part 8/8)
---
# Workflow: Testing & Production (Flutter BLoC) (Part 8/8)

> **Navigation:** This workflow is split into 8 parts.

## Tools & Commands

### Testing
```bash
# Run semua tests
flutter test

# Run dengan coverage report
flutter test --coverage

# Generate HTML coverage report
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html

# Run specific test file
flutter test test/features/product/presentation/bloc/product_bloc_test.dart

# Run tests dengan name filter
flutter test --name "LoadProducts"

# Run integration tests
flutter test integration_test/app_test.dart

# Run integration tests di specific device
flutter test integration_test/ -d <device_id>
```

### Build Runner (WAJIB sebelum test/build)
```bash
# Generate semua code (*.g.dart, *.freezed.dart, *.config.dart)
dart run build_runner build --delete-conflicting-outputs

# Watch mode (saat development)
dart run build_runner watch --delete-conflicting-outputs

# Clean generated files
dart run build_runner clean
```

### Performance
```bash
# Profile mode (untuk performance testing)
flutter run --profile

# Build release
flutter build apk --release
flutter build appbundle --release
flutter build ios --release

# Build dengan obfuscation (production)
flutter build apk --release --obfuscate --split-debug-info=symbols/
flutter build appbundle --release --obfuscate --split-debug-info=symbols/

# Analyze app size
flutter build apk --analyze-size
flutter build appbundle --analyze-size
```

### CI/CD
```bash
# Local Fastlane test
cd android && bundle exec fastlane internal
cd ios && bundle exec fastlane beta

# Install Fastlane dependencies
cd android && bundle install
cd ios && bundle install
```


## Perbedaan Testing: BLoC vs Riverpod vs GetX

| Aspek | BLoC | Riverpod | GetX |
|-------|------|----------|------|
| Primary test tool | `blocTest<B,S>()` | `ProviderContainer` | `Get.put()` + manual |
| Mock state | `MockBloc` / `MockCubit` | `overrideWith()` | Manual mock controller |
| Widget wrap | `BlocProvider.value()` | `ProviderScope(overrides:)` | `Get.put()` |
| Stream mock | `whenListen()` | `overrideWith()` | `ever()` / manual |
| Teardown | `bloc.close()` | `container.dispose()` | `Get.reset()` |
| Code gen in CI | `build_runner` (freezed) | `build_runner` (riverpod_generator) | Tidak perlu |
| Test verbosity | Medium (declarative) | Low (minimal setup) | High (manual setup) |


## Next Steps

Setelah testing & production workflow selesai:
1. Monitor app performance di production (Crashlytics, Analytics)
2. Setup error tracking dan alerting (Sentry / Crashlytics dashboard)
3. Collect user feedback (in-app feedback, store reviews)
4. Plan next iteration / features
5. Setup automated regression testing schedule
6. Regular dependency updates (`flutter pub outdated && flutter pub upgrade`)
7. Security audit berkala

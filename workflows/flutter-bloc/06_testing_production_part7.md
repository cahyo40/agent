---
description: Comprehensive testing (unit, widget, integration) dan production preparation khusus Flutter BLoC: `bloc_test` package... (Part 7/8)
---
# Workflow: Testing & Production (Flutter BLoC) (Part 7/8)

> **Navigation:** This workflow is split into 8 parts.

## Final Steps
- [ ] Build release APK: `flutter build apk --release --obfuscate --split-debug-info=symbols/`
- [ ] Build release AAB: `flutter build appbundle --release --obfuscate --split-debug-info=symbols/`
- [ ] Build release IPA: `flutter build ipa --release --obfuscate --split-debug-info=symbols/`
- [ ] Test release build di real devices (WAJIB!)
- [ ] Beta testing (TestFlight untuk iOS, Internal Testing untuk Android)
- [ ] Monitor crash reports selama beta period
- [ ] Fix critical beta bugs
- [ ] Submit ke stores
- [ ] Monitor first 24-48 jam setelah release
```

---

### 7. Fastlane Configuration

**Description:** Fastlane setup untuk automated deployment. Konfigurasi sama dengan Riverpod — Fastlane tidak peduli state management apa yang dipakai. Yang penting: pastikan `build_runner` sudah dijalankan sebelum Fastlane build.

**Output Format:**

```ruby
# android/Gemfile
source "https://rubygems.org"
gem "fastlane"

# android/fastlane/Fastfile
default_platform(:android)

platform :android do
  desc "Deploy to internal testing track"
  lane :internal do
    # Pastikan build_runner sudah dijalankan sebelum lane ini!
    # Di CI, biasanya sudah dijalankan di step sebelumnya.
    # Kalau manual: sh("cd .. && dart run build_runner build --delete-conflicting-outputs")

    # Increment version code
    increment_version_code(
      gradle_file_path: "app/build.gradle",
    )

    # Build AAB via Flutter
    sh("cd ../.. && flutter build appbundle --release --obfuscate --split-debug-info=build/symbols")

    # Upload to Play Store internal track
    upload_to_play_store(
      track: "internal",
      aab: "../build/app/outputs/bundle/release/app-release.aab",
      skip_upload_metadata: true,
      skip_upload_images: true,
      skip_upload_screenshots: true,
      json_key_data: ENV["PLAY_STORE_SERVICE_ACCOUNT_JSON"],
    )

    # Notify team via Slack (opsional)
    # slack(
    #   message: "Android internal build uploaded successfully!",
    #   slack_url: ENV["SLACK_WEBHOOK_URL"],
    # )
  end

  desc "Promote internal to production"
  lane :production do
    upload_to_play_store(
      track: "internal",
      track_promote_to: "production",
      skip_upload_aab: true,
      skip_upload_metadata: false,
      json_key_data: ENV["PLAY_STORE_SERVICE_ACCOUNT_JSON"],
    )
  end

  desc "Build APK for local testing"
  lane :build_debug do
    sh("cd ../.. && dart run build_runner build --delete-conflicting-outputs")
    sh("cd ../.. && flutter build apk --debug")
  end
end

# ios/Gemfile
source "https://rubygems.org"
gem "fastlane"
gem "cocoapods"

# ios/fastlane/Fastfile
default_platform(:ios)

platform :ios do
  desc "Deploy to TestFlight"
  lane :beta do
    setup_ci

    # Fetch signing certificates via match
    match(
      type: "appstore",
      readonly: true,
      git_url: ENV["MATCH_GIT_URL"],
    )

    # Pastikan build_runner sudah dijalankan!
    sh("cd ../.. && dart run build_runner build --delete-conflicting-outputs")

    # Build IPA
    build_ios_app(
      export_method: "app-store",
      output_directory: "../build/ios/ipa",
      configuration: "Release",
    )

    # Upload to TestFlight
    upload_to_testflight(
      skip_waiting_for_build_processing: true,
      api_key_path: "fastlane/api_key.json",
    )
  end

  desc "Deploy to App Store"
  lane :release do
    setup_ci

    match(type: "appstore", readonly: true)

    sh("cd ../.. && dart run build_runner build --delete-conflicting-outputs")

    build_ios_app(
      export_method: "app-store",
      configuration: "Release",
    )

    upload_to_app_store(
      submit_for_review: true,
      automatic_release: false,
      force: true, # Skip HTML preview
      precheck_include_in_app_purchases: false,
      api_key_path: "fastlane/api_key.json",
    )
  end

  desc "Register new device for development"
  lane :register_device do
    device_name = prompt(text: "Enter device name: ")
    device_udid = prompt(text: "Enter device UDID: ")

    register_devices(
      devices: { device_name => device_udid }
    )

    match(type: "development", force_for_new_devices: true)
  end
end
```

**Fastlane Appfile Configuration:**

```ruby
# android/fastlane/Appfile
json_key_file(ENV["PLAY_STORE_JSON_KEY_PATH"])
package_name("com.example.myapp")

# ios/fastlane/Appfile
app_identifier("com.example.myapp")
apple_id(ENV["APPLE_ID"])
itc_team_id(ENV["ITC_TEAM_ID"])
team_id(ENV["TEAM_ID"])
```

---


## Test Helpers & Utilities

### Shared Test Setup

```dart
// test/helpers/test_helpers.dart
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';

// ========================================
// Centralized Mock Classes
// Semua MockBloc didefinisikan di sini supaya reusable
// ========================================
class MockProductBloc extends MockBloc<ProductEvent, ProductState>
    implements ProductBloc {}

class MockAuthBloc extends MockBloc<AuthEvent, AuthState>
    implements AuthBloc {}

class MockCartBloc extends MockBloc<CartEvent, CartState>
    implements CartBloc {}

class MockSettingsCubit extends MockCubit<SettingsState>
    implements SettingsCubit {}

// ========================================
// Mock Repositories
// ========================================
class MockProductRepository extends Mock implements ProductRepository {}
class MockAuthRepository extends Mock implements AuthRepository {}
class MockUserRepository extends Mock implements UserRepository {}

// ========================================
// Mock Use Cases
// ========================================
class MockGetProducts extends Mock implements GetProducts {}
class MockCreateProduct extends Mock implements CreateProduct {}
class MockDeleteProduct extends Mock implements DeleteProduct {}
class MockLoginUseCase extends Mock implements LoginUseCase {}

// ========================================
// Mock Navigation
// ========================================
class MockGoRouter extends Mock implements GoRouter {}
class MockNavigatorObserver extends Mock implements NavigatorObserver {}

// ========================================
// Widget Test Wrapper
// Helper untuk wrap widget dengan semua providers yang dibutuhkan
// ========================================
Widget buildTestableWidget({
  required Widget child,
  ProductBloc? productBloc,
  AuthBloc? authBloc,
  CartBloc? cartBloc,
  SettingsCubit? settingsCubit,
  GoRouter? goRouter,
}) {
  Widget widget = child;

  // Wrap dengan BlocProviders yang dibutuhkan
  final providers = <BlocProvider>[
    if (productBloc != null)
      BlocProvider<ProductBloc>.value(value: productBloc),
    if (authBloc != null)
      BlocProvider<AuthBloc>.value(value: authBloc),
    if (cartBloc != null)
      BlocProvider<CartBloc>.value(value: cartBloc),
    if (settingsCubit != null)
      BlocProvider<SettingsCubit>.value(value: settingsCubit),
  ];

  if (providers.isNotEmpty) {
    widget = MultiBlocProvider(
      providers: providers,
      child: widget,
    );
  }

  if (goRouter != null) {
    widget = InheritedGoRouter(
      goRouter: goRouter,
      child: widget,
    );
  }

  return MaterialApp(home: widget);
}

// ========================================
// Test Fixtures
// ========================================
class TestFixtures {
  static final product = Product(
    id: '1',
    name: 'Test Product',
    price: 99000,
    description: 'A test product',
    imageUrl: 'https://example.com/image.png',
    createdAt: DateTime(2024, 1, 1),
  );

  static final productList = [
    product,
    Product(id: '2', name: 'Product 2', price: 150000),
    Product(id: '3', name: 'Product 3', price: 200000),
  ];

  static final user = User(
    id: 'user-1',
    email: 'test@example.com',
    name: 'Test User',
    avatarUrl: 'https://example.com/avatar.png',
  );
}

// ========================================
// Fake Classes untuk registerFallbackValue
// ========================================
class FakeRoute extends Fake implements Route<dynamic> {}
class FakeGetProductsParams extends Fake implements GetProductsParams {}
class FakeCreateProductParams extends Fake implements CreateProductParams {}
class FakeLoginParams extends Fake implements LoginParams {}

// Register semua fallback values
void registerAllFallbackValues() {
  registerFallbackValue(FakeRoute());
  registerFallbackValue(FakeGetProductsParams());
  registerFallbackValue(FakeCreateProductParams());
  registerFallbackValue(FakeLoginParams());
}
```

---


## Workflow Steps

1. **Setup Testing Infrastructure**
   - Add test dependencies (`bloc_test`, `mocktail`)
   - Setup test helpers dan mock classes
   - Create test fixtures
   - Verify `build_runner` works (`dart run build_runner build`)

2. **Write Bloc/Cubit Unit Tests**
   - Test setiap Event → State transition dengan `blocTest`
   - Test initial state
   - Test error scenarios
   - Test debounce / transformer behavior
   - Run: `flutter test test/features/*/presentation/bloc/`

3. **Write Use Case & Repository Tests**
   - Test use cases (same pattern as Riverpod)
   - Test repositories
   - Test data sources
   - Run: `flutter test test/features/*/domain/ test/features/*/data/`

4. **Write Widget Tests**
   - Setup `MockBloc` untuk setiap bloc yang dibutuhkan
   - Test screens dengan berbagai states menggunakan `whenListen`
   - Test user interactions (verify events dispatched)
   - Test BlocListener behavior (SnackBars, dialogs, navigation)
   - Run: `flutter test test/features/*/presentation/screens/`

5. **Write Integration Tests**
   - Test end-to-end flows
   - Setup test environment (mock server / emulators)
   - Run: `flutter test integration_test/`

6. **Setup CI/CD**
   - Create GitHub Actions workflows
   - Pastikan `build_runner` step ada di CI
   - Configure secrets
   - Test CI pipeline end-to-end

7. **Performance Optimization**
   - Profile dengan DevTools (profile mode)
   - Implement `buildWhen` di heavy BlocBuilders
   - Setup `Bloc.observer` untuk monitoring
   - Verify Equatable di semua States
   - Fix performance issues

8. **Production Preparation**
   - Complete production checklist
   - Setup app signing (keystore, certificates)
   - Configure Fastlane
   - Prepare store listings dan screenshots
   - Run `build_runner` final build

9. **Deployment**
   - Build release versions (APK/AAB/IPA)
   - Upload ke stores (Fastlane atau manual)
   - Beta testing period
   - Monitor crash reports dan analytics
   - Production release


## Success Criteria

- [ ] Unit test coverage ≥ 80% overall
- [ ] Semua Bloc/Cubit classes coverage 100%
- [ ] All critical paths punya widget tests
- [ ] Integration tests cover happy paths
- [ ] CI/CD pipeline runs tanpa error (termasuk `build_runner`)
- [ ] No high/critical defects
- [ ] Performance benchmarks met (no jank, <3s startup)
- [ ] `buildWhen` diterapkan di semua heavy widgets
- [ ] `Bloc.observer` configured
- [ ] App size optimized
- [ ] Production checklist complete
- [ ] App published ke stores


---
description: Comprehensive testing (unit, widget, integration) dan production preparation: CI/CD pipeline, performance optimizatio... (Part 2/2)
---
# Workflow: Testing & Production (Part 2/2)

> **Navigation:** This workflow is split into 2 parts.

## List Optimization
- [ ] Use ListView.builder (NOT ListView with children)
- [ ] Implement pagination untuk long lists
- [ ] Use const constructors untuk list items
- [ ] Avoid heavy computation di itemBuilder


## State Management
- [ ] Use `select` untuk minimize rebuilds
- [ ] Avoid storing large objects di state
- [ ] Use `const` widgets di build method
- [ ] Implement proper dispose()


## Memory Management
- [ ] Cancel subscriptions on dispose
- [ ] Clear image cache periodically
- [ ] Use `RepaintBoundary` untuk complex widgets
- [ ] Avoid memory leaks di streams


## Startup Performance
- [ ] Defer non-critical initialization
- [ ] Use splash screen dengan proper initialization
- [ ] Minimize main bundle size
- [ ] Preload critical assets


## Profiling Steps
1. Run `flutter run --profile`
2. Open DevTools
3. Check for:
   - Raster thread jank (>16ms frames)
   - UI thread jank
   - Memory leaks (growing memory)
   - Excessive rebuilds
```

---

### 6. Production Checklist

**Description:** Comprehensive checklist sebelum release ke production.

**Output Format:**
```markdown
# Production Release Checklist


## Pre-Release
- [ ] App version updated di pubspec.yaml
- [ ] CHANGELOG.md updated
- [ ] README.md updated
- [ ] All tests passing
- [ ] Code coverage > 80%
- [ ] No analyzer warnings
- [ ] Code formatted


## Android
- [ ] ProGuard/R8 rules configured
- [ ] App signing configured
- [ ] Keystore backed up securely
- [ ] minSdkVersion appropriate
- [ ] targetSdkVersion latest
- [ ] App icon (all densities)
- [ ] Splash screen
- [ ] Play Store listing prepared
- [ ] Screenshots generated
- [ ] Privacy policy URL


## iOS
- [ ] App Store Connect setup
- [ ] App icon (all sizes)
- [ ] Launch screen
- [ ] Signing certificates
- [ ] Provisioning profiles
- [ ] Info.plist configured
- [ ] App Store listing prepared
- [ ] Screenshots (all devices)
- [ ] Privacy policy URL


## Firebase (jika pakai)
- [ ] Production Firebase project
- [ ] Security rules deployed
- [ ] Analytics enabled
- [ ] Crashlytics enabled
- [ ] Performance monitoring enabled
- [ ] Push notifications tested


## Performance
- [ ] Profiled dengan DevTools
- [ ] No jank (>16ms frames)
- [ ] Memory usage acceptable
- [ ] App size optimized
- [ ] Cold start < 3 seconds


## Security
- [ ] API keys not hardcoded
- [ ] SSL pinning (optional)
- [ ] Obfuscation enabled (`--obfuscate`)
- [ ] Split debug info (`--split-debug-info`)
- [ ] No sensitive data di logs


## Final Steps
- [ ] Build release APK/AAB
- [ ] Build release IPA
- [ ] Test on real devices
- [ ] Beta testing (TestFlight/Internal Testing)
- [ ] Submit to stores
```

---

### 7. Fastlane Configuration

**Description:** Fastlane setup untuk automated deployment.

**Output Format:**
```ruby
# android/fastlane/Fastfile
platform :android do
  desc "Deploy to internal testing"
  lane :internal do
    # Increment version code
    increment_version_code(
      gradle_file_path: "app/build.gradle",
    )
    
    # Build AAB
    gradle(
      task: "bundle",
      build_type: "release",
      properties: {
        "android.injected.signing.store.file" => ENV["KEYSTORE_FILE"],
        "android.injected.signing.store.password" => ENV["KEYSTORE_PASSWORD"],
        "android.injected.signing.key.alias" => ENV["KEY_ALIAS"],
        "android.injected.signing.key.password" => ENV["KEY_PASSWORD"],
      }
    )
    
    # Upload to Play Store
    upload_to_play_store(
      track: "internal",
      aab: "../build/app/outputs/bundle/release/app-release.aab",
      skip_upload_metadata: true,
      skip_upload_images: true,
      skip_upload_screenshots: true,
    )
  end
  
  desc "Deploy to production"
  lane :production do
    gradle(task: "bundle", build_type: "release")
    
    upload_to_play_store(
      track: "production",
      aab: "../build/app/outputs/bundle/release/app-release.aab",
    )
  end
end

# ios/fastlane/Fastfile
platform :ios do
  desc "Deploy to TestFlight"
  lane :beta do
    setup_ci
    
    # Sync certificates
    match(
      type: "appstore",
      readonly: true,
    )
    
    # Build IPA
    build_ios_app(
      export_method: "app-store",
      output_directory: "../build/ios/ipa",
    )
    
    # Upload to TestFlight
    upload_to_testflight(
      skip_waiting_for_build_processing: true,
    )
  end
  
  desc "Deploy to App Store"
  lane :release do
    setup_ci
    
    match(type: "appstore", readonly: true)
    
    build_ios_app(export_method: "app-store")
    
    upload_to_app_store(
      submit_for_review: true,
      automatic_release: false,
    )
  end
end
```


## Workflow Steps

1. **Setup Testing Infrastructure**
   - Add test dependencies
   - Setup test utilities
   - Create mock classes

2. **Write Unit Tests**
   - Test use cases
   - Test repositories
   - Test services
   - Run tests: `flutter test`

3. **Write Widget Tests**
   - Test screens
   - Test components
   - Test forms
   - Test navigation

4. **Write Integration Tests**
   - Test end-to-end flows
   - Setup test environment
   - Run: `flutter test integration_test/`

5. **Setup CI/CD**
   - Create GitHub Actions workflows
   - Configure secrets
   - Test CI pipeline

6. **Performance Optimization**
   - Profile dengan DevTools
   - Fix performance issues
   - Verify optimizations

7. **Production Preparation**
   - Complete checklist
   - Setup signing
   - Configure Fastlane
   - Prepare store listings

8. **Deployment**
   - Build release versions
   - Upload ke stores
   - Monitor analytics


## Success Criteria

- [ ] Unit test coverage ≥ 80%
- [ ] All critical paths have widget tests
- [ ] Integration tests cover happy paths
- [ ] CI/CD pipeline runs tanpa error
- [ ] No high/critical defects
- [ ] Performance benchmarks met
- [ ] App size optimized
- [ ] Production checklist complete
- [ ] App published ke stores


## Tools & Commands

### Testing
```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage

# Run specific test file
flutter test test/features/auth/domain/usecases/login_test.dart

# Run integration tests
flutter test integration_test/app_test.dart
```

### Performance
```bash
# Profile mode
flutter run --profile

# Build release
flutter build apk --release
flutter build ios --release

# Build with obfuscation
flutter build apk --release --obfuscate --split-debug-info=symbols/
```

### CI/CD
```bash
# Local Fastlane test
cd android && fastlane internal
cd ios && fastlane beta
```


## Next Steps

Setelah testing & production workflow selesai:
1. Monitor app performance di production
2. Collect user feedback
3. Plan next features
4. Setup monitoring dan crash reporting
5. Regular updates dan maintenance

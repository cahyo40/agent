---
description: Comprehensive testing (unit, widget, integration) dan production preparation untuk Flutter app dengan GetX state mana... (Part 1/8)
---
# Workflow: Testing & Production (GetX) (Part 1/8)

> **Navigation:** This workflow is split into 8 parts.

## Overview

Comprehensive testing (unit, widget, integration) dan production preparation untuk Flutter app dengan GetX state management. Workflow ini mencakup seluruh pipeline dari menulis test hingga deploy ke production, termasuk CI/CD setup, performance optimization, dan production checklist.

Berbeda dengan Riverpod yang membutuhkan `ProviderScope` dan `ProviderContainer` untuk testing, GetX menggunakan pendekatan yang lebih straightforward: `Get.put()` untuk dependency injection dan `Get.reset()` untuk cleanup. Tidak diperlukan code generation (`build_runner`) sehingga CI/CD pipeline lebih sederhana.


## Output Location

**Base Folder:** `sdlc/flutter-getx/06-testing-production/`

```
sdlc/flutter-getx/06-testing-production/
  unit-tests/
    controller_tests.dart
    service_tests.dart
    repository_tests.dart
    binding_tests.dart
  widget-tests/
    view_tests.dart
    component_tests.dart
    navigation_tests.dart
  integration-tests/
    app_test.dart
    flow_tests.dart
  ci-cd/
    github-actions.yml
    fastlane/
      Fastfile
      Appfile
      Matchfile
  performance/
    optimization_checklist.md
    benchmark_results.md
  production/
    release_checklist.md
    monitoring_setup.md
```


## Prerequisites

- Flutter SDK >= 3.24.0
- Semua deliverable dari workflow 01-05 sudah selesai
- Dependencies testing sudah ditambahkan di `pubspec.yaml`

### Testing Dependencies

```yaml
# pubspec.yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  integration_test:
    sdk: flutter
  mocktail: ^1.0.4
  fake_async: ^1.3.1
  golden_toolkit: ^0.15.0
  flutter_lints: ^3.0.0
  coverage: ^1.9.2
  test: ^1.25.0
```

> **Catatan:** Tidak perlu `riverpod_test`, `state_notifier_test`, atau `build_runner`. GetX testing hanya membutuhkan `mocktail` untuk mocking dan standard Flutter test utilities.

---


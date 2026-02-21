---
description: Implementasi repository pattern dengan REST API menggunakan Dio. (Part 1/7)
---
# Workflow: Backend Integration (REST API) - GetX (Part 1/7)

> **Navigation:** This workflow is split into 7 parts.

## Overview

Implementasi repository pattern dengan REST API menggunakan Dio. Workflow ini mencakup setup Dio dengan interceptors, error handling, offline-first strategy, dan pagination. Semua dependency di-manage melalui `GetxService` dan `Get.put()` / `Get.find()` — bukan Riverpod provider.


## Output Location

**Base Folder:** `sdlc/flutter-youi/03-backend-integration/`

Struktur output:

```
sdlc/flutter-youi/03-backend-integration/
  dio_client.dart
  interceptors/
    auth_interceptor.dart
    retry_interceptor.dart
    logging_interceptor.dart
    error_interceptor.dart
  error/
    app_exception.dart
    error_mapper.dart
  models/
    api_response.dart
    paginated_response.dart
  repositories/
    base_repository.dart
    product_repository.dart
  controllers/
    paginated_controller.dart
  views/
    product_list_view.dart
  bindings/
    network_binding.dart
```


## Prerequisites

- Project setup dari `01_project_setup.md` selesai
- API endpoint tersedia (base URL, auth endpoint, data endpoint)
- Package dependencies sudah ditambahkan:

```yaml
# pubspec.yaml
dependencies:
  get: ^4.6.6
  dio: ^5.4.0
  connectivity_plus: ^6.0.0
  hive_flutter: ^1.1.0
  pretty_dio_logger: ^1.4.0
```

---


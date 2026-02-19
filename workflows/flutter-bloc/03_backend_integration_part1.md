---
description: Implementasi repository pattern dengan REST API menggunakan Dio dan flutter_bloc. (Part 1/8)
---
# Workflow: Backend Integration (REST API) - Flutter BLoC (Part 1/8)

> **Navigation:** This workflow is split into 8 parts.

## Overview

Implementasi repository pattern dengan REST API menggunakan Dio dan flutter_bloc. Workflow ini mencakup setup Dio sebagai `@lazySingleton` di get_it, interceptors dengan akses service locator, error handling, offline-first strategy, dan pagination menggunakan BLoC events/state.

> **Perbedaan utama dengan Riverpod:**
> - `DioClient` di-register sebagai `@lazySingleton` di get_it, bukan Riverpod provider
> - Auth interceptor menggunakan `sl<SecureStorageService>()` (service locator), bukan `ref.read()`
> - Pagination menggunakan `PaginatedProductBloc` dengan sealed events (`LoadProducts`, `LoadNextPage`, `RefreshProducts`, `SearchProducts`)
> - State berisi pagination metadata eksplisit: `PaginatedProductState(products, hasMore, currentPage, ...)`
> - UI menggunakan `BlocBuilder` + `BlocListener` untuk error handling
> - Data layer (repository, data source, models) tetap framework-agnostic — tidak ada coupling ke BLoC maupun Riverpod


## Output Location

**Base Folder:** `sdlc/flutter-bloc/03-backend-integration/`

**Output Files:**
- `dio-setup.md` - Konfigurasi Dio lengkap dengan get_it registration
- `interceptors/` - Auth (sl-based), retry, logging, error interceptors
- `error-handling.md` - Error mapper dan AppException hierarchy
- `repository-pattern.md` - Repository implementation dengan offline-first
- `pagination.md` - BLoC-based infinite scroll implementation
- `examples/` - Contoh API integration lengkap


## Prerequisites

- Project setup dari `01_project_setup.md` selesai (termasuk get_it + injectable)
- API endpoint tersedia
- API documentation (Swagger/OpenAPI)
- Dependencies sudah di-add:
  ```yaml
  dependencies:
    dio: ^5.4.0
    get_it: ^7.6.7
    injectable: ^2.3.2
    flutter_bloc: ^8.1.4
    equatable: ^2.0.5
    dartz: ^0.10.1
    connectivity_plus: ^6.0.0
    flutter_secure_storage: ^9.0.0
    json_annotation: ^4.8.1
    freezed_annotation: ^2.4.1

  dev_dependencies:
    injectable_generator: ^2.4.1
    build_runner: ^2.4.8
    json_serializable: ^6.7.1
    freezed: ^2.4.6
  ```


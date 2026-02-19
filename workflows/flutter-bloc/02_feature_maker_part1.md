---
description: Generate feature baru dengan struktur Clean Architecture lengkap menggunakan **flutter_bloc**. (Part 1/11)
---
# Workflow: Flutter BLoC Feature Maker (Part 1/11)

> **Navigation:** This workflow is split into 11 parts.

## Overview

Generate feature baru dengan struktur Clean Architecture lengkap menggunakan **flutter_bloc**. Workflow ini membuat boilerplate code untuk feature baru termasuk entity, model, repository, use case, **BLoC (events + states)**, dan screen dengan `BlocConsumer`.

Perbedaan utama dengan Riverpod version:
- State management menggunakan `Bloc<Event, State>` atau `Cubit<State>`
- Events dan States didefinisikan sebagai **sealed class** (Dart 3)
- Side effects ditangani via `BlocListener`
- DI menggunakan `get_it` + `injectable` (bukan Riverpod providers)
- Pattern matching pada state di `BlocBuilder`


## Output Location

**Base Folder:** `sdlc/flutter-bloc/02-feature-maker/`

**Output Files:**
- `feature-template.md` - Panduan menggunakan template
- `feature-generator-script.md` - Script/logika untuk generate feature
- `templates/` - Template files untuk setiap layer
  - `domain/` - Entity, repository, use case templates
  - `data/` - Model, repository impl, data source templates
  - `presentation/` - BLoC, screen, widget templates
- `examples/` - Contoh feature yang sudah jadi (Todo)


## Prerequisites

- Project setup dari `01_project_setup.md` selesai
- Clean Architecture structure sudah ada
- Dependencies sudah terinstall:
  - `flutter_bloc` / `bloc`
  - `equatable`
  - `get_it` + `injectable` + `injectable_generator`
  - `freezed` + `freezed_annotation` (optional, untuk events/states)
  - `go_router`
  - `dartz` (untuk Either)
  - `dio` (HTTP client)
  - `shimmer`


## Feature Folder Structure

```
lib/features/{feature_name}/
├── data/
│   ├── datasources/
│   │   ├── {feature_name}_remote_ds.dart
│   │   └── {feature_name}_local_ds.dart
│   ├── models/
│   │   └── {feature_name}_model.dart
│   └── repositories/
│       └── {feature_name}_repository_impl.dart
├── domain/
│   ├── entities/
│   │   └── {feature_name}_entity.dart
│   ├── repositories/
│   │   └── {feature_name}_repository.dart
│   └── usecases/
│       ├── get_{feature_name}s.dart
│       ├── get_{feature_name}_by_id.dart
│       ├── create_{feature_name}.dart
│       ├── update_{feature_name}.dart
│       └── delete_{feature_name}.dart
└── presentation/
    ├── bloc/
    │   ├── {feature_name}_bloc.dart
    │   ├── {feature_name}_event.dart
    │   └── {feature_name}_state.dart
    ├── screens/
    │   ├── {feature_name}_list_screen.dart
    │   └── {feature_name}_detail_screen.dart
    └── widgets/
        ├── {feature_name}_list_item.dart
        ├── {feature_name}_form.dart
        └── {feature_name}_shimmer.dart
```


## Placeholder Convention

Gunakan placeholder berikut saat generate feature. Replace semua sebelum dipakai:

| Placeholder | Contoh (Todo) | Keterangan |
|---|---|---|
| `{FeatureName}` | `Todo` | PascalCase |
| `{featureName}` | `todo` | camelCase |
| `{feature_name}` | `todo` | snake_case |
| `{FEATURE_NAME}` | `TODO` | UPPER_CASE |
| `{feature-name}` | `todo` | kebab-case |

---


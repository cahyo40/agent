---
description: Setup Flutter project dari nol dengan Clean Architecture dan BLoC state management. (Part 2/6)
---
# Workflow: Flutter Project Setup with BLoC (Part 2/6)

> **Navigation:** This workflow is split into 6 parts.

## Deliverables

### 1. Project Structure - Clean Architecture dengan BLoC

**Description:** Struktur folder lengkap dengan Clean Architecture + BLoC pattern.

**Recommended Skills:** `senior-flutter-developer`, `senior-software-architect`

**Instructions:**
1. Buat folder structure berikut:
   ```
   lib/
   ├── app.dart                    # Root widget dengan MultiBlocProvider
   ├── main.dart                   # Entry point
   ├── bootstrap/                  # App initialization
   │   ├── bootstrap.dart         # App bootstrapping (init Hive, get_it, etc.)
   │   └── observers/             # BlocObserver untuk logging
   │       └── app_bloc_observer.dart
   ├── core/                      # Shared infrastructure
   │   ├── di/                    # Dependency Injection (get_it + injectable)
   │   │   ├── injection.dart     # @InjectableInit setup
   │   │   └── injection.config.dart  # Generated
   │   ├── error/                 # Error handling
   │   │   ├── exceptions.dart    # AppException, ServerException, etc.
   │   │   └── failures.dart      # Failure, ServerFailure, etc.
   │   ├── network/               # Dio setup, interceptors
   │   │   ├── api_client.dart
   │   │   └── interceptors/
   │   ├── router/                # GoRouter configuration
   │   │   ├── app_router.dart
   │   │   ├── routes.dart
   │   │   └── guards/
   │   │       └── auth_guard.dart
   │   ├── storage/               # Secure & local storage
   │   │   ├── secure_storage.dart
   │   │   └── local_storage.dart
   │   ├── theme/                 # App theme & colors
   │   │   ├── app_theme.dart
   │   │   ├── colors.dart
   │   │   └── typography.dart
   │   ├── usecase/               # Base UseCase contract
   │   │   └── usecase.dart
   │   └── widgets/               # Shared core widgets
   │       ├── error_view.dart
   │       ├── loading_view.dart
   │       └── empty_view.dart
   ├── features/                  # Feature modules
   │   └── product/               # Contoh feature
   │       ├── data/
   │       │   ├── datasources/
   │       │   │   ├── product_remote_datasource.dart
   │       │   │   └── product_local_datasource.dart
   │       │   ├── models/
   │       │   │   └── product_model.dart
   │       │   └── repositories/
   │       │       └── product_repository_impl.dart
   │       ├── domain/
   │       │   ├── entities/
   │       │   │   └── product.dart
   │       │   ├── repositories/
   │       │   │   └── product_repository.dart
   │       │   └── usecases/
   │       │       ├── get_products.dart
   │       │       ├── get_product.dart
   │       │       ├── create_product.dart
   │       │       └── delete_product.dart
   │       └── presentation/
   │           ├── bloc/
   │           │   ├── product_bloc.dart      # Bloc class
   │           │   ├── product_event.dart     # Events
   │           │   └── product_state.dart     # States
   │           ├── screens/
   │           │   ├── product_list_screen.dart
   │           │   ├── product_detail_screen.dart
   │           │   └── product_create_screen.dart
   │           └── widgets/
   │               ├── product_card.dart
   │               └── shimmer_product_list.dart
   ├── l10n/                      # Localization
   ├── shared/                    # Shared utilities
   │   ├── extensions/
   │   │   ├── context_extension.dart
   │   │   └── string_extension.dart
   │   ├── mixins/
   │   ├── utils/
   │   │   ├── logger.dart
   │   │   └── validators.dart
   │   └── widgets/
   │       ├── app_button.dart
   │       └── app_text_field.dart
   └── main.dart
   ```
2. Setup setiap folder dengan base files
3. Konfigurasi import alias di `pubspec.yaml`

**Catatan Penting tentang BLoC folder structure:**
- Setiap feature punya folder `bloc/` di dalam `presentation/` (bukan `controllers/`)
- BLoC terdiri dari 3 file: `*_bloc.dart`, `*_event.dart`, `*_state.dart`
- Untuk fitur sederhana, bisa pakai `cubit/` folder dengan 2 file: `*_cubit.dart`, `*_state.dart`

---

## Deliverables

### 2. Dependencies (pubspec.yaml)

**Description:** Konfigurasi semua dependencies untuk Flutter BLoC project.

**Output Format:**
```yaml
# pubspec.yaml
name: my_app
description: A new Flutter project with BLoC pattern.

publish_to: 'none'

version: 1.0.0+1

environment:
  sdk: '>=3.11.0 <4.0.0'  # Updated untuk Flutter 3.41.1

dependencies:
  flutter:
    sdk: flutter

  # State Management - BLoC
  flutter_bloc: ^8.1.6
  bloc: ^8.1.4
  equatable: ^2.0.5

  # Dependency Injection
  get_it: ^8.0.0
  injectable: ^2.5.0

  # Routing
  go_router: ^14.0.0

  # Network
  dio: ^5.4.0
  connectivity_plus: ^6.0.0

  # Storage
  hive_flutter: ^1.1.0
  flutter_secure_storage: ^9.0.0

  # Functional Programming
  dartz: ^0.10.1

  # UI
  cached_network_image: ^3.3.1
  shimmer: ^3.0.0
  google_fonts: ^6.2.1

  # Code Generation Annotations
  freezed_annotation: ^2.4.1
  json_annotation: ^4.8.1

  # Utils
  intl: ^0.19.0

  # Firebase (optional) - Updated untuk Flutter 3.41.1
  # firebase_core: ^3.12.0
  # firebase_auth: ^5.5.0
  # cloud_firestore: ^5.6.0
  # firebase_storage: ^12.4.0
  # firebase_messaging: ^15.2.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^4.0.0

  # Code Generation
  build_runner: ^2.4.9
  freezed: ^2.5.0
  json_serializable: ^6.7.1
  injectable_generator: ^2.6.2

  # Testing
  bloc_test: ^9.1.7
  mocktail: ^1.0.0

flutter:
  uses-material-design: true
```

**Penjelasan dependencies BLoC vs Riverpod:**

| Concern               | BLoC Stack                          | Riverpod Stack                      |
|------------------------|-------------------------------------|--------------------------------------|
| State Management       | `flutter_bloc`, `bloc`              | `flutter_riverpod`, `riverpod_annotation` |
| DI                     | `get_it`, `injectable`              | Built-in Riverpod providers          |
| State/Event classes    | `equatable`, `freezed` (optional)   | `freezed` (optional)                |
| Linting                | `flutter_lints`                     | `riverpod_lint`, `custom_lint`       |
| Testing                | `bloc_test`, `mocktail`             | `mocktail` (langsung test provider)  |
| Code Gen               | `injectable_generator`              | `riverpod_generator`                |

---


# Enterprise Project Architecture

## Folder Structure

```text
lib/
├── bootstrap/                 # App initialization
│   ├── app.dart               # Root widget
│   ├── bootstrap.dart         # App bootstrapping
│   └── observers/             # Bloc/Provider observers
├── core/
│   ├── di/                    # Dependency injection setup
│   ├── error/
│   │   ├── exceptions.dart    # Custom exceptions
│   │   ├── failures.dart      # Domain failures
│   │   └── error_handler.dart # Global error handling
│   ├── network/
│   │   ├── api_client.dart    # Dio setup
│   │   ├── interceptors/      # Auth, logging, retry
│   │   └── network_info.dart  # Connectivity
│   ├── router/
│   │   ├── app_router.dart    # GoRouter config
│   │   ├── guards/            # Route guards
│   │   └── routes.dart        # Route definitions
│   ├── storage/
│   │   ├── secure_storage.dart
│   │   └── local_storage.dart
│   └── theme/
│       ├── app_theme.dart
│       ├── colors.dart
│       └── typography.dart
├── features/
│   └── <feature>/
│       ├── data/
│       │   ├── datasources/
│       │   │   ├── <feature>_remote_ds.dart
│       │   │   └── <feature>_local_ds.dart
│       │   ├── models/
│       │   │   └── <entity>_model.dart
│       │   └── repositories/
│       │       └── <feature>_repository_impl.dart
│       ├── domain/
│       │   ├── entities/
│       │   ├── repositories/  # Abstract contracts
│       │   └── usecases/
│       └── presentation/
│           ├── controllers/   # Riverpod controllers
│           ├── screens/
│           └── widgets/
├── l10n/                      # Localization
│   ├── app_en.arb
│   └── app_id.arb
├── shared/
│   ├── extensions/
│   ├── mixins/
│   ├── utils/
│   └── widgets/
└── main.dart
```

## Layer Responsibilities

### Domain Layer

- Entities: Pure Dart classes representing business objects
- Repositories (abstract): Contracts for data operations
- Use Cases: Single-responsibility business logic

### Data Layer

- Models: JSON-serializable DTOs with `fromJson`/`toJson`
- Data Sources: Remote (API) and Local (Cache/DB)
- Repository Impl: Implements domain contracts

### Presentation Layer

- Controllers: State management (Riverpod/BLoC)
- Screens: Full pages
- Widgets: Reusable UI components

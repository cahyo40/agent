# Clean Architecture Guide

## Folder Structure

```
lib/
├── core/
│   ├── config/          # AppRouter, AppPages
│   ├── constants/       # App constants
│   ├── di/              # Dependency injection
│   ├── extensions/      # Dart/Flutter extensions
│   ├── network/         # Dio client, interceptors
│   ├── services/        # App-wide services
│   ├── themes/          # AppTheme (wraps YoTheme.lightTheme/darkTheme)
│   ├── utils/           # Utility functions
│   └── widgets/         # Global widgets (YoUI)
├── features/
│   └── <feature>/
│       ├── data/
│       │   ├── datasources/     # API calls, local storage
│       │   ├── models/          # JSON serialization
│       │   └── repositories/    # Repository implementations
│       ├── domain/
│       │   ├── entities/        # Business objects (pure Dart)
│       │   ├── repositories/    # Abstract interfaces
│       │   └── usecases/        # Business logic
│       └── presentation/
│           ├── pages/           # Full page (YoScaffold)
│           ├── screens/         # Screen component
│           ├── providers/       # Riverpod providers
│           ├── controllers/     # GetX controllers
│           ├── bloc/            # BLoC/Cubit
│           └── widgets/         # Feature-specific widgets
└── l10n/                        # Localization files
```

## Layer Rules

### Domain Layer (Pure Dart)
- ❌ TIDAK boleh import Flutter
- ❌ TIDAK boleh import data layer
- ❌ TIDAK boleh import presentation layer
- ✅ Hanya Dart native + entities + repository interfaces + usecases

### Data Layer
- ✅ Boleh import domain layer (implements repository interface)
- ❌ TIDAK boleh import presentation layer
- ✅ Menggunakan models (JSON/Hive) dan datasources

### Presentation Layer
- ✅ Boleh import domain layer (uses usecases)
- ❌ TIDAK boleh import data layer langsung
- ✅ Menggunakan YoUI components dari yo_ui

## Data Flow

```
UI (Page/Screen)
  ↓ event/action
Provider/Controller/BLoC
  ↓ call
UseCase
  ↓ call
Repository (abstract interface in domain)
  ↓ implemented by
RepositoryImpl (in data)
  ↓ call
DataSource (Remote/Local)
  ↓ return
Model → Entity mapping
  ↑ return to UI
```

## Generated Files per Feature

Saat menjalankan `dart run yo.dart page:auth`:

```
features/auth/
├── data/
│   ├── datasources/
│   │   └── auth_remote_datasource.dart
│   ├── models/
│   │   └── auth_model.dart
│   └── repositories/
│       └── auth_repository_impl.dart
├── domain/
│   ├── entities/
│   │   └── auth_entity.dart
│   ├── repositories/
│   │   └── auth_repository.dart      # abstract
│   └── usecases/
│       └── auth_usecase.dart
└── presentation/
    ├── pages/
    │   └── auth_page.dart            # YoScaffold + YoLoading + YoErrorState
    └── providers/                    # atau controllers/ atau bloc/
        └── auth_provider.dart
```

# Flutter BLoC Workflows

Production-ready Flutter development workflows menggunakan **flutter_bloc** dan **Clean Architecture**.

## Quick Start

```
Gunakan workflow @flutter-bloc/01_project_setup

Setup Flutter project "[nama_app]" dengan Clean Architecture + flutter_bloc + get_it
```

## Workflow Index

| # | File | Deskripsi | Fase |
|---|------|-----------|------|
| 01 | `01_project_setup.md` | Project setup, folder structure, DI | 🏗 Foundation |
| 02 | `02_feature_maker.md` | Buat feature baru (domain → data → UI) | 🏗 Foundation |
| 03 | `03_backend_integration.md` | Dio, interceptors, REST API, pagination | 🔌 Backend |
| 04 | `04_firebase_integration.md` | Firebase Auth, Firestore, Storage, FCM | 🔌 Backend |
| 05 | `05_supabase_integration.md` | Supabase Auth, PostgreSQL, Realtime | 🔌 Backend |
| 06 | `06_testing_production.md` | blocTest, MockBloc, CI/CD | ✅ Quality |
| 07 | `07_translation.md` | easy_localization, LocaleCubit | ✨ Enhancement |
| 09 | `09_state_management_advanced.md` | Pagination, optimistic, cross-Bloc | ✨ Enhancement |
| 10 | `10_offline_storage.md` | Hive, Isar, SecureStorage, ConnectivityCubit | ✨ Enhancement |
| 11 | `11_ui_components.md` | AppButton, Shimmer, EmptyState, AppCard | ✨ Enhancement |
| 12 | `12_push_notifications.md` | FCM, local notifications, deep linking | 🚀 Deploy |
| 13 | `13_performance_monitoring.md` | Firebase Performance, Sentry | 🚀 Deploy |

## Architecture

```
presentation → domain ← data
     ↑            ↑       ↑
  BLoC/Cubit  UseCases  Repository
  Screens     Entities  DataSources
  Widgets     Repos     Models (JSON)
```

### Key Patterns

- **Events:** `sealed class ProductEvent extends Equatable`
- **States:** `sealed class ProductState extends Equatable`
- **DI:** `get_it` + `injectable` (`@lazySingleton`, `@injectable`)
- **Error:** `Result<T>` sealed class (no `dartz`)
- **Nav:** `go_router` dengan `AuthGuard`
- **Network:** `Dio` + Auth/Retry/Logging interceptors

## Documentation

Lihat [USAGE.md](./USAGE.md) untuk panduan lengkap, contoh prompt, dan troubleshooting.
Lihat [examples.md](./examples.md) untuk copy-paste prompts siap pakai.

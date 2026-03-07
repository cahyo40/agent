# Flutter GetX Workflows

Production-ready Flutter development workflows menggunakan **GetX** state management dan **Clean Architecture**.

## Quick Start

```
Gunakan workflow @flutter-getx/01_project_setup

Setup Flutter project "[nama_app]" dengan Clean Architecture + GetX
```

## Workflow Index

| # | File | Deskripsi | Fase |
|---|------|-----------|------|
| 01 | `01_project_setup.md` | Project setup, folder structure, DI | 🏗 Foundation |
| 02 | `02_feature_maker.md` | Buat feature baru (domain → data → UI) | 🏗 Foundation |
| 03 | `03_ui_components.md` | AppButton, Shimmer, EmptyState, AppCard | 🏗 Foundation |
| 04 | `04_state_management_advanced.md` | Pagination, Workers, StateMixin, cross-Controller | 🔌 Backend |
| 05 | `05_backend_integration.md` | Dio, interceptors, REST API, pagination | 🔌 Backend |
| 06 | `06_firebase_integration.md` | Firebase Auth, Firestore, Storage, FCM | 🔌 Backend |
| 07 | `07_supabase_integration.md` | Supabase Auth, PostgreSQL, Realtime | 🔌 Backend |
| 08 | `08_offline_storage.md` | GetStorage, Hive, SecureStorage | ✨ Enhancement |
| 09 | `09_translation.md` | easy_localization, LocaleController | ✨ Enhancement |
| 10 | `10_push_notifications.md` | FCM, local notifications, deep linking | 🚀 Deploy |
| 11 | `11_testing_production.md` | Unit Tests, Widget Tests, CI/CD | ✅ Quality |
| 12 | `12_performance_monitoring.md` | Firebase Crashlytics, Sentry, Security | 🚀 Deploy |

## Architecture

```
presentation → domain ← data
     ↑            ↑       ↑
Controllers   UseCases  Repository
  Screens     Entities  DataSources
  Widgets     Repos     Models (JSON)
```

### Key Patterns

- **State Management:** `GetxController` dengan `.obs` variables dan `Obx()`
- **Advanced State:** `StateMixin` dan `Workers` (`debounce`, `ever`, dll)
- **DI:** `Get.put()`, `Get.lazyPut()` via `Bindings` per route
- **Error:** `Result<T>` sealed class (no `dartz`)
- **Nav:** `GetMaterialApp` dengan named routes (`Get.toNamed`) dan `GetMiddleware`
- **Network:** `Dio` + Auth/Retry/Logging interceptors

## Documentation

Lihat [USAGE.md](./USAGE.md) untuk panduan lengkap, contoh prompt, dan troubleshooting.
Lihat [examples.md](./examples.md) untuk copy-paste prompts siap pakai.

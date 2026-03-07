# Flutter Riverpod Workflows - User Guide

Panduan lengkap penggunaan workflows untuk development Flutter dengan Riverpod dan Clean Architecture.

## 📋 Daftar Isi

1. [Overview](#overview)
2. [Persyaratan Sistem](#persyaratan-sistem)
3. [Daftar Workflows](#daftar-workflows)
4. [Cara Penggunaan](#cara-penggunaan)
5. [Contoh Prompt](#contoh-prompt)

---

Workflows ini dirancang untuk eksekusi end-to-end development Flutter menggunakan pendekatan AI agentic. Total terdapat **12 workflows** yang mencakup dari setup, UI/state, integrasi data, fitur pro, hingga quality & security.

---

## Persyaratan Sistem

- **Flutter SDK**: 3.41.1+ (stable channel)
- **Dart SDK**: 3.11.0+
- **Architecture**: Domain-Driven Design / Clean Architecture

---

## Daftar Workflows

Berikut daftar fungsionalitas tiap workflow:

### Phase 1: Foundation
- **`01_project_setup.md`**: Initial project, GoRouter, Theme, Clean Arch folder structure.
- **`02_feature_maker.md`**: Generator files untuk layer DOMAIN, DATA, dan PRESENTATION.
- **`03_ui_components.md`**: Komponen dasar (Button, TextField, Card, Shimmer, ErrorState).

### Phase 2: Data & Patterns
- **`04_state_management_advanced.md`**: Riverpod AsyncNotifier, family, pagination, debounce.
- **`05_backend_integration.md`**: Integrasi REST API menggunakan Dio dan Interceptors.
- **`06_firebase_integration.md`**: Firebase Auth, Firestore, Storage.
- **`07_supabase_integration.md`**: Supabase Auth, PostgreSQL (RLS), Realtime.
- **`08_offline_storage.md`**: Hive, Drift SQLite, Secure Storage.

### Phase 3: Pro Enhancements
- **`09_translation.md`**: i18n localization (multi-bahasa).
- **`10_push_notifications.md`**: FCM dan local notification dengan deep linking routing.

### Phase 4: Quality, Security & Deploy
- **`11_testing_production.md`**: Unit, Widget, Integration tests dengan Mocktail.
- **`12_performance_monitoring.md`**: Sentry tracing, Firebase Crashlytics, dan Security Hardening (SSL Pinning, root detection).

---

## Cara Penggunaan

### Urutan Standar (Project Baru)

```text
Phase 1
01_project_setup.md  →  02_feature_maker.md  →  03_ui_components.md

Phase 2
04_state_management_advanced.md  →  (Pilih: 05_backend / 06_firebase / 07_supabase)  →  08_offline_storage.md

Phase 3 & 4
09_translation.md  →  10_push_notifications.md  →  11_testing_production.md  →  12_performance_monitoring.md
```

### Prompt Dasar
Untuk mulai, gunakan prompt sederhana memanggil workflow terkait:
> "@mcp:context7 jalankan workflow flutter-riverpod/01_project_setup.md untuk membuat struktur dasar aplikasi ini"

---

## Contoh Prompt

Buka file **`example.md`** di folder ini untuk melihat kumpulan lengkap prompt (copy-paste) per workflow. Contoh:

- **Setup Project:** "Tolong jalankan `01_project_setup.md` dengan nama package `com.example.app`"
- **Build Feature:** "Generate fitur 'Profile' menggunakan `02_feature_maker.md`"
- **Performance & Security:** "Tolong aplikasikan `12_performance_monitoring.md` untuk implementasi SSL pinning"

---
description: Integrasi Supabase sebagai alternative backend dengan GetX state management: Authentication, PostgreSQL Database, Rea... (Part 1/7)
---
# Workflow: Supabase Integration (GetX) (Part 1/7)

> **Navigation:** This workflow is split into 7 parts.

## Overview

Integrasi Supabase sebagai alternative backend dengan GetX state management: Authentication, PostgreSQL Database, Realtime subscriptions, dan Storage. Workflow ini mencakup setup lengkap dengan Row Level Security (RLS), reactive state menggunakan `.obs`, dan lifecycle management via `onInit()`/`onClose()`.

Perbedaan utama dengan versi Riverpod:
- Tidak ada `ProviderScope` — Supabase init langsung sebelum `runApp(GetMaterialApp(...))`
- Auth controller menggunakan `GetxController` dengan `Rx<User?>` dan `Rx<Session?>`
- Auth state change di-listen via `_supabase.auth.onAuthStateChange.listen()` di `onInit()`
- Database CRUD controller menggunakan `RxList`, `RxBool` untuk loading state
- Realtime subscription managed di `onInit()` dan di-cleanup di `onClose()`
- Storage service di-register via `Get.put()` atau `Get.lazyPut()` di bindings
- Navigation redirect menggunakan `Get.offAllNamed()` bukan GoRouter


## Output Location

**Base Folder:** `sdlc/flutter-getx/05-supabase-integration/`

**Output Files:**
- `supabase-setup.md` - Setup Supabase project dan Flutter
- `auth/` - Authentication (email, magic link, OAuth)
- `database/` - PostgreSQL operations dengan RLS
- `realtime/` - Realtime subscriptions
- `storage/` - File storage
- `security/` - RLS policies dan best practices
- `examples/` - Contoh implementasi lengkap


## Prerequisites

- Project setup dari `01_project_setup.md` selesai
- Supabase account (supabase.com)
- Supabase project created
- GetX sudah terkonfigurasi di project


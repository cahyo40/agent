---
description: Integrasi Supabase sebagai alternative backend dengan flutter_bloc state management: Authentication, PostgreSQL Datab... (Part 1/8)
---
# Workflow: Supabase Integration (flutter_bloc) (Part 1/8)

> **Navigation:** This workflow is split into 8 parts.

## Overview

Integrasi Supabase sebagai alternative backend dengan flutter_bloc state management: Authentication, PostgreSQL Database, Realtime subscriptions, dan Storage. Workflow ini mencakup setup lengkap dengan Row Level Security (RLS), event-driven state management menggunakan `Bloc<Event, State>` dan `Cubit`, serta lifecycle management via `close()`.

Perbedaan utama dengan versi Riverpod:
- Tidak ada `ProviderScope` — Supabase init di `bootstrap()` sebelum `runApp()`
- Auth menggunakan `AuthBloc` dengan sealed `SupabaseAuthEvent` dan `SupabaseAuthState` (Equatable)
- Auth state change di-listen via `StreamSubscription` di bloc constructor, di-cancel di `close()`
- Database CRUD menggunakan `ProductBloc` dengan event classes per operasi dan state yang menyertakan data + pagination info
- Realtime menggunakan `RealtimeProductBloc` — `RealtimeChannel` di-subscribe di constructor, `unsubscribe()` di `close()`
- Storage menggunakan `UploadCubit` (simple state tanpa event classes)
- DI via `get_it` + `injectable` — bukan `Get.put()` dan bukan `ProviderScope`
- Navigation redirect via `GoRouter` redirect guard, bukan `Get.offAllNamed()`


## Output Location

**Base Folder:** `sdlc/flutter-bloc/05-supabase-integration/`

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
- flutter_bloc, get_it, dan injectable sudah terkonfigurasi di project


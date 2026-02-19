---
description: Integrasi Firebase services untuk Flutter dengan **flutter_bloc** sebagai state management: Authentication, Cloud Fir... (Part 1/7)
---
# Workflow: Firebase Integration (flutter_bloc) (Part 1/7)

> **Navigation:** This workflow is split into 7 parts.

## Overview

Integrasi Firebase services untuk Flutter dengan **flutter_bloc** sebagai state management: Authentication, Cloud Firestore, Firebase Storage, dan Firebase Cloud Messaging (FCM). Workflow ini mencakup setup lengkap, BLoC/Cubit patterns, dependency injection via `get_it` + `injectable`, dan best practices untuk production.

Perbedaan utama dari versi Riverpod:
- **Tidak ada `ProviderScope`** — gunakan `MultiBlocProvider` di root widget
- **Auth state** di-manage via `AuthBloc` dengan `StreamSubscription` ke `FirebaseAuth.authStateChanges()`
- **Firestore real-time** via `StreamSubscription` atau `emit.forEach()` di dalam Bloc
- **Upload progress** di-handle oleh `UploadCubit` dengan granular states
- **DI** sepenuhnya via `get_it` + `injectable`, bukan Riverpod providers


## Output Location

**Base Folder:** `sdlc/flutter-bloc/04-firebase-integration/`

**Output Files:**
- `firebase-setup.md` - Setup Firebase project dan Flutter
- `auth/` - Authentication implementation (AuthBloc, AuthRepository)
- `firestore/` - Database CRUD operations (ProductBloc, real-time streams)
- `storage/` - File upload/download (UploadCubit, progress tracking)
- `fcm/` - Push notifications (NotificationService)
- `security/` - Security rules dan best practices
- `examples/` - Contoh implementasi lengkap


## Prerequisites

- Project setup dari `01_project_setup.md` selesai (termasuk `get_it` + `injectable`)
- Firebase account (firebase.google.com)
- FlutterFire CLI terinstall
- Sudah familiar dengan BLoC pattern (events, states, bloc class)


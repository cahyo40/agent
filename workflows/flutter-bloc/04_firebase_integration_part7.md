---
description: Integrasi Firebase services untuk Flutter dengan **flutter_bloc** sebagai state management: Authentication, Cloud Fir... (Part 7/7)
---
# Workflow: Firebase Integration (flutter_bloc) (Part 7/7)

> **Navigation:** This workflow is split into 7 parts.

## Workflow Steps

1. **Setup Firebase Project**
   - Create Firebase project di console
   - Register Android & iOS apps
   - Download config files (google-services.json, GoogleService-Info.plist)
   - Install FlutterFire CLI
   - Run `flutterfire configure`

2. **Configure Dependencies**
   - Add Firebase packages ke pubspec.yaml
   - Add `flutter_bloc`, `get_it`, `injectable`
   - Initialize Firebase di `bootstrap.dart`
   - Setup `MultiBlocProvider` di root widget
   - Register Firebase instances di `get_it` module

3. **Implement Authentication**
   - Buat `AuthRepository` contract dan implementasi
   - Buat `AuthEvent` sealed class (semua event)
   - Buat `AuthState` sealed class (semua state)
   - Buat `AuthBloc` dengan `StreamSubscription` ke auth stream
   - Register `AuthBloc` di `MultiBlocProvider` root
   - Buat login/register UI dengan `BlocConsumer`
   - Setup `GoRouter` redirect berdasarkan auth state

4. **Setup Firestore**
   - Design data structure dan model
   - Buat `ProductRemoteDataSource` dan Firestore implementation
   - Buat `ProductBloc` dengan real-time stream subscription
   - Deploy security rules
   - Buat CRUD UI

5. **Configure Storage**
   - Buat `FirebaseStorageService` dengan progress callback
   - Buat `UploadState` sealed class (initial, uploading, success, error)
   - Buat `UploadCubit` untuk manage upload lifecycle
   - Setup storage security rules
   - Buat upload UI dengan progress indicator

6. **Setup FCM**
   - Buat `NotificationService` (framework-agnostic, `@lazySingleton`)
   - Configure platform-specific settings (AndroidManifest, Info.plist)
   - Setup local notifications untuk foreground messages
   - Handle notification tap + navigation via GoRouter
   - Implement token persistence ke Firestore
   - Register background message handler

7. **Test Integration**
   - Test authentication flows (email, Google, sign out)
   - Test Firestore CRUD operations + real-time updates
   - Test file upload/download + progress tracking
   - Test push notifications (foreground, background, terminated)
   - Verify security rules dengan Firebase Emulator Suite
   - Test bloc lifecycle (subscription cancel, memory leaks)


## Pola Penting: BLoC vs Cubit Decision

Kapan pakai **Bloc** (event-driven):
- Auth: banyak event berbeda (sign in, sign up, sign out, check)
- Firestore list: perlu handle stream events + CRUD events
- Complex flows dengan multiple entry points

Kapan pakai **Cubit** (method-driven):
- Upload: satu flow linear (pilih file -> upload -> selesai)
- Simple toggle/counter states
- Tidak perlu event traceability

```
Bloc  = complex events, stream subscriptions, event traceability
Cubit = simple methods, linear flows, kurang boilerplate
```


## Injectable Registration Summary

```dart
// Semua registrations yang dibutuhkan untuk Firebase integration:

// Module (external dependencies)
@module
abstract class FirebaseModule {
  @lazySingleton
  FirebaseAuth get auth => FirebaseAuth.instance;

  @lazySingleton
  FirebaseFirestore get firestore => FirebaseFirestore.instance;

  @lazySingleton
  FirebaseStorage get storage => FirebaseStorage.instance;

  @lazySingleton
  FirebaseMessaging get messaging => FirebaseMessaging.instance;

  @lazySingleton
  GoogleSignIn get googleSignIn => GoogleSignIn();

  @lazySingleton
  FlutterLocalNotificationsPlugin get localNotifications =>
      FlutterLocalNotificationsPlugin();
}

// Repositories (auto-registered via @LazySingleton annotation pada class)
// - AuthRepositoryImpl -> AuthRepository
// - ProductRepositoryImpl -> ProductRepository

// Services (auto-registered via @lazySingleton annotation pada class)
// - FirebaseStorageService
// - NotificationService
// - FcmTokenRepository

// Blocs (auto-registered via @injectable annotation pada class)
// - AuthBloc
// - ProductBloc

// Cubits (auto-registered via @injectable annotation pada class)
// - UploadCubit

// Jalankan: dart run build_runner build --delete-conflicting-outputs
```


## Success Criteria

- [ ] Firebase project configured untuk semua platforms
- [ ] `MultiBlocProvider` di root widget menyediakan `AuthBloc`
- [ ] Authentication berfungsi (email/password & Google Sign-In)
- [ ] Auth state stream di-listen via `StreamSubscription` di `AuthBloc`
- [ ] `AuthBloc.close()` properly cancel subscription
- [ ] GoRouter redirect berdasarkan `AuthBloc` state
- [ ] Firestore CRUD operations berfungsi via `ProductBloc`
- [ ] Real-time updates dengan Firestore stream berfungsi
- [ ] `ProductBloc` handle stream subscription lifecycle dengan benar
- [ ] Security rules configured dan tested
- [ ] File upload dengan progress tracking berfungsi via `UploadCubit`
- [ ] `UploadCubit` cek `isClosed` sebelum emit progress
- [ ] Push notifications received di foreground & background
- [ ] Local notifications displayed correctly (foreground)
- [ ] Notification tap navigate ke route yang benar
- [ ] FCM token disimpan ke Firestore
- [ ] Semua dependencies registered di `get_it` via `injectable`
- [ ] Offline persistence enabled untuk Firestore


## Security Best Practices

### Firestore Rules (Lengkap)
```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    function isAuthenticated() {
      return request.auth != null;
    }

    function isOwner(userId) {
      return request.auth.uid == userId;
    }

    function isValidString(field, maxLength) {
      return field is string && field.size() > 0 && field.size() <= maxLength;
    }

    function isValidPrice(price) {
      return price is number && price >= 0 && price <= 999999999;
    }

    // Products collection
    match /products/{productId} {
      allow read: if isAuthenticated();
      allow create: if isAuthenticated()
        && isValidString(request.resource.data.name, 100)
        && isValidPrice(request.resource.data.price);
      allow update: if isAuthenticated()
        && isOwner(resource.data.ownerId);
      allow delete: if isAuthenticated()
        && isOwner(resource.data.ownerId);
    }

    // Users collection
    match /users/{userId} {
      allow read: if isAuthenticated() && isOwner(userId);
      allow write: if isAuthenticated() && isOwner(userId);
    }
  }
}
```

### Storage Rules
```
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /profile_images/{userId}/{allPaths=**} {
      allow read: if request.auth != null;
      allow write: if request.auth != null
        && request.auth.uid == userId
        && request.resource.size < 5 * 1024 * 1024
        && request.resource.contentType.matches('image/.*');
    }

    match /product_images/{allPaths=**} {
      allow read: if request.auth != null;
      allow write: if request.auth != null
        && request.resource.size < 10 * 1024 * 1024
        && request.resource.contentType.matches('image/.*');
    }
  }
}
```


## Next Steps

Setelah Firebase integration selesai:
1. Add comprehensive testing dengan Firebase Emulator Suite
2. Setup Firebase Analytics untuk tracking user behavior
3. Add Firebase Crashlytics untuk crash reporting
4. Implement Firebase Remote Config untuk feature flags
5. Explore Firebase App Check untuk API security
6. Consider Supabase sebagai alternative backend

---
description: Integrasi Firebase services untuk Flutter dengan GetX state management: Authentication, Cloud Firestore, Firebase Sto... (Part 7/7)
---
# Workflow: Firebase Integration (GetX) (Part 7/7)

> **Navigation:** This workflow is split into 7 parts.

## Workflow Steps

1. **Setup Firebase Project**
   - Create Firebase project di console.firebase.google.com
   - Register Android & iOS apps
   - Download config files (google-services.json, GoogleService-Info.plist)
   - Install FlutterFire CLI
   - Run `flutterfire configure`

2. **Configure Dependencies**
   - Add Firebase packages ke pubspec.yaml
   - Initialize Firebase di `main.dart` sebelum `runApp()`
   - Register services ke GetX DI dengan `Get.putAsync()`
   - Setup `InitialBinding` untuk auth controller

3. **Implement Authentication**
   - Setup `AuthRepository` (domain layer - framework agnostic)
   - Implement `AuthRepositoryImpl` dengan Firebase Auth
   - Create `AuthController extends GetxController` dengan reactive state
   - Setup `AuthMiddleware` untuk route guard
   - Test login, register, dan logout flow

4. **Setup Firestore**
   - Design data structure dan collection schema
   - Create Firestore security rules
   - Implement data source dan repository layer
   - Create `ProductController` dengan `bindStream()` untuk real-time updates
   - Setup `ProductBinding` untuk DI per-page

5. **Configure Storage**
   - Setup Firebase Storage rules (size limit, content type)
   - Implement `FirebaseStorageService` (framework-agnostic)
   - Create `UploadController` dengan `RxDouble uploadProgress`
   - Add image compression sebelum upload
   - Handle download URLs dan cache

6. **Setup FCM**
   - Configure platform-specific settings (AndroidManifest, AppDelegate)
   - Implement `FCMService extends GetxService`
   - Setup foreground message handler dengan local notifications
   - Setup background handler (top-level function)
   - Implement `Get.toNamed()` untuk navigation dari notifikasi
   - Subscribe ke topics sesuai kebutuhan

7. **Test Integration**
   - Test authentication flows (login, register, logout, Google sign-in)
   - Test Firestore CRUD operations dan real-time stream
   - Test file upload/download dengan progress tracking
   - Test push notifications (foreground, background, terminated)
   - Verify security rules di Firebase console
   - Test offline persistence


## Success Criteria

- [ ] Firebase project configured untuk semua platforms (Android, iOS)
- [ ] `main.dart` menggunakan `Get.putAsync()` untuk service registration
- [ ] Authentication berfungsi (email/password & Google Sign-In)
- [ ] `AuthController extends GetxController` dengan `.obs` reactive state
- [ ] Auth state stream ter-listen via `onInit()` dan `ever()`
- [ ] Auth middleware redirect berfungsi dengan `Get.offAllNamed()`
- [ ] Firestore CRUD operations berfungsi via repository pattern
- [ ] Real-time updates dengan `bindStream()` berfungsi
- [ ] Firestore security rules configured dan tested
- [ ] File upload dengan `RxDouble uploadProgress` tracking berfungsi
- [ ] Image compression sebelum upload implemented
- [ ] Storage security rules (size limit, content type) configured
- [ ] `FCMService extends GetxService` persistent selama app lifecycle
- [ ] Push notifications received di foreground & background
- [ ] Local notifications displayed correctly
- [ ] Notification tap navigasi dengan `Get.toNamed()` berfungsi
- [ ] Background message handler sebagai top-level function
- [ ] Offline persistence enabled untuk Firestore
- [ ] No memory leaks - stream subscriptions di-cancel di `onClose()`


## Security Best Practices

### Firestore Rules
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

    // Products collection
    match /products/{productId} {
      allow read: if isAuthenticated();
      allow create: if isAuthenticated()
        && isValidString(request.resource.data.name, 100)
        && request.resource.data.price is number
        && request.resource.data.price >= 0;
      allow update: if isAuthenticated() && isOwner(resource.data.ownerId);
      allow delete: if isAuthenticated() && isOwner(resource.data.ownerId);
    }

    // Users collection - private
    match /users/{userId} {
      allow read: if isAuthenticated() && isOwner(userId);
      allow write: if isAuthenticated() && isOwner(userId);

      // Notifications subcollection
      match /notifications/{notificationId} {
        allow read: if isAuthenticated() && isOwner(userId);
        allow update: if isAuthenticated() && isOwner(userId);
        // Hanya server/Cloud Functions yang boleh create notification
        allow create: if false;
        allow delete: if isAuthenticated() && isOwner(userId);
      }
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

    match /product_images/{productId}/{allPaths=**} {
      allow read: if request.auth != null;
      allow write: if request.auth != null
        && request.resource.size < 10 * 1024 * 1024
        && request.resource.contentType.matches('image/.*');
    }
  }
}
```

### Code-Level Security
- Jangan hardcode API keys - gunakan `firebase_options.dart` yang auto-generated
- Gunakan `Either<Failure, T>` untuk error handling yang explicit
- Validate input di client-side DAN server-side (security rules)
- Cancel stream subscriptions di `onClose()` untuk menghindari memory leaks
- Jangan log sensitive data (token, credentials) di production
- Gunakan `Get.putAsync()` untuk async service initialization agar tidak race condition
- FCM token harus di-refresh dan disimpan ke server secara berkala


## Next Steps

Setelah Firebase integration selesai:
1. Implement Firebase Emulator Suite untuk local development dan testing
2. Add Firebase Analytics untuk tracking user behavior
3. Setup Firebase Crashlytics untuk crash reporting
4. Implement Firebase Remote Config untuk feature flags
5. Add Firebase App Check untuk API security
6. Setup Cloud Functions untuk server-side logic (notification triggers, data validation)
7. Implement Firebase Performance Monitoring
8. Lanjut ke `05_api_integration.md` untuk REST API integration

---
description: Integrasi Firebase services untuk Flutter: Authentication, Cloud Firestore, Firebase Storage, dan Firebase Cloud Mess... (Part 4/4)
---
# Workflow: Firebase Integration (Part 4/4)

> **Navigation:** This workflow is split into 4 parts.

## Workflow Steps

1. **Setup Firebase Project**
   - Create Firebase project di console
   - Register Android & iOS apps
   - Download config files (google-services.json, GoogleService-Info.plist)
   - Install FlutterFire CLI
   - Run `flutterfire configure`

2. **Configure Dependencies**
   - Add Firebase packages ke pubspec.yaml
   - Initialize Firebase di main.dart
   - Setup platform-specific config (AndroidManifest, AppDelegate)

3. **Implement Authentication**
   - Setup Firebase Auth
   - Implement email/password login
   - Add Google Sign-In
   - Create auth repository dan controller

4. **Setup Firestore**
   - Design data structure
   - Create security rules
   - Implement CRUD operations
   - Setup real-time streams

5. **Configure Storage**
   - Setup Firebase Storage rules
   - Implement file upload dengan progress
   - Add image compression
   - Handle download URLs

6. **Setup FCM**
   - Configure push notifications
   - Request permissions
   - Handle foreground/background messages
   - Setup local notifications

7. **Test Integration**
   - Test authentication flows
   - Test Firestore operations
   - Test file upload/download
   - Test push notifications
   - Verify security rules


## Success Criteria

- [ ] Firebase project configured untuk semua platforms
- [ ] Authentication berfungsi (email/password & Google)
- [ ] Auth state stream implemented
- [ ] Firestore CRUD operations berfungsi
- [ ] Real-time updates dengan streams berfungsi
- [ ] Security rules configured dan tested
- [ ] File upload dengan progress tracking berfungsi
- [ ] Push notifications received di foreground & background
- [ ] Local notifications displayed correctly
- [ ] Offline persistence enabled


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
    
    // Always validate data
    match /products/{productId} {
      allow read: if isAuthenticated();
      allow create: if isAuthenticated() 
        && isValidString(request.resource.data.name, 100)
        && request.resource.data.price is number
        && request.resource.data.price >= 0;
      allow update: if isAuthenticated() && isOwner(resource.data.ownerId);
      allow delete: if isAuthenticated() && isOwner(resource.data.ownerId);
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
      allow write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```


## Next Steps

Setelah Firebase integration selesai:
1. Add Supabase integration untuk alternative backend
2. Implement comprehensive testing dengan Firebase emulators
3. Setup analytics tracking (Firebase Analytics)
4. Add crash reporting (Firebase Crashlytics)
5. Implement remote config (Firebase Remote Config)

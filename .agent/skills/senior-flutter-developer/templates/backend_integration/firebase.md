# Flutter Firebase Integration

## Overview

Production-grade Firebase integration for Flutter including Authentication, Firestore, Cloud Functions, Storage, FCM, and Crashlytics.

## When to Use

- Building Flutter apps with Firebase backend
- Implementing authentication (Email, Google, Apple, Phone)
- Real-time database with offline support
- Push notifications (FCM)
- Monitoring (Crashlytics, Analytics, Performance)

---

## Project Structure

```text
lib/
├── core/
│   ├── config/
│   │   ├── firebase_config.dart      # Firebase initialization
│   │   └── environment.dart
│   ├── error/
│   │   ├── exceptions.dart
│   │   └── failures.dart
│   └── utils/
│       └── result.dart               # Result/Either type
├── features/
│   └── auth/
│       ├── data/
│       │   ├── datasources/
│       │   ├── models/
│       │   └── repositories/
│       ├── domain/
│       │   ├── entities/
│       │   ├── repositories/
│       │   └── usecases/
│       └── presentation/
```

---

## Firebase Initialization

```dart
class FirebaseConfig {
  static late FirebaseAnalytics analytics;
  static late FirebasePerformance performance;
  
  static Future<void> initialize() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    
    // Crashlytics setup
    await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(!kDebugMode);
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
    
    // Analytics setup
    analytics = FirebaseAnalytics.instance;
    await analytics.setAnalyticsCollectionEnabled(!kDebugMode);
    
    // Firestore settings
    FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );
  }
  
  static Future<void> setUser(String userId) async {
    await FirebaseCrashlytics.instance.setUserIdentifier(userId);
    await analytics.setUserId(id: userId);
  }
}
```

---

## Authentication Repository

```dart
abstract class AuthRepository {
  Stream<UserEntity?> get authStateChanges;
  UserEntity? get currentUser;
  
  Future<Result<UserEntity>> signInWithEmail({
    required String email,
    required String password,
  });
  
  Future<Result<UserEntity>> signInWithGoogle();
  Future<Result<UserEntity>> signInWithApple();
  Future<Result<void>> signOut();
  Future<Result<void>> deleteAccount();
}

// Implementation
class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuth _auth;
  final GoogleSignIn _googleSignIn;
  final FirebaseFirestore _firestore;
  
  @override
  Future<Result<UserEntity>> signInWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return const Result.failure(AuthFailure(message: 'Sign in cancelled'));
      }

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      await _createOrUpdateUserProfile(userCredential.user!);
      
      return Result.success(UserEntity.fromFirebaseUser(userCredential.user!));
    } on FirebaseAuthException catch (e) {
      return Result.failure(_mapFirebaseAuthError(e));
    }
  }
  
  AuthFailure _mapFirebaseAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return const AuthFailure(message: 'No account found');
      case 'wrong-password':
        return const AuthFailure(message: 'Incorrect password');
      case 'email-already-in-use':
        return const AuthFailure(message: 'Email already registered');
      default:
        return AuthFailure(message: e.message ?? 'Authentication failed');
    }
  }
}
```

---

## Firestore Base Repository

```dart
abstract class BaseFirestoreRepository<T> {
  final FirebaseFirestore firestore;
  final String collectionPath;
  final Map<String, T> _cache = {};

  CollectionReference<Map<String, dynamic>> get collection =>
      firestore.collection(collectionPath);

  T fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc);
  Map<String, dynamic> toFirestore(T entity);

  Future<Result<T?>> getById(String id) async {
    try {
      if (_cache.containsKey(id)) return Result.success(_cache[id]);
      
      final doc = await collection.doc(id).get();
      if (!doc.exists) return const Result.success(null);
      
      final entity = fromFirestore(doc);
      _cache[id] = entity;
      return Result.success(entity);
    } on FirebaseException catch (e) {
      return Result.failure(ServerFailure(message: e.message ?? 'Failed'));
    }
  }

  Stream<T?> watchById(String id) {
    return collection.doc(id).snapshots().map((doc) {
      if (!doc.exists) return null;
      final entity = fromFirestore(doc);
      _cache[id] = entity;
      return entity;
    });
  }

  Future<Result<PaginatedResult<T>>> getPaginated({
    Query? query,
    DocumentSnapshot? startAfter,
    int limit = 20,
  }) async {
    try {
      Query q = query ?? collection;
      q = q.limit(limit + 1);
      if (startAfter != null) q = q.startAfterDocument(startAfter);

      final snapshot = await q.get();
      final docs = snapshot.docs;
      final hasMore = docs.length > limit;
      final items = docs.take(limit).map(fromFirestore).toList();

      return Result.success(PaginatedResult(
        items: items,
        hasMore: hasMore,
        lastDocument: docs.isNotEmpty ? docs.last : null,
      ));
    } on FirebaseException catch (e) {
      return Result.failure(ServerFailure(message: e.message ?? 'Query failed'));
    }
  }
}
```

---

## FCM Service

```dart
class FCMService {
  final FirebaseMessaging _messaging;
  
  Future<void> initialize() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      final token = await _messaging.getToken();
      if (token != null) await _saveToken(token);
      
      _messaging.onTokenRefresh.listen(_saveToken);
      _setupMessageHandlers();
    }
  }

  void _setupMessageHandlers() {
    FirebaseMessaging.onMessage.listen((message) {
      // Handle foreground message
    });

    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      // Handle message opened app
    });
  }

  Future<void> subscribeToTopic(String topic) async {
    await _messaging.subscribeToTopic(topic);
  }
}
```

---

## Security Rules

### Firestore

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    function isAuthenticated() {
      return request.auth != null;
    }
    
    function isOwner(userId) {
      return request.auth.uid == userId;
    }
    
    match /users/{userId} {
      allow read: if isAuthenticated() && isOwner(userId);
      allow create: if isAuthenticated() && isOwner(userId);
      allow update: if isAuthenticated() && isOwner(userId);
    }
    
    match /products/{productId} {
      allow read: if true;
      allow write: if false; // Admin only via Cloud Functions
    }
  }
}
```

### Storage

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /profiles/{userId}/{fileName} {
      allow read: if request.auth != null;
      allow write: if request.auth.uid == userId &&
                     request.resource.contentType.matches('image/.*') &&
                     request.resource.size < 5 * 1024 * 1024;
    }
  }
}
```

---

## Best Practices

### ✅ Do This

- ✅ Use Clean Architecture with repository pattern
- ✅ Implement Result/Either for error handling
- ✅ Abstract Firebase behind interfaces
- ✅ Enable offline persistence
- ✅ Use cursor-based pagination
- ✅ Implement security rules
- ✅ Log user ID in Crashlytics

### ❌ Avoid This

- ❌ Don't store large objects in Firestore (use Storage)
- ❌ Don't make unlimited queries
- ❌ Don't skip security rules in production
- ❌ Don't handle errors silently

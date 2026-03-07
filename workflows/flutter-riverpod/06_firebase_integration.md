---
description: Integrasi Firebase services untuk Flutter — Authentication, Cloud Firestore, Firebase Storage, dan FCM.
---
# Workflow: Firebase Integration

// turbo-all

## Overview

Integrasi Firebase services untuk Flutter: Authentication, Cloud Firestore,
Firebase Storage, dan Firebase Cloud Messaging (FCM). Mencakup setup lengkap
dan best practices.


## Prerequisites

- Project setup dari `01_project_setup.md` selesai
- Firebase account (firebase.google.com)
- FlutterFire CLI terinstall


## Agent Behavior

- **Auto-setup FlutterFire CLI** jika belum terinstall.
- **Jangan hardcode Firebase config** — gunakan `flutterfire configure`.
- **Selalu setup security rules** — jangan biarkan open access di production.
- **Test di emulator dulu** sebelum deploy ke production.


## Recommended Skills

- `senior-firebase-developer` — Firebase services
- `senior-flutter-developer` — Flutter patterns
- `python-async-specialist` — Concurrency & Parallelism (Dart isolates equivalent)


## Workflow Steps

### Step 1: Firebase Project Setup

1. **Install FlutterFire CLI:**
   ```bash
   dart pub global activate flutterfire_cli
   ```

2. **Configure Firebase:**
   ```bash
   flutterfire configure
   ```

3. **Add Dependencies:**
   ```yaml
   dependencies:
     firebase_core: ^3.12.0
     firebase_auth: ^5.5.0
     cloud_firestore: ^5.6.0
     firebase_storage: ^12.4.0
     firebase_messaging: ^15.2.0
   ```

4. **Initialize Firebase:**
   ```dart
   // bootstrap/bootstrap.dart
   import 'package:firebase_core/firebase_core.dart';
   import 'firebase_options.dart';

   Future<void> bootstrap() async {
     WidgetsFlutterBinding.ensureInitialized();

     await Firebase.initializeApp(
       options:
           DefaultFirebaseOptions.currentPlatform,
     );

     runApp(
       const ProviderScope(child: MyApp()),
     );
   }
   ```

### Step 2: Firebase Authentication

```dart
// features/auth/domain/repositories/auth_repository.dart
abstract class AuthRepository {
  Stream<User?> get authStateChanges;
  Future<Result<User>>
      signInWithEmailAndPassword(
    String email,
    String password,
  );
  Future<Result<User>>
      signInWithGoogle();
  Future<Result<User>> signUp(
    String email,
    String password,
  );
  Future<Result<void>> signOut();
  User? get currentUser;
}

// features/auth/data/repositories/auth_repository_impl.dart
class AuthRepositoryImpl
    implements AuthRepository {
  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;

  AuthRepositoryImpl({
    FirebaseAuth? firebaseAuth,
    GoogleSignIn? googleSignIn,
  })  : _firebaseAuth =
            firebaseAuth ?? FirebaseAuth.instance,
        _googleSignIn =
            googleSignIn ?? GoogleSignIn();

  @override
  Stream<User?> get authStateChanges =>
      _firebaseAuth.authStateChanges();

  @override
  Future<Result<User>>
      signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      final result = await _firebaseAuth
          .signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (result.user == null) {
        return const Err(
          AuthFailure('User not found'),
        );
      }

      return Success(result.user!);
    } on FirebaseAuthException catch (e) {
      return Err(_mapAuthError(e));
    }
  }

  @override
  Future<Result<User>>
      signInWithGoogle() async {
    try {
      final googleUser =
          await _googleSignIn.signIn();
      if (googleUser == null) {
        return const Err(
          AuthFailure('Google sign-in cancelled'),
        );
      }

      final googleAuth =
          await googleUser.authentication;
      final credential =
          GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final result = await _firebaseAuth
          .signInWithCredential(credential);

      if (result.user == null) {
        return const Err(
          AuthFailure('Failed to sign in'),
        );
      }

      return Success(result.user!);
    } on FirebaseAuthException catch (e) {
      return Err(_mapAuthError(e));
    }
  }

  @override
  Future<Result<void>> signOut() async {
    try {
      await Future.wait([
        _firebaseAuth.signOut(),
        _googleSignIn.signOut(),
      ]);
      return const Success(null);
    } on FirebaseAuthException catch (e) {
      return Err(_mapAuthError(e));
    }
  }

  Failure _mapAuthError(
    FirebaseAuthException e,
  ) {
    switch (e.code) {
      case 'user-not-found':
        return const AuthFailure(
          'No user found with this email',
        );
      case 'wrong-password':
        return const AuthFailure(
          'Incorrect password',
        );
      case 'email-already-in-use':
        return const AuthFailure(
          'Email is already registered',
        );
      default:
        return AuthFailure(
          e.message ?? 'Authentication error',
        );
    }
  }
}

// features/auth/presentation/controllers/auth_controller.dart
@riverpod
class AuthController extends _$AuthController {
  @override
  Stream<User?> build() {
    final repository =
        ref.watch(authRepositoryProvider);
    return repository.authStateChanges;
  }

  Future<void> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository =
          ref.read(authRepositoryProvider);
      final result = await repository
          .signInWithEmailAndPassword(
        email,
        password,
      );
      return result.fold(
        (failure) => throw failure,
        (user) => user,
      );
    });
  }

  Future<void> signOut() async {
    final repository =
        ref.read(authRepositoryProvider);
    await repository.signOut();
  }
}
```

### Step 3: Cloud Firestore CRUD

```dart
// features/product/data/datasources/product_firestore_ds.dart
class ProductFirestoreDataSource
    implements ProductRemoteDataSource {
  final FirebaseFirestore _firestore;

  ProductFirestoreDataSource({
    FirebaseFirestore? firestore,
  }) : _firestore =
            firestore ?? FirebaseFirestore.instance;

  CollectionReference get _productsCollection =>
      _firestore.collection('products');

  @override
  Stream<List<ProductModel>> getProducts() {
    return _productsCollection
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ProductModel.fromJson(
                  doc.data() as Map<String, dynamic>,
                ).copyWith(id: doc.id))
            .toList());
  }

  @override
  Future<ProductModel> createProduct(
    ProductModel product,
  ) async {
    final docRef =
        await _productsCollection.add({
      'name': product.name,
      'price': product.price,
      'description': product.description,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    return product.copyWith(id: docRef.id);
  }

  @override
  Future<ProductModel> updateProduct(
    ProductModel product,
  ) async {
    await _productsCollection
        .doc(product.id)
        .update({
      'name': product.name,
      'price': product.price,
      'description': product.description,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    return product;
  }

  @override
  Future<void> deleteProduct(String id) async {
    await _productsCollection.doc(id).delete();
  }
}
```

### Step 4: Firebase Storage

```dart
// core/storage/firebase_storage_service.dart
class FirebaseStorageService {
  final FirebaseStorage _storage;

  FirebaseStorageService({
    FirebaseStorage? storage,
  }) : _storage =
            storage ?? FirebaseStorage.instance;

  Future<Result<String>> uploadFile({
    required File file,
    required String path,
    void Function(double progress)? onProgress,
  }) async {
    try {
      final ref = _storage.ref().child(path);
      final uploadTask = ref.putFile(file);

      uploadTask.snapshotEvents.listen(
        (TaskSnapshot snapshot) {
          final progress =
              snapshot.bytesTransferred /
                  snapshot.totalBytes;
          onProgress?.call(progress);
        },
      );

      await uploadTask;
      final downloadUrl =
          await ref.getDownloadURL();

      return Success(downloadUrl);
    } on FirebaseException catch (e) {
      return Err(
        StorageFailure(
          e.message ?? 'Upload failed',
        ),
      );
    }
  }

  Future<Result<void>> deleteFile(
    String url,
  ) async {
    try {
      final ref = _storage.refFromURL(url);
      await ref.delete();
      return const Success(null);
    } on FirebaseException catch (e) {
      return Err(
        StorageFailure(
          e.message ?? 'Delete failed',
        ),
      );
    }
  }
}
```

### Step 5: Firebase Cloud Messaging (FCM)

```dart
// core/notifications/fcm_service.dart
class FCMService {
  final FirebaseMessaging _messaging;
  final FlutterLocalNotificationsPlugin
      _localNotifications;

  FCMService({
    FirebaseMessaging? messaging,
    FlutterLocalNotificationsPlugin?
        localNotifications,
  })  : _messaging =
            messaging ?? FirebaseMessaging.instance,
        _localNotifications =
            localNotifications ??
                FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    await _requestPermissions();
    await _initializeLocalNotifications();

    FirebaseMessaging.onMessage
        .listen(_handleForegroundMessage);
    FirebaseMessaging.onMessageOpenedApp
        .listen(_handleNotificationTap);

    final initialMessage =
        await _messaging.getInitialMessage();
    if (initialMessage != null) {
      _handleNotificationTap(initialMessage);
    }

    final token = await _messaging.getToken();
    print('FCM Token: $token');
  }

  Future<void> _requestPermissions() async {
    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  Future<void>
      _initializeLocalNotifications() async {
    const androidSettings =
        AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosSettings =
        DarwinInitializationSettings();

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse:
          (details) {},
    );
  }

  void _handleForegroundMessage(
    RemoteMessage message,
  ) {
    final notification = message.notification;
    if (notification != null) {
      _showLocalNotification(
        title:
            notification.title ?? 'New Notification',
        body: notification.body ?? '',
        payload: message.data.toString(),
      );
    }
  }

  void _handleNotificationTap(
    RemoteMessage message,
  ) {
    final data = message.data;
    final route = data['route'];
    if (route != null) {
      // Use GoRouter to navigate
    }
  }

  Future<void> _showLocalNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    const androidDetails =
        AndroidNotificationDetails(
      'default_channel',
      'Default Channel',
      importance: Importance.max,
      priority: Priority.high,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(),
    );

    await _localNotifications.show(
      DateTime.now().millisecond,
      title,
      body,
      details,
      payload: payload,
    );
  }

  Future<String?> getToken() =>
      _messaging.getToken();
  Stream<String> get onTokenRefresh =>
      _messaging.onTokenRefresh;
}

// Background handler (top-level function)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(
  RemoteMessage message,
) async {
  await Firebase.initializeApp();
}
```

### Step 6: Security Rules

#### Firestore Rules
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
      return field is string
          && field.size() > 0
          && field.size() <= maxLength;
    }

    match /products/{productId} {
      allow read: if isAuthenticated();
      allow create: if isAuthenticated()
        && isValidString(
             request.resource.data.name, 100)
        && request.resource.data.price is number
        && request.resource.data.price >= 0;
      allow update: if isAuthenticated()
        && isOwner(resource.data.ownerId);
      allow delete: if isAuthenticated()
        && isOwner(resource.data.ownerId);
    }

    match /users/{userId} {
      allow read: if isAuthenticated()
          && isOwner(userId);
      allow write: if isAuthenticated()
          && isOwner(userId);
    }
  }
}
```

#### Storage Rules
```
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /profile_images/{userId}/{allPaths=**} {
      allow read: if request.auth != null;
      allow write: if request.auth != null
          && request.auth.uid == userId;
    }
}
```

### Step 7: Isolate Parsing & Background Sync

Jika listener Firestore (`snapshots()`) mengembalikan ribuan dokumen yang merombak UI thread, gunakan `Isolate.run()` untuk memproses mapping JSON/Map ke Entity.

```dart
// Untuk single future read berukuran masif
Future<List<ProductModel>> getMassiveProducts() async {
  final snapshot = await _productsCollection.limit(10000).get();
  
  // Karena snapshot.docs binding ke native plugin, 
  // kita ekstrak datanya dulu ke List<Map> polos sebelum dilempar ke Isolate
  final rawData = snapshot.docs.map((doc) => {
    'id': doc.id,
    ...doc.data() as Map<String, dynamic>
  }).toList();

  return await Isolate.run(() {
    return rawData.map((data) => ProductModel.fromJson(data)).toList();
  });
}
```

Untuk menjadwalkan background sync (misal Firebase offline persistence tidak cukup, atau perlu sinkronisasi hybrid backend):

```yaml
dependencies:
  workmanager: ^0.5.2
```

```dart
// lib/bootstrap/background_worker.dart
import 'package:workmanager/workmanager.dart';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    switch (task) {
      case 'syncFirebaseTask':
        // Background sync logic
        break;
    }
    return Future.value(true);
  });
}
```

### Step 8: Test Integration

- Test authentication flows
- Test Firestore operations
- Test file upload/download
- Test push notifications
- Verify security rules
- Test background processing (Isolate dan periodic sync)


## Success Criteria

- [ ] Firebase project configured untuk semua platforms
- [ ] Authentication berfungsi (email/password & Google)
- [ ] Auth state stream implemented
- [ ] Firestore CRUD operations berfungsi
- [ ] Real-time updates dengan streams berfungsi
- [ ] Security rules configured dan tested
- [ ] File upload dengan progress tracking berfungsi
- [ ] Push notifications received (foreground & background)
- [ ] Local notifications displayed correctly
- [ ] Offline persistence enabled
- [ ] Heavy Firestore query diparsing memakai `Isolate.run()` tanpa UI freeze


## Next Steps

Setelah Firebase integration selesai:
1. Add Supabase integration untuk alternative backend
2. Implement comprehensive testing dengan Firebase emulators
3. Setup analytics tracking (Firebase Analytics)
4. Add crash reporting (Firebase Crashlytics)
5. Implement remote config (Firebase Remote Config)

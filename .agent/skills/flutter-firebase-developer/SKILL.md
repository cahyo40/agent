---
name: flutter-firebase-developer
description: "Expert Flutter Firebase integration including Authentication, Firestore, Cloud Functions, Storage, FCM, and Crashlytics"
---

# Flutter Firebase Developer

## Overview

Skill ini menjadikan AI Agent Anda sebagai spesialis integrasi Firebase di Flutter. Agent akan mampu mengimplementasikan Authentication (Email, Google, Apple), Firestore database dengan real-time sync, Cloud Storage, Push Notifications (FCM), Cloud Functions, dan monitoring dengan Crashlytics—semua dengan best practices untuk production.

## When to Use This Skill

- Use when building Flutter apps with Firebase backend
- Use when implementing social login (Google, Apple, Facebook)
- Use when needing real-time database synchronization
- Use when the user asks about Firebase, Firestore, or FCM
- Use when setting up push notifications or analytics

## How It Works

### Step 1: Project Setup

```bash
# Install FlutterFire CLI
dart pub global activate flutterfire_cli

# Configure Firebase (run in project root)
flutterfire configure

# This generates firebase_options.dart
```

#### Dependencies

```yaml
# pubspec.yaml
dependencies:
  firebase_core: ^3.8.0
  firebase_auth: ^5.3.3
  cloud_firestore: ^5.5.0
  firebase_storage: ^12.3.6
  firebase_messaging: ^15.1.5
  firebase_crashlytics: ^4.2.0
  firebase_analytics: ^11.3.5
  google_sign_in: ^6.2.2
```

#### Initialize Firebase

```dart
// main.dart
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Optional: Enable Crashlytics
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
  
  runApp(const MyApp());
}
```

### Step 2: Firebase Authentication

#### 2.1 Auth Repository

```dart
class FirebaseAuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  
  // Current user stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();
  
  User? get currentUser => _auth.currentUser;
  
  // Email/Password Sign Up
  Future<UserCredential> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    return await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }
  
  // Email/Password Sign In
  Future<UserCredential> signInWithEmail({
    required String email,
    required String password,
  }) async {
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }
  
  // Google Sign In
  Future<UserCredential?> signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
    if (googleUser == null) return null;
    
    final GoogleSignInAuthentication googleAuth = 
        await googleUser.authentication;
    
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    
    return await _auth.signInWithCredential(credential);
  }
  
  // Sign Out
  Future<void> signOut() async {
    await Future.wait([
      _auth.signOut(),
      _googleSignIn.signOut(),
    ]);
  }
  
  // Password Reset
  Future<void> sendPasswordResetEmail(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }
}
```

### Step 3: Cloud Firestore

#### 3.1 Data Model with Serialization

```dart
import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String name;
  final String email;
  final DateTime createdAt;
  final DateTime? updatedAt;
  
  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.createdAt,
    this.updatedAt,
  });
  
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      id: doc.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: data['updatedAt'] != null 
          ? (data['updatedAt'] as Timestamp).toDate() 
          : null,
    );
  }
  
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'email': email,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null 
          ? Timestamp.fromDate(updatedAt!) 
          : FieldValue.serverTimestamp(),
    };
  }
}
```

#### 3.2 Firestore Repository

```dart
class UserRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  CollectionReference<Map<String, dynamic>> get _usersRef =>
      _firestore.collection('users');
  
  // Create
  Future<void> createUser(UserModel user) async {
    await _usersRef.doc(user.id).set(user.toFirestore());
  }
  
  // Read (single)
  Future<UserModel?> getUser(String id) async {
    final doc = await _usersRef.doc(id).get();
    if (!doc.exists) return null;
    return UserModel.fromFirestore(doc);
  }
  
  // Read (stream for real-time)
  Stream<UserModel?> watchUser(String id) {
    return _usersRef.doc(id).snapshots().map((doc) {
      if (!doc.exists) return null;
      return UserModel.fromFirestore(doc);
    });
  }
  
  // Read (list with query)
  Future<List<UserModel>> getUsers({
    String? nameStartsWith,
    int limit = 20,
  }) async {
    Query<Map<String, dynamic>> query = _usersRef;
    
    if (nameStartsWith != null) {
      query = query
          .orderBy('name')
          .startAt([nameStartsWith])
          .endAt(['$nameStartsWith\uf8ff']);
    }
    
    final snapshot = await query.limit(limit).get();
    return snapshot.docs.map(UserModel.fromFirestore).toList();
  }
  
  // Update
  Future<void> updateUser(String id, Map<String, dynamic> data) async {
    await _usersRef.doc(id).update({
      ...data,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
  
  // Delete
  Future<void> deleteUser(String id) async {
    await _usersRef.doc(id).delete();
  }
  
  // Batch Write
  Future<void> batchUpdateUsers(List<UserModel> users) async {
    final batch = _firestore.batch();
    for (final user in users) {
      batch.update(_usersRef.doc(user.id), user.toFirestore());
    }
    await batch.commit();
  }
  
  // Transaction
  Future<void> transferCredits({
    required String fromUserId,
    required String toUserId,
    required int amount,
  }) async {
    await _firestore.runTransaction((transaction) async {
      final fromDoc = await transaction.get(_usersRef.doc(fromUserId));
      final toDoc = await transaction.get(_usersRef.doc(toUserId));
      
      final fromCredits = fromDoc.data()?['credits'] as int? ?? 0;
      final toCredits = toDoc.data()?['credits'] as int? ?? 0;
      
      if (fromCredits < amount) {
        throw Exception('Insufficient credits');
      }
      
      transaction.update(_usersRef.doc(fromUserId), {
        'credits': fromCredits - amount,
      });
      transaction.update(_usersRef.doc(toUserId), {
        'credits': toCredits + amount,
      });
    });
  }
}
```

### Step 4: Firebase Cloud Messaging (FCM)

```dart
class FCMService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  
  Future<void> initialize() async {
    // Request permission (iOS)
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    
    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      // Get FCM token
      final token = await _messaging.getToken();
      print('FCM Token: $token');
      
      // Save token to Firestore for server-side sending
      await _saveTokenToFirestore(token);
      
      // Listen to token refresh
      _messaging.onTokenRefresh.listen(_saveTokenToFirestore);
      
      // Handle foreground messages
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
      
      // Handle background/terminated messages
      FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);
    }
  }
  
  void _handleForegroundMessage(RemoteMessage message) {
    // Show local notification or update UI
    print('Foreground message: ${message.notification?.title}');
  }
  
  void _handleMessageOpenedApp(RemoteMessage message) {
    // Navigate based on message data
    final route = message.data['route'];
    if (route != null) {
      // Navigate to route
    }
  }
  
  Future<void> _saveTokenToFirestore(String? token) async {
    if (token == null) return;
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;
    
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .update({'fcmToken': token});
  }
}
```

### Step 5: Firebase Storage

```dart
class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  
  Future<String> uploadProfileImage({
    required String userId,
    required File imageFile,
  }) async {
    final ref = _storage.ref('profiles/$userId/avatar.jpg');
    
    final metadata = SettableMetadata(
      contentType: 'image/jpeg',
      customMetadata: {'uploadedBy': userId},
    );
    
    final uploadTask = ref.putFile(imageFile, metadata);
    
    // Optional: Listen to upload progress
    uploadTask.snapshotEvents.listen((snapshot) {
      final progress = snapshot.bytesTransferred / snapshot.totalBytes;
      print('Upload progress: ${(progress * 100).toStringAsFixed(1)}%');
    });
    
    await uploadTask;
    return await ref.getDownloadURL();
  }
  
  Future<void> deleteProfileImage(String userId) async {
    final ref = _storage.ref('profiles/$userId/avatar.jpg');
    await ref.delete();
  }
}
```

## Best Practices

### ✅ Do This

- ✅ Use `flutterfire configure` for multi-platform setup
- ✅ Implement proper error handling for Firebase operations
- ✅ Use Firestore security rules in production
- ✅ Enable offline persistence for better UX
- ✅ Use transactions for atomic multi-document updates

### ❌ Avoid This

- ❌ Don't store sensitive data without security rules
- ❌ Don't ignore FCM token refresh events
- ❌ Don't make unlimited queries—always use `.limit()`
- ❌ Don't store large files (>1MB) in Firestore—use Storage

## Common Pitfalls

**Problem:** Firebase not initializing on Android release builds
**Solution:** Ensure `google-services.json` is in `android/app/` and Gradle plugins are configured correctly.

**Problem:** FCM not receiving messages on iOS
**Solution:** Enable Push Notifications capability in Xcode and upload APNs key to Firebase Console.

## Related Skills

- `@senior-flutter-developer` - Core Flutter patterns
- `@flutter-bloc-specialist` - State management with Firebase
- `@senior-firebase-developer` - Advanced Firebase patterns
- `@flutter-testing-specialist` - Testing Firebase integrations

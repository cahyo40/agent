---
name: flutter-firebase-developer
description: "Expert Flutter Firebase integration including Authentication, Firestore, Cloud Functions, Storage, FCM, and Crashlytics with production-ready architecture"
---

# Flutter Firebase Developer

## Overview

This skill transforms you into a **production-grade Firebase specialist** for Flutter. Beyond basic CRUD operations, you'll implement proper architecture patterns, error handling, offline-first strategies, security best practices, and scalable patterns used in real-world applications.

## When to Use This Skill

- Use when building Flutter apps with Firebase backend
- Use when implementing authentication (Email, Google, Apple, Phone)
- Use when needing real-time database with offline support
- Use when designing scalable Firestore schema
- Use when implementing push notifications (FCM)
- Use when setting up monitoring (Crashlytics, Analytics, Performance)

---

## Part 1: Architecture Foundation

### 1.1 Project Structure

```text
lib/
├── core/
│   ├── config/
│   │   ├── firebase_config.dart      # Firebase initialization
│   │   └── environment.dart          # Environment variables
│   ├── error/
│   │   ├── exceptions.dart           # Custom exceptions
│   │   └── failures.dart             # Failure types
│   ├── network/
│   │   └── network_info.dart         # Connectivity checker
│   └── utils/
│       ├── logger.dart               # Logging wrapper
│       └── result.dart               # Result/Either type
│
├── features/
│   └── auth/
│       ├── data/
│       │   ├── datasources/
│       │   │   ├── auth_remote_datasource.dart
│       │   │   └── auth_local_datasource.dart
│       │   ├── models/
│       │   │   └── user_model.dart
│       │   └── repositories/
│       │       └── auth_repository_impl.dart
│       ├── domain/
│       │   ├── entities/
│       │   │   └── user_entity.dart
│       │   ├── repositories/
│       │   │   └── auth_repository.dart  # Abstract
│       │   └── usecases/
│       │       ├── sign_in_usecase.dart
│       │       └── sign_out_usecase.dart
│       └── presentation/
│           ├── controllers/
│           ├── screens/
│           └── widgets/
```

### 1.2 Firebase Initialization (Production)

```dart
// lib/core/config/firebase_config.dart
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_performance/firebase_performance.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class FirebaseConfig {
  static late FirebaseAnalytics analytics;
  static late FirebasePerformance performance;
  
  static Future<void> initialize() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    
    // Crashlytics setup
    await _setupCrashlytics();
    
    // Analytics setup
    analytics = FirebaseAnalytics.instance;
    await analytics.setAnalyticsCollectionEnabled(!kDebugMode);
    
    // Performance monitoring
    performance = FirebasePerformance.instance;
    await performance.setPerformanceCollectionEnabled(!kDebugMode);
    
    // Firestore settings
    _configureFirestore();
  }
  
  static Future<void> _setupCrashlytics() async {
    // Disable in debug mode
    await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(!kDebugMode);
    
    // Catch Flutter errors
    FlutterError.onError = (errorDetails) {
      FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
    };
    
    // Catch async errors
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };
  }
  
  static void _configureFirestore() {
    final firestore = FirebaseFirestore.instance;
    
    // Enable offline persistence
    firestore.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );
    
    // Use emulator in development
    if (kDebugMode && const bool.fromEnvironment('USE_EMULATOR')) {
      firestore.useFirestoreEmulator('localhost', 8080);
    }
  }
  
  /// Set user ID for analytics and crashlytics
  static Future<void> setUser(String userId, {Map<String, String>? properties}) async {
    await FirebaseCrashlytics.instance.setUserIdentifier(userId);
    await analytics.setUserId(id: userId);
    
    if (properties != null) {
      for (final entry in properties.entries) {
        await analytics.setUserProperty(name: entry.key, value: entry.value);
        await FirebaseCrashlytics.instance.setCustomKey(entry.key, entry.value);
      }
    }
  }
  
  /// Log custom event
  static Future<void> logEvent(String name, {Map<String, dynamic>? parameters}) async {
    await analytics.logEvent(name: name, parameters: parameters);
  }
}
```

### 1.3 Result Type for Error Handling

```dart
// lib/core/utils/result.dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'result.freezed.dart';

@freezed
class Result<T> with _$Result<T> {
  const factory Result.success(T data) = Success<T>;
  const factory Result.failure(Failure failure) = Fail<T>;
  
  const Result._();
  
  bool get isSuccess => this is Success<T>;
  bool get isFailure => this is Fail<T>;
  
  T? get dataOrNull => whenOrNull(success: (data) => data);
  
  Failure? get failureOrNull => whenOrNull(failure: (f) => f);
  
  /// Execute callback if success
  Result<R> map<R>(R Function(T data) mapper) {
    return when(
      success: (data) => Result.success(mapper(data)),
      failure: (failure) => Result.failure(failure),
    );
  }
  
  /// Execute async callback if success
  Future<Result<R>> mapAsync<R>(Future<R> Function(T data) mapper) async {
    return when(
      success: (data) async => Result.success(await mapper(data)),
      failure: (failure) async => Result.failure(failure),
    );
  }
}

// Failure types
abstract class Failure {
  final String message;
  final String? code;
  final dynamic originalError;
  
  const Failure({
    required this.message,
    this.code,
    this.originalError,
  });
}

class AuthFailure extends Failure {
  const AuthFailure({required super.message, super.code, super.originalError});
}

class ServerFailure extends Failure {
  const ServerFailure({required super.message, super.code, super.originalError});
}

class NetworkFailure extends Failure {
  const NetworkFailure({super.message = 'No internet connection'});
}

class CacheFailure extends Failure {
  const CacheFailure({super.message = 'Cache error'});
}

class ValidationFailure extends Failure {
  const ValidationFailure({required super.message});
}
```

---

## Part 2: Authentication (Production-Ready)

### 2.1 Auth Repository Interface

```dart
// lib/features/auth/domain/repositories/auth_repository.dart
abstract class AuthRepository {
  /// Stream of auth state changes
  Stream<UserEntity?> get authStateChanges;
  
  /// Get current user
  UserEntity? get currentUser;
  
  /// Sign in with email and password
  Future<Result<UserEntity>> signInWithEmail({
    required String email,
    required String password,
  });
  
  /// Sign up with email and password
  Future<Result<UserEntity>> signUpWithEmail({
    required String email,
    required String password,
    required String displayName,
  });
  
  /// Sign in with Google
  Future<Result<UserEntity>> signInWithGoogle();
  
  /// Sign in with Apple
  Future<Result<UserEntity>> signInWithApple();
  
  /// Sign in with phone number
  Future<Result<String>> sendPhoneVerificationCode(String phoneNumber);
  Future<Result<UserEntity>> verifyPhoneCode({
    required String verificationId,
    required String smsCode,
  });
  
  /// Sign out
  Future<Result<void>> signOut();
  
  /// Delete account
  Future<Result<void>> deleteAccount();
  
  /// Password reset
  Future<Result<void>> sendPasswordResetEmail(String email);
  
  /// Update profile
  Future<Result<UserEntity>> updateProfile({
    String? displayName,
    String? photoUrl,
  });
  
  /// Reauthenticate (for sensitive operations)
  Future<Result<void>> reauthenticate({
    required String email,
    required String password,
  });
}
```

### 2.2 Auth Repository Implementation

```dart
// lib/features/auth/data/repositories/auth_repository_impl.dart
class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuth _auth;
  final GoogleSignIn _googleSignIn;
  final FirebaseFirestore _firestore;
  final NetworkInfo _networkInfo;
  final Logger _logger;

  AuthRepositoryImpl({
    FirebaseAuth? auth,
    GoogleSignIn? googleSignIn,
    FirebaseFirestore? firestore,
    required NetworkInfo networkInfo,
    required Logger logger,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn(),
        _firestore = firestore ?? FirebaseFirestore.instance,
        _networkInfo = networkInfo,
        _logger = logger;

  @override
  Stream<UserEntity?> get authStateChanges {
    return _auth.authStateChanges().asyncMap((user) async {
      if (user == null) return null;
      return await _getUserWithProfile(user);
    });
  }

  @override
  UserEntity? get currentUser {
    final user = _auth.currentUser;
    if (user == null) return null;
    return UserEntity.fromFirebaseUser(user);
  }

  @override
  Future<Result<UserEntity>> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      if (!await _networkInfo.isConnected) {
        return const Result.failure(NetworkFailure());
      }

      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = await _getUserWithProfile(credential.user!);
      
      _logger.info('User signed in: ${user.id}');
      await FirebaseConfig.setUser(user.id);
      
      return Result.success(user);
    } on FirebaseAuthException catch (e) {
      _logger.error('Sign in failed', error: e);
      return Result.failure(_mapFirebaseAuthError(e));
    } catch (e, stack) {
      _logger.error('Sign in failed', error: e, stackTrace: stack);
      return Result.failure(AuthFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<UserEntity>> signInWithGoogle() async {
    try {
      if (!await _networkInfo.isConnected) {
        return const Result.failure(NetworkFailure());
      }

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
      
      // Create/update user profile in Firestore
      await _createOrUpdateUserProfile(userCredential.user!);
      
      final user = await _getUserWithProfile(userCredential.user!);
      
      _logger.info('Google sign in successful: ${user.id}');
      await FirebaseConfig.setUser(user.id);
      
      return Result.success(user);
    } on FirebaseAuthException catch (e) {
      _logger.error('Google sign in failed', error: e);
      return Result.failure(_mapFirebaseAuthError(e));
    } catch (e, stack) {
      _logger.error('Google sign in failed', error: e, stackTrace: stack);
      return Result.failure(AuthFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<UserEntity>> signInWithApple() async {
    try {
      if (!await _networkInfo.isConnected) {
        return const Result.failure(NetworkFailure());
      }

      final appleProvider = AppleAuthProvider()
        ..addScope('email')
        ..addScope('name');

      final userCredential = await _auth.signInWithProvider(appleProvider);
      
      await _createOrUpdateUserProfile(userCredential.user!);
      final user = await _getUserWithProfile(userCredential.user!);
      
      _logger.info('Apple sign in successful: ${user.id}');
      await FirebaseConfig.setUser(user.id);
      
      return Result.success(user);
    } on FirebaseAuthException catch (e) {
      return Result.failure(_mapFirebaseAuthError(e));
    } catch (e, stack) {
      _logger.error('Apple sign in failed', error: e, stackTrace: stack);
      return Result.failure(AuthFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<String>> sendPhoneVerificationCode(String phoneNumber) async {
    try {
      final completer = Completer<Result<String>>();

      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (credential) async {
          // Auto-verification (Android only)
          await _auth.signInWithCredential(credential);
        },
        verificationFailed: (e) {
          completer.complete(Result.failure(_mapFirebaseAuthError(e)));
        },
        codeSent: (verificationId, resendToken) {
          completer.complete(Result.success(verificationId));
        },
        codeAutoRetrievalTimeout: (verificationId) {},
        timeout: const Duration(seconds: 60),
      );

      return completer.future;
    } catch (e) {
      return Result.failure(AuthFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<void>> signOut() async {
    try {
      await Future.wait([
        _auth.signOut(),
        _googleSignIn.signOut(),
      ]);
      
      _logger.info('User signed out');
      return const Result.success(null);
    } catch (e) {
      return Result.failure(AuthFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<void>> deleteAccount() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return const Result.failure(AuthFailure(message: 'Not authenticated'));
      }

      // Delete user data from Firestore
      await _firestore.collection('users').doc(user.uid).delete();
      
      // Delete Firebase Auth account
      await user.delete();
      
      _logger.info('Account deleted: ${user.uid}');
      return const Result.success(null);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        return const Result.failure(
          AuthFailure(
            message: 'Please sign in again to delete your account',
            code: 'requires-recent-login',
          ),
        );
      }
      return Result.failure(_mapFirebaseAuthError(e));
    } catch (e) {
      return Result.failure(AuthFailure(message: e.toString()));
    }
  }

  // Private helpers
  Future<UserEntity> _getUserWithProfile(User firebaseUser) async {
    final doc = await _firestore.collection('users').doc(firebaseUser.uid).get();
    
    if (doc.exists) {
      return UserEntity.fromFirestore(doc);
    }
    
    return UserEntity.fromFirebaseUser(firebaseUser);
  }

  Future<void> _createOrUpdateUserProfile(User user) async {
    final docRef = _firestore.collection('users').doc(user.uid);
    final doc = await docRef.get();

    if (!doc.exists) {
      await docRef.set({
        'email': user.email,
        'displayName': user.displayName,
        'photoUrl': user.photoURL,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } else {
      await docRef.update({
        'lastLoginAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }
  }

  AuthFailure _mapFirebaseAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return const AuthFailure(message: 'No account found with this email');
      case 'wrong-password':
        return const AuthFailure(message: 'Incorrect password');
      case 'email-already-in-use':
        return const AuthFailure(message: 'Email is already registered');
      case 'invalid-email':
        return const AuthFailure(message: 'Invalid email address');
      case 'weak-password':
        return const AuthFailure(message: 'Password is too weak');
      case 'too-many-requests':
        return const AuthFailure(message: 'Too many attempts. Please try again later');
      case 'user-disabled':
        return const AuthFailure(message: 'This account has been disabled');
      default:
        return AuthFailure(message: e.message ?? 'Authentication failed', code: e.code);
    }
  }
}
```

---

## Part 3: Firestore (Scalable Patterns)

### 3.1 Base Repository with Caching

```dart
// lib/core/data/base_firestore_repository.dart
abstract class BaseFirestoreRepository<T> {
  final FirebaseFirestore firestore;
  final String collectionPath;
  final Logger logger;
  
  // Local cache
  final Map<String, T> _cache = {};
  final Map<String, DateTime> _cacheTimestamp = {};
  final Duration cacheDuration;

  BaseFirestoreRepository({
    required this.collectionPath,
    required this.logger,
    FirebaseFirestore? firestore,
    this.cacheDuration = const Duration(minutes: 5),
  }) : firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get collection =>
      firestore.collection(collectionPath);

  /// Convert Firestore document to entity
  T fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc);

  /// Convert entity to Firestore map
  Map<String, dynamic> toFirestore(T entity);

  /// Get document by ID with caching
  Future<Result<T?>> getById(String id, {bool forceRefresh = false}) async {
    try {
      // Check cache first
      if (!forceRefresh && _isCacheValid(id)) {
        return Result.success(_cache[id]);
      }

      final doc = await collection.doc(id).get();
      
      if (!doc.exists) {
        return const Result.success(null);
      }

      final entity = fromFirestore(doc);
      _updateCache(id, entity);
      
      return Result.success(entity);
    } on FirebaseException catch (e) {
      logger.error('Failed to get $collectionPath/$id', error: e);
      return Result.failure(ServerFailure(message: e.message ?? 'Failed to fetch'));
    }
  }

  /// Real-time stream with automatic cache updates
  Stream<T?> watchById(String id) {
    return collection.doc(id).snapshots().map((doc) {
      if (!doc.exists) return null;
      
      final entity = fromFirestore(doc);
      _updateCache(id, entity);
      
      return entity;
    });
  }

  /// Paginated query with cursor-based pagination
  Future<Result<PaginatedResult<T>>> getPaginated({
    Query<Map<String, dynamic>>? query,
    DocumentSnapshot? startAfter,
    int limit = 20,
  }) async {
    try {
      Query<Map<String, dynamic>> q = query ?? collection;
      
      q = q.limit(limit + 1); // Fetch one extra to check if more exist
      
      if (startAfter != null) {
        q = q.startAfterDocument(startAfter);
      }

      final snapshot = await q.get();
      final docs = snapshot.docs;
      
      final hasMore = docs.length > limit;
      final items = docs.take(limit).map(fromFirestore).toList();
      final lastDoc = docs.length >= limit ? docs[limit - 1] : null;

      return Result.success(PaginatedResult(
        items: items,
        hasMore: hasMore,
        lastDocument: lastDoc,
      ));
    } on FirebaseException catch (e) {
      return Result.failure(ServerFailure(message: e.message ?? 'Query failed'));
    }
  }

  /// Create document
  Future<Result<T>> create(T entity, {String? customId}) async {
    try {
      final docRef = customId != null 
          ? collection.doc(customId) 
          : collection.doc();
      
      final data = toFirestore(entity);
      data['createdAt'] = FieldValue.serverTimestamp();
      data['updatedAt'] = FieldValue.serverTimestamp();
      
      await docRef.set(data);
      
      final doc = await docRef.get();
      final created = fromFirestore(doc);
      
      _updateCache(docRef.id, created);
      logger.info('Created $collectionPath/${docRef.id}');
      
      return Result.success(created);
    } on FirebaseException catch (e) {
      return Result.failure(ServerFailure(message: e.message ?? 'Create failed'));
    }
  }

  /// Update document
  Future<Result<T>> update(String id, Map<String, dynamic> updates) async {
    try {
      updates['updatedAt'] = FieldValue.serverTimestamp();
      
      await collection.doc(id).update(updates);
      
      final doc = await collection.doc(id).get();
      final updated = fromFirestore(doc);
      
      _updateCache(id, updated);
      logger.info('Updated $collectionPath/$id');
      
      return Result.success(updated);
    } on FirebaseException catch (e) {
      return Result.failure(ServerFailure(message: e.message ?? 'Update failed'));
    }
  }

  /// Delete document
  Future<Result<void>> delete(String id) async {
    try {
      await collection.doc(id).delete();
      
      _cache.remove(id);
      _cacheTimestamp.remove(id);
      
      logger.info('Deleted $collectionPath/$id');
      return const Result.success(null);
    } on FirebaseException catch (e) {
      return Result.failure(ServerFailure(message: e.message ?? 'Delete failed'));
    }
  }

  /// Batch operations
  Future<Result<void>> batchWrite(List<BatchOperation<T>> operations) async {
    try {
      final batch = firestore.batch();
      
      for (final op in operations) {
        final docRef = collection.doc(op.id);
        
        switch (op.type) {
          case BatchOperationType.create:
            batch.set(docRef, toFirestore(op.entity!));
            break;
          case BatchOperationType.update:
            batch.update(docRef, op.updates!);
            break;
          case BatchOperationType.delete:
            batch.delete(docRef);
            break;
        }
      }
      
      await batch.commit();
      
      // Invalidate cache for affected documents
      for (final op in operations) {
        _cache.remove(op.id);
        _cacheTimestamp.remove(op.id);
      }
      
      return const Result.success(null);
    } on FirebaseException catch (e) {
      return Result.failure(ServerFailure(message: e.message ?? 'Batch failed'));
    }
  }

  // Cache helpers
  bool _isCacheValid(String id) {
    if (!_cache.containsKey(id)) return false;
    
    final timestamp = _cacheTimestamp[id];
    if (timestamp == null) return false;
    
    return DateTime.now().difference(timestamp) < cacheDuration;
  }

  void _updateCache(String id, T entity) {
    _cache[id] = entity;
    _cacheTimestamp[id] = DateTime.now();
  }

  void clearCache() {
    _cache.clear();
    _cacheTimestamp.clear();
  }
}

class PaginatedResult<T> {
  final List<T> items;
  final bool hasMore;
  final DocumentSnapshot? lastDocument;

  PaginatedResult({
    required this.items,
    required this.hasMore,
    this.lastDocument,
  });
}

enum BatchOperationType { create, update, delete }

class BatchOperation<T> {
  final String id;
  final BatchOperationType type;
  final T? entity;
  final Map<String, dynamic>? updates;

  BatchOperation.create(this.id, this.entity)
      : type = BatchOperationType.create,
        updates = null;

  BatchOperation.update(this.id, this.updates)
      : type = BatchOperationType.update,
        entity = null;

  BatchOperation.delete(this.id)
      : type = BatchOperationType.delete,
        entity = null,
        updates = null;
}
```

### 3.2 Firestore Schema Design Patterns

```dart
/*
 * FIRESTORE SCHEMA DESIGN PATTERNS
 * ================================
 * 
 * 1. DENORMALIZATION (Read-heavy apps)
 *    - Duplicate frequently accessed data
 *    - Trade write complexity for read performance
 * 
 * 2. SUBCOLLECTIONS (Hierarchical data)
 *    - users/{userId}/orders/{orderId}
 *    - Inherits parent's security context
 * 
 * 3. COLLECTION GROUPS (Cross-user queries)
 *    - Query all orders across all users
 *    - Requires composite indexes
 * 
 * 4. COUNTERS (Aggregations)
 *    - Use Cloud Functions to maintain counters
 *    - Avoid client-side aggregations
 */

// Example: E-commerce schema
/*
/users
  /{userId}
    - email: string
    - displayName: string
    - photoUrl: string?
    - createdAt: timestamp
    - stats:              # Denormalized counters
        totalOrders: number
        totalSpent: number
    
    /addresses            # Subcollection
      /{addressId}
        - label: string
        - street: string
        - city: string
        - ...

/products
  /{productId}
    - name: string
    - price: number
    - category: string
    - stock: number
    - vendorId: string
    - vendorName: string  # Denormalized
    - imageUrls: string[]
    - createdAt: timestamp

/orders
  /{orderId}
    - userId: string
    - userEmail: string   # Denormalized for admin queries
    - status: string      # pending, confirmed, shipped, delivered
    - total: number
    - createdAt: timestamp
    - items:              # Embedded array (if <100 items)
        - productId: string
        - name: string    # Snapshot at order time
        - price: number   # Snapshot at order time
        - quantity: number

/carts
  /{userId}               # Document ID = userId (1:1)
    - items:
        - productId: string
        - quantity: number
    - updatedAt: timestamp
*/
```

### 3.3 Offline-First Strategy

```dart
// lib/core/services/sync_service.dart
class FirestoreSyncService {
  final FirebaseFirestore _firestore;
  final ConnectivityService _connectivity;
  final Logger _logger;
  
  final _pendingWrites = <PendingWrite>[];
  
  FirestoreSyncService({
    required ConnectivityService connectivity,
    required Logger logger,
  })  : _firestore = FirebaseFirestore.instance,
        _connectivity = connectivity,
        _logger = logger {
    _listenToConnectivity();
  }
  
  void _listenToConnectivity() {
    _connectivity.onConnectivityChanged.listen((connected) {
      if (connected) {
        _processPendingWrites();
      }
    });
  }
  
  /// Write with offline queue
  Future<void> write({
    required String collection,
    required String docId,
    required Map<String, dynamic> data,
    required WriteType type,
  }) async {
    final docRef = _firestore.collection(collection).doc(docId);
    
    try {
      switch (type) {
        case WriteType.set:
          await docRef.set(data);
          break;
        case WriteType.update:
          await docRef.update(data);
          break;
        case WriteType.delete:
          await docRef.delete();
          break;
      }
    } catch (e) {
      // Queue for later if offline
      _pendingWrites.add(PendingWrite(
        collection: collection,
        docId: docId,
        data: data,
        type: type,
        createdAt: DateTime.now(),
      ));
      
      _logger.warn('Write queued for sync: $collection/$docId');
    }
  }
  
  Future<void> _processPendingWrites() async {
    if (_pendingWrites.isEmpty) return;
    
    _logger.info('Processing ${_pendingWrites.length} pending writes');
    
    final batch = _firestore.batch();
    final processed = <PendingWrite>[];
    
    for (final write in _pendingWrites) {
      final docRef = _firestore.collection(write.collection).doc(write.docId);
      
      try {
        switch (write.type) {
          case WriteType.set:
            batch.set(docRef, write.data);
            break;
          case WriteType.update:
            batch.update(docRef, write.data);
            break;
          case WriteType.delete:
            batch.delete(docRef);
            break;
        }
        processed.add(write);
      } catch (e) {
        _logger.error('Failed to process pending write', error: e);
      }
    }
    
    try {
      await batch.commit();
      _pendingWrites.removeWhere((w) => processed.contains(w));
      _logger.info('Synced ${processed.length} pending writes');
    } catch (e) {
      _logger.error('Batch commit failed', error: e);
    }
  }
  
  int get pendingWriteCount => _pendingWrites.length;
}

enum WriteType { set, update, delete }

class PendingWrite {
  final String collection;
  final String docId;
  final Map<String, dynamic> data;
  final WriteType type;
  final DateTime createdAt;

  PendingWrite({
    required this.collection,
    required this.docId,
    required this.data,
    required this.type,
    required this.createdAt,
  });
}
```

---

## Part 4: Cloud Functions Integration

### 4.1 Calling Cloud Functions

```dart
// lib/core/services/cloud_functions_service.dart
class CloudFunctionsService {
  final FirebaseFunctions _functions;
  final Logger _logger;

  CloudFunctionsService({
    FirebaseFunctions? functions,
    required Logger logger,
  })  : _functions = functions ?? FirebaseFunctions.instance,
        _logger = logger;

  /// Call a function with retry logic
  Future<Result<T>> call<T>({
    required String functionName,
    Map<String, dynamic>? parameters,
    int maxRetries = 3,
  }) async {
    int attempt = 0;
    
    while (attempt < maxRetries) {
      try {
        final callable = _functions.httpsCallable(
          functionName,
          options: HttpsCallableOptions(
            timeout: const Duration(seconds: 30),
          ),
        );

        final result = await callable.call(parameters);
        return Result.success(result.data as T);
      } on FirebaseFunctionsException catch (e) {
        _logger.error('Function $functionName failed', error: e);
        
        // Don't retry certain errors
        if (e.code == 'permission-denied' || 
            e.code == 'unauthenticated' ||
            e.code == 'invalid-argument') {
          return Result.failure(ServerFailure(
            message: e.message ?? 'Function call failed',
            code: e.code,
          ));
        }
        
        attempt++;
        if (attempt < maxRetries) {
          await Future.delayed(Duration(seconds: attempt * 2));
        }
      }
    }
    
    return Result.failure(
      ServerFailure(message: 'Function $functionName failed after $maxRetries attempts'),
    );
  }

  /// Common function calls
  Future<Result<Map<String, dynamic>>> processPayment({
    required String orderId,
    required double amount,
    required String paymentMethodId,
  }) {
    return call(
      functionName: 'processPayment',
      parameters: {
        'orderId': orderId,
        'amount': amount,
        'paymentMethodId': paymentMethodId,
      },
    );
  }

  Future<Result<void>> sendNotification({
    required String userId,
    required String title,
    required String body,
    Map<String, String>? data,
  }) {
    return call(
      functionName: 'sendNotification',
      parameters: {
        'userId': userId,
        'title': title,
        'body': body,
        'data': data,
      },
    );
  }
}
```

---

## Part 5: FCM (Production Setup)

### 5.1 FCM Service with Topics and Groups

```dart
// lib/core/services/fcm_service.dart
class FCMService {
  final FirebaseMessaging _messaging;
  final FirebaseFirestore _firestore;
  final Logger _logger;
  
  final _messageController = StreamController<RemoteMessage>.broadcast();
  Stream<RemoteMessage> get onMessage => _messageController.stream;

  FCMService({
    FirebaseMessaging? messaging,
    FirebaseFirestore? firestore,
    required Logger logger,
  })  : _messaging = messaging ?? FirebaseMessaging.instance,
        _firestore = firestore ?? FirebaseFirestore.instance,
        _logger = logger;

  Future<void> initialize() async {
    // Request permission
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
      criticalAlert: false,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      await _setupToken();
      _setupMessageHandlers();
      _logger.info('FCM initialized');
    } else {
      _logger.warn('FCM permission denied');
    }
  }

  Future<void> _setupToken() async {
    // Get and save token
    final token = await _messaging.getToken();
    if (token != null) {
      await _saveToken(token);
    }

    // Listen for token refresh
    _messaging.onTokenRefresh.listen(_saveToken);
  }

  Future<void> _saveToken(String token) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    // Save with device info for multi-device support
    await _firestore.collection('users').doc(userId).collection('devices').doc(token).set({
      'token': token,
      'platform': Platform.operatingSystem,
      'createdAt': FieldValue.serverTimestamp(),
      'lastActiveAt': FieldValue.serverTimestamp(),
    });

    _logger.info('FCM token saved');
  }

  void _setupMessageHandlers() {
    // Foreground messages
    FirebaseMessaging.onMessage.listen((message) {
      _logger.info('Foreground message: ${message.notification?.title}');
      _messageController.add(message);
    });

    // Background/terminated messages
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      _logger.info('Message opened app: ${message.data}');
      _handleMessageNavigation(message);
    });

    // Check for initial message (app opened from terminated)
    _messaging.getInitialMessage().then((message) {
      if (message != null) {
        _logger.info('Initial message: ${message.data}');
        _handleMessageNavigation(message);
      }
    });
  }

  void _handleMessageNavigation(RemoteMessage message) {
    final type = message.data['type'];
    final id = message.data['id'];

    switch (type) {
      case 'order':
        // Navigate to order details
        break;
      case 'chat':
        // Navigate to chat
        break;
      default:
        // Navigate to notifications
        break;
    }
  }

  /// Subscribe to topic
  Future<void> subscribeToTopic(String topic) async {
    await _messaging.subscribeToTopic(topic);
    _logger.info('Subscribed to topic: $topic');
  }

  /// Unsubscribe from topic
  Future<void> unsubscribeFromTopic(String topic) async {
    await _messaging.unsubscribeFromTopic(topic);
    _logger.info('Unsubscribed from topic: $topic');
  }

  /// Remove token on logout
  Future<void> removeToken() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    final token = await _messaging.getToken();

    if (userId != null && token != null) {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('devices')
          .doc(token)
          .delete();
    }

    await _messaging.deleteToken();
  }

  void dispose() {
    _messageController.close();
  }
}
```

---

## Part 6: Security Best Practices

### 6.1 Firestore Security Rules

```javascript
// firestore.rules
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // Helper functions
    function isAuthenticated() {
      return request.auth != null;
    }
    
    function isOwner(userId) {
      return request.auth.uid == userId;
    }
    
    function isAdmin() {
      return get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
    }
    
    function hasValidFields(required, optional) {
      let all = required.concat(optional);
      return request.resource.data.keys().hasAll(required) &&
             request.resource.data.keys().hasOnly(all);
    }
    
    // Users collection
    match /users/{userId} {
      allow read: if isAuthenticated() && (isOwner(userId) || isAdmin());
      allow create: if isAuthenticated() && isOwner(userId);
      allow update: if isAuthenticated() && isOwner(userId) &&
                       !request.resource.data.diff(resource.data).affectedKeys().hasAny(['role', 'createdAt']);
      allow delete: if isAdmin();
      
      // User's private data
      match /private/{doc} {
        allow read, write: if isOwner(userId);
      }
      
      // User's devices (FCM tokens)
      match /devices/{deviceId} {
        allow read, write: if isOwner(userId);
      }
    }
    
    // Products (public read, admin write)
    match /products/{productId} {
      allow read: if true;
      allow write: if isAdmin();
    }
    
    // Orders (owner read/write, admin read all)
    match /orders/{orderId} {
      allow read: if isAuthenticated() && 
                    (resource.data.userId == request.auth.uid || isAdmin());
      allow create: if isAuthenticated() &&
                       request.resource.data.userId == request.auth.uid;
      allow update: if isAdmin();
      allow delete: if false; // Never delete orders
    }
  }
}
```

### 6.2 Storage Security Rules

```javascript
// storage.rules
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    
    function isAuthenticated() {
      return request.auth != null;
    }
    
    function isOwner(userId) {
      return request.auth.uid == userId;
    }
    
    function isImage() {
      return request.resource.contentType.matches('image/.*');
    }
    
    function isUnder5MB() {
      return request.resource.size < 5 * 1024 * 1024;
    }
    
    // User profile images
    match /profiles/{userId}/{fileName} {
      allow read: if isAuthenticated();
      allow write: if isOwner(userId) && isImage() && isUnder5MB();
    }
    
    // Public assets
    match /public/{allPaths=**} {
      allow read: if true;
      allow write: if false;
    }
    
    // Private user files
    match /private/{userId}/{allPaths=**} {
      allow read, write: if isOwner(userId);
    }
  }
}
```

---

## Part 7: Testing Firebase

### 7.1 Unit Testing with Mocks

```dart
// test/repositories/auth_repository_test.dart
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockNetworkInfo extends Mock implements NetworkInfo {}
class MockLogger extends Mock implements Logger {}

void main() {
  late AuthRepositoryImpl repository;
  late MockFirebaseAuth mockAuth;
  late FakeFirebaseFirestore fakeFirestore;
  late MockNetworkInfo mockNetworkInfo;
  late MockLogger mockLogger;

  setUp(() {
    mockAuth = MockFirebaseAuth();
    fakeFirestore = FakeFirebaseFirestore();
    mockNetworkInfo = MockNetworkInfo();
    mockLogger = MockLogger();

    repository = AuthRepositoryImpl(
      auth: mockAuth,
      firestore: fakeFirestore,
      networkInfo: mockNetworkInfo,
      logger: mockLogger,
    );

    when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
    when(() => mockLogger.info(any())).thenReturn(null);
    when(() => mockLogger.error(any(), error: any(named: 'error'))).thenReturn(null);
  });

  group('signInWithEmail', () {
    test('returns user on successful sign in', () async {
      final mockUser = MockUser(
        uid: 'test-uid',
        email: 'test@example.com',
      );
      mockAuth = MockFirebaseAuth(mockUser: mockUser);
      
      repository = AuthRepositoryImpl(
        auth: mockAuth,
        firestore: fakeFirestore,
        networkInfo: mockNetworkInfo,
        logger: mockLogger,
      );

      final result = await repository.signInWithEmail(
        email: 'test@example.com',
        password: 'password123',
      );

      expect(result.isSuccess, true);
      expect(result.dataOrNull?.email, 'test@example.com');
    });

    test('returns NetworkFailure when offline', () async {
      when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => false);

      final result = await repository.signInWithEmail(
        email: 'test@example.com',
        password: 'password',
      );

      expect(result.isFailure, true);
      expect(result.failureOrNull, isA<NetworkFailure>());
    });
  });
}
```

---

## Best Practices

### ✅ Architecture

- ✅ Use Clean Architecture with repository pattern
- ✅ Implement Result/Either type for error handling
- ✅ Abstract Firebase behind interfaces for testability
- ✅ Use dependency injection for Firebase services

### ✅ Security

- ✅ Never expose `service_role` or admin credentials
- ✅ Implement comprehensive Firestore security rules
- ✅ Use App Check for API abuse prevention
- ✅ Validate data on both client and server (Cloud Functions)

### ✅ Performance

- ✅ Enable offline persistence
- ✅ Use cursor-based pagination (not offset)
- ✅ Implement local caching layer
- ✅ Denormalize data for read-heavy operations

### ✅ Monitoring

- ✅ Log user ID in Crashlytics
- ✅ Track key events in Analytics
- ✅ Monitor performance with Firebase Performance

### ❌ Avoid

- ❌ Don't store large objects in Firestore (use Storage)
- ❌ Don't make unlimited queries
- ❌ Don't skip security rules in production
- ❌ Don't handle errors silently

---

## Related Skills

- `@senior-flutter-developer` - Core Flutter patterns
- `@flutter-riverpod-specialist` - State management
- `@flutter-bloc-specialist` - BLoC with Firebase
- `@flutter-testing-specialist` - Testing Firebase
- `@senior-firebase-developer` - Advanced Firebase

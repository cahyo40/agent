---
name: flutter-supabase-developer
description: "Expert Flutter Supabase integration including Authentication, PostgreSQL database, Realtime subscriptions, Storage, Edge Functions, and RLS with production-ready architecture"
---

# Flutter Supabase Developer

## Overview

This skill transforms you into a **production-grade Supabase specialist** for Flutter. Beyond basic CRUD operations, you'll implement proper architecture patterns, error handling, offline strategies, Row Level Security (RLS), real-time subscriptions, and scalable patterns used in real-world applications.

## When to Use This Skill

- Use when building Flutter apps with Supabase backend
- Use when needing PostgreSQL database with real-time capabilities
- Use when implementing Row Level Security for multi-tenant apps
- Use when building offline-capable applications
- Use when migrating from Firebase to Supabase
- Use when needing Edge Functions for server-side logic

---

## Part 1: Architecture Foundation

### 1.1 Project Structure

```text
lib/
├── core/
│   ├── config/
│   │   ├── supabase_config.dart     # Supabase initialization
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

### 1.2 Supabase Initialization (Production)

```dart
// lib/core/config/supabase_config.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';

class SupabaseConfig {
  static late SupabaseClient client;
  
  static Future<void> initialize() async {
    await Supabase.initialize(
      url: const String.fromEnvironment('SUPABASE_URL'),
      anonKey: const String.fromEnvironment('SUPABASE_ANON_KEY'),
      authOptions: const FlutterAuthClientOptions(
        authFlowType: AuthFlowType.pkce, // Secure OAuth flow
      ),
      realtimeClientOptions: const RealtimeClientOptions(
        logLevel: kDebugMode ? RealtimeLogLevel.info : RealtimeLogLevel.error,
      ),
      storageOptions: const StorageClientOptions(
        retryAttempts: 3,
      ),
    );
    
    client = Supabase.instance.client;
    
    // Setup auth state listener for logging
    client.auth.onAuthStateChange.listen((data) {
      final event = data.event;
      final session = data.session;
      
      if (kDebugMode) {
        print('[Auth] Event: $event, User: ${session?.user.id}');
      }
    });
  }
  
  /// Get current session with refresh
  static Future<Session?> getSession() async {
    try {
      final session = client.auth.currentSession;
      
      if (session == null) return null;
      
      // Check if token needs refresh (within 60 seconds of expiry)
      final expiresAt = DateTime.fromMillisecondsSinceEpoch(
        session.expiresAt! * 1000,
      );
      
      if (DateTime.now().isAfter(expiresAt.subtract(const Duration(seconds: 60)))) {
        final response = await client.auth.refreshSession();
        return response.session;
      }
      
      return session;
    } catch (e) {
      return null;
    }
  }
  
  /// Set user for analytics/logging
  static void setUser(String userId, {Map<String, String>? properties}) {
    // Integrate with your analytics/logging service
    // e.g., Sentry.configureScope((scope) => scope.setUser(userId));
  }
}

// Global accessor
SupabaseClient get supabase => SupabaseConfig.client;
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
  
  Result<R> map<R>(R Function(T data) mapper) {
    return when(
      success: (data) => Result.success(mapper(data)),
      failure: (failure) => Result.failure(failure),
    );
  }
  
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
  
  const Failure({required this.message, this.code, this.originalError});
}

class AuthFailure extends Failure {
  const AuthFailure({required super.message, super.code, super.originalError});
}

class DatabaseFailure extends Failure {
  const DatabaseFailure({required super.message, super.code, super.originalError});
}

class NetworkFailure extends Failure {
  const NetworkFailure({super.message = 'No internet connection'});
}

class StorageFailure extends Failure {
  const StorageFailure({required super.message, super.code});
}

class ValidationFailure extends Failure {
  const ValidationFailure({required super.message});
}

class RLSFailure extends Failure {
  const RLSFailure({super.message = 'Access denied by Row Level Security'});
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
  
  /// Get current session
  Future<Session?> get currentSession;
  
  /// Sign in with email and password
  Future<Result<UserEntity>> signInWithEmail({
    required String email,
    required String password,
  });
  
  /// Sign up with email and password
  Future<Result<UserEntity>> signUpWithEmail({
    required String email,
    required String password,
    String? displayName,
    Map<String, dynamic>? metadata,
  });
  
  /// Sign in with Magic Link (Passwordless)
  Future<Result<void>> signInWithMagicLink(String email);
  
  /// Sign in with OAuth (Google, Apple, GitHub, etc.)
  Future<Result<void>> signInWithOAuth(OAuthProvider provider);
  
  /// Sign in with Phone OTP
  Future<Result<void>> sendPhoneOTP(String phone);
  Future<Result<UserEntity>> verifyPhoneOTP({
    required String phone,
    required String token,
  });
  
  /// Sign out
  Future<Result<void>> signOut();
  
  /// Delete account
  Future<Result<void>> deleteAccount();
  
  /// Password reset
  Future<Result<void>> sendPasswordResetEmail(String email);
  
  /// Update password
  Future<Result<void>> updatePassword(String newPassword);
  
  /// Update user profile
  Future<Result<UserEntity>> updateProfile({
    String? displayName,
    String? avatarUrl,
    Map<String, dynamic>? metadata,
  });
}
```

### 2.2 Auth Repository Implementation

```dart
// lib/features/auth/data/repositories/auth_repository_impl.dart
class AuthRepositoryImpl implements AuthRepository {
  final SupabaseClient _client;
  final NetworkInfo _networkInfo;
  final AuthLocalDataSource _localDataSource;
  final Logger _logger;

  AuthRepositoryImpl({
    SupabaseClient? client,
    required NetworkInfo networkInfo,
    required AuthLocalDataSource localDataSource,
    required Logger logger,
  })  : _client = client ?? supabase,
        _networkInfo = networkInfo,
        _localDataSource = localDataSource,
        _logger = logger;

  @override
  Stream<UserEntity?> get authStateChanges {
    return _client.auth.onAuthStateChange.asyncMap((data) async {
      final user = data.session?.user;
      if (user == null) {
        await _localDataSource.clearUser();
        return null;
      }
      
      // Fetch full profile from database
      return await _fetchUserProfile(user.id);
    });
  }

  @override
  UserEntity? get currentUser {
    final user = _client.auth.currentUser;
    if (user == null) return null;
    return UserEntity.fromSupabaseUser(user);
  }

  @override
  Future<Session?> get currentSession async {
    return await SupabaseConfig.getSession();
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

      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null) {
        return const Result.failure(AuthFailure(message: 'Sign in failed'));
      }

      final user = await _fetchUserProfile(response.user!.id);
      await _localDataSource.cacheUser(user);
      
      _logger.info('User signed in: ${user.id}');
      SupabaseConfig.setUser(user.id);
      
      return Result.success(user);
    } on AuthException catch (e) {
      _logger.error('Sign in failed', error: e);
      return Result.failure(_mapAuthError(e));
    } catch (e, stack) {
      _logger.error('Sign in failed', error: e, stackTrace: stack);
      return Result.failure(AuthFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<UserEntity>> signUpWithEmail({
    required String email,
    required String password,
    String? displayName,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      if (!await _networkInfo.isConnected) {
        return const Result.failure(NetworkFailure());
      }

      final response = await _client.auth.signUp(
        email: email,
        password: password,
        data: {
          'display_name': displayName,
          ...?metadata,
        },
      );

      if (response.user == null) {
        return const Result.failure(AuthFailure(message: 'Sign up failed'));
      }

      // Create profile in public.profiles table
      await _createUserProfile(
        userId: response.user!.id,
        email: email,
        displayName: displayName,
      );

      final user = await _fetchUserProfile(response.user!.id);
      
      _logger.info('User signed up: ${user.id}');
      SupabaseConfig.setUser(user.id);
      
      return Result.success(user);
    } on AuthException catch (e) {
      return Result.failure(_mapAuthError(e));
    } catch (e) {
      return Result.failure(AuthFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<void>> signInWithMagicLink(String email) async {
    try {
      await _client.auth.signInWithOtp(
        email: email,
        emailRedirectTo: 'io.yourapp://login-callback',
      );
      
      return const Result.success(null);
    } on AuthException catch (e) {
      return Result.failure(_mapAuthError(e));
    }
  }

  @override
  Future<Result<void>> signInWithOAuth(OAuthProvider provider) async {
    try {
      final success = await _client.auth.signInWithOAuth(
        provider,
        redirectTo: 'io.yourapp://login-callback',
        authScreenLaunchMode: LaunchMode.externalApplication,
      );

      if (!success) {
        return const Result.failure(AuthFailure(message: 'OAuth sign in cancelled'));
      }

      return const Result.success(null);
    } on AuthException catch (e) {
      return Result.failure(_mapAuthError(e));
    }
  }

  @override
  Future<Result<void>> signOut() async {
    try {
      await _client.auth.signOut();
      await _localDataSource.clearUser();
      
      _logger.info('User signed out');
      return const Result.success(null);
    } catch (e) {
      return Result.failure(AuthFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<void>> deleteAccount() async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) {
        return const Result.failure(AuthFailure(message: 'Not authenticated'));
      }

      // Call Edge Function to delete user (requires service role)
      await _client.functions.invoke('delete-user', body: {'userId': userId});
      
      await _localDataSource.clearUser();
      
      _logger.info('Account deleted: $userId');
      return const Result.success(null);
    } catch (e) {
      return Result.failure(AuthFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<UserEntity>> updateProfile({
    String? displayName,
    String? avatarUrl,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) {
        return const Result.failure(AuthFailure(message: 'Not authenticated'));
      }

      // Update auth metadata
      await _client.auth.updateUser(
        UserAttributes(
          data: {
            if (displayName != null) 'display_name': displayName,
            ...?metadata,
          },
        ),
      );

      // Update profile table
      await _client.from('profiles').update({
        if (displayName != null) 'display_name': displayName,
        if (avatarUrl != null) 'avatar_url': avatarUrl,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', userId);

      final user = await _fetchUserProfile(userId);
      await _localDataSource.cacheUser(user);
      
      return Result.success(user);
    } catch (e) {
      return Result.failure(AuthFailure(message: e.toString()));
    }
  }

  // Private helpers
  Future<UserEntity> _fetchUserProfile(String userId) async {
    final response = await _client
        .from('profiles')
        .select()
        .eq('id', userId)
        .maybeSingle();

    if (response != null) {
      return UserEntity.fromJson(response);
    }

    // Fallback to auth user data
    final authUser = _client.auth.currentUser!;
    return UserEntity.fromSupabaseUser(authUser);
  }

  Future<void> _createUserProfile({
    required String userId,
    required String email,
    String? displayName,
  }) async {
    await _client.from('profiles').upsert({
      'id': userId,
      'email': email,
      'display_name': displayName,
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    });
  }

  AuthFailure _mapAuthError(AuthException e) {
    switch (e.statusCode) {
      case '400':
        return AuthFailure(message: 'Invalid request', code: e.statusCode);
      case '401':
        return const AuthFailure(message: 'Invalid credentials');
      case '422':
        return AuthFailure(message: e.message, code: e.statusCode);
      case '429':
        return const AuthFailure(message: 'Too many attempts. Please try again later');
      default:
        return AuthFailure(message: e.message, code: e.statusCode);
    }
  }
}
```

---

## Part 3: PostgreSQL Database (Advanced Patterns)

### 3.1 Base Repository with Query Builder

```dart
// lib/core/data/base_supabase_repository.dart
abstract class BaseSupabaseRepository<T> {
  final SupabaseClient client;
  final String tableName;
  final Logger logger;
  
  // Local cache
  final Map<String, T> _cache = {};
  final Map<String, DateTime> _cacheTimestamp = {};
  final Duration cacheDuration;

  BaseSupabaseRepository({
    required this.tableName,
    required this.logger,
    SupabaseClient? client,
    this.cacheDuration = const Duration(minutes: 5),
  }) : client = client ?? supabase;

  /// Convert JSON to entity
  T fromJson(Map<String, dynamic> json);

  /// Convert entity to JSON
  Map<String, dynamic> toJson(T entity);

  /// Get ID from entity
  String getId(T entity);

  /// Get by ID with caching
  Future<Result<T?>> getById(String id, {bool forceRefresh = false}) async {
    try {
      if (!forceRefresh && _isCacheValid(id)) {
        return Result.success(_cache[id]);
      }

      final response = await client
          .from(tableName)
          .select()
          .eq('id', id)
          .maybeSingle();

      if (response == null) {
        return const Result.success(null);
      }

      final entity = fromJson(response);
      _updateCache(id, entity);

      return Result.success(entity);
    } on PostgrestException catch (e) {
      logger.error('Failed to get $tableName/$id', error: e);
      return Result.failure(_mapPostgrestError(e));
    }
  }

  /// Real-time stream
  Stream<T?> watchById(String id) {
    return client
        .from(tableName)
        .stream(primaryKey: ['id'])
        .eq('id', id)
        .map((list) {
          if (list.isEmpty) return null;
          
          final entity = fromJson(list.first);
          _updateCache(id, entity);
          
          return entity;
        });
  }

  /// Paginated query with cursor
  Future<Result<PaginatedResult<T>>> getPaginated({
    List<String>? select,
    Map<String, dynamic>? filters,
    String orderBy = 'created_at',
    bool ascending = false,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      PostgrestFilterBuilder query = client
          .from(tableName)
          .select(select?.join(',') ?? '*');

      // Apply filters
      if (filters != null) {
        for (final entry in filters.entries) {
          if (entry.value is List) {
            query = query.inFilter(entry.key, entry.value as List);
          } else if (entry.value is Map) {
            final op = entry.value as Map<String, dynamic>;
            if (op.containsKey('gte')) {
              query = query.gte(entry.key, op['gte']);
            }
            if (op.containsKey('lte')) {
              query = query.lte(entry.key, op['lte']);
            }
            if (op.containsKey('like')) {
              query = query.ilike(entry.key, '%${op['like']}%');
            }
          } else {
            query = query.eq(entry.key, entry.value);
          }
        }
      }

      final response = await query
          .order(orderBy, ascending: ascending)
          .range(offset, offset + limit);

      final items = (response as List).map((e) => fromJson(e)).toList();
      final hasMore = items.length > limit;
      
      if (hasMore) {
        items.removeLast();
      }

      return Result.success(PaginatedResult(
        items: items,
        hasMore: hasMore,
        offset: offset,
        limit: limit,
      ));
    } on PostgrestException catch (e) {
      return Result.failure(_mapPostgrestError(e));
    }
  }

  /// Full-text search
  Future<Result<List<T>>> search({
    required String column,
    required String query,
    int limit = 20,
  }) async {
    try {
      final response = await client
          .from(tableName)
          .select()
          .textSearch(column, query, type: TextSearchType.websearch)
          .limit(limit);

      return Result.success(
        (response as List).map((e) => fromJson(e)).toList(),
      );
    } on PostgrestException catch (e) {
      return Result.failure(_mapPostgrestError(e));
    }
  }

  /// Create
  Future<Result<T>> create(T entity) async {
    try {
      final data = toJson(entity);
      data['created_at'] = DateTime.now().toIso8601String();
      data['updated_at'] = DateTime.now().toIso8601String();

      final response = await client
          .from(tableName)
          .insert(data)
          .select()
          .single();

      final created = fromJson(response);
      _updateCache(getId(created), created);

      logger.info('Created $tableName/${getId(created)}');
      return Result.success(created);
    } on PostgrestException catch (e) {
      return Result.failure(_mapPostgrestError(e));
    }
  }

  /// Update
  Future<Result<T>> update(String id, Map<String, dynamic> updates) async {
    try {
      updates['updated_at'] = DateTime.now().toIso8601String();

      final response = await client
          .from(tableName)
          .update(updates)
          .eq('id', id)
          .select()
          .single();

      final updated = fromJson(response);
      _updateCache(id, updated);

      logger.info('Updated $tableName/$id');
      return Result.success(updated);
    } on PostgrestException catch (e) {
      return Result.failure(_mapPostgrestError(e));
    }
  }

  /// Upsert
  Future<Result<T>> upsert(T entity) async {
    try {
      final data = toJson(entity);
      data['updated_at'] = DateTime.now().toIso8601String();

      final response = await client
          .from(tableName)
          .upsert(data)
          .select()
          .single();

      final result = fromJson(response);
      _updateCache(getId(result), result);

      return Result.success(result);
    } on PostgrestException catch (e) {
      return Result.failure(_mapPostgrestError(e));
    }
  }

  /// Delete
  Future<Result<void>> delete(String id) async {
    try {
      await client.from(tableName).delete().eq('id', id);

      _cache.remove(id);
      _cacheTimestamp.remove(id);

      logger.info('Deleted $tableName/$id');
      return const Result.success(null);
    } on PostgrestException catch (e) {
      return Result.failure(_mapPostgrestError(e));
    }
  }

  /// Soft delete
  Future<Result<void>> softDelete(String id) async {
    return update(id, {'deleted_at': DateTime.now().toIso8601String()});
  }

  /// Call RPC function
  Future<Result<R>> rpc<R>(
    String functionName, {
    Map<String, dynamic>? params,
    R Function(dynamic)? parser,
  }) async {
    try {
      final response = await client.rpc(functionName, params: params);

      if (parser != null) {
        return Result.success(parser(response));
      }

      return Result.success(response as R);
    } on PostgrestException catch (e) {
      return Result.failure(_mapPostgrestError(e));
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

  Failure _mapPostgrestError(PostgrestException e) {
    // RLS violation
    if (e.code == '42501') {
      return const RLSFailure();
    }
    
    // Unique constraint violation
    if (e.code == '23505') {
      return DatabaseFailure(message: 'Record already exists', code: e.code);
    }
    
    // Foreign key violation
    if (e.code == '23503') {
      return DatabaseFailure(message: 'Referenced record not found', code: e.code);
    }
    
    // Not null violation
    if (e.code == '23502') {
      return DatabaseFailure(message: 'Required field is missing', code: e.code);
    }

    return DatabaseFailure(message: e.message, code: e.code);
  }
}

class PaginatedResult<T> {
  final List<T> items;
  final bool hasMore;
  final int offset;
  final int limit;

  PaginatedResult({
    required this.items,
    required this.hasMore,
    required this.offset,
    required this.limit,
  });

  int get nextOffset => offset + limit;
}
```

### 3.2 Example Repository Implementation

```dart
// lib/features/products/data/repositories/product_repository.dart
class ProductRepository extends BaseSupabaseRepository<Product> {
  ProductRepository({required super.logger}) : super(tableName: 'products');

  @override
  Product fromJson(Map<String, dynamic> json) => Product.fromJson(json);

  @override
  Map<String, dynamic> toJson(Product entity) => entity.toJson();

  @override
  String getId(Product entity) => entity.id;

  /// Get products by category with nested vendor data
  Future<Result<List<Product>>> getByCategory(
    String categoryId, {
    int limit = 20,
  }) async {
    try {
      final response = await client
          .from(tableName)
          .select('''
            *,
            vendor:vendors(id, name, logo_url),
            category:categories(id, name)
          ''')
          .eq('category_id', categoryId)
          .eq('is_active', true)
          .order('created_at', ascending: false)
          .limit(limit);

      return Result.success(
        (response as List).map((e) => Product.fromJson(e)).toList(),
      );
    } on PostgrestException catch (e) {
      return Result.failure(_mapPostgrestError(e));
    }
  }

  /// Search products with full-text search
  Future<Result<List<Product>>> searchProducts(String query) async {
    try {
      // Using PostgreSQL full-text search
      final response = await client
          .from(tableName)
          .select()
          .textSearch('fts', query, type: TextSearchType.websearch)
          .eq('is_active', true)
          .limit(50);

      return Result.success(
        (response as List).map((e) => Product.fromJson(e)).toList(),
      );
    } on PostgrestException catch (e) {
      return Result.failure(_mapPostgrestError(e));
    }
  }

  /// Get product stats using RPC
  Future<Result<ProductStats>> getStats(String productId) async {
    return rpc<ProductStats>(
      'get_product_stats',
      params: {'product_id': productId},
      parser: (data) => ProductStats.fromJson(data),
    );
  }

  /// Increment view count atomically
  Future<Result<void>> incrementViews(String productId) async {
    return rpc<void>(
      'increment_product_views',
      params: {'product_id': productId},
    );
  }
}
```

---

## Part 4: Realtime Subscriptions

### 4.1 Realtime Service

```dart
// lib/core/services/realtime_service.dart
class RealtimeService {
  final SupabaseClient _client;
  final Logger _logger;
  
  final Map<String, RealtimeChannel> _channels = {};
  final Map<String, StreamController> _controllers = {};

  RealtimeService({
    SupabaseClient? client,
    required Logger logger,
  })  : _client = client ?? supabase,
        _logger = logger;

  /// Subscribe to table changes
  Stream<RealtimePayload<T>> subscribe<T>({
    required String table,
    required T Function(Map<String, dynamic>) fromJson,
    String? filter,
    List<PostgresChangeEvent> events = const [
      PostgresChangeEvent.insert,
      PostgresChangeEvent.update,
      PostgresChangeEvent.delete,
    ],
  }) {
    final channelName = 'table_$table${filter ?? ''}';
    
    // Reuse existing channel
    if (_controllers.containsKey(channelName)) {
      return _controllers[channelName]!.stream as Stream<RealtimePayload<T>>;
    }

    final controller = StreamController<RealtimePayload<T>>.broadcast(
      onCancel: () => _unsubscribe(channelName),
    );
    
    _controllers[channelName] = controller;

    final channel = _client.channel(channelName);
    
    for (final event in events) {
      channel.onPostgresChanges(
        event: event,
        schema: 'public',
        table: table,
        filter: filter != null ? PostgresChangeFilter.fromString(filter) : null,
        callback: (payload) {
          try {
            final data = _parsePayload<T>(payload, fromJson);
            controller.add(data);
            _logger.debug('Realtime [$table]: ${payload.eventType}');
          } catch (e) {
            _logger.error('Failed to parse realtime payload', error: e);
          }
        },
      );
    }

    channel.subscribe((status, error) {
      if (status == RealtimeSubscribeStatus.subscribed) {
        _logger.info('Subscribed to $channelName');
      } else if (error != null) {
        _logger.error('Subscription error: $channelName', error: error);
        controller.addError(error);
      }
    });

    _channels[channelName] = channel;
    return controller.stream;
  }

  /// Subscribe to presence (online users)
  Stream<List<PresenceState>> subscribeToPresence({
    required String channelName,
    required Map<String, dynamic> userState,
  }) {
    final controller = StreamController<List<PresenceState>>.broadcast(
      onCancel: () => _unsubscribe('presence_$channelName'),
    );

    final channel = _client.channel('presence_$channelName');

    channel
        .onPresenceSync((payload) {
          final presences = channel.presenceState();
          controller.add(presences.entries.map((e) {
            return PresenceState(
              id: e.key,
              data: e.value.first,
            );
          }).toList());
        })
        .onPresenceJoin((payload) {
          _logger.debug('User joined: ${payload.newPresences}');
        })
        .onPresenceLeave((payload) {
          _logger.debug('User left: ${payload.leftPresences}');
        })
        .subscribe((status, error) async {
          if (status == RealtimeSubscribeStatus.subscribed) {
            await channel.track(userState);
          }
        });

    _channels['presence_$channelName'] = channel;
    return controller.stream;
  }

  /// Subscribe to broadcast messages
  Stream<Map<String, dynamic>> subscribeToBroadcast({
    required String channelName,
    required String eventName,
  }) {
    final controller = StreamController<Map<String, dynamic>>.broadcast(
      onCancel: () => _unsubscribe('broadcast_$channelName'),
    );

    final channel = _client.channel('broadcast_$channelName');

    channel
        .onBroadcast(
          event: eventName,
          callback: (payload) {
            controller.add(payload);
          },
        )
        .subscribe();

    _channels['broadcast_$channelName'] = channel;
    return controller.stream;
  }

  /// Send broadcast message
  Future<void> broadcast({
    required String channelName,
    required String eventName,
    required Map<String, dynamic> payload,
  }) async {
    final channel = _channels['broadcast_$channelName'];
    
    if (channel == null) {
      _logger.warn('Channel not found: broadcast_$channelName');
      return;
    }

    await channel.sendBroadcastMessage(
      event: eventName,
      payload: payload,
    );
  }

  void _unsubscribe(String channelName) {
    _channels[channelName]?.unsubscribe();
    _channels.remove(channelName);
    _controllers[channelName]?.close();
    _controllers.remove(channelName);
    _logger.info('Unsubscribed from $channelName');
  }

  void dispose() {
    for (final channel in _channels.values) {
      channel.unsubscribe();
    }
    for (final controller in _controllers.values) {
      controller.close();
    }
    _channels.clear();
    _controllers.clear();
  }

  RealtimePayload<T> _parsePayload<T>(
    PostgresChangePayload payload,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    return RealtimePayload(
      eventType: payload.eventType,
      newRecord: payload.newRecord.isNotEmpty
          ? fromJson(payload.newRecord)
          : null,
      oldRecord: payload.oldRecord.isNotEmpty
          ? fromJson(payload.oldRecord)
          : null,
    );
  }
}

class RealtimePayload<T> {
  final PostgresChangeEvent eventType;
  final T? newRecord;
  final T? oldRecord;

  RealtimePayload({
    required this.eventType,
    this.newRecord,
    this.oldRecord,
  });
}

class PresenceState {
  final String id;
  final Map<String, dynamic> data;

  PresenceState({required this.id, required this.data});
}
```

---

## Part 5: Storage Service

### 5.1 Storage Service with Progress

```dart
// lib/core/services/storage_service.dart
class SupabaseStorageService {
  final SupabaseClient _client;
  final Logger _logger;

  SupabaseStorageService({
    SupabaseClient? client,
    required Logger logger,
  })  : _client = client ?? supabase,
        _logger = logger;

  /// Upload file with progress tracking
  Future<Result<String>> uploadFile({
    required String bucket,
    required String path,
    required File file,
    String? contentType,
    bool upsert = true,
    void Function(double progress)? onProgress,
  }) async {
    try {
      final bytes = await file.readAsBytes();
      final totalBytes = bytes.length;
      
      // For progress tracking, use chunked upload in production
      // This is a simplified version
      onProgress?.call(0.0);

      await _client.storage.from(bucket).uploadBinary(
        path,
        bytes,
        fileOptions: FileOptions(
          contentType: contentType ?? _getContentType(file.path),
          upsert: upsert,
        ),
      );

      onProgress?.call(1.0);

      final url = _client.storage.from(bucket).getPublicUrl(path);
      
      _logger.info('Uploaded to $bucket/$path');
      return Result.success(url);
    } on StorageException catch (e) {
      _logger.error('Upload failed', error: e);
      return Result.failure(StorageFailure(message: e.message, code: e.statusCode));
    }
  }

  /// Upload from bytes (for web/memory)
  Future<Result<String>> uploadBytes({
    required String bucket,
    required String path,
    required Uint8List bytes,
    required String contentType,
    bool upsert = true,
  }) async {
    try {
      await _client.storage.from(bucket).uploadBinary(
        path,
        bytes,
        fileOptions: FileOptions(contentType: contentType, upsert: upsert),
      );

      final url = _client.storage.from(bucket).getPublicUrl(path);
      return Result.success(url);
    } on StorageException catch (e) {
      return Result.failure(StorageFailure(message: e.message));
    }
  }

  /// Get signed URL for private files
  Future<Result<String>> getSignedUrl({
    required String bucket,
    required String path,
    Duration expiresIn = const Duration(hours: 1),
  }) async {
    try {
      final url = await _client.storage.from(bucket).createSignedUrl(
        path,
        expiresIn.inSeconds,
      );
      return Result.success(url);
    } on StorageException catch (e) {
      return Result.failure(StorageFailure(message: e.message));
    }
  }

  /// Download file
  Future<Result<Uint8List>> downloadFile({
    required String bucket,
    required String path,
  }) async {
    try {
      final bytes = await _client.storage.from(bucket).download(path);
      return Result.success(bytes);
    } on StorageException catch (e) {
      return Result.failure(StorageFailure(message: e.message));
    }
  }

  /// Delete file
  Future<Result<void>> deleteFile({
    required String bucket,
    required String path,
  }) async {
    try {
      await _client.storage.from(bucket).remove([path]);
      _logger.info('Deleted $bucket/$path');
      return const Result.success(null);
    } on StorageException catch (e) {
      return Result.failure(StorageFailure(message: e.message));
    }
  }

  /// Delete multiple files
  Future<Result<void>> deleteFiles({
    required String bucket,
    required List<String> paths,
  }) async {
    try {
      await _client.storage.from(bucket).remove(paths);
      return const Result.success(null);
    } on StorageException catch (e) {
      return Result.failure(StorageFailure(message: e.message));
    }
  }

  /// List files in folder
  Future<Result<List<FileObject>>> listFiles({
    required String bucket,
    String path = '',
    int limit = 100,
    int offset = 0,
  }) async {
    try {
      final files = await _client.storage.from(bucket).list(
        path: path,
        searchOptions: SearchOptions(limit: limit, offset: offset),
      );
      return Result.success(files);
    } on StorageException catch (e) {
      return Result.failure(StorageFailure(message: e.message));
    }
  }

  String _getContentType(String path) {
    final ext = path.split('.').last.toLowerCase();
    
    return switch (ext) {
      'jpg' || 'jpeg' => 'image/jpeg',
      'png' => 'image/png',
      'gif' => 'image/gif',
      'webp' => 'image/webp',
      'pdf' => 'application/pdf',
      'json' => 'application/json',
      'mp4' => 'video/mp4',
      'mp3' => 'audio/mpeg',
      _ => 'application/octet-stream',
    };
  }
}
```

---

## Part 6: Edge Functions

### 6.1 Edge Functions Service

```dart
// lib/core/services/edge_functions_service.dart
class EdgeFunctionsService {
  final SupabaseClient _client;
  final Logger _logger;

  EdgeFunctionsService({
    SupabaseClient? client,
    required Logger logger,
  })  : _client = client ?? supabase,
        _logger = logger;

  /// Invoke edge function with retry
  Future<Result<T>> invoke<T>({
    required String functionName,
    Map<String, dynamic>? body,
    Map<String, String>? headers,
    int maxRetries = 3,
    T Function(dynamic)? parser,
  }) async {
    int attempt = 0;

    while (attempt < maxRetries) {
      try {
        final response = await _client.functions.invoke(
          functionName,
          body: body,
          headers: headers,
        );

        if (response.status != 200) {
          throw FunctionException(
            status: response.status,
            details: response.data,
          );
        }

        final data = parser != null ? parser(response.data) : response.data as T;
        return Result.success(data);
      } on FunctionException catch (e) {
        _logger.error('Edge function $functionName failed', error: e);

        // Don't retry client errors
        if (e.status >= 400 && e.status < 500) {
          return Result.failure(ServerFailure(
            message: e.details?.toString() ?? 'Function call failed',
            code: e.status.toString(),
          ));
        }

        attempt++;
        if (attempt < maxRetries) {
          await Future.delayed(Duration(seconds: attempt * 2));
        }
      } catch (e, stack) {
        _logger.error('Edge function $functionName failed', error: e, stackTrace: stack);
        
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

  // Common functions
  Future<Result<Map<String, dynamic>>> processPayment({
    required String orderId,
    required double amount,
    required String paymentMethodId,
  }) {
    return invoke(
      functionName: 'process-payment',
      body: {
        'orderId': orderId,
        'amount': amount,
        'paymentMethodId': paymentMethodId,
      },
    );
  }

  Future<Result<void>> sendEmail({
    required String to,
    required String subject,
    required String html,
  }) {
    return invoke(
      functionName: 'send-email',
      body: {'to': to, 'subject': subject, 'html': html},
    );
  }

  Future<Result<String>> generateReport({
    required String reportType,
    required DateTime startDate,
    required DateTime endDate,
  }) {
    return invoke(
      functionName: 'generate-report',
      body: {
        'type': reportType,
        'startDate': startDate.toIso8601String(),
        'endDate': endDate.toIso8601String(),
      },
    );
  }
}
```

---

## Part 7: Row Level Security (RLS)

### 7.1 RLS Policy Patterns

```sql
-- ============================================
-- ROW LEVEL SECURITY PATTERNS
-- ============================================

-- Enable RLS on all tables
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE products ENABLE ROW LEVEL SECURITY;
ALTER TABLE orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE order_items ENABLE ROW LEVEL SECURITY;

-- ============================================
-- 1. USER ISOLATION (Users see only their data)
-- ============================================

-- Profiles: Users can only access their own profile
CREATE POLICY "Users can view own profile"
ON profiles FOR SELECT
USING (auth.uid() = id);

CREATE POLICY "Users can update own profile"
ON profiles FOR UPDATE
USING (auth.uid() = id);

-- ============================================
-- 2. ROLE-BASED ACCESS
-- ============================================

-- Create helper function
CREATE OR REPLACE FUNCTION public.get_user_role()
RETURNS TEXT AS $$
  SELECT role FROM profiles WHERE id = auth.uid();
$$ LANGUAGE SQL SECURITY DEFINER;

-- Products: Public read, Admin write
CREATE POLICY "Anyone can view active products"
ON products FOR SELECT
USING (is_active = true OR get_user_role() = 'admin');

CREATE POLICY "Admins can insert products"
ON products FOR INSERT
WITH CHECK (get_user_role() = 'admin');

CREATE POLICY "Admins can update products"
ON products FOR UPDATE
USING (get_user_role() = 'admin');

CREATE POLICY "Admins can delete products"
ON products FOR DELETE
USING (get_user_role() = 'admin');

-- ============================================
-- 3. MULTI-TENANT (Organization-based)
-- ============================================

-- Create helper function
CREATE OR REPLACE FUNCTION public.get_user_org_id()
RETURNS UUID AS $$
  SELECT organization_id FROM profiles WHERE id = auth.uid();
$$ LANGUAGE SQL SECURITY DEFINER;

-- Team members: Same organization only
CREATE POLICY "Users can view team members"
ON team_members FOR SELECT
USING (organization_id = get_user_org_id());

-- ============================================
-- 4. HIERARCHICAL ACCESS
-- ============================================

-- Orders: User sees own, Admin sees all
CREATE POLICY "Users can view own orders"
ON orders FOR SELECT
USING (
  user_id = auth.uid() 
  OR get_user_role() = 'admin'
);

CREATE POLICY "Users can create own orders"
ON orders FOR INSERT
WITH CHECK (user_id = auth.uid());

-- Order items: Based on parent order access
CREATE POLICY "Access order items through orders"
ON order_items FOR SELECT
USING (
  EXISTS (
    SELECT 1 FROM orders 
    WHERE orders.id = order_items.order_id
    AND (orders.user_id = auth.uid() OR get_user_role() = 'admin')
  )
);

-- ============================================
-- 5. TIME-BASED ACCESS
-- ============================================

CREATE POLICY "Can only edit recent orders"
ON orders FOR UPDATE
USING (
  user_id = auth.uid() 
  AND created_at > NOW() - INTERVAL '24 hours'
  AND status = 'pending'
);

-- ============================================
-- 6. SOFT DELETE PATTERN
-- ============================================

-- Hide soft-deleted records
CREATE POLICY "Hide deleted records"
ON products FOR SELECT
USING (deleted_at IS NULL OR get_user_role() = 'admin');
```

### 7.2 Database Functions (RPC)

```sql
-- ============================================
-- SECURE DATABASE FUNCTIONS
-- ============================================

-- Increment view count atomically
CREATE OR REPLACE FUNCTION increment_product_views(product_id UUID)
RETURNS VOID AS $$
BEGIN
  UPDATE products 
  SET views = views + 1 
  WHERE id = product_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Get product statistics
CREATE OR REPLACE FUNCTION get_product_stats(product_id UUID)
RETURNS JSON AS $$
DECLARE
  result JSON;
BEGIN
  SELECT json_build_object(
    'views', p.views,
    'orders_count', COUNT(oi.id),
    'revenue', COALESCE(SUM(oi.quantity * oi.unit_price), 0),
    'avg_rating', COALESCE(AVG(r.rating), 0)
  )
  INTO result
  FROM products p
  LEFT JOIN order_items oi ON oi.product_id = p.id
  LEFT JOIN reviews r ON r.product_id = p.id
  WHERE p.id = product_id
  GROUP BY p.id, p.views;
  
  RETURN result;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Transfer credits between users (transactional)
CREATE OR REPLACE FUNCTION transfer_credits(
  from_user_id UUID,
  to_user_id UUID,
  amount INT
)
RETURNS VOID AS $$
BEGIN
  -- Check if sender has enough credits
  IF (SELECT credits FROM profiles WHERE id = from_user_id) < amount THEN
    RAISE EXCEPTION 'Insufficient credits';
  END IF;
  
  -- Deduct from sender
  UPDATE profiles 
  SET credits = credits - amount,
      updated_at = NOW()
  WHERE id = from_user_id;
  
  -- Add to receiver
  UPDATE profiles 
  SET credits = credits + amount,
      updated_at = NOW()
  WHERE id = to_user_id;
  
  -- Log transaction
  INSERT INTO credit_transactions (from_user_id, to_user_id, amount)
  VALUES (from_user_id, to_user_id, amount);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
```

---

## Part 8: Testing Supabase

```dart
// test/repositories/product_repository_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MockSupabaseClient extends Mock implements SupabaseClient {}
class MockSupabaseQueryBuilder extends Mock implements SupabaseQueryBuilder {}
class MockLogger extends Mock implements Logger {}

void main() {
  late ProductRepository repository;
  late MockSupabaseClient mockClient;
  late MockLogger mockLogger;

  setUp(() {
    mockClient = MockSupabaseClient();
    mockLogger = MockLogger();
    repository = ProductRepository(
      client: mockClient,
      logger: mockLogger,
    );
  });

  group('getById', () {
    test('returns product when found', () async {
      final mockQueryBuilder = MockSupabaseQueryBuilder();
      
      when(() => mockClient.from('products')).thenReturn(mockQueryBuilder);
      when(() => mockQueryBuilder.select()).thenReturn(mockQueryBuilder);
      when(() => mockQueryBuilder.eq('id', 'test-id')).thenReturn(mockQueryBuilder);
      when(() => mockQueryBuilder.maybeSingle()).thenAnswer(
        (_) async => {'id': 'test-id', 'name': 'Test Product', 'price': 100},
      );

      final result = await repository.getById('test-id');

      expect(result.isSuccess, true);
      expect(result.dataOrNull?.name, 'Test Product');
    });

    test('returns null when not found', () async {
      final mockQueryBuilder = MockSupabaseQueryBuilder();
      
      when(() => mockClient.from('products')).thenReturn(mockQueryBuilder);
      when(() => mockQueryBuilder.select()).thenReturn(mockQueryBuilder);
      when(() => mockQueryBuilder.eq('id', 'missing')).thenReturn(mockQueryBuilder);
      when(() => mockQueryBuilder.maybeSingle()).thenAnswer((_) async => null);

      final result = await repository.getById('missing');

      expect(result.isSuccess, true);
      expect(result.dataOrNull, isNull);
    });
  });
}
```

---

## Best Practices

### ✅ Architecture

- ✅ Use Clean Architecture with repository pattern
- ✅ Implement Result type for error handling
- ✅ Abstract Supabase behind interfaces for testability
- ✅ Use dependency injection for Supabase services

### ✅ Security

- ✅ Always enable RLS on all tables
- ✅ Use `anon` key in client apps, never `service_role`
- ✅ Validate data in Edge Functions for sensitive operations
- ✅ Use `SECURITY DEFINER` for RPC functions that bypass RLS

### ✅ Performance

- ✅ Use cursor-based pagination
- ✅ Implement local caching
- ✅ Select only needed columns
- ✅ Create indexes for frequently queried columns

### ✅ Realtime

- ✅ Limit subscriptions to necessary tables/filters
- ✅ Unsubscribe when widgets dispose
- ✅ Use presence for online status, not polling

### ❌ Avoid

- ❌ Don't skip RLS policies
- ❌ Don't make unlimited queries
- ❌ Don't store secrets in client code
- ❌ Don't use `.single()` when record might not exist

---

## Related Skills

- `@senior-flutter-developer` - Core Flutter patterns
- `@flutter-riverpod-specialist` - State management
- `@flutter-bloc-specialist` - BLoC with Supabase
- `@flutter-testing-specialist` - Testing Supabase
- `@senior-supabase-developer` - Advanced Supabase
- `@postgresql-specialist` - Advanced SQL patterns

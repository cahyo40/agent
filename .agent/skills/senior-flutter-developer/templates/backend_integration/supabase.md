# Flutter Supabase Integration

## Overview

Production-grade Supabase integration for Flutter including Authentication, PostgreSQL database, Realtime subscriptions, Storage, Edge Functions, and Row Level Security.

## When to Use

- Building Flutter apps with Supabase backend
- Need PostgreSQL database with real-time capabilities
- Implementing Row Level Security for multi-tenant apps
- Building offline-capable applications
- Migrating from Firebase to Supabase

---

## Project Structure

```text
lib/
├── core/
│   ├── config/
│   │   ├── supabase_config.dart     # Supabase initialization
│   │   └── environment.dart
│   ├── error/
│   │   ├── exceptions.dart
│   │   └── failures.dart
│   └── utils/
│       └── result.dart
├── features/
│   └── auth/
│       ├── data/
│       ├── domain/
│       └── presentation/
```

---

## Supabase Initialization

```dart
class SupabaseConfig {
  static late SupabaseClient client;
  
  static Future<void> initialize() async {
    await Supabase.initialize(
      url: const String.fromEnvironment('SUPABASE_URL'),
      anonKey: const String.fromEnvironment('SUPABASE_ANON_KEY'),
      authOptions: const FlutterAuthClientOptions(
        authFlowType: AuthFlowType.pkce,
      ),
      realtimeClientOptions: const RealtimeClientOptions(
        logLevel: kDebugMode ? RealtimeLogLevel.info : RealtimeLogLevel.error,
      ),
    );
    
    client = Supabase.instance.client;
  }
  
  static Future<Session?> getSession() async {
    final session = client.auth.currentSession;
    if (session == null) return null;
    
    final expiresAt = DateTime.fromMillisecondsSinceEpoch(session.expiresAt! * 1000);
    if (DateTime.now().isAfter(expiresAt.subtract(const Duration(seconds: 60)))) {
      final response = await client.auth.refreshSession();
      return response.session;
    }
    return session;
  }
}

SupabaseClient get supabase => SupabaseConfig.client;
```

---

## Authentication

```dart
abstract class AuthRepository {
  Stream<UserEntity?> get authStateChanges;
  UserEntity? get currentUser;
  
  Future<Result<UserEntity>> signInWithEmail({
    required String email,
    required String password,
  });
  
  Future<Result<UserEntity>> signUpWithEmail({
    required String email,
    required String password,
    String? displayName,
  });
  
  Future<Result<void>> signInWithMagicLink(String email);
  Future<Result<void>> signInWithOAuth(OAuthProvider provider);
  Future<Result<void>> signOut();
}

// Implementation
class AuthRepositoryImpl implements AuthRepository {
  final SupabaseClient _client;
  
  @override
  Future<Result<UserEntity>> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null) {
        return const Result.failure(AuthFailure(message: 'Sign in failed'));
      }

      final user = await _fetchUserProfile(response.user!.id);
      return Result.success(user);
    } on AuthException catch (e) {
      return Result.failure(_mapAuthError(e));
    }
  }
  
  @override
  Future<Result<void>> signInWithOAuth(OAuthProvider provider) async {
    try {
      await _client.auth.signInWithOAuth(
        provider,
        redirectTo: 'io.yourapp://login-callback',
        authScreenLaunchMode: LaunchMode.externalApplication,
      );
      return const Result.success(null);
    } on AuthException catch (e) {
      return Result.failure(_mapAuthError(e));
    }
  }
}
```

---

## Database Repository

```dart
abstract class BaseSupabaseRepository<T> {
  final SupabaseClient client;
  final String tableName;
  
  T fromJson(Map<String, dynamic> json);
  Map<String, dynamic> toJson(T entity);

  Future<Result<T?>> getById(String id) async {
    try {
      final response = await client
          .from(tableName)
          .select()
          .eq('id', id)
          .maybeSingle();

      if (response == null) return const Result.success(null);
      return Result.success(fromJson(response));
    } on PostgrestException catch (e) {
      return Result.failure(DatabaseFailure(message: e.message));
    }
  }

  Stream<T?> watchById(String id) {
    return client
        .from(tableName)
        .stream(primaryKey: ['id'])
        .eq('id', id)
        .map((list) => list.isEmpty ? null : fromJson(list.first));
  }

  Future<Result<List<T>>> getPaginated({
    Map<String, dynamic>? filters,
    String orderBy = 'created_at',
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      var query = client.from(tableName).select();
      
      filters?.forEach((key, value) {
        query = query.eq(key, value);
      });

      final response = await query
          .order(orderBy, ascending: false)
          .range(offset, offset + limit - 1);

      return Result.success(
        (response as List).map((e) => fromJson(e)).toList(),
      );
    } on PostgrestException catch (e) {
      return Result.failure(DatabaseFailure(message: e.message));
    }
  }

  Future<Result<T>> create(T entity) async {
    try {
      final data = toJson(entity);
      data['created_at'] = DateTime.now().toIso8601String();

      final response = await client
          .from(tableName)
          .insert(data)
          .select()
          .single();

      return Result.success(fromJson(response));
    } on PostgrestException catch (e) {
      return Result.failure(DatabaseFailure(message: e.message));
    }
  }

  Future<Result<T>> update(String id, Map<String, dynamic> updates) async {
    try {
      updates['updated_at'] = DateTime.now().toIso8601String();

      final response = await client
          .from(tableName)
          .update(updates)
          .eq('id', id)
          .select()
          .single();

      return Result.success(fromJson(response));
    } on PostgrestException catch (e) {
      return Result.failure(DatabaseFailure(message: e.message));
    }
  }

  Future<Result<void>> delete(String id) async {
    try {
      await client.from(tableName).delete().eq('id', id);
      return const Result.success(null);
    } on PostgrestException catch (e) {
      return Result.failure(DatabaseFailure(message: e.message));
    }
  }
}
```

---

## Row Level Security (RLS)

```sql
-- Enable RLS
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;

-- Users can only read/update their own profile
CREATE POLICY "Users can view own profile"
  ON profiles FOR SELECT
  USING (auth.uid() = id);

CREATE POLICY "Users can update own profile"
  ON profiles FOR UPDATE
  USING (auth.uid() = id);

-- Public read, authenticated write
CREATE POLICY "Products are viewable by everyone"
  ON products FOR SELECT
  USING (true);

CREATE POLICY "Authenticated users can insert products"
  ON products FOR INSERT
  WITH CHECK (auth.role() = 'authenticated');
```

---

## Storage

```dart
class StorageService {
  final SupabaseClient _client;
  
  Future<Result<String>> uploadFile({
    required String bucket,
    required String path,
    required File file,
  }) async {
    try {
      final bytes = await file.readAsBytes();
      await _client.storage.from(bucket).uploadBinary(path, bytes);
      
      final publicUrl = _client.storage.from(bucket).getPublicUrl(path);
      return Result.success(publicUrl);
    } on StorageException catch (e) {
      return Result.failure(StorageFailure(message: e.message));
    }
  }
  
  Future<Result<void>> deleteFile({
    required String bucket,
    required String path,
  }) async {
    try {
      await _client.storage.from(bucket).remove([path]);
      return const Result.success(null);
    } on StorageException catch (e) {
      return Result.failure(StorageFailure(message: e.message));
    }
  }
}
```

---

## Edge Functions

```dart
Future<Result<T>> callEdgeFunction<T>({
  required String functionName,
  Map<String, dynamic>? body,
}) async {
  try {
    final response = await supabase.functions.invoke(
      functionName,
      body: body,
    );
    
    if (response.status != 200) {
      return Result.failure(ServerFailure(message: 'Function failed'));
    }
    
    return Result.success(response.data as T);
  } catch (e) {
    return Result.failure(ServerFailure(message: e.toString()));
  }
}
```

---

## Best Practices

### ✅ Do This

- ✅ Use RLS for all tables
- ✅ Use service_role only in Edge Functions
- ✅ Implement proper error handling with Result type
- ✅ Use real-time subscriptions for live data
- ✅ Cache data locally for offline support
- ✅ Use cursor-based pagination

### ❌ Avoid This

- ❌ Don't expose service_role key in client code
- ❌ Don't skip RLS in production
- ❌ Don't make unlimited queries
- ❌ Don't store large files in database (use Storage)

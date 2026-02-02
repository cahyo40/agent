---
name: flutter-supabase-developer
description: "Expert Flutter Supabase integration including Authentication, PostgreSQL database, Realtime subscriptions, Storage, and Edge Functions"
---

# Flutter Supabase Developer

## Overview

Skill ini menjadikan AI Agent Anda sebagai spesialis integrasi Supabase di Flutter. Agent akan mampu mengimplementasikan Authentication, query PostgreSQL dengan type-safe client, Realtime subscriptions, Row Level Security (RLS), Storage untuk file uploads, dan Edge Functions—semua dengan best practices untuk production.

## When to Use This Skill

- Use when building Flutter apps with Supabase backend
- Use when needing PostgreSQL database with real-time capabilities
- Use when implementing Row Level Security for multi-tenant apps
- Use when the user asks about Supabase or prefers open-source Firebase alternative
- Use when migrating from Firebase to Supabase

## How It Works

### Step 1: Project Setup

```yaml
# pubspec.yaml
dependencies:
  supabase_flutter: ^2.8.0
  # Optional for auth
  google_sign_in: ^6.2.2
  sign_in_with_apple: ^6.1.3
```

#### Initialize Supabase

```dart
// main.dart
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Supabase.initialize(
    url: 'https://your-project.supabase.co',
    anonKey: 'your-anon-key',
    authOptions: const FlutterAuthClientOptions(
      authFlowType: AuthFlowType.pkce,
    ),
    realtimeClientOptions: const RealtimeClientOptions(
      logLevel: RealtimeLogLevel.info,
    ),
  );
  
  runApp(const MyApp());
}

// Global accessor
final supabase = Supabase.instance.client;
```

### Step 2: Supabase Authentication

#### 2.1 Auth Repository

```dart
class SupabaseAuthRepository {
  final SupabaseClient _client = Supabase.instance.client;
  
  // Current user
  User? get currentUser => _client.auth.currentUser;
  
  // Auth state stream
  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;
  
  // Email/Password Sign Up
  Future<AuthResponse> signUpWithEmail({
    required String email,
    required String password,
    Map<String, dynamic>? metadata,
  }) async {
    return await _client.auth.signUp(
      email: email,
      password: password,
      data: metadata,
    );
  }
  
  // Email/Password Sign In
  Future<AuthResponse> signInWithEmail({
    required String email,
    required String password,
  }) async {
    return await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }
  
  // Magic Link (Passwordless)
  Future<void> signInWithMagicLink(String email) async {
    await _client.auth.signInWithOtp(
      email: email,
      emailRedirectTo: 'io.supabase.yourapp://login-callback',
    );
  }
  
  // OAuth (Google, Apple, GitHub, etc.)
  Future<bool> signInWithOAuth(OAuthProvider provider) async {
    return await _client.auth.signInWithOAuth(
      provider,
      redirectTo: 'io.supabase.yourapp://login-callback',
    );
  }
  
  // Sign Out
  Future<void> signOut() async {
    await _client.auth.signOut();
  }
  
  // Password Reset
  Future<void> resetPassword(String email) async {
    await _client.auth.resetPasswordForEmail(
      email,
      redirectTo: 'io.supabase.yourapp://reset-callback',
    );
  }
  
  // Update user metadata
  Future<UserResponse> updateUser({
    String? email,
    String? password,
    Map<String, dynamic>? data,
  }) async {
    return await _client.auth.updateUser(
      UserAttributes(
        email: email,
        password: password,
        data: data,
      ),
    );
  }
}
```

#### 2.2 Deep Link Setup (for OAuth/Magic Link)

```dart
// Handle deep links on app start
void initDeepLinks() {
  // Handle app opened from terminated state
  _handleInitialDeepLink();
  
  // Handle app opened from background
  supabase.auth.onAuthStateChange.listen((data) {
    final event = data.event;
    if (event == AuthChangeEvent.signedIn) {
      // Navigate to home
    }
  });
}
```

### Step 3: PostgreSQL Database Operations

#### 3.1 Data Model

```dart
class TodoModel {
  final String id;
  final String userId;
  final String title;
  final bool isCompleted;
  final DateTime createdAt;
  
  TodoModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.isCompleted,
    required this.createdAt,
  });
  
  factory TodoModel.fromJson(Map<String, dynamic> json) {
    return TodoModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      title: json['title'] as String,
      isCompleted: json['is_completed'] as bool,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'title': title,
      'is_completed': isCompleted,
    };
  }
}
```

#### 3.2 Repository with CRUD Operations

```dart
class TodoRepository {
  final SupabaseClient _client = Supabase.instance.client;
  
  // CREATE
  Future<TodoModel> createTodo({
    required String title,
  }) async {
    final userId = _client.auth.currentUser!.id;
    
    final response = await _client
        .from('todos')
        .insert({
          'user_id': userId,
          'title': title,
          'is_completed': false,
        })
        .select()
        .single();
    
    return TodoModel.fromJson(response);
  }
  
  // READ (list with filters)
  Future<List<TodoModel>> getTodos({
    bool? isCompleted,
    int limit = 20,
    int offset = 0,
  }) async {
    var query = _client
        .from('todos')
        .select()
        .order('created_at', ascending: false)
        .range(offset, offset + limit - 1);
    
    if (isCompleted != null) {
      query = query.eq('is_completed', isCompleted);
    }
    
    final response = await query;
    return (response as List).map((e) => TodoModel.fromJson(e)).toList();
  }
  
  // READ (single)
  Future<TodoModel?> getTodo(String id) async {
    final response = await _client
        .from('todos')
        .select()
        .eq('id', id)
        .maybeSingle();
    
    if (response == null) return null;
    return TodoModel.fromJson(response);
  }
  
  // UPDATE
  Future<TodoModel> updateTodo({
    required String id,
    String? title,
    bool? isCompleted,
  }) async {
    final updates = <String, dynamic>{};
    if (title != null) updates['title'] = title;
    if (isCompleted != null) updates['is_completed'] = isCompleted;
    updates['updated_at'] = DateTime.now().toIso8601String();
    
    final response = await _client
        .from('todos')
        .update(updates)
        .eq('id', id)
        .select()
        .single();
    
    return TodoModel.fromJson(response);
  }
  
  // DELETE
  Future<void> deleteTodo(String id) async {
    await _client.from('todos').delete().eq('id', id);
  }
  
  // SEARCH
  Future<List<TodoModel>> searchTodos(String query) async {
    final response = await _client
        .from('todos')
        .select()
        .ilike('title', '%$query%')
        .order('created_at', ascending: false)
        .limit(20);
    
    return (response as List).map((e) => TodoModel.fromJson(e)).toList();
  }
  
  // RPC (Call PostgreSQL function)
  Future<int> getCompletedCount() async {
    final response = await _client.rpc('get_completed_todos_count');
    return response as int;
  }
}
```

### Step 4: Realtime Subscriptions

```dart
class RealtimeTodoService {
  final SupabaseClient _client = Supabase.instance.client;
  RealtimeChannel? _channel;
  
  // Stream of todo changes
  Stream<List<TodoModel>> watchTodos() {
    final controller = StreamController<List<TodoModel>>();
    
    _channel = _client.channel('todos_channel')
      .onPostgresChanges(
        event: PostgresChangeEvent.all,
        schema: 'public',
        table: 'todos',
        filter: PostgresChangeFilter(
          type: PostgresChangeFilterType.eq,
          column: 'user_id',
          value: _client.auth.currentUser!.id,
        ),
        callback: (payload) {
          // Refetch todos on any change
          _fetchAndEmit(controller);
        },
      )
      .subscribe();
    
    // Initial fetch
    _fetchAndEmit(controller);
    
    return controller.stream;
  }
  
  Future<void> _fetchAndEmit(StreamController<List<TodoModel>> controller) async {
    final response = await _client
        .from('todos')
        .select()
        .order('created_at', ascending: false);
    
    final todos = (response as List)
        .map((e) => TodoModel.fromJson(e))
        .toList();
    
    controller.add(todos);
  }
  
  void dispose() {
    _channel?.unsubscribe();
  }
}
```

### Step 5: Supabase Storage

```dart
class SupabaseStorageService {
  final SupabaseClient _client = Supabase.instance.client;
  
  Future<String> uploadProfileImage({
    required String userId,
    required File imageFile,
  }) async {
    final fileExt = imageFile.path.split('.').last;
    final fileName = '$userId/avatar.$fileExt';
    
    await _client.storage
        .from('avatars')
        .upload(
          fileName,
          imageFile,
          fileOptions: const FileOptions(
            cacheControl: '3600',
            upsert: true,
          ),
        );
    
    return _client.storage.from('avatars').getPublicUrl(fileName);
  }
  
  Future<void> deleteProfileImage(String userId) async {
    await _client.storage.from('avatars').remove(['$userId/avatar.jpg']);
  }
  
  // Signed URL (for private buckets)
  Future<String> getSignedUrl(String path) async {
    final response = await _client.storage
        .from('private-files')
        .createSignedUrl(path, 3600); // Valid for 1 hour
    
    return response;
  }
}
```

### Step 6: Row Level Security (RLS)

```sql
-- Example RLS policies for todos table

-- Enable RLS
ALTER TABLE todos ENABLE ROW LEVEL SECURITY;

-- Users can only see their own todos
CREATE POLICY "Users can view own todos"
ON todos FOR SELECT
USING (auth.uid() = user_id);

-- Users can only insert their own todos
CREATE POLICY "Users can insert own todos"
ON todos FOR INSERT
WITH CHECK (auth.uid() = user_id);

-- Users can only update their own todos
CREATE POLICY "Users can update own todos"
ON todos FOR UPDATE
USING (auth.uid() = user_id);

-- Users can only delete their own todos
CREATE POLICY "Users can delete own todos"
ON todos FOR DELETE
USING (auth.uid() = user_id);
```

## Best Practices

### ✅ Do This

- ✅ Always enable Row Level Security on production tables
- ✅ Use `.maybeSingle()` instead of `.single()` when record might not exist
- ✅ Implement proper error handling for Supabase exceptions
- ✅ Use typed models with `fromJson`/`toJson` serialization
- ✅ Unsubscribe from Realtime channels when disposing widgets

### ❌ Avoid This

- ❌ Don't expose `service_role` key in client apps—only use `anon` key
- ❌ Don't skip RLS—it's your security layer
- ❌ Don't make unlimited queries—always use `.limit()`
- ❌ Don't store credentials in code—use environment variables

## Common Pitfalls

**Problem:** RLS blocking all queries
**Solution:** Ensure user is authenticated and RLS policies match your use case. Test policies in Supabase Dashboard SQL editor.

**Problem:** Realtime not receiving updates
**Solution:** Enable Realtime for the table in Supabase Dashboard (Database → Replication).

**Problem:** OAuth redirect not working on mobile
**Solution:** Configure deep link scheme in `AndroidManifest.xml` and `Info.plist`, and add redirect URL in Supabase Dashboard.

## Related Skills

- `@senior-flutter-developer` - Core Flutter patterns
- `@senior-supabase-developer` - Advanced Supabase patterns
- `@flutter-riverpod-specialist` - State management with Supabase
- `@postgresql-specialist` - Advanced PostgreSQL queries

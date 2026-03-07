---
description: Integrasi Supabase sebagai alternative backend — Authentication, PostgreSQL Database, Realtime subscriptions, dan Storage.
---
# Workflow: Supabase Integration

// turbo-all

## Overview

Integrasi Supabase sebagai alternative backend: Authentication, PostgreSQL
Database, Realtime subscriptions, dan Storage. Mencakup setup lengkap
dengan Row Level Security (RLS).


## Prerequisites

- Project setup dari `01_project_setup.md` selesai
- Supabase account (supabase.com)
- Supabase project created


## Agent Behavior

- **Tanya Supabase URL dan anon key** — jangan hardcode, gunakan env vars.
- **Selalu enable RLS** — default deny all.
- **Setup realtime** hanya untuk tables yang butuh live updates.
- **Gunakan `String.fromEnvironment`** untuk config values.


## Recommended Skills

- `senior-supabase-developer` — Supabase services
- `postgresql-specialist` — Database & RLS
- `python-async-specialist` — Concurrency & Parallelism (Dart isolates equivalent)


## Workflow Steps

### Step 1: Supabase Project Setup

```yaml
dependencies:
  supabase_flutter: ^2.3.0
```

```dart
// core/config/app_config.dart
class AppConfig {
  static const String supabaseUrl =
      String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue:
        'https://your-project.supabase.co',
  );

  static const String supabaseAnonKey =
      String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'your-anon-key',
  );
}

// bootstrap/bootstrap.dart
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: AppConfig.supabaseUrl,
    anonKey: AppConfig.supabaseAnonKey,
    debug: kDebugMode,
  );

  runApp(const ProviderScope(child: MyApp()));
}

final supabase = Supabase.instance.client;
```

### Step 2: Supabase Authentication

```dart
// features/auth/data/repositories/supabase_auth_repository.dart
class SupabaseAuthRepository
    implements AuthRepository {
  final SupabaseClient _supabase;

  SupabaseAuthRepository({
    SupabaseClient? supabase,
  }) : _supabase =
            supabase ?? Supabase.instance.client;

  @override
  Stream<AuthState> get authStateChanges =>
      _supabase.auth.onAuthStateChange;

  @override
  Future<Result<User>>
      signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      final response = await _supabase.auth
          .signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null) {
        return const Err(
          AuthFailure('Sign in failed'),
        );
      }

      return Success(response.user!);
    } on AuthException catch (e) {
      return Err(AuthFailure(e.message));
    }
  }

  @override
  Future<Result<void>>
      signInWithMagicLink(String email) async {
    try {
      await _supabase.auth.signInWithOtp(
        email: email,
        shouldCreateUser: false,
      );
      return const Success(null);
    } on AuthException catch (e) {
      return Err(AuthFailure(e.message));
    }
  }

  @override
  Future<Result<User>>
      signInWithOAuth(String provider) async {
    try {
      final response = await _supabase.auth
          .signInWithOAuth(
        OAuthProvider.values.byName(provider),
        redirectTo:
            'io.supabase.yourapp://callback',
      );

      if (!response) {
        return const Err(
          AuthFailure('OAuth sign in failed'),
        );
      }

      await for (final state
          in _supabase.auth.onAuthStateChange) {
        if (state.event ==
                AuthChangeEvent.signedIn &&
            state.session != null) {
          return Success(state.session!.user);
        }
      }

      return const Err(
        AuthFailure('OAuth sign in timeout'),
      );
    } on AuthException catch (e) {
      return Err(AuthFailure(e.message));
    }
  }

  @override
  Future<Result<void>> signOut() async {
    try {
      await _supabase.auth.signOut();
      return const Success(null);
    } on AuthException catch (e) {
      return Err(AuthFailure(e.message));
    }
  }

  @override
  User? get currentUser =>
      _supabase.auth.currentUser;

  @override
  Session? get currentSession =>
      _supabase.auth.currentSession;
}
```

### Step 3: PostgreSQL Database Operations

```dart
// features/product/data/datasources/product_supabase_ds.dart
class ProductSupabaseDataSource
    implements ProductRemoteDataSource {
  final SupabaseClient _supabase;

  ProductSupabaseDataSource({
    SupabaseClient? supabase,
  }) : _supabase =
            supabase ?? Supabase.instance.client;

  SupabaseQueryBuilder get _productsTable =>
      _supabase.from('products');

  @override
  Future<List<ProductModel>> getProducts() async {
    final response = await _productsTable
        .select()
        .order('created_at', ascending: false);

    return (response as List)
        .map((json) => ProductModel.fromJson(json))
        .toList();
  }

  @override
  Future<ProductModel> getProductById(
    String id,
  ) async {
    final response = await _productsTable
        .select()
        .eq('id', id)
        .single();

    return ProductModel.fromJson(response);
  }

  @override
  Future<ProductModel> createProduct(
    ProductModel product,
  ) async {
    final response = await _productsTable
        .insert({
          'name': product.name,
          'price': product.price,
          'description': product.description,
          'user_id':
              _supabase.auth.currentUser!.id,
        })
        .select()
        .single();

    return ProductModel.fromJson(response);
  }

  @override
  Future<ProductModel> updateProduct(
    ProductModel product,
  ) async {
    final response = await _productsTable
        .update({
          'name': product.name,
          'price': product.price,
          'description': product.description,
          'updated_at':
              DateTime.now().toIso8601String(),
        })
        .eq('id', product.id)
        .select()
        .single();

    return ProductModel.fromJson(response);
  }

  @override
  Future<void> deleteProduct(String id) async {
    await _productsTable.delete().eq('id', id);
  }

  Future<List<ProductModel>> searchProducts(
    String query,
  ) async {
    final response = await _productsTable
        .select()
        .ilike('name', '%$query%')
        .order('created_at', ascending: false);

    return (response as List)
        .map((json) => ProductModel.fromJson(json))
        .toList();
  }

  Future<List<ProductModel>>
      getProductsWithPagination({
    required int page,
    required int limit,
  }) async {
    final response = await _productsTable
        .select()
        .range(
          (page - 1) * limit,
          page * limit - 1,
        )
        .order('created_at', ascending: false);

    return (response as List)
        .map((json) => ProductModel.fromJson(json))
        .toList();
  }
}
```

### Step 4: Realtime Subscriptions

```dart
// features/product/data/datasources/product_realtime_ds.dart
class ProductRealtimeDataSource {
  final SupabaseClient _supabase;
  RealtimeChannel? _channel;

  ProductRealtimeDataSource({
    SupabaseClient? supabase,
  }) : _supabase =
            supabase ?? Supabase.instance.client;

  Stream<List<ProductModel>> watchProducts() {
    final initialFuture = _supabase
        .from('products')
        .select()
        .order('created_at', ascending: false)
        .then((response) => (response as List)
            .map((json) =>
                ProductModel.fromJson(json))
            .toList());

    _channel = _supabase
        .channel('products')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'products',
          callback: (payload) {
            // Handle realtime updates
          },
        )
        .subscribe();

    return Stream.fromFuture(initialFuture);
  }

  void unsubscribe() {
    _channel?.unsubscribe();
    _channel = null;
  }
}
```

### Step 5: Supabase Storage

```dart
// core/storage/supabase_storage_service.dart
class SupabaseStorageService {
  final SupabaseClient _supabase;

  SupabaseStorageService({
    SupabaseClient? supabase,
  }) : _supabase =
            supabase ?? Supabase.instance.client;

  Future<Result<String>> uploadFile({
    required File file,
    required String bucket,
    required String path,
  }) async {
    try {
      final fileBytes = await file.readAsBytes();

      await _supabase.storage
          .from(bucket)
          .uploadBinary(
        path,
        fileBytes,
        fileOptions:
            const FileOptions(upsert: true),
      );

      final publicUrl = _supabase.storage
          .from(bucket)
          .getPublicUrl(path);

      return Success(publicUrl);
    } on StorageException catch (e) {
      return Err(StorageFailure(e.message));
    }
  }

  Future<Result<String>> getSignedUrl({
    required String bucket,
    required String path,
    int expiresIn = 60,
  }) async {
    try {
      final signedUrl = await _supabase.storage
          .from(bucket)
          .createSignedUrl(path, expiresIn);

      return Success(signedUrl);
    } on StorageException catch (e) {
      return Err(StorageFailure(e.message));
    }
  }

  Future<Result<void>> deleteFile({
    required String bucket,
    required String path,
  }) async {
    try {
      await _supabase.storage
          .from(bucket)
          .remove([path]);
      return const Success(null);
    } on StorageException catch (e) {
      return Err(StorageFailure(e.message));
    }
  }
}
```

### Step 6: RLS Policies

```sql
-- Enable RLS
ALTER TABLE products
    ENABLE ROW LEVEL SECURITY;

-- Users can read all products
CREATE POLICY "Products are viewable by authenticated"
ON products FOR SELECT
TO authenticated
USING (true);

-- Users can create their own products
CREATE POLICY "Users can create own products"
ON products FOR INSERT
TO authenticated
WITH CHECK (auth.uid() = user_id);

-- Users can update their own products
CREATE POLICY "Users can update own products"
ON products FOR UPDATE
TO authenticated
USING (auth.uid() = user_id)
WITH CHECK (auth.uid() = user_id);

-- Users can delete their own products
CREATE POLICY "Users can delete own products"
ON products FOR DELETE
TO authenticated
USING (auth.uid() = user_id);

-- Performance: Index on policy columns
CREATE INDEX idx_products_user_id
    ON products(user_id);
```

### Step 7: Isolate Parsing & Background Sync

Sama halnya dengan REST API, jika query mereturn record yang sangat besar (ribuan rows), pindahkan proses konversi JSON ke `Isolate.run()` agar tidak menyebabkan frame drop.

```dart
// features/product/data/datasources/product_supabase_ds.dart
import 'dart:isolate';

  Future<List<ProductModel>> getMassiveProducts() async {
    final response = await _productsTable.select().limit(10000);

    // Casting dynamic response ke format List<Map> yang didukung native
    final rawData = List<Map<String, dynamic>>.from(response as List);

    return await Isolate.run(() {
      return rawData.map((json) => ProductModel.fromJson(json)).toList();
    });
  }
```

Jadwalkan sinkronisasi background jika Anda butuh mekanisme hybrid-offline (Supabase saat ini belum memiliki offline persistence official secanggih Firebase).

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
      case 'syncSupabaseTask':
        // Logika sync background misal via SQLite -> Supabase
        break;
    }
    return Future.value(true);
  });
}
```

### Step 8: Test Integration

- Test auth flows
- Test CRUD operations
- Test RLS policies
- Test realtime subscriptions
- Test file upload
- Test background processing (Isolate dan periodic sync)


## Success Criteria

- [ ] Supabase initialized dan connected
- [ ] Authentication berfungsi (email, magic link, OAuth)
- [ ] Auth state stream implemented
- [ ] PostgreSQL CRUD operations berfungsi
- [ ] RLS policies configured dan tested
- [ ] Realtime subscriptions berfungsi
- [ ] File upload/download berfungsi
- [ ] Storage RLS policies configured
- [ ] Error handling untuk semua Supabase exceptions
- [ ] Heavy database query diparsing menggunakan `Isolate.run()`
- [ ] Background sync task terdaftar (opsional memakai workmanager)


## Next Steps

Setelah Supabase integration selesai:
1. Implement comprehensive testing
2. Setup CI/CD pipeline
3. Add analytics tracking
4. Monitor performance dengan Supabase Dashboard

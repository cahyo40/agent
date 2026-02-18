# Workflow: Supabase Integration

## Overview

Integrasi Supabase sebagai alternative backend: Authentication, PostgreSQL Database, Realtime subscriptions, dan Storage. Workflow ini mencakup setup lengkap dengan Row Level Security (RLS).

## Output Location

**Base Folder:** `sdlc/flutter-riverpod/05-supabase-integration/`

**Output Files:**
- `supabase-setup.md` - Setup Supabase project dan Flutter
- `auth/` - Authentication (magic link, OAuth, phone)
- `database/` - PostgreSQL operations dengan RLS
- `realtime/` - Realtime subscriptions
- `storage/` - File storage
- `security/` - RLS policies dan best practices
- `examples/` - Contoh implementasi lengkap

## Prerequisites

- Project setup dari `01_project_setup.md` selesai
- Supabase account (supabase.com)
- Supabase project created

## Deliverables

### 1. Supabase Project Setup

**Description:** Setup Supabase project dan konfigurasi Flutter app.

**Recommended Skills:** `senior-flutter-developer`, `senior-supabase-developer`

**Instructions:**
1. **Install Dependencies:**
   ```yaml
   dependencies:
     supabase_flutter: ^2.3.0
   ```

2. **Initialize Supabase:**
   ```dart
   // bootstrap/bootstrap.dart
   import 'package:supabase_flutter/supabase_flutter.dart';
   
   Future<void> bootstrap() async {
     WidgetsFlutterBinding.ensureInitialized();
     
     await Supabase.initialize(
       url: 'https://your-project.supabase.co',
       anonKey: 'your-anon-key',
       debug: kDebugMode,
     );
     
     runApp(const ProviderScope(child: MyApp()));
   }
   ```

3. **Environment Configuration:**
   - Jangan hardcode URL dan API key
   - Gunakan environment variables atau flutter_dotenv

**Output Format:**
```dart
// core/config/app_config.dart
class AppConfig {
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://your-project.supabase.co',
  );
  
  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'your-anon-key',
  );
}

// bootstrap/bootstrap.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/config/app_config.dart';

Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Supabase.initialize(
    url: AppConfig.supabaseUrl,
    anonKey: AppConfig.supabaseAnonKey,
    debug: kDebugMode,
  );
  
  // Enable offline persistence untuk PostgreSQL
  // Supabase menggunakan PostgREST dengan caching built-in
  
  runApp(const ProviderScope(child: MyApp()));
}

// Global Supabase client access
final supabase = Supabase.instance.client;
```

---

### 2. Supabase Authentication

**Description:** Implementasi Supabase Auth dengan magic link, OAuth providers, dan phone auth.

**Recommended Skills:** `senior-flutter-developer`, `senior-supabase-developer`

**Instructions:**
1. **Auth Methods:**
   - Email/password (traditional)
   - Magic link (passwordless)
   - OAuth (Google, Apple, GitHub, etc.)
   - Phone OTP

2. **Auth State Management:**
   - Auth state stream
   - Session persistence
   - Auto-refresh token

3. **Auth Repository:**
   - Abstract contract
   - Supabase implementation

**Output Format:**
```dart
// features/auth/domain/repositories/auth_repository.dart
abstract class AuthRepository {
  Stream<AuthState> get authStateChanges;
  Future<Either<Failure, User>> signInWithEmailAndPassword(String email, String password);
  Future<Either<Failure, Unit>> signInWithMagicLink(String email);
  Future<Either<Failure, User>> signInWithOAuth(String provider);
  Future<Either<Failure, User>> signUp(String email, String password);
  Future<Either<Failure, Unit>> signOut();
  User? get currentUser;
  Session? get currentSession;
}

// features/auth/data/repositories/supabase_auth_repository.dart
class SupabaseAuthRepository implements AuthRepository {
  final SupabaseClient _supabase;
  
  SupabaseAuthRepository({SupabaseClient? supabase})
      : _supabase = supabase ?? Supabase.instance.client;
  
  @override
  Stream<AuthState> get authStateChanges => 
      _supabase.auth.onAuthStateChange.map((data) => data);
  
  @override
  Future<Either<Failure, User>> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      
      if (response.user == null) {
        return const Left(AuthFailure('Sign in failed'));
      }
      
      return Right(response.user!);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } catch (e) {
      return Left(AuthFailure(e.toString()));
    }
  }
  
  @override
  Future<Either<Failure, Unit>> signInWithMagicLink(String email) async {
    try {
      await _supabase.auth.signInWithOtp(
        email: email,
        shouldCreateUser: false,
      );
      
      return const Right(unit);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } catch (e) {
      return Left(AuthFailure(e.toString()));
    }
  }
  
  @override
  Future<Either<Failure, User>> signInWithOAuth(String provider) async {
    try {
      final response = await _supabase.auth.signInWithOAuth(
        OAuthProvider.values.byName(provider),
        redirectTo: 'io.supabase.yourapp://callback',
      );
      
      if (!response) {
        return const Left(AuthFailure('OAuth sign in failed'));
      }
      
      // Wait for auth state change
      await for (final state in _supabase.auth.onAuthStateChange) {
        if (state.event == AuthChangeEvent.signedIn && state.session != null) {
          return Right(state.session!.user);
        }
      }
      
      return const Left(AuthFailure('OAuth sign in timeout'));
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } catch (e) {
      return Left(AuthFailure(e.toString()));
    }
  }
  
  @override
  Future<Either<Failure, User>> signUp(String email, String password) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
      );
      
      if (response.user == null) {
        return const Left(AuthFailure('Sign up failed'));
      }
      
      return Right(response.user!);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } catch (e) {
      return Left(AuthFailure(e.toString()));
    }
  }
  
  @override
  Future<Either<Failure, Unit>> signOut() async {
    try {
      await _supabase.auth.signOut();
      return const Right(unit);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } catch (e) {
      return Left(AuthFailure(e.toString()));
    }
  }
  
  @override
  User? get currentUser => _supabase.auth.currentUser;
  
  @override
  Session? get currentSession => _supabase.auth.currentSession;
}

// Controller
@riverpod
class AuthController extends _$AuthController {
  @override
  Stream<AuthState> build() {
    final repository = ref.watch(authRepositoryProvider);
    return repository.authStateChanges;
  }
  
  Future<void> signInWithEmailAndPassword(String email, String password) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(authRepositoryProvider);
      final result = await repository.signInWithEmailAndPassword(email, password);
      return result.fold(
        (failure) => throw failure,
        (user) => user,
      );
    });
  }
  
  Future<void> sendMagicLink(String email) async {
    final repository = ref.read(authRepositoryProvider);
    final result = await repository.signInWithMagicLink(email);
    
    result.fold(
      (failure) => throw failure,
      (_) {
        // Show success message: "Check your email!"
      },
    );
  }
}
```

---

### 3. PostgreSQL Database Operations

**Description:** CRUD operations dengan Supabase PostgreSQL dan Row Level Security.

**Recommended Skills:** `senior-flutter-developer`, `senior-supabase-developer`, `senior-database-engineer-sql`

**Instructions:**
1. **Database Schema:**
   - Design tables di Supabase Dashboard
   - Setup relationships
   - Configure indexes

2. **RLS Policies:**
   - Enable RLS per table
   - Create policies untuk read/write
   - Authenticated vs Anonymous access

3. **Repository Pattern:**
   - CRUD operations
   - Query dengan filters
   - Joins dan relationships
   - Pagination

**Output Format:**
```dart
// features/product/data/datasources/product_supabase_ds.dart
class ProductSupabaseDataSource implements ProductRemoteDataSource {
  final SupabaseClient _supabase;
  
  ProductSupabaseDataSource({SupabaseClient? supabase})
      : _supabase = supabase ?? Supabase.instance.client;
  
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
  Future<ProductModel> getProductById(String id) async {
    final response = await _productsTable
        .select()
        .eq('id', id)
        .single();
    
    return ProductModel.fromJson(response);
  }
  
  @override
  Future<ProductModel> createProduct(ProductModel product) async {
    final response = await _productsTable
        .insert({
          'name': product.name,
          'price': product.price,
          'description': product.description,
          'user_id': _supabase.auth.currentUser!.id,
        })
        .select()
        .single();
    
    return ProductModel.fromJson(response);
  }
  
  @override
  Future<ProductModel> updateProduct(ProductModel product) async {
    final response = await _productsTable
        .update({
          'name': product.name,
          'price': product.price,
          'description': product.description,
          'updated_at': DateTime.now().toIso8601String(),
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
  
  // Advanced queries
  Future<List<ProductModel>> searchProducts(String query) async {
    final response = await _productsTable
        .select()
        .ilike('name', '%$query%')
        .order('created_at', ascending: false);
    
    return (response as List)
        .map((json) => ProductModel.fromJson(json))
        .toList();
  }
  
  Future<List<ProductModel>> getProductsWithPagination({
    required int page,
    required int limit,
  }) async {
    final response = await _productsTable
        .select()
        .range((page - 1) * limit, page * limit - 1)
        .order('created_at', ascending: false);
    
    return (response as List)
        .map((json) => ProductModel.fromJson(json))
        .toList();
  }
  
  // Join dengan table lain
  Future<List<ProductWithUser>> getProductsWithUser() async {
    final response = await _productsTable
        .select('*, users(*)')
        .order('created_at', ascending: false);
    
    return (response as List)
        .map((json) => ProductWithUser.fromJson(json))
        .toList();
  }
}

// SQL untuk RLS Policies (dijalankan di Supabase SQL Editor)
/*
-- Enable RLS
ALTER TABLE products ENABLE ROW LEVEL SECURITY;

-- Policy: Users can read all products
CREATE POLICY "Products are viewable by authenticated users"
ON products FOR SELECT
TO authenticated
USING (true);

-- Policy: Users can only insert their own products
CREATE POLICY "Users can create their own products"
ON products FOR INSERT
TO authenticated
WITH CHECK (auth.uid() = user_id);

-- Policy: Users can only update their own products
CREATE POLICY "Users can update their own products"
ON products FOR UPDATE
TO authenticated
USING (auth.uid() = user_id)
WITH CHECK (auth.uid() = user_id);

-- Policy: Users can only delete their own products
CREATE POLICY "Users can delete their own products"
ON products FOR DELETE
TO authenticated
USING (auth.uid() = user_id);

-- Policy: Allow anonymous read (optional)
CREATE POLICY "Products are viewable by everyone"
ON products FOR SELECT
TO anon
USING (true);
*/
```

---

### 4. Realtime Subscriptions

**Description:** Real-time updates dengan Supabase Realtime.

**Recommended Skills:** `senior-flutter-developer`, `senior-supabase-developer`

**Instructions:**
1. **Setup Realtime:**
   - Enable realtime di Supabase Dashboard
   - Subscribe ke table changes
   - Handle INSERT, UPDATE, DELETE events

2. **Channel Management:**
   - Subscribe/unsubscribe
   - Broadcast events
   - Presence tracking

**Output Format:**
```dart
// features/product/data/datasources/product_realtime_ds.dart
class ProductRealtimeDataSource {
  final SupabaseClient _supabase;
  RealtimeChannel? _channel;
  
  ProductRealtimeDataSource({SupabaseClient? supabase})
      : _supabase = supabase ?? Supabase.instance.client;
  
  Stream<List<ProductModel>> watchProducts() {
    // Initial fetch
    final initialFuture = _supabase
        .from('products')
        .select()
        .order('created_at', ascending: false)
        .then((response) => (response as List)
            .map((json) => ProductModel.fromJson(json))
            .toList());
    
    // Subscribe to realtime changes
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
    
    // Combine initial data dengan realtime stream
    return Stream.fromFuture(initialFuture);
  }
  
  Stream<ProductModel> watchProduct(String productId) {
    final controller = StreamController<ProductModel>.broadcast();
    
    // Initial fetch
    _supabase
        .from('products')
        .select()
        .eq('id', productId)
        .single()
        .then((response) {
      controller.add(ProductModel.fromJson(response));
    });
    
    // Subscribe to changes on this specific product
    _channel = _supabase
        .channel('product_$productId')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'products',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'id',
            value: productId,
          ),
          callback: (payload) {
            if (payload.newRecord != null) {
              controller.add(ProductModel.fromJson(payload.newRecord!));
            }
          },
        )
        .subscribe();
    
    return controller.stream;
  }
  
  void unsubscribe() {
    _channel?.unsubscribe();
    _channel = null;
  }
}

// Controller dengan realtime
@riverpod
class RealtimeProductController extends _$RealtimeProductController {
  ProductRealtimeDataSource? _dataSource;
  StreamSubscription? _subscription;
  
  @override
  Stream<List<Product>> build() {
    _dataSource = ref.watch(productRealtimeDataSourceProvider);
    
    // Cleanup on dispose
    ref.onDispose(() {
      _subscription?.cancel();
      _dataSource?.unsubscribe();
    });
    
    return _dataSource!.watchProducts().map(
      (models) => models.map((m) => m.toEntity()).toList(),
    );
  }
  
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    // Realtime akan otomatis update
  }
}
```

---

### 5. Supabase Storage

**Description:** File storage dengan Supabase Storage.

**Recommended Skills:** `senior-flutter-developer`, `senior-supabase-developer`

**Instructions:**
1. **Upload Files:**
   - Image upload dengan compression
   - Progress tracking
   - Upload to specific bucket

2. **Download Files:**
   - Get signed URLs
   - Cache management

**Output Format:**
```dart
// core/storage/supabase_storage_service.dart
class SupabaseStorageService {
  final SupabaseClient _supabase;
  
  SupabaseStorageService({SupabaseClient? supabase})
      : _supabase = supabase ?? Supabase.instance.client;
  
  Future<Either<Failure, String>> uploadFile({
    required File file,
    required String bucket,
    required String path,
    void Function(double progress)? onProgress,
  }) async {
    try {
      final fileBytes = await file.readAsBytes();
      
      await _supabase.storage.from(bucket).uploadBinary(
        path,
        fileBytes,
        fileOptions: const FileOptions(upsert: true),
      );
      
      final publicUrl = _supabase.storage.from(bucket).getPublicUrl(path);
      
      return Right(publicUrl);
    } on StorageException catch (e) {
      return Left(StorageFailure(e.message));
    } catch (e) {
      return Left(StorageFailure(e.toString()));
    }
  }
  
  Future<Either<Failure, String>> uploadImage({
    required File imageFile,
    required String bucket,
    required String folder,
    int quality = 85,
  }) async {
    try {
      // Compress image
      final compressedBytes = await FlutterImageCompress.compressWithFile(
        imageFile.absolute.path,
        quality: quality,
      );
      
      if (compressedBytes == null) {
        return const Left(StorageFailure('Failed to compress image'));
      }
      
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      final path = '$folder/$fileName';
      
      await _supabase.storage.from(bucket).uploadBinary(
        path,
        compressedBytes,
        fileOptions: const FileOptions(contentType: 'image/jpeg'),
      );
      
      final publicUrl = _supabase.storage.from(bucket).getPublicUrl(path);
      
      return Right(publicUrl);
    } on StorageException catch (e) {
      return Left(StorageFailure(e.message));
    } catch (e) {
      return Left(StorageFailure(e.toString()));
    }
  }
  
  Future<Either<Failure, String>> getSignedUrl({
    required String bucket,
    required String path,
    int expiresIn = 60,
  }) async {
    try {
      final signedUrl = await _supabase.storage
          .from(bucket)
          .createSignedUrl(path, expiresIn);
      
      return Right(signedUrl);
    } on StorageException catch (e) {
      return Left(StorageFailure(e.message));
    }
  }
  
  Future<Either<Failure, Unit>> deleteFile({
    required String bucket,
    required String path,
  }) async {
    try {
      await _supabase.storage.from(bucket).remove([path]);
      return const Right(unit);
    } on StorageException catch (e) {
      return Left(StorageFailure(e.message));
    }
  }
}

// Storage RLS Policy
/*
-- Allow authenticated users to upload to their own folder
CREATE POLICY "Users can upload to their own folder"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (
  bucket_id = 'avatars' AND
  (storage.foldername(name))[1] = auth.uid()::text
);

-- Allow users to read all public files
CREATE POLICY "Anyone can view public files"
ON storage.objects FOR SELECT
TO anon
USING (bucket_id = 'public');
*/
```

## Workflow Steps

1. **Setup Supabase Project**
   - Create project di supabase.com
   - Copy URL dan anon key
   - Setup environment variables
   - Initialize Supabase di Flutter

2. **Configure Authentication**
   - Enable auth methods (email, magic link, OAuth)
   - Setup OAuth providers (Google, Apple, etc.)
   - Implement auth repository
   - Create auth controller dengan Riverpod

3. **Design Database Schema**
   - Create tables di Supabase Dashboard
   - Setup relationships dan foreign keys
   - Add indexes untuk performance
   - Enable RLS (Row Level Security)

4. **Create RLS Policies**
   - Policies untuk authenticated users
   - Policies untuk anon users (if needed)
   - Test policies dengan different users
   - Validate security

5. **Implement Repository Pattern**
   - CRUD operations
   - Advanced queries (search, filters)
   - Pagination
   - Joins dengan related tables

6. **Setup Realtime**
   - Enable realtime untuk tables
   - Subscribe ke changes
   - Handle INSERT, UPDATE, DELETE events
   - Update UI secara real-time

7. **Configure Storage**
   - Create storage buckets
   - Setup RLS untuk storage
   - Implement file upload/download
   - Add image compression

8. **Test Integration**
   - Test auth flows
   - Test CRUD operations
   - Test RLS policies
   - Test realtime subscriptions
   - Test file upload

## Success Criteria

- [ ] Supabase initialized dan connected
- [ ] Authentication berfungsi (email/password, magic link, OAuth)
- [ ] Auth state stream implemented
- [ ] PostgreSQL CRUD operations berfungsi
- [ ] RLS policies configured dan tested
- [ ] Realtime subscriptions berfungsi
- [ ] File upload/download dengan Supabase Storage berfungsi
- [ ] Storage RLS policies configured
- [ ] All operations respect RLS policies
- [ ] Error handling implemented untuk semua Supabase exceptions

## RLS Best Practices

### PostgreSQL RLS Policies
```sql
-- 1. Selalu enable RLS untuk semua tables
ALTER TABLE products ENABLE ROW LEVEL SECURITY;

-- 2. Default deny all
CREATE POLICY "Deny all" ON products FOR ALL TO PUBLIC USING (false);

-- 3. Specific policies untuk setiap operation
CREATE POLICY "Select own products" 
ON products FOR SELECT 
USING (auth.uid() = user_id);

CREATE POLICY "Insert own products"
ON products FOR INSERT
WITH CHECK (auth.uid() = user_id);

-- 4. Use functions untuk complex logic
CREATE OR REPLACE FUNCTION is_product_owner(product_id uuid)
RETURNS BOOLEAN AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1 FROM products 
    WHERE id = product_id AND user_id = auth.uid()
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 5. Performance: Index pada columns yang digunakan di policies
CREATE INDEX idx_products_user_id ON products(user_id);
```

## Next Steps

Setelah Supabase integration selesai:
1. Implement comprehensive testing
2. Setup CI/CD pipeline
3. Add analytics tracking
4. Monitor performance dengan Supabase Dashboard
5. Setup backup dan disaster recovery

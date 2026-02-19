---
description: Integrasi Supabase sebagai alternative backend: Authentication, PostgreSQL Database, Realtime subscriptions, dan Storage. (Part 2/4)
---
# Workflow: Supabase Integration (Part 2/4)

> **Navigation:** This workflow is split into 4 parts.

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

## Deliverables

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

## Deliverables

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


---
description: Integrasi Supabase sebagai alternative backend dengan flutter_bloc state management.
---
# Workflow: Supabase Integration — Flutter BLoC

// turbo-all

## Overview

Integrasi Supabase (PostgreSQL + Auth + Realtime + Storage) dengan BLoC architecture:
- **Supabase Auth** → `AuthBloc` dengan `StreamSubscription` ke `onAuthStateChange`
- **PostgreSQL CRUD** → Repository pattern + `ProductBloc`
- **Realtime** → `RealtimeProductBloc` dengan `RealtimeChannel`
- **Storage** → `UploadCubit` untuk file uploads

**Perbedaan utama dari versi Riverpod:**
- Tidak ada `ProviderScope` — Supabase init di `bootstrap()` sebelum `runApp()`
- Auth state via `AuthBloc` dengan `StreamSubscription` (di-cancel di `close()`)
- Realtime channel di-subscribe di Bloc constructor, `unsubscribe()` di `close()`
- DI via `get_it` + `injectable`, bukan Riverpod providers


## Prerequisites

- Project setup dari `01_project_setup.md` selesai
- Supabase project dibuat di supabase.com
- `SUPABASE_URL` dan `SUPABASE_ANON_KEY` tersedia


## Agent Behavior

- **Init Supabase** di `bootstrap()` sebelum `runApp()`.
- **AuthBloc**: listen ke `onAuthStateChange` stream via `StreamSubscription`.
- **Cancel subscriptions** di `close()` untuk prevent memory leaks.
- **RLS policies** harus dikonfigurasi di Supabase dashboard.
- **Jangan pakai `dartz`** — gunakan `Result<T>` sealed class.
- **Run code generation** setelah semua file dibuat.


## Recommended Skills

- `senior-supabase-developer` — Supabase + BLoC
- `senior-flutter-developer` — Flutter architecture


## Dependencies

```yaml
dependencies:
  supabase_flutter: ^2.5.0
  flutter_bloc: ^8.1.4
  equatable: ^2.0.5
  injectable: ^2.3.2
  get_it: ^7.6.7
  json_annotation: ^4.8.1

dev_dependencies:
  injectable_generator: ^2.4.1
  build_runner: ^2.4.8
  json_serializable: ^6.7.1
```


## Workflow Steps

### Step 1: Supabase Setup

```dart
// lib/app/bootstrap.dart
Future<void> bootstrap({required Widget app}) async {
  WidgetsFlutterBinding.ensureInitialized();

  // Init Supabase SEBELUM get_it
  await Supabase.initialize(
    url: const String.fromEnvironment('SUPABASE_URL'),
    anonKey: const String.fromEnvironment('SUPABASE_ANON_KEY'),
    authOptions: const FlutterAuthClientOptions(
      authFlowType: AuthFlowType.pkce,
    ),
  );

  await configureDependencies();
  runApp(app);
}

// lib/main.dart
void main() => bootstrap(app: const App());
```

```sql
-- Supabase SQL: Row Level Security (RLS)
-- Jalankan di Supabase SQL Editor

-- Products table
CREATE TABLE products (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  name TEXT NOT NULL,
  description TEXT,
  price DECIMAL(10,2) NOT NULL,
  stock INTEGER DEFAULT 0,
  is_active BOOLEAN DEFAULT true,
  user_id UUID REFERENCES auth.users(id),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Enable RLS
ALTER TABLE products ENABLE ROW LEVEL SECURITY;

-- Policies
CREATE POLICY "Users can view active products" ON products
  FOR SELECT USING (is_active = true);

CREATE POLICY "Users can manage their own products" ON products
  FOR ALL USING (auth.uid() = user_id);
```


### Step 2: AuthBloc (Supabase Auth + Stream)

```dart
// features/auth/presentation/bloc/auth_event.dart
part of 'auth_bloc.dart';

sealed class AuthEvent extends Equatable {
  const AuthEvent();
  @override
  List<Object?> get props => [];
}

final class AuthStarted extends AuthEvent { const AuthStarted(); }
final class AuthStateChanged extends AuthEvent {
  final AuthState supabaseState;
  const AuthStateChanged(this.supabaseState);
  @override
  List<Object?> get props => [supabaseState];
}
final class AuthSignInWithEmail extends AuthEvent {
  final String email;
  final String password;
  const AuthSignInWithEmail({required this.email, required this.password});
  @override
  List<Object?> get props => [email, password];
}
final class AuthSignUpWithEmail extends AuthEvent {
  final String email;
  final String password;
  const AuthSignUpWithEmail({required this.email, required this.password});
  @override
  List<Object?> get props => [email, password];
}
final class AuthSignOut extends AuthEvent { const AuthSignOut(); }

// features/auth/presentation/bloc/auth_state.dart
part of 'auth_bloc.dart';

sealed class AppAuthState extends Equatable {
  const AppAuthState();
  @override
  List<Object?> get props => [];
}

final class AppAuthInitial extends AppAuthState { const AppAuthInitial(); }
final class AppAuthAuthenticated extends AppAuthState {
  final User user;
  const AppAuthAuthenticated(this.user);
  @override
  List<Object?> get props => [user];
}
final class AppAuthUnauthenticated extends AppAuthState { const AppAuthUnauthenticated(); }
final class AppAuthLoading extends AppAuthState { const AppAuthLoading(); }
final class AppAuthError extends AppAuthState {
  final String message;
  const AppAuthError(this.message);
  @override
  List<Object?> get props => [message];
}

// features/auth/presentation/bloc/auth_bloc.dart
import 'dart:async';
import 'package:equatable/equatable.dart' hide AuthState;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'auth_event.dart';
part 'auth_state.dart';

@singleton
class AuthBloc extends Bloc<AuthEvent, AppAuthState> {
  final SupabaseClient _supabase;
  StreamSubscription<AuthState>? _authSubscription;

  AuthBloc({required SupabaseClient supabase})
      : _supabase = supabase,
        super(const AppAuthInitial()) {
    on<AuthStarted>(_onAuthStarted);
    on<AuthStateChanged>(_onAuthStateChanged);
    on<AuthSignInWithEmail>(_onSignIn);
    on<AuthSignUpWithEmail>(_onSignUp);
    on<AuthSignOut>(_onSignOut);
  }

  void _onAuthStarted(AuthStarted event, Emitter<AppAuthState> emit) {
    // Check current session
    final session = _supabase.auth.currentSession;
    if (session != null) {
      emit(AppAuthAuthenticated(session.user));
    } else {
      emit(const AppAuthUnauthenticated());
    }

    // Subscribe ke auth state changes
    _authSubscription = _supabase.auth.onAuthStateChange.listen((data) {
      add(AuthStateChanged(data));
    });
  }

  void _onAuthStateChanged(
    AuthStateChanged event,
    Emitter<AppAuthState> emit,
  ) {
    final user = event.supabaseState.session?.user;
    if (user != null) {
      emit(AppAuthAuthenticated(user));
    } else {
      emit(const AppAuthUnauthenticated());
    }
  }

  Future<void> _onSignIn(
    AuthSignInWithEmail event,
    Emitter<AppAuthState> emit,
  ) async {
    emit(const AppAuthLoading());
    try {
      await _supabase.auth.signInWithPassword(
        email: event.email,
        password: event.password,
      );
      // State di-update via AuthStateChanged dari stream
    } on AuthException catch (e) {
      emit(AppAuthError(e.message));
    }
  }

  Future<void> _onSignUp(
    AuthSignUpWithEmail event,
    Emitter<AppAuthState> emit,
  ) async {
    emit(const AppAuthLoading());
    try {
      await _supabase.auth.signUp(
        email: event.email,
        password: event.password,
      );
    } on AuthException catch (e) {
      emit(AppAuthError(e.message));
    }
  }

  Future<void> _onSignOut(
    AuthSignOut event,
    Emitter<AppAuthState> emit,
  ) async {
    await _supabase.auth.signOut();
  }

  @override
  Future<void> close() {
    _authSubscription?.cancel();
    return super.close();
  }
}
```


### Step 3: Repository Pattern

```dart
// features/products/domain/repositories/product_repository.dart
abstract class ProductRepository {
  Future<Result<List<Product>>> getProducts({int? limit, int? offset});
  Future<Result<Product>> getProduct(String id);
  Future<Result<Product>> createProduct(Product product);
  Future<Result<Product>> updateProduct(Product product);
  Future<Result<void>> deleteProduct(String id);
  Stream<List<Product>> watchProducts();
}

// features/products/data/repositories/product_repository_impl.dart
@LazySingleton(as: ProductRepository)
class ProductRepositoryImpl implements ProductRepository {
  final SupabaseClient _supabase;
  static const _table = 'products';

  ProductRepositoryImpl({required SupabaseClient supabase})
      : _supabase = supabase;

  @override
  Future<Result<List<Product>>> getProducts({
    int? limit,
    int? offset,
  }) async {
    try {
      var query = _supabase
          .from(_table)
          .select()
          .eq('is_active', true)
          .order('created_at', ascending: false);

      if (limit != null) query = query.limit(limit) as dynamic;
      if (offset != null) query = query.range(offset, offset + (limit ?? 20) - 1) as dynamic;

      final data = await query as List<dynamic>;
      final products = data
          .map((json) => ProductModel.fromJson(json as Map<String, dynamic>).toEntity())
          .toList();
      return Success(products);
    } on PostgrestException catch (e) {
      return ResultFailure(ServerFailure(message: e.message));
    }
  }

  @override
  Future<Result<Product>> createProduct(Product product) async {
    try {
      final userId = _supabase.auth.currentUser!.id;
      final data = await _supabase
          .from(_table)
          .insert({
            'name': product.name,
            'description': product.description,
            'price': product.price,
            'stock': product.stock,
            'user_id': userId,
          })
          .select()
          .single();
      return Success(ProductModel.fromJson(data).toEntity());
    } on PostgrestException catch (e) {
      return ResultFailure(ServerFailure(message: e.message));
    }
  }

  @override
  Future<Result<void>> deleteProduct(String id) async {
    try {
      await _supabase.from(_table).delete().eq('id', id);
      return const Success(null);
    } on PostgrestException catch (e) {
      return ResultFailure(ServerFailure(message: e.message));
    }
  }

  @override
  Stream<List<Product>> watchProducts() {
    return _supabase
        .from(_table)
        .stream(primaryKey: ['id'])
        .eq('is_active', true)
        .order('created_at', ascending: false)
        .map((data) => data
            .map((json) => ProductModel.fromJson(json).toEntity())
            .toList());
  }
}
```


### Step 4: ProductBloc

```dart
// features/products/presentation/bloc/product_bloc.dart
@injectable
class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final GetProducts _getProducts;
  final CreateProduct _createProduct;
  final DeleteProduct _deleteProduct;

  ProductBloc({
    required GetProducts getProducts,
    required CreateProduct createProduct,
    required DeleteProduct deleteProduct,
  })  : _getProducts = getProducts,
        _createProduct = createProduct,
        _deleteProduct = deleteProduct,
        super(const ProductInitial()) {
    on<LoadProducts>(_onLoadProducts);
    on<CreateProductEvent>(_onCreateProduct);
    on<DeleteProductEvent>(_onDeleteProduct);
  }

  List<Product> _currentProducts = [];

  Future<void> _onLoadProducts(
    LoadProducts event,
    Emitter<ProductState> emit,
  ) async {
    emit(const ProductLoading());
    final result = await _getProducts();
    result.fold(
      (f) => emit(ProductError(f.message)),
      (products) {
        _currentProducts = products;
        emit(ProductLoaded(products));
      },
    );
  }

  Future<void> _onCreateProduct(
    CreateProductEvent event,
    Emitter<ProductState> emit,
  ) async {
    final result = await _createProduct(event.product);
    result.fold(
      (f) => emit(ProductOperationError(
          message: f.message, currentProducts: _currentProducts)),
      (created) {
        _currentProducts = [..._currentProducts, created];
        emit(ProductCreated(product: created, updatedProducts: _currentProducts));
        emit(ProductLoaded(_currentProducts));
      },
    );
  }

  Future<void> _onDeleteProduct(
    DeleteProductEvent event,
    Emitter<ProductState> emit,
  ) async {
    final result = await _deleteProduct(event.id);
    result.fold(
      (f) => emit(ProductOperationError(
          message: f.message, currentProducts: _currentProducts)),
      (_) {
        _currentProducts =
            _currentProducts.where((p) => p.id != event.id).toList();
        emit(ProductDeleted(
            deletedId: event.id, updatedProducts: _currentProducts));
        emit(ProductLoaded(_currentProducts));
      },
    );
  }
}
```


### Step 5: Realtime Bloc

```dart
// features/products/presentation/bloc/realtime_product_bloc.dart
@injectable
class RealtimeProductBloc extends Bloc<RealtimeProductEvent, RealtimeProductState> {
  final SupabaseClient _supabase;
  RealtimeChannel? _channel;

  RealtimeProductBloc({required SupabaseClient supabase})
      : _supabase = supabase,
        super(const RealtimeProductInitial()) {
    on<StartRealtimeListener>(_onStartListener);
    on<RealtimeProductUpdated>(_onProductUpdated);
    on<StopRealtimeListener>(_onStopListener);
  }

  Future<void> _onStartListener(
    StartRealtimeListener event,
    Emitter<RealtimeProductState> emit,
  ) async {
    emit(const RealtimeProductLoading());

    // Load initial data
    final data = await _supabase
        .from('products')
        .select()
        .eq('is_active', true)
        .order('created_at', ascending: false) as List;

    final products = data
        .map((json) => ProductModel.fromJson(json as Map<String, dynamic>).toEntity())
        .toList();

    emit(RealtimeProductLoaded(products));

    // Subscribe ke realtime changes
    _channel = _supabase
        .channel('products:realtime')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'products',
          callback: (payload) {
            add(RealtimeProductUpdated(payload));
          },
        )
        .subscribe();
  }

  void _onProductUpdated(
    RealtimeProductUpdated event,
    Emitter<RealtimeProductState> emit,
  ) {
    final currentState = state;
    if (currentState is! RealtimeProductLoaded) return;

    final payload = event.payload;
    final updatedProducts = List<Product>.from(currentState.products);

    switch (payload.eventType) {
      case PostgresChangeEvent.insert:
        final newProduct = ProductModel.fromJson(
          payload.newRecord as Map<String, dynamic>,
        ).toEntity();
        updatedProducts.insert(0, newProduct);
      case PostgresChangeEvent.update:
        final updated = ProductModel.fromJson(
          payload.newRecord as Map<String, dynamic>,
        ).toEntity();
        final index = updatedProducts.indexWhere((p) => p.id == updated.id);
        if (index != -1) updatedProducts[index] = updated;
      case PostgresChangeEvent.delete:
        final deletedId = payload.oldRecord['id'] as String;
        updatedProducts.removeWhere((p) => p.id == deletedId);
      default:
        break;
    }

    emit(RealtimeProductLoaded(updatedProducts));
  }

  Future<void> _onStopListener(
    StopRealtimeListener event,
    Emitter<RealtimeProductState> emit,
  ) async {
    await _channel?.unsubscribe();
    _channel = null;
  }

  @override
  Future<void> close() async {
    await _channel?.unsubscribe();
    return super.close();
  }
}
```


### Step 6: Upload Cubit (Supabase Storage)

```dart
// features/upload/presentation/cubit/upload_cubit.dart
@injectable
class UploadCubit extends Cubit<UploadState> {
  final SupabaseClient _supabase;

  UploadCubit({required SupabaseClient supabase})
      : _supabase = supabase,
        super(const UploadInitial());

  Future<void> uploadImage({
    required File file,
    required String bucket,
    String? fileName,
  }) async {
    emit(const UploadInProgress(0));
    try {
      final extension = file.path.split('.').last.toLowerCase();
      final name = fileName ?? '${DateTime.now().millisecondsSinceEpoch}.$extension';
      final path = 'uploads/$name';

      await _supabase.storage.from(bucket).upload(
        path,
        file,
        fileOptions: FileOptions(
          contentType: 'image/$extension',
          upsert: false,
        ),
      );

      final publicUrl = _supabase.storage.from(bucket).getPublicUrl(path);
      emit(UploadSuccess(publicUrl));
    } on StorageException catch (e) {
      emit(UploadFailure(e.message));
    }
  }

  void reset() => emit(const UploadInitial());
}
```


### Step 7: DI Module Registration

```dart
// core/di/modules/supabase_module.dart
@module
abstract class SupabaseModule {
  @lazySingleton
  SupabaseClient get supabaseClient => Supabase.instance.client;
}
```

### Step 8: Isolates untuk Parsing JSON Data Besar dari Supabase

Jika Supabase mengembalikan banyak records dan memberatkan main UI thread saat parsing, manfaatkan `Isolate.run`:

```dart
// features/products/data/repositories/product_repository_impl.dart
import 'dart:isolate';

  @override
  Future<Result<List<Product>>> getMassiveProducts() async {
    try {
      final data = await _supabase.from(_table).select().limit(5000) as List<dynamic>;
      
      final productsList = await Isolate.run<List<Product>>(() {
        return data.map((json) => ProductModel.fromJson(json as Map<String, dynamic>).toEntity()).toList();
      });

      return Success(productsList);
    } on PostgrestException catch (e) {
      return ResultFailure(ServerFailure(message: e.message));
    }
  }
```

### Step 9: Background Workmanager dengan Supabase

Supabase client juga harus di-initialize di dalam isolate Workmanager jika mengakses DB.

```dart
// lib/bootstrap/background_worker.dart
import 'package:workmanager/workmanager.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    await Supabase.initialize(
      url: const String.fromEnvironment('SUPABASE_URL'),
      anonKey: const String.fromEnvironment('SUPABASE_ANON_KEY'),
    );
    switch (task) {
      case 'syncSupabase':
        // logic sinkronisasi local DB ke Supabase
        break;
    }
    return Future.value(true);
  });
}
```


## Success Criteria

- [ ] Supabase initialized di `bootstrap()` sebelum `configureDependencies()`
- [ ] `AuthBloc` di-provide di root `MultiBlocProvider` (singleton)
- [ ] Auth state listener via `onAuthStateChange` stream dengan `StreamSubscription`
- [ ] `StreamSubscription` di-cancel di `close()` untuk prevent memory leaks
- [ ] RLS policies dikonfigurasi di Supabase dashboard
- [ ] Realtime channel di-unsubscribe di `close()`
- [ ] Tidak ada `dartz` — pakai `Result<T>` sealed class
- [ ] `dart run build_runner build -d` sukses


## Next Steps

- Testing → `06_testing_production.md`
- Advanced patterns → `09_state_management_advanced.md`

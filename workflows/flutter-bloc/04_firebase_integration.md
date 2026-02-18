# Workflow: Firebase Integration (flutter_bloc)

## Overview

Integrasi Firebase services untuk Flutter dengan **flutter_bloc** sebagai state management: Authentication, Cloud Firestore, Firebase Storage, dan Firebase Cloud Messaging (FCM). Workflow ini mencakup setup lengkap, BLoC/Cubit patterns, dependency injection via `get_it` + `injectable`, dan best practices untuk production.

Perbedaan utama dari versi Riverpod:
- **Tidak ada `ProviderScope`** — gunakan `MultiBlocProvider` di root widget
- **Auth state** di-manage via `AuthBloc` dengan `StreamSubscription` ke `FirebaseAuth.authStateChanges()`
- **Firestore real-time** via `StreamSubscription` atau `emit.forEach()` di dalam Bloc
- **Upload progress** di-handle oleh `UploadCubit` dengan granular states
- **DI** sepenuhnya via `get_it` + `injectable`, bukan Riverpod providers

## Output Location

**Base Folder:** `sdlc/flutter-bloc/04-firebase-integration/`

**Output Files:**
- `firebase-setup.md` - Setup Firebase project dan Flutter
- `auth/` - Authentication implementation (AuthBloc, AuthRepository)
- `firestore/` - Database CRUD operations (ProductBloc, real-time streams)
- `storage/` - File upload/download (UploadCubit, progress tracking)
- `fcm/` - Push notifications (NotificationService)
- `security/` - Security rules dan best practices
- `examples/` - Contoh implementasi lengkap

## Prerequisites

- Project setup dari `01_project_setup.md` selesai (termasuk `get_it` + `injectable`)
- Firebase account (firebase.google.com)
- FlutterFire CLI terinstall
- Sudah familiar dengan BLoC pattern (events, states, bloc class)

## Deliverables

### 1. Firebase Project Setup

**Description:** Setup Firebase project, konfigurasi Flutter app, dan inisialisasi di `bootstrap()` dengan `MultiBlocProvider`.

**Recommended Skills:** `senior-flutter-developer`, `senior-firebase-developer`

**Instructions:**
1. **Install FlutterFire CLI:**
   ```bash
   dart pub global activate flutterfire_cli
   ```

2. **Configure Firebase:**
   ```bash
   flutterfire configure
   ```

3. **Add Dependencies:** (Updated untuk Flutter 3.41.1)
   ```yaml
   dependencies:
     # Firebase
     firebase_core: ^3.12.0
     firebase_auth: ^5.5.0
     cloud_firestore: ^5.6.0
     firebase_storage: ^12.4.0
     firebase_messaging: ^15.2.0

     # BLoC
     flutter_bloc: ^9.1.0
     bloc: ^9.0.0
     equatable: ^2.0.7

     # DI
     get_it: ^8.0.3
     injectable: ^2.5.0

     # Utils
     dartz: ^0.10.1
     google_sign_in: ^6.2.2
     flutter_local_notifications: ^18.0.1
     flutter_image_compress: ^2.3.0
     path_provider: ^2.1.5

   dev_dependencies:
     injectable_generator: ^2.7.0
     build_runner: ^2.4.14
   ```

4. **Initialize Firebase di bootstrap:**

   Perbedaan kunci dari Riverpod: kita TIDAK pakai `ProviderScope`. Sebagai gantinya, semua Bloc/Cubit disediakan lewat `MultiBlocProvider` di root, dan service-service non-UI di-register ke `get_it`.

   ```dart
   // lib/bootstrap.dart
   import 'package:firebase_core/firebase_core.dart';
   import 'package:flutter/material.dart';
   import 'package:flutter_bloc/flutter_bloc.dart';
   import 'firebase_options.dart';
   import 'injection.dart';

   Future<void> bootstrap() async {
     WidgetsFlutterBinding.ensureInitialized();

     // 1. Init Firebase SEBELUM semua service lain
     await Firebase.initializeApp(
       options: DefaultFirebaseOptions.currentPlatform,
     );

     // 2. Init dependency injection (get_it + injectable)
     await configureDependencies();

     // 3. Init FCM service (harus setelah Firebase init)
     await getIt<NotificationService>().initialize();

     // 4. Run app dengan MultiBlocProvider
     runApp(const MyApp());
   }
   ```

5. **Root Widget dengan MultiBlocProvider:**
   ```dart
   // lib/app.dart
   class MyApp extends StatelessWidget {
     const MyApp({super.key});

     @override
     Widget build(BuildContext context) {
       return MultiBlocProvider(
         providers: [
           BlocProvider<AuthBloc>(
             create: (_) => getIt<AuthBloc>()..add(AuthCheckRequested()),
           ),
           // Bloc lain yang perlu global scope
         ],
         child: MaterialApp.router(
           routerConfig: getIt<AppRouter>().config,
           title: 'Firebase BLoC App',
         ),
       );
     }
   }
   ```

6. **DI Registration (injectable module):**
   ```dart
   // lib/injection.dart
   import 'package:get_it/get_it.dart';
   import 'package:injectable/injectable.dart';
   import 'injection.config.dart';

   final getIt = GetIt.instance;

   @InjectableInit()
   Future<void> configureDependencies() async => getIt.init();
   ```

   ```dart
   // lib/core/di/firebase_module.dart
   @module
   abstract class FirebaseModule {
     @lazySingleton
     FirebaseAuth get firebaseAuth => FirebaseAuth.instance;

     @lazySingleton
     FirebaseFirestore get firestore => FirebaseFirestore.instance;

     @lazySingleton
     FirebaseStorage get firebaseStorage => FirebaseStorage.instance;

     @lazySingleton
     FirebaseMessaging get firebaseMessaging => FirebaseMessaging.instance;
   }
   ```

**Output Format:**
```dart
// lib/firebase_options.dart (auto-generated by FlutterFire)
// File ini di-generate otomatis — JANGAN edit manual

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      default:
        throw UnsupportedError('Unsupported platform');
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'YOUR_API_KEY',
    appId: 'YOUR_APP_ID',
    messagingSenderId: 'YOUR_SENDER_ID',
    projectId: 'YOUR_PROJECT_ID',
    storageBucket: 'YOUR_BUCKET',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'YOUR_API_KEY',
    appId: 'YOUR_APP_ID',
    messagingSenderId: 'YOUR_SENDER_ID',
    projectId: 'YOUR_PROJECT_ID',
    storageBucket: 'YOUR_BUCKET',
    iosClientId: 'YOUR_IOS_CLIENT_ID',
    iosBundleId: 'YOUR_BUNDLE_ID',
  );
}
```

---

### 2. Firebase Authentication (AuthBloc)

**Description:** Implementasi Firebase Auth dengan BLoC pattern. AuthBloc mendengarkan `authStateChanges` stream via `StreamSubscription`, dan meng-emit state sesuai perubahan auth.

**Recommended Skills:** `senior-flutter-developer`, `senior-firebase-developer`

**Instructions:**
1. **Auth Repository** — contract dan Firebase implementation (sama konsepnya dengan Riverpod, tapi tanpa Riverpod annotation)
2. **AuthEvent** — sealed class dengan semua event yang mungkin
3. **AuthState** — sealed class dengan semua state
4. **AuthBloc** — subscribe ke auth stream, handle events, manage lifecycle
5. **DI Registration** — register ke `get_it` via `@injectable`

**Auth Repository:**
```dart
// lib/features/auth/domain/repositories/auth_repository.dart
abstract class AuthRepository {
  /// Stream perubahan auth state dari Firebase
  Stream<User?> get authStateChanges;

  /// Sign in dengan email dan password
  Future<Either<Failure, User>> signInWithEmailAndPassword(
    String email,
    String password,
  );

  /// Sign in dengan Google
  Future<Either<Failure, User>> signInWithGoogle();

  /// Register user baru
  Future<Either<Failure, User>> signUp(String email, String password);

  /// Sign out dari semua provider
  Future<Either<Failure, Unit>> signOut();

  /// Get current user (nullable)
  User? get currentUser;
}
```

```dart
// lib/features/auth/data/repositories/auth_repository_impl.dart
@LazySingleton(as: AuthRepository)
class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;

  AuthRepositoryImpl(this._firebaseAuth, this._googleSignIn);

  @override
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  @override
  Future<Either<Failure, User>> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      final result = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (result.user == null) {
        return const Left(AuthFailure('User not found'));
      }

      return Right(result.user!);
    } on FirebaseAuthException catch (e) {
      return Left(_mapAuthError(e));
    }
  }

  @override
  Future<Either<Failure, User>> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return const Left(AuthFailure('Google sign-in dibatalkan'));
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final result = await _firebaseAuth.signInWithCredential(credential);

      if (result.user == null) {
        return const Left(AuthFailure('Gagal sign in dengan Google'));
      }

      return Right(result.user!);
    } on FirebaseAuthException catch (e) {
      return Left(_mapAuthError(e));
    }
  }

  @override
  Future<Either<Failure, User>> signUp(String email, String password) async {
    try {
      final result = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (result.user == null) {
        return const Left(AuthFailure('Gagal membuat user'));
      }

      return Right(result.user!);
    } on FirebaseAuthException catch (e) {
      return Left(_mapAuthError(e));
    }
  }

  @override
  Future<Either<Failure, Unit>> signOut() async {
    try {
      await Future.wait([
        _firebaseAuth.signOut(),
        _googleSignIn.signOut(),
      ]);
      return const Right(unit);
    } on FirebaseAuthException catch (e) {
      return Left(_mapAuthError(e));
    }
  }

  @override
  User? get currentUser => _firebaseAuth.currentUser;

  Failure _mapAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return const AuthFailure('Tidak ada user dengan email ini');
      case 'wrong-password':
        return const AuthFailure('Password salah');
      case 'email-already-in-use':
        return const AuthFailure('Email sudah terdaftar');
      case 'invalid-email':
        return const AuthFailure('Format email tidak valid');
      case 'weak-password':
        return const AuthFailure('Password terlalu lemah');
      case 'too-many-requests':
        return const AuthFailure('Terlalu banyak percobaan. Coba lagi nanti');
      case 'operation-not-allowed':
        return const AuthFailure('Metode sign-in tidak diaktifkan');
      default:
        return AuthFailure(e.message ?? 'Terjadi kesalahan autentikasi');
    }
  }
}
```

**Auth Events (sealed class):**
```dart
// lib/features/auth/presentation/bloc/auth_event.dart
import 'package:equatable/equatable.dart';

sealed class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// Cek status auth saat app startup atau saat stream berubah
class AuthCheckRequested extends AuthEvent {
  const AuthCheckRequested();
}

/// User request sign in dengan email + password
class SignInWithEmailRequested extends AuthEvent {
  final String email;
  final String password;

  const SignInWithEmailRequested({
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [email, password];
}

/// User request sign in dengan Google
class SignInWithGoogleRequested extends AuthEvent {
  const SignInWithGoogleRequested();
}

/// User request registrasi akun baru
class SignUpRequested extends AuthEvent {
  final String email;
  final String password;

  const SignUpRequested({
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [email, password];
}

/// User request sign out
class SignOutRequested extends AuthEvent {
  const SignOutRequested();
}

/// Internal event: auth state berubah dari Firebase stream
class _AuthStateChanged extends AuthEvent {
  final User? user;

  const _AuthStateChanged(this.user);

  @override
  List<Object?> get props => [user];
}
```

**Auth States (sealed class):**
```dart
// lib/features/auth/presentation/bloc/auth_state.dart
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';

sealed class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

/// State awal sebelum auth check dilakukan
class AuthInitial extends AuthState {
  const AuthInitial();
}

/// Sedang memproses operasi auth (sign in, sign up, sign out)
class AuthLoading extends AuthState {
  const AuthLoading();
}

/// User sudah terautentikasi
class Authenticated extends AuthState {
  final User user;

  const Authenticated(this.user);

  @override
  List<Object?> get props => [user.uid];
}

/// User belum/tidak terautentikasi
class Unauthenticated extends AuthState {
  const Unauthenticated();
}

/// Terjadi error saat operasi auth
class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);

  @override
  List<Object?> get props => [message];
}
```

**AuthBloc Implementation:**
```dart
// lib/features/auth/presentation/bloc/auth_bloc.dart
import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

@injectable
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;

  /// StreamSubscription untuk listen auth state changes dari Firebase.
  /// PENTING: harus di-cancel di close() untuk avoid memory leak.
  StreamSubscription<User?>? _authSubscription;

  AuthBloc(this._authRepository) : super(const AuthInitial()) {
    // Register semua event handlers
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<SignInWithEmailRequested>(_onSignInWithEmail);
    on<SignInWithGoogleRequested>(_onSignInWithGoogle);
    on<SignUpRequested>(_onSignUp);
    on<SignOutRequested>(_onSignOut);
    on<_AuthStateChanged>(_onAuthStateChanged);

    // Subscribe ke Firebase auth state stream.
    // Setiap kali auth state berubah (login/logout/token refresh),
    // kita dispatch internal event _AuthStateChanged.
    _authSubscription = _authRepository.authStateChanges.listen(
      (user) => add(_AuthStateChanged(user)),
    );
  }

  /// Handle internal auth state change dari Firebase stream
  void _onAuthStateChanged(
    _AuthStateChanged event,
    Emitter<AuthState> emit,
  ) {
    if (event.user != null) {
      emit(Authenticated(event.user!));
    } else {
      emit(const Unauthenticated());
    }
  }

  /// Handle explicit auth check (biasa dipanggil saat app start)
  Future<void> _onAuthCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    final user = _authRepository.currentUser;
    if (user != null) {
      emit(Authenticated(user));
    } else {
      emit(const Unauthenticated());
    }
  }

  /// Handle sign in dengan email + password
  Future<void> _onSignInWithEmail(
    SignInWithEmailRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    final result = await _authRepository.signInWithEmailAndPassword(
      event.email,
      event.password,
    );

    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) => emit(Authenticated(user)),
    );
  }

  /// Handle sign in dengan Google
  Future<void> _onSignInWithGoogle(
    SignInWithGoogleRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    final result = await _authRepository.signInWithGoogle();

    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) => emit(Authenticated(user)),
    );
  }

  /// Handle registrasi user baru
  Future<void> _onSignUp(
    SignUpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    final result = await _authRepository.signUp(
      event.email,
      event.password,
    );

    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) => emit(Authenticated(user)),
    );
  }

  /// Handle sign out
  Future<void> _onSignOut(
    SignOutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    final result = await _authRepository.signOut();

    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (_) => emit(const Unauthenticated()),
    );
  }

  /// WAJIB: cancel subscription saat bloc di-dispose
  /// Tanpa ini, stream listener tetap aktif = memory leak
  @override
  Future<void> close() {
    _authSubscription?.cancel();
    return super.close();
  }
}
```

**Penggunaan di UI:**
```dart
// lib/features/auth/presentation/pages/login_page.dart
class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      // listenWhen: hanya react saat state berubah ke error
      listenWhen: (prev, curr) => curr is AuthError,
      listener: (context, state) {
        if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      builder: (context, state) {
        if (state is AuthLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        return Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // ... form fields ...
                ElevatedButton(
                  onPressed: () {
                    context.read<AuthBloc>().add(
                          SignInWithEmailRequested(
                            email: _emailController.text.trim(),
                            password: _passwordController.text,
                          ),
                        );
                  },
                  child: const Text('Sign In'),
                ),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: () {
                    context.read<AuthBloc>().add(
                          const SignInWithGoogleRequested(),
                        );
                  },
                  icon: const Icon(Icons.login),
                  label: const Text('Sign in with Google'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
```

**Auth Guard dengan BlocListener di Router:**
```dart
// lib/core/router/auth_guard.dart
// Contoh redirect di GoRouter berdasarkan AuthBloc state
GoRouter appRouter(AuthBloc authBloc) {
  return GoRouter(
    refreshListenable: GoRouterRefreshStream(authBloc.stream),
    redirect: (context, state) {
      final authState = authBloc.state;
      final isOnLogin = state.matchedLocation == '/login';

      if (authState is Unauthenticated && !isOnLogin) {
        return '/login';
      }
      if (authState is Authenticated && isOnLogin) {
        return '/home';
      }
      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (_, __) => const LoginPage()),
      GoRoute(path: '/home', builder: (_, __) => const HomePage()),
    ],
  );
}

/// Helper class untuk convert BLoC stream ke Listenable (GoRouter butuh ini)
class GoRouterRefreshStream extends ChangeNotifier {
  late final StreamSubscription<dynamic> _subscription;

  GoRouterRefreshStream(Stream<dynamic> stream) {
    _subscription = stream.asBroadcastStream().listen((_) {
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
```

---

### 3. Cloud Firestore CRUD (ProductBloc)

**Description:** Implementasi Firestore untuk database dengan real-time updates via BLoC. Gunakan `StreamSubscription` di dalam Bloc untuk listen Firestore snapshots, lalu emit state baru setiap ada perubahan data.

**Recommended Skills:** `senior-flutter-developer`, `senior-firebase-developer`

**Instructions:**
1. **ProductRemoteDataSource** — abstraksi untuk Firestore operations
2. **ProductFirestoreDataSource** — implementasi konkret
3. **ProductRepository** — orchestrate data sources
4. **ProductBloc** — events, states, stream subscription
5. **Security Rules** — validasi data di server side

**Data Source:**
```dart
// lib/features/product/data/datasources/product_remote_ds.dart
abstract class ProductRemoteDataSource {
  /// Stream real-time list produk dari Firestore
  Stream<List<ProductModel>> watchProducts();

  /// Get single product by ID
  Future<ProductModel> getProductById(String id);

  /// Create produk baru, return model dengan ID dari Firestore
  Future<ProductModel> createProduct(ProductModel product);

  /// Update produk existing
  Future<ProductModel> updateProduct(ProductModel product);

  /// Delete produk by ID
  Future<void> deleteProduct(String id);

  /// Batch write multiple products (untuk bulk operations)
  Future<void> batchWrite(List<ProductModel> products);
}
```

```dart
// lib/features/product/data/datasources/product_firestore_ds.dart
@LazySingleton(as: ProductRemoteDataSource)
class ProductFirestoreDataSource implements ProductRemoteDataSource {
  final FirebaseFirestore _firestore;

  ProductFirestoreDataSource(this._firestore);

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection('products');

  @override
  Stream<List<ProductModel>> watchProducts() {
    return _collection
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ProductModel.fromJson(
                  {...doc.data(), 'id': doc.id},
                ))
            .toList());
  }

  @override
  Future<ProductModel> getProductById(String id) async {
    final doc = await _collection.doc(id).get();
    if (!doc.exists) {
      throw NotFoundException('Produk tidak ditemukan');
    }
    return ProductModel.fromJson({...doc.data()!, 'id': doc.id});
  }

  @override
  Future<ProductModel> createProduct(ProductModel product) async {
    final docRef = await _collection.add({
      'name': product.name,
      'price': product.price,
      'description': product.description,
      'imageUrl': product.imageUrl,
      'ownerId': product.ownerId,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    return product.copyWith(id: docRef.id);
  }

  @override
  Future<ProductModel> updateProduct(ProductModel product) async {
    await _collection.doc(product.id).update({
      'name': product.name,
      'price': product.price,
      'description': product.description,
      'imageUrl': product.imageUrl,
      'updatedAt': FieldValue.serverTimestamp(),
    });
    return product;
  }

  @override
  Future<void> deleteProduct(String id) async {
    await _collection.doc(id).delete();
  }

  @override
  Future<void> batchWrite(List<ProductModel> products) async {
    final batch = _firestore.batch();
    for (final product in products) {
      final docRef = _collection.doc();
      batch.set(docRef, {
        'name': product.name,
        'price': product.price,
        'description': product.description,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }
    await batch.commit();
  }
}
```

**Product Events:**
```dart
// lib/features/product/presentation/bloc/product_event.dart
sealed class ProductEvent extends Equatable {
  const ProductEvent();

  @override
  List<Object?> get props => [];
}

/// Mulai subscribe ke Firestore stream
class ProductSubscriptionRequested extends ProductEvent {
  const ProductSubscriptionRequested();
}

/// Internal: data dari stream berubah
class _ProductsUpdated extends ProductEvent {
  final List<Product> products;

  const _ProductsUpdated(this.products);

  @override
  List<Object?> get props => [products];
}

/// Internal: error dari stream
class _ProductsError extends ProductEvent {
  final String message;

  const _ProductsError(this.message);

  @override
  List<Object?> get props => [message];
}

/// Tambah produk baru
class ProductAdded extends ProductEvent {
  final String name;
  final double price;
  final String? description;
  final String? imageUrl;

  const ProductAdded({
    required this.name,
    required this.price,
    this.description,
    this.imageUrl,
  });

  @override
  List<Object?> get props => [name, price, description, imageUrl];
}

/// Update produk existing
class ProductUpdated extends ProductEvent {
  final Product product;

  const ProductUpdated(this.product);

  @override
  List<Object?> get props => [product];
}

/// Delete produk
class ProductDeleted extends ProductEvent {
  final String productId;

  const ProductDeleted(this.productId);

  @override
  List<Object?> get props => [productId];
}
```

**Product States:**
```dart
// lib/features/product/presentation/bloc/product_state.dart
sealed class ProductState extends Equatable {
  const ProductState();

  @override
  List<Object?> get props => [];
}

class ProductInitial extends ProductState {
  const ProductInitial();
}

class ProductLoading extends ProductState {
  const ProductLoading();
}

/// Data produk tersedia (dari Firestore real-time stream)
class ProductLoaded extends ProductState {
  final List<Product> products;

  const ProductLoaded(this.products);

  @override
  List<Object?> get props => [products];
}

/// Error saat load atau operasi CRUD
class ProductError extends ProductState {
  final String message;
  /// Simpan data terakhir supaya UI tetap bisa tampilkan data lama
  final List<Product> previousProducts;

  const ProductError(this.message, {this.previousProducts = const []});

  @override
  List<Object?> get props => [message, previousProducts];
}

/// Operasi CRUD sedang berjalan (add/update/delete)
/// State ini terpisah dari loading karena list produk tetap ditampilkan
class ProductOperationInProgress extends ProductState {
  final List<Product> products;
  final String operation; // 'add', 'update', 'delete'

  const ProductOperationInProgress(this.products, this.operation);

  @override
  List<Object?> get props => [products, operation];
}
```

**ProductBloc Implementation:**
```dart
// lib/features/product/presentation/bloc/product_bloc.dart
@injectable
class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final ProductRepository _productRepository;

  /// StreamSubscription untuk Firestore real-time updates.
  /// Pattern: subscribe di event handler, cancel di close().
  StreamSubscription<List<Product>>? _productsSubscription;

  ProductBloc(this._productRepository) : super(const ProductInitial()) {
    on<ProductSubscriptionRequested>(_onSubscriptionRequested);
    on<_ProductsUpdated>(_onProductsUpdated);
    on<_ProductsError>(_onProductsError);
    on<ProductAdded>(_onProductAdded);
    on<ProductUpdated>(_onProductUpdated);
    on<ProductDeleted>(_onProductDeleted);
  }

  /// Subscribe ke Firestore real-time stream.
  /// Cancel subscription lama kalau ada (prevent duplicate listeners).
  Future<void> _onSubscriptionRequested(
    ProductSubscriptionRequested event,
    Emitter<ProductState> emit,
  ) async {
    emit(const ProductLoading());

    // Cancel existing subscription jika ada
    await _productsSubscription?.cancel();

    _productsSubscription = _productRepository.watchProducts().listen(
      (products) => add(_ProductsUpdated(products)),
      onError: (error) => add(_ProductsError(error.toString())),
    );
  }

  void _onProductsUpdated(
    _ProductsUpdated event,
    Emitter<ProductState> emit,
  ) {
    emit(ProductLoaded(event.products));
  }

  void _onProductsError(
    _ProductsError event,
    Emitter<ProductState> emit,
  ) {
    final previousProducts = state is ProductLoaded
        ? (state as ProductLoaded).products
        : <Product>[];
    emit(ProductError(event.message, previousProducts: previousProducts));
  }

  Future<void> _onProductAdded(
    ProductAdded event,
    Emitter<ProductState> emit,
  ) async {
    final currentProducts =
        state is ProductLoaded ? (state as ProductLoaded).products : <Product>[];

    emit(ProductOperationInProgress(currentProducts, 'add'));

    final result = await _productRepository.createProduct(
      Product(
        id: '',
        name: event.name,
        price: event.price,
        description: event.description,
        createdAt: DateTime.now(),
      ),
    );

    result.fold(
      (failure) => emit(ProductError(
        failure.message,
        previousProducts: currentProducts,
      )),
      // Tidak perlu emit success — Firestore stream akan otomatis
      // push data terbaru via _ProductsUpdated event
      (_) {},
    );
  }

  Future<void> _onProductUpdated(
    ProductUpdated event,
    Emitter<ProductState> emit,
  ) async {
    final currentProducts =
        state is ProductLoaded ? (state as ProductLoaded).products : <Product>[];

    emit(ProductOperationInProgress(currentProducts, 'update'));

    final result = await _productRepository.updateProduct(event.product);

    result.fold(
      (failure) => emit(ProductError(
        failure.message,
        previousProducts: currentProducts,
      )),
      (_) {}, // Stream akan auto-update
    );
  }

  Future<void> _onProductDeleted(
    ProductDeleted event,
    Emitter<ProductState> emit,
  ) async {
    final currentProducts =
        state is ProductLoaded ? (state as ProductLoaded).products : <Product>[];

    emit(ProductOperationInProgress(currentProducts, 'delete'));

    final result = await _productRepository.deleteProduct(event.productId);

    result.fold(
      (failure) => emit(ProductError(
        failure.message,
        previousProducts: currentProducts,
      )),
      (_) {}, // Stream akan auto-update
    );
  }

  @override
  Future<void> close() {
    _productsSubscription?.cancel();
    return super.close();
  }
}
```

**Alternatif: Menggunakan `emit.forEach()` (lebih ringkas):**
```dart
// Alternatif approach tanpa manual StreamSubscription.
// emit.forEach() otomatis manage subscription lifecycle.
// Kekurangan: kurang fleksibel untuk complex error handling.

@injectable
class ProductStreamBloc extends Bloc<ProductEvent, ProductState> {
  final ProductRepository _productRepository;

  ProductStreamBloc(this._productRepository) : super(const ProductInitial()) {
    on<ProductSubscriptionRequested>(_onSubscriptionRequested);
  }

  Future<void> _onSubscriptionRequested(
    ProductSubscriptionRequested event,
    Emitter<ProductState> emit,
  ) async {
    emit(const ProductLoading());

    // emit.forEach otomatis subscribe dan cancel subscription
    await emit.forEach<List<Product>>(
      _productRepository.watchProducts(),
      onData: (products) => ProductLoaded(products),
      onError: (error, stackTrace) => ProductError(error.toString()),
    );
  }
}
```

**Penggunaan di UI:**
```dart
// lib/features/product/presentation/pages/product_list_page.dart
class ProductListPage extends StatelessWidget {
  const ProductListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      // Buat ProductBloc dan langsung subscribe ke stream
      create: (context) => getIt<ProductBloc>()
        ..add(const ProductSubscriptionRequested()),
      child: const _ProductListView(),
    );
  }
}

class _ProductListView extends StatelessWidget {
  const _ProductListView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Produk')),
      body: BlocBuilder<ProductBloc, ProductState>(
        builder: (context, state) {
          return switch (state) {
            ProductInitial() => const SizedBox.shrink(),
            ProductLoading() => const Center(
                child: CircularProgressIndicator(),
              ),
            ProductLoaded(:final products) => _buildList(context, products),
            ProductOperationInProgress(:final products) => Stack(
                children: [
                  _buildList(context, products),
                  const Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: LinearProgressIndicator(),
                  ),
                ],
              ),
            ProductError(:final message, :final previousProducts) =>
              previousProducts.isEmpty
                  ? Center(child: Text('Error: $message'))
                  : _buildList(context, previousProducts),
          };
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildList(BuildContext context, List<Product> products) {
    if (products.isEmpty) {
      return const Center(child: Text('Belum ada produk'));
    }

    return ListView.builder(
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return ListTile(
          title: Text(product.name),
          subtitle: Text('Rp ${product.price.toStringAsFixed(0)}'),
          trailing: IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              context.read<ProductBloc>().add(
                    ProductDeleted(product.id),
                  );
            },
          ),
        );
      },
    );
  }
}
```

**Firestore Security Rules:**
```
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

    function isValidString(field, maxLength) {
      return field is string && field.size() > 0 && field.size() <= maxLength;
    }

    // Products collection
    match /products/{productId} {
      allow read: if isAuthenticated();
      allow create: if isAuthenticated()
        && isValidString(request.resource.data.name, 100)
        && request.resource.data.price is number
        && request.resource.data.price >= 0;
      allow update: if isAuthenticated()
        && isOwner(resource.data.ownerId)
        && request.resource.data.updatedAt == request.time;
      allow delete: if isAuthenticated()
        && isOwner(resource.data.ownerId);
    }

    // Users collection
    match /users/{userId} {
      allow read: if isAuthenticated() && isOwner(userId);
      allow write: if isAuthenticated() && isOwner(userId);
    }
  }
}
```

---

### 4. Firebase Storage (UploadCubit)

**Description:** File upload dan download dengan progress tracking menggunakan Cubit. Cubit dipilih karena upload adalah operasi satu arah tanpa complex event — cukup panggil method, state berubah. Tidak perlu event class.

**Recommended Skills:** `senior-flutter-developer`, `senior-firebase-developer`

**Instructions:**
1. **StorageService** — service layer untuk Firebase Storage operations
2. **UploadState** — granular states (initial, uploading+progress, uploaded+url, error)
3. **UploadCubit** — manage upload lifecycle
4. **DI Registration** — register semua component ke `get_it`

**Storage Service:**
```dart
// lib/core/storage/firebase_storage_service.dart
@lazySingleton
class FirebaseStorageService {
  final FirebaseStorage _storage;

  FirebaseStorageService(this._storage);

  /// Upload file ke Firebase Storage dengan progress callback.
  /// Return download URL jika sukses.
  Future<Either<Failure, String>> uploadFile({
    required File file,
    required String path,
    void Function(double progress)? onProgress,
  }) async {
    try {
      final ref = _storage.ref().child(path);
      final uploadTask = ref.putFile(file);

      // Listen progress events
      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        final progress = snapshot.bytesTransferred / snapshot.totalBytes;
        onProgress?.call(progress);
      });

      await uploadTask;
      final downloadUrl = await ref.getDownloadURL();

      return Right(downloadUrl);
    } on FirebaseException catch (e) {
      return Left(StorageFailure(e.message ?? 'Upload gagal'));
    }
  }

  /// Upload image dengan kompresi otomatis
  Future<Either<Failure, String>> uploadImage({
    required File imageFile,
    required String folder,
    int quality = 85,
    void Function(double progress)? onProgress,
  }) async {
    try {
      // Compress image sebelum upload
      final compressedBytes = await FlutterImageCompress.compressWithFile(
        imageFile.absolute.path,
        quality: quality,
      );

      if (compressedBytes == null) {
        return const Left(StorageFailure('Gagal compress gambar'));
      }

      // Write compressed bytes ke temp file
      final tempDir = await getTemporaryDirectory();
      final fileName =
          '${DateTime.now().millisecondsSinceEpoch}_${folder.hashCode}.jpg';
      final tempFile = File('${tempDir.path}/$fileName');
      await tempFile.writeAsBytes(compressedBytes);

      final storagePath = '$folder/$fileName';

      return uploadFile(
        file: tempFile,
        path: storagePath,
        onProgress: onProgress,
      );
    } catch (e) {
      return Left(StorageFailure(e.toString()));
    }
  }

  /// Delete file dari Storage by URL
  Future<Either<Failure, Unit>> deleteFile(String url) async {
    try {
      final ref = _storage.refFromURL(url);
      await ref.delete();
      return const Right(unit);
    } on FirebaseException catch (e) {
      return Left(StorageFailure(e.message ?? 'Gagal menghapus file'));
    }
  }
}
```

**Upload State:**
```dart
// lib/features/upload/presentation/cubit/upload_state.dart
sealed class UploadState extends Equatable {
  const UploadState();

  @override
  List<Object?> get props => [];
}

/// Belum ada upload yang dimulai
class UploadInitial extends UploadState {
  const UploadInitial();
}

/// Upload sedang berjalan, dengan progress 0.0 - 1.0
class UploadInProgress extends UploadState {
  final double progress;
  final String fileName;

  const UploadInProgress({
    required this.progress,
    required this.fileName,
  });

  /// Helper: progress dalam persen (0 - 100)
  int get progressPercent => (progress * 100).toInt();

  @override
  List<Object?> get props => [progress, fileName];
}

/// Upload selesai, URL file tersedia
class UploadSuccess extends UploadState {
  final String downloadUrl;
  final String fileName;

  const UploadSuccess({
    required this.downloadUrl,
    required this.fileName,
  });

  @override
  List<Object?> get props => [downloadUrl, fileName];
}

/// Upload gagal
class UploadFailure extends UploadState {
  final String message;

  const UploadFailure(this.message);

  @override
  List<Object?> get props => [message];
}
```

**Upload Cubit:**
```dart
// lib/features/upload/presentation/cubit/upload_cubit.dart
@injectable
class UploadCubit extends Cubit<UploadState> {
  final FirebaseStorageService _storageService;

  UploadCubit(this._storageService) : super(const UploadInitial());

  /// Upload gambar profil ke Firebase Storage
  Future<String?> uploadProfileImage({
    required File imageFile,
    required String userId,
  }) async {
    final fileName = imageFile.path.split('/').last;

    emit(UploadInProgress(progress: 0.0, fileName: fileName));

    final result = await _storageService.uploadImage(
      imageFile: imageFile,
      folder: 'profile_images/$userId',
      quality: 85,
      onProgress: (progress) {
        // Emit state baru setiap progress berubah
        // PENTING: cek isClosed sebelum emit untuk avoid
        // "emit after close" error
        if (!isClosed) {
          emit(UploadInProgress(progress: progress, fileName: fileName));
        }
      },
    );

    return result.fold(
      (failure) {
        emit(UploadFailure(failure.message));
        return null;
      },
      (url) {
        emit(UploadSuccess(downloadUrl: url, fileName: fileName));
        return url;
      },
    );
  }

  /// Upload file generic (dokumen, dll)
  Future<String?> uploadFile({
    required File file,
    required String storagePath,
  }) async {
    final fileName = file.path.split('/').last;

    emit(UploadInProgress(progress: 0.0, fileName: fileName));

    final result = await _storageService.uploadFile(
      file: file,
      path: storagePath,
      onProgress: (progress) {
        if (!isClosed) {
          emit(UploadInProgress(progress: progress, fileName: fileName));
        }
      },
    );

    return result.fold(
      (failure) {
        emit(UploadFailure(failure.message));
        return null;
      },
      (url) {
        emit(UploadSuccess(downloadUrl: url, fileName: fileName));
        return url;
      },
    );
  }

  /// Reset state ke initial (untuk upload ulang)
  void reset() => emit(const UploadInitial());
}
```

**Penggunaan di UI:**
```dart
// lib/features/upload/presentation/widgets/upload_button.dart
class UploadButton extends StatelessWidget {
  const UploadButton({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<UploadCubit>(),
      child: BlocConsumer<UploadCubit, UploadState>(
        listener: (context, state) {
          if (state is UploadSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Upload berhasil!')),
            );
          }
          if (state is UploadFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Gagal: ${state.message}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          return Column(
            children: [
              // Progress indicator
              if (state is UploadInProgress) ...[
                LinearProgressIndicator(value: state.progress),
                const SizedBox(height: 8),
                Text('${state.progressPercent}% - ${state.fileName}'),
              ],

              // Upload button
              if (state is! UploadInProgress)
                ElevatedButton.icon(
                  onPressed: () => _pickAndUpload(context),
                  icon: const Icon(Icons.upload),
                  label: Text(
                    state is UploadSuccess
                        ? 'Upload Lagi'
                        : 'Pilih & Upload Gambar',
                  ),
                ),

              // Tampilkan preview jika sudah upload
              if (state is UploadSuccess) ...[
                const SizedBox(height: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    state.downloadUrl,
                    height: 200,
                    fit: BoxFit.cover,
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  Future<void> _pickAndUpload(BuildContext context) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;

    final userId = context.read<AuthBloc>().state;
    if (userId is! Authenticated) return;

    context.read<UploadCubit>().uploadProfileImage(
          imageFile: File(picked.path),
          userId: userId.user.uid,
        );
  }
}
```

**Storage Security Rules:**
```
// storage.rules
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    // Profile images: user hanya bisa write ke folder sendiri
    match /profile_images/{userId}/{allPaths=**} {
      allow read: if request.auth != null;
      allow write: if request.auth != null
        && request.auth.uid == userId
        && request.resource.size < 5 * 1024 * 1024  // Max 5MB
        && request.resource.contentType.matches('image/.*');
    }

    // Product images: authenticated user bisa upload
    match /product_images/{allPaths=**} {
      allow read: if request.auth != null;
      allow write: if request.auth != null
        && request.resource.size < 10 * 1024 * 1024  // Max 10MB
        && request.resource.contentType.matches('image/.*');
    }
  }
}
```

---

### 5. Firebase Cloud Messaging / FCM (NotificationService)

**Description:** Push notifications dengan FCM. Service ini framework-agnostic (tidak extend Bloc/Cubit) karena FCM berjalan di level app lifecycle, bukan UI state. Di-register sebagai `@lazySingleton` di `get_it`. Navigasi on-tap lewat GoRouter.

**Recommended Skills:** `senior-flutter-developer`, `senior-firebase-developer`

**Instructions:**
1. **NotificationService** — setup FCM, handle foreground/background messages
2. **Local Notifications** — tampilkan notifikasi saat app di foreground
3. **Navigation** — handle tap notifikasi, navigate ke route yang sesuai
4. **Token Management** — simpan FCM token ke Firestore untuk server-side push
5. **Background Handler** — top-level function untuk background messages

**NotificationService Implementation:**
```dart
// lib/core/notifications/notification_service.dart
@lazySingleton
class NotificationService {
  final FirebaseMessaging _messaging;
  final FlutterLocalNotificationsPlugin _localNotifications;
  final GoRouter _router;

  NotificationService(
    this._messaging,
    this._localNotifications,
    this._router,
  );

  /// Initialize FCM dan local notifications.
  /// Panggil di bootstrap() SETELAH Firebase.initializeApp().
  Future<void> initialize() async {
    // 1. Request permissions (iOS wajib, Android opsional untuk 13+)
    await _requestPermissions();

    // 2. Setup local notifications plugin
    await _initializeLocalNotifications();

    // 3. Handle foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // 4. Handle notification tap saat app di background
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);

    // 5. Handle notification tap saat app terminated
    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      // Delay sedikit agar router sudah siap
      Future.delayed(
        const Duration(milliseconds: 500),
        () => _handleNotificationTap(initialMessage),
      );
    }

    // 6. Get dan log FCM token
    final token = await _messaging.getToken();
    debugPrint('FCM Token: $token');
  }

  Future<void> _requestPermissions() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );
    debugPrint('FCM Permission: ${settings.authorizationStatus}');
  }

  Future<void> _initializeLocalNotifications() async {
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false, // Sudah request via FCM
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onLocalNotificationTap,
    );

    // Create notification channel untuk Android
    const androidChannel = AndroidNotificationChannel(
      'high_importance_channel',
      'High Importance Notifications',
      description: 'Channel untuk notifikasi penting',
      importance: Importance.max,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidChannel);
  }

  /// Handle message saat app di foreground.
  /// Firebase TIDAK otomatis tampilkan notifikasi di foreground,
  /// jadi kita perlu tampilkan manual via local notifications.
  void _handleForegroundMessage(RemoteMessage message) {
    final notification = message.notification;
    if (notification == null) return;

    _showLocalNotification(
      title: notification.title ?? 'Notifikasi Baru',
      body: notification.body ?? '',
      payload: _encodePayload(message.data),
    );
  }

  /// Handle tap pada notifikasi (background state)
  void _handleNotificationTap(RemoteMessage message) {
    _navigateFromPayload(message.data);
  }

  /// Handle tap pada local notification (foreground state)
  void _onLocalNotificationTap(NotificationResponse details) {
    if (details.payload == null) return;
    final data = _decodePayload(details.payload!);
    _navigateFromPayload(data);
  }

  /// Navigate berdasarkan data payload dari notifikasi
  void _navigateFromPayload(Map<String, dynamic> data) {
    final route = data['route'] as String?;
    final id = data['id'] as String?;

    if (route == null) return;

    // Gunakan GoRouter untuk navigasi
    switch (route) {
      case 'product_detail':
        if (id != null) _router.push('/products/$id');
        break;
      case 'order_detail':
        if (id != null) _router.push('/orders/$id');
        break;
      case 'chat':
        _router.push('/chat');
        break;
      default:
        _router.push(route);
    }
  }

  /// Tampilkan local notification
  Future<void> _showLocalNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'high_importance_channel',
      'High Importance Notifications',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch.remainder(100000),
      title,
      body,
      details,
      payload: payload,
    );
  }

  /// Get FCM token (untuk kirim ke backend/Firestore)
  Future<String?> getToken() => _messaging.getToken();

  /// Stream token refresh
  Stream<String> get onTokenRefresh => _messaging.onTokenRefresh;

  /// Subscribe ke topic (misal: 'promo', 'news')
  Future<void> subscribeToTopic(String topic) async {
    await _messaging.subscribeToTopic(topic);
  }

  /// Unsubscribe dari topic
  Future<void> unsubscribeFromTopic(String topic) async {
    await _messaging.unsubscribeFromTopic(topic);
  }

  // --- Helper encode/decode payload ---
  String _encodePayload(Map<String, dynamic> data) {
    return data.entries.map((e) => '${e.key}=${e.value}').join('&');
  }

  Map<String, dynamic> _decodePayload(String payload) {
    return Map.fromEntries(
      payload.split('&').map((entry) {
        final parts = entry.split('=');
        return MapEntry(parts[0], parts.length > 1 ? parts[1] : '');
      }),
    );
  }
}
```

**Background Message Handler:**
```dart
// lib/main.dart (atau file terpisah)
// WAJIB top-level function (tidak boleh di dalam class)
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Init Firebase di background isolate
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  debugPrint('Background message: ${message.messageId}');
  // Handle background data message jika perlu
}
```

```dart
// Di bootstrap.dart, register background handler SEBELUM runApp
Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Register background handler
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  await configureDependencies();
  await getIt<NotificationService>().initialize();

  runApp(const MyApp());
}
```

**Token Persistence ke Firestore:**
```dart
// lib/core/notifications/token_repository.dart
@lazySingleton
class FcmTokenRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final NotificationService _notificationService;

  FcmTokenRepository(
    this._firestore,
    this._auth,
    this._notificationService,
  );

  /// Simpan FCM token ke Firestore user document.
  /// Panggil setelah user login.
  Future<void> saveToken() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final token = await _notificationService.getToken();
    if (token == null) return;

    await _firestore.collection('users').doc(user.uid).set(
      {
        'fcmTokens': FieldValue.arrayUnion([token]),
        'lastTokenUpdate': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  /// Listen token refresh dan auto-update ke Firestore
  void listenTokenRefresh() {
    _notificationService.onTokenRefresh.listen((newToken) async {
      final user = _auth.currentUser;
      if (user == null) return;

      await _firestore.collection('users').doc(user.uid).update({
        'fcmTokens': FieldValue.arrayUnion([newToken]),
        'lastTokenUpdate': FieldValue.serverTimestamp(),
      });
    });
  }

  /// Hapus token saat user logout
  Future<void> removeToken() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final token = await _notificationService.getToken();
    if (token == null) return;

    await _firestore.collection('users').doc(user.uid).update({
      'fcmTokens': FieldValue.arrayRemove([token]),
    });
  }
}
```

---

## Workflow Steps

1. **Setup Firebase Project**
   - Create Firebase project di console
   - Register Android & iOS apps
   - Download config files (google-services.json, GoogleService-Info.plist)
   - Install FlutterFire CLI
   - Run `flutterfire configure`

2. **Configure Dependencies**
   - Add Firebase packages ke pubspec.yaml
   - Add `flutter_bloc`, `get_it`, `injectable`
   - Initialize Firebase di `bootstrap.dart`
   - Setup `MultiBlocProvider` di root widget
   - Register Firebase instances di `get_it` module

3. **Implement Authentication**
   - Buat `AuthRepository` contract dan implementasi
   - Buat `AuthEvent` sealed class (semua event)
   - Buat `AuthState` sealed class (semua state)
   - Buat `AuthBloc` dengan `StreamSubscription` ke auth stream
   - Register `AuthBloc` di `MultiBlocProvider` root
   - Buat login/register UI dengan `BlocConsumer`
   - Setup `GoRouter` redirect berdasarkan auth state

4. **Setup Firestore**
   - Design data structure dan model
   - Buat `ProductRemoteDataSource` dan Firestore implementation
   - Buat `ProductBloc` dengan real-time stream subscription
   - Deploy security rules
   - Buat CRUD UI

5. **Configure Storage**
   - Buat `FirebaseStorageService` dengan progress callback
   - Buat `UploadState` sealed class (initial, uploading, success, error)
   - Buat `UploadCubit` untuk manage upload lifecycle
   - Setup storage security rules
   - Buat upload UI dengan progress indicator

6. **Setup FCM**
   - Buat `NotificationService` (framework-agnostic, `@lazySingleton`)
   - Configure platform-specific settings (AndroidManifest, Info.plist)
   - Setup local notifications untuk foreground messages
   - Handle notification tap + navigation via GoRouter
   - Implement token persistence ke Firestore
   - Register background message handler

7. **Test Integration**
   - Test authentication flows (email, Google, sign out)
   - Test Firestore CRUD operations + real-time updates
   - Test file upload/download + progress tracking
   - Test push notifications (foreground, background, terminated)
   - Verify security rules dengan Firebase Emulator Suite
   - Test bloc lifecycle (subscription cancel, memory leaks)

## Pola Penting: BLoC vs Cubit Decision

Kapan pakai **Bloc** (event-driven):
- Auth: banyak event berbeda (sign in, sign up, sign out, check)
- Firestore list: perlu handle stream events + CRUD events
- Complex flows dengan multiple entry points

Kapan pakai **Cubit** (method-driven):
- Upload: satu flow linear (pilih file -> upload -> selesai)
- Simple toggle/counter states
- Tidak perlu event traceability

```
Bloc  = complex events, stream subscriptions, event traceability
Cubit = simple methods, linear flows, kurang boilerplate
```

## Injectable Registration Summary

```dart
// Semua registrations yang dibutuhkan untuk Firebase integration:

// Module (external dependencies)
@module
abstract class FirebaseModule {
  @lazySingleton
  FirebaseAuth get auth => FirebaseAuth.instance;

  @lazySingleton
  FirebaseFirestore get firestore => FirebaseFirestore.instance;

  @lazySingleton
  FirebaseStorage get storage => FirebaseStorage.instance;

  @lazySingleton
  FirebaseMessaging get messaging => FirebaseMessaging.instance;

  @lazySingleton
  GoogleSignIn get googleSignIn => GoogleSignIn();

  @lazySingleton
  FlutterLocalNotificationsPlugin get localNotifications =>
      FlutterLocalNotificationsPlugin();
}

// Repositories (auto-registered via @LazySingleton annotation pada class)
// - AuthRepositoryImpl -> AuthRepository
// - ProductRepositoryImpl -> ProductRepository

// Services (auto-registered via @lazySingleton annotation pada class)
// - FirebaseStorageService
// - NotificationService
// - FcmTokenRepository

// Blocs (auto-registered via @injectable annotation pada class)
// - AuthBloc
// - ProductBloc

// Cubits (auto-registered via @injectable annotation pada class)
// - UploadCubit

// Jalankan: dart run build_runner build --delete-conflicting-outputs
```

## Success Criteria

- [ ] Firebase project configured untuk semua platforms
- [ ] `MultiBlocProvider` di root widget menyediakan `AuthBloc`
- [ ] Authentication berfungsi (email/password & Google Sign-In)
- [ ] Auth state stream di-listen via `StreamSubscription` di `AuthBloc`
- [ ] `AuthBloc.close()` properly cancel subscription
- [ ] GoRouter redirect berdasarkan `AuthBloc` state
- [ ] Firestore CRUD operations berfungsi via `ProductBloc`
- [ ] Real-time updates dengan Firestore stream berfungsi
- [ ] `ProductBloc` handle stream subscription lifecycle dengan benar
- [ ] Security rules configured dan tested
- [ ] File upload dengan progress tracking berfungsi via `UploadCubit`
- [ ] `UploadCubit` cek `isClosed` sebelum emit progress
- [ ] Push notifications received di foreground & background
- [ ] Local notifications displayed correctly (foreground)
- [ ] Notification tap navigate ke route yang benar
- [ ] FCM token disimpan ke Firestore
- [ ] Semua dependencies registered di `get_it` via `injectable`
- [ ] Offline persistence enabled untuk Firestore

## Security Best Practices

### Firestore Rules (Lengkap)
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
      return field is string && field.size() > 0 && field.size() <= maxLength;
    }

    function isValidPrice(price) {
      return price is number && price >= 0 && price <= 999999999;
    }

    // Products collection
    match /products/{productId} {
      allow read: if isAuthenticated();
      allow create: if isAuthenticated()
        && isValidString(request.resource.data.name, 100)
        && isValidPrice(request.resource.data.price);
      allow update: if isAuthenticated()
        && isOwner(resource.data.ownerId);
      allow delete: if isAuthenticated()
        && isOwner(resource.data.ownerId);
    }

    // Users collection
    match /users/{userId} {
      allow read: if isAuthenticated() && isOwner(userId);
      allow write: if isAuthenticated() && isOwner(userId);
    }
  }
}
```

### Storage Rules
```
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /profile_images/{userId}/{allPaths=**} {
      allow read: if request.auth != null;
      allow write: if request.auth != null
        && request.auth.uid == userId
        && request.resource.size < 5 * 1024 * 1024
        && request.resource.contentType.matches('image/.*');
    }

    match /product_images/{allPaths=**} {
      allow read: if request.auth != null;
      allow write: if request.auth != null
        && request.resource.size < 10 * 1024 * 1024
        && request.resource.contentType.matches('image/.*');
    }
  }
}
```

## Next Steps

Setelah Firebase integration selesai:
1. Add comprehensive testing dengan Firebase Emulator Suite
2. Setup Firebase Analytics untuk tracking user behavior
3. Add Firebase Crashlytics untuk crash reporting
4. Implement Firebase Remote Config untuk feature flags
5. Explore Firebase App Check untuk API security
6. Consider Supabase sebagai alternative backend

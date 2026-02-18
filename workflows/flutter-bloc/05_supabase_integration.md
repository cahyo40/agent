# Workflow: Supabase Integration (flutter_bloc)

## Overview

Integrasi Supabase sebagai alternative backend dengan flutter_bloc state management: Authentication, PostgreSQL Database, Realtime subscriptions, dan Storage. Workflow ini mencakup setup lengkap dengan Row Level Security (RLS), event-driven state management menggunakan `Bloc<Event, State>` dan `Cubit`, serta lifecycle management via `close()`.

Perbedaan utama dengan versi Riverpod:
- Tidak ada `ProviderScope` — Supabase init di `bootstrap()` sebelum `runApp()`
- Auth menggunakan `AuthBloc` dengan sealed `SupabaseAuthEvent` dan `SupabaseAuthState` (Equatable)
- Auth state change di-listen via `StreamSubscription` di bloc constructor, di-cancel di `close()`
- Database CRUD menggunakan `ProductBloc` dengan event classes per operasi dan state yang menyertakan data + pagination info
- Realtime menggunakan `RealtimeProductBloc` — `RealtimeChannel` di-subscribe di constructor, `unsubscribe()` di `close()`
- Storage menggunakan `UploadCubit` (simple state tanpa event classes)
- DI via `get_it` + `injectable` — bukan `Get.put()` dan bukan `ProviderScope`
- Navigation redirect via `GoRouter` redirect guard, bukan `Get.offAllNamed()`

## Output Location

**Base Folder:** `sdlc/flutter-bloc/05-supabase-integration/`

**Output Files:**
- `supabase-setup.md` - Setup Supabase project dan Flutter
- `auth/` - Authentication (email, magic link, OAuth)
- `database/` - PostgreSQL operations dengan RLS
- `realtime/` - Realtime subscriptions
- `storage/` - File storage
- `security/` - RLS policies dan best practices
- `examples/` - Contoh implementasi lengkap

## Prerequisites

- Project setup dari `01_project_setup.md` selesai
- Supabase account (supabase.com)
- Supabase project created
- flutter_bloc, get_it, dan injectable sudah terkonfigurasi di project

## Deliverables

### 1. Supabase Project Setup

**Description:** Setup Supabase project dan konfigurasi Flutter app dengan flutter_bloc + get_it.

**Recommended Skills:** `senior-flutter-developer`, `senior-supabase-developer`

**Instructions:**
1. **Install Dependencies:**
   ```yaml
   dependencies:
     supabase_flutter: ^2.3.0
     flutter_bloc: ^8.1.0
     equatable: ^2.0.5
     get_it: ^7.6.0
     injectable: ^2.3.0
     dartz: ^0.10.1
     go_router: ^14.0.0
     flutter_image_compress: ^2.1.0
     image_picker: ^1.0.7
   
   dev_dependencies:
     injectable_generator: ^2.4.0
     build_runner: ^2.4.0
   ```

2. **Initialize Supabase di `bootstrap()`:**
   ```dart
   // bootstrap/bootstrap.dart
   import 'package:flutter/foundation.dart';
   import 'package:flutter/material.dart';
   import 'package:supabase_flutter/supabase_flutter.dart';
   import 'core/config/app_config.dart';
   import 'core/di/injection.dart';
   import 'app.dart';

   Future<void> bootstrap() async {
     WidgetsFlutterBinding.ensureInitialized();

     await Supabase.initialize(
       url: AppConfig.supabaseUrl,
       anonKey: AppConfig.supabaseAnonKey,
       debug: kDebugMode,
     );

     // Setup dependency injection
     configureDependencies();

     runApp(const MyApp());
   }
   ```
   > **Catatan:** Tidak ada `ProviderScope` wrapper. DI menggunakan `get_it` +
   > `injectable`. BlocProvider ditempatkan di widget tree di `MyApp` atau
   > per-route via `BlocProvider`.

3. **Environment Configuration:**
   - Jangan hardcode URL dan API key
   - Gunakan `--dart-define` atau `flutter_dotenv`

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
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/config/app_config.dart';
import 'core/di/injection.dart';
import 'app.dart';

Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: AppConfig.supabaseUrl,
    anonKey: AppConfig.supabaseAnonKey,
    debug: kDebugMode,
  );

  // Setup get_it + injectable DI
  configureDependencies();

  runApp(const MyApp());
}

// Global Supabase client access (framework-agnostic)
final supabase = Supabase.instance.client;

// core/di/injection.dart
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'injection.config.dart';

final getIt = GetIt.instance;

@InjectableInit()
void configureDependencies() => getIt.init();

// Register Supabase client sebagai external dependency
@module
abstract class RegisterModule {
  @lazySingleton
  SupabaseClient get supabaseClient => Supabase.instance.client;
}

// core/di/injection.config.dart
// File ini di-generate oleh build_runner:
//   dart run build_runner build --delete-conflicting-outputs

// app.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/di/injection.dart';
import 'core/router/app_router.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // AuthBloc hidup sepanjang app — global provider
        BlocProvider<AuthBloc>(
          create: (_) => getIt<AuthBloc>()..add(CheckAuthStatus()),
        ),
      ],
      child: MaterialApp.router(
        title: 'My App',
        routerConfig: appRouter,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
```

---

### 2. Supabase Authentication (flutter_bloc)

**Description:** Implementasi Supabase Auth dengan `AuthBloc` menggunakan sealed event/state classes (Equatable), `StreamSubscription` untuk auth state changes, dan lifecycle cleanup di `close()`.

**Recommended Skills:** `senior-flutter-developer`, `senior-supabase-developer`

**Instructions:**
1. **Auth Methods:**
   - Email/password (traditional)
   - Magic link (passwordless)
   - OAuth (Google, Apple, GitHub, etc.)
   - Phone OTP

2. **Auth State Management (flutter_bloc):**
   - `sealed class SupabaseAuthEvent extends Equatable` — semua events
   - `sealed class SupabaseAuthState extends Equatable` — semua states
   - `StreamSubscription<AuthState>` listen `onAuthStateChange` di constructor
   - Cancel subscription di `close()`
   - Navigation redirect via GoRouter `redirect` guard

3. **Auth Repository:**
   - Abstract contract (framework-agnostic)
   - Supabase implementation
   - Di-register via `@Injectable()` + `get_it`

**Output Format:**
```dart
// features/auth/domain/repositories/auth_repository.dart
// Framework-agnostic — sama dengan versi Riverpod/GetX
abstract class AuthRepository {
  Stream<AuthState> get authStateChanges;
  Future<Either<Failure, User>> signInWithEmailAndPassword(
    String email,
    String password,
  );
  Future<Either<Failure, void>> signInWithMagicLink(String email);
  Future<Either<Failure, User>> signInWithOAuth(String provider);
  Future<Either<Failure, User>> signUp(String email, String password);
  Future<Either<Failure, void>> signOut();
  User? get currentUser;
  Session? get currentSession;
}

// features/auth/data/repositories/supabase_auth_repository.dart
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../../../core/error/failures.dart';

@LazySingleton(as: AuthRepository)
class SupabaseAuthRepository implements AuthRepository {
  final SupabaseClient _supabase;

  SupabaseAuthRepository(this._supabase);

  @override
  Stream<AuthState> get authStateChanges =>
      _supabase.auth.onAuthStateChange;

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
  Future<Either<Failure, void>> signInWithMagicLink(String email) async {
    try {
      await _supabase.auth.signInWithOtp(
        email: email,
        shouldCreateUser: false,
      );

      return const Right(null);
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
        if (state.event == AuthChangeEvent.signedIn &&
            state.session != null) {
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
  Future<Either<Failure, User>> signUp(
    String email,
    String password,
  ) async {
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
  Future<Either<Failure, void>> signOut() async {
    try {
      await _supabase.auth.signOut();
      return const Right(null);
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

// ============================================================
// AUTH EVENTS — Sealed class dengan Equatable
// ============================================================

// features/auth/presentation/bloc/auth_event.dart
import 'package:equatable/equatable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

sealed class SupabaseAuthEvent extends Equatable {
  const SupabaseAuthEvent();

  @override
  List<Object?> get props => [];
}

/// Cek status auth saat app startup
class CheckAuthStatus extends SupabaseAuthEvent {}

/// Sign in dengan email dan password
class SignInWithEmail extends SupabaseAuthEvent {
  final String email;
  final String password;

  const SignInWithEmail({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}

/// Sign in dengan magic link (passwordless)
class SignInWithMagicLink extends SupabaseAuthEvent {
  final String email;

  const SignInWithMagicLink({required this.email});

  @override
  List<Object?> get props => [email];
}

/// Sign in dengan OAuth provider (Google, Apple, GitHub, etc.)
class SignInWithOAuth extends SupabaseAuthEvent {
  final String provider;

  const SignInWithOAuth({required this.provider});

  @override
  List<Object?> get props => [provider];
}

/// Sign up dengan email dan password
class SignUpWithEmail extends SupabaseAuthEvent {
  final String email;
  final String password;

  const SignUpWithEmail({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}

/// Sign out
class SignOut extends SupabaseAuthEvent {}

/// Internal event — dipanggil oleh stream listener, BUKAN oleh UI
class _AuthStateChanged extends SupabaseAuthEvent {
  final AuthState authState;

  const _AuthStateChanged(this.authState);

  @override
  List<Object?> get props => [authState];
}

// ============================================================
// AUTH STATES — Sealed class dengan Equatable
// ============================================================

// features/auth/presentation/bloc/auth_state.dart
import 'package:equatable/equatable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

sealed class SupabaseAuthState extends Equatable {
  const SupabaseAuthState();

  @override
  List<Object?> get props => [];
}

/// State awal — belum dicek
class AuthInitial extends SupabaseAuthState {}

/// Sedang proses (sign in, sign up, sign out)
class AuthLoading extends SupabaseAuthState {}

/// User sudah authenticated
class Authenticated extends SupabaseAuthState {
  final User user;
  final Session session;

  const Authenticated({required this.user, required this.session});

  @override
  List<Object?> get props => [user, session];
}

/// User belum login / sudah logout
class Unauthenticated extends SupabaseAuthState {}

/// Magic link berhasil dikirim — UI tampilkan "Cek email kamu"
class MagicLinkSent extends SupabaseAuthState {}

/// Sign up berhasil — UI tampilkan "Cek email untuk verifikasi"
class SignUpSuccess extends SupabaseAuthState {}

/// Error saat auth
class AuthError extends SupabaseAuthState {
  final String message;

  const AuthError({required this.message});

  @override
  List<Object?> get props => [message];
}

// ============================================================
// AUTH BLOC — Event-driven, dengan StreamSubscription
// ============================================================

// features/auth/presentation/bloc/auth_bloc.dart
import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;
import 'package:supabase_flutter/supabase_flutter.dart' as supa show AuthState;
import '../../domain/repositories/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

@lazySingleton
class AuthBloc extends Bloc<SupabaseAuthEvent, SupabaseAuthState> {
  final AuthRepository _authRepository;
  StreamSubscription<supa.AuthState>? _authSubscription;

  AuthBloc(this._authRepository) : super(AuthInitial()) {
    // Register event handlers
    on<CheckAuthStatus>(_onCheckAuthStatus);
    on<SignInWithEmail>(_onSignInWithEmail);
    on<SignInWithMagicLink>(_onSignInWithMagicLink);
    on<SignInWithOAuth>(_onSignInWithOAuth);
    on<SignUpWithEmail>(_onSignUpWithEmail);
    on<SignOut>(_onSignOut);
    on<_AuthStateChanged>(_onAuthStateChanged);

    // Listen to Supabase auth state changes
    _authSubscription = _authRepository.authStateChanges.listen(
      (authState) => add(_AuthStateChanged(authState)),
      onError: (error) => add(const _AuthStateChanged(
        supa.AuthState(AuthChangeEvent.signedOut, null),
      )),
    );
  }

  // ---- Check auth status saat app startup ----
  Future<void> _onCheckAuthStatus(
    CheckAuthStatus event,
    Emitter<SupabaseAuthState> emit,
  ) async {
    final user = _authRepository.currentUser;
    final session = _authRepository.currentSession;

    if (user != null && session != null) {
      emit(Authenticated(user: user, session: session));
    } else {
      emit(Unauthenticated());
    }
  }

  // ---- Sign in with email & password ----
  Future<void> _onSignInWithEmail(
    SignInWithEmail event,
    Emitter<SupabaseAuthState> emit,
  ) async {
    emit(AuthLoading());

    final result = await _authRepository.signInWithEmailAndPassword(
      event.email,
      event.password,
    );

    result.fold(
      (failure) => emit(AuthError(message: failure.message)),
      (user) {
        // Auth state listener akan emit Authenticated
        // Tidak perlu emit manual disini karena onAuthStateChange akan trigger
      },
    );
  }

  // ---- Sign in with magic link ----
  Future<void> _onSignInWithMagicLink(
    SignInWithMagicLink event,
    Emitter<SupabaseAuthState> emit,
  ) async {
    emit(AuthLoading());

    final result = await _authRepository.signInWithMagicLink(event.email);

    result.fold(
      (failure) => emit(AuthError(message: failure.message)),
      (_) => emit(MagicLinkSent()),
    );
  }

  // ---- Sign in with OAuth ----
  Future<void> _onSignInWithOAuth(
    SignInWithOAuth event,
    Emitter<SupabaseAuthState> emit,
  ) async {
    emit(AuthLoading());

    final result = await _authRepository.signInWithOAuth(event.provider);

    result.fold(
      (failure) => emit(AuthError(message: failure.message)),
      (user) {
        // Auth state listener akan handle
      },
    );
  }

  // ---- Sign up ----
  Future<void> _onSignUpWithEmail(
    SignUpWithEmail event,
    Emitter<SupabaseAuthState> emit,
  ) async {
    emit(AuthLoading());

    final result = await _authRepository.signUp(event.email, event.password);

    result.fold(
      (failure) => emit(AuthError(message: failure.message)),
      (user) => emit(SignUpSuccess()),
    );
  }

  // ---- Sign out ----
  Future<void> _onSignOut(
    SignOut event,
    Emitter<SupabaseAuthState> emit,
  ) async {
    emit(AuthLoading());

    final result = await _authRepository.signOut();

    result.fold(
      (failure) => emit(AuthError(message: failure.message)),
      (_) => emit(Unauthenticated()),
    );
  }

  // ---- Handle auth state changes dari Supabase stream ----
  void _onAuthStateChanged(
    _AuthStateChanged event,
    Emitter<SupabaseAuthState> emit,
  ) {
    final authState = event.authState;

    switch (authState.event) {
      case AuthChangeEvent.signedIn:
        if (authState.session != null) {
          emit(Authenticated(
            user: authState.session!.user,
            session: authState.session!,
          ));
        }
        break;
      case AuthChangeEvent.signedOut:
        emit(Unauthenticated());
        break;
      case AuthChangeEvent.tokenRefreshed:
        if (authState.session != null) {
          emit(Authenticated(
            user: authState.session!.user,
            session: authState.session!,
          ));
        }
        break;
      case AuthChangeEvent.userUpdated:
        if (authState.session != null) {
          emit(Authenticated(
            user: authState.session!.user,
            session: authState.session!,
          ));
        }
        break;
      case AuthChangeEvent.passwordRecovery:
        // Handle password recovery — bisa emit state khusus jika perlu
        break;
      default:
        break;
    }
  }

  @override
  Future<void> close() {
    _authSubscription?.cancel();
    return super.close();
  }
}

// ============================================================
// GOROUTER REDIRECT — Proteksi route berdasarkan auth state
// ============================================================

// core/router/app_router.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/bloc/auth_state.dart';

final appRouter = GoRouter(
  initialLocation: '/splash',
  redirect: (context, state) {
    final authState = context.read<AuthBloc>().state;
    final isOnAuthPage = state.matchedLocation == '/login' ||
        state.matchedLocation == '/register';
    final isSplash = state.matchedLocation == '/splash';

    // Masih loading — tetap di splash
    if (authState is AuthInitial || authState is AuthLoading) {
      return isSplash ? null : '/splash';
    }

    // Belum login — redirect ke login
    if (authState is Unauthenticated || authState is AuthError) {
      return isOnAuthPage ? null : '/login';
    }

    // Sudah login tapi masih di auth page — redirect ke home
    if (authState is Authenticated && (isOnAuthPage || isSplash)) {
      return '/home';
    }

    return null;
  },
  routes: [
    // ... define routes
  ],
);

// ============================================================
// LOGIN PAGE — Contoh UI yang menggunakan AuthBloc
// ============================================================

// features/auth/presentation/pages/login_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: BlocListener<AuthBloc, SupabaseAuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
          if (state is MagicLinkSent) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Cek email kamu untuk link login'),
              ),
            );
          }
          if (state is SignUpSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Akun dibuat! Cek email untuk verifikasi.'),
              ),
            );
          }
          // Navigation handled oleh GoRouter redirect
        },
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
              ),
              const SizedBox(height: 24),

              // Login button dengan loading state
              BlocBuilder<AuthBloc, SupabaseAuthState>(
                builder: (context, state) {
                  final isLoading = state is AuthLoading;

                  return SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isLoading
                          ? null
                          : () => context.read<AuthBloc>().add(
                                SignInWithEmail(
                                  email: _emailController.text.trim(),
                                  password: _passwordController.text,
                                ),
                              ),
                      child: isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Login'),
                    ),
                  );
                },
              ),

              const SizedBox(height: 12),

              // Magic link
              TextButton(
                onPressed: () => context.read<AuthBloc>().add(
                      SignInWithMagicLink(
                        email: _emailController.text.trim(),
                      ),
                    ),
                child: const Text('Login dengan Magic Link'),
              ),

              const SizedBox(height: 12),

              // OAuth buttons
              OutlinedButton.icon(
                onPressed: () => context.read<AuthBloc>().add(
                      const SignInWithOAuth(provider: 'google'),
                    ),
                icon: const Icon(Icons.g_mobiledata),
                label: const Text('Login dengan Google'),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: () => context.read<AuthBloc>().add(
                      const SignInWithOAuth(provider: 'apple'),
                    ),
                icon: const Icon(Icons.apple),
                label: const Text('Login dengan Apple'),
              ),

              const SizedBox(height: 24),

              // Register link
              TextButton(
                onPressed: () => context.go('/register'),
                child: const Text('Belum punya akun? Daftar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

---

### 3. PostgreSQL Database Operations (flutter_bloc)

**Description:** CRUD operations dengan Supabase PostgreSQL, Row Level Security, dan `ProductBloc` event-driven. State menyertakan data list, pagination info, dan loading/error status.

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

3. **Data Source (Framework-Agnostic):**
   - Class ini SAMA dengan versi Riverpod/GetX — tidak bergantung pada state management

4. **Bloc (flutter_bloc-Specific):**
   - Sealed `ProductEvent` classes per operasi CRUD
   - Single `ProductState` class dengan copyWith untuk data + loading + error + pagination
   - Atau sealed states — pilih sesuai preferensi tim
   - Di-register via `@Injectable()` + `get_it`

**Output Format:**
```dart
// ============================================================
// DATA SOURCE — Framework-agnostic, sama dengan versi Riverpod/GetX
// ============================================================

// features/product/data/datasources/product_supabase_ds.dart
import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/product_model.dart';

@lazySingleton
class ProductSupabaseDataSource {
  final SupabaseClient _supabase;

  ProductSupabaseDataSource(this._supabase);

  SupabaseQueryBuilder get _productsTable =>
      _supabase.from('products');

  Future<List<ProductModel>> getProducts() async {
    final response = await _productsTable
        .select()
        .order('created_at', ascending: false);

    return (response as List)
        .map((json) => ProductModel.fromJson(json))
        .toList();
  }

  Future<ProductModel> getProductById(String id) async {
    final response = await _productsTable
        .select()
        .eq('id', id)
        .single();

    return ProductModel.fromJson(response);
  }

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
  Future<List<Map<String, dynamic>>> getProductsWithUser() async {
    final response = await _productsTable
        .select('*, users(*)')
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }
}

// ============================================================
// PRODUCT MODEL
// ============================================================

// features/product/data/models/product_model.dart
import 'package:equatable/equatable.dart';

class ProductModel extends Equatable {
  final String id;
  final String name;
  final double price;
  final String? description;
  final String userId;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const ProductModel({
    required this.id,
    required this.name,
    required this.price,
    this.description,
    required this.userId,
    required this.createdAt,
    this.updatedAt,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] as String,
      name: json['name'] as String,
      price: (json['price'] as num).toDouble(),
      description: json['description'] as String?,
      userId: json['user_id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'price': price,
        'description': description,
        'user_id': userId,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt?.toIso8601String(),
      };

  @override
  List<Object?> get props =>
      [id, name, price, description, userId, createdAt, updatedAt];
}

// ============================================================
// PRODUCT EVENTS — Sealed classes per operasi CRUD
// ============================================================

// features/product/presentation/bloc/product_event.dart
import 'package:equatable/equatable.dart';
import '../../data/models/product_model.dart';

sealed class ProductEvent extends Equatable {
  const ProductEvent();

  @override
  List<Object?> get props => [];
}

/// Fetch semua produk
class FetchProducts extends ProductEvent {}

/// Fetch dengan pagination (load more)
class FetchProductsPaginated extends ProductEvent {
  final bool refresh;

  const FetchProductsPaginated({this.refresh = false});

  @override
  List<Object?> get props => [refresh];
}

/// Search produk berdasarkan query
class SearchProducts extends ProductEvent {
  final String query;

  const SearchProducts({required this.query});

  @override
  List<Object?> get props => [query];
}

/// Fetch single product by ID
class FetchProductById extends ProductEvent {
  final String id;

  const FetchProductById({required this.id});

  @override
  List<Object?> get props => [id];
}

/// Create product baru
class CreateProduct extends ProductEvent {
  final ProductModel product;

  const CreateProduct({required this.product});

  @override
  List<Object?> get props => [product];
}

/// Update existing product
class UpdateProduct extends ProductEvent {
  final ProductModel product;

  const UpdateProduct({required this.product});

  @override
  List<Object?> get props => [product];
}

/// Delete product by ID
class DeleteProduct extends ProductEvent {
  final String id;

  const DeleteProduct({required this.id});

  @override
  List<Object?> get props => [id];
}

// ============================================================
// PRODUCT STATE — Single class dengan copyWith
// Menyertakan data, pagination info, loading, dan error
// ============================================================

// features/product/presentation/bloc/product_state.dart
import 'package:equatable/equatable.dart';
import '../../data/models/product_model.dart';

enum ProductStatus { initial, loading, loaded, error }

class ProductState extends Equatable {
  final List<ProductModel> products;
  final ProductModel? selectedProduct;
  final ProductStatus status;
  final String? errorMessage;
  final int currentPage;
  final bool hasMore;
  final String searchQuery;

  const ProductState({
    this.products = const [],
    this.selectedProduct,
    this.status = ProductStatus.initial,
    this.errorMessage,
    this.currentPage = 1,
    this.hasMore = true,
    this.searchQuery = '',
  });

  ProductState copyWith({
    List<ProductModel>? products,
    ProductModel? selectedProduct,
    ProductStatus? status,
    String? errorMessage,
    int? currentPage,
    bool? hasMore,
    String? searchQuery,
  }) {
    return ProductState(
      products: products ?? this.products,
      selectedProduct: selectedProduct ?? this.selectedProduct,
      status: status ?? this.status,
      errorMessage: errorMessage,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  @override
  List<Object?> get props => [
        products,
        selectedProduct,
        status,
        errorMessage,
        currentPage,
        hasMore,
        searchQuery,
      ];
}

// ============================================================
// PRODUCT BLOC — Event-driven CRUD
// ============================================================

// features/product/presentation/bloc/product_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../data/datasources/product_supabase_ds.dart';
import 'product_event.dart';
import 'product_state.dart';

@injectable
class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final ProductSupabaseDataSource _dataSource;
  static const int _pageSize = 20;

  ProductBloc(this._dataSource) : super(const ProductState()) {
    on<FetchProducts>(_onFetchProducts);
    on<FetchProductsPaginated>(_onFetchProductsPaginated);
    on<SearchProducts>(_onSearchProducts);
    on<FetchProductById>(_onFetchProductById);
    on<CreateProduct>(_onCreateProduct);
    on<UpdateProduct>(_onUpdateProduct);
    on<DeleteProduct>(_onDeleteProduct);
  }

  // ---- Fetch all products ----
  Future<void> _onFetchProducts(
    FetchProducts event,
    Emitter<ProductState> emit,
  ) async {
    emit(state.copyWith(status: ProductStatus.loading));

    try {
      final products = await _dataSource.getProducts();
      emit(state.copyWith(
        status: ProductStatus.loaded,
        products: products,
        errorMessage: null,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ProductStatus.error,
        errorMessage: 'Gagal memuat produk: $e',
      ));
    }
  }

  // ---- Fetch with pagination ----
  Future<void> _onFetchProductsPaginated(
    FetchProductsPaginated event,
    Emitter<ProductState> emit,
  ) async {
    if (event.refresh) {
      emit(state.copyWith(
        status: ProductStatus.loading,
        products: [],
        currentPage: 1,
        hasMore: true,
      ));
    }

    if (!state.hasMore || state.status == ProductStatus.loading) return;

    emit(state.copyWith(status: ProductStatus.loading));

    try {
      final newProducts = await _dataSource.getProductsWithPagination(
        page: state.currentPage,
        limit: _pageSize,
      );

      emit(state.copyWith(
        status: ProductStatus.loaded,
        products: [...state.products, ...newProducts],
        currentPage: state.currentPage + 1,
        hasMore: newProducts.length >= _pageSize,
        errorMessage: null,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ProductStatus.error,
        errorMessage: 'Gagal memuat halaman: $e',
      ));
    }
  }

  // ---- Search products ----
  Future<void> _onSearchProducts(
    SearchProducts event,
    Emitter<ProductState> emit,
  ) async {
    emit(state.copyWith(
      status: ProductStatus.loading,
      searchQuery: event.query,
    ));

    try {
      final List products;
      if (event.query.isEmpty) {
        products = await _dataSource.getProducts();
      } else {
        products = await _dataSource.searchProducts(event.query);
      }

      emit(state.copyWith(
        status: ProductStatus.loaded,
        products: products.cast(),
        errorMessage: null,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ProductStatus.error,
        errorMessage: 'Search gagal: $e',
      ));
    }
  }

  // ---- Get single product ----
  Future<void> _onFetchProductById(
    FetchProductById event,
    Emitter<ProductState> emit,
  ) async {
    emit(state.copyWith(status: ProductStatus.loading));

    try {
      final product = await _dataSource.getProductById(event.id);
      emit(state.copyWith(
        status: ProductStatus.loaded,
        selectedProduct: product,
        errorMessage: null,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ProductStatus.error,
        errorMessage: 'Gagal memuat detail: $e',
      ));
    }
  }

  // ---- Create product ----
  Future<void> _onCreateProduct(
    CreateProduct event,
    Emitter<ProductState> emit,
  ) async {
    emit(state.copyWith(status: ProductStatus.loading));

    try {
      final created = await _dataSource.createProduct(event.product);
      emit(state.copyWith(
        status: ProductStatus.loaded,
        products: [created, ...state.products],
        errorMessage: null,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ProductStatus.error,
        errorMessage: 'Gagal membuat produk: $e',
      ));
    }
  }

  // ---- Update product ----
  Future<void> _onUpdateProduct(
    UpdateProduct event,
    Emitter<ProductState> emit,
  ) async {
    emit(state.copyWith(status: ProductStatus.loading));

    try {
      final updated = await _dataSource.updateProduct(event.product);
      final updatedList = state.products.map((p) {
        return p.id == updated.id ? updated : p;
      }).toList();

      emit(state.copyWith(
        status: ProductStatus.loaded,
        products: updatedList,
        selectedProduct: updated,
        errorMessage: null,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ProductStatus.error,
        errorMessage: 'Gagal update produk: $e',
      ));
    }
  }

  // ---- Delete product ----
  Future<void> _onDeleteProduct(
    DeleteProduct event,
    Emitter<ProductState> emit,
  ) async {
    emit(state.copyWith(status: ProductStatus.loading));

    try {
      await _dataSource.deleteProduct(event.id);
      final filtered = state.products
          .where((p) => p.id != event.id)
          .toList();

      emit(state.copyWith(
        status: ProductStatus.loaded,
        products: filtered,
        errorMessage: null,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ProductStatus.error,
        errorMessage: 'Gagal hapus produk: $e',
      ));
    }
  }
}

// ============================================================
// PRODUCT LIST PAGE — Contoh UI dengan BlocBuilder
// ============================================================

// features/product/presentation/pages/product_list_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection.dart';
import '../bloc/product_bloc.dart';
import '../bloc/product_event.dart';
import '../bloc/product_state.dart';

class ProductListPage extends StatelessWidget {
  const ProductListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<ProductBloc>()..add(FetchProducts()),
      child: const _ProductListView(),
    );
  }
}

class _ProductListView extends StatelessWidget {
  const _ProductListView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Produk'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.go('/product/create'),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              onChanged: (val) => context.read<ProductBloc>().add(
                    SearchProducts(query: val),
                  ),
              decoration: const InputDecoration(
                hintText: 'Cari produk...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
          ),

          // Product list
          Expanded(
            child: BlocBuilder<ProductBloc, ProductState>(
              builder: (context, state) {
                if (state.status == ProductStatus.loading &&
                    state.products.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state.status == ProductStatus.error &&
                    state.products.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(state.errorMessage ?? 'Unknown error'),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: () => context
                              .read<ProductBloc>()
                              .add(FetchProducts()),
                          child: const Text('Coba Lagi'),
                        ),
                      ],
                    ),
                  );
                }

                if (state.products.isEmpty) {
                  return const Center(child: Text('Belum ada produk'));
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    context.read<ProductBloc>().add(FetchProducts());
                  },
                  child: ListView.builder(
                    itemCount: state.products.length,
                    itemBuilder: (context, index) {
                      final product = state.products[index];
                      return ListTile(
                        title: Text(product.name),
                        subtitle: Text('Rp ${product.price}'),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => context
                              .read<ProductBloc>()
                              .add(DeleteProduct(id: product.id)),
                        ),
                        onTap: () => context.go(
                          '/product/detail/${product.id}',
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// SQL: RLS POLICIES — Framework-agnostic
// Dijalankan di Supabase SQL Editor
// ============================================================
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

### 4. Realtime Subscriptions (flutter_bloc)

**Description:** Real-time updates dengan Supabase Realtime, dikelola melalui `Bloc` lifecycle. `RealtimeChannel` di-subscribe di constructor bloc, `unsubscribe()` di `close()`. Perubahan data dari callback realtime di-dispatch sebagai internal event.

**Recommended Skills:** `senior-flutter-developer`, `senior-supabase-developer`

**Instructions:**
1. **Setup Realtime:**
   - Enable realtime di Supabase Dashboard
   - Subscribe ke table changes di bloc constructor
   - Unsubscribe di `close()`
   - Handle INSERT, UPDATE, DELETE events

2. **Channel Management:**
   - `RealtimeChannel?` disimpan sebagai field di bloc
   - Payload dari callback di-convert jadi event internal
   - Bloc state di-update sesuai event type

3. **Pattern:**
   - Internal event `_RealtimeUpdate` membawa payload
   - Bloc memproses payload dan update state
   - UI hanya perlu `BlocBuilder` — tidak perlu manage subscription

**Output Format:**
```dart
// ============================================================
// REALTIME EVENTS
// ============================================================

// features/product/presentation/bloc/realtime_product_event.dart
import 'package:equatable/equatable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/models/product_model.dart';

sealed class RealtimeProductEvent extends Equatable {
  const RealtimeProductEvent();

  @override
  List<Object?> get props => [];
}

/// Load initial data saat bloc pertama kali dibuat
class LoadRealtimeProducts extends RealtimeProductEvent {}

/// Internal event — dipanggil oleh realtime callback, BUKAN oleh UI
class _RealtimeUpdate extends RealtimeProductEvent {
  final PostgresChangePayload payload;

  const _RealtimeUpdate(this.payload);

  @override
  List<Object?> get props => [payload];
}

/// Manual refresh — re-fetch semua data
class RefreshRealtimeProducts extends RealtimeProductEvent {}

// ============================================================
// REALTIME STATES
// ============================================================

// features/product/presentation/bloc/realtime_product_state.dart
import 'package:equatable/equatable.dart';
import '../../data/models/product_model.dart';

sealed class RealtimeProductState extends Equatable {
  const RealtimeProductState();

  @override
  List<Object?> get props => [];
}

class RealtimeProductInitial extends RealtimeProductState {}

class RealtimeProductLoading extends RealtimeProductState {}

class RealtimeProductLoaded extends RealtimeProductState {
  final List<ProductModel> products;

  const RealtimeProductLoaded({required this.products});

  @override
  List<Object?> get props => [products];
}

class RealtimeProductError extends RealtimeProductState {
  final String message;

  const RealtimeProductError({required this.message});

  @override
  List<Object?> get props => [message];
}

// ============================================================
// REALTIME PRODUCT BLOC
// Channel subscribe di constructor, unsubscribe di close()
// ============================================================

// features/product/presentation/bloc/realtime_product_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/datasources/product_supabase_ds.dart';
import '../../data/models/product_model.dart';
import 'realtime_product_event.dart';
import 'realtime_product_state.dart';

@injectable
class RealtimeProductBloc
    extends Bloc<RealtimeProductEvent, RealtimeProductState> {
  final ProductSupabaseDataSource _dataSource;
  final SupabaseClient _supabase;

  RealtimeChannel? _channel;

  RealtimeProductBloc(this._dataSource, this._supabase)
      : super(RealtimeProductInitial()) {
    on<LoadRealtimeProducts>(_onLoadRealtimeProducts);
    on<_RealtimeUpdate>(_onRealtimeUpdate);
    on<RefreshRealtimeProducts>(_onRefreshRealtimeProducts);

    // Subscribe ke realtime channel langsung di constructor
    _channel = _supabase
        .channel('products_realtime')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'products',
          callback: (payload) {
            // Dispatch internal event — bloc akan handle di _onRealtimeUpdate
            add(_RealtimeUpdate(payload));
          },
        )
        .subscribe();
  }

  // ---- Load initial data ----
  Future<void> _onLoadRealtimeProducts(
    LoadRealtimeProducts event,
    Emitter<RealtimeProductState> emit,
  ) async {
    emit(RealtimeProductLoading());

    try {
      final products = await _dataSource.getProducts();
      emit(RealtimeProductLoaded(products: products));
    } catch (e) {
      emit(RealtimeProductError(message: 'Gagal memuat produk: $e'));
    }
  }

  // ---- Handle realtime update dari Supabase ----
  Future<void> _onRealtimeUpdate(
    _RealtimeUpdate event,
    Emitter<RealtimeProductState> emit,
  ) async {
    final currentState = state;
    if (currentState is! RealtimeProductLoaded) {
      // Kalau belum pernah load, fetch semua dulu
      add(LoadRealtimeProducts());
      return;
    }

    final products = List<ProductModel>.from(currentState.products);
    final payload = event.payload;

    switch (payload.eventType) {
      case PostgresChangeEvent.insert:
        if (payload.newRecord.isNotEmpty) {
          final newProduct = ProductModel.fromJson(payload.newRecord);
          products.insert(0, newProduct);
        }
        break;

      case PostgresChangeEvent.update:
        if (payload.newRecord.isNotEmpty) {
          final updatedProduct = ProductModel.fromJson(payload.newRecord);
          final index = products.indexWhere((p) => p.id == updatedProduct.id);
          if (index != -1) {
            products[index] = updatedProduct;
          }
        }
        break;

      case PostgresChangeEvent.delete:
        if (payload.oldRecord.isNotEmpty) {
          final deletedId = payload.oldRecord['id'] as String?;
          if (deletedId != null) {
            products.removeWhere((p) => p.id == deletedId);
          }
        }
        break;

      default:
        // PostgresChangeEvent.all — tidak terjadi sebagai event type
        break;
    }

    emit(RealtimeProductLoaded(products: products));
  }

  // ---- Manual refresh ----
  Future<void> _onRefreshRealtimeProducts(
    RefreshRealtimeProducts event,
    Emitter<RealtimeProductState> emit,
  ) async {
    emit(RealtimeProductLoading());

    try {
      final products = await _dataSource.getProducts();
      emit(RealtimeProductLoaded(products: products));
    } catch (e) {
      emit(RealtimeProductError(message: 'Gagal refresh: $e'));
    }
  }

  @override
  Future<void> close() {
    _channel?.unsubscribe();
    return super.close();
  }
}

// ============================================================
// WATCH SINGLE PRODUCT — Bloc yang listen 1 product saja
// ============================================================

// features/product/presentation/bloc/product_detail_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/models/product_model.dart';

// Events
sealed class ProductDetailEvent extends Equatable {
  const ProductDetailEvent();
  @override
  List<Object?> get props => [];
}

class WatchProduct extends ProductDetailEvent {
  final String productId;
  const WatchProduct({required this.productId});
  @override
  List<Object?> get props => [productId];
}

class _ProductUpdated extends ProductDetailEvent {
  final Map<String, dynamic> record;
  const _ProductUpdated(this.record);
  @override
  List<Object?> get props => [record];
}

// States
sealed class ProductDetailState extends Equatable {
  const ProductDetailState();
  @override
  List<Object?> get props => [];
}

class ProductDetailInitial extends ProductDetailState {}
class ProductDetailLoading extends ProductDetailState {}

class ProductDetailLoaded extends ProductDetailState {
  final ProductModel product;
  const ProductDetailLoaded({required this.product});
  @override
  List<Object?> get props => [product];
}

class ProductDetailError extends ProductDetailState {
  final String message;
  const ProductDetailError({required this.message});
  @override
  List<Object?> get props => [message];
}

// Bloc
class ProductDetailBloc extends Bloc<ProductDetailEvent, ProductDetailState> {
  final SupabaseClient _supabase;
  RealtimeChannel? _channel;

  ProductDetailBloc(this._supabase) : super(ProductDetailInitial()) {
    on<WatchProduct>(_onWatchProduct);
    on<_ProductUpdated>(_onProductUpdated);
  }

  Future<void> _onWatchProduct(
    WatchProduct event,
    Emitter<ProductDetailState> emit,
  ) async {
    emit(ProductDetailLoading());

    try {
      // Initial fetch
      final response = await _supabase
          .from('products')
          .select()
          .eq('id', event.productId)
          .single();

      emit(ProductDetailLoaded(product: ProductModel.fromJson(response)));

      // Subscribe to changes on this specific product
      _channel?.unsubscribe(); // cleanup previous channel jika ada
      _channel = _supabase
          .channel('product_${event.productId}')
          .onPostgresChanges(
            event: PostgresChangeEvent.all,
            schema: 'public',
            table: 'products',
            filter: PostgresChangeFilter(
              type: PostgresChangeFilterType.eq,
              column: 'id',
              value: event.productId,
            ),
            callback: (payload) {
              if (payload.newRecord.isNotEmpty) {
                add(_ProductUpdated(payload.newRecord));
              }
            },
          )
          .subscribe();
    } catch (e) {
      emit(ProductDetailError(message: 'Gagal memuat detail: $e'));
    }
  }

  void _onProductUpdated(
    _ProductUpdated event,
    Emitter<ProductDetailState> emit,
  ) {
    emit(ProductDetailLoaded(
      product: ProductModel.fromJson(event.record),
    ));
  }

  @override
  Future<void> close() {
    _channel?.unsubscribe();
    return super.close();
  }
}

// ============================================================
// CHAT BLOC — Contoh realtime untuk messaging
// ============================================================

// features/chat/presentation/bloc/chat_bloc.dart
import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Events
sealed class ChatEvent extends Equatable {
  const ChatEvent();
  @override
  List<Object?> get props => [];
}

class LoadMessages extends ChatEvent {}

class SendMessage extends ChatEvent {
  final String text;
  const SendMessage({required this.text});
  @override
  List<Object?> get props => [text];
}

class _MessageInserted extends ChatEvent {
  final Map<String, dynamic> record;
  const _MessageInserted(this.record);
  @override
  List<Object?> get props => [record];
}

class _MessageDeleted extends ChatEvent {
  final Map<String, dynamic> oldRecord;
  const _MessageDeleted(this.oldRecord);
  @override
  List<Object?> get props => [oldRecord];
}

// State
class ChatState extends Equatable {
  final List<Map<String, dynamic>> messages;
  final bool isLoading;
  final bool isConnected;
  final String? error;

  const ChatState({
    this.messages = const [],
    this.isLoading = false,
    this.isConnected = false,
    this.error,
  });

  ChatState copyWith({
    List<Map<String, dynamic>>? messages,
    bool? isLoading,
    bool? isConnected,
    String? error,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      isConnected: isConnected ?? this.isConnected,
      error: error,
    );
  }

  @override
  List<Object?> get props => [messages, isLoading, isConnected, error];
}

// Bloc
class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final SupabaseClient _supabase;
  RealtimeChannel? _channel;

  ChatBloc(this._supabase) : super(const ChatState()) {
    on<LoadMessages>(_onLoadMessages);
    on<SendMessage>(_onSendMessage);
    on<_MessageInserted>(_onMessageInserted);
    on<_MessageDeleted>(_onMessageDeleted);

    // Subscribe ke realtime messages
    _channel = _supabase
        .channel('messages_channel')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'messages',
          callback: (payload) {
            add(_MessageInserted(payload.newRecord));
          },
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.delete,
          schema: 'public',
          table: 'messages',
          callback: (payload) {
            add(_MessageDeleted(payload.oldRecord));
          },
        )
        .subscribe((status, error) {
      // Tidak bisa emit langsung dari callback — tapi bisa track connection
      // Gunakan add() jika perlu update state
    });
  }

  Future<void> _onLoadMessages(
    LoadMessages event,
    Emitter<ChatState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));

    try {
      final response = await _supabase
          .from('messages')
          .select('*, users(name, avatar_url)')
          .order('created_at', ascending: true)
          .limit(50);

      emit(state.copyWith(
        isLoading: false,
        messages: List<Map<String, dynamic>>.from(response),
        isConnected: true,
        error: null,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: 'Gagal memuat pesan: $e',
      ));
    }
  }

  Future<void> _onSendMessage(
    SendMessage event,
    Emitter<ChatState> emit,
  ) async {
    try {
      await _supabase.from('messages').insert({
        'text': event.text,
        'user_id': _supabase.auth.currentUser!.id,
      });
      // Realtime subscription akan otomatis add ke messages
    } catch (e) {
      emit(state.copyWith(error: 'Gagal mengirim pesan: $e'));
    }
  }

  void _onMessageInserted(
    _MessageInserted event,
    Emitter<ChatState> emit,
  ) {
    emit(state.copyWith(
      messages: [...state.messages, event.record],
    ));
  }

  void _onMessageDeleted(
    _MessageDeleted event,
    Emitter<ChatState> emit,
  ) {
    final filtered = state.messages
        .where((m) => m['id'] != event.oldRecord['id'])
        .toList();
    emit(state.copyWith(messages: filtered));
  }

  @override
  Future<void> close() {
    _channel?.unsubscribe();
    return super.close();
  }
}

// ============================================================
// PRESENCE TRACKING — Siapa yang online (Cubit)
// ============================================================

// features/presence/presentation/cubit/presence_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PresenceState extends Equatable {
  final List<Map<String, dynamic>> onlineUsers;

  const PresenceState({this.onlineUsers = const []});

  @override
  List<Object?> get props => [onlineUsers];
}

class PresenceCubit extends Cubit<PresenceState> {
  final SupabaseClient _supabase;
  RealtimeChannel? _presenceChannel;

  PresenceCubit(this._supabase) : super(const PresenceState()) {
    _trackPresence();
  }

  void _trackPresence() {
    final userId = _supabase.auth.currentUser?.id ?? 'anonymous';

    _presenceChannel = _supabase.channel('online_users')
      ..onPresenceSync((payload) {
        final presenceState = _presenceChannel!.presenceState();
        final users = <Map<String, dynamic>>[];

        for (final entry in presenceState.entries) {
          for (final presence in entry.value) {
            users.add(presence.payload);
          }
        }
        emit(PresenceState(onlineUsers: users));
      })
      ..onPresenceJoin((payload) {
        // User baru join
      })
      ..onPresenceLeave((payload) {
        // User leave
      })
      ..subscribe((status, error) async {
        if (status == RealtimeSubscribeStatus.subscribed) {
          await _presenceChannel!.track({
            'user_id': userId,
            'online_at': DateTime.now().toIso8601String(),
          });
        }
      });
  }

  @override
  Future<void> close() {
    _presenceChannel?.unsubscribe();
    return super.close();
  }
}
```

---

### 5. Supabase Storage (flutter_bloc — Cubit)

**Description:** File storage dengan Supabase Storage. Storage service adalah framework-agnostic, controller menggunakan `UploadCubit` untuk upload progress tracking. Cubit dipilih karena upload hanya perlu simple state transitions tanpa complex events.

**Recommended Skills:** `senior-flutter-developer`, `senior-supabase-developer`

**Instructions:**
1. **Upload Files:**
   - Image upload dengan compression
   - Progress tracking via state emission
   - Upload to specific bucket

2. **Download Files:**
   - Get signed URLs
   - Cache management

3. **Service Registration:**
   - `SupabaseStorageService` di-register via `@LazySingleton()` di get_it
   - `UploadCubit` di-provide via `BlocProvider` di widget tree

**Output Format:**
```dart
// ============================================================
// STORAGE SERVICE — Framework-agnostic, sama dengan Riverpod/GetX
// ============================================================

// core/storage/supabase_storage_service.dart
import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import '../error/failures.dart';

@lazySingleton
class SupabaseStorageService {
  final SupabaseClient _supabase;

  SupabaseStorageService(this._supabase);

  Future<Either<Failure, String>> uploadFile({
    required File file,
    required String bucket,
    required String path,
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
        return const Left(StorageFailure('Gagal compress gambar'));
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

  Future<Either<Failure, void>> deleteFile({
    required String bucket,
    required String path,
  }) async {
    try {
      await _supabase.storage.from(bucket).remove([path]);
      return const Right(null);
    } on StorageException catch (e) {
      return Left(StorageFailure(e.message));
    }
  }

  Future<Either<Failure, List<FileObject>>> listFiles({
    required String bucket,
    required String path,
  }) async {
    try {
      final files = await _supabase.storage.from(bucket).list(path: path);
      return Right(files);
    } on StorageException catch (e) {
      return Left(StorageFailure(e.message));
    }
  }
}

// ============================================================
// UPLOAD STATE
// ============================================================

// features/upload/presentation/cubit/upload_state.dart
import 'dart:io';
import 'package:equatable/equatable.dart';

enum UploadStatus { initial, picking, uploading, success, error }

class UploadState extends Equatable {
  final File? selectedFile;
  final double progress;
  final UploadStatus status;
  final String? uploadedUrl;
  final String? errorMessage;
  final List<String> uploadedFiles;

  const UploadState({
    this.selectedFile,
    this.progress = 0.0,
    this.status = UploadStatus.initial,
    this.uploadedUrl,
    this.errorMessage,
    this.uploadedFiles = const [],
  });

  UploadState copyWith({
    File? selectedFile,
    double? progress,
    UploadStatus? status,
    String? uploadedUrl,
    String? errorMessage,
    List<String>? uploadedFiles,
  }) {
    return UploadState(
      selectedFile: selectedFile ?? this.selectedFile,
      progress: progress ?? this.progress,
      status: status ?? this.status,
      uploadedUrl: uploadedUrl ?? this.uploadedUrl,
      errorMessage: errorMessage,
      uploadedFiles: uploadedFiles ?? this.uploadedFiles,
    );
  }

  @override
  List<Object?> get props =>
      [selectedFile, progress, status, uploadedUrl, errorMessage, uploadedFiles];
}

// ============================================================
// UPLOAD CUBIT — Simple state tanpa event classes
// ============================================================

// features/upload/presentation/cubit/upload_cubit.dart
import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/storage/supabase_storage_service.dart';
import 'upload_state.dart';

@injectable
class UploadCubit extends Cubit<UploadState> {
  final SupabaseStorageService _storageService;

  UploadCubit(this._storageService) : super(const UploadState());

  // ---- Pick image dari gallery ----
  Future<void> pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1920,
      maxHeight: 1080,
    );

    if (pickedFile != null) {
      emit(state.copyWith(
        selectedFile: File(pickedFile.path),
        status: UploadStatus.initial,
      ));
    }
  }

  // ---- Pick image dari camera ----
  Future<void> takePhoto() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 1920,
      maxHeight: 1080,
    );

    if (pickedFile != null) {
      emit(state.copyWith(
        selectedFile: File(pickedFile.path),
        status: UploadStatus.initial,
      ));
    }
  }

  // ---- Upload selected image ----
  Future<void> uploadImage({
    required String bucket,
    required String folder,
  }) async {
    if (state.selectedFile == null) return;

    emit(state.copyWith(status: UploadStatus.uploading, progress: 0.0));

    // Simulate progress (Supabase SDK belum support stream progress)
    _simulateProgress();

    final result = await _storageService.uploadImage(
      imageFile: state.selectedFile!,
      bucket: bucket,
      folder: folder,
    );

    result.fold(
      (failure) => emit(state.copyWith(
        status: UploadStatus.error,
        errorMessage: failure.message,
      )),
      (url) => emit(state.copyWith(
        status: UploadStatus.success,
        uploadedUrl: url,
        progress: 1.0,
        uploadedFiles: [...state.uploadedFiles, url],
        selectedFile: null,
      )),
    );
  }

  // ---- Upload generic file ----
  Future<String?> uploadGenericFile({
    required File file,
    required String bucket,
    required String path,
  }) async {
    emit(state.copyWith(status: UploadStatus.uploading));

    final result = await _storageService.uploadFile(
      file: file,
      bucket: bucket,
      path: path,
    );

    return result.fold(
      (failure) {
        emit(state.copyWith(
          status: UploadStatus.error,
          errorMessage: failure.message,
        ));
        return null;
      },
      (url) {
        emit(state.copyWith(
          status: UploadStatus.success,
          uploadedFiles: [...state.uploadedFiles, url],
        ));
        return url;
      },
    );
  }

  // ---- Delete file ----
  Future<void> deleteFile({
    required String bucket,
    required String path,
  }) async {
    final result = await _storageService.deleteFile(
      bucket: bucket,
      path: path,
    );

    result.fold(
      (failure) => emit(state.copyWith(
        status: UploadStatus.error,
        errorMessage: failure.message,
      )),
      (_) {
        final filtered = state.uploadedFiles
            .where((url) => !url.contains(path))
            .toList();
        emit(state.copyWith(
          status: UploadStatus.success,
          uploadedFiles: filtered,
        ));
      },
    );
  }

  // ---- Simulate upload progress ----
  void _simulateProgress() {
    Future.delayed(const Duration(milliseconds: 200), () {
      if (state.status == UploadStatus.uploading && state.progress < 0.9) {
        emit(state.copyWith(progress: state.progress + 0.1));
        _simulateProgress();
      }
    });
  }

  // ---- Clear state ----
  void clearSelection() {
    emit(state.copyWith(
      selectedFile: null,
      progress: 0.0,
      status: UploadStatus.initial,
      errorMessage: null,
    ));
  }
}

// ============================================================
// UPLOAD PAGE — Contoh UI dengan BlocBuilder/BlocListener
// ============================================================

// features/upload/presentation/pages/upload_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection.dart';
import '../cubit/upload_cubit.dart';
import '../cubit/upload_state.dart';

class UploadPage extends StatelessWidget {
  const UploadPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<UploadCubit>(),
      child: const _UploadView(),
    );
  }
}

class _UploadView extends StatelessWidget {
  const _UploadView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Upload File')),
      body: BlocListener<UploadCubit, UploadState>(
        listener: (context, state) {
          if (state.status == UploadStatus.error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage ?? 'Upload gagal')),
            );
          }
          if (state.status == UploadStatus.success) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Upload berhasil!')),
            );
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              // Preview selected file
              BlocBuilder<UploadCubit, UploadState>(
                buildWhen: (prev, curr) =>
                    prev.selectedFile != curr.selectedFile,
                builder: (context, state) {
                  if (state.selectedFile != null) {
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(
                        state.selectedFile!,
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    );
                  }
                  return Container(
                    height: 200,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(
                      child: Text('Belum ada file dipilih'),
                    ),
                  );
                },
              ),

              const SizedBox(height: 16),

              // Pick buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () =>
                          context.read<UploadCubit>().pickImage(),
                      icon: const Icon(Icons.photo_library),
                      label: const Text('Gallery'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () =>
                          context.read<UploadCubit>().takePhoto(),
                      icon: const Icon(Icons.camera_alt),
                      label: const Text('Camera'),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Upload progress
              BlocBuilder<UploadCubit, UploadState>(
                buildWhen: (prev, curr) =>
                    prev.progress != curr.progress ||
                    prev.status != curr.status,
                builder: (context, state) {
                  if (state.status == UploadStatus.uploading) {
                    return Column(
                      children: [
                        LinearProgressIndicator(value: state.progress),
                        const SizedBox(height: 8),
                        Text(
                          '${(state.progress * 100).toStringAsFixed(0)}%',
                        ),
                      ],
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),

              const SizedBox(height: 16),

              // Upload button
              BlocBuilder<UploadCubit, UploadState>(
                builder: (context, state) {
                  final isUploading = state.status == UploadStatus.uploading;

                  return SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isUploading
                          ? null
                          : () => context.read<UploadCubit>().uploadImage(
                                bucket: 'products',
                                folder: 'images',
                              ),
                      child: isUploading
                          ? const Text('Uploading...')
                          : const Text('Upload'),
                    ),
                  );
                },
              ),

              const SizedBox(height: 24),

              // Uploaded files list
              Expanded(
                child: BlocBuilder<UploadCubit, UploadState>(
                  buildWhen: (prev, curr) =>
                      prev.uploadedFiles != curr.uploadedFiles,
                  builder: (context, state) {
                    return ListView.builder(
                      itemCount: state.uploadedFiles.length,
                      itemBuilder: (context, index) {
                        final url = state.uploadedFiles[index];
                        return ListTile(
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              url,
                              width: 48,
                              height: 48,
                              fit: BoxFit.cover,
                            ),
                          ),
                          title: Text(
                            url.split('/').last,
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () =>
                                context.read<UploadCubit>().deleteFile(
                                      bucket: 'products',
                                      path: url
                                          .split(
                                              '/storage/v1/object/public/products/')
                                          .last,
                                    ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// SQL: Storage RLS Policies — Framework-agnostic
// ============================================================
/*
-- Allow authenticated users to upload to their own folder
CREATE POLICY "Users can upload to their own folder"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (
  bucket_id = 'products' AND
  (storage.foldername(name))[1] = auth.uid()::text
);

-- Allow users to update their own files
CREATE POLICY "Users can update their own files"
ON storage.objects FOR UPDATE
TO authenticated
USING (
  bucket_id = 'products' AND
  (storage.foldername(name))[1] = auth.uid()::text
);

-- Allow users to delete their own files
CREATE POLICY "Users can delete their own files"
ON storage.objects FOR DELETE
TO authenticated
USING (
  bucket_id = 'products' AND
  (storage.foldername(name))[1] = auth.uid()::text
);

-- Allow anyone to read public bucket files
CREATE POLICY "Anyone can view public files"
ON storage.objects FOR SELECT
TO anon
USING (bucket_id = 'products');

-- Allow authenticated users to read all files
CREATE POLICY "Authenticated can view all files"
ON storage.objects FOR SELECT
TO authenticated
USING (true);
*/
```

---

### 6. RLS Best Practices & Advanced Policies

**Description:** Row Level Security policies dan SQL best practices. Section ini framework-agnostic — sama untuk Riverpod, GetX, maupun BLoC.

**Recommended Skills:** `senior-supabase-developer`, `senior-database-engineer-sql`

```sql
-- ============================================================
-- 1. Selalu enable RLS untuk semua tables
-- ============================================================
ALTER TABLE products ENABLE ROW LEVEL SECURITY;

-- ============================================================
-- 2. Default deny all — PENTING untuk keamanan
-- ============================================================
CREATE POLICY "Deny all" ON products FOR ALL TO PUBLIC USING (false);

-- ============================================================
-- 3. Specific policies untuk setiap operation
-- ============================================================
CREATE POLICY "Select own products"
ON products FOR SELECT
USING (auth.uid() = user_id);

CREATE POLICY "Insert own products"
ON products FOR INSERT
WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Update own products"
ON products FOR UPDATE
USING (auth.uid() = user_id)
WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Delete own products"
ON products FOR DELETE
USING (auth.uid() = user_id);

-- ============================================================
-- 4. Use functions untuk complex logic
-- ============================================================
CREATE OR REPLACE FUNCTION is_product_owner(product_id uuid)
RETURNS BOOLEAN AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1 FROM products
    WHERE id = product_id AND user_id = auth.uid()
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================================
-- 5. Performance: Index pada columns yang digunakan di policies
-- ============================================================
CREATE INDEX idx_products_user_id ON products(user_id);

-- ============================================================
-- 6. Role-based access (admin, moderator)
-- ============================================================
CREATE POLICY "Admin full access"
ON products FOR ALL
TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM user_roles
    WHERE user_id = auth.uid() AND role = 'admin'
  )
);

-- ============================================================
-- 7. Public read, owner write pattern
-- ============================================================
CREATE POLICY "Public read"
ON products FOR SELECT
TO anon, authenticated
USING (is_published = true);

CREATE POLICY "Owner write"
ON products FOR INSERT
TO authenticated
WITH CHECK (auth.uid() = user_id);
```

---

## Workflow Steps

1. **Setup Supabase Project**
   - Create project di supabase.com
   - Copy URL dan anon key
   - Setup environment variables (`--dart-define`)
   - Initialize Supabase di `bootstrap()` sebelum `runApp()`
   - Setup `get_it` + `injectable` DI
   - Register `SupabaseClient` sebagai external module

2. **Configure Authentication**
   - Enable auth methods (email, magic link, OAuth)
   - Setup OAuth providers (Google, Apple, etc.)
   - Implement auth repository (framework-agnostic)
   - Create `AuthBloc` dengan sealed `SupabaseAuthEvent` / `SupabaseAuthState`
   - Listen `onAuthStateChange` via `StreamSubscription` di constructor
   - Cancel subscription di `close()`
   - Setup GoRouter `redirect` guard untuk navigation

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

5. **Implement CRUD Bloc**
   - Data source (framework-agnostic)
   - `ProductBloc` dengan sealed event classes per operasi
   - `ProductState` dengan `copyWith` — termasuk pagination info
   - Register via `@Injectable()` di get_it
   - Provide via `BlocProvider` di widget tree

6. **Setup Realtime**
   - Enable realtime untuk tables di Supabase Dashboard
   - `RealtimeProductBloc` — subscribe channel di constructor
   - Unsubscribe di `close()`
   - Realtime callback -> internal event -> state update
   - `ProductDetailBloc` untuk watch single product
   - `ChatBloc` untuk messaging
   - `PresenceCubit` untuk online tracking

7. **Configure Storage**
   - Create storage buckets di Supabase Dashboard
   - Setup RLS untuk storage
   - Implement `SupabaseStorageService` (framework-agnostic)
   - `UploadCubit` dengan progress tracking
   - Register service via `@LazySingleton` di get_it

8. **Test Integration**
   - Test auth flows (login, register, magic link, OAuth, logout)
   - Test CRUD operations
   - Test RLS policies (coba akses data user lain)
   - Test realtime subscriptions
   - Test file upload dan delete
   - Test bloc lifecycle (`close()` cleanup)

## Success Criteria

- [ ] Supabase initialized di `bootstrap()` sebelum `runApp()`
- [ ] DI menggunakan `get_it` + `injectable` — `SupabaseClient` sebagai external module
- [ ] `AuthBloc` menggunakan sealed `SupabaseAuthEvent` dan `SupabaseAuthState` (Equatable)
- [ ] Auth state change di-listen via `StreamSubscription` di constructor, cancel di `close()`
- [ ] Authentication berfungsi (email/password, magic link, OAuth)
- [ ] Navigation redirect via GoRouter `redirect` guard
- [ ] PostgreSQL CRUD operations via `ProductBloc` event-driven
- [ ] `ProductState` menyertakan `List<ProductModel>`, pagination info, status, error
- [ ] Search products via `SearchProducts` event
- [ ] Pagination via `FetchProductsPaginated` event
- [ ] RLS policies configured dan tested
- [ ] `RealtimeProductBloc` — channel subscribe di constructor, unsubscribe di `close()`
- [ ] Realtime callback dispatch internal event `_RealtimeUpdate`
- [ ] `ProductDetailBloc` watch single product dengan filtered channel
- [ ] `ChatBloc` realtime messaging berfungsi
- [ ] `PresenceCubit` tracking online users
- [ ] `UploadCubit` dengan progress tracking
- [ ] Storage service registered via `@LazySingleton` di get_it
- [ ] Storage RLS policies configured
- [ ] Error handling implemented untuk semua Supabase exceptions
- [ ] Semua bloc/cubit cleanup resources di `close()`

## flutter_bloc-Specific Tips untuk Supabase

```dart
// 1. AuthBloc sebagai lazySingleton — hidup sepanjang app
@lazySingleton
class AuthBloc extends Bloc<SupabaseAuthEvent, SupabaseAuthState> { ... }

// 2. Provide di root — MultiBlocProvider di MyApp
MultiBlocProvider(
  providers: [
    BlocProvider<AuthBloc>(
      create: (_) => getIt<AuthBloc>()..add(CheckAuthStatus()),
    ),
  ],
  child: MaterialApp.router(...),
);

// 3. Per-route BlocProvider untuk feature blocs
BlocProvider(
  create: (_) => getIt<ProductBloc>()..add(FetchProducts()),
  child: const ProductListPage(),
);

// 4. SELALU cleanup di close() — channel, subscription, timer
@override
Future<void> close() {
  _channel?.unsubscribe();
  _authSubscription?.cancel();
  return super.close();
}

// 5. Internal events untuk realtime — prefix dengan underscore
class _RealtimeUpdate extends RealtimeProductEvent { ... }
class _AuthStateChanged extends SupabaseAuthEvent { ... }

// 6. Gunakan buildWhen untuk optimasi rebuild
BlocBuilder<UploadCubit, UploadState>(
  buildWhen: (prev, curr) => prev.progress != curr.progress,
  builder: (context, state) { ... },
);

// 7. BlocListener untuk side-effects (snackbar, navigation)
BlocListener<AuthBloc, SupabaseAuthState>(
  listener: (context, state) {
    if (state is AuthError) {
      ScaffoldMessenger.of(context).showSnackBar(...);
    }
  },
  child: ...,
);

// 8. Cubit untuk simple state (upload, toggle, counter)
// Bloc untuk complex event-driven state (auth, CRUD, realtime)
```

## Next Steps

Setelah Supabase integration selesai:
1. Implement comprehensive testing (unit test blocs, integration test auth flow)
2. Setup CI/CD pipeline
3. Add analytics tracking
4. Monitor performance dengan Supabase Dashboard
5. Setup backup dan disaster recovery
6. Pertimbangkan Supabase Edge Functions untuk server-side logic
7. Implement offline-first strategy dengan local cache

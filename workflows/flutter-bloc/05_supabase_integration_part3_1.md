---
description: Integrasi Supabase sebagai alternative backend dengan flutter_bloc state management: Authentication, PostgreSQL Datab... (Sub-part 1/3)
---
# Workflow: Supabase Integration (flutter_bloc) (Part 3/8)

> **Navigation:** This workflow is split into 8 parts.

## Deliverables

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
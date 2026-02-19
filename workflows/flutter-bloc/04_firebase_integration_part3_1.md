---
description: Integrasi Firebase services untuk Flutter dengan **flutter_bloc** sebagai state management: Authentication, Cloud Fir... (Sub-part 1/3)
---
# Workflow: Firebase Integration (flutter_bloc) (Part 3/7)

> **Navigation:** This workflow is split into 7 parts.

## Deliverables

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
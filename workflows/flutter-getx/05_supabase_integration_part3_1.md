---
description: Integrasi Supabase sebagai alternative backend dengan GetX state management: Authentication, PostgreSQL Database, Rea... (Sub-part 1/3)
---
# Workflow: Supabase Integration (GetX) (Part 3/7)

> **Navigation:** This workflow is split into 7 parts.

## Deliverables

### 2. Supabase Authentication (GetX)

**Description:** Implementasi Supabase Auth dengan GetxController, reactive observables, dan auth state listener di `onInit()`.

**Recommended Skills:** `senior-flutter-developer`, `senior-supabase-developer`

**Instructions:**
1. **Auth Methods:**
   - Email/password (traditional)
   - Magic link (passwordless)
   - OAuth (Google, Apple, GitHub, etc.)
   - Phone OTP

2. **Auth State Management (GetX):**
   - `Rx<User?>` dan `Rx<Session?>` sebagai reactive state
   - Listen `onAuthStateChange` di `onInit()`
   - Cancel subscription di `onClose()`
   - Navigate pakai `Get.offAllNamed()`

3. **Auth Repository:**
   - Abstract contract (framework-agnostic)
   - Supabase implementation

**Output Format:**
```dart
// features/auth/domain/repositories/auth_repository.dart
// Framework-agnostic — sama dengan versi Riverpod
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
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../../../core/error/failures.dart';

class SupabaseAuthRepository implements AuthRepository {
  final SupabaseClient _supabase;

  SupabaseAuthRepository({SupabaseClient? supabase})
      : _supabase = supabase ?? Supabase.instance.client;

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
// AUTH CONTROLLER — GetX version
// Ini BERBEDA dari Riverpod. Tidak ada @riverpod annotation.
// Gunakan GetxController + .obs reactive variables.
// ============================================================

// features/auth/presentation/controllers/auth_controller.dart
import 'dart:async';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/repositories/supabase_auth_repository.dart';
import '../../../../routes/app_routes.dart';

class AuthController extends GetxController {
  final SupabaseAuthRepository _authRepo = Get.find<SupabaseAuthRepository>();

  // ---- Reactive State ----
  final Rx<User?> user = Rx<User?>(null);
  final Rx<Session?> session = Rx<Session?>(null);
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxBool isAuthenticated = false.obs;

  // ---- Stream subscription ----
  StreamSubscription<AuthState>? _authSubscription;

  @override
  void onInit() {
    super.onInit();

    // Set initial values
    user.value = _authRepo.currentUser;
    session.value = _authRepo.currentSession;
    isAuthenticated.value = user.value != null;

    // Listen to auth state changes
    _authSubscription = _authRepo.authStateChanges.listen(
      _handleAuthStateChange,
      onError: (error) {
        errorMessage.value = 'Auth stream error: $error';
      },
    );
  }

  @override
  void onClose() {
    _authSubscription?.cancel();
    super.onClose();
  }

  // ---- Handle auth state ----
  void _handleAuthStateChange(AuthState state) {
    user.value = state.session?.user;
    session.value = state.session;
    isAuthenticated.value = state.session != null;

    switch (state.event) {
      case AuthChangeEvent.signedIn:
        errorMessage.value = '';
        Get.offAllNamed(AppRoutes.home);
        break;
      case AuthChangeEvent.signedOut:
        user.value = null;
        session.value = null;
        isAuthenticated.value = false;
        Get.offAllNamed(AppRoutes.login);
        break;
      case AuthChangeEvent.tokenRefreshed:
        session.value = state.session;
        break;
      case AuthChangeEvent.userUpdated:
        user.value = state.session?.user;
        break;
      case AuthChangeEvent.passwordRecovery:
        Get.toNamed(AppRoutes.resetPassword);
        break;
      default:
        break;
    }
  }

  // ---- Sign in with email & password ----
  Future<void> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    isLoading.value = true;
    errorMessage.value = '';

    final result = await _authRepo.signInWithEmailAndPassword(
      email,
      password,
    );

    result.fold(
      (failure) {
        errorMessage.value = failure.message;
        Get.snackbar('Error', failure.message);
      },
      (user) {
        // Auth state listener akan handle navigation
      },
    );

    isLoading.value = false;
  }

  // ---- Sign in with magic link ----
  Future<void> signInWithMagicLink(String email) async {
    isLoading.value = true;
    errorMessage.value = '';

    final result = await _authRepo.signInWithMagicLink(email);

    result.fold(
      (failure) {
        errorMessage.value = failure.message;
        Get.snackbar('Error', failure.message);
      },
      (_) {
        Get.snackbar(
          'Magic Link Sent',
          'Cek email kamu untuk link login',
        );
      },
    );

    isLoading.value = false;
  }

  // ---- Sign in with OAuth ----
  Future<void> signInWithOAuth(String provider) async {
    isLoading.value = true;
    errorMessage.value = '';

    final result = await _authRepo.signInWithOAuth(provider);

    result.fold(
      (failure) {
        errorMessage.value = failure.message;
        Get.snackbar('Error', failure.message);
      },
      (user) {
        // Auth state listener akan handle navigation
      },
    );

    isLoading.value = false;
  }

  // ---- Sign up ----
  Future<void> signUp(String email, String password) async {
    isLoading.value = true;
    errorMessage.value = '';

    final result = await _authRepo.signUp(email, password);

    result.fold(
      (failure) {
        errorMessage.value = failure.message;
        Get.snackbar('Error', failure.message);
      },
      (user) {
        Get.snackbar(
          'Success',
          'Akun berhasil dibuat. Silakan cek email untuk verifikasi.',
        );
      },
    );

    isLoading.value = false;
  }

  // ---- Sign out ----
  Future<void> signOut() async {
    isLoading.value = true;

    final result = await _authRepo.signOut();

    result.fold(
      (failure) {
        errorMessage.value = failure.message;
        Get.snackbar('Error', failure.message);
      },
      (_) {
        // Auth state listener akan handle navigation ke login
      },
    );

    isLoading.value = false;
  }
}

// ============================================================
// AUTH MIDDLEWARE — Proteksi route yang butuh login
// ============================================================

// routes/auth_middleware.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../features/auth/presentation/controllers/auth_controller.dart';
import 'app_routes.dart';
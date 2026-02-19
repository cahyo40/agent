---
description: Integrasi Supabase sebagai alternative backend dengan flutter_bloc state management: Authentication, PostgreSQL Datab... (Sub-part 2/3)
---
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


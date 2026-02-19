---
description: Integrasi Firebase services untuk Flutter dengan **flutter_bloc** sebagai state management: Authentication, Cloud Fir... (Sub-part 2/3)
---
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


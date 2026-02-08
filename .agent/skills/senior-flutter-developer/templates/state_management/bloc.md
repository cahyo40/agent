# BLoC State Management

## Overview

BLoC (Business Logic Component) pattern provides predictable state management using event-driven architecture with strong separation of concerns.

## When to Use

- Complex business logic requiring separation from UI
- Team prefers event-driven architecture
- Need strong traceability and debugging
- Building apps with predictable state flows

---

## BLoC vs Cubit

```text
┌─────────────────────────────────────────────────┐
│ CUBIT (Simpler)                                 │
│   - Function-based state changes                │
│   - Good for simple state logic                 │
│   - Less boilerplate                            │
│   emit(NewState())                              │
│                                                 │
│ BLOC (Full Pattern)                             │
│   - Event-driven state changes                  │
│   - Good for complex business logic             │
│   - Better traceability & debugging             │
│   on<Event>((event, emit) => ...)               │
└─────────────────────────────────────────────────┘
```

---

## Implementation

### Define Events

```dart
// auth_event.dart
part of 'auth_bloc.dart';

sealed class AuthEvent {}

final class AuthLoginRequested extends AuthEvent {
  final String email;
  final String password;
  AuthLoginRequested({required this.email, required this.password});
}

final class AuthLogoutRequested extends AuthEvent {}

final class AuthCheckRequested extends AuthEvent {}
```

### Define States

```dart
// auth_state.dart
part of 'auth_bloc.dart';

sealed class AuthState {}

final class AuthInitial extends AuthState {}

final class AuthLoading extends AuthState {}

final class AuthAuthenticated extends AuthState {
  final User user;
  AuthAuthenticated(this.user);
}

final class AuthUnauthenticated extends AuthState {}

final class AuthError extends AuthState {
  final String message;
  AuthError(this.message);
}
```

### Implement BLoC

```dart
import 'package:flutter_bloc/flutter_bloc.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;
  
  AuthBloc({required AuthRepository authRepository})
      : _authRepository = authRepository,
        super(AuthInitial()) {
    on<AuthLoginRequested>(_onLoginRequested);
    on<AuthLogoutRequested>(_onLogoutRequested);
    on<AuthCheckRequested>(_onCheckRequested);
  }
  
  Future<void> _onLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final user = await _authRepository.login(
        email: event.email,
        password: event.password,
      );
      emit(AuthAuthenticated(user));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }
  
  Future<void> _onLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    await _authRepository.logout();
    emit(AuthUnauthenticated());
  }
  
  Future<void> _onCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    final user = await _authRepository.getCurrentUser();
    if (user != null) {
      emit(AuthAuthenticated(user));
    } else {
      emit(AuthUnauthenticated());
    }
  }
}
```

---

## UI Integration

```dart
// Provide BLoC
BlocProvider(
  create: (context) => AuthBloc(
    authRepository: context.read<AuthRepository>(),
  )..add(AuthCheckRequested()),
  child: const AuthPage(),
)

// Listen to state changes
BlocListener<AuthBloc, AuthState>(
  listener: (context, state) {
    if (state is AuthError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(state.message)),
      );
    }
  },
  child: ...
)

// Build UI based on state
BlocBuilder<AuthBloc, AuthState>(
  builder: (context, state) {
    return switch (state) {
      AuthLoading() => const CircularProgressIndicator(),
      AuthAuthenticated(:final user) => Text('Welcome ${user.name}'),
      AuthUnauthenticated() => const LoginForm(),
      AuthError(:final message) => Text('Error: $message'),
      AuthInitial() => const SizedBox.shrink(),
    };
  },
)

// Dispatch events
ElevatedButton(
  onPressed: () {
    context.read<AuthBloc>().add(
      AuthLoginRequested(email: email, password: password),
    );
  },
  child: const Text('Login'),
)
```

---

## Advanced Patterns

### Bloc-to-Bloc Communication

```dart
class CartBloc extends Bloc<CartEvent, CartState> {
  final AuthBloc _authBloc;
  late final StreamSubscription<AuthState> _authSubscription;
  
  CartBloc({required AuthBloc authBloc})
      : _authBloc = authBloc,
        super(CartInitial()) {
    _authSubscription = _authBloc.stream.listen((authState) {
      if (authState is AuthUnauthenticated) {
        add(CartCleared());
      }
    });
  }
  
  @override
  Future<void> close() {
    _authSubscription.cancel();
    return super.close();
  }
}
```

### Event Debounce

```dart
on<SearchQueryChanged>(
  _onSearchQueryChanged,
  transformer: debounce(const Duration(milliseconds: 300)),
);

EventTransformer<E> debounce<E>(Duration duration) {
  return (events, mapper) => events.debounceTime(duration).flatMap(mapper);
}
```

---

## Best Practices

### ✅ Do This

- ✅ Use `sealed class` for Events and States (Dart 3+)
- ✅ Keep BLoCs focused—one responsibility per BLoC
- ✅ Use `BlocObserver` for debugging
- ✅ Test BLoCs with `bloc_test`
- ✅ Use `context.read<Bloc>()` for events

### ❌ Avoid This

- ❌ Don't put UI logic in BLoC
- ❌ Don't access BuildContext inside BLoC
- ❌ Don't emit states after `close()`
- ❌ Don't create circular dependencies

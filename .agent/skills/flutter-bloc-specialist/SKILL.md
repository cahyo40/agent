---
name: flutter-bloc-specialist
description: "Expert Flutter state management with BLoC pattern including Cubit, streams, event-driven architecture, and clean separation of concerns"
---

# Flutter BLoC Specialist

## Overview

Skill ini menjadikan AI Agent Anda sebagai spesialis BLoC (Business Logic Component) pattern di Flutter. Agent akan mampu mengimplementasikan state management yang scalable menggunakan `flutter_bloc` package, memisahkan business logic dari UI secara bersih, dan menerapkan event-driven architecture untuk aplikasi Flutter yang kompleks.

## When to Use This Skill

- Use when building Flutter apps that require predictable state management
- Use when implementing complex business logic that needs separation from UI
- Use when the team prefers event-driven architecture over reactive streams
- Use when the user asks about BLoC, Cubit, or flutter_bloc package
- Use when migrating from other state management solutions to BLoC

## How It Works

### Step 1: Understand BLoC vs Cubit

```text
┌─────────────────────────────────────────────────────────┐
│                  BLoC vs CUBIT                          │
├─────────────────────────────────────────────────────────┤
│ CUBIT (Simpler)                                         │
│   - Function-based state changes                        │
│   - Good for simple state logic                         │
│   - Less boilerplate                                    │
│   emit(NewState())                                      │
│                                                         │
│ BLOC (Full Pattern)                                     │
│   - Event-driven state changes                          │
│   - Good for complex business logic                     │
│   - Better traceability & debugging                     │
│   on<Event>((event, emit) => ...)                       │
└─────────────────────────────────────────────────────────┘
```

### Step 2: Project Structure

```text
lib/
├── core/
│   ├── bloc/                     # Base bloc classes
│   │   ├── app_bloc_observer.dart
│   │   └── base_bloc.dart
│   └── constants/
├── features/
│   └── auth/
│       ├── bloc/
│       │   ├── auth_bloc.dart    # BLoC class
│       │   ├── auth_event.dart   # Events
│       │   └── auth_state.dart   # States
│       ├── data/
│       │   ├── repositories/
│       │   └── models/
│       └── presentation/
│           ├── pages/
│           └── widgets/
└── main.dart
```

### Step 3: Implement BLoC Pattern

#### 3.1 Define Events

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

#### 3.2 Define States

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

#### 3.3 Implement BLoC

```dart
// auth_bloc.dart
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

### Step 4: Use in UI

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

### Step 5: Advanced Patterns

#### Bloc-to-Bloc Communication

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

#### Transforming Events (Debounce/Throttle)

```dart
on<SearchQueryChanged>(
  _onSearchQueryChanged,
  transformer: debounce(const Duration(milliseconds: 300)),
);

EventTransformer<E> debounce<E>(Duration duration) {
  return (events, mapper) => events.debounceTime(duration).flatMap(mapper);
}
```

## Best Practices

### ✅ Do This

- ✅ Use `sealed class` for Events and States (Dart 3+)
- ✅ Keep BLoCs focused—one responsibility per BLoC
- ✅ Use `BlocObserver` for debugging and logging
- ✅ Test BLoCs independently from UI using `bloc_test`
- ✅ Use `context.read<Bloc>()` for event dispatch, `context.watch<Bloc>()` for rebuilds

### ❌ Avoid This

- ❌ Don't put UI logic in BLoC—only business logic
- ❌ Don't access BuildContext inside BLoC
- ❌ Don't emit states after `close()` is called
- ❌ Don't create circular dependencies between BLoCs

## Common Pitfalls

**Problem:** State not updating in UI
**Solution:** Ensure state classes are immutable. Use `Equatable` or override `==` and `hashCode`.

**Problem:** Memory leak from stream subscriptions
**Solution:** Always cancel subscriptions in `close()` method.

**Problem:** Too much boilerplate for simple state
**Solution:** Use `Cubit` instead of full `Bloc` for simple cases.

## Related Skills

- `@senior-flutter-developer` - Core Flutter patterns
- `@flutter-riverpod-specialist` - Alternative state management
- `@flutter-testing-specialist` - Testing BLoC with bloc_test
- `@senior-software-architect` - Clean architecture patterns

# State Management Patterns

## Riverpod (Recommended)

### Generated Provider Pattern

```dart
// features/auth/presentation/providers/auth_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AuthState {
  final bool isLoading;
  final String? error;
  final User? user;

  const AuthState({
    this.isLoading = false,
    this.error,
    this.user,
  });

  AuthState copyWith({bool? isLoading, String? error, User? user}) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      user: user ?? this.user,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(const AuthState());

  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      // TODO: Implement login logic
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});
```

### Generated Page Pattern (Riverpod)

```dart
// YoScaffold + ConsumerWidget
class AuthPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(authProvider);
    return YoScaffold(
      appBar: AppBar(title: YoText.heading('Auth')),
      body: _buildBody(state),
    );
  }

  Widget _buildBody(AuthState state) {
    if (state.isLoading) return const YoLoading();
    if (state.error != null) {
      return YoErrorState(message: state.error!, onRetry: () {});
    }
    return Center(child: YoText('Auth Page'));
  }
}
```

---

## GetX

### Generated Controller Pattern

```dart
// features/auth/presentation/controllers/auth_controller.dart
import 'package:get/get.dart';

class AuthController extends GetxController {
  final _isLoading = false.obs;
  final _error = Rxn<String>();

  bool get isLoading => _isLoading.value;
  String? get error => _error.value;

  Future<void> login(String email, String password) async {
    _isLoading.value = true;
    _error.value = null;
    try {
      // TODO: Implement login logic
    } catch (e) {
      _error.value = e.toString();
    } finally {
      _isLoading.value = false;
    }
  }
}
```

### Generated Page Pattern (GetX)

```dart
// YoScaffold + GetView
class AuthPage extends GetView<AuthController> {
  @override
  Widget build(BuildContext context) {
    return YoScaffold(
      appBar: AppBar(title: YoText.heading('Auth')),
      body: Obx(() => _buildBody()),
    );
  }

  Widget _buildBody() {
    if (controller.isLoading) return const YoLoading();
    if (controller.error != null) {
      return YoErrorState(message: controller.error!, onRetry: () {});
    }
    return Center(child: YoText('Auth Page'));
  }
}
```

---

## BLoC

### Generated BLoC Pattern

```dart
// features/auth/presentation/bloc/auth_event.dart
abstract class AuthEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class AuthLoginRequested extends AuthEvent {
  final String email;
  final String password;
  AuthLoginRequested({required this.email, required this.password});
  @override
  List<Object?> get props => [email, password];
}

// features/auth/presentation/bloc/auth_state.dart
abstract class AuthState extends Equatable {
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}
class AuthLoading extends AuthState {}
class AuthSuccess extends AuthState { /* ... */ }
class AuthFailure extends AuthState {
  final String message;
  AuthFailure({required this.message});
}

// features/auth/presentation/bloc/auth_bloc.dart
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(AuthInitial()) {
    on<AuthLoginRequested>(_onLogin);
  }

  Future<void> _onLogin(AuthLoginRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      // TODO: Implement login logic
      emit(AuthSuccess());
    } catch (e) {
      emit(AuthFailure(message: e.toString()));
    }
  }
}
```

### Generated Page Pattern (BLoC)

```dart
// YoScaffold + BlocBuilder
class AuthPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AuthBloc(),
      child: YoScaffold(
        appBar: AppBar(title: YoText.heading('Auth')),
        body: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) => _buildBody(context, state),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, AuthState state) {
    if (state is AuthLoading) return const YoLoading();
    if (state is AuthFailure) {
      return YoErrorState(message: state.message, onRetry: () {
        context.read<AuthBloc>().add(AuthLoginRequested(...));
      });
    }
    return Center(child: YoText('Auth Page'));
  }
}
```

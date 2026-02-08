# BLoC Pattern

## BLoC vs Cubit

```
BLOC vs CUBIT
├── CUBIT (Simpler)
│   ├── Methods emit new states
│   ├── Good for simple state changes
│   └── Less boilerplate
│
└── BLOC (More Control)
    ├── Events trigger state changes
    ├── Better for complex flows
    ├── Transformable event streams
    └── Better traceability
```

## Cubit Implementation

### State Definition

```dart
@freezed
class CounterState with _$CounterState {
  const factory CounterState({
    @Default(0) int count,
    @Default(false) bool isLoading,
    String? error,
  }) = _CounterState;
}
```

### Cubit

```dart
class CounterCubit extends Cubit<CounterState> {
  CounterCubit() : super(const CounterState());

  void increment() => emit(state.copyWith(count: state.count + 1));
  void decrement() => emit(state.copyWith(count: state.count - 1));
  
  Future<void> reset() async {
    emit(state.copyWith(isLoading: true));
    await Future.delayed(const Duration(seconds: 1));
    emit(const CounterState());
  }
}
```

### Usage in Widget

```dart
class CounterPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CounterCubit(),
      child: const CounterView(),
    );
  }
}

class CounterView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: BlocBuilder<CounterCubit, CounterState>(
          builder: (context, state) {
            if (state.isLoading) {
              return const CircularProgressIndicator();
            }
            return Text('${state.count}');
          },
        ),
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            onPressed: () => context.read<CounterCubit>().increment(),
            child: const Icon(Icons.add),
          ),
          const SizedBox(height: 8),
          FloatingActionButton(
            onPressed: () => context.read<CounterCubit>().decrement(),
            child: const Icon(Icons.remove),
          ),
        ],
      ),
    );
  }
}
```

## Bloc with Events

### Events

```dart
@freezed
class AuthEvent with _$AuthEvent {
  const factory AuthEvent.loginRequested(String email, String password) = LoginRequested;
  const factory AuthEvent.logoutRequested() = LogoutRequested;
  const factory AuthEvent.checkAuthStatus() = CheckAuthStatus;
}
```

### States

```dart
@freezed
class AuthState with _$AuthState {
  const factory AuthState.initial() = AuthInitial;
  const factory AuthState.loading() = AuthLoading;
  const factory AuthState.authenticated(User user) = Authenticated;
  const factory AuthState.unauthenticated() = Unauthenticated;
  const factory AuthState.failure(String message) = AuthFailure;
}
```

### Bloc

```dart
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc({required this.authRepository}) : super(const AuthState.initial()) {
    on<LoginRequested>(_onLoginRequested);
    on<LogoutRequested>(_onLogoutRequested);
    on<CheckAuthStatus>(_onCheckAuthStatus);
  }

  final AuthRepository authRepository;

  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthState.loading());
    
    try {
      final user = await authRepository.login(event.email, event.password);
      emit(AuthState.authenticated(user));
    } catch (e) {
      emit(AuthState.failure(e.toString()));
    }
  }

  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    await authRepository.logout();
    emit(const AuthState.unauthenticated());
  }

  Future<void> _onCheckAuthStatus(
    CheckAuthStatus event,
    Emitter<AuthState> emit,
  ) async {
    final user = await authRepository.getCurrentUser();
    if (user != null) {
      emit(AuthState.authenticated(user));
    } else {
      emit(const AuthState.unauthenticated());
    }
  }
}
```

## Advanced BLoC Patterns

### Event Transformer - Debounce

```dart
class SearchBloc extends Bloc<SearchEvent, SearchState> {
  SearchBloc() : super(const SearchState.initial()) {
    on<SearchQueryChanged>(
      _onSearchQueryChanged,
      transformer: debounce(const Duration(milliseconds: 300)),
    );
  }

  EventTransformer<T> debounce<T>(Duration duration) {
    return (events, mapper) => events.debounceTime(duration).flatMap(mapper);
  }

  Future<void> _onSearchQueryChanged(
    SearchQueryChanged event,
    Emitter<SearchState> emit,
  ) async {
    if (event.query.isEmpty) {
      emit(const SearchState.initial());
      return;
    }
    
    emit(const SearchState.loading());
    final results = await searchRepository.search(event.query);
    emit(SearchState.success(results));
  }
}
```

### BlocListener - Side Effects

```dart
BlocListener<AuthBloc, AuthState>(
  listenWhen: (previous, current) => 
    previous != current && current is AuthFailure,
  listener: (context, state) {
    if (state is AuthFailure) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(state.message)),
      );
    }
  },
  child: const AuthView(),
)
```

### MultiBlocProvider & MultiBlocListener

```dart
MultiBlocProvider(
  providers: [
    BlocProvider(create: (_) => AuthBloc()),
    BlocProvider(create: (_) => ThemeBloc()),
    BlocProvider(create: (context) => CartBloc(
      authBloc: context.read<AuthBloc>(),
    )),
  ],
  child: const MyApp(),
)
```

## Testing BLoC

### Cubit Test

```dart
void main() {
  group('CounterCubit', () {
    late CounterCubit cubit;

    setUp(() {
      cubit = CounterCubit();
    });

    tearDown(() {
      cubit.close();
    });

    test('initial state is CounterState(count: 0)', () {
      expect(cubit.state, const CounterState());
    });

    blocTest<CounterCubit, CounterState>(
      'emits [CounterState(count: 1)] when increment is called',
      build: () => CounterCubit(),
      act: (cubit) => cubit.increment(),
      expect: () => [const CounterState(count: 1)],
    );

    blocTest<CounterCubit, CounterState>(
      'emits states in order when multiple actions',
      build: () => CounterCubit(),
      act: (cubit) {
        cubit.increment();
        cubit.increment();
        cubit.decrement();
      },
      expect: () => [
        const CounterState(count: 1),
        const CounterState(count: 2),
        const CounterState(count: 1),
      ],
    );
  });
}
```

### Bloc Test with Mocks

```dart
class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  group('AuthBloc', () {
    late AuthBloc bloc;
    late MockAuthRepository mockRepo;

    setUp(() {
      mockRepo = MockAuthRepository();
      bloc = AuthBloc(authRepository: mockRepo);
    });

    blocTest<AuthBloc, AuthState>(
      'emits [loading, authenticated] on successful login',
      build: () {
        when(() => mockRepo.login(any(), any()))
            .thenAnswer((_) async => tUser);
        return bloc;
      },
      act: (bloc) => bloc.add(const LoginRequested('email', 'pass')),
      expect: () => [
        const AuthState.loading(),
        AuthState.authenticated(tUser),
      ],
      verify: (_) {
        verify(() => mockRepo.login('email', 'pass')).called(1);
      },
    );
  });
}
```

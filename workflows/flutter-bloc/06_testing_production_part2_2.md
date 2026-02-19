---
description: Comprehensive testing (unit, widget, integration) dan production preparation khusus Flutter BLoC: `bloc_test` package... (Sub-part 2/3)
---
// ========================================
// test/features/auth/presentation/bloc/auth_bloc_test.dart
// ========================================
class MockLoginUseCase extends Mock implements LoginUseCase {}
class MockLogoutUseCase extends Mock implements LogoutUseCase {}
class MockGetCurrentUser extends Mock implements GetCurrentUser {}

class FakeLoginParams extends Fake implements LoginParams {}

void main() {
  late AuthBloc bloc;
  late MockLoginUseCase mockLogin;
  late MockLogoutUseCase mockLogout;
  late MockGetCurrentUser mockGetCurrentUser;

  final tUser = User(id: '1', email: 'test@example.com', name: 'Test User');

  setUpAll(() {
    registerFallbackValue(FakeLoginParams());
  });

  setUp(() {
    mockLogin = MockLoginUseCase();
    mockLogout = MockLogoutUseCase();
    mockGetCurrentUser = MockGetCurrentUser();
    bloc = AuthBloc(
      login: mockLogin,
      logout: mockLogout,
      getCurrentUser: mockGetCurrentUser,
    );
  });

  tearDown(() => bloc.close());

  group('LoginRequested', () {
    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthAuthenticated] on successful login',
      build: () {
        when(() => mockLogin(any())).thenAnswer(
          (_) async => Right(tUser),
        );
        return bloc;
      },
      act: (bloc) => bloc.add(const LoginRequested(
        email: 'test@example.com',
        password: 'password123',
      )),
      expect: () => [
        const AuthLoading(),
        AuthAuthenticated(user: tUser),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthError] on failed login',
      build: () {
        when(() => mockLogin(any())).thenAnswer(
          (_) async => const Left(AuthFailure('Invalid credentials')),
        );
        return bloc;
      },
      act: (bloc) => bloc.add(const LoginRequested(
        email: 'wrong@email.com',
        password: 'wrong',
      )),
      expect: () => [
        const AuthLoading(),
        const AuthError(message: 'Invalid credentials'),
      ],
    );
  });

  group('LogoutRequested', () {
    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthUnauthenticated] on logout',
      seed: () => AuthAuthenticated(user: tUser),
      build: () {
        when(() => mockLogout()).thenAnswer((_) async => const Right(unit));
        return bloc;
      },
      act: (bloc) => bloc.add(const LogoutRequested()),
      expect: () => [
        const AuthLoading(),
        const AuthUnauthenticated(),
      ],
    );
  });
}
```

**Cubit Testing Pattern:**

```dart
// test/features/settings/presentation/cubit/theme_cubit_test.dart
// Cubit lebih simple karena tidak ada Event — langsung panggil method

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late ThemeCubit cubit;
  late MockThemeRepository mockRepo;

  setUp(() {
    mockRepo = MockThemeRepository();
    cubit = ThemeCubit(repository: mockRepo);
  });

  tearDown(() => cubit.close());

  blocTest<ThemeCubit, ThemeState>(
    'emits [ThemeState(isDark: true)] when toggleTheme called from light mode',
    seed: () => const ThemeState(isDark: false),
    build: () {
      when(() => mockRepo.saveTheme(any())).thenAnswer((_) async {});
      return cubit;
    },
    act: (cubit) => cubit.toggleTheme(),
    expect: () => [
      const ThemeState(isDark: true),
    ],
  );
}
```

**Use Case Testing (sama dengan Riverpod):**

```dart
// test/features/product/domain/usecases/get_products_test.dart
class MockProductRepository extends Mock implements ProductRepository {}

void main() {
  late GetProducts useCase;
  late MockProductRepository mockRepository;

  setUp(() {
    mockRepository = MockProductRepository();
    useCase = GetProducts(mockRepository);
  });

  final tProducts = [
    Product(id: '1', name: 'Product 1', price: 10.0),
    Product(id: '2', name: 'Product 2', price: 20.0),
  ];

  test('should get products from repository', () async {
    // Arrange
    when(() => mockRepository.getProducts(page: any(named: 'page')))
        .thenAnswer((_) async => Right(tProducts));

    // Act
    final result = await useCase(const GetProductsParams(page: 1));

    // Assert
    expect(result, Right(tProducts));
    verify(() => mockRepository.getProducts(page: 1)).called(1);
    verifyNoMoreInteractions(mockRepository);
  });

  test('should return failure when repository fails', () async {
    when(() => mockRepository.getProducts(page: any(named: 'page')))
        .thenAnswer((_) async => Left(ServerFailure('Error')));

    final result = await useCase(const GetProductsParams(page: 1));

    expect(result, Left(ServerFailure('Error')));
  });
}
```


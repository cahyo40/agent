# Riverpod State Management

## Overview

Riverpod is the recommended state management for Flutter. It offers type-safe, compile-time checked providers with no BuildContext dependency.

## When to Use

- Starting a new Flutter project
- Refactoring legacy ChangeNotifier or Bloc
- Need testable, dependency-injectable state
- Optimizing rebuilds with `select()`
- Implementing caching or debounce logic

---

## Part 1: Code Generation Syntax (Recommended)

Riverpod 2.0+ strongly recommends using code generation for better type safety.

### Providers with Annotations

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'providers.g.dart';

// 1. Simple Read-Only Provider (autoDispose by default)
@riverpod
String appTitle(AppTitleRef ref) {
  return 'My Awesome App';
}

// 2. Notifier Provider (Sync State)
@riverpod
class Counter extends _$Counter {
  @override
  int build() => 0;

  void increment() => state++;
}

// 3. AsyncNotifier Provider (Async State)
@riverpod
class Products extends _$Products {
  @override
  FutureOr<List<Product>> build() async {
    final repo = ref.watch(productRepositoryProvider);
    return repo.fetchProducts();
  }

  Future<void> addProduct(Product product) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref.read(productRepositoryProvider).add(product);
      return ref.read(productRepositoryProvider).fetchProducts();
    });
  }
}
```

### Family & KeepAlive (Caching)

```dart
@riverpod
Future<User> user(UserRef ref, {required String id}) async {
  // Keep alive for 5 minutes (caching)
  final link = ref.keepAlive();
  final timer = Timer(const Duration(minutes: 5), () {
    link.close();
  });
  ref.onDispose(() => timer.cancel());

  return ref.watch(userRepositoryProvider).getById(id);
}
```

---

## Part 2: Advanced State Patterns

### AsyncValue & Error Handling

```dart
class ProductList extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final products = ref.watch(productsProvider);

    return products.when(
      data: (data) => ListView(children: ...),
      error: (e, st) => ErrorView(e),
      loading: () => const LoadingSpinner(),
      skipLoadingOnRefresh: true,
      skipLoadingOnReload: true,
    );
  }
}
```

### Rebuild Optimization (select)

```dart
@override
Widget build(BuildContext context, WidgetRef ref) {
  // Only rebuild if 'name' changes
  final name = ref.watch(userProvider.select((user) => user.name));
  return Text(name);
}
```

---

## Part 3: Architecture Integration

```text
lib/
├── features/
│   ├── auth/
│   │   ├── data/
│   │   │   ├── auth_repository.dart  // @riverpod provider
│   │   │   └── auth_api.dart
│   │   ├── domain/
│   │   │   └── user.dart             // Freezed class
│   │   └── presentation/
│   │       ├── auth_controller.dart  // @riverpod AsyncNotifier
│   │       └── login_screen.dart
├── core/
│   ├── router/
│   └── theme/
└── main.dart
```

### Controller Pattern (ViewModel)

```dart
@riverpod
class LoginController extends _$LoginController {
  @override
  FutureOr<void> build() {
    // Initial state is void (idle)
  }

  Future<void> login(String email, String password) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => 
      ref.read(authRepositoryProvider).signIn(email, password)
    );
  }
}
```

---

## Part 4: Testing

```dart
void main() {
  test('Counter increments', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    expect(container.read(counterProvider), 0);
    container.read(counterProvider.notifier).increment();
    expect(container.read(counterProvider), 1);
  });
}

// Mocking Dependencies
test('Products provider fetches from repo', () async {
  final mockRepo = MockProductRepository();
  when(() => mockRepo.fetchProducts()).thenAnswer((_) async => [Product(id: 1)]);

  final container = ProviderContainer(
    overrides: [
      productRepositoryProvider.overrideWithValue(mockRepo),
    ],
  );

  final products = await container.read(productsProvider.future);
  expect(products.length, 1);
});
```

---

## Best Practices

### ✅ Do This

- ✅ Use Code Generation (riverpod_annotation)
- ✅ Use `ref.watch` in `build` method
- ✅ Use `ref.read` in callbacks
- ✅ Use `autoDispose` by default
- ✅ Use `Freezed` for State classes

### ❌ Avoid This

- ❌ Storing Ref globally
- ❌ `StateProvider` for complex logic
- ❌ Ignoring `AsyncValue` errors
- ❌ Mutable State objects

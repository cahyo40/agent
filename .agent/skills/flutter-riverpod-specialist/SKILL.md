---
name: flutter-riverpod-specialist
description: "Expert Flutter state management with Riverpod including providers, code generation, testing, and clean architecture patterns"
---

# Flutter Riverpod Specialist

## Overview

This skill transforms you into a **Riverpod Expert**. You will move beyond simple providers to mastering the **Riverpod Generator (riverpod_annotation)**, handling complex async state with `AsyncValue`, implementing **Feature-First Architecture**, and writing robust unit/widget tests for your providers.

## When to Use This Skill

- Use when starting a new Flutter project (Architecture decision)
- Use when refactoring legacy `ChangeNotifier` or `Bloc` to Riverpod
- Use when optimizing rebuilds with `select()`
- Use when implementing caching or debounce logic
- Use when testing state changes in isolation

---

## Part 1: The New Syntax (Code Generation)

Riverpod 2.0+ strongly recommends using code generation for better type safety and DX.

### 1.1 Providers with Annotations

```dart
// main.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'main.g.dart';

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
    // "ref.watch" here creates dependencies automatically
    final repo = ref.watch(productRepositoryProvider);
    return repo.fetchProducts();
  }

  Future<void> addProduct(Product product) async {
    // Optimistic UI Update possible here
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref.read(productRepositoryProvider).add(product);
      return ref.read(productRepositoryProvider).fetchProducts();
    });
  }
}
```

### 1.2 Family & KeepAlive

Passing arguments and caching.

```dart
// Auto-generates provider family
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

### 2.1 AsyncValue & Error Handling

Don't just use `try-catch`. Use `AsyncValue` power.

```dart
// In Widget
class ProductList extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final products = ref.watch(productsProvider);

    return products.when(
      data: (data) => ListView(children: ...),
      error: (e, st) => ErrorView(e),
      loading: () => const LoadingSpinner(),
      // Handle reloading state specifically (keep showing data while refreshing)
      skipLoadingOnRefresh: true, 
      skipLoadingOnReload: true,
    );
  }
}
```

### 2.2 Rebuild Optimization (`select`)

Stop widget rebuilding on every state change.

```dart
@override
Widget build(BuildContext context, WidgetRef ref) {
  // Only rebuild if 'name' changes. Ignore 'age' or 'email' changes.
  final name = ref.watch(userProvider.select((user) => user.name));
  
  return Text(name);
}
```

---

## Part 3: Architecture Integration

Feature-First Architecture with Riverpod.

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
│   └── products/
├── core/
│   ├── router/
│   └── theme/
└── main.dart
```

**Controller Pattern (ViewModel):**

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

## Part 4: Testing Strategies

Testing Riverpod is easier than generic Provider because it doesn't depend on Flutter tree.

### 4.1 Unit Testing Providers

```dart
void main() {
  test('Counter increments', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    // Initial state
    expect(container.read(counterProvider), 0);

    // Mutation
    container.read(counterProvider.notifier).increment();

    // Verification
    expect(container.read(counterProvider), 1);
  });
}
```

### 4.2 Mocking Dependencies (Overrides)

```dart
test('Products provider fetches from repo', () async {
  final mockRepo = MockProductRepository();
  when(() => mockRepo.fetchProducts()).thenAnswer((_) async => [Product(id: 1)]);

  final container = ProviderContainer(
    overrides: [
      productRepositoryProvider.overrideWithValue(mockRepo),
    ],
  );

  // Wait for AsyncValue
  final products = await container.read(productsProvider.future);
  expect(products.length, 1);
});
```

---

## Part 5: Best Practices Checklist

### ✅ Do This

- ✅ **Use Code Generation**: It prevents `Provider<String>` conflicts and handles modifiers (family/autoDispose) automatically.
- ✅ **Use `ref.watch` in `build`**: Always watch providers inside `build` method to react to changes.
- ✅ **Use `ref.read` in callbacks**: Only read inside `onPressed` or LifeCycle methods.
- ✅ **Use `autoDispose` by default**: Most providers (especially UI state) should destroy themselves when not used.
- ✅ **Use `Freezed` unions**: Combine with Riverpod for robust State classes (Data/Loading/Error).

### ❌ Avoid This

- ❌ **Storing Ref globally**: Never assign `ref` to a global variable. Pass it down or context.
- ❌ **`StateProvider` Abuse**: `StateProvider` is for simple UI toggles. Use `Notifier/AsyncNotifier` for logic.
- ❌ **Ignoring `AsyncValue` errors**: Always handle the error case in `.when`, don't assume success.
- ❌ **Mutable State objects**: Always use immutable state (copy method).

---

## Related Skills

- `@senior-flutter-developer` - Clean Architecture context
- `@flutter-testing-specialist` - Broader testing strategies
- `@flutter-firebase-developer` - Integration example

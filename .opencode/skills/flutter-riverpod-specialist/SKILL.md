---
name: flutter-riverpod-specialist
description: "Expert Flutter state management with Riverpod including providers, code generation, testing, and clean architecture patterns"
---

# Flutter Riverpod Specialist

## Overview

Master Riverpod state management in Flutter including all provider types, code generation, async handling, testing, and clean architecture integration.

## When to Use This Skill

- Use when implementing Riverpod
- Use when complex state management
- Use when building scalable Flutter apps
- Use when testing state logic

## How It Works

### Step 1: Provider Types

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Simple Provider (read-only value)
final configProvider = Provider<AppConfig>((ref) {
  return AppConfig();
});

// StateProvider (simple mutable state)
final counterProvider = StateProvider<int>((ref) => 0);

// FutureProvider (async data)
final userProvider = FutureProvider<User>((ref) async {
  final api = ref.watch(apiProvider);
  return await api.fetchCurrentUser();
});

// StreamProvider (reactive streams)
final messagesProvider = StreamProvider<List<Message>>((ref) {
  final repo = ref.watch(messageRepoProvider);
  return repo.watchMessages();
});

// StateNotifierProvider (complex state)
final todoListProvider = StateNotifierProvider<TodoNotifier, List<Todo>>((ref) {
  return TodoNotifier(ref.watch(todoRepoProvider));
});

// NotifierProvider (Riverpod 2.0+)
final cartProvider = NotifierProvider<CartNotifier, Cart>(() {
  return CartNotifier();
});

// AsyncNotifierProvider
final productsProvider = AsyncNotifierProvider<ProductsNotifier, List<Product>>(() {
  return ProductsNotifier();
});
```

### Step 2: Notifiers

```dart
// StateNotifier (legacy but still valid)
class TodoNotifier extends StateNotifier<List<Todo>> {
  final TodoRepository _repo;
  
  TodoNotifier(this._repo) : super([]);

  Future<void> loadTodos() async {
    state = await _repo.getAll();
  }

  void add(Todo todo) {
    state = [...state, todo];
  }

  void toggle(String id) {
    state = [
      for (final todo in state)
        if (todo.id == id) todo.copyWith(completed: !todo.completed)
        else todo
    ];
  }
}

// Notifier (Riverpod 2.0+)
class CartNotifier extends Notifier<Cart> {
  @override
  Cart build() => Cart.empty();

  void addItem(Product product) {
    state = state.copyWith(
      items: [...state.items, CartItem(product: product, quantity: 1)]
    );
  }

  void removeItem(String productId) {
    state = state.copyWith(
      items: state.items.where((i) => i.product.id != productId).toList()
    );
  }
}

// AsyncNotifier
class ProductsNotifier extends AsyncNotifier<List<Product>> {
  @override
  Future<List<Product>> build() async {
    return await ref.watch(productRepoProvider).getAll();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => 
      ref.watch(productRepoProvider).getAll()
    );
  }
}
```

### Step 3: Widget Integration

```dart
// ConsumerWidget
class TodoListScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todosAsync = ref.watch(todosProvider);
    
    return todosAsync.when(
      loading: () => const CircularProgressIndicator(),
      error: (error, stack) => Text('Error: $error'),
      data: (todos) => ListView.builder(
        itemCount: todos.length,
        itemBuilder: (context, index) => TodoTile(todo: todos[index]),
      ),
    );
  }
}

// ConsumerStatefulWidget
class CounterScreen extends ConsumerStatefulWidget {
  @override
  ConsumerState<CounterScreen> createState() => _CounterScreenState();
}

class _CounterScreenState extends ConsumerState<CounterScreen> {
  @override
  void initState() {
    super.initState();
    // Can access ref here
    ref.read(analyticsProvider).logScreenView('counter');
  }

  @override
  Widget build(BuildContext context) {
    final count = ref.watch(counterProvider);
    
    return Column(
      children: [
        Text('Count: $count'),
        ElevatedButton(
          onPressed: () => ref.read(counterProvider.notifier).state++,
          child: const Text('Increment'),
        ),
      ],
    );
  }
}
```

### Step 4: Testing

```dart
void main() {
  test('TodoNotifier adds todo', () {
    final container = ProviderContainer(
      overrides: [
        todoRepoProvider.overrideWithValue(MockTodoRepo()),
      ],
    );

    final notifier = container.read(todoListProvider.notifier);
    
    notifier.add(Todo(id: '1', title: 'Test'));
    
    expect(container.read(todoListProvider).length, 1);
  });

  testWidgets('Counter increments', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(home: CounterScreen()),
      ),
    );

    expect(find.text('Count: 0'), findsOneWidget);
    
    await tester.tap(find.text('Increment'));
    await tester.pump();
    
    expect(find.text('Count: 1'), findsOneWidget);
  });
}
```

## Best Practices

### ✅ Do This

- ✅ Use ref.watch in build
- ✅ Use ref.read for events
- ✅ Keep providers focused
- ✅ Use code generation
- ✅ Override providers in tests

### ❌ Avoid This

- ❌ Don't watch in callbacks
- ❌ Don't overuse global state
- ❌ Don't mutate state directly
- ❌ Don't skip autoDispose

## Related Skills

- `@senior-flutter-developer` - Flutter fundamentals
- `@flutter-testing-specialist` - Testing Flutter

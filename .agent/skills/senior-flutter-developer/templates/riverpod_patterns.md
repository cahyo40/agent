# Advanced Riverpod Patterns

## Pattern 1: Family Providers with Caching

```dart
@riverpod
class ProductDetail extends _$ProductDetail {
  @override
  Future<Product> build(String productId) async {
    // Auto-dispose after 5 minutes of inactivity
    ref.keepAlive();
    final timer = Timer(const Duration(minutes: 5), ref.invalidateSelf);
    ref.onDispose(timer.cancel);

    return ref.read(productRepositoryProvider).getProduct(productId);
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(productRepositoryProvider).getProduct(arg),
    );
  }
}
```

## Pattern 2: Computed Providers with Select

```dart
@riverpod
int cartItemCount(CartItemCountRef ref) {
  return ref.watch(cartControllerProvider.select((cart) => cart.items.length));
}

@riverpod
double cartTotal(CartTotalRef ref) {
  final items = ref.watch(cartControllerProvider.select((c) => c.items));
  return items.fold(0, (sum, item) => sum + (item.price * item.quantity));
}

// Usage in widget (only rebuilds when count changes)
Consumer(
  builder: (context, ref, _) {
    final count = ref.watch(cartItemCountProvider);
    return Badge(label: Text('$count'));
  },
)
```

## Pattern 3: AsyncNotifier with Optimistic Updates

```dart
@riverpod
class TodoList extends _$TodoList {
  @override
  Future<List<Todo>> build() async {
    return ref.read(todoRepositoryProvider).getTodos();
  }

  Future<void> toggleComplete(Todo todo) async {
    final updatedTodo = todo.copyWith(isComplete: !todo.isComplete);
    
    // Optimistic update
    state = AsyncData([
      for (final t in state.valueOrNull ?? [])
        if (t.id == todo.id) updatedTodo else t,
    ]);

    try {
      await ref.read(todoRepositoryProvider).updateTodo(updatedTodo);
    } catch (e) {
      // Rollback on failure
      state = AsyncData([
        for (final t in state.valueOrNull ?? [])
          if (t.id == todo.id) todo else t,
      ]);
      rethrow;
    }
  }
}
```

## Pattern 4: Multi-Provider Composition

```dart
@riverpod
Future<DashboardData> dashboard(DashboardRef ref) async {
  // Parallel fetching with error handling per request
  final results = await Future.wait([
    ref.watch(userProfileProvider.future).then((v) => ('user', v, null))
        .catchError((e) => ('user', null, e)),
    ref.watch(recentOrdersProvider.future).then((v) => ('orders', v, null))
        .catchError((e) => ('orders', null, e)),
    ref.watch(notificationsProvider.future).then((v) => ('notifs', v, null))
        .catchError((e) => ('notifs', null, e)),
  ]);

  return DashboardData(
    user: results[0].$2 as UserProfile?,
    orders: results[1].$2 as List<Order>?,
    notifications: results[2].$2 as List<Notification>?,
    errors: results.where((r) => r.$3 != null).map((r) => r.$1).toList(),
  );
}
```

## Pattern 5: Debounced Search

```dart
@riverpod
class SearchController extends _$SearchController {
  Timer? _debounceTimer;

  @override
  AsyncValue<List<SearchResult>> build() => const AsyncData([]);

  void search(String query) {
    _debounceTimer?.cancel();
    
    if (query.isEmpty) {
      state = const AsyncData([]);
      return;
    }

    _debounceTimer = Timer(const Duration(milliseconds: 300), () async {
      state = const AsyncLoading();
      state = await AsyncValue.guard(
        () => ref.read(searchRepositoryProvider).search(query),
      );
    });
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }
}
```

---
description: Generate feature baru dengan struktur Clean Architecture lengkap menggunakan **flutter_bloc**. (Part 10/11)
---
# Workflow: Flutter BLoC Feature Maker (Part 10/11)

> **Navigation:** This workflow is split into 11 parts.

## Usage Example: Todo Feature (BLoC)

### Step 5: Todo List Screen

**File: `lib/features/todo/presentation/screens/todo_list_screen.dart`**
```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/routes.dart';
import '../../../../injection.dart';
import '../../domain/entities/todo_entity.dart';
import '../bloc/todo_bloc.dart';
import '../widgets/todo_shimmer.dart';

class TodoListScreen extends StatelessWidget {
  const TodoListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<TodoBloc>()..add(const LoadTodos()),
      child: const _TodoListView(),
    );
  }
}

class _TodoListView extends StatelessWidget {
  const _TodoListView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Todo List'),
        actions: [
          // Tampilkan counter dari BlocBuilder
          BlocBuilder<TodoBloc, TodoState>(
            builder: (context, state) {
              if (state is TodoLoaded) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: Text(
                      '${state.completedCount}/${state.todos.length}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: BlocConsumer<TodoBloc, TodoState>(
        listener: (context, state) {
          switch (state) {
            case TodoCreated(:final todo):
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('"${todo.title}" ditambahkan!')),
              );
            case TodoDeleted():
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Todo dihapus')),
              );
            case TodoOperationError(:final message):
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Error: $message'),
                  backgroundColor: Colors.red,
                ),
              );
            default:
              break;
          }
        },
        builder: (context, state) {
          return switch (state) {
            TodoInitial() => const Center(child: Text('Memuat...')),
            TodoLoading() => const TodoListShimmer(),
            TodoLoaded(:final todos) => _buildTodoList(context, todos),
            TodoError(:final message) => _buildError(context, message),
            TodoCreated(:final updatedTodos) => _buildTodoList(context, updatedTodos),
            TodoDeleted(:final updatedTodos) => _buildTodoList(context, updatedTodos),
            TodoOperationError(:final currentTodos) => _buildTodoList(context, currentTodos),
            TodoDetailLoaded() => const SizedBox.shrink(),
          };
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildTodoList(BuildContext context, List<Todo> todos) {
    if (todos.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle_outline, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('Belum ada todo'),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        context.read<TodoBloc>().add(const RefreshTodos());
      },
      child: ListView.builder(
        itemCount: todos.length,
        itemBuilder: (context, index) {
          final todo = todos[index];
          return Dismissible(
            key: Key(todo.id),
            direction: DismissDirection.endToStart,
            background: Container(
              color: Colors.red,
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 16),
              child: const Icon(Icons.delete, color: Colors.white),
            ),
            onDismissed: (_) {
              context.read<TodoBloc>().add(DeleteTodoEvent(todo.id));
            },
            child: ListTile(
              leading: Checkbox(
                value: todo.isCompleted,
                onChanged: (_) {
                  context.read<TodoBloc>().add(ToggleTodoEvent(todo));
                },
              ),
              title: Text(
                todo.title,
                style: TextStyle(
                  decoration: todo.isCompleted
                      ? TextDecoration.lineThrough
                      : null,
                  color: todo.isCompleted ? Colors.grey : null,
                ),
              ),
              subtitle: todo.description != null
                  ? Text(todo.description!, maxLines: 1, overflow: TextOverflow.ellipsis)
                  : null,
              onTap: () => context.push(AppRoutes.todoDetailPath(todo.id)),
            ),
          );
        },
      ),
    );
  }

  Widget _buildError(BuildContext context, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text('Error: $message'),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => context.read<TodoBloc>().add(const LoadTodos()),
            child: const Text('Coba Lagi'),
          ),
        ],
      ),
    );
  }

  void _showAddDialog(BuildContext context) {
    final titleController = TextEditingController();
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Tambah Todo'),
        content: TextField(
          controller: titleController,
          decoration: const InputDecoration(hintText: 'Judul todo...'),
          autofocus: true,
          onSubmitted: (value) {
            if (value.isNotEmpty) {
              context.read<TodoBloc>().add(CreateTodoEvent(title: value));
              Navigator.pop(dialogContext);
            }
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              if (titleController.text.isNotEmpty) {
                context.read<TodoBloc>().add(
                      CreateTodoEvent(title: titleController.text),
                    );
                Navigator.pop(dialogContext);
              }
            },
            child: const Text('Tambah'),
          ),
        ],
      ),
    );
  }
}
```

## Usage Example: Todo Feature (BLoC)

### Step 6: Register Routes

**File: `lib/core/router/routes.dart`**
```dart
class AppRoutes {
  static const String todos = '/todos';
  static const String todoDetail = '/todos/:id';
  static const String todoCreate = '/todos/create';

  static String todoDetailPath(String id) => '/todos/$id';
}
```

**File: `lib/core/router/app_router.dart`**
```dart
GoRoute(
  path: AppRoutes.todos,
  builder: (context, state) => const TodoListScreen(),
  routes: [
    GoRoute(
      path: 'create',
      builder: (context, state) => const TodoCreateScreen(),
    ),
    GoRoute(
      path: ':id',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return TodoDetailScreen(todoId: id);
      },
    ),
  ],
),
```

## Usage Example: Todo Feature (BLoC)

### Step 7: DI Registration

```dart
// Dengan @injectable annotations, cukup jalankan:
// dart run build_runner build -d
// Semua class yang di-annotasi @injectable / @lazySingleton otomatis ter-register.
```

## Usage Example: Todo Feature (BLoC)

### Step 8: Run & Test
```bash
# Generate code (freezed, injectable, dll)
dart run build_runner build --delete-conflicting-outputs

# Analyze
flutter analyze

# Run app
flutter run

# Test navigasi:
# 1. Todo list screen -> Add todo -> Snackbar muncul
# 2. Tap todo -> Detail screen
# 3. Swipe to delete -> Snackbar muncul
# 4. Toggle checkbox -> Status berubah
# 5. Pull to refresh -> Data refresh tanpa shimmer
```

---


---
description: Generate feature baru dengan struktur Clean Architecture lengkap menggunakan GetX + YoUI pattern. (Part 8/10)
---
# Workflow: Flutter Feature Maker (GetX) (Part 8/10)

> **Navigation:** This workflow is split into 10 parts.

## Usage Example

### Step 1: Generate Feature Files
```bash
# Ganti placeholder dengan nama feature:
# {FeatureName} -> Todo
# {featureName} -> todo
# {feature_name} -> todo
#
# Tidak perlu code generation -- langsung siap pakai!
```

## Usage Example

### Step 2: Domain Layer -- Entity

**File: `lib/features/todo/domain/entities/todo_entity.dart`**
```dart
import 'package:equatable/equatable.dart';

class Todo extends Equatable {
  final String id;
  final String title;
  final String? description;
  final bool isCompleted;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const Todo({
    required this.id,
    required this.title,
    this.description,
    this.isCompleted = false,
    required this.createdAt,
    this.updatedAt,
  });

  Todo copyWith({
    String? id,
    String? title,
    String? description,
    bool? isCompleted,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Todo(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [id, title, description, isCompleted, createdAt, updatedAt];
}
```

## Usage Example

### Step 3: Data Layer -- Model (Manual JSON)

**File: `lib/features/todo/data/models/todo_model.dart`**
```dart
import '../../domain/entities/todo_entity.dart';

class TodoModel {
  final String id;
  final String title;
  final String? description;
  final bool isCompleted;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const TodoModel({
    required this.id,
    required this.title,
    this.description,
    this.isCompleted = false,
    required this.createdAt,
    this.updatedAt,
  });

  factory TodoModel.fromJson(Map<String, dynamic> json) {
    return TodoModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      isCompleted: json['is_completed'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'is_completed': isCompleted,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  Todo toEntity() {
    return Todo(
      id: id,
      title: title,
      description: description,
      isCompleted: isCompleted,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  factory TodoModel.fromEntity(Todo entity) {
    return TodoModel(
      id: entity.id,
      title: entity.title,
      description: entity.description,
      isCompleted: entity.isCompleted,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  static List<TodoModel> fromJsonList(List<dynamic> jsonList) {
    return jsonList
        .map((json) => TodoModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }
}
```

## Usage Example

### Step 4: Presentation Layer -- Controller

**File: `lib/features/todo/controllers/todo_controller.dart`**
```dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yo_ui/yo_ui.dart';
import '../../../domain/entities/todo_entity.dart';
import '../domain/repositories/todo_repository.dart';

class TodoController extends GetxController {
  final TodoRepository _repository = Get.find<TodoRepository>();

  // Reactive state
  final RxList<Todo> todos = <Todo>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final Rx<Todo?> selectedTodo = Rx<Todo?>(null);
  final RxBool isSubmitting = false.obs;

  // Filter
  final RxString filter = 'all'.obs; // 'all', 'active', 'completed'

  // Computed list berdasarkan filter
  List<Todo> get filteredTodos {
    switch (filter.value) {
      case 'active':
        return todos.where((t) => !t.isCompleted).toList();
      case 'completed':
        return todos.where((t) => t.isCompleted).toList();
      default:
        return todos;
    }
  }

  int get completedCount => todos.where((t) => t.isCompleted).length;
  int get activeCount => todos.where((t) => !t.isCompleted).length;

  @override
  void onInit() {
    super.onInit();
    fetchTodos();
  }

  Future<void> fetchTodos() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final result = await _repository.getTodos();

      result.fold(
        (failure) => errorMessage.value = failure.message,
        (data) => todos.assignAll(data),
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> createTodo({
    required String title,
    String? description,
  }) async {
    try {
      isSubmitting.value = true;

      final newTodo = Todo(
        id: '',
        title: title,
        description: description,
        createdAt: DateTime.now(),
      );

      final result = await _repository.createTodo(newTodo);

      result.fold(
        (failure) {
          errorMessage.value = failure.message;
          // YoToast.error() dipanggil dari View layer
        },
        (todo) {
          todos.add(todo);
          Get.back();
          // YoToast.success() dipanggil dari View layer
        },
      );
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<void> toggleComplete(String id) async {
    final index = todos.indexWhere((t) => t.id == id);
    if (index == -1) return;

    final todo = todos[index];
    final updated = todo.copyWith(
      isCompleted: !todo.isCompleted,
      updatedAt: DateTime.now(),
    );

    final result = await _repository.updateTodo(updated);

    result.fold(
      (failure) => errorMessage.value = failure.message,
      (updatedTodo) {
        todos[index] = updatedTodo;
      },
    );
  }

  Future<void> deleteTodo(String id) async {
    final result = await _repository.deleteTodo(id);

    result.fold(
      (failure) => errorMessage.value = failure.message,
      (_) {
        todos.removeWhere((t) => t.id == id);
        if (selectedTodo.value?.id == id) {
          selectedTodo.value = null;
        }
          // YoToast.success() dipanggil dari View layer
      },
    );
  }

  void confirmDelete(String id, BuildContext context) {
    Get.dialog(
      AlertDialog(
        title: const Text('Hapus Todo'),
        content: const Text('Apakah Anda yakin ingin menghapus todo ini?'),
        actions: [
          YoButton.ghost(
            text: 'Batal',
            onPressed: () => Get.back(),
          ),
          YoButton.primary(
            text: 'Hapus',
            onPressed: () {
              Get.back();
              deleteTodo(id);
              YoToast.success(
                context: context,
                message: 'Todo berhasil dihapus',
              );
            },
            backgroundColor: Theme.of(context)
                .colorScheme
                .error,
          ),
        ],
      ),
    );
  }

  void setFilter(String value) {
    filter.value = value;
  }
}
```

## Usage Example

### Step 5: Presentation Layer -- Binding

**File: `lib/features/todo/bindings/todo_binding.dart`**
```dart
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../controllers/todo_controller.dart';
import '../data/datasources/todo_remote_ds.dart';
import '../data/datasources/todo_local_ds.dart';
import '../data/repositories/todo_repository_impl.dart';
import '../domain/repositories/todo_repository.dart';

class TodoBinding extends Bindings {
  @override
  void dependencies() {
    // Data Sources
    Get.lazyPut<TodoRemoteDataSource>(
      () => TodoRemoteDataSourceImpl(Get.find()),
    );
    Get.lazyPut<TodoLocalDataSource>(
      () => TodoLocalDataSourceImpl(GetStorage()),
    );

    // Repository
    Get.lazyPut<TodoRepository>(
      () => TodoRepositoryImpl(
        remoteDataSource: Get.find<TodoRemoteDataSource>(),
        localDataSource: Get.find<TodoLocalDataSource>(),
      ),
    );

    // Controller
    Get.lazyPut<TodoController>(() => TodoController());
  }
}
```

## Usage Example

### Step 6: Register Routes (WAJIB!)

**File: `lib/routes/app_routes.dart`**
```dart
abstract class AppRoutes {
  // ... existing routes ...

  // Todo routes
  static const String todos = '/todos';
  static const String todoDetail = '/todos/:id';
  static const String todoCreate = '/todos/create';

  static String todoDetailPath(String id) => '/todos/$id';
}
```

**File: `lib/routes/app_pages.dart`**
```dart
import 'package:get/get.dart';
import 'app_routes.dart';
import '../features/todo/bindings/todo_binding.dart';
import '../features/todo/views/todo_list_view.dart';
import '../features/todo/views/todo_detail_view.dart';

class AppPages {
  static final routes = [
    // ... existing routes ...

    // Todo routes
    GetPage(
      name: AppRoutes.todos,
      page: () => const TodoListView(),
      binding: TodoBinding(),
      transition: Transition.rightToLeft,
      children: [
        GetPage(
          name: '/:id',
          page: () => const TodoDetailView(),
        ),
      ],
    ),
  ];
}
```


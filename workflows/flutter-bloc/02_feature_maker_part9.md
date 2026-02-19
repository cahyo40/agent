---
description: Generate feature baru dengan struktur Clean Architecture lengkap menggunakan **flutter_bloc**. (Part 9/11)
---
# Workflow: Flutter BLoC Feature Maker (Part 9/11)

> **Navigation:** This workflow is split into 11 parts.

## Usage Example: Todo Feature (BLoC)

### Step 1: Entity

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

  factory Todo.create({required String title, String? description}) {
    return Todo(
      id: '',
      title: title,
      description: description,
      createdAt: DateTime.now(),
    );
  }

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

## Usage Example: Todo Feature (BLoC)

### Step 2: BLoC Events

**File: `lib/features/todo/presentation/bloc/todo_event.dart`**
```dart
part of 'todo_bloc.dart';

sealed class TodoEvent extends Equatable {
  const TodoEvent();
  @override
  List<Object?> get props => [];
}

final class LoadTodos extends TodoEvent {
  const LoadTodos();
}

final class LoadTodoById extends TodoEvent {
  final String id;
  const LoadTodoById(this.id);
  @override
  List<Object?> get props => [id];
}

final class CreateTodoEvent extends TodoEvent {
  final String title;
  final String? description;
  const CreateTodoEvent({required this.title, this.description});
  @override
  List<Object?> get props => [title, description];
}

final class UpdateTodoEvent extends TodoEvent {
  final Todo todo;
  const UpdateTodoEvent(this.todo);
  @override
  List<Object?> get props => [todo];
}

final class ToggleTodoEvent extends TodoEvent {
  final Todo todo;
  const ToggleTodoEvent(this.todo);
  @override
  List<Object?> get props => [todo];
}

final class DeleteTodoEvent extends TodoEvent {
  final String id;
  const DeleteTodoEvent(this.id);
  @override
  List<Object?> get props => [id];
}

final class RefreshTodos extends TodoEvent {
  const RefreshTodos();
}
```

## Usage Example: Todo Feature (BLoC)

### Step 3: BLoC States

**File: `lib/features/todo/presentation/bloc/todo_state.dart`**
```dart
part of 'todo_bloc.dart';

sealed class TodoState extends Equatable {
  const TodoState();
  @override
  List<Object?> get props => [];
}

final class TodoInitial extends TodoState {
  const TodoInitial();
}

final class TodoLoading extends TodoState {
  const TodoLoading();
}

final class TodoLoaded extends TodoState {
  final List<Todo> todos;
  const TodoLoaded(this.todos);
  bool get isEmpty => todos.isEmpty;
  int get completedCount => todos.where((t) => t.isCompleted).length;
  int get pendingCount => todos.where((t) => !t.isCompleted).length;
  @override
  List<Object?> get props => [todos];
}

final class TodoError extends TodoState {
  final String message;
  const TodoError(this.message);
  @override
  List<Object?> get props => [message];
}

final class TodoCreated extends TodoState {
  final Todo todo;
  final List<Todo> updatedTodos;
  const TodoCreated({required this.todo, required this.updatedTodos});
  @override
  List<Object?> get props => [todo, updatedTodos];
}

final class TodoDeleted extends TodoState {
  final String deletedId;
  final List<Todo> updatedTodos;
  const TodoDeleted({required this.deletedId, required this.updatedTodos});
  @override
  List<Object?> get props => [deletedId, updatedTodos];
}

final class TodoOperationError extends TodoState {
  final String message;
  final List<Todo> currentTodos;
  const TodoOperationError({required this.message, required this.currentTodos});
  @override
  List<Object?> get props => [message, currentTodos];
}

final class TodoDetailLoaded extends TodoState {
  final Todo todo;
  const TodoDetailLoaded(this.todo);
  @override
  List<Object?> get props => [todo];
}
```

## Usage Example: Todo Feature (BLoC)

### Step 4: BLoC

**File: `lib/features/todo/presentation/bloc/todo_bloc.dart`**
```dart
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/todo_entity.dart';
import '../../domain/usecases/create_todo.dart';
import '../../domain/usecases/delete_todo.dart';
import '../../domain/usecases/get_todo_by_id.dart';
import '../../domain/usecases/get_todos.dart';
import '../../domain/usecases/update_todo.dart';

part 'todo_event.dart';
part 'todo_state.dart';

@injectable
class TodoBloc extends Bloc<TodoEvent, TodoState> {
  final GetTodos _getTodos;
  final GetTodoById _getTodoById;
  final CreateTodo _createTodo;
  final UpdateTodo _updateTodo;
  final DeleteTodo _deleteTodo;

  TodoBloc({
    required GetTodos getTodos,
    required GetTodoById getTodoById,
    required CreateTodo createTodo,
    required UpdateTodo updateTodo,
    required DeleteTodo deleteTodo,
  })  : _getTodos = getTodos,
        _getTodoById = getTodoById,
        _createTodo = createTodo,
        _updateTodo = updateTodo,
        _deleteTodo = deleteTodo,
        super(const TodoInitial()) {
    on<LoadTodos>(_onLoadTodos);
    on<LoadTodoById>(_onLoadTodoById);
    on<CreateTodoEvent>(_onCreateTodo);
    on<UpdateTodoEvent>(_onUpdateTodo);
    on<ToggleTodoEvent>(_onToggleTodo);
    on<DeleteTodoEvent>(_onDeleteTodo);
    on<RefreshTodos>(_onRefreshTodos);
  }

  List<Todo> _currentTodos = [];

  Future<void> _onLoadTodos(LoadTodos event, Emitter<TodoState> emit) async {
    emit(const TodoLoading());
    final result = await _getTodos(const NoParams());
    result.fold(
      (f) => emit(TodoError(f.message)),
      (todos) {
        _currentTodos = todos;
        emit(TodoLoaded(todos));
      },
    );
  }

  Future<void> _onLoadTodoById(LoadTodoById event, Emitter<TodoState> emit) async {
    emit(const TodoLoading());
    final result = await _getTodoById(GetTodoByIdParams(id: event.id));
    result.fold(
      (f) => emit(TodoError(f.message)),
      (todo) => emit(TodoDetailLoaded(todo)),
    );
  }

  Future<void> _onCreateTodo(CreateTodoEvent event, Emitter<TodoState> emit) async {
    final newTodo = Todo.create(title: event.title, description: event.description);
    final result = await _createTodo(newTodo);
    result.fold(
      (f) => emit(TodoOperationError(message: f.message, currentTodos: _currentTodos)),
      (created) {
        _currentTodos = [..._currentTodos, created];
        emit(TodoCreated(todo: created, updatedTodos: _currentTodos));
        emit(TodoLoaded(_currentTodos));
      },
    );
  }

  Future<void> _onUpdateTodo(UpdateTodoEvent event, Emitter<TodoState> emit) async {
    final result = await _updateTodo(event.todo);
    result.fold(
      (f) => emit(TodoOperationError(message: f.message, currentTodos: _currentTodos)),
      (updated) {
        _currentTodos = _currentTodos.map((t) => t.id == updated.id ? updated : t).toList();
        emit(TodoLoaded(_currentTodos));
      },
    );
  }

  Future<void> _onToggleTodo(ToggleTodoEvent event, Emitter<TodoState> emit) async {
    final toggled = event.todo.copyWith(
      isCompleted: !event.todo.isCompleted,
      updatedAt: DateTime.now(),
    );
    final result = await _updateTodo(toggled);
    result.fold(
      (f) => emit(TodoOperationError(message: f.message, currentTodos: _currentTodos)),
      (updated) {
        _currentTodos = _currentTodos.map((t) => t.id == updated.id ? updated : t).toList();
        emit(TodoLoaded(_currentTodos));
      },
    );
  }

  Future<void> _onDeleteTodo(DeleteTodoEvent event, Emitter<TodoState> emit) async {
    final result = await _deleteTodo(DeleteTodoParams(id: event.id));
    result.fold(
      (f) => emit(TodoOperationError(message: f.message, currentTodos: _currentTodos)),
      (_) {
        _currentTodos = _currentTodos.where((t) => t.id != event.id).toList();
        emit(TodoDeleted(deletedId: event.id, updatedTodos: _currentTodos));
        emit(TodoLoaded(_currentTodos));
      },
    );
  }

  Future<void> _onRefreshTodos(RefreshTodos event, Emitter<TodoState> emit) async {
    final result = await _getTodos(const NoParams());
    result.fold(
      (f) => emit(TodoError(f.message)),
      (todos) {
        _currentTodos = todos;
        emit(TodoLoaded(todos));
      },
    );
  }
}
```


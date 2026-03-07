---
description: Generate feature baru dengan struktur Clean Architecture lengkap menggunakan flutter_bloc.
---
# Workflow: Flutter BLoC Feature Maker

// turbo-all

## Overview

Generate feature baru dengan Clean Architecture structure dan **BLoC pattern**:
- Domain layer (entity, repository contract, use cases)
- Data layer (model dengan `fromJson`/`toJson`, data sources, repository impl)
- Presentation layer (**BLoC events + states**, screens dengan `BlocConsumer`, widgets)

**Perbedaan utama dengan Riverpod Feature Maker:**
- State management pakai `Bloc<Event, State>` (bukan `Notifier`)
- Events dan States sebagai **sealed class** (Dart 3)
- Side effects ditangani via `BlocListener`
- DI pakai `get_it` + `injectable`
- Pattern matching pada state di `BlocBuilder`


## Prerequisites

- Project setup dari `01_project_setup.md` selesai
- `get_it` + `injectable` configured
- `flutter_bloc`, `equatable` installed
- `GoRouter` configured


## Agent Behavior

- **Tanya nama feature** — contoh: `product`, `order`, `user`, `todo`.
- **Tanya fields** — list fields yang dibutuhkan entity.
- **Auto-generate semua layers** — domain, data, presentation (3 files bloc).
- **Auto-register routes** — tambahkan ke `routes.dart` dan `app_router.dart`.
- **Gunakan Result<T> sealed class** — tidak pakai `dartz`.
- **Provide BlocProvider di level route** — bukan di MultiBlocProvider root.
- **Selalu run code generation** setelah semua file dibuat.


## Recommended Skills

- `senior-flutter-developer` — Flutter + BLoC + Clean Architecture
- `senior-software-engineer` — Code scaffolding


## Output Location

`sdlc/flutter-bloc/02-feature-maker/`


## Placeholder Convention

| Placeholder | Contoh (Todo) | Keterangan |
|---|---|---|
| `{FeatureName}` | `Todo` | PascalCase |
| `{featureName}` | `todo` | camelCase |
| `{feature_name}` | `todo` | snake_case |


## Output Structure

```
lib/features/{feature_name}/
├── data/
│   ├── datasources/
│   │   ├── {feature_name}_remote_ds.dart
│   │   └── {feature_name}_local_ds.dart
│   ├── models/
│   │   └── {feature_name}_model.dart
│   └── repositories/
│       └── {feature_name}_repository_impl.dart
├── domain/
│   ├── entities/
│   │   └── {feature_name}_entity.dart
│   ├── repositories/
│   │   └── {feature_name}_repository.dart
│   └── usecases/
│       ├── get_{feature_name}s.dart
│       ├── get_{feature_name}_by_id.dart
│       ├── create_{feature_name}.dart
│       ├── update_{feature_name}.dart
│       └── delete_{feature_name}.dart
└── presentation/
    ├── bloc/
    │   ├── {feature_name}_bloc.dart
    │   ├── {feature_name}_event.dart
    │   └── {feature_name}_state.dart
    ├── screens/
    │   ├── {feature_name}_list_screen.dart
    │   └── {feature_name}_detail_screen.dart
    └── widgets/
        ├── {feature_name}_list_item.dart
        ├── {feature_name}_form.dart
        └── {feature_name}_shimmer.dart
```


## Workflow Steps

### Step 1: Analyze Requirements

- Tentukan nama feature (snake_case, contoh: `product`, `order`, `todo`)
- List fields untuk entity
- Tentukan operations (CRUD atau subset)

### Step 2: Generate Domain Layer

#### Entity

```dart
// domain/entities/{feature_name}_entity.dart
import 'package:equatable/equatable.dart';

class {FeatureName} extends Equatable {
  final String id;
  final String name;
  final String? description;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const {FeatureName}({
    required this.id,
    required this.name,
    this.description,
    this.isActive = true,
    required this.createdAt,
    this.updatedAt,
  });

  {FeatureName} copyWith({
    String? id,
    String? name,
    String? description,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => {FeatureName}(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );

  @override
  List<Object?> get props => [id, name, description, isActive, createdAt, updatedAt];
}
```

#### Repository Contract

```dart
// domain/repositories/{feature_name}_repository.dart
import '../../../../core/error/result.dart';
import '../entities/{feature_name}_entity.dart';

abstract class {FeatureName}Repository {
  Future<Result<List<{FeatureName}>>> get{FeatureName}s();
  Future<Result<{FeatureName}>> get{FeatureName}ById(String id);
  Future<Result<{FeatureName}>> create{FeatureName}({FeatureName} item);
  Future<Result<{FeatureName}>> update{FeatureName}({FeatureName} item);
  Future<Result<void>> delete{FeatureName}(String id);
}
```

#### Use Cases

```dart
// domain/usecases/get_{feature_name}s.dart
import 'package:injectable/injectable.dart';
import '../../../../core/error/result.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/{feature_name}_entity.dart';
import '../repositories/{feature_name}_repository.dart';

@injectable
class Get{FeatureName}s implements UseCaseNoParams<List<{FeatureName}>> {
  final {FeatureName}Repository repository;
  Get{FeatureName}s(this.repository);

  @override
  Future<Result<List<{FeatureName}>>> call() => repository.get{FeatureName}s();
}

// domain/usecases/get_{feature_name}_by_id.dart
class Get{FeatureName}ByIdParams {
  final String id;
  const Get{FeatureName}ByIdParams({required this.id});
}

@injectable
class Get{FeatureName}ById implements UseCase<{FeatureName}, Get{FeatureName}ByIdParams> {
  final {FeatureName}Repository repository;
  Get{FeatureName}ById(this.repository);

  @override
  Future<Result<{FeatureName}>> call(Get{FeatureName}ByIdParams params) =>
      repository.get{FeatureName}ById(params.id);
}

// domain/usecases/create_{feature_name}.dart
@injectable
class Create{FeatureName} implements UseCase<{FeatureName}, {FeatureName}> {
  final {FeatureName}Repository repository;
  Create{FeatureName}(this.repository);

  @override
  Future<Result<{FeatureName}>> call({FeatureName} item) =>
      repository.create{FeatureName}(item);
}

// domain/usecases/update_{feature_name}.dart
@injectable
class Update{FeatureName} implements UseCase<{FeatureName}, {FeatureName}> {
  final {FeatureName}Repository repository;
  Update{FeatureName}(this.repository);

  @override
  Future<Result<{FeatureName}>> call({FeatureName} item) =>
      repository.update{FeatureName}(item);
}

// domain/usecases/delete_{feature_name}.dart
class Delete{FeatureName}Params {
  final String id;
  const Delete{FeatureName}Params({required this.id});
}

@injectable
class Delete{FeatureName} implements UseCase<void, Delete{FeatureName}Params> {
  final {FeatureName}Repository repository;
  Delete{FeatureName}(this.repository);

  @override
  Future<Result<void>> call(Delete{FeatureName}Params params) =>
      repository.delete{FeatureName}(params.id);
}
```

### Step 3: Generate Data Layer

#### Model

```dart
// data/models/{feature_name}_model.dart
import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/{feature_name}_entity.dart';

part '{feature_name}_model.g.dart';

@JsonSerializable()
class {FeatureName}Model {
  final String id;
  final String name;
  final String? description;
  @JsonKey(name: 'is_active')
  final bool isActive;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;

  const {FeatureName}Model({
    required this.id,
    required this.name,
    this.description,
    this.isActive = true,
    required this.createdAt,
    this.updatedAt,
  });

  factory {FeatureName}Model.fromJson(Map<String, dynamic> json) =>
      _${FeatureName}ModelFromJson(json);

  Map<String, dynamic> toJson() => _${FeatureName}ModelToJson(this);

  factory {FeatureName}Model.fromEntity({FeatureName} entity) => {FeatureName}Model(
    id: entity.id,
    name: entity.name,
    description: entity.description,
    isActive: entity.isActive,
    createdAt: entity.createdAt,
    updatedAt: entity.updatedAt,
  );

  {FeatureName} toEntity() => {FeatureName}(
    id: id,
    name: name,
    description: description,
    isActive: isActive,
    createdAt: createdAt,
    updatedAt: updatedAt,
  );
}
```

#### Remote Data Source

```dart
// data/datasources/{feature_name}_remote_ds.dart
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../models/{feature_name}_model.dart';

abstract class {FeatureName}RemoteDataSource {
  Future<List<{FeatureName}Model>> get{FeatureName}s();
  Future<{FeatureName}Model> get{FeatureName}ById(String id);
  Future<{FeatureName}Model> create{FeatureName}({FeatureName}Model model);
  Future<{FeatureName}Model> update{FeatureName}({FeatureName}Model model);
  Future<void> delete{FeatureName}(String id);
}

@LazySingleton(as: {FeatureName}RemoteDataSource)
class {FeatureName}RemoteDataSourceImpl implements {FeatureName}RemoteDataSource {
  final Dio dio;
  static const String _basePath = '/api/{feature_name}s';

  {FeatureName}RemoteDataSourceImpl(this.dio);

  @override
  Future<List<{FeatureName}Model>> get{FeatureName}s() async {
    final response = await dio.get(_basePath);
    final List<dynamic> data = response.data['data'];
    return data.map((json) => {FeatureName}Model.fromJson(json)).toList();
  }

  @override
  Future<{FeatureName}Model> get{FeatureName}ById(String id) async {
    final response = await dio.get('$_basePath/$id');
    return {FeatureName}Model.fromJson(response.data['data']);
  }

  @override
  Future<{FeatureName}Model> create{FeatureName}({FeatureName}Model model) async {
    final response = await dio.post(_basePath, data: model.toJson());
    return {FeatureName}Model.fromJson(response.data['data']);
  }

  @override
  Future<{FeatureName}Model> update{FeatureName}({FeatureName}Model model) async {
    final response = await dio.put('$_basePath/${model.id}', data: model.toJson());
    return {FeatureName}Model.fromJson(response.data['data']);
  }

  @override
  Future<void> delete{FeatureName}(String id) async {
    await dio.delete('$_basePath/$id');
  }
}
```

#### Repository Implementation

```dart
// data/repositories/{feature_name}_repository_impl.dart
import 'package:injectable/injectable.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/error/result.dart';
import '../../domain/entities/{feature_name}_entity.dart';
import '../../domain/repositories/{feature_name}_repository.dart';
import '../datasources/{feature_name}_remote_ds.dart';
import '../models/{feature_name}_model.dart';

@LazySingleton(as: {FeatureName}Repository)
class {FeatureName}RepositoryImpl implements {FeatureName}Repository {
  final {FeatureName}RemoteDataSource remoteDataSource;

  {FeatureName}RepositoryImpl(this.remoteDataSource);

  @override
  Future<Result<List<{FeatureName}>>> get{FeatureName}s() async {
    try {
      final models = await remoteDataSource.get{FeatureName}s();
      return Success(models.map((m) => m.toEntity()).toList());
    } on ServerException catch (e) {
      return ResultFailure(ServerFailure(message: e.message));
    } on NetworkException {
      return const ResultFailure(NetworkFailure());
    }
  }

  @override
  Future<Result<{FeatureName}>> get{FeatureName}ById(String id) async {
    try {
      final model = await remoteDataSource.get{FeatureName}ById(id);
      return Success(model.toEntity());
    } on ServerException catch (e) {
      return ResultFailure(ServerFailure(message: e.message));
    }
  }

  @override
  Future<Result<{FeatureName}>> create{FeatureName}({FeatureName} item) async {
    try {
      final model = {FeatureName}Model.fromEntity(item);
      final result = await remoteDataSource.create{FeatureName}(model);
      return Success(result.toEntity());
    } on ServerException catch (e) {
      return ResultFailure(ServerFailure(message: e.message));
    }
  }

  @override
  Future<Result<{FeatureName}>> update{FeatureName}({FeatureName} item) async {
    try {
      final model = {FeatureName}Model.fromEntity(item);
      final result = await remoteDataSource.update{FeatureName}(model);
      return Success(result.toEntity());
    } on ServerException catch (e) {
      return ResultFailure(ServerFailure(message: e.message));
    }
  }

  @override
  Future<Result<void>> delete{FeatureName}(String id) async {
    try {
      await remoteDataSource.delete{FeatureName}(id);
      return const Success(null);
    } on ServerException catch (e) {
      return ResultFailure(ServerFailure(message: e.message));
    }
  }
}
```

### Step 4: Generate Presentation Layer — BLoC

**Ini bagian terpenting yang membedakan BLoC dari Riverpod!**

#### BLoC Events

```dart
// presentation/bloc/{feature_name}_event.dart
part of '{feature_name}_bloc.dart';

/// Sealed class untuk semua {FeatureName} events.
/// Setiap event = satu aksi user/system yang bisa di-trace via BlocObserver.
sealed class {FeatureName}Event extends Equatable {
  const {FeatureName}Event();

  @override
  List<Object?> get props => [];
}

/// Load semua {featureName}s
final class Load{FeatureName}s extends {FeatureName}Event {
  const Load{FeatureName}s();
}

/// Load single {featureName} by ID
final class Load{FeatureName}ById extends {FeatureName}Event {
  final String id;
  const Load{FeatureName}ById(this.id);
  @override
  List<Object?> get props => [id];
}

/// Create {featureName} baru
final class Create{FeatureName}Event extends {FeatureName}Event {
  final String name;
  final String? description;
  const Create{FeatureName}Event({required this.name, this.description});
  @override
  List<Object?> get props => [name, description];
}

/// Update {featureName}
final class Update{FeatureName}Event extends {FeatureName}Event {
  final {FeatureName} {featureName};
  const Update{FeatureName}Event(this.{featureName});
  @override
  List<Object?> get props => [{featureName}];
}

/// Delete {featureName}
final class Delete{FeatureName}Event extends {FeatureName}Event {
  final String id;
  const Delete{FeatureName}Event(this.id);
  @override
  List<Object?> get props => [id];
}

/// Refresh (re-fetch dari server)
final class Refresh{FeatureName}s extends {FeatureName}Event {
  const Refresh{FeatureName}s();
}
```

#### BLoC States

```dart
// presentation/bloc/{feature_name}_state.dart
part of '{feature_name}_bloc.dart';

/// Sealed class untuk semua {FeatureName} states.
///
/// State flow:
///   Initial -> Loading -> Loaded / Error
///   Loaded -> Loading (refresh) -> Loaded / Error
///   Loaded -> {FeatureName}Created (side effect) -> Loaded (via BlocListener)
///   Loaded -> {FeatureName}Deleted (side effect) -> Loaded (via BlocListener)
sealed class {FeatureName}State extends Equatable {
  const {FeatureName}State();

  @override
  List<Object?> get props => [];
}

/// State awal
final class {FeatureName}Initial extends {FeatureName}State {
  const {FeatureName}Initial();
}

/// Sedang loading
final class {FeatureName}Loading extends {FeatureName}State {
  const {FeatureName}Loading();
}

/// List berhasil di-load
final class {FeatureName}Loaded extends {FeatureName}State {
  final List<{FeatureName}> {featureName}s;
  const {FeatureName}Loaded(this.{featureName}s);
  bool get isEmpty => {featureName}s.isEmpty;
  @override
  List<Object?> get props => [{featureName}s];
}

/// Error saat load
final class {FeatureName}Error extends {FeatureName}State {
  final String message;
  const {FeatureName}Error(this.message);
  @override
  List<Object?> get props => [message];
}

// === Side Effect States (ditangkap BlocListener) ===

/// Create berhasil — trigger snackbar via BlocListener
final class {FeatureName}Created extends {FeatureName}State {
  final {FeatureName} {featureName};
  final List<{FeatureName}> updated{FeatureName}s;
  const {FeatureName}Created({
    required this.{featureName},
    required this.updated{FeatureName}s,
  });
  @override
  List<Object?> get props => [{featureName}, updated{FeatureName}s];
}

/// Update berhasil
final class {FeatureName}Updated extends {FeatureName}State {
  final {FeatureName} {featureName};
  final List<{FeatureName}> updated{FeatureName}s;
  const {FeatureName}Updated({
    required this.{featureName},
    required this.updated{FeatureName}s,
  });
  @override
  List<Object?> get props => [{featureName}, updated{FeatureName}s];
}

/// Delete berhasil
final class {FeatureName}Deleted extends {FeatureName}State {
  final String deletedId;
  final List<{FeatureName}> updated{FeatureName}s;
  const {FeatureName}Deleted({
    required this.deletedId,
    required this.updated{FeatureName}s,
  });
  @override
  List<Object?> get props => [deletedId, updated{FeatureName}s];
}

/// Error saat CUD operation (preserve data)
final class {FeatureName}OperationError extends {FeatureName}State {
  final String message;
  final List<{FeatureName}> current{FeatureName}s;
  const {FeatureName}OperationError({
    required this.message,
    required this.current{FeatureName}s,
  });
  @override
  List<Object?> get props => [message, current{FeatureName}s];
}

/// Single item di-load (detail screen)
final class {FeatureName}DetailLoaded extends {FeatureName}State {
  final {FeatureName} {featureName};
  const {FeatureName}DetailLoaded(this.{featureName});
  @override
  List<Object?> get props => [{featureName}];
}
```

#### BLoC Implementation

```dart
// presentation/bloc/{feature_name}_bloc.dart
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/usecase/usecase.dart';
import '../../domain/entities/{feature_name}_entity.dart';
import '../../domain/usecases/create_{feature_name}.dart';
import '../../domain/usecases/delete_{feature_name}.dart';
import '../../domain/usecases/get_{feature_name}_by_id.dart';
import '../../domain/usecases/get_{feature_name}s.dart';
import '../../domain/usecases/update_{feature_name}.dart';

part '{feature_name}_event.dart';
part '{feature_name}_state.dart';

@injectable
class {FeatureName}Bloc extends Bloc<{FeatureName}Event, {FeatureName}State> {
  final Get{FeatureName}s _get{FeatureName}s;
  final Get{FeatureName}ById _get{FeatureName}ById;
  final Create{FeatureName} _create{FeatureName};
  final Update{FeatureName} _update{FeatureName};
  final Delete{FeatureName} _delete{FeatureName};

  {FeatureName}Bloc({
    required Get{FeatureName}s get{FeatureName}s,
    required Get{FeatureName}ById get{FeatureName}ById,
    required Create{FeatureName} create{FeatureName},
    required Update{FeatureName} update{FeatureName},
    required Delete{FeatureName} delete{FeatureName},
  })  : _get{FeatureName}s = get{FeatureName}s,
        _get{FeatureName}ById = get{FeatureName}ById,
        _create{FeatureName} = create{FeatureName},
        _update{FeatureName} = update{FeatureName},
        _delete{FeatureName} = delete{FeatureName},
        super(const {FeatureName}Initial()) {
    on<Load{FeatureName}s>(_onLoad{FeatureName}s);
    on<Load{FeatureName}ById>(_onLoad{FeatureName}ById);
    on<Create{FeatureName}Event>(_onCreate{FeatureName});
    on<Update{FeatureName}Event>(_onUpdate{FeatureName});
    on<Delete{FeatureName}Event>(_onDelete{FeatureName});
    on<Refresh{FeatureName}s>(_onRefresh{FeatureName}s);
  }

  // Cache current list untuk optimistic updates
  List<{FeatureName}> _current{FeatureName}s = [];

  Future<void> _onLoad{FeatureName}s(
    Load{FeatureName}s event,
    Emitter<{FeatureName}State> emit,
  ) async {
    emit(const {FeatureName}Loading());
    final result = await _get{FeatureName}s();
    result.fold(
      (f) => emit({FeatureName}Error(f.message)),
      (items) {
        _current{FeatureName}s = items;
        emit({FeatureName}Loaded(items));
      },
    );
  }

  Future<void> _onLoad{FeatureName}ById(
    Load{FeatureName}ById event,
    Emitter<{FeatureName}State> emit,
  ) async {
    emit(const {FeatureName}Loading());
    final result = await _get{FeatureName}ById(
      Get{FeatureName}ByIdParams(id: event.id),
    );
    result.fold(
      (f) => emit({FeatureName}Error(f.message)),
      (item) => emit({FeatureName}DetailLoaded(item)),
    );
  }

  Future<void> _onCreate{FeatureName}(
    Create{FeatureName}Event event,
    Emitter<{FeatureName}State> emit,
  ) async {
    final newItem = {FeatureName}(
      id: '',
      name: event.name,
      description: event.description,
      createdAt: DateTime.now(),
    );
    final result = await _create{FeatureName}(newItem);
    result.fold(
      (f) => emit({FeatureName}OperationError(
        message: f.message,
        current{FeatureName}s: _current{FeatureName}s,
      )),
      (created) {
        _current{FeatureName}s = [..._current{FeatureName}s, created];
        // Emit side-effect state terlebih dahulu (untuk BlocListener)
        emit({FeatureName}Created(
          {featureName}: created,
          updated{FeatureName}s: _current{FeatureName}s,
        ));
        // Lalu kembali ke Loaded state
        emit({FeatureName}Loaded(_current{FeatureName}s));
      },
    );
  }

  Future<void> _onUpdate{FeatureName}(
    Update{FeatureName}Event event,
    Emitter<{FeatureName}State> emit,
  ) async {
    final result = await _update{FeatureName}(event.{featureName});
    result.fold(
      (f) => emit({FeatureName}OperationError(
        message: f.message,
        current{FeatureName}s: _current{FeatureName}s,
      )),
      (updated) {
        _current{FeatureName}s = _current{FeatureName}s
            .map((item) => item.id == updated.id ? updated : item)
            .toList();
        emit({FeatureName}Updated(
          {featureName}: updated,
          updated{FeatureName}s: _current{FeatureName}s,
        ));
        emit({FeatureName}Loaded(_current{FeatureName}s));
      },
    );
  }

  Future<void> _onDelete{FeatureName}(
    Delete{FeatureName}Event event,
    Emitter<{FeatureName}State> emit,
  ) async {
    final result = await _delete{FeatureName}(
      Delete{FeatureName}Params(id: event.id),
    );
    result.fold(
      (f) => emit({FeatureName}OperationError(
        message: f.message,
        current{FeatureName}s: _current{FeatureName}s,
      )),
      (_) {
        _current{FeatureName}s =
            _current{FeatureName}s.where((item) => item.id != event.id).toList();
        emit({FeatureName}Deleted(
          deletedId: event.id,
          updated{FeatureName}s: _current{FeatureName}s,
        ));
        emit({FeatureName}Loaded(_current{FeatureName}s));
      },
    );
  }

  Future<void> _onRefresh{FeatureName}s(
    Refresh{FeatureName}s event,
    Emitter<{FeatureName}State> emit,
  ) async {
    final result = await _get{FeatureName}s();
    result.fold(
      (f) => emit({FeatureName}Error(f.message)),
      (items) {
        _current{FeatureName}s = items;
        emit({FeatureName}Loaded(items));
      },
    );
  }
}
```

### Step 5: Generate Presentation Layer — Screens

#### List Screen

```dart
// presentation/screens/{feature_name}_list_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/router/routes.dart';
import '../bloc/{feature_name}_bloc.dart';
import '../widgets/{feature_name}_list_item.dart';
import '../widgets/{feature_name}_shimmer.dart';

/// {FeatureName}ListScreen: provide BlocProvider di sini (bukan di MultiBlocProvider root)
class {FeatureName}ListScreen extends StatelessWidget {
  const {FeatureName}ListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<{FeatureName}Bloc>()..add(const Load{FeatureName}s()),
      child: const _{FeatureName}ListView(),
    );
  }
}

class _{FeatureName}ListView extends StatelessWidget {
  const _{FeatureName}ListView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('{FeatureName}s'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<{FeatureName}Bloc>().add(const Refresh{FeatureName}s());
            },
          ),
        ],
      ),
      // BlocConsumer = BlocListener (side effects) + BlocBuilder (UI)
      body: BlocConsumer<{FeatureName}Bloc, {FeatureName}State>(
        // listener: tangkap side-effect states (Create/Update/Delete success/error)
        listener: (context, state) {
          switch (state) {
            case {FeatureName}Created(:final {featureName}):
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${featureName}.name} berhasil dibuat!'),
                  backgroundColor: Colors.green,
                ),
              );
            case {FeatureName}Deleted():
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('{FeatureName} berhasil dihapus!'),
                  backgroundColor: Colors.orange,
                ),
              );
            case {FeatureName}Updated(:final {featureName}):
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${featureName}.name} berhasil diupdate!'),
                  backgroundColor: Colors.blue,
                ),
              );
            case {FeatureName}OperationError(:final message):
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
        // builder: render UI berdasarkan state
        builder: (context, state) {
          return switch (state) {
            {FeatureName}Initial() => const Center(
                child: Text('Tap refresh untuk memuat data'),
              ),
            {FeatureName}Loading() => const {FeatureName}ListShimmer(),
            {FeatureName}Loaded(:final {featureName}s) =>
              _buildList(context, {featureName}s),
            {FeatureName}Error(:final message) => _buildError(context, message),
            {FeatureName}Created(:final updated{FeatureName}s) =>
              _buildList(context, updated{FeatureName}s),
            {FeatureName}Updated(:final updated{FeatureName}s) =>
              _buildList(context, updated{FeatureName}s),
            {FeatureName}Deleted(:final updated{FeatureName}s) =>
              _buildList(context, updated{FeatureName}s),
            {FeatureName}OperationError(:final current{FeatureName}s) =>
              _buildList(context, current{FeatureName}s),
            {FeatureName}DetailLoaded() => const SizedBox.shrink(),
          };
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildList(BuildContext context, List<{FeatureName}> items) {
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Belum ada {featureName}',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: () => _showCreateDialog(context),
              icon: const Icon(Icons.add),
              label: const Text('Tambah {FeatureName}'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        context.read<{FeatureName}Bloc>().add(const Refresh{FeatureName}s());
      },
      child: ListView.builder(
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return {FeatureName}ListItem(
            {featureName}: item,
            onTap: () => context.push(AppRoutes.{featureName}DetailPath(item.id)),
            onDelete: () => _confirmDelete(context, item.id),
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
          Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
          const SizedBox(height: 16),
          Text('Error: $message', textAlign: TextAlign.center),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              context.read<{FeatureName}Bloc>().add(const Load{FeatureName}s());
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Coba Lagi'),
          ),
        ],
      ),
    );
  }

  void _showCreateDialog(BuildContext context) {
    final nameController = TextEditingController();
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Tambah {FeatureName}'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(
            labelText: 'Nama',
            hintText: 'Masukkan nama {featureName}',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isNotEmpty) {
                context.read<{FeatureName}Bloc>().add(
                  Create{FeatureName}Event(name: nameController.text),
                );
                Navigator.pop(dialogContext);
              }
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, String id) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Hapus {FeatureName}'),
        content: const Text('Yakin ingin menghapus {featureName} ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              context.read<{FeatureName}Bloc>().add(Delete{FeatureName}Event(id));
              Navigator.pop(dialogContext);
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
```

#### Detail Screen

```dart
// presentation/screens/{feature_name}_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection.dart';
import '../bloc/{feature_name}_bloc.dart';

class {FeatureName}DetailScreen extends StatelessWidget {
  final String {featureName}Id;

  const {FeatureName}DetailScreen({super.key, required this.{featureName}Id});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          getIt<{FeatureName}Bloc>()..add(Load{FeatureName}ById({featureName}Id)),
      child: Scaffold(
        appBar: AppBar(title: const Text('{FeatureName} Detail')),
        body: BlocBuilder<{FeatureName}Bloc, {FeatureName}State>(
          builder: (context, state) {
            return switch (state) {
              {FeatureName}Loading() =>
                const Center(child: CircularProgressIndicator()),
              {FeatureName}DetailLoaded(:final {featureName}) =>
                _buildDetail(context, {featureName}),
              {FeatureName}Error(:final message) =>
                Center(child: Text('Error: $message')),
              _ => const SizedBox.shrink(),
            };
          },
        ),
      ),
    );
  }

  Widget _buildDetail(BuildContext context, {FeatureName} {featureName}) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            {featureName}.name,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          if ({featureName}.description != null) ...[
            Text(
              {featureName}.description!,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 16),
          ],
          Chip(
            label: Text({featureName}.isActive ? 'Aktif' : 'Nonaktif'),
            backgroundColor:
                {featureName}.isActive ? Colors.green[100] : Colors.red[100],
          ),
          const SizedBox(height: 8),
          Text(
            'Dibuat: ${featureName}.createdAt.toLocal()}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
```

### Step 6: Generate Widgets

#### List Item

```dart
// presentation/widgets/{feature_name}_list_item.dart
import 'package:flutter/material.dart';
import '../../domain/entities/{feature_name}_entity.dart';

class {FeatureName}ListItem extends StatelessWidget {
  final {FeatureName} {featureName};
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const {FeatureName}ListItem({
    super.key,
    required this.{featureName},
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          child: Text({featureName}.name[0].toUpperCase()),
        ),
        title: Text({featureName}.name),
        subtitle: {featureName}.description != null
            ? Text(
                {featureName}.description!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              )
            : null,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!{featureName}.isActive)
              const Icon(Icons.block, color: Colors.red, size: 16),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: onDelete,
            ),
          ],
        ),
        onTap: onTap,
      ),
    );
  }
}
```

#### Shimmer Loading

```dart
// presentation/widgets/{feature_name}_shimmer.dart
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class {FeatureName}ListShimmer extends StatelessWidget {
  const {FeatureName}ListShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 8,
      itemBuilder: (context, index) => const _{FeatureName}ListItemShimmer(),
    );
  }
}

class _{FeatureName}ListItemShimmer extends StatelessWidget {
  const _{FeatureName}ListItemShimmer();

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: ListTile(
        leading: Container(
          width: 48,
          height: 48,
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
        ),
        title: Container(height: 16, color: Colors.white),
        subtitle: Container(
          height: 12,
          margin: const EdgeInsets.only(top: 8),
          color: Colors.white,
        ),
      ),
    );
  }
}
```

### Step 7: Register Routes

```dart
// STEP 1: Update lib/core/router/routes.dart
class AppRoutes {
  // ... existing routes ...

  // {FeatureName} routes
  static const String {featureName}s = '/{featureName}s';
  static const String {featureName}Detail = '/{featureName}s/:id';
  static const String {featureName}Create = '/{featureName}s/create';

  static String {featureName}DetailPath(String id) => '/{featureName}s/$id';
}

// STEP 2: Add GoRoute to app_router.dart
GoRoute(
  path: AppRoutes.{featureName}s,
  builder: (context, state) => const {FeatureName}ListScreen(),
  routes: [
    GoRoute(
      path: 'create',
      builder: (context, state) => BlocProvider(
        create: (_) => getIt<{FeatureName}Bloc>(),
        child: const {FeatureName}CreateScreen(),
      ),
    ),
    GoRoute(
      path: ':id',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return {FeatureName}DetailScreen({featureName}Id: id);
      },
    ),
  ],
),
```

### Step 8: Run Code Generation

```bash
dart run build_runner build --delete-conflicting-outputs
```

### Step 9: Write BLoC Tests

```dart
// test/features/{feature_name}/presentation/bloc/{feature_name}_bloc_test.dart
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockGet{FeatureName}s extends Mock implements Get{FeatureName}s {}
class MockCreate{FeatureName} extends Mock implements Create{FeatureName} {}
class MockDelete{FeatureName} extends Mock implements Delete{FeatureName} {}

void main() {
  late {FeatureName}Bloc bloc;
  late MockGet{FeatureName}s mockGet{FeatureName}s;

  setUp(() {
    mockGet{FeatureName}s = MockGet{FeatureName}s();
    bloc = {FeatureName}Bloc(
      get{FeatureName}s: mockGet{FeatureName}s,
      get{FeatureName}ById: MockGet{FeatureName}ById(),
      create{FeatureName}: MockCreate{FeatureName}(),
      update{FeatureName}: MockUpdate{FeatureName}(),
      delete{FeatureName}: MockDelete{FeatureName}(),
    );
  });

  tearDown(() => bloc.close());

  group('Load{FeatureName}s', () {
    blocTest<{FeatureName}Bloc, {FeatureName}State>(
      'emits [Loading, Loaded] when success',
      build: () {
        when(() => mockGet{FeatureName}s())
            .thenAnswer((_) async => Success([]));
        return bloc;
      },
      act: (bloc) => bloc.add(const Load{FeatureName}s()),
      expect: () => [
        const {FeatureName}Loading(),
        const {FeatureName}Loaded([]),
      ],
    );

    blocTest<{FeatureName}Bloc, {FeatureName}State>(
      'emits [Loading, Error] when failure',
      build: () {
        when(() => mockGet{FeatureName}s()).thenAnswer(
          (_) async => const ResultFailure(ServerFailure(message: 'Error')),
        );
        return bloc;
      },
      act: (bloc) => bloc.add(const Load{FeatureName}s()),
      expect: () => [
        const {FeatureName}Loading(),
        const {FeatureName}Error('Error'),
      ],
    );
  });
}
```


## Usage Example: Todo Feature

Untuk generate feature bernama `Todo`, replace semua placeholder:
- `{FeatureName}` → `Todo`
- `{featureName}` → `todo`
- `{feature_name}` → `todo`

Contoh BLoC Todo selesai dapat dilihat di `examples/todo/` folder.


## Success Criteria

- [ ] Feature structure mengikuti Clean Architecture
- [ ] Semua file ter-generate tanpa error
- [ ] `dartz` tidak digunakan — pakai `Result<T>` sealed class
- [ ] BLoC events didefinisikan sebagai `sealed class` + `final class`
- [ ] BLoC states dibagi: loading/loaded/error + side-effect states
- [ ] `BlocConsumer` digunakan untuk list screen (listener + builder)
- [ ] Pattern matching exhaustive pada state di `builder`
- [ ] `BlocProvider` di level screen (bukan di root MultiBlocProvider)
- [ ] Routes registered di `routes.dart` + `app_router.dart`
- [ ] Shimmer loading implemented
- [ ] Code generation: `dart run build_runner build -d` sukses
- [ ] `flutter analyze` tidak ada error
- [ ] BLoC tests passing dengan `bloc_test`


## Next Steps

Setelah generate feature:
1. Connect ke backend → `03_backend_integration.md`
2. Tambah tests → `06_testing_production.md`

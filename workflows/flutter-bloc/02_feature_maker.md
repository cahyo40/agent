# Workflow: Flutter BLoC Feature Maker

## Overview

Generate feature baru dengan struktur Clean Architecture lengkap menggunakan **flutter_bloc**. Workflow ini membuat boilerplate code untuk feature baru termasuk entity, model, repository, use case, **BLoC (events + states)**, dan screen dengan `BlocConsumer`.

Perbedaan utama dengan Riverpod version:
- State management menggunakan `Bloc<Event, State>` atau `Cubit<State>`
- Events dan States didefinisikan sebagai **sealed class** (Dart 3)
- Side effects ditangani via `BlocListener`
- DI menggunakan `get_it` + `injectable` (bukan Riverpod providers)
- Pattern matching pada state di `BlocBuilder`

## Output Location

**Base Folder:** `sdlc/flutter-bloc/02-feature-maker/`

**Output Files:**
- `feature-template.md` - Panduan menggunakan template
- `feature-generator-script.md` - Script/logika untuk generate feature
- `templates/` - Template files untuk setiap layer
  - `domain/` - Entity, repository, use case templates
  - `data/` - Model, repository impl, data source templates
  - `presentation/` - BLoC, screen, widget templates
- `examples/` - Contoh feature yang sudah jadi (Todo)

## Prerequisites

- Project setup dari `01_project_setup.md` selesai
- Clean Architecture structure sudah ada
- Dependencies sudah terinstall:
  - `flutter_bloc` / `bloc`
  - `equatable`
  - `get_it` + `injectable` + `injectable_generator`
  - `freezed` + `freezed_annotation` (optional, untuk events/states)
  - `go_router`
  - `dartz` (untuk Either)
  - `dio` (HTTP client)
  - `shimmer`

## Feature Folder Structure

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

## Placeholder Convention

Gunakan placeholder berikut saat generate feature. Replace semua sebelum dipakai:

| Placeholder | Contoh (Todo) | Keterangan |
|---|---|---|
| `{FeatureName}` | `Todo` | PascalCase |
| `{featureName}` | `todo` | camelCase |
| `{feature_name}` | `todo` | snake_case |
| `{FEATURE_NAME}` | `TODO` | UPPER_CASE |
| `{feature-name}` | `todo` | kebab-case |

---

## Deliverables

### 1. Entity (Domain Layer)

**Description:** Entity class dengan Equatable untuk value equality.

**Recommended Skills:** `senior-flutter-developer`

**Template: `domain/entities/{feature_name}_entity.dart`**
```dart
import 'package:equatable/equatable.dart';

/// Domain entity untuk {FeatureName}.
/// Representasi data murni tanpa dependency ke framework/library.
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

  /// Factory untuk create baru (id belum ada)
  factory {FeatureName}.create({
    required String name,
    String? description,
  }) {
    return {FeatureName}(
      id: '', // akan di-assign oleh backend
      name: name,
      description: description,
      createdAt: DateTime.now(),
    );
  }

  /// CopyWith untuk immutable update
  {FeatureName} copyWith({
    String? id,
    String? name,
    String? description,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return {FeatureName}(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [id, name, description, isActive, createdAt, updatedAt];

  @override
  String toString() => '{FeatureName}(id: $id, name: $name, isActive: $isActive)';
}
```

---

### 2. Repository Contract (Domain Layer)

**Description:** Abstract class yang define contract antara domain dan data layer. Menggunakan `Either<Failure, T>` dari dartz.

**Template: `domain/repositories/{feature_name}_repository.dart`**
```dart
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/{feature_name}_entity.dart';

/// Repository contract untuk {FeatureName}.
/// Domain layer hanya tau interface ini, tidak tau implementasinya.
abstract class {FeatureName}Repository {
  /// Ambil semua {featureName}s
  Future<Either<Failure, List<{FeatureName}>>> get{FeatureName}s();

  /// Ambil {featureName} berdasarkan ID
  Future<Either<Failure, {FeatureName}>> get{FeatureName}ById(String id);

  /// Buat {featureName} baru
  Future<Either<Failure, {FeatureName}>> create{FeatureName}({FeatureName} {featureName});

  /// Update {featureName} yang ada
  Future<Either<Failure, {FeatureName}>> update{FeatureName}({FeatureName} {featureName});

  /// Hapus {featureName} berdasarkan ID
  Future<Either<Failure, Unit>> delete{FeatureName}(String id);
}
```

---

### 3. Use Cases (Domain Layer)

**Description:** Use case classes. Setiap use case punya satu responsibility (Single Responsibility Principle). Extend dari base `UseCase<Type, Params>`.

**Base UseCase:**
```dart
// lib/core/usecases/usecase.dart
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../error/failures.dart';

abstract class UseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}

class NoParams extends Equatable {
  const NoParams();
  @override
  List<Object?> get props => [];
}
```

**Template: `domain/usecases/get_{feature_name}s.dart`**
```dart
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/{feature_name}_entity.dart';
import '../repositories/{feature_name}_repository.dart';

@injectable
class Get{FeatureName}s implements UseCase<List<{FeatureName}>, NoParams> {
  final {FeatureName}Repository repository;

  Get{FeatureName}s(this.repository);

  @override
  Future<Either<Failure, List<{FeatureName}>>> call(NoParams params) {
    return repository.get{FeatureName}s();
  }
}
```

**Template: `domain/usecases/get_{feature_name}_by_id.dart`**
```dart
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/{feature_name}_entity.dart';
import '../repositories/{feature_name}_repository.dart';

@injectable
class Get{FeatureName}ById implements UseCase<{FeatureName}, Get{FeatureName}ByIdParams> {
  final {FeatureName}Repository repository;

  Get{FeatureName}ById(this.repository);

  @override
  Future<Either<Failure, {FeatureName}>> call(Get{FeatureName}ByIdParams params) {
    return repository.get{FeatureName}ById(params.id);
  }
}

class Get{FeatureName}ByIdParams extends Equatable {
  final String id;
  const Get{FeatureName}ByIdParams({required this.id});
  @override
  List<Object?> get props => [id];
}
```

**Template: `domain/usecases/create_{feature_name}.dart`**
```dart
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/{feature_name}_entity.dart';
import '../repositories/{feature_name}_repository.dart';

@injectable
class Create{FeatureName} implements UseCase<{FeatureName}, {FeatureName}> {
  final {FeatureName}Repository repository;

  Create{FeatureName}(this.repository);

  @override
  Future<Either<Failure, {FeatureName}>> call({FeatureName} {featureName}) {
    return repository.create{FeatureName}({featureName});
  }
}
```

**Template: `domain/usecases/update_{feature_name}.dart`**
```dart
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/{feature_name}_entity.dart';
import '../repositories/{feature_name}_repository.dart';

@injectable
class Update{FeatureName} implements UseCase<{FeatureName}, {FeatureName}> {
  final {FeatureName}Repository repository;

  Update{FeatureName}(this.repository);

  @override
  Future<Either<Failure, {FeatureName}>> call({FeatureName} {featureName}) {
    return repository.update{FeatureName}({featureName});
  }
}
```

**Template: `domain/usecases/delete_{feature_name}.dart`**
```dart
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/{feature_name}_repository.dart';

@injectable
class Delete{FeatureName} implements UseCase<Unit, Delete{FeatureName}Params> {
  final {FeatureName}Repository repository;

  Delete{FeatureName}(this.repository);

  @override
  Future<Either<Failure, Unit>> call(Delete{FeatureName}Params params) {
    return repository.delete{FeatureName}(params.id);
  }
}

class Delete{FeatureName}Params extends Equatable {
  final String id;
  const Delete{FeatureName}Params({required this.id});
  @override
  List<Object?> get props => [id];
}
```

---

### 4. Model (Data Layer)

**Description:** Data model dengan JSON serialization. Dua opsi: manual atau freezed.

**Opsi A - Manual (tanpa freezed):**

**Template: `data/models/{feature_name}_model.dart`**
```dart
import '../../domain/entities/{feature_name}_entity.dart';

class {FeatureName}Model {
  final String id;
  final String name;
  final String? description;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const {FeatureName}Model({
    required this.id,
    required this.name,
    this.description,
    this.isActive = true,
    required this.createdAt,
    this.updatedAt,
  });

  /// Parse dari JSON (API response)
  factory {FeatureName}Model.fromJson(Map<String, dynamic> json) {
    return {FeatureName}Model(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  /// Convert ke JSON (request body)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  /// Convert model ke domain entity
  {FeatureName} toEntity() {
    return {FeatureName}(
      id: id,
      name: name,
      description: description,
      isActive: isActive,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  /// Create model dari domain entity
  factory {FeatureName}Model.fromEntity({FeatureName} entity) {
    return {FeatureName}Model(
      id: entity.id,
      name: entity.name,
      description: entity.description,
      isActive: entity.isActive,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }
}
```

**Opsi B - Dengan freezed:**
```dart
import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/{feature_name}_entity.dart';

part '{feature_name}_model.freezed.dart';
part '{feature_name}_model.g.dart';

@freezed
class {FeatureName}Model with _${FeatureName}Model {
  const {FeatureName}Model._(); // private constructor untuk custom methods

  const factory {FeatureName}Model({
    required String id,
    required String name,
    String? description,
    @JsonKey(name: 'is_active') @Default(true) bool isActive,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
  }) = _{FeatureName}Model;

  factory {FeatureName}Model.fromJson(Map<String, dynamic> json) =>
      _${FeatureName}ModelFromJson(json);

  /// Convert ke domain entity
  {FeatureName} toEntity() {
    return {FeatureName}(
      id: id,
      name: name,
      description: description,
      isActive: isActive,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  factory {FeatureName}Model.fromEntity({FeatureName} entity) {
    return {FeatureName}Model(
      id: entity.id,
      name: entity.name,
      description: entity.description,
      isActive: entity.isActive,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }
}
```

---

### 5. Data Source (Data Layer)

**Template: `data/datasources/{feature_name}_remote_ds.dart`**
```dart
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
    final response = await dio.put(
      '$_basePath/${model.id}',
      data: model.toJson(),
    );
    return {FeatureName}Model.fromJson(response.data['data']);
  }

  @override
  Future<void> delete{FeatureName}(String id) async {
    await dio.delete('$_basePath/$id');
  }
}
```

**Template: `data/datasources/{feature_name}_local_ds.dart`**
```dart
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/{feature_name}_model.dart';

abstract class {FeatureName}LocalDataSource {
  Future<List<{FeatureName}Model>> getCached{FeatureName}s();
  Future<void> cache{FeatureName}s(List<{FeatureName}Model> models);
  Future<void> clearCache();
}

@LazySingleton(as: {FeatureName}LocalDataSource)
class {FeatureName}LocalDataSourceImpl implements {FeatureName}LocalDataSource {
  final SharedPreferences prefs;
  static const String _cacheKey = 'cached_{feature_name}s';

  {FeatureName}LocalDataSourceImpl(this.prefs);

  @override
  Future<List<{FeatureName}Model>> getCached{FeatureName}s() async {
    final jsonString = prefs.getString(_cacheKey);
    if (jsonString == null) return [];

    final List<dynamic> jsonList = json.decode(jsonString);
    return jsonList.map((j) => {FeatureName}Model.fromJson(j)).toList();
  }

  @override
  Future<void> cache{FeatureName}s(List<{FeatureName}Model> models) async {
    final jsonList = models.map((m) => m.toJson()).toList();
    await prefs.setString(_cacheKey, json.encode(jsonList));
  }

  @override
  Future<void> clearCache() async {
    await prefs.remove(_cacheKey);
  }
}
```

---

### 6. Repository Implementation (Data Layer)

**Template: `data/repositories/{feature_name}_repository_impl.dart`**
```dart
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/{feature_name}_entity.dart';
import '../../domain/repositories/{feature_name}_repository.dart';
import '../datasources/{feature_name}_local_ds.dart';
import '../datasources/{feature_name}_remote_ds.dart';
import '../models/{feature_name}_model.dart';

@LazySingleton(as: {FeatureName}Repository)
class {FeatureName}RepositoryImpl implements {FeatureName}Repository {
  final {FeatureName}RemoteDataSource remoteDataSource;
  final {FeatureName}LocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  {FeatureName}RepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<{FeatureName}>>> get{FeatureName}s() async {
    if (await networkInfo.isConnected) {
      try {
        final models = await remoteDataSource.get{FeatureName}s();
        await localDataSource.cache{FeatureName}s(models);
        return Right(models.map((m) => m.toEntity()).toList());
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      }
    } else {
      try {
        final cached = await localDataSource.getCached{FeatureName}s();
        return Right(cached.map((m) => m.toEntity()).toList());
      } on CacheException catch (e) {
        return Left(CacheFailure(e.message));
      }
    }
  }

  @override
  Future<Either<Failure, {FeatureName}>> get{FeatureName}ById(String id) async {
    try {
      final model = await remoteDataSource.get{FeatureName}ById(id);
      return Right(model.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, {FeatureName}>> create{FeatureName}({FeatureName} {featureName}) async {
    try {
      final model = {FeatureName}Model.fromEntity({featureName});
      final result = await remoteDataSource.create{FeatureName}(model);
      return Right(result.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, {FeatureName}>> update{FeatureName}({FeatureName} {featureName}) async {
    try {
      final model = {FeatureName}Model.fromEntity({featureName});
      final result = await remoteDataSource.update{FeatureName}(model);
      return Right(result.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, Unit>> delete{FeatureName}(String id) async {
    try {
      await remoteDataSource.delete{FeatureName}(id);
      return const Right(unit);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }
}
```

---

### 7. BLoC Events (Presentation Layer)

**Description:** Sealed class untuk semua event yang bisa terjadi pada feature ini. Gunakan sealed class Dart 3 untuk exhaustive pattern matching.

**Template: `presentation/bloc/{feature_name}_event.dart`**
```dart
part of '{feature_name}_bloc.dart';

/// Sealed class untuk semua {FeatureName} events.
/// Setiap event merepresentasikan satu aksi dari user atau system.
sealed class {FeatureName}Event extends Equatable {
  const {FeatureName}Event();

  @override
  List<Object?> get props => [];
}

/// Load semua {featureName}s dari repository
final class Load{FeatureName}s extends {FeatureName}Event {
  const Load{FeatureName}s();
}

/// Load single {featureName} berdasarkan ID
final class Load{FeatureName}ById extends {FeatureName}Event {
  final String id;
  const Load{FeatureName}ById(this.id);

  @override
  List<Object?> get props => [id];
}

/// Buat {featureName} baru
final class Create{FeatureName}Event extends {FeatureName}Event {
  final String name;
  final String? description;

  const Create{FeatureName}Event({
    required this.name,
    this.description,
  });

  @override
  List<Object?> get props => [name, description];
}

/// Update {featureName} yang ada
final class Update{FeatureName}Event extends {FeatureName}Event {
  final {FeatureName} {featureName};

  const Update{FeatureName}Event(this.{featureName});

  @override
  List<Object?> get props => [{featureName}];
}

/// Hapus {featureName} berdasarkan ID
final class Delete{FeatureName}Event extends {FeatureName}Event {
  final String id;

  const Delete{FeatureName}Event(this.id);

  @override
  List<Object?> get props => [id];
}

/// Refresh data (re-fetch dari server)
final class Refresh{FeatureName}s extends {FeatureName}Event {
  const Refresh{FeatureName}s();
}
```

---

### 8. BLoC States (Presentation Layer)

**Description:** Sealed class untuk semua state yang mungkin. Termasuk state khusus untuk side effects (Created, Updated, Deleted) yang ditangkap oleh `BlocListener`.

**Template: `presentation/bloc/{feature_name}_state.dart`**
```dart
part of '{feature_name}_bloc.dart';

/// Sealed class untuk semua {FeatureName} states.
///
/// State flow:
///   Initial -> Loading -> Loaded / Error
///   Loaded -> Loading (refresh) -> Loaded / Error
///   Loaded -> {FeatureName}Created (side effect) -> Loaded (list updated)
///   Loaded -> {FeatureName}Deleted (side effect) -> Loaded (list updated)
sealed class {FeatureName}State extends Equatable {
  const {FeatureName}State();

  @override
  List<Object?> get props => [];
}

/// State awal, belum ada data
final class {FeatureName}Initial extends {FeatureName}State {
  const {FeatureName}Initial();
}

/// Sedang loading data
final class {FeatureName}Loading extends {FeatureName}State {
  const {FeatureName}Loading();
}

/// Data berhasil di-load
final class {FeatureName}Loaded extends {FeatureName}State {
  final List<{FeatureName}> {featureName}s;

  const {FeatureName}Loaded(this.{featureName}s);

  /// Helper: check apakah list kosong
  bool get isEmpty => {featureName}s.isEmpty;

  @override
  List<Object?> get props => [{featureName}s];
}

/// Error terjadi saat load data
final class {FeatureName}Error extends {FeatureName}State {
  final String message;

  const {FeatureName}Error(this.message);

  @override
  List<Object?> get props => [message];
}

// ============================================================
// Side Effect States (ditangkap oleh BlocListener, bukan builder)
// ============================================================

/// {FeatureName} berhasil dibuat - trigger snackbar/navigation
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

/// {FeatureName} berhasil di-update
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

/// {FeatureName} berhasil dihapus
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

/// Error saat operasi CUD (Create/Update/Delete) - side effect error
final class {FeatureName}OperationError extends {FeatureName}State {
  final String message;
  final List<{FeatureName}> current{FeatureName}s; // preserve current data

  const {FeatureName}OperationError({
    required this.message,
    required this.current{FeatureName}s,
  });

  @override
  List<Object?> get props => [message, current{FeatureName}s];
}

// ============================================================
// Detail States (untuk detail screen)
// ============================================================

/// Single {featureName} berhasil di-load
final class {FeatureName}DetailLoaded extends {FeatureName}State {
  final {FeatureName} {featureName};

  const {FeatureName}DetailLoaded(this.{featureName});

  @override
  List<Object?> get props => [{featureName}];
}
```

---

### 9. BLoC (Presentation Layer)

**Description:** BLoC class yang menangani semua events dan emit states. Setiap event di-handle oleh method `on<Event>` yang memanggil use case dari domain layer.

**Template: `presentation/bloc/{feature_name}_bloc.dart`**
```dart
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/usecases/usecase.dart';
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
    // Register event handlers
    on<Load{FeatureName}s>(_onLoad{FeatureName}s);
    on<Load{FeatureName}ById>(_onLoad{FeatureName}ById);
    on<Create{FeatureName}Event>(_onCreate{FeatureName});
    on<Update{FeatureName}Event>(_onUpdate{FeatureName});
    on<Delete{FeatureName}Event>(_onDelete{FeatureName});
    on<Refresh{FeatureName}s>(_onRefresh{FeatureName}s);
  }

  /// Daftar {featureName} yang sedang di-hold (untuk preserve saat side effect)
  List<{FeatureName}> _current{FeatureName}s = [];

  /// Handle: Load semua {featureName}s
  Future<void> _onLoad{FeatureName}s(
    Load{FeatureName}s event,
    Emitter<{FeatureName}State> emit,
  ) async {
    emit(const {FeatureName}Loading());

    final result = await _get{FeatureName}s(const NoParams());

    result.fold(
      (failure) => emit({FeatureName}Error(failure.message)),
      ({featureName}s) {
        _current{FeatureName}s = {featureName}s;
        emit({FeatureName}Loaded({featureName}s));
      },
    );
  }

  /// Handle: Load single {featureName} by ID
  Future<void> _onLoad{FeatureName}ById(
    Load{FeatureName}ById event,
    Emitter<{FeatureName}State> emit,
  ) async {
    emit(const {FeatureName}Loading());

    final result = await _get{FeatureName}ById(
      Get{FeatureName}ByIdParams(id: event.id),
    );

    result.fold(
      (failure) => emit({FeatureName}Error(failure.message)),
      ({featureName}) => emit({FeatureName}DetailLoaded({featureName})),
    );
  }

  /// Handle: Create {featureName} baru
  Future<void> _onCreate{FeatureName}(
    Create{FeatureName}Event event,
    Emitter<{FeatureName}State> emit,
  ) async {
    final new{FeatureName} = {FeatureName}.create(
      name: event.name,
      description: event.description,
    );

    final result = await _create{FeatureName}(new{FeatureName});

    result.fold(
      (failure) => emit({FeatureName}OperationError(
        message: failure.message,
        current{FeatureName}s: _current{FeatureName}s,
      )),
      (created) {
        _current{FeatureName}s = [..._current{FeatureName}s, created];
        emit({FeatureName}Created(
          {featureName}: created,
          updated{FeatureName}s: _current{FeatureName}s,
        ));
        // Setelah side effect state, emit Loaded agar builder update
        emit({FeatureName}Loaded(_current{FeatureName}s));
      },
    );
  }

  /// Handle: Update {featureName}
  Future<void> _onUpdate{FeatureName}(
    Update{FeatureName}Event event,
    Emitter<{FeatureName}State> emit,
  ) async {
    final result = await _update{FeatureName}(event.{featureName});

    result.fold(
      (failure) => emit({FeatureName}OperationError(
        message: failure.message,
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

  /// Handle: Delete {featureName}
  Future<void> _onDelete{FeatureName}(
    Delete{FeatureName}Event event,
    Emitter<{FeatureName}State> emit,
  ) async {
    final result = await _delete{FeatureName}(
      Delete{FeatureName}Params(id: event.id),
    );

    result.fold(
      (failure) => emit({FeatureName}OperationError(
        message: failure.message,
        current{FeatureName}s: _current{FeatureName}s,
      )),
      (_) {
        _current{FeatureName}s = _current{FeatureName}s
            .where((item) => item.id != event.id)
            .toList();
        emit({FeatureName}Deleted(
          deletedId: event.id,
          updated{FeatureName}s: _current{FeatureName}s,
        ));
        emit({FeatureName}Loaded(_current{FeatureName}s));
      },
    );
  }

  /// Handle: Refresh (re-fetch dari server)
  Future<void> _onRefresh{FeatureName}s(
    Refresh{FeatureName}s event,
    Emitter<{FeatureName}State> emit,
  ) async {
    // Tidak emit Loading agar UI tidak flash shimmer saat pull-to-refresh
    final result = await _get{FeatureName}s(const NoParams());

    result.fold(
      (failure) => emit({FeatureName}Error(failure.message)),
      ({featureName}s) {
        _current{FeatureName}s = {featureName}s;
        emit({FeatureName}Loaded({featureName}s));
      },
    );
  }
}
```

**Alternatif: Cubit (untuk feature sederhana tanpa complex events)**
```dart
@injectable
class {FeatureName}Cubit extends Cubit<{FeatureName}State> {
  final Get{FeatureName}s _get{FeatureName}s;
  final Create{FeatureName} _create{FeatureName};
  final Delete{FeatureName} _delete{FeatureName};

  {FeatureName}Cubit({
    required Get{FeatureName}s get{FeatureName}s,
    required Create{FeatureName} create{FeatureName},
    required Delete{FeatureName} delete{FeatureName},
  })  : _get{FeatureName}s = get{FeatureName}s,
        _create{FeatureName} = create{FeatureName},
        _delete{FeatureName} = delete{FeatureName},
        super(const {FeatureName}Initial());

  List<{FeatureName}> _items = [];

  Future<void> loadAll() async {
    emit(const {FeatureName}Loading());
    final result = await _get{FeatureName}s(const NoParams());
    result.fold(
      (f) => emit({FeatureName}Error(f.message)),
      (items) {
        _items = items;
        emit({FeatureName}Loaded(items));
      },
    );
  }

  Future<void> create({required String name, String? description}) async {
    final entity = {FeatureName}.create(name: name, description: description);
    final result = await _create{FeatureName}(entity);
    result.fold(
      (f) => emit({FeatureName}OperationError(message: f.message, current{FeatureName}s: _items)),
      (created) {
        _items = [..._items, created];
        emit({FeatureName}Loaded(_items));
      },
    );
  }

  Future<void> delete(String id) async {
    final result = await _delete{FeatureName}(Delete{FeatureName}Params(id: id));
    result.fold(
      (f) => emit({FeatureName}OperationError(message: f.message, current{FeatureName}s: _items)),
      (_) {
        _items = _items.where((item) => item.id != id).toList();
        emit({FeatureName}Loaded(_items));
      },
    );
  }
}
```

---

### 10. List Screen (Presentation Layer)

**Description:** Screen utama yang menampilkan list {featureName}. Menggunakan `BlocConsumer` dengan `listener:` untuk side effects (snackbar, navigation) dan `builder:` untuk render UI berdasarkan state.

**Template: `presentation/screens/{feature_name}_list_screen.dart`**
```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/routes.dart';
import '../../../../injection.dart'; // get_it
import '../bloc/{feature_name}_bloc.dart';
import '../widgets/{feature_name}_list_item.dart';
import '../widgets/{feature_name}_shimmer.dart';

class {FeatureName}ListScreen extends StatelessWidget {
  const {FeatureName}ListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // BlocProvider: inject BLoC dari get_it dan auto-dispose
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
      // BlocConsumer: listener untuk side effects, builder untuk UI
      body: BlocConsumer<{FeatureName}Bloc, {FeatureName}State>(
        // === LISTENER: Side effects (snackbar, dialog, navigation) ===
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
        // === BUILDER: Render UI berdasarkan state ===
        builder: (context, state) {
          return switch (state) {
            {FeatureName}Initial() => const Center(
                child: Text('Tap refresh untuk memuat data'),
              ),
            {FeatureName}Loading() => const {FeatureName}ListShimmer(),
            {FeatureName}Loaded(:final {featureName}s) => _buildList(
                context,
                {featureName}s,
              ),
            {FeatureName}Error(:final message) => _buildError(
                context,
                message,
              ),
            // Side effect states yang juga punya list data
            {FeatureName}Created(:final updated{FeatureName}s) =>
              _buildList(context, updated{FeatureName}s),
            {FeatureName}Updated(:final updated{FeatureName}s) =>
              _buildList(context, updated{FeatureName}s),
            {FeatureName}Deleted(:final updated{FeatureName}s) =>
              _buildList(context, updated{FeatureName}s),
            {FeatureName}OperationError(:final current{FeatureName}s) =>
              _buildList(context, current{FeatureName}s),
            // Detail state: seharusnya tidak muncul di list screen
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

  Widget _buildList(BuildContext context, List<{FeatureName}> {featureName}s) {
    if ({featureName}s.isEmpty) {
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
        itemCount: {featureName}s.length,
        itemBuilder: (context, index) {
          final {featureName} = {featureName}s[index];
          return {FeatureName}ListItem(
            {featureName}: {featureName},
            onTap: () => context.push(
              AppRoutes.{featureName}DetailPath({featureName}.id),
            ),
            onDelete: () => _confirmDelete(context, {featureName}.id),
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
              context.read<{FeatureName}Bloc>().add(
                    Delete{FeatureName}Event(id),
                  );
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

---

### 11. Detail Screen

**Template: `presentation/screens/{feature_name}_detail_screen.dart`**
```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../injection.dart';
import '../../domain/entities/{feature_name}_entity.dart';
import '../bloc/{feature_name}_bloc.dart';

class {FeatureName}DetailScreen extends StatelessWidget {
  final String {featureName}Id;

  const {FeatureName}DetailScreen({super.key, required this.{featureName}Id});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<{FeatureName}Bloc>()
        ..add(Load{FeatureName}ById({featureName}Id)),
      child: Scaffold(
        appBar: AppBar(title: const Text('{FeatureName} Detail')),
        body: BlocBuilder<{FeatureName}Bloc, {FeatureName}State>(
          builder: (context, state) {
            return switch (state) {
              {FeatureName}Loading() => const Center(
                  child: CircularProgressIndicator(),
                ),
              {FeatureName}DetailLoaded(:final {featureName}) =>
                _buildDetail(context, {featureName}),
              {FeatureName}Error(:final message) => Center(
                  child: Text('Error: $message'),
                ),
              _ => const SizedBox.shrink(),
            };
          },
        ),
      ),
    );
  }

  Widget _buildDetail(BuildContext context, {FeatureName} {featureName}) {
    return Padding(
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
            'Dibuat: ${{featureName}.createdAt}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
```

---

### 12. Widget Templates

**Template: `presentation/widgets/{feature_name}_list_item.dart`**
```dart
import 'package:flutter/material.dart';
import '../../domain/entities/{feature_name}_entity.dart';

class {FeatureName}ListItem extends StatelessWidget {
  final {FeatureName} {featureName};
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const {FeatureName}ListItem({
    super.key,
    required this.{featureName},
    this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor:
              {featureName}.isActive ? Colors.green[100] : Colors.grey[300],
          child: Text(
            {featureName}.name[0].toUpperCase(),
            style: TextStyle(
              color: {featureName}.isActive ? Colors.green[800] : Colors.grey[600],
            ),
          ),
        ),
        title: Text({featureName}.name),
        subtitle: {featureName}.description != null
            ? Text(
                {featureName}.description!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              )
            : null,
        trailing: onDelete != null
            ? IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                onPressed: onDelete,
              )
            : null,
        onTap: onTap,
      ),
    );
  }
}
```

**Template: `presentation/widgets/{feature_name}_form.dart`**
```dart
import 'package:flutter/material.dart';

class {FeatureName}Form extends StatefulWidget {
  final String? initialName;
  final String? initialDescription;
  final void Function(String name, String? description) onSubmit;

  const {FeatureName}Form({
    super.key,
    this.initialName,
    this.initialDescription,
    required this.onSubmit,
  });

  @override
  State<{FeatureName}Form> createState() => _{FeatureName}FormState();
}

class _{FeatureName}FormState extends State<{FeatureName}Form> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _descController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);
    _descController = TextEditingController(text: widget.initialDescription);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: 'Nama'),
            validator: (v) => v == null || v.isEmpty ? 'Nama wajib diisi' : null,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _descController,
            decoration: const InputDecoration(labelText: 'Deskripsi (opsional)'),
            maxLines: 3,
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                if (_formKey.currentState?.validate() ?? false) {
                  widget.onSubmit(
                    _nameController.text,
                    _descController.text.isNotEmpty ? _descController.text : null,
                  );
                }
              },
              child: const Text('Simpan'),
            ),
          ),
        ],
      ),
    );
  }
}
```

**Template: `presentation/widgets/{feature_name}_shimmer.dart`**
```dart
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class {FeatureName}ListShimmer extends StatelessWidget {
  const {FeatureName}ListShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
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
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: ListTile(
          leading: const CircleAvatar(backgroundColor: Colors.white),
          title: Container(
            height: 14,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          subtitle: Container(
            height: 10,
            width: 150,
            margin: const EdgeInsets.only(top: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          trailing: Container(
            width: 24,
            height: 24,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );
  }
}
```

---

### 13. Route Registration (GoRouter)

**Description:** Register feature routes di GoRouter. Sama seperti Riverpod version.

**Step 1: Route constants `lib/core/router/routes.dart`**
```dart
class AppRoutes {
  // ... existing routes ...

  // {FeatureName} routes
  static const String {featureName}s = '/{feature_name}s';
  static const String {featureName}Detail = '/{feature_name}s/:id';
  static const String {featureName}Create = '/{feature_name}s/create';
  static const String {featureName}Edit = '/{feature_name}s/:id/edit';

  // Helper methods
  static String {featureName}DetailPath(String id) => '/{feature_name}s/$id';
  static String {featureName}EditPath(String id) => '/{feature_name}s/$id/edit';
}
```

**Step 2: GoRouter config `lib/core/router/app_router.dart`**
```dart
import '../../features/{feature_name}/presentation/screens/{feature_name}_list_screen.dart';
import '../../features/{feature_name}/presentation/screens/{feature_name}_detail_screen.dart';

// Add to GoRouter routes list:
GoRoute(
  path: AppRoutes.{featureName}s,
  builder: (context, state) => const {FeatureName}ListScreen(),
  routes: [
    GoRoute(
      path: 'create',
      builder: (context, state) => const {FeatureName}CreateScreen(),
    ),
    GoRoute(
      path: ':id',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return {FeatureName}DetailScreen({featureName}Id: id);
      },
      routes: [
        GoRoute(
          path: 'edit',
          builder: (context, state) {
            final id = state.pathParameters['id']!;
            return {FeatureName}EditScreen({featureName}Id: id);
          },
        ),
      ],
    ),
  ],
),
```

**Step 3: Navigation dari screen**
```dart
// Navigate to list
context.push(AppRoutes.{featureName}s);

// Navigate to detail
context.push(AppRoutes.{featureName}DetailPath(item.id));

// Navigate to create
context.push(AppRoutes.{featureName}Create);

// Navigate back
context.pop();
```

---

### 14. DI Registration (get_it + injectable)

**Description:** Dependency injection menggunakan get_it + injectable. Dua opsi: annotation-based (injectable) atau manual.

**Opsi A: Dengan @injectable annotations (recommended)**

Semua class yang sudah di-annotasi (`@injectable`, `@lazySingleton`, `@LazySingleton(as:)`) akan otomatis ter-register saat menjalankan `build_runner`.

```dart
// lib/injection.dart
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';

import 'injection.config.dart';

final getIt = GetIt.instance;

@InjectableInit()
void configureDependencies() => getIt.init();
```

```dart
// lib/main.dart
void main() {
  configureDependencies();
  runApp(const MyApp());
}
```

Jalankan code generation:
```bash
dart run build_runner build -d
```

**Opsi B: Manual registration (tanpa injectable)**
```dart
// lib/features/{feature_name}/di/{feature_name}_module.dart
import 'package:get_it/get_it.dart';

void register{FeatureName}Feature(GetIt sl) {
  // BLoC
  sl.registerFactory(
    () => {FeatureName}Bloc(
      get{FeatureName}s: sl(),
      get{FeatureName}ById: sl(),
      create{FeatureName}: sl(),
      update{FeatureName}: sl(),
      delete{FeatureName}: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => Get{FeatureName}s(sl()));
  sl.registerLazySingleton(() => Get{FeatureName}ById(sl()));
  sl.registerLazySingleton(() => Create{FeatureName}(sl()));
  sl.registerLazySingleton(() => Update{FeatureName}(sl()));
  sl.registerLazySingleton(() => Delete{FeatureName}(sl()));

  // Repository
  sl.registerLazySingleton<{FeatureName}Repository>(
    () => {FeatureName}RepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  // Data sources
  sl.registerLazySingleton<{FeatureName}RemoteDataSource>(
    () => {FeatureName}RemoteDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<{FeatureName}LocalDataSource>(
    () => {FeatureName}LocalDataSourceImpl(sl()),
  );
}
```

```dart
// lib/injection.dart (manual version)
import 'package:get_it/get_it.dart';
import 'features/{feature_name}/di/{feature_name}_module.dart';

final getIt = GetIt.instance;

void configureDependencies() {
  // Core
  // ... register Dio, SharedPreferences, NetworkInfo ...

  // Features
  register{FeatureName}Feature(getIt);
}
```

**PENTING:** BLoC harus di-register sebagai `registerFactory` (bukan singleton) agar setiap screen mendapat instance baru. Use cases dan repositories boleh singleton.

---

## Workflow Steps

1. **Analyze Requirements**
   - Tentukan nama feature (contoh: `product`, `order`, `user`)
   - List fields yang dibutuhkan
   - Tentukan relationships (if any)
   - Pilih Bloc vs Cubit (Bloc untuk complex events, Cubit untuk simple CRUD)

2. **Generate Domain Layer**
   - Create entity class (Equatable)
   - Create repository abstract contract (Either<Failure, T>)
   - Generate use cases (CRUD): GetAll, GetById, Create, Update, Delete

3. **Generate Data Layer**
   - Create model (manual atau freezed)
   - Implement remote data source (Dio)
   - Implement local data source (SharedPreferences/Hive, optional)
   - Create repository implementation

4. **Generate Presentation Layer - BLoC**
   - Define Events sealed class (semua aksi user)
   - Define States sealed class (semua kemungkinan state + side effects)
   - Create BLoC class dengan `on<Event>` handlers
   - Generate screens dengan `BlocConsumer`
   - Create widgets (list item, form, shimmer)

5. **Setup DI (get_it)**
   - Register BLoC (`registerFactory`)
   - Register use cases (`registerLazySingleton`)
   - Register repository (`registerLazySingleton`)
   - Register data sources (`registerLazySingleton`)
   - Jalankan `build_runner` jika pakai injectable

6. **Add Routes to GoRouter**
   - Update `routes.dart` (constants + helper methods)
   - Update `app_router.dart` (GoRoute config)
   - Test navigation dari screens

7. **Run Code Generation** (jika pakai freezed/injectable)
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```

8. **Test Feature**
   - Test semua states (initial, loading, loaded, empty, error)
   - Test CRUD operations + side effect states
   - Test BlocListener snackbar/navigation
   - Verify shimmer loading
   - Test route navigation
   - `flutter analyze`

---

## Usage Example: Todo Feature (BLoC)

Contoh lengkap generate feature `Todo` dengan BLoC.

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

### Step 7: DI Registration

```dart
// Dengan @injectable annotations, cukup jalankan:
// dart run build_runner build -d
// Semua class yang di-annotasi @injectable / @lazySingleton otomatis ter-register.
```

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

## BLoC vs Cubit: Kapan Pakai Apa?

| Aspek | Bloc | Cubit |
|---|---|---|
| Complexity | Complex feature dengan banyak events | Simple CRUD tanpa event transformation |
| Traceability | Setiap event ter-log, mudah debug | Method calls, kurang traceable |
| Events | Sealed class, exhaustive | Langsung method call |
| Testing | Event-driven, predictable | Method-driven |
| `transformEvents` | Bisa debounce/throttle events | Tidak bisa |
| Recommendation | Feature utama (order, product) | Feature kecil (settings, profile) |

## Success Criteria

- [ ] Feature structure mengikuti Clean Architecture
- [ ] Entity, Repository, Use Cases ter-generate (Domain)
- [ ] Model, DataSource, RepoImpl ter-generate (Data)
- [ ] Events sealed class lengkap (semua CRUD events)
- [ ] States sealed class lengkap (termasuk side effect states)
- [ ] BLoC class dengan semua `on<Event>` handlers
- [ ] Screen menggunakan `BlocConsumer` (listener + builder)
- [ ] `BlocListener` menangkap side effects (snackbar/navigation)
- [ ] `BlocBuilder` render UI dengan pattern matching pada state
- [ ] DI registered di get_it (BLoC sebagai Factory, sisanya Singleton)
- [ ] Routes registered di GoRouter
- [ ] Shimmer loading implemented
- [ ] `flutter analyze` tidak ada error
- [ ] Code generation berhasil (`build_runner`)

## Tools & Dependencies

- **State Management:** `flutter_bloc`, `bloc`
- **Code Generation:** `build_runner`, `freezed`, `json_serializable`, `injectable_generator`
- **DI:** `get_it`, `injectable`
- **Routing:** `go_router`
- **Functional:** `dartz` (Either)
- **HTTP:** `dio`
- **Equality:** `equatable`
- **Shimmer:** `shimmer`
- **Form (optional):** `flutter_form_builder`, `formz`

## Next Steps

Setelah generate feature:
1. Implement business logic di use cases
2. Connect ke backend (REST API, Firebase, atau Supabase)
3. Add unit tests untuk BLoC (`bloc_test` package)
4. Add widget tests
5. Add `BlocObserver` untuk logging/analytics
6. Lanjut ke `03_api_integration.md`

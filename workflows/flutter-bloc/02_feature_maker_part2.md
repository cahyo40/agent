---
description: Generate feature baru dengan struktur Clean Architecture lengkap menggunakan **flutter_bloc**. (Part 2/11)
---
# Workflow: Flutter BLoC Feature Maker (Part 2/11)

> **Navigation:** This workflow is split into 11 parts.

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

## Deliverables

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

## Deliverables

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

## Deliverables

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


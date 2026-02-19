---
description: Generate feature baru dengan struktur Clean Architecture lengkap menggunakan GetX pattern. (Part 2/10)
---
# Workflow: Flutter Feature Maker (GetX) (Part 2/10)

> **Navigation:** This workflow is split into 10 parts.

## Deliverables

### 1. Feature Template Generator

**Description:** Template lengkap untuk generate feature baru. Karena GetX tidak butuh code generation, semua file langsung bisa dipakai tanpa `build_runner`.

**Recommended Skills:** `senior-flutter-developer`

**Instructions:**
Buat template untuk generate feature dengan struktur:

```
lib/features/{feature_name}/
├── bindings/
│   └── {feature_name}_binding.dart
├── controllers/
│   └── {feature_name}_controller.dart
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
└── views/
    ├── {feature_name}_list_view.dart
    ├── {feature_name}_detail_view.dart
    └── widgets/
        ├── {feature_name}_list_item.dart
        ├── {feature_name}_form.dart
        └── {feature_name}_shimmer.dart
```

> **Catatan:** Berbeda dengan Riverpod yang punya folder `presentation/screens/`, di GetX kita pakai `views/` sesuai konvensi GetX. Controller dan binding punya folder tersendiri di level feature.

**Output Format:**
```dart
// TEMPLATE: features/{feature}/domain/entities/{feature}_entity.dart
import 'package:equatable/equatable.dart';

class {FeatureName} extends Equatable {
  final String id;
  final String name;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const {FeatureName}({
    required this.id,
    required this.name,
    required this.createdAt,
    this.updatedAt,
  });

  {FeatureName} copyWith({
    String? id,
    String? name,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return {FeatureName}(
      id: id ?? this.id,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [id, name, createdAt, updatedAt];
}
```

---

## Deliverables

### 2. Domain Layer Template

**Description:** Template untuk domain layer (entity, repository contract, use cases). Layer ini identical dengan Riverpod version karena domain layer tidak bergantung pada state management.

**Recommended Skills:** `senior-flutter-developer`

**Instructions:**
Buat template untuk:
1. Entity dengan Equatable dan `copyWith`
2. Repository abstract contract (menggunakan `Either<Failure, T>` dari dartz)
3. Use cases (GetAll, GetById, Create, Update, Delete)

**Output Format:**
```dart
// TEMPLATE: domain/entities/{feature}_entity.dart
import 'package:equatable/equatable.dart';

class {FeatureName} extends Equatable {
  final String id;
  final String name;
  final String? description;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const {FeatureName}({
    required this.id,
    required this.name,
    this.description,
    required this.createdAt,
    this.updatedAt,
  });

  {FeatureName} copyWith({
    String? id,
    String? name,
    String? description,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return {FeatureName}(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [id, name, description, createdAt, updatedAt];
}

// TEMPLATE: domain/repositories/{feature}_repository.dart
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/{feature_name}_entity.dart';

abstract class {FeatureName}Repository {
  Future<Either<Failure, List<{FeatureName}>>> get{FeatureName}s();
  Future<Either<Failure, {FeatureName}>> get{FeatureName}ById(String id);
  Future<Either<Failure, {FeatureName}>> create{FeatureName}({FeatureName} {featureName});
  Future<Either<Failure, {FeatureName}>> update{FeatureName}({FeatureName} {featureName});
  Future<Either<Failure, Unit>> delete{FeatureName}(String id);
}

// TEMPLATE: domain/usecases/get_{feature}s.dart
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/{feature_name}_entity.dart';
import '../repositories/{feature_name}_repository.dart';

class Get{FeatureName}s implements UseCase<List<{FeatureName}>, NoParams> {
  final {FeatureName}Repository repository;

  Get{FeatureName}s(this.repository);

  @override
  Future<Either<Failure, List<{FeatureName}>>> call(NoParams params) {
    return repository.get{FeatureName}s();
  }
}

// TEMPLATE: domain/usecases/get_{feature}_by_id.dart
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/{feature_name}_entity.dart';
import '../repositories/{feature_name}_repository.dart';

class Get{FeatureName}ById implements UseCase<{FeatureName}, String> {
  final {FeatureName}Repository repository;

  Get{FeatureName}ById(this.repository);

  @override
  Future<Either<Failure, {FeatureName}>> call(String id) {
    return repository.get{FeatureName}ById(id);
  }
}

// TEMPLATE: domain/usecases/create_{feature}.dart
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/{feature_name}_entity.dart';
import '../repositories/{feature_name}_repository.dart';

class Create{FeatureName} implements UseCase<{FeatureName}, {FeatureName}> {
  final {FeatureName}Repository repository;

  Create{FeatureName}(this.repository);

  @override
  Future<Either<Failure, {FeatureName}>> call({FeatureName} {featureName}) {
    return repository.create{FeatureName}({featureName});
  }
}

// TEMPLATE: domain/usecases/update_{feature}.dart
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/{feature_name}_entity.dart';
import '../repositories/{feature_name}_repository.dart';

class Update{FeatureName} implements UseCase<{FeatureName}, {FeatureName}> {
  final {FeatureName}Repository repository;

  Update{FeatureName}(this.repository);

  @override
  Future<Either<Failure, {FeatureName}>> call({FeatureName} {featureName}) {
    return repository.update{FeatureName}({featureName});
  }
}

// TEMPLATE: domain/usecases/delete_{feature}.dart
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/{feature_name}_repository.dart';

class Delete{FeatureName} implements UseCase<Unit, String> {
  final {FeatureName}Repository repository;

  Delete{FeatureName}(this.repository);

  @override
  Future<Either<Failure, Unit>> call(String id) {
    return repository.delete{FeatureName}(id);
  }
}

// TEMPLATE: core/usecases/usecase.dart (shared base class)
import 'package:dartz/dartz.dart';
import '../error/failures.dart';

abstract class UseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}

class NoParams {
  const NoParams();
}
```

---


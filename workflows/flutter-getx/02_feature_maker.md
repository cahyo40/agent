# Workflow: Flutter Feature Maker (GetX)

## Overview

Generate feature baru dengan struktur Clean Architecture lengkap menggunakan GetX pattern. Workflow ini membuat boilerplate code untuk feature baru termasuk entity, model (manual JSON serialization), repository, use case, GetxController, Binding, dan screen (GetView). Tidak perlu code generation (build_runner/freezed) -- semua file langsung siap pakai.

## Output Location

**Base Folder:** `sdlc/flutter-getx/02-feature-maker/`

**Output Files:**
- `feature-template.md` - Panduan menggunakan template
- `feature-generator-script.md` - Script/logika untuk generate feature
- `templates/` - Template files untuk setiap layer
  - `domain/` - Entity, repository, use case templates
  - `data/` - Model (manual fromJson/toJson), repository impl, data source templates
  - `presentation/` - Controller, binding, view, widget templates
- `examples/` - Contoh feature yang sudah jadi (Todo)

## Prerequisites

- Project setup dari `01_project_setup.md` selesai
- Clean Architecture structure sudah ada
- Dependencies sudah terinstall (`get`, `get_storage`, `dio`, `equatable`, `dartz`, `shimmer`)

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

### 3. Data Layer Template

**Description:** Template untuk data layer (model, repository impl, data sources). Perbedaan utama dengan Riverpod version: **manual fromJson/toJson** tanpa freezed, dan **GetStorage** untuk local cache (bukan Hive).

**Recommended Skills:** `senior-flutter-developer`

**Instructions:**
Buat template untuk:
1. Model dengan manual JSON serialization (fromJson/toJson) -- **tanpa freezed**
2. Remote data source (Dio)
3. Local data source (GetStorage)
4. Repository implementation

**Output Format:**
```dart
// TEMPLATE: data/models/{feature}_model.dart
// CATATAN: Manual fromJson/toJson - TIDAK pakai freezed/json_serializable
import '../../domain/entities/{feature_name}_entity.dart';

class {FeatureName}Model {
  final String id;
  final String name;
  final String? description;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const {FeatureName}Model({
    required this.id,
    required this.name,
    this.description,
    required this.createdAt,
    this.updatedAt,
  });

  /// Factory constructor dari JSON (manual serialization)
  factory {FeatureName}Model.fromJson(Map<String, dynamic> json) {
    return {FeatureName}Model(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  /// Convert ke JSON (manual serialization)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
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
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  /// Factory dari list JSON
  static List<{FeatureName}Model> fromJsonList(List<dynamic> jsonList) {
    return jsonList
        .map((json) => {FeatureName}Model.fromJson(json as Map<String, dynamic>))
        .toList();
  }
}

// TEMPLATE: data/datasources/{feature}_remote_ds.dart
import 'package:dio/dio.dart';
import '../models/{feature_name}_model.dart';

abstract class {FeatureName}RemoteDataSource {
  Future<List<{FeatureName}Model>> get{FeatureName}s();
  Future<{FeatureName}Model> get{FeatureName}ById(String id);
  Future<{FeatureName}Model> create{FeatureName}({FeatureName}Model model);
  Future<{FeatureName}Model> update{FeatureName}({FeatureName}Model model);
  Future<void> delete{FeatureName}(String id);
}

class {FeatureName}RemoteDataSourceImpl implements {FeatureName}RemoteDataSource {
  final Dio _dio;
  static const String _basePath = '/api/{feature_name}s';

  {FeatureName}RemoteDataSourceImpl(this._dio);

  @override
  Future<List<{FeatureName}Model>> get{FeatureName}s() async {
    try {
      final response = await _dio.get(_basePath);
      final List<dynamic> data = response.data['data'] ?? response.data;
      return {FeatureName}Model.fromJsonList(data);
    } on DioException catch (e) {
      throw ServerException(e.message ?? 'Failed to fetch {featureName}s');
    }
  }

  @override
  Future<{FeatureName}Model> get{FeatureName}ById(String id) async {
    try {
      final response = await _dio.get('$_basePath/$id');
      return {FeatureName}Model.fromJson(response.data['data'] ?? response.data);
    } on DioException catch (e) {
      throw ServerException(e.message ?? 'Failed to fetch {featureName}');
    }
  }

  @override
  Future<{FeatureName}Model> create{FeatureName}({FeatureName}Model model) async {
    try {
      final response = await _dio.post(
        _basePath,
        data: model.toJson(),
      );
      return {FeatureName}Model.fromJson(response.data['data'] ?? response.data);
    } on DioException catch (e) {
      throw ServerException(e.message ?? 'Failed to create {featureName}');
    }
  }

  @override
  Future<{FeatureName}Model> update{FeatureName}({FeatureName}Model model) async {
    try {
      final response = await _dio.put(
        '$_basePath/${model.id}',
        data: model.toJson(),
      );
      return {FeatureName}Model.fromJson(response.data['data'] ?? response.data);
    } on DioException catch (e) {
      throw ServerException(e.message ?? 'Failed to update {featureName}');
    }
  }

  @override
  Future<void> delete{FeatureName}(String id) async {
    try {
      await _dio.delete('$_basePath/$id');
    } on DioException catch (e) {
      throw ServerException(e.message ?? 'Failed to delete {featureName}');
    }
  }
}

// TEMPLATE: data/datasources/{feature}_local_ds.dart
// Menggunakan GetStorage (bukan Hive) sesuai GetX ecosystem
import 'dart:convert';
import 'package:get_storage/get_storage.dart';
import '../models/{feature_name}_model.dart';

abstract class {FeatureName}LocalDataSource {
  List<{FeatureName}Model>? getCached{FeatureName}s();
  Future<void> cache{FeatureName}s(List<{FeatureName}Model> models);
  {FeatureName}Model? getCached{FeatureName}ById(String id);
  Future<void> clearCache();
}

class {FeatureName}LocalDataSourceImpl implements {FeatureName}LocalDataSource {
  final GetStorage _storage;
  static const String _cacheKey = 'cached_{feature_name}s';

  {FeatureName}LocalDataSourceImpl(this._storage);

  @override
  List<{FeatureName}Model>? getCached{FeatureName}s() {
    final jsonString = _storage.read<String>(_cacheKey);
    if (jsonString == null) return null;

    try {
      final List<dynamic> jsonList = json.decode(jsonString);
      return {FeatureName}Model.fromJsonList(jsonList);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> cache{FeatureName}s(List<{FeatureName}Model> models) async {
    final jsonList = models.map((m) => m.toJson()).toList();
    await _storage.write(_cacheKey, json.encode(jsonList));
  }

  @override
  {FeatureName}Model? getCached{FeatureName}ById(String id) {
    final cached = getCached{FeatureName}s();
    if (cached == null) return null;
    try {
      return cached.firstWhere((m) => m.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> clearCache() async {
    await _storage.remove(_cacheKey);
  }
}

// TEMPLATE: data/repositories/{feature}_repository_impl.dart
import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/{feature_name}_entity.dart';
import '../../domain/repositories/{feature_name}_repository.dart';
import '../datasources/{feature_name}_remote_ds.dart';
import '../datasources/{feature_name}_local_ds.dart';
import '../models/{feature_name}_model.dart';

class {FeatureName}RepositoryImpl implements {FeatureName}Repository {
  final {FeatureName}RemoteDataSource _remoteDataSource;
  final {FeatureName}LocalDataSource _localDataSource;

  {FeatureName}RepositoryImpl({
    required {FeatureName}RemoteDataSource remoteDataSource,
    required {FeatureName}LocalDataSource localDataSource,
  })  : _remoteDataSource = remoteDataSource,
        _localDataSource = localDataSource;

  @override
  Future<Either<Failure, List<{FeatureName}>>> get{FeatureName}s() async {
    try {
      final models = await _remoteDataSource.get{FeatureName}s();
      // Cache hasil dari remote
      await _localDataSource.cache{FeatureName}s(models);
      final entities = models.map((m) => m.toEntity()).toList();
      return Right(entities);
    } on ServerException catch (e) {
      // Fallback ke cache jika remote gagal
      final cached = _localDataSource.getCached{FeatureName}s();
      if (cached != null) {
        return Right(cached.map((m) => m.toEntity()).toList());
      }
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, {FeatureName}>> get{FeatureName}ById(String id) async {
    try {
      final model = await _remoteDataSource.get{FeatureName}ById(id);
      return Right(model.toEntity());
    } on ServerException catch (e) {
      // Fallback ke cache
      final cached = _localDataSource.getCached{FeatureName}ById(id);
      if (cached != null) {
        return Right(cached.toEntity());
      }
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, {FeatureName}>> create{FeatureName}({FeatureName} {featureName}) async {
    try {
      final model = {FeatureName}Model.fromEntity({featureName});
      final result = await _remoteDataSource.create{FeatureName}(model);
      return Right(result.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, {FeatureName}>> update{FeatureName}({FeatureName} {featureName}) async {
    try {
      final model = {FeatureName}Model.fromEntity({featureName});
      final result = await _remoteDataSource.update{FeatureName}(model);
      return Right(result.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> delete{FeatureName}(String id) async {
    try {
      await _remoteDataSource.delete{FeatureName}(id);
      return const Right(unit);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
```

---

### 4. Presentation Layer Template (GetX-specific)

**Description:** Template untuk GetxController dengan reactive state menggunakan `.obs`. Ini perbedaan utama dengan Riverpod version yang pakai `AsyncNotifier` dan `AsyncValue`.

**Recommended Skills:** `senior-flutter-developer`

**Instructions:**
Buat template untuk:
1. GetxController dengan `.obs` reactive variables
2. CRUD methods dengan `Get.snackbar()` feedback
3. State management: `isLoading`, `errorMessage`, `selectedItem`
4. `onInit()` untuk initial data fetch

**Output Format:**
```dart
// TEMPLATE: controllers/{feature}_controller.dart
import 'package:get/get.dart';
import '../../../domain/entities/{feature_name}_entity.dart';
import '../../../domain/repositories/{feature_name}_repository.dart';

class {FeatureName}Controller extends GetxController {
  final {FeatureName}Repository _repository = Get.find<{FeatureName}Repository>();

  // ============================================================
  // Reactive State Variables (.obs)
  // ============================================================
  final RxList<{FeatureName}> {featureName}s = <{FeatureName}>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final Rx<{FeatureName}?> selectedItem = Rx<{FeatureName}?>(null);

  // Form-related state
  final RxBool isSubmitting = false.obs;

  // Pagination (optional)
  final RxInt currentPage = 1.obs;
  final RxBool hasMoreData = true.obs;

  // ============================================================
  // Lifecycle
  // ============================================================
  @override
  void onInit() {
    super.onInit();
    fetch{FeatureName}s();
  }

  @override
  void onClose() {
    // Cleanup jika diperlukan
    super.onClose();
  }

  // ============================================================
  // READ - Fetch All
  // ============================================================
  Future<void> fetch{FeatureName}s() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final result = await _repository.get{FeatureName}s();

      result.fold(
        (failure) {
          errorMessage.value = failure.message;
        },
        (data) {
          {featureName}s.assignAll(data);
        },
      );
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  // ============================================================
  // READ - Fetch By ID
  // ============================================================
  Future<void> fetch{FeatureName}ById(String id) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final result = await _repository.get{FeatureName}ById(id);

      result.fold(
        (failure) {
          errorMessage.value = failure.message;
          Get.snackbar(
            'Error',
            failure.message,
            snackPosition: SnackPosition.BOTTOM,
          );
        },
        (data) {
          selectedItem.value = data;
        },
      );
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  // ============================================================
  // CREATE
  // ============================================================
  Future<void> create{FeatureName}({
    required String name,
    String? description,
  }) async {
    try {
      isSubmitting.value = true;

      final new{FeatureName} = {FeatureName}(
        id: '', // Backend akan generate ID
        name: name,
        description: description,
        createdAt: DateTime.now(),
      );

      final result = await _repository.create{FeatureName}(new{FeatureName});

      result.fold(
        (failure) {
          Get.snackbar(
            'Error',
            failure.message,
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Get.theme.colorScheme.error,
            colorText: Get.theme.colorScheme.onError,
          );
        },
        ({featureName}) {
          {featureName}s.add({featureName});
          Get.back(); // Tutup form/dialog
          Get.snackbar(
            'Berhasil',
            '{FeatureName} berhasil dibuat',
            snackPosition: SnackPosition.BOTTOM,
          );
        },
      );
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isSubmitting.value = false;
    }
  }

  // ============================================================
  // UPDATE
  // ============================================================
  Future<void> update{FeatureName}({
    required String id,
    required String name,
    String? description,
  }) async {
    try {
      isSubmitting.value = true;

      // Ambil data existing lalu update fields
      final existing = {featureName}s.firstWhere((item) => item.id == id);
      final updated = existing.copyWith(
        name: name,
        description: description,
        updatedAt: DateTime.now(),
      );

      final result = await _repository.update{FeatureName}(updated);

      result.fold(
        (failure) {
          Get.snackbar(
            'Error',
            failure.message,
            snackPosition: SnackPosition.BOTTOM,
          );
        },
        ({featureName}) {
          // Update item di list
          final index = {featureName}s.indexWhere((item) => item.id == id);
          if (index != -1) {
            {featureName}s[index] = {featureName};
          }
          // Update selectedItem jika sedang dilihat
          if (selectedItem.value?.id == id) {
            selectedItem.value = {featureName};
          }
          Get.back();
          Get.snackbar(
            'Berhasil',
            '{FeatureName} berhasil diupdate',
            snackPosition: SnackPosition.BOTTOM,
          );
        },
      );
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isSubmitting.value = false;
    }
  }

  // ============================================================
  // DELETE
  // ============================================================
  Future<void> delete{FeatureName}(String id) async {
    try {
      final result = await _repository.delete{FeatureName}(id);

      result.fold(
        (failure) {
          Get.snackbar(
            'Error',
            failure.message,
            snackPosition: SnackPosition.BOTTOM,
          );
        },
        (_) {
          {featureName}s.removeWhere((item) => item.id == id);
          // Clear selectedItem jika yang dihapus sedang dipilih
          if (selectedItem.value?.id == id) {
            selectedItem.value = null;
          }
          Get.snackbar(
            'Berhasil',
            '{FeatureName} berhasil dihapus',
            snackPosition: SnackPosition.BOTTOM,
          );
        },
      );
    } catch (e) {
      Get.snackbar('Error', e.toString());
    }
  }

  // ============================================================
  // Helper Methods
  // ============================================================
  void selectItem({FeatureName} item) {
    selectedItem.value = item;
  }

  void clearSelectedItem() {
    selectedItem.value = null;
  }

  /// Confirm delete dengan dialog
  void confirmDelete(String id) {
    Get.dialog(
      AlertDialog(
        title: const Text('Hapus {FeatureName}'),
        content: const Text('Apakah Anda yakin ingin menghapus item ini?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              Get.back(); // Tutup dialog
              delete{FeatureName}(id);
            },
            child: const Text(
              'Hapus',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
```

---

### 5. Complete Screen Template (GetX-specific)

**Description:** Template screen lengkap menggunakan `GetView<Controller>` dengan `Obx(() { ... })` untuk reactive UI. Perbedaan utama dengan Riverpod:
- `GetView<Controller>` bukan `ConsumerWidget`
- `Obx(() { ... })` bukan `.when(data:, error:, loading:)`
- Manual state check: `isLoading`, `errorMessage`, `isEmpty`
- `Get.toNamed()` bukan `context.push()`
- `Get.dialog()` bukan `showDialog()`
- `Get.back()` bukan `Navigator.pop()`

**Recommended Skills:** `senior-flutter-developer`

**Output Format:**
```dart
// TEMPLATE: views/{feature}_list_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../routes/app_routes.dart';
import '../controllers/{feature_name}_controller.dart';
import 'widgets/{feature_name}_list_item.dart';
import 'widgets/{feature_name}_shimmer.dart';

class {FeatureName}ListView extends GetView<{FeatureName}Controller> {
  const {FeatureName}ListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('{FeatureName}s'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: controller.fetch{FeatureName}s,
          ),
        ],
      ),
      body: Obx(() {
        // State 1: Loading (initial load, list masih kosong)
        if (controller.isLoading.value && controller.{featureName}s.isEmpty) {
          return const {FeatureName}ListShimmer();
        }

        // State 2: Error
        if (controller.errorMessage.value.isNotEmpty &&
            controller.{featureName}s.isEmpty) {
          return _buildErrorView();
        }

        // State 3: Empty
        if (controller.{featureName}s.isEmpty) {
          return _buildEmptyView();
        }

        // State 4: Data loaded
        return RefreshIndicator(
          onRefresh: controller.fetch{FeatureName}s,
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: controller.{featureName}s.length,
            itemBuilder: (context, index) {
              final item = controller.{featureName}s[index];
              return {FeatureName}ListItem(
                {featureName}: item,
                onTap: () {
                  controller.selectItem(item);
                  Get.toNamed(
                    AppRoutes.{featureName}DetailPath(item.id),
                  );
                },
                onDelete: () => controller.confirmDelete(item.id),
              );
            },
          ),
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              controller.errorMessage.value,
              textAlign: TextAlign.center,
              style: Get.textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: controller.fetch{FeatureName}s,
              icon: const Icon(Icons.refresh),
              label: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.inbox_outlined,
            size: 64,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          Text(
            'Belum ada {featureName}',
            style: Get.textTheme.titleMedium?.copyWith(
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap tombol + untuk menambahkan',
            style: Get.textTheme.bodyMedium?.copyWith(
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  void _showCreateDialog() {
    final nameController = TextEditingController();
    final descController = TextEditingController();

    Get.dialog(
      AlertDialog(
        title: const Text('Buat {FeatureName} Baru'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Nama',
                hintText: 'Masukkan nama {featureName}',
              ),
              autofocus: true,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: descController,
              decoration: const InputDecoration(
                labelText: 'Deskripsi (opsional)',
                hintText: 'Masukkan deskripsi',
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Batal'),
          ),
          Obx(() => ElevatedButton(
                onPressed: controller.isSubmitting.value
                    ? null
                    : () {
                        if (nameController.text.trim().isEmpty) {
                          Get.snackbar('Error', 'Nama tidak boleh kosong');
                          return;
                        }
                        controller.create{FeatureName}(
                          name: nameController.text.trim(),
                          description: descController.text.trim().isEmpty
                              ? null
                              : descController.text.trim(),
                        );
                      },
                child: controller.isSubmitting.value
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Simpan'),
              )),
        ],
      ),
    );
  }
}

// TEMPLATE: views/{feature}_detail_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/{feature_name}_controller.dart';

class {FeatureName}DetailView extends GetView<{FeatureName}Controller> {
  const {FeatureName}DetailView({super.key});

  @override
  Widget build(BuildContext context) {
    // Ambil ID dari route parameter
    final String? id = Get.parameters['id'];

    // Fetch detail jika selectedItem belum ada
    if (controller.selectedItem.value == null && id != null) {
      controller.fetch{FeatureName}ById(id);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail {FeatureName}'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            controller.clearSelectedItem();
            Get.back();
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _showEditDialog(),
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () {
              if (id != null) {
                controller.confirmDelete(id);
              }
            },
          ),
        ],
      ),
      body: Obx(() {
        // Loading state
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        // Error state
        if (controller.errorMessage.value.isNotEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(controller.errorMessage.value),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    if (id != null) controller.fetch{FeatureName}ById(id);
                  },
                  child: const Text('Coba Lagi'),
                ),
              ],
            ),
          );
        }

        // Data not found
        final item = controller.selectedItem.value;
        if (item == null) {
          return const Center(child: Text('{FeatureName} tidak ditemukan'));
        }

        // Data loaded
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        style: Get.textTheme.headlineSmall,
                      ),
                      if (item.description != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          item.description!,
                          style: Get.textTheme.bodyLarge,
                        ),
                      ],
                      const SizedBox(height: 16),
                      const Divider(),
                      const SizedBox(height: 8),
                      _buildInfoRow(
                        'Dibuat',
                        _formatDate(item.createdAt),
                      ),
                      if (item.updatedAt != null)
                        _buildInfoRow(
                          'Diupdate',
                          _formatDate(item.updatedAt!),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  void _showEditDialog() {
    final item = controller.selectedItem.value;
    if (item == null) return;

    final nameController = TextEditingController(text: item.name);
    final descController = TextEditingController(text: item.description ?? '');

    Get.dialog(
      AlertDialog(
        title: const Text('Edit {FeatureName}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Nama'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: descController,
              decoration: const InputDecoration(labelText: 'Deskripsi'),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Batal'),
          ),
          Obx(() => ElevatedButton(
                onPressed: controller.isSubmitting.value
                    ? null
                    : () {
                        controller.update{FeatureName}(
                          id: item.id,
                          name: nameController.text.trim(),
                          description: descController.text.trim().isEmpty
                              ? null
                              : descController.text.trim(),
                        );
                      },
                child: controller.isSubmitting.value
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Update'),
              )),
        ],
      ),
    );
  }
}

// TEMPLATE: views/widgets/{feature}_list_item.dart
import 'package:flutter/material.dart';
import '../../../../domain/entities/{feature_name}_entity.dart';

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
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          child: Text(
            {featureName}.name.isNotEmpty
                ? {featureName}.name[0].toUpperCase()
                : '?',
          ),
        ),
        title: Text({featureName}.name),
        subtitle: {featureName}.description != null
            ? Text(
                {featureName}.description!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              )
            : null,
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, color: Colors.red),
          onPressed: onDelete,
        ),
        onTap: onTap,
      ),
    );
  }
}

// TEMPLATE: views/widgets/{feature}_form.dart
import 'package:flutter/material.dart';

class {FeatureName}Form extends StatefulWidget {
  final String? initialName;
  final String? initialDescription;
  final bool isLoading;
  final void Function(String name, String? description) onSubmit;

  const {FeatureName}Form({
    super.key,
    this.initialName,
    this.initialDescription,
    this.isLoading = false,
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
            decoration: const InputDecoration(
              labelText: 'Nama',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Nama wajib diisi';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _descController,
            decoration: const InputDecoration(
              labelText: 'Deskripsi (opsional)',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: widget.isLoading ? null : _submit,
              child: widget.isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Simpan'),
            ),
          ),
        ],
      ),
    );
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      widget.onSubmit(
        _nameController.text.trim(),
        _descController.text.trim().isEmpty
            ? null
            : _descController.text.trim(),
      );
    }
  }
}
```

---

### 6. Route Registration Template (GetX-specific)

**Description:** Template untuk register feature routes dengan `GetPage` di `app_pages.dart`. Perbedaan utama dengan Riverpod:
- `GetPage` bukan `GoRoute`
- `binding:` untuk auto-inject dependencies
- `Get.toNamed()` bukan `context.push()`
- `Get.parameters['id']` bukan `state.pathParameters['id']`

**Recommended Skills:** `senior-flutter-developer`

**Output Format:**
```dart
// STEP 1: Tambah route constants di lib/routes/app_routes.dart
abstract class AppRoutes {
  // ... existing routes ...

  // {FeatureName} routes
  static const String {featureName}s = '/{feature_name}s';
  static const String {featureName}Detail = '/{feature_name}s/:id';
  static const String {featureName}Create = '/{feature_name}s/create';
  static const String {featureName}Edit = '/{feature_name}s/:id/edit';

  // Helper methods untuk generate path dengan parameter
  static String {featureName}DetailPath(String id) => '/{feature_name}s/$id';
  static String {featureName}EditPath(String id) => '/{feature_name}s/$id/edit';
}

// STEP 2: Register GetPage di lib/routes/app_pages.dart
import 'package:get/get.dart';
import 'app_routes.dart';
import '../features/{feature_name}/bindings/{feature_name}_binding.dart';
import '../features/{feature_name}/views/{feature_name}_list_view.dart';
import '../features/{feature_name}/views/{feature_name}_detail_view.dart';

class AppPages {
  static final routes = [
    // ... existing routes ...

    // {FeatureName} routes
    GetPage(
      name: AppRoutes.{featureName}s,
      page: () => const {FeatureName}ListView(),
      binding: {FeatureName}Binding(),
      transition: Transition.rightToLeft,
      children: [
        GetPage(
          name: '/create',
          page: () => const {FeatureName}CreateView(),
          // Binding sudah di-inherit dari parent
        ),
        GetPage(
          name: '/:id',
          page: () => const {FeatureName}DetailView(),
          // Binding sudah di-inherit dari parent
          children: [
            GetPage(
              name: '/edit',
              page: () => const {FeatureName}EditView(),
            ),
          ],
        ),
      ],
    ),
  ];
}

// STEP 3: Contoh navigasi di views
// ----------------------------------

// Navigate ke list
Get.toNamed(AppRoutes.{featureName}s);

// Navigate ke detail (dengan parameter ID)
Get.toNamed(AppRoutes.{featureName}DetailPath(itemId));

// Navigate ke create
Get.toNamed(AppRoutes.{featureName}Create);

// Navigate ke edit
Get.toNamed(AppRoutes.{featureName}EditPath(itemId));

// Navigate back
Get.back();

// Navigate back dan kirim result
Get.back(result: true);

// Navigate dan replace current route (no back)
Get.offNamed(AppRoutes.{featureName}s);

// Navigate dan clear semua stack
Get.offAllNamed(AppRoutes.home);

// STEP 4: Akses route parameters di view
// ----------------------------------

// Di dalam GetView atau controller:
final String? id = Get.parameters['id'];  // Ambil :id dari URL

// Atau akses via arguments (jika pakai Get.toNamed dengan arguments)
final args = Get.arguments as Map<String, dynamic>?;
```

---

### 7. Binding Template

**Description:** Template untuk `{FeatureName}Binding extends Bindings`. Binding adalah pengganti provider/riverpod untuk dependency injection di GetX. Binding otomatis dipanggil saat route diakses dan dependency di-dispose saat route di-pop.

**Recommended Skills:** `senior-flutter-developer`

**Output Format:**
```dart
// TEMPLATE: bindings/{feature}_binding.dart
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../controllers/{feature_name}_controller.dart';
import '../data/datasources/{feature_name}_remote_ds.dart';
import '../data/datasources/{feature_name}_local_ds.dart';
import '../data/repositories/{feature_name}_repository_impl.dart';
import '../domain/repositories/{feature_name}_repository.dart';

class {FeatureName}Binding extends Bindings {
  @override
  void dependencies() {
    // Data Sources
    Get.lazyPut<{FeatureName}RemoteDataSource>(
      () => {FeatureName}RemoteDataSourceImpl(Get.find()),
    );
    Get.lazyPut<{FeatureName}LocalDataSource>(
      () => {FeatureName}LocalDataSourceImpl(GetStorage()),
    );

    // Repository
    Get.lazyPut<{FeatureName}Repository>(
      () => {FeatureName}RepositoryImpl(
        remoteDataSource: Get.find<{FeatureName}RemoteDataSource>(),
        localDataSource: Get.find<{FeatureName}LocalDataSource>(),
      ),
    );

    // Controller
    Get.lazyPut<{FeatureName}Controller>(
      () => {FeatureName}Controller(),
    );
  }
}

// ============================================================
// CATATAN PENTING tentang Bindings di GetX:
// ============================================================
//
// 1. Get.lazyPut() - Create instance saat pertama kali dipanggil
//    - Auto-dispose saat controller di-dispose
//    - Cocok untuk per-feature dependencies
//
// 2. Get.put() - Create instance segera (eager loading)
//    - Gunakan untuk dependencies yang selalu dibutuhkan
//    - Tambah `permanent: true` jika tidak boleh di-dispose
//
// 3. Get.putAsync() - Untuk async initialization
//    - Contoh: database connection, shared preferences init
//
// 4. Get.create() - Create new instance setiap kali dipanggil
//    - Cocok jika butuh fresh instance setiap akses
//
// ============================================================
// Contoh binding dengan use cases (opsional):
// ============================================================
//
// class {FeatureName}Binding extends Bindings {
//   @override
//   void dependencies() {
//     // Data Sources
//     Get.lazyPut<{FeatureName}RemoteDataSource>(
//       () => {FeatureName}RemoteDataSourceImpl(Get.find()),
//     );
//
//     // Repository
//     Get.lazyPut<{FeatureName}Repository>(
//       () => {FeatureName}RepositoryImpl(
//         remoteDataSource: Get.find(),
//       ),
//     );
//
//     // Use Cases (opsional, bisa langsung pakai repository)
//     Get.lazyPut(() => Get{FeatureName}s(Get.find()));
//     Get.lazyPut(() => Get{FeatureName}ById(Get.find()));
//     Get.lazyPut(() => Create{FeatureName}(Get.find()));
//     Get.lazyPut(() => Update{FeatureName}(Get.find()));
//     Get.lazyPut(() => Delete{FeatureName}(Get.find()));
//
//     // Controller
//     Get.lazyPut<{FeatureName}Controller>(
//       () => {FeatureName}Controller(),
//     );
//   }
// }
```

---

### 8. Shimmer Loading Template

**Description:** Template shimmer loading skeleton. Standalone StatelessWidget -- tidak perlu ConsumerWidget atau GetView karena shimmer tidak butuh reactive data.

**Recommended Skills:** `senior-flutter-developer`

**Output Format:**
```dart
// TEMPLATE: views/widgets/{feature}_shimmer.dart
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class {FeatureName}ListShimmer extends StatelessWidget {
  const {FeatureName}ListShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 8,
      itemBuilder: (context, index) => const {FeatureName}ListItemShimmer(),
    );
  }
}

class {FeatureName}ListItemShimmer extends StatelessWidget {
  const {FeatureName}ListItemShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Card(
        margin: const EdgeInsets.only(bottom: 8),
        child: ListTile(
          leading: Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
          title: Container(
            height: 16,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          subtitle: Container(
            height: 12,
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

/// Shimmer untuk detail view
class {FeatureName}DetailShimmer extends StatelessWidget {
  const {FeatureName}DetailShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title shimmer
            Container(
              height: 24,
              width: 200,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 16),
            // Description shimmer
            Container(
              height: 14,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              height: 14,
              width: 250,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 24),
            // Info card shimmer
            Container(
              height: 120,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

## Workflow Steps

1. **Analyze Requirements**
   - Tentukan nama feature (contoh: `todo`, `product`, `order`)
   - List fields yang dibutuhkan beserta tipe data
   - Tentukan relationships (if any)
   - Mapping API endpoints

2. **Generate Domain Layer**
   - Create entity class dengan Equatable
   - Create repository abstract contract
   - Generate use cases (CRUD): GetAll, GetById, Create, Update, Delete

3. **Generate Data Layer**
   - Create model dengan **manual fromJson/toJson** (tanpa freezed!)
   - Implement remote data source (Dio)
   - Implement local data source (GetStorage)
   - Create repository implementation dengan cache fallback

4. **Generate Presentation Layer**
   - Create `GetxController` dengan `.obs` reactive variables
   - Create `{FeatureName}Binding` untuk dependency injection
   - Generate views (`GetView<Controller>`) untuk list dan detail
   - Create widgets (list item, form, shimmer)
   - Implement state handling manual (`isLoading`, `errorMessage`, empty check)

5. **Setup Bindings**
   - Create `{FeatureName}Binding extends Bindings`
   - Register data sources, repository, dan controller dengan `Get.lazyPut()`
   - Verify dependency chain benar (DataSource -> Repository -> Controller)

6. **Add Routes to AppPages**
   - **Step 6.1:** Tambah route constants di `lib/routes/app_routes.dart`
     - Add route strings untuk list, detail, create, edit
     - Add helper methods untuk generate path dengan params
   
   - **Step 6.2:** Register `GetPage` di `lib/routes/app_pages.dart`
     - Import feature views
     - Add `GetPage` dengan `binding:` property
     - Setup children routes untuk detail dan edit
     - Configure `transition:` (optional)
   
   - **Step 6.3:** Update navigation di views
     - Use `Get.toNamed()` untuk navigate
     - Use `Get.back()` untuk go back
     - Use route helper methods untuk type safety
   
   - **Step 6.4:** Test routing
     - Verifikasi semua routes bisa diakses
     - Test navigasi dari list ke detail
     - Test navigasi dari list ke create
     - Test navigasi dari detail ke edit
     - Test `Get.back()` behavior

7. **Test Feature**
   - **Tidak perlu `dart run build_runner build`** -- semua file langsung siap!
   - Run `flutter analyze` -- pastikan tidak ada error
   - Test semua states (loading, error, empty, data)
   - Test CRUD operations
   - Verify shimmer loading tampil saat loading
   - Test navigation/routing
   - Test `Get.snackbar()` feedback

## Success Criteria

- [ ] Feature structure mengikuti Clean Architecture
- [ ] Semua file ter-generate tanpa error
- [ ] **Tidak perlu code generation** (no build_runner)
- [ ] Manual fromJson/toJson bekerja dengan benar
- [ ] **Bindings configured** -- dependency chain benar
- [ ] **GetPage routes registered** di app_pages.dart
- [ ] **Route constants defined** di app_routes.dart
- [ ] Feature bisa di-navigate dengan `Get.toNamed()`
- [ ] Navigation ke detail/create/edit berfungsi
- [ ] `Obx()` reactive state berfungsi (loading, error, empty, data)
- [ ] Shimmer loading implemented
- [ ] CRUD operations berfungsi dengan `Get.snackbar()` feedback
- [ ] `Get.dialog()` confirmation berfungsi
- [ ] `flutter analyze` tidak ada error
- [ ] Null safety handled dengan baik

## Usage Example

Untuk generate feature baru bernama `Todo`:

### Step 1: Generate Feature Files
```bash
# Ganti placeholder dengan nama feature:
# {FeatureName} -> Todo
# {featureName} -> todo
# {feature_name} -> todo
#
# Tidak perlu code generation -- langsung siap pakai!
```

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

### Step 4: Presentation Layer -- Controller

**File: `lib/features/todo/controllers/todo_controller.dart`**
```dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
          Get.snackbar(
            'Error',
            failure.message,
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red.shade100,
          );
        },
        (todo) {
          todos.add(todo);
          Get.back();
          Get.snackbar(
            'Berhasil',
            'Todo berhasil ditambahkan',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green.shade100,
          );
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
      (failure) => Get.snackbar('Error', failure.message),
      (updatedTodo) {
        todos[index] = updatedTodo;
      },
    );
  }

  Future<void> deleteTodo(String id) async {
    final result = await _repository.deleteTodo(id);

    result.fold(
      (failure) => Get.snackbar('Error', failure.message),
      (_) {
        todos.removeWhere((t) => t.id == id);
        if (selectedTodo.value?.id == id) {
          selectedTodo.value = null;
        }
        Get.snackbar('Berhasil', 'Todo berhasil dihapus');
      },
    );
  }

  void confirmDelete(String id) {
    Get.dialog(
      AlertDialog(
        title: const Text('Hapus Todo'),
        content: const Text('Apakah Anda yakin ingin menghapus todo ini?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              deleteTodo(id);
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
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

### Step 7: View -- List Screen

**File: `lib/features/todo/views/todo_list_view.dart`**
```dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../routes/app_routes.dart';
import '../controllers/todo_controller.dart';
import 'widgets/todo_shimmer.dart';

class TodoListView extends GetView<TodoController> {
  const TodoListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Todos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: controller.fetchTodos,
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Obx(() => Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildFilterChip('Semua', 'all'),
                  _buildFilterChip('Aktif (${controller.activeCount})', 'active'),
                  _buildFilterChip('Selesai (${controller.completedCount})', 'completed'),
                ],
              )),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.todos.isEmpty) {
          return const TodoListShimmer();
        }

        if (controller.errorMessage.value.isNotEmpty && controller.todos.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text(controller.errorMessage.value),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: controller.fetchTodos,
                  child: const Text('Coba Lagi'),
                ),
              ],
            ),
          );
        }

        final items = controller.filteredTodos;

        if (items.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.checklist, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text('Tidak ada todo', style: TextStyle(color: Colors.grey)),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: controller.fetchTodos,
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final todo = items[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: Checkbox(
                    value: todo.isCompleted,
                    onChanged: (_) => controller.toggleComplete(todo.id),
                  ),
                  title: Text(
                    todo.title,
                    style: TextStyle(
                      decoration: todo.isCompleted
                          ? TextDecoration.lineThrough
                          : null,
                    ),
                  ),
                  subtitle: todo.description != null
                      ? Text(todo.description!, maxLines: 1, overflow: TextOverflow.ellipsis)
                      : null,
                  onTap: () {
                    controller.selectedTodo.value = todo;
                    Get.toNamed(AppRoutes.todoDetailPath(todo.id));
                  },
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: () => controller.confirmDelete(todo.id),
                  ),
                ),
              );
            },
          ),
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    return ChoiceChip(
      label: Text(label),
      selected: controller.filter.value == value,
      onSelected: (_) => controller.setFilter(value),
    );
  }

  void _showCreateDialog() {
    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();

    Get.dialog(
      AlertDialog(
        title: const Text('Buat Todo Baru'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleCtrl,
              decoration: const InputDecoration(labelText: 'Judul'),
              autofocus: true,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: descCtrl,
              decoration: const InputDecoration(labelText: 'Deskripsi (opsional)'),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Batal'),
          ),
          Obx(() => ElevatedButton(
                onPressed: controller.isSubmitting.value
                    ? null
                    : () {
                        if (titleCtrl.text.trim().isEmpty) {
                          Get.snackbar('Error', 'Judul tidak boleh kosong');
                          return;
                        }
                        controller.createTodo(
                          title: titleCtrl.text.trim(),
                          description: descCtrl.text.trim().isEmpty
                              ? null
                              : descCtrl.text.trim(),
                        );
                      },
                child: controller.isSubmitting.value
                    ? const SizedBox(
                        width: 20, height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Simpan'),
              )),
        ],
      ),
    );
  }
}
```

### Step 8: Test Feature

```bash
# Langsung run -- tidak perlu code generation!
flutter analyze
flutter run

# Test navigation:
# 1. List screen -> Tap + -> Create dialog
# 2. Create todo -> Cek muncul di list
# 3. Tap checkbox -> Toggle complete
# 4. Tap todo item -> Detail screen
# 5. Swipe/pull down -> Refresh
# 6. Tap delete -> Confirmation dialog -> Delete
# 7. Filter chips -> All / Active / Completed
```

## GetX vs Riverpod -- Perbandingan Feature Maker

| Aspek | GetX | Riverpod |
|-------|------|----------|
| Controller | `GetxController` + `.obs` | `AsyncNotifier` + `@riverpod` |
| State | `RxList`, `RxBool`, `Rx<T?>` | `AsyncValue<List<T>>` |
| UI Binding | `Obx(() { ... })` | `.when(data:, error:, loading:)` |
| Screen Base | `GetView<Controller>` | `ConsumerWidget` |
| DI | `Bindings` + `Get.lazyPut()` | `@riverpod` annotation |
| Navigation | `Get.toNamed()` | `context.push()` |
| Routes | `GetPage` + `binding:` | `GoRoute` |
| Dialog | `Get.dialog()` | `showDialog(context:)` |
| Snackbar | `Get.snackbar()` | `ScaffoldMessenger` |
| Back | `Get.back()` | `context.pop()` |
| Model | Manual `fromJson/toJson` | `freezed` + code gen |
| Code Gen | **Tidak perlu** | `build_runner` wajib |
| Local Cache | `GetStorage` | `Hive` / `SharedPreferences` |

## Tools & Templates

- **Shimmer:** `shimmer` package untuk loading skeleton
- **Local Storage:** `GetStorage` (GetX ecosystem, bukan Hive)
- **HTTP Client:** `Dio` untuk API calls
- **Error Handling:** `dartz` (`Either<Failure, T>`) untuk functional error handling
- **Equality:** `equatable` untuk entity comparison
- **Code Generation:** **Tidak diperlukan** -- ini advantage utama GetX

## Next Steps

Setelah generate feature:
1. Implement business logic di use cases (jika pakai use case pattern)
2. Connect ke backend (REST API) -- lihat `03_backend_integration.md`
3. Add Firebase integration -- lihat `04_firebase_integration.md`
4. Add Supabase integration -- lihat `05_supabase_integration.md`
5. Add tests (unit, widget, integration) -- lihat `06_testing_production.md`
6. Add analytics tracking
7. Add translation/localization -- lihat `07_translation.md`

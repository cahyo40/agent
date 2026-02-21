---
description: Generate feature baru dengan struktur Clean Architecture lengkap menggunakan GetX pattern. (Part 3/10)
---
# Workflow: Flutter Feature Maker (GetX) (Part 3/10)

> **Navigation:** This workflow is split into 10 parts.

## Deliverables

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


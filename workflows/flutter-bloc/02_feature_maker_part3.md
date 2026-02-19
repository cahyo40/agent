---
description: Generate feature baru dengan struktur Clean Architecture lengkap menggunakan **flutter_bloc**. (Part 3/11)
---
# Workflow: Flutter BLoC Feature Maker (Part 3/11)

> **Navigation:** This workflow is split into 11 parts.

## Deliverables

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

## Deliverables

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

## Deliverables

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


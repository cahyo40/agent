---
description: Implementasi offline-first storage dengan Hive untuk cache, Isar untuk complex queries, dan flutter_secure_storage un...
---
# 10 - Offline Storage (Hive + Isar + SecureStorage)

**Goal:** Implementasi offline-first storage dengan Hive untuk cache, Isar untuk complex queries, dan flutter_secure_storage untuk sensitive data. Menggunakan `get_it` untuk DI.

**Output:** `sdlc/flutter-bloc/10-offline-storage/`

**Time Estimate:** 3-4 jam

---

## Install

```yaml
dependencies:
  hive_flutter: ^1.1.0
  isar_flutter_libs: ^3.1.0+1
  isar: ^3.1.0+1
  flutter_secure_storage: ^9.0.0
  connectivity_plus: ^6.0.0

dev_dependencies:
  isar_generator: ^3.1.0+1
```

---

## Deliverables

### 1. Hive Cache Service

**File:** `lib/core/storage/cache_service.dart`

```dart
import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class CacheService {
  static const _boxName = 'app_cache';
  static const _ttlPrefix = '_ttl_';

  Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox<String>(_boxName);
  }

  Box<String> get _box => Hive.box<String>(_boxName);

  Future<void> set<T>(
    String key,
    T data, {
    Duration ttl = const Duration(minutes: 30),
  }) async {
    final json = jsonEncode(data);
    final expiry = DateTime.now().add(ttl).millisecondsSinceEpoch;
    await _box.put(key, json);
    await _box.put('$_ttlPrefix$key', expiry.toString());
  }

  T? get<T>(String key, T Function(dynamic) fromJson) {
    final expiryStr = _box.get('$_ttlPrefix$key');
    if (expiryStr != null) {
      final expiry = int.parse(expiryStr);
      if (DateTime.now().millisecondsSinceEpoch > expiry) {
        _box.delete(key);
        _box.delete('$_ttlPrefix$key');
        return null;
      }
    }
    final json = _box.get(key);
    return json != null ? fromJson(jsonDecode(json)) : null;
  }

  Future<void> delete(String key) async {
    await _box.delete(key);
    await _box.delete('$_ttlPrefix$key');
  }

  Future<void> clear() => _box.clear();
}
```

---

### 2. Offline-First Repository

**File:** `lib/features/product/data/repositories/product_repository_impl.dart`

```dart
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/connectivity_cubit.dart';
import '../../../../core/storage/cache_service.dart';
import '../../domain/entities/product.dart';
import '../../domain/repositories/product_repository.dart';
import '../datasources/product_remote_datasource.dart';

@LazySingleton(as: ProductRepository)
class ProductRepositoryImpl implements ProductRepository {
  const ProductRepositoryImpl({
    required this.remote,
    required this.cache,
    required this.connectivity,
  });

  final ProductRemoteDataSource remote;
  final CacheService cache;
  final ConnectivityCubit connectivity;

  static const _cacheKey = 'products_list';

  @override
  Future<Either<Failure, List<Product>>> getProducts() async {
    if (connectivity.state.isConnected) {
      try {
        final products = await remote.getProducts();
        await cache.set(
          _cacheKey,
          products.map((p) => p.toJson()).toList(),
          ttl: const Duration(hours: 1),
        );
        return Right(products);
      } catch (e) {
        return _fromCache();
      }
    }
    return _fromCache();
  }

  Either<Failure, List<Product>> _fromCache() {
    final cached = cache.get<List<Product>>(
      _cacheKey,
      (json) => (json as List)
          .map((e) => Product.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
    if (cached != null) return Right(cached);
    return const Left(CacheFailure('No cached data available'));
  }
}
```

---

### 3. Isar Database (Complex Queries)

**File:** `lib/core/storage/isar_service.dart`

```dart
import 'package:injectable/injectable.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import '../../features/product/data/models/product_isar_model.dart';

@lazySingleton
class IsarService {
  late Isar _isar;

  Future<void> init() async {
    final dir = await getApplicationDocumentsDirectory();
    _isar = await Isar.open(
      [ProductIsarModelSchema],
      directory: dir.path,
    );
  }

  Isar get db => _isar;
}
```

**File:** `lib/features/product/data/models/product_isar_model.dart`

```dart
import 'package:isar/isar.dart';

part 'product_isar_model.g.dart';

@collection
class ProductIsarModel {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String serverId;

  late String name;
  late double price;
  late int stock;

  @Index()
  late String category;

  late DateTime updatedAt;
}
```

**File:** `lib/features/product/data/datasources/product_local_datasource.dart`

```dart
import 'package:injectable/injectable.dart';
import 'package:isar/isar.dart';
import '../../../../core/storage/isar_service.dart';
import '../models/product_isar_model.dart';

@lazySingleton
class ProductLocalDataSource {
  const ProductLocalDataSource(this._isarService);

  final IsarService _isarService;
  Isar get _db => _isarService.db;

  Future<List<ProductIsarModel>> getAll() =>
      _db.productIsarModels.where().findAll();

  Future<List<ProductIsarModel>> searchByName(String query) =>
      _db.productIsarModels
          .filter()
          .nameContains(query, caseSensitive: false)
          .findAll();

  Future<void> saveAll(List<ProductIsarModel> products) =>
      _db.writeTxn(() => _db.productIsarModels.putAll(products));

  Future<void> delete(String serverId) => _db.writeTxn(() async {
        final item = await _db.productIsarModels
            .filter()
            .serverIdEqualTo(serverId)
            .findFirst();
        if (item != null) await _db.productIsarModels.delete(item.id);
      });
}
```

---

### 4. Connectivity Cubit

**File:** `lib/core/network/connectivity_cubit.dart`

```dart
import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

part 'connectivity_state.dart';

@lazySingleton
class ConnectivityCubit extends Cubit<ConnectivityState> {
  ConnectivityCubit() : super(const ConnectivityState(isConnected: true)) {
    _subscription = Connectivity().onConnectivityChanged.listen((result) {
      emit(ConnectivityState(isConnected: result != ConnectivityResult.none));
    });
  }

  late final StreamSubscription _subscription;

  @override
  Future<void> close() {
    _subscription.cancel();
    return super.close();
  }
}
```

**File:** `lib/core/network/connectivity_state.dart`

```dart
part of 'connectivity_cubit.dart';

final class ConnectivityState extends Equatable {
  const ConnectivityState({required this.isConnected});
  final bool isConnected;

  @override
  List<Object?> get props => [isConnected];
}
```

---

### 5. Secure Storage

**File:** `lib/core/storage/secure_storage_service.dart`

```dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class SecureStorageService {
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );

  static const _accessTokenKey = 'access_token';
  static const _refreshTokenKey = 'refresh_token';

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await Future.wait([
      _storage.write(key: _accessTokenKey, value: accessToken),
      _storage.write(key: _refreshTokenKey, value: refreshToken),
    ]);
  }

  Future<String?> getAccessToken() => _storage.read(key: _accessTokenKey);
  Future<String?> getRefreshToken() => _storage.read(key: _refreshTokenKey);
  Future<void> clearAll() => _storage.deleteAll();
}
```

---

## Success Criteria
- Hive cache dengan TTL berfungsi
- Offline fallback ke cache saat tidak ada internet
- Isar full-text search berfungsi
- Secure storage encrypt tokens di device
- `ConnectivityCubit` reactive dengan `BlocBuilder`

## Next Steps
- `11_ui_components.md` - Reusable UI components

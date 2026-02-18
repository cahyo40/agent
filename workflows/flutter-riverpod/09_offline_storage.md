# 09 - Offline Storage (Hive + Isar + SecureStorage)

**Goal:** Implementasi offline-first storage dengan Hive untuk cache, Isar untuk complex queries, dan flutter_secure_storage untuk sensitive data.

**Output:** `sdlc/flutter-riverpod/09-offline-storage/`

**Time Estimate:** 3-4 jam

---

## Install

```yaml
# pubspec.yaml
dependencies:
  hive_flutter: ^1.1.0
  isar_flutter_libs: ^3.1.0+1
  isar: ^3.1.0+1
  flutter_secure_storage: ^9.0.0
  path_provider: ^2.1.2

dev_dependencies:
  isar_generator: ^3.1.0+1
  build_runner: ^2.4.9
```

---

## Deliverables

### 1. Hive Setup (Simple Cache)

**File:** `lib/core/storage/hive_storage.dart`

```dart
import 'package:hive_flutter/hive_flutter.dart';

/// Hive boxes untuk caching.
class HiveBoxes {
  static const products = 'products_cache';
  static const userProfile = 'user_profile';
  static const settings = 'app_settings';
}

/// Initialize Hive di bootstrap.
Future<void> initHive() async {
  await Hive.initFlutter();
  // Register adapters jika pakai custom types
  await Future.wait([
    Hive.openBox<String>(HiveBoxes.products),
    Hive.openBox<Map>(HiveBoxes.userProfile),
    Hive.openBox(HiveBoxes.settings),
  ]);
}
```

**File:** `lib/core/storage/cache_service.dart`

```dart
import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'cache_service.g.dart';

@riverpod
CacheService cacheService(Ref ref) => CacheService();

/// Generic cache service menggunakan Hive.
class CacheService {
  static const _ttlKey = '_ttl_';

  Box<String> get _box => Hive.box<String>(HiveBoxes.products);

  /// Save JSON data dengan TTL (time-to-live).
  Future<void> set<T>(
    String key,
    T data, {
    Duration ttl = const Duration(minutes: 30),
  }) async {
    final json = jsonEncode(data);
    final expiry = DateTime.now().add(ttl).millisecondsSinceEpoch;
    await _box.put(key, json);
    await _box.put('$_ttlKey$key', expiry.toString());
  }

  /// Get cached data, returns null jika expired.
  T? get<T>(String key, T Function(dynamic json) fromJson) {
    final expiryStr = _box.get('$_ttlKey$key');
    if (expiryStr != null) {
      final expiry = int.parse(expiryStr);
      if (DateTime.now().millisecondsSinceEpoch > expiry) {
        _box.delete(key);
        _box.delete('$_ttlKey$key');
        return null;
      }
    }
    final json = _box.get(key);
    if (json == null) return null;
    return fromJson(jsonDecode(json));
  }

  Future<void> delete(String key) async {
    await _box.delete(key);
    await _box.delete('$_ttlKey$key');
  }

  Future<void> clear() => _box.clear();
}
```

---

### 2. Offline-First Repository

**File:** `lib/features/product/data/repositories/product_repository_impl.dart`

```dart
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/connectivity_service.dart';
import '../../../../core/storage/cache_service.dart';
import '../../domain/entities/product.dart';
import '../../domain/repositories/product_repository.dart';
import '../datasources/product_remote_datasource.dart';

class ProductRepositoryImpl implements ProductRepository {
  const ProductRepositoryImpl({
    required this.remote,
    required this.cache,
    required this.connectivity,
  });

  final ProductRemoteDataSource remote;
  final CacheService cache;
  final ConnectivityService connectivity;

  static const _cacheKey = 'products_list';

  @override
  Future<Either<Failure, List<Product>>> getProducts() async {
    final isOnline = await connectivity.isConnected;

    if (isOnline) {
      try {
        final products = await remote.getProducts();
        // Save to cache
        await cache.set(
          _cacheKey,
          products.map((p) => p.toJson()).toList(),
          ttl: const Duration(hours: 1),
        );
        return Right(products);
      } catch (e) {
        // Fallback to cache on network error
        return _getFromCache();
      }
    } else {
      return _getFromCache();
    }
  }

  Either<Failure, List<Product>> _getFromCache() {
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
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../features/product/data/models/product_isar_model.dart';

part 'isar_service.g.dart';

@Riverpod(keepAlive: true)
Future<Isar> isarService(Ref ref) async {
  final dir = await getApplicationDocumentsDirectory();
  return Isar.open(
    [ProductIsarModelSchema],
    directory: dir.path,
  );
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

  @ignore
  bool get isLowStock => stock < 10;
}
```

**File:** `lib/features/product/data/datasources/product_local_datasource.dart`

```dart
import 'package:isar/isar.dart';
import '../models/product_isar_model.dart';

class ProductLocalDataSource {
  const ProductLocalDataSource(this._isar);

  final Isar _isar;

  Future<List<ProductIsarModel>> getAll() =>
      _isar.productIsarModels.where().findAll();

  Future<List<ProductIsarModel>> searchByName(String query) =>
      _isar.productIsarModels
          .filter()
          .nameContains(query, caseSensitive: false)
          .findAll();

  Future<List<ProductIsarModel>> getByCategory(String category) =>
      _isar.productIsarModels
          .filter()
          .categoryEqualTo(category)
          .sortByUpdatedAtDesc()
          .findAll();

  Future<void> saveAll(List<ProductIsarModel> products) =>
      _isar.writeTxn(() => _isar.productIsarModels.putAll(products));

  Future<void> delete(String serverId) => _isar.writeTxn(() async {
        final item = await _isar.productIsarModels
            .filter()
            .serverIdEqualTo(serverId)
            .findFirst();
        if (item != null) await _isar.productIsarModels.delete(item.id);
      });

  Future<void> clear() =>
      _isar.writeTxn(() => _isar.productIsarModels.clear());
}
```

---

### 4. Secure Storage (Sensitive Data)

**File:** `lib/core/storage/secure_storage_service.dart`

```dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'secure_storage_service.g.dart';

@Riverpod(keepAlive: true)
SecureStorageService secureStorageService(Ref ref) =>
    const SecureStorageService();

/// Secure storage untuk tokens dan sensitive data.
class SecureStorageService {
  const SecureStorageService();

  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );

  static const _accessTokenKey = 'access_token';
  static const _refreshTokenKey = 'refresh_token';
  static const _userIdKey = 'user_id';

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await Future.wait([
      _storage.write(key: _accessTokenKey, value: accessToken),
      _storage.write(key: _refreshTokenKey, value: refreshToken),
    ]);
  }

  Future<String?> getAccessToken() =>
      _storage.read(key: _accessTokenKey);

  Future<String?> getRefreshToken() =>
      _storage.read(key: _refreshTokenKey);

  Future<void> saveUserId(String userId) =>
      _storage.write(key: _userIdKey, value: userId);

  Future<String?> getUserId() => _storage.read(key: _userIdKey);

  Future<void> clearAll() => _storage.deleteAll();
}
```

---

### 5. Connectivity Service

**File:** `lib/core/network/connectivity_service.dart`

```dart
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'connectivity_service.g.dart';

@Riverpod(keepAlive: true)
ConnectivityService connectivityService(Ref ref) => ConnectivityService();

class ConnectivityService {
  final _connectivity = Connectivity();

  Future<bool> get isConnected async {
    final result = await _connectivity.checkConnectivity();
    return result != ConnectivityResult.none;
  }

  Stream<bool> get onConnectivityChanged =>
      _connectivity.onConnectivityChanged.map(
        (result) => result != ConnectivityResult.none,
      );
}

/// Provider untuk listen connectivity changes.
@Riverpod(keepAlive: true)
Stream<bool> connectivityStream(Ref ref) =>
    ref.watch(connectivityServiceProvider).onConnectivityChanged;
```

---

## Success Criteria
- Hive cache dengan TTL berfungsi
- Offline fallback ke cache saat tidak ada internet
- Isar full-text search berfungsi
- Secure storage encrypt tokens di device
- Connectivity stream reactive

## Next Steps
- `10_ui_components.md` - Reusable UI components

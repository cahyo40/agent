---
description: Implementasi offline-first storage dengan GetStorage untuk simple cache, Hive untuk complex data, dan flutter_secure_...
---
# 09 - Offline Storage (GetStorage + Hive + SecureStorage)

**Goal:** Implementasi offline-first storage dengan GetStorage untuk simple cache, Hive untuk complex data, dan flutter_secure_storage untuk sensitive data.

**Output:** `sdlc/flutter-getx/09-offline-storage/`

**Time Estimate:** 3-4 jam

---

## Install

```yaml
dependencies:
  get_storage: ^2.1.1          # GetX built-in storage
  hive_flutter: ^1.1.0         # Complex local DB
  flutter_secure_storage: ^9.0.0
  connectivity_plus: ^6.0.0
```

---

## Deliverables

### 1. GetStorage Service (Simple Cache)

**File:** `lib/core/storage/storage_service.dart`

```dart
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

/// Simple key-value storage menggunakan GetStorage.
class StorageService extends GetxService {
  late final GetStorage _box;

  static const _ttlPrefix = '_ttl_';

  Future<StorageService> init() async {
    await GetStorage.init();
    _box = GetStorage();
    return this;
  }

  /// Save data dengan optional TTL.
  Future<void> set<T>(
    String key,
    T value, {
    Duration? ttl,
  }) async {
    await _box.write(key, value);
    if (ttl != null) {
      final expiry = DateTime.now().add(ttl).millisecondsSinceEpoch;
      await _box.write('$_ttlPrefix$key', expiry);
    }
  }

  /// Get data, returns null jika expired.
  T? get<T>(String key) {
    final expiryMs = _box.read<int>('$_ttlPrefix$key');
    if (expiryMs != null &&
        DateTime.now().millisecondsSinceEpoch > expiryMs) {
      _box.remove(key);
      _box.remove('$_ttlPrefix$key');
      return null;
    }
    return _box.read<T>(key);
  }

  Future<void> remove(String key) async {
    await _box.remove(key);
    await _box.remove('$_ttlPrefix$key');
  }

  Future<void> clear() => _box.erase();

  bool has(String key) => _box.hasData(key);

  /// Listen to key changes reactively.
  void listenKey<T>(String key, void Function(T?) callback) {
    _box.listenKey(key, callback);
  }
}
```

**Register di main.dart:**

```dart
await Get.putAsync(() => StorageService().init());
```

---

### 2. Offline-First Repository

**File:** `lib/features/product/data/repositories/product_repository_impl.dart`

```dart
import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:get/get.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/storage/storage_service.dart';
import '../../../../core/network/connectivity_service.dart';
import '../../domain/entities/product.dart';
import '../../domain/repositories/product_repository.dart';
import '../datasources/product_remote_datasource.dart';

class ProductRepositoryImpl implements ProductRepository {
  const ProductRepositoryImpl({
    required this.remote,
    required this.storage,
    required this.connectivity,
  });

  final ProductRemoteDataSource remote;
  final StorageService storage;
  final ConnectivityService connectivity;

  static const _cacheKey = 'products_list';
  static const _cacheTtl = Duration(hours: 1);

  @override
  Future<Either<Failure, List<Product>>> getProducts() async {
    final isOnline = await connectivity.isConnected;

    if (isOnline) {
      try {
        final products = await remote.getProducts();
        // Save to cache
        await storage.set(
          _cacheKey,
          jsonEncode(products.map((p) => p.toJson()).toList()),
          ttl: _cacheTtl,
        );
        return Right(products);
      } catch (e) {
        return _fromCache();
      }
    } else {
      return _fromCache();
    }
  }

  Either<Failure, List<Product>> _fromCache() {
    final cached = storage.get<String>(_cacheKey);
    if (cached != null) {
      final list = (jsonDecode(cached) as List)
          .map((e) => Product.fromJson(e as Map<String, dynamic>))
          .toList();
      return Right(list);
    }
    return const Left(CacheFailure('No cached data available'));
  }
}
```

---

### 3. Hive Database (Complex Data)

**File:** `lib/core/storage/hive_service.dart`

```dart
import 'package:hive_flutter/hive_flutter.dart';
import 'package:get/get.dart';

class HiveService extends GetxService {
  static const _productsBox = 'products_db';

  Future<HiveService> init() async {
    await Hive.initFlutter();
    await Hive.openBox<Map>(_productsBox);
    return this;
  }

  Box<Map> get productsBox => Hive.box<Map>(_productsBox);
}
```

**File:** `lib/features/product/data/datasources/product_local_datasource.dart`

```dart
import 'package:hive_flutter/hive_flutter.dart';

class ProductLocalDataSource {
  const ProductLocalDataSource(this._box);

  final Box<Map> _box;

  List<Map> getAll() => _box.values.toList();

  Map? getById(String id) => _box.get(id);

  Future<void> saveAll(List<Map<String, dynamic>> products) async {
    final map = {for (final p in products) p['id'] as String: p};
    await _box.putAll(map);
  }

  Future<void> delete(String id) => _box.delete(id);

  Future<void> clear() => _box.clear();

  List<Map> search(String query) => _box.values
      .where((p) =>
          (p['name'] as String? ?? '')
              .toLowerCase()
              .contains(query.toLowerCase()))
      .toList();
}
```

---

### 4. Secure Storage (Tokens)

**File:** `lib/core/storage/secure_storage_service.dart`

```dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';

class SecureStorageService extends GetxService {
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

### 5. Connectivity Service

**File:** `lib/core/network/connectivity_service.dart`

```dart
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';

class ConnectivityService extends GetxService {
  final _connectivity = Connectivity();
  final isConnectedRx = true.obs;

  Future<ConnectivityService> init() async {
    final result = await _connectivity.checkConnectivity();
    isConnectedRx.value = result != ConnectivityResult.none;

    _connectivity.onConnectivityChanged.listen((result) {
      isConnectedRx.value = result != ConnectivityResult.none;
      if (isConnectedRx.value) {
        Get.snackbar('Back Online', 'Connection restored');
      }
    });

    return this;
  }

  Future<bool> get isConnected async {
    final result = await _connectivity.checkConnectivity();
    return result != ConnectivityResult.none;
  }
}
```

---

## Success Criteria
- GetStorage cache dengan TTL berfungsi
- Offline fallback ke cache saat tidak ada internet
- Hive search berfungsi
- Secure storage encrypt tokens di device
- Connectivity reactive dengan `isConnectedRx.obs`

## Next Steps
- `10_ui_components.md` - Reusable UI components

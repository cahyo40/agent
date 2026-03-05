---
description: Implementasi offline-first storage dengan Hive untuk cache, Drift untuk complex queries, dan flutter_secure_storage untuk sensitive data.
---
# Workflow: Offline Storage (Hive + Drift + SecureStorage)

// turbo-all

## Overview

Implementasi offline-first storage: Hive untuk simple cache dengan TTL, Drift
(SQLite) untuk complex queries dan relational data, dan flutter_secure_storage
untuk sensitive data seperti tokens.

> **⚠️ Note:** Workflow ini menggunakan **Drift** sebagai pengganti Isar.
> Isar sudah deprecated dan menyebabkan build errors pada Android namespace.
> Drift berbasis SQLite, stabil, dan memiliki type-safe query builder.


## Prerequisites

- Project setup dari `01_project_setup.md` selesai
- Riverpod configured


## Agent Behavior

- **Gunakan Drift** untuk structured/relational data — bukan Isar.
- **Gunakan Hive** untuk simple key-value cache saja.
- **Selalu set TTL** pada cache — default 30 menit.
- **Gunakan `Result<T>`** sealed class — bukan `dartz` `Either`.
- **Encrypt sensitive data** — gunakan flutter_secure_storage.


## Recommended Skills

- `senior-flutter-developer` — Offline patterns
- `senior-database-engineer-sql` — SQLite/Drift


## Workflow Steps

### Step 1: Add Dependencies

```yaml
# pubspec.yaml
dependencies:
  hive_flutter: ^1.1.0
  drift: ^2.22.0
  sqlite3_flutter_libs: ^0.5.28
  path_provider: ^2.1.2
  path: ^1.9.0
  flutter_secure_storage: ^9.2.0
  connectivity_plus: ^6.0.0

dev_dependencies:
  drift_dev: ^2.22.0
  build_runner: ^2.4.9
```

```bash
flutter pub get
```

### Step 2: Result Type (Sealed Class)

> Digunakan sebagai pengganti `dartz` `Either<Failure, T>`.

```dart
// lib/core/error/result.dart

/// Sealed class untuk menggantikan dartz Either.
sealed class Result<T> {
  const Result();
}

/// Representasi operasi yang berhasil.
final class Success<T> extends Result<T> {
  final T data;
  const Success(this.data);
}

/// Representasi operasi yang gagal.
final class Err<T> extends Result<T> {
  final Failure failure;
  const Err(this.failure);
}

/// Extension methods untuk Result.
extension ResultX<T> on Result<T> {
  /// Fold pattern — handle both success and error.
  R fold<R>(
    R Function(Failure failure) onError,
    R Function(T data) onSuccess,
  ) {
    return switch (this) {
      Success(:final data) => onSuccess(data),
      Err(:final failure) => onError(failure),
    };
  }

  /// Get data or null.
  T? get dataOrNull => switch (this) {
    Success(:final data) => data,
    Err() => null,
  };

  /// Get data or throw.
  T get dataOrThrow => switch (this) {
    Success(:final data) => data,
    Err(:final failure) => throw failure,
  };

  /// Check if result is success.
  bool get isSuccess => this is Success<T>;

  /// Check if result is error.
  bool get isError => this is Err<T>;

  /// Map the success value.
  Result<R> map<R>(R Function(T data) transform) {
    return switch (this) {
      Success(:final data) =>
          Success(transform(data)),
      Err(:final failure) => Err(failure),
    };
  }
}
```

### Step 3: Hive Setup (Simple Cache)

```dart
// lib/core/storage/hive_storage.dart
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
  await Future.wait([
    Hive.openBox<String>(HiveBoxes.products),
    Hive.openBox<Map>(HiveBoxes.userProfile),
    Hive.openBox(HiveBoxes.settings),
  ]);
}
```

```dart
// lib/core/storage/cache_service.dart
import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'cache_service.g.dart';

@riverpod
CacheService cacheService(Ref ref) =>
    CacheService();

/// Generic cache service menggunakan Hive.
class CacheService {
  static const _ttlKey = '_ttl_';

  Box<String> get _box =>
      Hive.box<String>(HiveBoxes.products);

  /// Save JSON data dengan TTL (time-to-live).
  Future<void> set<T>(
    String key,
    T data, {
    Duration ttl =
        const Duration(minutes: 30),
  }) async {
    final json = jsonEncode(data);
    final expiry = DateTime.now()
        .add(ttl)
        .millisecondsSinceEpoch;
    await _box.put(key, json);
    await _box.put(
      '$_ttlKey$key',
      expiry.toString(),
    );
  }

  /// Get cached data, returns null jika expired.
  T? get<T>(
    String key,
    T Function(dynamic json) fromJson,
  ) {
    final expiryStr = _box.get('$_ttlKey$key');
    if (expiryStr != null) {
      final expiry = int.parse(expiryStr);
      if (DateTime.now().millisecondsSinceEpoch >
          expiry) {
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

### Step 4: Drift Database (Complex Queries)

```dart
// lib/core/storage/app_database.dart
import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_database.g.dart';

/// Products table definition.
class Products extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  RealColumn get price => real()();
  IntColumn get stock =>
      integer().withDefault(const Constant(0))();
  TextColumn get category =>
      text().withDefault(const Constant(''))();
  TextColumn get description =>
      text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt =>
      dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// App database with Drift.
@DriftDatabase(tables: [Products])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) =>
          m.createAll(),
      onUpgrade: (Migrator m, int from, int to) async {
        // Handle schema migrations here
      },
    );
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder =
        await getApplicationDocumentsDirectory();
    final file = File(
      p.join(dbFolder.path, 'app_db.sqlite'),
    );
    return NativeDatabase.createInBackground(
      file,
    );
  });
}
```

```dart
// lib/core/di/database_providers.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../storage/app_database.dart';

part 'database_providers.g.dart';

@Riverpod(keepAlive: true)
AppDatabase appDatabase(Ref ref) {
  final db = AppDatabase();
  ref.onDispose(() => db.close());
  return db;
}
```

### Step 5: Product Local Data Source (Drift)

```dart
// lib/features/product/data/datasources/product_local_datasource.dart
import 'package:drift/drift.dart';
import '../../../../core/storage/app_database.dart';

class ProductLocalDataSource {
  const ProductLocalDataSource(this._db);

  final AppDatabase _db;

  /// Get all products.
  Future<List<Product>> getAll() =>
      _db.select(_db.products).get();

  /// Search by name (case-insensitive).
  Future<List<Product>> searchByName(
    String query,
  ) {
    return (_db.select(_db.products)
          ..where(
            (p) => p.name.like('%$query%'),
          ))
        .get();
  }

  /// Get products by category,
  /// sorted by updatedAt desc.
  Future<List<Product>> getByCategory(
    String category,
  ) {
    return (_db.select(_db.products)
          ..where(
            (p) => p.category.equals(category),
          )
          ..orderBy([
            (p) => OrderingTerm.desc(p.updatedAt),
          ]))
        .get();
  }

  /// Get products with pagination.
  Future<List<Product>> getPaginated({
    required int limit,
    required int offset,
  }) {
    return (_db.select(_db.products)
          ..orderBy([
            (p) => OrderingTerm.desc(p.createdAt),
          ])
          ..limit(limit, offset: offset))
        .get();
  }

  /// Get low stock products (stock < 10).
  Future<List<Product>> getLowStock() {
    return (_db.select(_db.products)
          ..where(
            (p) => p.stock.isSmallerThanValue(10),
          ))
        .get();
  }

  /// Watch all products (reactive stream).
  Stream<List<Product>> watchAll() =>
      _db.select(_db.products).watch();

  /// Save or update a single product.
  Future<void> upsert(
    ProductsCompanion product,
  ) {
    return _db
        .into(_db.products)
        .insertOnConflictUpdate(product);
  }

  /// Save multiple products in a batch.
  Future<void> saveAll(
    List<ProductsCompanion> products,
  ) {
    return _db.batch((batch) {
      batch.insertAllOnConflictUpdate(
        _db.products,
        products,
      );
    });
  }

  /// Delete by ID.
  Future<void> delete(String id) {
    return (_db.delete(_db.products)
          ..where((p) => p.id.equals(id)))
        .go();
  }

  /// Clear all products.
  Future<void> clear() =>
      _db.delete(_db.products).go();
}
```

### Step 6: Offline-First Repository (with Result<T>)

```dart
// lib/features/product/data/repositories/product_repository_impl.dart
import '../../../../core/error/failures.dart';
import '../../../../core/error/result.dart';
import '../../../../core/network/connectivity_service.dart';
import '../../../../core/storage/cache_service.dart';
import '../../domain/entities/product.dart';
import '../../domain/repositories/product_repository.dart';
import '../datasources/product_remote_datasource.dart';
import '../datasources/product_local_datasource.dart';

class ProductRepositoryImpl
    implements ProductRepository {
  const ProductRepositoryImpl({
    required this.remote,
    required this.local,
    required this.cache,
    required this.connectivity,
  });

  final ProductRemoteDataSource remote;
  final ProductLocalDataSource local;
  final CacheService cache;
  final ConnectivityService connectivity;

  @override
  Future<Result<List<Product>>>
      getProducts() async {
    final isOnline =
        await connectivity.isConnected;

    if (isOnline) {
      try {
        final products =
            await remote.getProducts();
        // Sync to local DB
        await local.saveAll(
          products
              .map((p) => p.toCompanion())
              .toList(),
        );
        return Success(products);
      } catch (e) {
        // Fallback to local DB on error
        return _getFromLocal();
      }
    } else {
      return _getFromLocal();
    }
  }

  Future<Result<List<Product>>>
      _getFromLocal() async {
    try {
      final localProducts =
          await local.getAll();
      if (localProducts.isNotEmpty) {
        return Success(
          localProducts
              .map((p) => p.toEntity())
              .toList(),
        );
      }
      return const Err(
        CacheFailure('No cached data available'),
      );
    } catch (e) {
      return const Err(
        CacheFailure('Failed to read local data'),
      );
    }
  }

  @override
  Future<Result<List<Product>>>
      searchProducts(String query) async {
    try {
      final results =
          await local.searchByName(query);
      return Success(
        results
            .map((p) => p.toEntity())
            .toList(),
      );
    } catch (e) {
      return const Err(
        CacheFailure('Search failed'),
      );
    }
  }
}
```

### Step 7: Secure Storage (Sensitive Data)

```dart
// lib/core/storage/secure_storage_service.dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'secure_storage_service.g.dart';

@Riverpod(keepAlive: true)
SecureStorageService secureStorageService(
  Ref ref,
) => const SecureStorageService();

/// Secure storage untuk tokens dan sensitive data.
class SecureStorageService {
  const SecureStorageService();

  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility:
          KeychainAccessibility.first_unlock,
    ),
  );

  static const _accessTokenKey = 'access_token';
  static const _refreshTokenKey = 'refresh_token';
  static const _userIdKey = 'user_id';

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await Future.wait([
      _storage.write(
        key: _accessTokenKey,
        value: accessToken,
      ),
      _storage.write(
        key: _refreshTokenKey,
        value: refreshToken,
      ),
    ]);
  }

  Future<String?> getAccessToken() =>
      _storage.read(key: _accessTokenKey);

  Future<String?> getRefreshToken() =>
      _storage.read(key: _refreshTokenKey);

  Future<void> saveUserId(String userId) =>
      _storage.write(
        key: _userIdKey,
        value: userId,
      );

  Future<String?> getUserId() =>
      _storage.read(key: _userIdKey);

  Future<void> clearAll() =>
      _storage.deleteAll();
}
```

### Step 8: Connectivity Service

```dart
// lib/core/network/connectivity_service.dart
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'connectivity_service.g.dart';

@Riverpod(keepAlive: true)
ConnectivityService connectivityService(
  Ref ref,
) => ConnectivityService();

class ConnectivityService {
  final _connectivity = Connectivity();

  Future<bool> get isConnected async {
    final results =
        await _connectivity.checkConnectivity();
    return results.isNotEmpty &&
        !results.contains(ConnectivityResult.none);
  }

  Stream<bool> get onConnectivityChanged =>
      _connectivity.onConnectivityChanged.map(
        (results) =>
            results.isNotEmpty &&
            !results.contains(
              ConnectivityResult.none,
            ),
      );
}

/// Provider untuk listen connectivity changes.
@Riverpod(keepAlive: true)
Stream<bool> connectivityStream(Ref ref) =>
    ref
        .watch(connectivityServiceProvider)
        .onConnectivityChanged;
```

### Step 9: Run Code Generation

```bash
dart run build_runner build -d
```


## Success Criteria

- [ ] Hive cache dengan TTL berfungsi
- [ ] Offline fallback ke local DB saat tidak ada internet
- [ ] Drift queries berfungsi (search, filter, sort, pagination)
- [ ] Drift reactive streams (`watchAll()`) berfungsi
- [ ] Secure storage encrypt tokens di device
- [ ] Connectivity stream reactive
- [ ] `Result<T>` sealed class digunakan (bukan `dartz`)
- [ ] Code generation berhasil tanpa error
- [ ] No build errors (isar removed)


## Migration Notes

### Dari Isar ke Drift

| Isar | Drift |
|------|-------|
| `@collection` annotation | `extends Table` |
| `Isar.open()` | `NativeDatabase` |
| `.filter().nameContains()` | `.where((p) => p.name.like('%..%'))` |
| `.sortByUpdatedAtDesc()` | `OrderingTerm.desc(p.updatedAt)` |
| `isar.writeTxn()` | `db.batch()` or direct operations |
| Schema via code gen | Schema via Dart table classes |

### Dari dartz ke sealed classes

| dartz | Sealed Class |
|-------|-------------|
| `Either<Failure, T>` | `Result<T>` |
| `Right(value)` | `Success(value)` |
| `Left(failure)` | `Err(failure)` |
| `result.fold(onLeft, onRight)` | `result.fold(onError, onSuccess)` |
| `result.getOrElse(() => default)` | `result.dataOrNull ?? default` |


## Next Steps

Setelah offline storage selesai:
1. `10_ui_components.md` — Reusable UI components
2. `11_push_notifications.md` — FCM + local notifications

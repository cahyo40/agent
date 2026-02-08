# Repository Pattern with Offline-First

## Abstract Repository Contract (Domain Layer)

```dart
abstract interface class ProductRepository {
  Future<Either<Failure, List<Product>>> getProducts();
  Future<Either<Failure, Product>> getProduct(String id);
  Stream<List<Product>> watchProducts();
}
```

## Implementation with Offline-First Strategy (Data Layer)

```dart
class ProductRepositoryImpl implements ProductRepository {
  ProductRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
    required this.syncQueue,
  });

  final ProductRemoteDataSource remoteDataSource;
  final ProductLocalDataSource localDataSource;
  final NetworkInfo networkInfo;
  final SyncQueue syncQueue;

  @override
  Future<Either<Failure, List<Product>>> getProducts() async {
    // Strategy: Return local first, sync in background
    try {
      final localProducts = await localDataSource.getProducts();
      
      // Background sync if online
      if (await networkInfo.isConnected) {
        _syncInBackground();
      }

      return Right(localProducts.map((m) => m.toEntity()).toList());
    } on CacheException catch (e) {
      // No local data, try remote
      if (await networkInfo.isConnected) {
        return _fetchFromRemote();
      }
      return Left(CacheFailure(e.message));
    }
  }

  Future<void> _syncInBackground() async {
    try {
      final remoteProducts = await remoteDataSource.getProducts();
      await localDataSource.cacheProducts(remoteProducts);
    } catch (_) {
      // Silent fail for background sync
    }
  }

  @override
  Stream<List<Product>> watchProducts() {
    return localDataSource.watchProducts().map(
      (models) => models.map((m) => m.toEntity()).toList(),
    );
  }
}
```

## Either Pattern for Error Handling

```dart
sealed class Either<L, R> {
  const Either();
  
  T fold<T>(T Function(L) onLeft, T Function(R) onRight);
  Either<L, T> map<T>(T Function(R) f);
  Future<Either<L, T>> mapAsync<T>(Future<T> Function(R) f);
}

class Left<L, R> extends Either<L, R> {
  const Left(this.value);
  final L value;

  @override
  T fold<T>(T Function(L) onLeft, T Function(R) onRight) => onLeft(value);

  @override
  Either<L, T> map<T>(T Function(R) f) => Left(value);

  @override
  Future<Either<L, T>> mapAsync<T>(Future<T> Function(R) f) async => Left(value);
}

class Right<L, R> extends Either<L, R> {
  const Right(this.value);
  final R value;

  @override
  T fold<T>(T Function(L) onLeft, T Function(R) onRight) => onRight(value);

  @override
  Either<L, T> map<T>(T Function(R) f) => Right(f(value));

  @override
  Future<Either<L, T>> mapAsync<T>(Future<T> Function(R) f) async => Right(await f(value));
}
```

## Usage in Controller

```dart
Future<void> loadProducts() async {
  state = const AsyncLoading();
  final result = await ref.read(productRepositoryProvider).getProducts();
  
  state = result.fold(
    (failure) => AsyncError(failure, StackTrace.current),
    (products) => AsyncData(products),
  );
}
```

## Failure Classes

```dart
abstract class Failure {
  const Failure([this.message = '']);
  final String message;
}

class ServerFailure extends Failure {
  const ServerFailure([super.message]);
}

class CacheFailure extends Failure {
  const CacheFailure([super.message]);
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'No internet connection']);
}
```

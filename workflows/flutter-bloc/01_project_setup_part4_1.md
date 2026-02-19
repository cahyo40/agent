---
description: Setup Flutter project dari nol dengan Clean Architecture dan BLoC state management. (Sub-part 1/4)
---
# Workflow: Flutter Project Setup with BLoC (Part 4/6)

> **Navigation:** This workflow is split into 6 parts.

## Deliverables

### 4. Example Feature Implementation - Product (Full BLoC Pattern)

**Description:** Contoh feature lengkap dengan CRUD operations menggunakan BLoC.

**Recommended Skills:** `senior-flutter-developer`

**Instructions:**

#### 4a. Domain Layer

```dart
// features/product/domain/entities/product.dart
import 'package:equatable/equatable.dart';

class Product extends Equatable {
  final String id;
  final String name;
  final String description;
  final double price;
  final String? imageUrl;
  final DateTime createdAt;

  const Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.imageUrl,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, name, description, price, imageUrl, createdAt];
}
```

```dart
// features/product/domain/repositories/product_repository.dart
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/product.dart';

abstract class ProductRepository {
  Future<Either<Failure, List<Product>>> getProducts();
  Future<Either<Failure, Product>> getProduct(String id);
  Future<Either<Failure, Product>> createProduct({
    required String name,
    required String description,
    required double price,
    String? imageUrl,
  });
  Future<Either<Failure, void>> deleteProduct(String id);
}
```

```dart
// features/product/domain/usecases/get_products.dart
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/product.dart';
import '../repositories/product_repository.dart';

@injectable
class GetProducts extends UseCaseNoParams<List<Product>> {
  final ProductRepository repository;

  GetProducts(this.repository);

  @override
  Future<Either<Failure, List<Product>>> call() {
    return repository.getProducts();
  }
}
```

```dart
// features/product/domain/usecases/create_product.dart
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/product.dart';
import '../repositories/product_repository.dart';

@injectable
class CreateProduct extends UseCase<Product, CreateProductParams> {
  final ProductRepository repository;

  CreateProduct(this.repository);

  @override
  Future<Either<Failure, Product>> call(CreateProductParams params) {
    return repository.createProduct(
      name: params.name,
      description: params.description,
      price: params.price,
      imageUrl: params.imageUrl,
    );
  }
}

class CreateProductParams extends Equatable {
  final String name;
  final String description;
  final double price;
  final String? imageUrl;

  const CreateProductParams({
    required this.name,
    required this.description,
    required this.price,
    this.imageUrl,
  });

  @override
  List<Object?> get props => [name, description, price, imageUrl];
}
```

```dart
// features/product/domain/usecases/delete_product.dart
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/product_repository.dart';

@injectable
class DeleteProduct extends UseCase<void, String> {
  final ProductRepository repository;

  DeleteProduct(this.repository);

  @override
  Future<Either<Failure, void>> call(String id) {
    return repository.deleteProduct(id);
  }
}
```


#### 4b. Data Layer

```dart
// features/product/data/models/product_model.dart
import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/product.dart';

part 'product_model.g.dart';

@JsonSerializable()
class ProductModel extends Product {
  const ProductModel({
    required super.id,
    required super.name,
    required super.description,
    required super.price,
    super.imageUrl,
    required super.createdAt,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) =>
      _$ProductModelFromJson(json);

  Map<String, dynamic> toJson() => _$ProductModelToJson(this);

  factory ProductModel.fromEntity(Product product) {
    return ProductModel(
      id: product.id,
      name: product.name,
      description: product.description,
      price: product.price,
      imageUrl: product.imageUrl,
      createdAt: product.createdAt,
    );
  }
}
```

```dart
// features/product/data/datasources/product_remote_datasource.dart
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/exceptions.dart';
import '../models/product_model.dart';

@lazySingleton
class ProductRemoteDataSource {
  final Dio _dio;

  ProductRemoteDataSource(this._dio);

  Future<List<ProductModel>> getProducts() async {
    try {
      final response = await _dio.get('/products');
      return (response.data as List)
          .map((json) => ProductModel.fromJson(json))
          .toList();
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data?['message'] ?? 'Failed to fetch products',
        statusCode: e.response?.statusCode,
      );
    }
  }

  Future<ProductModel> getProduct(String id) async {
    try {
      final response = await _dio.get('/products/$id');
      return ProductModel.fromJson(response.data);
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data?['message'] ?? 'Failed to fetch product',
        statusCode: e.response?.statusCode,
      );
    }
  }

  Future<ProductModel> createProduct(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post('/products', data: data);
      return ProductModel.fromJson(response.data);
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data?['message'] ?? 'Failed to create product',
        statusCode: e.response?.statusCode,
      );
    }
  }

  Future<void> deleteProduct(String id) async {
    try {
      await _dio.delete('/products/$id');
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data?['message'] ?? 'Failed to delete product',
        statusCode: e.response?.statusCode,
      );
    }
  }
}
```

```dart
// features/product/data/repositories/product_repository_impl.dart
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/product.dart';
import '../../domain/repositories/product_repository.dart';
import '../datasources/product_remote_datasource.dart';

@LazySingleton(as: ProductRepository)
class ProductRepositoryImpl implements ProductRepository {
  final ProductRemoteDataSource remoteDataSource;

  ProductRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, List<Product>>> getProducts() async {
    try {
      final products = await remoteDataSource.getProducts();
      return Right(products);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on NetworkException {
      return const Left(NetworkFailure());
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Product>> getProduct(String id) async {
    try {
      final product = await remoteDataSource.getProduct(id);
      return Right(product);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Product>> createProduct({
    required String name,
    required String description,
    required double price,
    String? imageUrl,
  }) async {
    try {
      final product = await remoteDataSource.createProduct({
        'name': name,
        'description': description,
        'price': price,
        'imageUrl': imageUrl,
      });
      return Right(product);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteProduct(String id) async {
    try {
      await remoteDataSource.deleteProduct(id);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
```


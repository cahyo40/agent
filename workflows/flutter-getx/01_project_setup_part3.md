---
description: Setup Flutter project dari nol dengan Clean Architecture dan GetX state management. (Part 3/4)
---
# Workflow: Flutter Project Setup with GetX (Part 3/4)

> **Navigation:** This workflow is split into 4 parts.

## Deliverables

### 3. Example Feature Implementation

**Description:** Contoh feature lengkap dengan GetX pattern.

**Recommended Skills:** `senior-flutter-developer`

**Instructions:**
1. **Domain Layer:**
   - Buat `Product` entity
   - Buat `ProductRepository` interface

2. **Data Layer:**
   - Buat `ProductModel`
   - Implement `ProductRepositoryImpl`
   - Setup API provider

3. **Feature Layer (GetX Pattern):**
   - Controller dengan reactive state (.obs)
   - Binding untuk DI
   - View dengan Obx/GetBuilder

**Output Format:**
```dart
// lib/domain/entities/product.dart
class Product extends Equatable {
  final String id;
  final String name;
  final double price;
  final String? description;
  final DateTime createdAt;
  
  const Product({
    required this.id,
    required this.name,
    required this.price,
    this.description,
    required this.createdAt,
  });
  
  @override
  List<Object?> get props => [id, name, price, description, createdAt];
}

// lib/domain/repositories/product_repository.dart
abstract class ProductRepository {
  Future<Either<Failure, List<Product>>> getProducts();
  Future<Either<Failure, Product>> getProductById(String id);
  Future<Either<Failure, Product>> createProduct(Product product);
  Future<Either<Failure, Product>> updateProduct(Product product);
  Future<Either<Failure, Unit>> deleteProduct(String id);
}

// lib/data/models/product_model.dart
class ProductModel {
  final String id;
  final String name;
  final double price;
  final String? description;
  final DateTime createdAt;
  
  ProductModel({
    required this.id,
    required this.name,
    required this.price,
    this.description,
    required this.createdAt,
  });
  
  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'],
      name: json['name'],
      price: json['price'].toDouble(),
      description: json['description'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'description': description,
      'created_at': createdAt.toIso8601String(),
    };
  }
  
  Product toEntity() {
    return Product(
      id: id,
      name: name,
      price: price,
      description: description,
      createdAt: createdAt,
    );
  }
}

// lib/features/products/controllers/product_controller.dart
import 'package:get/get.dart';
import '../../../domain/entities/product.dart';
import '../../../domain/repositories/product_repository.dart';

class ProductController extends GetxController {
  final ProductRepository _repository = Get.find();
  
  // Reactive state variables
  final RxList<Product> products = <Product>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final Rx<Product?> selectedProduct = Rx<Product?>(null);
  
  @override
  void onInit() {
    super.onInit();
    fetchProducts();
  }
  
  Future<void> fetchProducts() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      
      final result = await _repository.getProducts();
      
      result.fold(
        (failure) {
          errorMessage.value = failure.message;
        },
        (data) {
          products.assignAll(data);
        },
      );
    } finally {
      isLoading.value = false;
    }
  }
  
  Future<void> createProduct(String name, double price) async {
    try {
      isLoading.value = true;
      
      final newProduct = Product(
        id: '',
        name: name,
        price: price,
        createdAt: DateTime.now(),
      );
      
      final result = await _repository.createProduct(newProduct);
      
      result.fold(
        (failure) {
          Get.snackbar(
            'Error',
            failure.message,
            snackPosition: SnackPosition.BOTTOM,
          );
        },
        (product) {
          products.add(product);
          Get.back(); // Close dialog/form
          Get.snackbar(
            'Success',
            'Product created successfully',
            snackPosition: SnackPosition.BOTTOM,
          );
        },
      );
    } finally {
      isLoading.value = false;
    }
  }
  
  Future<void> deleteProduct(String id) async {
    try {
      final result = await _repository.deleteProduct(id);
      
      result.fold(
        (failure) {
          Get.snackbar('Error', failure.message);
        },
        (_) {
          products.removeWhere((p) => p.id == id);
          Get.snackbar('Success', 'Product deleted');
        },
      );
    } catch (e) {
      Get.snackbar('Error', e.toString());
    }
  }
  
  void selectProduct(Product product) {
    selectedProduct.value = product;
  }
  
  void clearSelectedProduct() {
    selectedProduct.value = null;
  }
}

// lib/features/products/bindings/product_binding.dart
import 'package:get/get.dart';
import '../controllers/product_controller.dart';
import '../../../data/repositories/product_repository_impl.dart';
import '../../../domain/repositories/product_repository.dart';

class ProductBinding extends Bindings {
  @override
  void dependencies() {
    // Repository
    Get.lazyPut<ProductRepository>(
      () => ProductRepositoryImpl(),
    );
    
    // Controller
    Get.lazyPut<ProductController>(
      () => ProductController(),
    );
  }
}

// lib/features/products/views/product_list_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../routes/app_routes.dart';
import '../controllers/product_controller.dart';
import '../widgets/product_shimmer.dart';

class ProductListView extends GetView<ProductController> {
  const ProductListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Products'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: controller.fetchProducts,
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.products.isEmpty) {
          return const ProductShimmerList();
        }
        
        if (controller.errorMessage.value.isNotEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(controller.errorMessage.value),
                ElevatedButton(
                  onPressed: controller.fetchProducts,
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }
        
        if (controller.products.isEmpty) {
          return const Center(child: Text('No products available'));
        }
        
        return RefreshIndicator(
          onRefresh: controller.fetchProducts,
          child: ListView.builder(
            itemCount: controller.products.length,
            itemBuilder: (context, index) {
              final product = controller.products[index];
              return ListTile(
                title: Text(product.name),
                subtitle: Text('\$${product.price}'),
                onTap: () {
                  controller.selectProduct(product);
                  Get.toNamed(AppRoutes.productDetailPath(product.id));
                },
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => _confirmDelete(product.id),
                ),
              );
            },
          ),
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.toNamed('${AppRoutes.products}/create'),
        child: const Icon(Icons.add),
      ),
    );
  }
  
  void _confirmDelete(String id) {
    Get.dialog(
      AlertDialog(
        title: const Text('Delete Product'),
        content: const Text('Are you sure?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              controller.deleteProduct(id);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
```

---

## Deliverables

### 4. Error Handling

**Description:** Setup error handling dengan GetX.

**Output Format:**
```dart
// lib/core/error/failures.dart
abstract class Failure {
  final String message;
  const Failure(this.message);
}

class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Server error']);
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'No internet connection']);
}

class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Cache error']);
}

// lib/core/error/exceptions.dart
class ServerException implements Exception {
  final String message;
  ServerException([this.message = 'Server error']);
}

class NetworkException implements Exception {
  final String message;
  NetworkException([this.message = 'No internet connection']);
}

// lib/core/widgets/error_view.dart
class ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  
  const ErrorView({
    super.key,
    required this.message,
    required this.onRetry,
  });
  
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.red),
          const SizedBox(height: 16),
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: onRetry,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}
```


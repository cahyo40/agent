---
description: Setup Flutter project dari nol dengan Clean Architecture, GetX, dan YoUI. (Part 3/5)
---
# Workflow: Flutter Project Setup with GetX + YoUI (Part 3/5)

> **Navigation:** This workflow is split into 5 parts.

## Deliverables

### 3. Example Feature Implementation

**Description:** Contoh feature lengkap dengan GetX pattern dan YoUI widgets.

**Recommended Skills:** `senior-flutter-developer`

**Instructions:**
1. **Domain Layer:**
   - Buat `Product` entity
   - Buat `ProductRepository` interface

2. **Data Layer:**
   - Buat `ProductModel`
   - Implement `ProductRepositoryImpl`
   - Setup API provider

3. **Feature Layer (GetX + YoUI Pattern):**
   - Controller dengan reactive state (.obs)
   - Binding untuk DI
   - View dengan `YoCard`, `YoButton`, `YoShimmer`, `YoToast`

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
  List<Object?> get props =>
      [id, name, price, description, createdAt];
}

// lib/domain/repositories/product_repository.dart
abstract class ProductRepository {
  Future<Either<Failure, List<Product>>> getProducts();
  Future<Either<Failure, Product>> getProductById(
    String id,
  );
  Future<Either<Failure, Product>> createProduct(
    Product product,
  );
  Future<Either<Failure, Product>> updateProduct(
    Product product,
  );
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
  
  factory ProductModel.fromJson(
    Map<String, dynamic> json,
  ) {
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
  final Rx<Product?> selectedProduct =
      Rx<Product?>(null);
  
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
  
  Future<void> createProduct(
    String name,
    double price,
  ) async {
    try {
      isLoading.value = true;
      
      final newProduct = Product(
        id: '',
        name: name,
        price: price,
        createdAt: DateTime.now(),
      );
      
      final result =
          await _repository.createProduct(newProduct);
      
      result.fold(
        (failure) {
          // YoToast akan dipanggil dari View
          errorMessage.value = failure.message;
        },
        (product) {
          products.add(product);
          Get.back();
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
          errorMessage.value = failure.message;
        },
        (_) {
          products.removeWhere((p) => p.id == id);
        },
      );
    } catch (e) {
      errorMessage.value = e.toString();
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
    Get.lazyPut<ProductRepository>(
      () => ProductRepositoryImpl(),
    );
    Get.lazyPut<ProductController>(
      () => ProductController(),
    );
  }
}

// lib/features/products/views/product_list_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yo_ui/yo_ui.dart';
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
        // Loading state — YoUI Shimmer
        if (controller.isLoading.value &&
            controller.products.isEmpty) {
          return ListView.builder(
            itemCount: 5,
            padding: const EdgeInsets.all(16),
            itemBuilder: (context, index) =>
                Padding(
              padding:
                  const EdgeInsets.only(bottom: 8),
              child: YoShimmer.card(height: 80),
            ),
          );
        }
        
        // Error state — YoUI Button
        if (controller
            .errorMessage.value.isNotEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 48,
                    color: Theme.of(context)
                        .colorScheme
                        .error,
                  ),
                  const SizedBox(height: 16),
                  YoText.bodyMedium(
                    controller.errorMessage.value,
                  ),
                  const SizedBox(height: 16),
                  YoButton.primary(
                    text: 'Retry',
                    onPressed:
                        controller.fetchProducts,
                  ),
                ],
              ),
            ),
          );
        }
        
        // Empty state
        if (controller.products.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.inventory_2_outlined,
                  size: 48,
                  color: Theme.of(context)
                      .colorScheme
                      .onSurfaceVariant,
                ),
                const SizedBox(height: 16),
                YoText.titleMedium(
                  'No products available',
                ),
                const SizedBox(height: 8),
                YoText.bodyMedium(
                  'Add your first product',
                ),
                const SizedBox(height: 24),
                YoButton.primary(
                  text: 'Add Product',
                  onPressed: () => Get.toNamed(
                    '${AppRoutes.products}/create',
                  ),
                ),
              ],
            ),
          );
        }
        
        // Data state — YoUI Card
        return RefreshIndicator(
          onRefresh: controller.fetchProducts,
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: controller.products.length,
            itemBuilder: (context, index) {
              final product =
                  controller.products[index];
              return Padding(
                padding: const EdgeInsets.only(
                  bottom: 8,
                ),
                child: YoCard(
                  onTap: () {
                    controller
                        .selectProduct(product);
                    Get.toNamed(
                      AppRoutes.productDetailPath(
                        product.id,
                      ),
                    );
                  },
                  child: ListTile(
                    title: YoText.titleSmall(
                      product.name,
                    ),
                    subtitle: YoText.bodySmall(
                      '\$${product.price}',
                    ),
                    trailing: IconButton(
                      icon: const Icon(
                        Icons.delete,
                        color: Colors.red,
                      ),
                      onPressed: () =>
                          _confirmDelete(
                        context,
                        product.id,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.toNamed(
          '${AppRoutes.products}/create',
        ),
        child: const Icon(Icons.add),
      ),
    );
  }
  
  void _confirmDelete(
    BuildContext context,
    String id,
  ) {
    Get.dialog(
      AlertDialog(
        title: const Text('Delete Product'),
        content: const Text('Are you sure?'),
        actions: [
          YoButton.ghost(
            text: 'Cancel',
            onPressed: () => Get.back(),
          ),
          YoButton.primary(
            text: 'Delete',
            onPressed: () {
              Get.back();
              controller.deleteProduct(id);
              YoToast.success(
                context: context,
                message: 'Product deleted',
              );
            },
            backgroundColor: Theme.of(context)
                .colorScheme
                .error,
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

**Description:** Setup error handling terstruktur.

**Output Format:**
```dart
// lib/core/error/failures.dart
abstract class Failure {
  final String message;
  const Failure(this.message);
}

class ServerFailure extends Failure {
  const ServerFailure(
    [super.message = 'Server error'],
  );
}

class NetworkFailure extends Failure {
  const NetworkFailure(
    [super.message = 'No internet connection'],
  );
}

class CacheFailure extends Failure {
  const CacheFailure(
    [super.message = 'Cache error'],
  );
}

// lib/core/error/exceptions.dart
class ServerException implements Exception {
  final String message;
  ServerException([this.message = 'Server error']);
}

class NetworkException implements Exception {
  final String message;
  NetworkException(
    [this.message = 'No internet connection'],
  );
}

// lib/core/widgets/error_view.dart
import 'package:flutter/material.dart';
import 'package:yo_ui/yo_ui.dart';

/// Error state widget menggunakan YoUI components.
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
    final colorScheme = Theme.of(context).colorScheme;
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: colorScheme.errorContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline,
                size: 40,
                color: colorScheme.onErrorContainer,
              ),
            ),
            const SizedBox(height: 16),
            YoText.titleMedium(
              'Something went wrong',
            ),
            const SizedBox(height: 8),
            YoText.bodyMedium(message),
            const SizedBox(height: 24),
            YoButton.primary(
              text: 'Retry',
              onPressed: onRetry,
            ),
          ],
        ),
      ),
    );
  }
}

// lib/core/widgets/empty_state_view.dart
import 'package:flutter/material.dart';
import 'package:yo_ui/yo_ui.dart';

/// Empty state widget menggunakan YoUI components.
class EmptyStateView extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final String? actionLabel;
  final VoidCallback? onAction;
  
  const EmptyStateView({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    this.actionLabel,
    this.onAction,
  });
  
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: colorScheme
                    .surfaceContainerHighest,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 40,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            YoText.titleMedium(title),
            const SizedBox(height: 8),
            YoText.bodyMedium(description),
            if (actionLabel != null &&
                onAction != null) ...[
              const SizedBox(height: 24),
              YoButton.primary(
                text: actionLabel!,
                onPressed: onAction!,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
```

---

---
description: Setup Flutter project dari nol dengan Clean Architecture dan Riverpod state management. (Part 4/5)
---
# Workflow: Flutter Project Setup with Riverpod (Part 4/5)

> **Navigation:** This workflow is split into 5 parts.

## Deliverables

### 3. Example Feature Implementation

**Description:** Contoh feature lengkap dengan CRUD operations menggunakan Riverpod.

**Recommended Skills:** `senior-flutter-developer`

**Instructions:**
1. **Domain Layer:**
   - Buat `Product` entity
   - Buat `ProductRepository` abstract contract
   - Buat `GetProducts` use case

2. **Data Layer:**
   - Buat `ProductModel` dengan JSON serialization
   - Implement `ProductRepositoryImpl`
   - Setup remote & local data sources

3. **Presentation Layer:**
   - Buat `ProductController` dengan Riverpod
   - Buat `ProductListScreen` dengan states
   - Implement loading, error, empty, dan data states
   - **Implement navigation menggunakan GoRouter**

**Output Format:**
```dart
// features/product/domain/entities/product.dart
class Product extends Equatable {
  final String id;
  final String name;
  final double price;
  
  const Product({
    required this.id,
    required this.name,
    required this.price,
  });
  
  @override
  List<Object?> get props => [id, name, price];
}

// features/product/domain/repositories/product_repository.dart
abstract class ProductRepository {
  Future<Either<Failure, List<Product>>> getProducts();
  Future<Either<Failure, Product>> getProduct(String id);
}

// features/product/presentation/controllers/product_controller.dart
@riverpod
class ProductController extends _$ProductController {
  @override
  FutureOr<List<Product>> build() async {
    final repository = ref.watch(productRepositoryProvider);
    final result = await repository.getProducts();
    
    return result.fold(
      (failure) => throw failure,
      (products) => products,
    );
  }
  
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(productRepositoryProvider);
      final result = await repository.getProducts();
      return result.getOrElse(() => []);
    });
  }
}

// features/product/presentation/screens/product_list_screen.dart
import 'package:go_router/go_router.dart';
import '../../../../core/router/routes.dart';

class ProductListScreen extends ConsumerWidget {
  const ProductListScreen({super.key});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(productControllerProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Products'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () => context.push(AppRoutes.profile),
          ),
        ],
      ),
      body: productsAsync.when(
        data: (products) => products.isEmpty
            ? const EmptyProductView()
            : ListView.builder(
                itemCount: products.length,
                itemBuilder: (context, index) {
                  final product = products[index];
                  return ListTile(
                    title: Text(product.name),
                    subtitle: Text('\$${product.price}'),
                    onTap: () => context.push(AppRoutes.productDetailPath(product.id)),
                  );
                },
              ),
        error: (error, _) => ErrorView(
          error: error,
          onRetry: () => ref.read(productControllerProvider.notifier).refresh(),
        ),
        loading: () => const ShimmerProductList(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push(AppRoutes.productCreate),
        child: const Icon(Icons.add),
      ),
    );
  }
}

// features/product/presentation/screens/product_detail_screen.dart
class ProductDetailScreen extends ConsumerWidget {
  final String productId;
  
  const ProductDetailScreen({super.key, required this.productId});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Detail'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => context.push(AppRoutes.productEditPath(productId)),
          ),
        ],
      ),
      body: Center(child: Text('Product ID: $productId')),
    );
  }
}
```

---

## Deliverables

### 4. Dependencies Injection Setup

**Description:** Setup dependency injection dengan Riverpod.

**Recommended Skills:** `senior-flutter-developer`

**Instructions:**
1. Setup providers untuk:
   - API client (Dio)
   - Repositories
   - Use cases
   - Storage
   - Network info

2. Implement provider overrides untuk testing

**Output Format:**
```dart
// core/di/providers.dart
part 'providers.g.dart';

// API Client
@riverpod
Dio dio(DioRef ref) {
  final dio = Dio(BaseOptions(
    baseUrl: 'https://api.example.com',
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 15),
  ));
  
  // Add interceptors
  dio.interceptors.addAll([
    AuthInterceptor(ref),
    LoggingInterceptor(),
  ]);
  
  return dio;
}

// Repositories
@riverpod
ProductRepository productRepository(ProductRepositoryRef ref) {
  return ProductRepositoryImpl(
    remoteDataSource: ref.watch(productRemoteDataSourceProvider),
    localDataSource: ref.watch(productLocalDataSourceProvider),
    networkInfo: ref.watch(networkInfoProvider),
  );
}
```


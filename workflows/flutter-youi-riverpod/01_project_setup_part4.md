---
description: Setup Flutter project dari nol dengan Clean Architecture, Riverpod, dan YoUI. (Part 4/5)
---
# Workflow: Flutter Project Setup with Riverpod + YoUI + YoUI (Part 4/5)

> **Navigation:** This workflow is split into 5 parts.

## Deliverables

### 3. Example Feature Implementation

**Description:** Contoh feature lengkap dengan CRUD operations menggunakan Riverpod dan YoUI widgets.

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
   - Buat `ProductListScreen` dengan YoUI widgets dan states
   - Implement loading, error, empty, dan data states
   - **Implement navigation menggunakan GoRouter**

**Output Format:**
```dart
// features/product/domain/entities/product.dart
class Product extends Equatable {
  final String id;
  final String name;
  final double price;
  final String? imageUrl;
  
  const Product({
    required this.id,
    required this.name,
    required this.price,
    this.imageUrl,
  });
  
  Product copyWith({
    String? id,
    String? name,
    double? price,
    String? imageUrl,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
  
  @override
  List<Object?> get props => [id, name, price, imageUrl];
}

// features/product/domain/repositories/product_repository.dart
abstract class ProductRepository {
  Future<Either<Failure, List<Product>>> getProducts();
  Future<Either<Failure, Product>> getProduct(String id);
  Future<Either<Failure, Product>> createProduct(
    Product product,
  );
  Future<Either<Failure, Product>> updateProduct(
    Product product,
  );
  Future<Either<Failure, Unit>> deleteProduct(String id);
}

// features/product/domain/usecases/get_products.dart
class GetProducts
    implements UseCase<List<Product>, NoParams> {
  final ProductRepository repository;
  
  GetProducts(this.repository);
  
  @override
  Future<Either<Failure, List<Product>>> call(
    NoParams params,
  ) {
    return repository.getProducts();
  }
}

// features/product/presentation/controllers/product_controller.dart
@riverpod
class ProductController extends _$ProductController {
  @override
  FutureOr<List<Product>> build() async {
    final repository =
        ref.watch(productRepositoryProvider);
    final result = await repository.getProducts();
    
    return result.fold(
      (failure) => throw failure,
      (products) => products,
    );
  }
  
  Future<void> createProduct({
    required String name,
    required double price,
  }) async {
    final repository =
        ref.read(productRepositoryProvider);
    final product = Product(
      id: '',
      name: name,
      price: price,
    );
    final result =
        await repository.createProduct(product);
    
    result.fold(
      (failure) => state =
          AsyncError(failure, StackTrace.current),
      (newProduct) {
        final currentData = state.valueOrNull ?? [];
        state =
            AsyncData([...currentData, newProduct]);
      },
    );
  }
  
  Future<void> deleteProduct(String id) async {
    final repository =
        ref.read(productRepositoryProvider);
    final result =
        await repository.deleteProduct(id);
    
    result.fold(
      (failure) => state =
          AsyncError(failure, StackTrace.current),
      (_) {
        final currentData = state.valueOrNull ?? [];
        state = AsyncData(
          currentData
              .where((item) => item.id != id)
              .toList(),
        );
      },
    );
  }
  
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository =
          ref.read(productRepositoryProvider);
      final result = await repository.getProducts();
      return result.getOrElse(() => []);
    });
  }
}

// features/product/presentation/screens/product_list_screen.dart
import 'package:go_router/go_router.dart';
import 'package:youi/youi.dart';
import '../../../../core/router/routes.dart';

class ProductListScreen extends ConsumerWidget {
  const ProductListScreen({super.key});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync =
        ref.watch(productControllerProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Products'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () =>
                context.push(AppRoutes.profile),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref
            .read(productControllerProvider.notifier)
            .refresh(),
        child: productsAsync.when(
          data: (products) {
            if (products.isEmpty) {
              return const EmptyProductView();
            }
            return ListView.builder(
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];
                return YoCard(
                  onTap: () => context.push(
                    AppRoutes.productDetailPath(
                      product.id,
                    ),
                  ),
                  child: ListTile(
                    title: Text(product.name),
                    subtitle: Text(
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
                        ref,
                        product.id,
                      ),
                    ),
                  ),
                );
              },
            );
          },
          error: (error, _) => ErrorView(
            error: error,
            onRetry: () => ref
                .read(
                  productControllerProvider.notifier,
                )
                .refresh(),
          ),
          loading: () =>
              const ShimmerProductList(),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () =>
            context.push(AppRoutes.productCreate),
        child: const Icon(Icons.add),
      ),
    );
  }
  
  void _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    String id,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Product'),
        content: const Text('Are you sure?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              ref
                  .read(
                    productControllerProvider
                        .notifier,
                  )
                  .deleteProduct(id);
              Navigator.pop(context);
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}

// features/product/presentation/screens/product_detail_screen.dart
class ProductDetailScreen extends ConsumerWidget {
  final String productId;
  
  const ProductDetailScreen({
    super.key,
    required this.productId,
  });
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Detail'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => context.push(
              AppRoutes.productEditPath(productId),
            ),
          ),
        ],
      ),
      body: Center(
        child: Text('Product ID: $productId'),
      ),
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
ProductRepository productRepository(
  ProductRepositoryRef ref,
) {
  return ProductRepositoryImpl(
    remoteDataSource:
        ref.watch(productRemoteDataSourceProvider),
    localDataSource:
        ref.watch(productLocalDataSourceProvider),
    networkInfo: ref.watch(networkInfoProvider),
  );
}

// Network Info
@riverpod
NetworkInfo networkInfo(NetworkInfoRef ref) {
  return NetworkInfoImpl(Connectivity());
}
```

---

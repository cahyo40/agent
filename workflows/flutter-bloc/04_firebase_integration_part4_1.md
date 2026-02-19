---
description: Integrasi Firebase services untuk Flutter dengan **flutter_bloc** sebagai state management: Authentication, Cloud Fir... (Sub-part 1/3)
---
# Workflow: Firebase Integration (flutter_bloc) (Part 4/7)

> **Navigation:** This workflow is split into 7 parts.

## Deliverables

### 3. Cloud Firestore CRUD (ProductBloc)

**Description:** Implementasi Firestore untuk database dengan real-time updates via BLoC. Gunakan `StreamSubscription` di dalam Bloc untuk listen Firestore snapshots, lalu emit state baru setiap ada perubahan data.

**Recommended Skills:** `senior-flutter-developer`, `senior-firebase-developer`

**Instructions:**
1. **ProductRemoteDataSource** — abstraksi untuk Firestore operations
2. **ProductFirestoreDataSource** — implementasi konkret
3. **ProductRepository** — orchestrate data sources
4. **ProductBloc** — events, states, stream subscription
5. **Security Rules** — validasi data di server side

**Data Source:**
```dart
// lib/features/product/data/datasources/product_remote_ds.dart
abstract class ProductRemoteDataSource {
  /// Stream real-time list produk dari Firestore
  Stream<List<ProductModel>> watchProducts();

  /// Get single product by ID
  Future<ProductModel> getProductById(String id);

  /// Create produk baru, return model dengan ID dari Firestore
  Future<ProductModel> createProduct(ProductModel product);

  /// Update produk existing
  Future<ProductModel> updateProduct(ProductModel product);

  /// Delete produk by ID
  Future<void> deleteProduct(String id);

  /// Batch write multiple products (untuk bulk operations)
  Future<void> batchWrite(List<ProductModel> products);
}
```

```dart
// lib/features/product/data/datasources/product_firestore_ds.dart
@LazySingleton(as: ProductRemoteDataSource)
class ProductFirestoreDataSource implements ProductRemoteDataSource {
  final FirebaseFirestore _firestore;

  ProductFirestoreDataSource(this._firestore);

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection('products');

  @override
  Stream<List<ProductModel>> watchProducts() {
    return _collection
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ProductModel.fromJson(
                  {...doc.data(), 'id': doc.id},
                ))
            .toList());
  }

  @override
  Future<ProductModel> getProductById(String id) async {
    final doc = await _collection.doc(id).get();
    if (!doc.exists) {
      throw NotFoundException('Produk tidak ditemukan');
    }
    return ProductModel.fromJson({...doc.data()!, 'id': doc.id});
  }

  @override
  Future<ProductModel> createProduct(ProductModel product) async {
    final docRef = await _collection.add({
      'name': product.name,
      'price': product.price,
      'description': product.description,
      'imageUrl': product.imageUrl,
      'ownerId': product.ownerId,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    return product.copyWith(id: docRef.id);
  }

  @override
  Future<ProductModel> updateProduct(ProductModel product) async {
    await _collection.doc(product.id).update({
      'name': product.name,
      'price': product.price,
      'description': product.description,
      'imageUrl': product.imageUrl,
      'updatedAt': FieldValue.serverTimestamp(),
    });
    return product;
  }

  @override
  Future<void> deleteProduct(String id) async {
    await _collection.doc(id).delete();
  }

  @override
  Future<void> batchWrite(List<ProductModel> products) async {
    final batch = _firestore.batch();
    for (final product in products) {
      final docRef = _collection.doc();
      batch.set(docRef, {
        'name': product.name,
        'price': product.price,
        'description': product.description,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }
    await batch.commit();
  }
}
```

**Product Events:**
```dart
// lib/features/product/presentation/bloc/product_event.dart
sealed class ProductEvent extends Equatable {
  const ProductEvent();

  @override
  List<Object?> get props => [];
}

/// Mulai subscribe ke Firestore stream
class ProductSubscriptionRequested extends ProductEvent {
  const ProductSubscriptionRequested();
}

/// Internal: data dari stream berubah
class _ProductsUpdated extends ProductEvent {
  final List<Product> products;

  const _ProductsUpdated(this.products);

  @override
  List<Object?> get props => [products];
}

/// Internal: error dari stream
class _ProductsError extends ProductEvent {
  final String message;

  const _ProductsError(this.message);

  @override
  List<Object?> get props => [message];
}

/// Tambah produk baru
class ProductAdded extends ProductEvent {
  final String name;
  final double price;
  final String? description;
  final String? imageUrl;

  const ProductAdded({
    required this.name,
    required this.price,
    this.description,
    this.imageUrl,
  });

  @override
  List<Object?> get props => [name, price, description, imageUrl];
}

/// Update produk existing
class ProductUpdated extends ProductEvent {
  final Product product;

  const ProductUpdated(this.product);

  @override
  List<Object?> get props => [product];
}

/// Delete produk
class ProductDeleted extends ProductEvent {
  final String productId;

  const ProductDeleted(this.productId);

  @override
  List<Object?> get props => [productId];
}
```

**Product States:**
```dart
// lib/features/product/presentation/bloc/product_state.dart
sealed class ProductState extends Equatable {
  const ProductState();

  @override
  List<Object?> get props => [];
}

class ProductInitial extends ProductState {
  const ProductInitial();
}

class ProductLoading extends ProductState {
  const ProductLoading();
}

/// Data produk tersedia (dari Firestore real-time stream)
class ProductLoaded extends ProductState {
  final List<Product> products;

  const ProductLoaded(this.products);

  @override
  List<Object?> get props => [products];
}

/// Error saat load atau operasi CRUD
class ProductError extends ProductState {
  final String message;
  /// Simpan data terakhir supaya UI tetap bisa tampilkan data lama
  final List<Product> previousProducts;

  const ProductError(this.message, {this.previousProducts = const []});

  @override
  List<Object?> get props => [message, previousProducts];
}

/// Operasi CRUD sedang berjalan (add/update/delete)
/// State ini terpisah dari loading karena list produk tetap ditampilkan
class ProductOperationInProgress extends ProductState {
  final List<Product> products;
  final String operation; // 'add', 'update', 'delete'

  const ProductOperationInProgress(this.products, this.operation);

  @override
  List<Object?> get props => [products, operation];
}
```

**ProductBloc Implementation:**
```dart
// lib/features/product/presentation/bloc/product_bloc.dart
@injectable
class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final ProductRepository _productRepository;

  /// StreamSubscription untuk Firestore real-time updates.
  /// Pattern: subscribe di event handler, cancel di close().
  StreamSubscription<List<Product>>? _productsSubscription;

  ProductBloc(this._productRepository) : super(const ProductInitial()) {
    on<ProductSubscriptionRequested>(_onSubscriptionRequested);
    on<_ProductsUpdated>(_onProductsUpdated);
    on<_ProductsError>(_onProductsError);
    on<ProductAdded>(_onProductAdded);
    on<ProductUpdated>(_onProductUpdated);
    on<ProductDeleted>(_onProductDeleted);
  }

  /// Subscribe ke Firestore real-time stream.
  /// Cancel subscription lama kalau ada (prevent duplicate listeners).
  Future<void> _onSubscriptionRequested(
    ProductSubscriptionRequested event,
    Emitter<ProductState> emit,
  ) async {
    emit(const ProductLoading());

    // Cancel existing subscription jika ada
    await _productsSubscription?.cancel();

    _productsSubscription = _productRepository.watchProducts().listen(
      (products) => add(_ProductsUpdated(products)),
      onError: (error) => add(_ProductsError(error.toString())),
    );
  }

  void _onProductsUpdated(
    _ProductsUpdated event,
    Emitter<ProductState> emit,
  ) {
    emit(ProductLoaded(event.products));
  }

  void _onProductsError(
    _ProductsError event,
    Emitter<ProductState> emit,
  ) {
    final previousProducts = state is ProductLoaded
        ? (state as ProductLoaded).products
        : <Product>[];
    emit(ProductError(event.message, previousProducts: previousProducts));
  }

  Future<void> _onProductAdded(
    ProductAdded event,
    Emitter<ProductState> emit,
  ) async {
    final currentProducts =
        state is ProductLoaded ? (state as ProductLoaded).products : <Product>[];

    emit(ProductOperationInProgress(currentProducts, 'add'));

    final result = await _productRepository.createProduct(
      Product(
        id: '',
        name: event.name,
        price: event.price,
        description: event.description,
        createdAt: DateTime.now(),
      ),
    );

    result.fold(
      (failure) => emit(ProductError(
        failure.message,
        previousProducts: currentProducts,
      )),
      // Tidak perlu emit success — Firestore stream akan otomatis
      // push data terbaru via _ProductsUpdated event
      (_) {},
    );
  }

  Future<void> _onProductUpdated(
    ProductUpdated event,
    Emitter<ProductState> emit,
  ) async {
    final currentProducts =
        state is ProductLoaded ? (state as ProductLoaded).products : <Product>[];

    emit(ProductOperationInProgress(currentProducts, 'update'));

    final result = await _productRepository.updateProduct(event.product);

    result.fold(
      (failure) => emit(ProductError(
        failure.message,
        previousProducts: currentProducts,
      )),
      (_) {}, // Stream akan auto-update
    );
  }

  Future<void> _onProductDeleted(
    ProductDeleted event,
    Emitter<ProductState> emit,
  ) async {
    final currentProducts =
        state is ProductLoaded ? (state as ProductLoaded).products : <Product>[];
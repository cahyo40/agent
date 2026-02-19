---
description: Setup Flutter project dari nol dengan Clean Architecture dan BLoC state management. (Sub-part 2/4)
---

#### 4c. Presentation Layer - BLoC (Events, States, Bloc)

**Ini bagian paling penting yang membedakan BLoC dari Riverpod.**

```dart
// features/product/presentation/bloc/product_event.dart
part of 'product_bloc.dart';

/// Base event class - sealed untuk exhaustive pattern matching
sealed class ProductEvent extends Equatable {
  const ProductEvent();

  @override
  List<Object?> get props => [];
}

/// Load semua products
class LoadProducts extends ProductEvent {
  const LoadProducts();
}

/// Load product detail by ID
class LoadProductDetail extends ProductEvent {
  final String id;
  const LoadProductDetail({required this.id});

  @override
  List<Object?> get props => [id];
}

/// Create product baru
class CreateProductEvent extends ProductEvent {
  final String name;
  final String description;
  final double price;
  final String? imageUrl;

  const CreateProductEvent({
    required this.name,
    required this.description,
    required this.price,
    this.imageUrl,
  });

  @override
  List<Object?> get props => [name, description, price, imageUrl];
}

/// Delete product by ID
class DeleteProductEvent extends ProductEvent {
  final String id;
  const DeleteProductEvent({required this.id});

  @override
  List<Object?> get props => [id];
}

/// Refresh products list
class RefreshProducts extends ProductEvent {
  const RefreshProducts();
}
```

```dart
// features/product/presentation/bloc/product_state.dart
part of 'product_bloc.dart';

/// Base state class - sealed untuk exhaustive pattern matching
sealed class ProductState extends Equatable {
  const ProductState();

  @override
  List<Object?> get props => [];
}

/// State awal, belum ada action
class ProductInitial extends ProductState {
  const ProductInitial();
}

/// Sedang loading data
class ProductLoading extends ProductState {
  const ProductLoading();
}

/// Products berhasil di-load
class ProductLoaded extends ProductState {
  final List<Product> products;

  const ProductLoaded({required this.products});

  @override
  List<Object?> get props => [products];

  /// Helper untuk cek apakah list kosong
  bool get isEmpty => products.isEmpty;
}

/// Product detail berhasil di-load
class ProductDetailLoaded extends ProductState {
  final Product product;

  const ProductDetailLoaded({required this.product});

  @override
  List<Object?> get props => [product];
}

/// Product berhasil dibuat
class ProductCreated extends ProductState {
  final Product product;

  const ProductCreated({required this.product});

  @override
  List<Object?> get props => [product];
}

/// Product berhasil dihapus
class ProductDeleted extends ProductState {
  final String productId;

  const ProductDeleted({required this.productId});

  @override
  List<Object?> get props => [productId];
}

/// Error state
class ProductError extends ProductState {
  final String message;

  const ProductError({required this.message});

  @override
  List<Object?> get props => [message];
}
```

```dart
// features/product/presentation/bloc/product_bloc.dart
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../domain/entities/product.dart';
import '../../domain/usecases/get_products.dart';
import '../../domain/usecases/get_product.dart';
import '../../domain/usecases/create_product.dart';
import '../../domain/usecases/delete_product.dart';

part 'product_event.dart';
part 'product_state.dart';

@injectable
class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final GetProducts _getProducts;
  final GetProduct _getProduct;
  final CreateProduct _createProduct;
  final DeleteProduct _deleteProduct;

  ProductBloc({
    required GetProducts getProducts,
    required GetProduct getProduct,
    required CreateProduct createProduct,
    required DeleteProduct deleteProduct,
  })  : _getProducts = getProducts,
        _getProduct = getProduct,
        _createProduct = createProduct,
        _deleteProduct = deleteProduct,
        super(const ProductInitial()) {
    // Register event handlers
    on<LoadProducts>(_onLoadProducts);
    on<LoadProductDetail>(_onLoadProductDetail);
    on<CreateProductEvent>(_onCreateProduct);
    on<DeleteProductEvent>(_onDeleteProduct);
    on<RefreshProducts>(_onRefreshProducts);
  }

  /// Handler: Load semua products
  Future<void> _onLoadProducts(
    LoadProducts event,
    Emitter<ProductState> emit,
  ) async {
    emit(const ProductLoading());

    final result = await _getProducts();

    result.fold(
      (failure) => emit(ProductError(message: failure.message)),
      (products) => emit(ProductLoaded(products: products)),
    );
  }

  /// Handler: Load product detail
  Future<void> _onLoadProductDetail(
    LoadProductDetail event,
    Emitter<ProductState> emit,
  ) async {
    emit(const ProductLoading());

    final result = await _getProduct(event.id);

    result.fold(
      (failure) => emit(ProductError(message: failure.message)),
      (product) => emit(ProductDetailLoaded(product: product)),
    );
  }

  /// Handler: Create product baru
  Future<void> _onCreateProduct(
    CreateProductEvent event,
    Emitter<ProductState> emit,
  ) async {
    emit(const ProductLoading());

    final result = await _createProduct(
      CreateProductParams(
        name: event.name,
        description: event.description,
        price: event.price,
        imageUrl: event.imageUrl,
      ),
    );

    result.fold(
      (failure) => emit(ProductError(message: failure.message)),
      (product) => emit(ProductCreated(product: product)),
    );
  }

  /// Handler: Delete product
  Future<void> _onDeleteProduct(
    DeleteProductEvent event,
    Emitter<ProductState> emit,
  ) async {
    emit(const ProductLoading());

    final result = await _deleteProduct(event.id);

    result.fold(
      (failure) => emit(ProductError(message: failure.message)),
      (_) => emit(ProductDeleted(productId: event.id)),
    );
  }

  /// Handler: Refresh products (sama dengan load, tapi bisa dibedakan logic-nya)
  Future<void> _onRefreshProducts(
    RefreshProducts event,
    Emitter<ProductState> emit,
  ) async {
    // Tidak emit loading supaya UI tidak flicker saat refresh
    final result = await _getProducts();

    result.fold(
      (failure) => emit(ProductError(message: failure.message)),
      (products) => emit(ProductLoaded(products: products)),
    );
  }
}
```


---
description: Integrasi Firebase services untuk Flutter dengan **flutter_bloc** sebagai state management: Authentication, Cloud Fir... (Sub-part 2/3)
---
    emit(ProductOperationInProgress(currentProducts, 'delete'));

    final result = await _productRepository.deleteProduct(event.productId);

    result.fold(
      (failure) => emit(ProductError(
        failure.message,
        previousProducts: currentProducts,
      )),
      (_) {}, // Stream akan auto-update
    );
  }

  @override
  Future<void> close() {
    _productsSubscription?.cancel();
    return super.close();
  }
}
```

**Alternatif: Menggunakan `emit.forEach()` (lebih ringkas):**
```dart
// Alternatif approach tanpa manual StreamSubscription.
// emit.forEach() otomatis manage subscription lifecycle.
// Kekurangan: kurang fleksibel untuk complex error handling.

@injectable
class ProductStreamBloc extends Bloc<ProductEvent, ProductState> {
  final ProductRepository _productRepository;

  ProductStreamBloc(this._productRepository) : super(const ProductInitial()) {
    on<ProductSubscriptionRequested>(_onSubscriptionRequested);
  }

  Future<void> _onSubscriptionRequested(
    ProductSubscriptionRequested event,
    Emitter<ProductState> emit,
  ) async {
    emit(const ProductLoading());

    // emit.forEach otomatis subscribe dan cancel subscription
    await emit.forEach<List<Product>>(
      _productRepository.watchProducts(),
      onData: (products) => ProductLoaded(products),
      onError: (error, stackTrace) => ProductError(error.toString()),
    );
  }
}
```

**Penggunaan di UI:**
```dart
// lib/features/product/presentation/pages/product_list_page.dart
class ProductListPage extends StatelessWidget {
  const ProductListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      // Buat ProductBloc dan langsung subscribe ke stream
      create: (context) => getIt<ProductBloc>()
        ..add(const ProductSubscriptionRequested()),
      child: const _ProductListView(),
    );
  }
}

class _ProductListView extends StatelessWidget {
  const _ProductListView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Produk')),
      body: BlocBuilder<ProductBloc, ProductState>(
        builder: (context, state) {
          return switch (state) {
            ProductInitial() => const SizedBox.shrink(),
            ProductLoading() => const Center(
                child: CircularProgressIndicator(),
              ),
            ProductLoaded(:final products) => _buildList(context, products),
            ProductOperationInProgress(:final products) => Stack(
                children: [
                  _buildList(context, products),
                  const Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: LinearProgressIndicator(),
                  ),
                ],
              ),
            ProductError(:final message, :final previousProducts) =>
              previousProducts.isEmpty
                  ? Center(child: Text('Error: $message'))
                  : _buildList(context, previousProducts),
          };
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildList(BuildContext context, List<Product> products) {
    if (products.isEmpty) {
      return const Center(child: Text('Belum ada produk'));
    }

    return ListView.builder(
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return ListTile(
          title: Text(product.name),
          subtitle: Text('Rp ${product.price.toStringAsFixed(0)}'),
          trailing: IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              context.read<ProductBloc>().add(
                    ProductDeleted(product.id),
                  );
            },
          ),
        );
      },
    );
  }
}
```

**Firestore Security Rules:**
```
// firestore.rules
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Helper functions
    function isAuthenticated() {
      return request.auth != null;
    }

    function isOwner(userId) {
      return request.auth.uid == userId;
    }

    function isValidString(field, maxLength) {
      return field is string && field.size() > 0 && field.size() <= maxLength;
    }

    // Products collection
    match /products/{productId} {
      allow read: if isAuthenticated();
      allow create: if isAuthenticated()
        && isValidString(request.resource.data.name, 100)
        && request.resource.data.price is number
        && request.resource.data.price >= 0;
      allow update: if isAuthenticated()
        && isOwner(resource.data.ownerId)
        && request.resource.data.updatedAt == request.time;
      allow delete: if isAuthenticated()
        && isOwner(resource.data.ownerId);
    }

    // Users collection
    match /users/{userId} {
      allow read: if isAuthenticated() && isOwner(userId);
      allow write: if isAuthenticated() && isOwner(userId);
    }
  }
}
```


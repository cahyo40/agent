---
description: Setup Flutter project dari nol dengan Clean Architecture dan BLoC state management. (Sub 1/2)
---

#### 4d. Presentation Layer - Screens (UI)

```dart
// features/product/presentation/screens/product_list_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/routes.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/empty_view.dart';
import '../bloc/product_bloc.dart';
import '../widgets/product_card.dart';
import '../widgets/shimmer_product_list.dart';

class ProductListScreen extends StatelessWidget {
  const ProductListScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
      // BlocListener untuk side effects (snackbar, navigation, etc.)
      // BlocBuilder untuk rebuild UI berdasarkan state
      // BlocConsumer = BlocListener + BlocBuilder
      body: BlocConsumer<ProductBloc, ProductState>(
        // Listener: side effects saja, tidak rebuild UI
        listener: (context, state) {
          if (state is ProductDeleted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Product berhasil dihapus'),
                backgroundColor: Colors.green,
              ),
            );
            // Refresh list setelah delete
            context.read<ProductBloc>().add(const LoadProducts());
          }
          if (state is ProductError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        // Builder: rebuild UI berdasarkan state
        builder: (context, state) {
          // Pattern matching pada sealed class state
          return switch (state) {
            ProductInitial() => const Center(
                child: Text('Tap refresh to load products'),
              ),
            ProductLoading() => const ShimmerProductList(),
            ProductLoaded(:final products) => products.isEmpty
                ? EmptyView(
                    message: 'Belum ada product',
                    onAction: () => context.push(AppRoutes.productCreate),
                    actionLabel: 'Tambah Product',
                  )
                : RefreshIndicator(
                    onRefresh: () async {
                      context.read<ProductBloc>().add(const RefreshProducts());
                    },
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: products.length,
                      itemBuilder: (context, index) {
                        final product = products[index];
                        return ProductCard(
                          product: product,
                          onTap: () => context.push(
                            AppRoutes.productDetailPath(product.id),
                          ),
                          onDelete: () {
                            context.read<ProductBloc>().add(
                              DeleteProductEvent(id: product.id),
                            );
                          },
                        );
                      },
                    ),
                  ),
            ProductError(:final message) => ErrorView(
                message: message,
                onRetry: () {
                  context.read<ProductBloc>().add(const LoadProducts());
                },
              ),
            // States yang tidak relevan untuk list screen
            _ => const SizedBox.shrink(),
          };
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push(AppRoutes.productCreate),
        child: const Icon(Icons.add),
      ),
    );
  }
}
```

```dart
// features/product/presentation/screens/product_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/routes.dart';
import '../bloc/product_bloc.dart';

class ProductDetailScreen extends StatelessWidget {
  final String productId;

  const ProductDetailScreen({super.key, required this.productId});

  @override
  Widget build(BuildContext context) {
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
      body: BlocBuilder<ProductBloc, ProductState>(
        builder: (context, state) {
          return switch (state) {
            ProductLoading() => const Center(
                child: CircularProgressIndicator(),
              ),
            ProductDetailLoaded(:final product) => SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (product.imageUrl != null)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          product.imageUrl!,
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                    const SizedBox(height: 16),
                    Text(
                      product.name,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '\$${product.price.toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(product.description),
                  ],
                ),
              ),
            ProductError(:final message) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(message),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        context.read<ProductBloc>().add(
                          LoadProductDetail(id: productId),
                        );
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            _ => const SizedBox.shrink(),
          };
        },
      ),
    );
  }
}
```

```dart
// features/product/presentation/screens/product_create_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/product_bloc.dart';

class ProductCreateScreen extends StatefulWidget {
  const ProductCreateScreen({super.key});

  @override
  State<ProductCreateScreen> createState() => _ProductCreateScreenState();
}

class _ProductCreateScreenState extends State<ProductCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      context.read<ProductBloc>().add(
        CreateProductEvent(
          name: _nameController.text.trim(),
          description: _descriptionController.text.trim(),
          price: double.parse(_priceController.text.trim()),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Product')),
      body: BlocListener<ProductBloc, ProductState>(
        listener: (context, state) {
          if (state is ProductCreated) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Product "${state.product.name}" berhasil dibuat'),
                backgroundColor: Colors.green,
              ),
            );
            // Navigate back setelah berhasil create
            context.pop();
          }
          if (state is ProductError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: BlocBuilder<ProductBloc, ProductState>(
          builder: (context, state) {
            final isLoading = state is ProductLoading;
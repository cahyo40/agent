---
description: Integrasi Supabase sebagai alternative backend dengan flutter_bloc state management: Authentication, PostgreSQL Datab... (Sub-part 2/3)
---
  // ---- Fetch all products ----
  Future<void> _onFetchProducts(
    FetchProducts event,
    Emitter<ProductState> emit,
  ) async {
    emit(state.copyWith(status: ProductStatus.loading));

    try {
      final products = await _dataSource.getProducts();
      emit(state.copyWith(
        status: ProductStatus.loaded,
        products: products,
        errorMessage: null,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ProductStatus.error,
        errorMessage: 'Gagal memuat produk: $e',
      ));
    }
  }

  // ---- Fetch with pagination ----
  Future<void> _onFetchProductsPaginated(
    FetchProductsPaginated event,
    Emitter<ProductState> emit,
  ) async {
    if (event.refresh) {
      emit(state.copyWith(
        status: ProductStatus.loading,
        products: [],
        currentPage: 1,
        hasMore: true,
      ));
    }

    if (!state.hasMore || state.status == ProductStatus.loading) return;

    emit(state.copyWith(status: ProductStatus.loading));

    try {
      final newProducts = await _dataSource.getProductsWithPagination(
        page: state.currentPage,
        limit: _pageSize,
      );

      emit(state.copyWith(
        status: ProductStatus.loaded,
        products: [...state.products, ...newProducts],
        currentPage: state.currentPage + 1,
        hasMore: newProducts.length >= _pageSize,
        errorMessage: null,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ProductStatus.error,
        errorMessage: 'Gagal memuat halaman: $e',
      ));
    }
  }

  // ---- Search products ----
  Future<void> _onSearchProducts(
    SearchProducts event,
    Emitter<ProductState> emit,
  ) async {
    emit(state.copyWith(
      status: ProductStatus.loading,
      searchQuery: event.query,
    ));

    try {
      final List products;
      if (event.query.isEmpty) {
        products = await _dataSource.getProducts();
      } else {
        products = await _dataSource.searchProducts(event.query);
      }

      emit(state.copyWith(
        status: ProductStatus.loaded,
        products: products.cast(),
        errorMessage: null,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ProductStatus.error,
        errorMessage: 'Search gagal: $e',
      ));
    }
  }

  // ---- Get single product ----
  Future<void> _onFetchProductById(
    FetchProductById event,
    Emitter<ProductState> emit,
  ) async {
    emit(state.copyWith(status: ProductStatus.loading));

    try {
      final product = await _dataSource.getProductById(event.id);
      emit(state.copyWith(
        status: ProductStatus.loaded,
        selectedProduct: product,
        errorMessage: null,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ProductStatus.error,
        errorMessage: 'Gagal memuat detail: $e',
      ));
    }
  }

  // ---- Create product ----
  Future<void> _onCreateProduct(
    CreateProduct event,
    Emitter<ProductState> emit,
  ) async {
    emit(state.copyWith(status: ProductStatus.loading));

    try {
      final created = await _dataSource.createProduct(event.product);
      emit(state.copyWith(
        status: ProductStatus.loaded,
        products: [created, ...state.products],
        errorMessage: null,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ProductStatus.error,
        errorMessage: 'Gagal membuat produk: $e',
      ));
    }
  }

  // ---- Update product ----
  Future<void> _onUpdateProduct(
    UpdateProduct event,
    Emitter<ProductState> emit,
  ) async {
    emit(state.copyWith(status: ProductStatus.loading));

    try {
      final updated = await _dataSource.updateProduct(event.product);
      final updatedList = state.products.map((p) {
        return p.id == updated.id ? updated : p;
      }).toList();

      emit(state.copyWith(
        status: ProductStatus.loaded,
        products: updatedList,
        selectedProduct: updated,
        errorMessage: null,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ProductStatus.error,
        errorMessage: 'Gagal update produk: $e',
      ));
    }
  }

  // ---- Delete product ----
  Future<void> _onDeleteProduct(
    DeleteProduct event,
    Emitter<ProductState> emit,
  ) async {
    emit(state.copyWith(status: ProductStatus.loading));

    try {
      await _dataSource.deleteProduct(event.id);
      final filtered = state.products
          .where((p) => p.id != event.id)
          .toList();

      emit(state.copyWith(
        status: ProductStatus.loaded,
        products: filtered,
        errorMessage: null,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ProductStatus.error,
        errorMessage: 'Gagal hapus produk: $e',
      ));
    }
  }
}

// ============================================================
// PRODUCT LIST PAGE — Contoh UI dengan BlocBuilder
// ============================================================

// features/product/presentation/pages/product_list_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection.dart';
import '../bloc/product_bloc.dart';
import '../bloc/product_event.dart';
import '../bloc/product_state.dart';

class ProductListPage extends StatelessWidget {
  const ProductListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<ProductBloc>()..add(FetchProducts()),
      child: const _ProductListView(),
    );
  }
}

class _ProductListView extends StatelessWidget {
  const _ProductListView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Produk'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.go('/product/create'),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              onChanged: (val) => context.read<ProductBloc>().add(
                    SearchProducts(query: val),
                  ),
              decoration: const InputDecoration(
                hintText: 'Cari produk...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
          ),

          // Product list
          Expanded(
            child: BlocBuilder<ProductBloc, ProductState>(
              builder: (context, state) {
                if (state.status == ProductStatus.loading &&
                    state.products.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state.status == ProductStatus.error &&
                    state.products.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(state.errorMessage ?? 'Unknown error'),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: () => context
                              .read<ProductBloc>()
                              .add(FetchProducts()),
                          child: const Text('Coba Lagi'),
                        ),
                      ],
                    ),
                  );
                }

                if (state.products.isEmpty) {
                  return const Center(child: Text('Belum ada produk'));
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    context.read<ProductBloc>().add(FetchProducts());
                  },
                  child: ListView.builder(
                    itemCount: state.products.length,
                    itemBuilder: (context, index) {
                      final product = state.products[index];
                      return ListTile(
                        title: Text(product.name),
                        subtitle: Text('Rp ${product.price}'),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => context
                              .read<ProductBloc>()
                              .add(DeleteProduct(id: product.id)),
                        ),
                        onTap: () => context.go(
                          '/product/detail/${product.id}',
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// SQL: RLS POLICIES — Framework-agnostic
// Dijalankan di Supabase SQL Editor
// ============================================================
/*
-- Enable RLS
ALTER TABLE products ENABLE ROW LEVEL SECURITY;

-- Policy: Users can read all products
CREATE POLICY "Products are viewable by authenticated users"
ON products FOR SELECT
TO authenticated
USING (true);

-- Policy: Users can only insert their own products
CREATE POLICY "Users can create their own products"
ON products FOR INSERT
TO authenticated
WITH CHECK (auth.uid() = user_id);

-- Policy: Users can only update their own products
CREATE POLICY "Users can update their own products"
ON products FOR UPDATE
TO authenticated
USING (auth.uid() = user_id)
WITH CHECK (auth.uid() = user_id);

-- Policy: Users can only delete their own products
CREATE POLICY "Users can delete their own products"
ON products FOR DELETE
TO authenticated
USING (auth.uid() = user_id);

-- Policy: Allow anonymous read (optional)
CREATE POLICY "Products are viewable by everyone"
ON products FOR SELECT
TO anon
USING (true);
*/
```


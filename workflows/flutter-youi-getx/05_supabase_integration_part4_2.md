---
description: Integrasi Supabase sebagai alternative backend dengan GetX state management: Authentication, PostgreSQL Database, Rea... (Sub-part 2/3)
---
  // ---- Pull to refresh ----
  Future<void> onRefresh() async {
    await fetchProducts();
  }
}

// ============================================================
// PRODUCT BINDING — DI untuk product feature
// ============================================================

// features/product/bindings/product_binding.dart
import 'package:get/get.dart';
import '../data/datasources/product_supabase_ds.dart';
import '../presentation/controllers/product_controller.dart';

class ProductBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ProductSupabaseDataSource>(
      () => ProductSupabaseDataSource(),
    );
    Get.lazyPut<ProductController>(
      () => ProductController(dataSource: Get.find()),
    );
  }
}

// ============================================================
// PRODUCT LIST PAGE — Contoh UI
// ============================================================

// features/product/presentation/pages/product_list_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/product_controller.dart';

class ProductListPage extends GetView<ProductController> {
  const ProductListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Produk'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => Get.toNamed('/product/create'),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              onChanged: (val) => controller.searchQuery.value = val,
              decoration: const InputDecoration(
                hintText: 'Cari produk...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
          ),

          // Product list
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value && controller.products.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }

              if (controller.errorMessage.isNotEmpty &&
                  controller.products.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(controller.errorMessage.value),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: controller.fetchProducts,
                        child: const Text('Coba Lagi'),
                      ),
                    ],
                  ),
                );
              }

              if (controller.products.isEmpty) {
                return const Center(child: Text('Belum ada produk'));
              }

              return RefreshIndicator(
                onRefresh: controller.onRefresh,
                child: ListView.builder(
                  itemCount: controller.products.length,
                  itemBuilder: (context, index) {
                    final product = controller.products[index];
                    return ListTile(
                      title: Text(product.name),
                      subtitle: Text('Rp ${product.price}'),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => controller.deleteProduct(product.id),
                      ),
                      onTap: () => Get.toNamed(
                        '/product/detail/${product.id}',
                      ),
                    );
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// SQL: RLS POLICIES — Sama dengan versi Riverpod
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


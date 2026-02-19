---
description: Integrasi Firebase services untuk Flutter dengan GetX state management: Authentication, Cloud Firestore, Firebase Sto... (Sub-part 2/3)
---
     // Untuk pagination
     String? _lastProductId;

     @override
     void onInit() {
       super.onInit();

       // Bind Firestore stream ke RxList
       // bindStream() otomatis listen dan update products
       // Ini pengganti Stream<List<Product>> build() di Riverpod
       products.bindStream(
         _repository.watchProducts(),
         onError: (error) {
           errorMessage.value = 'Gagal memuat produk: $error';
         },
       );
     }

     /// Tambah product baru
     Future<void> addProduct({
       required String name,
       required double price,
       String? description,
     }) async {
       isLoading.value = true;
       errorMessage.value = '';

       final currentUser = _authController.user.value;
       if (currentUser == null) {
         errorMessage.value = 'User belum login';
         isLoading.value = false;
         return;
       }

       final product = ProductModel(
         id: '',
         name: name,
         price: price,
         description: description,
         ownerId: currentUser.uid,
         createdAt: DateTime.now(),
         updatedAt: DateTime.now(),
       );

       final result = await _repository.createProduct(product);

       result.fold(
         (failure) {
           errorMessage.value = failure.message;
           Get.snackbar('Error', failure.message);
         },
         (created) {
           Get.snackbar('Berhasil', 'Produk berhasil ditambahkan');
           // Tidak perlu manual update list - stream otomatis update
         },
       );

       isLoading.value = false;
     }

     /// Update product
     Future<void> updateProduct(ProductModel product) async {
       isLoading.value = true;
       errorMessage.value = '';

       final result = await _repository.updateProduct(product);

       result.fold(
         (failure) {
           errorMessage.value = failure.message;
           Get.snackbar('Error', failure.message);
         },
         (updated) {
           Get.snackbar('Berhasil', 'Produk berhasil diupdate');
         },
       );

       isLoading.value = false;
     }

     /// Delete product
     Future<void> deleteProduct(String id) async {
       // Confirmation dialog menggunakan GetX
       final confirmed = await Get.dialog<bool>(
         AlertDialog(
           title: const Text('Konfirmasi'),
           content: const Text('Yakin ingin menghapus produk ini?'),
           actions: [
             TextButton(
               onPressed: () => Get.back(result: false),
               child: const Text('Batal'),
             ),
             TextButton(
               onPressed: () => Get.back(result: true),
               child: const Text('Hapus', style: TextStyle(color: Colors.red)),
             ),
           ],
         ),
       );

       if (confirmed != true) return;

       isLoading.value = true;

       final result = await _repository.deleteProduct(id);

       result.fold(
         (failure) {
           errorMessage.value = failure.message;
           Get.snackbar('Error', failure.message);
         },
         (_) {
           Get.snackbar('Berhasil', 'Produk berhasil dihapus');
         },
       );

       isLoading.value = false;
     }

     /// Load more products (pagination)
     Future<void> loadMore() async {
       if (!hasMore.value || isLoading.value) return;

       isLoading.value = true;
       _lastProductId = products.isNotEmpty ? products.last.id : null;

       final result = await _repository.getProducts(
         limit: 20,
         lastId: _lastProductId,
       );

       result.fold(
         (failure) {
           errorMessage.value = failure.message;
         },
         (newProducts) {
           if (newProducts.isEmpty) {
             hasMore.value = false;
           } else {
             products.addAll(newProducts);
             _lastProductId = newProducts.last.id;
           }
         },
       );

       isLoading.value = false;
     }

     /// Search products
     final RxList<ProductModel> searchResults = <ProductModel>[].obs;
     final RxString searchQuery = ''.obs;

     void searchProducts(String query) {
       searchQuery.value = query;
       if (query.isEmpty) {
         searchResults.clear();
         return;
       }

       // Client-side filtering dari data yang sudah di-stream
       searchResults.value = products
           .where((p) => p.name.toLowerCase().contains(query.toLowerCase()))
           .toList();
     }
   }
   ```

5. **Product Binding:**
   ```dart
   // features/product/bindings/product_binding.dart
   import 'package:get/get.dart';
   import '../controllers/product_controller.dart';
   import '../data/datasources/product_firestore_ds.dart';
   import '../data/datasources/product_remote_ds.dart';
   import '../data/repositories/product_repository_impl.dart';
   import '../domain/repositories/product_repository.dart';

   class ProductBinding extends Bindings {
     @override
     void dependencies() {
       // Data source
       Get.lazyPut<ProductRemoteDataSource>(
         () => ProductFirestoreDataSource(),
       );

       // Repository
       Get.lazyPut<ProductRepository>(
         () => ProductRepositoryImpl(
           remoteDataSource: Get.find<ProductRemoteDataSource>(),
         ),
       );

       // Controller
       Get.lazyPut(() => ProductController());
     }
   }
   ```

6. **Product List View:**
   ```dart
   // features/product/views/product_list_view.dart
   import 'package:flutter/material.dart';
   import 'package:get/get.dart';
   import '../controllers/product_controller.dart';

   class ProductListView extends GetView<ProductController> {
     const ProductListView({super.key});

     @override
     Widget build(BuildContext context) {
       return Scaffold(
         appBar: AppBar(
           title: const Text('Products'),
           actions: [
             IconButton(
               icon: const Icon(Icons.search),
               onPressed: () => _showSearch(context),
             ),
           ],
         ),
         body: Obx(() {
           if (controller.products.isEmpty && controller.isLoading.value) {
             return const Center(child: CircularProgressIndicator());
           }

           if (controller.products.isEmpty) {
             return const Center(
               child: Text('Belum ada produk'),
             );
           }

           return RefreshIndicator(
             onRefresh: () async {
               // Stream akan otomatis refresh
             },
             child: ListView.builder(
               itemCount: controller.products.length,
               itemBuilder: (context, index) {
                 final product = controller.products[index];
                 return ListTile(
                   title: Text(product.name),
                   subtitle: Text('Rp ${product.price.toStringAsFixed(0)}'),
                   trailing: IconButton(
                     icon: const Icon(Icons.delete, color: Colors.red),
                     onPressed: () => controller.deleteProduct(product.id),
                   ),
                   onTap: () => Get.toNamed(
                     '/products/${product.id}',
                     arguments: product,
                   ),
                 );
               },
             ),
           );
         }),
         floatingActionButton: FloatingActionButton(
           onPressed: () => Get.toNamed('/products/create'),
           child: const Icon(Icons.add),
         ),
       );
     }

     void _showSearch(BuildContext context) {
       showSearch(
         context: context,
         delegate: ProductSearchDelegate(controller),
       );
     }
   }
   ```

7. **Firestore Security Rules:**
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
           && isOwner(resource.data.ownerId);
         allow delete: if isAuthenticated()
           && isOwner(resource.data.ownerId);
       }

       // Users collection
       match /users/{userId} {
         allow read: if isAuthenticated() && isOwner(userId);
         allow write: if isAuthenticated() && isOwner(userId);
       }

       // User profiles - public read
       match /profiles/{userId} {
         allow read: if isAuthenticated();
         allow write: if isAuthenticated() && isOwner(userId);
       }
     }
   }
   ```


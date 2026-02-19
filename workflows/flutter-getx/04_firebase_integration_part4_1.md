---
description: Integrasi Firebase services untuk Flutter dengan GetX state management: Authentication, Cloud Firestore, Firebase Sto... (Sub-part 1/3)
---
# Workflow: Firebase Integration (GetX) (Part 4/7)

> **Navigation:** This workflow is split into 7 parts.

## Deliverables

### 3. Cloud Firestore CRUD (GetX)

**Description:** Implementasi Firestore untuk database dengan real-time updates menggunakan GetX reactive streams dan `bindStream()`.

**Recommended Skills:** `senior-flutter-developer`, `senior-firebase-developer`

**Perbedaan dengan Riverpod:**
| Aspek | Riverpod | GetX |
|-------|----------|------|
| Stream binding | `Stream<List<Product>> build()` | `products.bindStream()` di `onInit()` |
| State type | `AsyncValue<List<Product>>` | `RxList<Product>` + `RxBool isLoading` |
| Error handling | `AsyncValue.guard()` | Manual try-catch + `RxString error` |
| Access | `ref.watch(productControllerProvider)` | `Get.find<ProductController>()` |

**Instructions:**

1. **Product Model:**
   ```dart
   // features/product/data/models/product_model.dart
   import 'package:cloud_firestore/cloud_firestore.dart';

   class ProductModel {
     final String id;
     final String name;
     final double price;
     final String? description;
     final String? imageUrl;
     final String ownerId;
     final DateTime createdAt;
     final DateTime updatedAt;

     const ProductModel({
       required this.id,
       required this.name,
       required this.price,
       this.description,
       this.imageUrl,
       required this.ownerId,
       required this.createdAt,
       required this.updatedAt,
     });

     factory ProductModel.fromFirestore(DocumentSnapshot doc) {
       final data = doc.data() as Map<String, dynamic>;
       return ProductModel(
         id: doc.id,
         name: data['name'] ?? '',
         price: (data['price'] ?? 0).toDouble(),
         description: data['description'],
         imageUrl: data['imageUrl'],
         ownerId: data['ownerId'] ?? '',
         createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
         updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
       );
     }

     Map<String, dynamic> toFirestore() {
       return {
         'name': name,
         'price': price,
         'description': description,
         'imageUrl': imageUrl,
         'ownerId': ownerId,
         'createdAt': FieldValue.serverTimestamp(),
         'updatedAt': FieldValue.serverTimestamp(),
       };
     }

     Map<String, dynamic> toUpdateMap() {
       return {
         'name': name,
         'price': price,
         'description': description,
         'imageUrl': imageUrl,
         'updatedAt': FieldValue.serverTimestamp(),
       };
     }

     ProductModel copyWith({
       String? id,
       String? name,
       double? price,
       String? description,
       String? imageUrl,
       String? ownerId,
       DateTime? createdAt,
       DateTime? updatedAt,
     }) {
       return ProductModel(
         id: id ?? this.id,
         name: name ?? this.name,
         price: price ?? this.price,
         description: description ?? this.description,
         imageUrl: imageUrl ?? this.imageUrl,
         ownerId: ownerId ?? this.ownerId,
         createdAt: createdAt ?? this.createdAt,
         updatedAt: updatedAt ?? this.updatedAt,
       );
     }
   }
   ```

2. **Firestore Data Source (Framework-Agnostic):**

   Layer data source tetap sama dengan versi Riverpod karena tidak bergantung pada state management framework.

   ```dart
   // features/product/data/datasources/product_remote_ds.dart
   abstract class ProductRemoteDataSource {
     Stream<List<ProductModel>> watchProducts();
     Future<List<ProductModel>> getProducts({int limit = 20, String? lastId});
     Future<ProductModel> getProductById(String id);
     Future<ProductModel> createProduct(ProductModel product);
     Future<ProductModel> updateProduct(ProductModel product);
     Future<void> deleteProduct(String id);
     Future<void> batchDelete(List<String> ids);
   }

   // features/product/data/datasources/product_firestore_ds.dart
   import 'package:cloud_firestore/cloud_firestore.dart';
   import 'product_remote_ds.dart';
   import '../models/product_model.dart';

   class ProductFirestoreDataSource implements ProductRemoteDataSource {
     final FirebaseFirestore _firestore;

     ProductFirestoreDataSource({FirebaseFirestore? firestore})
         : _firestore = firestore ?? FirebaseFirestore.instance;

     CollectionReference get _productsRef =>
         _firestore.collection('products');

     @override
     Stream<List<ProductModel>> watchProducts() {
       return _productsRef
           .orderBy('createdAt', descending: true)
           .snapshots()
           .map((snapshot) => snapshot.docs
               .map((doc) => ProductModel.fromFirestore(doc))
               .toList());
     }

     @override
     Future<List<ProductModel>> getProducts({
       int limit = 20,
       String? lastId,
     }) async {
       Query query = _productsRef
           .orderBy('createdAt', descending: true)
           .limit(limit);

       // Pagination: mulai setelah document terakhir
       if (lastId != null) {
         final lastDoc = await _productsRef.doc(lastId).get();
         query = query.startAfterDocument(lastDoc);
       }

       final snapshot = await query.get();
       return snapshot.docs
           .map((doc) => ProductModel.fromFirestore(doc))
           .toList();
     }

     @override
     Future<ProductModel> getProductById(String id) async {
       final doc = await _productsRef.doc(id).get();
       if (!doc.exists) {
         throw Exception('Product not found');
       }
       return ProductModel.fromFirestore(doc);
     }

     @override
     Future<ProductModel> createProduct(ProductModel product) async {
       final docRef = await _productsRef.add(product.toFirestore());
       return product.copyWith(id: docRef.id);
     }

     @override
     Future<ProductModel> updateProduct(ProductModel product) async {
       await _productsRef.doc(product.id).update(product.toUpdateMap());
       return product;
     }

     @override
     Future<void> deleteProduct(String id) async {
       await _productsRef.doc(id).delete();
     }

     @override
     Future<void> batchDelete(List<String> ids) async {
       final batch = _firestore.batch();
       for (final id in ids) {
         batch.delete(_productsRef.doc(id));
       }
       await batch.commit();
     }
   }
   ```

3. **Product Repository:**
   ```dart
   // features/product/domain/repositories/product_repository.dart
   import '../../data/models/product_model.dart';
   import '../../../../core/error/failures.dart';
   import '../../../../core/utils/either.dart';

   abstract class ProductRepository {
     Stream<List<ProductModel>> watchProducts();
     Future<Either<Failure, List<ProductModel>>> getProducts({
       int limit = 20,
       String? lastId,
     });
     Future<Either<Failure, ProductModel>> getProductById(String id);
     Future<Either<Failure, ProductModel>> createProduct(ProductModel product);
     Future<Either<Failure, ProductModel>> updateProduct(ProductModel product);
     Future<Either<Failure, void>> deleteProduct(String id);
   }

   // features/product/data/repositories/product_repository_impl.dart
   class ProductRepositoryImpl implements ProductRepository {
     final ProductRemoteDataSource _remoteDataSource;

     ProductRepositoryImpl({required ProductRemoteDataSource remoteDataSource})
         : _remoteDataSource = remoteDataSource;

     @override
     Stream<List<ProductModel>> watchProducts() {
       return _remoteDataSource.watchProducts();
     }

     @override
     Future<Either<Failure, List<ProductModel>>> getProducts({
       int limit = 20,
       String? lastId,
     }) async {
       try {
         final products = await _remoteDataSource.getProducts(
           limit: limit,
           lastId: lastId,
         );
         return Right(products);
       } catch (e) {
         return Left(ServerFailure(e.toString()));
       }
     }

     @override
     Future<Either<Failure, ProductModel>> getProductById(String id) async {
       try {
         final product = await _remoteDataSource.getProductById(id);
         return Right(product);
       } catch (e) {
         return Left(ServerFailure(e.toString()));
       }
     }

     @override
     Future<Either<Failure, ProductModel>> createProduct(
       ProductModel product,
     ) async {
       try {
         final created = await _remoteDataSource.createProduct(product);
         return Right(created);
       } catch (e) {
         return Left(ServerFailure(e.toString()));
       }
     }

     @override
     Future<Either<Failure, ProductModel>> updateProduct(
       ProductModel product,
     ) async {
       try {
         final updated = await _remoteDataSource.updateProduct(product);
         return Right(updated);
       } catch (e) {
         return Left(ServerFailure(e.toString()));
       }
     }

     @override
     Future<Either<Failure, void>> deleteProduct(String id) async {
       try {
         await _remoteDataSource.deleteProduct(id);
         return const Right(null);
       } catch (e) {
         return Left(ServerFailure(e.toString()));
       }
     }
   }
   ```

4. **Product Controller (GetX) - dengan `bindStream()`:**

   Ini perbedaan kunci: GetX menggunakan `bindStream()` untuk menghubungkan Firestore stream ke `RxList`, sehingga UI otomatis update ketika data berubah.

   ```dart
   // features/product/controllers/product_controller.dart
   import 'package:get/get.dart';
   import '../data/models/product_model.dart';
   import '../domain/repositories/product_repository.dart';
   import '../../auth/controllers/auth_controller.dart';

   class ProductController extends GetxController {
     final ProductRepository _repository = Get.find<ProductRepository>();
     final AuthController _authController = Get.find<AuthController>();

     // Reactive state - pengganti AsyncValue<List<Product>> di Riverpod
     final RxList<ProductModel> products = <ProductModel>[].obs;
     final RxBool isLoading = false.obs;
     final RxString errorMessage = ''.obs;
     final RxBool hasMore = true.obs;
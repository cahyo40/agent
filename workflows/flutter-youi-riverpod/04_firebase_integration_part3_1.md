---
description: Integrasi Firebase services untuk Flutter: Authentication, Cloud Firestore, Firebase Storage, dan Firebase Cloud Mess... (Sub 1/2)
---
# Workflow: Firebase Integration (Part 3/4)

> **Navigation:** This workflow is split into 4 parts.

## Deliverables

### 3. Cloud Firestore CRUD

**Description:** Implementasi Firestore untuk database dengan real-time updates.

**Recommended Skills:** `senior-flutter-developer`, `senior-firebase-developer`

**Instructions:**
1. **Firestore Service:**
   - CRUD operations
   - Real-time stream queries
   - Batch writes
   - Transactions

2. **Repository Pattern:**
   - Abstract contract
   - Firestore implementation
   - Offline persistence

3. **Security Rules:**
   - Basic read/write rules
   - User authentication rules
   - Data validation

**Output Format:**
```dart
// features/product/data/datasources/product_remote_ds.dart
abstract class ProductRemoteDataSource {
  Stream<List<ProductModel>> getProducts();
  Future<ProductModel> getProductById(String id);
  Future<ProductModel> createProduct(ProductModel product);
  Future<ProductModel> updateProduct(ProductModel product);
  Future<void> deleteProduct(String id);
}

// features/product/data/datasources/product_firestore_ds.dart
class ProductFirestoreDataSource implements ProductRemoteDataSource {
  final FirebaseFirestore _firestore;
  
  ProductFirestoreDataSource({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;
  
  CollectionReference get _productsCollection => 
      _firestore.collection('products');
  
  @override
  Stream<List<ProductModel>> getProducts() {
    return _productsCollection
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ProductModel.fromJson(
                  doc.data() as Map<String, dynamic>,
                ).copyWith(id: doc.id))
            .toList());
  }
  
  @override
  Future<ProductModel> getProductById(String id) async {
    final doc = await _productsCollection.doc(id).get();
    if (!doc.exists) {
      throw NotFoundException('Product not found');
    }
    return ProductModel.fromJson(doc.data() as Map<String, dynamic>)
        .copyWith(id: doc.id);
  }
  
  @override
  Future<ProductModel> createProduct(ProductModel product) async {
    final docRef = await _productsCollection.add({
      'name': product.name,
      'price': product.price,
      'description': product.description,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    
    return product.copyWith(id: docRef.id);
  }
  
  @override
  Future<ProductModel> updateProduct(ProductModel product) async {
    await _productsCollection.doc(product.id).update({
      'name': product.name,
      'price': product.price,
      'description': product.description,
      'updatedAt': FieldValue.serverTimestamp(),
    });
    
    return product;
  }
  
  @override
  Future<void> deleteProduct(String id) async {
    await _productsCollection.doc(id).delete();
  }
}

// Controller dengan real-time stream
@riverpod
class ProductController extends _$ProductController {
  @override
  Stream<List<Product>> build() {
    final repository = ref.watch(productRepositoryProvider);
    return repository.watchProducts();
  }
  
  Future<void> addProduct({
    required String name,
    required double price,
    String? description,
  }) async {
    final repository = ref.read(productRepositoryProvider);
    final result = await repository.createProduct(Product(
      id: '',
      name: name,
      price: price,
      description: description,
      createdAt: DateTime.now(),
    ));
    
    result.fold(
      (failure) => throw failure,
      (_) {},
    );
  }
}

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
    
    // Products collection
    match /products/{productId} {
      allow read: if isAuthenticated();
      allow create: if isAuthenticated() && 
        request.resource.data.name is string &&
        request.resource.data.price is number;
      allow update: if isAuthenticated() &&
        request.resource.data.updatedAt == request.time;
      allow delete: if isAuthenticated();
    }
    
    // Users collection
    match /users/{userId} {
      allow read: if isAuthenticated() && isOwner(userId);
      allow write: if isAuthenticated() && isOwner(userId);
    }
  }
}
```

---

## Deliverables

### 4. Firebase Storage

**Description:** File upload dan download dengan progress tracking.

**Recommended Skills:** `senior-flutter-developer`, `senior-firebase-developer`

**Instructions:**
1. **Upload Service:**
   - Image upload with compression
   - Progress tracking
   - Error handling

2. **Download Service:**
   - Get download URL
   - Cache management

**Output Format:**
```dart
// core/storage/firebase_storage_service.dart
class FirebaseStorageService {
  final FirebaseStorage _storage;
  
  FirebaseStorageService({FirebaseStorage? storage})
      : _storage = storage ?? FirebaseStorage.instance;
  
  Future<Either<Failure, String>> uploadFile({
    required File file,
    required String path,
    void Function(double progress)? onProgress,
  }) async {
    try {
      final ref = _storage.ref().child(path);
      final uploadTask = ref.putFile(file);
      
      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        final progress = snapshot.bytesTransferred / snapshot.totalBytes;
        onProgress?.call(progress);
      });
      
      await uploadTask;
      final downloadUrl = await ref.getDownloadURL();
      
      return Right(downloadUrl);
    } on FirebaseException catch (e) {
      return Left(StorageFailure(e.message ?? 'Upload failed'));
    }
  }
  
  Future<Either<Failure, String>> uploadImage({
    required File imageFile,
    required String folder,
    int quality = 85,
    void Function(double progress)? onProgress,
  }) async {
    try {
      // Compress image
      final compressedFile = await FlutterImageCompress.compressWithFile(
        imageFile.absolute.path,
        quality: quality,
      );
      
      if (compressedFile == null) {
        return const Left(StorageFailure('Failed to compress image'));
      }
      
      final tempDir = await getTemporaryDirectory();
      final tempFile = File('${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg');
      await tempFile.writeAsBytes(compressedFile);
      
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_${folder}.jpg';
      final path = '$folder/$fileName';
      
      return uploadFile(
        file: tempFile,
        path: path,
        onProgress: onProgress,
      );
    } catch (e) {
      return Left(StorageFailure(e.toString()));
    }
  }
  
  Future<Either<Failure, Unit>> deleteFile(String url) async {
    try {
      final ref = _storage.refFromURL(url);
      await ref.delete();
      return const Right(unit);
    } on FirebaseException catch (e) {
      return Left(StorageFailure(e.message ?? 'Delete failed'));
    }
  }
}

// Usage in controller
@riverpod
class ImageUploadController extends _$ImageUploadController {
  @override
  FutureOr<void> build() {}
  
  Future<String?> uploadProfileImage(File imageFile) async {
    state = const AsyncValue.loading();
    
    final storageService = ref.read(firebaseStorageServiceProvider);
    final user = ref.read(authControllerProvider).valueOrNull;
    
    if (user == null) return null;
    
    final result = await storageService.uploadImage(
      imageFile: imageFile,
      folder: 'profile_images/${user.uid}',
      onProgress: (progress) {
        // Update progress UI
      },
    );
    
    state = await AsyncValue.guard(() async {
      return result.fold(
        (failure) => throw failure,
        (url) => url,
      );
    });
    
    return state.valueOrNull as String?;
  }
}
```

---

## Deliverables

### 5. Firebase Cloud Messaging (FCM)

**Description:** Push notifications dengan FCM.

**Recommended Skills:** `senior-flutter-developer`, `senior-firebase-developer`

**Instructions:**
1. **Setup FCM:**
   - Configure Android & iOS
   - Request permissions
   - Handle foreground/background messages

2. **Notification Service:**
   - Local notifications (flutter_local_notifications)
   - Navigate on notification tap
   - Data messages handling
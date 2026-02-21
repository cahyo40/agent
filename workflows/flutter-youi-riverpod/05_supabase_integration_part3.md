---
description: Integrasi Supabase sebagai alternative backend: Authentication, PostgreSQL Database, Realtime subscriptions, dan Storage. (Part 3/4)
---
# Workflow: Supabase Integration (Part 3/4)

> **Navigation:** This workflow is split into 4 parts.

## Deliverables

### 4. Realtime Subscriptions

**Description:** Real-time updates dengan Supabase Realtime.

**Recommended Skills:** `senior-flutter-developer`, `senior-supabase-developer`

**Instructions:**
1. **Setup Realtime:**
   - Enable realtime di Supabase Dashboard
   - Subscribe ke table changes
   - Handle INSERT, UPDATE, DELETE events

2. **Channel Management:**
   - Subscribe/unsubscribe
   - Broadcast events
   - Presence tracking

**Output Format:**
```dart
// features/product/data/datasources/product_realtime_ds.dart
class ProductRealtimeDataSource {
  final SupabaseClient _supabase;
  RealtimeChannel? _channel;
  
  ProductRealtimeDataSource({SupabaseClient? supabase})
      : _supabase = supabase ?? Supabase.instance.client;
  
  Stream<List<ProductModel>> watchProducts() {
    // Initial fetch
    final initialFuture = _supabase
        .from('products')
        .select()
        .order('created_at', ascending: false)
        .then((response) => (response as List)
            .map((json) => ProductModel.fromJson(json))
            .toList());
    
    // Subscribe to realtime changes
    _channel = _supabase
        .channel('products')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'products',
          callback: (payload) {
            // Handle realtime updates
          },
        )
        .subscribe();
    
    // Combine initial data dengan realtime stream
    return Stream.fromFuture(initialFuture);
  }
  
  Stream<ProductModel> watchProduct(String productId) {
    final controller = StreamController<ProductModel>.broadcast();
    
    // Initial fetch
    _supabase
        .from('products')
        .select()
        .eq('id', productId)
        .single()
        .then((response) {
      controller.add(ProductModel.fromJson(response));
    });
    
    // Subscribe to changes on this specific product
    _channel = _supabase
        .channel('product_$productId')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'products',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'id',
            value: productId,
          ),
          callback: (payload) {
            if (payload.newRecord != null) {
              controller.add(ProductModel.fromJson(payload.newRecord!));
            }
          },
        )
        .subscribe();
    
    return controller.stream;
  }
  
  void unsubscribe() {
    _channel?.unsubscribe();
    _channel = null;
  }
}

// Controller dengan realtime
@riverpod
class RealtimeProductController extends _$RealtimeProductController {
  ProductRealtimeDataSource? _dataSource;
  StreamSubscription? _subscription;
  
  @override
  Stream<List<Product>> build() {
    _dataSource = ref.watch(productRealtimeDataSourceProvider);
    
    // Cleanup on dispose
    ref.onDispose(() {
      _subscription?.cancel();
      _dataSource?.unsubscribe();
    });
    
    return _dataSource!.watchProducts().map(
      (models) => models.map((m) => m.toEntity()).toList(),
    );
  }
  
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    // Realtime akan otomatis update
  }
}
```

---

## Deliverables

### 5. Supabase Storage

**Description:** File storage dengan Supabase Storage.

**Recommended Skills:** `senior-flutter-developer`, `senior-supabase-developer`

**Instructions:**
1. **Upload Files:**
   - Image upload dengan compression
   - Progress tracking
   - Upload to specific bucket

2. **Download Files:**
   - Get signed URLs
   - Cache management

**Output Format:**
```dart
// core/storage/supabase_storage_service.dart
class SupabaseStorageService {
  final SupabaseClient _supabase;
  
  SupabaseStorageService({SupabaseClient? supabase})
      : _supabase = supabase ?? Supabase.instance.client;
  
  Future<Either<Failure, String>> uploadFile({
    required File file,
    required String bucket,
    required String path,
    void Function(double progress)? onProgress,
  }) async {
    try {
      final fileBytes = await file.readAsBytes();
      
      await _supabase.storage.from(bucket).uploadBinary(
        path,
        fileBytes,
        fileOptions: const FileOptions(upsert: true),
      );
      
      final publicUrl = _supabase.storage.from(bucket).getPublicUrl(path);
      
      return Right(publicUrl);
    } on StorageException catch (e) {
      return Left(StorageFailure(e.message));
    } catch (e) {
      return Left(StorageFailure(e.toString()));
    }
  }
  
  Future<Either<Failure, String>> uploadImage({
    required File imageFile,
    required String bucket,
    required String folder,
    int quality = 85,
  }) async {
    try {
      // Compress image
      final compressedBytes = await FlutterImageCompress.compressWithFile(
        imageFile.absolute.path,
        quality: quality,
      );
      
      if (compressedBytes == null) {
        return const Left(StorageFailure('Failed to compress image'));
      }
      
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      final path = '$folder/$fileName';
      
      await _supabase.storage.from(bucket).uploadBinary(
        path,
        compressedBytes,
        fileOptions: const FileOptions(contentType: 'image/jpeg'),
      );
      
      final publicUrl = _supabase.storage.from(bucket).getPublicUrl(path);
      
      return Right(publicUrl);
    } on StorageException catch (e) {
      return Left(StorageFailure(e.message));
    } catch (e) {
      return Left(StorageFailure(e.toString()));
    }
  }
  
  Future<Either<Failure, String>> getSignedUrl({
    required String bucket,
    required String path,
    int expiresIn = 60,
  }) async {
    try {
      final signedUrl = await _supabase.storage
          .from(bucket)
          .createSignedUrl(path, expiresIn);
      
      return Right(signedUrl);
    } on StorageException catch (e) {
      return Left(StorageFailure(e.message));
    }
  }
  
  Future<Either<Failure, Unit>> deleteFile({
    required String bucket,
    required String path,
  }) async {
    try {
      await _supabase.storage.from(bucket).remove([path]);
      return const Right(unit);
    } on StorageException catch (e) {
      return Left(StorageFailure(e.message));
    }
  }
}

// Storage RLS Policy
/*
-- Allow authenticated users to upload to their own folder
CREATE POLICY "Users can upload to their own folder"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (
  bucket_id = 'avatars' AND
  (storage.foldername(name))[1] = auth.uid()::text
);

-- Allow users to read all public files
CREATE POLICY "Anyone can view public files"
ON storage.objects FOR SELECT
TO anon
USING (bucket_id = 'public');
*/
```


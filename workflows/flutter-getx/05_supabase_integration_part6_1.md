---
description: Integrasi Supabase sebagai alternative backend dengan GetX state management: Authentication, PostgreSQL Database, Rea... (Sub-part 1/3)
---
# Workflow: Supabase Integration (GetX) (Part 6/7)

> **Navigation:** This workflow is split into 7 parts.

## Deliverables

### 5. Supabase Storage (GetX)

**Description:** File storage dengan Supabase Storage. Storage service adalah framework-agnostic, controller menggunakan GetX reactive state untuk upload progress.

**Recommended Skills:** `senior-flutter-developer`, `senior-supabase-developer`

**Instructions:**
1. **Upload Files:**
   - Image upload dengan compression
   - Progress tracking via `RxDouble`
   - Upload to specific bucket

2. **Download Files:**
   - Get signed URLs
   - Cache management

3. **Service Registration:**
   - `SupabaseStorageService` di-register via `Get.put()` / `Get.lazyPut()` di bindings

**Output Format:**
```dart
// ============================================================
// STORAGE SERVICE — Framework-agnostic, sama dengan Riverpod
// ============================================================

// core/storage/supabase_storage_service.dart
import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import '../error/failures.dart';

class SupabaseStorageService {
  final SupabaseClient _supabase;

  SupabaseStorageService({SupabaseClient? supabase})
      : _supabase = supabase ?? Supabase.instance.client;

  Future<Either<Failure, String>> uploadFile({
    required File file,
    required String bucket,
    required String path,
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
        return const Left(StorageFailure('Gagal compress gambar'));
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

  Future<Either<Failure, void>> deleteFile({
    required String bucket,
    required String path,
  }) async {
    try {
      await _supabase.storage.from(bucket).remove([path]);
      return const Right(null);
    } on StorageException catch (e) {
      return Left(StorageFailure(e.message));
    }
  }

  Future<Either<Failure, List<FileObject>>> listFiles({
    required String bucket,
    required String path,
  }) async {
    try {
      final files = await _supabase.storage.from(bucket).list(path: path);
      return Right(files);
    } on StorageException catch (e) {
      return Left(StorageFailure(e.message));
    }
  }
}

// ============================================================
// UPLOAD CONTROLLER — GetX version
// Menggunakan RxDouble untuk progress tracking
// ============================================================

// features/upload/presentation/controllers/upload_controller.dart
import 'dart:io';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/storage/supabase_storage_service.dart';

class UploadController extends GetxController {
  final SupabaseStorageService _storageService =
      Get.find<SupabaseStorageService>();

  // ---- Reactive State ----
  final RxDouble uploadProgress = 0.0.obs;
  final RxBool isUploading = false.obs;
  final RxString uploadedUrl = ''.obs;
  final RxString errorMessage = ''.obs;
  final Rx<File?> selectedFile = Rx<File?>(null);
  final RxList<String> uploadedFiles = <String>[].obs;

  // ---- Pick image dari gallery ----
  Future<void> pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1920,
      maxHeight: 1080,
    );

    if (pickedFile != null) {
      selectedFile.value = File(pickedFile.path);
    }
  }

  // ---- Pick image dari camera ----
  Future<void> takePhoto() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 1920,
      maxHeight: 1080,
    );

    if (pickedFile != null) {
      selectedFile.value = File(pickedFile.path);
    }
  }

  // ---- Upload file ----
  Future<void> uploadFile({
    required String bucket,
    required String folder,
  }) async {
    if (selectedFile.value == null) {
      Get.snackbar('Error', 'Pilih file terlebih dahulu');
      return;
    }

    isUploading.value = true;
    uploadProgress.value = 0.0;
    errorMessage.value = '';

    // Simulate progress (Supabase SDK belum support stream progress)
    _simulateProgress();

    final result = await _storageService.uploadImage(
      imageFile: selectedFile.value!,
      bucket: bucket,
      folder: folder,
    );

    result.fold(
      (failure) {
        errorMessage.value = failure.message;
        Get.snackbar('Upload Gagal', failure.message);
      },
      (url) {
        uploadedUrl.value = url;
        uploadedFiles.add(url);
        uploadProgress.value = 1.0;
        Get.snackbar('Success', 'File berhasil diupload');
      },
    );

    isUploading.value = false;
    selectedFile.value = null;
  }

  // ---- Upload generic file ----
  Future<String?> uploadGenericFile({
    required File file,
    required String bucket,
    required String path,
  }) async {
    isUploading.value = true;
    errorMessage.value = '';

    final result = await _storageService.uploadFile(
      file: file,
      bucket: bucket,
      path: path,
    );

    isUploading.value = false;

    return result.fold(
      (failure) {
        errorMessage.value = failure.message;
        return null;
      },
      (url) {
        uploadedFiles.add(url);
        return url;
      },
    );
  }

  // ---- Delete file ----
  Future<void> deleteFile({
    required String bucket,
    required String path,
  }) async {
    final result = await _storageService.deleteFile(
      bucket: bucket,
      path: path,
    );

    result.fold(
      (failure) => Get.snackbar('Error', failure.message),
      (_) {
        uploadedFiles.removeWhere((url) => url.contains(path));
        Get.snackbar('Success', 'File berhasil dihapus');
      },
    );
  }

  // Simulate upload progress karena Supabase belum support
  // real upload progress di uploadBinary
  void _simulateProgress() {
    Future.delayed(const Duration(milliseconds: 200), () {
      if (isUploading.value && uploadProgress.value < 0.9) {
        uploadProgress.value += 0.1;
        _simulateProgress();
      }
    });
  }

  // ---- Clear state ----
  void clearSelection() {
    selectedFile.value = null;
    uploadProgress.value = 0.0;
    errorMessage.value = '';
  }
}

// ============================================================
// UPLOAD PAGE — Contoh UI
// ============================================================

// features/upload/presentation/pages/upload_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/upload_controller.dart';

class UploadPage extends GetView<UploadController> {
  const UploadPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Upload File')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Preview selected file
            Obx(() {
              if (controller.selectedFile.value != null) {
                return ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(
                    controller.selectedFile.value!,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                );
              }
              return Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Text('Belum ada file dipilih'),
                ),
              );
            }),

            const SizedBox(height: 16),

            // Pick buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: controller.pickImage,
                    icon: const Icon(Icons.photo_library),
                    label: const Text('Gallery'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: controller.takePhoto,
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Camera'),
                  ),
                ),
              ],
            ),
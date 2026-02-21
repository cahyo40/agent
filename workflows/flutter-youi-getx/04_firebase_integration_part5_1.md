---
description: Integrasi Firebase services untuk Flutter dengan GetX state management: Authentication, Cloud Firestore, Firebase Sto... (Sub-part 1/3)
---
# Workflow: Firebase Integration (GetX) (Part 5/7)

> **Navigation:** This workflow is split into 7 parts.

## Deliverables

### 4. Firebase Storage (GetX)

**Description:** File upload dan download dengan progress tracking menggunakan reactive `RxDouble`.

**Recommended Skills:** `senior-flutter-developer`, `senior-firebase-developer`

**Instructions:**

1. **Storage Service (Framework-Agnostic):**

   Layer service tetap sama dengan Riverpod karena tidak bergantung pada state management. Service ini murni Firebase SDK.

   ```dart
   // core/storage/firebase_storage_service.dart
   import 'dart:io';
   import 'package:firebase_storage/firebase_storage.dart';
   import 'package:flutter_image_compress/flutter_image_compress.dart';
   import 'package:path_provider/path_provider.dart';
   import '../error/failures.dart';
   import '../utils/either.dart';

   class FirebaseStorageService {
     final FirebaseStorage _storage;

     FirebaseStorageService({FirebaseStorage? storage})
         : _storage = storage ?? FirebaseStorage.instance;

     /// Upload file ke Firebase Storage
     Future<Either<Failure, String>> uploadFile({
       required File file,
       required String path,
       void Function(double progress)? onProgress,
     }) async {
       try {
         final ref = _storage.ref().child(path);
         final uploadTask = ref.putFile(file);

         // Listen ke upload progress
         uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
           final progress = snapshot.bytesTransferred / snapshot.totalBytes;
           onProgress?.call(progress);
         });

         await uploadTask;
         final downloadUrl = await ref.getDownloadURL();

         return Right(downloadUrl);
       } on FirebaseException catch (e) {
         return Left(StorageFailure(e.message ?? 'Upload gagal'));
       } catch (e) {
         return Left(StorageFailure('Upload error: ${e.toString()}'));
       }
     }

     /// Upload image dengan compression
     Future<Either<Failure, String>> uploadImage({
       required File imageFile,
       required String folder,
       int quality = 85,
       void Function(double progress)? onProgress,
     }) async {
       try {
         // Compress image sebelum upload
         final compressedBytes = await FlutterImageCompress.compressWithFile(
           imageFile.absolute.path,
           quality: quality,
         );

         if (compressedBytes == null) {
           return const Left(StorageFailure('Gagal compress image'));
         }

         // Save compressed image ke temp file
         final tempDir = await getTemporaryDirectory();
         final timestamp = DateTime.now().millisecondsSinceEpoch;
         final tempFile = File('${tempDir.path}/${timestamp}_compressed.jpg');
         await tempFile.writeAsBytes(compressedBytes);

         final fileName = '${timestamp}_$folder.jpg';
         final path = '$folder/$fileName';

         return uploadFile(
           file: tempFile,
           path: path,
           onProgress: onProgress,
         );
       } catch (e) {
         return Left(StorageFailure('Image upload error: ${e.toString()}'));
       }
     }

     /// Delete file dari Storage
     Future<Either<Failure, void>> deleteFile(String url) async {
       try {
         final ref = _storage.refFromURL(url);
         await ref.delete();
         return const Right(null);
       } on FirebaseException catch (e) {
         return Left(StorageFailure(e.message ?? 'Delete gagal'));
       }
     }

     /// Get download URL dari path
     Future<Either<Failure, String>> getDownloadUrl(String path) async {
       try {
         final url = await _storage.ref().child(path).getDownloadURL();
         return Right(url);
       } on FirebaseException catch (e) {
         return Left(StorageFailure(e.message ?? 'Gagal mendapatkan URL'));
       }
     }
   }
   ```

2. **Upload Controller (GetX):**

   Perbedaan dengan Riverpod: menggunakan `RxDouble` untuk progress tracking yang reactive.

   ```dart
   // features/upload/controllers/upload_controller.dart
   import 'dart:io';
   import 'package:get/get.dart';
   import 'package:image_picker/image_picker.dart';
   import '../../../core/storage/firebase_storage_service.dart';
   import '../../auth/controllers/auth_controller.dart';

   class UploadController extends GetxController {
     final FirebaseStorageService _storageService =
         Get.find<FirebaseStorageService>();
     final AuthController _authController = Get.find<AuthController>();
     final ImagePicker _imagePicker = ImagePicker();

     // Reactive state
     final RxDouble uploadProgress = 0.0.obs;
     final RxBool isUploading = false.obs;
     final RxString uploadedUrl = ''.obs;
     final RxString errorMessage = ''.obs;
     final Rx<File?> selectedFile = Rx<File?>(null);

     /// Pick image dari gallery
     Future<void> pickImage() async {
       final XFile? pickedFile = await _imagePicker.pickImage(
         source: ImageSource.gallery,
         maxWidth: 1920,
         maxHeight: 1080,
         imageQuality: 85,
       );

       if (pickedFile != null) {
         selectedFile.value = File(pickedFile.path);
       }
     }

     /// Pick image dari camera
     Future<void> takePhoto() async {
       final XFile? pickedFile = await _imagePicker.pickImage(
         source: ImageSource.camera,
         maxWidth: 1920,
         maxHeight: 1080,
         imageQuality: 85,
       );

       if (pickedFile != null) {
         selectedFile.value = File(pickedFile.path);
       }
     }

     /// Upload profile image
     Future<String?> uploadProfileImage() async {
       final file = selectedFile.value;
       if (file == null) {
         errorMessage.value = 'Pilih gambar terlebih dahulu';
         return null;
       }

       final user = _authController.user.value;
       if (user == null) {
         errorMessage.value = 'User belum login';
         return null;
       }

       isUploading.value = true;
       uploadProgress.value = 0.0;
       errorMessage.value = '';

       final result = await _storageService.uploadImage(
         imageFile: file,
         folder: 'profile_images/${user.uid}',
         onProgress: (progress) {
           // Update reactive progress - UI otomatis update
           uploadProgress.value = progress;
         },
       );

       isUploading.value = false;

       return result.fold(
         (failure) {
           errorMessage.value = failure.message;
           Get.snackbar('Upload Gagal', failure.message);
           return null;
         },
         (url) {
           uploadedUrl.value = url;
           Get.snackbar('Berhasil', 'Gambar berhasil diupload');
           return url;
         },
       );
     }

     /// Upload generic file
     Future<String?> uploadFile({
       required File file,
       required String folder,
     }) async {
       isUploading.value = true;
       uploadProgress.value = 0.0;
       errorMessage.value = '';

       final result = await _storageService.uploadFile(
         file: file,
         path: '$folder/${DateTime.now().millisecondsSinceEpoch}',
         onProgress: (progress) {
           uploadProgress.value = progress;
         },
       );

       isUploading.value = false;

       return result.fold(
         (failure) {
           errorMessage.value = failure.message;
           return null;
         },
         (url) {
           uploadedUrl.value = url;
           return url;
         },
       );
     }

     /// Reset state
     void reset() {
       selectedFile.value = null;
       uploadProgress.value = 0.0;
       uploadedUrl.value = '';
       errorMessage.value = '';
       isUploading.value = false;
     }
   }
   ```

3. **Upload View dengan Progress:**
   ```dart
   // features/upload/views/upload_view.dart
   import 'package:flutter/material.dart';
   import 'package:get/get.dart';
   import '../controllers/upload_controller.dart';

   class UploadView extends GetView<UploadController> {
     const UploadView({super.key});

     @override
     Widget build(BuildContext context) {
       return Scaffold(
         appBar: AppBar(title: const Text('Upload Gambar')),
         body: Padding(
           padding: const EdgeInsets.all(16.0),
           child: Column(
             children: [
               // Preview selected image
               Obx(() {
                 final file = controller.selectedFile.value;
                 if (file != null) {
                   return ClipRRect(
                     borderRadius: BorderRadius.circular(12),
                     child: Image.file(
                       file,
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
                     color: Colors.grey[200],
                     borderRadius: BorderRadius.circular(12),
                   ),
                   child: const Icon(Icons.image, size: 64, color: Colors.grey),
                 );
               }),
               const SizedBox(height: 16),

               // Pick image buttons
               Row(
                 children: [
                   Expanded(
                     child: OutlinedButton.icon(
                       onPressed: controller.pickImage,
                       icon: const Icon(Icons.photo_library),
                       label: const Text('Gallery'),
                     ),
                   ),
                   const SizedBox(width: 8),
                   Expanded(
                     child: OutlinedButton.icon(
                       onPressed: controller.takePhoto,
                       icon: const Icon(Icons.camera_alt),
                       label: const Text('Camera'),
                     ),
                   ),
                 ],
               ),
               const SizedBox(height: 24),
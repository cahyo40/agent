---
description: Integrasi Supabase sebagai alternative backend dengan flutter_bloc state management: Authentication, PostgreSQL Datab... (Sub-part 1/3)
---
# Workflow: Supabase Integration (flutter_bloc) (Part 6/8)

> **Navigation:** This workflow is split into 8 parts.

## Deliverables

### 5. Supabase Storage (flutter_bloc — Cubit)

**Description:** File storage dengan Supabase Storage. Storage service adalah framework-agnostic, controller menggunakan `UploadCubit` untuk upload progress tracking. Cubit dipilih karena upload hanya perlu simple state transitions tanpa complex events.

**Recommended Skills:** `senior-flutter-developer`, `senior-supabase-developer`

**Instructions:**
1. **Upload Files:**
   - Image upload dengan compression
   - Progress tracking via state emission
   - Upload to specific bucket

2. **Download Files:**
   - Get signed URLs
   - Cache management

3. **Service Registration:**
   - `SupabaseStorageService` di-register via `@LazySingleton()` di get_it
   - `UploadCubit` di-provide via `BlocProvider` di widget tree

**Output Format:**
```dart
// ============================================================
// STORAGE SERVICE — Framework-agnostic, sama dengan Riverpod/GetX
// ============================================================

// core/storage/supabase_storage_service.dart
import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import '../error/failures.dart';

@lazySingleton
class SupabaseStorageService {
  final SupabaseClient _supabase;

  SupabaseStorageService(this._supabase);

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
// UPLOAD STATE
// ============================================================

// features/upload/presentation/cubit/upload_state.dart
import 'dart:io';
import 'package:equatable/equatable.dart';

enum UploadStatus { initial, picking, uploading, success, error }

class UploadState extends Equatable {
  final File? selectedFile;
  final double progress;
  final UploadStatus status;
  final String? uploadedUrl;
  final String? errorMessage;
  final List<String> uploadedFiles;

  const UploadState({
    this.selectedFile,
    this.progress = 0.0,
    this.status = UploadStatus.initial,
    this.uploadedUrl,
    this.errorMessage,
    this.uploadedFiles = const [],
  });

  UploadState copyWith({
    File? selectedFile,
    double? progress,
    UploadStatus? status,
    String? uploadedUrl,
    String? errorMessage,
    List<String>? uploadedFiles,
  }) {
    return UploadState(
      selectedFile: selectedFile ?? this.selectedFile,
      progress: progress ?? this.progress,
      status: status ?? this.status,
      uploadedUrl: uploadedUrl ?? this.uploadedUrl,
      errorMessage: errorMessage,
      uploadedFiles: uploadedFiles ?? this.uploadedFiles,
    );
  }

  @override
  List<Object?> get props =>
      [selectedFile, progress, status, uploadedUrl, errorMessage, uploadedFiles];
}

// ============================================================
// UPLOAD CUBIT — Simple state tanpa event classes
// ============================================================

// features/upload/presentation/cubit/upload_cubit.dart
import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/storage/supabase_storage_service.dart';
import 'upload_state.dart';

@injectable
class UploadCubit extends Cubit<UploadState> {
  final SupabaseStorageService _storageService;

  UploadCubit(this._storageService) : super(const UploadState());

  // ---- Pick image dari gallery ----
  Future<void> pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1920,
      maxHeight: 1080,
    );

    if (pickedFile != null) {
      emit(state.copyWith(
        selectedFile: File(pickedFile.path),
        status: UploadStatus.initial,
      ));
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
      emit(state.copyWith(
        selectedFile: File(pickedFile.path),
        status: UploadStatus.initial,
      ));
    }
  }

  // ---- Upload selected image ----
  Future<void> uploadImage({
    required String bucket,
    required String folder,
  }) async {
    if (state.selectedFile == null) return;

    emit(state.copyWith(status: UploadStatus.uploading, progress: 0.0));

    // Simulate progress (Supabase SDK belum support stream progress)
    _simulateProgress();

    final result = await _storageService.uploadImage(
      imageFile: state.selectedFile!,
      bucket: bucket,
      folder: folder,
    );

    result.fold(
      (failure) => emit(state.copyWith(
        status: UploadStatus.error,
        errorMessage: failure.message,
      )),
      (url) => emit(state.copyWith(
        status: UploadStatus.success,
        uploadedUrl: url,
        progress: 1.0,
        uploadedFiles: [...state.uploadedFiles, url],
        selectedFile: null,
      )),
    );
  }

  // ---- Upload generic file ----
  Future<String?> uploadGenericFile({
    required File file,
    required String bucket,
    required String path,
  }) async {
    emit(state.copyWith(status: UploadStatus.uploading));

    final result = await _storageService.uploadFile(
      file: file,
      bucket: bucket,
      path: path,
    );

    return result.fold(
      (failure) {
        emit(state.copyWith(
          status: UploadStatus.error,
          errorMessage: failure.message,
        ));
        return null;
      },
      (url) {
        emit(state.copyWith(
          status: UploadStatus.success,
          uploadedFiles: [...state.uploadedFiles, url],
        ));
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
      (failure) => emit(state.copyWith(
        status: UploadStatus.error,
        errorMessage: failure.message,
      )),
      (_) {
        final filtered = state.uploadedFiles
            .where((url) => !url.contains(path))
            .toList();
        emit(state.copyWith(
          status: UploadStatus.success,
          uploadedFiles: filtered,
        ));
      },
    );
  }

  // ---- Simulate upload progress ----
  void _simulateProgress() {
    Future.delayed(const Duration(milliseconds: 200), () {
      if (state.status == UploadStatus.uploading && state.progress < 0.9) {
        emit(state.copyWith(progress: state.progress + 0.1));
        _simulateProgress();
      }
    });
  }

  // ---- Clear state ----
  void clearSelection() {
    emit(state.copyWith(
      selectedFile: null,
      progress: 0.0,
      status: UploadStatus.initial,
      errorMessage: null,
    ));
  }
}

// ============================================================
// UPLOAD PAGE — Contoh UI dengan BlocBuilder/BlocListener
// ============================================================

// features/upload/presentation/pages/upload_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection.dart';
import '../cubit/upload_cubit.dart';
import '../cubit/upload_state.dart';
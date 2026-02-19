---
description: Integrasi Firebase services untuk Flutter dengan **flutter_bloc** sebagai state management: Authentication, Cloud Fir... (Part 5/7)
---
# Workflow: Firebase Integration (flutter_bloc) (Part 5/7)

> **Navigation:** This workflow is split into 7 parts.

## Deliverables

### 4. Firebase Storage (UploadCubit)

**Description:** File upload dan download dengan progress tracking menggunakan Cubit. Cubit dipilih karena upload adalah operasi satu arah tanpa complex event — cukup panggil method, state berubah. Tidak perlu event class.

**Recommended Skills:** `senior-flutter-developer`, `senior-firebase-developer`

**Instructions:**
1. **StorageService** — service layer untuk Firebase Storage operations
2. **UploadState** — granular states (initial, uploading+progress, uploaded+url, error)
3. **UploadCubit** — manage upload lifecycle
4. **DI Registration** — register semua component ke `get_it`

**Storage Service:**
```dart
// lib/core/storage/firebase_storage_service.dart
@lazySingleton
class FirebaseStorageService {
  final FirebaseStorage _storage;

  FirebaseStorageService(this._storage);

  /// Upload file ke Firebase Storage dengan progress callback.
  /// Return download URL jika sukses.
  Future<Either<Failure, String>> uploadFile({
    required File file,
    required String path,
    void Function(double progress)? onProgress,
  }) async {
    try {
      final ref = _storage.ref().child(path);
      final uploadTask = ref.putFile(file);

      // Listen progress events
      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        final progress = snapshot.bytesTransferred / snapshot.totalBytes;
        onProgress?.call(progress);
      });

      await uploadTask;
      final downloadUrl = await ref.getDownloadURL();

      return Right(downloadUrl);
    } on FirebaseException catch (e) {
      return Left(StorageFailure(e.message ?? 'Upload gagal'));
    }
  }

  /// Upload image dengan kompresi otomatis
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
        return const Left(StorageFailure('Gagal compress gambar'));
      }

      // Write compressed bytes ke temp file
      final tempDir = await getTemporaryDirectory();
      final fileName =
          '${DateTime.now().millisecondsSinceEpoch}_${folder.hashCode}.jpg';
      final tempFile = File('${tempDir.path}/$fileName');
      await tempFile.writeAsBytes(compressedBytes);

      final storagePath = '$folder/$fileName';

      return uploadFile(
        file: tempFile,
        path: storagePath,
        onProgress: onProgress,
      );
    } catch (e) {
      return Left(StorageFailure(e.toString()));
    }
  }

  /// Delete file dari Storage by URL
  Future<Either<Failure, Unit>> deleteFile(String url) async {
    try {
      final ref = _storage.refFromURL(url);
      await ref.delete();
      return const Right(unit);
    } on FirebaseException catch (e) {
      return Left(StorageFailure(e.message ?? 'Gagal menghapus file'));
    }
  }
}
```

**Upload State:**
```dart
// lib/features/upload/presentation/cubit/upload_state.dart
sealed class UploadState extends Equatable {
  const UploadState();

  @override
  List<Object?> get props => [];
}

/// Belum ada upload yang dimulai
class UploadInitial extends UploadState {
  const UploadInitial();
}

/// Upload sedang berjalan, dengan progress 0.0 - 1.0
class UploadInProgress extends UploadState {
  final double progress;
  final String fileName;

  const UploadInProgress({
    required this.progress,
    required this.fileName,
  });

  /// Helper: progress dalam persen (0 - 100)
  int get progressPercent => (progress * 100).toInt();

  @override
  List<Object?> get props => [progress, fileName];
}

/// Upload selesai, URL file tersedia
class UploadSuccess extends UploadState {
  final String downloadUrl;
  final String fileName;

  const UploadSuccess({
    required this.downloadUrl,
    required this.fileName,
  });

  @override
  List<Object?> get props => [downloadUrl, fileName];
}

/// Upload gagal
class UploadFailure extends UploadState {
  final String message;

  const UploadFailure(this.message);

  @override
  List<Object?> get props => [message];
}
```

**Upload Cubit:**
```dart
// lib/features/upload/presentation/cubit/upload_cubit.dart
@injectable
class UploadCubit extends Cubit<UploadState> {
  final FirebaseStorageService _storageService;

  UploadCubit(this._storageService) : super(const UploadInitial());

  /// Upload gambar profil ke Firebase Storage
  Future<String?> uploadProfileImage({
    required File imageFile,
    required String userId,
  }) async {
    final fileName = imageFile.path.split('/').last;

    emit(UploadInProgress(progress: 0.0, fileName: fileName));

    final result = await _storageService.uploadImage(
      imageFile: imageFile,
      folder: 'profile_images/$userId',
      quality: 85,
      onProgress: (progress) {
        // Emit state baru setiap progress berubah
        // PENTING: cek isClosed sebelum emit untuk avoid
        // "emit after close" error
        if (!isClosed) {
          emit(UploadInProgress(progress: progress, fileName: fileName));
        }
      },
    );

    return result.fold(
      (failure) {
        emit(UploadFailure(failure.message));
        return null;
      },
      (url) {
        emit(UploadSuccess(downloadUrl: url, fileName: fileName));
        return url;
      },
    );
  }

  /// Upload file generic (dokumen, dll)
  Future<String?> uploadFile({
    required File file,
    required String storagePath,
  }) async {
    final fileName = file.path.split('/').last;

    emit(UploadInProgress(progress: 0.0, fileName: fileName));

    final result = await _storageService.uploadFile(
      file: file,
      path: storagePath,
      onProgress: (progress) {
        if (!isClosed) {
          emit(UploadInProgress(progress: progress, fileName: fileName));
        }
      },
    );

    return result.fold(
      (failure) {
        emit(UploadFailure(failure.message));
        return null;
      },
      (url) {
        emit(UploadSuccess(downloadUrl: url, fileName: fileName));
        return url;
      },
    );
  }

  /// Reset state ke initial (untuk upload ulang)
  void reset() => emit(const UploadInitial());
}
```

**Penggunaan di UI:**
```dart
// lib/features/upload/presentation/widgets/upload_button.dart
class UploadButton extends StatelessWidget {
  const UploadButton({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<UploadCubit>(),
      child: BlocConsumer<UploadCubit, UploadState>(
        listener: (context, state) {
          if (state is UploadSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Upload berhasil!')),
            );
          }
          if (state is UploadFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Gagal: ${state.message}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          return Column(
            children: [
              // Progress indicator
              if (state is UploadInProgress) ...[
                LinearProgressIndicator(value: state.progress),
                const SizedBox(height: 8),
                Text('${state.progressPercent}% - ${state.fileName}'),
              ],

              // Upload button
              if (state is! UploadInProgress)
                ElevatedButton.icon(
                  onPressed: () => _pickAndUpload(context),
                  icon: const Icon(Icons.upload),
                  label: Text(
                    state is UploadSuccess
                        ? 'Upload Lagi'
                        : 'Pilih & Upload Gambar',
                  ),
                ),

              // Tampilkan preview jika sudah upload
              if (state is UploadSuccess) ...[
                const SizedBox(height: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    state.downloadUrl,
                    height: 200,
                    fit: BoxFit.cover,
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  Future<void> _pickAndUpload(BuildContext context) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;

    final userId = context.read<AuthBloc>().state;
    if (userId is! Authenticated) return;

    context.read<UploadCubit>().uploadProfileImage(
          imageFile: File(picked.path),
          userId: userId.user.uid,
        );
  }
}
```

**Storage Security Rules:**
```
// storage.rules
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    // Profile images: user hanya bisa write ke folder sendiri
    match /profile_images/{userId}/{allPaths=**} {
      allow read: if request.auth != null;
      allow write: if request.auth != null
        && request.auth.uid == userId
        && request.resource.size < 5 * 1024 * 1024  // Max 5MB
        && request.resource.contentType.matches('image/.*');
    }

    // Product images: authenticated user bisa upload
    match /product_images/{allPaths=**} {
      allow read: if request.auth != null;
      allow write: if request.auth != null
        && request.resource.size < 10 * 1024 * 1024  // Max 10MB
        && request.resource.contentType.matches('image/.*');
    }
  }
}
```

---


---
description: Generate feature baru dengan struktur Clean Architecture lengkap menggunakan GetX pattern. (Part 4/10)
---
# Workflow: Flutter Feature Maker (GetX) (Part 4/10)

> **Navigation:** This workflow is split into 10 parts.

## Deliverables

### 4. Presentation Layer Template (GetX-specific)

**Description:** Template untuk GetxController dengan reactive state menggunakan `.obs`. Ini perbedaan utama dengan Riverpod version yang pakai `AsyncNotifier` dan `AsyncValue`.

**Recommended Skills:** `senior-flutter-developer`

**Instructions:**
Buat template untuk:
1. GetxController dengan `.obs` reactive variables
2. CRUD methods dengan `Get.snackbar()` feedback
3. State management: `isLoading`, `errorMessage`, `selectedItem`
4. `onInit()` untuk initial data fetch

**Output Format:**
```dart
// TEMPLATE: controllers/{feature}_controller.dart
import 'package:get/get.dart';
import '../../../domain/entities/{feature_name}_entity.dart';
import '../../../domain/repositories/{feature_name}_repository.dart';

class {FeatureName}Controller extends GetxController {
  final {FeatureName}Repository _repository = Get.find<{FeatureName}Repository>();

  // ============================================================
  // Reactive State Variables (.obs)
  // ============================================================
  final RxList<{FeatureName}> {featureName}s = <{FeatureName}>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final Rx<{FeatureName}?> selectedItem = Rx<{FeatureName}?>(null);

  // Form-related state
  final RxBool isSubmitting = false.obs;

  // Pagination (optional)
  final RxInt currentPage = 1.obs;
  final RxBool hasMoreData = true.obs;

  // ============================================================
  // Lifecycle
  // ============================================================
  @override
  void onInit() {
    super.onInit();
    fetch{FeatureName}s();
  }

  @override
  void onClose() {
    // Cleanup jika diperlukan
    super.onClose();
  }

  // ============================================================
  // READ - Fetch All
  // ============================================================
  Future<void> fetch{FeatureName}s() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final result = await _repository.get{FeatureName}s();

      result.fold(
        (failure) {
          errorMessage.value = failure.message;
        },
        (data) {
          {featureName}s.assignAll(data);
        },
      );
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  // ============================================================
  // READ - Fetch By ID
  // ============================================================
  Future<void> fetch{FeatureName}ById(String id) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final result = await _repository.get{FeatureName}ById(id);

      result.fold(
        (failure) {
          errorMessage.value = failure.message;
          Get.snackbar(
            'Error',
            failure.message,
            snackPosition: SnackPosition.BOTTOM,
          );
        },
        (data) {
          selectedItem.value = data;
        },
      );
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  // ============================================================
  // CREATE
  // ============================================================
  Future<void> create{FeatureName}({
    required String name,
    String? description,
  }) async {
    try {
      isSubmitting.value = true;

      final new{FeatureName} = {FeatureName}(
        id: '', // Backend akan generate ID
        name: name,
        description: description,
        createdAt: DateTime.now(),
      );

      final result = await _repository.create{FeatureName}(new{FeatureName});

      result.fold(
        (failure) {
          Get.snackbar(
            'Error',
            failure.message,
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Get.theme.colorScheme.error,
            colorText: Get.theme.colorScheme.onError,
          );
        },
        ({featureName}) {
          {featureName}s.add({featureName});
          Get.back(); // Tutup form/dialog
          Get.snackbar(
            'Berhasil',
            '{FeatureName} berhasil dibuat',
            snackPosition: SnackPosition.BOTTOM,
          );
        },
      );
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isSubmitting.value = false;
    }
  }

  // ============================================================
  // UPDATE
  // ============================================================
  Future<void> update{FeatureName}({
    required String id,
    required String name,
    String? description,
  }) async {
    try {
      isSubmitting.value = true;

      // Ambil data existing lalu update fields
      final existing = {featureName}s.firstWhere((item) => item.id == id);
      final updated = existing.copyWith(
        name: name,
        description: description,
        updatedAt: DateTime.now(),
      );

      final result = await _repository.update{FeatureName}(updated);

      result.fold(
        (failure) {
          Get.snackbar(
            'Error',
            failure.message,
            snackPosition: SnackPosition.BOTTOM,
          );
        },
        ({featureName}) {
          // Update item di list
          final index = {featureName}s.indexWhere((item) => item.id == id);
          if (index != -1) {
            {featureName}s[index] = {featureName};
          }
          // Update selectedItem jika sedang dilihat
          if (selectedItem.value?.id == id) {
            selectedItem.value = {featureName};
          }
          Get.back();
          Get.snackbar(
            'Berhasil',
            '{FeatureName} berhasil diupdate',
            snackPosition: SnackPosition.BOTTOM,
          );
        },
      );
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isSubmitting.value = false;
    }
  }

  // ============================================================
  // DELETE
  // ============================================================
  Future<void> delete{FeatureName}(String id) async {
    try {
      final result = await _repository.delete{FeatureName}(id);

      result.fold(
        (failure) {
          Get.snackbar(
            'Error',
            failure.message,
            snackPosition: SnackPosition.BOTTOM,
          );
        },
        (_) {
          {featureName}s.removeWhere((item) => item.id == id);
          // Clear selectedItem jika yang dihapus sedang dipilih
          if (selectedItem.value?.id == id) {
            selectedItem.value = null;
          }
          Get.snackbar(
            'Berhasil',
            '{FeatureName} berhasil dihapus',
            snackPosition: SnackPosition.BOTTOM,
          );
        },
      );
    } catch (e) {
      Get.snackbar('Error', e.toString());
    }
  }

  // ============================================================
  // Helper Methods
  // ============================================================
  void selectItem({FeatureName} item) {
    selectedItem.value = item;
  }

  void clearSelectedItem() {
    selectedItem.value = null;
  }

  /// Confirm delete dengan dialog
  void confirmDelete(String id) {
    Get.dialog(
      AlertDialog(
        title: const Text('Hapus {FeatureName}'),
        content: const Text('Apakah Anda yakin ingin menghapus item ini?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              Get.back(); // Tutup dialog
              delete{FeatureName}(id);
            },
            child: const Text(
              'Hapus',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
```

---


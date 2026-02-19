---
description: Generate feature baru dengan struktur Clean Architecture lengkap menggunakan GetX pattern. (Sub-part 1/3)
---
# Workflow: Flutter Feature Maker (GetX) (Part 5/10)

> **Navigation:** This workflow is split into 10 parts.

## Deliverables

### 5. Complete Screen Template (GetX-specific)

**Description:** Template screen lengkap menggunakan `GetView<Controller>` dengan `Obx(() { ... })` untuk reactive UI. Perbedaan utama dengan Riverpod:
- `GetView<Controller>` bukan `ConsumerWidget`
- `Obx(() { ... })` bukan `.when(data:, error:, loading:)`
- Manual state check: `isLoading`, `errorMessage`, `isEmpty`
- `Get.toNamed()` bukan `context.push()`
- `Get.dialog()` bukan `showDialog()`
- `Get.back()` bukan `Navigator.pop()`

**Recommended Skills:** `senior-flutter-developer`

**Output Format:**
```dart
// TEMPLATE: views/{feature}_list_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../routes/app_routes.dart';
import '../controllers/{feature_name}_controller.dart';
import 'widgets/{feature_name}_list_item.dart';
import 'widgets/{feature_name}_shimmer.dart';

class {FeatureName}ListView extends GetView<{FeatureName}Controller> {
  const {FeatureName}ListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('{FeatureName}s'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: controller.fetch{FeatureName}s,
          ),
        ],
      ),
      body: Obx(() {
        // State 1: Loading (initial load, list masih kosong)
        if (controller.isLoading.value && controller.{featureName}s.isEmpty) {
          return const {FeatureName}ListShimmer();
        }

        // State 2: Error
        if (controller.errorMessage.value.isNotEmpty &&
            controller.{featureName}s.isEmpty) {
          return _buildErrorView();
        }

        // State 3: Empty
        if (controller.{featureName}s.isEmpty) {
          return _buildEmptyView();
        }

        // State 4: Data loaded
        return RefreshIndicator(
          onRefresh: controller.fetch{FeatureName}s,
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: controller.{featureName}s.length,
            itemBuilder: (context, index) {
              final item = controller.{featureName}s[index];
              return {FeatureName}ListItem(
                {featureName}: item,
                onTap: () {
                  controller.selectItem(item);
                  Get.toNamed(
                    AppRoutes.{featureName}DetailPath(item.id),
                  );
                },
                onDelete: () => controller.confirmDelete(item.id),
              );
            },
          ),
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              controller.errorMessage.value,
              textAlign: TextAlign.center,
              style: Get.textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: controller.fetch{FeatureName}s,
              icon: const Icon(Icons.refresh),
              label: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.inbox_outlined,
            size: 64,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          Text(
            'Belum ada {featureName}',
            style: Get.textTheme.titleMedium?.copyWith(
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap tombol + untuk menambahkan',
            style: Get.textTheme.bodyMedium?.copyWith(
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  void _showCreateDialog() {
    final nameController = TextEditingController();
    final descController = TextEditingController();

    Get.dialog(
      AlertDialog(
        title: const Text('Buat {FeatureName} Baru'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Nama',
                hintText: 'Masukkan nama {featureName}',
              ),
              autofocus: true,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: descController,
              decoration: const InputDecoration(
                labelText: 'Deskripsi (opsional)',
                hintText: 'Masukkan deskripsi',
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Batal'),
          ),
          Obx(() => ElevatedButton(
                onPressed: controller.isSubmitting.value
                    ? null
                    : () {
                        if (nameController.text.trim().isEmpty) {
                          Get.snackbar('Error', 'Nama tidak boleh kosong');
                          return;
                        }
                        controller.create{FeatureName}(
                          name: nameController.text.trim(),
                          description: descController.text.trim().isEmpty
                              ? null
                              : descController.text.trim(),
                        );
                      },
                child: controller.isSubmitting.value
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Simpan'),
              )),
        ],
      ),
    );
  }
}

// TEMPLATE: views/{feature}_detail_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/{feature_name}_controller.dart';

class {FeatureName}DetailView extends GetView<{FeatureName}Controller> {
  const {FeatureName}DetailView({super.key});

  @override
  Widget build(BuildContext context) {
    // Ambil ID dari route parameter
    final String? id = Get.parameters['id'];

    // Fetch detail jika selectedItem belum ada
    if (controller.selectedItem.value == null && id != null) {
      controller.fetch{FeatureName}ById(id);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail {FeatureName}'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            controller.clearSelectedItem();
            Get.back();
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _showEditDialog(),
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () {
              if (id != null) {
                controller.confirmDelete(id);
              }
            },
          ),
        ],
      ),
      body: Obx(() {
        // Loading state
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        // Error state
        if (controller.errorMessage.value.isNotEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(controller.errorMessage.value),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    if (id != null) controller.fetch{FeatureName}ById(id);
                  },
                  child: const Text('Coba Lagi'),
                ),
              ],
            ),
          );
        }

        // Data not found
        final item = controller.selectedItem.value;
        if (item == null) {
          return const Center(child: Text('{FeatureName} tidak ditemukan'));
        }

        // Data loaded
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        style: Get.textTheme.headlineSmall,
                      ),
                      if (item.description != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          item.description!,
                          style: Get.textTheme.bodyLarge,
                        ),
                      ],
                      const SizedBox(height: 16),
                      const Divider(),
                      const SizedBox(height: 8),
                      _buildInfoRow(
                        'Dibuat',
                        _formatDate(item.createdAt),
                      ),
                      if (item.updatedAt != null)
                        _buildInfoRow(
                          'Diupdate',
                          _formatDate(item.updatedAt!),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
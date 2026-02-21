---
description: Generate feature baru dengan struktur Clean Architecture lengkap menggunakan GetX + YoUI pattern. (Part 9/10)
---
# Workflow: Flutter Feature Maker (GetX) (Part 9/10)

> **Navigation:** This workflow is split into 10 parts.

## Usage Example

### Step 7: View -- List Screen

**File: `lib/features/todo/views/todo_list_view.dart`**
```dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yo_ui/yo_ui.dart';
import '../../../routes/app_routes.dart';
import '../controllers/todo_controller.dart';

class TodoListView extends GetView<TodoController> {
  const TodoListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Todos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: controller.fetchTodos,
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Obx(() => Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildFilterChip('Semua', 'all'),
                  _buildFilterChip('Aktif (${controller.activeCount})', 'active'),
                  _buildFilterChip('Selesai (${controller.completedCount})', 'completed'),
                ],
              )),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.todos.isEmpty) {
          return ListView.builder(
            itemCount: 5,
            padding: const EdgeInsets.all(16),
            itemBuilder: (context, index) =>
                Padding(
              padding:
                  const EdgeInsets.only(bottom: 8),
              child: YoShimmer.card(height: 72),
            ),
          );

        if (controller.errorMessage.value.isNotEmpty && controller.todos.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Theme.of(context).colorScheme.error,
                ),
                const SizedBox(height: 16),
                YoText.bodyLarge(controller.errorMessage.value),
                const SizedBox(height: 16),
                YoButton.primary(
                  text: 'Coba Lagi',
                  onPressed: controller.fetchTodos,
                ),
              ],
            ),
          );
        }

        final items = controller.filteredTodos;

        if (items.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.checklist, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                YoText.bodyMedium('Tidak ada todo'),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: controller.fetchTodos,
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final todo = items[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: YoCard(
                  child: ListTile(
                    leading: Checkbox(
                      value: todo.isCompleted,
                      onChanged: (_) => controller.toggleComplete(todo.id),
                    ),
                    title: YoText.bodyLarge(
                      todo.title,
                    ),
                    subtitle: todo.description != null
                        ? YoText.bodySmall(
                            todo.description!,
                          )
                        : null,
                    onTap: () {
                      controller.selectedTodo.value = todo;
                      Get.toNamed(AppRoutes.todoDetailPath(todo.id));
                    },
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: () => controller.confirmDelete(todo.id, context),
                    ),
                  ),
                ),
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

  Widget _buildFilterChip(String label, String value) {
    return ChoiceChip(
      label: Text(label),
      selected: controller.filter.value == value,
      onSelected: (_) => controller.setFilter(value),
    );
  }

  void _showCreateDialog() {
    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();

    Get.dialog(
      AlertDialog(
        title: const Text('Buat Todo Baru'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleCtrl,
              decoration: const InputDecoration(labelText: 'Judul'),
              autofocus: true,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: descCtrl,
              decoration: const InputDecoration(labelText: 'Deskripsi (opsional)'),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          YoButton.ghost(
            text: 'Batal',
            onPressed: () => Get.back(),
          ),
          Obx(() => YoButton.primary(
                text: controller.isSubmitting.value
                    ? 'Menyimpan...'
                    : 'Simpan',
                onPressed: controller.isSubmitting.value
                    ? null
                    : () {
                        if (titleCtrl.text.trim().isEmpty) {
                          YoToast.error(
                            context: Get.context!,
                            message: 'Judul tidak boleh kosong',
                          );
                          return;
                        }
                        controller.createTodo(
                          title: titleCtrl.text.trim(),
                          description: descCtrl.text.trim().isEmpty
                              ? null
                              : descCtrl.text.trim(),
                        );
                      },
              )),
        ],
      ),
    );
  }
}
```

## Usage Example

### Step 8: Test Feature

```bash
# Langsung run -- tidak perlu code generation!
flutter analyze
flutter run

# Test navigation:
# 1. List screen -> Tap + -> Create dialog
# 2. Create todo -> Cek muncul di list
# 3. Tap checkbox -> Toggle complete
# 4. Tap todo item -> Detail screen
# 5. Swipe/pull down -> Refresh
# 6. Tap delete -> Confirmation dialog -> Delete
# 7. Filter chips -> All / Active / Completed
```


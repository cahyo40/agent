---
description: Generate feature baru dengan struktur Clean Architecture lengkap menggunakan GetX pattern. (Sub-part 2/3)
---
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  void _showEditDialog() {
    final item = controller.selectedItem.value;
    if (item == null) return;

    final nameController = TextEditingController(text: item.name);
    final descController = TextEditingController(text: item.description ?? '');

    Get.dialog(
      AlertDialog(
        title: const Text('Edit {FeatureName}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Nama'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: descController,
              decoration: const InputDecoration(labelText: 'Deskripsi'),
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
                        controller.update{FeatureName}(
                          id: item.id,
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
                    : const Text('Update'),
              )),
        ],
      ),
    );
  }
}

// TEMPLATE: views/widgets/{feature}_list_item.dart
import 'package:flutter/material.dart';
import '../../../../domain/entities/{feature_name}_entity.dart';

class {FeatureName}ListItem extends StatelessWidget {
  final {FeatureName} {featureName};
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const {FeatureName}ListItem({
    super.key,
    required this.{featureName},
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          child: Text(
            {featureName}.name.isNotEmpty
                ? {featureName}.name[0].toUpperCase()
                : '?',
          ),
        ),
        title: Text({featureName}.name),
        subtitle: {featureName}.description != null
            ? Text(
                {featureName}.description!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              )
            : null,
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, color: Colors.red),
          onPressed: onDelete,
        ),
        onTap: onTap,
      ),
    );
  }
}

// TEMPLATE: views/widgets/{feature}_form.dart
import 'package:flutter/material.dart';

class {FeatureName}Form extends StatefulWidget {
  final String? initialName;
  final String? initialDescription;
  final bool isLoading;
  final void Function(String name, String? description) onSubmit;

  const {FeatureName}Form({
    super.key,
    this.initialName,
    this.initialDescription,
    this.isLoading = false,
    required this.onSubmit,
  });

  @override
  State<{FeatureName}Form> createState() => _{FeatureName}FormState();
}

class _{FeatureName}FormState extends State<{FeatureName}Form> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _descController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);
    _descController = TextEditingController(text: widget.initialDescription);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Nama',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Nama wajib diisi';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _descController,
            decoration: const InputDecoration(
              labelText: 'Deskripsi (opsional)',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: widget.isLoading ? null : _submit,
              child: widget.isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Simpan'),
            ),
          ),
        ],
      ),
    );
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      widget.onSubmit(
        _nameController.text.trim(),
        _descController.text.trim().isEmpty
            ? null
            : _descController.text.trim(),
      );
    }
  }
}
```


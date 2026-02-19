---
description: Generate feature baru dengan struktur Clean Architecture lengkap menggunakan **flutter_bloc**. (Part 6/11)
---
# Workflow: Flutter BLoC Feature Maker (Part 6/11)

> **Navigation:** This workflow is split into 11 parts.

## Deliverables

### 10. List Screen (Presentation Layer)

**Description:** Screen utama yang menampilkan list {featureName}. Menggunakan `BlocConsumer` dengan `listener:` untuk side effects (snackbar, navigation) dan `builder:` untuk render UI berdasarkan state.

**Template: `presentation/screens/{feature_name}_list_screen.dart`**
```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/routes.dart';
import '../../../../injection.dart'; // get_it
import '../bloc/{feature_name}_bloc.dart';
import '../widgets/{feature_name}_list_item.dart';
import '../widgets/{feature_name}_shimmer.dart';

class {FeatureName}ListScreen extends StatelessWidget {
  const {FeatureName}ListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // BlocProvider: inject BLoC dari get_it dan auto-dispose
    return BlocProvider(
      create: (_) => getIt<{FeatureName}Bloc>()..add(const Load{FeatureName}s()),
      child: const _{FeatureName}ListView(),
    );
  }
}

class _{FeatureName}ListView extends StatelessWidget {
  const _{FeatureName}ListView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('{FeatureName}s'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<{FeatureName}Bloc>().add(const Refresh{FeatureName}s());
            },
          ),
        ],
      ),
      // BlocConsumer: listener untuk side effects, builder untuk UI
      body: BlocConsumer<{FeatureName}Bloc, {FeatureName}State>(
        // === LISTENER: Side effects (snackbar, dialog, navigation) ===
        listener: (context, state) {
          switch (state) {
            case {FeatureName}Created(:final {featureName}):
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${featureName}.name} berhasil dibuat!'),
                  backgroundColor: Colors.green,
                ),
              );
            case {FeatureName}Deleted():
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('{FeatureName} berhasil dihapus!'),
                  backgroundColor: Colors.orange,
                ),
              );
            case {FeatureName}Updated(:final {featureName}):
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${featureName}.name} berhasil diupdate!'),
                  backgroundColor: Colors.blue,
                ),
              );
            case {FeatureName}OperationError(:final message):
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Error: $message'),
                  backgroundColor: Colors.red,
                ),
              );
            default:
              break;
          }
        },
        // === BUILDER: Render UI berdasarkan state ===
        builder: (context, state) {
          return switch (state) {
            {FeatureName}Initial() => const Center(
                child: Text('Tap refresh untuk memuat data'),
              ),
            {FeatureName}Loading() => const {FeatureName}ListShimmer(),
            {FeatureName}Loaded(:final {featureName}s) => _buildList(
                context,
                {featureName}s,
              ),
            {FeatureName}Error(:final message) => _buildError(
                context,
                message,
              ),
            // Side effect states yang juga punya list data
            {FeatureName}Created(:final updated{FeatureName}s) =>
              _buildList(context, updated{FeatureName}s),
            {FeatureName}Updated(:final updated{FeatureName}s) =>
              _buildList(context, updated{FeatureName}s),
            {FeatureName}Deleted(:final updated{FeatureName}s) =>
              _buildList(context, updated{FeatureName}s),
            {FeatureName}OperationError(:final current{FeatureName}s) =>
              _buildList(context, current{FeatureName}s),
            // Detail state: seharusnya tidak muncul di list screen
            {FeatureName}DetailLoaded() => const SizedBox.shrink(),
          };
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildList(BuildContext context, List<{FeatureName}> {featureName}s) {
    if ({featureName}s.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Belum ada {featureName}',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: () => _showCreateDialog(context),
              icon: const Icon(Icons.add),
              label: const Text('Tambah {FeatureName}'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        context.read<{FeatureName}Bloc>().add(const Refresh{FeatureName}s());
      },
      child: ListView.builder(
        itemCount: {featureName}s.length,
        itemBuilder: (context, index) {
          final {featureName} = {featureName}s[index];
          return {FeatureName}ListItem(
            {featureName}: {featureName},
            onTap: () => context.push(
              AppRoutes.{featureName}DetailPath({featureName}.id),
            ),
            onDelete: () => _confirmDelete(context, {featureName}.id),
          );
        },
      ),
    );
  }

  Widget _buildError(BuildContext context, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
          const SizedBox(height: 16),
          Text('Error: $message', textAlign: TextAlign.center),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              context.read<{FeatureName}Bloc>().add(const Load{FeatureName}s());
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Coba Lagi'),
          ),
        ],
      ),
    );
  }

  void _showCreateDialog(BuildContext context) {
    final nameController = TextEditingController();
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Tambah {FeatureName}'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(
            labelText: 'Nama',
            hintText: 'Masukkan nama {featureName}',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isNotEmpty) {
                context.read<{FeatureName}Bloc>().add(
                      Create{FeatureName}Event(name: nameController.text),
                    );
                Navigator.pop(dialogContext);
              }
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, String id) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Hapus {FeatureName}'),
        content: const Text('Yakin ingin menghapus {featureName} ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              context.read<{FeatureName}Bloc>().add(
                    Delete{FeatureName}Event(id),
                  );
              Navigator.pop(dialogContext);
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
```

---

## Deliverables

### 11. Detail Screen

**Template: `presentation/screens/{feature_name}_detail_screen.dart`**
```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../injection.dart';
import '../../domain/entities/{feature_name}_entity.dart';
import '../bloc/{feature_name}_bloc.dart';

class {FeatureName}DetailScreen extends StatelessWidget {
  final String {featureName}Id;

  const {FeatureName}DetailScreen({super.key, required this.{featureName}Id});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<{FeatureName}Bloc>()
        ..add(Load{FeatureName}ById({featureName}Id)),
      child: Scaffold(
        appBar: AppBar(title: const Text('{FeatureName} Detail')),
        body: BlocBuilder<{FeatureName}Bloc, {FeatureName}State>(
          builder: (context, state) {
            return switch (state) {
              {FeatureName}Loading() => const Center(
                  child: CircularProgressIndicator(),
                ),
              {FeatureName}DetailLoaded(:final {featureName}) =>
                _buildDetail(context, {featureName}),
              {FeatureName}Error(:final message) => Center(
                  child: Text('Error: $message'),
                ),
              _ => const SizedBox.shrink(),
            };
          },
        ),
      ),
    );
  }

  Widget _buildDetail(BuildContext context, {FeatureName} {featureName}) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            {featureName}.name,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          if ({featureName}.description != null) ...[
            Text(
              {featureName}.description!,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 16),
          ],
          Chip(
            label: Text({featureName}.isActive ? 'Aktif' : 'Nonaktif'),
            backgroundColor:
                {featureName}.isActive ? Colors.green[100] : Colors.red[100],
          ),
          const SizedBox(height: 8),
          Text(
            'Dibuat: ${{featureName}.createdAt}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
```

---


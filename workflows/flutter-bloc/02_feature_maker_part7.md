---
description: Generate feature baru dengan struktur Clean Architecture lengkap menggunakan **flutter_bloc**. (Part 7/11)
---
# Workflow: Flutter BLoC Feature Maker (Part 7/11)

> **Navigation:** This workflow is split into 11 parts.

## Deliverables

### 12. Widget Templates

**Template: `presentation/widgets/{feature_name}_list_item.dart`**
```dart
import 'package:flutter/material.dart';
import '../../domain/entities/{feature_name}_entity.dart';

class {FeatureName}ListItem extends StatelessWidget {
  final {FeatureName} {featureName};
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const {FeatureName}ListItem({
    super.key,
    required this.{featureName},
    this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor:
              {featureName}.isActive ? Colors.green[100] : Colors.grey[300],
          child: Text(
            {featureName}.name[0].toUpperCase(),
            style: TextStyle(
              color: {featureName}.isActive ? Colors.green[800] : Colors.grey[600],
            ),
          ),
        ),
        title: Text({featureName}.name),
        subtitle: {featureName}.description != null
            ? Text(
                {featureName}.description!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              )
            : null,
        trailing: onDelete != null
            ? IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                onPressed: onDelete,
              )
            : null,
        onTap: onTap,
      ),
    );
  }
}
```

**Template: `presentation/widgets/{feature_name}_form.dart`**
```dart
import 'package:flutter/material.dart';

class {FeatureName}Form extends StatefulWidget {
  final String? initialName;
  final String? initialDescription;
  final void Function(String name, String? description) onSubmit;

  const {FeatureName}Form({
    super.key,
    this.initialName,
    this.initialDescription,
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
            decoration: const InputDecoration(labelText: 'Nama'),
            validator: (v) => v == null || v.isEmpty ? 'Nama wajib diisi' : null,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _descController,
            decoration: const InputDecoration(labelText: 'Deskripsi (opsional)'),
            maxLines: 3,
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                if (_formKey.currentState?.validate() ?? false) {
                  widget.onSubmit(
                    _nameController.text,
                    _descController.text.isNotEmpty ? _descController.text : null,
                  );
                }
              },
              child: const Text('Simpan'),
            ),
          ),
        ],
      ),
    );
  }
}
```

**Template: `presentation/widgets/{feature_name}_shimmer.dart`**
```dart
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class {FeatureName}ListShimmer extends StatelessWidget {
  const {FeatureName}ListShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 8,
      itemBuilder: (context, index) => const _{FeatureName}ListItemShimmer(),
    );
  }
}

class _{FeatureName}ListItemShimmer extends StatelessWidget {
  const _{FeatureName}ListItemShimmer();

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: ListTile(
          leading: const CircleAvatar(backgroundColor: Colors.white),
          title: Container(
            height: 14,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          subtitle: Container(
            height: 10,
            width: 150,
            margin: const EdgeInsets.only(top: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          trailing: Container(
            width: 24,
            height: 24,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );
  }
}
```

---

## Deliverables

### 13. Route Registration (GoRouter)

**Description:** Register feature routes di GoRouter. Sama seperti Riverpod version.

**Step 1: Route constants `lib/core/router/routes.dart`**
```dart
class AppRoutes {
  // ... existing routes ...

  // {FeatureName} routes
  static const String {featureName}s = '/{feature_name}s';
  static const String {featureName}Detail = '/{feature_name}s/:id';
  static const String {featureName}Create = '/{feature_name}s/create';
  static const String {featureName}Edit = '/{feature_name}s/:id/edit';

  // Helper methods
  static String {featureName}DetailPath(String id) => '/{feature_name}s/$id';
  static String {featureName}EditPath(String id) => '/{feature_name}s/$id/edit';
}
```

**Step 2: GoRouter config `lib/core/router/app_router.dart`**
```dart
import '../../features/{feature_name}/presentation/screens/{feature_name}_list_screen.dart';
import '../../features/{feature_name}/presentation/screens/{feature_name}_detail_screen.dart';

// Add to GoRouter routes list:
GoRoute(
  path: AppRoutes.{featureName}s,
  builder: (context, state) => const {FeatureName}ListScreen(),
  routes: [
    GoRoute(
      path: 'create',
      builder: (context, state) => const {FeatureName}CreateScreen(),
    ),
    GoRoute(
      path: ':id',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return {FeatureName}DetailScreen({featureName}Id: id);
      },
      routes: [
        GoRoute(
          path: 'edit',
          builder: (context, state) {
            final id = state.pathParameters['id']!;
            return {FeatureName}EditScreen({featureName}Id: id);
          },
        ),
      ],
    ),
  ],
),
```

**Step 3: Navigation dari screen**
```dart
// Navigate to list
context.push(AppRoutes.{featureName}s);

// Navigate to detail
context.push(AppRoutes.{featureName}DetailPath(item.id));

// Navigate to create
context.push(AppRoutes.{featureName}Create);

// Navigate back
context.pop();
```

---

## Deliverables

### 14. DI Registration (get_it + injectable)

**Description:** Dependency injection menggunakan get_it + injectable. Dua opsi: annotation-based (injectable) atau manual.

**Opsi A: Dengan @injectable annotations (recommended)**

Semua class yang sudah di-annotasi (`@injectable`, `@lazySingleton`, `@LazySingleton(as:)`) akan otomatis ter-register saat menjalankan `build_runner`.

```dart
// lib/injection.dart
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';

import 'injection.config.dart';

final getIt = GetIt.instance;

@InjectableInit()
void configureDependencies() => getIt.init();
```

```dart
// lib/main.dart
void main() {
  configureDependencies();
  runApp(const MyApp());
}
```

Jalankan code generation:
```bash
dart run build_runner build -d
```

**Opsi B: Manual registration (tanpa injectable)**
```dart
// lib/features/{feature_name}/di/{feature_name}_module.dart
import 'package:get_it/get_it.dart';

void register{FeatureName}Feature(GetIt sl) {
  // BLoC
  sl.registerFactory(
    () => {FeatureName}Bloc(
      get{FeatureName}s: sl(),
      get{FeatureName}ById: sl(),
      create{FeatureName}: sl(),
      update{FeatureName}: sl(),
      delete{FeatureName}: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => Get{FeatureName}s(sl()));
  sl.registerLazySingleton(() => Get{FeatureName}ById(sl()));
  sl.registerLazySingleton(() => Create{FeatureName}(sl()));
  sl.registerLazySingleton(() => Update{FeatureName}(sl()));
  sl.registerLazySingleton(() => Delete{FeatureName}(sl()));

  // Repository
  sl.registerLazySingleton<{FeatureName}Repository>(
    () => {FeatureName}RepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  // Data sources
  sl.registerLazySingleton<{FeatureName}RemoteDataSource>(
    () => {FeatureName}RemoteDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<{FeatureName}LocalDataSource>(
    () => {FeatureName}LocalDataSourceImpl(sl()),
  );
}
```

```dart
// lib/injection.dart (manual version)
import 'package:get_it/get_it.dart';
import 'features/{feature_name}/di/{feature_name}_module.dart';

final getIt = GetIt.instance;

void configureDependencies() {
  // Core
  // ... register Dio, SharedPreferences, NetworkInfo ...

  // Features
  register{FeatureName}Feature(getIt);
}
```

**PENTING:** BLoC harus di-register sebagai `registerFactory` (bukan singleton) agar setiap screen mendapat instance baru. Use cases dan repositories boleh singleton.

---


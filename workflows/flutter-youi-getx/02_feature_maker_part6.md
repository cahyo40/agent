---
description: Generate feature baru dengan struktur Clean Architecture lengkap menggunakan GetX + YoUI pattern. (Part 6/10)
---
# Workflow: Flutter Feature Maker (GetX) (Part 6/10)

> **Navigation:** This workflow is split into 10 parts.

## Deliverables

### 6. Route Registration Template (GetX-specific)

**Description:** Template untuk register feature routes dengan `GetPage` di `app_pages.dart`. Perbedaan utama dengan Riverpod:
- `GetPage` bukan `GoRoute`
- `binding:` untuk auto-inject dependencies
- `Get.toNamed()` bukan `context.push()`
- `Get.parameters['id']` bukan `state.pathParameters['id']`

**Recommended Skills:** `senior-flutter-developer`

**Output Format:**
```dart
// STEP 1: Tambah route constants di lib/routes/app_routes.dart
abstract class AppRoutes {
  // ... existing routes ...

  // {FeatureName} routes
  static const String {featureName}s = '/{feature_name}s';
  static const String {featureName}Detail = '/{feature_name}s/:id';
  static const String {featureName}Create = '/{feature_name}s/create';
  static const String {featureName}Edit = '/{feature_name}s/:id/edit';

  // Helper methods untuk generate path dengan parameter
  static String {featureName}DetailPath(String id) => '/{feature_name}s/$id';
  static String {featureName}EditPath(String id) => '/{feature_name}s/$id/edit';
}

// STEP 2: Register GetPage di lib/routes/app_pages.dart
import 'package:get/get.dart';
import 'app_routes.dart';
import '../features/{feature_name}/bindings/{feature_name}_binding.dart';
import '../features/{feature_name}/views/{feature_name}_list_view.dart';
import '../features/{feature_name}/views/{feature_name}_detail_view.dart';

class AppPages {
  static final routes = [
    // ... existing routes ...

    // {FeatureName} routes
    GetPage(
      name: AppRoutes.{featureName}s,
      page: () => const {FeatureName}ListView(),
      binding: {FeatureName}Binding(),
      transition: Transition.rightToLeft,
      children: [
        GetPage(
          name: '/create',
          page: () => const {FeatureName}CreateView(),
          // Binding sudah di-inherit dari parent
        ),
        GetPage(
          name: '/:id',
          page: () => const {FeatureName}DetailView(),
          // Binding sudah di-inherit dari parent
          children: [
            GetPage(
              name: '/edit',
              page: () => const {FeatureName}EditView(),
            ),
          ],
        ),
      ],
    ),
  ];
}

// STEP 3: Contoh navigasi di views
// ----------------------------------

// Navigate ke list
Get.toNamed(AppRoutes.{featureName}s);

// Navigate ke detail (dengan parameter ID)
Get.toNamed(AppRoutes.{featureName}DetailPath(itemId));

// Navigate ke create
Get.toNamed(AppRoutes.{featureName}Create);

// Navigate ke edit
Get.toNamed(AppRoutes.{featureName}EditPath(itemId));

// Navigate back
Get.back();

// Navigate back dan kirim result
Get.back(result: true);

// Navigate dan replace current route (no back)
Get.offNamed(AppRoutes.{featureName}s);

// Navigate dan clear semua stack
Get.offAllNamed(AppRoutes.home);

// STEP 4: Akses route parameters di view
// ----------------------------------

// Di dalam GetView atau controller:
final String? id = Get.parameters['id'];  // Ambil :id dari URL

// Atau akses via arguments (jika pakai Get.toNamed dengan arguments)
final args = Get.arguments as Map<String, dynamic>?;
```

---

## Deliverables

### 7. Binding Template

**Description:** Template untuk `{FeatureName}Binding extends Bindings`. Binding adalah pengganti provider/riverpod untuk dependency injection di GetX. Binding otomatis dipanggil saat route diakses dan dependency di-dispose saat route di-pop.

**Recommended Skills:** `senior-flutter-developer`

**Output Format:**
```dart
// TEMPLATE: bindings/{feature}_binding.dart
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../controllers/{feature_name}_controller.dart';
import '../data/datasources/{feature_name}_remote_ds.dart';
import '../data/datasources/{feature_name}_local_ds.dart';
import '../data/repositories/{feature_name}_repository_impl.dart';
import '../domain/repositories/{feature_name}_repository.dart';

class {FeatureName}Binding extends Bindings {
  @override
  void dependencies() {
    // Data Sources
    Get.lazyPut<{FeatureName}RemoteDataSource>(
      () => {FeatureName}RemoteDataSourceImpl(Get.find()),
    );
    Get.lazyPut<{FeatureName}LocalDataSource>(
      () => {FeatureName}LocalDataSourceImpl(GetStorage()),
    );

    // Repository
    Get.lazyPut<{FeatureName}Repository>(
      () => {FeatureName}RepositoryImpl(
        remoteDataSource: Get.find<{FeatureName}RemoteDataSource>(),
        localDataSource: Get.find<{FeatureName}LocalDataSource>(),
      ),
    );

    // Controller
    Get.lazyPut<{FeatureName}Controller>(
      () => {FeatureName}Controller(),
    );
  }
}

// ============================================================
// CATATAN PENTING tentang Bindings di GetX:
// ============================================================
//
// 1. Get.lazyPut() - Create instance saat pertama kali dipanggil
//    - Auto-dispose saat controller di-dispose
//    - Cocok untuk per-feature dependencies
//
// 2. Get.put() - Create instance segera (eager loading)
//    - Gunakan untuk dependencies yang selalu dibutuhkan
//    - Tambah `permanent: true` jika tidak boleh di-dispose
//
// 3. Get.putAsync() - Untuk async initialization
//    - Contoh: database connection, shared preferences init
//
// 4. Get.create() - Create new instance setiap kali dipanggil
//    - Cocok jika butuh fresh instance setiap akses
//
// ============================================================
// Contoh binding dengan use cases (opsional):
// ============================================================
//
// class {FeatureName}Binding extends Bindings {
//   @override
//   void dependencies() {
//     // Data Sources
//     Get.lazyPut<{FeatureName}RemoteDataSource>(
//       () => {FeatureName}RemoteDataSourceImpl(Get.find()),
//     );
//
//     // Repository
//     Get.lazyPut<{FeatureName}Repository>(
//       () => {FeatureName}RepositoryImpl(
//         remoteDataSource: Get.find(),
//       ),
//     );
//
//     // Use Cases (opsional, bisa langsung pakai repository)
//     Get.lazyPut(() => Get{FeatureName}s(Get.find()));
//     Get.lazyPut(() => Get{FeatureName}ById(Get.find()));
//     Get.lazyPut(() => Create{FeatureName}(Get.find()));
//     Get.lazyPut(() => Update{FeatureName}(Get.find()));
//     Get.lazyPut(() => Delete{FeatureName}(Get.find()));
//
//     // Controller
//     Get.lazyPut<{FeatureName}Controller>(
//       () => {FeatureName}Controller(),
//     );
//   }
// }
```

---

## Deliverables

### 8. Shimmer Loading Template (YoUI)

**Description:** Template shimmer loading skeleton menggunakan `YoShimmer` dari YoUI. Tidak perlu manual shimmer — cukup panggil `YoShimmer.card()` atau `YoShimmer.listTile()`.

**Recommended Skills:** `senior-flutter-developer`

**Output Format:**
```dart
// TEMPLATE: views/widgets/{feature}_shimmer.dart
import 'package:flutter/material.dart';
import 'package:yo_ui/yo_ui.dart';

/// Shimmer list loading menggunakan YoShimmer.
class {FeatureName}ListShimmer extends StatelessWidget {
  const {FeatureName}ListShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 8,
      itemBuilder: (context, index) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: YoShimmer.card(height: 80),
      ),
    );
  }
}

/// Shimmer untuk detail view menggunakan YoShimmer.
class {FeatureName}DetailShimmer extends StatelessWidget {
  const {FeatureName}DetailShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          YoShimmer.card(height: 200),
          const SizedBox(height: 16),
          YoShimmer.listTile(),
          const SizedBox(height: 8),
          YoShimmer.listTile(),
          const SizedBox(height: 8),
          YoShimmer.listTile(),
        ],
      ),
    );
  }
}
```

> **Note:** YoShimmer sudah handle baseColor dan highlightColor otomatis sesuai YoUI theme.
> Tidak perlu manual `Shimmer.fromColors()` lagi.

**Recommended Skills:** `senior-flutter-developer`


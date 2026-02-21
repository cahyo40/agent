---
description: Generate feature baru dengan struktur Clean Architecture lengkap menggunakan GetX pattern. (Part 7/10)
---
# Workflow: Flutter Feature Maker (GetX) (Part 7/10)

> **Navigation:** This workflow is split into 10 parts.

## Workflow Steps

1. **Analyze Requirements**
   - Tentukan nama feature (contoh: `todo`, `product`, `order`)
   - List fields yang dibutuhkan beserta tipe data
   - Tentukan relationships (if any)
   - Mapping API endpoints

2. **Generate Domain Layer**
   - Create entity class dengan Equatable
   - Create repository abstract contract
   - Generate use cases (CRUD): GetAll, GetById, Create, Update, Delete

3. **Generate Data Layer**
   - Create model dengan **manual fromJson/toJson** (tanpa freezed!)
   - Implement remote data source (Dio)
   - Implement local data source (GetStorage)
   - Create repository implementation dengan cache fallback

4. **Generate Presentation Layer**
   - Create `GetxController` dengan `.obs` reactive variables
   - Create `{FeatureName}Binding` untuk dependency injection
   - Generate views (`GetView<Controller>`) untuk list dan detail
   - Create widgets (list item, form, shimmer)
   - Implement state handling manual (`isLoading`, `errorMessage`, empty check)

5. **Setup Bindings**
   - Create `{FeatureName}Binding extends Bindings`
   - Register data sources, repository, dan controller dengan `Get.lazyPut()`
   - Verify dependency chain benar (DataSource -> Repository -> Controller)

6. **Add Routes to AppPages**
   - **Step 6.1:** Tambah route constants di `lib/routes/app_routes.dart`
     - Add route strings untuk list, detail, create, edit
     - Add helper methods untuk generate path dengan params
   
   - **Step 6.2:** Register `GetPage` di `lib/routes/app_pages.dart`
     - Import feature views
     - Add `GetPage` dengan `binding:` property
     - Setup children routes untuk detail dan edit
     - Configure `transition:` (optional)
   
   - **Step 6.3:** Update navigation di views
     - Use `Get.toNamed()` untuk navigate
     - Use `Get.back()` untuk go back
     - Use route helper methods untuk type safety
   
   - **Step 6.4:** Test routing
     - Verifikasi semua routes bisa diakses
     - Test navigasi dari list ke detail
     - Test navigasi dari list ke create
     - Test navigasi dari detail ke edit
     - Test `Get.back()` behavior

7. **Test Feature**
   - **Tidak perlu `dart run build_runner build`** -- semua file langsung siap!
   - Run `flutter analyze` -- pastikan tidak ada error
   - Test semua states (loading, error, empty, data)
   - Test CRUD operations
   - Verify shimmer loading tampil saat loading
   - Test navigation/routing
   - Test `Get.snackbar()` feedback


## Success Criteria

- [ ] Feature structure mengikuti Clean Architecture
- [ ] Semua file ter-generate tanpa error
- [ ] **Tidak perlu code generation** (no build_runner)
- [ ] Manual fromJson/toJson bekerja dengan benar
- [ ] **Bindings configured** -- dependency chain benar
- [ ] **GetPage routes registered** di app_pages.dart
- [ ] **Route constants defined** di app_routes.dart
- [ ] Feature bisa di-navigate dengan `Get.toNamed()`
- [ ] Navigation ke detail/create/edit berfungsi
- [ ] `Obx()` reactive state berfungsi (loading, error, empty, data)
- [ ] Shimmer loading implemented
- [ ] CRUD operations berfungsi dengan `Get.snackbar()` feedback
- [ ] `Get.dialog()` confirmation berfungsi
- [ ] `flutter analyze` tidak ada error
- [ ] Null safety handled dengan baik


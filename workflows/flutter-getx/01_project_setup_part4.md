---
description: Setup Flutter project dari nol dengan Clean Architecture dan GetX state management. (Part 4/4)
---
# Workflow: Flutter Project Setup with GetX (Part 4/4)

> **Navigation:** This workflow is split into 4 parts.

## Workflow Steps

1. **Project Initialization**
   - Create Flutter project
   - Add dependencies ke pubspec.yaml
   - Run `flutter pub get`
   - Setup folder structure

2. **GetX Configuration**
   - Setup GetMaterialApp
   - Configure routes dan bindings
   - Setup auth middleware

3. **Core Layer Setup**
   - Implement error handling classes
   - Setup theme
   - Configure storage service

4. **Example Feature Implementation**
   - Create domain layer (entity, repository interface)
   - Create data layer (model, repository impl)
   - Create feature layer (controller, binding, view)
   - Implement reactive state dengan Obx

5. **Test Setup**
   - Verify app runs without error
   - Test navigation
   - Test example feature


## Success Criteria

- [ ] Project structure mengikuti Clean Architecture
- [ ] Semua dependencies terinstall tanpa error
- [ ] GetMaterialApp configured dengan routing
- [ ] Bindings setup untuk dependency injection
- [ ] Example feature berjalan dengan reactive state (Obx)
- [ ] Navigation berfungsi dengan GetX routing
- [ ] `flutter analyze` tidak ada warning/error
- [ ] App bisa build dan run


## GetX vs Riverpod

| Feature | GetX | Riverpod |
|---------|------|----------|
| State Management | `.obs` + `Obx` | `AsyncValue` + `.when()` |
| Dependency Injection | `Get.put()` / Bindings | `Provider` + `@riverpod` |
| Routing | `GetMaterialApp` | `GoRouter` |
| Navigation | `Get.to()` / `Get.toNamed()` | `context.push()` |
| Code Generation | Tidak perlu | Perlu (build_runner) |
| Reactive | ✅ `.obs` streams | ✅ AsyncValue |
| Performance | ✅ Lightweight | ✅ Excellent |


## Tools & Templates

- **Flutter Version:** 3.41.1+
- **Dart Version:** 3.11.0+
- **State Management:** GetX 4.6+
- **Routing:** GetX Routing (built-in)
- **HTTP Client:** Dio 5.4+
- **Local Storage:** GetStorage 2.1+


## Next Steps

Setelah workflow ini selesai, lanjut ke:
1. `02_feature_maker.md` - Untuk generate feature baru
2. `03_backend_integration.md` - Untuk API integration
3. `04_firebase_integration.md` - Untuk Firebase
4. `05_supabase_integration.md` - Untuk Supabase
5. `06_testing_production.md` - Testing dan deployment


## Catatan Penting GetX

1. **Reactive State**: Gunakan `.obs` untuk reactive variables dan `Obx()` untuk listen
2. **Controllers**: Auto-dispose saat view di-close (kecuali `permanent: true`)
3. **Bindings**: Lazy loading untuk performance optimal
4. **Navigation**: Simpler syntax dengan `Get.to()` dan `Get.toNamed()`
5. **Snackbar/Dialog**: Built-in tanpa context: `Get.snackbar()`, `Get.dialog()`

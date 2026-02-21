---
description: Setup Flutter project dari nol dengan Clean Architecture, Riverpod, dan YoUI. (Part 5/5)
---
# Workflow: Flutter Project Setup with Riverpod + YoUI + YoUI (Part 5/5)

> **Navigation:** This workflow is split into 5 parts.

## Workflow Steps

1. **Project Initialization**
   - Create Flutter project
   - Add dependencies ke pubspec.yaml (termasuk YoUI)
   - Run `flutter pub get`
   - Setup folder structure

2. **Core Layer Setup**
   - Implement error handling classes
   - Setup router dengan GoRouter
   - Configure secure storage
   - Setup YoUI app theme

3. **Example Feature Implementation**
   - Create domain layer (entity, repository contract)
   - Create data layer (model, repository impl, data sources)
   - Create presentation layer (controller, screen with YoUI widgets)
   - Implement all states (loading, error, empty, data)

4. **DI Configuration**
   - Setup all providers
   - Configure interceptors
   - Setup repository injection

5. **Code Generation**
   - Run `dart run build_runner build -d`
   - Verify generated files

6. **Testing Setup**
   - Verify app runs without error
   - Test navigation
   - Test example feature


## Success Criteria

- [ ] Project structure mengikuti Clean Architecture
- [ ] Semua dependencies terinstall tanpa error
- [ ] **YoUI package berhasil diintegrasikan**
- [ ] **GoRouter configured dengan routes lengkap**
- [ ] **Route constants defined di routes.dart**
- [ ] **Auth guard implemented**
- [ ] Example feature berjalan dengan semua states (loading, error, empty, data)
- [ ] **Navigation antar screens berfungsi**
- [ ] **Deeplinking configured (optional)**
- [ ] Code generation berjalan tanpa error
- [ ] `flutter analyze` tidak ada warning/error
- [ ] App bisa build dan run
- [ ] Shimmer loading implemented
- [ ] **YoUI widgets (YoCard, YoButton) digunakan di screens**


## Tools & Templates

- **Flutter Version:** 3.41.1+ (Tested on stable channel)
- **Dart Version:** 3.11.0+
- **State Management:** Riverpod 2.5+ dengan code generation
- **UI Library:** YoUI (git dependency)
- **Routing:** GoRouter 14.0+
- **HTTP Client:** Dio 5.4+
- **Local Storage:** Hive 1.1+
- **Firebase:** Core 3.12+, Auth 5.5+, Firestore 5.6+ (Untuk Flutter 3.41.1)
- **Code Generation:** build_runner, freezed, riverpod_generator


## Next Steps

Setelah workflow ini selesai, lanjut ke:
1. `02_feature_maker.md` - Untuk generate feature baru
2. `03_backend_integration.md` - Untuk API integration lengkap
3. `04_firebase_integration.md` - Untuk Firebase services
4. `05_supabase_integration.md` - Untuk Supabase integration

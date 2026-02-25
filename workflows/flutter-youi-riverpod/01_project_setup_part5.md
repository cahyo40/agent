---
description: Setup Flutter project dari nol dengan Clean Architecture, Riverpod, dan YoUI. (Part 5/5)
---
# Workflow: Flutter Project Setup with Riverpod + YoUI (Part 5/5)

> **Navigation:** This workflow is split into 5 parts.

## Workflow Steps

1. **Project Initialization**
   - Create Flutter project: `flutter create --org com.example my_app`
   - Buka root folder project Flutter: `cd my_app`

2. **Run YoDev Generator**
   - Jalankan: `dart run yo.dart init --state=riverpod`
   - Pastikan output memunculkan pesan sukses tanpa error kritikal.

3. **Verify Configuration**
   - Cek `pubspec.yaml` untuk package yang baru di-add (Riverpod, YoUI, GoRouter, dll).
   - Pastikan file `yo.yaml` tersedia untuk dibaca pada generasi fitur nanti.
   - Run `flutter pub get`.

4. **Verify Core Layer & Implement Dependencies**
   - Periksa folder `lib/core/` and `lib/bootstrap/`.
   - Setup API client, secure storage config, dsb jika ditandai dalam `// TODO`.

5. **Code Generation**
   - Run `dart run build_runner build -d`
   - Verify generated files

6. **Testing Setup**
   - Verify app runs without error: `flutter run`
   - Test navigation
   - Verify that YoUI is properly loaded via `app_theme.dart`.

## Success Criteria

- [ ] Project structure mengikuti Clean Architecture dari template `yo.dart`
- [ ] File `yo.yaml` ada di root folder
- [ ] Semua dependencies terinstall tanpa error
- [ ] **YoUI package berhasil diintegrasikan**
- [ ] **GoRouter configured dengan routes lengkap**
- [ ] Code generation berjalan tanpa error
- [ ] `flutter analyze` tidak ada warning/error
- [ ] App bisa build dan run

## Tools & Templates

- **Flutter Version:** 3.41.1+ (Tested on stable channel)
- **Dart Version:** 3.11.0+
- **State Management:** Riverpod 2.5+ dengan code generation
- **UI Library:** YoUI (git dependency)
- **Code Generation Tools:** build_runner, freezed, riverpod_generator, **yo_generator**

## Next Steps

Setelah workflow ini selesai, lanjut ke:
1. `02_feature_maker.md` - Untuk generate feature baru menggunakan `yo.dart page:<name>` dll.
2. `03_backend_integration.md` - Untuk API integration lengkap
3. `04_firebase_integration.md` - Untuk Firebase services
4. `05_supabase_integration.md` - Untuk Supabase integration

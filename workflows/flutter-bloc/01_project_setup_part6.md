---
description: Setup Flutter project dari nol dengan Clean Architecture dan BLoC state management. (Part 6/6)
---
# Workflow: Flutter Project Setup with BLoC (Part 6/6)

> **Navigation:** This workflow is split into 6 parts.

## Workflow Steps

1. **Project Initialization**
   - Create Flutter project: `flutter create --empty my_app`
   - Add dependencies ke pubspec.yaml (lihat section 2)
   - Run `flutter pub get`
   - Setup folder structure (lihat section 1)

2. **Core Layer Setup**
   - Implement error handling classes (Failure, Exception)
   - Setup `get_it` + `injectable` DI
   - Setup `BlocObserver` untuk logging
   - Setup router dengan GoRouter
   - Configure secure storage (Hive)
   - Setup app theme

3. **Code Generation (DI)**
   - Run `dart run build_runner build --delete-conflicting-outputs`
   - Verify `injection.config.dart` generated

4. **Example Feature Implementation**
   - Create domain layer (entity, repository contract, use cases)
   - Create data layer (model, repository impl, data sources)
   - Create presentation layer:
     - Define Events (`product_event.dart`)
     - Define States (`product_state.dart`)
     - Implement Bloc (`product_bloc.dart`)
     - Create screens dengan `BlocBuilder` / `BlocConsumer`
   - Implement all states (initial, loading, loaded, error)
   - Handle side effects dengan `BlocListener`

5. **Root Widget Setup**
   - Setup `MultiBlocProvider` di `app.dart` untuk global blocs
   - Setup feature-specific `BlocProvider` di level route

6. **Testing Setup**
   - Write unit tests dengan `bloc_test`
   - Test setiap event handler
   - Verify state transitions

7. **Verification**
   - Run `flutter analyze` - pastikan clean
   - Run `flutter test` - pastikan passing
   - Run app dan test navigation manual
   - Verify BlocObserver logs di console


## Success Criteria

- [ ] Project structure mengikuti Clean Architecture
- [ ] Semua dependencies terinstall tanpa error
- [ ] `get_it` + `injectable` DI configured dan generated
- [ ] `BlocObserver` logging events/transitions
- [ ] **GoRouter configured dengan routes lengkap**
- [ ] **Route constants defined di routes.dart**
- [ ] **Auth guard implemented**
- [ ] Example Product feature lengkap:
  - [ ] Events: `LoadProducts`, `CreateProductEvent`, `DeleteProductEvent`
  - [ ] States: `ProductInitial`, `ProductLoading`, `ProductLoaded`, `ProductError`
  - [ ] `BlocBuilder` untuk UI rendering
  - [ ] `BlocListener` untuk side effects (snackbar, navigation)
  - [ ] Pattern matching pada sealed state classes
- [ ] `BlocProvider` di level route untuk feature-specific blocs
- [ ] `MultiBlocProvider` di root untuk global blocs
- [ ] Shimmer loading implemented
- [ ] **Navigation antar screens berfungsi**
- [ ] Code generation berjalan tanpa error
- [ ] `flutter analyze` tidak ada warning/error
- [ ] Unit tests passing dengan `bloc_test`
- [ ] App bisa build dan run


## Tools & Templates

- **Flutter Version:** 3.41.1+ (Tested on stable channel)
- **Dart Version:** 3.11.0+
- **State Management:** flutter_bloc 8.1+, bloc 8.1+
- **DI:** get_it 8.0+, injectable 2.5+
- **Routing:** GoRouter 14.0+
- **HTTP Client:** Dio 5.4+
- **Local Storage:** Hive 1.1+
- **Firebase:** Core 3.12+, Auth 5.5+, Firestore 5.6+ (Untuk Flutter 3.41.1)
- **Code Generation:** build_runner, freezed, json_serializable, injectable_generator
- **Testing:** bloc_test 9.1+, mocktail 1.0+


## Next Steps

Setelah workflow ini selesai, lanjut ke:
1. `02_feature_maker.md` - Untuk generate feature baru dengan BLoC pattern
2. `03_backend_integration.md` - Untuk API integration lengkap
3. `04_firebase_integration.md` - Untuk Firebase services
4. `05_supabase_integration.md` - Untuk Supabase integration

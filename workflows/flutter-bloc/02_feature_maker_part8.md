---
description: Generate feature baru dengan struktur Clean Architecture lengkap menggunakan **flutter_bloc**. (Part 8/11)
---
# Workflow: Flutter BLoC Feature Maker (Part 8/11)

> **Navigation:** This workflow is split into 11 parts.

## Workflow Steps

1. **Analyze Requirements**
   - Tentukan nama feature (contoh: `product`, `order`, `user`)
   - List fields yang dibutuhkan
   - Tentukan relationships (if any)
   - Pilih Bloc vs Cubit (Bloc untuk complex events, Cubit untuk simple CRUD)

2. **Generate Domain Layer**
   - Create entity class (Equatable)
   - Create repository abstract contract (Either<Failure, T>)
   - Generate use cases (CRUD): GetAll, GetById, Create, Update, Delete

3. **Generate Data Layer**
   - Create model (manual atau freezed)
   - Implement remote data source (Dio)
   - Implement local data source (SharedPreferences/Hive, optional)
   - Create repository implementation

4. **Generate Presentation Layer - BLoC**
   - Define Events sealed class (semua aksi user)
   - Define States sealed class (semua kemungkinan state + side effects)
   - Create BLoC class dengan `on<Event>` handlers
   - Generate screens dengan `BlocConsumer`
   - Create widgets (list item, form, shimmer)

5. **Setup DI (get_it)**
   - Register BLoC (`registerFactory`)
   - Register use cases (`registerLazySingleton`)
   - Register repository (`registerLazySingleton`)
   - Register data sources (`registerLazySingleton`)
   - Jalankan `build_runner` jika pakai injectable

6. **Add Routes to GoRouter**
   - Update `routes.dart` (constants + helper methods)
   - Update `app_router.dart` (GoRoute config)
   - Test navigation dari screens

7. **Run Code Generation** (jika pakai freezed/injectable)
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```

8. **Test Feature**
   - Test semua states (initial, loading, loaded, empty, error)
   - Test CRUD operations + side effect states
   - Test BlocListener snackbar/navigation
   - Verify shimmer loading
   - Test route navigation
   - `flutter analyze`

---


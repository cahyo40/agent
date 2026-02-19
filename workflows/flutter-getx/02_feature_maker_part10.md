---
description: Generate feature baru dengan struktur Clean Architecture lengkap menggunakan GetX pattern. (Part 10/10)
---
# Workflow: Flutter Feature Maker (GetX) (Part 10/10)

> **Navigation:** This workflow is split into 10 parts.

## GetX vs Riverpod -- Perbandingan Feature Maker

| Aspek | GetX | Riverpod |
|-------|------|----------|
| Controller | `GetxController` + `.obs` | `AsyncNotifier` + `@riverpod` |
| State | `RxList`, `RxBool`, `Rx<T?>` | `AsyncValue<List<T>>` |
| UI Binding | `Obx(() { ... })` | `.when(data:, error:, loading:)` |
| Screen Base | `GetView<Controller>` | `ConsumerWidget` |
| DI | `Bindings` + `Get.lazyPut()` | `@riverpod` annotation |
| Navigation | `Get.toNamed()` | `context.push()` |
| Routes | `GetPage` + `binding:` | `GoRoute` |
| Dialog | `Get.dialog()` | `showDialog(context:)` |
| Snackbar | `Get.snackbar()` | `ScaffoldMessenger` |
| Back | `Get.back()` | `context.pop()` |
| Model | Manual `fromJson/toJson` | `freezed` + code gen |
| Code Gen | **Tidak perlu** | `build_runner` wajib |
| Local Cache | `GetStorage` | `Hive` / `SharedPreferences` |


## Tools & Templates

- **Shimmer:** `shimmer` package untuk loading skeleton
- **Local Storage:** `GetStorage` (GetX ecosystem, bukan Hive)
- **HTTP Client:** `Dio` untuk API calls
- **Error Handling:** `dartz` (`Either<Failure, T>`) untuk functional error handling
- **Equality:** `equatable` untuk entity comparison
- **Code Generation:** **Tidak diperlukan** -- ini advantage utama GetX


## Next Steps

Setelah generate feature:
1. Implement business logic di use cases (jika pakai use case pattern)
2. Connect ke backend (REST API) -- lihat `03_backend_integration.md`
3. Add Firebase integration -- lihat `04_firebase_integration.md`
4. Add Supabase integration -- lihat `05_supabase_integration.md`
5. Add tests (unit, widget, integration) -- lihat `06_testing_production.md`
6. Add analytics tracking
7. Add translation/localization -- lihat `07_translation.md`

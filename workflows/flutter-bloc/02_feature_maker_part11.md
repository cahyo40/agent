---
description: Generate feature baru dengan struktur Clean Architecture lengkap menggunakan **flutter_bloc**. (Part 11/11)
---
# Workflow: Flutter BLoC Feature Maker (Part 11/11)

> **Navigation:** This workflow is split into 11 parts.

## BLoC vs Cubit: Kapan Pakai Apa?

| Aspek | Bloc | Cubit |
|---|---|---|
| Complexity | Complex feature dengan banyak events | Simple CRUD tanpa event transformation |
| Traceability | Setiap event ter-log, mudah debug | Method calls, kurang traceable |
| Events | Sealed class, exhaustive | Langsung method call |
| Testing | Event-driven, predictable | Method-driven |
| `transformEvents` | Bisa debounce/throttle events | Tidak bisa |
| Recommendation | Feature utama (order, product) | Feature kecil (settings, profile) |


## Success Criteria

- [ ] Feature structure mengikuti Clean Architecture
- [ ] Entity, Repository, Use Cases ter-generate (Domain)
- [ ] Model, DataSource, RepoImpl ter-generate (Data)
- [ ] Events sealed class lengkap (semua CRUD events)
- [ ] States sealed class lengkap (termasuk side effect states)
- [ ] BLoC class dengan semua `on<Event>` handlers
- [ ] Screen menggunakan `BlocConsumer` (listener + builder)
- [ ] `BlocListener` menangkap side effects (snackbar/navigation)
- [ ] `BlocBuilder` render UI dengan pattern matching pada state
- [ ] DI registered di get_it (BLoC sebagai Factory, sisanya Singleton)
- [ ] Routes registered di GoRouter
- [ ] Shimmer loading implemented
- [ ] `flutter analyze` tidak ada error
- [ ] Code generation berhasil (`build_runner`)


## Tools & Dependencies

- **State Management:** `flutter_bloc`, `bloc`
- **Code Generation:** `build_runner`, `freezed`, `json_serializable`, `injectable_generator`
- **DI:** `get_it`, `injectable`
- **Routing:** `go_router`
- **Functional:** `dartz` (Either)
- **HTTP:** `dio`
- **Equality:** `equatable`
- **Shimmer:** `shimmer`
- **Form (optional):** `flutter_form_builder`, `formz`


## Next Steps

Setelah generate feature:
1. Implement business logic di use cases
2. Connect ke backend (REST API, Firebase, atau Supabase)
3. Add unit tests untuk BLoC (`bloc_test` package)
4. Add widget tests
5. Add `BlocObserver` untuk logging/analytics
6. Lanjut ke `03_api_integration.md`

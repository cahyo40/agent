---
description: Generate feature baru dengan struktur Clean Architecture lengkap menggunakan **flutter_bloc**. (Part 5/11)
---
# Workflow: Flutter BLoC Feature Maker (Part 5/11)

> **Navigation:** This workflow is split into 11 parts.

## Deliverables

### 9. BLoC (Presentation Layer)

**Description:** BLoC class yang menangani semua events dan emit states. Setiap event di-handle oleh method `on<Event>` yang memanggil use case dari domain layer.

**Template: `presentation/bloc/{feature_name}_bloc.dart`**
```dart
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/{feature_name}_entity.dart';
import '../../domain/usecases/create_{feature_name}.dart';
import '../../domain/usecases/delete_{feature_name}.dart';
import '../../domain/usecases/get_{feature_name}_by_id.dart';
import '../../domain/usecases/get_{feature_name}s.dart';
import '../../domain/usecases/update_{feature_name}.dart';

part '{feature_name}_event.dart';
part '{feature_name}_state.dart';

@injectable
class {FeatureName}Bloc extends Bloc<{FeatureName}Event, {FeatureName}State> {
  final Get{FeatureName}s _get{FeatureName}s;
  final Get{FeatureName}ById _get{FeatureName}ById;
  final Create{FeatureName} _create{FeatureName};
  final Update{FeatureName} _update{FeatureName};
  final Delete{FeatureName} _delete{FeatureName};

  {FeatureName}Bloc({
    required Get{FeatureName}s get{FeatureName}s,
    required Get{FeatureName}ById get{FeatureName}ById,
    required Create{FeatureName} create{FeatureName},
    required Update{FeatureName} update{FeatureName},
    required Delete{FeatureName} delete{FeatureName},
  })  : _get{FeatureName}s = get{FeatureName}s,
        _get{FeatureName}ById = get{FeatureName}ById,
        _create{FeatureName} = create{FeatureName},
        _update{FeatureName} = update{FeatureName},
        _delete{FeatureName} = delete{FeatureName},
        super(const {FeatureName}Initial()) {
    // Register event handlers
    on<Load{FeatureName}s>(_onLoad{FeatureName}s);
    on<Load{FeatureName}ById>(_onLoad{FeatureName}ById);
    on<Create{FeatureName}Event>(_onCreate{FeatureName});
    on<Update{FeatureName}Event>(_onUpdate{FeatureName});
    on<Delete{FeatureName}Event>(_onDelete{FeatureName});
    on<Refresh{FeatureName}s>(_onRefresh{FeatureName}s);
  }

  /// Daftar {featureName} yang sedang di-hold (untuk preserve saat side effect)
  List<{FeatureName}> _current{FeatureName}s = [];

  /// Handle: Load semua {featureName}s
  Future<void> _onLoad{FeatureName}s(
    Load{FeatureName}s event,
    Emitter<{FeatureName}State> emit,
  ) async {
    emit(const {FeatureName}Loading());

    final result = await _get{FeatureName}s(const NoParams());

    result.fold(
      (failure) => emit({FeatureName}Error(failure.message)),
      ({featureName}s) {
        _current{FeatureName}s = {featureName}s;
        emit({FeatureName}Loaded({featureName}s));
      },
    );
  }

  /// Handle: Load single {featureName} by ID
  Future<void> _onLoad{FeatureName}ById(
    Load{FeatureName}ById event,
    Emitter<{FeatureName}State> emit,
  ) async {
    emit(const {FeatureName}Loading());

    final result = await _get{FeatureName}ById(
      Get{FeatureName}ByIdParams(id: event.id),
    );

    result.fold(
      (failure) => emit({FeatureName}Error(failure.message)),
      ({featureName}) => emit({FeatureName}DetailLoaded({featureName})),
    );
  }

  /// Handle: Create {featureName} baru
  Future<void> _onCreate{FeatureName}(
    Create{FeatureName}Event event,
    Emitter<{FeatureName}State> emit,
  ) async {
    final new{FeatureName} = {FeatureName}.create(
      name: event.name,
      description: event.description,
    );

    final result = await _create{FeatureName}(new{FeatureName});

    result.fold(
      (failure) => emit({FeatureName}OperationError(
        message: failure.message,
        current{FeatureName}s: _current{FeatureName}s,
      )),
      (created) {
        _current{FeatureName}s = [..._current{FeatureName}s, created];
        emit({FeatureName}Created(
          {featureName}: created,
          updated{FeatureName}s: _current{FeatureName}s,
        ));
        // Setelah side effect state, emit Loaded agar builder update
        emit({FeatureName}Loaded(_current{FeatureName}s));
      },
    );
  }

  /// Handle: Update {featureName}
  Future<void> _onUpdate{FeatureName}(
    Update{FeatureName}Event event,
    Emitter<{FeatureName}State> emit,
  ) async {
    final result = await _update{FeatureName}(event.{featureName});

    result.fold(
      (failure) => emit({FeatureName}OperationError(
        message: failure.message,
        current{FeatureName}s: _current{FeatureName}s,
      )),
      (updated) {
        _current{FeatureName}s = _current{FeatureName}s
            .map((item) => item.id == updated.id ? updated : item)
            .toList();
        emit({FeatureName}Updated(
          {featureName}: updated,
          updated{FeatureName}s: _current{FeatureName}s,
        ));
        emit({FeatureName}Loaded(_current{FeatureName}s));
      },
    );
  }

  /// Handle: Delete {featureName}
  Future<void> _onDelete{FeatureName}(
    Delete{FeatureName}Event event,
    Emitter<{FeatureName}State> emit,
  ) async {
    final result = await _delete{FeatureName}(
      Delete{FeatureName}Params(id: event.id),
    );

    result.fold(
      (failure) => emit({FeatureName}OperationError(
        message: failure.message,
        current{FeatureName}s: _current{FeatureName}s,
      )),
      (_) {
        _current{FeatureName}s = _current{FeatureName}s
            .where((item) => item.id != event.id)
            .toList();
        emit({FeatureName}Deleted(
          deletedId: event.id,
          updated{FeatureName}s: _current{FeatureName}s,
        ));
        emit({FeatureName}Loaded(_current{FeatureName}s));
      },
    );
  }

  /// Handle: Refresh (re-fetch dari server)
  Future<void> _onRefresh{FeatureName}s(
    Refresh{FeatureName}s event,
    Emitter<{FeatureName}State> emit,
  ) async {
    // Tidak emit Loading agar UI tidak flash shimmer saat pull-to-refresh
    final result = await _get{FeatureName}s(const NoParams());

    result.fold(
      (failure) => emit({FeatureName}Error(failure.message)),
      ({featureName}s) {
        _current{FeatureName}s = {featureName}s;
        emit({FeatureName}Loaded({featureName}s));
      },
    );
  }
}
```

**Alternatif: Cubit (untuk feature sederhana tanpa complex events)**
```dart
@injectable
class {FeatureName}Cubit extends Cubit<{FeatureName}State> {
  final Get{FeatureName}s _get{FeatureName}s;
  final Create{FeatureName} _create{FeatureName};
  final Delete{FeatureName} _delete{FeatureName};

  {FeatureName}Cubit({
    required Get{FeatureName}s get{FeatureName}s,
    required Create{FeatureName} create{FeatureName},
    required Delete{FeatureName} delete{FeatureName},
  })  : _get{FeatureName}s = get{FeatureName}s,
        _create{FeatureName} = create{FeatureName},
        _delete{FeatureName} = delete{FeatureName},
        super(const {FeatureName}Initial());

  List<{FeatureName}> _items = [];

  Future<void> loadAll() async {
    emit(const {FeatureName}Loading());
    final result = await _get{FeatureName}s(const NoParams());
    result.fold(
      (f) => emit({FeatureName}Error(f.message)),
      (items) {
        _items = items;
        emit({FeatureName}Loaded(items));
      },
    );
  }

  Future<void> create({required String name, String? description}) async {
    final entity = {FeatureName}.create(name: name, description: description);
    final result = await _create{FeatureName}(entity);
    result.fold(
      (f) => emit({FeatureName}OperationError(message: f.message, current{FeatureName}s: _items)),
      (created) {
        _items = [..._items, created];
        emit({FeatureName}Loaded(_items));
      },
    );
  }

  Future<void> delete(String id) async {
    final result = await _delete{FeatureName}(Delete{FeatureName}Params(id: id));
    result.fold(
      (f) => emit({FeatureName}OperationError(message: f.message, current{FeatureName}s: _items)),
      (_) {
        _items = _items.where((item) => item.id != id).toList();
        emit({FeatureName}Loaded(_items));
      },
    );
  }
}
```

---


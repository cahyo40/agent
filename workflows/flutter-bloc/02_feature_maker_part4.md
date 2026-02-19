---
description: Generate feature baru dengan struktur Clean Architecture lengkap menggunakan **flutter_bloc**. (Part 4/11)
---
# Workflow: Flutter BLoC Feature Maker (Part 4/11)

> **Navigation:** This workflow is split into 11 parts.

## Deliverables

### 8. BLoC States (Presentation Layer)

**Description:** Sealed class untuk semua state yang mungkin. Termasuk state khusus untuk side effects (Created, Updated, Deleted) yang ditangkap oleh `BlocListener`.

**Template: `presentation/bloc/{feature_name}_state.dart`**
```dart
part of '{feature_name}_bloc.dart';

/// Sealed class untuk semua {FeatureName} states.
///
/// State flow:
///   Initial -> Loading -> Loaded / Error
///   Loaded -> Loading (refresh) -> Loaded / Error
///   Loaded -> {FeatureName}Created (side effect) -> Loaded (list updated)
///   Loaded -> {FeatureName}Deleted (side effect) -> Loaded (list updated)
sealed class {FeatureName}State extends Equatable {
  const {FeatureName}State();

  @override
  List<Object?> get props => [];
}

/// State awal, belum ada data
final class {FeatureName}Initial extends {FeatureName}State {
  const {FeatureName}Initial();
}

/// Sedang loading data
final class {FeatureName}Loading extends {FeatureName}State {
  const {FeatureName}Loading();
}

/// Data berhasil di-load
final class {FeatureName}Loaded extends {FeatureName}State {
  final List<{FeatureName}> {featureName}s;

  const {FeatureName}Loaded(this.{featureName}s);

  /// Helper: check apakah list kosong
  bool get isEmpty => {featureName}s.isEmpty;

  @override
  List<Object?> get props => [{featureName}s];
}

/// Error terjadi saat load data
final class {FeatureName}Error extends {FeatureName}State {
  final String message;

  const {FeatureName}Error(this.message);

  @override
  List<Object?> get props => [message];
}

// ============================================================
// Side Effect States (ditangkap oleh BlocListener, bukan builder)
// ============================================================

/// {FeatureName} berhasil dibuat - trigger snackbar/navigation
final class {FeatureName}Created extends {FeatureName}State {
  final {FeatureName} {featureName};
  final List<{FeatureName}> updated{FeatureName}s;

  const {FeatureName}Created({
    required this.{featureName},
    required this.updated{FeatureName}s,
  });

  @override
  List<Object?> get props => [{featureName}, updated{FeatureName}s];
}

/// {FeatureName} berhasil di-update
final class {FeatureName}Updated extends {FeatureName}State {
  final {FeatureName} {featureName};
  final List<{FeatureName}> updated{FeatureName}s;

  const {FeatureName}Updated({
    required this.{featureName},
    required this.updated{FeatureName}s,
  });

  @override
  List<Object?> get props => [{featureName}, updated{FeatureName}s];
}

/// {FeatureName} berhasil dihapus
final class {FeatureName}Deleted extends {FeatureName}State {
  final String deletedId;
  final List<{FeatureName}> updated{FeatureName}s;

  const {FeatureName}Deleted({
    required this.deletedId,
    required this.updated{FeatureName}s,
  });

  @override
  List<Object?> get props => [deletedId, updated{FeatureName}s];
}

/// Error saat operasi CUD (Create/Update/Delete) - side effect error
final class {FeatureName}OperationError extends {FeatureName}State {
  final String message;
  final List<{FeatureName}> current{FeatureName}s; // preserve current data

  const {FeatureName}OperationError({
    required this.message,
    required this.current{FeatureName}s,
  });

  @override
  List<Object?> get props => [message, current{FeatureName}s];
}

// ============================================================
// Detail States (untuk detail screen)
// ============================================================

/// Single {featureName} berhasil di-load
final class {FeatureName}DetailLoaded extends {FeatureName}State {
  final {FeatureName} {featureName};

  const {FeatureName}DetailLoaded(this.{featureName});

  @override
  List<Object?> get props => [{featureName}];
}
```

---


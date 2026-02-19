---
description: Generate feature baru dengan struktur Clean Architecture lengkap. (Part 2/4)
---
# Workflow: Flutter Feature Maker (Part 2/4)

> **Navigation:** This workflow is split into 4 parts.

## Deliverables

### 1. Feature Template Generator

**Description:** Template lengkap untuk generate feature baru dengan satu command.

**Recommended Skills:** `senior-flutter-developer`

**Instructions:**
Buat template untuk generate feature dengan struktur:

```
lib/features/{feature_name}/
├── data/
│   ├── datasources/
│   │   ├── {feature_name}_remote_ds.dart
│   │   └── {feature_name}_local_ds.dart
│   ├── models/
│   │   └── {feature_name}_model.dart
│   └── repositories/
│       └── {feature_name}_repository_impl.dart
├── domain/
│   ├── entities/
│   │   └── {feature_name}_entity.dart
│   ├── repositories/
│   │   └── {feature_name}_repository.dart
│   └── usecases/
│       ├── get_{feature_name}s.dart
│       ├── get_{feature_name}_by_id.dart
│       ├── create_{feature_name}.dart
│       ├── update_{feature_name}.dart
│       └── delete_{feature_name}.dart
└── presentation/
    ├── controllers/
    │   └── {feature_name}_controller.dart
    ├── screens/
    │   ├── {feature_name}_list_screen.dart
    │   └── {feature_name}_detail_screen.dart
    └── widgets/
        ├── {feature_name}_list_item.dart
        ├── {feature_name}_form.dart
        └── {feature_name}_shimmer.dart
```

**Output Format:**
```dart
// TEMPLATE: features/{feature}/domain/entities/{feature}_entity.dart
class {FeatureName} extends Equatable {
  final String id;
  final String name;
  final DateTime createdAt;
  final DateTime? updatedAt;
  
  const {FeatureName}({
    required this.id,
    required this.name,
    required this.createdAt,
    this.updatedAt,
  });
  
  {FeatureName} copyWith({
    String? id,
    String? name,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return {FeatureName}(
      id: id ?? this.id,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
  
  @override
  List<Object?> get props => [id, name, createdAt, updatedAt];
}
```

---

## Deliverables

### 2. Domain Layer Template

**Description:** Template untuk domain layer (entity, repository contract, use cases).

**Recommended Skills:** `senior-flutter-developer`

**Instructions:**
Buat template untuk:
1. Entity dengan Equatable
2. Repository abstract contract
3. Use cases (GetAll, GetById, Create, Update, Delete)

**Output Format:**
```dart
// TEMPLATE: domain/repositories/{feature}_repository.dart
abstract class {FeatureName}Repository {
  Future<Either<Failure, List<{FeatureName}>>> get{FeatureName}s();
  Future<Either<Failure, {FeatureName}>> get{FeatureName}ById(String id);
  Future<Either<Failure, {FeatureName}>> create{FeatureName}({FeatureName} {featureName});
  Future<Either<Failure, {FeatureName}>> update{FeatureName}({FeatureName} {featureName});
  Future<Either<Failure, Unit>> delete{FeatureName}(String id);
}

// TEMPLATE: domain/usecases/get_{feature}s.dart
class Get{FeatureName}s implements UseCase<List<{FeatureName}>, NoParams> {
  final {FeatureName}Repository repository;
  
  Get{FeatureName}s(this.repository);
  
  @override
  Future<Either<Failure, List<{FeatureName}>>> call(NoParams params) {
    return repository.get{FeatureName}s();
  }
}

// TEMPLATE: domain/usecases/create_{feature}.dart
class Create{FeatureName} implements UseCase<{FeatureName}, {FeatureName}> {
  final {FeatureName}Repository repository;
  
  Create{FeatureName}(this.repository);
  
  @override
  Future<Either<Failure, {FeatureName}>> call({FeatureName} {featureName}) {
    return repository.create{FeatureName}({featureName});
  }
}
```

---

## Deliverables

### 3. Data Layer Template

**Description:** Template untuk data layer (model, repository impl, data sources).

**Recommended Skills:** `senior-flutter-developer`

**Instructions:**
Buat template untuk:
1. Model dengan JSON serialization (freezed)
2. Remote data source (Dio)
3. Local data source (Hive)
4. Repository implementation

**Output Format:**
```dart
// TEMPLATE: data/models/{feature}_model.dart
import 'package:freezed_annotation/freezed_annotation.dart';

part '{feature_name}_model.freezed.dart';
part '{feature_name}_model.g.dart';

@freezed
class {FeatureName}Model with _${FeatureName}Model {
  const factory {FeatureName}Model({
    required String id,
    required String name,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
  }) = _{FeatureName}Model;
  
  factory {FeatureName}Model.fromJson(Map<String, dynamic> json) =>
      _${FeatureName}ModelFromJson(json);
}

// Extension untuk convert ke entity
extension {FeatureName}ModelX on {FeatureName}Model {
  {FeatureName} toEntity() {
    return {FeatureName}(
      id: id,
      name: name,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
```

---

## Deliverables

### 4. Presentation Layer Template

**Description:** Template untuk presentation layer (controller, screens, widgets).

**Recommended Skills:** `senior-flutter-developer`

**Instructions:**
Buat template untuk:
1. Controller dengan Riverpod (AsyncNotifier)
2. List screen dengan semua states
3. Detail screen
4. Shimmer loading widget
5. List item widget
6. Form widget

**Output Format:**
```dart
// TEMPLATE: presentation/controllers/{feature}_controller.dart
@riverpod
class {FeatureName}Controller extends _${FeatureName}Controller {
  @override
  FutureOr<List<{FeatureName}>> build() async {
    final repository = ref.watch({featureName}RepositoryProvider);
    final result = await repository.get{FeatureName}s();
    
    return result.fold(
      (failure) => throw failure,
      ({featureName}s) => {featureName}s,
    );
  }
  
  Future<void> create{FeatureName}({required String name}) async {
    final repository = ref.read({featureName}RepositoryProvider);
    final result = await repository.create{FeatureName}({FeatureName}(id: '', name: name, createdAt: DateTime.now()));
    
    result.fold(
      (failure) => state = AsyncError(failure, StackTrace.current),
      ({featureName}) {
        final currentData = state.valueOrNull ?? [];
        state = AsyncData([...currentData, {featureName}]);
      },
    );
  }
  
  Future<void> delete{FeatureName}(String id) async {
    final repository = ref.read({featureName}RepositoryProvider);
    final result = await repository.delete{FeatureName}(id);
    
    result.fold(
      (failure) => state = AsyncError(failure, StackTrace.current),
      (_) {
        final currentData = state.valueOrNull ?? [];
        state = AsyncData(currentData.where((item) => item.id != id).toList());
      },
    );
  }
  
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read({featureName}RepositoryProvider);
      final result = await repository.get{FeatureName}s();
      return result.getOrElse(() => []);
    });
  }
}
```

---

## Deliverables

### 5. Complete Screen Template

**Description:** Template screen lengkap dengan semua states.

**Recommended Skills:** `senior-flutter-developer`

**Output Format:**
```dart
// TEMPLATE: presentation/screens/{feature}_list_screen.dart
class {FeatureName}ListScreen extends ConsumerWidget {
  const {FeatureName}ListScreen({super.key});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final {featureName}sAsync = ref.watch({featureName}ControllerProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('{FeatureName}s'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read({featureName}ControllerProvider.notifier).refresh(),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read({featureName}ControllerProvider.notifier).refresh(),
        child: {featureName}sAsync.when(
          data: ({featureName}s) {
            if ({featureName}s.isEmpty) {
              return {FeatureName}EmptyView(
                onCreate: () => _showCreateDialog(context, ref),
              );
            }
            return ListView.builder(
              itemCount: {featureName}s.length,
              itemBuilder: (context, index) {
                final {featureName} = {featureName}s[index];
                return {FeatureName}ListItem(
                  {featureName}: {featureName},
                  onTap: () => context.push('/{featureName}s/${{featureName}.id}'),
                  onDelete: () => _confirmDelete(context, ref, {featureName}.id),
                );
              },
            );
          },
          error: (error, stack) => ErrorView(
            error: error,
            onRetry: () => ref.read({featureName}ControllerProvider.notifier).refresh(),
          ),
          loading: () => const {FeatureName}ListShimmer(),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateDialog(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }
  
  void _showCreateDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => {FeatureName}FormDialog(
        onSubmit: (name) => ref.read({featureName}ControllerProvider.notifier).create{FeatureName}(name: name),
      ),
    );
  }
  
  void _confirmDelete(BuildContext context, WidgetRef ref, String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete {FeatureName}'),
        content: const Text('Are you sure?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              ref.read({featureName}ControllerProvider.notifier).delete{FeatureName}(id);
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
```

---


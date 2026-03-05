---
description: Generate feature baru dengan struktur Clean Architecture lengkap.
---
# Workflow: Flutter Feature Maker

// turbo-all

## Overview

Generate feature baru dengan Clean Architecture structure: domain layer (entity,
repository contract, use cases), data layer (model, data sources, repository
impl), dan presentation layer (controller, screens, widgets).


## Prerequisites

- Project setup dari `01_project_setup.md` selesai
- GoRouter configured
- Riverpod configured


## Agent Behavior

- **Tanya nama feature** — contoh: `product`, `order`, `user`, `todo`.
- **Tanya fields** — list fields yang dibutuhkan entity.
- **Auto-generate semua layers** — domain, data, presentation.
- **Auto-register routes** — tambahkan ke `routes.dart` dan `app_router.dart`.
- **Selalu run code generation** setelah semua file dibuat.


## Recommended Skills

- `senior-flutter-developer` — Flutter + Clean Architecture
- `senior-software-engineer` — Code scaffolding


## Output Structure

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


## Workflow Steps

### Step 1: Analyze Requirements

- Tentukan nama feature (contoh: `product`, `order`, `user`)
- List fields yang dibutuhkan
- Tentukan relationships (if any)

### Step 2: Generate Domain Layer

#### Entity

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
  List<Object?> get props =>
      [id, name, createdAt, updatedAt];
}
```

#### Repository Contract

```dart
// TEMPLATE: domain/repositories/{feature}_repository.dart
abstract class {FeatureName}Repository {
  Future<Result<List<{FeatureName}>>>
      get{FeatureName}s();
  Future<Result<{FeatureName}>>
      get{FeatureName}ById(String id);
  Future<Result<{FeatureName}>>
      create{FeatureName}({FeatureName} item);
  Future<Result<{FeatureName}>>
      update{FeatureName}({FeatureName} item);
  Future<Result<void>>
      delete{FeatureName}(String id);
}
```

#### Use Cases

```dart
// TEMPLATE: domain/usecases/get_{feature}s.dart
class Get{FeatureName}s
    implements UseCase<List<{FeatureName}>, NoParams> {
  final {FeatureName}Repository repository;

  Get{FeatureName}s(this.repository);

  @override
  Future<Result<List<{FeatureName}>>> call(
    NoParams params,
  ) {
    return repository.get{FeatureName}s();
  }
}

// TEMPLATE: domain/usecases/create_{feature}.dart
class Create{FeatureName}
    implements UseCase<{FeatureName}, {FeatureName}> {
  final {FeatureName}Repository repository;

  Create{FeatureName}(this.repository);

  @override
  Future<Result<{FeatureName}>> call(
    {FeatureName} item,
  ) {
    return repository.create{FeatureName}(item);
  }
}
```

### Step 3: Generate Data Layer

#### Model (Freezed)

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
    @JsonKey(name: 'created_at')
    required DateTime createdAt,
    @JsonKey(name: 'updated_at')
    DateTime? updatedAt,
  }) = _{FeatureName}Model;

  factory {FeatureName}Model.fromJson(
    Map<String, dynamic> json,
  ) => _${FeatureName}ModelFromJson(json);
}

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

### Step 4: Generate Presentation Layer

#### Controller

```dart
// TEMPLATE: presentation/controllers/{feature}_controller.dart
@riverpod
class {FeatureName}Controller
    extends _${FeatureName}Controller {
  @override
  FutureOr<List<{FeatureName}>> build() async {
    final repository =
        ref.watch({featureName}RepositoryProvider);
    final result =
        await repository.get{FeatureName}s();

    return result.fold(
      (failure) => throw failure,
      (items) => items,
    );
  }

  Future<void> create{FeatureName}({
    required String name,
  }) async {
    final repository =
        ref.read({featureName}RepositoryProvider);
    final result =
        await repository.create{FeatureName}(
      {FeatureName}(
        id: '',
        name: name,
        createdAt: DateTime.now(),
      ),
    );

    result.fold(
      (failure) => state =
          AsyncError(failure, StackTrace.current),
      (item) {
        final currentData =
            state.valueOrNull ?? [];
        state =
            AsyncData([...currentData, item]);
      },
    );
  }

  Future<void> delete{FeatureName}(
    String id,
  ) async {
    final repository =
        ref.read({featureName}RepositoryProvider);
    final result =
        await repository.delete{FeatureName}(id);

    result.fold(
      (failure) => state =
          AsyncError(failure, StackTrace.current),
      (_) {
        final currentData =
            state.valueOrNull ?? [];
        state = AsyncData(
          currentData
              .where((item) => item.id != id)
              .toList(),
        );
      },
    );
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(
        {featureName}RepositoryProvider,
      );
      final result =
          await repository.get{FeatureName}s();
      return result.dataOrNull ?? [];
    });
  }
}
```

#### List Screen

```dart
// TEMPLATE: presentation/screens/{feature}_list_screen.dart
class {FeatureName}ListScreen extends ConsumerWidget {
  const {FeatureName}ListScreen({super.key});

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {
    final itemsAsync = ref.watch(
      {featureName}ControllerProvider,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('{FeatureName}s'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref
                .read(
                  {featureName}ControllerProvider
                      .notifier,
                )
                .refresh(),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref
            .read(
              {featureName}ControllerProvider
                  .notifier,
            )
            .refresh(),
        child: itemsAsync.when(
          data: (items) {
            if (items.isEmpty) {
              return {FeatureName}EmptyView(
                onCreate: () =>
                    _showCreateDialog(context, ref),
              );
            }
            return ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                return {FeatureName}ListItem(
                  item: item,
                  onTap: () => context.push(
                    '/{featureName}s/${item.id}',
                  ),
                  onDelete: () => _confirmDelete(
                    context,
                    ref,
                    item.id,
                  ),
                );
              },
            );
          },
          error: (error, stack) => ErrorView(
            error: error,
            onRetry: () => ref
                .read(
                  {featureName}ControllerProvider
                      .notifier,
                )
                .refresh(),
          ),
          loading: () =>
              const {FeatureName}ListShimmer(),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () =>
            _showCreateDialog(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }
}
```

#### Shimmer Loading

```dart
// TEMPLATE: presentation/widgets/{feature}_shimmer.dart
class {FeatureName}ListShimmer
    extends StatelessWidget {
  const {FeatureName}ListShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 8,
      itemBuilder: (context, index) =>
          const {FeatureName}ListItemShimmer(),
    );
  }
}

class {FeatureName}ListItemShimmer
    extends StatelessWidget {
  const {FeatureName}ListItemShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: ListTile(
        leading: Container(
          width: 48,
          height: 48,
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
        ),
        title: Container(
          height: 16,
          color: Colors.white,
        ),
        subtitle: Container(
          height: 12,
          margin: const EdgeInsets.only(top: 8),
          color: Colors.white,
        ),
      ),
    );
  }
}
```

### Step 5: Register Routes

```dart
// STEP 1: Update lib/core/router/routes.dart
class AppRoutes {
  // ... existing routes ...

  // {FeatureName} routes
  static const String {featureName}s =
      '/{featureName}s';
  static const String {featureName}Detail =
      '/{featureName}s/:id';
  static const String {featureName}Create =
      '/{featureName}s/create';
  static const String {featureName}Edit =
      '/{featureName}s/:id/edit';

  static String {featureName}DetailPath(
    String id,
  ) => '/{featureName}s/$id';
  static String {featureName}EditPath(
    String id,
  ) => '/{featureName}s/$id/edit';
}

// STEP 2: Add GoRoute to app_router.dart
GoRoute(
  path: AppRoutes.{featureName}s,
  builder: (context, state) =>
      const {FeatureName}ListScreen(),
  routes: [
    GoRoute(
      path: 'create',
      builder: (context, state) =>
          const {FeatureName}CreateScreen(),
    ),
    GoRoute(
      path: ':id',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return {FeatureName}DetailScreen(
          {featureName}Id: id,
        );
      },
      routes: [
        GoRoute(
          path: 'edit',
          builder: (context, state) {
            final id =
                state.pathParameters['id']!;
            return {FeatureName}EditScreen(
              {featureName}Id: id,
            );
          },
        ),
      ],
    ),
  ],
),
```

### Step 6: Setup DI

- Add repository provider di `providers.dart`
- Add data source providers
- Register use cases (if using)

### Step 7: Run Code Generation

```bash
dart run build_runner build -d
```

### Step 8: Test Feature

- Test semua states (loading, error, empty, data)
- Test CRUD operations
- Verify shimmer loading
- Test navigation/routing


## Success Criteria

- [ ] Feature structure mengikuti Clean Architecture
- [ ] Semua file ter-generate tanpa error
- [ ] Code generation berhasil
- [ ] Routes registered di GoRouter
- [ ] Route constants defined di `routes.dart`
- [ ] Feature bisa di-navigate dari app
- [ ] Navigation ke detail/create/edit berfungsi
- [ ] Semua states berfungsi (loading, error, empty, data)
- [ ] Shimmer loading implemented
- [ ] CRUD operations berfungsi
- [ ] `flutter analyze` tidak ada error
- [ ] Null safety handled dengan baik


## Usage Example

Untuk generate feature baru bernama `Todo`:

```bash
# Placeholder replacements:
# {FeatureName} -> Todo
# {featureName} -> todo
# {feature_name} -> todo
```

**Routes:** Update `routes.dart` + `app_router.dart`
**Navigation:** `context.push(AppRoutes.todoDetailPath(todo.id))`


## Tools & Templates

- **Code Generation:** build_runner, freezed, json_serializable, riverpod_generator
- **Shimmer:** shimmer package
- **Form:** flutter_form_builder (optional)
- **Validation:** formz (optional)


## Next Steps

Setelah generate feature:
1. Implement business logic di use cases
2. Connect ke backend (REST API, Firebase, atau Supabase)
3. Add tests (unit, widget, integration)
4. Add analytics tracking

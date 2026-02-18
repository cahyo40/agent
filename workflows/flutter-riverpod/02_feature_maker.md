# Workflow: Flutter Feature Maker

## Overview

Generate feature baru dengan struktur Clean Architecture lengkap. Workflow ini membuat boilerplate code untuk feature baru termasuk entity, model, repository, use case, controller, dan screen.

## Output Location

**Base Folder:** `sdlc/flutter-riverpod/02-feature-maker/`

**Output Files:**
- `feature-template.md` - Panduan menggunakan template
- `feature-generator-script.md` - Script/logika untuk generate feature
- `templates/` - Template files untuk setiap layer
  - `domain/` - Entity, repository, use case templates
  - `data/` - Model, repository impl, data source templates
  - `presentation/` - Controller, screen, widget templates
- `examples/` - Contoh feature yang sudah jadi

## Prerequisites

- Project setup dari `01_project_setup.md` selesai
- Clean Architecture structure sudah ada
- Dependencies sudah terinstall

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

### 6. Route Registration Template

**Description:** Template untuk register feature routes ke GoRouter.

**Output Format:**
```dart
// STEP 1: Add route constants di lib/core/router/routes.dart
class AppRoutes {
  // ... existing routes ...
  
  // {FeatureName} routes
  static const String {featureName}s = '/{featureName}s';
  static const String {featureName}Detail = '/{featureName}s/:id';
  static const String {featureName}Create = '/{featureName}s/create';
  static const String {featureName}Edit = '/{featureName}s/:id/edit';
  
  // Helper methods
  static String {featureName}DetailPath(String id) => '/{featureName}s/$id';
  static String {featureName}EditPath(String id) => '/{featureName}s/$id/edit';
}

// STEP 2: Import screens di lib/core/router/app_router.dart
import '../../features/{feature_name}/presentation/screens/{feature_name}_list_screen.dart';
import '../../features/{feature_name}/presentation/screens/{feature_name}_detail_screen.dart';
import '../../features/{feature_name}/presentation/screens/{feature_name}_create_screen.dart';
import '../../features/{feature_name}/presentation/screens/{feature_name}_edit_screen.dart';

// STEP 3: Add routes ke GoRouter configuration
GoRoute(
  path: AppRoutes.{featureName}s,
  builder: (context, state) => const {FeatureName}ListScreen(),
  routes: [
    GoRoute(
      path: 'create',
      builder: (context, state) => const {FeatureName}CreateScreen(),
    ),
    GoRoute(
      path: ':id',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return {FeatureName}DetailScreen({featureName}Id: id);
      },
      routes: [
        GoRoute(
          path: 'edit',
          builder: (context, state) {
            final id = state.pathParameters['id']!;
            return {FeatureName}EditScreen({featureName}Id: id);
          },
        ),
      ],
    ),
  ],
),

// STEP 4: Navigation examples
// Navigate to list
context.push(AppRoutes.{featureName}s);

// Navigate to detail
context.push(AppRoutes.{featureName}DetailPath({featureName}Id));

// Navigate to create
context.push(AppRoutes.{featureName}Create);

// Navigate to edit
context.push(AppRoutes.{featureName}EditPath({featureName}Id));

// Navigate back
context.pop();
```

---

### 7. Shimmer Loading Template

**Description:** Template shimmer loading skeleton.

**Output Format:**
```dart
// TEMPLATE: presentation/widgets/{feature}_shimmer.dart
class {FeatureName}ListShimmer extends StatelessWidget {
  const {FeatureName}ListShimmer({super.key});
  
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 8,
      itemBuilder: (context, index) => const {FeatureName}ListItemShimmer(),
    );
  }
}

class {FeatureName}ListItemShimmer extends StatelessWidget {
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

## Workflow Steps

1. **Analyze Requirements**
   - Tentukan nama feature (contoh: `product`, `order`, `user`)
   - List fields yang dibutuhkan
   - Tentukan relationships (if any)

2. **Generate Domain Layer**
   - Create entity class
   - Create repository abstract contract
   - Generate use cases (CRUD)

3. **Generate Data Layer**
   - Create model with Freezed
   - Implement remote data source
   - Implement local data source (optional)
   - Create repository implementation

4. **Generate Presentation Layer**
   - Create Riverpod controller
   - Generate screens (list & detail)
   - Create widgets (list item, form, shimmer)
   - Implement error views

5. **Setup DI**
   - Add repository provider di `providers.dart`
   - Add data source providers
   - Register use cases (if using)

6. **Add Routes to AppRouter** ⭐
   - **Step 6.1:** Update `lib/core/router/routes.dart`
     - Add route constants untuk feature
     - Add helper methods untuk generate path dengan params
   
   - **Step 6.2:** Update `lib/core/router/app_router.dart`
     - Import feature screens
     - Add GoRoute untuk list screen (parent route)
     - Add nested routes untuk create, detail, dan edit
     - Configure path parameters (`:id`)
   
   - **Step 6.3:** Update navigation di screens
     - Use `context.push()` untuk navigate
     - Use `context.pop()` untuk go back
     - Use route helper methods untuk type safety
   
   - **Step 6.4:** Test routing
     - Verifikasi semua routes bisa diakses
     - Test navigation dari list ke detail
     - Test navigation dari list ke create
     - Test navigation dari detail ke edit

7. **Run Code Generation**
   - `dart run build_runner build -d`
   - Verify generated files
   - Fix any errors

8. **Test Feature**
   - Test semua states (loading, error, empty, data)
   - Test CRUD operations
   - Verify shimmer loading
   - Test navigation/routing
   - Verify deeplinking (jika diperlukan)

## Success Criteria

- [ ] Feature structure mengikuti Clean Architecture
- [ ] Semua file ter-generate tanpa error
- [ ] Code generation berhasil
- [ ] **Routes registered di GoRouter**
- [ ] **Route constants defined di routes.dart**
- [ ] Feature bisa di-navigate dari app
- [ ] Navigation ke detail/create/edit berfungsi
- [ ] Semua states berfungsi (loading, error, empty, data)
- [ ] Shimmer loading implemented
- [ ] CRUD operations berfungsi
- [ ] `flutter analyze` tidak ada error
- [ ] Null safety handled dengan baik

## Usage Example

Untuk generate feature baru bernama `Todo`:

### Step 1: Generate Feature Files
```bash
# Ganti placeholder dengan nama feature
# {FeatureName} -> Todo
# {featureName} -> todo
# {feature_name} -> todo

# Copy template files dan ganti placeholder
# atau gunakan script generator
```

### Step 2: Register Routes (WAJIB!)

**File: `lib/core/router/routes.dart`**
```dart
class AppRoutes {
  // ... existing routes ...
  
  // Todo routes
  static const String todos = '/todos';
  static const String todoDetail = '/todos/:id';
  static const String todoCreate = '/todos/create';
  
  static String todoDetailPath(String id) => '/todos/$id';
}
```

**File: `lib/core/router/app_router.dart`**
```dart
import '../../features/todo/presentation/screens/todo_list_screen.dart';
import '../../features/todo/presentation/screens/todo_detail_screen.dart';
import '../../features/todo/presentation/screens/todo_create_screen.dart';

// Add to GoRouter routes list:
GoRoute(
  path: AppRoutes.todos,
  builder: (context, state) => const TodoListScreen(),
  routes: [
    GoRoute(
      path: 'create',
      builder: (context, state) => const TodoCreateScreen(),
    ),
    GoRoute(
      path: ':id',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return TodoDetailScreen(todoId: id);
      },
    ),
  ],
),
```

**File: `lib/features/todo/presentation/screens/todo_list_screen.dart`**
```dart
// Navigate to create
FloatingActionButton(
  onPressed: () => context.push(AppRoutes.todoCreate),
  child: const Icon(Icons.add),
),

// Navigate to detail
ListTile(
  onTap: () => context.push(AppRoutes.todoDetailPath(todo.id)),
  title: Text(todo.title),
)
```

### Step 3: Run Code Generation
```bash
dart run build_runner build -d
```

### Step 4: Test Feature & Routing
```bash
flutter run
# Test navigation:
# 1. List screen -> Create screen
# 2. List screen -> Detail screen
# 3. Detail screen -> Back
```

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

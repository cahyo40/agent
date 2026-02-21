---
description: Generate feature baru dengan struktur Clean Architecture lengkap. (Part 4/4)
---
# Workflow: Flutter Feature Maker with YoUI (Part 4/4)

> **Navigation:** This workflow is split into 4 parts.

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
   - Generate screens (list & detail) with YoUI widgets
   - Create widgets (list item with YoCard, form, shimmer)
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
- [ ] **YoUI widgets digunakan (YoCard, etc.)**
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
YoCard(
  onTap: () => context.push(AppRoutes.todoDetailPath(todo.id)),
  child: ListTile(title: Text(todo.title)),
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
- **UI Components:** YoUI (YoCard, YoButton, etc.)
- **Shimmer:** shimmer package
- **Form:** flutter_form_builder (optional)
- **Validation:** formz (optional)


## Next Steps

Setelah generate feature:
1. Implement business logic di use cases
2. Connect ke backend (REST API, Firebase, atau Supabase)
3. Add tests (unit, widget, integration)
4. Add analytics tracking

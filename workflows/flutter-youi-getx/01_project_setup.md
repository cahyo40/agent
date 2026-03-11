---
description: Setup project Flutter dengan GetX + YoUI + Clean Architecture - Complete Guide
---

# 01 - Flutter Project Setup (Complete Guide)

**Goal:** Setup project Flutter dari nol dengan GetX state management, YoUI components, dan Clean Architecture.

**Output:** `sdlc/flutter-youi/01-project-setup/`

**Time Estimate:** 3-4 jam

---

## Overview

Workflow ini mencakup:
- ✅ Clean Architecture folder structure
- ✅ GetX reactive state management
- ✅ YoUI component library integration
- ✅ GetX routing & dependency injection
- ✅ Dio HTTP client setup
- ✅ GetStorage offline storage
- ✅ Example feature dengan semua states
- ✅ Error handling terstruktur

---

## Prerequisites

- **Flutter SDK:** 3.41.1+ (stable channel)
- **Dart SDK:** 3.11.0+
- **IDE:** VS Code atau Android Studio
- **Git:** Version control

---

## Step 1: Create Project

```bash
# Create new Flutter project
flutter create --org com.example myapp

# Navigate to project
cd myapp

# Create folder structure
mkdir -p lib/app/bindings
mkdir -p lib/app/routes
mkdir -p lib/core
mkdir -p lib/core/constants
mkdir -p lib/core/utils
mkdir -p lib/core/theme
mkdir -p lib/features
```

---

## Step 2: Project Structure

```
lib/
├── app/
│   ├── bindings/
│   │   └── initial_binding.dart
│   ├── routes/
│   │   └── app_pages.dart
│   └── main.dart
├── core/
│   ├── constants/
│   │   └── api_constants.dart
│   ├── utils/
│   │   └── app_logger.dart
│   └── theme/
│       └── app_theme.dart
├── features/
│   └── example/
│       ├── bindings/
│       │   └── example_binding.dart
│       ├── controllers/
│       │   └── example_controller.dart
│       ├── data/
│       │   ├── models/
│       │   │   └── example_model.dart
│       │   └── repositories/
│       │       └── example_repository.dart
│       ├── domain/
│       │   ├── entities/
│       │   │   └── example_entity.dart
│       │   └── repositories/
│       │       └── example_repository_interface.dart
│       └── presentation/
│           └── screens/
│               └── example_screen.dart
└── main.dart
```

---

## Step 3: Dependencies (pubspec.yaml)

```yaml
name: myapp
description: Flutter app with GetX + YoUI + Clean Architecture
publish_to: 'none'
version: 1.0.0+1

environment:
  sdk: '>=3.11.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter

  # State Management + Routing + DI
  get: ^4.6.6

  # UI Component Library
  yo_ui:
    git:
      url: https://github.com/cahyo40/youi.git
      ref: main

  # Network
  dio: ^5.4.0
  connectivity_plus: ^6.0.0

  # Storage
  get_storage: ^2.1.1
  flutter_secure_storage: ^9.0.0

  # Utils
  dartz: ^0.10.1
  equatable: ^2.0.5
  intl: ^0.19.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.0
  mocktail: ^1.0.0

flutter:
  uses-material-design: true
```

**Install dependencies:**
```bash
flutter pub get
```

---

## Step 4: Main Entry Point

**File:** `lib/app/main.dart`

```dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:yo_ui/yo_ui.dart';

import 'routes/app_pages.dart';
import 'bindings/initial_binding.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize GetStorage
  await GetStorage.init();
  
  // Run app
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'MyApp',
      debugShowCheckedModeBanner: false,
      
      // Theme
      theme: YoTheme.lightTheme,
      darkTheme: YoTheme.darkTheme,
      themeMode: ThemeMode.system,
      
      // Routing
      initialRoute: AppPages.INITIAL,
      getPages: AppPages.routes,
      
      // Initial binding
      initialBinding: InitialBinding(),
      
      // Default transition
      defaultTransition: Transition.fade,
    );
  }
}
```

---

## Step 5: Routing Setup

**File:** `lib/app/routes/app_pages.dart`

```dart
import 'package:get/get.dart';

import '../bindings/initial_binding.dart';
import '../../features/example/bindings/example_binding.dart';
import '../../features/example/presentation/screens/example_screen.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.EXAMPLE;

  static final routes = [
    GetPage(
      name: _Paths.EXAMPLE,
      page: () => const ExampleScreen(),
      binding: ExampleBinding(),
      transition: Transition.fade,
    ),
  ];
}
```

**File:** `lib/app/routes/app_routes.dart`

```dart
part of 'app_pages.dart';

abstract class Routes {
  Routes._();
  static const EXAMPLE = _Paths.EXAMPLE;
}

class _Paths {
  _Paths._();
  static const EXAMPLE = '/example';
}
```

---

## Step 6: Initial Binding

**File:** `lib/app/bindings/initial_binding.dart`

```dart
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    // Global dependencies
    Get.lazyPut(() => GetStorage(), fenix: true);
    
    // Add other global services here
  }
}
```

---

## Step 7: Example Feature

### 7.1 Entity

**File:** `lib/features/example/domain/entities/example_entity.dart`

```dart
import 'package:equatable/equatable.dart';

class ExampleEntity extends Equatable {
  final int id;
  final String title;
  final String description;
  final bool isCompleted;

  const ExampleEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.isCompleted,
  });

  @override
  List<Object> get props => [id, title, description, isCompleted];
}
```

### 7.2 Model

**File:** `lib/features/example/data/models/example_model.dart`

```dart
import 'package:equatable/equatable.dart';
import '../../domain/entities/example_entity.dart';

class ExampleModel extends Equatable {
  final int id;
  final String title;
  final String description;
  final bool isCompleted;

  const ExampleModel({
    required this.id,
    required this.title,
    required this.description,
    required this.isCompleted,
  });

  factory ExampleModel.fromJson(Map<String, dynamic> json) {
    return ExampleModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      isCompleted: json['isCompleted'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'isCompleted': isCompleted,
    };
  }

  ExampleEntity toEntity() {
    return ExampleEntity(
      id: id,
      title: title,
      description: description,
      isCompleted: isCompleted,
    );
  }

  @override
  List<Object> get props => [id, title, description, isCompleted];
}
```

### 7.3 Repository Interface

**File:** `lib/features/example/domain/repositories/example_repository_interface.dart`

```dart
import 'package:dartz/dartz.dart';
import '../entities/example_entity.dart';

abstract class ExampleRepositoryInterface {
  Future<Either<Exception, List<ExampleEntity>>> getAll();
  Future<Either<Exception, ExampleEntity>> getById(int id);
  Future<Either<Exception, ExampleEntity>> create(ExampleEntity entity);
  Future<Either<Exception, ExampleEntity>> update(ExampleEntity entity);
  Future<Either<Exception, Unit>> delete(int id);
}
```

### 7.4 Repository Implementation

**File:** `lib/features/example/data/repositories/example_repository.dart`

```dart
import 'package:dartz/dartz.dart';
import 'package:get_storage/get_storage.dart';
import '../../domain/entities/example_entity.dart';
import '../../domain/repositories/example_repository_interface.dart';
import '../models/example_model.dart';

class ExampleRepository implements ExampleRepositoryInterface {
  final GetStorage _storage;

  ExampleRepository(this._storage);

  @override
  Future<Either<Exception, List<ExampleEntity>>> getAll() async {
    try {
      final data = _storage.read<List>('examples');
      if (data == null) {
        return const Right([]);
      }
      
      final models = data
          .map((json) => ExampleModel.fromJson(json).toEntity())
          .toList();
      
      return Right(models);
    } catch (e) {
      return Left(Exception('Failed to get examples: $e'));
    }
  }

  @override
  Future<Either<Exception, ExampleEntity>> getById(int id) async {
    try {
      final items = await getAll();
      return items.fold(
        (l) => l,
        (r) {
          final entity = r.firstWhere(
            (e) => e.id == id,
            orElse: () => throw Exception('Not found'),
          );
          return Right(entity);
        },
      );
    } catch (e) {
      return Left(Exception('Failed to get example: $e'));
    }
  }

  @override
  Future<Either<Exception, ExampleEntity>> create(ExampleEntity entity) async {
    try {
      final model = ExampleModel(
        id: DateTime.now().millisecondsSinceEpoch,
        title: entity.title,
        description: entity.description,
        isCompleted: entity.isCompleted,
      );
      
      final items = await getAll();
      items.fold(
        (_) => {},
        (r) {
          r.add(model.toEntity());
          _storage.write('examples', r.map((e) => (e as ExampleModel).toJson()).toList());
        },
      );
      
      return Right(model.toEntity());
    } catch (e) {
      return Left(Exception('Failed to create example: $e'));
    }
  }

  @override
  Future<Either<Exception, ExampleEntity>> update(ExampleEntity entity) async {
    try {
      final items = await getAll();
      return items.fold(
        (l) => l,
        (r) {
          final index = r.indexWhere((e) => e.id == entity.id);
          if (index == -1) {
            return Left(Exception('Not found'));
          }
          
          r[index] = entity;
          _storage.write('examples', r.map((e) => (ExampleModel(
            id: e.id,
            title: e.title,
            description: e.description,
            isCompleted: e.isCompleted,
          )).toJson()).toList());
          
          return Right(entity);
        },
      );
    } catch (e) {
      return Left(Exception('Failed to update example: $e'));
    }
  }

  @override
  Future<Either<Exception, Unit>> delete(int id) async {
    try {
      final items = await getAll();
      return items.fold(
        (l) => l,
        (r) {
          r.removeWhere((e) => e.id == id);
          _storage.write('examples', r.map((e) => (e as ExampleModel).toJson()).toList());
          return const Right(unit);
        },
      );
    } catch (e) {
      return Left(Exception('Failed to delete example: $e'));
    }
  }
}
```

### 7.5 Controller

**File:** `lib/features/example/controllers/example_controller.dart`

```dart
import 'package:get/get.dart';
import '../../domain/entities/example_entity.dart';
import '../data/repositories/example_repository.dart';

class ExampleController extends GetxController {
  final ExampleRepository _repository;

  ExampleController(this._repository);

  // Reactive state
  final examples = <ExampleEntity>[].obs;
  final isLoading = false.obs;
  final error = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadExamples();
  }

  // Load all examples
  Future<void> loadExamples() async {
    try {
      isLoading.value = true;
      error.value = '';
      
      final result = await _repository.getAll();
      result.fold(
        (l) => error.value = l.toString(),
        (r) => examples.value = r,
      );
    } catch (e) {
      error.value = 'Failed to load examples: $e';
    } finally {
      isLoading.value = false;
    }
  }

  // Add example
  Future<void> addExample(String title, String description) async {
    try {
      final entity = ExampleEntity(
        id: 0,
        title: title,
        description: description,
        isCompleted: false,
      );
      
      final result = await _repository.create(entity);
      result.fold(
        (l) => Get.snackbar('Error', l.toString()),
        (r) {
          examples.add(r);
          Get.snackbar('Success', 'Example added');
        },
      );
    } catch (e) {
      Get.snackbar('Error', 'Failed to add example: $e');
    }
  }

  // Toggle completion
  Future<void> toggleExample(int id) async {
    try {
      final index = examples.indexWhere((e) => e.id == id);
      if (index == -1) return;
      
      final entity = examples[index];
      final updated = ExampleEntity(
        id: entity.id,
        title: entity.title,
        description: entity.description,
        isCompleted: !entity.isCompleted,
      );
      
      final result = await _repository.update(updated);
      result.fold(
        (l) => Get.snackbar('Error', l.toString()),
        (r) => examples[index] = r,
      );
    } catch (e) {
      Get.snackbar('Error', 'Failed to toggle example: $e');
    }
  }

  // Delete example
  Future<void> deleteExample(int id) async {
    try {
      final result = await _repository.delete(id);
      result.fold(
        (l) => Get.snackbar('Error', l.toString()),
        (r) {
          examples.removeWhere((e) => e.id == id);
          Get.snackbar('Success', 'Example deleted');
        },
      );
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete example: $e');
    }
  }
}
```

### 7.6 Binding

**File:** `lib/features/example/bindings/example_binding.dart`

```dart
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../controllers/example_controller.dart';
import '../data/repositories/example_repository.dart';

class ExampleBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ExampleRepository>(
      () => ExampleRepository(GetStorage()),
    );
    
    Get.lazyPut<ExampleController>(
      () => ExampleController(Get.find()),
    );
  }
}
```

### 7.7 Screen

**File:** `lib/features/example/presentation/screens/example_screen.dart`

```dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yo_ui/yo_ui.dart';
import '../../controllers/example_controller.dart';

class ExampleScreen extends GetView<ExampleController> {
  const ExampleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Examples'),
        backgroundColor: YoColors.primary,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: YoShimmer.list());
        }

        if (controller.error.value.isNotEmpty) {
          return YoToast.error(controller.error.value);
        }

        if (controller.examples.isEmpty) {
          return const YoEmptyState(
            title: 'No examples',
            subtitle: 'Tap + to add one',
            icon: Icons.list,
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.examples.length,
          itemBuilder: (context, index) {
            final example = controller.examples[index];
            return YoCard(
              child: ListTile(
                title: Text(example.title),
                subtitle: Text(example.description),
                trailing: Checkbox(
                  value: example.isCompleted,
                  onChanged: (_) => controller.toggleExample(example.id),
                ),
                onTap: () => controller.toggleExample(example.id),
              ),
            );
          },
        );
      }),
      floatingActionButton: YoButton.fab(
        icon: Icons.add,
        onPressed: _showAddDialog,
      ),
    );
  }

  void _showAddDialog() {
    final titleController = TextEditingController();
    final descController = TextEditingController();

    Get.dialog(
      AlertDialog(
        title: const Text('Add Example'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            TextField(
              controller: descController,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
          ],
        ),
        actions: [
          YoButton.text(
            label: 'Cancel',
            onPressed: () => Get.back(),
          ),
          YoButton.primary(
            label: 'Add',
            onPressed: () {
              controller.addExample(
                titleController.text,
                descController.text,
              );
              Get.back();
            },
          ),
        ],
      ),
    );
  }
}
```

---

## Step 8: Verification

```bash
# Run the app
flutter run

# Verify:
# ✅ App starts without errors
# ✅ YoUI theme applied
# ✅ Example screen loads
# ✅ Can add/edit/delete examples
# ✅ Data persists with GetStorage
```

---

## Success Criteria

- ✅ Project structure follows Clean Architecture
- ✅ GetX routing works
- ✅ Dependency injection via Bindings
- ✅ YoUI components render correctly
- ✅ Example feature functional
- ✅ Data persists with GetStorage
- ✅ Error handling in place

---

## Next Steps

- **02_feature_maker.md** - Generate new features
- **03_backend_integration.md** - Add REST API with Dio
- **08_state_management_advanced.md** - Advanced GetX patterns

---

**Note:** Ini adalah foundation untuk semua features selanjutnya. Pastikan semua berfungsi dengan baik.

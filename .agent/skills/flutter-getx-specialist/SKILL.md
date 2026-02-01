---
name: flutter-getx-specialist
description: "Expert Flutter state management with GetX including reactive state, dependency injection, routing, and utilities"
---

# Flutter GetX Specialist

## Overview

Master GetX for Flutter including reactive state management, dependency injection, route management, and utility features.

## When to Use This Skill

- Use when implementing GetX
- Use when rapid prototyping
- Use when need all-in-one solution
- Use when simpler state management

## How It Works

### Step 1: State Management

```dart
import 'package:get/get.dart';

// Reactive variables
class CounterController extends GetxController {
  var count = 0.obs;  // Observable
  var user = Rxn<User>();  // Nullable observable
  var items = <String>[].obs;  // Observable list

  void increment() => count++;
  void decrement() => count--;
  
  void addItem(String item) => items.add(item);
}

// GetBuilder (non-reactive)
class SimpleController extends GetxController {
  int count = 0;
  
  void increment() {
    count++;
    update();  // Manual update
  }
}

// GetxController lifecycle
class UserController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    fetchUser();
  }

  @override
  void onReady() {
    super.onReady();
    // Called after widget is rendered
  }

  @override
  void onClose() {
    // Cleanup resources
    super.onClose();
  }
}
```

### Step 2: Widget Integration

```dart
// Obx (reactive)
class CounterScreen extends StatelessWidget {
  final controller = Get.put(CounterController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Obx(() => Text('Count: ${controller.count}')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: controller.increment,
        child: Icon(Icons.add),
      ),
    );
  }
}

// GetBuilder (non-reactive, better performance)
class ItemsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<ItemController>(
      init: ItemController(),
      builder: (controller) {
        return ListView.builder(
          itemCount: controller.items.length,
          itemBuilder: (_, i) => ListTile(title: Text(controller.items[i])),
        );
      },
    );
  }
}

// GetX widget (combines both)
GetX<CounterController>(
  init: CounterController(),
  builder: (controller) {
    return Text('${controller.count}');
  },
)
```

### Step 3: Dependency Injection

```dart
// Register dependencies
void main() {
  // Permanent (never disposed)
  Get.put(ApiService(), permanent: true);
  
  // Lazy singleton
  Get.lazyPut(() => AuthController());
  
  // Factory (new instance each time)
  Get.create(() => FormController());

  runApp(MyApp());
}

// Bindings (organized DI)
class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => HomeController());
    Get.lazyPut(() => UserRepository());
  }
}

// Retrieve instances
final authController = Get.find<AuthController>();
```

### Step 4: Route Management

```dart
// Define routes
class AppPages {
  static final routes = [
    GetPage(
      name: '/home',
      page: () => HomeScreen(),
      binding: HomeBinding(),
      transition: Transition.fade,
    ),
    GetPage(
      name: '/user/:id',
      page: () => UserScreen(),
      binding: UserBinding(),
    ),
  ];
}

// Navigation
Get.toNamed('/home');
Get.toNamed('/user/123', arguments: {'name': 'John'});
Get.back();
Get.offAllNamed('/login');

// Get arguments
final args = Get.arguments;
final userId = Get.parameters['id'];
```

## Best Practices

### ✅ Do This

- ✅ Use Obx for reactive UI
- ✅ Use GetBuilder for lists
- ✅ Use Bindings for DI
- ✅ Use named routes
- ✅ Dispose controllers properly

### ❌ Avoid This

- ❌ Don't overuse Obx (performance)
- ❌ Don't mix state solutions
- ❌ Don't forget permanent: true
- ❌ Don't skip onClose cleanup

## Related Skills

- `@senior-flutter-developer` - Flutter fundamentals
- `@flutter-riverpod-specialist` - Alternative state

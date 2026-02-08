# GetX State Management

## Overview

GetX is an all-in-one Flutter solution providing state management, dependency injection, and route management with minimal boilerplate.

> **Note**: GetX is recommended for simple apps and rapid prototyping. For enterprise apps, consider Riverpod or BLoC.

## When to Use

- Rapid prototyping
- Simple to medium complexity apps
- Need all-in-one solution
- Team prefers minimal boilerplate

---

## State Management

### Reactive Variables

```dart
import 'package:get/get.dart';

class CounterController extends GetxController {
  var count = 0.obs;  // Observable
  var user = Rxn<User>();  // Nullable observable
  var items = <String>[].obs;  // Observable list

  void increment() => count++;
  void decrement() => count--;
  void addItem(String item) => items.add(item);
}
```

### GetBuilder (Non-reactive)

```dart
class SimpleController extends GetxController {
  int count = 0;
  
  void increment() {
    count++;
    update();  // Manual update
  }
}
```

### Controller Lifecycle

```dart
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

---

## Widget Integration

### Obx (Reactive)

```dart
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
```

### GetBuilder (Better Performance)

```dart
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
```

---

## Dependency Injection

```dart
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

---

## Route Management

```dart
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

---

## Best Practices

### ✅ Do This

- ✅ Use Obx for reactive UI
- ✅ Use GetBuilder for lists (better performance)
- ✅ Use Bindings for organized DI
- ✅ Use named routes
- ✅ Dispose controllers properly

### ❌ Avoid This

- ❌ Don't overuse Obx (performance)
- ❌ Don't mix state solutions
- ❌ Don't forget `permanent: true` for services
- ❌ Don't skip onClose cleanup

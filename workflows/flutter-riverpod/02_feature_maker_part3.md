---
description: Generate feature baru dengan struktur Clean Architecture lengkap. (Part 3/4)
---
# Workflow: Flutter Feature Maker (Part 3/4)

> **Navigation:** This workflow is split into 4 parts.

## Deliverables

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

## Deliverables

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


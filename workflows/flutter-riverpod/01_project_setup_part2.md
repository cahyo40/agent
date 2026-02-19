---
description: Setup Flutter project dari nol dengan Clean Architecture dan Riverpod state management. (Part 2/5)
---
# Workflow: Flutter Project Setup with Riverpod (Part 2/5)

> **Navigation:** This workflow is split into 5 parts.

## Deliverables

### 1. Project Structure Clean Architecture

**Description:** Struktur folder lengkap dengan Clean Architecture pattern.

**Recommended Skills:** `senior-flutter-developer`, `senior-ui-ux-designer`

**Instructions:**
1. Buat folder structure berikut:
   ```
   lib/
   ├── bootstrap/              # App initialization
   │   ├── app.dart           # Root widget
   │   ├── bootstrap.dart     # App bootstrapping
   │   └── observers/         # Riverpod observers
   ├── core/                  # Shared infrastructure
   │   ├── di/               # Dependency injection
   │   ├── error/            # Error handling
   │   ├── network/          # Dio setup, interceptors
   │   ├── router/           # GoRouter configuration
   │   ├── storage/          # Secure & local storage
   │   └── theme/            # App theme & colors
   ├── features/             # Feature modules
   │   └── example/          # Contoh feature
   │       ├── data/         # Data layer
   │       ├── domain/       # Domain layer
   │       └── presentation/ # Presentation layer
   ├── l10n/                 # Localization
   ├── shared/               # Shared utilities
   │   ├── extensions/
   │   ├── mixins/
   │   ├── utils/
   │   └── widgets/
   └── main.dart
   ```
2. Setup setiap folder dengan base files
3. Konfigurasi import alias di `pubspec.yaml`

**Output Format:**
```yaml
# pubspec.yaml
name: my_app
description: A new Flutter project.

publish_to: 'none'

version: 1.0.0+1

environment:
  sdk: '>=3.11.0 <4.0.0'  # Updated untuk Flutter 3.41.1

dependencies:
  flutter:
    sdk: flutter
  
  # State Management
  flutter_riverpod: ^2.5.1
  riverpod_annotation: ^2.3.5
  
  # Routing
  go_router: ^14.0.0
  
  # Network
  dio: ^5.4.0
  connectivity_plus: ^6.0.0
  
  # Storage
  hive_flutter: ^1.1.0
  flutter_secure_storage: ^9.0.0
  
  # UI
  cached_network_image: ^3.3.1
  shimmer: ^3.0.0
  flutter_screenutil: ^5.9.0
  google_fonts: ^6.2.1
  
  # Utils
  freezed_annotation: ^2.4.1
  json_annotation: ^4.8.1
  intl: ^0.19.0
  equatable: ^2.0.5
  dartz: ^0.10.1
  
  # Firebase (optional) - Updated untuk Flutter 3.41.1
  # firebase_core: ^3.12.0
  # firebase_auth: ^5.5.0
  # cloud_firestore: ^5.6.0
  # firebase_storage: ^12.4.0
  # firebase_messaging: ^15.2.0
  
  # Supabase (optional)
  # supabase_flutter: ^2.8.0
  
dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^4.0.0
  build_runner: ^2.4.9
  freezed: ^2.5.0
  json_serializable: ^6.7.1
  riverpod_generator: ^2.4.0
  custom_lint: ^0.6.4
  riverpod_lint: ^2.3.10

flutter:
  uses-material-design: true
```

---


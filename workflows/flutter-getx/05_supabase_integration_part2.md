---
description: Integrasi Supabase sebagai alternative backend dengan GetX state management: Authentication, PostgreSQL Database, Rea... (Part 2/7)
---
# Workflow: Supabase Integration (GetX) (Part 2/7)

> **Navigation:** This workflow is split into 7 parts.

## Deliverables

### 1. Supabase Project Setup

**Description:** Setup Supabase project dan konfigurasi Flutter app dengan GetX.

**Recommended Skills:** `senior-flutter-developer`, `senior-supabase-developer`

**Instructions:**
1. **Install Dependencies:**
   ```yaml
   dependencies:
     supabase_flutter: ^2.3.0
     get: ^4.6.6
     flutter_image_compress: ^2.1.0
     image_picker: ^1.0.7
   ```

2. **Initialize Supabase (tanpa ProviderScope):**
   ```dart
   // main.dart
   import 'package:flutter/material.dart';
   import 'package:get/get.dart';
   import 'package:supabase_flutter/supabase_flutter.dart';
   import 'core/config/app_config.dart';
   import 'app.dart';

   void main() async {
     WidgetsFlutterBinding.ensureInitialized();

     await Supabase.initialize(
       url: AppConfig.supabaseUrl,
       anonKey: AppConfig.supabaseAnonKey,
       debug: kDebugMode,
     );

     runApp(const MyApp());
   }
   ```
   > **Catatan:** Tidak ada `ProviderScope` wrapper. Semua dependency injection
   > menggunakan `Get.put()` / `Get.lazyPut()` di `InitialBinding` atau
   > feature-level bindings.

3. **Environment Configuration:**
   - Jangan hardcode URL dan API key
   - Gunakan `--dart-define` atau `flutter_dotenv`

**Output Format:**
```dart
// core/config/app_config.dart
class AppConfig {
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://your-project.supabase.co',
  );

  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'your-anon-key',
  );
}

// main.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/config/app_config.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: AppConfig.supabaseUrl,
    anonKey: AppConfig.supabaseAnonKey,
    debug: kDebugMode,
  );

  runApp(const MyApp());
}

// Global Supabase client access (framework-agnostic)
final supabase = Supabase.instance.client;

// app.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'routes/app_pages.dart';
import 'routes/app_routes.dart';
import 'bindings/initial_binding.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'My App',
      initialBinding: InitialBinding(),
      initialRoute: AppRoutes.splash,
      getPages: AppPages.routes,
      debugShowCheckedModeBanner: false,
    );
  }
}

// bindings/initial_binding.dart
import 'package:get/get.dart';
import '../features/auth/data/repositories/supabase_auth_repository.dart';
import '../features/auth/presentation/controllers/auth_controller.dart';
import '../core/storage/supabase_storage_service.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    // Repository — lazy singleton
    Get.lazyPut<SupabaseAuthRepository>(
      () => SupabaseAuthRepository(),
      fenix: true, // auto-recreate jika disposed
    );

    // Auth controller — permanent, hidup sepanjang app
    Get.put<AuthController>(
      AuthController(),
      permanent: true,
    );

    // Storage service — lazy singleton
    Get.lazyPut<SupabaseStorageService>(
      () => SupabaseStorageService(),
      fenix: true,
    );
  }
}
```

---


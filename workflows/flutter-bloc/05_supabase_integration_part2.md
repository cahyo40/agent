---
description: Integrasi Supabase sebagai alternative backend dengan flutter_bloc state management: Authentication, PostgreSQL Datab... (Part 2/8)
---
# Workflow: Supabase Integration (flutter_bloc) (Part 2/8)

> **Navigation:** This workflow is split into 8 parts.

## Deliverables

### 1. Supabase Project Setup

**Description:** Setup Supabase project dan konfigurasi Flutter app dengan flutter_bloc + get_it.

**Recommended Skills:** `senior-flutter-developer`, `senior-supabase-developer`

**Instructions:**
1. **Install Dependencies:**
   ```yaml
   dependencies:
     supabase_flutter: ^2.3.0
     flutter_bloc: ^8.1.0
     equatable: ^2.0.5
     get_it: ^7.6.0
     injectable: ^2.3.0
     dartz: ^0.10.1
     go_router: ^14.0.0
     flutter_image_compress: ^2.1.0
     image_picker: ^1.0.7
   
   dev_dependencies:
     injectable_generator: ^2.4.0
     build_runner: ^2.4.0
   ```

2. **Initialize Supabase di `bootstrap()`:**
   ```dart
   // bootstrap/bootstrap.dart
   import 'package:flutter/foundation.dart';
   import 'package:flutter/material.dart';
   import 'package:supabase_flutter/supabase_flutter.dart';
   import 'core/config/app_config.dart';
   import 'core/di/injection.dart';
   import 'app.dart';

   Future<void> bootstrap() async {
     WidgetsFlutterBinding.ensureInitialized();

     await Supabase.initialize(
       url: AppConfig.supabaseUrl,
       anonKey: AppConfig.supabaseAnonKey,
       debug: kDebugMode,
     );

     // Setup dependency injection
     configureDependencies();

     runApp(const MyApp());
   }
   ```
   > **Catatan:** Tidak ada `ProviderScope` wrapper. DI menggunakan `get_it` +
   > `injectable`. BlocProvider ditempatkan di widget tree di `MyApp` atau
   > per-route via `BlocProvider`.

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

// bootstrap/bootstrap.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/config/app_config.dart';
import 'core/di/injection.dart';
import 'app.dart';

Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: AppConfig.supabaseUrl,
    anonKey: AppConfig.supabaseAnonKey,
    debug: kDebugMode,
  );

  // Setup get_it + injectable DI
  configureDependencies();

  runApp(const MyApp());
}

// Global Supabase client access (framework-agnostic)
final supabase = Supabase.instance.client;

// core/di/injection.dart
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'injection.config.dart';

final getIt = GetIt.instance;

@InjectableInit()
void configureDependencies() => getIt.init();

// Register Supabase client sebagai external dependency
@module
abstract class RegisterModule {
  @lazySingleton
  SupabaseClient get supabaseClient => Supabase.instance.client;
}

// core/di/injection.config.dart
// File ini di-generate oleh build_runner:
//   dart run build_runner build --delete-conflicting-outputs

// app.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/di/injection.dart';
import 'core/router/app_router.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // AuthBloc hidup sepanjang app — global provider
        BlocProvider<AuthBloc>(
          create: (_) => getIt<AuthBloc>()..add(CheckAuthStatus()),
        ),
      ],
      child: MaterialApp.router(
        title: 'My App',
        routerConfig: appRouter,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
```

---


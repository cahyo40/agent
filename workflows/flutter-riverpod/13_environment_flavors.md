---
description: Setup Environment Config (dev, staging, prod) dengan keamanan envied, `--dart-define`, dan App Flavors.
---
# Workflow: Environment Config & Flavors

// turbo-all

## Overview

Setup Environment Configuration yang aman dan terstruktur untuk Flutter Riverpod. Mencakup penggunaan `envied` untuk obfuscation API keys, setup `--dart-define` untuk environment dev/staging/prod, dan konfigurasi native App Flavors (Android/iOS) menggunakan `flutter_flavorizr` (opsional) atau setup manual.

## Prerequisites

- Base workflow `01_project_setup.md` sudah selesai
- Kebutuhan URL API untuk minimal 2 environment (misal: Dev dan Prod)

## Agent Behavior

- **Gunakan `envied`** untuk menyimpan keys API/secrets, bukan plain string.
- Jangan pernah hardcode API Key di repository. Ciptakan file `.env.example`.
- Siapkan `AppConfig` provider di Riverpod untuk membaca environment.

## Recommended Skills

- `senior-flutter-developer` — Env & CI/CD best practices
- `devsecops-specialist` — Secret management

## Dependencies

Update `pubspec.yaml`:

```yaml
dependencies:
  envied: ^0.5.3

dev_dependencies:
  envied_generator: ^0.5.3
  build_runner: ^2.4.9
```

## Workflow Steps

### Step 1: Buat `.env` files

Jangan jadikan ini bagian dari commit ke git (tambahkan ke `.gitignore`).

```text
# .env.dev
API_BASE_URL=https://api-dev.example.com
API_KEY=dev_secret_key_123

# .env.prod
API_BASE_URL=https://api.example.com
API_KEY=prod_secret_key_456
```

Buat juga `.env.example` untuk referensi developer lain:

```text
# .env.example
API_BASE_URL=
API_KEY=
```

### Step 2: Konfigurasi Envied

Buat class `Env` untuk membaca environment variables dengan aman (obfuscated).

```dart
// lib/core/config/env.dart
import 'package:envied/envied.dart';

part 'env.g.dart';

// Ganti path sesuai target environment (e.g. .env.prod saat build prod)
// Atau gunakan Environment Variables dari CI pipeline
@Envied(path: '.env', requireEnvFile: true)
abstract class Env {
  @EnviedField(varName: 'API_BASE_URL', obfuscate: true)
  static final String apiBaseUrl = _Env.apiBaseUrl;

  @EnviedField(varName: 'API_KEY', obfuscate: true)
  static final String apiKey = _Env.apiKey;
}
```

### Step 3: Run Build Runner

Jalankan generator agar `env.g.dart` dibuat.

```bash
dart run build_runner build -d
```

### Step 4: Setup AppConfig & Flavoring

Gunakan `--dart-define` untuk menentukan build environment.

```dart
// lib/core/config/app_config.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'env.dart';

enum Environment { dev, staging, prod }

class AppConfig {
  final Environment environment;
  final String apiBaseUrl;
  final String apiKey;

  AppConfig({
    required this.environment,
    required this.apiBaseUrl,
    required this.apiKey,
  });

  bool get isDevelopment => environment == Environment.dev;
}

final appConfigProvider = Provider<AppConfig>((ref) {
  // Define environment via command line: --dart-define=ENV=prod
  const envString = String.fromEnvironment('ENV', defaultValue: 'dev');
  
  final Environment env = switch (envString) {
    'prod' => Environment.prod,
    'staging' => Environment.staging,
    _ => Environment.dev,
  };

  return AppConfig(
    environment: env,
    apiBaseUrl: Env.apiBaseUrl, 
    apiKey: Env.apiKey,
  );
});
```

### Step 5: Update Dio/Network Setup

Pastikan API Client menggunakan config ini.

```dart
// lib/core/network/dio_provider.dart
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/app_config.dart';

final dioProvider = Provider<Dio>((ref) {
  final config = ref.watch(appConfigProvider);
  
  final dio = Dio(BaseOptions(
    baseUrl: config.apiBaseUrl,
    headers: {
      'Authorization': 'Bearer ${config.apiKey}',
    },
    connectTimeout: const Duration(seconds: 15),
  ));

  // Add interceptors...
  
  return dio;
});
```

### Step 6: Native Flavors (Opsional tapi Direkomendasikan)

Jika perlu nama aplikasi, bundle ID, atau Firebase config berbeda untuk tiap env. Lakukan configurasi manual pada level OS:

**Android (app/build.gradle):**
```gradle
flavorDimensions "env"
productFlavors {
    dev {
        dimension "env"
        applicationIdSuffix ".dev"
        resValue "string", "app_name", "MyApp Dev"
    }
    prod {
        dimension "env"
        resValue "string", "app_name", "MyApp"
    }
}
```

**Run command:**
```bash
flutter run --flavor dev --dart-define=ENV=dev
flutter run --flavor prod --dart-define=ENV=prod
```

## Success Criteria

- [ ] File `.env` masuk ke `.gitignore`
- [ ] Obfuscated API Keys via `envied` telah diimplementasikan
- [ ] Provider `AppConfig` tersedia untuk mengakses variabel env
- [ ] `--dart-define` parsing bekerja dengan benar
- [ ] Aplikasi dapat di-build dengan target env yang berbeda

## Next Steps

Setelah ini selesai, Anda bisa langsung mengatur:
- `14_security_hardening.md` untuk Certificate Pinning dan Biometric.
- `11_testing_production.md` untuk pipeline CI/CD multienv.

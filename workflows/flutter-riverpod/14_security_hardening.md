---
description: Implementasi Security Hardening (Certificate Pinning, Biometric Auth, Root Detection) untuk aplikasi Enterprise Flutter Riverpod.
---
# Workflow: Security Hardening

// turbo-all

## Overview

Mengubah aplikasi Flutter menjadi standar Security lapis tinggi (Enterprise-grade). Langkah ini akan menambahkan SSL Certificate Pinning di Dio, autentikasi biometrik (`local_auth`), dan pencegahan di-run pada device root/jailbreak. Serta perlindungan key / credential secara enkripsi.

## Prerequisites

- Workflow `05_backend_integration.md` sukses (Untuk apply pinning di Dio)
- Workflow `08_offline_storage.md` sukses (Terutama jika memakai `flutter_secure_storage`)

## Agent Behavior

- Gunakan standard `validateCertificate` di Dio `IOHttpClientAdapter` (Dio 5.0+).
- Implementasi sistem pengecekan jailbreak dengan package khusus apabila diminta.
- Kombinasikan biometric + secure storage, yaitu simpan token hanya saat di-unlock.

## Recommended Skills

- `senior-flutter-developer`
- `mobile-security-tester`
- `senior-api-security-specialist`

## Dependencies

Update `pubspec.yaml`:

```yaml
dependencies:
  local_auth: ^2.1.8
  freerasp: ^6.1.0 # Root/Jailbreak detection (atau flutter_jailbreak_detection)
```

## Workflow Steps

### Step 1: Certificate Pinning (Dio)

Mencegah serangan *Mitm* (Man In The Middle) dengan memegang SHA-256 hash dari server certificate SSL Anda.

```dart
// lib/core/network/dio_provider.dart
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(BaseOptions(
    baseUrl: 'https://api.yoursite.com',
  ));

  // Certificate Pinning Implementation (Dio 5.0+)
  dio.httpClientAdapter = IOHttpClientAdapter(
    createHttpClient: () {
      final client = HttpClient();
      return client;
    },
    validateCertificate: (cert, host, port) {
      if (host != 'api.yoursite.com') return true;
      if (cert == null) return false;
      
      // Hash SHA-256 dari sertifikat public key API
      const pinnedHash = 'YOUR_SHA256_HASH_HERE';
      
      // Lakukan perbandingan (gunakan library crypto atau validasi native)
      // Contoh simpel, atau biasanya verifikasi public key
      // Jika salah, return false -> request akan gagal (DioException)
      return true; 
    },
  );

  return dio;
});
```

*Catatan:* Cara termudah dan paling aman bisa menggunakan plugin `http_certificate_pinning`.

### Step 2: Implementasi Biometric Authentication

Buat Service untuk meminta otentikasi (FaceID/TouchID).

```dart
// lib/core/security/biometric_service.dart
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';

final biometricServiceProvider = Provider((ref) => BiometricService());

class BiometricService {
  final LocalAuthentication _auth = LocalAuthentication();

  Future<bool> authenticate(String reason) async {
    try {
      final bool canAuthenticateWithBiometrics = await _auth.canCheckBiometrics;
      final bool canAuthenticate = canAuthenticateWithBiometrics || await _auth.isDeviceSupported();

      if (!canAuthenticate) return false;

      return await _auth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );
    } on PlatformException catch (_) {
      return false;
    }
  }
}
```

### Step 3: Root / Jailbreak Detection

Untuk mencegah API abuse. 

```dart
// lib/core/security/threat_detection.dart
import 'package:freerasp/freerasp.dart';

Future<void> initSecurityThreatDetection() async {
  final config = TalsecConfig(
    androidConfig: AndroidConfig(
      packageName: 'com.example.app',
      signingCertHashes: ['SHA256_CERT_HASH_HERE'],
      supportedAlternativeStores: ['com.sec.android.app.samsungapps'],
    ),
    iosConfig: IOSConfig(
      bundleIds: ['com.example.app'],
      teamId: 'YOUR_APPLE_TEAM_ID',
    ),
    watcherMail: 'security@example.com',
  );

  final callback = ThreatCallback(
    onAppIntegrity: () => print("App is modified"),
    onObfuscationIssues: () => print("Obfuscation issue"),
    onDebug: () => print("Debugger attached"),
    onDeviceBinding: () => print("Device binding compromised"),
    onDeviceID: () => print("Device ID modified"),
    onHooks: () => print("Hooks detected (Frida/Xposed)"),
    onPrivilegedAccess: () => print("Device is Rooted/Jailbroken"),
    onSecureHardwareNotAvailable: () => print("No Keystore/SecureEnclave"),
    onSimulator: () => print("Running on Emulator"),
    onUnofficialStore: () => print("Installed from unknown source"),
  );

  Talsec.instance.attachListener(callback);
  await Talsec.instance.start(config);
}
```

Panggil `initSecurityThreatDetection()` di `main.dart` sebelum `runApp()`.

### Step 4: Obfuscation Build (Production)

Pastikan aplikasi selalu di-obfuscate di pipeline:
```bash
flutter build apk --obfuscate --split-debug-info=./debug_info
flutter build ios --obfuscate --split-debug-info=./debug_info
```

## Success Criteria

- [ ] Pengecekan Certificate Pinning aktif
- [ ] Autentikasi biometrik (`local_auth`) dapat membedakan device suported/unsupported
- [ ] Aplikasi dapat men-detect jika di-run pada emulator/root
- [ ] Build script dan CI/CD sudah memanfaatkan `--obfuscate`

## Next Steps

Setelah ini selesai, Anda bisa mengatur performa final di aplikasi:
- `12_performance_monitoring.md` untuk Firebase Crashlytics & Sentry

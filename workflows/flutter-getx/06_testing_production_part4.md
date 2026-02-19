---
description: Comprehensive testing (unit, widget, integration) dan production preparation untuk Flutter app dengan GetX state mana... (Part 4/8)
---
# Workflow: Testing & Production (GetX) (Part 4/8)

> **Navigation:** This workflow is split into 8 parts.

## Deliverables

### 3. Integration Testing

Integration test menguji flow lengkap dari UI hingga data layer. Struktur sama dengan Riverpod version, tapi setup menggunakan GetX bindings.

#### 3.1 Integration Test Setup

```dart
// integration_test/app_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:get/get.dart';

import 'package:app/main.dart' as app;
import 'package:app/core/bindings/initial_binding.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    // Reset GetX sebelum setiap integration test
    Get.reset();
  });

  group('App E2E Tests', () {
    testWidgets('complete product flow - create, view, edit, delete',
        (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Step 1: Login
      await tester.enterText(
        find.byKey(const Key('email_field')),
        'admin@example.com',
      );
      await tester.enterText(
        find.byKey(const Key('password_field')),
        'password123',
      );
      await tester.tap(find.byKey(const Key('login_button')));
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Step 2: Navigasi ke halaman produk
      await tester.tap(find.byKey(const Key('menu_products')));
      await tester.pumpAndSettle();

      // Step 3: Tambah produk baru
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const Key('product_name_field')),
        'Integration Test Product',
      );
      await tester.enterText(
        find.byKey(const Key('product_price_field')),
        '50000',
      );
      await tester.tap(find.byKey(const Key('save_button')));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Step 4: Verify produk muncul di list
      expect(find.text('Integration Test Product'), findsOneWidget);

      // Step 5: Edit produk
      await tester.tap(find.text('Integration Test Product'));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('edit_button')));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const Key('product_name_field')),
        'Updated Product',
      );
      await tester.tap(find.byKey(const Key('save_button')));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Step 6: Kembali dan verify update
      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(find.text('Updated Product'), findsOneWidget);

      // Step 7: Delete produk
      await tester.longPress(find.text('Updated Product'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Hapus'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Ya, Hapus'));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Verify produk sudah terhapus
      expect(find.text('Updated Product'), findsNothing);
    });

    testWidgets('authentication flow', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Test invalid login
      await tester.enterText(
        find.byKey(const Key('email_field')),
        'wrong@email.com',
      );
      await tester.enterText(
        find.byKey(const Key('password_field')),
        'wrongpassword',
      );
      await tester.tap(find.byKey(const Key('login_button')));
      await tester.pumpAndSettle(const Duration(seconds: 3));

      expect(find.text('Email atau password salah'), findsOneWidget);

      // Test valid login
      await tester.enterText(
        find.byKey(const Key('email_field')),
        'admin@example.com',
      );
      await tester.enterText(
        find.byKey(const Key('password_field')),
        'password123',
      );
      await tester.tap(find.byKey(const Key('login_button')));
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Verify berhasil login
      expect(find.byKey(const Key('home_screen')), findsOneWidget);

      // Test logout
      await tester.tap(find.byKey(const Key('menu_profile')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Logout'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Ya, Logout'));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      expect(find.byKey(const Key('login_screen')), findsOneWidget);
    });
  });
}
```

#### 3.2 Integration Test dengan Mock API

```dart
// integration_test/mock_api_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:get/get.dart';

import 'package:app/core/network/api_client.dart';
import 'helpers/mock_api_client.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    Get.reset();
    // Inject mock API client sebelum app dimulai
    Get.put<ApiClient>(MockApiClient(), permanent: true);
  });

  testWidgets('should work with mock API', (tester) async {
    // App akan menggunakan MockApiClient karena sudah di-inject
    // sebelum InitialBinding dijalankan
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    // Test flow dengan mock data...
    expect(find.byKey(const Key('home_screen')), findsOneWidget);
  });
}
```

---


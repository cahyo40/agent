---
description: Comprehensive testing (unit, widget, integration) dan production preparation khusus Flutter BLoC: `bloc_test` package... (Part 4/8)
---
# Workflow: Testing & Production (Flutter BLoC) (Part 4/8)

> **Navigation:** This workflow is split into 8 parts.

## Deliverables

### 3. Integration Testing

**Description:** Integration tests untuk end-to-end flows. Framework integration testing sama dengan Riverpod — bedanya hanya di setup BlocProvider vs ProviderScope di app entry point.

**Recommended Skills:** `senior-flutter-developer`, `playwright-specialist`

**Instructions:**
1. **Test Scenarios:**
   - Happy paths (login → browse → action → result)
   - Error scenarios (network down, validation errors)
   - Complete user journeys

2. **Test Environment:**
   - Mock servers (mockoon, wiremock, atau json_server)
   - Test databases
   - Firebase emulators (jika pakai Firebase)
   - Supabase local (jika pakai Supabase)

3. **BLoC-specific Setup:**
   - `injectable` test environment configuration
   - Test module untuk inject mock dependencies
   - `getIt.reset()` di setUp setiap test

**Output Format:**

```dart
// integration_test/app_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:my_app/main.dart' as app;
import 'package:my_app/injection.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // Reset injectable container sebelum setiap test
  setUp(() async {
    await getIt.reset();
    await configureDependencies(environment: 'test');
  });

  group('End-to-End Tests', () {
    testWidgets('complete login flow', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Navigate ke login screen
      await tester.tap(find.text('Masuk'));
      await tester.pumpAndSettle();

      // Masukkan credentials
      await tester.enterText(
        find.byKey(const Key('email_field')),
        'test@example.com',
      );
      await tester.enterText(
        find.byKey(const Key('password_field')),
        'password123',
      );

      // Submit login
      await tester.tap(find.text('Login'));
      await tester.pumpAndSettle();

      // Verify berhasil masuk ke home
      expect(find.text('Selamat Datang'), findsOneWidget);
    });

    testWidgets('create product flow', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Login dulu
      await _performLogin(tester);

      // Navigate ke create product
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      // Isi form product
      await tester.enterText(
        find.byKey(const Key('product_name_field')),
        'Produk Baru',
      );
      await tester.enterText(
        find.byKey(const Key('product_price_field')),
        '150000',
      );
      await tester.enterText(
        find.byKey(const Key('product_description_field')),
        'Deskripsi produk baru',
      );

      // Submit
      await tester.tap(find.text('Simpan'));
      await tester.pumpAndSettle();

      // Verify product muncul di list
      expect(find.text('Produk Baru'), findsOneWidget);
      expect(find.text('Rp 150.000'), findsOneWidget);
    });

    testWidgets('search and filter products', (tester) async {
      app.main();
      await tester.pumpAndSettle();
      await _performLogin(tester);

      // Tap search icon
      await tester.tap(find.byIcon(Icons.search));
      await tester.pumpAndSettle();

      // Ketik search query
      await tester.enterText(find.byType(TextField), 'Produk');
      await tester.pumpAndSettle();

      // Verify filtered results
      expect(find.text('Produk Baru'), findsOneWidget);
    });

    testWidgets('handles offline gracefully', (tester) async {
      // Simulasi offline mode
      app.main();
      await tester.pumpAndSettle();

      // Assert offline indicator muncul
      expect(find.text('Tidak ada koneksi internet'), findsOneWidget);
    });
  });
}

// Helper function
Future<void> _performLogin(WidgetTester tester) async {
  await tester.tap(find.text('Masuk'));
  await tester.pumpAndSettle();
  await tester.enterText(
    find.byKey(const Key('email_field')),
    'test@example.com',
  );
  await tester.enterText(
    find.byKey(const Key('password_field')),
    'password123',
  );
  await tester.tap(find.text('Login'));
  await tester.pumpAndSettle();
}
```

---


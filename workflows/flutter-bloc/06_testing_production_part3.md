---
description: Comprehensive testing (unit, widget, integration) dan production preparation khusus Flutter BLoC: `bloc_test` package... (Part 3/8)
---
# Workflow: Testing & Production (Flutter BLoC) (Part 3/8)

> **Navigation:** This workflow is split into 8 parts.

## Deliverables

### 2. Widget Testing dengan MockBloc

**Description:** Widget tests untuk screens dan UI components. Di BLoC, kita pakai `MockBloc` dan `whenListen` dari `bloc_test` untuk mock bloc state di widget tests. TIDAK perlu `ProviderScope` atau `ProviderContainer`.

**Recommended Skills:** `senior-flutter-developer`, `playwright-specialist`

**Instructions:**
1. **MockBloc Setup:**
   - Extend `MockBloc<Event, State>` dari `bloc_test`
   - Gunakan `whenListen` untuk setup stream dan initial state
   - Wrap widget dengan `BlocProvider<T>.value(value: mockBloc)`
   - JANGAN pakai `BlocProvider(create: ...)` di test — pakai `.value()`

2. **Screen Tests:**
   - Test dengan berbagai states (initial, loading, error, empty, data)
   - Test user interactions (tap, scroll, swipe)
   - Test navigation (GoRouter mock)

3. **Component Tests:**
   - Test reusable widgets
   - Test form validation
   - Test error boundaries / error widgets

**Output Format:**

```dart
// test/features/product/presentation/screens/product_list_screen_test.dart
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

// ========================================
// MockBloc — ini yang beda dari Riverpod!
// Tidak perlu MockNotifier, cukup extend MockBloc
// ========================================
class MockProductBloc extends MockBloc<ProductEvent, ProductState>
    implements ProductBloc {}

class MockAuthBloc extends MockBloc<AuthEvent, AuthState>
    implements AuthBloc {}

void main() {
  late MockProductBloc mockProductBloc;
  late MockAuthBloc mockAuthBloc;

  final tProducts = [
    Product(id: '1', name: 'Test Product', price: 99.99),
    Product(id: '2', name: 'Another Product', price: 49.99),
  ];

  setUp(() {
    mockProductBloc = MockProductBloc();
    mockAuthBloc = MockAuthBloc();
  });

  // Helper untuk pump widget dengan BlocProvider
  // Ini SANGAT berbeda dari Riverpod yang pakai ProviderScope
  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: MultiBlocProvider(
        providers: [
          BlocProvider<ProductBloc>.value(value: mockProductBloc),
          BlocProvider<AuthBloc>.value(value: mockAuthBloc),
        ],
        child: const ProductListScreen(),
      ),
    );
  }

  // ========================================
  // Loading State Tests
  // ========================================
  group('Loading State', () {
    testWidgets('shows CircularProgressIndicator when state is ProductLoading',
        (tester) async {
      // whenListen: setup mock bloc stream dan initial state
      // Ini pengganti ProviderScope overrides di Riverpod
      whenListen(
        mockProductBloc,
        Stream<ProductState>.empty(),
        initialState: const ProductLoading(),
      );

      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });

  // ========================================
  // Data Loaded State Tests
  // ========================================
  group('Loaded State', () {
    testWidgets('shows product list when state is ProductLoaded',
        (tester) async {
      whenListen(
        mockProductBloc,
        Stream<ProductState>.empty(),
        initialState: ProductLoaded(products: tProducts),
      );

      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.text('Test Product'), findsOneWidget);
      expect(find.text('Another Product'), findsOneWidget);
      expect(find.text('Rp 99.99'), findsOneWidget);
    });

    testWidgets('shows empty state when product list is empty',
        (tester) async {
      whenListen(
        mockProductBloc,
        Stream<ProductState>.empty(),
        initialState: const ProductLoaded(products: []),
      );

      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.text('Tidak ada produk'), findsOneWidget);
      expect(find.byIcon(Icons.inbox), findsOneWidget);
    });
  });

  // ========================================
  // Error State Tests
  // ========================================
  group('Error State', () {
    testWidgets('shows error message and retry button when state is ProductError',
        (tester) async {
      whenListen(
        mockProductBloc,
        Stream<ProductState>.empty(),
        initialState: const ProductError(message: 'Server error'),
      );

      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.text('Server error'), findsOneWidget);
      expect(find.text('Coba Lagi'), findsOneWidget);
    });

    testWidgets('dispatches LoadProducts when retry button is tapped',
        (tester) async {
      whenListen(
        mockProductBloc,
        Stream<ProductState>.empty(),
        initialState: const ProductError(message: 'Network error'),
      );

      await tester.pumpWidget(createWidgetUnderTest());

      await tester.tap(find.text('Coba Lagi'));
      await tester.pump();

      // Verify event ditambahkan ke bloc
      verify(() => mockProductBloc.add(const LoadProducts())).called(1);
    });
  });

  // ========================================
  // User Interaction Tests
  // ========================================
  group('User Interactions', () {
    testWidgets('dispatches DeleteProductEvent on swipe dismiss',
        (tester) async {
      whenListen(
        mockProductBloc,
        Stream<ProductState>.empty(),
        initialState: ProductLoaded(products: tProducts),
      );

      await tester.pumpWidget(createWidgetUnderTest());

      // Swipe untuk delete
      await tester.drag(
        find.text('Test Product'),
        const Offset(-500, 0),
      );
      await tester.pumpAndSettle();

      // Confirm delete dialog
      await tester.tap(find.text('Hapus'));
      await tester.pump();

      verify(() => mockProductBloc.add(const DeleteProductEvent(id: '1')))
          .called(1);
    });

    testWidgets('shows SnackBar when product is created (BlocListener)',
        (tester) async {
      // whenListen dengan stream yang emit state baru
      // Ini test BlocListener behavior
      whenListen(
        mockProductBloc,
        Stream.fromIterable([
          const ProductLoading(),
          ProductCreated(product: tProducts.first),
        ]),
        initialState: ProductLoaded(products: tProducts),
      );

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump(); // Process stream events

      expect(find.text('Produk berhasil dibuat'), findsOneWidget);
    });
  });

  // ========================================
  // Navigation Tests (dengan GoRouter)
  // ========================================
  group('Navigation', () {
    testWidgets('navigates to product detail on tap', (tester) async {
      final mockGoRouter = MockGoRouter();

      whenListen(
        mockProductBloc,
        Stream<ProductState>.empty(),
        initialState: ProductLoaded(products: tProducts),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: InheritedGoRouter(
            goRouter: mockGoRouter,
            child: BlocProvider<ProductBloc>.value(
              value: mockProductBloc,
              child: const ProductListScreen(),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Test Product'));
      await tester.pumpAndSettle();

      verify(() => mockGoRouter.push('/products/1')).called(1);
    });
  });
}

// ========================================
// test/features/auth/presentation/screens/login_screen_test.dart
// ========================================
class MockLoginFormBloc extends MockBloc<LoginFormEvent, LoginFormState>
    implements LoginFormBloc {}

void main() {
  late MockAuthBloc mockAuthBloc;
  late MockLoginFormBloc mockLoginFormBloc;

  setUp(() {
    mockAuthBloc = MockAuthBloc();
    mockLoginFormBloc = MockLoginFormBloc();
  });

  testWidgets('shows validation error when email is empty', (tester) async {
    whenListen(
      mockAuthBloc,
      Stream<AuthState>.empty(),
      initialState: const AuthUnauthenticated(),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<AuthBloc>.value(
          value: mockAuthBloc,
          child: const LoginScreen(),
        ),
      ),
    );

    // Tap login button tanpa isi form
    await tester.tap(find.byType(ElevatedButton));
    await tester.pumpAndSettle();

    expect(find.text('Email wajib diisi'), findsOneWidget);
  });

  testWidgets('shows loading indicator when auth state is AuthLoading',
      (tester) async {
    whenListen(
      mockAuthBloc,
      Stream<AuthState>.empty(),
      initialState: const AuthLoading(),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<AuthBloc>.value(
          value: mockAuthBloc,
          child: const LoginScreen(),
        ),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    // Login button harus disabled saat loading
    final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
    expect(button.onPressed, isNull);
  });

  testWidgets('dispatches LoginRequested with form data', (tester) async {
    whenListen(
      mockAuthBloc,
      Stream<AuthState>.empty(),
      initialState: const AuthUnauthenticated(),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<AuthBloc>.value(
          value: mockAuthBloc,
          child: const LoginScreen(),
        ),
      ),
    );

    // Isi form
    await tester.enterText(
      find.byKey(const Key('email_field')),
      'test@example.com',
    );
    await tester.enterText(
      find.byKey(const Key('password_field')),
      'password123',
    );

    // Submit
    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();

    verify(() => mockAuthBloc.add(const LoginRequested(
          email: 'test@example.com',
          password: 'password123',
        ))).called(1);
  });
}
```

**Golden Test Pattern (untuk BLoC):**

```dart
// test/features/product/presentation/widgets/product_card_golden_test.dart
void main() {
  testWidgets('ProductCard matches golden file', (tester) async {
    // Golden tests tidak perlu MockBloc karena test widget individual
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ProductCard(
            product: Product(
              id: '1',
              name: 'Golden Test Product',
              price: 150000,
              imageUrl: 'assets/test/product.png',
            ),
            onTap: () {},
            onDelete: () {},
          ),
        ),
      ),
    );

    await expectLater(
      find.byType(ProductCard),
      matchesGoldenFile('goldens/product_card.png'),
    );
  });
}
```

---


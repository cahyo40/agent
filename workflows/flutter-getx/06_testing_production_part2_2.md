---
description: Comprehensive testing (unit, widget, integration) dan production preparation untuk Flutter app dengan GetX state mana... (Sub-part 2/3)
---
      controller.selectProduct(product);

      expect(controller.selectedProduct.value, product);
    });

    test('should compute total value reactively', () async {
      final products = [
        TestDataFactory.createProduct(price: 10000.0, stock: 5),
        TestDataFactory.createProduct(id: 'p2', price: 20000.0, stock: 3),
      ];

      when(() => mockRepository.getProducts())
          .thenAnswer((_) async => Right(products));

      controller.onInit();
      await Future.delayed(Duration.zero);

      // totalValue = (10000 * 5) + (20000 * 3) = 110000
      expect(controller.totalInventoryValue, 110000.0);
    });
  });
}
```

#### 1.3 Testing Service Layer

```dart
// test/unit/services/auth_service_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dartz/dartz.dart';

import 'package:app/core/services/auth_service.dart';
import 'package:app/features/auth/data/repositories/auth_repository.dart';
import '../../helpers/test_helpers.dart';

void main() {
  late AuthService authService;
  late MockAuthRepository mockAuthRepo;
  late MockStorageService mockStorage;

  setUp(() {
    mockAuthRepo = MockAuthRepository();
    mockStorage = MockStorageService();
    Get.put<AuthRepository>(mockAuthRepo);
    Get.put<StorageService>(mockStorage);
    authService = Get.put(AuthService());
  });

  tearDown(() {
    Get.reset();
  });

  group('AuthService - Login', () {
    test('should login successfully and save token', () async {
      const email = 'test@example.com';
      const password = 'password123';
      final user = TestDataFactory.createUser(email: email);
      const token = 'jwt-token-123';

      when(() => mockAuthRepo.login(email, password))
          .thenAnswer((_) async => Right(AuthResult(user: user, token: token)));
      when(() => mockStorage.saveToken(token))
          .thenAnswer((_) async => {});
      when(() => mockStorage.saveUser(any()))
          .thenAnswer((_) async => {});

      final result = await authService.login(email, password);

      expect(result.isRight(), true);
      expect(authService.currentUser.value, user);
      expect(authService.isAuthenticated.value, true);
      verify(() => mockStorage.saveToken(token)).called(1);
    });

    test('should handle login failure', () async {
      when(() => mockAuthRepo.login(any(), any()))
          .thenAnswer((_) async => Left(AuthFailure('Invalid credentials')));

      final result = await authService.login('wrong@email.com', 'wrong');

      expect(result.isLeft(), true);
      expect(authService.isAuthenticated.value, false);
      expect(authService.currentUser.value, null);
    });

    test('should handle network error during login', () async {
      when(() => mockAuthRepo.login(any(), any()))
          .thenThrow(NetworkException('No internet'));

      final result = await authService.login('test@example.com', 'pass');

      expect(result.isLeft(), true);
    });
  });

  group('AuthService - Logout', () {
    test('should logout and clear stored data', () async {
      when(() => mockAuthRepo.logout())
          .thenAnswer((_) async => const Right(unit));
      when(() => mockStorage.clearAll())
          .thenAnswer((_) async => {});

      await authService.logout();

      expect(authService.currentUser.value, null);
      expect(authService.isAuthenticated.value, false);
      verify(() => mockStorage.clearAll()).called(1);
    });
  });

  group('AuthService - Token Refresh', () {
    test('should refresh token when expired', () async {
      const oldToken = 'old-token';
      const newToken = 'new-token';

      when(() => mockStorage.getToken())
          .thenAnswer((_) async => oldToken);
      when(() => mockAuthRepo.refreshToken(oldToken))
          .thenAnswer((_) async => Right(newToken));
      when(() => mockStorage.saveToken(newToken))
          .thenAnswer((_) async => {});

      final result = await authService.refreshToken();

      expect(result, true);
      verify(() => mockStorage.saveToken(newToken)).called(1);
    });
  });
}
```

#### 1.4 Testing GetX Bindings

```dart
// test/unit/bindings/product_binding_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import 'package:app/features/product/bindings/product_binding.dart';
import 'package:app/features/product/presentation/controllers/product_controller.dart';
import 'package:app/features/product/data/repositories/product_repository.dart';
import '../../helpers/test_helpers.dart';

void main() {
  tearDown(() {
    Get.reset();
  });

  group('ProductBinding', () {
    test('should register all required dependencies', () {
      // Pre-register dependencies yang dibutuhkan ProductBinding
      Get.put<ProductRepository>(MockProductRepository());

      // Execute binding
      ProductBinding().dependencies();

      // Verify semua controller ter-register
      expect(Get.isRegistered<ProductController>(), true);
    });

    test('should use lazyPut for controllers', () {
      Get.put<ProductRepository>(MockProductRepository());

      ProductBinding().dependencies();

      // Controller harus bisa di-find
      final controller = Get.find<ProductController>();
      expect(controller, isA<ProductController>());
    });

    test('should allow re-registration after reset', () {
      Get.put<ProductRepository>(MockProductRepository());

      ProductBinding().dependencies();
      Get.reset();

      // Setelah reset, binding bisa dipanggil lagi
      Get.put<ProductRepository>(MockProductRepository());
      ProductBinding().dependencies();

      expect(Get.isRegistered<ProductController>(), true);
    });
  });
}
```


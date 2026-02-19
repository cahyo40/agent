---
description: Setup Flutter project dari nol dengan Clean Architecture dan BLoC state management. (Part 5/6)
---
# Workflow: Flutter Project Setup with BLoC (Part 5/6)

> **Navigation:** This workflow is split into 6 parts.

## Deliverables

### 5. Cubit Pattern (Untuk Fitur Sederhana)

**Description:** Untuk fitur yang tidak butuh events terpisah, pakai `Cubit` yang lebih sederhana.

```dart
// Contoh: ThemeCubit (toggle light/dark mode)
// features/settings/presentation/cubit/theme_cubit.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

part 'theme_state.dart';

@injectable
class ThemeCubit extends Cubit<ThemeState> {
  ThemeCubit() : super(const ThemeState(themeMode: ThemeMode.system));

  void setThemeMode(ThemeMode mode) {
    emit(ThemeState(themeMode: mode));
  }

  void toggleTheme() {
    final newMode = state.themeMode == ThemeMode.light
        ? ThemeMode.dark
        : ThemeMode.light;
    emit(ThemeState(themeMode: newMode));
  }
}

// features/settings/presentation/cubit/theme_state.dart
part of 'theme_cubit.dart';

class ThemeState extends Equatable {
  final ThemeMode themeMode;

  const ThemeState({required this.themeMode});

  @override
  List<Object?> get props => [themeMode];
}
```

**Kapan pakai Bloc vs Cubit:**

| Kriteria         | Bloc                                    | Cubit                    |
|------------------|-----------------------------------------|--------------------------|
| Complexity       | Fitur kompleks (CRUD, multi-step)       | Fitur sederhana (toggle, counter) |
| Events           | Butuh events terpisah untuk traceability | Langsung call method     |
| Testing          | Bisa test per-event                     | Test per-method          |
| Transformations  | Bisa pakai `EventTransformer` (debounce, throttle) | Tidak bisa |
| Verbosity        | Lebih verbose (3 files)                 | Lebih ringkas (2 files)  |

---

## Deliverables

### 6. Testing Setup dengan bloc_test

**Description:** Setup unit testing untuk BLoC.

```dart
// test/features/product/presentation/bloc/product_bloc_test.dart
import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

// Mocks
class MockGetProducts extends Mock implements GetProducts {}
class MockGetProduct extends Mock implements GetProduct {}
class MockCreateProduct extends Mock implements CreateProduct {}
class MockDeleteProduct extends Mock implements DeleteProduct {}

void main() {
  late ProductBloc bloc;
  late MockGetProducts mockGetProducts;
  late MockGetProduct mockGetProduct;
  late MockCreateProduct mockCreateProduct;
  late MockDeleteProduct mockDeleteProduct;

  setUp(() {
    mockGetProducts = MockGetProducts();
    mockGetProduct = MockGetProduct();
    mockCreateProduct = MockCreateProduct();
    mockDeleteProduct = MockDeleteProduct();

    bloc = ProductBloc(
      getProducts: mockGetProducts,
      getProduct: mockGetProduct,
      createProduct: mockCreateProduct,
      deleteProduct: mockDeleteProduct,
    );
  });

  tearDown(() {
    bloc.close();
  });

  group('LoadProducts', () {
    final tProducts = [
      Product(
        id: '1',
        name: 'Test Product',
        description: 'Description',
        price: 10.0,
        createdAt: DateTime.now(),
      ),
    ];

    blocTest<ProductBloc, ProductState>(
      'emits [ProductLoading, ProductLoaded] when LoadProducts is added '
      'and getProducts returns success',
      build: () {
        when(() => mockGetProducts())
            .thenAnswer((_) async => Right(tProducts));
        return bloc;
      },
      act: (bloc) => bloc.add(const LoadProducts()),
      expect: () => [
        const ProductLoading(),
        ProductLoaded(products: tProducts),
      ],
      verify: (_) {
        verify(() => mockGetProducts()).called(1);
      },
    );

    blocTest<ProductBloc, ProductState>(
      'emits [ProductLoading, ProductError] when LoadProducts is added '
      'and getProducts returns failure',
      build: () {
        when(() => mockGetProducts()).thenAnswer(
          (_) async => const Left(ServerFailure(message: 'Server error')),
        );
        return bloc;
      },
      act: (bloc) => bloc.add(const LoadProducts()),
      expect: () => [
        const ProductLoading(),
        const ProductError(message: 'Server error'),
      ],
    );
  });

  group('DeleteProductEvent', () {
    blocTest<ProductBloc, ProductState>(
      'emits [ProductLoading, ProductDeleted] when delete succeeds',
      build: () {
        when(() => mockDeleteProduct('1'))
            .thenAnswer((_) async => const Right(null));
        return bloc;
      },
      act: (bloc) => bloc.add(const DeleteProductEvent(id: '1')),
      expect: () => [
        const ProductLoading(),
        const ProductDeleted(productId: '1'),
      ],
    );
  });
}
```

---

## Deliverables

### 7. Perbandingan Pattern: BLoC vs Riverpod

**Quick Reference** untuk developer yang sudah familiar dengan salah satu pattern.

#### State Management Comparison

| Aspect                    | BLoC Pattern                                      | Riverpod Pattern                              |
|---------------------------|---------------------------------------------------|-----------------------------------------------|
| **State class**           | `sealed class ProductState extends Equatable`     | `AsyncValue<List<Product>>` (built-in)        |
| **Event dispatch**        | `bloc.add(LoadProducts())`                        | `ref.read(provider.notifier).load()`          |
| **State listen (UI)**     | `BlocBuilder<ProductBloc, ProductState>`          | `ref.watch(productProvider)`                  |
| **Side effects**          | `BlocListener<ProductBloc, ProductState>`         | `ref.listen(provider, ...)`                   |
| **Combined**              | `BlocConsumer` (Builder + Listener)               | `ConsumerWidget` + `ref.listen` in build      |
| **DI**                    | `get_it` + `injectable` + `BlocProvider`          | Built-in `Provider` / `@riverpod`             |
| **Global state**          | `MultiBlocProvider` di root                       | `ProviderScope` di root                       |
| **Scoped state**          | `BlocProvider` di level screen/route              | `ProviderScope` overrides                     |
| **Code generation**       | `injectable_generator` (DI), `freezed` (optional) | `riverpod_generator`, `freezed` (optional)    |
| **Testing**               | `bloc_test` package                               | Override providers di test                    |
| **Debugging**             | `BlocObserver` (global)                           | `ProviderObserver` (global)                   |

#### Code Mapping (Side by Side)

**Riverpod way:**
```dart
// Provider
@riverpod
class ProductController extends _$ProductController {
  @override
  FutureOr<List<Product>> build() async {
    final repo = ref.watch(productRepositoryProvider);
    final result = await repo.getProducts();
    return result.fold((f) => throw f, (data) => data);
  }
}

// UI
class ProductScreen extends ConsumerWidget {
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(productControllerProvider);
    return state.when(
      data: (products) => ListView(...),
      loading: () => ShimmerList(),
      error: (e, _) => ErrorView(error: e),
    );
  }
}
```

**BLoC way:**
```dart
// Bloc
class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final GetProducts _getProducts;
  ProductBloc(this._getProducts) : super(ProductInitial()) {
    on<LoadProducts>((event, emit) async {
      emit(ProductLoading());
      final result = await _getProducts();
      result.fold(
        (f) => emit(ProductError(message: f.message)),
        (data) => emit(ProductLoaded(products: data)),
      );
    });
  }
}

// UI
class ProductScreen extends StatelessWidget {
  Widget build(BuildContext context) {
    return BlocBuilder<ProductBloc, ProductState>(
      builder: (context, state) {
        return switch (state) {
          ProductLoaded(:final products) => ListView(...),
          ProductLoading() => ShimmerList(),
          ProductError(:final message) => ErrorView(message: message),
          _ => SizedBox.shrink(),
        };
      },
    );
  }
}
```

#### Kapan Pilih BLoC vs Riverpod

| Pilih BLoC jika...                                | Pilih Riverpod jika...                        |
|----------------------------------------------------|-----------------------------------------------|
| Tim sudah familiar dengan BLoC                     | Tim lebih suka functional/declarative style   |
| Butuh strict event-driven architecture             | Ingin less boilerplate                        |
| Perlu event transformations (debounce, throttle)   | Ingin DI built-in tanpa get_it               |
| Enterprise project dengan banyak developer         | Project kecil-menengah, butuh cepat           |
| Butuh clear separation events & states             | Prefer `AsyncValue` built-in loading/error    |
| Ingin `BlocObserver` untuk centralized logging     | Prefer granular provider-level control        |

---


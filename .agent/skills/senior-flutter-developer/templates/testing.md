# Testing Strategy

## Unit Test: Repository with Mocks

```dart
@GenerateMocks([ProductRemoteDataSource, ProductLocalDataSource, NetworkInfo])
void main() {
  late ProductRepositoryImpl repository;
  late MockProductRemoteDataSource mockRemote;
  late MockProductLocalDataSource mockLocal;
  late MockNetworkInfo mockNetworkInfo;

  setUp(() {
    mockRemote = MockProductRemoteDataSource();
    mockLocal = MockProductLocalDataSource();
    mockNetworkInfo = MockNetworkInfo();
    
    repository = ProductRepositoryImpl(
      remoteDataSource: mockRemote,
      localDataSource: mockLocal,
      networkInfo: mockNetworkInfo,
      syncQueue: MockSyncQueue(),
    );
  });

  group('getProducts', () {
    test('should return cached data when local data exists', () async {
      // Arrange
      when(mockLocal.getProducts()).thenAnswer((_) async => [tProductModel]);
      when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);

      // Act
      final result = await repository.getProducts();

      // Assert
      expect(result, isA<Right<Failure, List<Product>>>());
      verify(mockLocal.getProducts()).called(1);
    });

    test('should fetch remote when cache is empty and online', () async {
      // Arrange
      when(mockLocal.getProducts()).thenThrow(CacheException('Empty'));
      when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(mockRemote.getProducts()).thenAnswer((_) async => [tProductModel]);

      // Act
      final result = await repository.getProducts();

      // Assert
      expect(result, isA<Right<Failure, List<Product>>>());
      verify(mockRemote.getProducts()).called(1);
    });
  });
}
```

## Widget Test: Screen with Provider Overrides

```dart
void main() {
  testWidgets('ProductListScreen shows products', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          productsControllerProvider.overrideWith(
            () => MockProductsController(),
          ),
        ],
        child: const MaterialApp(home: ProductListScreen()),
      ),
    );

    // Loading state
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.pumpAndSettle();

    // Data state
    expect(find.byType(ProductCard), findsNWidgets(3));
    expect(find.text('Product 1'), findsOneWidget);
  });
}
```

## Golden Test: Visual Regression

```dart
void main() {
  testWidgets('ProductCard matches golden', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 200,
              child: ProductCard(product: tProduct),
            ),
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

## Integration Test

```dart
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('End-to-end test', () {
    testWidgets('complete purchase flow', (tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      // Navigate to product
      await tester.tap(find.text('Products'));
      await tester.pumpAndSettle();

      // Add to cart
      await tester.tap(find.byType(ProductCard).first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Add to Cart'));
      await tester.pumpAndSettle();

      // Verify cart
      await tester.tap(find.byIcon(Icons.shopping_cart));
      await tester.pumpAndSettle();
      expect(find.text('1 item'), findsOneWidget);
    });
  });
}
```

## Test Fixtures

```dart
// test/fixtures/product_fixtures.dart
class ProductFixtures {
  static final tProduct = Product(
    id: '1',
    name: 'Test Product',
    price: 99.99,
    imageUrl: 'https://example.com/image.jpg',
  );

  static final tProductModel = ProductModel(
    id: '1',
    name: 'Test Product',
    price: 99.99,
    imageUrl: 'https://example.com/image.jpg',
  );

  static final tProductList = [
    tProduct,
    Product(id: '2', name: 'Product 2', price: 49.99, imageUrl: ''),
  ];
}
```

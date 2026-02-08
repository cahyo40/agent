# Performance Optimization

## 1. Slivers for Complex Scrolling

```dart
class ProductListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        const SliverAppBar(
          floating: true,
          title: Text('Products'),
        ),
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.7,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) => ProductCard(product: products[index]),
              childCount: products.length,
            ),
          ),
        ),
      ],
    );
  }
}
```

## 2. RepaintBoundary for Complex Widgets

```dart
class ExpensiveWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: CustomPaint(
        painter: ComplexChartPainter(data: chartData),
      ),
    );
  }
}
```

## 3. Isolate for Heavy Computation

```dart
Future<List<ProcessedData>> processLargeDataset(List<RawData> data) async {
  return compute(_processInBackground, data);
}

List<ProcessedData> _processInBackground(List<RawData> data) {
  return data
      .where((d) => d.isValid)
      .map((d) => ProcessedData.fromRaw(d))
      .toList()
    ..sort((a, b) => b.score.compareTo(a.score));
}
```

## 4. Image Caching & Precaching

```dart
class OptimizedImage extends StatelessWidget {
  const OptimizedImage({required this.url, this.width, this.height});
  
  final String url;
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: url,
      width: width,
      height: height,
      memCacheWidth: width?.toInt(),
      memCacheHeight: height?.toInt(),
      fadeInDuration: const Duration(milliseconds: 200),
      placeholder: (_, __) => const ShimmerPlaceholder(),
      errorWidget: (_, __, ___) => const Icon(Icons.error),
    );
  }
}

// Precache images in initState or provider
Future<void> precacheProductImages(List<Product> products) async {
  final context = navigatorKey.currentContext!;
  await Future.wait(
    products.take(10).map((p) => 
      precacheImage(CachedNetworkImageProvider(p.imageUrl), context)
    ),
  );
}
```

## 5. ListView Optimization

```dart
ListView.builder(
  // Use const constructors
  itemBuilder: (context, index) {
    return const ProductTile(); // Use const when possible
  },
  // Add extent for fixed-height items
  itemExtent: 80.0,
  // Cache extent for smoother scrolling
  cacheExtent: 500.0,
  // Use separatorBuilder instead of padding
  // Key for proper diffing
  key: const PageStorageKey<String>('productList'),
)
```

## 6. Const Constructors

```dart
// ✅ Good
const EdgeInsets.all(16)
const TextStyle(fontSize: 14)
const Icon(Icons.add)

// ❌ Avoid
EdgeInsets.all(16) // Creates new instance every build
TextStyle(fontSize: 14)
Icon(Icons.add)
```

## 7. Memoization with ValueNotifier

```dart
class ExpensiveCalculation extends StatefulWidget {
  @override
  State<ExpensiveCalculation> createState() => _ExpensiveCalculationState();
}

class _ExpensiveCalculationState extends State<ExpensiveCalculation> {
  late final ValueNotifier<List<Data>> _processedData;

  @override
  void initState() {
    super.initState();
    _processedData = ValueNotifier(_calculateExpensiveData());
  }

  List<Data> _calculateExpensiveData() {
    // Heavy computation
    return [];
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<Data>>(
      valueListenable: _processedData,
      builder: (context, data, _) {
        return ListView.builder(
          itemCount: data.length,
          itemBuilder: (context, index) => DataTile(data: data[index]),
        );
      },
    );
  }
}
```

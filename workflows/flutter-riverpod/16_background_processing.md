---
description: Implementasi Dart Isolates dan local background execution untuk heavy computations agar UI tidak jank.
---
# Workflow: Background Processing & Isolates

// turbo-all

## Overview

Aplikasi yang responsif membutuhkan frame rate 60fps. Mem-parsing JSON besar, rendering gambar, atau filter list yang sangat panjang di main UI thread akan menurunkan frame rate dan menyebabkan "jank" (freeze sementara). Workflow ini menjelaskan best practices memakai Dart 3 Isolates untuk heavy computation.


## Prerequisites

- Project setup dari `01_project_setup.md` selesai
- API dan Backend integration dari `05_backend_integration.md` tersedia


## Agent Behavior

- **Gunakan `Isolate.run()`** dari Dart 3 (atau `compute()`) untuk parsing JSON payload berukuran besar (lebih dari 1MB).
- Hindari pembuatan Isolate untuk tasks yang sangat cepat/kecil karena *overhead* spawning isolate (±50-100ms) bisa jadi lebih lama dibanding task-nya.
- **Tampilkan loading state** (Shimmer/Spinner) di UI ketika background Isolate sedang bekerja.


## Recommended Skills

- `senior-flutter-developer` — Performance optimization, Isolates
- `python-async-specialist` (atau setaranya di Dart) — Concurrency & Parallelism


## Workflow Steps

### Step 1: Parsing Data Besar dengan `Isolate.run()`

Pada Dart 3, `Isolate.run()` adalah cara termudah dan paling efisien untuk memindahkan pekerjaan sinkron dan berat (seperti memparsing JSON besar) ke background thread (Isolate).

```dart
// lib/features/products/data/repositories/product_repository_impl.dart
import 'dart:convert';
import 'dart:isolate';
import 'package:dio/dio.dart';

import '../models/product_model.dart';
import '../../domain/repositories/product_repository.dart';

class ProductRepositoryImpl implements ProductRepository {
  final Dio dio;

  ProductRepositoryImpl(this.dio);

  @override
  Future<List<ProductModel>> getThousandsOfProducts() async {
    final response = await dio.get('/products/massive-payload');
    
    // Asumsi: response.data is a JSON String, OR Dio already parsed it to a Map/List.
    // Jika masih berupa JSON string:
    final jsonString = response.data.toString();
    
    // Gunakan Isolate.run() untuk menghindari UI freeze saat memparsing
    final List<ProductModel> products = await Isolate.run<List<ProductModel>>(() {
      // PROSES BERAT DALAM ISOLATE (Background Thread)
      // Perhatikan: Dalam blok ini, kita tidak boleh memanggil object/instance 
      // yang terikat ke thread utama (seperti Flutter plugins, file system platform khusus, dll)
      
      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList.map((e) => ProductModel.fromJson(e as Map<String, dynamic>)).toList();
    });

    return products;
  }
}
```

### Step 2: Menggunakan `compute()` sebagai Alternatif (Legacy / Top-Level func)

Fungsi `compute()` melakukan hal serupa dengan `Isolate.run()`, namun membutuhkan *top-level function* atau *static function*. `Isolate.run()` lebih modern karena mendukung *closure*.

```dart
import 'package:flutter/foundation.dart';

// Top-level function wajib di luar class atau static method
List<ProductModel> _parseProducts(String jsonStr) {
  final parsed = jsonDecode(jsonStr).cast<Map<String, dynamic>>();
  return parsed.map<ProductModel>((json) => ProductModel.fromJson(json)).toList();
}

Future<List<ProductModel>> getProductsWithCompute(String responseBody) async {
  // compute membutuhkan (function, parameter)
  return compute(_parseProducts, responseBody);
}
```

### Step 3: Implementasi Riverpod FutureProvider untuk Isolate

Ketika memanggil Data atau API yang menggunakan Isolate melalui Riverpod, status `AsyncLoading` berguna untuk memberi tahu UI agar me-render efek *shimmer*.

```dart
// lib/features/products/presentation/providers/product_provider.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../domain/entities/product.dart';
import '../data/repositories/product_repository_impl.dart';

part 'product_provider.g.dart';

@riverpod
Future<List<Product>> massiveProducts(MassiveProductsRef ref) async {
  final repository = ref.watch(productRepositoryProvider);
  return await repository.getThousandsOfProducts();
}
```

```dart
// Di UI File (contoh)
Widget build(BuildContext context, WidgetRef ref) {
  final productsAsync = ref.watch(massiveProductsProvider);

  return productsAsync.when(
    data: (products) => ListView.builder(
      itemCount: products.length,
      itemBuilder: (_, i) => ProductTile(product: products[i]),
    ),
    loading: () => const ShimmerList(), // Didefinisikan di 03_ui_components.md
    error: (err, stack) => AppErrorWidget(message: err.toString()),
  );
}
```

### Step 4: Menangani Tugas Periodik Latar Belakang (Contoh dengan `workmanager`)

Untuk mengeksekusi proses ketika aplikasi tertutup (contoh: sinkronisasi data lokal ke server secara batch tiap 12 jam).

```yaml
dependencies:
  workmanager: ^0.5.2
```

```dart
// lib/bootstrap/background_worker.dart
import 'package:workmanager/workmanager.dart';

@pragma('vm:entry-point') // Wajib agar compiler tidak menghapus function ini
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    switch (task) {
      case 'syncDataTask':
        // Lakukan sinkronisasi background (misal: API calls)
        // print('Syncing data in background...');
        break;
    }
    return Future.value(true);
  });
}

class BackgroundWorker {
  static Future<void> initialize() async {
    await Workmanager().initialize(
      callbackDispatcher,
      isInDebugMode: false,
    );
  }

  static void registerPeriodicSync() {
    Workmanager().registerPeriodicTask(
      "1",
      "syncDataTask",
      frequency: const Duration(hours: 12), // Minimum durasi di Android ~15 mins
    );
  }
}
```
*Note: Panggil `BackgroundWorker.initialize()` di `main.dart` / `bootstrap.dart`.*


## Success Criteria

- [ ] UI tidak jank (frozen) ketika aplikasi me-load payload JSON yang sangat besar.
- [ ] Profile timeline di DevTools tidak menunjukkan `Frame time > 16ms` akibat *JSON decoding*.
- [ ] Isolates / `compute()` berhasil mengembalikan tipe data model yang benar ke thread utama.
- [ ] Periodic background tasks terdaftar tanpa error (opsional jika menggunakan workmanager).


## Next Steps

Setelah sukses memindahkan data parsing yang berat ke Isolates:
1. Pastikan offline caching mendukung struktur data ini (Lihat `08_offline_storage.md`).
2. Pastikan Error handler global menangkap kegagalan parsing / isolat (Lihat `12_performance_monitoring.md`).

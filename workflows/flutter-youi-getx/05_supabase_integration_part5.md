---
description: Integrasi Supabase sebagai alternative backend dengan GetX state management: Authentication, PostgreSQL Database, Rea... (Part 5/7)
---
# Workflow: Supabase Integration (GetX) (Part 5/7)

> **Navigation:** This workflow is split into 7 parts.

## Deliverables

### 4. Realtime Subscriptions (GetX)

**Description:** Real-time updates dengan Supabase Realtime, dikelola melalui `GetxController` lifecycle (`onInit` / `onClose`).

**Recommended Skills:** `senior-flutter-developer`, `senior-supabase-developer`

**Instructions:**
1. **Setup Realtime:**
   - Enable realtime di Supabase Dashboard
   - Subscribe ke table changes via `onInit()`
   - Unsubscribe di `onClose()`
   - Handle INSERT, UPDATE, DELETE events

2. **Channel Management:**
   - `RealtimeChannel?` disimpan sebagai field di controller
   - Broadcast events
   - Presence tracking

**Output Format:**
```dart
// ============================================================
// REALTIME DATA SOURCE — Framework-agnostic
// ============================================================

// features/product/data/datasources/product_realtime_ds.dart
import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/product_model.dart';

class ProductRealtimeDataSource {
  final SupabaseClient _supabase;
  RealtimeChannel? _channel;

  ProductRealtimeDataSource({SupabaseClient? supabase})
      : _supabase = supabase ?? Supabase.instance.client;

  Stream<List<ProductModel>> watchProducts() {
    final controller = StreamController<List<ProductModel>>.broadcast();

    // Initial fetch
    _supabase
        .from('products')
        .select()
        .order('created_at', ascending: false)
        .then((response) {
      final products = (response as List)
          .map((json) => ProductModel.fromJson(json))
          .toList();
      controller.add(products);
    });

    // Subscribe to realtime changes
    _channel = _supabase
        .channel('products_realtime')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'products',
          callback: (payload) {
            // Re-fetch setelah ada perubahan
            _supabase
                .from('products')
                .select()
                .order('created_at', ascending: false)
                .then((response) {
              final products = (response as List)
                  .map((json) => ProductModel.fromJson(json))
                  .toList();
              controller.add(products);
            });
          },
        )
        .subscribe();

    return controller.stream;
  }

  Stream<ProductModel> watchProduct(String productId) {
    final controller = StreamController<ProductModel>.broadcast();

    // Initial fetch
    _supabase
        .from('products')
        .select()
        .eq('id', productId)
        .single()
        .then((response) {
      controller.add(ProductModel.fromJson(response));
    });

    // Subscribe to changes on specific product
    _channel = _supabase
        .channel('product_$productId')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'products',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'id',
            value: productId,
          ),
          callback: (payload) {
            if (payload.newRecord.isNotEmpty) {
              controller.add(
                ProductModel.fromJson(payload.newRecord),
              );
            }
          },
        )
        .subscribe();

    return controller.stream;
  }

  void unsubscribe() {
    _channel?.unsubscribe();
    _channel = null;
  }
}

// ============================================================
// REALTIME PRODUCT CONTROLLER — GetX version
// Lifecycle: subscribe di onInit(), unsubscribe di onClose()
// ============================================================

// features/product/presentation/controllers/realtime_product_controller.dart
import 'dart:async';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/datasources/product_realtime_ds.dart';
import '../../data/models/product_model.dart';

class RealtimeProductController extends GetxController {
  final ProductRealtimeDataSource _realtimeDs;

  RealtimeProductController({ProductRealtimeDataSource? realtimeDs})
      : _realtimeDs = realtimeDs ?? ProductRealtimeDataSource();

  // ---- Reactive State ----
  final RxList<ProductModel> products = <ProductModel>[].obs;
  final Rx<ProductModel?> selectedProduct = Rx<ProductModel?>(null);
  final RxBool isLoading = true.obs;
  final RxString errorMessage = ''.obs;

  // ---- Internal ----
  RealtimeChannel? _channel;
  StreamSubscription? _streamSubscription;

  @override
  void onInit() {
    super.onInit();
    _subscribeToChanges();
  }

  @override
  void onClose() {
    _streamSubscription?.cancel();
    _channel?.unsubscribe();
    _realtimeDs.unsubscribe();
    super.onClose();
  }

  // ---- Subscribe ke realtime changes ----
  void _subscribeToChanges() {
    isLoading.value = true;

    _streamSubscription = _realtimeDs.watchProducts().listen(
      (productList) {
        products.assignAll(productList);
        isLoading.value = false;
        errorMessage.value = '';
      },
      onError: (error) {
        errorMessage.value = 'Realtime error: $error';
        isLoading.value = false;
      },
    );
  }

  // ---- Watch single product ----
  void watchProduct(String productId) {
    _realtimeDs.watchProduct(productId).listen(
      (product) {
        selectedProduct.value = product;
      },
      onError: (error) {
        errorMessage.value = 'Watch product error: $error';
      },
    );
  }

  // ---- Manual refresh ----
  void refresh() {
    _streamSubscription?.cancel();
    _realtimeDs.unsubscribe();
    _subscribeToChanges();
  }
}

// ============================================================
// ALTERNATIVE: Direct channel di controller (tanpa data source)
// Lebih simple untuk kasus straightforward
// ============================================================

// features/chat/presentation/controllers/chat_controller.dart
import 'dart:async';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ChatController extends GetxController {
  final _supabase = Supabase.instance.client;

  RealtimeChannel? _channel;
  final RxList<Map<String, dynamic>> messages = <Map<String, dynamic>>[].obs;
  final RxBool isConnected = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadMessages();
    _subscribeToMessages();
  }

  @override
  void onClose() {
    _channel?.unsubscribe();
    super.onClose();
  }

  Future<void> _loadMessages() async {
    try {
      final response = await _supabase
          .from('messages')
          .select('*, users(name, avatar_url)')
          .order('created_at', ascending: true)
          .limit(50);

      messages.assignAll(List<Map<String, dynamic>>.from(response));
    } catch (e) {
      Get.snackbar('Error', 'Gagal memuat pesan: $e');
    }
  }

  void _subscribeToMessages() {
    _channel = _supabase
        .channel('messages_channel')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'messages',
          callback: (payload) {
            messages.add(payload.newRecord);
          },
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.delete,
          schema: 'public',
          table: 'messages',
          callback: (payload) {
            messages.removeWhere(
              (m) => m['id'] == payload.oldRecord['id'],
            );
          },
        )
        .subscribe((status, error) {
      isConnected.value = status == RealtimeSubscribeStatus.subscribed;
    });
  }

  Future<void> sendMessage(String text) async {
    try {
      await _supabase.from('messages').insert({
        'text': text,
        'user_id': _supabase.auth.currentUser!.id,
      });
      // Realtime subscription akan otomatis update messages list
    } catch (e) {
      Get.snackbar('Error', 'Gagal mengirim pesan: $e');
    }
  }
}

// ============================================================
// PRESENCE TRACKING — Siapa yang online
// ============================================================

// features/presence/presentation/controllers/presence_controller.dart
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PresenceController extends GetxController {
  final _supabase = Supabase.instance.client;

  RealtimeChannel? _presenceChannel;
  final RxList<Map<String, dynamic>> onlineUsers =
      <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    _trackPresence();
  }

  @override
  void onClose() {
    _presenceChannel?.unsubscribe();
    super.onClose();
  }

  void _trackPresence() {
    final userId = _supabase.auth.currentUser?.id ?? 'anonymous';

    _presenceChannel = _supabase.channel('online_users')
      ..onPresenceSync((payload) {
        final presenceState = _presenceChannel!.presenceState();
        final users = <Map<String, dynamic>>[];

        for (final entry in presenceState.entries) {
          for (final presence in entry.value) {
            users.add(presence.payload);
          }
        }
        onlineUsers.assignAll(users);
      })
      ..onPresenceJoin((payload) {
        // User baru join
      })
      ..onPresenceLeave((payload) {
        // User leave
      })
      ..subscribe((status, error) async {
        if (status == RealtimeSubscribeStatus.subscribed) {
          await _presenceChannel!.track({
            'user_id': userId,
            'online_at': DateTime.now().toIso8601String(),
          });
        }
      });
  }
}

// ============================================================
// REALTIME BINDING
// ============================================================

// features/product/bindings/realtime_product_binding.dart
import 'package:get/get.dart';
import '../data/datasources/product_realtime_ds.dart';
import '../presentation/controllers/realtime_product_controller.dart';

class RealtimeProductBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ProductRealtimeDataSource>(
      () => ProductRealtimeDataSource(),
    );
    Get.lazyPut<RealtimeProductController>(
      () => RealtimeProductController(realtimeDs: Get.find()),
    );
  }
}
```

---


---
description: Integrasi Supabase sebagai alternative backend dengan flutter_bloc state management: Authentication, PostgreSQL Datab... (Sub-part 1/3)
---
# Workflow: Supabase Integration (flutter_bloc) (Part 5/8)

> **Navigation:** This workflow is split into 8 parts.

## Deliverables

### 4. Realtime Subscriptions (flutter_bloc)

**Description:** Real-time updates dengan Supabase Realtime, dikelola melalui `Bloc` lifecycle. `RealtimeChannel` di-subscribe di constructor bloc, `unsubscribe()` di `close()`. Perubahan data dari callback realtime di-dispatch sebagai internal event.

**Recommended Skills:** `senior-flutter-developer`, `senior-supabase-developer`

**Instructions:**
1. **Setup Realtime:**
   - Enable realtime di Supabase Dashboard
   - Subscribe ke table changes di bloc constructor
   - Unsubscribe di `close()`
   - Handle INSERT, UPDATE, DELETE events

2. **Channel Management:**
   - `RealtimeChannel?` disimpan sebagai field di bloc
   - Payload dari callback di-convert jadi event internal
   - Bloc state di-update sesuai event type

3. **Pattern:**
   - Internal event `_RealtimeUpdate` membawa payload
   - Bloc memproses payload dan update state
   - UI hanya perlu `BlocBuilder` — tidak perlu manage subscription

**Output Format:**
```dart
// ============================================================
// REALTIME EVENTS
// ============================================================

// features/product/presentation/bloc/realtime_product_event.dart
import 'package:equatable/equatable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/models/product_model.dart';

sealed class RealtimeProductEvent extends Equatable {
  const RealtimeProductEvent();

  @override
  List<Object?> get props => [];
}

/// Load initial data saat bloc pertama kali dibuat
class LoadRealtimeProducts extends RealtimeProductEvent {}

/// Internal event — dipanggil oleh realtime callback, BUKAN oleh UI
class _RealtimeUpdate extends RealtimeProductEvent {
  final PostgresChangePayload payload;

  const _RealtimeUpdate(this.payload);

  @override
  List<Object?> get props => [payload];
}

/// Manual refresh — re-fetch semua data
class RefreshRealtimeProducts extends RealtimeProductEvent {}

// ============================================================
// REALTIME STATES
// ============================================================

// features/product/presentation/bloc/realtime_product_state.dart
import 'package:equatable/equatable.dart';
import '../../data/models/product_model.dart';

sealed class RealtimeProductState extends Equatable {
  const RealtimeProductState();

  @override
  List<Object?> get props => [];
}

class RealtimeProductInitial extends RealtimeProductState {}

class RealtimeProductLoading extends RealtimeProductState {}

class RealtimeProductLoaded extends RealtimeProductState {
  final List<ProductModel> products;

  const RealtimeProductLoaded({required this.products});

  @override
  List<Object?> get props => [products];
}

class RealtimeProductError extends RealtimeProductState {
  final String message;

  const RealtimeProductError({required this.message});

  @override
  List<Object?> get props => [message];
}

// ============================================================
// REALTIME PRODUCT BLOC
// Channel subscribe di constructor, unsubscribe di close()
// ============================================================

// features/product/presentation/bloc/realtime_product_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/datasources/product_supabase_ds.dart';
import '../../data/models/product_model.dart';
import 'realtime_product_event.dart';
import 'realtime_product_state.dart';

@injectable
class RealtimeProductBloc
    extends Bloc<RealtimeProductEvent, RealtimeProductState> {
  final ProductSupabaseDataSource _dataSource;
  final SupabaseClient _supabase;

  RealtimeChannel? _channel;

  RealtimeProductBloc(this._dataSource, this._supabase)
      : super(RealtimeProductInitial()) {
    on<LoadRealtimeProducts>(_onLoadRealtimeProducts);
    on<_RealtimeUpdate>(_onRealtimeUpdate);
    on<RefreshRealtimeProducts>(_onRefreshRealtimeProducts);

    // Subscribe ke realtime channel langsung di constructor
    _channel = _supabase
        .channel('products_realtime')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'products',
          callback: (payload) {
            // Dispatch internal event — bloc akan handle di _onRealtimeUpdate
            add(_RealtimeUpdate(payload));
          },
        )
        .subscribe();
  }

  // ---- Load initial data ----
  Future<void> _onLoadRealtimeProducts(
    LoadRealtimeProducts event,
    Emitter<RealtimeProductState> emit,
  ) async {
    emit(RealtimeProductLoading());

    try {
      final products = await _dataSource.getProducts();
      emit(RealtimeProductLoaded(products: products));
    } catch (e) {
      emit(RealtimeProductError(message: 'Gagal memuat produk: $e'));
    }
  }

  // ---- Handle realtime update dari Supabase ----
  Future<void> _onRealtimeUpdate(
    _RealtimeUpdate event,
    Emitter<RealtimeProductState> emit,
  ) async {
    final currentState = state;
    if (currentState is! RealtimeProductLoaded) {
      // Kalau belum pernah load, fetch semua dulu
      add(LoadRealtimeProducts());
      return;
    }

    final products = List<ProductModel>.from(currentState.products);
    final payload = event.payload;

    switch (payload.eventType) {
      case PostgresChangeEvent.insert:
        if (payload.newRecord.isNotEmpty) {
          final newProduct = ProductModel.fromJson(payload.newRecord);
          products.insert(0, newProduct);
        }
        break;

      case PostgresChangeEvent.update:
        if (payload.newRecord.isNotEmpty) {
          final updatedProduct = ProductModel.fromJson(payload.newRecord);
          final index = products.indexWhere((p) => p.id == updatedProduct.id);
          if (index != -1) {
            products[index] = updatedProduct;
          }
        }
        break;

      case PostgresChangeEvent.delete:
        if (payload.oldRecord.isNotEmpty) {
          final deletedId = payload.oldRecord['id'] as String?;
          if (deletedId != null) {
            products.removeWhere((p) => p.id == deletedId);
          }
        }
        break;

      default:
        // PostgresChangeEvent.all — tidak terjadi sebagai event type
        break;
    }

    emit(RealtimeProductLoaded(products: products));
  }

  // ---- Manual refresh ----
  Future<void> _onRefreshRealtimeProducts(
    RefreshRealtimeProducts event,
    Emitter<RealtimeProductState> emit,
  ) async {
    emit(RealtimeProductLoading());

    try {
      final products = await _dataSource.getProducts();
      emit(RealtimeProductLoaded(products: products));
    } catch (e) {
      emit(RealtimeProductError(message: 'Gagal refresh: $e'));
    }
  }

  @override
  Future<void> close() {
    _channel?.unsubscribe();
    return super.close();
  }
}

// ============================================================
// WATCH SINGLE PRODUCT — Bloc yang listen 1 product saja
// ============================================================

// features/product/presentation/bloc/product_detail_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/models/product_model.dart';

// Events
sealed class ProductDetailEvent extends Equatable {
  const ProductDetailEvent();
  @override
  List<Object?> get props => [];
}

class WatchProduct extends ProductDetailEvent {
  final String productId;
  const WatchProduct({required this.productId});
  @override
  List<Object?> get props => [productId];
}

class _ProductUpdated extends ProductDetailEvent {
  final Map<String, dynamic> record;
  const _ProductUpdated(this.record);
  @override
  List<Object?> get props => [record];
}

// States
sealed class ProductDetailState extends Equatable {
  const ProductDetailState();
  @override
  List<Object?> get props => [];
}

class ProductDetailInitial extends ProductDetailState {}
class ProductDetailLoading extends ProductDetailState {}

class ProductDetailLoaded extends ProductDetailState {
  final ProductModel product;
  const ProductDetailLoaded({required this.product});
  @override
  List<Object?> get props => [product];
}

class ProductDetailError extends ProductDetailState {
  final String message;
  const ProductDetailError({required this.message});
  @override
  List<Object?> get props => [message];
}

// Bloc
class ProductDetailBloc extends Bloc<ProductDetailEvent, ProductDetailState> {
  final SupabaseClient _supabase;
  RealtimeChannel? _channel;

  ProductDetailBloc(this._supabase) : super(ProductDetailInitial()) {
    on<WatchProduct>(_onWatchProduct);
    on<_ProductUpdated>(_onProductUpdated);
  }

  Future<void> _onWatchProduct(
    WatchProduct event,
    Emitter<ProductDetailState> emit,
  ) async {
    emit(ProductDetailLoading());

    try {
      // Initial fetch
      final response = await _supabase
          .from('products')
          .select()
          .eq('id', event.productId)
          .single();

      emit(ProductDetailLoaded(product: ProductModel.fromJson(response)));

      // Subscribe to changes on this specific product
      _channel?.unsubscribe(); // cleanup previous channel jika ada
      _channel = _supabase
          .channel('product_${event.productId}')
          .onPostgresChanges(
            event: PostgresChangeEvent.all,
            schema: 'public',
            table: 'products',
            filter: PostgresChangeFilter(
              type: PostgresChangeFilterType.eq,
              column: 'id',
              value: event.productId,
            ),
            callback: (payload) {
              if (payload.newRecord.isNotEmpty) {
                add(_ProductUpdated(payload.newRecord));
              }
            },
          )
          .subscribe();
    } catch (e) {
      emit(ProductDetailError(message: 'Gagal memuat detail: $e'));
    }
  }
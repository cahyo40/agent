---
description: Integrasi Supabase sebagai alternative backend dengan flutter_bloc state management: Authentication, PostgreSQL Datab... (Sub-part 1/3)
---
# Workflow: Supabase Integration (flutter_bloc) (Part 4/8)

> **Navigation:** This workflow is split into 8 parts.

## Deliverables

### 3. PostgreSQL Database Operations (flutter_bloc)

**Description:** CRUD operations dengan Supabase PostgreSQL, Row Level Security, dan `ProductBloc` event-driven. State menyertakan data list, pagination info, dan loading/error status.

**Recommended Skills:** `senior-flutter-developer`, `senior-supabase-developer`, `senior-database-engineer-sql`

**Instructions:**
1. **Database Schema:**
   - Design tables di Supabase Dashboard
   - Setup relationships
   - Configure indexes

2. **RLS Policies:**
   - Enable RLS per table
   - Create policies untuk read/write
   - Authenticated vs Anonymous access

3. **Data Source (Framework-Agnostic):**
   - Class ini SAMA dengan versi Riverpod/GetX — tidak bergantung pada state management

4. **Bloc (flutter_bloc-Specific):**
   - Sealed `ProductEvent` classes per operasi CRUD
   - Single `ProductState` class dengan copyWith untuk data + loading + error + pagination
   - Atau sealed states — pilih sesuai preferensi tim
   - Di-register via `@Injectable()` + `get_it`

**Output Format:**
```dart
// ============================================================
// DATA SOURCE — Framework-agnostic, sama dengan versi Riverpod/GetX
// ============================================================

// features/product/data/datasources/product_supabase_ds.dart
import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/product_model.dart';

@lazySingleton
class ProductSupabaseDataSource {
  final SupabaseClient _supabase;

  ProductSupabaseDataSource(this._supabase);

  SupabaseQueryBuilder get _productsTable =>
      _supabase.from('products');

  Future<List<ProductModel>> getProducts() async {
    final response = await _productsTable
        .select()
        .order('created_at', ascending: false);

    return (response as List)
        .map((json) => ProductModel.fromJson(json))
        .toList();
  }

  Future<ProductModel> getProductById(String id) async {
    final response = await _productsTable
        .select()
        .eq('id', id)
        .single();

    return ProductModel.fromJson(response);
  }

  Future<ProductModel> createProduct(ProductModel product) async {
    final response = await _productsTable
        .insert({
          'name': product.name,
          'price': product.price,
          'description': product.description,
          'user_id': _supabase.auth.currentUser!.id,
        })
        .select()
        .single();

    return ProductModel.fromJson(response);
  }

  Future<ProductModel> updateProduct(ProductModel product) async {
    final response = await _productsTable
        .update({
          'name': product.name,
          'price': product.price,
          'description': product.description,
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', product.id)
        .select()
        .single();

    return ProductModel.fromJson(response);
  }

  Future<void> deleteProduct(String id) async {
    await _productsTable.delete().eq('id', id);
  }

  // Advanced queries
  Future<List<ProductModel>> searchProducts(String query) async {
    final response = await _productsTable
        .select()
        .ilike('name', '%$query%')
        .order('created_at', ascending: false);

    return (response as List)
        .map((json) => ProductModel.fromJson(json))
        .toList();
  }

  Future<List<ProductModel>> getProductsWithPagination({
    required int page,
    required int limit,
  }) async {
    final response = await _productsTable
        .select()
        .range((page - 1) * limit, page * limit - 1)
        .order('created_at', ascending: false);

    return (response as List)
        .map((json) => ProductModel.fromJson(json))
        .toList();
  }

  // Join dengan table lain
  Future<List<Map<String, dynamic>>> getProductsWithUser() async {
    final response = await _productsTable
        .select('*, users(*)')
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }
}

// ============================================================
// PRODUCT MODEL
// ============================================================

// features/product/data/models/product_model.dart
import 'package:equatable/equatable.dart';

class ProductModel extends Equatable {
  final String id;
  final String name;
  final double price;
  final String? description;
  final String userId;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const ProductModel({
    required this.id,
    required this.name,
    required this.price,
    this.description,
    required this.userId,
    required this.createdAt,
    this.updatedAt,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] as String,
      name: json['name'] as String,
      price: (json['price'] as num).toDouble(),
      description: json['description'] as String?,
      userId: json['user_id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'price': price,
        'description': description,
        'user_id': userId,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt?.toIso8601String(),
      };

  @override
  List<Object?> get props =>
      [id, name, price, description, userId, createdAt, updatedAt];
}

// ============================================================
// PRODUCT EVENTS — Sealed classes per operasi CRUD
// ============================================================

// features/product/presentation/bloc/product_event.dart
import 'package:equatable/equatable.dart';
import '../../data/models/product_model.dart';

sealed class ProductEvent extends Equatable {
  const ProductEvent();

  @override
  List<Object?> get props => [];
}

/// Fetch semua produk
class FetchProducts extends ProductEvent {}

/// Fetch dengan pagination (load more)
class FetchProductsPaginated extends ProductEvent {
  final bool refresh;

  const FetchProductsPaginated({this.refresh = false});

  @override
  List<Object?> get props => [refresh];
}

/// Search produk berdasarkan query
class SearchProducts extends ProductEvent {
  final String query;

  const SearchProducts({required this.query});

  @override
  List<Object?> get props => [query];
}

/// Fetch single product by ID
class FetchProductById extends ProductEvent {
  final String id;

  const FetchProductById({required this.id});

  @override
  List<Object?> get props => [id];
}

/// Create product baru
class CreateProduct extends ProductEvent {
  final ProductModel product;

  const CreateProduct({required this.product});

  @override
  List<Object?> get props => [product];
}

/// Update existing product
class UpdateProduct extends ProductEvent {
  final ProductModel product;

  const UpdateProduct({required this.product});

  @override
  List<Object?> get props => [product];
}

/// Delete product by ID
class DeleteProduct extends ProductEvent {
  final String id;

  const DeleteProduct({required this.id});

  @override
  List<Object?> get props => [id];
}

// ============================================================
// PRODUCT STATE — Single class dengan copyWith
// Menyertakan data, pagination info, loading, dan error
// ============================================================

// features/product/presentation/bloc/product_state.dart
import 'package:equatable/equatable.dart';
import '../../data/models/product_model.dart';

enum ProductStatus { initial, loading, loaded, error }

class ProductState extends Equatable {
  final List<ProductModel> products;
  final ProductModel? selectedProduct;
  final ProductStatus status;
  final String? errorMessage;
  final int currentPage;
  final bool hasMore;
  final String searchQuery;

  const ProductState({
    this.products = const [],
    this.selectedProduct,
    this.status = ProductStatus.initial,
    this.errorMessage,
    this.currentPage = 1,
    this.hasMore = true,
    this.searchQuery = '',
  });

  ProductState copyWith({
    List<ProductModel>? products,
    ProductModel? selectedProduct,
    ProductStatus? status,
    String? errorMessage,
    int? currentPage,
    bool? hasMore,
    String? searchQuery,
  }) {
    return ProductState(
      products: products ?? this.products,
      selectedProduct: selectedProduct ?? this.selectedProduct,
      status: status ?? this.status,
      errorMessage: errorMessage,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  @override
  List<Object?> get props => [
        products,
        selectedProduct,
        status,
        errorMessage,
        currentPage,
        hasMore,
        searchQuery,
      ];
}

// ============================================================
// PRODUCT BLOC — Event-driven CRUD
// ============================================================

// features/product/presentation/bloc/product_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../data/datasources/product_supabase_ds.dart';
import 'product_event.dart';
import 'product_state.dart';

@injectable
class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final ProductSupabaseDataSource _dataSource;
  static const int _pageSize = 20;

  ProductBloc(this._dataSource) : super(const ProductState()) {
    on<FetchProducts>(_onFetchProducts);
    on<FetchProductsPaginated>(_onFetchProductsPaginated);
    on<SearchProducts>(_onSearchProducts);
    on<FetchProductById>(_onFetchProductById);
    on<CreateProduct>(_onCreateProduct);
    on<UpdateProduct>(_onUpdateProduct);
    on<DeleteProduct>(_onDeleteProduct);
  }
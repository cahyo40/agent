---
description: Implementasi repository pattern dengan REST API menggunakan Dio. (Part 6/7)
---
# Workflow: Backend Integration (REST API) - GetX (Part 6/7)

> **Navigation:** This workflow is split into 7 parts.

## Deliverables

### 5. API Response Wrapper

Framework-agnostic — sama dengan versi Riverpod. Digunakan untuk standarisasi parsing response.

#### 5.1 ApiResponse (Single Object)

**File:** `lib/core/models/api_response.dart`

```dart
class ApiResponse<T> {
  final bool success;
  final String? message;
  final T data;
  final Map<String, dynamic>? meta;

  const ApiResponse({
    required this.success,
    this.message,
    required this.data,
    this.meta,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) {
    return ApiResponse<T>(
      success: json['success'] as bool? ?? true,
      message: json['message'] as String?,
      data: fromJsonT(json['data']),
      meta: json['meta'] as Map<String, dynamic>?,
    );
  }
}
```

#### 5.2 PaginatedResponse

**File:** `lib/core/models/paginated_response.dart`

```dart
class PaginatedResponse<T> {
  final List<T> data;
  final int currentPage;
  final int lastPage;
  final int total;
  final int perPage;

  const PaginatedResponse({
    required this.data,
    required this.currentPage,
    required this.lastPage,
    required this.total,
    required this.perPage,
  });

  bool get hasNextPage => currentPage < lastPage;

  factory PaginatedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) {
    // Support format Laravel pagination
    final rawData = json['data'] as List? ?? [];
    final meta = json['meta'] as Map<String, dynamic>?;

    return PaginatedResponse<T>(
      data: rawData.map((e) => fromJsonT(e)).toList(),
      currentPage: meta?['current_page'] as int? ??
          json['current_page'] as int? ??
          1,
      lastPage:
          meta?['last_page'] as int? ?? json['last_page'] as int? ?? 1,
      total: meta?['total'] as int? ?? json['total'] as int? ?? 0,
      perPage:
          meta?['per_page'] as int? ?? json['per_page'] as int? ?? 20,
    );
  }
}
```

#### 5.3 Product Model (Contoh)

**File:** `lib/features/product/data/models/product_model.dart`

```dart
class ProductModel {
  final String id;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final String category;
  final int stock;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ProductModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.category,
    required this.stock,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      price: (json['price'] as num).toDouble(),
      imageUrl: json['image_url'] as String? ?? '',
      category: json['category'] as String? ?? '',
      stock: json['stock'] as int? ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'image_url': imageUrl,
      'category': category,
      'stock': stock,
    };
  }

  ProductModel copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    String? imageUrl,
    String? category,
    int? stock,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ProductModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
      category: category ?? this.category,
      stock: stock ?? this.stock,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
```

---


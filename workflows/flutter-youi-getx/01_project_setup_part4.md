---
description: Setup Flutter project dari nol dengan Clean Architecture, GetX, dan YoUI. (Part 4/5)
---
# Workflow: Flutter Project Setup with GetX + YoUI (Part 4/5)

> **Navigation:** This workflow is split into 5 parts.

## Deliverables

### 5. YoUI Theme Customization

**Description:** Kustomisasi YoUI theme sesuai kebutuhan project.

**Recommended Skills:** `senior-flutter-developer`, `senior-ui-ux-designer`

**Instructions:**
YoUI menyediakan 36 color schemes siap pakai. Pilih salah satu atau buat custom.

**Output Format:**
```dart
// lib/core/theme/app_theme.dart
import 'package:flutter/material.dart';
import 'package:yo_ui/yo_ui.dart';

/// YoUI theme wrapper untuk app.
///
/// YoUI menyediakan 36 preset color schemes.
/// Gunakan langsung atau buat custom.
class AppTheme {
  /// Light theme menggunakan YoUI.
  static ThemeData lightTheme(BuildContext context) {
    return YoTheme.lightTheme(context);
    
    // Atau dengan custom color scheme:
    // return YoTheme.lightTheme(
    //   context,
    //   YoColorScheme.techPurple,
    // );
  }
  
  /// Dark theme menggunakan YoUI.
  static ThemeData darkTheme(BuildContext context) {
    return YoTheme.darkTheme(context);
    
    // Atau dengan custom color scheme:
    // return YoTheme.darkTheme(
    //   context,
    //   YoColorScheme.techPurple,
    // );
  }
}

// Available YoUI Color Schemes (36):
// YoColorScheme.techPurple
// YoColorScheme.oceanBlue
// YoColorScheme.forestGreen
// YoColorScheme.sunsetOrange
// ... dan 32 lainnya
```

---

## Deliverables

### 6. Product Detail View dengan YoUI

**Description:** Detail view menggunakan YoUI components.

**Output Format:**
```dart
// lib/features/products/views/product_detail_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yo_ui/yo_ui.dart';
import '../controllers/product_controller.dart';

class ProductDetailView
    extends GetView<ProductController> {
  const ProductDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    final productId = Get.parameters['id'] ?? '';
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Detail'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              // Navigate to edit
            },
          ),
        ],
      ),
      body: Obx(() {
        final product =
            controller.selectedProduct.value;
        
        if (product == null) {
          return Center(
            child: YoText.bodyMedium(
              'Product not found',
            ),
          );
        }
        
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              YoCard(
                child: Padding(
                  padding:
                      const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      YoText.headlineMedium(
                        product.name,
                      ),
                      const SizedBox(height: 8),
                      YoText.titleLarge(
                        '\$${product.price}',
                      ),
                      if (product.description !=
                          null) ...[
                        const SizedBox(height: 16),
                        YoText.bodyMedium(
                          product.description!,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: YoButton.outline(
                      text: 'Edit',
                      onPressed: () {
                        // Navigate to edit
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: YoButton.primary(
                      text: 'Delete',
                      onPressed: () {
                        controller.deleteProduct(
                          product.id,
                        );
                        Get.back();
                        YoToast.success(
                          context: context,
                          message:
                              'Product deleted',
                        );
                      },
                      backgroundColor:
                          Theme.of(context)
                              .colorScheme
                              .error,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      }),
    );
  }
}
```

---

## Deliverables

### 7. Product Create Form dengan YoUI

**Description:** Form create product dengan YoUI components.

**Output Format:**
```dart
// lib/features/products/views/product_create_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yo_ui/yo_ui.dart';
import '../controllers/product_controller.dart';

class ProductCreateView
    extends GetView<ProductController> {
  const ProductCreateView({super.key});

  @override
  Widget build(BuildContext context) {
    final nameController = TextEditingController();
    final priceController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Product'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: formKey,
          child: Column(
            children: [
              YoCard(
                child: Padding(
                  padding:
                      const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      TextFormField(
                        controller:
                            nameController,
                        decoration:
                            const InputDecoration(
                          labelText:
                              'Product Name',
                          hintText:
                              'Enter product name',
                        ),
                        validator: (value) {
                          if (value == null ||
                              value.isEmpty) {
                            return 'Name is required';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller:
                            priceController,
                        decoration:
                            const InputDecoration(
                          labelText: 'Price',
                          hintText:
                              'Enter price',
                          prefixText: '\$ ',
                        ),
                        keyboardType:
                            TextInputType.number,
                        validator: (value) {
                          if (value == null ||
                              value.isEmpty) {
                            return 'Price is required';
                          }
                          if (double.tryParse(
                                  value) ==
                              null) {
                            return 'Invalid price';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Obx(
                () => YoButton.primary(
                  text: controller.isLoading.value
                      ? 'Creating...'
                      : 'Create Product',
                  onPressed:
                      controller.isLoading.value
                          ? null
                          : () {
                              if (formKey
                                  .currentState!
                                  .validate()) {
                                controller
                                    .createProduct(
                                  nameController
                                      .text,
                                  double.parse(
                                    priceController
                                        .text,
                                  ),
                                );
                                YoToast.success(
                                  context:
                                      context,
                                  message:
                                      'Product created!',
                                );
                              }
                            },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

---

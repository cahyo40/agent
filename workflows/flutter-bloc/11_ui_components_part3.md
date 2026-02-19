---
description: Library widget reusable yang konsisten: AppButton, AppTextField, AppCard, shimmer, empty state, error widget. Semua w... (Part 3/4)
---
# 11 - UI Components (Reusable Widget Library) (Part 3/4)

> **Navigation:** This workflow is split into 4 parts.

## Deliverables

### 5. BlocBuilder Integration Pattern

```dart
// ✅ Use AppErrorWidget + ShimmerList with BlocBuilder
BlocBuilder<ProductListBloc, ProductListState>(
  builder: (context, state) {
    return switch (state.status) {
      ProductListStatus.loading => const ShimmerList(),
      ProductListStatus.failure => AppErrorWidget(
          message: state.errorMessage ?? 'Unknown error',
          onRetry: () => context.read<ProductListBloc>().add(const FetchProducts()),
        ),
      ProductListStatus.success when state.products.isEmpty =>
        const EmptyStateWidget(
          icon: Icons.inventory_2_outlined,
          title: 'No Products',
          description: 'No products found.',
        ),
      _ => ListView.builder(
          itemCount: state.products.length,
          itemBuilder: (_, i) => ProductCard(product: state.products[i]),
        ),
    };
  },
);
```

---


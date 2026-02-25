# YoUI Feedback Components

## YoLoading

```dart
// Simple (digunakan otomatis di generated pages)
const YoLoading()

// With message
YoLoading(message: 'Loading data...')
```

## YoErrorState

```dart
// Digunakan otomatis di generated pages
YoErrorState(
  message: 'Failed to load data',
  onRetry: () => refresh(),
)

// Custom icon
YoErrorState(
  icon: Icons.wifi_off,
  message: 'No internet connection',
  onRetry: () => retry(),
)
```

## YoEmptyState

```dart
YoEmptyState(
  message: 'No items found',
  icon: Icons.inbox,
  actionLabel: 'Add Item',
  onAction: () => addItem(),
)
```

## YoToast

```dart
YoToast.success(context: context, message: 'Saved!')
YoToast.error(context: context, message: 'Failed!')
YoToast.info(context: context, message: 'Info message')
YoToast.warning(context: context, message: 'Warning!')
```

## YoShimmer

```dart
// Skeleton loading (gunakan ini daripada CircularProgressIndicator)
YoShimmer.card(height: 120)
YoShimmer.listTile()
YoShimmer.image(height: 200)
YoShimmer.text(width: 150)

// Custom shimmer
YoShimmer(
  child: Container(height: 100, width: double.infinity),
)
```

## YoSkeleton

```dart
YoSkeletonCard(count: 3)
YoSkeletonGrid(columns: 2, count: 4)
YoSkeletonListTile(count: 5)
```

## YoConfirmDialog

```dart
// Digunakan otomatis di generated dialogs
YoConfirmDialog(
  title: 'Delete Item?',
  content: YoText('This action cannot be undone'),
  confirmLabel: 'Delete',
  cancelLabel: 'Cancel',
  isDestructive: true,
  onConfirm: () => deleteItem(),
  onCancel: () => Navigator.pop(context),
)
```

## YoDialog

```dart
YoDialog.show(
  context: context,
  title: 'Custom Dialog',
  content: YoText('Dialog content here'),
  actions: [
    YoButton.ghost(text: 'Cancel', onPressed: () => Navigator.pop(context)),
    YoButton.primary(text: 'OK', onPressed: () => confirm()),
  ],
)
```

## YoBottomSheet

```dart
YoBottomSheet.show(
  context: context,
  title: 'Options',
  child: Column(
    children: [
      ListTile(title: Text('Option 1'), onTap: () {}),
      ListTile(title: Text('Option 2'), onTap: () {}),
    ],
  ),
)
```

## YoModal

```dart
YoModal.show(
  context: context,
  title: 'Modal Title',
  height: 0.8,
  child: ModalContent(),
)
```

## YoBanner

```dart
YoBanner(
  message: 'New update available!',
  type: YoBannerType.info,    // info, success, warning, error
  dismissible: true,
  action: YoButton.ghost(text: 'Update', onPressed: () {}),
)
```

## YoSnackbar

```dart
YoSnackbar.show(
  context: context,
  message: 'Item deleted',
  action: SnackBarAction(label: 'Undo', onPressed: () => undo()),
)
```

## YoProgress

```dart
YoProgress(value: 0.75, label: '75%')
YoProgress.linear(value: 0.5)
YoProgress.circular(value: 0.8)
```

## YoLoadingOverlay

```dart
YoLoadingOverlay(
  isLoading: isSubmitting,
  message: 'Submitting...',
  child: FormContent(),
)
```

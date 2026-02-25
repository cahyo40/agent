# YoUI Basic Components

## YoButton

```dart
// Variants
YoButton.primary(text: 'Submit', onPressed: () {})
YoButton.secondary(text: 'Cancel', onPressed: () {})
YoButton.outline(text: 'Details', onPressed: () {})
YoButton.ghost(text: 'Skip', onPressed: () {})
YoButton.pill(text: 'Tag', onPressed: () {})
YoButton.modern(text: 'Action', onPressed: () {})

// With icon
YoButton.primary(
  text: 'Save',
  icon: Icons.save,
  onPressed: () {},
)

// Loading state
YoButton.primary(
  text: 'Submit',
  isLoading: true,
  onPressed: null,
)
```

## YoCard

```dart
YoCard(
  child: Column(
    children: [
      YoText.heading('Card Title'),
      YoText('Card content here'),
    ],
  ),
)
```

## YoScaffold

```dart
// Digunakan otomatis di generated pages
YoScaffold(
  appBar: AppBar(title: YoText.heading('Title')),
  body: content,
  floatingActionButton: YoFAB(
    onPressed: () {},
    icon: Icons.add,
  ),
)
```

## YoImage

```dart
// Network image dengan cache
YoImage.network(
  url: 'https://example.com/image.jpg',
  width: 200,
  height: 200,
  fit: BoxFit.cover,
)

// Asset image
YoImage.asset(
  path: 'assets/images/logo.png',
  width: 100,
)

// Circular avatar
YoImage.circle(
  url: 'https://example.com/avatar.jpg',
  radius: 40,
)
```

## YoFAB (Floating Action Button)

```dart
YoFAB(
  onPressed: () {},
  icon: Icons.add,
  label: 'Add Item',
)
```

## YoIconButton

```dart
YoIconButton(
  icon: Icons.delete,
  onPressed: () {},
  color: Colors.red,
)
```

## YoDivider

```dart
const YoDivider()
const YoDivider.thick()
const YoDivider.dashed()
```

## YoColumn & YoRow

```dart
// Otomatis spacing
YoColumn(
  spacing: 16,
  children: [Widget1(), Widget2(), Widget3()],
)

YoRow(
  spacing: 8,
  children: [Widget1(), Widget2()],
)
```

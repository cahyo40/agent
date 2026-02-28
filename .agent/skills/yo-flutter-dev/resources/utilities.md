# YoUI Utilities & Helpers

## YoDateFormatter

```dart
YoDateFormatter.formatDate(DateTime.now())         // '07 Dec 2024'
YoDateFormatter.formatDateTime(DateTime.now())     // '07 Dec 2024, 14:30'
YoDateFormatter.formatRelativeTime(date)           // '2 hours ago'
YoDateFormatter.formatTimeAgo(date)                // 'Just now' / '5m ago'
YoDateFormatter.isToday(date)                      // true/false
YoDateFormatter.isYesterday(date)                  // true/false
```

## YoIdGenerator

```dart
YoIdGenerator.uuid()                   // UUID v4: '550e8400-e29b...'
YoIdGenerator.numericId(length: 8)     // '12345678'
YoIdGenerator.alphanumericId(length: 10) // 'aB3xY8pQ2r'
YoIdGenerator.userId()                 // 'USR_aB3xY8pQ'
YoIdGenerator.orderId()                // 'ORD_12345678'
```

## YoConnectivity

```dart
// Initialize di main.dart
await YoConnectivity.initialize();

// Cek status
bool isOnline = YoConnectivity.isConnected;

// Listen perubahan
YoConnectivity.addListener((connected) {
  if (!connected) {
    YoToast.warning(context: context, message: 'Offline');
  }
});

// Dispose
YoConnectivity.dispose();
```

## YoLogger

```dart
YoLogger.debug('Debug message');
YoLogger.info('Info message');
YoLogger.warning('Warning message');
YoLogger.error('Error message', error: e, stackTrace: s);
```

## Text Input Formatters

```dart
// Currency
CurrencyTextInputFormatter()         // 1000000 -> 1.000.000
IndonesiaCurrencyFormatter()         // 1000000 -> Rp 1.000.000

// Phone
PhoneNumberFormatter()               // 081234567890 -> 0812-3456-7890
IndonesiaPhoneFormatter()            // 6281234567890 -> +62 812 3456 7890

// Card
CreditCardFormatter()                // 1234567890123456 -> 1234 5678 9012 3456
```

## Extensions

### Context Extensions

```dart
// Theme shortcuts
context.theme         // ThemeData
context.colorScheme   // ColorScheme
context.textTheme     // TextTheme

// Media query
context.screenWidth
context.screenHeight
context.isSmallScreen  // < 600
context.isMediumScreen // 600-900
context.isLargeScreen  // > 900
```

### Color Extensions

```dart
Colors.blue.lighten(0.2)    // lighter shade
Colors.blue.darken(0.2)     // darker shade
Colors.blue.withOpacity(0.5)
```

### Device Extensions

```dart
context.isAndroid
context.isIOS
context.isMobile
context.isTablet
context.isDesktop
```

## Layout

### YoResponsive

```dart
YoResponsive(
  mobile: MobileLayout(),
  tablet: TabletLayout(),
  desktop: DesktopLayout(),
)
```

### YoAdaptive

```dart
YoAdaptive(
  breakpoint: 600,
  below: CompactView(),
  above: ExpandedView(),
)
```

### YoSpacing (Design Tokens)

Gunakan YoSpacing untuk nilai token mentah atau `context` extensions.

| Name | Spacing | Target |
|------|---------|--------|
| `xs` | 4.0 | Small elements |
| `sm` | 8.0 | Inner padding |
| `md` | 16.0 | Component spacing |
| `lg` | 24.0 | Page margins |
| `xl` | 32.0 | Section spacing |
| `xxl`| 48.0 | Large sections |

```dart
// Spacing values
padding: EdgeInsets.all(YoSpacing.md),

// Radius values
radius: YoSpacing.radiusMd,

// BorderRadius objects
borderRadius: YoSpacing.borderRadiusMd,
```

### YoPadding

```dart
YoPadding.all(child: widget)     // 16 all
YoPadding.horizontal(child: w)   // 16 horizontal
YoPadding.vertical(child: w)     // 16 vertical
YoPadding.page(child: w)         // standard page padding
```

### YoSpace

Gunakan `YoSpace` alih-alih `SizedBox` untuk mempertahankan konsistensi layout.

```dart
// Fixed Height (Standard)
const YoSpace.xs()   // 4
const YoSpace.sm()   // 8
const YoSpace.md()   // 16
const YoSpace.lg()   // 24
const YoSpace.xl()   // 32

// Custom Height/Width
const YoSpace.height(12)
const YoSpace.width(20)

// Responsive height (berbeda di mobile/desktop)
YoSpace.adaptiveHeight(16)
```

## Picker Components

```dart
YoDatePicker.show(context: context, onDateSelected: (date) {})
YoTimePicker.show(context: context, onTimeSelected: (time) {})
YoDateTimePicker.show(context: context, onSelected: (dt) {})
YoDateRangePicker.show(context: context, onRangeSelected: (range) {})
YoMonthPicker.show(context: context, onSelected: (month) {})
YoYearPicker.show(context: context, onSelected: (year) {})
YoColorPicker.show(context: context, onColorSelected: (color) {})
YoIconPicker.show(context: context, onIconSelected: (icon) {})
YoImagePicker.show(context: context, onImageSelected: (file) {})
YoFilePicker.show(context: context, onFileSelected: (file) {})
```

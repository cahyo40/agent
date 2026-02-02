---
name: yo-flutter-dev
description: "Expert Flutter development menggunakan yo.dart generator dan YoUI component library untuk Clean Architecture dengan Riverpod, BLoC, atau GetX"
---

# yo-flutter-dev

## Overview

Skill khusus untuk pengembangan Flutter menggunakan dua library proprietari:

- **yo.dart (flutter-generator)** - Code generator untuk Clean Architecture
- **yo_ui (youi)** - UI Component Library dengan 90+ komponen siap pakai

Skill ini memastikan konsistensi arsitektur dan mencegah hallusinasi AI dengan aturan ketat berbasis dokumentasi resmi.

## When to Use This Skill

- Memulai project Flutter baru dengan Clean Architecture
- Mengintegrasikan generator ke project yang sudah ada
- Generate fitur baru (page, model, controller, dll)
- Menggunakan komponen UI dari YoUI
- Membutuhkan panduan setup dan konfigurasi yo.yaml

---

## ⚠️ ANTI-HALLUCINATION RULES

> [!CAUTION]
> **WAJIB DIPATUHI untuk mencegah kode yang tidak akurat**

### Rule 1: BACA yo.yaml TERLEBIH DAHULU

```yaml
# Cek file yo.yaml di root project
# JANGAN generate apapun sebelum membaca ini
state_management: riverpod  # riverpod | bloc | getx
project_name: my_app
```

### Rule 2: JANGAN MENGARANG KOMPONEN

- ❌ JANGAN buat nama komponen YoUI yang tidak ada
- ✅ GUNAKAN hanya komponen yang terdokumentasi di bawah
- ✅ Jika ragu, cek repository youi terlebih dahulu

### Rule 3: GUNAKAN GENERATOR, BUKAN MANUAL

```bash
# ❌ JANGAN tulis manual jika generator tersedia
# ✅ SELALU gunakan generator
dart run yo.dart page:auth.login
dart run yo.dart model:user --feature=auth
```

### Rule 4: VERIFIKASI OUTPUT

- Setelah generate, BACA file yang dihasilkan
- Cari marker `// TODO` sebagai panduan implementasi
- JANGAN lanjut sebelum memahami struktur

### Rule 5: JANGAN MIX STATE MANAGEMENT

- Jika yo.yaml = riverpod, HANYA gunakan Riverpod
- Jika yo.yaml = bloc, HANYA gunakan BLoC
- Jika yo.yaml = getx, HANYA gunakan GetX

### Rule 6: GUNAKAN DOKUMENTASI LOKAL

- Cek guide.md di folder youi jika tersedia
- Cek COMPONENTS.md untuk referensi komponen
- Jangan generate API yang tidak terdokumentasi

---

## How It Works

### Skenario A: Project Baru (Folder Kosong)

```bash
# STEP 1: Clone generator
git clone https://github.com/cahyo40/flutter-generator.git
cd flutter-generator
dart pub get

# STEP 2: Buat project Flutter baru
flutter create my_app
cd my_app

# STEP 3: Copy generator ke project
cp ../flutter-generator/yo.dart .
cp -r ../flutter-generator/lib/generators ./lib/

# STEP 4: Inisialisasi dengan state management
# Pilih salah satu:
dart run yo.dart init --state=riverpod  # ✨ Recommended
dart run yo.dart init --state=bloc
dart run yo.dart init --state=getx

# STEP 5: Tambah YoUI di pubspec.yaml
```

**pubspec.yaml:**

```yaml
dependencies:
  flutter:
    sdk: flutter
  yo_ui:
    git:
      url: https://github.com/cahyo40/youi.git
      ref: main
```

```bash
# STEP 6: Install dependencies
flutter pub get

# STEP 7: Apply YoUI Theme di main.dart
```

**lib/main.dart:**

```dart
import 'package:flutter/material.dart';
import 'package:yo_ui/yo_ui.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: YoTheme.lightTheme(context),
      darkTheme: YoTheme.darkTheme(context),
      themeMode: ThemeMode.system,
      home: const HomeScreen(),
    );
  }
}
```

---

### Skenario B: Project yang Sudah Ada

```bash
# STEP 1: Clone generator ke folder temporary
git clone https://github.com/cahyo40/flutter-generator.git .yo-generator

# STEP 2: Copy file generator ke project
cp .yo-generator/yo.dart .
cp -r .yo-generator/lib/generators ./lib/

# STEP 3: Bersihkan temporary folder
rm -rf .yo-generator

# STEP 4: Cek apakah sudah ada yo.yaml
# Jika BELUM ada, jalankan init:
dart run yo.dart init --state=riverpod

# STEP 5: Tambah YoUI dependency jika belum
# Edit pubspec.yaml dan tambah yo_ui

# STEP 6: Jalankan pub get
flutter pub get
```

---

## Generator Commands Reference

### Core Commands

| Command | Description | Example |
|---------|-------------|---------|
| `init` | Inisialisasi project | `dart run yo.dart init --state=riverpod` |
| `page` | Generate full clean architecture | `dart run yo.dart page:home` |
| `page` (sub) | Generate dengan dot notation | `dart run yo.dart page:auth.login` |
| `page` (ui only) | Presentation layer saja | `dart run yo.dart page:splash --presentation-only` |

### Model & Entity

| Command | Description | Example |
|---------|-------------|---------|
| `model` | Generate model class | `dart run yo.dart model:user` |
| `model` (freezed) | Generate dengan freezed | `dart run yo.dart model:user --freezed` |
| `model` (feature) | Generate di feature tertentu | `dart run yo.dart model:user --feature=auth` |
| `entity` | Generate entity class | `dart run yo.dart entity:user --feature=auth` |

### State Management

| Command | Description | Example |
|---------|-------------|---------|
| `controller` | Generate controller (sesuai yo.yaml) | `dart run yo.dart controller:auth` |
| `controller` (cubit) | Generate cubit (bloc only) | `dart run yo.dart controller:auth --cubit` |

### Data Layer

| Command | Description | Example |
|---------|-------------|---------|
| `datasource` | Generate datasource | `dart run yo.dart datasource:auth --remote` |
| `datasource` | Local datasource | `dart run yo.dart datasource:auth --local` |
| `datasource` | Both | `dart run yo.dart datasource:auth --both` |
| `repository` | Generate repository | `dart run yo.dart repository:auth --feature=auth` |
| `usecase` | Generate use case | `dart run yo.dart usecase:login --feature=auth` |

### Infrastructure

| Command | Description | Example |
|---------|-------------|---------|
| `network` | Generate Dio client + interceptors | `dart run yo.dart network` |
| `di` | Generate dependency injection setup | `dart run yo.dart di` |

### UI Components

| Command | Description | Example |
|---------|-------------|---------|
| `screen` | Generate screen only | `dart run yo.dart screen:profile --feature=user` |
| `dialog` | Generate dialog | `dart run yo.dart dialog:confirm --feature=common` |
| `widget` | Generate widget | `dart run yo.dart widget:avatar --feature=user` |
| `widget` (global) | Generate global widget | `dart run yo.dart widget:avatar --global` |
| `service` | Generate service | `dart run yo.dart service:auth` |

### Utilities

| Command | Description | Example |
|---------|-------------|---------|
| `translation` | Add translation key | `dart run yo.dart translation --key=welcome --en="Welcome" --id="Selamat Datang"` |
| `package-name` | Change package name | `dart run yo.dart package-name:com.company.app` |
| `app-name` | Change app name | `dart run yo.dart app-name:"My App"` |
| `delete` | Delete feature/page | `dart run yo.dart delete:auth --delete-feature` |

### Flags

| Flag | Description |
|------|-------------|
| `--force` | Overwrite existing files |
| `--presentation-only` | Generate UI layer saja |
| `--freezed` | Gunakan freezed untuk model |
| `--feature=<name>` | Tentukan feature target |
| `--global` | Generate di folder global |
| `--cubit` | Generate cubit (bloc saja) |
| `--remote` / `--local` / `--both` | Tipe datasource |

---

## Clean Architecture Output

```
lib/
├── core/
│   ├── config/         # Router
│   ├── di/             # Dependency injection
│   ├── network/        # Dio + Interceptors
│   ├── themes/         # Material 3 Theme
│   └── widgets/        # Global widgets
├── features/
│   └── <feature>/
│       ├── data/
│       │   ├── datasources/
│       │   ├── models/
│       │   └── repositories/
│       ├── domain/
│       │   ├── entities/
│       │   ├── repositories/
│       │   └── usecases/
│       └── presentation/
│           ├── pages/
│           ├── providers/      # Riverpod
│           ├── controllers/    # GetX
│           └── bloc/           # Bloc
└── l10n/
```

---

## YoUI Component Reference

### Theme Setup

```dart
import 'package:yo_ui/yo_ui.dart';

MaterialApp(
  theme: YoTheme.lightTheme(context),
  darkTheme: YoTheme.darkTheme(context),
  // Atau dengan color scheme kustom:
  // theme: YoTheme.lightTheme(context, YoColorScheme.techPurple),
)
```

### Buttons

```dart
// Primary button
YoButton.primary(text: 'Submit', onPressed: () {})

// Secondary button
YoButton.secondary(text: 'Cancel', onPressed: () {})

// Outline button
YoButton.outline(text: 'Details', onPressed: () {})

// Ghost button
YoButton.ghost(text: 'Skip', onPressed: () {})

// Pill style
YoButton.pill(text: 'Tag', onPressed: () {})

// Modern style
YoButton.modern(text: 'Action', onPressed: () {})
```

### Text

```dart
YoText.headlineLarge('Title')
YoText.headlineMedium('Subtitle')
YoText.bodyMedium('Body text')
YoText.bodySmall('Caption')
```

### Form Components

```dart
// OTP Field
YoOtpField(
  length: 6,
  onCompleted: (pin) => verify(pin),
)

// Search Field
YoSearchField(
  hintText: 'Search...',
  suggestions: ['Item 1', 'Item 2'],
  onSearch: (query) => search(query),
)

// Chip Input
YoChipInput(
  chips: ['Tag1', 'Tag2'],
  suggestions: ['Tag3', 'Tag4'],
  maxChips: 5,
  onChanged: (chips) => update(chips),
)

// Range Slider
YoRangeSlider(
  values: RangeValues(20, 80),
  min: 0,
  max: 100,
  onChanged: (values) => filter(values),
)

// File Upload
YoFileUpload(
  maxFiles: 5,
  onFilesSelected: (files) => upload(files),
)
```

### Display Cards

```dart
// Product Card
YoProductCard(
  imageUrl: 'https://...',
  title: 'Product Name',
  price: 99.99,
  stock: 15,
)

// Profile Card
YoProfileCard.cover(
  avatarUrl: 'https://...',
  name: 'John Doe',
  stats: [YoProfileStat(value: '1.2K', label: 'Followers')],
)

// Article Card
YoArticleCard.featured(
  imageUrl: 'https://...',
  title: 'Article Title',
  category: 'Tech',
  readTime: 5,
)

// Destination Card
YoDestinationCard.featured(
  imageUrl: 'https://...',
  title: 'Bali',
  location: 'Indonesia',
  rating: 4.8,
  price: 1200,
)
```

### Navigation

```dart
// Stepper
YoStepper(
  currentStep: 0,
  type: YoStepperType.vertical,
  steps: [
    YoStep(title: 'Step 1', content: Widget1()),
    YoStep(title: 'Step 2', content: Widget2()),
  ],
  onStepContinue: () => nextStep(),
)

// Pagination
YoPagination(
  currentPage: 1,
  totalPages: 10,
  onPageChanged: (page) => loadPage(page),
)

// Breadcrumb
YoBreadcrumb(
  items: [
    YoBreadcrumbItem(label: 'Home', onTap: () => goHome()),
    YoBreadcrumbItem(label: 'Products'),
  ],
)
```

### Feedback & Display

```dart
// Toast
YoToast.success(context: context, message: 'Success!')
YoToast.error(context: context, message: 'Error!')
YoToast.info(context: context, message: 'Info')

// Shimmer Loading
YoShimmer.card(height: 120)
YoShimmer.listTile()
YoShimmer.image(height: 200)

// Modal
YoModal.show(
  context: context,
  title: 'Modal Title',
  height: 0.8,
  child: ModalContent(),
)

// Banner
YoBanner(
  message: 'New update!',
  type: YoBannerType.info,
  dismissible: true,
)

// Carousel
YoCarousel(
  images: imageUrls,
  autoPlay: true,
  height: 200,
)

// Data Table
YoDataTable(
  columns: [
    YoDataColumn(label: 'Name'),
    YoDataColumn(label: 'Email'),
  ],
  rows: data.map((item) => YoDataRow(
    cells: [
      YoDataCell(text: item.name),
      YoDataCell(text: item.email),
    ],
  )).toList(),
)

// Masonry Grid
YoMasonryGrid(
  columns: 2,
  children: items.map((item) => ItemCard(item)).toList(),
)
```

### Utilities

```dart
// Date Formatting
YoDateFormatter.formatDate(DateTime.now())     // '07 Dec 2024'
YoDateFormatter.formatRelativeTime(date)       // '2 hours ago'
YoDateFormatter.isToday(date)                  // true/false

// ID Generation
YoIdGenerator.uuid()                           // UUID v4
YoIdGenerator.numericId(length: 8)             // '12345678'
YoIdGenerator.userId()                         // 'USR_aB3xY8pQ'

// Connectivity
await YoConnectivity.initialize();
bool isOnline = YoConnectivity.isConnected;
YoConnectivity.addListener((connected) { });

// Text Input Formatters
CurrencyTextInputFormatter()        // 1000000 -> 1.000.000
IndonesiaCurrencyFormatter()        // 1000000 -> Rp 1.000.000
PhoneNumberFormatter()              // 081234567890 -> 0812-3456-7890
IndonesiaPhoneFormatter()           // 6281234567890 -> +62 812 3456 7890
CreditCardFormatter()               // 1234567890123456 -> 1234 5678 9012 3456
```

---

## yo.yaml Configuration

File konfigurasi yang dibuat saat `init`:

```yaml
# yo.yaml - Konfigurasi generator
project_name: my_app
state_management: riverpod  # riverpod | bloc | getx
use_freezed: true
use_go_router: true
localization: 
  - en
  - id
```

---

## Workflow Example

**User Request:** "Buatkan fitur authentication dengan login dan register"

**AI Response:**

```bash
# 1. Generate page struktur
dart run yo.dart page:auth.login
dart run yo.dart page:auth.register

# 2. Generate models
dart run yo.dart model:user --feature=auth --freezed
dart run yo.dart model:auth.request --feature=auth

# 3. Generate datasource dan repository
dart run yo.dart datasource:auth --remote --feature=auth
dart run yo.dart repository:auth --feature=auth

# 4. Generate usecases
dart run yo.dart usecase:login --feature=auth
dart run yo.dart usecase:register --feature=auth
```

**Kemudian AI:**

1. Baca file yang di-generate
2. Cari marker `// TODO`
3. Implementasi logic di tempat yang tepat
4. Gunakan komponen YoUI untuk UI

---

## Best Practices

### ✅ Do This

- ✅ Selalu jalankan `dart run yo.dart init` di project baru
- ✅ Baca yo.yaml sebelum generate
- ✅ Gunakan generator untuk semua struktur
- ✅ Ikuti naming convention (dot notation)
- ✅ Gunakan komponen YoUI yang terdokumentasi
- ✅ Verifikasi output sebelum modifikasi

### ❌ Avoid This

- ❌ Jangan generate tanpa cek yo.yaml
- ❌ Jangan mengarang nama komponen
- ❌ Jangan tulis manual jika ada generator
- ❌ Jangan mix state management
- ❌ Jangan skip marker // TODO
- ❌ Jangan abaikan struktur Clean Architecture

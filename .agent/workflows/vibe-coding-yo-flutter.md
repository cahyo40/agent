---
description: Initialize Vibe Coding context files for Flutter with yo.dart generator and YoUI component library
---

# /vibe-coding-yo-flutter

Workflow untuk setup dokumen konteks Vibe Coding khusus **Flutter dengan yo.dart Generator** dan **YoUI Component Library**. Workflow ini menggunakan code generator untuk Clean Architecture dengan state management modern (Riverpod/BLoC/GetX).

---

## 📋 Prerequisites

Sebelum memulai, siapkan informasi berikut:

1. **Deskripsi ide aplikasi** (2-3 paragraf)
2. **Target platforms** (pilih satu atau lebih):
   - 📱 Mobile: iOS, Android
   - 🌐 Web: Chrome, Firefox, Safari, Edge
   - 🖥️ Desktop: macOS, Windows, Linux
3. **State management preference** (Riverpod/BLoC/GetX)
4. **Backend preference** (Firebase/Supabase/Custom API)
5. **Vibe/estetika** yang diinginkan
6. **Responsive strategy** (Mobile-first / Desktop-first / Adaptive)

---

## 🏗️ Phase 1: The Holy Trinity (WAJIB)

### Step 1.1: Generate PRD.md

```
Tanyakan kepada user:
"Jelaskan ide aplikasi Flutter yang ingin dibuat. Sertakan:
- Apa masalah yang diselesaikan?
- Siapa target penggunanya?
- Apa fitur utama yang diinginkan?
- Platform apa? (iOS/Android/Web/Desktop)"
```

Gunakan skill `senior-project-manager`:

```markdown
Act as senior-project-manager.
Saya ingin membuat aplikasi Flutter: [IDE USER]

Buatkan file `PRD.md` yang mencakup:
1. Executive Summary (2-3 kalimat)
2. Problem Statement
3. Target User & Persona
4. User Stories (min 10 untuk MVP, format: As a [role], I want to [action], so that [benefit])
5. Core Features - kategorikan: Must Have, Should Have, Could Have, Won't Have
6. User Flow per fitur utama
7. Platform Requirements (iOS version, Android version, Desktop OS, Web browsers)
8. Success Metrics (DAU, Retention Rate, Core Action Completion Rate)

Output dalam Markdown yang rapi.
```

// turbo
**Simpan output ke file `PRD.md` di root project.**

---

### Step 1.2: Generate TECH_STACK.md

```
Tanyakan kepada user:
"Pilih preferensi:
1. State Management: Riverpod / BLoC / GetX?
2. Backend: Firebase / Supabase / Custom REST API?
3. Local Storage: Hive / Drift / SharedPreferences?"
```

Gunakan skill `yo-flutter-dev` + `senior-flutter-developer`:

```markdown
Act as yo-flutter-dev dan senior-flutter-developer.
Buatkan file `TECH_STACK.md` untuk Flutter app dengan yo.dart generator.

## Core Stack
- Flutter Version: Latest Stable (3.x)
- Dart Version: Latest Stable (3.x)
- Generator: yo.dart (flutter-generator)
- UI Library: YoUI (youi)

## Platform Requirements
### Mobile
- Minimum iOS: 12.0
- Minimum Android: API 21 (5.0)

### Web
- Renderer: CanvasKit (untuk performa) / HTML (untuk SEO)
- Supported Browsers: Chrome 84+, Firefox 72+, Safari 14.1+, Edge 84+
- PWA Support: Ya (service worker, manifest)

### Desktop
- Minimum macOS: 10.14 (Mojave)
- Minimum Windows: Windows 10 (1803+)
- Minimum Linux: Ubuntu 18.04+ / equivalent

## State Management
- Package: [PILIHAN: flutter_riverpod / flutter_bloc / get]
- Alasan: [JELASKAN]
- Generator Support: Ya (via yo.dart)

## Architecture
- Pattern: Clean Architecture (via yo.dart generator)
- Layers: Presentation → Domain → Data
- Generator Commands: `dart run yo.dart page:feature.screen`

## Navigation
- Package: go_router (WAJIB)
- Alasan: Type-safe, deep linking support, Flutter team maintained

## Backend & Data
- Backend: [Firebase / Supabase / Custom]
- Auth: [firebase_auth / supabase_flutter / custom JWT]
- Database: [cloud_firestore / supabase / REST API]
- Local Storage: [hive_flutter / drift / shared_preferences]

## Networking
- HTTP Client: dio
- API Code Gen: retrofit (jika REST API)
- Generator: `dart run yo.dart network` (auto-generate Dio client)

## UI & Theming
- Design System: YoUI Component Library
- Theme: YoTheme.lightTheme() / YoTheme.darkTheme()
- Color Schemes: YoColorScheme (techPurple, oceanBlue, forestGreen, etc.)
- Icons: flutter_svg + YoUI icons
- Fonts: Google Fonts (google_fonts package)

## Code Generation
- yo.dart: Clean Architecture generator
- freezed: Immutable models
- json_serializable: JSON serialization
- build_runner: Code generation runner

## Utilities
- Date/Time: YoDateFormatter (dari YoUI)
- ID Generation: YoIdGenerator (dari YoUI)
- Connectivity: YoConnectivity (dari YoUI)
- Input Formatters: YoUI formatters (currency, phone, credit card)
- Validation: reactive_forms atau flutter_form_builder

## Testing
- Unit Test: flutter_test + mocktail
- Widget Test: flutter_test
- Integration Test: integration_test
- Coverage Target: 80%

## Code Quality
- Linting: flutter_lints (strict)
- Code Gen: build_runner, freezed, json_serializable

## Approved Packages (pubspec.yaml)
```yaml
dependencies:
  flutter:
    sdk: flutter
  
  # YoUI Component Library
  yo_ui:
    git:
      url: https://github.com/cahyo40/youi.git
      ref: main
  
  # State Management
  flutter_riverpod: ^2.4.0  # atau flutter_bloc / get
  
  # Navigation
  go_router: ^13.0.0
  
  # Networking
  dio: ^5.4.0
  retrofit: ^4.1.0
  
  # Local Storage
  hive_flutter: ^1.1.0
  shared_preferences: ^2.2.0
  
  # UI
  google_fonts: ^6.1.0
  flutter_svg: ^2.0.9
  cached_network_image: ^3.3.0
  
  # Responsive & Multi-Platform
  responsive_framework: ^1.1.0
  flutter_adaptive_scaffold: ^0.1.0
  universal_platform: ^1.0.0
  
  # Desktop-specific (conditional)
  window_manager: ^0.3.0
  desktop_drop: ^0.4.0
  
  # Web-specific
  url_strategy: ^0.2.0
  
  # Utils
  intl: ^0.18.1
  freezed_annotation: ^2.4.1
  json_annotation: ^4.8.1
  
dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.1
  build_runner: ^2.4.8
  freezed: ^2.4.6
  json_serializable: ^6.7.1
  retrofit_generator: ^8.1.0
  mocktail: ^1.0.1
```

## yo.dart Generator Setup

```yaml
# yo.yaml (auto-generated saat init)
project_name: my_app
state_management: riverpod  # riverpod | bloc | getx
use_freezed: true
use_go_router: true
localization: 
  - en
  - id
```

## Constraints

- Package di luar daftar DILARANG tanpa approval
- Semua dependency harus versi stable
- WAJIB null safety
- WAJIB gunakan yo.dart generator untuk struktur Clean Architecture
- WAJIB gunakan YoUI components untuk UI

```

// turbo
**Simpan output ke file `TECH_STACK.md` di root project.**

---

### Step 1.3: Generate RULES.md

Gunakan skill `yo-flutter-dev`:

```markdown
Act as yo-flutter-dev.
Buatkan file `RULES.md` sebagai panduan AI untuk Flutter project dengan yo.dart generator.

## ⚠️ ANTI-HALLUCINATION RULES

> [!CAUTION]
> **WAJIB DIPATUHI untuk mencegah kode yang tidak akurat**

### Rule 1: BACA yo.yaml TERLEBIH DAHULU

```yaml
# Cek file yo.yaml di root project
# JANGAN generate apapun sebelum membaca ini
state_management: riverpod  # riverpod | bloc | getx
project_name: my_app
use_freezed: true
use_go_router: true
```

### Rule 2: GUNAKAN GENERATOR, BUKAN MANUAL

```bash
# ❌ JANGAN tulis manual jika generator tersedia
# ✅ SELALU gunakan generator yo.dart

# Generate full clean architecture page
dart run yo.dart page:auth.login

# Generate model dengan freezed
dart run yo.dart model:user --feature=auth --freezed

# Generate datasource dan repository
dart run yo.dart datasource:auth --remote --feature=auth
dart run yo.dart repository:auth --feature=auth

# Generate usecase
dart run yo.dart usecase:login --feature=auth
```

### Rule 3: JANGAN MENGARANG KOMPONEN YoUI

- ❌ JANGAN buat nama komponen YoUI yang tidak ada
- ✅ GUNAKAN hanya komponen yang terdokumentasi
- ✅ Jika ragu, cek repository youi terlebih dahulu

**Komponen YoUI yang VALID:**

- Buttons: `YoButton.primary()`, `YoButton.secondary()`, `YoButton.outline()`, `YoButton.ghost()`, `YoButton.pill()`, `YoButton.modern()`
- Text: `YoText.headlineLarge()`, `YoText.headlineMedium()`, `YoText.bodyMedium()`, `YoText.bodySmall()`
- Forms: `YoOtpField()`, `YoSearchField()`, `YoChipInput()`, `YoRangeSlider()`, `YoFileUpload()`
- Cards: `YoProductCard()`, `YoProfileCard.cover()`, `YoArticleCard.featured()`, `YoDestinationCard.featured()`
- Navigation: `YoStepper()`, `YoPagination()`, `YoBreadcrumb()`
- Feedback: `YoToast.success()`, `YoShimmer.card()`, `YoModal.show()`, `YoBanner()`, `YoCarousel()`
- Data: `YoDataTable()`, `YoMasonryGrid()`
- Utils: `YoDateFormatter`, `YoIdGenerator`, `YoConnectivity`

### Rule 4: VERIFIKASI OUTPUT GENERATOR

- Setelah generate, BACA file yang dihasilkan
- Cari marker `// TODO` sebagai panduan implementasi
- JANGAN lanjut sebelum memahami struktur

### Rule 5: JANGAN MIX STATE MANAGEMENT

- Jika yo.yaml = riverpod, HANYA gunakan Riverpod
- Jika yo.yaml = bloc, HANYA gunakan BLoC
- Jika yo.yaml = getx, HANYA gunakan GetX

### Rule 6: IKUTI STRUKTUR CLEAN ARCHITECTURE

```
lib/
├── core/
│   ├── config/         # Router (go_router)
│   ├── di/             # Dependency injection
│   ├── network/        # Dio + Interceptors (via yo.dart network)
│   ├── themes/         # YoTheme configuration
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

## Dart Code Quality Rules

- Gunakan prinsip SOLID, DRY, KISS
- Nama variabel deskriptif dalam bahasa Inggris
- Nama file: `snake_case.dart`
- Nama class: `PascalCase`
- Nama function/variable: `camelCase`
- Private members prefix dengan `_`
- Max 300 baris per file, jika lebih pecah menjadi file terpisah

## Type Safety Rules

- DILARANG menggunakan `dynamic` kecuali benar-benar diperlukan
- DILARANG menggunakan `as` untuk casting, gunakan pattern matching
- Semua function harus punya return type eksplisit
- Gunakan `final` untuk variabel yang tidak berubah
- Gunakan `const` untuk widget/value yang immutable

## Widget Rules

- Pecah widget besar menjadi widget kecil yang reusable
- Gunakan `const` constructor jika memungkinkan
- DILARANG logic bisnis di dalam Widget, pindahkan ke Provider/BLoC/Controller
- Setiap widget kompleks harus punya file terpisah
- Gunakan named parameters untuk widget custom
- **PRIORITASKAN YoUI components** untuk UI elements

## State Management Rules

### Jika Riverpod

- Gunakan `@riverpod` annotation untuk code generation
- Provider harus ada documentation comment
- Gunakan `AsyncValue` untuk async state
- DILARANG `.when()` tanpa handle semua state (data, loading, error)

### Jika BLoC

- Setiap fitur punya Event, State, dan BLoC terpisah
- State harus immutable (gunakan freezed)
- Gunakan `Equatable` untuk State
- Handle semua state di `BlocBuilder`

### Jika GetX

- Controller terpisah per fitur
- Gunakan `.obs` untuk reactive state
- DILARANG akses controller tanpa `Get.find()` atau dependency injection

## Error Handling Rules

- Semua async call harus di-wrap dengan try-catch
- Gunakan custom Exception class untuk domain errors
- Tampilkan user-friendly message di UI (gunakan `YoToast.error()`)
- Log technical detail untuk debugging
- Selalu handle `ConnectionException` dan `TimeoutException`

## API & Data Rules

- API calls HANYA di Repository layer
- Gunakan DTO untuk API response, Entity untuk domain
- Mapping DTO ↔ Entity di Repository
- JANGAN expose DTO ke Presentation layer

## Navigation Rules

- Semua route didefinisikan di satu file (`app_router.dart`)
- Gunakan named routes dengan type-safe parameters
- Handle deep linking jika diperlukan

## AI Behavior Rules

1. JANGAN pernah import package yang tidak ada di `pubspec.yaml`. Cek dulu.
2. JANGAN tinggalkan komentar `// TODO` atau `// ... logic here`. Tulis sampai selesai.
3. JANGAN menebak nama field dari API. Refer ke `API_CONTRACT.md` atau `DB_SCHEMA.md`.
4. IKUTI struktur folder yang di-generate oleh yo.dart.
5. IKUTI pola coding yang ada di `EXAMPLES.md`.
6. SELALU handle loading, error, dan empty state di UI (gunakan YoUI components).
7. SELALU jalankan `dart analyze` sebelum submit.
8. **WAJIB gunakan yo.dart generator** untuk struktur Clean Architecture.
9. **WAJIB gunakan YoUI components** untuk UI elements.
10. **JANGAN mengarang** nama komponen atau API yang tidak terdokumentasi.

## Workflow Rules

- Sebelum coding, jelaskan rencana dalam 3 bullet points
- Gunakan yo.dart generator untuk struktur
- Implementasi logic di marker `// TODO`
- Gunakan YoUI components untuk UI
- Validasi dengan `flutter analyze`
- Jika ragu, TANYA user

## Generator Commands Reference

### Core Commands

- `dart run yo.dart init --state=riverpod` - Inisialisasi project
- `dart run yo.dart page:feature.screen` - Generate full clean architecture
- `dart run yo.dart page:splash --presentation-only` - UI layer saja

### Model & Entity

- `dart run yo.dart model:user --freezed` - Generate model dengan freezed
- `dart run yo.dart entity:user --feature=auth` - Generate entity

### State Management

- `dart run yo.dart controller:auth` - Generate controller (sesuai yo.yaml)

### Data Layer

- `dart run yo.dart datasource:auth --remote` - Generate remote datasource
- `dart run yo.dart repository:auth --feature=auth` - Generate repository
- `dart run yo.dart usecase:login --feature=auth` - Generate use case

### Infrastructure

- `dart run yo.dart network` - Generate Dio client + interceptors
- `dart run yo.dart di` - Generate dependency injection setup

### UI Components

- `dart run yo.dart screen:profile --feature=user` - Generate screen only
- `dart run yo.dart dialog:confirm --feature=common` - Generate dialog
- `dart run yo.dart widget:avatar --feature=user` - Generate widget

### Utilities

- `dart run yo.dart translation --key=welcome --en="Welcome" --id="Selamat Datang"`
- `dart run yo.dart package-name:com.company.app`
- `dart run yo.dart app-name:"My App"`

### Flags

- `--force` - Overwrite existing files
- `--presentation-only` - Generate UI layer saja
- `--freezed` - Gunakan freezed untuk model
- `--feature=<name>` - Tentukan feature target
- `--global` - Generate di folder global
- `--cubit` - Generate cubit (bloc saja)
- `--remote` / `--local` / `--both` - Tipe datasource

```

// turbo
**Simpan output ke file `RULES.md` di root project.**

---

## 🎨 Phase 2: Support System

### Step 2.1: Generate DESIGN_SYSTEM.md

```

Tanyakan kepada user:
"Jelaskan vibe/estetika yang diinginkan untuk app Flutter ini."

```

Gunakan skill `yo-flutter-dev` + `senior-ui-ux-designer`:

```markdown
Act as yo-flutter-dev dan senior-ui-ux-designer.
Buatkan `DESIGN_SYSTEM.md` untuk Flutter app dengan YoUI library dan vibe: [VIBE USER]

## 1. YoUI Theme Configuration

### Theme Setup
```dart
import 'package:yo_ui/yo_ui.dart';

MaterialApp(
  theme: YoTheme.lightTheme(context),
  darkTheme: YoTheme.darkTheme(context),
  themeMode: ThemeMode.system,
)
```

### Available Color Schemes

```dart
// Pilih salah satu YoColorScheme yang sesuai vibe:
YoTheme.lightTheme(context, YoColorScheme.techPurple)
YoTheme.lightTheme(context, YoColorScheme.oceanBlue)
YoTheme.lightTheme(context, YoColorScheme.forestGreen)
YoTheme.lightTheme(context, YoColorScheme.sunsetOrange)
YoTheme.lightTheme(context, YoColorScheme.royalGold)
YoTheme.lightTheme(context, YoColorScheme.cherryRed)
```

### Custom Color Scheme (jika diperlukan)

```dart
static const customColorScheme = ColorScheme.light(
  primary: Color(0xFF[HEX]),
  onPrimary: Color(0xFFFFFFFF),
  primaryContainer: Color(0xFF[HEX]),
  secondary: Color(0xFF[HEX]),
  onSecondary: Color(0xFFFFFFFF),
  surface: Color(0xFF[HEX]),
  onSurface: Color(0xFF[HEX]),
  background: Color(0xFF[HEX]),
  error: Color(0xFFBA1A1A),
  onError: Color(0xFFFFFFFF),
);
```

## 2. Typography (YoUI Built-in)

```dart
// Gunakan YoText untuk typography
YoText.headlineLarge('Title')        // 32px, w600
YoText.headlineMedium('Subtitle')    // 28px, w600
YoText.titleLarge('Section Title')   // 22px, w500
YoText.titleMedium('Card Title')     // 16px, w500
YoText.bodyLarge('Body Text')        // 16px, w400
YoText.bodyMedium('Body Text')       // 14px, w400
YoText.bodySmall('Caption')          // 12px, w400
YoText.labelLarge('Button Text')     // 14px, w500
YoText.labelSmall('Small Label')     // 11px, w500
```

## 3. Spacing System (Custom untuk project)

```dart
class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;
  
  static const paddingXs = EdgeInsets.all(xs);
  static const paddingSm = EdgeInsets.all(sm);
  static const paddingMd = EdgeInsets.all(md);
  static const paddingLg = EdgeInsets.all(lg);
  
  static const horizontalSm = EdgeInsets.symmetric(horizontal: sm);
  static const horizontalMd = EdgeInsets.symmetric(horizontal: md);
  static const verticalSm = EdgeInsets.symmetric(vertical: sm);
  static const verticalMd = EdgeInsets.symmetric(vertical: md);
}
```

## 4. Border Radius (Custom untuk project)

```dart
class AppRadius {
  static const double sm = 4;
  static const double md = 8;
  static const double lg = 16;
  static const double xl = 24;
  static const double full = 999;
  
  static final borderSm = BorderRadius.circular(sm);
  static final borderMd = BorderRadius.circular(md);
  static final borderLg = BorderRadius.circular(lg);
  static final borderXl = BorderRadius.circular(xl);
  static final borderFull = BorderRadius.circular(full);
}
```

## 5. Component Usage (YoUI)

### Buttons

```dart
// Primary action
YoButton.primary(text: 'Submit', onPressed: () {})

// Secondary action
YoButton.secondary(text: 'Cancel', onPressed: () {})

// Outline style
YoButton.outline(text: 'Details', onPressed: () {})

// Ghost/Text style
YoButton.ghost(text: 'Skip', onPressed: () {})

// Pill style (untuk tags)
YoButton.pill(text: 'Tag', onPressed: () {})

// Modern style (elevated dengan shadow)
YoButton.modern(text: 'Action', onPressed: () {})
```

### Form Components

```dart
// OTP Input
YoOtpField(
  length: 6,
  onCompleted: (pin) => verify(pin),
)

// Search dengan suggestions
YoSearchField(
  hintText: 'Search...',
  suggestions: ['Item 1', 'Item 2'],
  onSearch: (query) => search(query),
)

// Chip Input (tags)
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
  stats: [
    YoProfileStat(value: '1.2K', label: 'Followers'),
    YoProfileStat(value: '345', label: 'Following'),
  ],
)

// Article Card
YoArticleCard.featured(
  imageUrl: 'https://...',
  title: 'Article Title',
  category: 'Tech',
  readTime: 5,
)

// Destination Card (untuk travel apps)
YoDestinationCard.featured(
  imageUrl: 'https://...',
  title: 'Bali',
  location: 'Indonesia',
  rating: 4.8,
  price: 1200,
)
```

### Feedback Components

```dart
// Toast Notifications
YoToast.success(context: context, message: 'Success!')
YoToast.error(context: context, message: 'Error occurred')
YoToast.info(context: context, message: 'Information')
YoToast.warning(context: context, message: 'Warning!')

// Loading States
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
  message: 'New update available!',
  type: YoBannerType.info,
  dismissible: true,
)

// Carousel
YoCarousel(
  images: imageUrls,
  autoPlay: true,
  height: 200,
)
```

### Navigation Components

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

### Data Display

```dart
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

## 6. Utilities (YoUI)

```dart
// Date Formatting
YoDateFormatter.formatDate(DateTime.now())     // '07 Dec 2024'
YoDateFormatter.formatRelativeTime(date)       // '2 hours ago'
YoDateFormatter.isToday(date)                  // true/false

// ID Generation
YoIdGenerator.uuid()                           // UUID v4
YoIdGenerator.numericId(length: 8)             // '12345678'
YoIdGenerator.userId()                         // 'USR_aB3xY8pQ'

// Connectivity Check
await YoConnectivity.initialize();
bool isOnline = YoConnectivity.isConnected;
YoConnectivity.addListener((connected) {
  // Handle connectivity change
});

// Text Input Formatters
CurrencyTextInputFormatter()        // 1000000 -> 1.000.000
IndonesiaCurrencyFormatter()        // 1000000 -> Rp 1.000.000
PhoneNumberFormatter()              // 081234567890 -> 0812-3456-7890
IndonesiaPhoneFormatter()           // 6281234567890 -> +62 812 3456 7890
CreditCardFormatter()               // 1234567890123456 -> 1234 5678 9012 3456
```

## 7. Animation & Motion

```dart
class AppDurations {
  static const fast = Duration(milliseconds: 150);
  static const normal = Duration(milliseconds: 300);
  static const slow = Duration(milliseconds: 500);
}

class AppCurves {
  static const defaultCurve = Curves.easeOutCubic;
  static const emphasis = Curves.easeInOutCubic;
  static const decelerate = Curves.decelerate;
}
```

## 8. Icons

- Gunakan `Icons` dari Material untuk icons standar
- Custom icons dalam format SVG di `assets/icons/`
- Size: 16 (small), 20 (default), 24 (medium), 32 (large)

## 9. Design Principles

- **Consistency**: Gunakan YoUI components untuk konsistensi visual
- **Accessibility**: YoUI components sudah built-in dengan accessibility
- **Responsiveness**: Gunakan `responsive_framework` untuk breakpoints
- **Performance**: Gunakan `const` constructor dan YoUI optimized widgets
- **Dark Mode**: YoTheme sudah support dark mode out of the box

```

// turbo
**Simpan output ke file `DESIGN_SYSTEM.md` di root project.**

---

### Step 2.2: Generate FOLDER_STRUCTURE.md

Gunakan skill `yo-flutter-dev`:

```markdown
Act as yo-flutter-dev.
Buatkan `FOLDER_STRUCTURE.md` untuk Flutter Clean Architecture dengan yo.dart generator.

## Project Structure (Generated by yo.dart)

```

lib/
├── main.dart                      # App entry point
├── app.dart                       # MaterialApp with YoTheme
│
├── core/                          # Shared/Core functionality
│   ├── config/                    # Configuration
│   │   └── app_router.dart        # go_router configuration
│   │
│   ├── di/                        # Dependency injection (via yo.dart di)
│   │   └── injection.dart
│   │
│   ├── network/                   # Network configuration (via yo.dart network)
│   │   ├── dio_client.dart
│   │   └── api_interceptor.dart
│   │
│   ├── themes/                    # YoUI Theme configuration
│   │   ├── app_theme.dart
│   │   └── color_schemes.dart
│   │
│   ├── utils/                     # Utility functions
│   │   ├── extensions/
│   │   ├── helpers/
│   │   └── validators/
│   │
│   ├── errors/                    # Error handling
│   │   ├── exceptions.dart
│   │   └── failures.dart
│   │
│   └── widgets/                   # Global reusable widgets
│       ├── loading_indicator.dart
│       ├── error_view.dart
│       └── empty_state.dart
│
├── features/                      # Feature modules (via yo.dart page:feature.screen)
│   └── [feature_name]/
│       ├── data/                  # Data layer
│       │   ├── datasources/       # Remote & Local (via yo.dart datasource)
│       │   │   ├── [feature]_remote_datasource.dart
│       │   │   └── [feature]_local_datasource.dart
│       │   ├── models/            # DTOs (via yo.dart model)
│       │   │   └── [model]_dto.dart
│       │   └── repositories/      # Repository implementations (via yo.dart repository)
│       │       └── [feature]_repository_impl.dart
│       │
│       ├── domain/                # Domain layer
│       │   ├── entities/          # Business entities (via yo.dart entity)
│       │   │   └── [entity].dart
│       │   ├── repositories/      # Repository interfaces
│       │   │   └── [feature]_repository.dart
│       │   └── usecases/          # Use cases (via yo.dart usecase)
│       │       ├── [action]_usecase.dart
│       │       └── ...
│       │
│       └── presentation/          # Presentation layer
│           ├── providers/         # Riverpod providers (jika state_management: riverpod)
│           │   └── [feature]_provider.dart
│           ├── blocs/             # BLoC files (jika state_management: bloc)
│           │   ├── [feature]_bloc.dart
│           │   ├── [feature]_event.dart
│           │   └── [feature]_state.dart
│           ├── controllers/       # GetX controllers (jika state_management: getx)
│           │   └── [feature]_controller.dart
│           ├── pages/             # Screen widgets (via yo.dart page)
│           │   └── [screen]_page.dart
│           └── widgets/           # Feature-specific widgets (via yo.dart widget)
│               └── [widget].dart
│
├── shared/                        # Shared widgets & components (YoUI)
│   ├── widgets/                   # Custom reusable widgets
│   │   └── custom_widgets.dart
│   │
│   └── layouts/                   # Layout components
│       ├── app_scaffold.dart
│       └── responsive_layout.dart
│
└── l10n/                          # Localization (via yo.dart translation)
    ├── app_en.arb
    └── app_id.arb

assets/
├── images/
├── icons/
├── fonts/
└── animations/                    # Lottie files

test/
├── unit/
├── widget/
└── integration/

# Generator files (di root project)

yo.dart                            # yo.dart generator script
yo.yaml                            # Generator configuration

```

## Naming Conventions
- Files: `snake_case.dart`
- Classes: `PascalCase`
- Functions/Variables: `camelCase`
- Constants: `camelCase` (bukan SCREAMING_CASE)
- Private: prefix `_`

## Feature Module Rules (via yo.dart)
- Setiap fitur adalah folder mandiri di `/features`
- Generate dengan: `dart run yo.dart page:feature.screen`
- Fitur tidak boleh import dari fitur lain secara langsung
- Komunikasi antar fitur melalui `core/` atau navigation
- Setiap fitur punya 3 layer: data, domain, presentation

## Generator Workflow
1. **Init project**: `dart run yo.dart init --state=riverpod`
2. **Generate page**: `dart run yo.dart page:auth.login`
3. **Generate model**: `dart run yo.dart model:user --feature=auth --freezed`
4. **Generate datasource**: `dart run yo.dart datasource:auth --remote --feature=auth`
5. **Generate repository**: `dart run yo.dart repository:auth --feature=auth`
6. **Generate usecase**: `dart run yo.dart usecase:login --feature=auth`

## Import Rules
- Gunakan relative import dalam satu fitur
- Gunakan absolute import untuk cross-module
- Import YoUI: `import 'package:yo_ui/yo_ui.dart';`
```

// turbo
**Simpan output ke file `FOLDER_STRUCTURE.md` di root project.**

---

### Step 2.3: Generate DB_SCHEMA.md

Gunakan skill `database-modeling-specialist` + `senior-firebase-developer` atau `senior-supabase-developer`:

```markdown
Act as database-modeling-specialist.
Berdasarkan fitur di PRD.md, desain database schema untuk [Firebase/Supabase].

Buatkan `DB_SCHEMA.md`.

### Untuk Firebase Firestore:
```

Collection: users
├── Document ID: {userId}
│   ├── email: string
│   ├── displayName: string
│   ├── avatarUrl: string?
│   ├── createdAt: timestamp
│   └── updatedAt: timestamp

Collection: [collection_lain]
├── ...

```

### Untuk Supabase PostgreSQL:
| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK, DEFAULT gen_random_uuid() | User ID |
| email | text | UNIQUE, NOT NULL | Email |
...

### Security Rules (Firebase) / RLS (Supabase):
[Definisikan aturan akses]

### Indexes:
[Daftar index yang diperlukan untuk query optimal]
```

// turbo
**Simpan output ke file `DB_SCHEMA.md` di root project.**

---

### Step 2.4: Generate API_CONTRACT.md

Gunakan skill `api-design-specialist`:

```markdown
Act as api-design-specialist.
Buatkan `API_CONTRACT.md` untuk Flutter app.

Jika Firebase: dokumentasikan Firestore queries dan Cloud Functions endpoints.
Jika Supabase: dokumentasikan table operations dan Edge Functions.
Jika REST API: dokumentasikan endpoints lengkap.

Format untuk setiap endpoint:

## Authentication

### POST /api/auth/login
**Request:**
```dart
// Model generated via: dart run yo.dart model:login.request --feature=auth --freezed
@freezed
class LoginRequest with _$LoginRequest {
  const factory LoginRequest({
    required String email,
    required String password,
  }) = _LoginRequest;
  
  factory LoginRequest.fromJson(Map<String, dynamic> json) =>
      _$LoginRequestFromJson(json);
}
```

**Response 200:**

```dart
// Model generated via: dart run yo.dart model:login.response --feature=auth --freezed
@freezed
class LoginResponse with _$LoginResponse {
  const factory LoginResponse({
    required User user,
    required String accessToken,
    required String refreshToken,
  }) = _LoginResponse;
  
  factory LoginResponse.fromJson(Map<String, dynamic> json) =>
      _$LoginResponseFromJson(json);
}
```

**Error Codes:**

- 400: Invalid credentials
- 429: Too many attempts

[Lanjutkan untuk semua endpoints]

```

// turbo
**Simpan output ke file `API_CONTRACT.md` di root project.**

---

### Step 2.5: Generate EXAMPLES.md

Gunakan skill `yo-flutter-dev`:

```markdown
Act as yo-flutter-dev.
Buatkan `EXAMPLES.md` berisi contoh kode Flutter yang jadi standar project dengan yo.dart generator dan YoUI.

## 1. Entity Pattern (Domain Layer)

Generated via: `dart run yo.dart entity:user --feature=auth`

```dart
// features/auth/domain/entities/user.dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'user.freezed.dart';

@freezed
class User with _$User {
  const factory User({
    required String id,
    required String email,
    required String displayName,
    String? avatarUrl,
    required DateTime createdAt,
  }) = _User;
}
```

## 2. DTO Pattern (Data Layer)

Generated via: `dart run yo.dart model:user --feature=auth --freezed`

```dart
// features/auth/data/models/user_dto.dart
import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/user.dart';

part 'user_dto.freezed.dart';
part 'user_dto.g.dart';

@freezed
class UserDto with _$UserDto {
  const UserDto._();
  
  const factory UserDto({
    required String id,
    required String email,
    @JsonKey(name: 'display_name') required String displayName,
    @JsonKey(name: 'avatar_url') String? avatarUrl,
    @JsonKey(name: 'created_at') required DateTime createdAt,
  }) = _UserDto;
  
  factory UserDto.fromJson(Map<String, dynamic> json) =>
      _$UserDtoFromJson(json);
  
  // Mapping to Entity
  User toEntity() => User(
    id: id,
    email: email,
    displayName: displayName,
    avatarUrl: avatarUrl,
    createdAt: createdAt,
  );
  
  // Mapping from Entity
  factory UserDto.fromEntity(User user) => UserDto(
    id: user.id,
    email: user.email,
    displayName: user.displayName,
    avatarUrl: user.avatarUrl,
    createdAt: user.createdAt,
  );
}
```

## 3. Repository Pattern

Generated via: `dart run yo.dart repository:auth --feature=auth`

```dart
// features/auth/data/repositories/auth_repository_impl.dart
import 'package:dartz/dartz.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/errors/exceptions.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  
  AuthRepositoryImpl({required this.remoteDataSource});
  
  @override
  Future<Either<Failure, User>> login({
    required String email,
    required String password,
  }) async {
    try {
      final userDto = await remoteDataSource.login(
        email: email,
        password: password,
      );
      return Right(userDto.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException {
      return Left(NetworkFailure('No internet connection'));
    }
  }
}
```

## 4. UseCase Pattern

Generated via: `dart run yo.dart usecase:login --feature=auth`

```dart
// features/auth/domain/usecases/login_usecase.dart
import 'package:dartz/dartz.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';
import '../../../../core/errors/failures.dart';

class LoginUseCase {
  final AuthRepository repository;
  
  LoginUseCase(this.repository);
  
  Future<Either<Failure, User>> call({
    required String email,
    required String password,
  }) async {
    return await repository.login(
      email: email,
      password: password,
    );
  }
}
```

## 5. State Management Patterns

### Riverpod Provider (jika yo.yaml state_management: riverpod)

```dart
// features/auth/presentation/providers/auth_provider.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/entities/user.dart';
import '../../domain/usecases/login_usecase.dart';

part 'auth_provider.g.dart';

@riverpod
class AuthNotifier extends _$AuthNotifier {
  @override
  AsyncValue<User?> build() {
    return const AsyncValue.data(null);
  }
  
  Future<void> login({
    required String email,
    required String password,
  }) async {
    state = const AsyncValue.loading();
    
    final loginUseCase = ref.read(loginUseCaseProvider);
    final result = await loginUseCase(email: email, password: password);
    
    result.fold(
      (failure) => state = AsyncValue.error(failure, StackTrace.current),
      (user) => state = AsyncValue.data(user),
    );
  }
}
```

### BLoC Pattern (jika yo.yaml state_management: bloc)

```dart
// features/auth/presentation/bloc/auth_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/user.dart';
import '../../domain/usecases/login_usecase.dart';

part 'auth_bloc.freezed.dart';
part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase loginUseCase;
  
  AuthBloc({required this.loginUseCase}) : super(const AuthState.initial()) {
    on<AuthEvent>((event, emit) async {
      await event.when(
        login: (email, password) => _onLogin(email, password, emit),
      );
    });
  }
  
  Future<void> _onLogin(
    String email,
    String password,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthState.loading());
    
    final result = await loginUseCase(email: email, password: password);
    
    result.fold(
      (failure) => emit(AuthState.error(failure.message)),
      (user) => emit(AuthState.authenticated(user)),
    );
  }
}
```

### GetX Controller (jika yo.yaml state_management: getx)

```dart
// features/auth/presentation/controllers/auth_controller.dart
import 'package:get/get.dart';
import '../../domain/entities/user.dart';
import '../../domain/usecases/login_usecase.dart';

class AuthController extends GetxController {
  final LoginUseCase loginUseCase;
  
  AuthController({required this.loginUseCase});
  
  final Rx<User?> user = Rx<User?>(null);
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  
  Future<void> login({
    required String email,
    required String password,
  }) async {
    isLoading.value = true;
    errorMessage.value = '';
    
    final result = await loginUseCase(email: email, password: password);
    
    result.fold(
      (failure) {
        errorMessage.value = failure.message;
        isLoading.value = false;
      },
      (userData) {
        user.value = userData;
        isLoading.value = false;
      },
    );
  }
}
```

## 6. UI Pattern dengan YoUI

Generated via: `dart run yo.dart page:auth.login`

```dart
// features/auth/presentation/pages/login_page.dart
import 'package:flutter/material.dart';
import 'package:yo_ui/yo_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // atau bloc/getx
import '../providers/auth_provider.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});
  
  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
  
  void _handleLogin() {
    final email = _emailController.text;
    final password = _passwordController.text;
    
    ref.read(authNotifierProvider.notifier).login(
      email: email,
      password: password,
    );
  }
  
  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Title
              YoText.headlineLarge('Welcome Back'),
              const SizedBox(height: 8),
              YoText.bodyMedium('Sign in to continue'),
              const SizedBox(height: 32),
              
              // Email Field
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              
              // Password Field
              TextField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  prefixIcon: Icon(Icons.lock_outlined),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 24),
              
              // Login Button with state handling
              authState.when(
                data: (_) => YoButton.primary(
                  text: 'Sign In',
                  onPressed: _handleLogin,
                ),
                loading: () => YoButton.primary(
                  text: 'Signing in...',
                  onPressed: null,
                ),
                error: (error, _) => Column(
                  children: [
                    YoBanner(
                      message: error.toString(),
                      type: YoBannerType.error,
                      dismissible: true,
                    ),
                    const SizedBox(height: 16),
                    YoButton.primary(
                      text: 'Sign In',
                      onPressed: _handleLogin,
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Secondary Actions
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  YoText.bodySmall('Don\'t have an account?'),
                  const SizedBox(width: 4),
                  YoButton.ghost(
                    text: 'Sign Up',
                    onPressed: () {
                      // Navigate to register
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

## 7. Error Handling Pattern

```dart
// core/errors/exceptions.dart
class ServerException implements Exception {
  final String message;
  ServerException(this.message);
}

class NetworkException implements Exception {}

class CacheException implements Exception {}

// core/errors/failures.dart
abstract class Failure {
  final String message;
  Failure(this.message);
}

class ServerFailure extends Failure {
  ServerFailure(super.message);
}

class NetworkFailure extends Failure {
  NetworkFailure(super.message);
}

class CacheFailure extends Failure {
  CacheFailure(super.message);
}
```

## 8. Dio Client Pattern

Generated via: `dart run yo.dart network`

```dart
// core/network/dio_client.dart
import 'package:dio/dio.dart';
import 'api_interceptor.dart';

class DioClient {
  late final Dio _dio;
  
  DioClient() {
    _dio = Dio(
      BaseOptions(
        baseUrl: 'https://api.example.com',
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );
    
    _dio.interceptors.add(ApiInterceptor());
  }
  
  Dio get dio => _dio;
}
```

## 9. YoUI Utilities Usage

```dart
// Date formatting
final formattedDate = YoDateFormatter.formatDate(DateTime.now());
final relativeTime = YoDateFormatter.formatRelativeTime(someDate);

// ID generation
final userId = YoIdGenerator.userId();  // 'USR_aB3xY8pQ'
final uuid = YoIdGenerator.uuid();      // UUID v4

// Connectivity check
await YoConnectivity.initialize();
if (YoConnectivity.isConnected) {
  // Make API call
}

// Input formatters
TextField(
  inputFormatters: [IndonesiaCurrencyFormatter()],
  // User types: 1000000
  // Displays: Rp 1.000.000
)
```

## 10. Testing Pattern

```dart
// test/features/auth/domain/usecases/login_usecase_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dartz/dartz.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late LoginUseCase useCase;
  late MockAuthRepository mockRepository;
  
  setUp(() {
    mockRepository = MockAuthRepository();
    useCase = LoginUseCase(mockRepository);
  });
  
  test('should return User when login is successful', () async {
    // Arrange
    final user = User(
      id: '1',
      email: 'test@example.com',
      displayName: 'Test User',
      createdAt: DateTime.now(),
    );
    when(() => mockRepository.login(
      email: any(named: 'email'),
      password: any(named: 'password'),
    )).thenAnswer((_) async => Right(user));
    
    // Act
    final result = await useCase(
      email: 'test@example.com',
      password: 'password123',
    );
    
    // Assert
    expect(result, Right(user));
    verify(() => mockRepository.login(
      email: 'test@example.com',
      password: 'password123',
    )).called(1);
  });
}
```

```

// turbo
**Simpan output ke file `EXAMPLES.md` di root project.**

---

## 🚀 Phase 3: Project Setup

### Step 3.1: Setup yo.dart Generator

```bash
# Clone generator repository
git clone https://github.com/cahyo40/flutter-generator.git .yo-generator

# Copy generator files to project
cp .yo-generator/yo.dart .
cp -r .yo-generator/lib/generators ./lib/

# Clean up temporary folder
rm -rf .yo-generator

# Initialize project with state management
# Pilih salah satu sesuai TECH_STACK.md:
dart run yo.dart init --state=riverpod  # Recommended
# dart run yo.dart init --state=bloc
# dart run yo.dart init --state=getx
```

// turbo

---

### Step 3.2: Setup YoUI Library

Edit `pubspec.yaml` dan tambahkan YoUI dependency:

```yaml
dependencies:
  flutter:
    sdk: flutter
  
  # YoUI Component Library
  yo_ui:
    git:
      url: https://github.com/cahyo40/youi.git
      ref: main
  
  # ... dependencies lainnya sesuai TECH_STACK.md
```

```bash
# Install dependencies
flutter pub get
```

// turbo

---

### Step 3.3: Configure YoTheme

Edit `lib/main.dart`:

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
      title: 'My App',
      theme: YoTheme.lightTheme(context),
      darkTheme: YoTheme.darkTheme(context),
      themeMode: ThemeMode.system,
      home: const HomeScreen(),
    );
  }
}
```

// turbo

---

### Step 3.4: Verify Setup

```bash
# Run code generation (jika ada freezed/json_serializable)
dart run build_runner build --delete-conflicting-outputs

# Analyze code
flutter analyze

# Run app
flutter run
```

// turbo

---

## 📝 Phase 4: Implementation Workflow

### Step 4.1: Generate Feature Structure

Contoh: Generate fitur authentication

```bash
# Generate full clean architecture untuk login page
dart run yo.dart page:auth.login

# Generate register page
dart run yo.dart page:auth.register

# Generate models
dart run yo.dart model:user --feature=auth --freezed
dart run yo.dart model:login.request --feature=auth --freezed
dart run yo.dart model:login.response --feature=auth --freezed

# Generate datasource
dart run yo.dart datasource:auth --remote --feature=auth

# Generate repository
dart run yo.dart repository:auth --feature=auth

# Generate usecases
dart run yo.dart usecase:login --feature=auth
dart run yo.dart usecase:register --feature=auth
dart run yo.dart usecase:logout --feature=auth
```

// turbo

---

### Step 4.2: Implement Business Logic

1. Baca file yang di-generate oleh yo.dart
2. Cari marker `// TODO` di setiap file
3. Implementasi logic sesuai `API_CONTRACT.md` dan `DB_SCHEMA.md`
4. Gunakan komponen YoUI untuk UI
5. Handle loading, error, dan empty state

---

### Step 4.3: Run Code Generation

```bash
# Generate freezed dan json_serializable code
dart run build_runner build --delete-conflicting-outputs

# Atau watch mode untuk auto-generate
dart run build_runner watch --delete-conflicting-outputs
```

// turbo

---

### Step 4.4: Testing

```bash
# Run unit tests
flutter test

# Run with coverage
flutter test --coverage

# View coverage report
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

// turbo

---

## ✅ Checklist

### Phase 1: The Holy Trinity

- [ ] `PRD.md` created
- [ ] `TECH_STACK.md` created
- [ ] `RULES.md` created

### Phase 2: Support System

- [ ] `DESIGN_SYSTEM.md` created
- [ ] `FOLDER_STRUCTURE.md` created
- [ ] `DB_SCHEMA.md` created
- [ ] `API_CONTRACT.md` created
- [ ] `EXAMPLES.md` created

### Phase 3: Project Setup

- [ ] yo.dart generator installed
- [ ] YoUI library added to pubspec.yaml
- [ ] YoTheme configured in main.dart
- [ ] Dependencies installed
- [ ] Setup verified

### Phase 4: Implementation

- [ ] Features generated with yo.dart
- [ ] Business logic implemented
- [ ] Code generation completed
- [ ] Tests written and passing

---

## 🎯 Best Practices

### ✅ Do This

- ✅ Selalu baca `yo.yaml` sebelum generate
- ✅ Gunakan yo.dart generator untuk struktur
- ✅ Gunakan YoUI components untuk UI
- ✅ Ikuti marker `// TODO` dari generator
- ✅ Handle semua state (loading, error, success)
- ✅ Jalankan `flutter analyze` sebelum commit

### ❌ Avoid This

- ❌ Jangan tulis manual jika ada generator
- ❌ Jangan mengarang nama komponen YoUI
- ❌ Jangan mix state management
- ❌ Jangan skip code generation
- ❌ Jangan abaikan struktur Clean Architecture

---

## 📚 References

- yo.dart Generator: <https://github.com/cahyo40/flutter-generator>
- YoUI Library: <https://github.com/cahyo40/youi>
- Flutter Clean Architecture: <https://resocoder.com/flutter-clean-architecture-tdd/>
- Riverpod: <https://riverpod.dev>
- BLoC: <https://bloclibrary.dev>
- GetX: <https://pub.dev/packages/get>

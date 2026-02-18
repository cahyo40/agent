# Workflow: Translation & Localization (GetX)

## Overview

Implementasi internationalization (i18n) untuk Flutter dengan GetX. Workflow ini menyediakan **dua opsi** pendekatan: GetX Built-in Translations (recommended) dan Easy Localization package. GetX menyediakan sistem translation bawaan yang ringan dan terintegrasi langsung — tidak perlu code generation atau JSON files terpisah.

## Output Location

**Base Folder:** `sdlc/flutter-getx/07-translation/`

```
sdlc/flutter-getx/07-translation/
├── dependencies.yaml
├── option_a_getx_builtin/
│   ├── app_translations.dart
│   ├── translations/
│   │   ├── en_us.dart
│   │   ├── id_id.dart
│   │   ├── ms_my.dart
│   │   ├── th_th.dart
│   │   └── vn_vn.dart
│   ├── locale_controller.dart
│   ├── main_config.dart
│   ├── language_selector_widget.dart
│   ├── settings_screen.dart
│   └── usage_examples.dart
├── option_b_easy_localization/
│   ├── setup.dart
│   ├── translations/
│   │   ├── en.json
│   │   ├── id.json
│   │   ├── ms.json
│   │   ├── th.json
│   │   └── vi.json
│   └── locale_controller.dart
├── screenshots/
│   └── .gitkeep
└── notes.md
```

## Prerequisites

- Flutter SDK >= 3.x
- GetX (`get`) package sudah terinstall
- `get_storage` untuk persistensi locale preference
- Pemahaman dasar GetX reactive state (`Rx`, `Obx`)
- Familiar dengan konsep Locale dan i18n di Flutter

## Deliverables

---

### 1. Dependencies Setup

GetX built-in translations membutuhkan **lebih sedikit dependencies** dibanding pendekatan easy_localization. Tidak perlu code generation atau JSON loader.

**File:** `sdlc/flutter-getx/07-translation/dependencies.yaml`

```yaml
# pubspec.yaml additions

dependencies:
  flutter:
    sdk: flutter
  get: ^4.6.6
  get_storage: ^2.1.1

  # --- Hanya jika pakai Option B (Easy Localization) ---
  # easy_localization: ^3.0.7

# --- Hanya jika pakai Option B ---
# flutter:
#   assets:
#     - assets/translations/
```

> **Catatan:** Dengan Option A (GetX Built-in), kamu **tidak** perlu folder assets
> untuk translation files. Semua translation didefinisikan langsung di Dart code
> sebagai `Map<String, String>`. Ini membuat build lebih ringan dan refactoring
> lebih mudah karena IDE bisa track semua keys.

---

### 2. Option A: GetX Built-in Translations (Recommended)

Pendekatan ini memanfaatkan class `Translations` bawaan GetX. Semua translation
string didefinisikan sebagai Dart Maps — type-safe, mudah di-refactor, dan tidak
butuh asset loading.

#### 2.1 Translation Maps per Bahasa

Setiap bahasa didefinisikan dalam file Dart terpisah yang meng-export sebuah
`Map<String, String>`. Gunakan **dot notation** untuk grouping keys supaya
terstruktur rapi.

**File:** `sdlc/flutter-getx/07-translation/option_a_getx_builtin/translations/en_us.dart`

```dart
// lib/core/translations/en_us.dart

const Map<String, String> enUS = {
  // ============================================================
  // General / Common
  // ============================================================
  'app.title': 'My Application',
  'app.description': 'A complete Flutter application with GetX',

  // Common actions
  'common.save': 'Save',
  'common.cancel': 'Cancel',
  'common.delete': 'Delete',
  'common.edit': 'Edit',
  'common.add': 'Add',
  'common.search': 'Search',
  'common.filter': 'Filter',
  'common.sort': 'Sort',
  'common.refresh': 'Refresh',
  'common.loading': 'Loading...',
  'common.retry': 'Retry',
  'common.confirm': 'Confirm',
  'common.back': 'Back',
  'common.next': 'Next',
  'common.done': 'Done',
  'common.close': 'Close',
  'common.yes': 'Yes',
  'common.no': 'No',
  'common.ok': 'OK',
  'common.submit': 'Submit',
  'common.continue': 'Continue',
  'common.skip': 'Skip',
  'common.select_all': 'Select All',
  'common.deselect_all': 'Deselect All',
  'common.no_data': 'No data available',
  'common.see_all': 'See All',
  'common.view_details': 'View Details',

  // Common labels
  'common.name': 'Name',
  'common.email': 'Email',
  'common.phone': 'Phone',
  'common.address': 'Address',
  'common.date': 'Date',
  'common.time': 'Time',
  'common.status': 'Status',
  'common.description': 'Description',
  'common.amount': 'Amount',
  'common.total': 'Total',
  'common.price': 'Price',
  'common.quantity': 'Quantity',

  // ============================================================
  // Authentication
  // ============================================================
  'auth.login': 'Login',
  'auth.logout': 'Logout',
  'auth.register': 'Register',
  'auth.forgot_password': 'Forgot Password?',
  'auth.reset_password': 'Reset Password',
  'auth.email_hint': 'Enter your email',
  'auth.password_hint': 'Enter your password',
  'auth.confirm_password': 'Confirm Password',
  'auth.login_success': 'Login successful',
  'auth.login_failed': 'Login failed. Please check your credentials.',
  'auth.register_success': 'Registration successful! Please log in.',
  'auth.logout_confirm': 'Are you sure you want to logout?',
  'auth.password_mismatch': 'Passwords do not match',
  'auth.welcome_back': 'Welcome back, @name!',
  'auth.new_user': 'New user? Create an account',
  'auth.existing_user': 'Already have an account? Login',
  'auth.or_continue_with': 'Or continue with',
  'auth.terms_agree': 'By continuing, you agree to our Terms of Service',

  // ============================================================
  // Navigation / Menu
  // ============================================================
  'nav.home': 'Home',
  'nav.profile': 'Profile',
  'nav.settings': 'Settings',
  'nav.notifications': 'Notifications',
  'nav.favorites': 'Favorites',
  'nav.history': 'History',
  'nav.help': 'Help & Support',
  'nav.about': 'About',
  'nav.dashboard': 'Dashboard',
  'nav.orders': 'Orders',
  'nav.products': 'Products',
  'nav.categories': 'Categories',
  'nav.cart': 'Cart',
  'nav.checkout': 'Checkout',

  // ============================================================
  // Settings
  // ============================================================
  'settings.title': 'Settings',
  'settings.language': 'Language',
  'settings.language_subtitle': 'Choose your preferred language',
  'settings.theme': 'Theme',
  'settings.theme_subtitle': 'Choose light or dark theme',
  'settings.theme_light': 'Light',
  'settings.theme_dark': 'Dark',
  'settings.theme_system': 'System',
  'settings.notifications': 'Notifications',
  'settings.notifications_subtitle': 'Manage notification preferences',
  'settings.push_notifications': 'Push Notifications',
  'settings.email_notifications': 'Email Notifications',
  'settings.sound': 'Sound',
  'settings.vibration': 'Vibration',
  'settings.privacy': 'Privacy',
  'settings.privacy_subtitle': 'Manage your privacy settings',
  'settings.account': 'Account',
  'settings.account_subtitle': 'Manage your account details',
  'settings.about_app': 'About App',
  'settings.version': 'Version',
  'settings.terms': 'Terms of Service',
  'settings.privacy_policy': 'Privacy Policy',
  'settings.rate_app': 'Rate This App',
  'settings.share_app': 'Share App',
  'settings.delete_account': 'Delete Account',
  'settings.delete_account_confirm':
      'Are you sure? This action cannot be undone.',
  'settings.cache_cleared': 'Cache cleared successfully',
  'settings.clear_cache': 'Clear Cache',

  // ============================================================
  // Profile
  // ============================================================
  'profile.title': 'My Profile',
  'profile.edit': 'Edit Profile',
  'profile.update_success': 'Profile updated successfully',
  'profile.update_failed': 'Failed to update profile',
  'profile.change_photo': 'Change Photo',
  'profile.full_name': 'Full Name',
  'profile.bio': 'Bio',
  'profile.date_of_birth': 'Date of Birth',
  'profile.gender': 'Gender',
  'profile.gender_male': 'Male',
  'profile.gender_female': 'Female',
  'profile.gender_other': 'Other',
  'profile.member_since': 'Member since @date',
  'profile.orders_count': '@count Orders',

  // ============================================================
  // Home
  // ============================================================
  'home.greeting_morning': 'Good Morning',
  'home.greeting_afternoon': 'Good Afternoon',
  'home.greeting_evening': 'Good Evening',
  'home.featured': 'Featured',
  'home.popular': 'Popular',
  'home.recent': 'Recent',
  'home.recommended': 'Recommended for You',
  'home.whats_new': "What's New",
  'home.trending': 'Trending Now',

  // ============================================================
  // Products / Catalog
  // ============================================================
  'product.details': 'Product Details',
  'product.add_to_cart': 'Add to Cart',
  'product.buy_now': 'Buy Now',
  'product.out_of_stock': 'Out of Stock',
  'product.in_stock': 'In Stock',
  'product.reviews': 'Reviews (@count)',
  'product.no_reviews': 'No reviews yet',
  'product.write_review': 'Write a Review',
  'product.specifications': 'Specifications',
  'product.related': 'Related Products',
  'product.added_to_cart': 'Added to cart',
  'product.price_from': 'From @price',
  'product.discount': '@percent% OFF',

  // ============================================================
  // Cart & Checkout
  // ============================================================
  'cart.title': 'Shopping Cart',
  'cart.empty': 'Your cart is empty',
  'cart.subtotal': 'Subtotal',
  'cart.shipping': 'Shipping',
  'cart.tax': 'Tax',
  'cart.total': 'Total',
  'cart.checkout': 'Proceed to Checkout',
  'cart.remove_item': 'Remove item?',
  'cart.item_count': '@count items',
  'cart.free_shipping': 'Free Shipping',

  'checkout.title': 'Checkout',
  'checkout.shipping_address': 'Shipping Address',
  'checkout.payment_method': 'Payment Method',
  'checkout.order_summary': 'Order Summary',
  'checkout.place_order': 'Place Order',
  'checkout.order_success': 'Order placed successfully!',
  'checkout.order_id': 'Order ID: @id',

  // ============================================================
  // Orders
  // ============================================================
  'order.title': 'My Orders',
  'order.empty': 'No orders yet',
  'order.status_pending': 'Pending',
  'order.status_processing': 'Processing',
  'order.status_shipped': 'Shipped',
  'order.status_delivered': 'Delivered',
  'order.status_cancelled': 'Cancelled',
  'order.track': 'Track Order',
  'order.reorder': 'Reorder',
  'order.cancel': 'Cancel Order',
  'order.details': 'Order Details',

  // ============================================================
  // Notifications
  // ============================================================
  'notification.title': 'Notifications',
  'notification.empty': 'No notifications',
  'notification.mark_read': 'Mark as Read',
  'notification.mark_all_read': 'Mark All as Read',
  'notification.clear_all': 'Clear All',

  // ============================================================
  // Error Messages
  // ============================================================
  'error.generic': 'Something went wrong. Please try again.',
  'error.network': 'No internet connection. Please check your network.',
  'error.server': 'Server error. Please try again later.',
  'error.timeout': 'Request timed out. Please try again.',
  'error.not_found': 'Not found',
  'error.unauthorized': 'Unauthorized. Please login again.',
  'error.forbidden': 'You do not have permission to access this.',
  'error.validation': 'Please check your input and try again.',
  'error.empty_field': 'This field cannot be empty',
  'error.invalid_email': 'Please enter a valid email address',
  'error.password_too_short': 'Password must be at least 8 characters',
  'error.unknown': 'An unknown error occurred',

  // ============================================================
  // Validation
  // ============================================================
  'validation.required': 'This field is required',
  'validation.email': 'Please enter a valid email',
  'validation.min_length': 'Must be at least @count characters',
  'validation.max_length': 'Must be at most @count characters',
  'validation.phone': 'Please enter a valid phone number',
  'validation.password_weak':
      'Password must contain uppercase, lowercase, and numbers',

  // ============================================================
  // Dates & Time
  // ============================================================
  'date.today': 'Today',
  'date.yesterday': 'Yesterday',
  'date.tomorrow': 'Tomorrow',
  'date.days_ago': '@count days ago',
  'date.hours_ago': '@count hours ago',
  'date.minutes_ago': '@count minutes ago',
  'date.just_now': 'Just now',

  // ============================================================
  // Language Names (untuk selector)
  // ============================================================
  'language.en': 'English',
  'language.id': 'Bahasa Indonesia',
  'language.ms': 'Bahasa Melayu',
  'language.th': 'ภาษาไทย',
  'language.vi': 'Tiếng Việt',
};
```

**File:** `sdlc/flutter-getx/07-translation/option_a_getx_builtin/translations/id_id.dart`

```dart
// lib/core/translations/id_id.dart

const Map<String, String> idID = {
  // ============================================================
  // General / Common
  // ============================================================
  'app.title': 'Aplikasi Saya',
  'app.description': 'Aplikasi Flutter lengkap dengan GetX',

  // Common actions
  'common.save': 'Simpan',
  'common.cancel': 'Batal',
  'common.delete': 'Hapus',
  'common.edit': 'Ubah',
  'common.add': 'Tambah',
  'common.search': 'Cari',
  'common.filter': 'Filter',
  'common.sort': 'Urutkan',
  'common.refresh': 'Segarkan',
  'common.loading': 'Memuat...',
  'common.retry': 'Coba Lagi',
  'common.confirm': 'Konfirmasi',
  'common.back': 'Kembali',
  'common.next': 'Selanjutnya',
  'common.done': 'Selesai',
  'common.close': 'Tutup',
  'common.yes': 'Ya',
  'common.no': 'Tidak',
  'common.ok': 'OK',
  'common.submit': 'Kirim',
  'common.continue': 'Lanjutkan',
  'common.skip': 'Lewati',
  'common.select_all': 'Pilih Semua',
  'common.deselect_all': 'Batal Pilih Semua',
  'common.no_data': 'Tidak ada data',
  'common.see_all': 'Lihat Semua',
  'common.view_details': 'Lihat Detail',

  // Common labels
  'common.name': 'Nama',
  'common.email': 'Email',
  'common.phone': 'Telepon',
  'common.address': 'Alamat',
  'common.date': 'Tanggal',
  'common.time': 'Waktu',
  'common.status': 'Status',
  'common.description': 'Deskripsi',
  'common.amount': 'Jumlah',
  'common.total': 'Total',
  'common.price': 'Harga',
  'common.quantity': 'Kuantitas',

  // ============================================================
  // Authentication
  // ============================================================
  'auth.login': 'Masuk',
  'auth.logout': 'Keluar',
  'auth.register': 'Daftar',
  'auth.forgot_password': 'Lupa Kata Sandi?',
  'auth.reset_password': 'Atur Ulang Kata Sandi',
  'auth.email_hint': 'Masukkan email Anda',
  'auth.password_hint': 'Masukkan kata sandi Anda',
  'auth.confirm_password': 'Konfirmasi Kata Sandi',
  'auth.login_success': 'Berhasil masuk',
  'auth.login_failed': 'Gagal masuk. Periksa kredensial Anda.',
  'auth.register_success': 'Pendaftaran berhasil! Silakan masuk.',
  'auth.logout_confirm': 'Apakah Anda yakin ingin keluar?',
  'auth.password_mismatch': 'Kata sandi tidak cocok',
  'auth.welcome_back': 'Selamat datang kembali, @name!',
  'auth.new_user': 'Pengguna baru? Buat akun',
  'auth.existing_user': 'Sudah punya akun? Masuk',
  'auth.or_continue_with': 'Atau lanjutkan dengan',
  'auth.terms_agree': 'Dengan melanjutkan, Anda menyetujui Ketentuan Layanan kami',

  // ============================================================
  // Navigation / Menu
  // ============================================================
  'nav.home': 'Beranda',
  'nav.profile': 'Profil',
  'nav.settings': 'Pengaturan',
  'nav.notifications': 'Notifikasi',
  'nav.favorites': 'Favorit',
  'nav.history': 'Riwayat',
  'nav.help': 'Bantuan & Dukungan',
  'nav.about': 'Tentang',
  'nav.dashboard': 'Dasbor',
  'nav.orders': 'Pesanan',
  'nav.products': 'Produk',
  'nav.categories': 'Kategori',
  'nav.cart': 'Keranjang',
  'nav.checkout': 'Pembayaran',

  // ============================================================
  // Settings
  // ============================================================
  'settings.title': 'Pengaturan',
  'settings.language': 'Bahasa',
  'settings.language_subtitle': 'Pilih bahasa yang Anda inginkan',
  'settings.theme': 'Tema',
  'settings.theme_subtitle': 'Pilih tema terang atau gelap',
  'settings.theme_light': 'Terang',
  'settings.theme_dark': 'Gelap',
  'settings.theme_system': 'Sistem',
  'settings.notifications': 'Notifikasi',
  'settings.notifications_subtitle': 'Kelola preferensi notifikasi',
  'settings.push_notifications': 'Notifikasi Push',
  'settings.email_notifications': 'Notifikasi Email',
  'settings.sound': 'Suara',
  'settings.vibration': 'Getaran',
  'settings.privacy': 'Privasi',
  'settings.privacy_subtitle': 'Kelola pengaturan privasi Anda',
  'settings.account': 'Akun',
  'settings.account_subtitle': 'Kelola detail akun Anda',
  'settings.about_app': 'Tentang Aplikasi',
  'settings.version': 'Versi',
  'settings.terms': 'Ketentuan Layanan',
  'settings.privacy_policy': 'Kebijakan Privasi',
  'settings.rate_app': 'Beri Rating Aplikasi',
  'settings.share_app': 'Bagikan Aplikasi',
  'settings.delete_account': 'Hapus Akun',
  'settings.delete_account_confirm':
      'Apakah Anda yakin? Tindakan ini tidak dapat dibatalkan.',
  'settings.cache_cleared': 'Cache berhasil dibersihkan',
  'settings.clear_cache': 'Bersihkan Cache',

  // ============================================================
  // Profile
  // ============================================================
  'profile.title': 'Profil Saya',
  'profile.edit': 'Ubah Profil',
  'profile.update_success': 'Profil berhasil diperbarui',
  'profile.update_failed': 'Gagal memperbarui profil',
  'profile.change_photo': 'Ubah Foto',
  'profile.full_name': 'Nama Lengkap',
  'profile.bio': 'Bio',
  'profile.date_of_birth': 'Tanggal Lahir',
  'profile.gender': 'Jenis Kelamin',
  'profile.gender_male': 'Laki-laki',
  'profile.gender_female': 'Perempuan',
  'profile.gender_other': 'Lainnya',
  'profile.member_since': 'Anggota sejak @date',
  'profile.orders_count': '@count Pesanan',

  // ============================================================
  // Home
  // ============================================================
  'home.greeting_morning': 'Selamat Pagi',
  'home.greeting_afternoon': 'Selamat Siang',
  'home.greeting_evening': 'Selamat Malam',
  'home.featured': 'Unggulan',
  'home.popular': 'Populer',
  'home.recent': 'Terbaru',
  'home.recommended': 'Rekomendasi untuk Anda',
  'home.whats_new': 'Yang Baru',
  'home.trending': 'Sedang Tren',

  // ============================================================
  // Products / Catalog
  // ============================================================
  'product.details': 'Detail Produk',
  'product.add_to_cart': 'Tambah ke Keranjang',
  'product.buy_now': 'Beli Sekarang',
  'product.out_of_stock': 'Stok Habis',
  'product.in_stock': 'Tersedia',
  'product.reviews': 'Ulasan (@count)',
  'product.no_reviews': 'Belum ada ulasan',
  'product.write_review': 'Tulis Ulasan',
  'product.specifications': 'Spesifikasi',
  'product.related': 'Produk Terkait',
  'product.added_to_cart': 'Ditambahkan ke keranjang',
  'product.price_from': 'Mulai dari @price',
  'product.discount': 'Diskon @percent%',

  // ============================================================
  // Cart & Checkout
  // ============================================================
  'cart.title': 'Keranjang Belanja',
  'cart.empty': 'Keranjang Anda kosong',
  'cart.subtotal': 'Subtotal',
  'cart.shipping': 'Ongkos Kirim',
  'cart.tax': 'Pajak',
  'cart.total': 'Total',
  'cart.checkout': 'Lanjut ke Pembayaran',
  'cart.remove_item': 'Hapus item?',
  'cart.item_count': '@count item',
  'cart.free_shipping': 'Gratis Ongkir',

  'checkout.title': 'Pembayaran',
  'checkout.shipping_address': 'Alamat Pengiriman',
  'checkout.payment_method': 'Metode Pembayaran',
  'checkout.order_summary': 'Ringkasan Pesanan',
  'checkout.place_order': 'Buat Pesanan',
  'checkout.order_success': 'Pesanan berhasil dibuat!',
  'checkout.order_id': 'ID Pesanan: @id',

  // ============================================================
  // Orders
  // ============================================================
  'order.title': 'Pesanan Saya',
  'order.empty': 'Belum ada pesanan',
  'order.status_pending': 'Menunggu',
  'order.status_processing': 'Diproses',
  'order.status_shipped': 'Dikirim',
  'order.status_delivered': 'Terkirim',
  'order.status_cancelled': 'Dibatalkan',
  'order.track': 'Lacak Pesanan',
  'order.reorder': 'Pesan Ulang',
  'order.cancel': 'Batalkan Pesanan',
  'order.details': 'Detail Pesanan',

  // ============================================================
  // Notifications
  // ============================================================
  'notification.title': 'Notifikasi',
  'notification.empty': 'Tidak ada notifikasi',
  'notification.mark_read': 'Tandai Sudah Dibaca',
  'notification.mark_all_read': 'Tandai Semua Sudah Dibaca',
  'notification.clear_all': 'Hapus Semua',

  // ============================================================
  // Error Messages
  // ============================================================
  'error.generic': 'Terjadi kesalahan. Silakan coba lagi.',
  'error.network': 'Tidak ada koneksi internet. Periksa jaringan Anda.',
  'error.server': 'Kesalahan server. Silakan coba lagi nanti.',
  'error.timeout': 'Waktu permintaan habis. Silakan coba lagi.',
  'error.not_found': 'Tidak ditemukan',
  'error.unauthorized': 'Tidak diizinkan. Silakan masuk lagi.',
  'error.forbidden': 'Anda tidak memiliki akses untuk ini.',
  'error.validation': 'Periksa input Anda dan coba lagi.',
  'error.empty_field': 'Kolom ini tidak boleh kosong',
  'error.invalid_email': 'Masukkan alamat email yang valid',
  'error.password_too_short': 'Kata sandi minimal 8 karakter',
  'error.unknown': 'Terjadi kesalahan yang tidak diketahui',

  // ============================================================
  // Validation
  // ============================================================
  'validation.required': 'Kolom ini wajib diisi',
  'validation.email': 'Masukkan email yang valid',
  'validation.min_length': 'Minimal @count karakter',
  'validation.max_length': 'Maksimal @count karakter',
  'validation.phone': 'Masukkan nomor telepon yang valid',
  'validation.password_weak':
      'Kata sandi harus mengandung huruf besar, huruf kecil, dan angka',

  // ============================================================
  // Dates & Time
  // ============================================================
  'date.today': 'Hari ini',
  'date.yesterday': 'Kemarin',
  'date.tomorrow': 'Besok',
  'date.days_ago': '@count hari lalu',
  'date.hours_ago': '@count jam lalu',
  'date.minutes_ago': '@count menit lalu',
  'date.just_now': 'Baru saja',

  // ============================================================
  // Language Names
  // ============================================================
  'language.en': 'English',
  'language.id': 'Bahasa Indonesia',
  'language.ms': 'Bahasa Melayu',
  'language.th': 'ภาษาไทย',
  'language.vi': 'Tiếng Việt',
};
```

**File:** `sdlc/flutter-getx/07-translation/option_a_getx_builtin/translations/ms_my.dart`

```dart
// lib/core/translations/ms_my.dart

const Map<String, String> msMY = {
  // ============================================================
  // General / Common
  // ============================================================
  'app.title': 'Aplikasi Saya',
  'app.description': 'Aplikasi Flutter lengkap dengan GetX',

  'common.save': 'Simpan',
  'common.cancel': 'Batal',
  'common.delete': 'Padam',
  'common.edit': 'Sunting',
  'common.add': 'Tambah',
  'common.search': 'Cari',
  'common.filter': 'Tapis',
  'common.sort': 'Susun',
  'common.refresh': 'Muat Semula',
  'common.loading': 'Memuatkan...',
  'common.retry': 'Cuba Lagi',
  'common.confirm': 'Sahkan',
  'common.back': 'Kembali',
  'common.next': 'Seterusnya',
  'common.done': 'Selesai',
  'common.close': 'Tutup',
  'common.yes': 'Ya',
  'common.no': 'Tidak',
  'common.ok': 'OK',
  'common.submit': 'Hantar',
  'common.continue': 'Teruskan',
  'common.skip': 'Langkau',
  'common.select_all': 'Pilih Semua',
  'common.deselect_all': 'Nyahpilih Semua',
  'common.no_data': 'Tiada data',
  'common.see_all': 'Lihat Semua',
  'common.view_details': 'Lihat Butiran',

  'common.name': 'Nama',
  'common.email': 'E-mel',
  'common.phone': 'Telefon',
  'common.address': 'Alamat',
  'common.date': 'Tarikh',
  'common.time': 'Masa',
  'common.status': 'Status',
  'common.description': 'Penerangan',
  'common.amount': 'Jumlah',
  'common.total': 'Jumlah Keseluruhan',
  'common.price': 'Harga',
  'common.quantity': 'Kuantiti',

  // ============================================================
  // Authentication
  // ============================================================
  'auth.login': 'Log Masuk',
  'auth.logout': 'Log Keluar',
  'auth.register': 'Daftar',
  'auth.forgot_password': 'Lupa Kata Laluan?',
  'auth.reset_password': 'Tetapkan Semula Kata Laluan',
  'auth.email_hint': 'Masukkan e-mel anda',
  'auth.password_hint': 'Masukkan kata laluan anda',
  'auth.confirm_password': 'Sahkan Kata Laluan',
  'auth.login_success': 'Berjaya log masuk',
  'auth.login_failed': 'Gagal log masuk. Sila semak kelayakan anda.',
  'auth.register_success': 'Pendaftaran berjaya! Sila log masuk.',
  'auth.logout_confirm': 'Adakah anda pasti mahu log keluar?',
  'auth.password_mismatch': 'Kata laluan tidak sepadan',
  'auth.welcome_back': 'Selamat kembali, @name!',
  'auth.new_user': 'Pengguna baru? Cipta akaun',
  'auth.existing_user': 'Sudah ada akaun? Log masuk',
  'auth.or_continue_with': 'Atau teruskan dengan',
  'auth.terms_agree': 'Dengan meneruskan, anda bersetuju dengan Terma Perkhidmatan kami',

  // ============================================================
  // Navigation / Menu
  // ============================================================
  'nav.home': 'Laman Utama',
  'nav.profile': 'Profil',
  'nav.settings': 'Tetapan',
  'nav.notifications': 'Pemberitahuan',
  'nav.favorites': 'Kegemaran',
  'nav.history': 'Sejarah',
  'nav.help': 'Bantuan & Sokongan',
  'nav.about': 'Mengenai',
  'nav.dashboard': 'Papan Pemuka',
  'nav.orders': 'Pesanan',
  'nav.products': 'Produk',
  'nav.categories': 'Kategori',
  'nav.cart': 'Troli',
  'nav.checkout': 'Bayaran',

  // ============================================================
  // Settings
  // ============================================================
  'settings.title': 'Tetapan',
  'settings.language': 'Bahasa',
  'settings.language_subtitle': 'Pilih bahasa pilihan anda',
  'settings.theme': 'Tema',
  'settings.theme_subtitle': 'Pilih tema cerah atau gelap',
  'settings.theme_light': 'Cerah',
  'settings.theme_dark': 'Gelap',
  'settings.theme_system': 'Sistem',
  'settings.notifications': 'Pemberitahuan',
  'settings.notifications_subtitle': 'Urus keutamaan pemberitahuan',
  'settings.push_notifications': 'Pemberitahuan Tolak',
  'settings.email_notifications': 'Pemberitahuan E-mel',
  'settings.sound': 'Bunyi',
  'settings.vibration': 'Getaran',
  'settings.privacy': 'Privasi',
  'settings.privacy_subtitle': 'Urus tetapan privasi anda',
  'settings.account': 'Akaun',
  'settings.account_subtitle': 'Urus butiran akaun anda',
  'settings.about_app': 'Mengenai Aplikasi',
  'settings.version': 'Versi',
  'settings.terms': 'Terma Perkhidmatan',
  'settings.privacy_policy': 'Dasar Privasi',
  'settings.rate_app': 'Nilai Aplikasi Ini',
  'settings.share_app': 'Kongsi Aplikasi',
  'settings.delete_account': 'Padam Akaun',
  'settings.delete_account_confirm':
      'Adakah anda pasti? Tindakan ini tidak boleh dibatalkan.',
  'settings.cache_cleared': 'Cache berjaya dibersihkan',
  'settings.clear_cache': 'Bersihkan Cache',

  // ============================================================
  // Profile
  // ============================================================
  'profile.title': 'Profil Saya',
  'profile.edit': 'Sunting Profil',
  'profile.update_success': 'Profil berjaya dikemas kini',
  'profile.update_failed': 'Gagal mengemas kini profil',
  'profile.change_photo': 'Tukar Foto',
  'profile.full_name': 'Nama Penuh',
  'profile.bio': 'Bio',
  'profile.date_of_birth': 'Tarikh Lahir',
  'profile.gender': 'Jantina',
  'profile.gender_male': 'Lelaki',
  'profile.gender_female': 'Perempuan',
  'profile.gender_other': 'Lain-lain',
  'profile.member_since': 'Ahli sejak @date',
  'profile.orders_count': '@count Pesanan',

  // ============================================================
  // Home
  // ============================================================
  'home.greeting_morning': 'Selamat Pagi',
  'home.greeting_afternoon': 'Selamat Tengah Hari',
  'home.greeting_evening': 'Selamat Petang',
  'home.featured': 'Terpilih',
  'home.popular': 'Popular',
  'home.recent': 'Terkini',
  'home.recommended': 'Dicadangkan untuk Anda',
  'home.whats_new': 'Apa yang Baru',
  'home.trending': 'Sedang Trending',

  // ============================================================
  // Products / Catalog
  // ============================================================
  'product.details': 'Butiran Produk',
  'product.add_to_cart': 'Tambah ke Troli',
  'product.buy_now': 'Beli Sekarang',
  'product.out_of_stock': 'Kehabisan Stok',
  'product.in_stock': 'Ada Stok',
  'product.reviews': 'Ulasan (@count)',
  'product.no_reviews': 'Tiada ulasan lagi',
  'product.write_review': 'Tulis Ulasan',
  'product.specifications': 'Spesifikasi',
  'product.related': 'Produk Berkaitan',
  'product.added_to_cart': 'Ditambah ke troli',
  'product.price_from': 'Dari @price',
  'product.discount': 'Diskaun @percent%',

  // ============================================================
  // Cart & Checkout
  // ============================================================
  'cart.title': 'Troli Belanja',
  'cart.empty': 'Troli anda kosong',
  'cart.subtotal': 'Subtotal',
  'cart.shipping': 'Penghantaran',
  'cart.tax': 'Cukai',
  'cart.total': 'Jumlah',
  'cart.checkout': 'Teruskan ke Bayaran',
  'cart.remove_item': 'Buang item?',
  'cart.item_count': '@count item',
  'cart.free_shipping': 'Penghantaran Percuma',

  'checkout.title': 'Bayaran',
  'checkout.shipping_address': 'Alamat Penghantaran',
  'checkout.payment_method': 'Kaedah Bayaran',
  'checkout.order_summary': 'Ringkasan Pesanan',
  'checkout.place_order': 'Buat Pesanan',
  'checkout.order_success': 'Pesanan berjaya dibuat!',
  'checkout.order_id': 'ID Pesanan: @id',

  // ============================================================
  // Orders
  // ============================================================
  'order.title': 'Pesanan Saya',
  'order.empty': 'Tiada pesanan lagi',
  'order.status_pending': 'Menunggu',
  'order.status_processing': 'Diproses',
  'order.status_shipped': 'Dihantar',
  'order.status_delivered': 'Telah Dihantar',
  'order.status_cancelled': 'Dibatalkan',
  'order.track': 'Jejak Pesanan',
  'order.reorder': 'Pesan Semula',
  'order.cancel': 'Batalkan Pesanan',
  'order.details': 'Butiran Pesanan',

  // ============================================================
  // Notifications
  // ============================================================
  'notification.title': 'Pemberitahuan',
  'notification.empty': 'Tiada pemberitahuan',
  'notification.mark_read': 'Tanda Sudah Dibaca',
  'notification.mark_all_read': 'Tanda Semua Sudah Dibaca',
  'notification.clear_all': 'Padam Semua',

  // ============================================================
  // Error Messages
  // ============================================================
  'error.generic': 'Sesuatu telah berlaku. Sila cuba lagi.',
  'error.network': 'Tiada sambungan internet. Sila semak rangkaian anda.',
  'error.server': 'Ralat pelayan. Sila cuba lagi kemudian.',
  'error.timeout': 'Permintaan tamat masa. Sila cuba lagi.',
  'error.not_found': 'Tidak dijumpai',
  'error.unauthorized': 'Tidak dibenarkan. Sila log masuk semula.',
  'error.forbidden': 'Anda tidak mempunyai kebenaran untuk mengakses ini.',
  'error.validation': 'Sila semak input anda dan cuba lagi.',
  'error.empty_field': 'Medan ini tidak boleh kosong',
  'error.invalid_email': 'Sila masukkan alamat e-mel yang sah',
  'error.password_too_short': 'Kata laluan mestilah sekurang-kurangnya 8 aksara',
  'error.unknown': 'Ralat yang tidak diketahui berlaku',

  // ============================================================
  // Validation
  // ============================================================
  'validation.required': 'Medan ini diperlukan',
  'validation.email': 'Sila masukkan e-mel yang sah',
  'validation.min_length': 'Mestilah sekurang-kurangnya @count aksara',
  'validation.max_length': 'Mestilah paling banyak @count aksara',
  'validation.phone': 'Sila masukkan nombor telefon yang sah',
  'validation.password_weak':
      'Kata laluan mestilah mengandungi huruf besar, huruf kecil, dan nombor',

  // ============================================================
  // Dates & Time
  // ============================================================
  'date.today': 'Hari ini',
  'date.yesterday': 'Semalam',
  'date.tomorrow': 'Esok',
  'date.days_ago': '@count hari lepas',
  'date.hours_ago': '@count jam lepas',
  'date.minutes_ago': '@count minit lepas',
  'date.just_now': 'Baru sahaja',

  // ============================================================
  // Language Names
  // ============================================================
  'language.en': 'English',
  'language.id': 'Bahasa Indonesia',
  'language.ms': 'Bahasa Melayu',
  'language.th': 'ภาษาไทย',
  'language.vi': 'Tiếng Việt',
};
```

**File:** `sdlc/flutter-getx/07-translation/option_a_getx_builtin/translations/th_th.dart`

```dart
// lib/core/translations/th_th.dart

const Map<String, String> thTH = {
  // ============================================================
  // General / Common
  // ============================================================
  'app.title': 'แอปพลิเคชันของฉัน',
  'app.description': 'แอปพลิเคชัน Flutter พร้อม GetX',

  'common.save': 'บันทึก',
  'common.cancel': 'ยกเลิก',
  'common.delete': 'ลบ',
  'common.edit': 'แก้ไข',
  'common.add': 'เพิ่ม',
  'common.search': 'ค้นหา',
  'common.filter': 'กรอง',
  'common.sort': 'เรียงลำดับ',
  'common.refresh': 'รีเฟรช',
  'common.loading': 'กำลังโหลด...',
  'common.retry': 'ลองอีกครั้ง',
  'common.confirm': 'ยืนยัน',
  'common.back': 'กลับ',
  'common.next': 'ถัดไป',
  'common.done': 'เสร็จสิ้น',
  'common.close': 'ปิด',
  'common.yes': 'ใช่',
  'common.no': 'ไม่',
  'common.ok': 'ตกลง',
  'common.submit': 'ส่ง',
  'common.continue': 'ดำเนินการต่อ',
  'common.skip': 'ข้าม',
  'common.select_all': 'เลือกทั้งหมด',
  'common.deselect_all': 'ยกเลิกเลือกทั้งหมด',
  'common.no_data': 'ไม่มีข้อมูล',
  'common.see_all': 'ดูทั้งหมด',
  'common.view_details': 'ดูรายละเอียด',

  'common.name': 'ชื่อ',
  'common.email': 'อีเมล',
  'common.phone': 'โทรศัพท์',
  'common.address': 'ที่อยู่',
  'common.date': 'วันที่',
  'common.time': 'เวลา',
  'common.status': 'สถานะ',
  'common.description': 'คำอธิบาย',
  'common.amount': 'จำนวน',
  'common.total': 'รวม',
  'common.price': 'ราคา',
  'common.quantity': 'ปริมาณ',

  // ============================================================
  // Authentication
  // ============================================================
  'auth.login': 'เข้าสู่ระบบ',
  'auth.logout': 'ออกจากระบบ',
  'auth.register': 'สมัครสมาชิก',
  'auth.forgot_password': 'ลืมรหัสผ่าน?',
  'auth.reset_password': 'รีเซ็ตรหัสผ่าน',
  'auth.email_hint': 'กรอกอีเมลของคุณ',
  'auth.password_hint': 'กรอกรหัสผ่านของคุณ',
  'auth.confirm_password': 'ยืนยันรหัสผ่าน',
  'auth.login_success': 'เข้าสู่ระบบสำเร็จ',
  'auth.login_failed': 'เข้าสู่ระบบไม่สำเร็จ กรุณาตรวจสอบข้อมูลของคุณ',
  'auth.register_success': 'สมัครสมาชิกสำเร็จ! กรุณาเข้าสู่ระบบ',
  'auth.logout_confirm': 'คุณแน่ใจหรือไม่ว่าต้องการออกจากระบบ?',
  'auth.password_mismatch': 'รหัสผ่านไม่ตรงกัน',
  'auth.welcome_back': 'ยินดีต้อนรับกลับ, @name!',
  'auth.new_user': 'ผู้ใช้ใหม่? สร้างบัญชี',
  'auth.existing_user': 'มีบัญชีแล้ว? เข้าสู่ระบบ',
  'auth.or_continue_with': 'หรือดำเนินการต่อด้วย',
  'auth.terms_agree': 'เมื่อดำเนินการต่อ คุณยอมรับข้อกำหนดการใช้งานของเรา',

  // ============================================================
  // Navigation / Menu
  // ============================================================
  'nav.home': 'หน้าหลัก',
  'nav.profile': 'โปรไฟล์',
  'nav.settings': 'ตั้งค่า',
  'nav.notifications': 'การแจ้งเตือน',
  'nav.favorites': 'รายการโปรด',
  'nav.history': 'ประวัติ',
  'nav.help': 'ช่วยเหลือและสนับสนุน',
  'nav.about': 'เกี่ยวกับ',
  'nav.dashboard': 'แดชบอร์ด',
  'nav.orders': 'คำสั่งซื้อ',
  'nav.products': 'สินค้า',
  'nav.categories': 'หมวดหมู่',
  'nav.cart': 'ตะกร้า',
  'nav.checkout': 'ชำระเงิน',

  // ============================================================
  // Settings
  // ============================================================
  'settings.title': 'ตั้งค่า',
  'settings.language': 'ภาษา',
  'settings.language_subtitle': 'เลือกภาษาที่คุณต้องการ',
  'settings.theme': 'ธีม',
  'settings.theme_subtitle': 'เลือกธีมสว่างหรือมืด',
  'settings.theme_light': 'สว่าง',
  'settings.theme_dark': 'มืด',
  'settings.theme_system': 'ระบบ',
  'settings.notifications': 'การแจ้งเตือน',
  'settings.notifications_subtitle': 'จัดการการตั้งค่าการแจ้งเตือน',
  'settings.push_notifications': 'การแจ้งเตือนแบบพุช',
  'settings.email_notifications': 'การแจ้งเตือนทางอีเมล',
  'settings.sound': 'เสียง',
  'settings.vibration': 'สั่น',
  'settings.privacy': 'ความเป็นส่วนตัว',
  'settings.privacy_subtitle': 'จัดการการตั้งค่าความเป็นส่วนตัว',
  'settings.account': 'บัญชี',
  'settings.account_subtitle': 'จัดการรายละเอียดบัญชีของคุณ',
  'settings.about_app': 'เกี่ยวกับแอป',
  'settings.version': 'เวอร์ชัน',
  'settings.terms': 'ข้อกำหนดการใช้งาน',
  'settings.privacy_policy': 'นโยบายความเป็นส่วนตัว',
  'settings.rate_app': 'ให้คะแนนแอปนี้',
  'settings.share_app': 'แชร์แอป',
  'settings.delete_account': 'ลบบัญชี',
  'settings.delete_account_confirm':
      'คุณแน่ใจหรือไม่? การดำเนินการนี้ไม่สามารถยกเลิกได้',
  'settings.cache_cleared': 'ล้างแคชสำเร็จ',
  'settings.clear_cache': 'ล้างแคช',

  // ============================================================
  // Profile
  // ============================================================
  'profile.title': 'โปรไฟล์ของฉัน',
  'profile.edit': 'แก้ไขโปรไฟล์',
  'profile.update_success': 'อัปเดตโปรไฟล์สำเร็จ',
  'profile.update_failed': 'อัปเดตโปรไฟล์ไม่สำเร็จ',
  'profile.change_photo': 'เปลี่ยนรูปภาพ',
  'profile.full_name': 'ชื่อเต็ม',
  'profile.bio': 'ประวัติย่อ',
  'profile.date_of_birth': 'วันเกิด',
  'profile.gender': 'เพศ',
  'profile.gender_male': 'ชาย',
  'profile.gender_female': 'หญิง',
  'profile.gender_other': 'อื่นๆ',
  'profile.member_since': 'สมาชิกตั้งแต่ @date',
  'profile.orders_count': '@count คำสั่งซื้อ',

  // ============================================================
  // Home
  // ============================================================
  'home.greeting_morning': 'สวัสดีตอนเช้า',
  'home.greeting_afternoon': 'สวัสดีตอนบ่าย',
  'home.greeting_evening': 'สวัสดีตอนเย็น',
  'home.featured': 'แนะนำ',
  'home.popular': 'ยอดนิยม',
  'home.recent': 'ล่าสุด',
  'home.recommended': 'แนะนำสำหรับคุณ',
  'home.whats_new': 'มีอะไรใหม่',
  'home.trending': 'กำลังเทรนด์',

  // ============================================================
  // Products / Catalog
  // ============================================================
  'product.details': 'รายละเอียดสินค้า',
  'product.add_to_cart': 'เพิ่มลงตะกร้า',
  'product.buy_now': 'ซื้อเลย',
  'product.out_of_stock': 'สินค้าหมด',
  'product.in_stock': 'มีสินค้า',
  'product.reviews': 'รีวิว (@count)',
  'product.no_reviews': 'ยังไม่มีรีวิว',
  'product.write_review': 'เขียนรีวิว',
  'product.specifications': 'สเปค',
  'product.related': 'สินค้าที่เกี่ยวข้อง',
  'product.added_to_cart': 'เพิ่มลงตะกร้าแล้ว',
  'product.price_from': 'เริ่มต้นที่ @price',
  'product.discount': 'ลด @percent%',

  // ============================================================
  // Cart & Checkout
  // ============================================================
  'cart.title': 'ตะกร้าสินค้า',
  'cart.empty': 'ตะกร้าของคุณว่าง',
  'cart.subtotal': 'ยอดรวมย่อย',
  'cart.shipping': 'ค่าจัดส่ง',
  'cart.tax': 'ภาษี',
  'cart.total': 'รวมทั้งหมด',
  'cart.checkout': 'ดำเนินการชำระเงิน',
  'cart.remove_item': 'ลบสินค้า?',
  'cart.item_count': '@count รายการ',
  'cart.free_shipping': 'ส่งฟรี',

  'checkout.title': 'ชำระเงิน',
  'checkout.shipping_address': 'ที่อยู่จัดส่ง',
  'checkout.payment_method': 'วิธีการชำระเงิน',
  'checkout.order_summary': 'สรุปคำสั่งซื้อ',
  'checkout.place_order': 'สั่งซื้อ',
  'checkout.order_success': 'สั่งซื้อสำเร็จ!',
  'checkout.order_id': 'รหัสคำสั่งซื้อ: @id',

  // ============================================================
  // Orders
  // ============================================================
  'order.title': 'คำสั่งซื้อของฉัน',
  'order.empty': 'ยังไม่มีคำสั่งซื้อ',
  'order.status_pending': 'รอดำเนินการ',
  'order.status_processing': 'กำลังดำเนินการ',
  'order.status_shipped': 'จัดส่งแล้ว',
  'order.status_delivered': 'ส่งถึงแล้ว',
  'order.status_cancelled': 'ยกเลิกแล้ว',
  'order.track': 'ติดตามคำสั่งซื้อ',
  'order.reorder': 'สั่งซื้ออีกครั้ง',
  'order.cancel': 'ยกเลิกคำสั่งซื้อ',
  'order.details': 'รายละเอียดคำสั่งซื้อ',

  // ============================================================
  // Notifications
  // ============================================================
  'notification.title': 'การแจ้งเตือน',
  'notification.empty': 'ไม่มีการแจ้งเตือน',
  'notification.mark_read': 'ทำเครื่องหมายว่าอ่านแล้ว',
  'notification.mark_all_read': 'ทำเครื่องหมายทั้งหมดว่าอ่านแล้ว',
  'notification.clear_all': 'ล้างทั้งหมด',

  // ============================================================
  // Error Messages
  // ============================================================
  'error.generic': 'เกิดข้อผิดพลาด กรุณาลองอีกครั้ง',
  'error.network': 'ไม่มีการเชื่อมต่ออินเทอร์เน็ต กรุณาตรวจสอบเครือข่าย',
  'error.server': 'เซิร์ฟเวอร์ผิดพลาด กรุณาลองอีกครั้งภายหลัง',
  'error.timeout': 'หมดเวลาคำขอ กรุณาลองอีกครั้ง',
  'error.not_found': 'ไม่พบ',
  'error.unauthorized': 'ไม่ได้รับอนุญาต กรุณาเข้าสู่ระบบอีกครั้ง',
  'error.forbidden': 'คุณไม่มีสิทธิ์เข้าถึง',
  'error.validation': 'กรุณาตรวจสอบข้อมูลของคุณแล้วลองอีกครั้ง',
  'error.empty_field': 'ช่องนี้ไม่สามารถเว้นว่างได้',
  'error.invalid_email': 'กรุณากรอกอีเมลที่ถูกต้อง',
  'error.password_too_short': 'รหัสผ่านต้องมีอย่างน้อย 8 ตัวอักษร',
  'error.unknown': 'เกิดข้อผิดพลาดที่ไม่ทราบสาเหตุ',

  // ============================================================
  // Validation
  // ============================================================
  'validation.required': 'จำเป็นต้องกรอกช่องนี้',
  'validation.email': 'กรุณากรอกอีเมลที่ถูกต้อง',
  'validation.min_length': 'ต้องมีอย่างน้อย @count ตัวอักษร',
  'validation.max_length': 'ต้องไม่เกิน @count ตัวอักษร',
  'validation.phone': 'กรุณากรอกหมายเลขโทรศัพท์ที่ถูกต้อง',
  'validation.password_weak':
      'รหัสผ่านต้องประกอบด้วยตัวพิมพ์ใหญ่ ตัวพิมพ์เล็ก และตัวเลข',

  // ============================================================
  // Dates & Time
  // ============================================================
  'date.today': 'วันนี้',
  'date.yesterday': 'เมื่อวาน',
  'date.tomorrow': 'พรุ่งนี้',
  'date.days_ago': '@count วันที่แล้ว',
  'date.hours_ago': '@count ชั่วโมงที่แล้ว',
  'date.minutes_ago': '@count นาทีที่แล้ว',
  'date.just_now': 'เมื่อสักครู่',

  // ============================================================
  // Language Names
  // ============================================================
  'language.en': 'English',
  'language.id': 'Bahasa Indonesia',
  'language.ms': 'Bahasa Melayu',
  'language.th': 'ภาษาไทย',
  'language.vi': 'Tiếng Việt',
};
```

**File:** `sdlc/flutter-getx/07-translation/option_a_getx_builtin/translations/vn_vn.dart`

```dart
// lib/core/translations/vn_vn.dart

const Map<String, String> viVN = {
  // ============================================================
  // General / Common
  // ============================================================
  'app.title': 'Ứng dụng của tôi',
  'app.description': 'Ứng dụng Flutter hoàn chỉnh với GetX',

  'common.save': 'Lưu',
  'common.cancel': 'Hủy',
  'common.delete': 'Xóa',
  'common.edit': 'Sửa',
  'common.add': 'Thêm',
  'common.search': 'Tìm kiếm',
  'common.filter': 'Lọc',
  'common.sort': 'Sắp xếp',
  'common.refresh': 'Làm mới',
  'common.loading': 'Đang tải...',
  'common.retry': 'Thử lại',
  'common.confirm': 'Xác nhận',
  'common.back': 'Quay lại',
  'common.next': 'Tiếp theo',
  'common.done': 'Hoàn thành',
  'common.close': 'Đóng',
  'common.yes': 'Có',
  'common.no': 'Không',
  'common.ok': 'OK',
  'common.submit': 'Gửi',
  'common.continue': 'Tiếp tục',
  'common.skip': 'Bỏ qua',
  'common.select_all': 'Chọn tất cả',
  'common.deselect_all': 'Bỏ chọn tất cả',
  'common.no_data': 'Không có dữ liệu',
  'common.see_all': 'Xem tất cả',
  'common.view_details': 'Xem chi tiết',

  'common.name': 'Tên',
  'common.email': 'Email',
  'common.phone': 'Điện thoại',
  'common.address': 'Địa chỉ',
  'common.date': 'Ngày',
  'common.time': 'Thời gian',
  'common.status': 'Trạng thái',
  'common.description': 'Mô tả',
  'common.amount': 'Số lượng',
  'common.total': 'Tổng cộng',
  'common.price': 'Giá',
  'common.quantity': 'Số lượng',

  // ============================================================
  // Authentication
  // ============================================================
  'auth.login': 'Đăng nhập',
  'auth.logout': 'Đăng xuất',
  'auth.register': 'Đăng ký',
  'auth.forgot_password': 'Quên mật khẩu?',
  'auth.reset_password': 'Đặt lại mật khẩu',
  'auth.email_hint': 'Nhập email của bạn',
  'auth.password_hint': 'Nhập mật khẩu của bạn',
  'auth.confirm_password': 'Xác nhận mật khẩu',
  'auth.login_success': 'Đăng nhập thành công',
  'auth.login_failed': 'Đăng nhập thất bại. Vui lòng kiểm tra lại.',
  'auth.register_success': 'Đăng ký thành công! Vui lòng đăng nhập.',
  'auth.logout_confirm': 'Bạn có chắc muốn đăng xuất?',
  'auth.password_mismatch': 'Mật khẩu không khớp',
  'auth.welcome_back': 'Chào mừng trở lại, @name!',
  'auth.new_user': 'Người dùng mới? Tạo tài khoản',
  'auth.existing_user': 'Đã có tài khoản? Đăng nhập',
  'auth.or_continue_with': 'Hoặc tiếp tục với',
  'auth.terms_agree': 'Bằng cách tiếp tục, bạn đồng ý với Điều khoản dịch vụ',

  // ============================================================
  // Navigation / Menu
  // ============================================================
  'nav.home': 'Trang chủ',
  'nav.profile': 'Hồ sơ',
  'nav.settings': 'Cài đặt',
  'nav.notifications': 'Thông báo',
  'nav.favorites': 'Yêu thích',
  'nav.history': 'Lịch sử',
  'nav.help': 'Trợ giúp & Hỗ trợ',
  'nav.about': 'Giới thiệu',
  'nav.dashboard': 'Bảng điều khiển',
  'nav.orders': 'Đơn hàng',
  'nav.products': 'Sản phẩm',
  'nav.categories': 'Danh mục',
  'nav.cart': 'Giỏ hàng',
  'nav.checkout': 'Thanh toán',

  // ============================================================
  // Settings
  // ============================================================
  'settings.title': 'Cài đặt',
  'settings.language': 'Ngôn ngữ',
  'settings.language_subtitle': 'Chọn ngôn ngữ bạn muốn',
  'settings.theme': 'Giao diện',
  'settings.theme_subtitle': 'Chọn giao diện sáng hoặc tối',
  'settings.theme_light': 'Sáng',
  'settings.theme_dark': 'Tối',
  'settings.theme_system': 'Hệ thống',
  'settings.notifications': 'Thông báo',
  'settings.notifications_subtitle': 'Quản lý cài đặt thông báo',
  'settings.push_notifications': 'Thông báo đẩy',
  'settings.email_notifications': 'Thông báo qua email',
  'settings.sound': 'Âm thanh',
  'settings.vibration': 'Rung',
  'settings.privacy': 'Quyền riêng tư',
  'settings.privacy_subtitle': 'Quản lý cài đặt quyền riêng tư',
  'settings.account': 'Tài khoản',
  'settings.account_subtitle': 'Quản lý chi tiết tài khoản',
  'settings.about_app': 'Về ứng dụng',
  'settings.version': 'Phiên bản',
  'settings.terms': 'Điều khoản dịch vụ',
  'settings.privacy_policy': 'Chính sách bảo mật',
  'settings.rate_app': 'Đánh giá ứng dụng',
  'settings.share_app': 'Chia sẻ ứng dụng',
  'settings.delete_account': 'Xóa tài khoản',
  'settings.delete_account_confirm':
      'Bạn có chắc không? Hành động này không thể hoàn tác.',
  'settings.cache_cleared': 'Đã xóa bộ nhớ đệm thành công',
  'settings.clear_cache': 'Xóa bộ nhớ đệm',

  // ============================================================
  // Profile
  // ============================================================
  'profile.title': 'Hồ sơ của tôi',
  'profile.edit': 'Chỉnh sửa hồ sơ',
  'profile.update_success': 'Cập nhật hồ sơ thành công',
  'profile.update_failed': 'Cập nhật hồ sơ thất bại',
  'profile.change_photo': 'Đổi ảnh',
  'profile.full_name': 'Họ và tên',
  'profile.bio': 'Tiểu sử',
  'profile.date_of_birth': 'Ngày sinh',
  'profile.gender': 'Giới tính',
  'profile.gender_male': 'Nam',
  'profile.gender_female': 'Nữ',
  'profile.gender_other': 'Khác',
  'profile.member_since': 'Thành viên từ @date',
  'profile.orders_count': '@count Đơn hàng',

  // ============================================================
  // Home
  // ============================================================
  'home.greeting_morning': 'Chào buổi sáng',
  'home.greeting_afternoon': 'Chào buổi chiều',
  'home.greeting_evening': 'Chào buổi tối',
  'home.featured': 'Nổi bật',
  'home.popular': 'Phổ biến',
  'home.recent': 'Gần đây',
  'home.recommended': 'Đề xuất cho bạn',
  'home.whats_new': 'Có gì mới',
  'home.trending': 'Xu hướng',

  // ============================================================
  // Products / Catalog
  // ============================================================
  'product.details': 'Chi tiết sản phẩm',
  'product.add_to_cart': 'Thêm vào giỏ',
  'product.buy_now': 'Mua ngay',
  'product.out_of_stock': 'Hết hàng',
  'product.in_stock': 'Còn hàng',
  'product.reviews': 'Đánh giá (@count)',
  'product.no_reviews': 'Chưa có đánh giá',
  'product.write_review': 'Viết đánh giá',
  'product.specifications': 'Thông số kỹ thuật',
  'product.related': 'Sản phẩm liên quan',
  'product.added_to_cart': 'Đã thêm vào giỏ hàng',
  'product.price_from': 'Từ @price',
  'product.discount': 'Giảm @percent%',

  // ============================================================
  // Cart & Checkout
  // ============================================================
  'cart.title': 'Giỏ hàng',
  'cart.empty': 'Giỏ hàng trống',
  'cart.subtotal': 'Tạm tính',
  'cart.shipping': 'Phí vận chuyển',
  'cart.tax': 'Thuế',
  'cart.total': 'Tổng cộng',
  'cart.checkout': 'Tiến hành thanh toán',
  'cart.remove_item': 'Xóa sản phẩm?',
  'cart.item_count': '@count sản phẩm',
  'cart.free_shipping': 'Miễn phí vận chuyển',

  'checkout.title': 'Thanh toán',
  'checkout.shipping_address': 'Địa chỉ giao hàng',
  'checkout.payment_method': 'Phương thức thanh toán',
  'checkout.order_summary': 'Tóm tắt đơn hàng',
  'checkout.place_order': 'Đặt hàng',
  'checkout.order_success': 'Đặt hàng thành công!',
  'checkout.order_id': 'Mã đơn hàng: @id',

  // ============================================================
  // Orders
  // ============================================================
  'order.title': 'Đơn hàng của tôi',
  'order.empty': 'Chưa có đơn hàng',
  'order.status_pending': 'Chờ xử lý',
  'order.status_processing': 'Đang xử lý',
  'order.status_shipped': 'Đã gửi',
  'order.status_delivered': 'Đã giao',
  'order.status_cancelled': 'Đã hủy',
  'order.track': 'Theo dõi đơn hàng',
  'order.reorder': 'Đặt lại',
  'order.cancel': 'Hủy đơn hàng',
  'order.details': 'Chi tiết đơn hàng',

  // ============================================================
  // Notifications
  // ============================================================
  'notification.title': 'Thông báo',
  'notification.empty': 'Không có thông báo',
  'notification.mark_read': 'Đánh dấu đã đọc',
  'notification.mark_all_read': 'Đánh dấu tất cả đã đọc',
  'notification.clear_all': 'Xóa tất cả',

  // ============================================================
  // Error Messages
  // ============================================================
  'error.generic': 'Đã xảy ra lỗi. Vui lòng thử lại.',
  'error.network': 'Không có kết nối internet. Vui lòng kiểm tra mạng.',
  'error.server': 'Lỗi máy chủ. Vui lòng thử lại sau.',
  'error.timeout': 'Yêu cầu hết thời gian. Vui lòng thử lại.',
  'error.not_found': 'Không tìm thấy',
  'error.unauthorized': 'Không được phép. Vui lòng đăng nhập lại.',
  'error.forbidden': 'Bạn không có quyền truy cập.',
  'error.validation': 'Vui lòng kiểm tra lại thông tin và thử lại.',
  'error.empty_field': 'Trường này không được để trống',
  'error.invalid_email': 'Vui lòng nhập địa chỉ email hợp lệ',
  'error.password_too_short': 'Mật khẩu phải có ít nhất 8 ký tự',
  'error.unknown': 'Đã xảy ra lỗi không xác định',

  // ============================================================
  // Validation
  // ============================================================
  'validation.required': 'Trường này là bắt buộc',
  'validation.email': 'Vui lòng nhập email hợp lệ',
  'validation.min_length': 'Phải có ít nhất @count ký tự',
  'validation.max_length': 'Phải có tối đa @count ký tự',
  'validation.phone': 'Vui lòng nhập số điện thoại hợp lệ',
  'validation.password_weak':
      'Mật khẩu phải chứa chữ hoa, chữ thường và số',

  // ============================================================
  // Dates & Time
  // ============================================================
  'date.today': 'Hôm nay',
  'date.yesterday': 'Hôm qua',
  'date.tomorrow': 'Ngày mai',
  'date.days_ago': '@count ngày trước',
  'date.hours_ago': '@count giờ trước',
  'date.minutes_ago': '@count phút trước',
  'date.just_now': 'Vừa xong',

  // ============================================================
  // Language Names
  // ============================================================
  'language.en': 'English',
  'language.id': 'Bahasa Indonesia',
  'language.ms': 'Bahasa Melayu',
  'language.th': 'ภาษาไทย',
  'language.vi': 'Tiếng Việt',
};
```

#### 2.2 AppTranslations Class

Class utama yang menggabungkan semua translation maps ke dalam satu registry
yang dikenali oleh GetX.

**File:** `sdlc/flutter-getx/07-translation/option_a_getx_builtin/app_translations.dart`

```dart
// lib/core/translations/app_translations.dart

import 'package:get/get.dart';

import 'translations/en_us.dart';
import 'translations/id_id.dart';
import 'translations/ms_my.dart';
import 'translations/th_th.dart';
import 'translations/vn_vn.dart';

/// Kelas utama translation GetX.
///
/// Class ini meng-extend [Translations] bawaan GetX dan mendaftarkan
/// semua bahasa yang didukung. GetX akan otomatis me-resolve
/// translation string berdasarkan locale aktif.
///
/// Usage: `'key'.tr` — tanpa parentheses, beda dengan easy_localization.
class AppTranslations extends Translations {
  /// Daftar semua locale yang didukung oleh aplikasi.
  /// Digunakan untuk validasi dan UI language selector.
  static const supportedLocales = [
    Locale('en', 'US'),
    Locale('id', 'ID'),
    Locale('ms', 'MY'),
    Locale('th', 'TH'),
    Locale('vi', 'VN'),
  ];

  /// Default locale — fallback jika locale device tidak didukung.
  static const fallbackLocale = Locale('en', 'US');

  /// Map locale ke display name (dalam bahasa asli masing-masing).
  /// Berguna untuk language selector UI.
  static const localeDisplayNames = {
    'en_US': 'English',
    'id_ID': 'Bahasa Indonesia',
    'ms_MY': 'Bahasa Melayu',
    'th_TH': 'ภาษาไทย',
    'vi_VN': 'Tiếng Việt',
  };

  /// Map locale ke flag emoji untuk UI.
  static const localeFlags = {
    'en_US': '🇺🇸',
    'id_ID': '🇮🇩',
    'ms_MY': '🇲🇾',
    'th_TH': '🇹🇭',
    'vi_VN': '🇻🇳',
  };

  @override
  Map<String, Map<String, String>> get keys => {
        'en_US': enUS,
        'id_ID': idID,
        'ms_MY': msMY,
        'th_TH': thTH,
        'vi_VN': viVN,
      };
}
```

---

### 3. Option B: Easy Localization (Alternative)

Jika tim sudah familiar dengan `easy_localization` atau project sudah
menggunakannya, GetX tetap compatible. Pendekatan ini menggunakan JSON files
di folder assets, sama seperti versi Riverpod.

> **Perbedaan penting:** Dengan easy_localization, extension method-nya adalah
> `'key'.tr()` (dengan parentheses), sedangkan GetX built-in menggunakan
> `'key'.tr` (tanpa parentheses). Jangan campur keduanya di satu project.

#### 3.1 Setup

**File:** `sdlc/flutter-getx/07-translation/option_b_easy_localization/setup.dart`

```dart
// main.dart — setup easy_localization dengan GetX

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:easy_localization/easy_localization.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  runApp(
    EasyLocalization(
      supportedLocales: const [
        Locale('en'),
        Locale('id'),
        Locale('ms'),
        Locale('th'),
        Locale('vi'),
      ],
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // PENTING: Dengan easy_localization, JANGAN set `translations:` di
    // GetMaterialApp. Biarkan easy_localization yang handle.
    return GetMaterialApp(
      // easy_localization properties:
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,

      // Jangan gunakan translations: AppTranslations() di sini
      // karena akan konflik dengan easy_localization.

      title: 'app.title'.tr(), // Perhatikan: .tr() bukan .tr
      home: const HomeScreen(),
    );
  }
}
```

#### 3.2 JSON Translation Files

Simpan di `assets/translations/`. Format standar easy_localization.

```
assets/
└── translations/
    ├── en.json
    ├── id.json
    ├── ms.json
    ├── th.json
    └── vi.json
```

```json
// assets/translations/en.json (contoh partial)
{
  "app": {
    "title": "My Application"
  },
  "common": {
    "save": "Save",
    "cancel": "Cancel",
    "delete": "Delete"
  },
  "auth": {
    "login": "Login",
    "logout": "Logout"
  }
}
```

#### 3.3 Locale Controller untuk Easy Localization

```dart
// lib/features/settings/controllers/locale_controller_easy.dart

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

/// Controller locale untuk pendekatan easy_localization.
///
/// Perbedaan: menggunakan context.setLocale() dari easy_localization
/// bukan Get.updateLocale() dari GetX.
class LocaleEasyController extends GetxController {
  final _storage = GetStorage();
  static const _storageKey = 'locale_easy';

  final currentLocaleCode = 'en'.obs;

  @override
  void onInit() {
    super.onInit();
    _loadSavedLocale();
  }

  void _loadSavedLocale() {
    final saved = _storage.read<String>(_storageKey);
    if (saved != null) {
      currentLocaleCode.value = saved;
    }
  }

  /// Ganti locale via easy_localization.
  /// Butuh BuildContext karena easy_localization menyimpan state di widget tree.
  void changeLocale(BuildContext context, String languageCode) {
    final locale = Locale(languageCode);
    context.setLocale(locale);
    currentLocaleCode.value = languageCode;
    _storage.write(_storageKey, languageCode);
  }
}
```

> **Rekomendasi:** Untuk project GetX, gunakan **Option A** (GetX Built-in).
> Option B hanya direkomendasikan jika ada kebutuhan spesifik seperti plural
> forms, gender support, atau linked translations yang belum didukung GetX
> built-in.

---

### 4. GetMaterialApp Configuration

Konfigurasi translation di `GetMaterialApp`. Ini hanya untuk **Option A**
(GetX Built-in).

**File:** `sdlc/flutter-getx/07-translation/option_a_getx_builtin/main_config.dart`

```dart
// lib/main.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'core/translations/app_translations.dart';
import 'features/settings/controllers/locale_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi GetStorage sebelum app start
  await GetStorage.init();

  // Register LocaleController sebelum GetMaterialApp di-build
  // supaya locale bisa di-load dari storage sebelum UI render.
  Get.put(LocaleController(), permanent: true);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final localeController = Get.find<LocaleController>();

    return GetMaterialApp(
      // ============================================================
      // Translation Configuration
      // ============================================================

      /// Instance dari AppTranslations yang berisi semua translation maps.
      translations: AppTranslations(),

      /// Locale awal. Akan di-override oleh LocaleController jika
      /// user sudah pernah memilih bahasa sebelumnya.
      locale: localeController.currentLocale,

      /// Fallback jika locale aktif tidak ditemukan di translation map.
      /// Pastikan bahasa ini punya translation lengkap.
      fallbackLocale: AppTranslations.fallbackLocale,

      // ============================================================
      // App Configuration
      // ============================================================
      title: 'app.title',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.blue,
        useMaterial3: true,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        colorSchemeSeed: Colors.blue,
        useMaterial3: true,
        brightness: Brightness.dark,
      ),

      // Initial route
      home: const HomeScreen(),

      // GetX named routes (optional, sesuaikan dengan project)
      // getPages: AppPages.routes,
    );
  }
}
```

---

### 5. Locale Controller (GetX)

Controller utama untuk mengelola locale. Menggunakan `GetxController` dengan
reactive state `Rx<Locale>` dan persistensi via `GetStorage`.

**File:** `sdlc/flutter-getx/07-translation/option_a_getx_builtin/locale_controller.dart`

```dart
// lib/features/settings/controllers/locale_controller.dart

import 'dart:ui';

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../../../core/translations/app_translations.dart';

/// Model sederhana untuk merepresentasikan satu bahasa di UI.
class LanguageOption {
  final Locale locale;
  final String displayName;
  final String flag;
  final String nativeName;

  const LanguageOption({
    required this.locale,
    required this.displayName,
    required this.flag,
    required this.nativeName,
  });

  /// Key untuk GetStorage (format: 'en_US')
  String get storageKey =>
      '${locale.languageCode}_${locale.countryCode}';
}

/// Controller untuk mengelola locale/bahasa aplikasi.
///
/// Fitur:
/// - Reactive locale dengan `Rx<Locale>`
/// - Persistensi ke GetStorage (survive app restart)
/// - Load saved locale saat `onInit()`
/// - Daftar bahasa yang didukung untuk language selector
///
/// Perbedaan dengan Riverpod:
/// - Riverpod: `@riverpod` + `ref.watch()` + `SharedPreferences`
/// - GetX: `GetxController` + `Obx()` + `GetStorage`
class LocaleController extends GetxController {
  // ---------------------------------------------------------------------------
  // Storage
  // ---------------------------------------------------------------------------
  final _storage = GetStorage();
  static const _storageKey = 'selected_locale';

  // ---------------------------------------------------------------------------
  // Reactive State
  // ---------------------------------------------------------------------------

  /// Locale aktif saat ini. Reactive — semua widget yang wrap dengan
  /// `Obx()` akan auto-rebuild saat nilai ini berubah.
  final _locale = AppTranslations.fallbackLocale.obs;

  /// Getter untuk locale saat ini.
  Locale get currentLocale => _locale.value;

  /// Getter untuk locale code (format: 'en_US').
  String get currentLocaleCode =>
      '${_locale.value.languageCode}_${_locale.value.countryCode}';

  // ---------------------------------------------------------------------------
  // Available Languages
  // ---------------------------------------------------------------------------

  /// Daftar semua bahasa yang tersedia untuk dipilih user.
  final List<LanguageOption> availableLanguages = const [
    LanguageOption(
      locale: Locale('en', 'US'),
      displayName: 'English',
      flag: '🇺🇸',
      nativeName: 'English',
    ),
    LanguageOption(
      locale: Locale('id', 'ID'),
      displayName: 'Indonesian',
      flag: '🇮🇩',
      nativeName: 'Bahasa Indonesia',
    ),
    LanguageOption(
      locale: Locale('ms', 'MY'),
      displayName: 'Malay',
      flag: '🇲🇾',
      nativeName: 'Bahasa Melayu',
    ),
    LanguageOption(
      locale: Locale('th', 'TH'),
      displayName: 'Thai',
      flag: '🇹🇭',
      nativeName: 'ภาษาไทย',
    ),
    LanguageOption(
      locale: Locale('vi', 'VN'),
      displayName: 'Vietnamese',
      flag: '🇻🇳',
      nativeName: 'Tiếng Việt',
    ),
  ];

  // ---------------------------------------------------------------------------
  // Lifecycle
  // ---------------------------------------------------------------------------

  @override
  void onInit() {
    super.onInit();
    _loadSavedLocale();
  }

  // ---------------------------------------------------------------------------
  // Private Methods
  // ---------------------------------------------------------------------------

  /// Load locale yang tersimpan dari GetStorage.
  /// Jika tidak ada yang tersimpan, gunakan fallback locale.
  void _loadSavedLocale() {
    final savedLocaleCode = _storage.read<String>(_storageKey);

    if (savedLocaleCode != null) {
      final parts = savedLocaleCode.split('_');
      if (parts.length == 2) {
        final savedLocale = Locale(parts[0], parts[1]);

        // Validasi: pastikan locale yang tersimpan masih didukung
        final isSupported = AppTranslations.supportedLocales.any(
          (l) =>
              l.languageCode == savedLocale.languageCode &&
              l.countryCode == savedLocale.countryCode,
        );

        if (isSupported) {
          _locale.value = savedLocale;
          Get.updateLocale(savedLocale);
          return;
        }
      }
    }

    // Jika tidak ada saved locale, coba match dengan device locale
    _matchDeviceLocale();
  }

  /// Coba cocokkan locale device dengan bahasa yang didukung.
  /// Fallback ke default jika tidak ada yang cocok.
  void _matchDeviceLocale() {
    final deviceLocale = Get.deviceLocale;
    if (deviceLocale != null) {
      for (final supported in AppTranslations.supportedLocales) {
        if (supported.languageCode == deviceLocale.languageCode) {
          _locale.value = supported;
          Get.updateLocale(supported);
          return;
        }
      }
    }
    // Tidak perlu update — sudah pakai fallback locale
  }

  // ---------------------------------------------------------------------------
  // Public Methods
  // ---------------------------------------------------------------------------

  /// Ganti locale aplikasi.
  ///
  /// Method ini:
  /// 1. Update reactive state `_locale`
  /// 2. Panggil `Get.updateLocale()` untuk trigger rebuild seluruh app
  /// 3. Simpan pilihan ke GetStorage untuk persistensi
  ///
  /// ```dart
  /// // Contoh penggunaan:
  /// final controller = Get.find<LocaleController>();
  /// controller.changeLocale(const Locale('id', 'ID'));
  /// ```
  void changeLocale(Locale newLocale) {
    // Validasi locale didukung
    final isSupported = AppTranslations.supportedLocales.any(
      (l) =>
          l.languageCode == newLocale.languageCode &&
          l.countryCode == newLocale.countryCode,
    );

    if (!isSupported) {
      Get.log('LocaleController: Locale $newLocale is not supported');
      return;
    }

    // Skip jika locale sama
    if (_locale.value == newLocale) return;

    // Update state + UI + storage
    _locale.value = newLocale;
    Get.updateLocale(newLocale);
    _storage.write(
      _storageKey,
      '${newLocale.languageCode}_${newLocale.countryCode}',
    );

    Get.log('LocaleController: Locale changed to $newLocale');
  }

  /// Shortcut untuk ganti locale dari LanguageOption.
  void changeLanguage(LanguageOption option) {
    changeLocale(option.locale);
  }

  /// Cek apakah locale tertentu sedang aktif.
  bool isCurrentLocale(Locale locale) {
    return _locale.value.languageCode == locale.languageCode &&
        _locale.value.countryCode == locale.countryCode;
  }

  /// Dapatkan LanguageOption yang sedang aktif.
  LanguageOption get currentLanguageOption {
    return availableLanguages.firstWhere(
      (lang) => isCurrentLocale(lang.locale),
      orElse: () => availableLanguages.first,
    );
  }

  /// Reset ke default locale.
  void resetToDefault() {
    changeLocale(AppTranslations.fallbackLocale);
  }
}
```

---

### 6. Language Selector Widget

Widget untuk memilih bahasa. Menggunakan `Obx()` untuk reactive UI — tidak
perlu `ConsumerWidget` atau `WidgetRef` seperti di Riverpod.

**File:** `sdlc/flutter-getx/07-translation/option_a_getx_builtin/language_selector_widget.dart`

```dart
// lib/features/settings/widgets/language_selector_widget.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/locale_controller.dart';

/// Widget untuk memilih bahasa aplikasi.
///
/// Menampilkan list bahasa yang tersedia dengan radio indicator
/// untuk bahasa yang sedang aktif. Menggunakan `Obx()` untuk
/// reactive rebuild — perbedaan utama dari Riverpod yang
/// menggunakan `ConsumerWidget` + `ref.watch()`.
class LanguageSelectorWidget extends StatelessWidget {
  const LanguageSelectorWidget({super.key});

  @override
  Widget build(BuildContext context) {
    // Ambil controller — sudah di-register di main.dart
    final controller = Get.find<LocaleController>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            'settings.language'.tr,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),

        // Obx() — reactive wrapper. Widget di dalamnya akan rebuild
        // otomatis setiap kali _locale berubah di controller.
        // Bandingkan dengan Riverpod: ref.watch(localeProvider)
        Obx(
          () => ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: controller.availableLanguages.length,
            itemBuilder: (context, index) {
              final language = controller.availableLanguages[index];
              final isSelected = controller.isCurrentLocale(language.locale);

              return _LanguageTile(
                language: language,
                isSelected: isSelected,
                onTap: () => controller.changeLanguage(language),
              );
            },
          ),
        ),
      ],
    );
  }
}

/// Tile individual untuk setiap bahasa.
class _LanguageTile extends StatelessWidget {
  final LanguageOption language;
  final bool isSelected;
  final VoidCallback onTap;

  const _LanguageTile({
    required this.language,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ListTile(
      onTap: onTap,
      leading: Text(
        language.flag,
        style: const TextStyle(fontSize: 28),
      ),
      title: Text(
        language.nativeName,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? colorScheme.primary : null,
        ),
      ),
      subtitle: Text(
        language.displayName,
        style: TextStyle(
          color: isSelected
              ? colorScheme.primary.withOpacity(0.7)
              : colorScheme.onSurfaceVariant,
        ),
      ),
      trailing: isSelected
          ? Icon(Icons.check_circle, color: colorScheme.primary)
          : Icon(Icons.circle_outlined, color: colorScheme.outline),
      selected: isSelected,
      selectedTileColor: colorScheme.primaryContainer.withOpacity(0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }
}

/// Bottom sheet variant — cocok untuk dipanggil dari Settings.
///
/// ```dart
/// // Cara pakai:
/// showLanguageBottomSheet();
/// ```
void showLanguageBottomSheet() {
  final controller = Get.find<LocaleController>();

  Get.bottomSheet(
    Container(
      decoration: BoxDecoration(
        color: Get.theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Get.theme.colorScheme.outline.withOpacity(0.4),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Title
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'settings.language'.tr,
              style: Get.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const Divider(height: 1),

          // Language list
          Obx(
            () => ListView.separated(
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: controller.availableLanguages.length,
              separatorBuilder: (_, __) => const SizedBox(height: 2),
              itemBuilder: (context, index) {
                final language = controller.availableLanguages[index];
                final isSelected =
                    controller.isCurrentLocale(language.locale);

                return ListTile(
                  onTap: () {
                    controller.changeLanguage(language);
                    Get.back(); // Tutup bottom sheet
                  },
                  leading: Text(
                    language.flag,
                    style: const TextStyle(fontSize: 24),
                  ),
                  title: Text(language.nativeName),
                  subtitle: Text(language.displayName),
                  trailing: isSelected
                      ? const Icon(Icons.check_circle, color: Colors.green)
                      : null,
                );
              },
            ),
          ),

          const SizedBox(height: 16),
        ],
      ),
    ),
    isScrollControlled: true,
  );
}

/// Dialog variant — alternatif selain bottom sheet.
void showLanguageDialog() {
  final controller = Get.find<LocaleController>();

  Get.dialog(
    AlertDialog(
      title: Text('settings.language'.tr),
      content: SizedBox(
        width: double.maxFinite,
        child: Obx(
          () => ListView.builder(
            shrinkWrap: true,
            itemCount: controller.availableLanguages.length,
            itemBuilder: (context, index) {
              final language = controller.availableLanguages[index];
              final isSelected = controller.isCurrentLocale(language.locale);

              return RadioListTile<String>(
                value: language.storageKey,
                groupValue: controller.currentLocaleCode,
                onChanged: (_) {
                  controller.changeLanguage(language);
                  Get.back();
                },
                title: Text('${language.flag}  ${language.nativeName}'),
                subtitle: Text(language.displayName),
                selected: isSelected,
              );
            },
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Get.back(),
          child: Text('common.cancel'.tr),
        ),
      ],
    ),
  );
}
```

---

### 7. Usage Examples

Contoh penggunaan translation di berbagai screen. Perhatikan: GetX built-in
menggunakan `'key'.tr` **(tanpa parentheses)**, berbeda dengan easy_localization
yang menggunakan `'key'.tr()`.

**File:** `sdlc/flutter-getx/07-translation/option_a_getx_builtin/usage_examples.dart`

```dart
// lib/features/home/views/home_screen.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Contoh penggunaan .tr di HomeScreen.
///
/// PENTING — perbedaan syntax:
/// - GetX built-in:      'key'.tr     (tanpa parentheses, property getter)
/// - easy_localization:  'key'.tr()   (dengan parentheses, method call)
/// - Riverpod/intl:      AppLocalizations.of(context).key
///
/// Jangan campur! Pilih satu pendekatan per project.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('nav.home'.tr),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            tooltip: 'nav.notifications'.tr,
            onPressed: () => Get.toNamed('/notifications'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Greeting berdasarkan waktu
            Text(
              _getGreeting(),
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 24),

            // Section headers menggunakan .tr
            _SectionHeader(title: 'home.featured'.tr),
            const SizedBox(height: 8),
            // ... featured items

            const SizedBox(height: 24),
            _SectionHeader(title: 'home.popular'.tr),
            const SizedBox(height: 8),
            // ... popular items

            const SizedBox(height: 24),
            _SectionHeader(title: 'home.recommended'.tr),
            const SizedBox(height: 8),
            // ... recommended items
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home),
            label: 'nav.home'.tr,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.shopping_bag),
            label: 'nav.products'.tr,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.shopping_cart),
            label: 'nav.cart'.tr,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.person),
            label: 'nav.profile'.tr,
          ),
        ],
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'home.greeting_morning'.tr;
    if (hour < 17) return 'home.greeting_afternoon'.tr;
    return 'home.greeting_evening'.tr;
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        TextButton(
          onPressed: () {},
          child: Text('common.see_all'.tr),
        ),
      ],
    );
  }
}

// -----------------------------------------------------------------------
// Contoh penggunaan .tr dengan parameter substitution
// -----------------------------------------------------------------------

/// GetX built-in TIDAK punya parameter substitution seperti
/// easy_localization. Untuk parameter, gunakan `trParams`.
///
/// Di translation map:
///   'auth.welcome_back': 'Welcome back, @name!'
///
/// Di code:
///   'auth.welcome_back'.trParams({'name': userName})
///
class WelcomeWidget extends StatelessWidget {
  final String userName;
  const WelcomeWidget({super.key, required this.userName});

  @override
  Widget build(BuildContext context) {
    return Text(
      'auth.welcome_back'.trParams({'name': userName}),
      style: Theme.of(context).textTheme.titleLarge,
    );
  }
}

// -----------------------------------------------------------------------
// Contoh form validation dengan .tr
// -----------------------------------------------------------------------

class LoginForm extends StatelessWidget {
  LoginForm({super.key});

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextFormField(
          controller: emailController,
          decoration: InputDecoration(
            labelText: 'common.email'.tr,
            hintText: 'auth.email_hint'.tr,
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'validation.required'.tr;
            }
            if (!GetUtils.isEmail(value)) {
              return 'validation.email'.tr;
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: passwordController,
          obscureText: true,
          decoration: InputDecoration(
            labelText: 'auth.password_hint'.tr,
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'validation.required'.tr;
            }
            if (value.length < 8) {
              return 'error.password_too_short'.tr;
            }
            return null;
          },
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              // Login logic
            },
            child: Text('auth.login'.tr),
          ),
        ),
        TextButton(
          onPressed: () {},
          child: Text('auth.forgot_password'.tr),
        ),
      ],
    );
  }
}

// -----------------------------------------------------------------------
// Contoh snackbar / toast dengan .tr
// -----------------------------------------------------------------------

/// Helper function untuk menampilkan translated snackbars.
void showTranslatedSnackbar({
  required String titleKey,
  required String messageKey,
  bool isError = false,
}) {
  Get.snackbar(
    titleKey.tr,
    messageKey.tr,
    snackPosition: SnackPosition.BOTTOM,
    backgroundColor: isError ? Colors.red.shade100 : Colors.green.shade100,
    colorText: isError ? Colors.red.shade900 : Colors.green.shade900,
    margin: const EdgeInsets.all(16),
    borderRadius: 12,
    duration: const Duration(seconds: 3),
  );
}

// Contoh pemanggilan:
// showTranslatedSnackbar(
//   titleKey: 'auth.login_success',
//   messageKey: 'auth.welcome_back',
// );
```

---

### 8. Settings Screen with Language

Settings screen lengkap yang menggunakan `Obx()` untuk menampilkan bahasa
yang sedang aktif. Bandingkan dengan Riverpod yang menggunakan `ref.watch()`.

**File:** `sdlc/flutter-getx/07-translation/option_a_getx_builtin/settings_screen.dart`

```dart
// lib/features/settings/views/settings_screen.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/locale_controller.dart';
import '../widgets/language_selector_widget.dart';

/// Settings screen dengan language selection.
///
/// Perbedaan utama dari Riverpod version:
/// - `Get.find<LocaleController>()` bukan `ref.watch(localeProvider)`
/// - `Obx(() => ...)` bukan `ConsumerWidget` + `ref.watch()`
/// - `Get.updateLocale()` bukan `ref.read(localeProvider.notifier).change()`
/// - Tidak perlu extends ConsumerWidget atau ConsumerStatefulWidget
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final localeController = Get.find<LocaleController>();
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('settings.title'.tr),
      ),
      body: ListView(
        children: [
          // ============================================================
          // Language Section
          // ============================================================
          _SectionTitle(title: 'settings.language'.tr),

          // Obx() wraps hanya bagian yang perlu reactive rebuild.
          // Ini lebih efisien daripada rebuild seluruh widget tree.
          Obx(() {
            final current = localeController.currentLanguageOption;
            return ListTile(
              leading: const Icon(Icons.language),
              title: Text('settings.language'.tr),
              subtitle: Text(
                '${current.flag}  ${current.nativeName}',
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => showLanguageBottomSheet(),
            );
          }),

          const Divider(),

          // ============================================================
          // Theme Section
          // ============================================================
          _SectionTitle(title: 'settings.theme'.tr),
          ListTile(
            leading: const Icon(Icons.palette),
            title: Text('settings.theme'.tr),
            subtitle: Text('settings.theme_subtitle'.tr),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // Navigate to theme settings
            },
          ),

          const Divider(),

          // ============================================================
          // Notifications Section
          // ============================================================
          _SectionTitle(title: 'settings.notifications'.tr),
          ListTile(
            leading: const Icon(Icons.notifications),
            title: Text('settings.push_notifications'.tr),
            trailing: Switch(
              value: true,
              onChanged: (value) {
                // Toggle push notifications
              },
            ),
          ),
          ListTile(
            leading: const Icon(Icons.email),
            title: Text('settings.email_notifications'.tr),
            trailing: Switch(
              value: false,
              onChanged: (value) {
                // Toggle email notifications
              },
            ),
          ),

          const Divider(),

          // ============================================================
          // Account Section
          // ============================================================
          _SectionTitle(title: 'settings.account'.tr),
          ListTile(
            leading: const Icon(Icons.person),
            title: Text('settings.account'.tr),
            subtitle: Text('settings.account_subtitle'.tr),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.privacy_tip),
            title: Text('settings.privacy'.tr),
            subtitle: Text('settings.privacy_subtitle'.tr),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),

          const Divider(),

          // ============================================================
          // App Info Section
          // ============================================================
          _SectionTitle(title: 'settings.about_app'.tr),
          ListTile(
            leading: const Icon(Icons.info),
            title: Text('settings.about_app'.tr),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.description),
            title: Text('settings.terms'.tr),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.security),
            title: Text('settings.privacy_policy'.tr),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.star_rate),
            title: Text('settings.rate_app'.tr),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.share),
            title: Text('settings.share_app'.tr),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),

          // Version info
          Padding(
            padding: const EdgeInsets.all(16),
            child: Center(
              child: Text(
                '${'settings.version'.tr} 1.0.0',
                style: TextStyle(
                  color: colorScheme.onSurfaceVariant,
                  fontSize: 12,
                ),
              ),
            ),
          ),

          const Divider(),

          // ============================================================
          // Cache & Data
          // ============================================================
          ListTile(
            leading: Icon(Icons.cached, color: colorScheme.error),
            title: Text('settings.clear_cache'.tr),
            onTap: () {
              Get.defaultDialog(
                title: 'common.confirm'.tr,
                middleText: 'settings.clear_cache'.tr,
                textConfirm: 'common.yes'.tr,
                textCancel: 'common.cancel'.tr,
                confirmTextColor: Colors.white,
                onConfirm: () {
                  // Clear cache logic
                  Get.back();
                  Get.snackbar(
                    'common.done'.tr,
                    'settings.cache_cleared'.tr,
                    snackPosition: SnackPosition.BOTTOM,
                  );
                },
              );
            },
          ),

          // ============================================================
          // Danger Zone
          // ============================================================
          const SizedBox(height: 16),
          ListTile(
            leading: Icon(Icons.delete_forever, color: colorScheme.error),
            title: Text(
              'settings.delete_account'.tr,
              style: TextStyle(color: colorScheme.error),
            ),
            onTap: () {
              Get.defaultDialog(
                title: 'settings.delete_account'.tr,
                middleText: 'settings.delete_account_confirm'.tr,
                textConfirm: 'common.delete'.tr,
                textCancel: 'common.cancel'.tr,
                confirmTextColor: Colors.white,
                buttonColor: colorScheme.error,
                onConfirm: () {
                  // Delete account logic
                  Get.back();
                },
              );
            },
          ),

          // Logout
          ListTile(
            leading: Icon(Icons.logout, color: colorScheme.error),
            title: Text(
              'auth.logout'.tr,
              style: TextStyle(color: colorScheme.error),
            ),
            onTap: () {
              Get.defaultDialog(
                title: 'auth.logout'.tr,
                middleText: 'auth.logout_confirm'.tr,
                textConfirm: 'common.yes'.tr,
                textCancel: 'common.cancel'.tr,
                confirmTextColor: Colors.white,
                onConfirm: () {
                  // Logout logic
                  Get.offAllNamed('/login');
                },
              );
            },
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Text(
        title,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }
}
```

---

## Translation Files Structure

### Option A — GetX Built-in (Dart Files)

```
lib/
└── core/
    └── translations/
        ├── app_translations.dart    # Main class extends Translations
        └── translations/
            ├── en_us.dart           # const Map<String, String> enUS
            ├── id_id.dart           # const Map<String, String> idID
            ├── ms_my.dart           # const Map<String, String> msMY
            ├── th_th.dart           # const Map<String, String> thTH
            └── vn_vn.dart           # const Map<String, String> viVN
```

**Keuntungan Dart files:**
- Type-safe — IDE bisa detect typo di keys
- Refactoring mudah — rename key otomatis di semua file
- Tidak perlu asset loading — compile langsung ke binary
- Bisa pakai const — lebih optimal untuk performance
- Autocomplete di IDE

### Option B — Easy Localization (JSON Files)

```
assets/
└── translations/
    ├── en.json
    ├── id.json
    ├── ms.json
    ├── th.json
    └── vi.json
```

**Keuntungan JSON files:**
- Format standar — bisa di-share dengan platform lain (web, backend)
- Mudah di-manage oleh non-developer (translator, content team)
- Bisa di-update tanpa rebuild (jika load dari remote)
- Support plural forms dan gender

---

## Perbandingan GetX vs Riverpod untuk Translation

| Aspek | GetX (Option A) | Riverpod |
|-------|-----------------|----------|
| Translation source | Dart Map (`'key'.tr`) | JSON + easy_localization (`'key'.tr()`) |
| State management | `GetxController` + `Obx()` | `@riverpod` + `ref.watch()` |
| Widget base class | `StatelessWidget` | `ConsumerWidget` |
| Change locale | `Get.updateLocale(locale)` | `ref.read(provider.notifier).change()` |
| Persistence | `GetStorage` | `SharedPreferences` |
| Parameter substitution | `'key'.trParams({'name': 'John'})` | `'key'.tr(args: ['John'])` |
| Plural support | Limited (manual) | Built-in via easy_localization |
| Dependencies | `get` only | `easy_localization` + `shared_preferences` |
| Code generation | None | None (tapi intl butuh) |

---

## Workflow Steps

### Step 1: Setup Dependencies
1. Tambahkan `get` dan `get_storage` ke `pubspec.yaml`
2. Run `flutter pub get`
3. Pilih Option A atau Option B (jangan campur)

### Step 2: Buat Translation Files
**Option A:**
1. Buat folder `lib/core/translations/translations/`
2. Buat file per bahasa: `en_us.dart`, `id_id.dart`, dll.
3. Isi setiap file dengan `const Map<String, String>`
4. Buat `app_translations.dart` yang extends `Translations`

**Option B:**
1. Buat folder `assets/translations/`
2. Buat file JSON per bahasa
3. Daftarkan assets di `pubspec.yaml`

### Step 3: Configure GetMaterialApp
1. Set `translations: AppTranslations()` (Option A)
2. Set `locale:` dan `fallbackLocale:`
3. Initialize `GetStorage` di `main()`

### Step 4: Buat Locale Controller
1. Buat `LocaleController extends GetxController`
2. Implement `Rx<Locale>` untuk reactive state
3. Implement `changeLocale()` dengan `Get.updateLocale()`
4. Implement persistence dengan `GetStorage`
5. Load saved locale di `onInit()`

### Step 5: Buat Language Selector Widget
1. Buat widget dengan `Obx()` untuk reactive UI
2. Implement bottom sheet atau dialog variant
3. Tampilkan flag, native name, dan checkmark

### Step 6: Integrate ke Screens
1. Ganti semua hardcoded string dengan `'key'.tr`
2. Gunakan `'key'.trParams({})` untuk dynamic values
3. Pastikan semua validator, error messages, dll sudah ditranslate

### Step 7: Testing
1. Test setiap bahasa — switch dan verify UI berubah
2. Test persistence — restart app dan verify bahasa tersimpan
3. Test fallback — set locale yang tidak didukung
4. Test edge cases — string panjang, RTL jika nanti support Arabic

---

## Success Criteria

- [ ] Semua 5 bahasa (EN, ID, MS, TH, VN) berfungsi dengan benar
- [ ] Switching bahasa mengubah **seluruh** UI secara real-time
- [ ] Pilihan bahasa tersimpan dan survive app restart
- [ ] Tidak ada hardcoded string di UI widgets
- [ ] Fallback locale berfungsi jika key tidak ditemukan
- [ ] Language selector menampilkan bahasa aktif dengan indicator
- [ ] Snackbar, dialog, dan error messages juga ditranslate
- [ ] Tidak ada crash saat switch bahasa cepat berulang kali
- [ ] Form validation messages menggunakan translated strings
- [ ] Device locale auto-detected saat pertama kali install

---

## Best Practices

### Key Naming Convention
```
# Gunakan dot notation yang konsisten:
section.subsection.action

# Contoh:
auth.login              # section: auth, action: login
settings.language       # section: settings, item: language
error.network           # section: error, type: network
product.add_to_cart     # section: product, action: add_to_cart
```

### Organisasi Translation Maps
```dart
// BAIK — grouped by section, consistent keys
'auth.login': 'Login',
'auth.logout': 'Logout',
'auth.register': 'Register',

// KURANG BAIK — mixed, inconsistent
'login': 'Login',
'user_logout': 'Logout',
'signUp': 'Register',
```

### Parameter Substitution
```dart
// Translation map:
'auth.welcome_back': 'Welcome back, @name!'

// Usage:
'auth.welcome_back'.trParams({'name': user.name})

// JANGAN lakukan string interpolation:
// '${'auth.welcome'.tr} ${user.name}' // BAD
```

### Hanya Wrap yang Perlu Reactive
```dart
// BAIK — hanya Text yang berubah di-wrap Obx
Column(
  children: [
    const Icon(Icons.language),  // Tidak perlu Obx
    Obx(() => Text(controller.currentLanguageOption.nativeName)),
  ],
)

// KURANG OPTIMAL — seluruh Column di-wrap Obx
Obx(() => Column(
  children: [
    const Icon(Icons.language),  // Rebuild sia-sia
    Text(controller.currentLanguageOption.nativeName),
  ],
))
```

### Testing Translations
```dart
// test/core/translations/translations_test.dart

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('all translation maps have the same keys', () {
    final enKeys = enUS.keys.toSet();
    final idKeys = idID.keys.toSet();
    final msKeys = msMY.keys.toSet();
    final thKeys = thTH.keys.toSet();
    final viKeys = viVN.keys.toSet();

    // Semua bahasa harus punya keys yang sama dengan English
    expect(idKeys, equals(enKeys), reason: 'ID missing keys');
    expect(msKeys, equals(enKeys), reason: 'MS missing keys');
    expect(thKeys, equals(enKeys), reason: 'TH missing keys');
    expect(viKeys, equals(enKeys), reason: 'VN missing keys');
  });

  test('no empty translation values', () {
    for (final entry in enUS.entries) {
      expect(entry.value.isNotEmpty, isTrue,
          reason: 'EN key "${entry.key}" is empty');
    }
    for (final entry in idID.entries) {
      expect(entry.value.isNotEmpty, isTrue,
          reason: 'ID key "${entry.key}" is empty');
    }
    // ... repeat for other languages
  });
}
```

---

## Catatan Tambahan

### Plural Forms (Limitasi GetX Built-in)

GetX built-in **tidak** punya plural support native. Jika butuh plural
(misal "1 item" vs "5 items"), lakukan manual:

```dart
// Helper function untuk plural sederhana
String pluralize(int count, String singular, String plural) {
  return count == 1 ? singular : plural;
}

// Atau buat translation keys terpisah:
// 'cart.item_one': '1 item'
// 'cart.item_other': '@count items'
```

Jika plural forms adalah requirement penting, pertimbangkan **Option B**
(easy_localization) yang punya plural support built-in.

### RTL Support (Future)

Jika nanti perlu support bahasa RTL (Arabic, Hebrew), tambahkan:
```dart
GetMaterialApp(
  locale: controller.currentLocale,
  // Flutter otomatis handle RTL berdasarkan locale
  // Tapi pastikan layout tidak hardcode left/right
)
```

### Remote Translation Loading

Untuk load translation dari server (misalnya untuk A/B testing copy):
```dart
class RemoteTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys => _remoteKeys;

  static Map<String, Map<String, String>> _remoteKeys = {};

  static Future<void> loadFromServer() async {
    // Fetch translations from API
    // Parse and assign to _remoteKeys
  }
}
```

---

## Next Steps

Setelah translation/localization selesai, lanjutkan ke workflow berikutnya
dalam urutan SDLC Flutter GetX:

1. **`08-testing/`** — Unit test, widget test, integration test dengan GetX
2. **`09-deployment/`** — Build, signing, release ke store
3. **`10-monitoring/`** — Analytics, crash reporting, performance monitoring

Pastikan semua translation keys sudah di-test sebelum deploy ke production.
Tambahkan translation test ke CI/CD pipeline supaya missing keys terdeteksi
otomatis saat PR review.

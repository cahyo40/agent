---
description: Implementasi internationalization (i18n) untuk Flutter dengan GetX. (Sub-part 3/7)
---
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

**File:** `sdlc/flutter-youi/07-translation/option_a_getx_builtin/translations/ms_my.dart`

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
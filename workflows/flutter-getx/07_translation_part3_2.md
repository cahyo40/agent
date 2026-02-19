---
description: Implementasi internationalization (i18n) untuk Flutter dengan GetX. (Sub-part 2/7)
---
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
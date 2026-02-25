# 🎬 The Ultimate Vibe Coding Playbook for Flutter & YoDev

Panduan ini dirancang khusus untuk Anda yang menggunakan **YoDev Monorepo**, **Clean Architecture**, dan **YoUI Component Library**. Tujuan utama dari Vibe Coding adalah **menulis lebih sedikit kode secara manual** dan lebih banyak berperan sebagai **Sutradara (Director) / Arsitek** yang memandu AI untuk menghasilkan kode berkualitas produksi.

---

## 🧠 1. Perubahan Mindset: Programmer vs Vibe Coder

| Programmer Tradisional | Vibe Coder (AI-Assisted) |
| :--- | :--- |
| Memikirkan sintaks baris per baris. | Memikirkan **alur data** dan **arsitektur**. |
| Menulis boilerplate (model, repository) dari nol. | Men-generate boilerplate, lalu fokus pada **business logic**. |
| Mencari error di StackOverflow. | Mempaste error ke AI beserta file terkait untuk di-debug. |
| Mencoba memuat seluruh aplikasi di kepala. | Memecah fitur menjadi tugas-tugas mikro (hanya memuat 1-2 file di kepala). |

**Prinsip Utama:** AI itu "pintar tapi pelupa dan suka berhalusinasi". AI akan menggunakan cara tercepat (dan kadang terburuk) jika tidak diberi batasan (constraints) dan konteks (context) yang jelas.

---

## 🏛️ 2. Persiapan Konteks (Context is King!)

AI Prompting tanpa konteks adalah bencana. Sebelum Anda meminta AI menulis kode, pastikan AI mengetahui lingkungan kerja Anda. 

### A. Penggunaan System Prompt / Rule Files
Pastikan environment AI Anda (Cursor, Windsurf, atau Claude) sudah membaca file-file ini:
- `yo-flutter-dev` skill guidelines.
- referensi ke komponen YoUI (misalnya isi `/resources/components-basic.md`).

### B. Konsep "Context Stacking" (Tumpukan Konteks)
Saat Anda memberikan prompt, gunakan fitur tag file (seperti `@nama_file.dart`) untuk membangun pemahaman AI.
- **Layer 1 (Aturan Main):** `"Tolong buat sesuai dengan Clean Architecture kita."`
- **Layer 2 (Contoh Nyata):** `"Lihat cara saya mengambil API di @auth_remote_datasource.dart."`
- **Layer 3 (Target):** `"Sekarang buat hal yang sama untuk @product_remote_datasource.dart."`

---

## 🔄 3. Workflow Mikro: Siklus Kerja Vibe Coder Profesional

Jangan pernah! **JANGAN PERNAH** meminta AI membuat seluruh fitur (UI, Logic, API) dalam 1 prompt. Terapkan siklus *Micro-Iteration* berikut:

### 🛠️ Langkah 1: Scaffolding (Boilerplate)
Sebagai Vibe Coder di lingkungan YoDev, Anda **HARUS menggunakan CLI Generator**.
1. Buka Terminal Anda.
2. Jalankan: `dart run yo.dart page:product.detail`
3. Jalankan: `dart run yo.dart datasource:product --remote`
4. Hasilnya: Anda sudah memiliki struktur folder yang benar, file yang saling terhubung, dan marker `// TODO`.

### 🧠 Langkah 2: Fokus pada Data & Logic Layer (Data to Domain)
Setelah file ter-generate, arahkan AI ke layer terbawah terlebih dahulu.
> **Prompt Example:**
> "Saya ingin mengerjakan fitur Detail Produk. Saya sudah men-generate file datasource dan repository.
> 1. Buka `@product_remote_datasource.dart`.
> 2. Implementasikan function untuk memanggil endpoint `GET /api/products/:id`.
> 3. Tangani exception sesuai format di proyek kita.
> Jangan sentuh UI dulu."

### 🎨 Langkah 3: Fokus pada Presentation / UI Layer
Sekarang barulah kita menyentuh UI. Di sinilah sering terjadi kesalahan (AI membuat UI yang ngawur). Kunci batasannya:
> **Prompt Example:**
> "Logic produk sudah selesai. Sekarang kita kerjakan `@product_detail_page.dart`.
> Konteks: Kita menggunakan Riverpod (`productDetailProvider`).
> 
> Instruksi WAJIB:
> 1. Gunakan komponen dari library **YoUI**.
> 2. DILARANG keras menggunakan widget bawaan Flutter seperti `Container`, `Padding`, `Text`, `ElevatedButton`, atau `Card`.
> 3. Gunakan `YoScaffold` sebagai base.
> 4. Tampilkan foto produk dengan `YoImage`, nama dengan `YoText.heading2()`, dan harga dengan `YoText.bodyLarge()`.
> 5. Untuk state Loading, gunakan `YoShimmer`. Untuk Error, gunakan `YoErrorState`.
> 
> Buatkan saya UI-nya."

### ✨ Langkah 4: Refinement (Perbaikan & Poles)
Jalankan aplikasi (Hot Reload). Jika transisinya kaku atau ada detail yang hilang:
> **Prompt Example:**
> "Tampilan sudah bagus, tapi ada dua hal yang perlu diperbaiki di `@product_detail_page.dart`:
> 1. Ubah tombol 'Beli' di bagian bawah agar *sticky* (menempel di bawah menggunakan `YoBottomNav` atau dipisah ke `bottomNavigationBar` scaffold).
> 2. Tampilkan `YoToast.showSuccess()` saat tombol Beli ditekan, lalu rute kembali ke halaman sebelumnya.
> Tolong refactor kodenya."

---

## 🛡️ 4. Anti-Halusinasi: Cara "Mendisiplinkan" AI

AI sering kali kembali ke kebiasaan lamanya (menulis kode kotor atau menggunakan library generik). Berikut trik mendisiplinkannya:

1. **Aturan Negatif yang Kuat:** `Jangan gunakan package X`, `Jangan ubah file Y`.
2. **Review Secara Aktif:** Jika AI memberikan kode:
   ```dart
   Container(
     padding: EdgeInsets.all(16),
     child: Text('Halo'),
   )
   ```
   **Jangan asal di-Accept!** Balas prompt: `"Kamu menggunakan Container dan Text bawaan. Ulangi dan ganti dengan YoCard dan YoText sesuai aturan YoUI."`
3. **Minta AI Membaca Dokumentasi:** `"Sebelum menulis kode, tolong baca komponen yang tersedia di @components-display.md untuk mencari tahu cara merender list produk yang benar."`

---

## 🐞 5. Vibe Debugging (Menangani Error dengan Elegan)

Sebagai Vibe Coder, Anda tidak perlu menghabiskan 2 jam memecahkan error merah.
1. Copy seluruh log error dari terminal / debug console.
2. Cari tahu file mana yang memicu error (misal: `@login_controller.dart`).
3. Berikan prompt investigasi:
   > "Aplikasi crash saat tombol login ditekan. Ini log errornya: `[PASTE_ERROR_DI_SINI]`. 
   > Tolong analisa `@login_controller.dart` dan `@auth_repository.dart`. Apa yang menyebabkannya dan bagaimana solusi perbaikannya tanpa merusak flow yang ada?"

---

## 📝 6. Lembar Contek (Cheat Sheet) Prompt Harian

Simpan prompt ini untuk mempercepat pekerjaan harian Anda:

### Menambahkan Model / Entity Baru
> "Buatkan konversi JSON serialization untuk `@user_model.dart`. Pastikan field `created_at` dikonversi dengan benar menjadi objek `DateTime` menggunakan _custom converter_ jika perlu. Gunakan `freezed` dan jalankan build_runner."

### Refactor File yang Terlalu Panjang
> "File `@checkout_page.dart` ini sudah melebihi 250 baris. Tolong ekstrak bagian metode pembayaran dan ringkasan pesanan menjadi widget terpisah di file baru (misalnya `@payment_method_section.dart` dan `@order_summary_section.dart`). Jaga agar state tetap terhubung dengan controller."

### Membuat Komponen Reusable
> "Saya sering menyalin kode UI keranjang kosong di berbagai tempat. Tolong buatkan widget kustom baru bernama `EmptyCartView` yang menggunakan `YoEmptyState` sebagai kerangkanya, lengkapi dengan animasi dan tombol aksi 'Cari Produk'. Tempatkan di folder `/presentation/widgets/`."

### Mengaplikasikan State Management (Riverpod/GetX/BLoC)
> "Tolong integrasikan API call di `@cart_repository.dart` ke dalam state management di `@cart_controller.dart`. Pastikan controller menangani state loading, success, dan error secara eksplisit agar bisa dikonsumsi oleh UI menggunakan pola yang sama dengan `@profile_controller.dart`."

---

## 🚀 Kesimpulan

Profesional Vibe Coder adalah tentang **komunikasi yang presisi**. Anda adalah sutradara yang mengatur *lighting* (konteks), *aktor* (AI), dan *naskah* (prompt). Jangan biarkan AI berimprovisasi terlalu jauh dan merusak "Vibe" arsitektur Anda. Gunakan alat YoDev Anda, pandu lapis demi lapis, dan nikmati proses ngoding dengan kecepatan x10!

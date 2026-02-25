# 🐹 The Ultimate Vibe Coding Playbook for Golang Backend

Panduan ini dirancang untuk memaksimalkan produktivitas Anda dalam mendevelop sistem Backend menggunakan **Golang** yang menerapkan prinsip **Clean Architecture**. Sama seperti di ekosistem frontend, Vibe Coding di Backend bertujuan agar Anda lebih banyak berperan sebagai **Arsitek Sistem (System Architect)** sedangkan AI bertindak sebagai "tukang ketik" yang sangat cerdas.

---

## 🧠 1. Perubahan Mindset Backend Vibe Coder

| Backend Engineer Tradisional | Backend Vibe Coder (AI-Assisted) |
| :--- | :--- |
| Menulis boilerplate (struct, interface, DTO) secara manual. | Men-generate struktur dasar, lalu berfokus pada **Domain Logic** & keamanan. |
| Tersesat saat konfigurasi DB dan wiring dependencies. | Memandu AI menyambungkan (wiring) _dependency injection_ secara spesifik. |
| Menulis Unit Test di akhir (dan sering terlewat). | Menginstruksikan AI membuat Unit Test bersamaan dengan Logic (TDD Vibe). |

**Prinsip Utama:** AI Golang cenderung memberikan solusi cepat yang mengabaikan abstraksi (seperti menulis kuiri SQL langsung di handler / controller). Anda **TIDAK BOLEH** membiarkan AI melakukan ini. Beri AI batasan (constraints) dan perintahkan AI untuk selalu mengikuti layer **Clean Architecture**: `Handler -> Usecase -> Repository`.

---

## 🏛️ 2. Persiapan Konteks (Context Stacking)

Backend sangat bergantung pada konsistensi struktur dan konvensi penamaan.
Saat Anda memberikan prompt, bangun pemahaman AI selapis demi selapis:

- **Layer 1 (Aturan Main Arsitektur):** `"Kita menggunakan Clean Architecture. Ada layer Handler, Usecase, dan Repository. Kita memakai framework Gin dan GORM."`
- **Layer 2 (Contoh Nyata):** `"Lihat contoh implementasi kita di @user_repository.go dan @user_usecase.go."`
- **Layer 3 (Target):** `"Sekarang, buatkan struktur serupa untuk fitur transaksi (@transaction_repository.go)."`

---

## 🔄 3. Workflow Mikro Backend: Siklus Kerja Vibe Coder

Hindari prompt seperti *"Buatkan saya API lengkap untuk E-Commerce"*. Anda akan mendapatkan kode _spaghetti_. Gunakan siklus **Micro-Iteration** berdasarkan Workflow kita:

### 🛠️ Langkah 1: Module Generation (Scaffolding Dasar)
Gunakan workflow existing (seperti `02_module_generator.md`) sebagai panduan dasar.
> **Prompt Example:**
> "Kita akan membuat fitur 'Order'. Tolong generate struktur dasar untuk Clean Architecture fitur ini:
> 1. Buatkan interface `OrderRepository` dan `OrderUsecase` di file domain.
> 2. Buatkan file kosong untuk implementasi repository, usecase, dan http handler-nya.
> Jangan tulis implementasi (logic) apa pun dulu, fokus pada `struct`, `interface`, dan DTO (Data Transfer Object) untuk request/response."

### 🗄️ Langkah 2: Fokus pada Data Layer (Repository)
Arahkan AI untuk hanya menulis kueri database tanpa mencampurkannya dengan urusan bisnis.
> **Prompt Example:**
> "Sekarang, berikan implementasi untuk `@order_repository.go`.
> Konteks: Kita menggunakan PostgreSQL dan GORM.
> Instruksi:
> 1. Buat _method_ untuk bikin order baru (`CreateOrder`), ambil order berdasarkan ID (`GetOrderByID`).
> 2. Pastikan kembalian berformat `(domain.Order, error)` dan jangan bocorkan tipe GORM ke usecase.
> 3. Implementasikan juga transaksi db (`tx := db.Begin()`) khusus untuk `CreateOrder` karena melibatkan banyak tabel."

### 🧠 Langkah 3: Fokus pada Domain Logic (Usecase)
Vibe Coding yang kuat memisahkan urusan *database* dan urusan *bisnis*.
> **Prompt Example:**
> "Repository order sudah selesai. Sekarang kerjakan `@order_usecase.go`.
> Instruksi WAJIB:
> 1. Panggil `CreateOrder` dari repository.
> 2. Lakukan validasi bisnis: Jika stok produk tidak cukup, kembalikan `ErrInsufficientStock` (rujuk `@errors.go`).
> 3. Usecase TIDAK BOLEH tahu bahwa ini adalah request HTTP, jadi jangan tangani response JSON di sini. Hanya _return_ data atau _error_ murni."

### 🌐 Langkah 4: Fokus pada Presentation (HTTP Handler / Controller)
Di sinilah Anda membungkus _usecase_ ke dalam HTTP framework.
> **Prompt Example:**
> "Logic usecase sudah jadi. Beralih ke `@order_handler.go`.
> Konteks: Kita memakai **Gin Framework**.
> Instruksi:
> 1. Buat endpoint `POST /orders` dan `GET /orders/:id`.
> 2. Bind JSON request dari user. Tangani error bad request dengan fungsi utilitas kita: `response.Error(c, http.StatusBadRequest, err)`.
> 3. Jika berhasil, panggil `response.Success(c, data)`. 
> Jangan tulis logic validasi stok di sini, cukup panggil fungsi Usecase!"

---

## 🛡️ 4. Anti-Halusinasi & Best Practices Golang

Agar AI tidak asal _generate_ code ngawur di Go:

1. **Paksa AI Menulis "Clean Errors":** `"Jangan kembalikan string error mentah. Lakukan wrap pada error: fmt.Errorf(\"failed to get order: %w\", err)."`
2. **Kendalikan Framework Injection:** `"Jangan menggunakan pointer ke framework spesifik di UseCase/Repository. Gunakan 'context.Context' murni (stdlib Go)."`
3. **Minta AI Membaca Contoh yang Ada:** `"Sebelum menulis middleware Auth, tolong pelajari workflow di @04_auth_security.md untuk tahu standar internal kita mengenai parsing JWT."`

---

## 🐞 5. Vibe Debugging backend (Menangani Panic/Error)

Ketika aplikasi backend crash (Panic) atau HTTP me-return HTTP 500:
1. Pastikan Anda menyalin **stack trace** lengkap.
2. Identifikasi _layer_ (Handler, Usecase, DB) yang menjadi titik ledaknya.
3. Berikan prompt investigasi:
   > "Terjadi nil pointer dereference (panic) saat memanggil endpoint API `GET /products`. Ini *stack trace* nya: `[PASTE_TRACE]`.
   > Tolong periksa `@product_usecase.go` di baris yang bermasalah. Pastikan pengecekan error atau pengecekan *nil* dilakukan sebelum mengakses property objek."

---

## 📝 6. Lembar Contek (Cheat Sheet) Prompt Harian Golang

Simpan prompt ini untuk pekerjaan harian Anda:

### Menambahkan Validasi DTO (Data Transfer Object)
> "Tolong tambahkan struct tag `binding:\"required\"` pada `@order_request.go` untuk field `ProductID` dan `Quantity`. Pastikan handler akan me-return HTTP 400 jika field ini tidak dikirimkan."

### Integrasi Redis Caching
> "Mengacu pada workflow di `@08_caching_redis.md`, tolong implementasikan _Redis caching_ untuk method `GetProductByID` di usecase layer (`@product_usecase.go`). Cek cache dulu, kalau *miss* baru panggil repository lalu simpan ke Redis dengan TTL 1 jam."

### Pembuatan Unit Test Cepat (TDD Vibe)
> "Tolong buatkan unit test file `@product_usecase_test.go` menggunakan `testify/assert` dan `testify/mock`. Buat skenario: 1) Sukses mendapatkan data, 2) Data tak ditemukan, 3) Terjadi error database."

### Refactor Fungsi Panjang
> "Fungsi `ProcessPayment` di `@payment_usecase.go` ini sudah terlalu panjang dan banyak logika _if-else_ yang bersarang (nested). Tolong refactor (ekstrak) logika perhitungan pajak dan validasi kupon ke fungsi private yang berbeda agar kodenya lebih *readable*."

---

## 🚀 Kesimpulan

Dalam Vibe Coding Backend Golang, ketegasan arsitektural adalah kuncinya. Anda harus bertindak sebagai _Tech Lead_ yang memaksa AI patuh pada batasan (seperti Clean Architecture dan Context). Pecah tugas besar menjadi bagian kecil (Scaffolding -> Repo -> Usecase -> Handler). Patuhi alur workflow di repositori Anda, dan biarkan AI menyingkirkan semua beban penulisan _boilerplate_ Go untuk Anda!

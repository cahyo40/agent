---
description: Setup Flutter project dari nol dengan Clean Architecture, GetX, dan YoUI. (Part 5/5)
---
# Workflow: Flutter Project Setup with GetX + YoUI (Part 5/5)

> **Navigation:** This workflow is split into 5 parts.

## Workflow Steps

### Step 1: Create Flutter Project

```bash
flutter create --org com.example my_app
cd my_app
```

### Step 2: Run YoDev Generator

```bash
# YoDev Generator mengkonfigurasi project Anda otomatis.
dart run yo.dart init --state=getx
```

### Step 3: Verify & Install Dependencies

- Pastikan `yo.yaml` sudah bersarang di root project.
- Jalankan sinkronasi package untuk mendownload YoUI & GetX:
```bash
flutter pub get
```

### Step 4: Setup Core Layer & App Properties

1. Cek `/lib/main.dart` dan konfigurasi `YoTheme` di `app.dart`.
2. Lakukan implementasi kustom seperti error handler pada file base `core/` jika terdapat `// TODO`.
3. Verifikasi rute dan app bindings di `layer/routes`.

### Step 5: Verify Run Project

```bash
flutter pub get
flutter run
```

## Success Criteria

- [ ] Project directory matching dengan standard target `yo.dart` (GetX version).
- [ ] File konfigurasi `yo.yaml` ada di direktori root.
- [ ] Project berjalan tanpa error & tidak ada conflict dependency YoUI.
- [ ] `flutter analyze` clean (no warnings).
- [ ] YoUI Theme terapply (cek font, warna, border radius) saat aplikasi launch pertama kali.

---

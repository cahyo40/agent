---
description: Generate feature baru dengan struktur Clean Architecture lengkap menggunakan GetX pattern. (Part 1/5)
---
# Workflow: Flutter Feature Maker (GetX) (Part 1/5)

> **Navigation:** This workflow is split into 5 parts.

## Overview

Generate feature baru dengan struktur Clean Architecture lengkap menggunakan GetX pattern. Workflow ini memanfaatkan generator CLI `yo.dart` untuk base template pembuatan Entity, Model, Interface Repositories, Use case, GetxController, Binding, dan View (`GetView`) tanpa mengharuskan Anda membangun file dari awal.

## Output Location

**Base Folder:** `lib/features/`

**Action Files:**
- Pengeditan akan bergantung pada file hasil generasi dengan menindaklanjuti comment flag `// TODO`.

## Prerequisites

- Project setup menggunakan `dart run yo.dart init --state=getx` telah selesai.
- Menguasai dasar-dasar GetX (`GetView`, `.obs`, `GetxController`, `Get.toNamed()`).
- Package ter-install: `get`, `get_storage`, `dio`, `equatable`, `dartz`, dan `yo_ui` components.


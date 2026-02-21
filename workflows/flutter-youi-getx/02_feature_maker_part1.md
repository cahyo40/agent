---
description: Generate feature baru dengan struktur Clean Architecture lengkap menggunakan GetX pattern. (Part 1/10)
---
# Workflow: Flutter Feature Maker (GetX) (Part 1/10)

> **Navigation:** This workflow is split into 10 parts.

## Overview

Generate feature baru dengan struktur Clean Architecture lengkap menggunakan GetX pattern. Workflow ini membuat boilerplate code untuk feature baru termasuk entity, model (manual JSON serialization), repository, use case, GetxController, Binding, dan screen (GetView). Tidak perlu code generation (build_runner/freezed) -- semua file langsung siap pakai.


## Output Location

**Base Folder:** `sdlc/flutter-youi/02-feature-maker/`

**Output Files:**
- `feature-template.md` - Panduan menggunakan template
- `feature-generator-script.md` - Script/logika untuk generate feature
- `templates/` - Template files untuk setiap layer
  - `domain/` - Entity, repository, use case templates
  - `data/` - Model (manual fromJson/toJson), repository impl, data source templates
  - `presentation/` - Controller, binding, view, widget templates
- `examples/` - Contoh feature yang sudah jadi (Todo)


## Prerequisites

- Project setup dari `01_project_setup.md` selesai
- Clean Architecture structure sudah ada
- Dependencies sudah terinstall (`get`, `get_storage`, `dio`, `equatable`, `dartz`, `shimmer`)


---
description: Generate feature baru dengan struktur Clean Architecture lengkap. (Part 1/4)
---
# Workflow: Flutter Feature Maker with YoUI (Part 1/4)

> **Navigation:** This workflow is split into 4 parts.

## Overview

Generate feature baru dengan struktur Clean Architecture lengkap. Workflow ini membuat boilerplate code untuk feature baru termasuk entity, model, repository, use case, controller, dan screen menggunakan YoUI widgets.


## Output Location

**Base Folder:** `sdlc/flutter-youi-riverpod/02-feature-maker/`

**Output Files:**
- `feature-template.md` - Panduan menggunakan template
- `feature-generator-script.md` - Script/logika untuk generate feature
- `templates/` - Template files untuk setiap layer
  - `domain/` - Entity, repository, use case templates
  - `data/` - Model, repository impl, data source templates
  - `presentation/` - Controller, screen, widget templates
- `examples/` - Contoh feature yang sudah jadi


## Prerequisites

- Project setup dari `01_project_setup.md` selesai
- Clean Architecture structure sudah ada
- Dependencies sudah terinstall (termasuk YoUI)

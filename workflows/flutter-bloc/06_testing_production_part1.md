---
description: Comprehensive testing (unit, widget, integration) dan production preparation khusus Flutter BLoC: `bloc_test` package... (Part 1/8)
---
# Workflow: Testing & Production (Flutter BLoC) (Part 1/8)

> **Navigation:** This workflow is split into 8 parts.

## Overview

Comprehensive testing (unit, widget, integration) dan production preparation khusus Flutter BLoC: `bloc_test` package, `MockBloc`, `whenListen`, CI/CD pipeline dengan `build_runner`, performance optimization, dan app store deployment.

**Perbedaan Utama dari Riverpod:**
- Testing pakai `bloc_test` package, bukan `ProviderContainer`
- `blocTest<Bloc, State>()` sebagai primary testing function
- Widget test wrap dengan `BlocProvider.value()`, bukan `ProviderScope`
- `MockBloc` / `MockCubit` dari `bloc_test` untuk widget tests
- `whenListen` untuk mock bloc streams
- `tearDown` wajib `bloc.close()` untuk prevent memory leaks
- CI/CD butuh `build_runner` step (untuk freezed/injectable code generation)


## Output Location

**Base Folder:** `sdlc/flutter-bloc/06-testing-production/`

**Output Files:**
- `testing/unit/` - Bloc unit tests dengan `blocTest`
- `testing/widget/` - Widget tests dengan `MockBloc`
- `testing/integration/` - Integration tests
- `testing/helpers/` - Test helpers, mocks, fixtures
- `ci-cd/` - GitHub Actions workflows
- `performance/` - Performance optimization guide
- `deployment/` - App store deployment guides
- `checklists/` - Production checklists


## Prerequisites

- Project setup dari `01_project_setup.md` selesai (clean architecture + injectable)
- Backend integration (REST API, Firebase, atau Supabase) selesai
- Features implemented dan functional
- `build_runner` configured dan berjalan tanpa error


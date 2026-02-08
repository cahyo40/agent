---
name: senior-flutter-developer
description: "Expert Flutter development with clean architecture, advanced Riverpod patterns, performance optimization, and production-ready mobile applications"
---

# Senior Flutter Developer

## Overview

This skill transforms you into a Staff-level Flutter Developer who architects and builds enterprise-grade mobile applications. You'll design scalable architectures, implement advanced state management patterns, optimize performance, and lead technical decisions.

## When to Use This Skill

- Use when architecting Flutter applications from scratch
- Use when implementing complex state management
- Use when optimizing app performance
- Use when reviewing code and mentoring
- Use when debugging complex issues
- Use when implementing advanced features

## Templates

This skill includes detailed templates for common patterns. Read the relevant template file when implementing:

### Core Templates

| Template | Path | Use Case |
|----------|------|----------|
| **Architecture** | `templates/architecture.md` | Clean Architecture layers, project structure |
| **Repository Pattern** | `templates/repository_pattern.md` | Offline-first, Either pattern, error handling |
| **Performance** | `templates/performance.md` | Slivers, RepaintBoundary, Isolates, caching |
| **Animations** | `templates/animations.md` | Implicit, explicit, staggered animations |

### State Management

| Template | Path | Use Case |
|----------|------|----------|
| **Riverpod** | `templates/state_management/riverpod.md` | Code generation, providers, AsyncValue |
| **BLoC** | `templates/state_management/bloc.md` | Events, states, Cubit, event transformers |
| **GetX** | `templates/state_management/getx.md` | Rx variables, controllers, routing |

### Backend Integration

| Template | Path | Use Case |
|----------|------|----------|
| **Firebase** | `templates/backend_integration/firebase.md` | Auth, Firestore, FCM, Storage, Security |
| **Supabase** | `templates/backend_integration/supabase.md` | Auth, PostgreSQL, Realtime, RLS, Storage |

### Platform-Specific

| Template | Path | Use Case |
|----------|------|----------|
| **iOS** | `templates/platform/ios.md` | APNS, IAP, Face ID, widgets, privacy manifest |
| **Android** | `templates/platform/android.md` | FCM, flavors, ProGuard, signing, widgets |
| **Web** | `templates/platform/web.md` | Responsive, SEO, PWA, web renderers |
| **Desktop** | `templates/platform/desktop.md` | Window management, menus, system tray |
| **Platform Channels** | `templates/platform/platform_channels.md` | MethodChannel, EventChannel, Pigeon |

### Tooling

| Template | Path | Use Case |
|----------|------|----------|
| **Testing** | `templates/tooling/testing.md` | Unit, widget, integration, mocking |
| **CI/CD** | `templates/tooling/ci_cd.md` | GitHub Actions, Fastlane, Codemagic |
| **Package Development** | `templates/tooling/package_development.md` | API design, pub.dev publishing |

## Quick Reference

### Project Structure (Clean Architecture)

```text
lib/
├── bootstrap/           # App initialization
├── core/               # DI, network, router, storage, theme
├── features/<feature>/ # Feature modules
│   ├── data/           # DataSources, Models, RepositoryImpl
│   ├── domain/         # Entities, Repositories (abstract), UseCases
│   └── presentation/   # Controllers, Screens, Widgets
├── l10n/               # Localization
├── shared/             # Extensions, mixins, utils, shared widgets
└── main.dart
```

### State Management Decision

```
When to use what?
├── RIVERPOD (Recommended)
│   ├── Type-safe, compile-time checked
│   ├── No BuildContext needed
│   └── Best for dependency injection
│
├── BLOC/CUBIT
│   ├── Event-driven architecture
│   ├── Better for complex business logic
│   └── Strong testing support
│
└── GETX (Use with caution)
    ├── Simple apps only
    ├── Rapid prototyping
    └── Not recommended for enterprise
```

### Essential Packages

```yaml
dependencies:
  # State Management
  flutter_riverpod: ^2.4.0
  riverpod_annotation: ^2.3.0
  
  # Routing
  go_router: ^13.0.0
  
  # Network
  dio: ^5.4.0
  connectivity_plus: ^5.0.0
  
  # Storage
  hive_flutter: ^1.1.0
  flutter_secure_storage: ^9.0.0
  
  # UI
  cached_network_image: ^3.3.0
  shimmer: ^3.0.0
  
  # Utils
  freezed_annotation: ^2.4.0
  json_annotation: ^4.8.0
  intl: ^0.18.0

dev_dependencies:
  build_runner: ^2.4.0
  freezed: ^2.4.0
  json_serializable: ^6.7.0
  riverpod_generator: ^2.3.0
  mockito: ^5.4.0
  bloc_test: ^9.1.0
```

## Best Practices

### ✅ Do This

- ✅ Design for testability from the start
- ✅ Use dependency injection consistently
- ✅ Implement proper error boundaries
- ✅ Use `select` to minimize rebuilds
- ✅ Profile with DevTools before optimization
- ✅ Implement feature flags for gradual rollout
- ✅ Use code generation (freezed, riverpod_generator)
- ✅ Write migration strategy for breaking changes

### ❌ Avoid This

- ❌ Don't over-engineer simple features
- ❌ Don't ignore memory leaks in streams
- ❌ Don't skip integration tests
- ❌ Don't hardcode environment values
- ❌ Don't use BuildContext after async gaps
- ❌ Don't block UI thread with heavy computation

## Production Checklist

```markdown
### Pre-Release
- [ ] ProGuard/R8 rules configured (Android)
- [ ] App signing configured
- [ ] Environment configs separated (dev/staging/prod)
- [ ] Error tracking integrated (Sentry/Crashlytics)
- [ ] Analytics implemented
- [ ] Deep linking tested
- [ ] Push notifications working

### Performance
- [ ] Profiled with DevTools
- [ ] No jank in > 60fps animations
- [ ] Memory leaks checked
- [ ] Image caching configured
- [ ] Lazy loading for lists
- [ ] App size optimized

### Quality
- [ ] Unit test coverage > 80%
- [ ] Widget tests for critical flows
- [ ] Integration tests for happy paths
- [ ] Accessibility audit passed
- [ ] Localization complete
```

## Related Skills

- `@yo-flutter-dev` - Flutter with yo.dart generator and YoUI
- `@senior-ios-developer` - Native iOS patterns
- `@senior-android-developer` - Native Android patterns
- `@app-store-publisher` - Store publishing
- `@senior-ui-ux-designer` - Mobile UX
- `@dapp-mobile-developer` - Flutter + Web3

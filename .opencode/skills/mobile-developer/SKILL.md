---
name: mobile-developer
description: "Foundational mobile app development skills including iOS, Android, cross-platform concepts, and mobile UX patterns"
---

# Mobile Developer

## Overview

This skill provides foundational knowledge for building mobile applications across iOS, Android, and cross-platform frameworks. Covers core concepts, platform guidelines, and development workflows.

## When to Use This Skill

- Use when building mobile apps from scratch
- Use when learning mobile development fundamentals
- Use when choosing between native vs cross-platform
- Use when implementing mobile UX patterns
- Use when debugging mobile applications

## How It Works

### Step 1: Mobile Development Landscape

```text
MOBILE DEVELOPMENT OPTIONS
├── Native Development
│   ├── iOS (Swift, SwiftUI)
│   ├── Android (Kotlin, Jetpack Compose)
│   └── Best for: Performance, platform features
├── Cross-Platform
│   ├── Flutter (Dart)
│   ├── React Native (JavaScript)
│   └── Best for: Code sharing, faster development
└── Hybrid
    ├── Ionic, Capacitor
    └── Best for: Web-to-mobile, simple apps
```

### Step 2: Mobile App Architecture

```text
RECOMMENDED ARCHITECTURE
├── Presentation Layer
│   ├── Screens/Pages
│   ├── Widgets/Components
│   └── ViewModels/Controllers
├── Domain Layer
│   ├── Use Cases
│   ├── Entities
│   └── Repository Interfaces
├── Data Layer
│   ├── Repository Implementations
│   ├── Data Sources (API, Local DB)
│   └── Models/DTOs
└── Core
    ├── Utils/Helpers
    ├── Constants
    └── DI Container
```

### Step 3: Project Structure Example

```text
mobile_app/
├── lib/                    # Source code
│   ├── core/
│   │   ├── constants/
│   │   ├── theme/
│   │   └── utils/
│   ├── features/
│   │   ├── auth/
│   │   │   ├── data/
│   │   │   ├── domain/
│   │   │   └── presentation/
│   │   └── home/
│   └── main.dart
├── assets/
│   ├── images/
│   ├── icons/
│   └── fonts/
├── test/
└── pubspec.yaml
```

### Step 4: Mobile UX Patterns

```markdown
## Essential Mobile Patterns

### Navigation
- Bottom Navigation (3-5 items max)
- Tab Bar (iOS) / Navigation Drawer (Android)
- Stack Navigation for detail screens

### Common Screens
- Splash Screen (< 2 seconds)
- Onboarding (3-5 slides)
- Login/Register
- Home/Dashboard
- Profile/Settings

### Interactions
- Pull-to-refresh
- Infinite scroll
- Swipe actions
- Bottom sheets
- Floating action button (Android)
```

### Step 5: Platform Guidelines

```markdown
## iOS Human Interface Guidelines
- Use native iOS components
- Support Dynamic Type (text scaling)
- Respect safe areas (notch, home indicator)
- Use SF Symbols for icons
- Follow iOS navigation patterns

## Android Material Design
- Use Material components
- Support dark theme
- Handle back button properly
- Use vector drawables
- Follow Material motion patterns

## Cross-Platform Considerations
- Adapt UI per platform when needed
- Handle platform gestures
- Support both notch and non-notch devices
- Test on multiple screen sizes
```

### Step 6: Essential Mobile Features

```markdown
## Must-Have Features

### Performance
- [ ] App size < 50MB
- [ ] Launch time < 2 seconds
- [ ] 60fps animations
- [ ] Efficient memory usage

### Offline Support
- [ ] Cache essential data
- [ ] Queue actions when offline
- [ ] Sync when online
- [ ] Show offline indicator

### Security
- [ ] Secure storage for tokens
- [ ] Certificate pinning (optional)
- [ ] Biometric authentication
- [ ] Data encryption

### UX
- [ ] Loading states
- [ ] Error handling with retry
- [ ] Empty states
- [ ] Haptic feedback
```

## Best Practices

### ✅ Do This

- ✅ Follow platform design guidelines
- ✅ Support multiple screen sizes
- ✅ Implement offline-first when possible
- ✅ Handle permissions gracefully
- ✅ Optimize images and assets
- ✅ Test on real devices
- ✅ Use proper state management

### ❌ Avoid This

- ❌ Don't ignore platform conventions
- ❌ Don't block main thread
- ❌ Don't hardcode dimensions
- ❌ Don't forget accessibility
- ❌ Don't skip error handling
- ❌ Don't ignore memory leaks

## Choosing a Framework

| Criteria | Native | Flutter | React Native |
|----------|--------|---------|--------------|
| Performance | ⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐ |
| Dev Speed | ⭐ | ⭐⭐⭐ | ⭐⭐⭐ |
| UI Flexibility | ⭐⭐ | ⭐⭐⭐ | ⭐⭐ |
| Native Features | ⭐⭐⭐ | ⭐⭐ | ⭐⭐ |
| Learning Curve | Steep | Medium | Easy (if know JS) |

## Related Skills

- `@senior-flutter-developer` - Flutter apps
- `@senior-ios-developer` - iOS native
- `@senior-android-developer` - Android native
- `@react-native-developer` - React Native apps

---
name: expo-developer
description: "Expert Expo development including SDK 50+, EAS Build, managed workflow, bare workflow, and cross-platform React Native applications"
---

# Expo Developer

## Overview

Build cross-platform mobile applications using Expo's managed workflow. This skill covers Expo SDK 50+, EAS Build for cloud builds, Expo Router for file-based navigation, and best practices for production-ready React Native apps.

## When to Use This Skill

- Use when starting new React Native projects
- Use when you need over-the-air updates
- Use when building for iOS, Android, and Web simultaneously
- Use when you want simplified native module access
- Use when using EAS Build for cloud CI/CD

## Templates Reference

| Template | Description |
|----------|-------------|
| [project-setup.md](templates/project-setup.md) | New Expo project with best practices |
| [expo-router.md](templates/expo-router.md) | File-based routing patterns |
| [eas-build.md](templates/eas-build.md) | EAS Build & Submit configuration |
| [native-modules.md](templates/native-modules.md) | Using native modules in Expo |

## How It Works

### Step 1: Create New Project

```bash
# Create new Expo project
npx create-expo-app@latest my-app

# Or with specific template
npx create-expo-app@latest my-app --template tabs

# Navigate to project
cd my-app
```

### Step 2: Project Structure (Expo Router)

```text
my-app/
├── app/                    # File-based routing
│   ├── _layout.tsx        # Root layout
│   ├── index.tsx          # Home screen (/)
│   ├── (tabs)/            # Tab group
│   │   ├── _layout.tsx    # Tab layout
│   │   ├── home.tsx       # /home
│   │   └── settings.tsx   # /settings
│   ├── (auth)/            # Auth group
│   │   ├── _layout.tsx
│   │   ├── login.tsx
│   │   └── register.tsx
│   └── [id].tsx           # Dynamic route /:id
├── components/
├── hooks/
├── constants/
├── assets/
├── app.json
├── eas.json
└── package.json
```

### Step 3: Root Layout

```tsx
// app/_layout.tsx
import { Stack } from 'expo-router'
import { useFonts } from 'expo-font'
import * as SplashScreen from 'expo-splash-screen'
import { useEffect } from 'react'

SplashScreen.preventAutoHideAsync()

export default function RootLayout() {
  const [loaded] = useFonts({
    SpaceMono: require('../assets/fonts/SpaceMono-Regular.ttf'),
  })

  useEffect(() => {
    if (loaded) {
      SplashScreen.hideAsync()
    }
  }, [loaded])

  if (!loaded) return null

  return (
    <Stack>
      <Stack.Screen name="(tabs)" options={{ headerShown: false }} />
      <Stack.Screen name="(auth)" options={{ headerShown: false }} />
      <Stack.Screen name="modal" options={{ presentation: 'modal' }} />
    </Stack>
  )
}
```

### Step 4: Tab Navigation

```tsx
// app/(tabs)/_layout.tsx
import { Tabs } from 'expo-router'
import { Ionicons } from '@expo/vector-icons'

export default function TabLayout() {
  return (
    <Tabs
      screenOptions={{
        tabBarActiveTintColor: '#007AFF',
        headerShown: false,
      }}
    >
      <Tabs.Screen
        name="index"
        options={{
          title: 'Home',
          tabBarIcon: ({ color, size }) => (
            <Ionicons name="home" size={size} color={color} />
          ),
        }}
      />
      <Tabs.Screen
        name="explore"
        options={{
          title: 'Explore',
          tabBarIcon: ({ color, size }) => (
            <Ionicons name="search" size={size} color={color} />
          ),
        }}
      />
      <Tabs.Screen
        name="profile"
        options={{
          title: 'Profile',
          tabBarIcon: ({ color, size }) => (
            <Ionicons name="person" size={size} color={color} />
          ),
        }}
      />
    </Tabs>
  )
}
```

### Step 5: API Routes (Expo Router API)

```typescript
// app/api/users+api.ts
export async function GET(request: Request) {
  return Response.json({ users: [] })
}

export async function POST(request: Request) {
  const body = await request.json()
  return Response.json({ user: body }, { status: 201 })
}
```

## Best Practices

### ✅ Do This

- ✅ Use Expo Router for file-based navigation
- ✅ Configure EAS Build for production builds
- ✅ Use expo-constants for environment variables
- ✅ Implement proper error boundaries
- ✅ Use expo-updates for OTA updates
- ✅ Optimize images with expo-image

### ❌ Avoid This

- ❌ Don't eject unless absolutely necessary
- ❌ Don't use deprecated Expo SDK features
- ❌ Don't skip app.json configuration
- ❌ Don't ignore build warnings
- ❌ Don't hardcode sensitive credentials

## Common Pitfalls

**Problem:** Build fails on EAS with native module errors
**Solution:** Check expo-doctor and ensure compatible versions in package.json

**Problem:** OTA updates not applying
**Solution:** Verify expo-updates is configured and runtimeVersion matches

**Problem:** iOS build rejected for permissions
**Solution:** Add proper usage descriptions in app.json infoPlist

## Related Skills

- `@senior-react-native-developer` - Advanced React Native patterns
- `@senior-typescript-developer` - TypeScript best practices
- `@app-store-publisher` - App Store and Play Store publishing

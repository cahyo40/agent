---
name: senior-react-native-developer
description: "Expert React Native development including New Architecture (Fabric/TurboModules), native modules, Reanimated, and cross-platform performance"
---

# React Native Developer

## Overview

This skill transforms you into an **Expert React Native Engineer**. You will master the **New Architecture (Fabric/TurboModules)**, handle complex animations with **Reanimated 3**, integrate native modules, and optimize performance for production mobile apps.

## When to Use This Skill

- Use when building cross-platform mobile apps
- Use when integrating platform-specific APIs
- Use when optimizing animation framerates (60/120fps)
- Use when debugging startup time or memory usage
- Use when implementing OTA updates

---

## Part 1: React Native Architecture

### 1.1 Old vs New Architecture

| Aspect | Old Architecture | New Architecture |
|--------|------------------|------------------|
| **Communication** | JSON Bridge (async) | JSI (synchronous) |
| **Rendering** | Shadow Tree + Yoga | Fabric (C++ Renderer) |
| **Native Modules** | Bridge-based | TurboModules (JSI) |
| **Performance** | ~60fps limited | Near-native speeds |
| **Type Safety** | Manual | Codegen (TypeScript) |

### 1.2 Architecture Diagram

```
┌────────────────────────────────────────────────────────────────┐
│                    React Native App                             │
├────────────────────────────────────────────────────────────────┤
│  ┌──────────────┐  ┌───────────────┐  ┌───────────────────┐   │
│  │ JavaScript   │  │  Hermes/JSC   │  │   Native Layer    │   │
│  │ (React Code) │◄─┤  (JS Engine)  ├─►│  (iOS/Android)    │   │
│  └──────────────┘  └───────────────┘  └───────────────────┘   │
│         │                  │                    │               │
│         ▼                  ▼                    ▼               │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │                         JSI                              │   │
│  │              (JavaScript Interface)                      │   │
│  └─────────────────────────────────────────────────────────┘   │
│         │                  │                    │               │
│  ┌──────┴──────┐  ┌────────┴────────┐  ┌───────┴──────────┐   │
│  │   Fabric    │  │  TurboModules   │  │     Codegen      │   │
│  │ (Renderer)  │  │ (Native Modules)│  │ (Type Generation)│   │
│  └─────────────┘  └─────────────────┘  └──────────────────┘   │
└────────────────────────────────────────────────────────────────┘
```

### 1.3 Enabling New Architecture

**Android** (`android/gradle.properties`):

```properties
newArchEnabled=true
```

**iOS** (`ios/Podfile`):

```ruby
ENV['RCT_NEW_ARCH_ENABLED'] = '1'
```

---

## Part 2: Project Structure

### 2.1 Recommended Structure

```text
src/
├── app/                    # Navigation & entry
│   ├── screens/            # Screen components
│   └── navigation/         # Navigation config
├── components/             # Shared components
│   ├── ui/                 # Primitives (Button, Text)
│   └── forms/              # Form components
├── features/               # Feature modules
│   ├── auth/
│   ├── profile/
│   └── feed/
├── hooks/                  # Custom hooks
├── services/               # API services
├── stores/                 # Zustand/MMKV state
├── theme/                  # Design tokens
├── types/                  # TypeScript types
└── utils/                  # Helper functions
```

### 2.2 Technology Stack

| Layer | Recommended | Alternative |
|-------|-------------|-------------|
| **Navigation** | React Navigation 7 | Expo Router |
| **State Management** | Zustand + MMKV | Jotai, Redux Toolkit |
| **Data Fetching** | TanStack Query | SWR |
| **Forms** | React Hook Form | Formik |
| **Animations** | Reanimated 3 | Moti |
| **Styling** | StyleSheet | NativeWind |
| **Storage** | MMKV | Async Storage |

---

## Part 3: Performance Optimization

### 3.1 Performance Checklist

| Issue | Solution |
|-------|----------|
| Slow list rendering | FlashList (not FlatList) |
| JS thread blocking | Move to worklets (Reanimated) |
| Slow startup | Hermes, lazy loading |
| Memory leaks | Proper cleanup, weak references |
| Large bundle | Code splitting, lazy imports |

### 3.2 FlashList (Replacing FlatList)

FlashList recycles views like native RecyclerView/UICollectionView:

```tsx
import { FlashList } from '@shopify/flash-list';

function UserList({ users }: { users: User[] }) {
  return (
    <FlashList
      data={users}
      renderItem={({ item }) => <UserCard user={item} />}
      estimatedItemSize={100}   // Critical for performance
      drawDistance={250}         // Pre-render buffer
      keyExtractor={(item) => item.id}
    />
  );
}
```

### 3.3 Hermes Engine

Hermes compiles JavaScript to bytecode ahead of time:

| Metric | Without Hermes | With Hermes |
|--------|---------------|-------------|
| **TTI** | ~4.5s | ~2.0s |
| **Memory** | ~185MB | ~136MB |
| **APK Size** | ~16MB | ~12MB |

Enable in `android/app/build.gradle`:

```groovy
project.ext.react = [
    enableHermes: true,
]
```

---

## Part 4: Animations with Reanimated

### 4.1 Why Reanimated?

| Feature | Animated API | Reanimated 3 |
|---------|--------------|--------------|
| Thread | JS Thread | UI Thread (60fps) |
| Gestures | Limited | Gesture Handler |
| Complexity | Simple only | Any animation |
| Performance | Can drop frames | Native speed |

### 4.2 Basic Animation Pattern

```tsx
import Animated, { 
  useSharedValue, 
  useAnimatedStyle, 
  withSpring,
  withTiming,
} from 'react-native-reanimated';

function AnimatedCard() {
  const offset = useSharedValue(0);
  const scale = useSharedValue(1);
  
  const animatedStyle = useAnimatedStyle(() => ({
    transform: [
      { translateX: offset.value },
      { scale: scale.value },
    ],
  }));
  
  const handlePress = () => {
    offset.value = withSpring(Math.random() * 200);
    scale.value = withTiming(1.2, { duration: 200 });
  };
  
  return (
    <TouchableOpacity onPress={handlePress}>
      <Animated.View style={[styles.card, animatedStyle]}>
        <Text>Tap me!</Text>
      </Animated.View>
    </TouchableOpacity>
  );
}
```

### 4.3 Gesture Handler Integration

```tsx
import { Gesture, GestureDetector } from 'react-native-gesture-handler';
import Animated, { useSharedValue, useAnimatedStyle, withSpring } from 'react-native-reanimated';

function DraggableCard() {
  const translateX = useSharedValue(0);
  const translateY = useSharedValue(0);
  
  const gesture = Gesture.Pan()
    .onUpdate((event) => {
      translateX.value = event.translationX;
      translateY.value = event.translationY;
    })
    .onEnd(() => {
      translateX.value = withSpring(0);
      translateY.value = withSpring(0);
    });
  
  const animatedStyle = useAnimatedStyle(() => ({
    transform: [
      { translateX: translateX.value },
      { translateY: translateY.value },
    ],
  }));
  
  return (
    <GestureDetector gesture={gesture}>
      <Animated.View style={[styles.card, animatedStyle]} />
    </GestureDetector>
  );
}
```

---

## Part 5: State Management

### 5.1 Zustand + MMKV Pattern

**Why MMKV over AsyncStorage?**

- Synchronous (no await needed)
- 30x faster
- C++ implementation

```typescript
import { create } from 'zustand';
import { persist, createJSONStorage } from 'zustand/middleware';
import { MMKV } from 'react-native-mmkv';

const storage = new MMKV();

const mmkvStorage = {
  getItem: (name: string) => storage.getString(name) ?? null,
  setItem: (name: string, value: string) => storage.set(name, value),
  removeItem: (name: string) => storage.delete(name),
};

interface AuthStore {
  token: string | null;
  user: User | null;
  login: (token: string, user: User) => void;
  logout: () => void;
}

export const useAuthStore = create<AuthStore>()(
  persist(
    (set) => ({
      token: null,
      user: null,
      login: (token, user) => set({ token, user }),
      logout: () => set({ token: null, user: null }),
    }),
    {
      name: 'auth-storage',
      storage: createJSONStorage(() => mmkvStorage),
    }
  )
);
```

---

## Part 6: Navigation

### 6.1 React Navigation 7 Setup

```tsx
import { NavigationContainer } from '@react-navigation/native';
import { createNativeStackNavigator } from '@react-navigation/native-stack';

type RootStackParamList = {
  Home: undefined;
  Profile: { userId: string };
  Settings: undefined;
};

const Stack = createNativeStackNavigator<RootStackParamList>();

function App() {
  return (
    <NavigationContainer>
      <Stack.Navigator
        screenOptions={{
          headerShown: false,
          animation: 'slide_from_right',
        }}
      >
        <Stack.Screen name="Home" component={HomeScreen} />
        <Stack.Screen 
          name="Profile" 
          component={ProfileScreen}
          options={{ presentation: 'modal' }}
        />
      </Stack.Navigator>
    </NavigationContainer>
  );
}
```

### 6.2 Type-Safe Navigation

```tsx
import { useNavigation, useRoute } from '@react-navigation/native';
import type { NativeStackNavigationProp } from '@react-navigation/native-stack';
import type { RouteProp } from '@react-navigation/native';

type ProfileScreenNavigationProp = NativeStackNavigationProp<RootStackParamList, 'Profile'>;
type ProfileScreenRouteProp = RouteProp<RootStackParamList, 'Profile'>;

function ProfileScreen() {
  const navigation = useNavigation<ProfileScreenNavigationProp>();
  const route = useRoute<ProfileScreenRouteProp>();
  
  const { userId } = route.params;
  
  return (
    <View>
      <Text>User: {userId}</Text>
      <Button onPress={() => navigation.navigate('Settings')} title="Settings" />
    </View>
  );
}
```

---

## Part 7: Native Modules (TurboModules)

### 7.1 Creating a TurboModule

**Step 1: Define TypeScript Spec**

```typescript
// NativeCalculator.ts
import type { TurboModule } from 'react-native';
import { TurboModuleRegistry } from 'react-native';

export interface Spec extends TurboModule {
  add(a: number, b: number): Promise<number>;
  multiply(a: number, b: number): number; // Synchronous with JSI
}

export default TurboModuleRegistry.getEnforcing<Spec>('Calculator');
```

**Step 2: Implement (Kotlin)**

```kotlin
class CalculatorModule(context: ReactApplicationContext) : 
  NativeCalculatorSpec(context) {

  override fun getName() = "Calculator"

  override fun add(a: Double, b: Double, promise: Promise) {
    promise.resolve(a + b)
  }
  
  override fun multiply(a: Double, b: Double): Double {
    return a * b
  }
}
```

---

## Part 8: Best Practices Summary

### ✅ Do This

- ✅ **Enable Hermes** - Mandatory for performance
- ✅ **Use FlashList** - Not FlatList for lists
- ✅ **Use MMKV** - Not AsyncStorage
- ✅ **Memoize callbacks** - `useCallback` for native props
- ✅ **Define styles outside** - `StyleSheet.create` outside component

### ❌ Avoid This

- ❌ **ScrollView for lists** - Renders ALL children (OOM crash)
- ❌ **Heavy JS computation** - Move to native/worklets
- ❌ **Inline functions in render** - Forces re-renders
- ❌ **Console.log in production** - Remove or use Reactotron

---

## Debugging Tools

| Tool | Purpose |
|------|---------|
| Flipper | Network, logs, performance |
| React DevTools | Component inspection |
| Perf Monitor | JS/UI FPS |
| Reactotron | State, API, async storage |

---

## Related Skills

- `@senior-react-developer` - React patterns
- `@senior-android-developer` - Native Android
- `@senior-ios-developer` - Native iOS
- `@flutter-riverpod-specialist` - Alternative: Flutter

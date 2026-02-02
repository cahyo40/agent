---
name: react-native-developer
description: "Expert React Native development including New Architecture (Fabric/TurboModules), native modules, Reanimated, and cross-platform performance"
---

# React Native Developer

## Overview

This skill transforms you into an **Expert React Native Engineer**. You will move beyond "bridged" JS threads to mastering the **New Architecture (Fabric/TurboModules)**, handling complex animations with **Reanimated 3**, integrating Native Modules (JSI), and optimizing performance (FlatList, Hermes).

## When to Use This Skill

- Use when building high-performance cross-platform apps
- Use when integrating platform-specific APIs (Camera, Bluetooth)
- Use when optimizing animation framerates (60/120fps)
- Use when debugging startup time or memory usage
- Use when implementing OTA updates (CodePush/EAS)

---

## Part 1: The New Architecture (Fabric & TurboModules)

The bridge is dead. Synchronous communication is key.

### 1.1 Enabling New Architecture

In `android/gradle.properties`:

```properties
newArchEnabled=true
```

In `ios/Podfile`:

```ruby
ENV['RCT_NEW_ARCH_ENABLED'] = '1'
```

### 1.2 TurboModules (Native Modules)

Type-safe native modules using TypeScript (`Codegen`).

**1. Define Spec (JS/TS):**

```typescript
// NativeCalculator.ts
import type { TurboModule } from 'react-native';
import { TurboModuleRegistry } from 'react-native';

export interface Spec extends TurboModule {
  add(a: number, b: number): Promise<number>;
}

export default TurboModuleRegistry.getEnforcing<Spec>('Calculator');
```

**2. Implement (Kotlin/Android):**

```kotlin
class CalculatorModule(context: ReactApplicationContext) : 
  NativeCalculatorSpec(context) {

  override fun getName() = "Calculator"

  override fun add(a: Double, b: Double, promise: Promise) {
    promise.resolve(a + b)
  }
}
```

---

## Part 2: High-Performance UI

### 2.1 FlashList (Better FlatList)

`FlatList` creates a view for every item. `FlashList` recycles views (like RecyclerView/UICollectionView).

```tsx
import { FlashList } from "@shopify/flash-list";

const MyList = ({ data }) => {
  return (
    <FlashList
      data={data}
      renderItem={({ item }) => <Text>{item.title}</Text>}
      estimatedItemSize={200} // Critical for performance
      drawDistance={250}
    />
  );
};
```

### 2.2 Reanimated 3 (Worklet Animations)

Run animations on UI Thread, not JS Thread.

```tsx
import Animated, { 
  useSharedValue, 
  useAnimatedStyle, 
  withSpring 
} from 'react-native-reanimated';

const Box = () => {
  const offset = useSharedValue(0);

  const style = useAnimatedStyle(() => ({
    transform: [{ translateX: offset.value }],
  }));

  return (
    <>
      <Animated.View style={[styles.box, style]} />
      <Button onPress={() => (offset.value = withSpring(Math.random() * 255))} />
    </>
  );
};
```

---

## Part 3: Navigation & State

### 3.1 React Navigation 6/7

Stack is native on iOS (`UINavigationController`) via `react-native-screens`.

```tsx
<Stack.Navigator
  screenOptions={{
    headerShown: false, // Custom headers are better
    animation: 'slide_from_right',
    presentation: 'modal', // Native modal behavior
  }}
>
  <Stack.Screen name="Home" component={HomeScreen} />
  <Stack.Screen name="Profile" component={ProfileScreen} />
</Stack.Navigator>
```

### 3.2 State Management (Zustand + MMKV)

Don't use AsyncStorage (it's slow & async). Use MMKV (C++ synchronous storage).

```typescript
import { create } from 'zustand';
import { MMKV } from 'react-native-mmkv';

const storage = new MMKV();

const useStore = create((set) => ({
  bears: 0,
  increasePopulation: () => set((state) => ({ bears: state.bears + 1 })),
  // Persist logic manually or via middleware
  hydrate: () => {
    const bears = storage.getNumber('bears') || 0;
    set({ bears });
  },
}));
```

---

## Part 4: Native Integration Patterns

### 4.1 Native UI Components (Fabric)

Exposing a custom Android `VideoView` or iOS `MapView` to React Native.

**JS Spec:**

```typescript
// MapViewNativeComponent.ts
import codegenNativeComponent from 'react-native/Libraries/Utilities/codegenNativeComponent';
import type { ViewProps } from 'react-native';

interface NativeProps extends ViewProps {
  zoomEnabled?: boolean;
}

export default codegenNativeComponent<NativeProps>('MapView');
```

---

## Part 5: Debugging & Profiling

### 5.1 Flipper (Deprecated) -> Chrome DevTools & React DevTools

- **CPU Profiler**: Find JS bottlenecks.
- **Perf Monitor**: Check JS FPS vs UI FPS.
  - If JS FPS < 60: Logic is too heavy on JS thread.
  - If UI FPS < 60: Too many views or overdraw.

### 5.2 Hermes Engine

Enable Hermes. It compiles JS to Bytecode ahead of time (AOT).

```groovy
// android/app/build.gradle
project.ext.react = [
    enableHermes: true,
]
```

---

## Part 6: Best Practices Checklist

### ✅ Do This

- ✅ **Enable Hermes**: Mandatory for startup speed and memory.
- ✅ **Use `useCallback` / `useMemo`**: Optimization is critical in RN to prevent re-renders passing props to Native Components.
- ✅ **Lazy Load Bundles**: Split your bundle if the app is huge (`React.lazy`).
- ✅ **Styles outside render**: Define `StyleSheet.create` outside the component to avoid recreating style objects.

### ❌ Avoid This

- ❌ **`ScrollView` for lists**: It renders ALL children at once. OOM Crash. Use `FlashList`.
- ❌ **Doing heavy math in JS**: Move image processing / heavy calc to C++/Native via JSI/TurboModule.
- ❌ **Inline Functions in Render**: `<View onLayout={() => {}} />` forces re-render.

---

## Related Skills

- `@senior-react-developer` - React Core concepts
- `@senior-android-developer` - Native Android Code
- `@senior-ios-developer` - Native iOS Code

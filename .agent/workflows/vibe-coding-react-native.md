---
description: Initialize Vibe Coding context files for React Native mobile application
---

# /vibe-coding-react-native

Workflow untuk setup dokumen konteks Vibe Coding khusus **React Native Mobile Application**.

---

## 📋 Prerequisites

1. **Deskripsi ide aplikasi mobile**
2. **Framework: Expo / Bare React Native?**
3. **Navigation: React Navigation / Expo Router?**
4. **Backend: Firebase / Supabase / Custom API?**
5. **State Management: Zustand / Redux Toolkit / TanStack Query?**

---

## 🏗️ Phase 1: Holy Trinity

### Step 1.1: Generate PRD.md

Skill: `senior-project-manager`

```markdown
Buatkan PRD.md untuk React Native app: [IDE]
- Executive Summary, Problem, Target User
- User Stories (10+ MVP)
- Features: Must/Should/Could/Won't
- Platform: iOS / Android / Both
- Success Metrics
```

// turbo
**Simpan ke `PRD.md`**

---

### Step 1.2: Generate TECH_STACK.md

Skill: `tech-stack-architect` + `react-native-developer`

```markdown
## Core Stack
- React Native: 0.73+
- Expo SDK: 50+ (recommended)
- Language: TypeScript strict
- Minimum iOS: 13.0
- Minimum Android: API 24

## Navigation
- Expo Router (file-based) / React Navigation 6

## State Management
- Server State: TanStack Query
- Client State: Zustand
- Forms: React Hook Form + Zod

## UI & Styling
- NativeWind (Tailwind for RN) / StyleSheet
- Expo Vector Icons
- React Native Reanimated 3

## Backend
- [Firebase / Supabase / Custom API]
- HTTP: Axios / fetch

## Storage
- Expo SecureStore (sensitive data)
- AsyncStorage / MMKV (general)

## Push Notifications
- Expo Notifications

## Approved Packages
```json
{
  "dependencies": {
    "expo": "~50.0.0",
    "expo-router": "~3.4.0",
    "react-native": "0.73.x",
    "@tanstack/react-query": "^5.17.0",
    "zustand": "^4.5.0",
    "react-hook-form": "^7.49.0",
    "zod": "^3.22.0",
    "nativewind": "^4.0.0",
    "react-native-reanimated": "^3.6.0",
    "expo-secure-store": "~12.8.0",
    "@react-native-async-storage/async-storage": "1.21.0",
    "axios": "^1.6.0"
  }
}
```

```

// turbo
**Simpan ke `TECH_STACK.md`**

---

### Step 1.3: Generate RULES.md

Skill: `react-native-developer`

```markdown
## TypeScript Rules
- Strict mode WAJIB
- DILARANG `any`
- Props dengan interface/type
- Explicit return types

## Component Rules
- Functional components only
- Custom hooks untuk logic
- Max 150 baris per component
- Memoize expensive components

## Styling Rules
- NativeWind atau StyleSheet
- DILARANG inline styles untuk styles yang repeated
- Responsive dengan Dimensions atau useWindowDimensions
- Platform-specific styles dengan Platform.select()

## Navigation Rules
- Type-safe navigation dengan typed routes
- Deep linking configured
- Auth flow dengan protected routes

## State Management Rules
- TanStack Query untuk server state
- Zustand untuk client state
- JANGAN mix responsibilities

## Performance Rules
- FlatList untuk long lists (BUKAN ScrollView)
- Memoize dengan useMemo, useCallback
- Lazy load screens dengan React.lazy
- Optimize images dengan proper caching

## Platform Rules
- Test di KEDUA platform (iOS & Android)
- Handle notch/safe area
- Handle keyboard dengan KeyboardAvoidingView

## AI Behavior Rules
1. JANGAN import package tidak ada di package.json
2. Handle both iOS dan Android
3. Handle safe areas
4. Handle keyboard properly
5. Refer ke API_CONTRACT.md
6. Follow FOLDER_STRUCTURE.md
```

// turbo
**Simpan ke `RULES.md`**

---

## 🎨 Phase 2: Support System

### Step 2.1: FOLDER_STRUCTURE.md

#### Expo Router Structure

```
app/
├── _layout.tsx                  # Root layout
├── index.tsx                    # Home screen
├── (auth)/                      # Auth group
│   ├── _layout.tsx
│   ├── login.tsx
│   └── register.tsx
├── (tabs)/                      # Tab navigator
│   ├── _layout.tsx
│   ├── home.tsx
│   ├── profile.tsx
│   └── settings.tsx
└── [id].tsx                     # Dynamic route

src/
├── components/
│   ├── ui/                      # Base components
│   │   ├── Button.tsx
│   │   ├── Input.tsx
│   │   └── Card.tsx
│   └── features/                # Feature components
│
├── hooks/                       # Custom hooks
│   ├── useAuth.ts
│   └── useUsers.ts
│
├── lib/
│   ├── api/                     # API functions
│   ├── stores/                  # Zustand stores
│   └── utils/                   # Utilities
│
├── types/                       # TypeScript types
└── constants/                   # App constants
    ├── colors.ts
    └── layout.ts
```

// turbo
**Simpan ke `FOLDER_STRUCTURE.md`**

---

### Step 2.2: DESIGN_SYSTEM.md

```markdown
## Colors
```typescript
export const colors = {
  primary: '#0ea5e9',
  secondary: '#64748b',
  background: '#ffffff',
  surface: '#f8fafc',
  text: '#0f172a',
  textSecondary: '#64748b',
  error: '#ef4444',
  success: '#22c55e',
};
```

## Typography

```typescript
export const typography = {
  h1: { fontSize: 32, fontWeight: '700' },
  h2: { fontSize: 24, fontWeight: '600' },
  h3: { fontSize: 20, fontWeight: '600' },
  body: { fontSize: 16, fontWeight: '400' },
  caption: { fontSize: 12, fontWeight: '400' },
};
```

## Spacing

```typescript
export const spacing = {
  xs: 4,
  sm: 8,
  md: 16,
  lg: 24,
  xl: 32,
};
```

## Border Radius

```typescript
export const borderRadius = {
  sm: 4,
  md: 8,
  lg: 16,
  full: 9999,
};
```

```

// turbo
**Simpan ke `DESIGN_SYSTEM.md`**

---

### Step 2.3: EXAMPLES.md

```markdown
## 1. Screen Component
```tsx
// app/(tabs)/home.tsx
import { View, Text, FlatList } from 'react-native';
import { useUsers } from '@/hooks/useUsers';
import { UserCard } from '@/components/features/UserCard';
import { Loading } from '@/components/ui/Loading';
import { ErrorView } from '@/components/ui/ErrorView';

export default function HomeScreen() {
  const { data: users, isLoading, error, refetch } = useUsers();

  if (isLoading) return <Loading />;
  if (error) return <ErrorView message={error.message} onRetry={refetch} />;

  return (
    <View className="flex-1 bg-background">
      <FlatList
        data={users}
        keyExtractor={(item) => item.id}
        renderItem={({ item }) => <UserCard user={item} />}
        contentContainerClassName="p-4 gap-4"
      />
    </View>
  );
}
```

## 2. Custom Hook with TanStack Query

```typescript
// hooks/useUsers.ts
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { getUsers, createUser } from '@/lib/api/users';

export function useUsers() {
  return useQuery({
    queryKey: ['users'],
    queryFn: getUsers,
  });
}

export function useCreateUser() {
  const queryClient = useQueryClient();
  
  return useMutation({
    mutationFn: createUser,
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['users'] });
    },
  });
}
```

## 3. Reusable Component

```tsx
// components/ui/Button.tsx
import { Pressable, Text, ActivityIndicator } from 'react-native';
import { cn } from '@/lib/utils';

interface ButtonProps {
  onPress: () => void;
  children: string;
  variant?: 'primary' | 'secondary';
  loading?: boolean;
  disabled?: boolean;
}

export function Button({
  onPress,
  children,
  variant = 'primary',
  loading = false,
  disabled = false,
}: ButtonProps) {
  return (
    <Pressable
      onPress={onPress}
      disabled={disabled || loading}
      className={cn(
        'py-3 px-6 rounded-lg items-center justify-center',
        variant === 'primary' && 'bg-primary',
        variant === 'secondary' && 'bg-secondary',
        disabled && 'opacity-50'
      )}
    >
      {loading ? (
        <ActivityIndicator color="white" />
      ) : (
        <Text className="text-white font-semibold">{children}</Text>
      )}
    </Pressable>
  );
}
```

## 4. Zustand Store

```typescript
// lib/stores/authStore.ts
import { create } from 'zustand';
import * as SecureStore from 'expo-secure-store';

interface AuthStore {
  token: string | null;
  user: User | null;
  setAuth: (token: string, user: User) => void;
  logout: () => void;
}

export const useAuthStore = create<AuthStore>((set) => ({
  token: null,
  user: null,
  setAuth: async (token, user) => {
    await SecureStore.setItemAsync('token', token);
    set({ token, user });
  },
  logout: async () => {
    await SecureStore.deleteItemAsync('token');
    set({ token: null, user: null });
  },
}));
```

## 5. Form with Validation

```tsx
import { useForm, Controller } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { z } from 'zod';

const schema = z.object({
  email: z.string().email(),
  password: z.string().min(8),
});

type FormData = z.infer<typeof schema>;

export function LoginForm() {
  const { control, handleSubmit, formState: { errors } } = useForm<FormData>({
    resolver: zodResolver(schema),
  });

  const onSubmit = (data: FormData) => {
    // Handle login
  };

  return (
    <View className="gap-4">
      <Controller
        control={control}
        name="email"
        render={({ field: { onChange, value } }) => (
          <Input
            placeholder="Email"
            value={value}
            onChangeText={onChange}
            error={errors.email?.message}
          />
        )}
      />
      <Button onPress={handleSubmit(onSubmit)}>Login</Button>
    </View>
  );
}
```

```

// turbo
**Simpan ke `EXAMPLES.md`**

---

## ✅ Phase 3: Project Setup

// turbo
```bash
npx create-expo-app@latest . --template tabs
npx expo install nativewind tailwindcss react-native-reanimated
npm install @tanstack/react-query zustand react-hook-form zod axios
npx expo install expo-secure-store
```

---

## 📁 Checklist

```
PRD.md, TECH_STACK.md, RULES.md, DESIGN_SYSTEM.md,
DB_SCHEMA.md, FOLDER_STRUCTURE.md, API_CONTRACT.md, EXAMPLES.md
```

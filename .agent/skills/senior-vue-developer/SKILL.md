---
name: senior-vue-developer
description: "Expert Vue.js development including Composition API, state management with Pinia, component patterns, and Vue 3 best practices"
---

# Senior Vue.js Developer

## Overview

This skill transforms you into an **Expert Vue.js Engineer** capable of building scalable Vue 3 applications. You will master the Composition API, implement Pinia for state management, apply modern component patterns, and optimize for production.

## When to Use This Skill

- Use when building Vue.js applications
- Use when implementing Composition API
- Use when managing state with Pinia
- Use when optimizing Vue performance
- Use when designing component architectures

---

## Part 1: Vue 3 Fundamentals

### 1.1 Vue's Core Philosophy

| Principle | Description |
|-----------|-------------|
| **Progressive Framework** | Adopt incrementally, from library to full framework |
| **Reactivity System** | Automatic dependency tracking and updates |
| **Single-File Components** | Template, logic, and styles in one file |
| **Composition over Options** | Composition API for better code organization |
| **Template Syntax** | Declarative HTML-based templates |

### 1.2 Options API vs Composition API

| Aspect | Options API | Composition API |
|--------|-------------|-----------------|
| **Organization** | By option (data, methods, computed) | By feature/concern |
| **Reusability** | Mixins (problematic) | Composables (clean) |
| **TypeScript** | Requires workarounds | First-class support |
| **Learning Curve** | Easier for beginners | Slightly steeper |
| **Recommendation** | Legacy projects | All new projects |

### 1.3 Vue 3 vs Vue 2 Key Differences

| Feature | Vue 2 | Vue 3 |
|---------|-------|-------|
| **Reactivity** | Object.defineProperty | Proxy (faster, complete) |
| **API Style** | Options API | Composition API + Options |
| **Fragments** | Not supported | Supported |
| **Teleport** | Not available | Built-in |
| **State Management** | Vuex | Pinia (recommended) |
| **Build Size** | Larger | Tree-shakeable, smaller |

---

## Part 2: Project Architecture

### 2.1 Recommended Structure

```text
src/
├── assets/            # Static assets (images, fonts)
├── components/        # Reusable components
│   ├── ui/            # Base components (Button, Input)
│   └── layout/        # Layout components (Header, Sidebar)
├── composables/       # Composition functions (auto-imported)
├── views/             # Page components
├── stores/            # Pinia stores
├── services/          # API services
├── types/             # TypeScript types
├── router/            # Vue Router configuration
├── utils/             # Helper functions
├── App.vue
└── main.ts
```

### 2.2 File Naming Conventions

| Type | Convention | Example |
|------|------------|---------|
| Components | PascalCase | `UserCard.vue` |
| Composables | camelCase with `use` prefix | `useAuth.ts` |
| Stores | camelCase with `use` prefix | `useUserStore.ts` |
| Views | PascalCase with View suffix | `DashboardView.vue` |
| Services | camelCase | `userService.ts` |

---

## Part 3: Composition API Patterns

### 3.1 Script Setup Syntax

The `<script setup>` is the recommended way to write Composition API:

```vue
<script setup lang="ts">
import { ref, computed, onMounted } from 'vue';

// Props with TypeScript
const props = defineProps<{
  userId: string;
  showDetails?: boolean;
}>();

// Emits with TypeScript
const emit = defineEmits<{
  (e: 'update', value: string): void;
  (e: 'delete', id: string): void;
}>();

// Reactive state
const user = ref<User | null>(null);
const isLoading = ref(true);

// Computed
const fullName = computed(() => 
  user.value ? `${user.value.firstName} ${user.value.lastName}` : ''
);

// Methods
const fetchUser = async () => {
  isLoading.value = true;
  try {
    user.value = await userService.getUser(props.userId);
  } finally {
    isLoading.value = false;
  }
};

// Lifecycle
onMounted(fetchUser);
</script>

<template>
  <div v-if="isLoading">Loading...</div>
  <div v-else-if="user">
    <h1>{{ fullName }}</h1>
    <button @click="emit('update', user.id)">Edit</button>
  </div>
</template>
```

### 3.2 Ref vs Reactive

| Feature | `ref()` | `reactive()` |
|---------|---------|--------------|
| **Type** | Any value | Objects only |
| **Access** | `.value` required | Direct access |
| **Reassignment** | Supported | Not supported |
| **Destructure** | Safe | Loses reactivity |
| **Recommendation** | Default choice | Complex objects |

```ts
// ref - preferred for primitives and objects
const count = ref(0);
const user = ref<User | null>(null);

// reactive - for complex state objects
const form = reactive({
  email: '',
  password: '',
  errors: {},
});
```

---

## Part 4: State Management

### 4.1 When to Use What

| State Type | Solution |
|------------|----------|
| Local component | `ref()`, `reactive()` |
| Parent-child | Props + Emits |
| Sibling/cross-component | `provide()`/`inject()` |
| Global app state | Pinia stores |
| Server data | Composables + fetch |

### 4.2 Pinia Store Patterns

**Option Store Syntax:**

```ts
// stores/user.ts
import { defineStore } from 'pinia';

export const useUserStore = defineStore('user', {
  state: () => ({
    user: null as User | null,
    token: null as string | null,
  }),
  
  getters: {
    isLoggedIn: (state) => !!state.token,
    fullName: (state) => 
      state.user ? `${state.user.firstName} ${state.user.lastName}` : '',
  },
  
  actions: {
    async login(email: string, password: string) {
      const response = await authService.login({ email, password });
      this.user = response.user;
      this.token = response.token;
    },
    
    logout() {
      this.user = null;
      this.token = null;
    },
  },
});
```

**Setup Store Syntax (Composition API style):**

```ts
// stores/cart.ts
import { defineStore } from 'pinia';
import { ref, computed } from 'vue';

export const useCartStore = defineStore('cart', () => {
  // State
  const items = ref<CartItem[]>([]);
  
  // Getters
  const total = computed(() => 
    items.value.reduce((sum, item) => sum + item.price * item.quantity, 0)
  );
  
  const itemCount = computed(() => items.value.length);
  
  // Actions
  function addItem(product: Product) {
    const existing = items.value.find(i => i.id === product.id);
    if (existing) {
      existing.quantity++;
    } else {
      items.value.push({ ...product, quantity: 1 });
    }
  }
  
  function removeItem(id: string) {
    items.value = items.value.filter(item => item.id !== id);
  }
  
  return { items, total, itemCount, addItem, removeItem };
});
```

---

## Part 5: Composables

### 5.1 Creating Reusable Composables

```ts
// composables/useApi.ts
import { ref, Ref } from 'vue';

interface UseApiReturn<T> {
  data: Ref<T | null>;
  error: Ref<Error | null>;
  isLoading: Ref<boolean>;
  execute: () => Promise<void>;
}

export function useApi<T>(fetcher: () => Promise<T>): UseApiReturn<T> {
  const data = ref<T | null>(null) as Ref<T | null>;
  const error = ref<Error | null>(null);
  const isLoading = ref(false);

  async function execute() {
    isLoading.value = true;
    error.value = null;
    try {
      data.value = await fetcher();
    } catch (e) {
      error.value = e as Error;
    } finally {
      isLoading.value = false;
    }
  }

  return { data, error, isLoading, execute };
}
```

### 5.2 Common Composable Patterns

| Composable | Purpose |
|------------|---------|
| `useAuth` | Authentication state and methods |
| `useLocalStorage` | Persist data in localStorage |
| `useFetch` | Data fetching with loading/error |
| `useForm` | Form state and validation |
| `useBreakpoints` | Responsive breakpoint detection |
| `useDebounce` | Debounced reactive values |

---

## Part 6: Component Communication

### 6.1 Communication Patterns

```
┌─────────────────────────────────────────────────────────────┐
│                  Component Communication                     │
├─────────────────────┬───────────────────────────────────────┤
│ Parent → Child      │ Props                                 │
│ Child → Parent      │ Emits                                 │
│ Ancestor → Descendant│ provide/inject                       │
│ Any → Any           │ Pinia store                           │
│ Siblings            │ Shared parent or store                │
└─────────────────────┴───────────────────────────────────────┘
```

### 6.2 Provide/Inject Pattern

```ts
// Parent component
import { provide, ref } from 'vue';

const theme = ref('light');
provide('theme', theme);

// Deep child component
import { inject } from 'vue';

const theme = inject<Ref<string>>('theme', ref('light'));
```

---

## Part 7: Performance Optimization

### 7.1 Optimization Techniques

| Issue | Solution |
|-------|----------|
| Large lists | `v-memo`, virtual scrolling |
| Heavy computation | `computed`, `watchEffect` |
| Async components | `defineAsyncComponent` |
| Unnecessary updates | `shallowRef`, `shallowReactive` |

### 7.2 v-memo for List Optimization

```vue
<template>
  <div v-for="item in list" :key="item.id" v-memo="[item.id, item.updated]">
    <ExpensiveComponent :data="item" />
  </div>
</template>
```

---

## Part 8: Best Practices Summary

### ✅ Do This

- ✅ Use `<script setup>` syntax
- ✅ Use TypeScript with Vue
- ✅ Extract logic to composables
- ✅ Use Pinia for global state
- ✅ Use `shallowRef` for large objects
- ✅ Use `v-memo` for expensive lists

### ❌ Avoid This

- ❌ Don't use Options API in new code
- ❌ Don't mutate props directly
- ❌ Don't overuse watchers
- ❌ Don't use Vuex (use Pinia)
- ❌ Don't destructure reactive objects
- ❌ Don't put heavy logic in templates

---

## Common Pitfalls

| Problem | Solution |
|---------|----------|
| Reactivity lost on destructure | Use `toRefs()` or access `.value` |
| Template ref not working | Match ref name with template attribute |
| Async setup blocking | Use `onMounted` for async |
| Pinia not persisting | Use `pinia-plugin-persistedstate` |

---

## Related Skills

- `@nuxt-developer` - Full-stack Vue with Nuxt
- `@senior-typescript-developer` - TypeScript patterns
- `@senior-ui-ux-designer` - Design implementation

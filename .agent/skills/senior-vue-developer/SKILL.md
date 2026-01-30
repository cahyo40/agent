---
name: senior-vue-developer
description: "Expert Vue.js development including Composition API, state management with Pinia, component patterns, and Vue 3 best practices"
---

# Senior Vue.js Developer

## Overview

This skill transforms you into an experienced Senior Vue Developer who builds scalable Vue 3 applications. You'll leverage the Composition API, implement Pinia for state management, and apply modern Vue best practices.

## When to Use This Skill

- Use when building Vue.js applications
- Use when implementing Composition API patterns
- Use when managing state with Pinia
- Use when optimizing Vue performance
- Use when the user asks about Vue patterns

## How It Works

### Step 1: Project Structure

```
src/
├── components/           # Reusable components
├── composables/          # Composition functions
├── views/                # Page components
├── stores/               # Pinia stores
├── services/             # API services
├── types/                # TypeScript types
├── router/               # Vue Router config
└── App.vue
```

### Step 2: Composition API Patterns

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
    user.value = await api.getUser(props.userId);
  } finally {
    isLoading.value = false;
  }
};

// Lifecycle
onMounted(() => {
  fetchUser();
});
</script>

<template>
  <div v-if="isLoading">Loading...</div>
  <div v-else-if="user">
    <h1>{{ fullName }}</h1>
    <button @click="emit('update', user.id)">Edit</button>
  </div>
</template>
```

### Step 3: Composables (Custom Hooks)

```typescript
// composables/useApi.ts
import { ref, Ref } from 'vue';

export function useApi<T>(fetcher: () => Promise<T>) {
  const data: Ref<T | null> = ref(null);
  const error = ref<Error | null>(null);
  const isLoading = ref(false);

  const execute = async () => {
    isLoading.value = true;
    error.value = null;
    try {
      data.value = await fetcher();
    } catch (e) {
      error.value = e as Error;
    } finally {
      isLoading.value = false;
    }
  };

  return { data, error, isLoading, execute };
}

// Usage in component
const { data: users, isLoading, execute } = useApi(() => api.getUsers());
onMounted(execute);
```

### Step 4: Pinia Store

```typescript
// stores/user.ts
import { defineStore } from 'pinia';

interface UserState {
  user: User | null;
  token: string | null;
}

export const useUserStore = defineStore('user', {
  state: (): UserState => ({
    user: null,
    token: null,
  }),
  
  getters: {
    isLoggedIn: (state) => !!state.token,
    fullName: (state) => 
      state.user ? `${state.user.firstName} ${state.user.lastName}` : '',
  },
  
  actions: {
    async login(email: string, password: string) {
      const { user, token } = await api.login(email, password);
      this.user = user;
      this.token = token;
    },
    
    logout() {
      this.user = null;
      this.token = null;
    },
  },
});

// Usage
const userStore = useUserStore();
await userStore.login(email, password);
```

## Examples

### Example 1: Form Component

```vue
<script setup lang="ts">
import { reactive } from 'vue';

const form = reactive({
  email: '',
  password: '',
});

const errors = reactive({
  email: '',
  password: '',
});

const validate = () => {
  errors.email = !form.email ? 'Email required' : '';
  errors.password = form.password.length < 8 ? 'Min 8 chars' : '';
  return !errors.email && !errors.password;
};

const submit = async () => {
  if (validate()) {
    await api.login(form);
  }
};
</script>

<template>
  <form @submit.prevent="submit">
    <input v-model="form.email" type="email" placeholder="Email" />
    <span v-if="errors.email">{{ errors.email }}</span>
    
    <input v-model="form.password" type="password" />
    <span v-if="errors.password">{{ errors.password }}</span>
    
    <button type="submit">Login</button>
  </form>
</template>
```

## Best Practices

### ✅ Do This

- ✅ Use `<script setup>` syntax
- ✅ Use TypeScript with Vue
- ✅ Extract logic to composables
- ✅ Use Pinia for global state
- ✅ Use `v-memo` for expensive lists

### ❌ Avoid This

- ❌ Don't use Options API in new code
- ❌ Don't mutate props directly
- ❌ Don't overuse watchers
- ❌ Don't use Vuex (use Pinia)

## Common Pitfalls

**Problem:** Reactivity lost when destructuring
**Solution:** Use `toRefs()` or access via `.value`.

**Problem:** Template refs not working
**Solution:** Ensure ref name matches template ref attribute.

## Related Skills

- `@senior-ui-ux-designer` - For design implementation
- `@senior-software-engineer` - For patterns

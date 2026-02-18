# 07 - Forms & Validation (VeeValidate + Zod)

**Goal:** Setup form handling dengan VeeValidate v4 dan Zod schema validation.

**Output:** `sdlc/nuxt-frontend/07-forms-validation/`

**Time Estimate:** 2-3 jam

---

## Install

```bash
pnpm add vee-validate zod @vee-validate/zod
```

---

## Deliverables

### 1. useFormField Composable

**File:** `composables/useFormField.ts`

```typescript
import { useField } from "vee-validate";

/** Composable for a single form field with VeeValidate. */
export function useFormField(name: string) {
  const { value, errorMessage, handleBlur, handleChange, meta } =
    useField(name);

  return {
    value,
    errorMessage,
    handleBlur,
    handleChange,
    meta,
    attrs: {
      onBlur: handleBlur,
      "onUpdate:modelValue": handleChange,
    },
  };
}
```

---

### 2. Reusable FormField Component

**File:** `components/shared/FormField.vue`

```vue
<script setup lang="ts">
interface Props {
  name: string;
  label: string;
  type?: string;
  placeholder?: string;
  description?: string;
  disabled?: boolean;
}

const props = withDefaults(defineProps<Props>(), { type: "text" });
const { value, errorMessage, attrs } = useFormField(props.name);
</script>

<template>
  <div class="space-y-2">
    <Label :for="name">{{ label }}</Label>
    <Input
      :id="name"
      v-model="value"
      :type="type"
      :placeholder="placeholder"
      :disabled="disabled"
      v-bind="attrs"
      :class="errorMessage ? 'border-destructive' : ''"
    />
    <p v-if="description && !errorMessage" class="text-xs text-muted-foreground">
      {{ description }}
    </p>
    <p v-if="errorMessage" class="text-xs text-destructive">
      {{ errorMessage }}
    </p>
  </div>
</template>
```

---

### 3. Create/Edit User Form

**File:** `components/features/UserForm.vue`

```vue
<script setup lang="ts">
import { useForm } from "vee-validate";
import { toTypedSchema } from "@vee-validate/zod";
import { z } from "zod";

const userSchema = z.object({
  email: z.string().email("Invalid email address"),
  full_name: z.string().min(1, "Name is required").max(100),
  role: z.enum(["user", "admin", "moderator"]),
  password: z
    .string()
    .min(8, "At least 8 characters")
    .regex(/[A-Z]/, "Must contain uppercase")
    .regex(/[0-9]/, "Must contain a number")
    .optional()
    .or(z.literal("")),
});

type UserFormValues = z.infer<typeof userSchema>;

interface Props {
  defaultValues?: Partial<UserFormValues>;
  isEdit?: boolean;
  isLoading?: boolean;
}

const props = withDefaults(defineProps<Props>(), { isEdit: false });
const emit = defineEmits<{ submit: [values: UserFormValues] }>();

const { handleSubmit, resetForm } = useForm<UserFormValues>({
  validationSchema: toTypedSchema(userSchema),
  initialValues: {
    email: props.defaultValues?.email ?? "",
    full_name: props.defaultValues?.full_name ?? "",
    role: props.defaultValues?.role ?? "user",
    password: "",
  },
});

const onSubmit = handleSubmit((values) => emit("submit", values));
</script>

<template>
  <form class="space-y-4" @submit="onSubmit">
    <FormField
      name="email"
      label="Email"
      type="email"
      placeholder="user@example.com"
      :disabled="isEdit"
    />

    <FormField
      name="full_name"
      label="Full Name"
      placeholder="John Doe"
    />

    <!-- Role Select -->
    <div class="space-y-2">
      <Label for="role">Role</Label>
      <VeeField name="role" v-slot="{ field }">
        <Select v-bind="field">
          <SelectTrigger>
            <SelectValue placeholder="Select role" />
          </SelectTrigger>
          <SelectContent>
            <SelectItem value="user">User</SelectItem>
            <SelectItem value="moderator">Moderator</SelectItem>
            <SelectItem value="admin">Admin</SelectItem>
          </SelectContent>
        </Select>
      </VeeField>
      <VeeErrorMessage name="role" class="text-xs text-destructive" />
    </div>

    <FormField
      v-if="!isEdit"
      name="password"
      label="Password"
      type="password"
      placeholder="Min 8 chars, uppercase, number"
    />

    <Button type="submit" :disabled="isLoading" class="w-full">
      {{ isLoading ? (isEdit ? "Saving..." : "Creating...") : (isEdit ? "Save Changes" : "Create User") }}
    </Button>
  </form>
</template>
```

---

### 4. Multi-Step Form

**File:** `components/shared/MultiStepForm.vue`

```vue
<script setup lang="ts">
interface Step {
  title: string;
}

interface Props {
  steps: Step[];
}

defineProps<Props>();
const emit = defineEmits<{ complete: [] }>();

const currentStep = ref(0);
const progress = computed(
  () => ((currentStep.value + 1) / props.steps.length) * 100
);
</script>

<template>
  <div class="space-y-6">
    <div class="space-y-2">
      <div class="flex justify-between text-sm text-muted-foreground">
        <span>{{ steps[currentStep]?.title }}</span>
        <span>Step {{ currentStep + 1 }} of {{ steps.length }}</span>
      </div>
      <Progress :value="progress" />
    </div>

    <slot :step="currentStep" />

    <div class="flex gap-2">
      <Button
        v-if="currentStep > 0"
        variant="outline"
        @click="currentStep--"
      >
        Back
      </Button>
      <Button
        class="flex-1"
        @click="currentStep < steps.length - 1 ? currentStep++ : emit('complete')"
      >
        {{ currentStep === steps.length - 1 ? "Complete" : "Next" }}
      </Button>
    </div>
  </div>
</template>
```

---

### 5. Common Zod Schemas

**File:** `utils/validations.ts`

```typescript
import { z } from "zod";

export const schemas = {
  email: z.string().email("Invalid email address"),

  password: z
    .string()
    .min(8, "At least 8 characters")
    .regex(/[A-Z]/, "Must contain uppercase")
    .regex(/[a-z]/, "Must contain lowercase")
    .regex(/[0-9]/, "Must contain a number"),

  phone: z
    .string()
    .regex(/^(\+62|62|0)8[1-9][0-9]{6,10}$/, "Invalid Indonesian phone"),

  positiveNumber: z.number().positive("Must be positive"),

  nonEmptyString: z.string().min(1, "This field is required"),

  url: z.string().url("Invalid URL").optional().or(z.literal("")),
};
```

---

## Success Criteria
- VeeValidate + Zod validation berfungsi
- Error messages tampil di bawah field
- `FormField` component reusable dan type-safe
- Multi-step form navigasi berfungsi
- Zod schemas konsisten dengan backend Pydantic/Go structs

## Next Steps
- `08_state_management.md` - State management

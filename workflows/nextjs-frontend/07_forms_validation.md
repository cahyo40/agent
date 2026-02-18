# 07 - Forms & Validation (React Hook Form + Zod)

**Goal:** Setup form handling dengan React Hook Form v7 dan Zod schema validation yang konsisten dengan backend.

**Output:** `sdlc/nextjs-frontend/07-forms-validation/`

**Time Estimate:** 2-3 jam

---

## Install

```bash
pnpm add react-hook-form zod @hookform/resolvers
```

---

## Deliverables

### 1. Reusable FormField Wrapper

**File:** `src/components/shared/form-field-wrapper.tsx`

```tsx
import {
  FormControl,
  FormDescription,
  FormField,
  FormItem,
  FormLabel,
  FormMessage,
} from "@/components/ui/form";
import { Input } from "@/components/ui/input";
import type { Control, FieldPath, FieldValues } from "react-hook-form";

interface FormFieldWrapperProps<T extends FieldValues> {
  control: Control<T>;
  name: FieldPath<T>;
  label: string;
  placeholder?: string;
  description?: string;
  type?: string;
  disabled?: boolean;
}

/** Reusable form field with label, input, and error message. */
export function FormFieldWrapper<T extends FieldValues>({
  control,
  name,
  label,
  placeholder,
  description,
  type = "text",
  disabled,
}: FormFieldWrapperProps<T>) {
  return (
    <FormField
      control={control}
      name={name}
      render={({ field }) => (
        <FormItem>
          <FormLabel>{label}</FormLabel>
          <FormControl>
            <Input
              type={type}
              placeholder={placeholder}
              disabled={disabled}
              {...field}
            />
          </FormControl>
          {description && (
            <FormDescription>{description}</FormDescription>
          )}
          <FormMessage />
        </FormItem>
      )}
    />
  );
}
```

---

### 2. Create/Edit User Form

**File:** `src/features/users/components/user-form.tsx`

```tsx
"use client";

import { zodResolver } from "@hookform/resolvers/zod";
import { useForm } from "react-hook-form";
import { z } from "zod";
import { Button } from "@/components/ui/button";
import { Form } from "@/components/ui/form";
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select";
import {
  FormControl,
  FormField,
  FormItem,
  FormLabel,
  FormMessage,
} from "@/components/ui/form";
import { FormFieldWrapper } from "@/components/shared/form-field-wrapper";
import type { User } from "../api/users-api";

// Zod schema (mirrors backend Pydantic schema)
const userSchema = z.object({
  email: z.string().email("Invalid email address"),
  full_name: z
    .string()
    .min(1, "Name is required")
    .max(100, "Name too long"),
  role: z.enum(["user", "admin", "moderator"]),
  password: z
    .string()
    .min(8, "Password must be at least 8 characters")
    .regex(/[A-Z]/, "Must contain uppercase")
    .regex(/[0-9]/, "Must contain a number")
    .optional()
    .or(z.literal("")),
});

type UserFormValues = z.infer<typeof userSchema>;

interface UserFormProps {
  defaultValues?: Partial<User>;
  onSubmit: (values: UserFormValues) => Promise<void>;
  isLoading?: boolean;
  isEdit?: boolean;
}

export function UserForm({
  defaultValues,
  onSubmit,
  isLoading,
  isEdit = false,
}: UserFormProps) {
  const form = useForm<UserFormValues>({
    resolver: zodResolver(userSchema),
    defaultValues: {
      email: defaultValues?.email ?? "",
      full_name: defaultValues?.full_name ?? "",
      role: (defaultValues?.role as any) ?? "user",
      password: "",
    },
  });

  return (
    <Form {...form}>
      <form
        onSubmit={form.handleSubmit(onSubmit)}
        className="space-y-4"
      >
        <FormFieldWrapper
          control={form.control}
          name="email"
          label="Email"
          type="email"
          placeholder="user@example.com"
          disabled={isEdit}
        />

        <FormFieldWrapper
          control={form.control}
          name="full_name"
          label="Full Name"
          placeholder="John Doe"
        />

        <FormField
          control={form.control}
          name="role"
          render={({ field }) => (
            <FormItem>
              <FormLabel>Role</FormLabel>
              <Select
                onValueChange={field.onChange}
                defaultValue={field.value}
              >
                <FormControl>
                  <SelectTrigger>
                    <SelectValue placeholder="Select role" />
                  </SelectTrigger>
                </FormControl>
                <SelectContent>
                  <SelectItem value="user">User</SelectItem>
                  <SelectItem value="moderator">Moderator</SelectItem>
                  <SelectItem value="admin">Admin</SelectItem>
                </SelectContent>
              </Select>
              <FormMessage />
            </FormItem>
          )}
        />

        {!isEdit && (
          <FormFieldWrapper
            control={form.control}
            name="password"
            label="Password"
            type="password"
            placeholder="Min 8 chars, uppercase, number"
          />
        )}

        <Button type="submit" disabled={isLoading} className="w-full">
          {isLoading
            ? isEdit
              ? "Saving..."
              : "Creating..."
            : isEdit
            ? "Save Changes"
            : "Create User"}
        </Button>
      </form>
    </Form>
  );
}
```

---

### 3. Multi-Step Form

**File:** `src/components/shared/multi-step-form.tsx`

```tsx
"use client";

import { useState } from "react";
import { Button } from "@/components/ui/button";
import { Progress } from "@/components/ui/progress";

interface Step {
  title: string;
  component: React.ReactNode;
}

interface MultiStepFormProps {
  steps: Step[];
  onComplete: () => void;
}

/** Multi-step form with progress indicator. */
export function MultiStepForm({ steps, onComplete }: MultiStepFormProps) {
  const [currentStep, setCurrentStep] = useState(0);
  const progress = ((currentStep + 1) / steps.length) * 100;

  const isFirst = currentStep === 0;
  const isLast = currentStep === steps.length - 1;

  return (
    <div className="space-y-6">
      {/* Progress */}
      <div className="space-y-2">
        <div className="flex justify-between text-sm text-muted-foreground">
          <span>{steps[currentStep]?.title}</span>
          <span>
            Step {currentStep + 1} of {steps.length}
          </span>
        </div>
        <Progress value={progress} />
      </div>

      {/* Step Content */}
      <div>{steps[currentStep]?.component}</div>

      {/* Navigation */}
      <div className="flex gap-2">
        {!isFirst && (
          <Button
            variant="outline"
            onClick={() => setCurrentStep((s) => s - 1)}
          >
            Back
          </Button>
        )}
        <Button
          className="flex-1"
          onClick={() =>
            isLast ? onComplete() : setCurrentStep((s) => s + 1)
          }
        >
          {isLast ? "Complete" : "Next"}
        </Button>
      </div>
    </div>
  );
}
```

---

### 4. File Upload Form Field

**File:** `src/components/shared/file-upload-field.tsx`

```tsx
"use client";

import { useCallback } from "react";
import { useDropzone } from "react-dropzone";
import { Upload, X } from "lucide-react";
import { cn } from "@/lib/utils";

interface FileUploadFieldProps {
  value?: File | null;
  onChange: (file: File | null) => void;
  accept?: Record<string, string[]>;
  maxSize?: number;
  label?: string;
}

/** Drag-and-drop file upload field. */
export function FileUploadField({
  value,
  onChange,
  accept = { "image/*": [".jpg", ".jpeg", ".png", ".webp"] },
  maxSize = 5 * 1024 * 1024,
  label = "Upload file",
}: FileUploadFieldProps) {
  const onDrop = useCallback(
    (acceptedFiles: File[]) => {
      onChange(acceptedFiles[0] ?? null);
    },
    [onChange]
  );

  const { getRootProps, getInputProps, isDragActive } = useDropzone({
    onDrop,
    accept,
    maxSize,
    multiple: false,
  });

  return (
    <div>
      {value ? (
        <div className="flex items-center gap-2 p-3 border rounded-md">
          <span className="text-sm flex-1 truncate">{value.name}</span>
          <button
            type="button"
            onClick={() => onChange(null)}
            className="text-muted-foreground hover:text-destructive"
          >
            <X className="h-4 w-4" />
          </button>
        </div>
      ) : (
        <div
          {...getRootProps()}
          className={cn(
            "border-2 border-dashed rounded-md p-8 text-center cursor-pointer transition-colors",
            isDragActive
              ? "border-primary bg-primary/5"
              : "border-muted-foreground/25 hover:border-primary/50"
          )}
        >
          <input {...getInputProps()} />
          <Upload className="h-8 w-8 mx-auto mb-2 text-muted-foreground" />
          <p className="text-sm text-muted-foreground">
            {isDragActive ? "Drop file here" : label}
          </p>
          <p className="text-xs text-muted-foreground mt-1">
            Max {Math.round(maxSize / (1024 * 1024))}MB
          </p>
        </div>
      )}
    </div>
  );
}
```

```bash
pnpm add react-dropzone
```

---

### 5. Common Zod Schemas

**File:** `src/lib/validations/common.ts`

```typescript
import { z } from "zod";

/** Reusable Zod schemas for common fields. */
export const schemas = {
  email: z.string().email("Invalid email address"),

  password: z
    .string()
    .min(8, "At least 8 characters")
    .regex(/[A-Z]/, "Must contain uppercase")
    .regex(/[a-z]/, "Must contain lowercase")
    .regex(/[0-9]/, "Must contain a number")
    .regex(/[^A-Za-z0-9]/, "Must contain special character"),

  phone: z
    .string()
    .regex(/^(\+62|62|0)8[1-9][0-9]{6,10}$/, "Invalid Indonesian phone"),

  uuid: z.string().uuid("Invalid ID"),

  positiveNumber: z.number().positive("Must be positive"),

  nonEmptyString: z.string().min(1, "This field is required"),

  url: z.string().url("Invalid URL").optional().or(z.literal("")),

  pagination: z.object({
    page: z.number().int().positive().default(1),
    limit: z.number().int().min(1).max(100).default(20),
  }),
};
```

---

## Success Criteria
- Form validation dengan Zod berfungsi
- Error messages tampil di bawah field
- Multi-step form navigasi berfungsi
- File upload drag-and-drop berfungsi
- Reusable FormFieldWrapper mengurangi boilerplate

## Next Steps
- `08_state_management.md` - State management
- `09_layout_dashboard.md` - Dashboard layout

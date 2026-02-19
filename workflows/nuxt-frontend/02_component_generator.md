---
description: Template untuk membuat UI components menggunakan Shadcn-vue dengan pola Atomic Design.
---
# 02 - Component Generator (Atomic Design + Shadcn-vue)

**Goal:** Template untuk membuat UI components menggunakan Shadcn-vue dengan pola Atomic Design.

**Output:** `sdlc/nuxt-frontend/02-component-generator/`

**Time Estimate:** 2-3 jam

---

## Install Shadcn-vue Components

```bash
# Install komponen yang sering dipakai
pnpm dlx shadcn-vue@latest add button
pnpm dlx shadcn-vue@latest add input
pnpm dlx shadcn-vue@latest add card
pnpm dlx shadcn-vue@latest add dialog
pnpm dlx shadcn-vue@latest add form
pnpm dlx shadcn-vue@latest add table
pnpm dlx shadcn-vue@latest add badge
pnpm dlx shadcn-vue@latest add avatar
pnpm dlx shadcn-vue@latest add dropdown-menu
pnpm dlx shadcn-vue@latest add toast
pnpm dlx shadcn-vue@latest add skeleton
pnpm dlx shadcn-vue@latest add alert
pnpm dlx shadcn-vue@latest add separator
pnpm dlx shadcn-vue@latest add sheet
pnpm dlx shadcn-vue@latest add select
pnpm dlx shadcn-vue@latest add checkbox
```

---

## Deliverables

### 1. Page Header Component

**File:** `components/shared/PageHeader.vue`

```vue
<script setup lang="ts">
interface Props {
  title: string;
  description?: string;
}

defineProps<Props>();
</script>

<template>
  <div class="flex items-center justify-between">
    <div>
      <h1 class="text-2xl font-bold tracking-tight">{{ title }}</h1>
      <p v-if="description" class="text-muted-foreground mt-1 text-sm">
        {{ description }}
      </p>
    </div>
    <div v-if="$slots.default" class="flex items-center gap-2">
      <slot />
    </div>
  </div>
</template>
```

---

### 2. Data Table Component

**File:** `components/shared/DataTable.vue`

```vue
<script setup lang="ts" generic="T extends Record<string, any>">
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from "@/components/ui/table";
import { Button } from "@/components/ui/button";
import { ChevronLeft, ChevronRight } from "lucide-vue-next";

interface Column<T> {
  key: keyof T | string;
  label: string;
  render?: (row: T) => string;
}

interface Props {
  columns: Column<T>[];
  data: T[];
  total?: number;
  page?: number;
  pageSize?: number;
}

const props = withDefaults(defineProps<Props>(), {
  total: 0,
  page: 1,
  pageSize: 10,
});

const emit = defineEmits<{
  "update:page": [page: number];
}>();

const totalPages = computed(() =>
  Math.ceil(props.total / props.pageSize)
);

function getCellValue(row: T, column: Column<T>): string {
  if (column.render) return column.render(row);
  return String(row[column.key as keyof T] ?? "");
}
</script>

<template>
  <div class="space-y-4">
    <div class="rounded-md border">
      <Table>
        <TableHeader>
          <TableRow>
            <TableHead v-for="col in columns" :key="String(col.key)">
              {{ col.label }}
            </TableHead>
            <TableHead v-if="$slots.actions">Actions</TableHead>
          </TableRow>
        </TableHeader>
        <TableBody>
          <template v-if="data.length">
            <TableRow v-for="(row, i) in data" :key="i">
              <TableCell v-for="col in columns" :key="String(col.key)">
                <slot :name="`cell-${String(col.key)}`" :row="row">
                  {{ getCellValue(row, col) }}
                </slot>
              </TableCell>
              <TableCell v-if="$slots.actions">
                <slot name="actions" :row="row" />
              </TableCell>
            </TableRow>
          </template>
          <TableRow v-else>
            <TableCell
              :colspan="columns.length + ($slots.actions ? 1 : 0)"
              class="h-24 text-center text-muted-foreground"
            >
              No results.
            </TableCell>
          </TableRow>
        </TableBody>
      </Table>
    </div>

    <!-- Pagination -->
    <div v-if="totalPages > 1" class="flex items-center justify-between">
      <p class="text-sm text-muted-foreground">
        Page {{ page }} of {{ totalPages }}
      </p>
      <div class="flex gap-2">
        <Button
          variant="outline"
          size="sm"
          :disabled="page <= 1"
          @click="emit('update:page', page - 1)"
        >
          <ChevronLeft class="h-4 w-4" />
        </Button>
        <Button
          variant="outline"
          size="sm"
          :disabled="page >= totalPages"
          @click="emit('update:page', page + 1)"
        >
          <ChevronRight class="h-4 w-4" />
        </Button>
      </div>
    </div>
  </div>
</template>
```

---

### 3. Table Skeleton

**File:** `components/shared/TableSkeleton.vue`

```vue
<script setup lang="ts">
interface Props {
  rows?: number;
  columns?: number;
}

withDefaults(defineProps<Props>(), { rows: 5, columns: 4 });
</script>

<template>
  <div class="rounded-md border">
    <div class="p-4 space-y-3">
      <div class="flex gap-4">
        <Skeleton v-for="i in columns" :key="i" class="h-4 w-full" />
      </div>
      <div v-for="i in rows" :key="i" class="flex gap-4">
        <Skeleton v-for="j in columns" :key="j" class="h-8 w-full" />
      </div>
    </div>
  </div>
</template>
```

---

### 4. Empty State

**File:** `components/shared/EmptyState.vue`

```vue
<script setup lang="ts">
import type { LucideIcon } from "lucide-vue-next";

interface Props {
  icon: LucideIcon;
  title: string;
  description: string;
  actionLabel?: string;
}

const props = defineProps<Props>();
const emit = defineEmits<{ action: [] }>();
</script>

<template>
  <div class="flex flex-col items-center justify-center py-16 text-center">
    <div class="rounded-full bg-muted p-4 mb-4">
      <component :is="icon" class="h-8 w-8 text-muted-foreground" />
    </div>
    <h3 class="text-lg font-semibold">{{ title }}</h3>
    <p class="text-muted-foreground mt-1 text-sm max-w-sm">{{ description }}</p>
    <Button v-if="actionLabel" class="mt-4" @click="emit('action')">
      {{ actionLabel }}
    </Button>
  </div>
</template>
```

---

### 5. Confirm Dialog

**File:** `components/shared/ConfirmDialog.vue`

```vue
<script setup lang="ts">
interface Props {
  open: boolean;
  title?: string;
  description?: string;
  isLoading?: boolean;
}

withDefaults(defineProps<Props>(), {
  title: "Are you sure?",
  description: "This action cannot be undone.",
});

const emit = defineEmits<{
  "update:open": [value: boolean];
  confirm: [];
}>();
</script>

<template>
  <AlertDialog :open="open" @update:open="emit('update:open', $event)">
    <AlertDialogContent>
      <AlertDialogHeader>
        <AlertDialogTitle>{{ title }}</AlertDialogTitle>
        <AlertDialogDescription>{{ description }}</AlertDialogDescription>
      </AlertDialogHeader>
      <AlertDialogFooter>
        <AlertDialogCancel :disabled="isLoading">Cancel</AlertDialogCancel>
        <AlertDialogAction
          :disabled="isLoading"
          class="bg-destructive text-destructive-foreground hover:bg-destructive/90"
          @click="emit('confirm')"
        >
          {{ isLoading ? "Deleting..." : "Delete" }}
        </AlertDialogAction>
      </AlertDialogFooter>
    </AlertDialogContent>
  </AlertDialog>
</template>
```

---

### 6. User Avatar

**File:** `components/shared/UserAvatar.vue`

```vue
<script setup lang="ts">
interface Props {
  name: string;
  imageUrl?: string | null;
  size?: "sm" | "md" | "lg";
}

const props = withDefaults(defineProps<Props>(), { size: "md" });

const sizeClasses = {
  sm: "h-7 w-7 text-xs",
  md: "h-9 w-9 text-sm",
  lg: "h-12 w-12 text-base",
};
</script>

<template>
  <Avatar :class="sizeClasses[size]">
    <AvatarImage v-if="imageUrl" :src="imageUrl" :alt="name" />
    <AvatarFallback>{{ getInitials(name) }}</AvatarFallback>
  </Avatar>
</template>
```

---

### 7. Status Badge

**File:** `components/shared/StatusBadge.vue`

```vue
<script setup lang="ts">
type Status = "active" | "inactive" | "pending" | "error";

const statusConfig: Record<Status, { label: string; class: string }> = {
  active: { label: "Active", class: "bg-green-100 text-green-700 hover:bg-green-100" },
  inactive: { label: "Inactive", class: "bg-gray-100 text-gray-700 hover:bg-gray-100" },
  pending: { label: "Pending", class: "bg-yellow-100 text-yellow-700 hover:bg-yellow-100" },
  error: { label: "Error", class: "bg-red-100 text-red-700 hover:bg-red-100" },
};

const props = defineProps<{ status: Status }>();
const config = computed(() => statusConfig[props.status]);
</script>

<template>
  <Badge variant="secondary" :class="cn(config.class)">
    {{ config.label }}
  </Badge>
</template>
```

---

## Success Criteria
- Semua Shadcn-vue base components terinstall
- DataTable render data dengan slot untuk custom cells
- Skeleton loader tampil saat loading
- Empty state tampil saat data kosong
- Confirm dialog berfungsi untuk delete
- Komponen auto-imported oleh Nuxt (tidak perlu import manual)

## Next Steps
- `03_api_client_integration.md` - Setup API client

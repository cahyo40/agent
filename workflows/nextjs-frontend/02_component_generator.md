---
description: Template untuk membuat UI components menggunakan Shadcn/UI primitives dengan pola Atomic Design.
---
# 02 - Component Generator (Atomic Design + Shadcn/UI)

**Goal:** Template untuk membuat UI components menggunakan Shadcn/UI primitives dengan pola Atomic Design.

**Output:** `sdlc/nextjs-frontend/02-component-generator/`

**Time Estimate:** 2-3 jam

---

## Install Shadcn Components

```bash
# Install komponen yang sering dipakai
pnpm dlx shadcn-ui@latest add button
pnpm dlx shadcn-ui@latest add input
pnpm dlx shadcn-ui@latest add card
pnpm dlx shadcn-ui@latest add dialog
pnpm dlx shadcn-ui@latest add form
pnpm dlx shadcn-ui@latest add table
pnpm dlx shadcn-ui@latest add badge
pnpm dlx shadcn-ui@latest add avatar
pnpm dlx shadcn-ui@latest add dropdown-menu
pnpm dlx shadcn-ui@latest add toast
pnpm dlx shadcn-ui@latest add skeleton
pnpm dlx shadcn-ui@latest add alert
pnpm dlx shadcn-ui@latest add separator
pnpm dlx shadcn-ui@latest add sheet
pnpm dlx shadcn-ui@latest add select
pnpm dlx shadcn-ui@latest add checkbox
```

---

## Deliverables

### 1. Page Header Component

**File:** `src/components/shared/page-header.tsx`

```tsx
interface PageHeaderProps {
  title: string;
  description?: string;
  children?: React.ReactNode;
}

/** Page header with title, description, and action slot. */
export function PageHeader({
  title,
  description,
  children,
}: PageHeaderProps) {
  return (
    <div className="flex items-center justify-between">
      <div>
        <h1 className="text-2xl font-bold tracking-tight">{title}</h1>
        {description && (
          <p className="text-muted-foreground mt-1 text-sm">{description}</p>
        )}
      </div>
      {children && <div className="flex items-center gap-2">{children}</div>}
    </div>
  );
}
```

---

### 2. Data Table Component

**File:** `src/components/shared/data-table.tsx`

```tsx
"use client";

import {
  ColumnDef,
  flexRender,
  getCoreRowModel,
  getPaginationRowModel,
  getSortedRowModel,
  SortingState,
  useReactTable,
} from "@tanstack/react-table";
import { useState } from "react";
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from "@/components/ui/table";
import { Button } from "@/components/ui/button";
import { ChevronLeft, ChevronRight } from "lucide-react";

interface DataTableProps<TData, TValue> {
  columns: ColumnDef<TData, TValue>[];
  data: TData[];
  pageSize?: number;
}

/** Reusable data table with sorting and pagination. */
export function DataTable<TData, TValue>({
  columns,
  data,
  pageSize = 10,
}: DataTableProps<TData, TValue>) {
  const [sorting, setSorting] = useState<SortingState>([]);

  const table = useReactTable({
    data,
    columns,
    getCoreRowModel: getCoreRowModel(),
    getPaginationRowModel: getPaginationRowModel(),
    getSortedRowModel: getSortedRowModel(),
    onSortingChange: setSorting,
    state: { sorting },
    initialState: { pagination: { pageSize } },
  });

  return (
    <div className="space-y-4">
      <div className="rounded-md border">
        <Table>
          <TableHeader>
            {table.getHeaderGroups().map((headerGroup) => (
              <TableRow key={headerGroup.id}>
                {headerGroup.headers.map((header) => (
                  <TableHead key={header.id}>
                    {header.isPlaceholder
                      ? null
                      : flexRender(
                          header.column.columnDef.header,
                          header.getContext()
                        )}
                  </TableHead>
                ))}
              </TableRow>
            ))}
          </TableHeader>
          <TableBody>
            {table.getRowModel().rows?.length ? (
              table.getRowModel().rows.map((row) => (
                <TableRow key={row.id}>
                  {row.getVisibleCells().map((cell) => (
                    <TableCell key={cell.id}>
                      {flexRender(
                        cell.column.columnDef.cell,
                        cell.getContext()
                      )}
                    </TableCell>
                  ))}
                </TableRow>
              ))
            ) : (
              <TableRow>
                <TableCell
                  colSpan={columns.length}
                  className="h-24 text-center text-muted-foreground"
                >
                  No results.
                </TableCell>
              </TableRow>
            )}
          </TableBody>
        </Table>
      </div>

      {/* Pagination */}
      <div className="flex items-center justify-between">
        <p className="text-sm text-muted-foreground">
          Page {table.getState().pagination.pageIndex + 1} of{" "}
          {table.getPageCount()}
        </p>
        <div className="flex gap-2">
          <Button
            variant="outline"
            size="sm"
            onClick={() => table.previousPage()}
            disabled={!table.getCanPreviousPage()}
          >
            <ChevronLeft className="h-4 w-4" />
          </Button>
          <Button
            variant="outline"
            size="sm"
            onClick={() => table.nextPage()}
            disabled={!table.getCanNextPage()}
          >
            <ChevronRight className="h-4 w-4" />
          </Button>
        </div>
      </div>
    </div>
  );
}
```

**Install TanStack Table:**
```bash
pnpm add @tanstack/react-table
```

---

### 3. Loading Skeleton

**File:** `src/components/shared/table-skeleton.tsx`

```tsx
import { Skeleton } from "@/components/ui/skeleton";

interface TableSkeletonProps {
  rows?: number;
  columns?: number;
}

/** Skeleton loader for table content. */
export function TableSkeleton({ rows = 5, columns = 4 }: TableSkeletonProps) {
  return (
    <div className="rounded-md border">
      <div className="p-4 space-y-3">
        {/* Header */}
        <div className="flex gap-4">
          {Array.from({ length: columns }).map((_, i) => (
            <Skeleton key={i} className="h-4 w-full" />
          ))}
        </div>
        {/* Rows */}
        {Array.from({ length: rows }).map((_, i) => (
          <div key={i} className="flex gap-4">
            {Array.from({ length: columns }).map((_, j) => (
              <Skeleton key={j} className="h-8 w-full" />
            ))}
          </div>
        ))}
      </div>
    </div>
  );
}
```

---

### 4. Empty State

**File:** `src/components/shared/empty-state.tsx`

```tsx
import { LucideIcon } from "lucide-react";
import { Button } from "@/components/ui/button";

interface EmptyStateProps {
  icon: LucideIcon;
  title: string;
  description: string;
  action?: {
    label: string;
    onClick: () => void;
  };
}

/** Empty state with icon, title, description, and optional action. */
export function EmptyState({
  icon: Icon,
  title,
  description,
  action,
}: EmptyStateProps) {
  return (
    <div className="flex flex-col items-center justify-center py-16 text-center">
      <div className="rounded-full bg-muted p-4 mb-4">
        <Icon className="h-8 w-8 text-muted-foreground" />
      </div>
      <h3 className="text-lg font-semibold">{title}</h3>
      <p className="text-muted-foreground mt-1 text-sm max-w-sm">
        {description}
      </p>
      {action && (
        <Button onClick={action.onClick} className="mt-4">
          {action.label}
        </Button>
      )}
    </div>
  );
}
```

---

### 5. Confirm Delete Dialog

**File:** `src/components/shared/confirm-dialog.tsx`

```tsx
"use client";

import {
  AlertDialog,
  AlertDialogAction,
  AlertDialogCancel,
  AlertDialogContent,
  AlertDialogDescription,
  AlertDialogFooter,
  AlertDialogHeader,
  AlertDialogTitle,
} from "@/components/ui/alert-dialog";

interface ConfirmDialogProps {
  open: boolean;
  onOpenChange: (open: boolean) => void;
  title?: string;
  description?: string;
  onConfirm: () => void;
  isLoading?: boolean;
}

/** Confirmation dialog for destructive actions. */
export function ConfirmDialog({
  open,
  onOpenChange,
  title = "Are you sure?",
  description = "This action cannot be undone.",
  onConfirm,
  isLoading,
}: ConfirmDialogProps) {
  return (
    <AlertDialog open={open} onOpenChange={onOpenChange}>
      <AlertDialogContent>
        <AlertDialogHeader>
          <AlertDialogTitle>{title}</AlertDialogTitle>
          <AlertDialogDescription>{description}</AlertDialogDescription>
        </AlertDialogHeader>
        <AlertDialogFooter>
          <AlertDialogCancel disabled={isLoading}>Cancel</AlertDialogCancel>
          <AlertDialogAction
            onClick={onConfirm}
            disabled={isLoading}
            className="bg-destructive text-destructive-foreground hover:bg-destructive/90"
          >
            {isLoading ? "Deleting..." : "Delete"}
          </AlertDialogAction>
        </AlertDialogFooter>
      </AlertDialogContent>
    </AlertDialog>
  );
}
```

---

### 6. User Avatar

**File:** `src/components/shared/user-avatar.tsx`

```tsx
import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar";
import { getInitials } from "@/lib/utils";

interface UserAvatarProps {
  name: string;
  imageUrl?: string | null;
  size?: "sm" | "md" | "lg";
}

const sizeClasses = {
  sm: "h-7 w-7 text-xs",
  md: "h-9 w-9 text-sm",
  lg: "h-12 w-12 text-base",
};

/** User avatar with fallback initials. */
export function UserAvatar({ name, imageUrl, size = "md" }: UserAvatarProps) {
  return (
    <Avatar className={sizeClasses[size]}>
      <AvatarImage src={imageUrl ?? undefined} alt={name} />
      <AvatarFallback>{getInitials(name)}</AvatarFallback>
    </Avatar>
  );
}
```

---

### 7. Status Badge

**File:** `src/components/shared/status-badge.tsx`

```tsx
import { Badge } from "@/components/ui/badge";
import { cn } from "@/lib/utils";

type Status = "active" | "inactive" | "pending" | "error";

const statusConfig: Record<
  Status,
  { label: string; className: string }
> = {
  active: {
    label: "Active",
    className: "bg-green-100 text-green-700 hover:bg-green-100",
  },
  inactive: {
    label: "Inactive",
    className: "bg-gray-100 text-gray-700 hover:bg-gray-100",
  },
  pending: {
    label: "Pending",
    className: "bg-yellow-100 text-yellow-700 hover:bg-yellow-100",
  },
  error: {
    label: "Error",
    className: "bg-red-100 text-red-700 hover:bg-red-100",
  },
};

interface StatusBadgeProps {
  status: Status;
}

/** Colored badge for entity status. */
export function StatusBadge({ status }: StatusBadgeProps) {
  const config = statusConfig[status];
  return (
    <Badge variant="secondary" className={cn(config.className)}>
      {config.label}
    </Badge>
  );
}
```

---

## Success Criteria
- Semua Shadcn/UI base components terinstall
- DataTable render data dengan sorting dan pagination
- Skeleton loader tampil saat loading
- Empty state tampil saat data kosong
- Confirm dialog berfungsi untuk delete
- Komponen reusable dan type-safe

## Next Steps
- `03_api_client_integration.md` - Setup API client

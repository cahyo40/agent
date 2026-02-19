---
description: Template layout untuk dashboard admin dengan sidebar collapsible, header, dark mode toggle, dan integrasi chart.
---
# 09 - Layout & Dashboard (Sidebar + Dark Mode + Charts)

**Goal:** Template layout untuk dashboard admin dengan sidebar collapsible, header, dark mode toggle, dan integrasi chart.

**Output:** `sdlc/nextjs-frontend/09-layout-dashboard/`

**Time Estimate:** 3-4 jam

---

## Install

```bash
pnpm add recharts next-themes
pnpm dlx shadcn-ui@latest add sheet separator
```

---

## Deliverables

### 1. Dashboard Layout

**File:** `src/app/(dashboard)/layout.tsx`

```tsx
import { Sidebar } from "@/components/shared/sidebar";
import { Header } from "@/components/shared/header";

export default function DashboardLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <div className="flex h-screen overflow-hidden bg-background">
      <Sidebar />
      <div className="flex flex-1 flex-col overflow-hidden">
        <Header />
        <main className="flex-1 overflow-y-auto p-6">{children}</main>
      </div>
    </div>
  );
}
```

---

### 2. Sidebar

**File:** `src/components/shared/sidebar.tsx`

```tsx
"use client";

import Link from "next/link";
import { usePathname } from "next/navigation";
import {
  LayoutDashboard,
  Users,
  Package,
  Settings,
  ChevronLeft,
} from "lucide-react";
import { cn } from "@/lib/utils";
import { Button } from "@/components/ui/button";
import { useUIStore } from "@/stores/ui-store";

const navItems = [
  { href: "/dashboard", label: "Dashboard", icon: LayoutDashboard },
  { href: "/dashboard/users", label: "Users", icon: Users },
  { href: "/dashboard/products", label: "Products", icon: Package },
  { href: "/dashboard/settings", label: "Settings", icon: Settings },
];

export function Sidebar() {
  const pathname = usePathname();
  const { sidebarOpen, toggleSidebar } = useUIStore();

  return (
    <aside
      className={cn(
        "relative flex flex-col border-r bg-card transition-all duration-300",
        sidebarOpen ? "w-64" : "w-16"
      )}
    >
      {/* Logo */}
      <div className="flex h-16 items-center border-b px-4">
        {sidebarOpen && (
          <span className="font-bold text-lg">MyApp</span>
        )}
      </div>

      {/* Nav */}
      <nav className="flex-1 space-y-1 p-2">
        {navItems.map(({ href, label, icon: Icon }) => {
          const isActive =
            href === "/dashboard"
              ? pathname === href
              : pathname.startsWith(href);

          return (
            <Link key={href} href={href}>
              <span
                className={cn(
                  "flex items-center gap-3 rounded-md px-3 py-2 text-sm transition-colors",
                  isActive
                    ? "bg-primary text-primary-foreground"
                    : "text-muted-foreground hover:bg-accent hover:text-accent-foreground"
                )}
              >
                <Icon className="h-4 w-4 shrink-0" />
                {sidebarOpen && <span>{label}</span>}
              </span>
            </Link>
          );
        })}
      </nav>

      {/* Collapse Button */}
      <Button
        variant="ghost"
        size="icon"
        onClick={toggleSidebar}
        className="absolute -right-3 top-20 h-6 w-6 rounded-full border bg-background"
      >
        <ChevronLeft
          className={cn(
            "h-3 w-3 transition-transform",
            !sidebarOpen && "rotate-180"
          )}
        />
      </Button>
    </aside>
  );
}
```

---

### 3. Header

**File:** `src/components/shared/header.tsx`

```tsx
"use client";

import { Bell, Moon, Sun } from "lucide-react";
import { useTheme } from "next-themes";
import { Button } from "@/components/ui/button";
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuLabel,
  DropdownMenuSeparator,
  DropdownMenuTrigger,
} from "@/components/ui/dropdown-menu";
import { UserAvatar } from "./user-avatar";
import { useAuthStore } from "@/stores/auth-store";

export function Header() {
  const { setTheme } = useTheme();
  const user = useAuthStore((state) => state.user);

  return (
    <header className="flex h-16 items-center justify-end gap-2 border-b px-6">
      {/* Dark Mode Toggle */}
      <DropdownMenu>
        <DropdownMenuTrigger asChild>
          <Button variant="ghost" size="icon">
            <Sun className="h-4 w-4 rotate-0 scale-100 transition-all dark:-rotate-90 dark:scale-0" />
            <Moon className="absolute h-4 w-4 rotate-90 scale-0 transition-all dark:rotate-0 dark:scale-100" />
          </Button>
        </DropdownMenuTrigger>
        <DropdownMenuContent align="end">
          <DropdownMenuItem onClick={() => setTheme("light")}>Light</DropdownMenuItem>
          <DropdownMenuItem onClick={() => setTheme("dark")}>Dark</DropdownMenuItem>
          <DropdownMenuItem onClick={() => setTheme("system")}>System</DropdownMenuItem>
        </DropdownMenuContent>
      </DropdownMenu>

      {/* Notifications */}
      <Button variant="ghost" size="icon">
        <Bell className="h-4 w-4" />
      </Button>

      {/* User Menu */}
      {user && (
        <DropdownMenu>
          <DropdownMenuTrigger asChild>
            <Button variant="ghost" className="relative h-8 w-8 rounded-full">
              <UserAvatar name={user.name} size="sm" />
            </Button>
          </DropdownMenuTrigger>
          <DropdownMenuContent align="end">
            <DropdownMenuLabel>
              <div className="flex flex-col">
                <span className="font-medium">{user.name}</span>
                <span className="text-xs text-muted-foreground">{user.email}</span>
              </div>
            </DropdownMenuLabel>
            <DropdownMenuSeparator />
            <DropdownMenuItem>Profile</DropdownMenuItem>
            <DropdownMenuItem>Settings</DropdownMenuItem>
            <DropdownMenuSeparator />
            <DropdownMenuItem className="text-destructive">Sign out</DropdownMenuItem>
          </DropdownMenuContent>
        </DropdownMenu>
      )}
    </header>
  );
}
```

---

### 4. Stats Cards

**File:** `src/components/shared/stats-card.tsx`

```tsx
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { LucideIcon } from "lucide-react";
import { cn } from "@/lib/utils";

interface StatsCardProps {
  title: string;
  value: string | number;
  description?: string;
  icon: LucideIcon;
  trend?: { value: number; isPositive: boolean };
}

export function StatsCard({
  title,
  value,
  description,
  icon: Icon,
  trend,
}: StatsCardProps) {
  return (
    <Card>
      <CardHeader className="flex flex-row items-center justify-between pb-2">
        <CardTitle className="text-sm font-medium text-muted-foreground">
          {title}
        </CardTitle>
        <Icon className="h-4 w-4 text-muted-foreground" />
      </CardHeader>
      <CardContent>
        <div className="text-2xl font-bold">{value}</div>
        {trend && (
          <p
            className={cn(
              "text-xs mt-1",
              trend.isPositive ? "text-green-600" : "text-red-600"
            )}
          >
            {trend.isPositive ? "+" : ""}{trend.value}% from last month
          </p>
        )}
        {description && (
          <p className="text-xs text-muted-foreground mt-1">{description}</p>
        )}
      </CardContent>
    </Card>
  );
}
```

---

### 5. Chart (Recharts)

**File:** `src/components/shared/revenue-chart.tsx`

```tsx
"use client";

import {
  Area,
  AreaChart,
  CartesianGrid,
  ResponsiveContainer,
  Tooltip,
  XAxis,
  YAxis,
} from "recharts";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";

interface RevenueChartProps {
  data: { month: string; revenue: number }[];
}

export function RevenueChart({ data }: RevenueChartProps) {
  return (
    <Card>
      <CardHeader>
        <CardTitle>Revenue Overview</CardTitle>
      </CardHeader>
      <CardContent>
        <ResponsiveContainer width="100%" height={300}>
          <AreaChart data={data}>
            <defs>
              <linearGradient id="colorRevenue" x1="0" y1="0" x2="0" y2="1">
                <stop offset="5%" stopColor="#6366f1" stopOpacity={0.3} />
                <stop offset="95%" stopColor="#6366f1" stopOpacity={0} />
              </linearGradient>
            </defs>
            <CartesianGrid strokeDasharray="3 3" className="stroke-muted" />
            <XAxis
              dataKey="month"
              className="text-xs fill-muted-foreground"
            />
            <YAxis className="text-xs fill-muted-foreground" />
            <Tooltip
              contentStyle={{
                backgroundColor: "hsl(var(--card))",
                border: "1px solid hsl(var(--border))",
                borderRadius: "6px",
              }}
            />
            <Area
              type="monotone"
              dataKey="revenue"
              stroke="#6366f1"
              fill="url(#colorRevenue)"
              strokeWidth={2}
            />
          </AreaChart>
        </ResponsiveContainer>
      </CardContent>
    </Card>
  );
}
```

---

### 6. Dashboard Page

**File:** `src/app/(dashboard)/dashboard/page.tsx`

```tsx
import { Users, Package, DollarSign, TrendingUp } from "lucide-react";
import { StatsCard } from "@/components/shared/stats-card";
import { RevenueChart } from "@/components/shared/revenue-chart";

const revenueData = [
  { month: "Jan", revenue: 4000 },
  { month: "Feb", revenue: 3000 },
  { month: "Mar", revenue: 5000 },
  { month: "Apr", revenue: 4500 },
  { month: "May", revenue: 6000 },
  { month: "Jun", revenue: 5500 },
];

export default function DashboardPage() {
  return (
    <div className="space-y-6">
      <h1 className="text-2xl font-bold">Dashboard</h1>

      {/* Stats */}
      <div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-4">
        <StatsCard
          title="Total Revenue"
          value="$45,231"
          icon={DollarSign}
          trend={{ value: 20.1, isPositive: true }}
        />
        <StatsCard
          title="Active Users"
          value="2,350"
          icon={Users}
          trend={{ value: 10.5, isPositive: true }}
        />
        <StatsCard
          title="Products"
          value="573"
          icon={Package}
          trend={{ value: 2.3, isPositive: false }}
        />
        <StatsCard
          title="Growth"
          value="12.5%"
          icon={TrendingUp}
          trend={{ value: 4.1, isPositive: true }}
        />
      </div>

      {/* Chart */}
      <RevenueChart data={revenueData} />
    </div>
  );
}
```

---

## Success Criteria
- Sidebar collapsible berfungsi di desktop
- Dark mode toggle berfungsi
- Stats cards tampil dengan trend indicator
- Area chart render dengan data
- Layout responsive di mobile (sidebar sebagai Sheet)

## Next Steps
- `10_testing_quality.md` - Testing setup

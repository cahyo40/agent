# 09 - Layout & Dashboard (Sidebar + Dark Mode + Charts)

**Goal:** Template layout dashboard admin dengan sidebar collapsible, header, dark mode toggle, dan chart menggunakan Vue Chart.js.

**Output:** `sdlc/nuxt-frontend/09-layout-dashboard/`

**Time Estimate:** 3-4 jam

---

## Install

```bash
pnpm add vue-chartjs chart.js
pnpm dlx shadcn-vue@latest add sheet separator progress
```

---

## Deliverables

### 1. Dashboard Layout

**File:** `layouts/dashboard.vue`

```vue
<template>
  <div class="flex h-screen overflow-hidden bg-background">
    <AppSidebar />
    <div class="flex flex-1 flex-col overflow-hidden">
      <AppHeader />
      <main class="flex-1 overflow-y-auto p-6">
        <slot />
      </main>
    </div>
  </div>
</template>
```

---

### 2. Sidebar

**File:** `components/shared/AppSidebar.vue`

```vue
<script setup lang="ts">
import {
  LayoutDashboard,
  Users,
  Package,
  Settings,
  ChevronLeft,
} from "lucide-vue-next";

const navItems = [
  { to: "/dashboard", label: "Dashboard", icon: LayoutDashboard, exact: true },
  { to: "/dashboard/users", label: "Users", icon: Users },
  { to: "/dashboard/products", label: "Products", icon: Package },
  { to: "/dashboard/settings", label: "Settings", icon: Settings },
];

const { sidebarOpen, toggleSidebar } = storeToRefs(useUIStore());
const { toggleSidebar: toggle } = useUIStore();
const route = useRoute();

function isActive(item: (typeof navItems)[0]): boolean {
  return item.exact
    ? route.path === item.to
    : route.path.startsWith(item.to);
}
</script>

<template>
  <aside
    class="relative flex flex-col border-r bg-card transition-all duration-300"
    :class="sidebarOpen ? 'w-64' : 'w-16'"
  >
    <!-- Logo -->
    <div class="flex h-16 items-center border-b px-4">
      <span v-if="sidebarOpen" class="font-bold text-lg">MyApp</span>
    </div>

    <!-- Nav -->
    <nav class="flex-1 space-y-1 p-2">
      <NuxtLink
        v-for="item in navItems"
        :key="item.to"
        :to="item.to"
        class="flex items-center gap-3 rounded-md px-3 py-2 text-sm transition-colors"
        :class="
          isActive(item)
            ? 'bg-primary text-primary-foreground'
            : 'text-muted-foreground hover:bg-accent hover:text-accent-foreground'
        "
      >
        <component :is="item.icon" class="h-4 w-4 shrink-0" />
        <span v-if="sidebarOpen">{{ item.label }}</span>
      </NuxtLink>
    </nav>

    <!-- Collapse Button -->
    <Button
      variant="ghost"
      size="icon"
      class="absolute -right-3 top-20 h-6 w-6 rounded-full border bg-background"
      @click="toggle"
    >
      <ChevronLeft
        class="h-3 w-3 transition-transform"
        :class="!sidebarOpen ? 'rotate-180' : ''"
      />
    </Button>
  </aside>
</template>
```

---

### 3. Header

**File:** `components/shared/AppHeader.vue`

```vue
<script setup lang="ts">
import { Bell, Moon, Sun } from "lucide-vue-next";

const colorMode = useColorMode();
const { user } = storeToRefs(useAuthStore());
const { logout } = useAuthStore();

function toggleTheme() {
  colorMode.preference = colorMode.value === "dark" ? "light" : "dark";
}
</script>

<template>
  <header class="flex h-16 items-center justify-end gap-2 border-b px-6">
    <!-- Dark Mode Toggle -->
    <Button variant="ghost" size="icon" @click="toggleTheme">
      <Sun v-if="colorMode.value === 'dark'" class="h-4 w-4" />
      <Moon v-else class="h-4 w-4" />
    </Button>

    <!-- Notifications -->
    <Button variant="ghost" size="icon">
      <Bell class="h-4 w-4" />
    </Button>

    <!-- User Menu -->
    <DropdownMenu v-if="user">
      <DropdownMenuTrigger as-child>
        <Button variant="ghost" class="relative h-8 w-8 rounded-full">
          <UserAvatar :name="user.name" size="sm" />
        </Button>
      </DropdownMenuTrigger>
      <DropdownMenuContent align="end">
        <DropdownMenuLabel>
          <div class="flex flex-col">
            <span class="font-medium">{{ user.name }}</span>
            <span class="text-xs text-muted-foreground">{{ user.email }}</span>
          </div>
        </DropdownMenuLabel>
        <DropdownMenuSeparator />
        <DropdownMenuItem as-child>
          <NuxtLink to="/dashboard/settings">Settings</NuxtLink>
        </DropdownMenuItem>
        <DropdownMenuSeparator />
        <DropdownMenuItem
          class="text-destructive"
          @click="logout"
        >
          Sign out
        </DropdownMenuItem>
      </DropdownMenuContent>
    </DropdownMenu>
  </header>
</template>
```

---

### 4. Stats Card

**File:** `components/shared/StatsCard.vue`

```vue
<script setup lang="ts">
import type { LucideIcon } from "lucide-vue-next";

interface Props {
  title: string;
  value: string | number;
  description?: string;
  icon: LucideIcon;
  trend?: { value: number; isPositive: boolean };
}

defineProps<Props>();
</script>

<template>
  <Card>
    <CardHeader class="flex flex-row items-center justify-between pb-2">
      <CardTitle class="text-sm font-medium text-muted-foreground">
        {{ title }}
      </CardTitle>
      <component :is="icon" class="h-4 w-4 text-muted-foreground" />
    </CardHeader>
    <CardContent>
      <div class="text-2xl font-bold">{{ value }}</div>
      <p
        v-if="trend"
        class="text-xs mt-1"
        :class="trend.isPositive ? 'text-green-600' : 'text-red-600'"
      >
        {{ trend.isPositive ? "+" : "" }}{{ trend.value }}% from last month
      </p>
      <p v-if="description" class="text-xs text-muted-foreground mt-1">
        {{ description }}
      </p>
    </CardContent>
  </Card>
</template>
```

---

### 5. Revenue Chart (Vue Chart.js)

**File:** `components/shared/RevenueChart.vue`

```vue
<script setup lang="ts">
import { Line } from "vue-chartjs";
import {
  Chart as ChartJS,
  CategoryScale,
  LinearScale,
  PointElement,
  LineElement,
  Title,
  Tooltip,
  Legend,
  Filler,
} from "chart.js";

ChartJS.register(
  CategoryScale,
  LinearScale,
  PointElement,
  LineElement,
  Title,
  Tooltip,
  Legend,
  Filler
);

interface Props {
  data: { month: string; revenue: number }[];
}

const props = defineProps<Props>();

const chartData = computed(() => ({
  labels: props.data.map((d) => d.month),
  datasets: [
    {
      label: "Revenue",
      data: props.data.map((d) => d.revenue),
      borderColor: "#6366f1",
      backgroundColor: "rgba(99, 102, 241, 0.1)",
      fill: true,
      tension: 0.4,
    },
  ],
}));

const chartOptions = {
  responsive: true,
  maintainAspectRatio: false,
  plugins: { legend: { display: false } },
  scales: {
    y: { grid: { color: "rgba(0,0,0,0.05)" } },
    x: { grid: { display: false } },
  },
};
</script>

<template>
  <Card>
    <CardHeader>
      <CardTitle>Revenue Overview</CardTitle>
    </CardHeader>
    <CardContent>
      <div class="h-[300px]">
        <Line :data="chartData" :options="chartOptions" />
      </div>
    </CardContent>
  </Card>
</template>
```

---

### 6. Dashboard Page

**File:** `pages/dashboard/index.vue`

```vue
<script setup lang="ts">
import { DollarSign, Users, Package, TrendingUp } from "lucide-vue-next";

definePageMeta({ middleware: "auth", layout: "dashboard" });
useSeoMeta({ title: "Dashboard" });

const revenueData = [
  { month: "Jan", revenue: 4000 },
  { month: "Feb", revenue: 3000 },
  { month: "Mar", revenue: 5000 },
  { month: "Apr", revenue: 4500 },
  { month: "May", revenue: 6000 },
  { month: "Jun", revenue: 5500 },
];
</script>

<template>
  <div class="space-y-6">
    <h1 class="text-2xl font-bold">Dashboard</h1>

    <div class="grid gap-4 sm:grid-cols-2 lg:grid-cols-4">
      <StatsCard
        title="Total Revenue"
        value="$45,231"
        :icon="DollarSign"
        :trend="{ value: 20.1, isPositive: true }"
      />
      <StatsCard
        title="Active Users"
        value="2,350"
        :icon="Users"
        :trend="{ value: 10.5, isPositive: true }"
      />
      <StatsCard
        title="Products"
        value="573"
        :icon="Package"
        :trend="{ value: 2.3, isPositive: false }"
      />
      <StatsCard
        title="Growth"
        value="12.5%"
        :icon="TrendingUp"
        :trend="{ value: 4.1, isPositive: true }"
      />
    </div>

    <RevenueChart :data="revenueData" />
  </div>
</template>
```

---

## Success Criteria
- Sidebar collapsible berfungsi
- Dark mode toggle via `@nuxtjs/color-mode`
- Stats cards tampil dengan trend indicator
- Line chart render dengan Chart.js
- `definePageMeta({ layout: "dashboard" })` berfungsi

## Next Steps
- `10_testing_quality.md` - Testing setup

---
name: dashboard-developer-specialist
description: "Expert dashboard and admin panel development including data visualization, real-time metrics, chart libraries, responsive layouts, and performance optimization"
---

# Dashboard Developer Specialist

## Overview

Skill ini menjadikan AI Agent sebagai spesialis pengembangan dashboard dan admin panel. Agent akan mampu membangun data visualization, real-time metrics, interactive charts, responsive admin layouts, dan performance-optimized dashboards.

## When to Use This Skill

- Use when building admin dashboards
- Use when creating analytics interfaces
- Use when implementing data visualization
- Use when designing metric displays and KPI cards
- Use when building real-time monitoring systems

---

## Part 1: Dashboard Architecture

### Dashboard Types

```text
DASHBOARD CATEGORIES
────────────────────

1. OPERATIONAL DASHBOARD
   - Real-time monitoring
   - Live metrics & alerts
   - System health status
   - Example: Server monitoring, live sales

2. ANALYTICAL DASHBOARD
   - Historical data analysis
   - Trends and patterns
   - Comparative analysis
   - Example: Marketing analytics, financial reports

3. STRATEGIC DASHBOARD
   - High-level KPIs
   - Business objectives
   - Executive summary
   - Example: CEO dashboard, quarterly reviews

4. ADMIN PANEL
   - CRUD operations
   - User management
   - Content management
   - Example: CMS, user admin, settings
```

### Standard Layout

```text
DASHBOARD LAYOUT STRUCTURE
┌─────────────────────────────────────────────────────────────────────┐
│  ☰  Logo              Search...              🔔  👤  Settings      │  ← Header
├──────────────┬──────────────────────────────────────────────────────┤
│              │  Dashboard Overview                           ▼ ⋮   │
│  📊 Overview │  ┌────────┐ ┌────────┐ ┌────────┐ ┌────────┐        │
│  👥 Users    │  │ Metric │ │ Metric │ │ Metric │ │ Metric │        │  ← KPI Cards
│  📦 Products │  │  $12K  │ │  +24%  │ │ 1,234  │ │  89%   │        │
│  📄 Orders   │  └────────┘ └────────┘ └────────┘ └────────┘        │
│  📈 Analytics│                                                      │
│  ⚙️ Settings │  ┌──────────────────────────────────────────────────┐│
│              │  │                                                  ││  ← Main Chart
│  ▼ Reports   │  │              Line/Bar Chart                      ││
│    • Daily   │  │                                                  ││
│    • Weekly  │  └──────────────────────────────────────────────────┘│
│    • Monthly │                                                      │
│              │  ┌─────────────────────┐ ┌─────────────────────────┐ │
│              │  │     Pie Chart       │ │     Recent Activity     │ │  ← Secondary
│              │  │                     │ │     • User signed up    │ │
│              │  │       🥧            │ │     • Order placed      │ │
│              │  └─────────────────────┘ └─────────────────────────┘ │
├──────────────┴──────────────────────────────────────────────────────┤
│  Sidebar     │               Main Content Area                       │
└─────────────────────────────────────────────────────────────────────┘
     240px                        Fluid (min 800px)
```

---

## Part 2: KPI Cards & Metrics

### Metric Card Anatomy

```text
METRIC CARD STRUCTURE
┌─────────────────────────────────────────┐
│  💰 Total Revenue                    ↗  │  ← Icon + Title + Trend
│                                         │
│  $124,563.00                            │  ← Primary Value (large)
│                                         │
│  ████████████████░░░░  80%              │  ← Progress Bar (optional)
│                                         │
│  ▲ 12.5% vs last month                  │  ← Comparison (green/red)
└─────────────────────────────────────────┘

METRIC CARD VARIANTS
├── Simple: Value only
├── With Trend: Value + change indicator
├── With Chart: Value + sparkline
├── With Progress: Value + progress bar
└── With Comparison: Value + period comparison
```

### Trend Indicators

```text
TREND COLORS & ICONS
├── Positive (Green #22C55E)
│   ├── ▲ +12.5%
│   ├── ↗ Trending up
│   └── Use for: Revenue up, costs down, improvements
│
├── Negative (Red #EF4444)
│   ├── ▼ -8.3%
│   ├── ↘ Trending down
│   └── Use for: Revenue down, errors up, declines
│
├── Neutral (Gray #6B7280)
│   ├── → 0%
│   └── Use for: No change, stable
│
└── Warning (Amber #F59E0B)
    ├── ⚠ Approaching limit
    └── Use for: Thresholds, warnings
```

---

## Part 3: Chart Selection Guide

### When to Use Each Chart

```text
CHART SELECTION MATRIX
┌─────────────────┬─────────────────────────────────────────────────┐
│ Data Type       │ Recommended Chart                               │
├─────────────────┼─────────────────────────────────────────────────┤
│ Trend over time │ Line Chart, Area Chart                          │
│ Comparison      │ Bar Chart, Grouped Bar                          │
│ Part of whole   │ Pie Chart, Donut Chart, Treemap                 │
│ Distribution    │ Histogram, Box Plot                             │
│ Relationship    │ Scatter Plot, Bubble Chart                      │
│ Ranking         │ Horizontal Bar, Lollipop                        │
│ Progress        │ Progress Bar, Gauge, Radial                     │
│ Geographic      │ Map, Choropleth, Bubble Map                     │
│ Flow/Process    │ Sankey, Funnel                                  │
│ Hierarchical    │ Treemap, Sunburst                               │
└─────────────────┴─────────────────────────────────────────────────┘

COMMON DASHBOARD CHARTS
├── Line Chart: Time series, trends
├── Bar Chart: Comparisons, rankings
├── Pie/Donut: Proportions (max 5-7 segments)
├── Area Chart: Volume over time
├── Sparkline: Inline trend indicators
├── Gauge: Single metric vs target
├── Heatmap: Correlation, activity
└── Table: Detailed data with sorting
```

### Chart Libraries

```text
RECOMMENDED LIBRARIES
─────────────────────

REACT:
├── Recharts ⭐ (declarative, composable)
├── Chart.js + react-chartjs-2
├── Nivo (beautiful, D3-based)
├── Victory (flexible, animated)
├── Tremor (dashboard-focused)
└── Apache ECharts (complex visualizations)

VUE:
├── Vue Chart.js
├── Vue ECharts
└── Vue ApexCharts

FLUTTER:
├── fl_chart ⭐ (most popular)
├── syncfusion_flutter_charts
├── charts_flutter (Google)
└── graphic

VANILLA JS:
├── Chart.js ⭐ (simple, flexible)
├── Apache ECharts (enterprise)
├── D3.js (low-level, powerful)
├── ApexCharts (modern, animated)
└── Highcharts (commercial, feature-rich)
```

---

## Part 4: Data Tables

### Table Best Practices

```text
DATA TABLE STRUCTURE
┌───────────────────────────────────────────────────────────────────────┐
│  🔍 Search...              Filter ▼   Export ▼   + Add New           │  ← Actions
├───────────────────────────────────────────────────────────────────────┤
│  ☐  Name ▲         Email              Role       Status    Actions   │  ← Header
├───────────────────────────────────────────────────────────────────────┤
│  ☐  John Doe      john@email.com      Admin      🟢 Active    ⋮      │
│  ☐  Jane Smith    jane@email.com      User       🟢 Active    ⋮      │
│  ☐  Bob Wilson    bob@email.com       Editor     🟡 Pending   ⋮      │
│  ☐  Alice Brown   alice@email.com     User       🔴 Inactive  ⋮      │
├───────────────────────────────────────────────────────────────────────┤
│  ◀  1  2  3  ...  10  ▶           Showing 1-10 of 156                │  ← Pagination
└───────────────────────────────────────────────────────────────────────┘

TABLE FEATURES:
├── Sorting (click header, show ▲▼ indicator)
├── Filtering (column-specific or global)
├── Search (real-time, debounced)
├── Pagination (page numbers or infinite scroll)
├── Selection (checkbox, bulk actions)
├── Row Actions (edit, delete, view)
├── Responsive (horizontal scroll or card view on mobile)
└── Empty State (when no data)
```

### Status Badges

```text
STATUS BADGE STYLES
├── Active/Success   🟢 [Active]     bg-green-100 text-green-800
├── Pending/Warning  🟡 [Pending]    bg-yellow-100 text-yellow-800
├── Inactive/Error   🔴 [Inactive]   bg-red-100 text-red-800
├── Info/Processing  🔵 [Processing] bg-blue-100 text-blue-800
└── Default/Draft    ⚪ [Draft]      bg-gray-100 text-gray-800
```

---

## Part 5: Sidebar Navigation

### Navigation Patterns

```text
SIDEBAR VARIANTS
────────────────

1. COLLAPSIBLE SIDEBAR
┌──────────────┐         ┌──────┐
│  📊 Overview │   →     │  📊  │
│  👥 Users    │         │  👥  │
│  📦 Products │         │  📦  │
└──────────────┘         └──────┘
   Expanded (240px)      Collapsed (64px)

2. MULTI-LEVEL NAVIGATION
├── 📊 Dashboard
├── 👥 Users
│   ├── All Users
│   ├── Add User
│   └── Roles
├── 📦 Products
│   ├── Inventory
│   └── Categories
└── ⚙️ Settings

3. GROUPED NAVIGATION
├── MAIN
│   ├── Dashboard
│   └── Analytics
├── MANAGEMENT
│   ├── Users
│   └── Products
└── SETTINGS
    ├── General
    └── Security
```

### Navigation State

```text
NAVIGATION STATES
├── Default: text-gray-600, bg-transparent
├── Hover: text-gray-900, bg-gray-100
├── Active: text-primary-600, bg-primary-50, left-border-primary
├── Expanded: Show child items
└── Collapsed: Icon only + tooltip

MOBILE BEHAVIOR
├── Drawer pattern (slide from left)
├── Overlay when open
├── Close on route change
└── Hamburger menu trigger
```

---

## Part 6: Real-Time Features

### Live Updates Architecture

```text
REAL-TIME PATTERNS
──────────────────

1. POLLING (Simple)
   Client ─── GET /metrics ───► Server
            (every 5-30 seconds)
   
   Use when: Low update frequency, simple implementation

2. SERVER-SENT EVENTS (SSE)
   Client ◄─── Event Stream ─── Server
            (one-way, text only)
   
   Use when: Server → Client only, simple data

3. WEBSOCKET (Full Duplex)
   Client ◄──► Bidirectional ◄──► Server
            (real-time, binary OK)
   
   Use when: High frequency, two-way communication

LIVE INDICATOR PATTERN
┌─────────────────────────────────────────┐
│  ● Live   Last updated: 2 seconds ago   │
│  🔄 Refreshing...                       │
│  ⚠️ Connection lost. Reconnecting...    │
└─────────────────────────────────────────┘
```

### Real-Time UI Patterns

```text
LIVE DATA DISPLAY
├── Blinking/Pulse animation on update
├── Highlight new rows (fade in)
├── Counter animation (number ticker)
├── Chart line animation (draw effect)
└── Toast notification for alerts

UPDATE STRATEGIES
├── Full refresh (simple, heavy)
├── Partial update (efficient, complex)
├── Optimistic update (instant, rollback if fail)
└── Delta/diff update (minimal data transfer)
```

---

## Part 7: Responsive Dashboard

### Breakpoint Strategies

```text
RESPONSIVE LAYOUT
─────────────────

DESKTOP (≥1024px)
┌──────────┬────────────────────────────────────────────────────┐
│ Sidebar  │  ┌────┐ ┌────┐ ┌────┐ ┌────┐                      │
│          │  │    │ │    │ │    │ │    │  ← 4 metric cards     │
│          │  └────┘ └────┘ └────┘ └────┘                      │
│          │  ┌────────────────────────────────────────────────┐│
│          │  │            Main Chart                          ││
│          │  └────────────────────────────────────────────────┘│
└──────────┴────────────────────────────────────────────────────┘

TABLET (768px - 1023px)
┌──────────────────────────────────────────────────────────────┐
│  ☰ Logo                                            🔔  👤    │
├──────────────────────────────────────────────────────────────┤
│  ┌─────────────┐ ┌─────────────┐                            │
│  │   Metric 1  │ │   Metric 2  │  ← 2 cards per row         │
│  └─────────────┘ └─────────────┘                            │
│  ┌─────────────┐ ┌─────────────┐                            │
│  │   Metric 3  │ │   Metric 4  │                            │
│  └─────────────┘ └─────────────┘                            │
│  ┌──────────────────────────────────────────────────────────┐│
│  │                    Chart                                 ││
│  └──────────────────────────────────────────────────────────┘│
└──────────────────────────────────────────────────────────────┘
     Sidebar: Drawer (hidden by default)

MOBILE (<768px)
┌────────────────────────────────┐
│  ☰                   🔔  👤    │
├────────────────────────────────┤
│  ┌────────────────────────────┐│
│  │        Metric 1           ││  ← 1 card per row
│  └────────────────────────────┘│
│  ┌────────────────────────────┐│
│  │        Metric 2           ││
│  └────────────────────────────┘│
│  ┌────────────────────────────┐│
│  │     Chart (scrollable)    ││
│  └────────────────────────────┘│
└────────────────────────────────┘
     Sidebar: Full-screen drawer
```

---

## Part 8: Dashboard UI Libraries

### Ready-to-Use Dashboard Templates

```text
REACT DASHBOARD LIBRARIES
─────────────────────────

TREMOR (tremor.so) ⭐
├── Dashboard-focused components
├── Built on Tailwind CSS
├── Charts, KPIs, Tables
└── Best for: Quick dashboards

SHADCN/UI + RECHARTS
├── Copy-paste components
├── Highly customizable
├── Modern design
└── Best for: Custom dashboards

ANT DESIGN PRO
├── Enterprise-ready
├── Complete admin template
├── Chinese documentation
└── Best for: Enterprise apps

MATERIAL-UI (MUI)
├── Google Material Design
├── Large ecosystem
├── Premium templates available
└── Best for: Material-based apps

NEXT.JS DASHBOARD TEMPLATES
├── Vercel Dashboard
├── Taxonomy
├── AdminJS
└── Built-in routing + API

FLUTTER DASHBOARD
─────────────────
├── flutter_admin_scaffold
├── dashboard_reborn
├── responsive_framework + fl_chart
└── syncfusion_flutter_core
```

---

## Part 9: Performance Optimization

### Dashboard Performance

```text
OPTIMIZATION STRATEGIES
───────────────────────

DATA LOADING
├── Lazy load below-fold content
├── Paginate large datasets
├── Use skeleton loading states
├── Cache API responses
└── Implement virtual scrolling for long lists

CHART OPTIMIZATION
├── Limit data points (aggregate if > 1000)
├── Debounce resize handlers
├── Lazy load charts not in viewport
├── Use canvas-based charts for large data
└── Avoid re-renders on unrelated state changes

REAL-TIME OPTIMIZATION
├── Batch updates (every 1-5 seconds)
├── Throttle WebSocket messages
├── Use delta updates, not full refresh
└── Disconnect when tab not visible

BUNDLE SIZE
├── Tree-shake chart libraries
├── Code-split dashboard routes
├── Lazy load heavy components
└── Use lightweight alternatives when possible
```

---

## Best Practices

### ✅ Do This

- ✅ Put most important metrics at top-left
- ✅ Use consistent color coding across charts
- ✅ Provide data export options (CSV, PDF)
- ✅ Show loading skeletons, not spinners
- ✅ Add tooltips to chart data points
- ✅ Include time range selectors
- ✅ Make tables sortable and filterable
- ✅ Support keyboard navigation
- ✅ Cache dashboard data appropriately
- ✅ Show "last updated" timestamps

### ❌ Avoid This

- ❌ Don't use more than 5-7 colors in a chart
- ❌ Don't show pie charts with > 7 segments
- ❌ Don't auto-refresh too frequently (< 5 seconds)
- ❌ Don't hide critical metrics in dropdowns
- ❌ Don't use 3D charts (harder to read)
- ❌ Don't forget empty states for no data
- ❌ Don't ignore mobile responsiveness
- ❌ Don't load all data at once (paginate!)

---

## Related Skills

- `@senior-react-developer` - React dashboard implementation
- `@senior-frontend-developer` - Frontend development
- `@bi-dashboard-developer` - Business intelligence dashboards
- `@analytics-engineer` - Data analytics and tracking
- `@senior-ui-ux-designer` - Dashboard design principles
- `@senior-tailwindcss-developer` - Styling with Tailwind

---
name: portfolio-dashboard-developer
description: "Expert portfolio website and analytics dashboard development with modern UI"
---

# Portfolio Dashboard Developer

## Overview

Build stunning portfolio websites and data-driven analytics dashboards.

## When to Use This Skill

- Use when creating portfolio sites
- Use when building dashboards

## How It Works

### Step 1: Portfolio Structure

```markdown
## Essential Sections

### Hero
- Name & Title
- Tagline / Value proposition
- CTA button
- Professional photo

### About
- Brief bio
- Skills & expertise
- Experience timeline
- Personal story

### Projects
- Featured work (3-6 projects)
- Case studies
- Live demos / Screenshots
- Tech stack used

### Contact
- Contact form
- Social links
- Email
- Location (optional)

### Optional
- Blog / Writing
- Testimonials
- Services
- Resume download
```

### Step 2: Portfolio Component (React)

```tsx
// ProjectCard.tsx
interface Project {
  title: string;
  description: string;
  image: string;
  tags: string[];
  liveUrl?: string;
  githubUrl?: string;
}

function ProjectCard({ project }: { project: Project }) {
  return (
    <div className="project-card">
      <div className="project-image">
        <img src={project.image} alt={project.title} />
        <div className="overlay">
          {project.liveUrl && (
            <a href={project.liveUrl} target="_blank">
              <ExternalLink /> Live
            </a>
          )}
          {project.githubUrl && (
            <a href={project.githubUrl} target="_blank">
              <Github /> Code
            </a>
          )}
        </div>
      </div>
      
      <div className="project-content">
        <h3>{project.title}</h3>
        <p>{project.description}</p>
        <div className="tags">
          {project.tags.map(tag => (
            <span key={tag} className="tag">{tag}</span>
          ))}
        </div>
      </div>
    </div>
  );
}
```

### Step 3: Dashboard Layout

```tsx
// Dashboard.tsx
function Dashboard() {
  return (
    <div className="dashboard">
      <Sidebar />
      
      <main className="dashboard-main">
        <header className="dashboard-header">
          <h1>Analytics Overview</h1>
          <DateRangePicker />
        </header>
        
        {/* Stats Cards */}
        <div className="stats-grid">
          <StatCard title="Total Revenue" value="$24,500" change={+12.5} />
          <StatCard title="Orders" value="1,240" change={+8.2} />
          <StatCard title="Customers" value="845" change={-2.4} />
          <StatCard title="Conversion" value="3.2%" change={+1.1} />
        </div>
        
        {/* Charts */}
        <div className="charts-grid">
          <ChartCard title="Revenue Trend">
            <LineChart data={revenueData} />
          </ChartCard>
          
          <ChartCard title="Sales by Category">
            <PieChart data={categoryData} />
          </ChartCard>
        </div>
        
        {/* Table */}
        <DataTable 
          title="Recent Orders"
          columns={orderColumns}
          data={orders}
        />
      </main>
    </div>
  );
}
```

### Step 4: Chart Components

```tsx
// Using Recharts
import { LineChart, Line, XAxis, YAxis, Tooltip, ResponsiveContainer } from 'recharts';

function RevenueChart({ data }) {
  return (
    <ResponsiveContainer width="100%" height={300}>
      <LineChart data={data}>
        <XAxis dataKey="date" />
        <YAxis />
        <Tooltip />
        <Line 
          type="monotone" 
          dataKey="revenue" 
          stroke="#3b82f6" 
          strokeWidth={2}
        />
      </LineChart>
    </ResponsiveContainer>
  );
}

// Stat Card with trend
function StatCard({ title, value, change }) {
  const isPositive = change >= 0;
  
  return (
    <div className="stat-card">
      <span className="stat-title">{title}</span>
      <span className="stat-value">{value}</span>
      <span className={`stat-change ${isPositive ? 'positive' : 'negative'}`}>
        {isPositive ? '↑' : '↓'} {Math.abs(change)}%
      </span>
    </div>
  );
}
```

### Step 5: Dashboard CSS

```css
.dashboard {
  display: flex;
  min-height: 100vh;
}

.dashboard-main {
  flex: 1;
  padding: 24px;
  background: #f5f7fa;
}

.stats-grid {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: 20px;
  margin-bottom: 24px;
}

.stat-card {
  background: white;
  padding: 20px;
  border-radius: 12px;
  box-shadow: 0 1px 3px rgba(0,0,0,0.1);
}

.stat-value {
  font-size: 28px;
  font-weight: 700;
  color: #1a1a1a;
}

.stat-change.positive { color: #10b981; }
.stat-change.negative { color: #ef4444; }

.charts-grid {
  display: grid;
  grid-template-columns: 2fr 1fr;
  gap: 20px;
}
```

## Best Practices

- ✅ Mobile-first design
- ✅ Fast loading (optimize images)
- ✅ Clear navigation
- ❌ Don't overcrowd with projects
- ❌ Don't use low-quality images

## Related Skills

- `@senior-react-developer`
- `@senior-ui-ux-designer`

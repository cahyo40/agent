---
name: hr-payroll-developer
description: "Expert HR and payroll system development including employee management, attendance, and salary processing"
---

# HR Payroll Developer

## Overview

This skill transforms you into an **HR & Payroll Systems Expert**. You will master **Employee Management**, **Attendance Tracking**, **Payroll Processing**, **Leave Management**, and **Tax Calculations** for building production-ready HRIS systems.

## When to Use This Skill

- Use when building HR information systems
- Use when implementing payroll processing
- Use when creating attendance systems
- Use when building leave management
- Use when handling tax and deduction calculations

---

## Part 1: HRIS Architecture

### 1.1 System Components

```
┌─────────────────────────────────────────────────────────────┐
│                        HRIS System                           │
├──────────────┬─────────────┬──────────────┬─────────────────┤
│ Employee Mgmt│ Attendance  │ Leave        │ Performance     │
├──────────────┼─────────────┼──────────────┼─────────────────┤
│ Payroll      │ Tax/Deduct  │ Benefits     │ Reporting       │
└──────────────┴─────────────┴──────────────┴─────────────────┘
```

### 1.2 Key Concepts

| Concept | Description |
|---------|-------------|
| **Gross Salary** | Base pay + allowances |
| **Net Salary** | Gross - deductions - tax |
| **Deductions** | Tax, insurance, loans |
| **Allowances** | Transport, meal, housing |
| **Payroll Period** | Monthly, bi-weekly |
| **Cut-off Date** | Attendance calculation deadline |

---

## Part 2: Database Schema

### 2.1 Core Tables

```sql
-- Employees
CREATE TABLE employees (
    id UUID PRIMARY KEY,
    employee_id VARCHAR(50) UNIQUE,  -- EMP001
    user_id UUID REFERENCES users(id),
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    email VARCHAR(255),
    phone VARCHAR(20),
    date_of_birth DATE,
    gender VARCHAR(20),
    hire_date DATE NOT NULL,
    termination_date DATE,
    department_id UUID REFERENCES departments(id),
    position_id UUID REFERENCES positions(id),
    manager_id UUID REFERENCES employees(id),
    employment_type VARCHAR(50),  -- 'full_time', 'part_time', 'contract'
    status VARCHAR(50) DEFAULT 'active',  -- 'active', 'on_leave', 'terminated'
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Salary Structure
CREATE TABLE salary_structures (
    id UUID PRIMARY KEY,
    employee_id UUID REFERENCES employees(id),
    effective_date DATE NOT NULL,
    base_salary DECIMAL(15, 2),
    currency VARCHAR(3) DEFAULT 'IDR',
    pay_frequency VARCHAR(20) DEFAULT 'monthly',
    bank_name VARCHAR(100),
    bank_account VARCHAR(50),
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Allowances & Deductions Templates
CREATE TABLE pay_components (
    id UUID PRIMARY KEY,
    name VARCHAR(100),
    type VARCHAR(20),  -- 'allowance', 'deduction'
    calculation_type VARCHAR(20),  -- 'fixed', 'percentage'
    amount DECIMAL(15, 2),  -- Fixed amount or percentage
    taxable BOOLEAN DEFAULT TRUE,
    mandatory BOOLEAN DEFAULT FALSE,
    active BOOLEAN DEFAULT TRUE
);

-- Attendance
CREATE TABLE attendance (
    id UUID PRIMARY KEY,
    employee_id UUID REFERENCES employees(id),
    date DATE NOT NULL,
    clock_in TIMESTAMPTZ,
    clock_out TIMESTAMPTZ,
    status VARCHAR(50),  -- 'present', 'absent', 'late', 'half_day', 'holiday'
    work_hours DECIMAL(4, 2),
    overtime_hours DECIMAL(4, 2) DEFAULT 0,
    notes TEXT,
    UNIQUE(employee_id, date)
);

-- Leave Requests
CREATE TABLE leave_requests (
    id UUID PRIMARY KEY,
    employee_id UUID REFERENCES employees(id),
    leave_type VARCHAR(50),  -- 'annual', 'sick', 'maternity', 'unpaid'
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    days INTEGER,
    reason TEXT,
    status VARCHAR(50) DEFAULT 'pending',  -- 'pending', 'approved', 'rejected'
    approved_by UUID REFERENCES employees(id),
    approved_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Leave Balances
CREATE TABLE leave_balances (
    id UUID PRIMARY KEY,
    employee_id UUID REFERENCES employees(id),
    leave_type VARCHAR(50),
    year INTEGER,
    entitled_days INTEGER,
    used_days INTEGER DEFAULT 0,
    carried_over INTEGER DEFAULT 0,
    UNIQUE(employee_id, leave_type, year)
);

-- Payroll Runs
CREATE TABLE payroll_runs (
    id UUID PRIMARY KEY,
    period_start DATE NOT NULL,
    period_end DATE NOT NULL,
    status VARCHAR(50) DEFAULT 'draft',  -- 'draft', 'processing', 'approved', 'paid'
    total_gross DECIMAL(18, 2),
    total_deductions DECIMAL(18, 2),
    total_net DECIMAL(18, 2),
    processed_at TIMESTAMPTZ,
    approved_by UUID REFERENCES users(id),
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Payslips
CREATE TABLE payslips (
    id UUID PRIMARY KEY,
    payroll_run_id UUID REFERENCES payroll_runs(id),
    employee_id UUID REFERENCES employees(id),
    base_salary DECIMAL(15, 2),
    gross_salary DECIMAL(15, 2),
    total_allowances DECIMAL(15, 2),
    total_deductions DECIMAL(15, 2),
    tax_amount DECIMAL(15, 2),
    net_salary DECIMAL(15, 2),
    work_days INTEGER,
    absent_days INTEGER,
    overtime_hours DECIMAL(6, 2),
    breakdown JSONB,  -- Detailed components
    created_at TIMESTAMPTZ DEFAULT NOW()
);
```

---

## Part 3: Payroll Processing

### 3.1 Calculate Payslip

```typescript
interface PayslipCalculation {
  baseSalary: number;
  allowances: { name: string; amount: number }[];
  deductions: { name: string; amount: number }[];
  tax: number;
  grossSalary: number;
  netSalary: number;
}

async function calculatePayslip(
  employeeId: string,
  periodStart: Date,
  periodEnd: Date
): Promise<PayslipCalculation> {
  const employee = await db.employees.findUnique({
    where: { id: employeeId },
    include: { salaryStructure: true },
  });
  
  const salary = employee.salaryStructure;
  
  // Get attendance summary
  const attendance = await db.attendance.aggregate({
    where: { employeeId, date: { gte: periodStart, lte: periodEnd } },
    _count: true,
    _sum: { workHours: true, overtimeHours: true },
  });
  
  // Calculate working days
  const workingDays = getWorkingDays(periodStart, periodEnd);
  const presentDays = attendance._count;
  const absentDays = workingDays - presentDays;
  
  // Prorate salary for absences (if applicable)
  const dailyRate = salary.baseSalary / workingDays;
  const proratedSalary = salary.baseSalary - (absentDays * dailyRate);
  
  // Get allowances
  const allowanceComponents = await db.employeePayComponents.findMany({
    where: { employeeId, component: { type: 'allowance' } },
    include: { component: true },
  });
  
  const allowances = allowanceComponents.map(ac => ({
    name: ac.component.name,
    amount: ac.component.calculationType === 'percentage'
      ? proratedSalary * (ac.component.amount / 100)
      : ac.component.amount,
  }));
  
  const totalAllowances = allowances.reduce((sum, a) => sum + a.amount, 0);
  
  // Overtime
  const overtimeRate = (salary.baseSalary / 173) * 1.5;  // 173 = avg monthly hours
  const overtimePay = attendance._sum.overtimeHours * overtimeRate;
  
  // Gross salary
  const grossSalary = proratedSalary + totalAllowances + overtimePay;
  
  // Get deductions
  const deductionComponents = await db.employeePayComponents.findMany({
    where: { employeeId, component: { type: 'deduction' } },
    include: { component: true },
  });
  
  const deductions = deductionComponents.map(dc => ({
    name: dc.component.name,
    amount: dc.component.calculationType === 'percentage'
      ? grossSalary * (dc.component.amount / 100)
      : dc.component.amount,
  }));
  
  const totalDeductions = deductions.reduce((sum, d) => sum + d.amount, 0);
  
  // Calculate tax (simplified progressive tax)
  const taxableIncome = grossSalary - (allowances.filter(a => !a.taxable).reduce((s, a) => s + a.amount, 0));
  const tax = calculateTax(taxableIncome * 12) / 12;  // Annualize then monthly
  
  // Net salary
  const netSalary = grossSalary - totalDeductions - tax;
  
  return {
    baseSalary: salary.baseSalary,
    allowances,
    deductions,
    tax,
    grossSalary,
    netSalary,
  };
}

function calculateTax(annualIncome: number): number {
  // Indonesian PPh 21 brackets (simplified)
  const brackets = [
    { limit: 60_000_000, rate: 0.05 },
    { limit: 250_000_000, rate: 0.15 },
    { limit: 500_000_000, rate: 0.25 },
    { limit: 5_000_000_000, rate: 0.30 },
    { limit: Infinity, rate: 0.35 },
  ];
  
  let tax = 0;
  let remaining = annualIncome;
  let prevLimit = 0;
  
  for (const bracket of brackets) {
    const taxableInBracket = Math.min(remaining, bracket.limit - prevLimit);
    if (taxableInBracket <= 0) break;
    
    tax += taxableInBracket * bracket.rate;
    remaining -= taxableInBracket;
    prevLimit = bracket.limit;
  }
  
  return tax;
}
```

### 3.2 Run Payroll

```typescript
app.post('/api/payroll/run', async (req, res) => {
  const { periodStart, periodEnd } = req.body;
  
  // Create payroll run
  const payrollRun = await db.payrollRuns.create({
    data: {
      periodStart: new Date(periodStart),
      periodEnd: new Date(periodEnd),
      status: 'processing',
    },
  });
  
  // Get all active employees
  const employees = await db.employees.findMany({
    where: { status: 'active' },
  });
  
  let totalGross = 0;
  let totalDeductions = 0;
  let totalNet = 0;
  
  for (const employee of employees) {
    const calculation = await calculatePayslip(employee.id, periodStart, periodEnd);
    
    await db.payslips.create({
      data: {
        payrollRunId: payrollRun.id,
        employeeId: employee.id,
        baseSalary: calculation.baseSalary,
        grossSalary: calculation.grossSalary,
        totalAllowances: calculation.allowances.reduce((s, a) => s + a.amount, 0),
        totalDeductions: calculation.deductions.reduce((s, d) => s + d.amount, 0),
        taxAmount: calculation.tax,
        netSalary: calculation.netSalary,
        breakdown: calculation,
      },
    });
    
    totalGross += calculation.grossSalary;
    totalDeductions += calculation.deductions.reduce((s, d) => s + d.amount, 0) + calculation.tax;
    totalNet += calculation.netSalary;
  }
  
  // Update payroll run totals
  await db.payrollRuns.update({
    where: { id: payrollRun.id },
    data: {
      status: 'draft',
      totalGross,
      totalDeductions,
      totalNet,
      processedAt: new Date(),
    },
  });
  
  res.json(payrollRun);
});
```

---

## Part 4: Leave Management

### 4.1 Request Leave

```typescript
app.post('/api/leave/request', async (req, res) => {
  const { leaveType, startDate, endDate, reason } = req.body;
  
  const days = calculateLeaveDays(new Date(startDate), new Date(endDate));
  
  // Check balance
  const balance = await db.leaveBalances.findFirst({
    where: {
      employeeId: req.user.employeeId,
      leaveType,
      year: new Date().getFullYear(),
    },
  });
  
  const available = balance.entitledDays + balance.carriedOver - balance.usedDays;
  
  if (days > available && leaveType !== 'unpaid') {
    return res.status(400).json({ error: 'Insufficient leave balance' });
  }
  
  const request = await db.leaveRequests.create({
    data: {
      employeeId: req.user.employeeId,
      leaveType,
      startDate: new Date(startDate),
      endDate: new Date(endDate),
      days,
      reason,
      status: 'pending',
    },
  });
  
  // Notify manager
  await notifyManager(req.user.employeeId, 'leave_request', request);
  
  res.json(request);
});
```

---

## Part 5: Best Practices Checklist

### ✅ Do This

- ✅ **Lock Payroll Period**: Prevent attendance changes after cut-off.
- ✅ **Audit Trail**: Log all payroll calculations and approvals.
- ✅ **Separate Test Environment**: Never test with production data.

### ❌ Avoid This

- ❌ **Manual Calculations**: Use tested formulas.
- ❌ **Skip Approvals**: Multi-level approval for payroll.
- ❌ **Ignore Tax Updates**: Stay current with regulations.

---

## Related Skills

- `@fintech-developer` - Financial systems
- `@erp-developer` - Enterprise systems
- `@booking-system-developer` - Attendance/scheduling

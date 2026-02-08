---
name: erp-developer
description: "Expert in Enterprise Resource Planning (ERP) development including finance, HR, manufacturing, inventory, sales, and integrated business workflows"
---

# ERP Developer

## Overview

This skill transforms you into an **Expert ERP Developer** with extensive experience building comprehensive Enterprise Resource Planning systems. You will master **Modular Architecture**, **Financial Accounting**, **HR & Payroll**, **Manufacturing (MRP/BOM)**, **Inventory Management**, **Approval Workflows**, and **Multi-Tenant Enterprise Systems**.

## When to Use This Skill

- Use when building enterprise management systems
- Use when integrating accounting, inventory, HR, manufacturing
- Use when implementing business workflows and approvals
- Use when building multi-tenant enterprise apps
- Use when migrating from legacy ERP systems
- Use when implementing audit trails and compliance

---

## Part 1: ERP Architecture

### 1.1 Core Modules

```
┌─────────────────────────────────────────────────────────────────────────┐
│                         ERP System                                       │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                          │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐ │
│  │   Finance    │  │    Sales     │  │   Purchase   │  │  Inventory   │ │
│  │   (GL/AP/AR) │  │ (Orders/CRM) │  │  (PO/Vendor) │  │  (WMS/Stock) │ │
│  └──────────────┘  └──────────────┘  └──────────────┘  └──────────────┘ │
│                                                                          │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐ │
│  │      HR      │  │ Manufacturing│  │   Project    │  │   Assets     │ │
│  │ (Payroll/    │  │ (BOM/MRP/    │  │  Management  │  │  Management  │ │
│  │  Attendance) │  │  WorkOrder)  │  │              │  │              │ │
│  └──────────────┘  └──────────────┘  └──────────────┘  └──────────────┘ │
│                                                                          │
├─────────────────────────────────────────────────────────────────────────┤
│                         Master Data Layer                                │
│  (Customers, Vendors, Products, Chart of Accounts, Cost Centers)        │
├─────────────────────────────────────────────────────────────────────────┤
│                    Workflow & Approval Engine                            │
├─────────────────────────────────────────────────────────────────────────┤
│                    Reporting & Analytics                                 │
└─────────────────────────────────────────────────────────────────────────┘
```

### 1.2 Module Breakdown

| Module | Sub-Modules | Key Features |
|--------|-------------|--------------|
| **Finance** | GL, AP, AR, Budgeting, Assets | Double-entry, multi-currency, period closing |
| **Sales** | Orders, Quotes, Invoicing, CRM | Pricing rules, delivery tracking |
| **Purchase** | PO, Vendors, Receiving, RFQ | Three-way match, approval workflow |
| **Inventory** | Stock, Warehouses, Transfers | FIFO/LIFO/Average, bin locations |
| **HR** | Employees, Payroll, Leave, Attendance | Salary structures, tax calculation |
| **Manufacturing** | BOM, Work Orders, MRP, QC | Material planning, production scheduling |
| **Project** | Projects, Tasks, Timesheets | Resource allocation, billing |
| **Assets** | Fixed Assets, Depreciation | Asset lifecycle, disposal |

---

## Part 2: Financial Module

### 2.1 Chart of Accounts Schema

```sql
-- Chart of Accounts
CREATE TABLE accounts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    company_id UUID REFERENCES companies(id),
    code VARCHAR(20) NOT NULL,
    name VARCHAR(200) NOT NULL,
    type VARCHAR(50) NOT NULL,  -- 'asset', 'liability', 'equity', 'revenue', 'expense'
    subtype VARCHAR(50),         -- 'current_asset', 'fixed_asset', 'bank', etc.
    parent_id UUID REFERENCES accounts(id),
    is_header BOOLEAN DEFAULT FALSE,
    is_system BOOLEAN DEFAULT FALSE,  -- System accounts cannot be deleted
    balance_type VARCHAR(10) NOT NULL,  -- 'debit', 'credit'
    currency_code VARCHAR(3) DEFAULT 'IDR',
    is_active BOOLEAN DEFAULT TRUE,
    
    -- Control accounts
    is_bank BOOLEAN DEFAULT FALSE,
    is_ar BOOLEAN DEFAULT FALSE,
    is_ap BOOLEAN DEFAULT FALSE,
    is_inventory BOOLEAN DEFAULT FALSE,
    
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    
    UNIQUE(company_id, code)
);

CREATE INDEX idx_accounts_type ON accounts(company_id, type);
CREATE INDEX idx_accounts_parent ON accounts(parent_id);

-- Fiscal Periods
CREATE TABLE fiscal_periods (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    company_id UUID REFERENCES companies(id),
    fiscal_year INTEGER NOT NULL,
    period_number INTEGER NOT NULL,  -- 1-12 for months, 13 for adjustments
    name VARCHAR(50) NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    status VARCHAR(20) DEFAULT 'open',  -- 'open', 'closed', 'locked'
    closed_by UUID REFERENCES users(id),
    closed_at TIMESTAMPTZ,
    
    UNIQUE(company_id, fiscal_year, period_number)
);
```

### 2.2 Double-Entry Bookkeeping

```sql
-- Journal Entries
CREATE TABLE journal_entries (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    company_id UUID REFERENCES companies(id),
    entry_number VARCHAR(50) NOT NULL,
    entry_date DATE NOT NULL,
    fiscal_period_id UUID REFERENCES fiscal_periods(id),
    
    -- Description
    description TEXT,
    reference VARCHAR(100),      -- 'INV-001', 'PO-001', 'PAY-001'
    reference_type VARCHAR(50),  -- 'invoice', 'payment', 'purchase_order'
    reference_id UUID,           -- Link to source document
    
    -- Amounts (for quick reference)
    total_debit DECIMAL(15, 2) NOT NULL,
    total_credit DECIMAL(15, 2) NOT NULL,
    
    -- Multi-currency
    currency_code VARCHAR(3) DEFAULT 'IDR',
    exchange_rate DECIMAL(15, 6) DEFAULT 1,
    
    -- Status
    status VARCHAR(20) DEFAULT 'draft',  -- 'draft', 'posted', 'reversed'
    posted_at TIMESTAMPTZ,
    posted_by UUID REFERENCES users(id),
    reversed_by_id UUID REFERENCES journal_entries(id),
    
    -- Audit
    created_by UUID REFERENCES users(id),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    
    UNIQUE(company_id, entry_number),
    CONSTRAINT balanced_entry CHECK (total_debit = total_credit)
);

-- Journal Lines
CREATE TABLE journal_lines (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    entry_id UUID REFERENCES journal_entries(id) ON DELETE CASCADE,
    line_number INTEGER NOT NULL,
    account_id UUID REFERENCES accounts(id),
    
    -- Amounts
    debit DECIMAL(15, 2) DEFAULT 0,
    credit DECIMAL(15, 2) DEFAULT 0,
    
    -- Original currency (for multi-currency)
    original_amount DECIMAL(15, 2),
    original_currency VARCHAR(3),
    
    -- Dimensions
    cost_center_id UUID REFERENCES cost_centers(id),
    project_id UUID REFERENCES projects(id),
    department_id UUID REFERENCES departments(id),
    
    description TEXT,
    
    CONSTRAINT valid_amount CHECK (
        (debit > 0 AND credit = 0) OR 
        (credit > 0 AND debit = 0)
    )
);

CREATE INDEX idx_journal_lines_account ON journal_lines(account_id);
CREATE INDEX idx_journal_lines_entry ON journal_lines(entry_id);

-- Balance validation trigger
CREATE OR REPLACE FUNCTION validate_entry_balance()
RETURNS TRIGGER AS $$
DECLARE
    total_debits DECIMAL(15, 2);
    total_credits DECIMAL(15, 2);
BEGIN
    SELECT 
        COALESCE(SUM(debit), 0), 
        COALESCE(SUM(credit), 0)
    INTO total_debits, total_credits
    FROM journal_lines 
    WHERE entry_id = NEW.entry_id;
    
    IF total_debits != total_credits THEN
        RAISE EXCEPTION 'Journal entry is not balanced: debits=%, credits=%', 
            total_debits, total_credits;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE CONSTRAINT TRIGGER check_entry_balance
AFTER INSERT OR UPDATE ON journal_lines
DEFERRABLE INITIALLY DEFERRED
FOR EACH ROW
EXECUTE FUNCTION validate_entry_balance();
```

### 2.3 Invoice to Journal Entry

```typescript
// services/accounting.service.ts
export class AccountingService {
  private readonly systemAccounts = {
    accountsReceivable: 'AR-001',
    accountsPayable: 'AP-001',
    revenue: 'REV-001',
    taxPayable: 'TAX-001',
    inventory: 'INV-001',
    cogs: 'COGS-001',
    bank: 'BANK-001',
  };
  
  async postSalesInvoice(invoice: Invoice): Promise<JournalEntry> {
    const period = await this.getCurrentPeriod(invoice.companyId);
    
    if (period.status !== 'open') {
      throw new Error('Fiscal period is closed');
    }
    
    const lines: JournalLineInput[] = [];
    
    // Debit: Accounts Receivable
    lines.push({
      accountCode: this.systemAccounts.accountsReceivable,
      debit: invoice.total,
      credit: 0,
      description: `Invoice ${invoice.invoiceNumber} - ${invoice.customer.name}`,
    });
    
    // Credit: Revenue (for each line item by category)
    for (const item of invoice.items) {
      lines.push({
        accountCode: item.revenueAccountCode || this.systemAccounts.revenue,
        debit: 0,
        credit: item.subtotal,
        description: `${item.productName} x ${item.quantity}`,
      });
    }
    
    // Credit: Tax Payable
    if (invoice.taxAmount > 0) {
      lines.push({
        accountCode: this.systemAccounts.taxPayable,
        debit: 0,
        credit: invoice.taxAmount,
        description: `PPN ${invoice.invoiceNumber}`,
      });
    }
    
    // Credit: COGS and Debit: Inventory (for product sales)
    for (const item of invoice.items) {
      if (item.product?.trackInventory) {
        const cogs = item.quantity * item.product.costPrice;
        
        // Debit COGS
        lines.push({
          accountCode: this.systemAccounts.cogs,
          debit: cogs,
          credit: 0,
          description: `COGS - ${item.productName}`,
        });
        
        // Credit Inventory
        lines.push({
          accountCode: this.systemAccounts.inventory,
          debit: 0,
          credit: cogs,
          description: `Inventory out - ${item.productName}`,
        });
      }
    }
    
    return this.createJournalEntry({
      companyId: invoice.companyId,
      entryDate: invoice.invoiceDate,
      description: `Sales Invoice ${invoice.invoiceNumber}`,
      referenceType: 'sales_invoice',
      referenceId: invoice.id,
      reference: invoice.invoiceNumber,
      lines,
    });
  }
  
  async postPaymentReceived(payment: Payment): Promise<JournalEntry> {
    const lines: JournalLineInput[] = [];
    
    // Debit: Bank
    lines.push({
      accountCode: payment.bankAccount.accountCode,
      debit: payment.amount,
      credit: 0,
      description: `Payment from ${payment.customer.name}`,
    });
    
    // Credit: Accounts Receivable
    lines.push({
      accountCode: this.systemAccounts.accountsReceivable,
      debit: 0,
      credit: payment.amount,
      description: `Payment for Invoice ${payment.invoice.invoiceNumber}`,
    });
    
    return this.createJournalEntry({
      companyId: payment.companyId,
      entryDate: payment.paymentDate,
      description: `Payment received - ${payment.paymentNumber}`,
      referenceType: 'payment',
      referenceId: payment.id,
      reference: payment.paymentNumber,
      lines,
    });
  }
  
  async getTrialBalance(companyId: string, asOfDate: Date): Promise<TrialBalanceReport> {
    const accounts = await db.$queryRaw<TrialBalanceRow[]>`
      SELECT 
        a.code,
        a.name,
        a.type,
        a.balance_type,
        COALESCE(SUM(jl.debit), 0) as total_debit,
        COALESCE(SUM(jl.credit), 0) as total_credit,
        CASE 
          WHEN a.balance_type = 'debit' THEN COALESCE(SUM(jl.debit), 0) - COALESCE(SUM(jl.credit), 0)
          ELSE COALESCE(SUM(jl.credit), 0) - COALESCE(SUM(jl.debit), 0)
        END as balance
      FROM accounts a
      LEFT JOIN journal_lines jl ON a.id = jl.account_id
      LEFT JOIN journal_entries je ON jl.entry_id = je.id
        AND je.status = 'posted'
        AND je.entry_date <= ${asOfDate}
      WHERE a.company_id = ${companyId}::uuid
        AND a.is_header = FALSE
      GROUP BY a.id, a.code, a.name, a.type, a.balance_type
      HAVING COALESCE(SUM(jl.debit), 0) != 0 
          OR COALESCE(SUM(jl.credit), 0) != 0
      ORDER BY a.code
    `;
    
    return {
      asOfDate,
      accounts,
      totalDebit: accounts.reduce((sum, a) => sum + a.totalDebit, 0),
      totalCredit: accounts.reduce((sum, a) => sum + a.totalCredit, 0),
    };
  }
}
```

### 2.4 Multi-Currency Support

```typescript
// services/currency.service.ts
export class CurrencyService {
  async convertAmount(
    amount: number,
    fromCurrency: string,
    toCurrency: string,
    date: Date
  ): Promise<{ convertedAmount: number; rate: number }> {
    if (fromCurrency === toCurrency) {
      return { convertedAmount: amount, rate: 1 };
    }
    
    const rate = await this.getExchangeRate(fromCurrency, toCurrency, date);
    return {
      convertedAmount: Math.round(amount * rate * 100) / 100,
      rate,
    };
  }
  
  async getExchangeRate(
    fromCurrency: string,
    toCurrency: string,
    date: Date
  ): Promise<number> {
    // Try to find exact date rate
    let rate = await db.exchangeRates.findFirst({
      where: {
        fromCurrency,
        toCurrency,
        effectiveDate: { lte: date },
      },
      orderBy: { effectiveDate: 'desc' },
    });
    
    if (!rate) {
      // Try reverse rate
      rate = await db.exchangeRates.findFirst({
        where: {
          fromCurrency: toCurrency,
          toCurrency: fromCurrency,
          effectiveDate: { lte: date },
        },
        orderBy: { effectiveDate: 'desc' },
      });
      
      if (rate) {
        return 1 / rate.rate;
      }
      
      throw new Error(`Exchange rate not found: ${fromCurrency} to ${toCurrency}`);
    }
    
    return rate.rate;
  }
}
```

---

## Part 3: HR & Payroll Module

### 3.1 Employee Schema

```sql
-- Employees
CREATE TABLE employees (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    company_id UUID REFERENCES companies(id),
    employee_number VARCHAR(50) NOT NULL,
    user_id UUID REFERENCES users(id),
    
    -- Personal Info
    full_name VARCHAR(200) NOT NULL,
    nickname VARCHAR(100),
    email VARCHAR(255),
    phone VARCHAR(20),
    id_number VARCHAR(50),        -- KTP
    npwp VARCHAR(50),             -- Tax ID
    date_of_birth DATE,
    gender VARCHAR(10),
    marital_status VARCHAR(20),   -- 'single', 'married', 'divorced', 'widowed'
    religion VARCHAR(50),
    blood_type VARCHAR(5),
    address TEXT,
    
    -- Employment
    department_id UUID REFERENCES departments(id),
    position_id UUID REFERENCES positions(id),
    manager_id UUID REFERENCES employees(id),
    employment_type VARCHAR(20),  -- 'permanent', 'contract', 'probation', 'intern'
    join_date DATE NOT NULL,
    end_date DATE,
    status VARCHAR(20) DEFAULT 'active',  -- 'active', 'inactive', 'terminated', 'resigned'
    
    -- Payroll
    salary_structure_id UUID REFERENCES salary_structures(id),
    bank_name VARCHAR(100),
    bank_account_number VARCHAR(50),
    bank_account_name VARCHAR(200),
    
    -- Leave
    annual_leave_balance DECIMAL(5, 2) DEFAULT 12,
    sick_leave_balance DECIMAL(5, 2) DEFAULT 12,
    
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    
    UNIQUE(company_id, employee_number)
);

CREATE INDEX idx_employees_department ON employees(department_id);
CREATE INDEX idx_employees_manager ON employees(manager_id);

-- Salary Structures
CREATE TABLE salary_structures (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    company_id UUID REFERENCES companies(id),
    name VARCHAR(100) NOT NULL,
    
    -- Base salary
    base_salary DECIMAL(15, 2) NOT NULL,
    currency VARCHAR(3) DEFAULT 'IDR',
    pay_frequency VARCHAR(20) DEFAULT 'monthly',  -- 'monthly', 'weekly', 'bi-weekly'
    
    -- Allowances
    transport_allowance DECIMAL(15, 2) DEFAULT 0,
    meal_allowance DECIMAL(15, 2) DEFAULT 0,
    housing_allowance DECIMAL(15, 2) DEFAULT 0,
    phone_allowance DECIMAL(15, 2) DEFAULT 0,
    position_allowance DECIMAL(15, 2) DEFAULT 0,
    
    -- Deductions
    bpjs_health_employee DECIMAL(5, 2) DEFAULT 1,     -- % of salary
    bpjs_employment_jht_employee DECIMAL(5, 2) DEFAULT 2,
    bpjs_employment_jp_employee DECIMAL(5, 2) DEFAULT 1,
    
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Attendance
CREATE TABLE attendance (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    employee_id UUID REFERENCES employees(id),
    date DATE NOT NULL,
    
    -- Clock in/out
    clock_in TIMESTAMPTZ,
    clock_out TIMESTAMPTZ,
    clock_in_location POINT,
    clock_out_location POINT,
    
    -- Work hours
    work_hours DECIMAL(5, 2),
    overtime_hours DECIMAL(5, 2) DEFAULT 0,
    
    -- Status
    status VARCHAR(20) DEFAULT 'present',  -- 'present', 'absent', 'late', 'half_day', 'leave', 'holiday'
    late_minutes INTEGER DEFAULT 0,
    early_leave_minutes INTEGER DEFAULT 0,
    
    notes TEXT,
    
    UNIQUE(employee_id, date)
);

-- Leave Requests
CREATE TABLE leave_requests (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    employee_id UUID REFERENCES employees(id),
    leave_type VARCHAR(50) NOT NULL,  -- 'annual', 'sick', 'maternity', 'unpaid', 'emergency'
    
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    total_days DECIMAL(5, 2) NOT NULL,
    
    reason TEXT,
    attachment_url TEXT,
    
    -- Approval
    status VARCHAR(20) DEFAULT 'pending',  -- 'pending', 'approved', 'rejected', 'cancelled'
    approved_by UUID REFERENCES employees(id),
    approved_at TIMESTAMPTZ,
    rejection_reason TEXT,
    
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Payroll
CREATE TABLE payroll_runs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    company_id UUID REFERENCES companies(id),
    period_month INTEGER NOT NULL,
    period_year INTEGER NOT NULL,
    
    -- Status
    status VARCHAR(20) DEFAULT 'draft',  -- 'draft', 'calculated', 'approved', 'paid'
    
    -- Totals
    total_gross DECIMAL(15, 2),
    total_deductions DECIMAL(15, 2),
    total_net DECIMAL(15, 2),
    employee_count INTEGER,
    
    calculated_at TIMESTAMPTZ,
    approved_by UUID REFERENCES users(id),
    approved_at TIMESTAMPTZ,
    paid_at TIMESTAMPTZ,
    
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE payroll_items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    payroll_run_id UUID REFERENCES payroll_runs(id),
    employee_id UUID REFERENCES employees(id),
    
    -- Days worked
    work_days INTEGER,
    present_days INTEGER,
    absent_days INTEGER,
    late_days INTEGER,
    leave_days INTEGER,
    
    -- Earnings
    base_salary DECIMAL(15, 2),
    transport_allowance DECIMAL(15, 2),
    meal_allowance DECIMAL(15, 2),
    housing_allowance DECIMAL(15, 2),
    position_allowance DECIMAL(15, 2),
    overtime_pay DECIMAL(15, 2),
    bonus DECIMAL(15, 2),
    other_earnings DECIMAL(15, 2),
    gross_salary DECIMAL(15, 2),
    
    -- Deductions
    absent_deduction DECIMAL(15, 2),
    late_deduction DECIMAL(15, 2),
    bpjs_health DECIMAL(15, 2),
    bpjs_employment DECIMAL(15, 2),
    pph21 DECIMAL(15, 2),          -- Income tax
    loan_deduction DECIMAL(15, 2),
    other_deductions DECIMAL(15, 2),
    total_deductions DECIMAL(15, 2),
    
    -- Net
    net_salary DECIMAL(15, 2),
    
    -- Payment
    bank_name VARCHAR(100),
    bank_account VARCHAR(50),
    
    created_at TIMESTAMPTZ DEFAULT NOW()
);
```

### 3.2 Payroll Calculation

```typescript
// services/payroll.service.ts
export class PayrollService {
  async calculatePayroll(
    companyId: string,
    month: number,
    year: number
  ): Promise<PayrollRun> {
    const employees = await db.employees.findMany({
      where: { companyId, status: 'active' },
      include: { salaryStructure: true, attendance: true },
    });
    
    const payrollRun = await db.payrollRuns.create({
      data: {
        companyId,
        periodMonth: month,
        periodYear: year,
        status: 'draft',
      },
    });
    
    const workDays = this.getWorkDaysInMonth(month, year);
    
    for (const employee of employees) {
      const attendance = await this.getMonthlyAttendance(employee.id, month, year);
      const leaves = await this.getMonthlyLeaves(employee.id, month, year);
      const salary = employee.salaryStructure;
      
      // Calculate days
      const presentDays = attendance.filter(a => a.status === 'present').length;
      const absentDays = workDays - presentDays - leaves.length;
      const lateDays = attendance.filter(a => a.lateMinutes > 15).length;
      const overtimeHours = attendance.reduce((sum, a) => sum + a.overtimeHours, 0);
      
      // Calculate earnings
      const dailyRate = salary.baseSalary / workDays;
      const baseSalary = salary.baseSalary;
      const transportAllowance = salary.transportAllowance;
      const mealAllowance = salary.mealAllowance * presentDays;
      const housingAllowance = salary.housingAllowance;
      const positionAllowance = salary.positionAllowance;
      const overtimePay = this.calculateOvertime(salary.baseSalary, overtimeHours);
      
      const grossSalary = baseSalary + transportAllowance + mealAllowance + 
                         housingAllowance + positionAllowance + overtimePay;
      
      // Calculate deductions
      const absentDeduction = dailyRate * absentDays;
      const lateDeduction = (dailyRate / 8) * lateDays; // 1 hour for each late day
      const bpjsHealth = this.calculateBPJSHealth(grossSalary);
      const bpjsEmployment = this.calculateBPJSEmployment(grossSalary, salary);
      const pph21 = await this.calculatePPH21(employee, grossSalary, month);
      
      const totalDeductions = absentDeduction + lateDeduction + bpjsHealth + 
                             bpjsEmployment + pph21;
      
      const netSalary = grossSalary - totalDeductions;
      
      await db.payrollItems.create({
        data: {
          payrollRunId: payrollRun.id,
          employeeId: employee.id,
          workDays,
          presentDays,
          absentDays,
          lateDays,
          leaveDays: leaves.length,
          baseSalary,
          transportAllowance,
          mealAllowance,
          housingAllowance,
          positionAllowance,
          overtimePay,
          grossSalary,
          absentDeduction,
          lateDeduction,
          bpjsHealth,
          bpjsEmployment,
          pph21,
          totalDeductions,
          netSalary,
          bankName: employee.bankName,
          bankAccount: employee.bankAccountNumber,
        },
      });
    }
    
    // Update totals
    const items = await db.payrollItems.findMany({
      where: { payrollRunId: payrollRun.id },
    });
    
    await db.payrollRuns.update({
      where: { id: payrollRun.id },
      data: {
        status: 'calculated',
        totalGross: items.reduce((sum, i) => sum + i.grossSalary, 0),
        totalDeductions: items.reduce((sum, i) => sum + i.totalDeductions, 0),
        totalNet: items.reduce((sum, i) => sum + i.netSalary, 0),
        employeeCount: items.length,
        calculatedAt: new Date(),
      },
    });
    
    return payrollRun;
  }
  
  private calculateOvertime(baseSalary: number, hours: number): number {
    // Indonesia: 1.5x for first hour, 2x for subsequent hours
    const hourlyRate = baseSalary / 173; // Monthly hours (52 weeks * 40 hours / 12)
    if (hours <= 0) return 0;
    
    const firstHour = Math.min(hours, 1) * hourlyRate * 1.5;
    const additionalHours = Math.max(hours - 1, 0) * hourlyRate * 2;
    
    return Math.round(firstHour + additionalHours);
  }
  
  private calculateBPJSHealth(grossSalary: number): number {
    const maxSalary = 12000000; // Max salary for BPJS calculation
    const baseSalary = Math.min(grossSalary, maxSalary);
    return Math.round(baseSalary * 0.01); // 1% employee contribution
  }
  
  private async calculatePPH21(
    employee: Employee,
    grossSalary: number,
    month: number
  ): Promise<number> {
    // Simplified PPH21 calculation
    const yearlyGross = grossSalary * 12;
    const ptkp = this.getPTKP(employee.maritalStatus);
    const taxableIncome = Math.max(yearlyGross - ptkp, 0);
    
    // Progressive tax rates
    let tax = 0;
    if (taxableIncome <= 60000000) {
      tax = taxableIncome * 0.05;
    } else if (taxableIncome <= 250000000) {
      tax = 3000000 + (taxableIncome - 60000000) * 0.15;
    } else if (taxableIncome <= 500000000) {
      tax = 31500000 + (taxableIncome - 250000000) * 0.25;
    } else {
      tax = 93500000 + (taxableIncome - 500000000) * 0.30;
    }
    
    return Math.round(tax / 12); // Monthly tax
  }
  
  private getPTKP(maritalStatus: string): number {
    // PTKP (Penghasilan Tidak Kena Pajak) 2023
    const ptkpBase = 54000000;
    const married = maritalStatus === 'married' ? 4500000 : 0;
    return ptkpBase + married;
  }
}
```

---

## Part 4: Manufacturing Module

### 4.1 Bill of Materials (BOM)

```sql
-- Products (items that can be manufactured or sold)
CREATE TABLE products (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    company_id UUID REFERENCES companies(id),
    code VARCHAR(50) NOT NULL,
    name VARCHAR(200) NOT NULL,
    type VARCHAR(20) NOT NULL,  -- 'raw_material', 'semi_finished', 'finished_goods', 'consumable'
    uom VARCHAR(20) NOT NULL,
    
    -- Purchasing
    purchase_price DECIMAL(15, 2),
    lead_time_days INTEGER DEFAULT 0,
    
    -- Manufacturing
    can_manufacture BOOLEAN DEFAULT FALSE,
    manufacture_time_hours DECIMAL(10, 2),
    
    -- Inventory
    safety_stock DECIMAL(15, 3) DEFAULT 0,
    reorder_point DECIMAL(15, 3) DEFAULT 0,
    reorder_qty DECIMAL(15, 3) DEFAULT 0,
    
    -- Costing
    costing_method VARCHAR(20) DEFAULT 'average',  -- 'fifo', 'lifo', 'average', 'standard'
    standard_cost DECIMAL(15, 2),
    
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    
    UNIQUE(company_id, code)
);

-- Bill of Materials
CREATE TABLE boms (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    company_id UUID REFERENCES companies(id),
    product_id UUID REFERENCES products(id),  -- Finished product
    bom_number VARCHAR(50) NOT NULL,
    name VARCHAR(200),
    
    -- Output
    output_qty DECIMAL(15, 3) DEFAULT 1,
    output_uom VARCHAR(20),
    
    -- Time
    manufacturing_hours DECIMAL(10, 2),
    setup_hours DECIMAL(10, 2) DEFAULT 0,
    
    -- Cost (calculated)
    material_cost DECIMAL(15, 2),
    labor_cost DECIMAL(15, 2),
    overhead_cost DECIMAL(15, 2),
    total_cost DECIMAL(15, 2),
    
    -- Status
    is_default BOOLEAN DEFAULT FALSE,
    is_active BOOLEAN DEFAULT TRUE,
    version INTEGER DEFAULT 1,
    
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    
    UNIQUE(company_id, bom_number)
);

-- BOM Items (materials required)
CREATE TABLE bom_items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    bom_id UUID REFERENCES boms(id) ON DELETE CASCADE,
    product_id UUID REFERENCES products(id),  -- Material/component
    
    quantity DECIMAL(15, 3) NOT NULL,
    uom VARCHAR(20) NOT NULL,
    
    -- Waste/scrap allowance
    scrap_percent DECIMAL(5, 2) DEFAULT 0,
    
    -- For nested BOMs
    sub_bom_id UUID REFERENCES boms(id),
    
    -- Sequence
    position INTEGER,
    
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_bom_items_bom ON bom_items(bom_id);

-- Work Centers
CREATE TABLE work_centers (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    company_id UUID REFERENCES companies(id),
    code VARCHAR(50) NOT NULL,
    name VARCHAR(200) NOT NULL,
    
    -- Capacity
    capacity_per_hour DECIMAL(10, 2),
    working_hours_per_day DECIMAL(5, 2) DEFAULT 8,
    
    -- Costing
    hourly_rate DECIMAL(15, 2),
    overhead_rate DECIMAL(15, 2),
    
    is_active BOOLEAN DEFAULT TRUE,
    
    UNIQUE(company_id, code)
);

-- Work Orders
CREATE TABLE work_orders (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    company_id UUID REFERENCES companies(id),
    wo_number VARCHAR(50) NOT NULL,
    
    -- Product
    product_id UUID REFERENCES products(id),
    bom_id UUID REFERENCES boms(id),
    quantity DECIMAL(15, 3) NOT NULL,
    uom VARCHAR(20),
    
    -- Scheduling
    planned_start_date TIMESTAMPTZ,
    planned_end_date TIMESTAMPTZ,
    actual_start_date TIMESTAMPTZ,
    actual_end_date TIMESTAMPTZ,
    
    -- Priority
    priority VARCHAR(20) DEFAULT 'normal',  -- 'low', 'normal', 'high', 'urgent'
    
    -- Status
    status VARCHAR(20) DEFAULT 'draft',  -- 'draft', 'confirmed', 'in_progress', 'completed', 'cancelled'
    
    -- Output
    completed_qty DECIMAL(15, 3) DEFAULT 0,
    rejected_qty DECIMAL(15, 3) DEFAULT 0,
    
    -- Costing
    planned_cost DECIMAL(15, 2),
    actual_cost DECIMAL(15, 2),
    
    -- Reference
    sales_order_id UUID,
    
    created_by UUID REFERENCES users(id),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    
    UNIQUE(company_id, wo_number)
);

-- Work Order Operations
CREATE TABLE wo_operations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    work_order_id UUID REFERENCES work_orders(id) ON DELETE CASCADE,
    work_center_id UUID REFERENCES work_centers(id),
    
    sequence INTEGER NOT NULL,
    name VARCHAR(200),
    description TEXT,
    
    -- Time
    setup_time_hours DECIMAL(10, 2),
    run_time_hours DECIMAL(10, 2),
    
    -- Status
    status VARCHAR(20) DEFAULT 'pending',  -- 'pending', 'in_progress', 'completed'
    started_at TIMESTAMPTZ,
    completed_at TIMESTAMPTZ,
    
    -- Actual
    actual_hours DECIMAL(10, 2),
    
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Work Order Materials
CREATE TABLE wo_materials (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    work_order_id UUID REFERENCES work_orders(id) ON DELETE CASCADE,
    product_id UUID REFERENCES products(id),
    
    required_qty DECIMAL(15, 3) NOT NULL,
    issued_qty DECIMAL(15, 3) DEFAULT 0,
    returned_qty DECIMAL(15, 3) DEFAULT 0,
    consumed_qty DECIMAL(15, 3) DEFAULT 0,
    
    uom VARCHAR(20),
    
    created_at TIMESTAMPTZ DEFAULT NOW()
);
```

### 4.2 Material Requirements Planning (MRP)

```typescript
// services/mrp.service.ts
interface MRPRequirement {
  productId: string;
  productCode: string;
  productName: string;
  requiredQty: number;
  availableQty: number;
  shortageQty: number;
  leadTimeDays: number;
  requiredDate: Date;
  orderDate: Date;
  action: 'purchase' | 'manufacture';
}

export class MRPService {
  async runMRP(
    companyId: string,
    planningHorizonDays: number = 30
  ): Promise<MRPRequirement[]> {
    const requirements: MRPRequirement[] = [];
    const endDate = addDays(new Date(), planningHorizonDays);
    
    // Get all pending demands (sales orders, work orders)
    const demands = await this.getDemands(companyId, endDate);
    
    // Get current inventory
    const inventory = await this.getInventoryLevels(companyId);
    
    for (const demand of demands) {
      await this.explodeBOM(demand, inventory, requirements);
    }
    
    // Consolidate and sort requirements
    return this.consolidateRequirements(requirements);
  }
  
  private async explodeBOM(
    demand: Demand,
    inventory: Map<string, number>,
    requirements: MRPRequirement[]
  ): Promise<void> {
    const product = await db.products.findUnique({
      where: { id: demand.productId },
    });
    
    const available = inventory.get(demand.productId) || 0;
    const shortage = Math.max(demand.quantity - available, 0);
    
    if (shortage <= 0) {
      // Sufficient stock
      inventory.set(demand.productId, available - demand.quantity);
      return;
    }
    
    if (product.canManufacture) {
      // Get BOM and explode
      const bom = await db.boms.findFirst({
        where: { productId: demand.productId, isDefault: true, isActive: true },
        include: { items: { include: { product: true } } },
      });
      
      if (bom) {
        requirements.push({
          productId: demand.productId,
          productCode: product.code,
          productName: product.name,
          requiredQty: shortage,
          availableQty: available,
          shortageQty: shortage,
          leadTimeDays: product.manufactureTimeHours / 8,
          requiredDate: demand.requiredDate,
          orderDate: subDays(demand.requiredDate, Math.ceil(product.manufactureTimeHours / 8)),
          action: 'manufacture',
        });
        
        // Explode BOM items
        for (const item of bom.items) {
          const qtyRequired = (item.quantity / bom.outputQty) * shortage;
          const scrapAllowance = qtyRequired * (item.scrapPercent / 100);
          
          await this.explodeBOM(
            {
              productId: item.productId,
              quantity: qtyRequired + scrapAllowance,
              requiredDate: subDays(demand.requiredDate, Math.ceil(product.manufactureTimeHours / 8)),
            },
            inventory,
            requirements
          );
        }
      }
    } else {
      // Raw material - need to purchase
      requirements.push({
        productId: demand.productId,
        productCode: product.code,
        productName: product.name,
        requiredQty: shortage,
        availableQty: available,
        shortageQty: shortage,
        leadTimeDays: product.leadTimeDays,
        requiredDate: demand.requiredDate,
        orderDate: subDays(demand.requiredDate, product.leadTimeDays),
        action: 'purchase',
      });
    }
    
    inventory.set(demand.productId, 0);
  }
  
  async createWorkOrder(
    requirement: MRPRequirement
  ): Promise<WorkOrder> {
    const product = await db.products.findUnique({
      where: { id: requirement.productId },
    });
    
    const bom = await db.boms.findFirst({
      where: { productId: requirement.productId, isDefault: true },
      include: { items: true },
    });
    
    const workOrder = await db.workOrders.create({
      data: {
        companyId: product.companyId,
        woNumber: await this.generateWONumber(product.companyId),
        productId: requirement.productId,
        bomId: bom.id,
        quantity: requirement.requiredQty,
        uom: product.uom,
        plannedStartDate: requirement.orderDate,
        plannedEndDate: requirement.requiredDate,
        status: 'draft',
      },
    });
    
    // Create material requirements
    for (const item of bom.items) {
      const qtyRequired = (item.quantity / bom.outputQty) * requirement.requiredQty;
      
      await db.woMaterials.create({
        data: {
          workOrderId: workOrder.id,
          productId: item.productId,
          requiredQty: qtyRequired,
          uom: item.uom,
        },
      });
    }
    
    return workOrder;
  }
}
```

---

## Part 5: Approval Workflow Engine

### 5.1 Workflow Schema

```sql
-- Workflow Definitions
CREATE TABLE workflows (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    company_id UUID REFERENCES companies(id),
    name VARCHAR(200) NOT NULL,
    document_type VARCHAR(50) NOT NULL,  -- 'purchase_order', 'leave_request', 'expense_claim'
    
    -- Trigger conditions
    conditions JSONB,  -- e.g., { "amount_gte": 10000000 }
    
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Workflow Steps
CREATE TABLE workflow_steps (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    workflow_id UUID REFERENCES workflows(id) ON DELETE CASCADE,
    step_number INTEGER NOT NULL,
    name VARCHAR(100),
    
    -- Approver type
    approver_type VARCHAR(50) NOT NULL,  -- 'user', 'role', 'manager', 'department_head'
    approver_id UUID,  -- user_id or role_id
    
    -- Auto-approval conditions
    auto_approve_conditions JSONB,  -- e.g., { "amount_lt": 1000000 }
    
    -- Escalation
    escalation_hours INTEGER,
    escalate_to_step INTEGER,
    
    UNIQUE(workflow_id, step_number)
);

-- Approval Requests
CREATE TABLE approval_requests (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    workflow_id UUID REFERENCES workflows(id),
    document_type VARCHAR(50) NOT NULL,
    document_id UUID NOT NULL,
    
    -- Current state
    current_step INTEGER DEFAULT 1,
    status VARCHAR(20) DEFAULT 'pending',  -- 'pending', 'approved', 'rejected', 'cancelled'
    
    -- Metadata
    document_data JSONB,  -- Snapshot of document for approval context
    
    requested_by UUID REFERENCES users(id),
    requested_at TIMESTAMPTZ DEFAULT NOW(),
    completed_at TIMESTAMPTZ
);

-- Approval History
CREATE TABLE approval_history (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    request_id UUID REFERENCES approval_requests(id),
    step_number INTEGER NOT NULL,
    
    -- Action
    action VARCHAR(20) NOT NULL,  -- 'approved', 'rejected', 'escalated', 'delegated'
    
    -- Actor
    acted_by UUID REFERENCES users(id),
    acted_at TIMESTAMPTZ DEFAULT NOW(),
    
    comments TEXT,
    
    -- Delegation
    delegated_from UUID REFERENCES users(id)
);
```

### 5.2 Workflow Engine

```typescript
// services/workflow.service.ts
export class WorkflowService {
  async submitForApproval(
    documentType: string,
    documentId: string,
    documentData: Record<string, any>,
    requestedBy: string
  ): Promise<ApprovalRequest> {
    // Find matching workflow
    const workflow = await this.findMatchingWorkflow(documentType, documentData);
    
    if (!workflow) {
      throw new Error('No approval workflow configured for this document');
    }
    
    // Create approval request
    const request = await db.approvalRequests.create({
      data: {
        workflowId: workflow.id,
        documentType,
        documentId,
        documentData,
        requestedBy,
        currentStep: 1,
        status: 'pending',
      },
    });
    
    // Process first step
    await this.processStep(request);
    
    return request;
  }
  
  private async processStep(request: ApprovalRequest): Promise<void> {
    const step = await db.workflowSteps.findFirst({
      where: {
        workflowId: request.workflowId,
        stepNumber: request.currentStep,
      },
    });
    
    if (!step) {
      // All steps completed
      await this.completeApproval(request);
      return;
    }
    
    // Check auto-approve conditions
    if (this.matchesConditions(request.documentData, step.autoApproveConditions)) {
      await this.autoApprove(request, step);
      return;
    }
    
    // Get approvers
    const approvers = await this.getApprovers(step, request);
    
    // Send notifications
    for (const approver of approvers) {
      await this.notificationService.sendApprovalRequest(approver, request, step);
    }
    
    // Set up escalation timer
    if (step.escalationHours) {
      await this.scheduleEscalation(request, step);
    }
  }
  
  async approve(
    requestId: string,
    userId: string,
    comments?: string
  ): Promise<ApprovalRequest> {
    const request = await db.approvalRequests.findUnique({
      where: { id: requestId },
      include: { workflow: { include: { steps: true } } },
    });
    
    // Validate approver
    const step = request.workflow.steps.find(s => s.stepNumber === request.currentStep);
    const canApprove = await this.canUserApprove(userId, step, request);
    
    if (!canApprove) {
      throw new Error('You are not authorized to approve this request');
    }
    
    // Record approval
    await db.approvalHistory.create({
      data: {
        requestId,
        stepNumber: request.currentStep,
        action: 'approved',
        actedBy: userId,
        comments,
      },
    });
    
    // Move to next step
    const nextStep = await db.workflowSteps.findFirst({
      where: {
        workflowId: request.workflowId,
        stepNumber: request.currentStep + 1,
      },
    });
    
    if (nextStep) {
      await db.approvalRequests.update({
        where: { id: requestId },
        data: { currentStep: request.currentStep + 1 },
      });
      
      await this.processStep({ ...request, currentStep: request.currentStep + 1 });
    } else {
      await this.completeApproval(request);
    }
    
    return db.approvalRequests.findUnique({ where: { id: requestId } });
  }
  
  async reject(
    requestId: string,
    userId: string,
    reason: string
  ): Promise<ApprovalRequest> {
    const request = await db.approvalRequests.findUnique({
      where: { id: requestId },
    });
    
    // Record rejection
    await db.approvalHistory.create({
      data: {
        requestId,
        stepNumber: request.currentStep,
        action: 'rejected',
        actedBy: userId,
        comments: reason,
      },
    });
    
    // Update request status
    await db.approvalRequests.update({
      where: { id: requestId },
      data: { 
        status: 'rejected',
        completedAt: new Date(),
      },
    });
    
    // Notify requester
    await this.notificationService.sendRejectionNotice(request, reason);
    
    // Trigger document rejection callback
    await this.triggerDocumentCallback(request, 'rejected');
    
    return db.approvalRequests.findUnique({ where: { id: requestId } });
  }
  
  private async getApprovers(
    step: WorkflowStep,
    request: ApprovalRequest
  ): Promise<User[]> {
    switch (step.approverType) {
      case 'user':
        return [await db.users.findUnique({ where: { id: step.approverId } })];
        
      case 'role':
        return db.users.findMany({
          where: {
            userRoles: { some: { roleId: step.approverId } },
          },
        });
        
      case 'manager':
        const employee = await db.employees.findFirst({
          where: { userId: request.requestedBy },
          include: { manager: { include: { user: true } } },
        });
        return employee?.manager?.user ? [employee.manager.user] : [];
        
      case 'department_head':
        const emp = await db.employees.findFirst({
          where: { userId: request.requestedBy },
          include: { department: { include: { head: { include: { user: true } } } } },
        });
        return emp?.department?.head?.user ? [emp.department.head.user] : [];
        
      default:
        return [];
    }
  }
}
```

---

## Part 6: Audit Trail

### 6.1 Comprehensive Logging

```sql
-- Audit Log
CREATE TABLE audit_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    company_id UUID REFERENCES companies(id),
    
    -- What changed
    table_name VARCHAR(100) NOT NULL,
    record_id UUID NOT NULL,
    action VARCHAR(20) NOT NULL,  -- 'INSERT', 'UPDATE', 'DELETE'
    
    -- Changes
    old_values JSONB,
    new_values JSONB,
    changed_fields TEXT[],
    
    -- Who
    user_id UUID REFERENCES users(id),
    user_name VARCHAR(200),
    user_ip VARCHAR(50),
    user_agent TEXT,
    
    -- When
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_audit_logs_table ON audit_logs(table_name, record_id);
CREATE INDEX idx_audit_logs_user ON audit_logs(user_id);
CREATE INDEX idx_audit_logs_created ON audit_logs(created_at DESC);

-- Generic audit trigger function
CREATE OR REPLACE FUNCTION audit_trigger_func()
RETURNS TRIGGER AS $$
DECLARE
    old_data JSONB;
    new_data JSONB;
    changed TEXT[];
    key TEXT;
BEGIN
    IF TG_OP = 'INSERT' THEN
        new_data := to_jsonb(NEW);
        INSERT INTO audit_logs (table_name, record_id, action, new_values, user_id)
        VALUES (TG_TABLE_NAME, NEW.id, 'INSERT', new_data, current_setting('app.user_id', true)::uuid);
        RETURN NEW;
        
    ELSIF TG_OP = 'UPDATE' THEN
        old_data := to_jsonb(OLD);
        new_data := to_jsonb(NEW);
        
        -- Get changed fields
        FOR key IN SELECT jsonb_object_keys(new_data)
        LOOP
            IF old_data->key IS DISTINCT FROM new_data->key THEN
                changed := array_append(changed, key);
            END IF;
        END LOOP;
        
        IF array_length(changed, 1) > 0 THEN
            INSERT INTO audit_logs (table_name, record_id, action, old_values, new_values, changed_fields, user_id)
            VALUES (TG_TABLE_NAME, NEW.id, 'UPDATE', old_data, new_data, changed, current_setting('app.user_id', true)::uuid);
        END IF;
        RETURN NEW;
        
    ELSIF TG_OP = 'DELETE' THEN
        old_data := to_jsonb(OLD);
        INSERT INTO audit_logs (table_name, record_id, action, old_values, user_id)
        VALUES (TG_TABLE_NAME, OLD.id, 'DELETE', old_data, current_setting('app.user_id', true)::uuid);
        RETURN OLD;
    END IF;
END;
$$ LANGUAGE plpgsql;

-- Apply to critical tables
CREATE TRIGGER audit_journal_entries
AFTER INSERT OR UPDATE OR DELETE ON journal_entries
FOR EACH ROW EXECUTE FUNCTION audit_trigger_func();

CREATE TRIGGER audit_purchase_orders
AFTER INSERT OR UPDATE OR DELETE ON purchase_orders
FOR EACH ROW EXECUTE FUNCTION audit_trigger_func();

CREATE TRIGGER audit_payroll_runs
AFTER INSERT OR UPDATE OR DELETE ON payroll_runs
FOR EACH ROW EXECUTE FUNCTION audit_trigger_func();
```

---

## Part 7: Best Practices Checklist

### ✅ Do This

- ✅ **Audit Trail**: Log all transactions with user, time, and changes
- ✅ **Period Closing**: Implement monthly/yearly close process with validation
- ✅ **Transaction Validation**: Never break double-entry accounting
- ✅ **Approval Workflows**: Multi-level approval for financial transactions
- ✅ **Data Integrity**: Use database constraints and foreign keys
- ✅ **Multi-Currency**: Support from day one with proper exchange rate handling
- ✅ **Soft Deletes**: Never hard delete financial records
- ✅ **Backup & Recovery**: Regular backups with point-in-time recovery

### ❌ Avoid This

- ❌ **Direct Balance Updates**: Always use movements/journal entries
- ❌ **Hard Deletes**: Soft delete or reverse with journal entry
- ❌ **Skipping Validation**: Always validate business rules
- ❌ **Single-Tenant Design**: Build multi-tenant from start
- ❌ **Ignoring Compliance**: Follow local tax and accounting regulations
- ❌ **Manual Calculations**: Automate tax, payroll, depreciation

---

## Related Skills

- `@crm-developer` - Customer relationship management
- `@pos-developer` - Point of sale integration
- `@inventory-management-developer` - Advanced inventory
- `@bi-dashboard-developer` - Business intelligence & reporting

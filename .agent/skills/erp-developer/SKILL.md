---
name: erp-developer
description: "Expert in Enterprise Resource Planning (ERP) development including business logic, accounting modules, and system integration"
---

# ERP Developer

## Overview

This skill transforms you into a **production-grade ERP specialist**. Beyond basic CRUD operations, you'll implement complete enterprise systems with proper accounting logic, inventory valuation, procurement workflows, HRIS modules, and multi-entity support used in real-world businesses.

## When to Use This Skill

- Use when building or customizing ERP systems
- Use when implementing accounting/financial modules
- Use when designing procurement and inventory workflows
- Use when building HRIS and payroll systems
- Use when integrating multiple business departments
- Use when designing multi-tenant enterprise applications

---

## Part 1: ERP Architecture

### 1.1 System Architecture

```text
ERP PLATFORM ARCHITECTURE
┌─────────────────────────────────────────────────────────────────────────┐
│                           PRESENTATION LAYER                            │
├──────────────────┬───────────────────┬─────────────────────────────────┤
│   Web Portal     │   Mobile Apps     │      External Integrations      │
│   (Admin/Users)  │   (Field Staff)   │      (Banks, E-commerce, etc)   │
└──────────────────┴───────────────────┴─────────────────────────────────┘
                               │
┌─────────────────────────────────────────────────────────────────────────┐
│                          API GATEWAY                                     │
│     (Authentication, Authorization, Rate Limiting, Audit Logging)       │
└─────────────────────────────────────────────────────────────────────────┘
                               │
┌─────────────────────────────────────────────────────────────────────────┐
│                        CORE ERP MODULES                                  │
├─────────────┬─────────────┬─────────────┬─────────────┬────────────────┤
│  Accounting │  Inventory  │ Procurement │    Sales    │      HRIS      │
│   (GL, AR,  │  (WMS, Stock│  (PO, RFQ,  │  (Quotes,   │  (Employees,   │
│   AP, Tax)  │  Valuation) │  Vendors)   │  Invoices)  │   Payroll)     │
├─────────────┴─────────────┴─────────────┴─────────────┴────────────────┤
│                         SHARED SERVICES                                  │
├─────────────┬─────────────┬─────────────┬─────────────┬────────────────┤
│  Workflow   │  Reporting  │  Document   │    Audit    │  Notification  │
│  Engine     │  Engine     │  Management │    Trail    │    Service     │
└─────────────┴─────────────┴─────────────┴─────────────┴────────────────┘
                               │
┌─────────────────────────────────────────────────────────────────────────┐
│                          DATA LAYER                                      │
├──────────────────┬───────────────────┬─────────────────────────────────┤
│   PostgreSQL     │    TimescaleDB    │       Object Storage            │
│   (Core Data)    │   (Time Series)   │      (Documents, Attachments)   │
└──────────────────┴───────────────────┴─────────────────────────────────┘
```

### 1.2 Core Database Schema

```sql
-- ============================================
-- MULTI-COMPANY/ENTITY SUPPORT
-- ============================================

CREATE TABLE companies (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    code VARCHAR(10) UNIQUE NOT NULL,
    name VARCHAR(255) NOT NULL,
    legal_name VARCHAR(255),
    tax_id VARCHAR(50),
    
    -- Defaults
    base_currency CHAR(3) DEFAULT 'IDR',
    fiscal_year_start INTEGER DEFAULT 1, -- Month (1-12)
    
    -- Address
    address TEXT,
    city VARCHAR(100),
    country_code CHAR(2),
    
    -- Settings
    settings JSONB DEFAULT '{}',
    
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================
-- CHART OF ACCOUNTS
-- ============================================

CREATE TABLE account_types (
    id VARCHAR(20) PRIMARY KEY, -- asset, liability, equity, revenue, expense
    name VARCHAR(100) NOT NULL,
    normal_balance VARCHAR(10) NOT NULL, -- debit, credit
    report_type VARCHAR(20) NOT NULL -- balance_sheet, income_statement
);

INSERT INTO account_types VALUES
    ('asset', 'Asset', 'debit', 'balance_sheet'),
    ('liability', 'Liability', 'credit', 'balance_sheet'),
    ('equity', 'Equity', 'credit', 'balance_sheet'),
    ('revenue', 'Revenue', 'credit', 'income_statement'),
    ('expense', 'Expense', 'debit', 'income_statement');

CREATE TABLE accounts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    company_id UUID NOT NULL REFERENCES companies(id),
    parent_id UUID REFERENCES accounts(id),
    
    code VARCHAR(20) NOT NULL, -- 1-1000, 1-1001
    name VARCHAR(255) NOT NULL,
    account_type_id VARCHAR(20) NOT NULL REFERENCES account_types(id),
    
    -- Classification
    is_header BOOLEAN DEFAULT false, -- Group account (no transactions)
    is_bank_account BOOLEAN DEFAULT false,
    is_reconcilable BOOLEAN DEFAULT true,
    
    -- Tax
    default_tax_id UUID REFERENCES taxes(id),
    
    -- Status
    is_active BOOLEAN DEFAULT true,
    
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    
    UNIQUE(company_id, code)
);

-- ============================================
-- GENERAL LEDGER
-- ============================================

CREATE TABLE fiscal_periods (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    company_id UUID NOT NULL REFERENCES companies(id),
    name VARCHAR(50) NOT NULL, -- "January 2024"
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    is_closed BOOLEAN DEFAULT false,
    closed_at TIMESTAMPTZ,
    closed_by UUID REFERENCES users(id),
    
    UNIQUE(company_id, start_date)
);

CREATE TABLE journal_entries (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    company_id UUID NOT NULL REFERENCES companies(id),
    
    -- Reference
    number VARCHAR(50) NOT NULL, -- JV-2024-00001
    reference VARCHAR(255),
    source_type VARCHAR(50), -- manual, invoice, payment, inventory
    source_id UUID,
    
    -- Dates
    entry_date DATE NOT NULL,
    period_id UUID NOT NULL REFERENCES fiscal_periods(id),
    
    -- Details
    description TEXT,
    
    -- Status
    status VARCHAR(20) DEFAULT 'draft', -- draft, posted, reversed
    posted_at TIMESTAMPTZ,
    posted_by UUID REFERENCES users(id),
    
    -- Reversal
    is_reversal BOOLEAN DEFAULT false,
    reversed_entry_id UUID REFERENCES journal_entries(id),
    
    created_at TIMESTAMPTZ DEFAULT NOW(),
    created_by UUID REFERENCES users(id),
    
    UNIQUE(company_id, number)
);

CREATE TABLE journal_lines (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    entry_id UUID NOT NULL REFERENCES journal_entries(id) ON DELETE CASCADE,
    account_id UUID NOT NULL REFERENCES accounts(id),
    
    -- Amounts
    debit DECIMAL(18, 2) DEFAULT 0,
    credit DECIMAL(18, 2) DEFAULT 0,
    
    -- Multi-currency
    currency_code CHAR(3),
    exchange_rate DECIMAL(18, 6) DEFAULT 1,
    debit_foreign DECIMAL(18, 2) DEFAULT 0,
    credit_foreign DECIMAL(18, 2) DEFAULT 0,
    
    -- Description
    description TEXT,
    
    -- Dimensions (for reporting)
    cost_center_id UUID,
    project_id UUID,
    
    -- Partner
    partner_id UUID REFERENCES partners(id),
    
    -- Reconciliation
    is_reconciled BOOLEAN DEFAULT false,
    reconciliation_id UUID,
    
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Ensure balanced entries
CREATE OR REPLACE FUNCTION check_journal_balance()
RETURNS TRIGGER AS $$
DECLARE
    total_debit DECIMAL(18, 2);
    total_credit DECIMAL(18, 2);
BEGIN
    SELECT COALESCE(SUM(debit), 0), COALESCE(SUM(credit), 0)
    INTO total_debit, total_credit
    FROM journal_lines
    WHERE entry_id = NEW.id;
    
    IF total_debit != total_credit THEN
        RAISE EXCEPTION 'Journal entry is not balanced. Debit: %, Credit: %',
            total_debit, total_credit;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- ACCOUNTS RECEIVABLE / PAYABLE
-- ============================================

CREATE TABLE partners (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    company_id UUID NOT NULL REFERENCES companies(id),
    
    -- Type
    is_customer BOOLEAN DEFAULT false,
    is_vendor BOOLEAN DEFAULT false,
    
    -- Identity
    code VARCHAR(20),
    name VARCHAR(255) NOT NULL,
    legal_name VARCHAR(255),
    tax_id VARCHAR(50),
    
    -- Contact
    email VARCHAR(255),
    phone VARCHAR(50),
    
    -- Address
    address TEXT,
    city VARCHAR(100),
    postal_code VARCHAR(20),
    country_code CHAR(2),
    
    -- Accounting
    receivable_account_id UUID REFERENCES accounts(id),
    payable_account_id UUID REFERENCES accounts(id),
    
    -- Terms
    payment_term_days INTEGER DEFAULT 30,
    credit_limit DECIMAL(18, 2),
    
    -- Banking
    bank_name VARCHAR(255),
    bank_account VARCHAR(50),
    
    -- Status
    is_active BOOLEAN DEFAULT true,
    
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE invoices (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    company_id UUID NOT NULL REFERENCES companies(id),
    partner_id UUID NOT NULL REFERENCES partners(id),
    
    -- Type
    type VARCHAR(20) NOT NULL, -- customer_invoice, vendor_bill, credit_note, debit_note
    
    -- Reference
    number VARCHAR(50) NOT NULL,
    reference VARCHAR(255),
    
    -- Dates
    invoice_date DATE NOT NULL,
    due_date DATE NOT NULL,
    period_id UUID NOT NULL REFERENCES fiscal_periods(id),
    
    -- Currency
    currency_code CHAR(3) NOT NULL,
    exchange_rate DECIMAL(18, 6) DEFAULT 1,
    
    -- Amounts
    subtotal DECIMAL(18, 2) NOT NULL,
    discount_amount DECIMAL(18, 2) DEFAULT 0,
    tax_amount DECIMAL(18, 2) DEFAULT 0,
    total DECIMAL(18, 2) NOT NULL,
    
    -- Payments
    amount_paid DECIMAL(18, 2) DEFAULT 0,
    amount_due DECIMAL(18, 2) GENERATED ALWAYS AS (total - amount_paid) STORED,
    
    -- Status
    status VARCHAR(20) DEFAULT 'draft', -- draft, posted, paid, partial, cancelled
    
    -- Journal
    journal_entry_id UUID REFERENCES journal_entries(id),
    
    -- Notes
    notes TEXT,
    internal_notes TEXT,
    
    created_at TIMESTAMPTZ DEFAULT NOW(),
    created_by UUID REFERENCES users(id),
    posted_at TIMESTAMPTZ,
    
    UNIQUE(company_id, type, number)
);

CREATE TABLE invoice_lines (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    invoice_id UUID NOT NULL REFERENCES invoices(id) ON DELETE CASCADE,
    
    -- Item
    product_id UUID REFERENCES products(id),
    description TEXT NOT NULL,
    
    -- Quantity
    quantity DECIMAL(18, 4) NOT NULL,
    unit_price DECIMAL(18, 4) NOT NULL,
    discount_percent DECIMAL(5, 2) DEFAULT 0,
    
    -- Account
    account_id UUID NOT NULL REFERENCES accounts(id),
    
    -- Tax
    tax_id UUID REFERENCES taxes(id),
    tax_amount DECIMAL(18, 2) DEFAULT 0,
    
    -- Total
    subtotal DECIMAL(18, 2) NOT NULL,
    total DECIMAL(18, 2) NOT NULL,
    
    -- Dimensions
    cost_center_id UUID,
    project_id UUID
);

-- ============================================
-- INVENTORY
-- ============================================

CREATE TABLE warehouses (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    company_id UUID NOT NULL REFERENCES companies(id),
    code VARCHAR(10) NOT NULL,
    name VARCHAR(255) NOT NULL,
    address TEXT,
    is_active BOOLEAN DEFAULT true,
    
    UNIQUE(company_id, code)
);

CREATE TABLE products (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    company_id UUID NOT NULL REFERENCES companies(id),
    
    -- Identity
    code VARCHAR(50) NOT NULL,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    
    -- Type
    type VARCHAR(20) DEFAULT 'stockable', -- stockable, consumable, service
    
    -- Category
    category_id UUID REFERENCES product_categories(id),
    
    -- Units
    uom_id UUID REFERENCES units_of_measure(id),
    purchase_uom_id UUID REFERENCES units_of_measure(id),
    
    -- Costing
    costing_method VARCHAR(20) DEFAULT 'average', -- fifo, lifo, average, standard
    standard_cost DECIMAL(18, 4),
    
    -- Pricing
    sale_price DECIMAL(18, 4),
    purchase_price DECIMAL(18, 4),
    
    -- Accounts
    income_account_id UUID REFERENCES accounts(id),
    expense_account_id UUID REFERENCES accounts(id),
    asset_account_id UUID REFERENCES accounts(id), -- Inventory account
    
    -- Tax
    sale_tax_id UUID REFERENCES taxes(id),
    purchase_tax_id UUID REFERENCES taxes(id),
    
    -- Inventory
    track_inventory BOOLEAN DEFAULT true,
    reorder_point DECIMAL(18, 4),
    reorder_quantity DECIMAL(18, 4),
    
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    
    UNIQUE(company_id, code)
);

CREATE TABLE stock_moves (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    company_id UUID NOT NULL REFERENCES companies(id),
    
    -- Reference
    reference VARCHAR(255),
    source_type VARCHAR(50), -- purchase, sale, transfer, adjustment
    source_id UUID,
    
    -- Product
    product_id UUID NOT NULL REFERENCES products(id),
    
    -- Locations
    from_warehouse_id UUID REFERENCES warehouses(id),
    to_warehouse_id UUID REFERENCES warehouses(id),
    
    -- Quantity
    quantity DECIMAL(18, 4) NOT NULL,
    uom_id UUID REFERENCES units_of_measure(id),
    
    -- Costing
    unit_cost DECIMAL(18, 4),
    total_cost DECIMAL(18, 4),
    
    -- Status
    status VARCHAR(20) DEFAULT 'draft', -- draft, confirmed, done, cancelled
    
    -- Dates
    scheduled_date TIMESTAMPTZ,
    done_date TIMESTAMPTZ,
    
    -- Journal
    journal_entry_id UUID REFERENCES journal_entries(id),
    
    created_at TIMESTAMPTZ DEFAULT NOW(),
    created_by UUID REFERENCES users(id)
);

CREATE TABLE stock_quantities (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    product_id UUID NOT NULL REFERENCES products(id),
    warehouse_id UUID NOT NULL REFERENCES warehouses(id),
    
    quantity_on_hand DECIMAL(18, 4) DEFAULT 0,
    quantity_reserved DECIMAL(18, 4) DEFAULT 0,
    quantity_available DECIMAL(18, 4) 
        GENERATED ALWAYS AS (quantity_on_hand - quantity_reserved) STORED,
    
    -- Costing
    average_cost DECIMAL(18, 4) DEFAULT 0,
    total_value DECIMAL(18, 2) DEFAULT 0,
    
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    
    UNIQUE(product_id, warehouse_id)
);
```

---

## Part 2: Accounting Module

### 2.1 Chart of Accounts Service

```typescript
// services/accounting/chart-of-accounts.service.ts
export class ChartOfAccountsService {
  constructor(
    private readonly db: Database,
    private readonly logger: Logger,
  ) {}

  async getAccountTree(companyId: string): Promise<AccountNode[]> {
    const accounts = await this.db
      .selectFrom('accounts')
      .where('company_id', '=', companyId)
      .where('is_active', '=', true)
      .orderBy('code')
      .selectAll()
      .execute();

    return this.buildTree(accounts);
  }

  async getTrialBalance(
    companyId: string,
    periodId: string,
  ): Promise<TrialBalanceReport> {
    const result = await this.db
      .selectFrom('accounts as a')
      .leftJoin('journal_lines as jl', 'a.id', 'jl.account_id')
      .leftJoin('journal_entries as je', 'jl.entry_id', 'je.id')
      .where('a.company_id', '=', companyId)
      .where('a.is_header', '=', false)
      .where((eb) =>
        eb.or([
          eb('je.period_id', '=', periodId),
          eb('je.id', 'is', null),
        ]),
      )
      .where((eb) =>
        eb.or([
          eb('je.status', '=', 'posted'),
          eb('je.id', 'is', null),
        ]),
      )
      .groupBy(['a.id', 'a.code', 'a.name', 'a.account_type_id'])
      .select([
        'a.id',
        'a.code',
        'a.name',
        'a.account_type_id as accountType',
        sql`COALESCE(SUM(jl.debit), 0)`.as('totalDebit'),
        sql`COALESCE(SUM(jl.credit), 0)`.as('totalCredit'),
        sql`COALESCE(SUM(jl.debit), 0) - COALESCE(SUM(jl.credit), 0)`.as('balance'),
      ])
      .orderBy('a.code')
      .execute();

    const totals = result.reduce(
      (acc, row) => ({
        debit: acc.debit + Number(row.totalDebit),
        credit: acc.credit + Number(row.totalCredit),
      }),
      { debit: 0, credit: 0 },
    );

    return {
      accounts: result,
      totals,
      isBalanced: totals.debit === totals.credit,
    };
  }

  async getAccountBalance(
    accountId: string,
    asOfDate: Date,
  ): Promise<AccountBalance> {
    const [result] = await this.db
      .selectFrom('journal_lines as jl')
      .innerJoin('journal_entries as je', 'jl.entry_id', 'je.id')
      .where('jl.account_id', '=', accountId)
      .where('je.status', '=', 'posted')
      .where('je.entry_date', '<=', asOfDate)
      .select([
        sql`COALESCE(SUM(jl.debit), 0)`.as('totalDebit'),
        sql`COALESCE(SUM(jl.credit), 0)`.as('totalCredit'),
      ])
      .execute();

    const account = await this.getAccount(accountId);
    const accountType = await this.getAccountType(account.accountTypeId);

    const balance =
      accountType.normalBalance === 'debit'
        ? Number(result.totalDebit) - Number(result.totalCredit)
        : Number(result.totalCredit) - Number(result.totalDebit);

    return {
      accountId,
      asOfDate,
      debit: Number(result.totalDebit),
      credit: Number(result.totalCredit),
      balance,
    };
  }
}
```

### 2.2 Journal Entry Service

```typescript
// services/accounting/journal.service.ts
export class JournalService {
  constructor(
    private readonly db: Database,
    private readonly periodService: FiscalPeriodService,
    private readonly eventBus: EventBus,
    private readonly logger: Logger,
  ) {}

  async createJournalEntry(data: CreateJournalEntryDto): Promise<Result<JournalEntry>> {
    return this.db.transaction(async (trx) => {
      // Validate period is open
      const period = await this.periodService.getPeriodForDate(
        data.companyId,
        data.entryDate,
      );

      if (!period) {
        return Result.failure(new ValidationError('No open fiscal period for this date'));
      }

      if (period.isClosed) {
        return Result.failure(new ValidationError('Fiscal period is closed'));
      }

      // Validate balanced
      const totalDebit = data.lines.reduce((sum, l) => sum + (l.debit || 0), 0);
      const totalCredit = data.lines.reduce((sum, l) => sum + (l.credit || 0), 0);

      if (Math.abs(totalDebit - totalCredit) > 0.001) {
        return Result.failure(
          new ValidationError(
            `Journal entry is not balanced. Debit: ${totalDebit}, Credit: ${totalCredit}`,
          ),
        );
      }

      // Generate number
      const number = await this.generateNumber(data.companyId, trx);

      // Create entry
      const [entry] = await trx
        .insertInto('journal_entries')
        .values({
          companyId: data.companyId,
          number,
          reference: data.reference,
          sourceType: data.sourceType,
          sourceId: data.sourceId,
          entryDate: data.entryDate,
          periodId: period.id,
          description: data.description,
          status: 'draft',
          createdBy: data.userId,
        })
        .returning('*')
        .execute();

      // Create lines
      for (const line of data.lines) {
        await trx
          .insertInto('journal_lines')
          .values({
            entryId: entry.id,
            accountId: line.accountId,
            debit: line.debit || 0,
            credit: line.credit || 0,
            currencyCode: line.currencyCode,
            exchangeRate: line.exchangeRate || 1,
            debitForeign: line.debitForeign || 0,
            creditForeign: line.creditForeign || 0,
            description: line.description,
            costCenterId: line.costCenterId,
            projectId: line.projectId,
            partnerId: line.partnerId,
          })
          .execute();
      }

      return Result.success(entry);
    });
  }

  async postJournalEntry(entryId: string, userId: string): Promise<Result<void>> {
    return this.db.transaction(async (trx) => {
      const entry = await trx
        .selectFrom('journal_entries')
        .where('id', '=', entryId)
        .forUpdate()
        .selectAll()
        .executeTakeFirst();

      if (!entry) {
        return Result.failure(new NotFoundError('Journal entry not found'));
      }

      if (entry.status !== 'draft') {
        return Result.failure(new ValidationError('Only draft entries can be posted'));
      }

      // Verify period is still open
      const period = await this.periodService.getPeriod(entry.periodId);
      if (period.isClosed) {
        return Result.failure(new ValidationError('Cannot post to closed period'));
      }

      // Verify balance
      const [balance] = await trx
        .selectFrom('journal_lines')
        .where('entry_id', '=', entryId)
        .select([
          sql`SUM(debit)`.as('totalDebit'),
          sql`SUM(credit)`.as('totalCredit'),
        ])
        .execute();

      if (Math.abs(Number(balance.totalDebit) - Number(balance.totalCredit)) > 0.001) {
        return Result.failure(new ValidationError('Journal entry is not balanced'));
      }

      // Post entry
      await trx
        .updateTable('journal_entries')
        .set({
          status: 'posted',
          postedAt: new Date(),
          postedBy: userId,
        })
        .where('id', '=', entryId)
        .execute();

      // Update account balances (if using materialized view)
      await this.updateAccountBalances(entryId, trx);

      this.eventBus.publish('journal.posted', { entryId });

      return Result.success(undefined);
    });
  }

  async reverseJournalEntry(
    entryId: string,
    reversalDate: Date,
    userId: string,
  ): Promise<Result<JournalEntry>> {
    return this.db.transaction(async (trx) => {
      const entry = await trx
        .selectFrom('journal_entries')
        .where('id', '=', entryId)
        .selectAll()
        .executeTakeFirst();

      if (!entry) {
        return Result.failure(new NotFoundError('Journal entry not found'));
      }

      if (entry.status !== 'posted') {
        return Result.failure(new ValidationError('Only posted entries can be reversed'));
      }

      // Get original lines
      const lines = await trx
        .selectFrom('journal_lines')
        .where('entry_id', '=', entryId)
        .selectAll()
        .execute();

      // Create reversal entry with swapped debits/credits
      const reversalData: CreateJournalEntryDto = {
        companyId: entry.companyId,
        entryDate: reversalDate,
        description: `Reversal of ${entry.number}`,
        reference: entry.number,
        sourceType: 'reversal',
        sourceId: entryId,
        userId,
        lines: lines.map((l) => ({
          accountId: l.accountId,
          debit: l.credit, // Swap
          credit: l.debit, // Swap
          description: l.description,
          partnerId: l.partnerId,
        })),
      };

      const reversalResult = await this.createJournalEntry(reversalData);
      
      if (reversalResult.isFailure) {
        return reversalResult;
      }

      const reversalEntry = reversalResult.data!;

      // Post reversal immediately
      await this.postJournalEntry(reversalEntry.id, userId);

      // Mark original as reversed
      await trx
        .updateTable('journal_entries')
        .set({
          status: 'reversed',
          reversedEntryId: reversalEntry.id,
        })
        .where('id', '=', entryId)
        .execute();

      // Mark reversal entry
      await trx
        .updateTable('journal_entries')
        .set({ isReversal: true })
        .where('id', '=', reversalEntry.id)
        .execute();

      return Result.success(reversalEntry);
    });
  }
}
```

### 2.3 Invoice Service with Auto-Posting

```typescript
// services/accounting/invoice.service.ts
export class InvoiceService {
  constructor(
    private readonly db: Database,
    private readonly journalService: JournalService,
    private readonly taxService: TaxService,
    private readonly sequenceService: SequenceService,
    private readonly eventBus: EventBus,
    private readonly logger: Logger,
  ) {}

  async createInvoice(data: CreateInvoiceDto): Promise<Result<Invoice>> {
    return this.db.transaction(async (trx) => {
      // Calculate line totals
      const calculatedLines = await this.calculateLines(data.lines, trx);
      
      // Calculate totals
      const subtotal = calculatedLines.reduce((sum, l) => sum + l.subtotal, 0);
      const discountAmount = calculatedLines.reduce((sum, l) => sum + l.discountAmount, 0);
      const taxAmount = calculatedLines.reduce((sum, l) => sum + l.taxAmount, 0);
      const total = subtotal - discountAmount + taxAmount;

      // Calculate due date
      const partner = await this.getPartner(data.partnerId);
      const dueDate = addDays(data.invoiceDate, partner.paymentTermDays || 30);

      // Generate number
      const number = await this.sequenceService.getNext(
        data.companyId,
        `invoice_${data.type}`,
        trx,
      );

      // Get period
      const period = await this.periodService.getPeriodForDate(
        data.companyId,
        data.invoiceDate,
      );

      // Create invoice
      const [invoice] = await trx
        .insertInto('invoices')
        .values({
          companyId: data.companyId,
          partnerId: data.partnerId,
          type: data.type,
          number,
          reference: data.reference,
          invoiceDate: data.invoiceDate,
          dueDate,
          periodId: period.id,
          currencyCode: data.currencyCode,
          exchangeRate: data.exchangeRate || 1,
          subtotal,
          discountAmount,
          taxAmount,
          total,
          status: 'draft',
          notes: data.notes,
          createdBy: data.userId,
        })
        .returning('*')
        .execute();

      // Create lines
      for (const line of calculatedLines) {
        await trx
          .insertInto('invoice_lines')
          .values({
            invoiceId: invoice.id,
            productId: line.productId,
            description: line.description,
            quantity: line.quantity,
            unitPrice: line.unitPrice,
            discountPercent: line.discountPercent,
            accountId: line.accountId,
            taxId: line.taxId,
            taxAmount: line.taxAmount,
            subtotal: line.subtotal,
            total: line.total,
          })
          .execute();
      }

      return Result.success({ ...invoice, lines: calculatedLines });
    });
  }

  async postInvoice(invoiceId: string, userId: string): Promise<Result<Invoice>> {
    return this.db.transaction(async (trx) => {
      const invoice = await trx
        .selectFrom('invoices')
        .where('id', '=', invoiceId)
        .forUpdate()
        .selectAll()
        .executeTakeFirst();

      if (!invoice) {
        return Result.failure(new NotFoundError('Invoice not found'));
      }

      if (invoice.status !== 'draft') {
        return Result.failure(new ValidationError('Invoice is already posted'));
      }

      const lines = await trx
        .selectFrom('invoice_lines')
        .where('invoice_id', '=', invoiceId)
        .selectAll()
        .execute();

      // Build journal entry
      const partner = await this.getPartner(invoice.partnerId);
      const journalLines: JournalLineDto[] = [];

      // Customer/Vendor account (receivable/payable)
      const isReceivable = ['customer_invoice', 'credit_note'].includes(invoice.type);
      const partnerAccountId = isReceivable
        ? partner.receivableAccountId
        : partner.payableAccountId;

      journalLines.push({
        accountId: partnerAccountId,
        debit: isReceivable ? invoice.total : 0,
        credit: isReceivable ? 0 : invoice.total,
        partnerId: partner.id,
        description: `${invoice.type} ${invoice.number}`,
      });

      // Revenue/Expense lines
      for (const line of lines) {
        journalLines.push({
          accountId: line.accountId,
          debit: isReceivable ? 0 : line.subtotal,
          credit: isReceivable ? line.subtotal : 0,
          description: line.description,
        });

        // Tax line
        if (line.taxAmount > 0) {
          const tax = await this.taxService.getTax(line.taxId!);
          journalLines.push({
            accountId: tax.accountId,
            debit: isReceivable ? 0 : line.taxAmount,
            credit: isReceivable ? line.taxAmount : 0,
            description: `Tax on ${line.description}`,
          });
        }
      }

      // Create and post journal entry
      const journalResult = await this.journalService.createJournalEntry({
        companyId: invoice.companyId,
        entryDate: invoice.invoiceDate,
        description: `${invoice.type} ${invoice.number}`,
        sourceType: 'invoice',
        sourceId: invoiceId,
        userId,
        lines: journalLines,
      });

      if (journalResult.isFailure) {
        return journalResult as Result<Invoice>;
      }

      await this.journalService.postJournalEntry(journalResult.data!.id, userId);

      // Update invoice
      await trx
        .updateTable('invoices')
        .set({
          status: 'posted',
          journalEntryId: journalResult.data!.id,
          postedAt: new Date(),
        })
        .where('id', '=', invoiceId)
        .execute();

      this.eventBus.publish('invoice.posted', { invoiceId });

      return Result.success({ ...invoice, status: 'posted' });
    });
  }

  async recordPayment(
    invoiceId: string,
    payment: PaymentDto,
  ): Promise<Result<Payment>> {
    return this.db.transaction(async (trx) => {
      const invoice = await trx
        .selectFrom('invoices')
        .where('id', '=', invoiceId)
        .forUpdate()
        .selectAll()
        .executeTakeFirst();

      if (!invoice || invoice.status === 'draft') {
        return Result.failure(new ValidationError('Invalid invoice'));
      }

      if (payment.amount > invoice.amountDue) {
        return Result.failure(
          new ValidationError(`Payment amount exceeds amount due (${invoice.amountDue})`),
        );
      }

      // Get partner
      const partner = await this.getPartner(invoice.partnerId);
      const isReceivable = ['customer_invoice', 'credit_note'].includes(invoice.type);

      // Create payment journal entry
      const journalLines: JournalLineDto[] = [
        // Debit bank, Credit receivable (for customer payment)
        // Debit payable, Credit bank (for vendor payment)
        {
          accountId: payment.bankAccountId,
          debit: isReceivable ? payment.amount : 0,
          credit: isReceivable ? 0 : payment.amount,
          description: `Payment for ${invoice.number}`,
        },
        {
          accountId: isReceivable ? partner.receivableAccountId : partner.payableAccountId,
          debit: isReceivable ? 0 : payment.amount,
          credit: isReceivable ? payment.amount : 0,
          partnerId: partner.id,
          description: `Payment for ${invoice.number}`,
        },
      ];

      const journalResult = await this.journalService.createJournalEntry({
        companyId: invoice.companyId,
        entryDate: payment.paymentDate,
        description: `Payment for ${invoice.number}`,
        sourceType: 'payment',
        userId: payment.userId,
        lines: journalLines,
      });

      if (journalResult.isFailure) {
        return journalResult as Result<Payment>;
      }

      await this.journalService.postJournalEntry(journalResult.data!.id, payment.userId);

      // Update invoice
      const newAmountPaid = Number(invoice.amountPaid) + payment.amount;
      const newStatus = newAmountPaid >= invoice.total ? 'paid' : 'partial';

      await trx
        .updateTable('invoices')
        .set({
          amountPaid: newAmountPaid,
          status: newStatus,
        })
        .where('id', '=', invoiceId)
        .execute();

      // Reconcile lines
      await this.reconcileInvoicePayment(invoice, payment, journalResult.data!, trx);

      this.eventBus.publish('payment.recorded', { invoiceId, amount: payment.amount });

      return Result.success({
        id: journalResult.data!.id,
        amount: payment.amount,
        invoiceId,
      });
    });
  }
}
```

---

## Part 3: Inventory Module

### 3.1 Stock Service with Costing

```typescript
// services/inventory/stock.service.ts
export class StockService {
  constructor(
    private readonly db: Database,
    private readonly journalService: JournalService,
    private readonly logger: Logger,
  ) {}

  async processStockMove(moveId: string, userId: string): Promise<Result<void>> {
    return this.db.transaction(async (trx) => {
      const move = await trx
        .selectFrom('stock_moves')
        .where('id', '=', moveId)
        .forUpdate()
        .selectAll()
        .executeTakeFirst();

      if (!move || move.status !== 'confirmed') {
        return Result.failure(new ValidationError('Invalid stock move'));
      }

      const product = await this.getProduct(move.productId);

      // Calculate cost based on costing method
      let unitCost: number;
      if (move.fromWarehouseId) {
        // Outgoing - use FIFO/Average cost
        unitCost = await this.calculateOutgoingCost(
          move.productId,
          move.fromWarehouseId,
          move.quantity,
          product.costingMethod,
          trx,
        );
      } else {
        // Incoming - use move's unit cost (from PO or manual)
        unitCost = move.unitCost || 0;
      }

      const totalCost = unitCost * move.quantity;

      // Update stock quantities
      if (move.fromWarehouseId) {
        await this.decrementStock(
          move.productId,
          move.fromWarehouseId,
          move.quantity,
          totalCost,
          trx,
        );
      }

      if (move.toWarehouseId) {
        await this.incrementStock(
          move.productId,
          move.toWarehouseId,
          move.quantity,
          totalCost,
          trx,
        );
      }

      // Create journal entry for stock valuation
      if (product.trackInventory && move.sourceType !== 'transfer') {
        await this.createStockJournalEntry(move, product, totalCost, userId, trx);
      }

      // Update move
      await trx
        .updateTable('stock_moves')
        .set({
          status: 'done',
          unitCost,
          totalCost,
          doneDate: new Date(),
        })
        .where('id', '=', moveId)
        .execute();

      return Result.success(undefined);
    });
  }

  private async calculateOutgoingCost(
    productId: string,
    warehouseId: string,
    quantity: number,
    method: CostingMethod,
    trx: Transaction,
  ): Promise<number> {
    switch (method) {
      case 'average':
        return this.getAverageCost(productId, warehouseId, trx);

      case 'fifo':
        return this.getFIFOCost(productId, warehouseId, quantity, trx);

      case 'lifo':
        return this.getLIFOCost(productId, warehouseId, quantity, trx);

      case 'standard':
        const product = await this.getProduct(productId);
        return product.standardCost || 0;

      default:
        throw new Error(`Unknown costing method: ${method}`);
    }
  }

  private async getAverageCost(
    productId: string,
    warehouseId: string,
    trx: Transaction,
  ): Promise<number> {
    const [stock] = await trx
      .selectFrom('stock_quantities')
      .where('product_id', '=', productId)
      .where('warehouse_id', '=', warehouseId)
      .select(['average_cost'])
      .execute();

    return stock?.averageCost || 0;
  }

  private async incrementStock(
    productId: string,
    warehouseId: string,
    quantity: number,
    totalCost: number,
    trx: Transaction,
  ): Promise<void> {
    const existing = await trx
      .selectFrom('stock_quantities')
      .where('product_id', '=', productId)
      .where('warehouse_id', '=', warehouseId)
      .forUpdate()
      .selectAll()
      .executeTakeFirst();

    if (existing) {
      const newQty = Number(existing.quantityOnHand) + quantity;
      const newValue = Number(existing.totalValue) + totalCost;
      const newAvgCost = newQty > 0 ? newValue / newQty : 0;

      await trx
        .updateTable('stock_quantities')
        .set({
          quantityOnHand: newQty,
          totalValue: newValue,
          averageCost: newAvgCost,
          updatedAt: new Date(),
        })
        .where('id', '=', existing.id)
        .execute();
    } else {
      await trx
        .insertInto('stock_quantities')
        .values({
          productId,
          warehouseId,
          quantityOnHand: quantity,
          quantityReserved: 0,
          averageCost: quantity > 0 ? totalCost / quantity : 0,
          totalValue: totalCost,
        })
        .execute();
    }
  }

  async getStockValuationReport(
    companyId: string,
    warehouseId?: string,
  ): Promise<StockValuationReport> {
    let query = this.db
      .selectFrom('stock_quantities as sq')
      .innerJoin('products as p', 'sq.product_id', 'p.id')
      .innerJoin('warehouses as w', 'sq.warehouse_id', 'w.id')
      .where('p.company_id', '=', companyId)
      .where('sq.quantity_on_hand', '>', 0);

    if (warehouseId) {
      query = query.where('sq.warehouse_id', '=', warehouseId);
    }

    const items = await query
      .select([
        'p.code as productCode',
        'p.name as productName',
        'w.name as warehouseName',
        'sq.quantity_on_hand as quantity',
        'sq.average_cost as unitCost',
        'sq.total_value as totalValue',
      ])
      .orderBy('p.code')
      .execute();

    const totalValue = items.reduce((sum, i) => sum + Number(i.totalValue), 0);

    return { items, totalValue };
  }
}
```

---

## Part 4: Financial Reporting

### 4.1 Financial Report Service

```typescript
// services/reporting/financial-report.service.ts
export class FinancialReportService {
  constructor(
    private readonly db: Database,
    private readonly accountService: ChartOfAccountsService,
  ) {}

  async getBalanceSheet(
    companyId: string,
    asOfDate: Date,
  ): Promise<BalanceSheetReport> {
    // Get all accounts with balances
    const accounts = await this.getAccountBalances(companyId, asOfDate);

    // Group by type
    const assets = accounts.filter((a) => a.accountType === 'asset');
    const liabilities = accounts.filter((a) => a.accountType === 'liability');
    const equity = accounts.filter((a) => a.accountType === 'equity');

    // Calculate retained earnings (Revenue - Expenses)
    const retainedEarnings = await this.calculateRetainedEarnings(companyId, asOfDate);

    return {
      asOfDate,
      assets: {
        items: this.groupByParent(assets),
        total: assets.reduce((sum, a) => sum + a.balance, 0),
      },
      liabilities: {
        items: this.groupByParent(liabilities),
        total: liabilities.reduce((sum, a) => sum + a.balance, 0),
      },
      equity: {
        items: this.groupByParent(equity),
        retainedEarnings,
        total: equity.reduce((sum, a) => sum + a.balance, 0) + retainedEarnings,
      },
    };
  }

  async getIncomeStatement(
    companyId: string,
    startDate: Date,
    endDate: Date,
  ): Promise<IncomeStatementReport> {
    const accountMovements = await this.getAccountMovements(
      companyId,
      startDate,
      endDate,
    );

    const revenue = accountMovements.filter((a) => a.accountType === 'revenue');
    const expenses = accountMovements.filter((a) => a.accountType === 'expense');

    const totalRevenue = revenue.reduce((sum, a) => sum + a.netChange, 0);
    const totalExpenses = expenses.reduce((sum, a) => sum + a.netChange, 0);
    const netIncome = totalRevenue - totalExpenses;

    return {
      periodStart: startDate,
      periodEnd: endDate,
      revenue: {
        items: this.groupByParent(revenue),
        total: totalRevenue,
      },
      expenses: {
        items: this.groupByParent(expenses),
        total: totalExpenses,
      },
      netIncome,
    };
  }

  async getCashFlowStatement(
    companyId: string,
    startDate: Date,
    endDate: Date,
  ): Promise<CashFlowReport> {
    // Get cash account movements
    const cashAccounts = await this.db
      .selectFrom('accounts')
      .where('company_id', '=', companyId)
      .where('is_bank_account', '=', true)
      .select(['id'])
      .execute();

    const cashAccountIds = cashAccounts.map((a) => a.id);

    // Get all journal lines for cash accounts in period
    const cashMovements = await this.db
      .selectFrom('journal_lines as jl')
      .innerJoin('journal_entries as je', 'jl.entry_id', 'je.id')
      .where('jl.account_id', 'in', cashAccountIds)
      .where('je.status', '=', 'posted')
      .where('je.entry_date', '>=', startDate)
      .where('je.entry_date', '<=', endDate)
      .select([
        'je.source_type as sourceType',
        sql`SUM(jl.debit - jl.credit)`.as('netCash'),
      ])
      .groupBy('je.source_type')
      .execute();

    // Categorize
    const operating = cashMovements
      .filter((m) => ['invoice', 'payment', 'expense'].includes(m.sourceType || ''))
      .reduce((sum, m) => sum + Number(m.netCash), 0);

    const investing = cashMovements
      .filter((m) => ['asset_purchase', 'asset_sale'].includes(m.sourceType || ''))
      .reduce((sum, m) => sum + Number(m.netCash), 0);

    const financing = cashMovements
      .filter((m) => ['loan', 'equity', 'dividend'].includes(m.sourceType || ''))
      .reduce((sum, m) => sum + Number(m.netCash), 0);

    // Beginning and ending cash
    const beginningCash = await this.getCashBalance(companyId, startDate);
    const endingCash = await this.getCashBalance(companyId, endDate);

    return {
      periodStart: startDate,
      periodEnd: endDate,
      operatingActivities: operating,
      investingActivities: investing,
      financingActivities: financing,
      netChange: operating + investing + financing,
      beginningCash,
      endingCash,
    };
  }
}
```

---

## Part 5: Workflow Engine

### 5.1 Approval Workflow

```typescript
// services/workflow/workflow.service.ts
export class WorkflowService {
  constructor(
    private readonly db: Database,
    private readonly notificationService: NotificationService,
  ) {}

  async submitForApproval(
    documentType: string,
    documentId: string,
    submittedBy: string,
  ): Promise<Result<WorkflowInstance>> {
    // Get workflow definition for document type
    const workflow = await this.getWorkflowDefinition(documentType);
    
    if (!workflow) {
      // No workflow required, auto-approve
      return Result.success({ status: 'approved' });
    }

    // Create workflow instance
    const instance = await this.db
      .insertInto('workflow_instances')
      .values({
        workflowId: workflow.id,
        documentType,
        documentId,
        currentStepIndex: 0,
        status: 'pending',
        submittedBy,
        submittedAt: new Date(),
      })
      .returning('*')
      .executeTakeFirst();

    // Create first approval task
    const firstStep = workflow.steps[0];
    await this.createApprovalTask(instance!.id, firstStep);

    return Result.success(instance!);
  }

  async approve(
    instanceId: string,
    approverId: string,
    comments?: string,
  ): Promise<Result<void>> {
    return this.db.transaction(async (trx) => {
      const instance = await trx
        .selectFrom('workflow_instances')
        .where('id', '=', instanceId)
        .forUpdate()
        .selectAll()
        .executeTakeFirst();

      if (!instance || instance.status !== 'pending') {
        return Result.failure(new ValidationError('Invalid workflow instance'));
      }

      const workflow = await this.getWorkflowDefinition(instance.workflowId);
      const currentStep = workflow.steps[instance.currentStepIndex];

      // Verify approver has authority
      const hasAuthority = await this.verifyApprovalAuthority(
        approverId,
        currentStep,
        instance,
      );

      if (!hasAuthority) {
        return Result.failure(new AuthorizationError('Not authorized to approve'));
      }

      // Record approval
      await trx
        .insertInto('approval_history')
        .values({
          instanceId,
          stepIndex: instance.currentStepIndex,
          action: 'approved',
          approverId,
          comments,
          approvedAt: new Date(),
        })
        .execute();

      // Check if more steps
      const nextStepIndex = instance.currentStepIndex + 1;
      
      if (nextStepIndex < workflow.steps.length) {
        // Move to next step
        await trx
          .updateTable('workflow_instances')
          .set({ currentStepIndex: nextStepIndex })
          .where('id', '=', instanceId)
          .execute();

        // Create next approval task
        const nextStep = workflow.steps[nextStepIndex];
        await this.createApprovalTask(instanceId, nextStep);
      } else {
        // Workflow complete
        await trx
          .updateTable('workflow_instances')
          .set({ status: 'approved', completedAt: new Date() })
          .where('id', '=', instanceId)
          .execute();

        // Trigger approved action
        await this.onWorkflowApproved(instance, trx);
      }

      return Result.success(undefined);
    });
  }

  async reject(
    instanceId: string,
    approverId: string,
    reason: string,
  ): Promise<Result<void>> {
    return this.db.transaction(async (trx) => {
      const instance = await trx
        .selectFrom('workflow_instances')
        .where('id', '=', instanceId)
        .forUpdate()
        .selectAll()
        .executeTakeFirst();

      if (!instance || instance.status !== 'pending') {
        return Result.failure(new ValidationError('Invalid workflow instance'));
      }

      // Record rejection
      await trx
        .insertInto('approval_history')
        .values({
          instanceId,
          stepIndex: instance.currentStepIndex,
          action: 'rejected',
          approverId,
          comments: reason,
          approvedAt: new Date(),
        })
        .execute();

      // Update instance
      await trx
        .updateTable('workflow_instances')
        .set({
          status: 'rejected',
          completedAt: new Date(),
        })
        .where('id', '=', instanceId)
        .execute();

      // Notify submitter
      await this.notificationService.notify({
        userId: instance.submittedBy,
        type: 'workflow_rejected',
        data: {
          documentType: instance.documentType,
          documentId: instance.documentId,
          reason,
        },
      });

      return Result.success(undefined);
    });
  }
}
```

---

## Part 6: Best Practices

### ✅ Data Integrity

- ✅ Use database transactions for all financial operations
- ✅ Implement double-entry bookkeeping (balanced journal entries)
- ✅ Use row-level locking for inventory and ledger updates
- ✅ Maintain comprehensive audit trails
- ✅ Soft delete instead of hard delete

### ✅ Security

- ✅ Implement granular Role-Based Access Control (RBAC)
- ✅ Encrypt sensitive data (bank accounts, tax IDs)
- ✅ Audit log all changes to financial data
- ✅ Separate duties (maker-checker for approvals)

### ✅ Performance

- ✅ Use read replicas for reporting
- ✅ Pre-compute period balances
- ✅ Index frequently queried columns
- ✅ Archive old fiscal periods

### ✅ Compliance

- ✅ Follow GAAP/IFRS accounting standards
- ✅ Make tax rates configurable
- ✅ Support multi-currency with exchange rates
- ✅ Generate audit-ready reports

### ❌ Avoid

- ❌ Don't hardcode tax rates or fiscal rules
- ❌ Don't skip fiscal period validation
- ❌ Don't allow unbalanced journal entries
- ❌ Don't delete sensitive records
- ❌ Don't run heavy reports on production DB

---

## Related Skills

- `@senior-backend-developer` - API architecture
- `@postgresql-specialist` - Database optimization
- `@hr-payroll-developer` - HRIS specialization
- `@pos-developer` - Retail integration
- `@inventory-management-developer` - Warehouse management

---
name: erp-developer
description: "Expert in Enterprise Resource Planning (ERP) development including business logic, accounting modules, and system integration"
---

# ERP Developer

## Overview

Master the development and customization of Enterprise Resource Planning (ERP) systems. Expertise in business process logic, accounting/finance modules, inventory management, HRIS integration, and enterprise-grade reporting.

## When to Use This Skill

- Use when building or customizing ERP platforms (Odoo, ERPNext, SAP)
- Use when implementing complex business workflows and financial logic
- Use for integrating various business departments into a single source of truth
- Use when designing highly secure, multi-tenant enterprise applications

## How It Works

### Step 1: Core Business Logic

- **Accounting**: Double-entry bookkeeping, multi-currency support, financial statements.
- **Procurement**: Purchase orders, RFQs, vendor management.
- **HRIS**: Payroll, attendance tracking, appraisal systems.

### Step 2: Customization & Frameworks

```python
# Odoo-style model definition
class SaleOrder(models.Model):
    _inherit = 'sale.order'
    
    custom_discount_id = fields.Many2one('custom.discount', string='Promotion')
    
    def action_confirm(self):
        self.apply_discounts()
        return super(SaleOrder, self).action_confirm()
```

### Step 3: Integration & Data Integrity

- **Database Locks**: Preventing race conditions in inventory and ledger entries.
- **Audit Logs**: Mandatory tracking of every change in sensitive financial data.
- **API Connectors**: Linking the ERP with E-commerce, Banks, and CRM.

### Step 4: Enterprise Reporting

- **OLAP Cubes**: For multidimensional data analysis.
- **Export Formats**: Detailed PDF generation for invoices, Excel for accounting.

## Best Practices

### ✅ Do This

- ✅ Prioritize data accuracy and relational integrity above all
- ✅ Follow strict financial standards (GAAP/IFRS) where applicable
- ✅ Implement granular Role-Based Access Control (RBAC)
- ✅ Use transactions to ensure atomic business operations
- ✅ Keep business logic modular and testable

### ❌ Avoid This

- ❌ Don't hardcode tax rates or fiscal rules—make them configurable
- ❌ Don't delete sensitive records—use "Archive" or "Soft Delete"
- ❌ Don't perform heavy reports on the main production database (use Read Replicas)
- ❌ Don't skip thorough documentation for custom business flows

## Related Skills

- `@senior-backend-developer` - Transactional logic
- `@pos-developer` - Retail integration
- `@hr-payroll-developer` - HR module specialization

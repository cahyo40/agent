---
name: personal-finance-app-developer
description: "Expert personal finance app development including budgeting, expense tracking, savings goals, and financial analytics"
---

# Personal Finance App Developer

## Overview

This skill transforms you into a **Personal Finance App Expert**. You will master **Expense Tracking**, **Budgeting**, **Savings Goals**, **Bank Integration**, and **Financial Analytics** for building production-ready personal finance applications.

## When to Use This Skill

- Use when building budgeting apps
- Use when implementing expense tracking
- Use when creating savings goals
- Use when integrating bank accounts
- Use when building financial dashboards

---

## Part 1: Personal Finance Architecture

### 1.1 System Components

```
┌─────────────────────────────────────────────────────────────┐
│                   Personal Finance App                       │
├────────────┬─────────────┬─────────────┬────────────────────┤
│ Accounts   │ Transactions│ Budgets     │ Goals              │
├────────────┴─────────────┴─────────────┴────────────────────┤
│               Bank Integration (Plaid)                       │
├─────────────────────────────────────────────────────────────┤
│              Analytics & Insights                            │
└─────────────────────────────────────────────────────────────┘
```

### 1.2 Key Concepts

| Concept | Description |
|---------|-------------|
| **Account** | Bank account, credit card, cash |
| **Transaction** | Income or expense |
| **Category** | Spending classification |
| **Budget** | Spending limit per category |
| **Goal** | Savings target |
| **Net Worth** | Assets minus liabilities |

---

## Part 2: Database Schema

### 2.1 Core Tables

```sql
-- Accounts
CREATE TABLE accounts (
    id UUID PRIMARY KEY,
    user_id UUID REFERENCES users(id),
    name VARCHAR(100),
    type VARCHAR(50),  -- 'checking', 'savings', 'credit_card', 'cash', 'investment'
    institution VARCHAR(100),
    balance DECIMAL(15, 2) DEFAULT 0,
    currency VARCHAR(3) DEFAULT 'USD',
    is_asset BOOLEAN DEFAULT TRUE,  -- FALSE for credit cards/loans
    is_linked BOOLEAN DEFAULT FALSE,
    plaid_account_id VARCHAR(100),
    last_synced_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Categories
CREATE TABLE categories (
    id UUID PRIMARY KEY,
    user_id UUID REFERENCES users(id),
    name VARCHAR(100),
    icon VARCHAR(50),
    color VARCHAR(7),
    parent_id UUID REFERENCES categories(id),
    type VARCHAR(20),  -- 'income', 'expense'
    is_system BOOLEAN DEFAULT FALSE
);

-- Transactions
CREATE TABLE transactions (
    id UUID PRIMARY KEY,
    user_id UUID REFERENCES users(id),
    account_id UUID REFERENCES accounts(id),
    category_id UUID REFERENCES categories(id),
    amount DECIMAL(15, 2) NOT NULL,  -- Positive = income, Negative = expense
    type VARCHAR(20),  -- 'income', 'expense', 'transfer'
    description VARCHAR(255),
    merchant VARCHAR(255),
    date DATE NOT NULL,
    notes TEXT,
    is_recurring BOOLEAN DEFAULT FALSE,
    recurring_id UUID,
    plaid_transaction_id VARCHAR(100),
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Budgets
CREATE TABLE budgets (
    id UUID PRIMARY KEY,
    user_id UUID REFERENCES users(id),
    category_id UUID REFERENCES categories(id),
    amount DECIMAL(15, 2),
    period VARCHAR(20) DEFAULT 'monthly',  -- 'weekly', 'monthly', 'yearly'
    start_date DATE,
    end_date DATE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Goals
CREATE TABLE goals (
    id UUID PRIMARY KEY,
    user_id UUID REFERENCES users(id),
    name VARCHAR(100),
    target_amount DECIMAL(15, 2),
    current_amount DECIMAL(15, 2) DEFAULT 0,
    deadline DATE,
    icon VARCHAR(50),
    color VARCHAR(7),
    status VARCHAR(20) DEFAULT 'active',  -- 'active', 'completed', 'cancelled'
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Recurring Transactions
CREATE TABLE recurring_transactions (
    id UUID PRIMARY KEY,
    user_id UUID REFERENCES users(id),
    account_id UUID REFERENCES accounts(id),
    category_id UUID REFERENCES categories(id),
    amount DECIMAL(15, 2),
    description VARCHAR(255),
    frequency VARCHAR(20),  -- 'daily', 'weekly', 'monthly', 'yearly'
    next_date DATE,
    end_date DATE,
    is_active BOOLEAN DEFAULT TRUE
);
```

---

## Part 3: Expense Tracking

### 3.1 Add Transaction

```typescript
async function addTransaction(
  userId: string,
  data: {
    accountId: string;
    categoryId: string;
    amount: number;
    type: 'income' | 'expense' | 'transfer';
    description: string;
    date: Date;
    merchant?: string;
  }
): Promise<Transaction> {
  // Ensure amount sign matches type
  const amount = data.type === 'expense' ? -Math.abs(data.amount) : Math.abs(data.amount);
  
  const transaction = await db.transactions.create({
    data: {
      userId,
      accountId: data.accountId,
      categoryId: data.categoryId,
      amount,
      type: data.type,
      description: data.description,
      date: data.date,
      merchant: data.merchant,
    },
  });
  
  // Update account balance
  await db.accounts.update({
    where: { id: data.accountId },
    data: { balance: { increment: amount } },
  });
  
  // Check budget alerts
  await checkBudgetAlerts(userId, data.categoryId);
  
  return transaction;
}
```

### 3.2 Auto-Categorization

```typescript
const MERCHANT_CATEGORIES: Record<string, string> = {
  'starbucks': 'food_coffee',
  'uber': 'transportation',
  'netflix': 'entertainment',
  'spotify': 'entertainment',
  'amazon': 'shopping',
};

async function autoCategorize(merchant: string, userId: string): Promise<string | null> {
  // Check merchant mapping
  const normalizedMerchant = merchant.toLowerCase();
  for (const [pattern, categoryKey] of Object.entries(MERCHANT_CATEGORIES)) {
    if (normalizedMerchant.includes(pattern)) {
      const category = await db.categories.findFirst({
        where: { userId, name: categoryKey },
      });
      if (category) return category.id;
    }
  }
  
  // Check user's previous categorization for same merchant
  const previousTx = await db.transactions.findFirst({
    where: {
      userId,
      merchant: { contains: merchant, mode: 'insensitive' },
      categoryId: { not: null },
    },
    orderBy: { date: 'desc' },
  });
  
  return previousTx?.categoryId || null;
}
```

---

## Part 4: Budgeting

### 4.1 Budget Tracking

```typescript
interface BudgetStatus {
  categoryId: string;
  categoryName: string;
  budgetAmount: number;
  spentAmount: number;
  remainingAmount: number;
  percentUsed: number;
  status: 'on_track' | 'warning' | 'exceeded';
}

async function getBudgetStatus(userId: string, month: Date): Promise<BudgetStatus[]> {
  const startOfMonth = new Date(month.getFullYear(), month.getMonth(), 1);
  const endOfMonth = new Date(month.getFullYear(), month.getMonth() + 1, 0);
  
  const budgets = await db.budgets.findMany({
    where: { userId, period: 'monthly' },
    include: { category: true },
  });
  
  const results: BudgetStatus[] = [];
  
  for (const budget of budgets) {
    const spent = await db.transactions.aggregate({
      where: {
        userId,
        categoryId: budget.categoryId,
        date: { gte: startOfMonth, lte: endOfMonth },
        type: 'expense',
      },
      _sum: { amount: true },
    });
    
    const spentAmount = Math.abs(spent._sum.amount || 0);
    const remainingAmount = budget.amount - spentAmount;
    const percentUsed = (spentAmount / budget.amount) * 100;
    
    results.push({
      categoryId: budget.categoryId,
      categoryName: budget.category.name,
      budgetAmount: budget.amount,
      spentAmount,
      remainingAmount,
      percentUsed,
      status: percentUsed >= 100 ? 'exceeded' : percentUsed >= 80 ? 'warning' : 'on_track',
    });
  }
  
  return results;
}
```

### 4.2 Budget Alerts

```typescript
async function checkBudgetAlerts(userId: string, categoryId: string) {
  const budgetStatus = await getBudgetStatus(userId, new Date());
  const categoryStatus = budgetStatus.find(b => b.categoryId === categoryId);
  
  if (!categoryStatus) return;
  
  if (categoryStatus.percentUsed >= 80 && categoryStatus.percentUsed < 100) {
    await sendNotification(userId, {
      title: 'Budget Warning',
      body: `You've used ${Math.round(categoryStatus.percentUsed)}% of your ${categoryStatus.categoryName} budget.`,
    });
  } else if (categoryStatus.percentUsed >= 100) {
    await sendNotification(userId, {
      title: 'Budget Exceeded',
      body: `You've exceeded your ${categoryStatus.categoryName} budget by ${formatCurrency(Math.abs(categoryStatus.remainingAmount))}.`,
    });
  }
}
```

---

## Part 5: Savings Goals

### 5.1 Goal Progress

```typescript
async function contributeToGoal(userId: string, goalId: string, amount: number) {
  const goal = await db.goals.findUnique({ where: { id: goalId } });
  
  const newAmount = goal.currentAmount + amount;
  const isCompleted = newAmount >= goal.targetAmount;
  
  await db.goals.update({
    where: { id: goalId },
    data: {
      currentAmount: newAmount,
      status: isCompleted ? 'completed' : 'active',
    },
  });
  
  if (isCompleted) {
    await sendNotification(userId, {
      title: '🎉 Goal Achieved!',
      body: `Congratulations! You've reached your "${goal.name}" savings goal!`,
    });
  }
}

async function getGoalProgress(goalId: string) {
  const goal = await db.goals.findUnique({ where: { id: goalId } });
  
  const percentComplete = (goal.currentAmount / goal.targetAmount) * 100;
  const remaining = goal.targetAmount - goal.currentAmount;
  
  // Calculate monthly saving needed to reach goal
  const monthsRemaining = goal.deadline
    ? differenceInMonths(goal.deadline, new Date())
    : null;
  
  const monthlyNeeded = monthsRemaining && monthsRemaining > 0
    ? remaining / monthsRemaining
    : null;
  
  return {
    ...goal,
    percentComplete,
    remaining,
    monthsRemaining,
    monthlyNeeded,
  };
}
```

---

## Part 6: Analytics

### 6.1 Spending Insights

```typescript
async function getSpendingInsights(userId: string, months = 3) {
  const startDate = subMonths(new Date(), months);
  
  // Spending by category
  const byCategory = await db.transactions.groupBy({
    by: ['categoryId'],
    where: {
      userId,
      type: 'expense',
      date: { gte: startDate },
    },
    _sum: { amount: true },
    orderBy: { _sum: { amount: 'asc' } },
  });
  
  // Month-over-month comparison
  const thisMonth = await getMonthlySpending(userId, new Date());
  const lastMonth = await getMonthlySpending(userId, subMonths(new Date(), 1));
  
  const monthChange = thisMonth - lastMonth;
  const monthChangePercent = lastMonth > 0 ? (monthChange / lastMonth) * 100 : 0;
  
  return {
    byCategory: byCategory.map(c => ({
      categoryId: c.categoryId,
      amount: Math.abs(c._sum.amount),
    })),
    thisMonth,
    lastMonth,
    monthChange,
    monthChangePercent,
  };
}
```

---

## Part 7: Best Practices Checklist

### ✅ Do This

- ✅ **Secure Bank Credentials**: Use Plaid/Yodlee.
- ✅ **Auto-Sync Transactions**: Background sync.
- ✅ **Flexible Categories**: Let users customize.

### ❌ Avoid This

- ❌ **Store Bank Passwords**: Use OAuth tokens.
- ❌ **Hard-Code Categories**: Users have different needs.
- ❌ **Ignore Data Privacy**: Encrypt sensitive data.

---

## Related Skills

- `@fintech-developer` - Financial systems
- `@trading-app-developer` - Investment tracking
- `@analytics-engineer` - Data analysis

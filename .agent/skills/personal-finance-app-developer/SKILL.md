---
name: personal-finance-app-developer
description: "Expert personal finance app development including budgeting, expense tracking, savings goals, and financial analytics"
---

# Personal Finance App Developer

## Overview

Skill ini menjadikan AI Agent Anda sebagai spesialis pengembangan aplikasi personal finance. Agent akan mampu membangun fitur budgeting, expense tracking, savings goals, financial analytics, dan integrasi dengan bank/payment services.

## When to Use This Skill

- Use when building budgeting or expense tracking apps
- Use when implementing savings goals and financial planning features
- Use when the user asks about personal finance app architecture
- Use when designing financial dashboards and analytics
- Use when integrating with Open Banking APIs

## How It Works

### Step 1: Core Features

```text
┌─────────────────────────────────────────────────────────┐
│           PERSONAL FINANCE APP FEATURES                 │
├─────────────────────────────────────────────────────────┤
│ 💰 Expense Tracking    - Categorize, tag, receipt scan  │
│ 📊 Budgeting           - Category budgets, alerts       │
│ 🎯 Savings Goals       - Target tracking, milestones    │
│ 📈 Analytics           - Trends, insights, reports      │
│ 🏦 Bank Sync           - Plaid, Open Banking APIs       │
│ 🔔 Notifications       - Bill reminders, budget alerts  │
│ 📱 Multi-platform      - Mobile, web, sync across       │
└─────────────────────────────────────────────────────────┘
```

### Step 2: Data Models

```dart
// Transaction model
class Transaction {
  final String id;
  final double amount;
  final TransactionType type; // income, expense
  final String categoryId;
  final DateTime date;
  final String description;
  final String? notes;
  final String? receiptUrl;
  final List<String> tags;
  final bool isRecurring;
  final String? recurringId;
  
  // Computed
  bool get isExpense => type == TransactionType.expense;
  bool get isIncome => type == TransactionType.income;
}

// Budget model
class Budget {
  final String id;
  final String categoryId;
  final double limit;
  final BudgetPeriod period; // weekly, monthly, yearly
  final DateTime startDate;
  final double spent;
  
  double get remaining => limit - spent;
  double get percentUsed => (spent / limit) * 100;
  bool get isOverBudget => spent > limit;
}

// Savings Goal model
class SavingsGoal {
  final String id;
  final String name;
  final double targetAmount;
  final double currentAmount;
  final DateTime? targetDate;
  final String? iconUrl;
  final Color color;
  
  double get progress => (currentAmount / targetAmount) * 100;
  double get remaining => targetAmount - currentAmount;
  bool get isCompleted => currentAmount >= targetAmount;
}

// Category with budget
class Category {
  final String id;
  final String name;
  final String icon;
  final Color color;
  final CategoryType type; // income, expense
  final Budget? budget;
}
```

### Step 3: Budget Calculation Logic

```dart
class BudgetService {
  // Calculate spending by category for period
  Future<Map<String, double>> getCategorySpending({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final transactions = await _repository.getTransactions(
      startDate: startDate,
      endDate: endDate,
      type: TransactionType.expense,
    );
    
    final spending = <String, double>{};
    for (final tx in transactions) {
      spending[tx.categoryId] = 
        (spending[tx.categoryId] ?? 0) + tx.amount;
    }
    return spending;
  }
  
  // Check budget alerts
  Future<List<BudgetAlert>> checkBudgetAlerts() async {
    final budgets = await _repository.getAllBudgets();
    final alerts = <BudgetAlert>[];
    
    for (final budget in budgets) {
      if (budget.percentUsed >= 100) {
        alerts.add(BudgetAlert(
          type: AlertType.exceeded,
          budget: budget,
          message: 'Budget exceeded by ${budget.spent - budget.limit}',
        ));
      } else if (budget.percentUsed >= 80) {
        alerts.add(BudgetAlert(
          type: AlertType.warning,
          budget: budget,
          message: '${budget.percentUsed.toInt()}% of budget used',
        ));
      }
    }
    return alerts;
  }
  
  // Calculate monthly summary
  Future<MonthlySummary> getMonthlySummary(DateTime month) async {
    final start = DateTime(month.year, month.month, 1);
    final end = DateTime(month.year, month.month + 1, 0);
    
    final transactions = await _repository.getTransactions(
      startDate: start,
      endDate: end,
    );
    
    double totalIncome = 0;
    double totalExpense = 0;
    
    for (final tx in transactions) {
      if (tx.isIncome) {
        totalIncome += tx.amount;
      } else {
        totalExpense += tx.amount;
      }
    }
    
    return MonthlySummary(
      month: month,
      totalIncome: totalIncome,
      totalExpense: totalExpense,
      netSavings: totalIncome - totalExpense,
      savingsRate: totalIncome > 0 
        ? ((totalIncome - totalExpense) / totalIncome) * 100 
        : 0,
    );
  }
}
```

### Step 4: Recurring Transactions

```dart
class RecurringTransactionService {
  // Process recurring transactions
  Future<void> processRecurringTransactions() async {
    final recurring = await _repository.getRecurringTransactions();
    final now = DateTime.now();
    
    for (final template in recurring) {
      if (_shouldCreateTransaction(template, now)) {
        await _repository.createTransaction(
          Transaction(
            id: _uuid.v4(),
            amount: template.amount,
            type: template.type,
            categoryId: template.categoryId,
            date: now,
            description: template.description,
            isRecurring: true,
            recurringId: template.id,
          ),
        );
        
        await _repository.updateLastProcessed(template.id, now);
      }
    }
  }
  
  bool _shouldCreateTransaction(
    RecurringTemplate template,
    DateTime now,
  ) {
    final lastProcessed = template.lastProcessed;
    
    switch (template.frequency) {
      case Frequency.daily:
        return now.difference(lastProcessed).inDays >= 1;
      case Frequency.weekly:
        return now.difference(lastProcessed).inDays >= 7;
      case Frequency.monthly:
        return now.month != lastProcessed.month;
      case Frequency.yearly:
        return now.year != lastProcessed.year;
    }
  }
}
```

### Step 5: Bank Integration (Plaid)

```dart
// Plaid integration for bank sync
class PlaidService {
  final String _clientId;
  final String _secret;
  
  // Create link token for Plaid Link
  Future<String> createLinkToken(String userId) async {
    final response = await _dio.post(
      'https://sandbox.plaid.com/link/token/create',
      data: {
        'client_id': _clientId,
        'secret': _secret,
        'user': {'client_user_id': userId},
        'client_name': 'MyFinanceApp',
        'products': ['transactions'],
        'country_codes': ['US'],
        'language': 'en',
      },
    );
    return response.data['link_token'];
  }
  
  // Exchange public token for access token
  Future<String> exchangePublicToken(String publicToken) async {
    final response = await _dio.post(
      'https://sandbox.plaid.com/item/public_token/exchange',
      data: {
        'client_id': _clientId,
        'secret': _secret,
        'public_token': publicToken,
      },
    );
    return response.data['access_token'];
  }
  
  // Sync transactions from bank
  Future<List<Transaction>> syncTransactions(
    String accessToken, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final response = await _dio.post(
      'https://sandbox.plaid.com/transactions/get',
      data: {
        'client_id': _clientId,
        'secret': _secret,
        'access_token': accessToken,
        'start_date': startDate?.toIso8601String().split('T')[0],
        'end_date': endDate?.toIso8601String().split('T')[0],
      },
    );
    
    return (response.data['transactions'] as List)
      .map((tx) => Transaction.fromPlaid(tx))
      .toList();
  }
}
```

### Step 6: Analytics & Insights

```dart
class FinancialAnalyticsService {
  // Spending trends over months
  Future<List<MonthlyTrend>> getSpendingTrends(int months) async {
    final trends = <MonthlyTrend>[];
    final now = DateTime.now();
    
    for (int i = 0; i < months; i++) {
      final month = DateTime(now.year, now.month - i, 1);
      final summary = await _budgetService.getMonthlySummary(month);
      trends.add(MonthlyTrend(
        month: month,
        income: summary.totalIncome,
        expense: summary.totalExpense,
        savings: summary.netSavings,
      ));
    }
    
    return trends.reversed.toList();
  }
  
  // Generate insights
  Future<List<Insight>> generateInsights() async {
    final insights = <Insight>[];
    final lastMonth = await _budgetService.getMonthlySummary(
      DateTime(DateTime.now().year, DateTime.now().month - 1, 1),
    );
    final thisMonth = await _budgetService.getMonthlySummary(
      DateTime.now(),
    );
    
    // Spending comparison
    if (thisMonth.totalExpense > lastMonth.totalExpense * 1.2) {
      insights.add(Insight(
        type: InsightType.warning,
        title: 'Spending Up',
        message: 'Your spending is 20% higher than last month',
        actionable: true,
      ));
    }
    
    // Savings opportunity
    if (thisMonth.savingsRate < 20) {
      insights.add(Insight(
        type: InsightType.tip,
        title: 'Savings Opportunity',
        message: 'Try to save at least 20% of your income',
      ));
    }
    
    return insights;
  }
}
```

## Best Practices

### ✅ Do This

- ✅ Use local-first architecture with cloud sync
- ✅ Implement proper data encryption for financial data
- ✅ Provide clear budget visualizations (charts, progress bars)
- ✅ Send proactive budget alerts and bill reminders
- ✅ Support multiple currencies and localization

### ❌ Avoid This

- ❌ Don't store sensitive bank credentials in plain text
- ❌ Don't skip transaction categorization—it's key to insights
- ❌ Don't ignore recurring transaction patterns
- ❌ Don't make data export difficult—users own their data
- ❌ Don't overcomplicate the UI—simplicity wins

## Related Skills

- `@senior-flutter-developer` - Mobile app development
- `@fintech-developer` - Banking API integration
- `@payment-integration-specialist` - Payment processing
- `@senior-firebase-developer` - Backend and sync
- `@analytics-engineer` - Financial analytics

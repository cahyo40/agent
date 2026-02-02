---
name: fintech-developer
description: "Expert fintech development including payment gateways, banking APIs, and financial integrations"
---

# Fintech Developer

## Overview

This skill transforms you into a **Financial Technology Expert**. You will master **Payment Processing**, **Banking APIs**, **KYC/AML Compliance**, **Money Transfer**, and **Financial Data Security** for building production-ready fintech applications.

## When to Use This Skill

- Use when building payment systems
- Use when integrating banking APIs
- Use when implementing KYC/AML
- Use when building money transfer apps
- Use when handling financial compliance

---

## Part 1: Fintech Architecture

### 1.1 System Components

```
┌─────────────────────────────────────────────────────────────┐
│                    Fintech Platform                          │
├──────────────┬────────────────┬────────────────┬────────────┤
│ User Wallets │ Payment Rails  │ KYC/AML        │ Reporting  │
├──────────────┴────────────────┴────────────────┴────────────┤
│                 Ledger (Double-Entry)                        │
├─────────────────────────────────────────────────────────────┤
│               Security & Compliance Layer                    │
└─────────────────────────────────────────────────────────────┘
```

### 1.2 Key Concepts

| Concept | Description |
|---------|-------------|
| **Ledger** | Immutable record of all transactions |
| **Float** | Funds in transit |
| **Settlement** | Final transfer of funds |
| **Reconciliation** | Matching records with bank |
| **KYC** | Know Your Customer verification |
| **AML** | Anti-Money Laundering checks |

---

## Part 2: Database Design

### 2.1 Ledger Schema

```sql
-- Accounts (wallets)
CREATE TABLE accounts (
    id UUID PRIMARY KEY,
    user_id UUID REFERENCES users(id),
    type VARCHAR(50) NOT NULL,  -- 'user_wallet', 'escrow', 'fees', 'settlement'
    currency VARCHAR(3) NOT NULL,
    balance DECIMAL(18, 2) DEFAULT 0,
    status VARCHAR(50) DEFAULT 'active',
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Transactions (immutable ledger)
CREATE TABLE transactions (
    id UUID PRIMARY KEY,
    reference VARCHAR(100) UNIQUE,
    type VARCHAR(50) NOT NULL,  -- 'deposit', 'withdrawal', 'transfer', 'fee'
    status VARCHAR(50) DEFAULT 'pending',  -- 'pending', 'completed', 'failed', 'reversed'
    amount DECIMAL(18, 2) NOT NULL,
    currency VARCHAR(3) NOT NULL,
    metadata JSONB,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    completed_at TIMESTAMPTZ
);

-- Ledger entries (double-entry)
CREATE TABLE ledger_entries (
    id UUID PRIMARY KEY,
    transaction_id UUID REFERENCES transactions(id),
    account_id UUID REFERENCES accounts(id),
    entry_type VARCHAR(10) NOT NULL,  -- 'debit', 'credit'
    amount DECIMAL(18, 2) NOT NULL,
    balance_after DECIMAL(18, 2) NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Ensure balanced entries
CREATE OR REPLACE FUNCTION check_balanced_transaction()
RETURNS TRIGGER AS $$
BEGIN
    IF (
        SELECT SUM(CASE WHEN entry_type = 'debit' THEN amount ELSE -amount END)
        FROM ledger_entries WHERE transaction_id = NEW.transaction_id
    ) != 0 THEN
        RAISE EXCEPTION 'Transaction is not balanced';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
```

---

## Part 3: Double-Entry Bookkeeping

### 3.1 Transfer Between Wallets

```typescript
async function transfer(
  fromAccountId: string,
  toAccountId: string,
  amount: number,
  currency: string
): Promise<Transaction> {
  return await db.$transaction(async (tx) => {
    // Lock accounts
    const [fromAccount, toAccount] = await Promise.all([
      tx.accounts.findUniqueOrThrow({
        where: { id: fromAccountId },
      }),
      tx.accounts.findUniqueOrThrow({
        where: { id: toAccountId },
      }),
    ]);
    
    // Validate
    if (fromAccount.balance < amount) {
      throw new Error('Insufficient balance');
    }
    
    // Create transaction
    const transaction = await tx.transactions.create({
      data: {
        reference: generateReference(),
        type: 'transfer',
        amount,
        currency,
        status: 'completed',
        completedAt: new Date(),
      },
    });
    
    // Debit sender
    const newFromBalance = fromAccount.balance - amount;
    await tx.accounts.update({
      where: { id: fromAccountId },
      data: { balance: newFromBalance },
    });
    await tx.ledgerEntries.create({
      data: {
        transactionId: transaction.id,
        accountId: fromAccountId,
        entryType: 'debit',
        amount,
        balanceAfter: newFromBalance,
      },
    });
    
    // Credit receiver
    const newToBalance = toAccount.balance + amount;
    await tx.accounts.update({
      where: { id: toAccountId },
      data: { balance: newToBalance },
    });
    await tx.ledgerEntries.create({
      data: {
        transactionId: transaction.id,
        accountId: toAccountId,
        entryType: 'credit',
        amount,
        balanceAfter: newToBalance,
      },
    });
    
    return transaction;
  });
}
```

---

## Part 4: KYC/AML Integration

### 4.1 KYC Verification

```typescript
interface KYCData {
  firstName: string;
  lastName: string;
  dateOfBirth: string;
  address: Address;
  idDocument: {
    type: 'passport' | 'national_id' | 'drivers_license';
    number: string;
    frontImage: string;
    backImage?: string;
  };
  selfie: string;
}

async function submitKYC(userId: string, data: KYCData) {
  // Submit to KYC provider (e.g., Jumio, Onfido)
  const result = await kycProvider.verify({
    documents: [data.idDocument],
    selfie: data.selfie,
    person: {
      name: `${data.firstName} ${data.lastName}`,
      dateOfBirth: data.dateOfBirth,
    },
  });
  
  // Store result
  await db.kycVerifications.create({
    data: {
      userId,
      status: result.status,  // 'approved', 'rejected', 'pending_review'
      provider: 'onfido',
      providerReference: result.id,
      data: result,
    },
  });
  
  // Update user KYC level
  if (result.status === 'approved') {
    await db.users.update({
      where: { id: userId },
      data: { kycLevel: 'verified', kycVerifiedAt: new Date() },
    });
  }
  
  return result;
}
```

### 4.2 AML Screening

```typescript
async function screenTransaction(transaction: Transaction): Promise<AMLResult> {
  const rules = [
    { name: 'large_amount', check: (t) => t.amount > 10000 },
    { name: 'high_frequency', check: async (t) => await checkFrequency(t.accountId) > 10 },
    { name: 'new_account_large_tx', check: async (t) => await isNewAccountLargeTx(t) },
    { name: 'sanctioned_country', check: async (t) => await isSanctionedCountry(t) },
  ];
  
  const triggered = [];
  for (const rule of rules) {
    if (await rule.check(transaction)) {
      triggered.push(rule.name);
    }
  }
  
  if (triggered.length > 0) {
    await db.amlAlerts.create({
      data: {
        transactionId: transaction.id,
        rules: triggered,
        status: 'pending_review',
      },
    });
    
    // Hold transaction for review
    await db.transactions.update({
      where: { id: transaction.id },
      data: { status: 'under_review' },
    });
  }
  
  return { flagged: triggered.length > 0, rules: triggered };
}
```

---

## Part 5: Banking API Integration

### 5.1 Plaid Connection

```typescript
import { Configuration, PlaidApi, PlaidEnvironments } from 'plaid';

const plaid = new PlaidApi(new Configuration({
  basePath: PlaidEnvironments.sandbox,
  baseOptions: {
    headers: {
      'PLAID-CLIENT-ID': process.env.PLAID_CLIENT_ID,
      'PLAID-SECRET': process.env.PLAID_SECRET,
    },
  },
}));

// Create link token
app.post('/api/plaid/link-token', async (req, res) => {
  const response = await plaid.linkTokenCreate({
    user: { client_user_id: req.user.id },
    client_name: 'My Fintech App',
    products: ['auth', 'transactions'],
    country_codes: ['US'],
    language: 'en',
  });
  
  res.json({ linkToken: response.data.link_token });
});

// Exchange public token
app.post('/api/plaid/exchange', async (req, res) => {
  const { publicToken } = req.body;
  
  const response = await plaid.itemPublicTokenExchange({
    public_token: publicToken,
  });
  
  // Store access token securely
  await db.bankConnections.create({
    data: {
      userId: req.user.id,
      accessToken: encrypt(response.data.access_token),
      itemId: response.data.item_id,
    },
  });
  
  res.json({ success: true });
});
```

---

## Part 6: Security Best Practices

### 6.1 Encryption

```typescript
import crypto from 'crypto';

const ENCRYPTION_KEY = process.env.ENCRYPTION_KEY;  // 32 bytes

function encrypt(text: string): string {
  const iv = crypto.randomBytes(16);
  const cipher = crypto.createCipheriv('aes-256-gcm', ENCRYPTION_KEY, iv);
  
  let encrypted = cipher.update(text, 'utf8', 'hex');
  encrypted += cipher.final('hex');
  
  const authTag = cipher.getAuthTag().toString('hex');
  
  return `${iv.toString('hex')}:${authTag}:${encrypted}`;
}

function decrypt(encrypted: string): string {
  const [ivHex, authTagHex, encryptedHex] = encrypted.split(':');
  
  const decipher = crypto.createDecipheriv(
    'aes-256-gcm',
    ENCRYPTION_KEY,
    Buffer.from(ivHex, 'hex')
  );
  
  decipher.setAuthTag(Buffer.from(authTagHex, 'hex'));
  
  let decrypted = decipher.update(encryptedHex, 'hex', 'utf8');
  decrypted += decipher.final('utf8');
  
  return decrypted;
}
```

---

## Part 7: Best Practices Checklist

### ✅ Do This

- ✅ **Double-Entry Ledger**: Every transaction must balance.
- ✅ **Idempotent Transactions**: Use unique reference IDs.
- ✅ **Encrypt Sensitive Data**: Bank accounts, tokens.

### ❌ Avoid This

- ❌ **Store Card Numbers**: Use tokenization (Stripe, etc.).
- ❌ **Skip AML Checks**: Legal requirement.
- ❌ **Floating Point for Money**: Use DECIMAL or integers.

---

## Related Skills

- `@payment-integration-specialist` - Payment gateways
- `@saas-billing-specialist` - Subscriptions
- `@trading-app-developer` - Trading systems

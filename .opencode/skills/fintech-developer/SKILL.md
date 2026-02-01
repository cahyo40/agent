---
name: fintech-developer
description: "Expert fintech development including banking APIs, money transfer, and financial integrations"
---

# Fintech Developer

## Overview

Build financial technology solutions with banking APIs and payment integrations.

## When to Use This Skill

- Use when building financial apps
- Use when integrating banking APIs

## How It Works

### Step 1: Indonesian Payment Landscape

```markdown
## Payment Gateways
- Midtrans (Tokopedia)
- Xendit
- DOKU
- Flip (for disbursement)

## E-Wallet
- GoPay, OVO, DANA, LinkAja, ShopeePay

## Virtual Account
- BCA, BNI, BRI, Mandiri, Permata

## QRIS
- Universal QR for all e-wallets
```

### Step 2: Midtrans Integration

```javascript
const midtrans = require('midtrans-client');

const snap = new midtrans.Snap({
  isProduction: false,
  serverKey: process.env.MIDTRANS_SERVER_KEY,
  clientKey: process.env.MIDTRANS_CLIENT_KEY
});

// Create transaction
async function createPayment(order) {
  const parameter = {
    transaction_details: {
      order_id: order.id,
      gross_amount: order.total
    },
    customer_details: {
      first_name: order.customer.name,
      email: order.customer.email,
      phone: order.customer.phone
    },
    item_details: order.items.map(item => ({
      id: item.id,
      price: item.price,
      quantity: item.quantity,
      name: item.name
    }))
  };

  const transaction = await snap.createTransaction(parameter);
  return transaction.redirect_url; // Send to frontend
}

// Handle notification
app.post('/midtrans/notification', async (req, res) => {
  const notification = await snap.transaction.notification(req.body);
  
  const orderId = notification.order_id;
  const status = notification.transaction_status;
  const fraudStatus = notification.fraud_status;

  if (status === 'capture' && fraudStatus === 'accept') {
    await markOrderPaid(orderId);
  } else if (status === 'settlement') {
    await markOrderPaid(orderId);
  } else if (status === 'cancel' || status === 'deny' || status === 'expire') {
    await markOrderFailed(orderId);
  }

  res.status(200).send('OK');
});
```

### Step 3: Xendit Disbursement

```javascript
const Xendit = require('xendit-node');

const xendit = new Xendit({
  secretKey: process.env.XENDIT_SECRET_KEY
});

const { Disbursement } = xendit;
const disbursement = new Disbursement({});

// Send money to bank account
async function sendMoney(recipient) {
  const result = await disbursement.create({
    externalID: `payout-${Date.now()}`,
    amount: recipient.amount,
    bankCode: recipient.bankCode, // 'BCA', 'BNI', 'BRI', 'MANDIRI'
    accountHolderName: recipient.name,
    accountNumber: recipient.accountNumber,
    description: 'Withdrawal'
  });

  return result;
}

// Check bank account
async function validateBankAccount(bankCode, accountNumber) {
  const result = await disbursement.getBankAccountData({
    accountNumber,
    bankCode
  });
  
  return {
    valid: result.status === 'SUCCESS',
    name: result.name_with_bank
  };
}
```

### Step 4: QRIS Generation

```python
# Using Xendit QRIS
import xendit

xendit.set_api_key(os.environ['XENDIT_SECRET_KEY'])

from xendit import QRCode

def create_qris(amount, external_id):
    qr = QRCode.create(
        external_id=external_id,
        type="DYNAMIC",
        callback_url="https://yoursite.com/qris/callback",
        amount=amount
    )
    
    return {
        'qr_string': qr.qr_string,
        'qr_id': qr.id
    }
```

## Best Practices

- ✅ Validate bank accounts before transfer
- ✅ Implement idempotency keys
- ✅ Handle all callback scenarios
- ❌ Don't skip fraud detection
- ❌ Don't store sensitive card data

## Related Skills

- `@payment-integration-specialist`
- `@senior-backend-developer`

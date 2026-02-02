---
name: indonesia-payment-integration
description: "Expert Indonesian payment gateway integration including Midtrans, Xendit, DOKU, e-wallets (GoPay, OVO, DANA, ShopeePay), QRIS, and local bank transfers"
---

# Indonesia Payment Integration

## Overview

Skill ini menjadikan AI Agent sebagai spesialis integrasi sistem pembayaran Indonesia. Agent akan mampu mengintegrasikan payment gateway lokal (Midtrans, Xendit, DOKU), e-wallets (GoPay, OVO, DANA, ShopeePay, LinkAja), QRIS, virtual accounts, dan transfer bank.

## When to Use This Skill

- Use when integrating Indonesian payment gateways
- Use when implementing e-wallet payments
- Use when building QRIS payment flows
- Use when setting up virtual account transfers

## Core Concepts

### Payment Landscape Indonesia

```text
INDONESIAN PAYMENT ECOSYSTEM:
─────────────────────────────

PAYMENT GATEWAYS (Aggregator):
├── Midtrans (GoTo/Gojek) ★ Most popular
├── Xendit ★ Developer-friendly
├── DOKU (oldest, since 2007)
├── Ipaymu
├── Durianpay
└── Finpay

E-WALLETS:
├── GoPay (Gojek)
├── OVO (Grab, Tokopedia)
├── DANA
├── ShopeePay
├── LinkAja
└── Jenius Pay

BANK TRANSFERS:
├── Virtual Account (VA)
│   ├── BCA, Mandiri, BNI, BRI
│   ├── Permata, CIMB, Danamon
│   └── BSI (Bank Syariah Indonesia)
│
└── Direct Transfer
    └── BI-FAST, RTGS, SKN

QRIS (QR Indonesian Standard):
└── Unified QR for all banks & e-wallets

CREDIT/DEBIT CARDS:
├── Visa, Mastercard
├── JCB
└── BCA Card, Mandiri Debit

PAYLATER / BNPL:
├── Kredivo
├── Akulaku
├── Atome
├── SPayLater (Shopee)
└── GoPay Later
```

### Payment Gateway Comparison

```text
┌─────────────────┬─────────────────┬─────────────────┐
│    MIDTRANS     │     XENDIT      │      DOKU       │
├─────────────────┼─────────────────┼─────────────────┤
│ Best for:       │ Best for:       │ Best for:       │
│ E-commerce,     │ SaaS, Fintech,  │ Enterprise,     │
│ Marketplace     │ Startups        │ Government      │
├─────────────────┼─────────────────┼─────────────────┤
│ Integration:    │ Integration:    │ Integration:    │
│ Snap (hosted)   │ REST API        │ REST API        │
│ Core API        │ SDK (Node, PHP) │ Hosted Checkout │
├─────────────────┼─────────────────┼─────────────────┤
│ Sandbox: Yes    │ Sandbox: Yes    │ Sandbox: Yes    │
│ Webhook: Yes    │ Webhook: Yes    │ Callback: Yes   │
├─────────────────┼─────────────────┼─────────────────┤
│ Settlement:     │ Settlement:     │ Settlement:     │
│ D+1 to D+2      │ D+1             │ D+2 to D+3      │
├─────────────────┼─────────────────┼─────────────────┤
│ Fee: ~2-3%      │ Fee: ~1.5-3%    │ Fee: ~2-3%      │
└─────────────────┴─────────────────┴─────────────────┘
```

### Integration Flow

```text
PAYMENT FLOW (Server-to-Server):
────────────────────────────────

┌─────────────┐                  ┌─────────────┐
│   CLIENT    │                  │   SERVER    │
│   (App/Web) │                  │  (Backend)  │
└─────────────┘                  └─────────────┘
       │                                │
       │ 1. Create Order                │
       │ {items, amount, customer}      │
       ├───────────────────────────────►│
       │                                │
       │                                │ 2. Create Transaction
       │                                │    └──► Payment Gateway
       │                                │
       │ 3. Return Payment Token/URL    │
       │◄───────────────────────────────┤
       │                                │
       │ 4. Redirect to Payment Page    │
       │    ───────────────────────────►│ Payment Gateway
       │                                │
       │ 5. User Completes Payment      │
       │    (OTP, PIN, Scan QR)         │
       │                                │
       │                                │ 6. Webhook Notification
       │                                │◄───── Payment Gateway
       │                                │
       │ 7. Update Order Status         │
       │◄───────────────────────────────┤
       │                                │
       │ 8. Show Success Page           │
       ▼                                ▼
```

### Midtrans Integration

```text
MIDTRANS SNAP (Hosted):
───────────────────────

Endpoints:
├── Sandbox: https://app.sandbox.midtrans.com/snap/v1
└── Production: https://app.midtrans.com/snap/v1

Create Transaction:
POST /transactions
Headers:
  Authorization: Basic base64(ServerKey:)
  Content-Type: application/json

Request Body:
{
  "transaction_details": {
    "order_id": "ORDER-12345",
    "gross_amount": 150000
  },
  "customer_details": {
    "first_name": "Budi",
    "email": "budi@example.com",
    "phone": "081234567890"
  },
  "item_details": [
    {
      "id": "ITEM-001",
      "price": 100000,
      "quantity": 1,
      "name": "Product A"
    },
    {
      "id": "ITEM-002",
      "price": 50000,
      "quantity": 1,
      "name": "Product B"
    }
  ]
}

Response:
{
  "token": "snap-token-xxx",
  "redirect_url": "https://app.midtrans.com/snap/v2/vtweb/xxx"
}

CLIENT INTEGRATION:
snap.pay('snap-token-xxx', {
  onSuccess: function(result) { /* success */ },
  onPending: function(result) { /* pending */ },
  onError: function(result) { /* error */ },
  onClose: function() { /* closed without completing */ }
});
```

### Virtual Account

```text
VIRTUAL ACCOUNT FLOW:
─────────────────────

1. Customer selects "Bank Transfer"
2. System creates VA number
3. Customer receives unique VA number
4. Customer transfers via ATM/Mobile Banking
5. Payment gateway detects payment
6. Webhook sent to merchant

VA FORMAT:
┌────────────────────────────────────────┐
│ Bank: BCA                              │
│ VA Number: 70012 1234567890123         │
│ Amount: Rp 150.000                     │
│ Expires: 24 hours                      │
└────────────────────────────────────────┘

SUPPORTED BANKS:
├── BCA (prefix: 70012)
├── BNI (prefix: 8808)
├── Mandiri (prefix: 70088)
├── BRI (prefix: 77777)
├── Permata (16 digits)
└── CIMB Niaga

REQUEST (Midtrans):
{
  "payment_type": "bank_transfer",
  "bank_transfer": {
    "bank": "bca"
  },
  "transaction_details": {
    "order_id": "ORDER-12345",
    "gross_amount": 150000
  }
}

RESPONSE:
{
  "va_numbers": [
    {
      "bank": "bca",
      "va_number": "70012123456789"
    }
  ],
  "transaction_status": "pending"
}
```

### E-Wallet Integration

```text
E-WALLET FLOW:
──────────────

GOPAY:
1. Create charge → get QR code URL or deeplink
2. Customer scans QR or opens GoPay app
3. Customer confirms payment with PIN
4. Webhook notification

GOPAY REQUEST (Midtrans):
{
  "payment_type": "gopay",
  "gopay": {
    "enable_callback": true,
    "callback_url": "yourapp://payment/callback"
  },
  "transaction_details": {
    "order_id": "ORDER-12345",
    "gross_amount": 150000
  }
}

RESPONSE:
{
  "actions": [
    {
      "name": "generate-qr-code",
      "method": "GET",
      "url": "https://api.midtrans.com/v2/gopay/xxx/qr-code"
    },
    {
      "name": "deeplink-redirect",
      "method": "GET",
      "url": "gojek://gopay/merchanttransfer?..."
    }
  ]
}

OVO (via Xendit):
{
  "external_id": "ORDER-12345",
  "amount": 150000,
  "phone": "081234567890",
  "ewallet_type": "OVO"
}
→ Customer receives OVO push notification

DANA (via Xendit):
{
  "external_id": "ORDER-12345",
  "amount": 150000,
  "callback_url": "https://yoursite.com/callback",
  "redirect_url": "https://yoursite.com/success",
  "ewallet_type": "DANA"
}
→ Customer redirected to DANA auth page
```

### QRIS (QR Indonesian Standard)

```text
QRIS PAYMENT:
─────────────

Single QR code accepted by ALL:
├── Bank mobile apps
├── E-wallets (GoPay, OVO, DANA, etc.)
└── Any QRIS-compatible app

FLOW:
1. Merchant generates QRIS
2. Customer scans with any supported app
3. Customer enters amount (dynamic) or confirms (static)
4. Payment processed
5. Webhook notification

QRIS TYPES:
├── Static (reusable, any amount)
└── Dynamic (one-time, fixed amount)

REQUEST (Midtrans):
{
  "payment_type": "qris",
  "transaction_details": {
    "order_id": "ORDER-12345",
    "gross_amount": 150000
  }
}

RESPONSE:
{
  "actions": [
    {
      "name": "generate-qr-code",
      "method": "GET",
      "url": "https://api.midtrans.com/v2/qris/xxx/qr-code"
    }
  ],
  "qr_string": "00020101021226610014ID.CO.QRIS..."
}

DISPLAY QR:
├── As image from URL
├── As QR generated from qr_string
└── Valid for 15-30 minutes typically
```

### Webhook Handling

```text
WEBHOOK NOTIFICATION:
─────────────────────

Midtrans sends POST to your webhook URL:

POST /webhooks/midtrans
{
  "transaction_time": "2026-02-02 08:00:00",
  "transaction_status": "settlement",
  "transaction_id": "xxxxx",
  "status_code": "200",
  "signature_key": "sha512hash...",
  "payment_type": "gopay",
  "order_id": "ORDER-12345",
  "gross_amount": "150000.00",
  "fraud_status": "accept"
}

TRANSACTION STATUSES:
├── pending - Waiting for payment
├── settlement - Payment successful ✓
├── capture - Card payment captured
├── deny - Payment denied
├── cancel - Cancelled by merchant
├── expire - Expired
└── refund - Refunded

SIGNATURE VERIFICATION:
hash = SHA512(order_id + status_code + gross_amount + server_key)
if (hash !== signature_key) reject

IDEMPOTENCY:
├── Store transaction_id
├── Check if already processed
└── Avoid double crediting
```

### Xendit Integration

```text
XENDIT API STRUCTURE:
─────────────────────

Base URL: https://api.xendit.co

INVOICE (All-in-one):
POST /v2/invoices
{
  "external_id": "ORDER-12345",
  "amount": 150000,
  "payer_email": "customer@email.com",
  "description": "Payment for Order #12345",
  "invoice_duration": 86400,
  "currency": "IDR",
  "payment_methods": ["OVO", "DANA", "QRIS", "BCA"]
}

Response:
{
  "id": "invoice-id",
  "invoice_url": "https://checkout.xendit.co/...",
  "expiry_date": "2026-02-03T08:00:00Z",
  "status": "PENDING"
}

WEBHOOK:
{
  "id": "invoice-id",
  "external_id": "ORDER-12345",
  "status": "PAID",
  "paid_amount": 150000,
  "payment_method": "OVO",
  "payment_channel": "OVO"
}
```

### Security & Compliance

```text
SECURITY REQUIREMENTS:
──────────────────────

1. SIGNATURE VERIFICATION
   - Always verify webhook signatures
   - Use server key, never expose client key

2. HTTPS ONLY
   - All API calls over HTTPS
   - Webhook endpoints must be HTTPS

3. ENVIRONMENT SEPARATION
   - Sandbox for testing
   - Production for live

4. CREDENTIAL STORAGE
   - Never hardcode keys
   - Use environment variables
   - Rotate keys periodically

5. PCI DSS
   - Use hosted payment pages
   - Never store card data on your server
   - Use tokenization

TESTING:
├── Use sandbox/test environment
├── Midtrans test cards:
│   ├── 4811 1111 1111 1114 (success)
│   ├── 4911 1111 1111 1113 (challenge)
│   └── 4411 1111 1111 1118 (deny)
└── Xendit test numbers available in docs
```

### Error Handling

```text
COMMON ERRORS:
──────────────

400 - Bad Request (invalid params)
401 - Unauthorized (wrong API key)
402 - Payment Required (insufficient balance)
404 - Not Found (invalid endpoint)
409 - Conflict (duplicate order_id)
500 - Server Error (retry)

RETRY STRATEGY:
├── Exponential backoff
├── Max 3-5 retries
└── Idempotency keys

FAILED PAYMENT HANDLING:
1. Show clear error message
2. Allow retry with new order_id
3. Log for investigation
4. Notify customer via email/SMS
```

## Best Practices

### ✅ Do This

- ✅ Always verify webhook signatures
- ✅ Use idempotency to prevent double charge
- ✅ Implement timeout handling (VA, QRIS)
- ✅ Show clear payment instructions to users
- ✅ Support multiple payment methods

### ❌ Avoid This

- ❌ Don't expose server keys to frontend
- ❌ Don't trust client-side payment status
- ❌ Don't skip webhook verification
- ❌ Don't hardcode API credentials

## Related Skills

- `@payment-integration-specialist` - General payment
- `@senior-backend-developer` - API development
- `@fintech-developer` - Financial systems
- `@e-commerce-developer` - Online stores

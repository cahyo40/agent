---
name: api-documentation-specialist
description: "API documentation specialist creating OpenAPI/Swagger specs, developer guides, SDK documentation, and API reference materials with excellent developer experience"
---

# API Documentation Specialist

## Overview

This skill transforms you into an **API Documentation Specialist** who creates comprehensive, developer-friendly API documentation including OpenAPI/Swagger specifications, getting started guides, SDK documentation, and API reference materials. You'll master technical writing best practices, API design documentation, and developer experience optimization.

## When to Use This Skill

- Use when creating API documentation for new services
- Use when writing OpenAPI/Swagger specifications
- Use when improving existing API documentation
- Use when creating SDK documentation and code examples
- Use when designing developer portals and API reference guides

---

## Part 1: API Documentation Fundamentals

### 1.1 Documentation Types

| Type | Purpose | Audience |
|------|---------|----------|
| **Getting Started** | Quick start, first API call | New developers |
| **API Reference** | Complete endpoint documentation | All developers |
| **Tutorials** | Step-by-step guides, use cases | Learning developers |
| **Conceptual Guides** | Architecture, authentication, patterns | All developers |
| **SDK Documentation** | Language-specific libraries | SDK users |
| **Changelog** | Version changes, migrations | Existing users |

### 1.2 Documentation Quality Attributes

```
┌─────────────────────────────────────────────────────────────┐
│              Great API Documentation                         │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  ACCURATE          COMPLETE          CONSISTENT             │
│  • Works as        • All endpoints   • Same style           │
│    documented      • Error codes     • Same terminology     │
│  • Up-to-date      • Examples        • Same structure       │
│                                                              │
│  CLEAR             CONCISE           SEARCHABLE             │
│  • Easy to         • No fluff        • Good navigation      │
│    understand      • Get to point    • Full-text search     │
│  • Simple words    • One idea/sentence                     │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

---

## Part 2: OpenAPI Specification

### 2.1 OpenAPI Structure

```yaml
openapi: 3.0.3
info:
  title: Payment API
  description: API for processing payments and managing transactions
  version: 2.0.0
  contact:
    name: API Support
    email: api-support@example.com
    url: https://developer.example.com/support
  license:
    name: MIT
    url: https://opensource.org/licenses/MIT

servers:
  - url: https://api.example.com/v2
    description: Production server
  - url: https://staging-api.example.com/v2
    description: Staging server

tags:
  - name: Payments
    description: Payment processing operations
  - name: Refunds
    description: Refund management operations

paths:
  /payments:
    post:
      tags:
        - Payments
      summary: Create a payment
      description: Process a new payment transaction
      operationId: createPayment
      requestBody:
        required: true
        content:
          application/json:
            schema:
              $ref: '#/components/schemas/PaymentRequest'
      responses:
        '201':
          description: Payment created successfully
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/Payment'
        '400':
          description: Invalid request
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/Error'
        '401':
          description: Unauthorized
        '422':
          description: Validation error
      security:
        - BearerAuth: []

components:
  securitySchemes:
    BearerAuth:
      type: http
      scheme: bearer
      bearerFormat: JWT
  
  schemas:
    PaymentRequest:
      type: object
      required:
        - amount
        - currency
        - paymentMethod
      properties:
        amount:
          type: number
          format: float
          example: 99.99
          description: Payment amount in specified currency
        currency:
          type: string
          enum: [USD, EUR, GBP, IDR]
          example: USD
          description: ISO 4217 currency code
        paymentMethod:
          $ref: '#/components/schemas/PaymentMethod'
        metadata:
          type: object
          description: Additional metadata for the payment
    
    Payment:
      allOf:
        - $ref: '#/components/schemas/PaymentRequest'
        - type: object
          properties:
            id:
              type: string
              format: uuid
              example: "550e8400-e29b-41d4-a716-446655440000"
            status:
              type: string
              enum: [pending, processing, completed, failed]
              example: completed
            createdAt:
              type: string
              format: date-time
            updatedAt:
              type: string
              format: date-time
    
    PaymentMethod:
      type: object
      oneOf:
        - $ref: '#/components/schemas/CardPayment'
        - $ref: '#/components/schemas/BankTransfer'
    
    CardPayment:
      type: object
      required:
        - type
        - cardNumber
        - expiryMonth
        - expiryYear
        - cvv
      properties:
        type:
          type: string
          const: card
        cardNumber:
          type: string
          pattern: '^[0-9]{13,19}$'
          example: "4111111111111111"
        expiryMonth:
          type: integer
          minimum: 1
          maximum: 12
          example: 12
        expiryYear:
          type: integer
          minimum: 2024
          example: 2025
        cvv:
          type: string
          pattern: '^[0-9]{3,4}$'
          example: "123"
    
    BankTransfer:
      type: object
      required:
        - type
        - bankCode
        - accountNumber
      properties:
        type:
          type: string
          const: bank_transfer
        bankCode:
          type: string
          example: "BCA"
        accountNumber:
          type: string
          example: "1234567890"
    
    Error:
      type: object
      required:
        - code
        - message
      properties:
        code:
          type: string
          example: "VALIDATION_ERROR"
        message:
          type: string
          example: "Invalid card number"
        details:
          type: array
          items:
            type: object
            properties:
              field:
                type: string
              message:
                type: string
```

### 2.2 Request/Response Examples

```yaml
paths:
  /payments/{paymentId}:
    get:
      summary: Get payment details
      parameters:
        - name: paymentId
          in: path
          required: true
          schema:
            type: string
            format: uuid
          description: The payment ID
          example: "550e8400-e29b-41d4-a716-446655440000"
      responses:
        '200':
          description: Payment details retrieved successfully
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/Payment'
              examples:
                completed-payment:
                  summary: Completed payment
                  value:
                    id: "550e8400-e29b-41d4-a716-446655440000"
                    amount: 99.99
                    currency: USD
                    status: completed
                    paymentMethod:
                      type: card
                      cardNumber: "************1111"
                      cardBrand: visa
                    createdAt: "2024-01-15T10:30:00Z"
                failed-payment:
                  summary: Failed payment
                  value:
                    id: "660e8400-e29b-41d4-a716-446655440001"
                    amount: 150.00
                    currency: USD
                    status: failed
                    failureReason: "Insufficient funds"
                    paymentMethod:
                      type: card
                      cardNumber: "************4242"
                      cardBrand: mastercard
                    createdAt: "2024-01-15T11:00:00Z"
```

### 2.3 Error Response Standardization

```yaml
components:
  schemas:
    ErrorResponse:
      type: object
      required:
        - error
      properties:
        error:
          type: object
          properties:
            code:
              type: string
              description: Machine-readable error code
              enum:
                - VALIDATION_ERROR
                - AUTHENTICATION_ERROR
                - AUTHORIZATION_ERROR
                - NOT_FOUND
                - RATE_LIMIT_EXCEEDED
                - INTERNAL_ERROR
            message:
              type: string
              description: Human-readable error message
            details:
              type: array
              description: Additional error details (for validation errors)
              items:
                type: object
                properties:
                  field:
                    type: string
                    description: Field that caused the error
                  code:
                    type: string
                    description: Field-specific error code
                  message:
                    type: string
                    description: Field-specific error message
            requestId:
              type: string
              format: uuid
              description: Request ID for debugging
            documentation_url:
              type: string
              format: uri
              description: Link to relevant documentation

# Example error responses
examples:
  validation-error:
    summary: Validation Error
    value:
      error:
        code: VALIDATION_ERROR
        message: "Request validation failed"
        details:
          - field: "amount"
            code: "required"
            message: "Amount is required"
          - field: "cardNumber"
            code: "invalid_format"
            message: "Card number must be 13-19 digits"
        requestId: "550e8400-e29b-41d4-a716-446655440000"
        documentation_url: "https://docs.example.com/api/errors#validation-error"
  
  rate-limit-error:
    summary: Rate Limit Exceeded
    value:
      error:
        code: RATE_LIMIT_EXCEEDED
        message: "Too many requests"
        details:
          limit: 100
          remaining: 0
          retryAfter: 60
        requestId: "660e8400-e29b-41d4-a716-446655440001"
```

---

## Part 3: Getting Started Guide

### 3.1 Structure

```markdown
# Getting Started

## Introduction

Welcome to the [API Name] API! This guide will help you make your first API call in under 5 minutes.

## Prerequisites

- [Account registration](link)
- API credentials (API key or OAuth)
- HTTP client (curl, Postman, or SDK)

## Quick Start

### Step 1: Get Your API Key

1. Log in to your dashboard
2. Navigate to Settings → API Keys
3. Click "Create New API Key"
4. Copy and securely store your key

```bash
sk_live_xxxxxxxxxxxxxxxxxxxx
```

⚠️ **Important:** Never share your API key or commit it to version control.

### Step 2: Make Your First Request

```bash
curl -X GET https://api.example.com/v2/payments \
  -H "Authorization: Bearer sk_live_xxxxxxxxxxxxxxxxxxxx" \
  -H "Content-Type: application/json"
```

### Step 3: Parse the Response

```json
{
  "data": [
    {
      "id": "pay_123",
      "amount": 99.99,
      "currency": "USD",
      "status": "completed"
    }
  ],
  "hasMore": false
}
```

## Next Steps

- [Authentication Guide](/docs/auth)
- [API Reference](/docs/api-reference)
- [SDKs and Libraries](/docs/sdks)
- [Code Examples](/docs/examples)
```

### 3.2 Code Examples (Multi-Language)

```markdown
## Code Examples

### JavaScript (Node.js)

```javascript
const stripe = require('stripe')('sk_test_...');

async function createPayment() {
  const payment = await stripe.payments.create({
    amount: 9999,
    currency: 'usd',
    payment_method: 'pm_card_visa',
  });
  
  console.log('Payment created:', payment.id);
}
```

### Python

```python
import stripe

stripe.api_key = 'sk_test_...'

def create_payment():
    payment = stripe.PaymentIntent.create(
        amount=9999,
        currency='usd',
        payment_method='pm_card_visa',
    )
    
    print(f'Payment created: {payment.id}')
```

### PHP

```php
\Stripe\Stripe::setApiKey('sk_test_...');

$payment = \Stripe\PaymentIntent::create([
    'amount' => 9999,
    'currency' => 'usd',
    'payment_method' => 'pm_card_visa',
]);

echo "Payment created: {$payment->id}";
```

### Go

```go
import "github.com/stripe/stripe-go/v72"

func createPayment() error {
    stripe.Key = "sk_test_..."
    
    params := &stripe.PaymentIntentParams{
        Amount: stripe.Int64(9999),
        Currency: stripe.String(string(stripe.CurrencyUSD)),
        PaymentMethod: stripe.String("pm_card_visa"),
    }
    
    payment, err := paymentintent.New(params)
    if err != nil {
        return err
    }
    
    fmt.Printf("Payment created: %s\n", payment.ID)
    return nil
}
```
```

---

## Part 4: Authentication Documentation

### 4.1 Authentication Methods

```markdown
# Authentication

The API supports multiple authentication methods depending on your use case.

## API Key Authentication

API keys are the simplest way to authenticate. Include your key in the Authorization header:

```bash
curl -X GET https://api.example.com/v2/resource \
  -H "Authorization: Bearer sk_live_xxxxxxxxxxxxx"
```

### Key Types

| Key Type | Prefix | Permissions | Use Case |
|----------|--------|-------------|----------|
| Secret Key | `sk_live_` | Full access | Server-side applications |
| Publishable Key | `pk_live_` | Limited access | Client-side applications |
| Restricted Key | `rk_live_` | Custom permissions | Specific operations |

## OAuth 2.0

For applications accessing user data, use OAuth 2.0:

### Authorization Code Flow

```
1. Redirect to authorization URL
   GET https://api.example.com/oauth/authorize
     ?client_id=YOUR_CLIENT_ID
     &redirect_uri=https://yourapp.com/callback
     &response_type=code
     &scope=read write

2. User authorizes your application

3. Exchange code for token
   POST https://api.example.com/oauth/token
   Content-Type: application/x-www-form-urlencoded
   
   grant_type=authorization_code
   &code=AUTH_CODE
   &client_id=YOUR_CLIENT_ID
   &client_secret=YOUR_CLIENT_SECRET
   &redirect_uri=https://yourapp.com/callback

4. Receive access token
   {
     "access_token": "eyJhbGciOiJIUzI1NiIs...",
     "token_type": "Bearer",
     "expires_in": 3600,
     "refresh_token": "dGhpcyBpcyBhIHJlZnJlc2g..."
   }
```

## JWT Authentication

For service-to-service communication:

```javascript
const jwt = require('jsonwebtoken');

const token = jwt.sign(
  { 
    sub: 'service-id',
    aud: 'api.example.com',
    iss: 'your-service',
    exp: Math.floor(Date.now() / 1000) + 3600
  },
  'your-secret-key',
  { algorithm: 'HS256' }
);

// Use in requests
fetch('https://api.example.com/v2/resource', {
  headers: {
    'Authorization': `Bearer ${token}`
  }
});
```
```

---

## Part 5: SDK Documentation

### 5.1 SDK Structure

```markdown
# SDK Documentation

## Installation

### npm

```bash
npm install @example/api-client
```

### yarn

```bash
yarn add @example/api-client
```

### CDN

```html
<script src="https://cdn.example.com/api-client/v2/client.min.js"></script>
```

## Quick Start

```javascript
import { ExampleClient } from '@example/api-client';

const client = new ExampleClient({
  apiKey: 'sk_live_xxxxxxxxxxxxx',
  timeout: 30000,
});

// Make a request
const payments = await client.payments.list({
  limit: 10,
  status: 'completed',
});

console.log(payments.data);
```

## Configuration

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `apiKey` | string | required | Your API key |
| `baseUrl` | string | `https://api.example.com/v2` | API base URL |
| `timeout` | number | 30000 | Request timeout in ms |
| `retries` | number | 3 | Number of retries on failure |
| `debug` | boolean | false | Enable debug logging |

## Error Handling

```javascript
import { 
  ApiError, 
  AuthenticationError, 
  ValidationError,
  RateLimitError 
} from '@example/api-client';

try {
  await client.payments.create({ amount: 100 });
} catch (error) {
  if (error instanceof ValidationError) {
    console.error('Validation failed:', error.details);
  } else if (error instanceof RateLimitError) {
    console.log('Retry after:', error.retryAfter);
  } else if (error instanceof ApiError) {
    console.error('API error:', error.message);
  } else {
    console.error('Unknown error:', error);
  }
}
```
```

---

## Part 6: Developer Portal Best Practices

### 6.1 Portal Structure

```
Developer Portal
├── Home
│   ├── Overview
│   ├── Quick Start
│   └── Status Page
├── Documentation
│   ├── Getting Started
│   ├── Authentication
│   ├── API Reference
│   ├── SDKs
│   └── Tutorials
├── Support
│   ├── Community Forum
│   ├── Contact Support
│   └── System Status
├── Dashboard
│   ├── API Keys
│   ├── Usage Analytics
│   └── Billing
└── Changelog
    ├── Latest
    └── Archive
```

### 6.2 Interactive Elements

```markdown
## Try It Out

Most API documentation should include interactive examples:

### Request

```http
POST /v2/payments HTTP/1.1
Host: api.example.com
Authorization: Bearer sk_test_xxxxx
Content-Type: application/json

{
  "amount": 99.99,
  "currency": "USD"
}
```

### Response

```json
{
  "id": "pay_123",
  "amount": 99.99,
  "status": "completed"
}
```

[▶️ Try in API Explorer]
```

---

## Best Practices

### ✅ Do This

- ✅ Include working code examples in multiple languages
- ✅ Provide clear error messages with solutions
- ✅ Use consistent terminology throughout
- ✅ Include request/response examples for every endpoint
- ✅ Document rate limits and quotas
- ✅ Provide SDK/client libraries when possible
- ✅ Keep documentation versioned with API
- ✅ Include a changelog for updates

### ❌ Avoid This

- ❌ Incomplete endpoint documentation
- ❌ Outdated examples that don't work
- ❌ Inconsistent naming conventions
- ❌ Missing error documentation
- ❌ No authentication examples
- ❌ Assuming prior knowledge
- ❌ Walls of text without examples

---

## Related Skills

- `@senior-technical-writer` - Technical writing
- `@api-design-specialist` - API design patterns
- `@senior-backend-developer` - Backend development
- `@document-generator` - Documentation generation
- `@senior-typescript-developer` - TypeScript SDKs

---
name: insurtech-developer
description: "Expert in insurance technology including claims processing, digital underwriting, and policy management"
---

# Insurtech Developer

## Overview

This skill transforms you into an **Insurance Technology Developer**. You will master **Policy Management**, **Claims Processing**, **Underwriting Automation**, and **Regulatory Compliance** for building modern insurance platforms.

## When to Use This Skill

- Use when digitizing insurance policy management
- Use when automating claims processing workflows
- Use when building underwriting risk models
- Use when integrating with third-party data providers
- Use when ensuring regulatory compliance (HIPAA, GDPR)

---

## Part 1: Insurance Domain Concepts

### 1.1 Core Entities

| Entity | Description |
|--------|-------------|
| **Policy** | Contract between insurer and policyholder |
| **Premium** | Periodic payment for coverage |
| **Claim** | Request for payout when event occurs |
| **Underwriting** | Risk assessment before issuing policy |
| **Coverage** | What is protected (life, auto, health) |

### 1.2 Insurance Product Types

| Type | Coverage | Example |
|------|----------|---------|
| **Health** | Medical expenses | Hospital stays, prescriptions |
| **Auto** | Vehicle damage, liability | Collision, theft |
| **Life** | Death benefit | Term life, whole life |
| **Property** | Home/building damage | Fire, flood |
| **Travel** | Trip issues | Cancellation, medical |

---

## Part 2: Policy Management System

### 2.1 Policy Lifecycle

```
Quote Request -> Underwriting -> Policy Issued -> Premium Collection -> Renewal/Cancellation
```

### 2.2 Data Model (Simplified)

```sql
CREATE TABLE policies (
    id UUID PRIMARY KEY,
    policyholder_id UUID NOT NULL,
    product_type VARCHAR(50),
    coverage_amount DECIMAL(12,2),
    premium_monthly DECIMAL(10,2),
    start_date DATE,
    end_date DATE,
    status VARCHAR(20)  -- 'active', 'expired', 'cancelled'
);

CREATE TABLE policyholders (
    id UUID PRIMARY KEY,
    name VARCHAR(100),
    email VARCHAR(100),
    dob DATE,
    address JSONB
);
```

### 2.3 Quote Engine

```python
def calculate_premium(coverage_amount, risk_score, age, product_type):
    base_rate = BASE_RATES[product_type]
    age_factor = 1 + (age - 25) * 0.02 if age > 25 else 1
    risk_factor = 1 + (risk_score / 100)
    
    return coverage_amount * base_rate * age_factor * risk_factor / 12
```

---

## Part 3: Claims Processing

### 3.1 Claim Workflow

```
Claim Submitted -> Document Collection -> Validation -> Adjudication -> Payout/Denial
```

### 3.2 Straight-Through Processing (STP)

Automate simple claims with no human intervention.

- **Rule Engine**: "If claim < $500 and photo verified, auto-approve."
- **ML Fraud Detection**: Flag anomalies for manual review.

### 3.3 Document Processing

- **OCR**: Extract data from uploaded receipts.
- **NLP**: Parse medical reports for ICD-10 codes.
- **Photo AI**: Damage assessment from vehicle photos.

---

## Part 4: Underwriting Automation

### 4.1 Risk Data Sources

| Source | Data |
|--------|------|
| **MIB** | Medical history (US) |
| **CLUE** | Claims history (property/auto) |
| **DMV** | Driving record |
| **Credit Bureau** | Credit-based insurance score |
| **IoT/Telematics** | Driving behavior, smart home sensors |

### 4.2 ML Risk Models

```python
from sklearn.ensemble import GradientBoostingClassifier

features = ['age', 'credit_score', 'claims_history', 'location_risk']
target = 'approved'

model = GradientBoostingClassifier()
model.fit(X_train, y_train)
```

### 4.3 Decision Factors

Output: Risk Score (1-100) + Recommended Premium Tier.

---

## Part 5: Compliance & Regulations

### 5.1 Key Regulations

| Region | Regulation |
|--------|------------|
| **US** | State-specific DOI, HIPAA (health) |
| **EU** | GDPR, Solvency II |
| **India** | IRDAI regulations |

### 5.2 Data Protection

- **Encrypt PII**: AES-256 at rest, TLS in transit.
- **Audit Logs**: Who accessed what, when.
- **Data Retention**: Delete expired policy data per regulation.

---

## Part 6: Best Practices Checklist

### ✅ Do This

- ✅ **Versioned Products**: Policy terms change; keep historical versions.
- ✅ **Idempotent Payments**: Avoid double-charging premiums.
- ✅ **Explain AI Decisions**: Regulators require explainability.

### ❌ Avoid This

- ❌ **Hardcoded Business Rules**: Use rule engines (Drools, custom).
- ❌ **Manual Document Handling**: Automate with OCR/NLP.
- ❌ **Ignoring State/Country Variations**: Requirements differ significantly.

---

## Related Skills

- `@fintech-developer` - Payment processing
- `@senior-database-engineer-sql` - Data modeling
- `@senior-ai-ml-engineer` - Risk models

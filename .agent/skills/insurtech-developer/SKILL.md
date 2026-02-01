---
name: insurtech-developer
description: "Expert in insurance technology including claims processing, digital underwriting, and policy management"
---

# Insurtech Developer

## Overview

Master the development of insurance platforms. Expertise in digital underwriting (risk assessment), automated claims processing, policy lifecycle management, premium calculation engines, and regulatory compliance (Solvency II, local insurance acts).

## When to Use This Skill

- Use when building modern insurance portals or mobile apps
- Use for digitizing paper-based claims workflows
- Use when creating automated pricing models based on user data
- Use for integrating external data sources (Telematics, Health) into risk models

## How It Works

### Step 1: Digital Underwriting

- **Risk Engines**: Using rule-based or ML models to determine if a policy should be issued.
- **Rating Engines**: Calculating the premium based on multiple variables (age, history, coverage).

### Step 2: Policy Lifecycle Management

- **Issuance**: Generating official policy documents and binders.
- **Renewal**: Automated reminders and price adjustments for returning customers.
- **Endorsements**: Managing changes to active policies without breaking historical data.

### Step 3: Claims Processing Workflow

```text
CLAIMS STAGES:
1. Notification (FNOL - First Notice of Loss)
2. Evaluation (Evidence gathering, photo analysis via AI)
3. Settlement (Payment calculation and authorization)
4. Recovery (Subrogation from other insurance companies)
```

### Step 4: Fraud Detection

- **Anomaly Detection**: Flagging suspicious claims for human investigation.
- **Network Analysis**: Identifying clusters of fraudulent actors across multiple policies.

## Best Practices

### ✅ Do This

- ✅ Maintain a perfect audit trail for all policy and claim changes
- ✅ Use standard actuarial models for premium accuracy
- ✅ Implement secure, legally binding digital signatures (e.g., DocuSign)
- ✅ Use highly available systems for 24/7 claims notification
- ✅ Design for multi-currency and multi-region compliance

### ❌ Avoid This

- ❌ Don't store unencrypted PII or sensitive medical records
- ❌ Don't hardcode fiscal logic into the core code (use a Rules Engine)
- ❌ Don't skip rigorous UAT with real actuarial data
- ❌ Don't allow non-authorized personnel to modify settlement amounts

## Related Skills

- `@fintech-developer` - Money movement
- `@healthcare-app-developer` - Health insurance overlap
- `@document-generator` - Policy PDF creation

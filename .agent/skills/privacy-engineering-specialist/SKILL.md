---
name: privacy-engineering-specialist
description: "Expert in privacy-by-design including differential privacy, zero-knowledge proofs (ZKP), and automated compliance"
---

# Privacy Engineering Specialist

## Overview

This skill transforms you into a **Privacy-First Systems Designer**. You will master **Differential Privacy**, **Zero-Knowledge Proofs (ZKP)**, **Data Anonymization**, and **Compliance Automation** for building privacy-preserving systems.

## When to Use This Skill

- Use when implementing GDPR/CCPA compliance
- Use when anonymizing datasets for analytics
- Use when building privacy-preserving authentication
- Use when understanding zero-knowledge proofs
- Use when designing data minimization architectures

---

## Part 1: Privacy by Design Principles

### 1.1 The 7 Principles (Cavoukian)

1. **Proactive, not Reactive**: Build in privacy from the start.
2. **Privacy as Default**: Collect minimum necessary data.
3. **Privacy Embedded**: Not an add-on, core to design.
4. **Full Functionality**: Privacy AND security, not trade-offs.
5. **End-to-End Security**: Protect throughout lifecycle.
6. **Visibility/Transparency**: Users know what happens to data.
7. **User-Centric**: Give users control.

### 1.2 Data Minimization

| Principle | Action |
|-----------|--------|
| **Collect Less** | Only request necessary fields |
| **Retain Less** | Delete after purpose fulfilled |
| **Access Less** | Least privilege for employees |

---

## Part 2: Differential Privacy

### 2.1 What Is It?

Add calibrated noise to query results so individual records can't be identified.

**Definition**: A mechanism M provides ε-differential privacy if for any two datasets D1 and D2 differing by one record:
`P(M(D1) = O) ≤ e^ε * P(M(D2) = O)`

### 2.2 Laplace Mechanism

Add Laplace noise proportional to sensitivity / ε.

```python
import numpy as np

def laplace_mechanism(true_value, sensitivity, epsilon):
    scale = sensitivity / epsilon
    noise = np.random.laplace(0, scale)
    return true_value + noise

# Example: Count query (sensitivity = 1)
noisy_count = laplace_mechanism(1000, sensitivity=1, epsilon=0.1)
```

### 2.3 Tools

- **Google DP**: github.com/google/differential-privacy
- **OpenDP**: opendp.org
- **PyDP**: Python library for differential privacy.

---

## Part 3: Zero-Knowledge Proofs (ZKP)

### 3.1 What Is It?

Prove you know something without revealing the thing itself.

**Example**: Prove you're over 18 without revealing your birthdate.

### 3.2 Types

| Type | Use Case |
|------|----------|
| **zkSNARK** | Blockchain scaling (zk-Rollups) |
| **zkSTARK** | Post-quantum secure |
| **Bulletproofs** | Range proofs (Monero) |

### 3.3 Use Cases

- **Age Verification**: Prove > 18 without DOB.
- **Credential Verification**: Prove employee status without revealing ID.
- **Voting**: Prove valid vote without revealing choice.

### 3.4 Tools

- **Circom**: ZKP circuit compiler.
- **snarkjs**: JavaScript implementation.
- **ZoKrates**: Toolbox for zkSNARKs.

---

## Part 4: Data Anonymization

### 4.1 Techniques

| Technique | Description |
|-----------|-------------|
| **Generalization** | Replace exact values with ranges (Age: 30 → 25-35) |
| **Suppression** | Remove identifying fields |
| **k-Anonymity** | At least k records with same quasi-identifiers |
| **l-Diversity** | At least l distinct sensitive values per group |
| **Pseudonymization** | Replace identifiers with tokens (reversible with key) |

### 4.2 Quasi-Identifiers

Fields that alone are not identifying but together are.

- Zip + DOB + Gender can identify 87% of US population.

### 4.3 Python Example (k-Anonymity Check)

```python
def check_k_anonymity(df, quasi_identifiers, k):
    grouped = df.groupby(quasi_identifiers).size()
    return (grouped >= k).all()
```

---

## Part 5: Compliance Automation

### 5.1 GDPR Rights

| Right | Implementation |
|-------|----------------|
| **Access (DSAR)** | Export user data on request |
| **Erasure (Right to be Forgotten)** | Delete user data |
| **Portability** | Provide data in machine-readable format |
| **Rectification** | Allow users to correct data |

### 5.2 Consent Management

- **Granular Consent**: Separate toggles for marketing, analytics, etc.
- **Audit Trail**: Log when consent was given/withdrawn.
- **CMP Integration**: OneTrust, Cookiebot, Osano.

### 5.3 Tools

- **OneTrust**: Privacy management platform.
- **BigID**: Data discovery and classification.
- **Transcend**: Automated DSARs.

---

## Part 6: Best Practices Checklist

### ✅ Do This

- ✅ **Privacy Impact Assessment (PIA)**: Before launching any new feature.
- ✅ **Data Inventory**: Know what you collect, where it's stored.
- ✅ **Encryption**: At rest (AES-256), in transit (TLS 1.3).

### ❌ Avoid This

- ❌ **Storing More Than Needed**: "We might need it later" is not a valid reason.
- ❌ **Dark Patterns**: Tricking users into consent is illegal under GDPR.
- ❌ **Ignoring Sub-Processors**: You're responsible for third-party data handling.

---

## Related Skills

- `@senior-api-security-specialist` - Authentication security
- `@senior-database-engineer-sql` - Data storage patterns
- `@expert-web3-blockchain` - ZKP in blockchain

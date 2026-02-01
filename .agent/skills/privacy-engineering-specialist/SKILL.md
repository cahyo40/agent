---
name: privacy-engineering-specialist
description: "Expert in privacy-by-design including differential privacy, zero-knowledge proofs (ZKP), and automated compliance"
---

# Privacy Engineering Specialist

## Overview

Master the integration of privacy into technical systems. Expertise in Privacy-by-Design, Differential Privacy, Zero-Knowledge Proofs (ZKP), homomorphic encryption, and building automated compliance-as-code (GDPR, CCPA).

## When to Use This Skill

- Use when handling sensitive user data (Financial, Healthcare, PII)
- Use when designing systems requiring "Need-to-Know" data access
- Use for implementing cryptographic proofs without revealing data
- Use when automating privacy impact assessments (PIA) in the dev lifecycle

## How It Works

### Step 1: Differential Privacy

- **Noise Injection**: Adding mathematical noise to datasets so individual records cannot be identified while maintaining statistical accuracy.
- **ε-Differential Privacy**: Measuring the privacy guarantee of a query.

### Step 2: Zero-Knowledge Proofs (ZKP)

```text
USE CASE:
A user can prove they are over 18 without 
revealing their actual birthdate to the application.
```

- **zk-SNARKs/zk-STARKs**: High-performance proofs for blockchain and identity systems.

### Step 3: Anonymization & Pseudonymization

- **K-Anonymity**: Ensuring a record is indistinguishable from at least k-1 other records.
- **Tokenization**: Replacing sensitive data with non-sensitive identifiers.

### Step 4: Compliance-as-Code

- **Privacy Linting**: Automatically detecting PII in logs or code.
- **Data Subject Access Request (DSAR) Automation**: Building systems that can instantly delete or export a user's entire data history on demand.

## Best Practices

### ✅ Do This

- ✅ Default to data minimization (collect only what is strictly necessary)
- ✅ Encrypt data at rest, in transit, and ideally in use (Homomorphic)
- ✅ Maintain a centralized "Data Map" of where user data lives
- ✅ Regularly perform "Privacy Red Teaming" (Re-identification attacks)
- ✅ Provide clear, granular privacy controls to end-users

### ❌ Avoid This

- ❌ Don't rely on simple "Hashing" as anonymization (it's easily reversed)
- ❌ Don't store encryption keys in the same location as the data
- ❌ Don't share sensitive raw datasets with third-party analytics
- ❌ Don't ignore "Shadow Data" (backups, logs, temporary files)

## Related Skills

- `@senior-cybersecurity-engineer` - Security overlap
- `@expert-web3-blockchain` - For ZKP applications
- `@senior-data-engineer` - Safe data pipelines

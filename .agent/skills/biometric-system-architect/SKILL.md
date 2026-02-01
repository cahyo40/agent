---
name: biometric-system-architect
description: "Expert in designing biometric authentication systems including FaceID, TouchID, and multi-modal biometric security"
---

# Biometric System Architect

## Overview

Master the design of secure and user-friendly biometric authentication. Expertise in facial recognition (FaceID), fingerprint (TouchID), iris scanning, palm vein patterns, and multi-modal fusion for high-security environments.

## When to Use This Skill

- Use when implementing biometric login in mobile or desktop apps
- Use when designing physical access control systems
- Use for high-security identity verification (banking, government)
- Use when navigating biometric data privacy and storage compliance

## How It Works

### Step 1: Data Capture & Liveness Detection

- **Anti-spoofing**: Detecting photos, videos, or 3D masks (Active vs. Passive liveness).
- **Depth Sensors**: Using IR and ToF (Time-of-Flight) cameras for physical volume verification.

### Step 2: Feature Extraction & Templates

- **Biometric Templates**: Converting raw sensor data into non-reversible mathematical representations (never store raw photos).
- **Minutiae Points**: Identifying unique patterns in fingerprints.

### Step 3: Security & Encryption

- **Secure Enclave**: Storing and processing biometric data in hardware-isolated environments (T.E.E).
- **Match-on-Chip**: Performing verification within the sensor hardware itself.

### Step 4: Performance Metrics

| Metric | Definition | Importance |
|--------|------------|------------|
| **FAR** | False Acceptance Rate | Security measure |
| **FRR** | False Rejection Rate | UX measure |
| **EER** | Equal Error Rate | Balanced performance indicator |

## Best Practices

### ✅ Do This

- ✅ Always implement liveness detection to prevent spoofing
- ✅ Encrypt biometric templates using salts and Pepper strings
- ✅ Provide fallback authentication (PIN/Password)
- ✅ Comply with local regulations (BIPA, GDPR, etc.)
- ✅ Use multi-modal fusion for extremely sensitive actions

### ❌ Avoid This

- ❌ Don't store biometric templates in standard databases or plain text
- ❌ Don't skip re-authentication for high-value transactions
- ❌ Don't use low-quality sensors in critical systems
- ❌ Don't lock out users forever without a secure manual recovery path

## Related Skills

- `@senior-cybersecurity-engineer` - Security fundamentals
- `@mobile-developer` - Implementation in apps
- `@computer-vision-specialist` - Biometric vision logic

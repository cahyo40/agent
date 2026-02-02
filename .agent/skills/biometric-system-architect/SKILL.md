---
name: biometric-system-architect
description: "Expert in designing biometric authentication systems including FaceID, TouchID, and multi-modal biometric security"
---

# Biometric System Architect

## Overview

This skill transforms you into a **Biometric Security Expert**. You will master **Fingerprint Recognition**, **Facial Recognition (FaceID)**, **Multi-Modal Biometrics**, and the **Security/Privacy** considerations for deploying biometric systems in production.

## When to Use This Skill

- Use when implementing passwordless authentication
- Use when building secure access control systems
- Use when integrating device biometrics (FaceID/TouchID)
- Use when designing attendance/time-tracking systems
- Use when understanding liveness detection and spoofing

---

## Part 1: Biometric Modalities

### 1.1 Common Types

| Modality | Accuracy | Spoofing Risk | Use Case |
|----------|----------|---------------|----------|
| **Fingerprint** | High | Medium | Mobile, Door locks |
| **Face** | High | Medium (2D), Low (3D) | Mobile, CCTV |
| **Iris** | Very High | Low | High-security facilities |
| **Voice** | Medium | High | Call centers |
| **Behavioral** | Medium | Low | Continuous auth |

### 1.2 On-Device vs Server-Side

| Approach | Pros | Cons |
|----------|------|------|
| **On-Device (LocalAuth)** | Private, fast | No cross-device sync |
| **Server-Side** | Centralized, auditable | Privacy risk, latency |

---

## Part 2: Mobile Integration (FaceID/TouchID)

### 2.1 iOS (LocalAuthentication Framework)

```swift
import LocalAuthentication

let context = LAContext()
var error: NSError?

if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
    context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "Unlock App") { success, error in
        if success {
            // Authenticated
        }
    }
}
```

### 2.2 Android (BiometricPrompt)

```kotlin
val biometricPrompt = BiometricPrompt(this, executor,
    object : BiometricPrompt.AuthenticationCallback() {
        override fun onAuthenticationSucceeded(result: BiometricPrompt.AuthenticationResult) {
            // Authenticated
        }
    })

val promptInfo = BiometricPrompt.PromptInfo.Builder()
    .setTitle("Login")
    .setNegativeButtonText("Cancel")
    .build()

biometricPrompt.authenticate(promptInfo)
```

### 2.3 Flutter (local_auth package)

```dart
final auth = LocalAuthentication();
final didAuth = await auth.authenticate(
  localizedReason: 'Authenticate to access',
  options: const AuthenticationOptions(biometricOnly: true),
);
```

---

## Part 3: Facial Recognition Systems

### 3.1 Pipeline

1. **Detection**: Find face in image (MTCNN, RetinaFace).
2. **Alignment**: Normalize face orientation.
3. **Embedding**: Extract 128-512 dim vector (ArcFace, FaceNet).
4. **Matching**: Compare embeddings (Cosine similarity).

### 3.2 Liveness Detection (Anti-Spoofing)

Prevent attacks using photos/videos/masks.

| Method | How |
|--------|-----|
| **Blink Detection** | Requires eye blink |
| **Head Movement** | "Turn left, nod" |
| **3D Depth (FaceID)** | Infrared dot projector |
| **Texture Analysis** | Detect print artifacts |

---

## Part 4: Security Considerations

### 4.1 Template Protection

Never store raw biometric data. Store only encrypted templates.

- **Cancelable Biometrics**: Transform template so it can be "revoked" if leaked.
- **Secure Enclave**: Use hardware-backed storage (TPM, Secure Element).

### 4.2 False Accept / False Reject Rates

| Metric | Meaning | Target |
|--------|---------|--------|
| **FAR** | Accept wrong person | < 0.001% |
| **FRR** | Reject correct person | < 1% |
| **EER** | Equal Error Rate | Lower is better |

### 4.3 Multi-Factor with Biometrics

Biometric = "Something you are" (Inherence).

- Combine with PIN (Knowledge) or Device (Possession) for MFA.

---

## Part 5: Privacy & Compliance

### 5.1 Regulations

- **GDPR (EU)**: Biometrics are "special category data". Explicit consent required.
- **BIPA (Illinois)**: Strict requirements for biometric data collection.
- **LGPD (Brazil)**: Similar to GDPR protections.

### 5.2 Best Practices

1. **Minimal Collection**: Only collect what you need.
2. **On-Device Processing**: Prefer local over cloud.
3. **Explicit Consent**: Clear opt-in, not opt-out.
4. **Retention Policy**: Delete after purpose fulfilled.

---

## Part 6: Best Practices Checklist

### ✅ Do This

- ✅ **Use Platform APIs**: LocalAuthentication (iOS), BiometricPrompt (Android). Don't build custom face recognition for mobile auth.
- ✅ **Implement Fallback**: Always allow PIN/password if biometrics fail.
- ✅ **Test Edge Cases**: Glasses, masks, lighting variations.

### ❌ Avoid This

- ❌ **Storing Raw Images**: Never store face photos for authentication.
- ❌ **2D Face Only**: Use 3D or liveness detection to prevent photo attacks.
- ❌ **Silent Fail**: Always inform user why authentication failed.

---

## Related Skills

- `@senior-api-security-specialist` - Authentication architecture
- `@computer-vision-specialist` - Face detection models
- `@senior-flutter-developer` - Mobile integration

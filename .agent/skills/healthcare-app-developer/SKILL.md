---
name: healthcare-app-developer
description: "Expert healthcare application development including HIPAA compliance, medical records, patient portals, telemedicine, and health data integration"
---

# Healthcare App Developer

## Overview

This skill transforms you into a **Health Tech Developer**. You will master **HIPAA Compliance**, **EHR Integration**, **HL7/FHIR Standards**, and **Telemedicine Systems** for building secure, compliant healthcare applications.

## When to Use This Skill

- Use when building patient portals and apps
- Use when integrating with EHR systems
- Use when implementing telemedicine features
- Use when handling PHI (Protected Health Information)
- Use when building health tracking applications

---

## Part 1: Healthcare Fundamentals

### 1.1 Key Terms

| Term | Meaning |
|------|---------|
| **PHI** | Protected Health Information |
| **EHR/EMR** | Electronic Health/Medical Records |
| **HL7** | Health Level 7 (messaging standard) |
| **FHIR** | Fast Healthcare Interoperability Resources |
| **HIPAA** | Health Insurance Portability and Accountability Act |
| **BAA** | Business Associate Agreement |

### 1.2 Healthcare Data Types

| Type | Examples |
|------|----------|
| **Demographics** | Name, DOB, address |
| **Clinical** | Diagnoses, medications, allergies |
| **Administrative** | Insurance, appointments |
| **Vitals** | Heart rate, blood pressure |
| **Lab Results** | Blood tests, imaging |

---

## Part 2: HIPAA Compliance

### 2.1 Key Requirements

| Rule | Requirement |
|------|-------------|
| **Privacy Rule** | Limit PHI disclosure |
| **Security Rule** | Protect electronic PHI |
| **Breach Notification** | Report breaches within 60 days |

### 2.2 Technical Safeguards

| Control | Implementation |
|---------|----------------|
| **Encryption** | AES-256 at rest, TLS 1.2+ in transit |
| **Access Control** | Role-based, MFA required |
| **Audit Logs** | Log all PHI access |
| **Backup** | Encrypted backups with testing |
| **Session Management** | Auto-logout, session limits |

### 2.3 HIPAA-Compliant Infrastructure

| Service | Provider |
|---------|----------|
| **Cloud** | AWS HIPAA-eligible, Google Cloud Healthcare |
| **Database** | RDS with encryption, MongoDB Atlas HIPAA |
| **Storage** | S3 with server-side encryption |
| **Auth** | Auth0 with BAA, AWS Cognito |

### 2.4 Business Associate Agreement (BAA)

Any third party handling PHI must sign a BAA:

- Cloud providers
- Analytics tools
- Communication platforms

---

## Part 3: FHIR Integration

### 3.1 What is FHIR?

RESTful API standard for healthcare data exchange.

### 3.2 Common Resources

| Resource | Data |
|----------|------|
| **Patient** | Demographics |
| **Practitioner** | Provider info |
| **Observation** | Vitals, lab results |
| **Condition** | Diagnoses |
| **MedicationRequest** | Prescriptions |
| **Encounter** | Visits |
| **Appointment** | Scheduling |

### 3.3 FHIR API Example

```typescript
// Get patient by ID
const response = await fetch('https://fhir.server.com/fhir/Patient/123', {
  headers: {
    'Authorization': `Bearer ${token}`,
    'Accept': 'application/fhir+json',
  },
});

const patient = await response.json();

// Patient resource structure
{
  "resourceType": "Patient",
  "id": "123",
  "name": [{
    "family": "Smith",
    "given": ["John"]
  }],
  "birthDate": "1990-01-15",
  "gender": "male"
}
```

### 3.4 FHIR Servers

- **HAPI FHIR**: Open source Java.
- **Microsoft Azure FHIR**: Managed service.
- **Google Cloud Healthcare API**: FHIR support.

---

## Part 4: Telemedicine Features

### 4.1 Core Components

| Feature | Implementation |
|---------|----------------|
| **Video Consult** | Twilio Video, Daily.co, WebRTC |
| **Scheduling** | Appointment booking with provider availability |
| **Waiting Room** | Virtual queue before call |
| **Documentation** | Encounter notes, prescriptions |
| **Prescription** | E-prescribing integration |

### 4.2 Video Call Architecture

```
Patient App → WebRTC/Twilio → Doctor App
                   ↓
            Recording (HIPAA storage)
                   ↓
            Encounter Documentation
```

### 4.3 Twilio Video (HIPAA)

```typescript
import Twilio from 'twilio';

const client = Twilio(ACCOUNT_SID, AUTH_TOKEN);

// Create room
const room = await client.video.rooms.create({
  uniqueName: `consult-${appointmentId}`,
  type: 'group-small',
  recordParticipantsOnConnect: true,
});

// Generate access token for participant
const token = new Twilio.jwt.AccessToken(
  ACCOUNT_SID,
  API_KEY_SID,
  API_KEY_SECRET,
  { identity: 'patient-123' }
);

token.addGrant(new Twilio.jwt.AccessToken.VideoGrant({
  room: room.uniqueName,
}));

return token.toJwt();
```

---

## Part 5: Health Device Integration

### 5.1 Wearable Data

| Platform | Data Types |
|----------|------------|
| **Apple HealthKit** | Steps, heart rate, sleep |
| **Google Fit** | Activity, vitals |
| **Fitbit API** | Exercise, sleep, heart rate |
| **Withings** | Weight, blood pressure |

### 5.2 HealthKit Integration (iOS)

```swift
import HealthKit

let healthStore = HKHealthStore()

// Request authorization
let typesToRead: Set<HKObjectType> = [
    HKObjectType.quantityType(forIdentifier: .heartRate)!,
    HKObjectType.quantityType(forIdentifier: .stepCount)!,
]

healthStore.requestAuthorization(toShare: nil, read: typesToRead) { success, error in
    // Handle authorization
}
```

---

## Part 6: Best Practices Checklist

### ✅ Do This

- ✅ **Sign BAAs**: With all vendors handling PHI.
- ✅ **Encrypt Everything**: At rest and in transit.
- ✅ **Audit Logs**: Who accessed what, when.

### ❌ Avoid This

- ❌ **PHI in Logs**: Mask or exclude sensitive data.
- ❌ **SMS for PHI**: Unencrypted; use secure messaging.
- ❌ **Storing More Than Needed**: Data minimization.

---

## Related Skills

- `@fitness-app-developer` - Fitness features
- `@wearable-app-developer` - Device integration
- `@senior-api-security-specialist` - Security

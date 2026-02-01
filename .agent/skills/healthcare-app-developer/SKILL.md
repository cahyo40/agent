---
name: healthcare-app-developer
description: "Expert healthcare application development including HIPAA compliance, medical records, patient portals, telemedicine, and health data integration"
---

# Healthcare App Developer

## Overview

Build healthcare applications with HIPAA compliance, patient management, telemedicine, health records, and medical device integration.

## When to Use This Skill

- Use when building health apps
- Use when HIPAA compliance needed
- Use when building telemedicine
- Use when handling medical data

## How It Works

### Step 1: HIPAA Compliance

```
HIPAA REQUIREMENTS
├── PRIVACY RULE
│   ├── PHI protection
│   ├── Minimum necessary
│   ├── Patient consent
│   └── Access controls
│
├── SECURITY RULE
│   ├── Encryption at rest/transit
│   ├── Audit logging
│   ├── Access management
│   └── Automatic session timeout
│
├── BREACH NOTIFICATION
│   ├── 60-day notification
│   ├── Incident response plan
│   └── Documentation
│
└── TECHNICAL SAFEGUARDS
    ├── Unique user ID
    ├── Emergency access
    ├── Auto logoff
    └── Encryption
```

### Step 2: Patient Data Model

```typescript
// Patient record structure
interface Patient {
  id: string;
  mrn: string; // Medical Record Number
  demographics: {
    firstName: string;
    lastName: string;
    dateOfBirth: Date;
    gender: 'male' | 'female' | 'other';
    ssn?: string; // Encrypted
  };
  contact: {
    phone: string;
    email: string;
    address: Address;
    emergencyContact: Contact;
  };
  insurance: InsuranceInfo[];
  medicalHistory: MedicalHistory;
  allergies: Allergy[];
  medications: Medication[];
  vitals: VitalRecord[];
}

// Audit logging
interface AuditLog {
  timestamp: Date;
  userId: string;
  action: 'view' | 'create' | 'update' | 'delete' | 'export';
  resource: string;
  resourceId: string;
  ipAddress: string;
  details: Record<string, any>;
}

// All PHI access must be logged
async function accessPatientRecord(
  userId: string, 
  patientId: string
): Promise<Patient> {
  await auditLog.log({
    action: 'view',
    userId,
    resource: 'patient',
    resourceId: patientId,
  });
  
  return patientRepository.findById(patientId);
}
```

### Step 3: Telemedicine Features

```typescript
// Video consultation
interface VideoSession {
  id: string;
  patientId: string;
  providerId: string;
  scheduledAt: Date;
  status: 'scheduled' | 'waiting' | 'in-progress' | 'completed';
  roomUrl: string;
  duration?: number;
  notes?: string;
}

// Prescription e-prescribing
interface Prescription {
  id: string;
  patientId: string;
  providerId: string;
  medication: {
    name: string;
    dosage: string;
    frequency: string;
    duration: string;
    refills: number;
  };
  pharmacy: Pharmacy;
  status: 'pending' | 'sent' | 'filled' | 'cancelled';
}

// Appointment scheduling
interface Appointment {
  id: string;
  patientId: string;
  providerId: string;
  type: 'in-person' | 'video' | 'phone';
  datetime: Date;
  duration: number;
  reason: string;
  status: 'scheduled' | 'confirmed' | 'completed' | 'cancelled';
}
```

### Step 4: HL7 FHIR Integration

```typescript
// FHIR Resource example
const patientResource = {
  resourceType: 'Patient',
  id: 'patient-123',
  identifier: [{
    system: 'http://hospital.org/mrn',
    value: 'MRN123456'
  }],
  name: [{
    family: 'Doe',
    given: ['John']
  }],
  gender: 'male',
  birthDate: '1980-01-15'
};

// FHIR Client
import { FHIRClient } from 'fhir-kit-client';

const client = new FHIRClient({
  baseUrl: 'https://fhir.hospital.org/r4'
});

// Search patients
const bundle = await client.search({
  resourceType: 'Patient',
  searchParams: { name: 'John' }
});
```

## Best Practices

### ✅ Do This

- ✅ Encrypt all PHI
- ✅ Implement audit logging
- ✅ Use role-based access
- ✅ Auto session timeout
- ✅ Regular security audits

### ❌ Avoid This

- ❌ Don't store PHI in logs
- ❌ Don't skip encryption
- ❌ Don't share credentials
- ❌ Don't bypass access controls

## Related Skills

- `@senior-api-security-specialist` - API security
- `@senior-backend-developer` - Backend development

---
name: senior-firebase-developer
description: "Expert Firebase development including Firestore, Authentication, Cloud Functions v2, Storage, FCM, App Check, AI Logic, Remote Config, and real-time applications"
---

# Senior Firebase Developer

## Overview

Expert Firebase Developer for building scalable,
real-time apps using Firestore, Auth (MFA, anonymous,
passkey), Cloud Functions v2, Storage, FCM, App Check,
Firebase AI Logic, Remote Config, and Extensions.

## When to Use

- Serverless applications
- Real-time data sync
- Rapid prototyping
- Mobile apps (Flutter, React Native, iOS, Android)
- AI-powered features with Gemini integration

---

## Part 1: Firebase Architecture

### 1.1 Services Overview

| Category | Services |
|----------|----------|
| **Build** | Firestore, Realtime DB, Auth, Storage, Functions v2, Hosting, Data Connect |
| **AI** | Firebase AI Logic (Gemini, Imagen), Vertex AI integration |
| **Engage** | FCM (Push), In-App Messaging, Remote Config, A/B Testing |
| **Monitor** | Crashlytics, Analytics, Performance Monitoring |
| **Protect** | App Check, Security Rules |

### 1.2 Firestore vs Realtime Database

| Aspect | Firestore | Realtime DB |
|--------|-----------|-------------|
| Data Model | Documents/Collections | JSON Tree |
| Queries | Compound, indexed | Limited |
| Scalability | Automatic | Manual sharding |
| Pricing | Per operation | Per bandwidth |
| Offline | ✅ Full | ✅ Limited |
| Vector Search | ✅ Native | ❌ No |

---

## Part 2: Setup

### 2.1 Web/TypeScript

```typescript
import { initializeApp, getApps } from 'firebase/app';
import { getFirestore } from 'firebase/firestore';
import { getAuth } from 'firebase/auth';
import { getStorage } from 'firebase/storage';

const config = {
  apiKey: process.env.FIREBASE_API_KEY,
  authDomain: 'project.firebaseapp.com',
  projectId: 'project-id',
  storageBucket: 'project.appspot.com',
  messagingSenderId: '123456',
  appId: '1:123456:web:abcdef',
};

const app = getApps().length
  ? getApps()[0]
  : initializeApp(config);
export const db = getFirestore(app);
export const auth = getAuth(app);
export const storage = getStorage(app);
```

### 2.2 Admin SDK (Server-side)

```typescript
import { initializeApp } from 'firebase-admin/app';
import { getFirestore } from 'firebase-admin/firestore';
import { getAuth } from 'firebase-admin/auth';

const app = initializeApp();
const db = getFirestore(app);
const auth = getAuth(app);
```

### 2.3 Flutter/Dart

```dart
// Run: flutterfire configure
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}
```

---

## Part 3: Firestore Operations

### 3.1 TypeScript CRUD

```typescript
import {
  collection, doc, getDoc, getDocs, addDoc,
  setDoc, updateDoc, deleteDoc, query, where,
  orderBy, limit, onSnapshot, serverTimestamp,
  writeBatch, runTransaction, arrayUnion,
  increment,
} from 'firebase/firestore';

// CREATE
const docRef = await addDoc(
  collection(db, 'users'),
  {
    name: 'John',
    createdAt: serverTimestamp(),
  },
);

// CREATE with custom ID
await setDoc(doc(db, 'users', 'custom-id'), {
  name: 'John',
});

// READ
const docSnap = await getDoc(doc(db, 'users', id));
if (docSnap.exists()) {
  return { id: docSnap.id, ...docSnap.data() };
}

// QUERY with compound filters
const q = query(
  collection(db, 'users'),
  where('role', '==', 'admin'),
  where('active', '==', true),
  orderBy('createdAt', 'desc'),
  limit(20),
);
const snapshot = await getDocs(q);
const users = snapshot.docs.map(
  (d) => ({ id: d.id, ...d.data() }),
);

// UPDATE
await updateDoc(doc(db, 'users', id), {
  name: 'Jane',
  'address.city': 'Jakarta', // nested field
});

// Atomic operations
await updateDoc(doc(db, 'posts', id), {
  likes: increment(1),
  tags: arrayUnion('firebase'),
});

// DELETE
await deleteDoc(doc(db, 'users', id));

// BATCH WRITES (atomic)
const batch = writeBatch(db);
batch.set(doc(db, 'users', 'u1'), { name: 'A' });
batch.update(doc(db, 'users', 'u2'), { name: 'B' });
batch.delete(doc(db, 'users', 'u3'));
await batch.commit();

// TRANSACTION
await runTransaction(db, async (transaction) => {
  const docSnap = await transaction.get(
    doc(db, 'accounts', id),
  );
  const newBalance = docSnap.data()!.balance - amount;
  transaction.update(
    doc(db, 'accounts', id),
    { balance: newBalance },
  );
});

// REALTIME LISTENER
const unsubscribe = onSnapshot(
  doc(db, 'users', id),
  (doc) => {
    console.log('Data:', doc.data());
  },
);
// Call unsubscribe() to stop listening
```

### 3.2 Flutter/Dart CRUD

```dart
final usersRef = FirebaseFirestore.instance
    .collection('users');

// CREATE
final docRef = await usersRef.add({
  'name': 'John',
  'createdAt': FieldValue.serverTimestamp(),
});

// READ
final doc = await usersRef.doc(id).get();
if (doc.exists) return doc.data();

// QUERY
final snapshot = await usersRef
    .where('role', isEqualTo: 'admin')
    .orderBy('createdAt', descending: true)
    .limit(20)
    .get();

// UPDATE
await usersRef.doc(id).update({'name': 'Jane'});

// Atomic operations
await usersRef.doc(id).update({
  'likes': FieldValue.increment(1),
  'tags': FieldValue.arrayUnion(['firebase']),
});

// DELETE
await usersRef.doc(id).delete();

// BATCH WRITES
final batch = FirebaseFirestore.instance.batch();
batch.set(usersRef.doc('u1'), {'name': 'A'});
batch.update(usersRef.doc('u2'), {'name': 'B'});
batch.delete(usersRef.doc('u3'));
await batch.commit();

// REALTIME STREAM
usersRef.snapshots().listen((snapshot) {
  for (var doc in snapshot.docs) {
    print(doc.data());
  }
});
```

### 3.3 Firestore Vector Search

```typescript
import { collection, query, findNearest }
  from 'firebase/firestore';

// Query vector field for similarity search
const q = query(
  collection(db, 'documents'),
  findNearest({
    vectorField: 'embedding',
    queryVector: embeddingVector,
    limit: 10,
    distanceMeasure: 'COSINE',
  }),
);
```

---

## Part 4: Security Rules

### 4.1 Firestore Rules

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    // Helper functions
    function isAuth() {
      return request.auth != null;
    }
    function isOwner(uid) {
      return request.auth.uid == uid;
    }
    function hasRole(role) {
      return request.auth.token[role] == true;
    }
    function isValidUser() {
      let data = request.resource.data;
      return data.name is string
        && data.name.size() > 0
        && data.email is string;
    }

    // Users collection
    match /users/{userId} {
      allow read: if isAuth();
      allow create: if isOwner(userId)
                    && isValidUser();
      allow update: if isOwner(userId);
      allow delete: if hasRole('admin');
    }

    // Posts with subcollections
    match /posts/{postId} {
      allow read: if resource.data.published == true
                  || isOwner(resource.data.authorId);
      allow create: if isAuth()
                    && request.resource.data.authorId
                       == request.auth.uid;
      allow update, delete:
        if isOwner(resource.data.authorId);

      // Comments subcollection
      match /comments/{commentId} {
        allow read: if true;
        allow create: if isAuth();
        allow delete: if isOwner(
          resource.data.userId
        ) || hasRole('admin');
      }
    }
  }
}
```

### 4.2 Storage Rules

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /users/{userId}/{allPaths=**} {
      allow read: if true;
      allow write: if request.auth.uid == userId
                   && request.resource.size < 5 * 1024 * 1024
                   && request.resource.contentType
                      .matches('image/.*');
    }
  }
}
```

---

## Part 5: Authentication

### 5.1 TypeScript Auth

```typescript
import {
  signInWithEmailAndPassword,
  createUserWithEmailAndPassword,
  signInWithPopup,
  signInAnonymously,
  linkWithCredential,
  GoogleAuthProvider,
  EmailAuthProvider,
  signOut,
  onAuthStateChanged,
  sendPasswordResetEmail,
  sendEmailVerification,
} from 'firebase/auth';

// Email Sign Up
const cred = await createUserWithEmailAndPassword(
  auth, email, password,
);
await sendEmailVerification(cred.user);

// Email Sign In
await signInWithEmailAndPassword(
  auth, email, password,
);

// Google Sign In
const provider = new GoogleAuthProvider();
const cred = await signInWithPopup(auth, provider);

// Anonymous Sign In
const { user } = await signInAnonymously(auth);

// Link anonymous to email account
const emailCred = EmailAuthProvider.credential(
  email, password,
);
await linkWithCredential(user, emailCred);

// Password Reset
await sendPasswordResetEmail(auth, email);

// Auth State Listener
const unsubscribe = onAuthStateChanged(
  auth, (user) => {
    if (user) console.log('Logged in:', user.uid);
    else console.log('Signed out');
  },
);

// Sign Out
await signOut(auth);
```

### 5.2 Custom Claims (Admin SDK)

```typescript
import { getAuth } from 'firebase-admin/auth';

// Set custom claims
await getAuth().setCustomUserClaims(uid, {
  admin: true,
  role: 'manager',
});

// Verify and read claims
const { customClaims } = await getAuth().getUser(uid);
```

### 5.3 Multi-Factor Authentication (MFA)

```typescript
import {
  getMultiFactorResolver,
  PhoneAuthProvider,
  PhoneMultiFactorGenerator,
  TotpMultiFactorGenerator,
  RecaptchaVerifier,
  multiFactor,
} from 'firebase/auth';

// Enroll phone as second factor
const session = await multiFactor(user)
  .getSession();
const phoneOpts = {
  phoneNumber: '+12345678900',
  session,
};
const phoneProvider = new PhoneAuthProvider(auth);
const verificationId = await phoneProvider
  .verifyPhoneNumber(phoneOpts, recaptchaVerifier);
// After user enters code:
const cred = PhoneAuthProvider.credential(
  verificationId, verificationCode,
);
const assertion = PhoneMultiFactorGenerator
  .assertion(cred);
await multiFactor(user).enroll(assertion, 'Phone');

// Handle MFA during sign-in
signInWithEmailAndPassword(auth, email, password)
  .catch((error) => {
    if (error.code ===
        'auth/multi-factor-auth-required') {
      const resolver = getMultiFactorResolver(
        auth, error,
      );
      // resolver.hints => available factors
      // resolver.resolveSignIn(assertion)
    }
  });
```

### 5.4 Flutter/Dart Auth

```dart
final auth = FirebaseAuth.instance;

// Email Sign Up
await auth.createUserWithEmailAndPassword(
  email: email, password: password,
);

// Google Sign In
final googleUser = await GoogleSignIn().signIn();
final googleAuth = await googleUser!.authentication;
final credential = GoogleAuthProvider.credential(
  accessToken: googleAuth.accessToken,
  idToken: googleAuth.idToken,
);
await auth.signInWithCredential(credential);

// Anonymous Sign In
await auth.signInAnonymously();

// Auth State Stream
auth.authStateChanges().listen((user) {
  if (user != null) {
    print('Signed in: ${user.uid}');
  } else {
    print('Signed out');
  }
});

// Sign Out
await auth.signOut();
```

---

## Part 6: Cloud Functions v2

### 6.1 HTTP & Callable Functions

```typescript
import { onRequest } from 'firebase-functions/v2/https';
import { onCall, HttpsError }
  from 'firebase-functions/v2/https';
import { initializeApp } from 'firebase-admin/app';
import { getFirestore } from 'firebase-admin/firestore';

initializeApp();
const db = getFirestore();

// HTTP Function
export const api = onRequest(
  { cors: true, region: 'us-central1' },
  async (req, res) => {
    const users = await db.collection('users').get();
    res.json(users.docs.map((d) => d.data()));
  },
);

// Callable Function with App Check
export const createUser = onCall(
  {
    enforceAppCheck: true,
    region: 'us-central1',
  },
  async (request) => {
    if (!request.auth) {
      throw new HttpsError(
        'unauthenticated',
        'Must be authenticated',
      );
    }
    const { name, email } = request.data;
    const docRef = await db
      .collection('users')
      .add({
        name,
        email,
        uid: request.auth.uid,
        createdAt: new Date(),
      });
    return { id: docRef.id };
  },
);
```

### 6.2 Firestore Triggers (v2)

```typescript
import {
  onDocumentCreated,
  onDocumentUpdated,
  onDocumentDeleted,
  onDocumentWritten,
  onDocumentCreatedWithAuthContext,
} from 'firebase-functions/v2/firestore';

// On document created
export const onUserCreate = onDocumentCreated(
  'users/{userId}',
  async (event) => {
    const data = event.data?.data();
    console.log('New user:', data);
    // Send welcome email, etc.
  },
);

// With auth context (who triggered it)
export const onPostCreate =
  onDocumentCreatedWithAuthContext(
    'posts/{postId}',
    async (event) => {
      const { authType, authId } = event;
      console.log(`Created by: ${authId}`);
    },
  );

// On document updated
export const onUserUpdate = onDocumentUpdated(
  'users/{userId}',
  async (event) => {
    const before = event.data?.before.data();
    const after = event.data?.after.data();
    if (before?.name !== after?.name) {
      console.log('Name changed');
    }
  },
);

// With retry
export const onOrderCreate = onDocumentCreated(
  { document: 'orders/{orderId}', retry: true },
  async (event) => {
    // Will retry on failure
  },
);
```

### 6.3 Scheduled Functions

```typescript
import { onSchedule }
  from 'firebase-functions/v2/scheduler';

// Run every day at midnight
export const dailyCleanup = onSchedule(
  '0 0 * * *',
  async (event) => {
    const cutoff = new Date();
    cutoff.setDate(cutoff.getDate() - 30);
    const old = await db.collection('logs')
      .where('createdAt', '<', cutoff)
      .get();
    const batch = db.batch();
    old.docs.forEach((d) => batch.delete(d.ref));
    await batch.commit();
  },
);
```

### 6.4 Auth & Storage Triggers

```typescript
import { beforeUserCreated, beforeUserSignedIn }
  from 'firebase-functions/v2/identity';
import { onObjectFinalized }
  from 'firebase-functions/v2/storage';

// Blocking function: before user creation
export const validateNewUser = beforeUserCreated(
  async (event) => {
    const email = event.data.email;
    if (!email?.endsWith('@company.com')) {
      throw new HttpsError(
        'permission-denied',
        'Only company emails allowed',
      );
    }
  },
);

// Storage trigger: image uploaded
export const onFileUploaded = onObjectFinalized(
  async (event) => {
    const filePath = event.data.name;
    const contentType = event.data.contentType;
    if (!contentType?.startsWith('image/')) return;
    // Generate thumbnail, etc.
  },
);
```

---

## Part 7: Storage

### 7.1 TypeScript

```typescript
import {
  ref, uploadBytes, uploadBytesResumable,
  getDownloadURL, deleteObject, listAll,
} from 'firebase/storage';

// Upload
const storageRef = ref(
  storage, `users/${userId}/profile.jpg`,
);
await uploadBytes(storageRef, file);
const url = await getDownloadURL(storageRef);

// Resumable upload with progress
const uploadTask = uploadBytesResumable(
  storageRef, file,
);
uploadTask.on('state_changed',
  (snapshot) => {
    const progress = (snapshot.bytesTransferred
      / snapshot.totalBytes) * 100;
    console.log(`Upload: ${progress}%`);
  },
  (error) => console.error(error),
  async () => {
    const url = await getDownloadURL(
      uploadTask.snapshot.ref,
    );
  },
);

// Delete
await deleteObject(storageRef);

// List files
const listRef = ref(storage, `users/${userId}`);
const result = await listAll(listRef);
```

### 7.2 Flutter/Dart

```dart
final ref = FirebaseStorage.instance
    .ref('users/$userId/profile.jpg');

// Upload
await ref.putFile(file);
final url = await ref.getDownloadURL();

// Upload with progress
final task = ref.putFile(file);
task.snapshotEvents.listen((snapshot) {
  final progress =
      snapshot.bytesTransferred / snapshot.totalBytes;
  print('Upload: ${(progress * 100).toFixed(1)}%');
});

// Delete
await ref.delete();
```

---

## Part 8: FCM (Push Notifications)

### 8.1 Send from Server (Admin SDK)

```typescript
import { getMessaging } from 'firebase-admin/messaging';

// Send to single device
await getMessaging().send({
  token: deviceToken,
  notification: {
    title: 'New Message',
    body: 'You have a new message',
  },
  data: {
    type: 'chat',
    messageId: '123',
  },
  android: {
    priority: 'high',
    notification: {
      channelId: 'messages',
    },
  },
  apns: {
    payload: {
      aps: { badge: 1, sound: 'default' },
    },
  },
});

// Send to topic
await getMessaging().send({
  topic: 'news',
  notification: {
    title: 'Breaking News',
    body: 'Something happened',
  },
});
```

### 8.2 Flutter/Dart (Client)

```dart
final messaging = FirebaseMessaging.instance;

// Request permission
final settings = await messaging.requestPermission();

// Get token
final token = await messaging.getToken();

// Foreground messages
FirebaseMessaging.onMessage.listen((message) {
  print('Message: ${message.notification?.title}');
});

// Background messages
FirebaseMessaging.onBackgroundMessage(
  _handleBackgroundMessage,
);

// Subscribe to topic
await messaging.subscribeToTopic('news');
```

---

## Part 9: App Check

### 9.1 Web Setup

```typescript
import { initializeAppCheck, ReCaptchaV3Provider }
  from 'firebase/app-check';

const appCheck = initializeAppCheck(app, {
  provider: new ReCaptchaV3Provider(
    'your-recaptcha-site-key',
  ),
  isTokenAutoRefreshEnabled: true,
});
```

### 9.2 Flutter Setup

```dart
await FirebaseAppCheck.instance.activate(
  androidProvider: AndroidProvider.playIntegrity,
  appleProvider: AppleProvider.deviceCheck,
);
```

---

## Part 10: Remote Config

```typescript
import {
  getRemoteConfig, fetchAndActivate,
  getValue,
} from 'firebase/remote-config';

const remoteConfig = getRemoteConfig(app);
remoteConfig.settings.minimumFetchIntervalMillis
  = 3600000; // 1 hour

remoteConfig.defaultConfig = {
  feature_enabled: false,
  welcome_message: 'Hello!',
};

await fetchAndActivate(remoteConfig);
const enabled = getValue(
  remoteConfig, 'feature_enabled',
).asBoolean();
```

---

## Part 11: Firebase AI Logic

```typescript
import { initializeApp } from 'firebase/app';
import { getAI, getGenerativeModel,
  GoogleAIBackend } from 'firebase/ai';

const app = initializeApp(config);
const ai = getAI(app, {
  backend: new GoogleAIBackend(),
});

const model = getGenerativeModel(ai, {
  model: 'gemini-2.0-flash',
});

const result = await model.generateContent(
  'Explain Firebase in 3 sentences',
);
console.log(result.response.text());
```

---

## Part 12: Firebase Emulators

```bash
# Install and start emulators
firebase init emulators
firebase emulators:start

# Start specific emulators
firebase emulators:start \
  --only auth,firestore,functions,storage

# Export/import data
firebase emulators:export ./emulator-data
firebase emulators:start \
  --import=./emulator-data
```

```typescript
// Connect to emulators in code
import { connectFirestoreEmulator }
  from 'firebase/firestore';
import { connectAuthEmulator }
  from 'firebase/auth';
import { connectStorageEmulator }
  from 'firebase/storage';
import { connectFunctionsEmulator }
  from 'firebase/functions';

if (process.env.NODE_ENV === 'development') {
  connectFirestoreEmulator(db, 'localhost', 8080);
  connectAuthEmulator(auth, 'http://localhost:9099');
  connectStorageEmulator(storage, 'localhost', 9199);
  connectFunctionsEmulator(
    functions, 'localhost', 5001,
  );
}
```

---

## Part 13: CLI & Deployment

```bash
# Install CLI
npm install -g firebase-tools

# Login
firebase login

# Init project
firebase init

# Deploy everything
firebase deploy

# Deploy specific services
firebase deploy --only functions
firebase deploy --only firestore:rules
firebase deploy --only hosting

# Deploy single function
firebase deploy --only functions:functionName

# Preview channels (staging)
firebase hosting:channel:deploy preview-name

# List projects
firebase projects:list

# Use project
firebase use project-id
```

---

## Best Practices

### ✅ Do This

- Always write Security Rules before going live
- Use Cloud Functions v2 for new functions
- Create composite indexes for compound queries
- Use batch writes for atomic operations
- Unsubscribe listeners when no longer needed
- Use emulators for local development
- Enable App Check for production apps
- Use custom claims for role-based access
- Structure data for query patterns (denormalize)
- Use `serverTimestamp()` for consistent times
- Set up billing alerts and budget caps
- Use Remote Config for feature flags

### ❌ Avoid

- Fetching entire collections without limits
- Storing sensitive data without Security Rules
- Ignoring billing alerts
- Using Cloud Functions v1 for new projects
- Deeply nested subcollections (max 2-3 levels)
- Large documents (keep under 1MB)
- Running expensive ops in Security Rules
- Exposing Admin SDK credentials client-side
- Skipping email verification

---

## Related Skills

- `@senior-flutter-developer` - Flutter + Firebase
- `@senior-supabase-developer` - Alternative BaaS
- `@senior-nextjs-developer` - Next.js + Firebase
- `@senior-cloud-architect` - GCP + Firebase
- `@senior-rag-engineer` - RAG with Firestore vectors

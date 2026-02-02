---
name: senior-firebase-developer
description: "Expert Firebase development including Firestore, Authentication, Cloud Functions, Storage, FCM, and real-time applications"
---

# Senior Firebase Developer

## Overview

Expert Firebase Developer capable of building scalable, real-time apps using Firestore, Auth, Cloud Functions, Storage, and FCM.

## When to Use

- Serverless applications
- Real-time data sync
- Rapid prototyping
- Mobile apps (Flutter, React Native)

---

## Part 1: Firebase Architecture

### 1.1 Services Overview

| Category | Services |
|----------|----------|
| **Build** | Firestore, Realtime DB, Auth, Storage, Functions, Hosting |
| **Engage** | FCM (Push), In-App Messaging, Remote Config |
| **Monitor** | Crashlytics, Analytics, Performance |

### 1.2 Firestore vs Realtime Database

| Aspect | Firestore | Realtime DB |
|--------|-----------|-------------|
| Data Model | Documents/Collections | JSON Tree |
| Queries | Compound, indexed | Limited |
| Scalability | Automatic | Manual sharding |
| Pricing | Per operation | Per bandwidth |

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
};

const app = getApps().length ? getApps()[0] : initializeApp(config);
export const db = getFirestore(app);
export const auth = getAuth(app);
export const storage = getStorage(app);
```

### 2.2 Flutter/Dart

```dart
// Run: flutterfire configure
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}
```

---

## Part 3: Firestore Operations

### 3.1 TypeScript CRUD

```typescript
import { collection, doc, getDoc, getDocs, addDoc, 
  updateDoc, deleteDoc, query, where, orderBy, 
  onSnapshot, serverTimestamp } from 'firebase/firestore';

// CREATE
const docRef = await addDoc(collection(db, 'users'), {
  name: 'John',
  createdAt: serverTimestamp(),
});

// READ
const docSnap = await getDoc(doc(db, 'users', id));
if (docSnap.exists()) {
  return { id: docSnap.id, ...docSnap.data() };
}

// QUERY
const q = query(
  collection(db, 'users'),
  where('role', '==', 'admin'),
  orderBy('createdAt', 'desc')
);
const snapshot = await getDocs(q);

// UPDATE
await updateDoc(doc(db, 'users', id), { name: 'Jane' });

// DELETE
await deleteDoc(doc(db, 'users', id));

// REALTIME
const unsubscribe = onSnapshot(doc(db, 'users', id), (doc) => {
  console.log('Data:', doc.data());
});
```

### 3.2 Flutter/Dart CRUD

```dart
final collection = FirebaseFirestore.instance.collection('users');

// CREATE
final docRef = await collection.add({
  'name': 'John',
  'createdAt': FieldValue.serverTimestamp(),
});

// READ
final doc = await collection.doc(id).get();
if (doc.exists) return doc.data();

// QUERY
final snapshot = await collection
  .where('role', isEqualTo: 'admin')
  .orderBy('createdAt', descending: true)
  .get();

// UPDATE
await collection.doc(id).update({'name': 'Jane'});

// DELETE
await collection.doc(id).delete();

// REALTIME STREAM
collection.snapshots().listen((snapshot) {
  for (var doc in snapshot.docs) {
    print(doc.data());
  }
});
```

---

## Part 4: Security Rules

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    function isAuth() { return request.auth != null; }
    function isOwner(uid) { return request.auth.uid == uid; }
    
    match /users/{userId} {
      allow read: if isAuth();
      allow write: if isOwner(userId);
    }
    
    match /posts/{postId} {
      allow read: if resource.data.published == true;
      allow create: if isAuth();
      allow update, delete: if request.auth.uid == resource.data.authorId;
    }
  }
}
```

---

## Part 5: Authentication

### 5.1 TypeScript

```typescript
import { signInWithEmailAndPassword, createUserWithEmailAndPassword,
  signInWithPopup, GoogleAuthProvider, signOut, onAuthStateChanged } from 'firebase/auth';

// Email Sign Up
const cred = await createUserWithEmailAndPassword(auth, email, password);

// Google Sign In
const provider = new GoogleAuthProvider();
const cred = await signInWithPopup(auth, provider);

// Auth State
onAuthStateChanged(auth, (user) => {
  if (user) console.log('Logged in:', user.uid);
});
```

### 5.2 Flutter/Dart

```dart
final auth = FirebaseAuth.instance;

// Email Sign Up
await auth.createUserWithEmailAndPassword(email: email, password: password);

// Google Sign In
final googleUser = await GoogleSignIn().signIn();
final googleAuth = await googleUser!.authentication;
final credential = GoogleAuthProvider.credential(
  accessToken: googleAuth.accessToken,
  idToken: googleAuth.idToken,
);
await auth.signInWithCredential(credential);

// Auth State Stream
auth.authStateChanges().listen((user) {
  print(user?.uid);
});
```

---

## Part 6: Cloud Functions

```typescript
import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
admin.initializeApp();

// HTTP Callable
export const createUser = functions.https.onCall(async (data, context) => {
  if (!context.auth) throw new functions.https.HttpsError('unauthenticated', '');
  return admin.firestore().collection('users').add(data);
});

// Firestore Trigger
export const onUserCreate = functions.firestore
  .document('users/{userId}')
  .onCreate(async (snap) => {
    console.log('New user:', snap.data());
  });
```

---

## Part 7: Storage

```typescript
import { ref, uploadBytes, getDownloadURL } from 'firebase/storage';

const storageRef = ref(storage, `users/${userId}/profile.jpg`);
await uploadBytes(storageRef, file);
const url = await getDownloadURL(storageRef);
```

```dart
final ref = FirebaseStorage.instance.ref('users/$userId/profile.jpg');
await ref.putFile(file);
final url = await ref.getDownloadURL();
```

---

## Best Practices

### ✅ Do This

- Always use Security Rules
- Create composite indexes
- Use batch writes for atomic ops
- Unsubscribe listeners
- Use emulators for dev

### ❌ Avoid

- Fetching entire collections
- Storing sensitive data unsecured
- Ignoring billing alerts

---

## Related Skills

- `@flutter-firebase-developer` - Flutter + Firebase
- `@senior-supabase-developer` - Alternative BaaS

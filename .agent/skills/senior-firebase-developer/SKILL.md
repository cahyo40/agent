---
name: senior-firebase-developer
description: "Expert Firebase development including Firestore, Authentication, Cloud Functions, Storage, and real-time applications"
---

# Senior Firebase Developer

## Overview

This skill transforms you into an experienced Firebase Developer who builds real-time, scalable applications using Firebase services including Firestore, Auth, Functions, and Storage.

## When to Use This Skill

- Use when building with Firebase
- Use when implementing Firestore database
- Use when setting up Firebase Auth
- Use when creating Cloud Functions

## How It Works

### Step 1: Firebase Setup

```javascript
// firebase.js
import { initializeApp } from 'firebase/app';
import { getFirestore } from 'firebase/firestore';
import { getAuth } from 'firebase/auth';
import { getStorage } from 'firebase/storage';

const firebaseConfig = {
  apiKey: process.env.NEXT_PUBLIC_FIREBASE_API_KEY,
  authDomain: "project.firebaseapp.com",
  projectId: "project-id",
  storageBucket: "project.appspot.com",
  messagingSenderId: "123456789",
  appId: "1:123456789:web:abc123"
};

const app = initializeApp(firebaseConfig);
export const db = getFirestore(app);
export const auth = getAuth(app);
export const storage = getStorage(app);
```

### Step 2: Firestore Operations

```javascript
import { 
  collection, doc, addDoc, getDoc, getDocs, 
  updateDoc, deleteDoc, query, where, orderBy, limit,
  onSnapshot
} from 'firebase/firestore';

// Create
const docRef = await addDoc(collection(db, 'users'), {
  name: 'John',
  email: 'john@example.com',
  createdAt: serverTimestamp()
});

// Read
const userDoc = await getDoc(doc(db, 'users', docRef.id));
const userData = userDoc.data();

// Query
const q = query(
  collection(db, 'posts'),
  where('authorId', '==', userId),
  orderBy('createdAt', 'desc'),
  limit(10)
);
const snapshot = await getDocs(q);

// Real-time listener
const unsubscribe = onSnapshot(q, (snapshot) => {
  const posts = snapshot.docs.map(doc => ({
    id: doc.id,
    ...doc.data()
  }));
  setPosts(posts);
});

// Update
await updateDoc(doc(db, 'users', id), { name: 'Jane' });

// Delete
await deleteDoc(doc(db, 'users', id));
```

### Step 3: Firebase Authentication

```javascript
import { 
  createUserWithEmailAndPassword,
  signInWithEmailAndPassword,
  signInWithPopup,
  GoogleAuthProvider,
  signOut,
  onAuthStateChanged
} from 'firebase/auth';

// Email/Password signup
const { user } = await createUserWithEmailAndPassword(
  auth, email, password
);

// Email/Password login
await signInWithEmailAndPassword(auth, email, password);

// Google login
const provider = new GoogleAuthProvider();
await signInWithPopup(auth, provider);

// Auth state listener
onAuthStateChanged(auth, (user) => {
  if (user) {
    console.log('Logged in:', user.uid);
  } else {
    console.log('Logged out');
  }
});

// Logout
await signOut(auth);
```

### Step 4: Cloud Functions

```javascript
// functions/index.js
const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();

// HTTP function
exports.api = functions.https.onRequest(async (req, res) => {
  const users = await admin.firestore().collection('users').get();
  res.json(users.docs.map(doc => doc.data()));
});

// Firestore trigger
exports.onUserCreated = functions.firestore
  .document('users/{userId}')
  .onCreate(async (snap, context) => {
    const user = snap.data();
    await sendWelcomeEmail(user.email);
  });

// Scheduled function
exports.dailyCleanup = functions.pubsub
  .schedule('0 0 * * *')
  .onRun(async () => {
    await cleanupOldData();
  });
```

## Best Practices

### ✅ Do This

- ✅ Use security rules properly
- ✅ Index queries for performance
- ✅ Use batched writes for multiple ops
- ✅ Unsubscribe listeners on cleanup

### ❌ Avoid This

- ❌ Don't expose API keys in client
- ❌ Don't skip security rules
- ❌ Don't store sensitive data unencrypted

## Related Skills

- `@senior-react-developer` - React integration
- `@senior-flutter-developer` - Flutter + Firebase

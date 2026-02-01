---
name: senior-firebase-developer
description: "Expert Firebase development including Firestore, Authentication, Cloud Functions, Storage, and real-time applications"
---

# Senior Firebase Developer

## Overview

Build applications with Firebase including Firestore, Authentication, Cloud Functions, Storage, and real-time features for web and mobile.

## When to Use This Skill

- Use when building Firebase apps
- Use when need serverless backend
- Use when real-time sync required
- Use when rapid prototyping

## How It Works

### Step 1: Firebase Setup

```typescript
// Firebase configuration
import { initializeApp } from 'firebase/app';
import { getFirestore } from 'firebase/firestore';
import { getAuth } from 'firebase/auth';
import { getStorage } from 'firebase/storage';
import { getFunctions } from 'firebase/functions';

const firebaseConfig = {
  apiKey: process.env.FIREBASE_API_KEY,
  authDomain: 'project.firebaseapp.com',
  projectId: 'project-id',
  storageBucket: 'project.appspot.com',
  messagingSenderId: '123456789',
  appId: '1:123456789:web:abc123'
};

const app = initializeApp(firebaseConfig);
export const db = getFirestore(app);
export const auth = getAuth(app);
export const storage = getStorage(app);
export const functions = getFunctions(app);
```

### Step 2: Firestore Operations

```typescript
import { 
  collection, doc, getDoc, getDocs, 
  addDoc, updateDoc, deleteDoc, 
  query, where, orderBy, limit, 
  onSnapshot, serverTimestamp 
} from 'firebase/firestore';

// Create
async function createUser(userData: User) {
  const docRef = await addDoc(collection(db, 'users'), {
    ...userData,
    createdAt: serverTimestamp()
  });
  return docRef.id;
}

// Read
async function getUser(userId: string) {
  const docSnap = await getDoc(doc(db, 'users', userId));
  if (docSnap.exists()) {
    return { id: docSnap.id, ...docSnap.data() };
  }
  return null;
}

// Query
async function getActiveUsers() {
  const q = query(
    collection(db, 'users'),
    where('status', '==', 'active'),
    orderBy('createdAt', 'desc'),
    limit(10)
  );
  const snapshot = await getDocs(q);
  return snapshot.docs.map(doc => ({ id: doc.id, ...doc.data() }));
}

// Real-time listener
function subscribeToUsers(callback: (users: User[]) => void) {
  const q = query(collection(db, 'users'), orderBy('createdAt', 'desc'));
  
  return onSnapshot(q, (snapshot) => {
    const users = snapshot.docs.map(doc => ({ 
      id: doc.id, 
      ...doc.data() 
    }));
    callback(users);
  });
}
```

### Step 3: Authentication

```typescript
import { 
  signInWithEmailAndPassword, 
  createUserWithEmailAndPassword,
  signInWithPopup, GoogleAuthProvider,
  signOut, onAuthStateChanged
} from 'firebase/auth';

// Email/Password auth
async function signUp(email: string, password: string) {
  const credential = await createUserWithEmailAndPassword(auth, email, password);
  return credential.user;
}

async function signIn(email: string, password: string) {
  const credential = await signInWithEmailAndPassword(auth, email, password);
  return credential.user;
}

// Google auth
async function signInWithGoogle() {
  const provider = new GoogleAuthProvider();
  const credential = await signInWithPopup(auth, provider);
  return credential.user;
}

// Auth state observer
onAuthStateChanged(auth, (user) => {
  if (user) {
    console.log('Signed in:', user.uid);
  } else {
    console.log('Signed out');
  }
});
```

### Step 4: Cloud Functions

```typescript
// functions/src/index.ts
import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

admin.initializeApp();

// HTTP trigger
export const createUser = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'Not authenticated');
  }
  
  const { name, email } = data;
  const userRef = await admin.firestore().collection('users').add({
    name,
    email,
    createdBy: context.auth.uid,
    createdAt: admin.firestore.FieldValue.serverTimestamp()
  });
  
  return { id: userRef.id };
});

// Firestore trigger
export const onUserCreate = functions.firestore
  .document('users/{userId}')
  .onCreate(async (snap, context) => {
    const user = snap.data();
    
    // Send welcome email
    await admin.firestore().collection('mail').add({
      to: user.email,
      template: { name: 'welcome' }
    });
  });
```

## Best Practices

### ✅ Do This

- ✅ Use Security Rules
- ✅ Index queries properly
- ✅ Use batch writes
- ✅ Handle offline mode
- ✅ Unsubscribe listeners

### ❌ Avoid This

- ❌ Don't skip security rules
- ❌ Don't fetch entire collections
- ❌ Don't ignore billing
- ❌ Don't forget cleanup

## Related Skills

- `@senior-flutter-developer` - Flutter + Firebase
- `@senior-react-developer` - React + Firebase

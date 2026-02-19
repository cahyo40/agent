---
description: Integrasi Firebase v10 (modular) sebagai backend-as-a-service: Auth, Firestore database, Storage, dan Push Notificati...
---
# 06 - Firebase Integration (Auth + Firestore + Storage + FCM)

**Goal:** Integrasi Firebase v10 (modular) sebagai backend-as-a-service: Auth, Firestore database, Storage, dan Push Notifications (FCM).

**Output:** `sdlc/nextjs-frontend/06-firebase-integration/`

**Time Estimate:** 4-5 jam

---

## Install

```bash
pnpm add firebase
pnpm add firebase-admin  # Server-side only
```

---

## Deliverables

### 1. Firebase Config

**File:** `src/lib/firebase/config.ts`

```typescript
import { initializeApp, getApps, type FirebaseApp } from "firebase/app";
import { getAuth } from "firebase/auth";
import { getFirestore } from "firebase/firestore";
import { getStorage } from "firebase/storage";

const firebaseConfig = {
  apiKey: process.env.NEXT_PUBLIC_FIREBASE_API_KEY!,
  authDomain: process.env.NEXT_PUBLIC_FIREBASE_AUTH_DOMAIN!,
  projectId: process.env.NEXT_PUBLIC_FIREBASE_PROJECT_ID!,
  storageBucket: process.env.NEXT_PUBLIC_FIREBASE_STORAGE_BUCKET!,
  messagingSenderId: process.env.NEXT_PUBLIC_FIREBASE_MESSAGING_SENDER_ID!,
  appId: process.env.NEXT_PUBLIC_FIREBASE_APP_ID!,
};

// Prevent multiple initializations in Next.js
const app: FirebaseApp =
  getApps().length === 0 ? initializeApp(firebaseConfig) : getApps()[0]!;

export const auth = getAuth(app);
export const db = getFirestore(app);
export const storage = getStorage(app);
export { app };
```

**File:** `src/lib/firebase/admin.ts` (Server-side)

```typescript
import { cert, getApps, initializeApp } from "firebase-admin/app";
import { getAuth } from "firebase-admin/auth";
import { getFirestore } from "firebase-admin/firestore";

const adminApp =
  getApps().length === 0
    ? initializeApp({
        credential: cert({
          projectId: process.env.FIREBASE_PROJECT_ID!,
          clientEmail: process.env.FIREBASE_CLIENT_EMAIL!,
          privateKey: process.env.FIREBASE_PRIVATE_KEY!.replace(/\\n/g, "\n"),
        }),
      })
    : getApps()[0]!;

export const adminAuth = getAuth(adminApp);
export const adminDb = getFirestore(adminApp);
```

---

### 2. Firebase Auth

**File:** `src/features/auth/hooks/use-firebase-auth.ts`

```typescript
"use client";

import {
  createUserWithEmailAndPassword,
  GoogleAuthProvider,
  onAuthStateChanged,
  signInWithEmailAndPassword,
  signInWithPopup,
  signOut,
  updateProfile,
  type User,
} from "firebase/auth";
import { useRouter } from "next/navigation";
import { useEffect, useState } from "react";
import { auth } from "@/lib/firebase/config";

export function useFirebaseAuth() {
  const [user, setUser] = useState<User | null>(null);
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const router = useRouter();

  useEffect(() => {
    const unsubscribe = onAuthStateChanged(auth, (firebaseUser) => {
      setUser(firebaseUser);
      setIsLoading(false);
    });
    return unsubscribe;
  }, []);

  const register = async (
    email: string,
    password: string,
    displayName: string
  ) => {
    setError(null);
    try {
      const { user } = await createUserWithEmailAndPassword(
        auth,
        email,
        password
      );
      await updateProfile(user, { displayName });
      router.push("/dashboard");
      return true;
    } catch (err: any) {
      setError(err.message);
      return false;
    }
  };

  const login = async (email: string, password: string) => {
    setError(null);
    try {
      await signInWithEmailAndPassword(auth, email, password);
      router.push("/dashboard");
      return true;
    } catch (err: any) {
      setError(
        err.code === "auth/invalid-credential"
          ? "Invalid email or password"
          : err.message
      );
      return false;
    }
  };

  const loginWithGoogle = async () => {
    setError(null);
    try {
      const provider = new GoogleAuthProvider();
      await signInWithPopup(auth, provider);
      router.push("/dashboard");
      return true;
    } catch (err: any) {
      setError(err.message);
      return false;
    }
  };

  const logout = async () => {
    await signOut(auth);
    router.push("/login");
  };

  return {
    user,
    isAuthenticated: !!user,
    isLoading,
    error,
    register,
    login,
    loginWithGoogle,
    logout,
  };
}
```

---

### 3. Firestore CRUD

**File:** `src/lib/firebase/firestore.ts`

```typescript
import {
  addDoc,
  collection,
  deleteDoc,
  doc,
  getDoc,
  getDocs,
  limit,
  orderBy,
  query,
  QueryConstraint,
  serverTimestamp,
  startAfter,
  Timestamp,
  updateDoc,
  where,
  type DocumentData,
  type QueryDocumentSnapshot,
} from "firebase/firestore";
import { db } from "./config";

/** Generic Firestore CRUD helpers. */
export const firestoreDb = {
  /** Get collection with optional constraints. */
  async getCollection<T extends DocumentData>(
    collectionName: string,
    constraints: QueryConstraint[] = []
  ): Promise<(T & { id: string })[]> {
    const ref = collection(db, collectionName);
    const q = query(ref, ...constraints);
    const snapshot = await getDocs(q);
    return snapshot.docs.map((doc) => ({
      id: doc.id,
      ...(doc.data() as T),
    }));
  },

  /** Get single document. */
  async getDocument<T extends DocumentData>(
    collectionName: string,
    id: string
  ): Promise<(T & { id: string }) | null> {
    const ref = doc(db, collectionName, id);
    const snapshot = await getDoc(ref);
    if (!snapshot.exists()) return null;
    return { id: snapshot.id, ...(snapshot.data() as T) };
  },

  /** Create document with auto-ID. */
  async createDocument<T extends DocumentData>(
    collectionName: string,
    data: T
  ): Promise<string> {
    const ref = collection(db, collectionName);
    const docRef = await addDoc(ref, {
      ...data,
      createdAt: serverTimestamp(),
      updatedAt: serverTimestamp(),
    });
    return docRef.id;
  },

  /** Update document fields. */
  async updateDocument<T extends DocumentData>(
    collectionName: string,
    id: string,
    data: Partial<T>
  ): Promise<void> {
    const ref = doc(db, collectionName, id);
    await updateDoc(ref, {
      ...data,
      updatedAt: serverTimestamp(),
    });
  },

  /** Delete document. */
  async deleteDocument(
    collectionName: string,
    id: string
  ): Promise<void> {
    const ref = doc(db, collectionName, id);
    await deleteDoc(ref);
  },
};
```

---

### 4. Firestore Realtime Listener

**File:** `src/features/chat/hooks/use-messages.ts`

```typescript
"use client";

import {
  collection,
  onSnapshot,
  orderBy,
  query,
  limit,
} from "firebase/firestore";
import { useEffect, useState } from "react";
import { db } from "@/lib/firebase/config";

export interface Message {
  id: string;
  text: string;
  userId: string;
  userName: string;
  createdAt: Date;
}

/** Real-time chat messages from Firestore. */
export function useMessages(roomId: string, messageLimit = 50) {
  const [messages, setMessages] = useState<Message[]>([]);
  const [isLoading, setIsLoading] = useState(true);

  useEffect(() => {
    const q = query(
      collection(db, "rooms", roomId, "messages"),
      orderBy("createdAt", "asc"),
      limit(messageLimit)
    );

    const unsubscribe = onSnapshot(q, (snapshot) => {
      const msgs = snapshot.docs.map((doc) => ({
        id: doc.id,
        ...doc.data(),
        createdAt: doc.data().createdAt?.toDate() ?? new Date(),
      })) as Message[];

      setMessages(msgs);
      setIsLoading(false);
    });

    return unsubscribe;
  }, [roomId, messageLimit]);

  return { messages, isLoading };
}
```

---

### 5. Firebase Storage Upload

**File:** `src/features/profile/hooks/use-avatar-upload.ts`

```typescript
"use client";

import {
  getDownloadURL,
  ref,
  uploadBytesResumable,
} from "firebase/storage";
import { useState } from "react";
import { storage } from "@/lib/firebase/config";

export function useAvatarUpload() {
  const [progress, setProgress] = useState(0);
  const [isUploading, setIsUploading] = useState(false);

  const upload = (file: File, userId: string): Promise<string> => {
    return new Promise((resolve, reject) => {
      setIsUploading(true);
      setProgress(0);

      const storageRef = ref(storage, `avatars/${userId}/${file.name}`);
      const uploadTask = uploadBytesResumable(storageRef, file);

      uploadTask.on(
        "state_changed",
        (snapshot) => {
          const pct = Math.round(
            (snapshot.bytesTransferred / snapshot.totalBytes) * 100
          );
          setProgress(pct);
        },
        (error) => {
          setIsUploading(false);
          reject(error);
        },
        async () => {
          const downloadURL = await getDownloadURL(uploadTask.snapshot.ref);
          setIsUploading(false);
          resolve(downloadURL);
        }
      );
    });
  };

  return { upload, progress, isUploading };
}
```

---

### 6. Firebase Cloud Messaging (Push Notifications)

**File:** `src/lib/firebase/messaging.ts`

```typescript
"use client";

import { getMessaging, getToken, onMessage } from "firebase/messaging";
import { app } from "./config";

const VAPID_KEY = process.env.NEXT_PUBLIC_FIREBASE_VAPID_KEY!;

/** Request notification permission and get FCM token. */
export async function requestNotificationPermission(): Promise<string | null> {
  if (typeof window === "undefined") return null;

  const permission = await Notification.requestPermission();
  if (permission !== "granted") return null;

  const messaging = getMessaging(app);
  const token = await getToken(messaging, { vapidKey: VAPID_KEY });
  return token;
}

/** Listen for foreground messages. */
export function onForegroundMessage(
  callback: (payload: any) => void
): () => void {
  const messaging = getMessaging(app);
  return onMessage(messaging, callback);
}
```

**File:** `public/firebase-messaging-sw.js` (Service Worker)

```javascript
importScripts("https://www.gstatic.com/firebasejs/10.7.0/firebase-app-compat.js");
importScripts("https://www.gstatic.com/firebasejs/10.7.0/firebase-messaging-compat.js");

firebase.initializeApp({
  apiKey: "...",
  authDomain: "...",
  projectId: "...",
  storageBucket: "...",
  messagingSenderId: "...",
  appId: "...",
});

const messaging = firebase.messaging();

messaging.onBackgroundMessage((payload) => {
  const { title, body } = payload.notification;
  self.registration.showNotification(title, { body });
});
```

---

### 7. Environment Variables

```bash
# .env.local
NEXT_PUBLIC_FIREBASE_API_KEY=AIza...
NEXT_PUBLIC_FIREBASE_AUTH_DOMAIN=myapp.firebaseapp.com
NEXT_PUBLIC_FIREBASE_PROJECT_ID=myapp
NEXT_PUBLIC_FIREBASE_STORAGE_BUCKET=myapp.appspot.com
NEXT_PUBLIC_FIREBASE_MESSAGING_SENDER_ID=123456789
NEXT_PUBLIC_FIREBASE_APP_ID=1:123:web:abc
NEXT_PUBLIC_FIREBASE_VAPID_KEY=BK...

# Server-side (Firebase Admin)
FIREBASE_PROJECT_ID=myapp
FIREBASE_CLIENT_EMAIL=firebase-adminsdk@myapp.iam.gserviceaccount.com
FIREBASE_PRIVATE_KEY="-----BEGIN PRIVATE KEY-----\n...\n-----END PRIVATE KEY-----\n"
```

---

## Success Criteria
- Email/password register dan login berfungsi
- Google Sign-In popup berfungsi
- Firestore CRUD berhasil
- Realtime listener menerima perubahan data
- File upload ke Storage dengan progress tracking
- FCM push notification diterima di browser

## Next Steps
- `07_forms_validation.md` - Form handling
- `08_state_management.md` - State management

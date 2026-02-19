---
description: Integrasi Firebase v10 menggunakan `nuxt-vuefire` module: Auth, Firestore, Storage, dan FCM.
---
# 06 - Firebase Integration (nuxt-vuefire)

**Goal:** Integrasi Firebase v10 menggunakan `nuxt-vuefire` module: Auth, Firestore, Storage, dan FCM.

**Output:** `sdlc/nuxt-frontend/06-firebase-integration/`

**Time Estimate:** 3-4 jam

---

## Install

```bash
pnpm add nuxt-vuefire firebase
```

**File:** `nuxt.config.ts`

```typescript
export default defineNuxtConfig({
  modules: [
    // ... existing
    "nuxt-vuefire",
  ],
  vuefire: {
    auth: { enabled: true },
    config: {
      apiKey: process.env.NUXT_PUBLIC_FIREBASE_API_KEY,
      authDomain: process.env.NUXT_PUBLIC_FIREBASE_AUTH_DOMAIN,
      projectId: process.env.NUXT_PUBLIC_FIREBASE_PROJECT_ID,
      storageBucket: process.env.NUXT_PUBLIC_FIREBASE_STORAGE_BUCKET,
      messagingSenderId: process.env.NUXT_PUBLIC_FIREBASE_MESSAGING_SENDER_ID,
      appId: process.env.NUXT_PUBLIC_FIREBASE_APP_ID,
    },
  },
});
```

---

## Deliverables

### 1. Firebase Auth Composable

**File:** `composables/useFirebaseAuth.ts`

```typescript
import {
  createUserWithEmailAndPassword,
  GoogleAuthProvider,
  signInWithEmailAndPassword,
  signInWithPopup,
  signOut,
  updateProfile,
} from "firebase/auth";

export function useFirebaseAuth() {
  const auth = useFirebaseAuth()!;
  const user = useCurrentUser();
  const router = useRouter();
  const toast = useToast();

  const isAuthenticated = computed(() => !!user.value);

  async function register(
    email: string,
    password: string,
    displayName: string
  ): Promise<boolean> {
    try {
      const { user: newUser } = await createUserWithEmailAndPassword(
        auth,
        email,
        password
      );
      await updateProfile(newUser, { displayName });
      await router.push("/dashboard");
      return true;
    } catch (err: any) {
      toast.add({ title: err.message, color: "red" });
      return false;
    }
  }

  async function login(email: string, password: string): Promise<boolean> {
    try {
      await signInWithEmailAndPassword(auth, email, password);
      await router.push("/dashboard");
      return true;
    } catch {
      toast.add({ title: "Invalid email or password", color: "red" });
      return false;
    }
  }

  async function loginWithGoogle(): Promise<boolean> {
    try {
      const provider = new GoogleAuthProvider();
      await signInWithPopup(auth, provider);
      await router.push("/dashboard");
      return true;
    } catch (err: any) {
      toast.add({ title: err.message, color: "red" });
      return false;
    }
  }

  async function logout(): Promise<void> {
    await signOut(auth);
    await router.push("/login");
  }

  return { user, isAuthenticated, register, login, loginWithGoogle, logout };
}
```

---

### 2. Firestore CRUD Composable

**File:** `composables/useFirestoreCollection.ts`

```typescript
import {
  addDoc,
  collection,
  deleteDoc,
  doc,
  serverTimestamp,
  updateDoc,
} from "firebase/firestore";
import { useCollection, useDocument } from "vuefire";

export function useFirestoreCollection<T extends { id?: string }>(
  collectionName: string
) {
  const db = useFirestore();
  const collectionRef = collection(db, collectionName);
  const toast = useToast();

  /** Reactive collection (auto-updates). */
  const { data: items, pending } = useCollection<T>(collectionRef);

  /** Get single document (reactive). */
  function getDocument(id: string) {
    const docRef = doc(db, collectionName, id);
    return useDocument<T>(docRef);
  }

  /** Create document. */
  async function create(data: Omit<T, "id">): Promise<string | null> {
    try {
      const docRef = await addDoc(collectionRef, {
        ...data,
        createdAt: serverTimestamp(),
        updatedAt: serverTimestamp(),
      });
      toast.add({ title: "Created successfully", color: "green" });
      return docRef.id;
    } catch (err: any) {
      toast.add({ title: err.message, color: "red" });
      return null;
    }
  }

  /** Update document. */
  async function update(id: string, data: Partial<T>): Promise<boolean> {
    try {
      const docRef = doc(db, collectionName, id);
      await updateDoc(docRef, {
        ...data,
        updatedAt: serverTimestamp(),
      });
      toast.add({ title: "Updated successfully", color: "green" });
      return true;
    } catch (err: any) {
      toast.add({ title: err.message, color: "red" });
      return false;
    }
  }

  /** Delete document. */
  async function remove(id: string): Promise<boolean> {
    try {
      const docRef = doc(db, collectionName, id);
      await deleteDoc(docRef);
      toast.add({ title: "Deleted successfully", color: "green" });
      return true;
    } catch (err: any) {
      toast.add({ title: err.message, color: "red" });
      return false;
    }
  }

  return { items, pending, getDocument, create, update, remove };
}
```

---

### 3. Firestore Realtime Chat

**File:** `composables/useChat.ts`

```typescript
import { collection, orderBy, query, limit } from "firebase/firestore";
import { useCollection } from "vuefire";
import { addDoc, serverTimestamp } from "firebase/firestore";

export interface Message {
  id: string;
  text: string;
  userId: string;
  userName: string;
  createdAt: Date;
}

export function useChat(roomId: string) {
  const db = useFirestore();
  const user = useCurrentUser();

  const messagesRef = collection(db, "rooms", roomId, "messages");
  const messagesQuery = query(
    messagesRef,
    orderBy("createdAt", "asc"),
    limit(50)
  );

  const { data: messages, pending } = useCollection<Message>(messagesQuery);

  async function sendMessage(text: string): Promise<void> {
    if (!user.value || !text.trim()) return;

    await addDoc(messagesRef, {
      text: text.trim(),
      userId: user.value.uid,
      userName: user.value.displayName ?? "Anonymous",
      createdAt: serverTimestamp(),
    });
  }

  return { messages, pending, sendMessage };
}
```

---

### 4. Firebase Storage Upload

**File:** `composables/useFirebaseStorage.ts`

```typescript
import {
  getDownloadURL,
  ref as storageRef,
  uploadBytesResumable,
} from "firebase/storage";

export function useFirebaseStorage() {
  const storage = useFirebaseStorage();
  const progress = ref(0);
  const isUploading = ref(false);

  function upload(file: File, path: string): Promise<string> {
    return new Promise((resolve, reject) => {
      isUploading.value = true;
      progress.value = 0;

      const fileRef = storageRef(storage, path);
      const task = uploadBytesResumable(fileRef, file);

      task.on(
        "state_changed",
        (snapshot) => {
          progress.value = Math.round(
            (snapshot.bytesTransferred / snapshot.totalBytes) * 100
          );
        },
        (error) => {
          isUploading.value = false;
          reject(error);
        },
        async () => {
          const url = await getDownloadURL(task.snapshot.ref);
          isUploading.value = false;
          resolve(url);
        }
      );
    });
  }

  return { upload, progress, isUploading };
}
```

---

### 5. Usage in Page

```vue
<script setup lang="ts">
definePageMeta({ middleware: "auth", layout: "dashboard" });

// VueFire: auto-imported, reactive, SSR-compatible
const { items: products, pending, create } = useFirestoreCollection("products");
</script>

<template>
  <div>
    <TableSkeleton v-if="pending" />
    <DataTable
      v-else
      :data="products"
      :columns="[
        { key: 'name', label: 'Name' },
        { key: 'price', label: 'Price' },
      ]"
    />
  </div>
</template>
```

---

### 6. Environment Variables

```bash
NUXT_PUBLIC_FIREBASE_API_KEY=AIza...
NUXT_PUBLIC_FIREBASE_AUTH_DOMAIN=myapp.firebaseapp.com
NUXT_PUBLIC_FIREBASE_PROJECT_ID=myapp
NUXT_PUBLIC_FIREBASE_STORAGE_BUCKET=myapp.appspot.com
NUXT_PUBLIC_FIREBASE_MESSAGING_SENDER_ID=123456789
NUXT_PUBLIC_FIREBASE_APP_ID=1:123:web:abc
```

---

## Success Criteria
- Email/password register dan login berfungsi
- Google Sign-In popup berfungsi
- `useCollection()` reactive dan auto-update
- Firestore CRUD berhasil
- File upload ke Storage dengan progress tracking

## Next Steps
- `07_forms_validation.md` - Form handling

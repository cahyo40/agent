---
name: appwrite-developer
description: "Expert Appwrite development including database, authentication, storage, functions, and self-hosted deployment with Docker"
---

# Appwrite Developer

## Overview

Expert Appwrite Developer for building full-stack apps with Appwrite's open-source BaaS. Supports both cloud-hosted and self-hosted (Docker) deployments.

## When to Use

- Self-hosted BaaS needed
- Docker deployment preferred
- Open-source requirement
- Multi-platform (web, mobile, server)

---

## Part 1: Appwrite Architecture

### 1.1 Services

| Service | Description |
|---------|-------------|
| **Database** | NoSQL document collections |
| **Auth** | 30+ login methods |
| **Storage** | File upload, download, preview |
| **Functions** | Serverless (Node, Python, Dart, etc.) |
| **Realtime** | WebSocket subscriptions |
| **Messaging** | Push, SMS, Email |

### 1.2 Appwrite vs Firebase vs Supabase

| Aspect | Appwrite | Firebase | Supabase |
|--------|----------|----------|----------|
| Database | NoSQL | NoSQL | PostgreSQL |
| Self-host | ✅ Docker | ❌ No | ✅ Docker |
| Functions | Multi-runtime | Node/Python | Deno |
| Open-source | ✅ 100% | ❌ No | ✅ Mostly |

---

## Part 2: Installation

### 2.1 Self-Hosted (Docker)

```bash
# Install with Docker
docker run -it --rm \
  --volume /var/run/docker.sock:/var/run/docker.sock \
  --volume "$(pwd)"/appwrite:/usr/src/code/appwrite:rw \
  --entrypoint="install" \
  appwrite/appwrite:1.5.7

# Or using docker-compose
mkdir appwrite && cd appwrite
curl -o docker-compose.yml https://appwrite.io/install/compose
docker compose up -d

# Access console
# http://localhost/console
```

### 2.2 Cloud Setup

1. Go to [cloud.appwrite.io](https://cloud.appwrite.io)
2. Create project
3. Get Project ID and Endpoint
4. Add platforms (Web, Flutter, etc.)

---

## Part 3: SDK Setup

### 3.1 TypeScript/JavaScript

```typescript
import { Client, Account, Databases, Storage, Functions } from 'appwrite';

const client = new Client()
  .setEndpoint('https://cloud.appwrite.io/v1') // Or self-hosted
  .setProject('your-project-id');

export const account = new Account(client);
export const databases = new Databases(client);
export const storage = new Storage(client);
export const functions = new Functions(client);
```

### 3.2 Flutter/Dart

```dart
import 'package:appwrite/appwrite.dart';

final client = Client()
  .setEndpoint('https://cloud.appwrite.io/v1')
  .setProject('your-project-id')
  .setSelfSigned(status: true); // For self-hosted with self-signed cert

final account = Account(client);
final databases = Databases(client);
final storage = Storage(client);
final functions = Functions(client);
```

---

## Part 4: Authentication

### 4.1 TypeScript

```typescript
import { account } from './appwrite';
import { ID } from 'appwrite';

// Email Sign Up
const user = await account.create(
  ID.unique(),
  'user@example.com',
  'password123',
  'John Doe' // Optional name
);

// Email Sign In
const session = await account.createEmailPasswordSession(
  'user@example.com',
  'password123'
);

// OAuth (Google, GitHub, etc.)
account.createOAuth2Session(
  'google',
  'http://localhost:3000/success', // Success redirect
  'http://localhost:3000/failure'  // Failure redirect
);

// Get current user
const user = await account.get();

// Get current session
const session = await account.getSession('current');

// Logout
await account.deleteSession('current');

// Logout all devices
await account.deleteSessions();
```

### 4.2 Flutter/Dart

```dart
import 'package:appwrite/appwrite.dart';

// Email Sign Up
await account.create(
  userId: ID.unique(),
  email: 'user@example.com',
  password: 'password123',
  name: 'John Doe',
);

// Email Sign In
await account.createEmailPasswordSession(
  email: 'user@example.com',
  password: 'password123',
);

// OAuth
await account.createOAuth2Session(provider: OAuthProvider.google);

// Get current user
final user = await account.get();

// Logout
await account.deleteSession(sessionId: 'current');
```

---

## Part 5: Database Operations

### 5.1 TypeScript CRUD

```typescript
import { databases } from './appwrite';
import { ID, Query } from 'appwrite';

const DATABASE_ID = 'main';
const COLLECTION_ID = 'posts';

// CREATE
const doc = await databases.createDocument(
  DATABASE_ID,
  COLLECTION_ID,
  ID.unique(),
  {
    title: 'Hello World',
    content: 'First post content',
    published: true,
    userId: user.$id,
  }
);

// READ single
const doc = await databases.getDocument(DATABASE_ID, COLLECTION_ID, documentId);

// READ with queries
const docs = await databases.listDocuments(
  DATABASE_ID,
  COLLECTION_ID,
  [
    Query.equal('published', true),
    Query.orderDesc('$createdAt'),
    Query.limit(10),
  ]
);

// UPDATE
await databases.updateDocument(
  DATABASE_ID,
  COLLECTION_ID,
  documentId,
  { title: 'Updated Title' }
);

// DELETE
await databases.deleteDocument(DATABASE_ID, COLLECTION_ID, documentId);
```

### 5.2 Flutter/Dart CRUD

```dart
const databaseId = 'main';
const collectionId = 'posts';

// CREATE
final doc = await databases.createDocument(
  databaseId: databaseId,
  collectionId: collectionId,
  documentId: ID.unique(),
  data: {
    'title': 'Hello World',
    'content': 'First post',
    'published': true,
  },
);

// READ with queries
final docs = await databases.listDocuments(
  databaseId: databaseId,
  collectionId: collectionId,
  queries: [
    Query.equal('published', true),
    Query.orderDesc('\$createdAt'),
    Query.limit(10),
  ],
);

// UPDATE
await databases.updateDocument(
  databaseId: databaseId,
  collectionId: collectionId,
  documentId: docId,
  data: {'title': 'Updated'},
);

// DELETE
await databases.deleteDocument(
  databaseId: databaseId,
  collectionId: collectionId,
  documentId: docId,
);
```

### 5.3 Query Operators

| Query | Description |
|-------|-------------|
| `Query.equal('field', value)` | Exact match |
| `Query.notEqual('field', value)` | Not equal |
| `Query.greaterThan('field', value)` | Greater than |
| `Query.lessThan('field', value)` | Less than |
| `Query.search('field', 'keyword')` | Full-text search |
| `Query.between('field', min, max)` | Range |
| `Query.isNull('field')` | Is null |
| `Query.isNotNull('field')` | Is not null |
| `Query.startsWith('field', 'prefix')` | Starts with |
| `Query.contains('field', value)` | Array contains |
| `Query.orderAsc('field')` | Sort ascending |
| `Query.orderDesc('field')` | Sort descending |
| `Query.limit(n)` | Limit results |
| `Query.offset(n)` | Skip results |

---

## Part 6: Realtime

### 6.1 TypeScript

```typescript
import { client } from './appwrite';

// Subscribe to document changes
const unsubscribe = client.subscribe(
  `databases.${DATABASE_ID}.collections.${COLLECTION_ID}.documents`,
  (response) => {
    console.log('Event:', response.events);
    console.log('Payload:', response.payload);
    
    if (response.events.includes('databases.*.collections.*.documents.*.create')) {
      addDocument(response.payload);
    }
    if (response.events.includes('databases.*.collections.*.documents.*.delete')) {
      removeDocument(response.payload.$id);
    }
  }
);

// Subscribe to specific document
client.subscribe(
  `databases.${DATABASE_ID}.collections.${COLLECTION_ID}.documents.${documentId}`,
  (response) => console.log('Document changed:', response.payload)
);

// Subscribe to file uploads
client.subscribe(`buckets.${BUCKET_ID}.files`, (response) => {
  console.log('File event:', response.events);
});

// Unsubscribe
unsubscribe();
```

### 6.2 Flutter/Dart

```dart
final realtime = Realtime(client);

final subscription = realtime.subscribe([
  'databases.$databaseId.collections.$collectionId.documents'
]);

subscription.stream.listen((event) {
  print('Event: ${event.events}');
  print('Payload: ${event.payload}');
});

// Unsubscribe
subscription.close();
```

---

## Part 7: Storage

### 7.1 TypeScript

```typescript
import { storage } from './appwrite';
import { ID } from 'appwrite';

const BUCKET_ID = 'uploads';

// Upload file
const file = await storage.createFile(
  BUCKET_ID,
  ID.unique(),
  document.getElementById('fileInput').files[0]
);

// Get file preview (images)
const preview = storage.getFilePreview(
  BUCKET_ID,
  fileId,
  400,  // width
  300   // height
);

// Get file download URL
const download = storage.getFileDownload(BUCKET_ID, fileId);

// Get file view URL
const view = storage.getFileView(BUCKET_ID, fileId);

// Delete file
await storage.deleteFile(BUCKET_ID, fileId);
```

### 7.2 Flutter/Dart

```dart
import 'dart:io';

// Upload file
final file = await storage.createFile(
  bucketId: 'uploads',
  fileId: ID.unique(),
  file: InputFile.fromPath(path: '/path/to/file.jpg'),
);

// Get preview bytes (for Image widget)
final bytes = await storage.getFilePreview(
  bucketId: 'uploads',
  fileId: fileId,
  width: 400,
  height: 300,
);

// Delete
await storage.deleteFile(bucketId: 'uploads', fileId: fileId);
```

---

## Part 8: Cloud Functions

### 8.1 Create Function (Node.js)

```javascript
// functions/hello/src/main.js
import { Client, Databases } from 'node-appwrite';

export default async ({ req, res, log, error }) => {
  const client = new Client()
    .setEndpoint(process.env.APPWRITE_FUNCTION_API_ENDPOINT)
    .setProject(process.env.APPWRITE_FUNCTION_PROJECT_ID)
    .setKey(process.env.APPWRITE_API_KEY);

  const databases = new Databases(client);

  try {
    const { name } = JSON.parse(req.body);
    
    const doc = await databases.createDocument(
      'main', 'users', 'unique()',
      { name, createdAt: new Date().toISOString() }
    );

    return res.json({ success: true, doc });
  } catch (err) {
    error(err.message);
    return res.json({ success: false, error: err.message }, 500);
  }
};
```

### 8.2 Deploy

```bash
# Install Appwrite CLI
npm install -g appwrite-cli

# Login
appwrite login

# Init project
appwrite init project

# Init function
appwrite init function

# Deploy
appwrite deploy function
```

---

## Part 9: Permissions

### 9.1 Document Permissions

```typescript
import { Permission, Role } from 'appwrite';

// Create with permissions
await databases.createDocument(
  DATABASE_ID,
  COLLECTION_ID,
  ID.unique(),
  { title: 'My Post' },
  [
    Permission.read(Role.any()),           // Public read
    Permission.write(Role.user(userId)),   // Owner write
    Permission.delete(Role.user(userId)),  // Owner delete
  ]
);
```

### 9.2 Permission Types

| Permission | Description |
|------------|-------------|
| `Role.any()` | Anyone (public) |
| `Role.guests()` | Unauthenticated users |
| `Role.users()` | Any authenticated user |
| `Role.user(id)` | Specific user |
| `Role.team(id)` | Team members |
| `Role.team(id, role)` | Team members with role |

---

## Part 10: Docker Self-Hosting Tips

```yaml
# docker-compose.override.yml
services:
  appwrite:
    environment:
      - _APP_DOMAIN=appwrite.yourdomain.com
      - _APP_DOMAIN_TARGET=appwrite.yourdomain.com
      - _APP_OPENSSL_KEY_V1=your-secret-key
      - _APP_REDIS_HOST=redis
      - _APP_REDIS_PORT=6379
      - _APP_SMTP_HOST=smtp.example.com
      - _APP_SMTP_PORT=587
```

**Common Commands:**

```bash
# Start
docker compose up -d

# Stop
docker compose down

# View logs
docker compose logs -f appwrite

# Update
docker compose pull && docker compose up -d
```

---

## Best Practices

### ✅ Do This

- Set proper document/collection permissions
- Use environment variables for secrets
- Implement proper error handling
- Use realtime for live updates
- Backup data regularly (self-hosted)

### ❌ Avoid

- Exposing API keys in client code
- Skipping permission setup
- Using admin SDK in client apps
- Ignoring rate limits

---

## Related Skills

- `@senior-firebase-developer` - Alternative BaaS
- `@senior-supabase-developer` - PostgreSQL BaaS
- `@docker-containerization-specialist` - Self-hosting

---
name: real-time-collaboration
description: "Expert real-time collaboration systems including CRDT, operational transformation, presence indicators, and collaborative editing"
---

# Real-Time Collaboration

## Overview

This skill transforms you into a **Real-Time Collaboration Expert**. You will master **CRDTs**, **Operational Transformation**, **Presence Indicators**, **Conflict Resolution**, and **Collaborative Editing** for building production-ready collaboration features.

## When to Use This Skill

- Use when building collaborative editors
- Use when implementing real-time sync
- Use when creating multiplayer features
- Use when handling offline-first sync
- Use when building presence indicators

---

## Part 1: Collaboration Fundamentals

### 1.1 Sync Strategies

| Strategy | Description | Use Case |
|----------|-------------|----------|
| **Last Write Wins** | Simple, lossy | Low contention |
| **Operational Transform** | Transform operations | Google Docs |
| **CRDT** | Conflict-free merge | Figma, Linear |
| **Event Sourcing** | Replay events | Audit-heavy apps |

### 1.2 Key Concepts

| Concept | Description |
|---------|-------------|
| **CRDT** | Conflict-free Replicated Data Type |
| **OT** | Operational Transformation |
| **Presence** | Who's online/where |
| **Cursor** | User's position in doc |
| **Version Vector** | Track causality |

---

## Part 2: Presence System

### 2.1 WebSocket Presence

```typescript
interface UserPresence {
  oderId: string;
  name: string;
  color: string;
  cursor?: { x: number; y: number };
  selection?: { start: number; end: number };
  lastActive: number;
}

// Server-side presence management
const roomPresence = new Map<string, Map<string, UserPresence>>();

wss.on('connection', (ws, req) => {
  const roomId = req.url.split('/')[2];
  const userId = getUserIdFromToken(req);
  
  // Add to room
  if (!roomPresence.has(roomId)) {
    roomPresence.set(roomId, new Map());
  }
  
  const room = roomPresence.get(roomId)!;
  
  ws.on('message', (data) => {
    const msg = JSON.parse(data.toString());
    
    if (msg.type === 'presence') {
      room.set(userId, {
        userId,
        name: msg.name,
        color: msg.color,
        cursor: msg.cursor,
        selection: msg.selection,
        lastActive: Date.now(),
      });
      
      // Broadcast to others
      broadcastToRoom(roomId, {
        type: 'presence_update',
        users: Array.from(room.values()),
      }, userId);
    }
  });
  
  ws.on('close', () => {
    room.delete(userId);
    broadcastToRoom(roomId, {
      type: 'user_left',
      userId,
    });
  });
});
```

### 2.2 React Presence Hook

```typescript
function usePresence(roomId: string) {
  const [users, setUsers] = useState<UserPresence[]>([]);
  const ws = useWebSocket(`wss://api.example.com/rooms/${roomId}`);
  
  useEffect(() => {
    ws.onmessage = (event) => {
      const msg = JSON.parse(event.data);
      
      if (msg.type === 'presence_update') {
        setUsers(msg.users);
      }
      
      if (msg.type === 'user_left') {
        setUsers(prev => prev.filter(u => u.userId !== msg.userId));
      }
    };
  }, [ws]);
  
  const updatePresence = useCallback((cursor: { x: number; y: number }) => {
    ws.send(JSON.stringify({
      type: 'presence',
      cursor,
      name: currentUser.name,
      color: currentUser.color,
    }));
  }, [ws]);
  
  return { users, updatePresence };
}
```

---

## Part 3: CRDTs

### 3.1 G-Counter (Grow-Only Counter)

```typescript
class GCounter {
  private counts: Map<string, number> = new Map();
  
  constructor(private nodeId: string) {}
  
  increment(amount = 1) {
    const current = this.counts.get(this.nodeId) || 0;
    this.counts.set(this.nodeId, current + amount);
  }
  
  value(): number {
    return Array.from(this.counts.values()).reduce((sum, c) => sum + c, 0);
  }
  
  merge(other: GCounter) {
    for (const [nodeId, count] of other.counts) {
      const current = this.counts.get(nodeId) || 0;
      this.counts.set(nodeId, Math.max(current, count));
    }
  }
  
  state(): Record<string, number> {
    return Object.fromEntries(this.counts);
  }
}
```

### 3.2 LWW-Register (Last-Writer-Wins)

```typescript
class LWWRegister<T> {
  private value: T | null = null;
  private timestamp = 0;
  private nodeId: string;
  
  constructor(nodeId: string) {
    this.nodeId = nodeId;
  }
  
  set(value: T, ts = Date.now()) {
    if (ts > this.timestamp) {
      this.value = value;
      this.timestamp = ts;
    }
  }
  
  get(): T | null {
    return this.value;
  }
  
  merge(other: LWWRegister<T>) {
    if (other.timestamp > this.timestamp) {
      this.value = other.value;
      this.timestamp = other.timestamp;
    }
  }
}
```

### 3.3 Using Yjs (Production CRDT Library)

```typescript
import * as Y from 'yjs';
import { WebsocketProvider } from 'y-websocket';

// Create document
const ydoc = new Y.Doc();

// Connect to server
const provider = new WebsocketProvider(
  'wss://y-websocket.example.com',
  'room-id',
  ydoc
);

// Shared types
const ytext = ydoc.getText('content');
const ymap = ydoc.getMap('metadata');
const yarray = ydoc.getArray('items');

// Observe changes
ytext.observe((event) => {
  console.log('Text changed:', ytext.toString());
});

// Make changes
ytext.insert(0, 'Hello');
ymap.set('title', 'My Document');
yarray.push(['item1', 'item2']);

// Awareness (presence)
const { awareness } = provider;

awareness.setLocalStateField('user', {
  name: 'John',
  color: '#ff0000',
});

awareness.on('change', () => {
  const states = Array.from(awareness.getStates().values());
  console.log('Users:', states);
});
```

---

## Part 4: Operational Transform

### 4.1 Basic OT for Text

```typescript
type Operation = 
  | { type: 'insert'; pos: number; text: string }
  | { type: 'delete'; pos: number; length: number };

function transform(op1: Operation, op2: Operation): Operation {
  // Transform op1 against op2
  if (op1.type === 'insert' && op2.type === 'insert') {
    if (op1.pos <= op2.pos) {
      return op1;
    } else {
      return { ...op1, pos: op1.pos + op2.text.length };
    }
  }
  
  if (op1.type === 'insert' && op2.type === 'delete') {
    if (op1.pos <= op2.pos) {
      return op1;
    } else if (op1.pos >= op2.pos + op2.length) {
      return { ...op1, pos: op1.pos - op2.length };
    } else {
      return { ...op1, pos: op2.pos };
    }
  }
  
  // ... more cases
  return op1;
}
```

### 4.2 Using Automerge

```typescript
import * as Automerge from '@automerge/automerge';

// Create document
let doc = Automerge.init<{ text: Automerge.Text }>();

// Make changes
doc = Automerge.change(doc, 'Add text', (d) => {
  d.text = new Automerge.Text();
  d.text.insertAt(0, 'Hello, world!');
});

// Get binary for sync
const binary = Automerge.save(doc);

// Merge with another doc
const otherDoc = Automerge.load<{ text: Automerge.Text }>(otherBinary);
doc = Automerge.merge(doc, otherDoc);

// Get changes since version
const changes = Automerge.getChanges(oldDoc, doc);
```

---

## Part 5: Collaborative Editor

### 5.1 React + Yjs + TipTap

```typescript
import { useEditor, EditorContent } from '@tiptap/react';
import StarterKit from '@tiptap/starter-kit';
import Collaboration from '@tiptap/extension-collaboration';
import CollaborationCursor from '@tiptap/extension-collaboration-cursor';
import * as Y from 'yjs';
import { WebsocketProvider } from 'y-websocket';

function CollaborativeEditor({ roomId }: { roomId: string }) {
  const ydoc = useMemo(() => new Y.Doc(), []);
  
  const provider = useMemo(() =>
    new WebsocketProvider('wss://collab.example.com', roomId, ydoc),
    [ydoc, roomId]
  );
  
  const editor = useEditor({
    extensions: [
      StarterKit,
      Collaboration.configure({ document: ydoc }),
      CollaborationCursor.configure({
        provider,
        user: { name: currentUser.name, color: currentUser.color },
      }),
    ],
  });
  
  return (
    <div>
      <OnlineUsers provider={provider} />
      <EditorContent editor={editor} />
    </div>
  );
}

function OnlineUsers({ provider }: { provider: WebsocketProvider }) {
  const [users, setUsers] = useState<User[]>([]);
  
  useEffect(() => {
    const { awareness } = provider;
    
    const handleChange = () => {
      setUsers(Array.from(awareness.getStates().values())
        .filter(s => s.user)
        .map(s => s.user));
    };
    
    awareness.on('change', handleChange);
    return () => awareness.off('change', handleChange);
  }, [provider]);
  
  return (
    <div className="flex gap-2">
      {users.map(user => (
        <div
          key={user.name}
          className="w-8 h-8 rounded-full"
          style={{ backgroundColor: user.color }}
          title={user.name}
        />
      ))}
    </div>
  );
}
```

---

## Part 6: Conflict Resolution

### 6.1 Merge Strategies

| Strategy | Description |
|----------|-------------|
| **Last Write Wins** | Latest timestamp wins |
| **First Write Wins** | Earliest change preserved |
| **Manual Resolution** | User chooses |
| **Auto-Merge** | CRDT handles |

---

## Part 7: Best Practices Checklist

### ✅ Do This

- ✅ **Use Established Libraries**: Yjs, Automerge.
- ✅ **Debounce Presence Updates**: Don't spam.
- ✅ **Handle Reconnection**: Queue offline changes.

### ❌ Avoid This

- ❌ **Implement OT From Scratch**: Very complex.
- ❌ **Sync Full Document**: Send deltas only.
- ❌ **Ignore Offline Mode**: Users go offline.

---

## Related Skills

- `@queue-system-specialist` - Message queues
- `@senior-react-developer` - React integration
- `@senior-nodejs-developer` - WebSocket servers

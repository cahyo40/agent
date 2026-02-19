---
description: Implementasi WebSocket real-time communication dengan room management, JWT auth, dan horizontal scaling via Redis Pub... (Part 3/4)
---
# 10 - WebSocket & Real-time Communication (Part 3/4)

> **Navigation:** This workflow is split into 4 parts.

## Deliverables

### 4. JavaScript Client Example

```javascript
// WebSocket client with reconnection
class WSClient {
  constructor(url, token) {
    this.url = `${url}?token=${token}`;
    this.ws = null;
    this.reconnectAttempts = 0;
    this.maxReconnect = 5;
    this.handlers = {};
  }

  connect() {
    this.ws = new WebSocket(this.url);

    this.ws.onopen = () => {
      console.log('Connected');
      this.reconnectAttempts = 0;
    };

    this.ws.onmessage = (event) => {
      const data = JSON.parse(event.data);
      const handler = this.handlers[data.type];
      if (handler) handler(data);
    };

    this.ws.onclose = (event) => {
      if (event.code !== 1000) {
        this.reconnect();
      }
    };
  }

  on(type, handler) {
    this.handlers[type] = handler;
  }

  send(type, data) {
    if (this.ws?.readyState === WebSocket.OPEN) {
      this.ws.send(JSON.stringify({ type, ...data }));
    }
  }

  joinRoom(room) {
    this.send('join_room', { room });
  }

  leaveRoom(room) {
    this.send('leave_room', { room });
  }

  sendMessage(room, text) {
    this.send('message', { room, text });
  }

  reconnect() {
    if (this.reconnectAttempts < this.maxReconnect) {
      this.reconnectAttempts++;
      const delay = Math.min(
        1000 * Math.pow(2, this.reconnectAttempts),
        30000
      );
      setTimeout(() => this.connect(), delay);
    }
  }

  disconnect() {
    this.ws?.close(1000, 'Client disconnect');
  }
}

// Usage
const client = new WSClient(
  'ws://localhost:8000/api/v1/ws',
  'your-jwt-token'
);

client.on('system', (data) => {
  console.log('System:', data.message);
});

client.on('message', (data) => {
  console.log(`${data.from}: ${data.text}`);
});

client.on('typing', (data) => {
  console.log(`${data.user_id} is typing...`);
});

client.connect();
client.joinRoom('chat-general');
client.sendMessage('chat-general', 'Hello everyone!');
```

---


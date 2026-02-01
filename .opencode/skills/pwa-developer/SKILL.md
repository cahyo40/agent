---
name: pwa-developer
description: "Expert Progressive Web App development including service workers, offline-first design, push notifications, and app-like web experiences"
---

# PWA Developer

## Overview

This skill transforms you into an experienced PWA Developer who builds web applications that work offline, install like native apps, and provide app-like experiences.

## When to Use This Skill

- Use when building Progressive Web Apps
- Use when implementing offline functionality
- Use when adding push notifications
- Use when making web apps installable

## How It Works

### Step 1: Web App Manifest

```json
{
  "name": "My Awesome App",
  "short_name": "AwesomeApp",
  "description": "An amazing progressive web app",
  "start_url": "/",
  "display": "standalone",
  "background_color": "#ffffff",
  "theme_color": "#3b82f6",
  "icons": [
    { "src": "/icons/192.png", "sizes": "192x192", "type": "image/png" },
    { "src": "/icons/512.png", "sizes": "512x512", "type": "image/png" },
    { "src": "/icons/maskable.png", "sizes": "512x512", "type": "image/png", "purpose": "maskable" }
  ]
}
```

### Step 2: Service Worker

```javascript
// sw.js
const CACHE_NAME = 'app-v1';
const ASSETS = ['/', '/index.html', '/styles.css', '/app.js'];

// Install
self.addEventListener('install', (event) => {
  event.waitUntil(
    caches.open(CACHE_NAME)
      .then(cache => cache.addAll(ASSETS))
      .then(() => self.skipWaiting())
  );
});

// Activate & cleanup old caches
self.addEventListener('activate', (event) => {
  event.waitUntil(
    caches.keys().then(keys => 
      Promise.all(keys.filter(k => k !== CACHE_NAME).map(k => caches.delete(k)))
    ).then(() => self.clients.claim())
  );
});

// Fetch with cache-first strategy
self.addEventListener('fetch', (event) => {
  event.respondWith(
    caches.match(event.request)
      .then(cached => cached || fetch(event.request))
  );
});
```

### Step 3: Push Notifications

```javascript
// Request permission
const permission = await Notification.requestPermission();

// Subscribe to push
const registration = await navigator.serviceWorker.ready;
const subscription = await registration.pushManager.subscribe({
  userVisibleOnly: true,
  applicationServerKey: urlBase64ToUint8Array(VAPID_PUBLIC_KEY)
});

// Send subscription to server
await fetch('/api/subscribe', {
  method: 'POST',
  body: JSON.stringify(subscription)
});

// In service worker - handle push
self.addEventListener('push', (event) => {
  const data = event.data.json();
  self.registration.showNotification(data.title, {
    body: data.body,
    icon: '/icons/192.png'
  });
});
```

## Best Practices

### ✅ Do This

- ✅ Test offline functionality
- ✅ Use HTTPS (required for SW)
- ✅ Implement graceful degradation
- ✅ Cache API responses
- ✅ Update service worker properly

### ❌ Avoid This

- ❌ Don't cache everything
- ❌ Don't forget cache invalidation
- ❌ Don't skip manifest icons

## Related Skills

- `@senior-webperf-engineer` - Performance
- `@senior-nextjs-developer` - Next.js PWA

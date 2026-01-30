---
name: whatsapp-bot-developer
description: "Expert WhatsApp bot development using WhatsApp Business API and Cloud API"
---

# WhatsApp Bot Developer

## Overview

Build WhatsApp bots using official Business API for customer engagement.

## When to Use This Skill

- Use when building WhatsApp bots
- Use when integrating WhatsApp Business API

## How It Works

### Step 1: Cloud API Setup

```markdown
## Prerequisites
1. Meta Business Account
2. WhatsApp Business Account
3. Phone number for WhatsApp
4. Webhook endpoint (HTTPS)

## Get Access Token
1. Go to developers.facebook.com
2. Create App → Business → WhatsApp
3. Get temporary access token
4. Generate permanent token for production
```

### Step 2: Webhook Handler

```javascript
const express = require('express');
const app = express();

const VERIFY_TOKEN = 'your_verify_token';
const ACCESS_TOKEN = process.env.WHATSAPP_TOKEN;
const PHONE_NUMBER_ID = process.env.PHONE_NUMBER_ID;

// Webhook verification
app.get('/webhook', (req, res) => {
  const mode = req.query['hub.mode'];
  const token = req.query['hub.verify_token'];
  const challenge = req.query['hub.challenge'];

  if (mode === 'subscribe' && token === VERIFY_TOKEN) {
    res.status(200).send(challenge);
  } else {
    res.sendStatus(403);
  }
});

// Receive messages
app.post('/webhook', async (req, res) => {
  const body = req.body;

  if (body.object === 'whatsapp_business_account') {
    const entry = body.entry[0];
    const changes = entry.changes[0];
    const message = changes.value.messages?.[0];

    if (message) {
      const from = message.from;
      const text = message.text?.body;
      
      await handleMessage(from, text);
    }
  }
  res.sendStatus(200);
});
```

### Step 3: Send Messages

```javascript
const axios = require('axios');

async function sendMessage(to, text) {
  await axios.post(
    `https://graph.facebook.com/v18.0/${PHONE_NUMBER_ID}/messages`,
    {
      messaging_product: 'whatsapp',
      to: to,
      type: 'text',
      text: { body: text }
    },
    {
      headers: { Authorization: `Bearer ${ACCESS_TOKEN}` }
    }
  );
}

// Send interactive buttons
async function sendButtons(to, bodyText, buttons) {
  await axios.post(
    `https://graph.facebook.com/v18.0/${PHONE_NUMBER_ID}/messages`,
    {
      messaging_product: 'whatsapp',
      to: to,
      type: 'interactive',
      interactive: {
        type: 'button',
        body: { text: bodyText },
        action: {
          buttons: buttons.map((btn, i) => ({
            type: 'reply',
            reply: { id: `btn_${i}`, title: btn }
          }))
        }
      }
    },
    { headers: { Authorization: `Bearer ${ACCESS_TOKEN}` } }
  );
}

// Send template message
async function sendTemplate(to, templateName, params) {
  await axios.post(
    `https://graph.facebook.com/v18.0/${PHONE_NUMBER_ID}/messages`,
    {
      messaging_product: 'whatsapp',
      to: to,
      type: 'template',
      template: {
        name: templateName,
        language: { code: 'id' },
        components: [{
          type: 'body',
          parameters: params.map(p => ({ type: 'text', text: p }))
        }]
      }
    },
    { headers: { Authorization: `Bearer ${ACCESS_TOKEN}` } }
  );
}
```

### Step 4: Message Handler

```javascript
async function handleMessage(from, text) {
  const lowerText = text.toLowerCase();

  if (lowerText === 'halo' || lowerText === 'hi') {
    await sendButtons(from, 'Halo! Ada yang bisa saya bantu?', [
      'Cek Pesanan',
      'Katalog Produk',
      'Hubungi CS'
    ]);
  } else if (lowerText.includes('pesanan')) {
    await sendMessage(from, 'Silakan kirim nomor pesanan Anda.');
  } else {
    // AI response
    const aiResponse = await getAIResponse(text);
    await sendMessage(from, aiResponse);
  }
}
```

## Best Practices

- ✅ Use templates for first message
- ✅ Handle all message types
- ✅ Respond within 24 hours
- ❌ Don't spam users
- ❌ Don't skip opt-in consent

## Related Skills

- `@chatbot-developer`
- `@customer-support-bot`

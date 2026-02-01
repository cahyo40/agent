---
name: telegram-bot-developer
description: "Expert Telegram bot development using Telegram Bot API"
---

# Telegram Bot Developer

## Overview

Build Telegram bots for automation, notifications, and user interaction.

## When to Use This Skill

- Use when building Telegram bots
- Use when creating notification systems

## How It Works

### Step 1: Bot Setup

```markdown
## Create Bot
1. Open @BotFather on Telegram
2. Send /newbot
3. Set name and username
4. Copy the API token

## Bot Commands
/setname - Set bot name
/setdescription - Set description
/setcommands - Set command menu
/setuserpic - Set profile picture
```

### Step 2: Basic Bot (node-telegram-bot-api)

```javascript
const TelegramBot = require('node-telegram-bot-api');
const bot = new TelegramBot(process.env.TELEGRAM_TOKEN, { polling: true });

// Handle /start command
bot.onText(/\/start/, (msg) => {
  const chatId = msg.chat.id;
  bot.sendMessage(chatId, 'Selamat datang! Ketik /help untuk bantuan.');
});

// Handle text messages
bot.on('message', async (msg) => {
  const chatId = msg.chat.id;
  const text = msg.text;

  if (text.startsWith('/')) return; // Skip commands

  // AI response
  const response = await getAIResponse(text);
  bot.sendMessage(chatId, response);
});

// Handle callback queries (inline buttons)
bot.on('callback_query', (query) => {
  const chatId = query.message.chat.id;
  const data = query.data;

  bot.answerCallbackQuery(query.id);
  bot.sendMessage(chatId, `Anda memilih: ${data}`);
});
```

### Step 3: Inline Keyboard

```javascript
// Send message with buttons
bot.sendMessage(chatId, 'Pilih menu:', {
  reply_markup: {
    inline_keyboard: [
      [
        { text: '📦 Cek Pesanan', callback_data: 'check_order' },
        { text: '🛒 Katalog', callback_data: 'catalog' }
      ],
      [
        { text: '📞 Hubungi CS', callback_data: 'contact' }
      ]
    ]
  }
});

// Reply keyboard (persistent)
bot.sendMessage(chatId, 'Menu utama:', {
  reply_markup: {
    keyboard: [
      ['🏠 Home', '📦 Pesanan'],
      ['⚙️ Pengaturan', '❓ Bantuan']
    ],
    resize_keyboard: true
  }
});
```

### Step 4: Send Media

```javascript
// Send photo
bot.sendPhoto(chatId, 'https://example.com/image.jpg', {
  caption: 'Produk terbaru!'
});

// Send document
bot.sendDocument(chatId, './invoice.pdf');

// Send location
bot.sendLocation(chatId, -6.2088, 106.8456);

// Send contact
bot.sendContact(chatId, '+628123456789', 'Customer Service');
```

### Step 5: Webhook (Production)

```javascript
const express = require('express');
const app = express();

const bot = new TelegramBot(process.env.TELEGRAM_TOKEN);
bot.setWebHook(`https://yourdomain.com/bot${process.env.TELEGRAM_TOKEN}`);

app.post(`/bot${process.env.TELEGRAM_TOKEN}`, (req, res) => {
  bot.processUpdate(req.body);
  res.sendStatus(200);
});

app.listen(3000);
```

## Best Practices

- ✅ Use webhook in production
- ✅ Handle errors gracefully
- ✅ Rate limit user requests
- ❌ Don't expose token
- ❌ Don't ignore updates

## Related Skills

- `@chatbot-developer`
- `@senior-nodejs-developer`

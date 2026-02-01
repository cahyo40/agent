---
name: customer-support-bot
description: "Expert customer support chatbot development with FAQ, ticketing, and human handoff"
---

# Customer Support Bot

## Overview

Build intelligent customer support bots with FAQ handling, ticket creation, and agent handoff.

## When to Use This Skill

- Use when building support bots
- Use when automating customer service

## How It Works

### Step 1: Support Bot Architecture

```markdown
## Components

### Intent Classification
- FAQ questions
- Order inquiries
- Complaints
- General questions

### Knowledge Base
- FAQ database
- Product information
- Policy documents

### Ticket System
- Create tickets
- Track status
- Escalate to human

### Human Handoff
- Detect frustration
- Complex issues
- User request
```

### Step 2: FAQ Handler

```javascript
const faqs = [
  {
    keywords: ['jam', 'buka', 'operasional'],
    answer: 'Kami buka Senin-Jumat, 09:00-18:00 WIB.'
  },
  {
    keywords: ['pengiriman', 'kirim', 'ongkir'],
    answer: 'Pengiriman 2-3 hari kerja. Gratis ongkir untuk pembelian di atas Rp100.000.'
  },
  {
    keywords: ['retur', 'kembalikan', 'refund'],
    answer: 'Retur dapat dilakukan dalam 7 hari. Hubungi CS untuk proses refund.'
  }
];

function findFAQ(message) {
  const lowerMsg = message.toLowerCase();
  
  for (const faq of faqs) {
    if (faq.keywords.some(kw => lowerMsg.includes(kw))) {
      return faq.answer;
    }
  }
  return null;
}
```

### Step 3: AI-Powered Support

```javascript
const systemPrompt = `
Anda adalah customer support agent untuk Toko ABC.
Panduan:
- Jawab dengan ramah dan profesional
- Gunakan bahasa Indonesia yang baik
- Jika tidak tahu, tawarkan hubungkan dengan CS manusia
- Jangan membuat janji yang tidak bisa ditepati

Informasi toko:
- Jam operasional: Senin-Jumat 09:00-18:00
- Pengiriman: 2-3 hari kerja
- Retur: 7 hari setelah diterima
`;

async function handleSupportMessage(userId, message, history) {
  // Check FAQ first
  const faqAnswer = findFAQ(message);
  if (faqAnswer) return faqAnswer;

  // AI response
  const response = await openai.chat.completions.create({
    model: 'gpt-4',
    messages: [
      { role: 'system', content: systemPrompt },
      ...history,
      { role: 'user', content: message }
    ]
  });

  return response.choices[0].message.content;
}
```

### Step 4: Ticket Creation

```javascript
async function createTicket(userId, issue, priority = 'normal') {
  const ticket = await db.tickets.create({
    ticket_id: generateTicketId(),
    user_id: userId,
    issue: issue,
    priority: priority, // low, normal, high, urgent
    status: 'open',
    created_at: new Date()
  });

  return `Tiket #${ticket.ticket_id} telah dibuat. Tim kami akan menghubungi Anda dalam 1x24 jam.`;
}

async function checkTicketStatus(ticketId) {
  const ticket = await db.tickets.findOne({ ticket_id: ticketId });
  
  if (!ticket) return 'Tiket tidak ditemukan.';
  
  return `Tiket #${ticketId}\nStatus: ${ticket.status}\nDibuat: ${ticket.created_at}`;
}
```

### Step 5: Human Handoff

```javascript
const frustrationKeywords = ['kesal', 'marah', 'kecewa', 'bodoh', 'lambat', 'parah'];

function detectFrustration(message) {
  const lower = message.toLowerCase();
  return frustrationKeywords.some(kw => lower.includes(kw));
}

async function handleMessage(userId, message) {
  // Check for frustration
  if (detectFrustration(message)) {
    await notifyHumanAgent(userId, message);
    return 'Saya mengerti Anda tidak puas. Saya akan menghubungkan Anda dengan tim kami segera.';
  }

  // Check for human request
  if (message.toLowerCase().includes('bicara dengan manusia')) {
    await notifyHumanAgent(userId, message);
    return 'Baik, agent kami akan menghubungi Anda dalam beberapa menit.';
  }

  // Normal processing
  return await handleSupportMessage(userId, message);
}
```

## Best Practices

- ✅ Always offer human handoff
- ✅ Track conversation history
- ✅ Set response time expectations
- ✅ Collect feedback after resolution
- ❌ Don't ignore negative sentiment
- ❌ Don't make false promises

## Related Skills

- `@chatbot-developer`
- `@whatsapp-bot-developer`

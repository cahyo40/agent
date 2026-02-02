---
name: customer-support-bot
description: "Expert customer support chatbot development with FAQ, ticketing, and human handoff"
---

# Customer Support Bot

## Overview

This skill transforms you into a **Customer Support Automation Expert**. You will master **FAQ Bots**, **Ticket Creation**, **Live Chat Handoff**, **Sentiment Detection**, and **Resolution Tracking** for building production-ready support automation.

## When to Use This Skill

- Use when building support chatbots
- Use when automating FAQ responses
- Use when implementing ticketing systems
- Use when creating live chat handoff
- Use when tracking support metrics

---

## Part 1: Support Bot Architecture

### 1.1 System Components

```
┌─────────────────────────────────────────────────────────────┐
│                   Support Bot Platform                       │
├────────────┬─────────────┬─────────────┬────────────────────┤
│ FAQ Engine │ Ticketing   │ Live Chat   │ Analytics          │
├────────────┴─────────────┴─────────────┴────────────────────┤
│               Knowledge Base & Embeddings                    │
├─────────────────────────────────────────────────────────────┤
│              CRM Integration & Agent Tools                   │
└─────────────────────────────────────────────────────────────┘
```

### 1.2 Key Concepts

| Concept | Description |
|---------|-------------|
| **First Contact Resolution** | Solved without escalation |
| **Deflection Rate** | Automated vs human handled |
| **CSAT** | Customer Satisfaction Score |
| **Handoff** | Transfer to human agent |
| **Queue** | Waiting customers |
| **Resolution Time** | Time to solve issue |

---

## Part 2: Database Schema

### 2.1 Core Tables

```sql
-- FAQ Articles
CREATE TABLE faq_articles (
    id UUID PRIMARY KEY,
    title VARCHAR(255),
    content TEXT,
    keywords TEXT[],
    category VARCHAR(100),
    embedding VECTOR(1536),  -- For semantic search
    views INTEGER DEFAULT 0,
    helpful_count INTEGER DEFAULT 0,
    not_helpful_count INTEGER DEFAULT 0,
    is_published BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Conversations
CREATE TABLE conversations (
    id UUID PRIMARY KEY,
    customer_id UUID REFERENCES users(id),
    channel VARCHAR(50),  -- 'web', 'whatsapp', 'messenger', 'email'
    status VARCHAR(50) DEFAULT 'active',  -- 'active', 'resolved', 'escalated', 'closed'
    assigned_agent_id UUID REFERENCES agents(id),
    sentiment_score DECIMAL(3, 2),  -- -1 to 1
    priority VARCHAR(20) DEFAULT 'normal',  -- 'low', 'normal', 'high', 'urgent'
    first_response_at TIMESTAMPTZ,
    resolved_at TIMESTAMPTZ,
    csat_score INTEGER,  -- 1-5
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Messages
CREATE TABLE messages (
    id UUID PRIMARY KEY,
    conversation_id UUID REFERENCES conversations(id),
    sender_type VARCHAR(20),  -- 'customer', 'bot', 'agent'
    sender_id UUID,
    content TEXT,
    message_type VARCHAR(20) DEFAULT 'text',  -- 'text', 'image', 'file', 'quick_reply'
    metadata JSONB,  -- For quick replies, attachments, etc.
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Tickets
CREATE TABLE tickets (
    id UUID PRIMARY KEY,
    conversation_id UUID REFERENCES conversations(id),
    customer_id UUID REFERENCES users(id),
    subject VARCHAR(255),
    description TEXT,
    status VARCHAR(50) DEFAULT 'open',  -- 'open', 'pending', 'in_progress', 'resolved', 'closed'
    priority VARCHAR(20) DEFAULT 'normal',
    category VARCHAR(100),
    assigned_to UUID REFERENCES agents(id),
    resolution TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    resolved_at TIMESTAMPTZ
);

-- Canned Responses
CREATE TABLE canned_responses (
    id UUID PRIMARY KEY,
    title VARCHAR(255),
    content TEXT,
    shortcut VARCHAR(50),  -- /greeting, /refund, etc.
    category VARCHAR(100),
    usage_count INTEGER DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW()
);
```

---

## Part 3: FAQ Bot with RAG

### 3.1 Semantic Search

```typescript
import { OpenAI } from 'openai';

const openai = new OpenAI();

async function findRelevantFAQs(query: string, limit = 3): Promise<FAQArticle[]> {
  // Generate embedding for query
  const embeddingResponse = await openai.embeddings.create({
    model: 'text-embedding-3-small',
    input: query,
  });
  
  const queryEmbedding = embeddingResponse.data[0].embedding;
  
  // Vector similarity search
  const results = await db.$queryRaw`
    SELECT 
      id, title, content, category,
      1 - (embedding <=> ${queryEmbedding}::vector) as similarity
    FROM faq_articles
    WHERE is_published = TRUE
    ORDER BY embedding <=> ${queryEmbedding}::vector
    LIMIT ${limit}
  `;
  
  // Filter by similarity threshold
  return results.filter(r => r.similarity > 0.7);
}
```

### 3.2 Generate Response

```typescript
async function generateBotResponse(
  conversationId: string,
  userMessage: string
): Promise<BotResponse> {
  // Get conversation history
  const history = await getConversationHistory(conversationId);
  
  // Find relevant FAQs
  const relevantFAQs = await findRelevantFAQs(userMessage);
  
  // Detect intent and sentiment
  const analysis = await analyzeMessage(userMessage);
  
  // Check if should escalate
  if (analysis.sentiment < -0.5 || analysis.intent === 'speak_to_human') {
    return {
      action: 'escalate',
      message: "I understand you'd like to speak with a support agent. Let me connect you now.",
    };
  }
  
  // Generate response with context
  const systemPrompt = `You are a helpful customer support agent. 
Answer based on the following knowledge base articles:
${relevantFAQs.map(f => `## ${f.title}\n${f.content}`).join('\n\n')}

If you cannot find an answer, offer to connect the customer with a human agent.
Be empathetic and helpful.`;
  
  const response = await openai.chat.completions.create({
    model: 'gpt-4o',
    messages: [
      { role: 'system', content: systemPrompt },
      ...history.map(m => ({
        role: m.senderType === 'customer' ? 'user' : 'assistant',
        content: m.content,
      })),
      { role: 'user', content: userMessage },
    ],
    temperature: 0.7,
  });
  
  const botMessage = response.choices[0].message.content;
  
  // Save message
  await saveMessage(conversationId, 'bot', botMessage);
  
  // Track FAQ usage
  if (relevantFAQs.length > 0) {
    await db.faqArticles.updateMany({
      where: { id: { in: relevantFAQs.map(f => f.id) } },
      data: { views: { increment: 1 } },
    });
  }
  
  return {
    action: 'respond',
    message: botMessage,
    suggestedArticles: relevantFAQs,
  };
}
```

---

## Part 4: Human Handoff

### 4.1 Escalation Logic

```typescript
interface EscalationReason {
  type: 'sentiment' | 'request' | 'complexity' | 'vip' | 'repeat';
  details?: string;
}

async function checkEscalation(
  conversationId: string,
  message: string
): Promise<EscalationReason | null> {
  const conversation = await db.conversations.findUnique({
    where: { id: conversationId },
    include: { customer: true, messages: true },
  });
  
  // VIP customer
  if (conversation.customer.tier === 'vip') {
    return { type: 'vip', details: 'VIP customer' };
  }
  
  // Explicit request
  const requestPhrases = ['speak to human', 'talk to agent', 'real person', 'representative'];
  if (requestPhrases.some(p => message.toLowerCase().includes(p))) {
    return { type: 'request', details: 'Customer requested human agent' };
  }
  
  // Negative sentiment
  const sentiment = await analyzeSentiment(message);
  if (sentiment < -0.5) {
    return { type: 'sentiment', details: `Negative sentiment: ${sentiment}` };
  }
  
  // Too many messages without resolution
  if (conversation.messages.length > 10) {
    return { type: 'complexity', details: 'Extended conversation without resolution' };
  }
  
  return null;
}

async function escalateToHuman(conversationId: string, reason: EscalationReason) {
  // Find available agent
  const agent = await findAvailableAgent();
  
  if (!agent) {
    // No agent available - create ticket
    const ticket = await createTicket(conversationId, reason);
    
    await sendBotMessage(conversationId, 
      `All our agents are currently busy. I've created a ticket (#${ticket.id.slice(0, 8)}) and someone will reach out to you shortly.`
    );
    
    return { action: 'ticket_created', ticketId: ticket.id };
  }
  
  // Assign to agent
  await db.conversations.update({
    where: { id: conversationId },
    data: {
      status: 'escalated',
      assignedAgentId: agent.id,
      priority: reason.type === 'sentiment' ? 'high' : 'normal',
    },
  });
  
  // Notify agent
  await notifyAgent(agent.id, {
    type: 'new_conversation',
    conversationId,
    reason: reason.details,
  });
  
  await sendBotMessage(conversationId, 
    `I'm connecting you with ${agent.name} now. They'll be with you in just a moment.`
  );
  
  return { action: 'escalated', agentId: agent.id };
}
```

---

## Part 5: Support Metrics

### 5.1 Dashboard Metrics

```typescript
interface SupportMetrics {
  totalConversations: number;
  deflectionRate: number;  // Bot resolved / total
  avgFirstResponseTime: number;
  avgResolutionTime: number;
  csatScore: number;
  topCategories: { category: string; count: number }[];
}

async function getSupportMetrics(startDate: Date, endDate: Date): Promise<SupportMetrics> {
  const conversations = await db.conversations.findMany({
    where: {
      createdAt: { gte: startDate, lte: endDate },
    },
  });
  
  const botResolved = conversations.filter(
    c => c.status === 'resolved' && !c.assignedAgentId
  ).length;
  
  const deflectionRate = botResolved / conversations.length;
  
  const avgFirstResponseTime = conversations
    .filter(c => c.firstResponseAt)
    .reduce((sum, c) => sum + differenceInSeconds(c.firstResponseAt, c.createdAt), 0) / conversations.length;
  
  const csatScores = conversations.filter(c => c.csatScore).map(c => c.csatScore);
  const csatScore = csatScores.reduce((a, b) => a + b, 0) / csatScores.length;
  
  return {
    totalConversations: conversations.length,
    deflectionRate,
    avgFirstResponseTime,
    avgResolutionTime: await calculateAvgResolutionTime(startDate, endDate),
    csatScore,
    topCategories: await getTopCategories(startDate, endDate),
  };
}
```

---

## Part 6: Best Practices Checklist

### ✅ Do This

- ✅ **Quick Replies**: Guide user options.
- ✅ **Typing Indicators**: Show bot is processing.
- ✅ **Fallback to Human**: Always offer escalation.

### ❌ Avoid This

- ❌ **Pretend to be Human**: Be transparent about bot.
- ❌ **Loop Forever**: Detect stuck conversations.
- ❌ **Ignore Feedback**: Track helpful/not helpful.

---

## Related Skills

- `@chatbot-developer` - Conversational AI
- `@nlp-specialist` - Intent detection
- `@senior-rag-engineer` - Knowledge retrieval

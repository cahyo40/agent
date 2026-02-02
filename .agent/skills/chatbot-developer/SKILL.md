---
name: chatbot-developer
description: "Expert chatbot development including conversational AI, dialog design, NLU integration, and bot UX"
---

# Chatbot Developer

## Overview

This skill transforms you into a **Conversational AI Expert**. You will master **Dialog Design**, **Intent Recognition**, **Entity Extraction**, **Context Management**, and **Bot UX** for building production-ready chatbot applications.

## When to Use This Skill

- Use when building customer service bots
- Use when implementing dialog flows
- Use when integrating NLU services
- Use when creating voice assistants
- Use when building FAQ bots

---

## Part 1: Chatbot Architecture

### 1.1 System Components

```
┌─────────────────────────────────────────────────────────────┐
│                      Chatbot System                          │
├────────────┬─────────────┬─────────────┬────────────────────┤
│ NLU Engine │ Dialog Mgr  │ Fulfillment │ Response Gen       │
├────────────┴─────────────┴─────────────┴────────────────────┤
│               Context & Session Management                   │
├─────────────────────────────────────────────────────────────┤
│              Channel Integrations                            │
└─────────────────────────────────────────────────────────────┘
```

### 1.2 Key Concepts

| Concept | Description |
|---------|-------------|
| **Intent** | User's goal (book_flight, check_balance) |
| **Entity** | Extracted values (date, city, amount) |
| **Slot** | Required parameter to fulfill intent |
| **Context** | Conversation state and memory |
| **Fallback** | Response when intent unknown |
| **Handoff** | Transfer to human agent |

---

## Part 2: NLU Integration

### 2.1 Intent Classification

```typescript
interface NLUResult {
  intent: { name: string; confidence: number };
  entities: { type: string; value: any; confidence: number }[];
  sentiment?: { score: number; label: string };
}

// Example with Dialogflow
import { SessionsClient } from '@google-cloud/dialogflow';

const client = new SessionsClient();

async function detectIntent(
  projectId: string,
  sessionId: string,
  text: string
): Promise<NLUResult> {
  const sessionPath = client.projectAgentSessionPath(projectId, sessionId);
  
  const request = {
    session: sessionPath,
    queryInput: {
      text: { text, languageCode: 'en' },
    },
  };
  
  const [response] = await client.detectIntent(request);
  const result = response.queryResult;
  
  return {
    intent: {
      name: result.intent.displayName,
      confidence: result.intentDetectionConfidence,
    },
    entities: Object.entries(result.parameters.fields || {}).map(([key, value]) => ({
      type: key,
      value: value.stringValue || value.numberValue || value.listValue,
      confidence: 1,
    })),
    sentiment: result.sentimentAnalysisResult?.queryTextSentiment
      ? {
          score: result.sentimentAnalysisResult.queryTextSentiment.score,
          label: result.sentimentAnalysisResult.queryTextSentiment.score > 0.3
            ? 'positive'
            : result.sentimentAnalysisResult.queryTextSentiment.score < -0.3
            ? 'negative'
            : 'neutral',
        }
      : undefined,
  };
}
```

### 2.2 OpenAI Function Calling

```typescript
import OpenAI from 'openai';

const openai = new OpenAI();

const tools: OpenAI.ChatCompletionTool[] = [
  {
    type: 'function',
    function: {
      name: 'check_order_status',
      description: 'Check the status of a customer order',
      parameters: {
        type: 'object',
        properties: {
          order_id: { type: 'string', description: 'The order ID to look up' },
        },
        required: ['order_id'],
      },
    },
  },
  {
    type: 'function',
    function: {
      name: 'search_products',
      description: 'Search for products in the catalog',
      parameters: {
        type: 'object',
        properties: {
          query: { type: 'string', description: 'Search query' },
          category: { type: 'string', description: 'Product category' },
        },
        required: ['query'],
      },
    },
  },
];

async function processMessage(sessionId: string, message: string) {
  const history = await getConversationHistory(sessionId);
  
  const response = await openai.chat.completions.create({
    model: 'gpt-4o',
    messages: [
      { role: 'system', content: SYSTEM_PROMPT },
      ...history,
      { role: 'user', content: message },
    ],
    tools,
    tool_choice: 'auto',
  });
  
  const assistantMessage = response.choices[0].message;
  
  // Handle function calls
  if (assistantMessage.tool_calls) {
    const toolResults = [];
    
    for (const toolCall of assistantMessage.tool_calls) {
      const args = JSON.parse(toolCall.function.arguments);
      const result = await executeFunction(toolCall.function.name, args);
      
      toolResults.push({
        tool_call_id: toolCall.id,
        role: 'tool' as const,
        content: JSON.stringify(result),
      });
    }
    
    // Get final response with tool results
    const finalResponse = await openai.chat.completions.create({
      model: 'gpt-4o',
      messages: [
        { role: 'system', content: SYSTEM_PROMPT },
        ...history,
        { role: 'user', content: message },
        assistantMessage,
        ...toolResults,
      ],
    });
    
    return finalResponse.choices[0].message.content;
  }
  
  return assistantMessage.content;
}
```

---

## Part 3: Dialog Management

### 3.1 Slot Filling

```typescript
interface Intent {
  name: string;
  requiredSlots: string[];
  optionalSlots?: string[];
  fulfillmentHandler: string;
}

interface DialogState {
  currentIntent?: string;
  filledSlots: Record<string, any>;
  missingSlots: string[];
  turnCount: number;
}

const INTENTS: Intent[] = [
  {
    name: 'book_appointment',
    requiredSlots: ['date', 'time', 'service_type'],
    optionalSlots: ['staff_preference'],
    fulfillmentHandler: 'handleBookAppointment',
  },
];

async function processDialog(sessionId: string, nluResult: NLUResult): Promise<string> {
  const state = await getDialogState(sessionId);
  
  // New intent detected
  if (nluResult.intent.confidence > 0.7 && !state.currentIntent) {
    const intent = INTENTS.find(i => i.name === nluResult.intent.name);
    if (intent) {
      state.currentIntent = intent.name;
      state.missingSlots = [...intent.requiredSlots];
    }
  }
  
  // Fill slots from entities
  for (const entity of nluResult.entities) {
    if (state.missingSlots.includes(entity.type)) {
      state.filledSlots[entity.type] = entity.value;
      state.missingSlots = state.missingSlots.filter(s => s !== entity.type);
    }
  }
  
  // Check if all slots filled
  if (state.missingSlots.length === 0 && state.currentIntent) {
    const intent = INTENTS.find(i => i.name === state.currentIntent);
    const result = await executeHandler(intent.fulfillmentHandler, state.filledSlots);
    
    // Clear state
    await clearDialogState(sessionId);
    
    return result;
  }
  
  // Prompt for next slot
  const nextSlot = state.missingSlots[0];
  await saveDialogState(sessionId, state);
  
  return getSlotPrompt(nextSlot);
}

function getSlotPrompt(slot: string): string {
  const prompts: Record<string, string> = {
    date: 'What date would you like to book?',
    time: 'What time works best for you?',
    service_type: 'What type of service are you looking for?',
    staff_preference: 'Do you have a staff preference?',
  };
  
  return prompts[slot] || `Please provide your ${slot.replace('_', ' ')}`;
}
```

---

## Part 4: Human Handoff

### 4.1 Escalation Logic

```typescript
interface EscalationTrigger {
  type: 'sentiment' | 'keyword' | 'loops' | 'explicit';
  threshold?: number;
  keywords?: string[];
}

const ESCALATION_TRIGGERS: EscalationTrigger[] = [
  { type: 'sentiment', threshold: -0.5 },
  { type: 'keyword', keywords: ['human', 'agent', 'speak to someone', 'representative'] },
  { type: 'loops', threshold: 3 },
  { type: 'explicit' },
];

async function checkEscalation(
  sessionId: string,
  message: string,
  nluResult: NLUResult
): Promise<boolean> {
  const state = await getDialogState(sessionId);
  
  // Explicit request
  if (nluResult.intent.name === 'speak_to_human') {
    return true;
  }
  
  // Keyword match
  const hasKeyword = ESCALATION_TRIGGERS
    .find(t => t.type === 'keyword')
    ?.keywords?.some(k => message.toLowerCase().includes(k));
  
  if (hasKeyword) return true;
  
  // Negative sentiment
  if (nluResult.sentiment?.score < -0.5) {
    return true;
  }
  
  // Too many turns without resolution
  if (state.turnCount > 10) {
    return true;
  }
  
  return false;
}

async function handoffToAgent(sessionId: string, reason: string) {
  const conversation = await getConversationHistory(sessionId);
  const summary = await summarizeConversation(conversation);
  
  // Create support ticket
  const ticket = await createSupportTicket({
    sessionId,
    summary,
    conversationHistory: conversation,
    reason,
  });
  
  // Notify available agents
  await notifyAgents(ticket);
  
  return {
    message: 'I'm connecting you with a human agent. They'll be with you shortly.',
    ticketId: ticket.id,
  };
}
```

---

## Part 5: Multi-Channel Support

### 5.1 Channel Adapter

```typescript
interface Message {
  text?: string;
  attachments?: Attachment[];
  quickReplies?: QuickReply[];
  cards?: Card[];
}

interface ChannelAdapter {
  parseIncoming(raw: any): { sessionId: string; text: string; metadata: any };
  formatOutgoing(message: Message): any;
  send(to: string, message: Message): Promise<void>;
}

// Web chat adapter
const webChatAdapter: ChannelAdapter = {
  parseIncoming(raw) {
    return {
      sessionId: raw.sessionId,
      text: raw.message,
      metadata: { platform: 'web' },
    };
  },
  
  formatOutgoing(message) {
    return {
      text: message.text,
      quickReplies: message.quickReplies,
      cards: message.cards,
    };
  },
  
  async send(sessionId, message) {
    await broadcastToSession(sessionId, this.formatOutgoing(message));
  },
};

// WhatsApp adapter
const whatsappAdapter: ChannelAdapter = {
  parseIncoming(raw) {
    return {
      sessionId: raw.from,
      text: raw.text?.body || '',
      metadata: { platform: 'whatsapp', messageId: raw.id },
    };
  },
  
  formatOutgoing(message) {
    if (message.quickReplies) {
      return {
        type: 'interactive',
        interactive: {
          type: 'button',
          body: { text: message.text },
          action: {
            buttons: message.quickReplies.map((qr, i) => ({
              type: 'reply',
              reply: { id: `btn_${i}`, title: qr.title },
            })),
          },
        },
      };
    }
    return { type: 'text', text: { body: message.text } };
  },
  
  async send(to, message) {
    await whatsappAPI.sendMessage(to, this.formatOutgoing(message));
  },
};
```

---

## Part 6: Best Practices Checklist

### ✅ Do This

- ✅ **Graceful Fallback**: Handle unknown intents.
- ✅ **Context Timeout**: Expire old conversations.
- ✅ **Quick Replies**: Guide user responses.

### ❌ Avoid This

- ❌ **Long Bot Messages**: Keep responses concise.
- ❌ **Dead Ends**: Always provide next steps.
- ❌ **Ignore Sentiment**: Detect frustration early.

---

## Related Skills

- `@customer-support-bot` - Support automation
- `@nlp-specialist` - Intent classification
- `@voice-assistant-developer` - Voice bots

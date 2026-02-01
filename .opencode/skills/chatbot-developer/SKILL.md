---
name: chatbot-developer
description: "Expert chatbot development including conversational AI, dialog design, NLU integration, and bot UX"
---

# Chatbot Developer

## Overview

This skill helps you build conversational AI experiences, from simple rule-based bots to sophisticated AI-powered assistants.

## When to Use This Skill

- Use when building chatbots
- Use when designing conversation flows
- Use when integrating LLMs in chat
- Use when creating customer support bots

## How It Works

### Step 1: Conversation Design

```
CONVERSATION DESIGN PRINCIPLES
├── GREETING
│   └── Set expectations
│   └── Explain capabilities
│
├── UNDERSTANDING
│   ├── Intent detection (what they want)
│   ├── Entity extraction (specific details)
│   └── Context management (conversation history)
│
├── RESPONDING
│   ├── Acknowledge input
│   ├── Provide helpful response
│   └── Guide next steps
│
└── FALLBACK
    ├── Graceful error handling
    ├── Clarification prompts
    └── Human handoff when needed
```

### Step 2: LLM-Powered Chatbot

```typescript
import OpenAI from 'openai';

const openai = new OpenAI();

interface Message {
  role: 'user' | 'assistant' | 'system';
  content: string;
}

class Chatbot {
  private history: Message[] = [];
  private systemPrompt: string;

  constructor(systemPrompt: string) {
    this.systemPrompt = systemPrompt;
    this.history.push({ role: 'system', content: systemPrompt });
  }

  async chat(userMessage: string): Promise<string> {
    this.history.push({ role: 'user', content: userMessage });

    const response = await openai.chat.completions.create({
      model: 'gpt-4',
      messages: this.history,
      temperature: 0.7,
      max_tokens: 500
    });

    const assistantMessage = response.choices[0].message.content;
    this.history.push({ role: 'assistant', content: assistantMessage });

    return assistantMessage;
  }

  clearHistory() {
    this.history = [{ role: 'system', content: this.systemPrompt }];
  }
}

// Usage
const bot = new Chatbot(`
You are a helpful customer support agent for an e-commerce store.
- Be friendly and professional
- Answer questions about orders, shipping, returns
- If you can't help, offer to connect with a human agent
`);

const response = await bot.chat("Where is my order?");
```

### Step 3: Streaming Responses

```typescript
async function* streamChat(messages: Message[]) {
  const stream = await openai.chat.completions.create({
    model: 'gpt-4',
    messages,
    stream: true
  });

  for await (const chunk of stream) {
    const content = chunk.choices[0]?.delta?.content;
    if (content) yield content;
  }
}

// Frontend usage
const messageDiv = document.getElementById('response');
for await (const chunk of streamChat(messages)) {
  messageDiv.textContent += chunk;
}
```

### Step 4: Chat UI Components

```tsx
function ChatInterface() {
  const [messages, setMessages] = useState([]);
  const [input, setInput] = useState('');
  const [isTyping, setIsTyping] = useState(false);

  const sendMessage = async () => {
    const userMsg = { role: 'user', content: input };
    setMessages(prev => [...prev, userMsg]);
    setInput('');
    setIsTyping(true);

    const response = await fetch('/api/chat', {
      method: 'POST',
      body: JSON.stringify({ message: input })
    });
    
    const data = await response.json();
    setMessages(prev => [...prev, { role: 'assistant', content: data.reply }]);
    setIsTyping(false);
  };

  return (
    <div className="chat-container">
      <div className="messages">
        {messages.map((msg, i) => (
          <div key={i} className={`message ${msg.role}`}>
            {msg.content}
          </div>
        ))}
        {isTyping && <TypingIndicator />}
      </div>
      <input 
        value={input}
        onChange={e => setInput(e.target.value)}
        onKeyPress={e => e.key === 'Enter' && sendMessage()}
      />
    </div>
  );
}
```

## Best Practices

### ✅ Do This

- ✅ Set clear bot personality
- ✅ Handle errors gracefully
- ✅ Provide quick reply buttons
- ✅ Stream long responses
- ✅ Offer human handoff

### ❌ Avoid This

- ❌ Don't pretend to be human
- ❌ Don't ignore context
- ❌ Don't give false confidence
- ❌ Don't forget rate limiting

## Related Skills

- `@senior-ai-agent-developer` - AI agents
- `@senior-rag-engineer` - Knowledge retrieval

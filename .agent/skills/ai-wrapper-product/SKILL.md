---
name: ai-wrapper-product
description: "Expert in building AI-powered products that wrap LLM APIs into focused, valuable tools and applications"
---

# AI Wrapper Product

## Overview

This skill transforms you into an **AI Product Builder**. You will master **LLM API Integration**, **Prompt Engineering**, **UX Design for AI**, and **Productization** for building valuable AI-powered tools.

## When to Use This Skill

- Use when building products on top of LLM APIs
- Use when creating vertical AI SaaS
- Use when designing AI-first user experiences
- Use when implementing prompt pipelines
- Use when differentiating from ChatGPT

---

## Part 1: What Makes a Good AI Wrapper?

### 1.1 The Value Stack

```
Raw API → Prompts → Context → Workflow → UI → Distribution
         (Your Value Adds Here)
```

### 1.2 Differentiation Strategies

| Strategy | Example |
|----------|---------|
| **Vertical Focus** | AI for lawyers, not general AI |
| **Data Moat** | Fine-tuned on proprietary data |
| **Workflow Integration** | Embedded in existing tools |
| **Superior UX** | Better than ChatGPT for X |
| **Pre-built Templates** | Ready-to-use prompts |

### 1.3 Common Categories

| Category | Examples |
|----------|----------|
| **Writing Assistants** | Copy.ai, Jasper, Grammarly |
| **Code Assistants** | Cursor, GitHub Copilot |
| **Image Generation** | Midjourney, DALL-E apps |
| **Customer Support** | Intercom, Zendesk AI |
| **Research Tools** | Perplexity, Elicit |

---

## Part 2: LLM API Integration

### 2.1 Provider Options

| Provider | Models | Notes |
|----------|--------|-------|
| **OpenAI** | GPT-4, GPT-4o | Most capable |
| **Anthropic** | Claude 3.5 Sonnet | Long context, safety |
| **Google** | Gemini 1.5 | Multimodal, long context |
| **Together AI** | Open source models | Cost-effective |
| **Groq** | Llama, Mixtral | Ultra-fast inference |

### 2.2 Basic Integration (OpenAI)

```typescript
import OpenAI from 'openai';

const openai = new OpenAI({
  apiKey: process.env.OPENAI_API_KEY,
});

async function generate(userPrompt: string): Promise<string> {
  const response = await openai.chat.completions.create({
    model: 'gpt-4o',
    messages: [
      { role: 'system', content: 'You are a helpful assistant.' },
      { role: 'user', content: userPrompt },
    ],
    temperature: 0.7,
  });
  
  return response.choices[0].message.content || '';
}
```

### 2.3 Streaming

```typescript
const stream = await openai.chat.completions.create({
  model: 'gpt-4o',
  messages: [...],
  stream: true,
});

for await (const chunk of stream) {
  process.stdout.write(chunk.choices[0]?.delta?.content || '');
}
```

---

## Part 3: Prompt Engineering for Products

### 3.1 System Prompt Design

```
You are [ROLE] that helps users [GOAL].

## Rules
- Always [constraint]
- Never [constraint]

## Format
Respond in [format].

## Examples
[Few-shot examples]
```

### 3.2 Template Variables

```typescript
const systemPrompt = `
You are a ${role} helping with ${task}.
The user's industry is ${industry}.
`.trim();
```

### 3.3 Output Parsing

Use structured outputs (JSON mode) for reliability:

```typescript
const response = await openai.chat.completions.create({
  model: 'gpt-4o',
  messages: [...],
  response_format: { type: 'json_object' },
});

const data = JSON.parse(response.choices[0].message.content);
```

---

## Part 4: AI UX Patterns

### 4.1 Key Patterns

| Pattern | Description |
|---------|-------------|
| **Streaming Output** | Show text as it generates |
| **Regenerate** | "Try again" button |
| **Edit & Refine** | User modifies output |
| **Save & Reuse** | Templates, history |
| **Feedback Loop** | 👍👎 for improvement |

### 4.2 Loading States

- Show typing indicator during generation.
- Display progress for long operations.
- Allow cancellation.

### 4.3 Error Handling

| Error | User Message |
|-------|--------------|
| Rate limit | "High demand. Please wait." |
| Context too long | "Input too long. Try shorter." |
| API error | "Something went wrong. Try again." |
| Safety filter | "I can't help with that." |

---

## Part 5: Monetization

### 5.1 Pricing Models

| Model | Description |
|-------|-------------|
| **Usage-Based** | Pay per API call/token |
| **Subscription** | Monthly access |
| **Freemium** | Free tier + paid features |
| **Credits** | Buy token packs |

### 5.2 Cost Management

- **Cache Responses**: For repeated queries.
- **Smaller Models First**: Upgrade when needed.
- **Rate Limiting**: Prevent abuse.
- **Token Counting**: Display usage to users.

---

## Part 6: Best Practices Checklist

### ✅ Do This

- ✅ **Solve One Problem Well**: Focus beats generality.
- ✅ **Add Human Value**: Curation, templates, workflow.
- ✅ **Collect Feedback**: Improve prompts with data.

### ❌ Avoid This

- ❌ **Just Reskinning ChatGPT**: No differentiation.
- ❌ **Ignoring Costs**: API bills add up fast.
- ❌ **Over-Promising AI**: Set realistic expectations.

---

## Related Skills

- `@senior-prompt-engineer` - Prompt optimization
- `@senior-rag-engineer` - Context injection
- `@saas-product-developer` - SaaS architecture

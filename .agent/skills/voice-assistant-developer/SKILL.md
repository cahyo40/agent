---
name: voice-assistant-developer
description: "Expert voice assistant development including Alexa skills, Google Actions, voice UI design, and conversational AI"
---

# Voice Assistant Developer

## Overview

This skill transforms you into a **Voice Assistant Expert**. You will master **Alexa Skills**, **Google Actions**, **Voice UI Design**, **Intent Handling**, and **Conversational Patterns** for building production-ready voice applications.

## When to Use This Skill

- Use when building Alexa skills
- Use when creating Google Actions
- Use when designing voice interfaces
- Use when implementing voice commands
- Use when building smart speaker apps

---

## Part 1: Voice Assistant Architecture

### 1.1 System Components

```
┌─────────────────────────────────────────────────────────────┐
│                    Voice Assistant                           │
├────────────┬─────────────┬─────────────┬────────────────────┤
│ Wake Word  │ ASR (STT)   │ NLU Engine  │ TTS Response       │
├────────────┴─────────────┴─────────────┴────────────────────┤
│               Intent Handlers & Fulfillment                  │
├─────────────────────────────────────────────────────────────┤
│              Account Linking & Device APIs                   │
└─────────────────────────────────────────────────────────────┘
```

### 1.2 Key Concepts

| Concept | Description |
|---------|-------------|
| **Invocation Name** | How to start the skill |
| **Intent** | User's goal |
| **Slot** | Variable/parameter in utterance |
| **Utterance** | What user says |
| **Prompt** | What assistant asks |
| **SSML** | Speech Synthesis Markup Language |

---

## Part 2: Alexa Skill Development

### 2.1 Skill Manifest (skill.json)

```json
{
  "manifest": {
    "publishingInformation": {
      "locales": {
        "en-US": {
          "name": "Daily Quote",
          "summary": "Get inspiring quotes daily",
          "examplePhrases": [
            "Alexa, open daily quote",
            "Alexa, ask daily quote for motivation",
            "Alexa, tell daily quote to inspire me"
          ],
          "keywords": ["quote", "inspiration", "motivation"]
        }
      }
    },
    "apis": {
      "custom": {
        "endpoint": {
          "uri": "arn:aws:lambda:us-east-1:123456789:function:daily-quote"
        }
      }
    }
  }
}
```

### 2.2 Interaction Model

```json
{
  "interactionModel": {
    "languageModel": {
      "invocationName": "daily quote",
      "intents": [
        {
          "name": "GetQuoteIntent",
          "slots": [
            {
              "name": "category",
              "type": "QUOTE_CATEGORY"
            }
          ],
          "samples": [
            "give me a quote",
            "inspire me",
            "get a {category} quote",
            "tell me something about {category}"
          ]
        },
        {
          "name": "AMAZON.HelpIntent",
          "samples": []
        },
        {
          "name": "AMAZON.StopIntent",
          "samples": []
        }
      ],
      "types": [
        {
          "name": "QUOTE_CATEGORY",
          "values": [
            { "name": { "value": "motivation" } },
            { "name": { "value": "success" } },
            { "name": { "value": "love" } },
            { "name": { "value": "life" } }
          ]
        }
      ]
    }
  }
}
```

### 2.3 Lambda Handler

```typescript
import { SkillBuilders, HandlerInput, RequestHandler } from 'ask-sdk-core';

const LaunchRequestHandler: RequestHandler = {
  canHandle(handlerInput: HandlerInput) {
    return handlerInput.requestEnvelope.request.type === 'LaunchRequest';
  },
  handle(handlerInput: HandlerInput) {
    const speakOutput = 'Welcome to Daily Quote! Ask me for an inspiring quote, or say help for options.';
    
    return handlerInput.responseBuilder
      .speak(speakOutput)
      .reprompt('What would you like? Say "give me a quote" to get started.')
      .getResponse();
  },
};

const GetQuoteIntentHandler: RequestHandler = {
  canHandle(handlerInput: HandlerInput) {
    return (
      handlerInput.requestEnvelope.request.type === 'IntentRequest' &&
      handlerInput.requestEnvelope.request.intent.name === 'GetQuoteIntent'
    );
  },
  async handle(handlerInput: HandlerInput) {
    const request = handlerInput.requestEnvelope.request as IntentRequest;
    const category = request.intent.slots?.category?.value || 'motivation';
    
    const quote = await getRandomQuote(category);
    
    // Use SSML for better speech
    const speakOutput = `
      <speak>
        <amazon:emotion name="excited" intensity="medium">
          Here's your ${category} quote:
        </amazon:emotion>
        <break time="500ms"/>
        "${quote.text}"
        <break time="300ms"/>
        <emphasis level="moderate">by ${quote.author}</emphasis>
        <break time="500ms"/>
        Would you like another quote?
      </speak>
    `;
    
    return handlerInput.responseBuilder
      .speak(speakOutput)
      .reprompt('Would you like another quote?')
      .withSimpleCard('Daily Quote', `"${quote.text}" - ${quote.author}`)
      .getResponse();
  },
};

export const handler = SkillBuilders.custom()
  .addRequestHandlers(
    LaunchRequestHandler,
    GetQuoteIntentHandler,
    HelpIntentHandler,
    StopIntentHandler,
    ErrorHandler
  )
  .lambda();
```

---

## Part 3: Google Actions

### 3.1 Actions Builder (actions.yaml)

```yaml
actions:
  - name: actions.intent.MAIN
    fulfillment:
      conversational:
        webhookHandler: main
  - name: get_quote
    intentEvents:
      - intent: get_quote
        handler:
          webhookHandler: get_quote
```

### 3.2 Dialogflow Fulfillment

```typescript
import { dialogflow, SimpleResponse, Suggestions } from 'actions-on-google';

const app = dialogflow();

app.intent('Default Welcome Intent', (conv) => {
  conv.ask(new SimpleResponse({
    speech: 'Welcome to Daily Quote! Would you like an inspiring quote?',
    text: 'Welcome to Daily Quote! Would you like an inspiring quote?',
  }));
  conv.ask(new Suggestions(['Get a quote', 'Help', 'Quit']));
});

app.intent('get_quote', async (conv, { category }) => {
  const quote = await getRandomQuote(category as string || 'motivation');
  
  conv.ask(new SimpleResponse({
    speech: `<speak>Here's your quote: <break time="300ms"/>"${quote.text}" <break time="200ms"/> by ${quote.author}.</speak>`,
    text: `"${quote.text}" - ${quote.author}`,
  }));
  
  conv.ask('Would you like another quote?');
  conv.ask(new Suggestions(['Another quote', 'Different category', 'Quit']));
});

export const fulfillment = app;
```

---

## Part 4: Voice UI Design

### 4.1 Conversation Flow

```typescript
interface VoiceFlow {
  prompts: {
    welcome: string;
    reprompt: string;
    help: string;
    goodbye: string;
    error: string;
  };
  confirmations: {
    affirmative: string[];
    negative: string[];
  };
}

const VOICE_FLOW: VoiceFlow = {
  prompts: {
    welcome: 'Welcome to Daily Quote! Say "get a quote" to hear something inspiring.',
    reprompt: "I didn't catch that. Would you like a quote?",
    help: 'You can ask for a quote by saying "give me a motivation quote" or "inspire me". Say stop to exit.',
    goodbye: 'Thanks for using Daily Quote. Have an inspiring day!',
    error: "Sorry, I had trouble with that. Please try again.",
  },
  confirmations: {
    affirmative: ['yes', 'sure', 'okay', 'yeah', 'yep', 'please'],
    negative: ['no', 'nope', 'stop', 'cancel', 'quit'],
  },
};
```

### 4.2 SSML Examples

```typescript
// Natural pauses and emphasis
const ssml1 = `
<speak>
  <prosody rate="medium" pitch="medium">
    Here's your daily quote:
  </prosody>
  <break time="500ms"/>
  <prosody rate="slow">
    "The only way to do great work is to love what you do."
  </prosody>
  <break time="300ms"/>
  <emphasis level="moderate">by Steve Jobs</emphasis>
</speak>
`;

// Audio effects
const ssml2 = `
<speak>
  <audio src="https://example.com/chime.mp3"/>
  Congratulations! You've completed a 7-day streak.
  <audio src="https://example.com/applause.mp3"/>
</speak>
`;

// Voice selection (Google)
const ssml3 = `
<speak>
  <voice name="en-US-Wavenet-D">
    Welcome to the meditation guide.
  </voice>
</speak>
`;
```

---

## Part 5: Account Linking

### 5.1 Alexa Account Linking

```typescript
const AccountLinkedHandler: RequestHandler = {
  canHandle(handlerInput: HandlerInput) {
    const accessToken = handlerInput.requestEnvelope.context.System.user.accessToken;
    return accessToken !== undefined;
  },
  async handle(handlerInput: HandlerInput) {
    const accessToken = handlerInput.requestEnvelope.context.System.user.accessToken;
    
    // Fetch user data from your API
    const userData = await fetchUserData(accessToken);
    
    return handlerInput.responseBuilder
      .speak(`Welcome back, ${userData.name}! You have ${userData.savedQuotes} saved quotes.`)
      .getResponse();
  },
};

// Prompt for account linking if not linked
const AccountLinkingPrompt: RequestHandler = {
  canHandle(handlerInput: HandlerInput) {
    return !handlerInput.requestEnvelope.context.System.user.accessToken;
  },
  handle(handlerInput: HandlerInput) {
    return handlerInput.responseBuilder
      .speak('To save quotes, please link your account. I\'ve sent a card to your Alexa app.')
      .withLinkAccountCard()
      .getResponse();
  },
};
```

---

## Part 6: Best Practices Checklist

### ✅ Do This

- ✅ **Short Responses**: Keep under 30 seconds.
- ✅ **Confirm Actions**: Repeat critical info back.
- ✅ **Handle Silence**: Provide reprompts.

### ❌ Avoid This

- ❌ **Long Menus**: Voice isn't suited for lists.
- ❌ **No Context**: Remember user state.
- ❌ **Skip Error Handling**: Graceful fallbacks.

---

## Related Skills

- `@chatbot-developer` - Conversational AI
- `@nlp-specialist` - Intent classification
- `@smart-home-developer` - Smart device control

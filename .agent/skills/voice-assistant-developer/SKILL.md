---
name: voice-assistant-developer
description: "Expert voice assistant development including Alexa skills, Google Actions, voice UI design, and conversational AI"
---

# Voice Assistant Developer

## Overview

Skill ini menjadikan AI Agent sebagai spesialis pengembangan voice assistant. Agent akan mampu membangun Alexa Skills, Google Actions, voice UI design, dan conversational flows untuk smart speakers dan voice-enabled devices.

## When to Use This Skill

- Use when building Alexa Skills
- Use when creating Google Actions
- Use when designing voice user interfaces
- Use when implementing voice commands in apps

## Core Concepts

### Platforms

```text
VOICE PLATFORMS:
────────────────
├── Amazon Alexa (Echo, Fire TV)
│   ├── Alexa Skills Kit (ASK)
│   ├── Lambda backend
│   └── Skill Store distribution
│
├── Google Assistant (Home, Android)
│   ├── Actions on Google
│   ├── Dialogflow NLU
│   └── Cloud Functions backend
│
├── Apple Siri (HomePod, iOS)
│   ├── SiriKit
│   ├── Intents framework
│   └── App Clips integration
│
└── Custom Voice (Wake word)
    ├── Picovoice, Speechly
    ├── On-device processing
    └── Privacy-focused
```

### Conversation Model

```text
VOICE INTERACTION FLOW:
───────────────────────

User: "Alexa, ask Pizza Shop to order a large pepperoni"

┌─────────────┐   ┌─────────────┐   ┌─────────────┐
│ Wake Word   │──►│ Speech to   │──►│ Intent      │
│ Detection   │   │ Text (STT)  │   │ Recognition │
│ "Alexa"     │   │ "order..."  │   │ OrderIntent │
└─────────────┘   └─────────────┘   └─────────────┘
                                           │
                                           ▼
                                    ┌─────────────┐
                                    │ Slot        │
                                    │ Extraction  │
                                    │ size=large  │
                                    │ type=pep    │
                                    └─────────────┘
                                           │
                                           ▼
                                    ┌─────────────┐
                                    │ Fulfillment │
                                    │ Lambda/API  │
                                    └─────────────┘
                                           │
                                           ▼
                                    ┌─────────────┐
                                    │ Text to     │
                                    │ Speech(TTS) │
                                    │ Response    │
                                    └─────────────┘

Alexa: "I've ordered a large pepperoni pizza. It'll be ready in 25 minutes."
```

### Intent & Slots

```text
INTENT DEFINITION:
──────────────────

OrderPizzaIntent:
  Utterances:
    - "order a {size} {topping} pizza"
    - "I want {size} pizza with {topping}"
    - "get me a pizza"
    - "{size} {topping}"
  
  Slots:
    - size: AMAZON.Size (small, medium, large)
    - topping: PizzaToppings (custom: pepperoni, margherita...)
  
  Required Slots:
    - size (prompt: "What size would you like?")
    - topping (prompt: "What topping?")

BUILT-IN INTENTS:
├── AMAZON.HelpIntent
├── AMAZON.StopIntent
├── AMAZON.CancelIntent
├── AMAZON.YesIntent
├── AMAZON.NoIntent
├── AMAZON.FallbackIntent
└── AMAZON.RepeatIntent
```

### Dialog Management

```text
CONVERSATION STATE:
───────────────────

┌─────────────────────────────────────────┐
│ Session Attributes (ephemeral)         │
│ - Current order: { size, topping }     │
│ - Dialog step: confirmation            │
│ - Context: ordering pizza              │
└─────────────────────────────────────────┘

┌─────────────────────────────────────────┐
│ Persistent Attributes (DynamoDB)       │
│ - User preferences                     │
│ - Order history                        │
│ - Saved addresses                      │
└─────────────────────────────────────────┘

DIALOG STATES:
├── STARTED - Intent just triggered
├── IN_PROGRESS - Collecting slots
├── COMPLETED - All slots filled
└── CONFIRMED - User confirmed action

MULTI-TURN EXAMPLE:
User: "Order a pizza"
Alexa: "What size?" [slot elicitation]
User: "Large"
Alexa: "What topping?" [slot elicitation]
User: "Pepperoni"
Alexa: "Large pepperoni pizza. Confirm?" [confirmation]
User: "Yes"
Alexa: "Order placed!" [completion]
```

### Voice UI Best Practices

```text
VOICE UI PRINCIPLES:
────────────────────

1. BREVITY
   ❌ "Your order for one large pepperoni pizza has been 
      successfully submitted to our system and will be 
      prepared shortly."
   ✓ "Ordered! Large pepperoni, ready in 25 minutes."

2. CONFIRMATION
   - Repeat back critical info
   - "Got it, large pepperoni. Confirm?"
   
3. ERROR RECOVERY
   - "I didn't catch that. Did you say pepperoni?"
   - Offer alternatives: "You can say toppings like 
     pepperoni, margherita, or hawaiian."

4. PROGRESSIVE DISCLOSURE
   - Don't dump all options at once
   - Guide step by step
   
5. EARCONS & AUDIO
   - Use sound cues for feedback
   - SSML for pauses, emphasis
   
6. REPROMPTS
   - If no response: "Still there? What topping?"
```

### SSML (Speech Synthesis Markup)

```text
SSML EXAMPLES:
──────────────

Basic:
<speak>
  Your order will arrive in <say-as interpret-as="cardinal">25</say-as> minutes.
</speak>

Pauses:
<speak>
  One moment <break time="1s"/> checking your order.
</speak>

Emphasis:
<speak>
  That's a <emphasis level="strong">great</emphasis> choice!
</speak>

Audio:
<speak>
  <audio src="https://s3.../ding.mp3"/>
  Order confirmed!
</speak>

Alexa-specific (Emotions):
<speak>
  <amazon:emotion name="excited" intensity="medium">
    Your pizza is on the way!
  </amazon:emotion>
</speak>
```

### API/Handler Structure

```text
SKILL HANDLER FLOW:
───────────────────

Request JSON    →  Handler Router  →  Intent Handler  →  Response JSON
{                  │                   │                   {
  type: Intent,    │ LaunchRequest     │ OrderIntent       outputSpeech,
  intent: Order,   │ IntentRequest     │ HelpIntent        reprompt,
  slots: {...}     │ SessionEnded      │ etc.              shouldEnd
}                  ↓                   ↓                   }

HANDLER EXAMPLE (pseudo):
```

OrderIntentHandler:
  canHandle(input):
    return input.intent == "OrderIntent"

  handle(input):
    size = input.slots.size
    topping = input.slots.topping

    if not size:
      return elicitSlot("size", "What size pizza?")
    if not topping:
      return elicitSlot("topping", "What topping?")
    
    # All slots filled
    placeOrder(size, topping)
    return speak("Ordered! {size} {topping} pizza.")

```
```

## Best Practices

### ✅ Do This

- ✅ Keep responses under 8 seconds
- ✅ Always handle AMAZON.HelpIntent
- ✅ Test with actual voice, not just text
- ✅ Support one-shot and multi-turn
- ✅ Use account linking for personalization

### ❌ Avoid This

- ❌ Don't require precise phrasing
- ❌ Don't read long lists verbally
- ❌ Don't forget reprompts
- ❌ Don't ignore regional accents in testing

## Related Skills

- `@chatbot-developer` - Conversational AI
- `@nlp-specialist` - Intent recognition
- `@senior-backend-developer` - Lambda/Cloud Functions
- `@iot-developer` - Smart home integration

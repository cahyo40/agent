---
name: ai-voice-clone
description: "Expert voice cloning and synthesis using ElevenLabs, PlayHT, and other AI voice platforms for content creation and applications"
---

# AI Voice Clone Specialist

## Overview

Create realistic voice clones and synthesized speech using AI platforms like ElevenLabs, PlayHT, and similar services. This skill covers voice cloning, text-to-speech integration, and building voice-enabled applications.

## When to Use This Skill

- Use when creating AI-generated voiceovers
- Use when building voice-enabled applications
- Use when cloning voices for podcasts or videos
- Use when implementing text-to-speech features
- Use when localizing content with AI voices

## Templates Reference

| Template | Description |
|----------|-------------|
| [elevenlabs-api.md](templates/elevenlabs-api.md) | ElevenLabs API integration |
| [voice-clone-setup.md](templates/voice-clone-setup.md) | Voice cloning workflow |
| [tts-integration.md](templates/tts-integration.md) | TTS in applications |

## How It Works

### Step 1: ElevenLabs Setup

```typescript
// Install
// npm install elevenlabs

import { ElevenLabsClient, play } from 'elevenlabs'

const client = new ElevenLabsClient({
  apiKey: process.env.ELEVENLABS_API_KEY,
})

// Text to Speech
async function textToSpeech(text: string, voiceId: string) {
  const audio = await client.textToSpeech.convert(voiceId, {
    text,
    model_id: 'eleven_multilingual_v2',
    voice_settings: {
      stability: 0.5,
      similarity_boost: 0.75,
      style: 0.0,
      use_speaker_boost: true,
    },
  })
  
  return audio // ReadableStream
}

// Play audio directly
async function speakText(text: string) {
  const audio = await client.textToSpeech.convert('voice-id', {
    text,
    model_id: 'eleven_turbo_v2_5',
  })
  
  await play(audio)
}
```

### Step 2: Voice Cloning

```typescript
// Create voice clone
async function createVoiceClone(
  name: string,
  files: File[],
  description?: string
) {
  const voice = await client.voices.add({
    name,
    files,
    description,
    labels: {
      accent: 'American',
      gender: 'male',
      use_case: 'narration',
    },
  })
  
  return voice
}

// Instant Voice Clone (from single sample)
async function instantClone(audioFile: File) {
  const voice = await client.voices.add({
    name: 'Quick Clone',
    files: [audioFile],
  })
  
  return voice.voice_id
}
```

### Step 3: Streaming TTS

```typescript
// Stream audio for real-time playback
async function streamTTS(text: string, voiceId: string): Promise<ReadableStream> {
  const response = await client.textToSpeech.streamingWithTimestamps(voiceId, {
    text,
    model_id: 'eleven_turbo_v2_5',
    output_format: 'mp3_44100_128',
  })
  
  // Process with timestamps for lip-sync
  for await (const chunk of response) {
    if (chunk.audio) {
      // Audio data
    }
    if (chunk.alignment) {
      // Word-level timestamps
    }
  }
  
  return response
}

// WebSocket streaming (lowest latency)
async function websocketStream() {
  const ws = new WebSocket(
    `wss://api.elevenlabs.io/v1/text-to-speech/${voiceId}/stream-input?model_id=eleven_turbo_v2_5`
  )
  
  ws.onopen = () => {
    ws.send(JSON.stringify({
      text: ' ',
      voice_settings: { stability: 0.5, similarity_boost: 0.75 },
      xi_api_key: API_KEY,
    }))
  }
  
  ws.onmessage = (event) => {
    const data = JSON.parse(event.data)
    if (data.audio) {
      // Play base64 audio
    }
  }
  
  // Send text chunks
  ws.send(JSON.stringify({ text: 'Hello world!' }))
  ws.send(JSON.stringify({ text: '' })) // Flush
}
```

### Step 4: Voice Management

```typescript
// List available voices
async function listVoices() {
  const voices = await client.voices.getAll()
  return voices.voices.map(v => ({
    id: v.voice_id,
    name: v.name,
    category: v.category,
    labels: v.labels,
  }))
}

// Get voice by name
async function getVoiceByName(name: string) {
  const voices = await client.voices.getAll()
  return voices.voices.find(v => 
    v.name.toLowerCase() === name.toLowerCase()
  )
}

// Delete cloned voice
async function deleteVoice(voiceId: string) {
  await client.voices.delete(voiceId)
}
```

### Step 5: Audio Generation for Apps

```typescript
// Generate audio file for download
async function generateAudioFile(
  text: string,
  voiceId: string,
  outputPath: string
) {
  const audio = await client.textToSpeech.convert(voiceId, {
    text,
    model_id: 'eleven_multilingual_v2',
    output_format: 'mp3_44100_192',
  })
  
  // Save to file
  const fs = require('fs')
  const buffer = Buffer.from(await audio.arrayBuffer())
  fs.writeFileSync(outputPath, buffer)
  
  return outputPath
}

// Batch processing
async function batchGenerateAudio(
  scripts: { id: string; text: string }[],
  voiceId: string
) {
  const results = []
  
  for (const script of scripts) {
    const filePath = `./output/${script.id}.mp3`
    await generateAudioFile(script.text, voiceId, filePath)
    results.push({ id: script.id, path: filePath })
    
    // Rate limiting
    await new Promise(r => setTimeout(r, 500))
  }
  
  return results
}
```

## Best Practices

### ✅ Do This

- ✅ Use high-quality, clean audio for cloning (1-5 minutes)
- ✅ Match voice to content tone
- ✅ Cache audio for repeated content
- ✅ Handle errors and rate limits gracefully
- ✅ Use streaming for real-time applications

### ❌ Avoid This

- ❌ Don't clone voices without permission
- ❌ Don't use for deceptive purposes
- ❌ Don't exceed API rate limits
- ❌ Don't skip audio quality checks
- ❌ Don't hardcode API keys

## Common Pitfalls

**Problem:** Voice sounds robotic
**Solution:** Adjust stability (lower) and similarity_boost settings

**Problem:** Pronunciation issues
**Solution:** Use SSML tags or phonetic spelling

**Problem:** Long generation times
**Solution:** Use eleven_turbo_v2_5 model for faster generation

## Related Skills

- `@audio-processing-specialist` - Audio manipulation
- `@podcast-producer` - Podcast creation
- `@video-editor-automation` - Video production

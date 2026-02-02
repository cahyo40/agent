---
name: audio-processing-specialist
description: "Expert in digital audio processing including signal analysis, filtering, effect implementation, and audio AI models"
---

# Audio Processing Specialist

## Overview

This skill transforms you into a **Digital Audio Engineer**. You will master **Audio DSP**, **FFmpeg Audio**, **Speech Processing**, and **Audio AI** for building professional audio processing pipelines.

## When to Use This Skill

- Use when processing audio files (normalize, compress, filter)
- Use when building audio transcription systems
- Use when implementing audio effects
- Use when analyzing audio signals
- Use when integrating audio AI models

---

## Part 1: Audio Fundamentals

### 1.1 Key Concepts

| Concept | Description |
|---------|-------------|
| **Sample Rate** | Samples per second (44.1kHz, 48kHz) |
| **Bit Depth** | Bits per sample (16-bit, 24-bit) |
| **Channels** | Mono (1), Stereo (2), Surround (5.1+) |
| **Codec** | Compression format (MP3, AAC, FLAC) |
| **Waveform** | Amplitude over time |
| **Spectrum** | Frequency over time (FFT) |

### 1.2 Common Formats

| Format | Lossy? | Use Case |
|--------|--------|----------|
| **WAV** | No | Editing, archival |
| **FLAC** | No | High-quality streaming |
| **MP3** | Yes | Universal playback |
| **AAC** | Yes | Streaming, mobile |
| **OGG Vorbis** | Yes | Games, web |

---

## Part 2: FFmpeg Audio Processing

### 2.1 Common Operations

```bash
# Convert format
ffmpeg -i input.wav output.mp3

# Extract audio from video
ffmpeg -i video.mp4 -vn -acodec copy audio.aac

# Normalize volume
ffmpeg -i input.mp3 -filter:a loudnorm output.mp3

# Change sample rate
ffmpeg -i input.wav -ar 16000 output.wav

# Trim audio
ffmpeg -i input.mp3 -ss 00:00:30 -t 00:01:00 output.mp3

# Merge audio files
ffmpeg -f concat -i filelist.txt -c copy output.mp3
```

### 2.2 Audio Filters

| Filter | Purpose |
|--------|---------|
| `loudnorm` | EBU R128 loudness normalization |
| `highpass=f=200` | Remove low-frequency rumble |
| `lowpass=f=3000` | Remove high-frequency hiss |
| `afftdn` | Noise reduction (FFT-based) |
| `compand` | Dynamic range compression |
| `equalizer` | EQ adjustment |

---

## Part 3: Python Audio Processing

### 3.1 Libraries

| Library | Purpose |
|---------|---------|
| **librosa** | Audio analysis, feature extraction |
| **pydub** | Simple audio manipulation |
| **scipy.signal** | Signal processing |
| **soundfile** | Read/write audio files |
| **pyaudio** | Real-time audio I/O |

### 3.2 Librosa Example

```python
import librosa
import librosa.display
import matplotlib.pyplot as plt

# Load audio
y, sr = librosa.load('audio.wav', sr=22050)

# Compute spectrogram
S = librosa.feature.melspectrogram(y=y, sr=sr)
S_dB = librosa.power_to_db(S, ref=np.max)

# Plot
librosa.display.specshow(S_dB, sr=sr, x_axis='time', y_axis='mel')
plt.colorbar(format='%+2.0f dB')
plt.show()
```

### 3.3 Pydub Example

```python
from pydub import AudioSegment

# Load
audio = AudioSegment.from_mp3("input.mp3")

# Normalize
normalized = audio.normalize()

# Fade in/out
faded = normalized.fade_in(2000).fade_out(3000)

# Export
faded.export("output.wav", format="wav")
```

---

## Part 4: Audio AI

### 4.1 Speech-to-Text

| Model | Notes |
|-------|-------|
| **Whisper (OpenAI)** | State-of-the-art, multilingual, free |
| **Deepgram** | Fast, real-time, API |
| **AssemblyAI** | Speaker diarization, sentiment |
| **Google Speech-to-Text** | Cloud API |

**Whisper Example:**

```python
import whisper

model = whisper.load_model("base")
result = model.transcribe("audio.mp3")
print(result["text"])
```

### 4.2 Text-to-Speech

| Model | Notes |
|-------|-------|
| **ElevenLabs** | Realistic voices, cloning |
| **Bark (Suno)** | Open source, emotional |
| **Coqui TTS** | Open source, multilingual |
| **Google TTS** | Cloud API |

### 4.3 Music Generation

- **Suno.ai**: Text-to-song with vocals.
- **Udio**: High-quality instrumental.
- **MusicGen (Meta)**: Open source.

---

## Part 5: Real-Time Audio

### 5.1 WebAudio API (Browser)

```javascript
const audioContext = new AudioContext();
const oscillator = audioContext.createOscillator();

oscillator.type = 'sine';
oscillator.frequency.value = 440;  // A4 note
oscillator.connect(audioContext.destination);
oscillator.start();
```

### 5.2 Python Real-Time (pyaudio)

```python
import pyaudio
import numpy as np

p = pyaudio.PyAudio()
stream = p.open(format=pyaudio.paFloat32,
                channels=1,
                rate=44100,
                input=True,
                frames_per_buffer=1024)

while True:
    data = stream.read(1024)
    audio_array = np.frombuffer(data, dtype=np.float32)
    # Process audio_array
```

---

## Part 6: Best Practices Checklist

### ✅ Do This

- ✅ **Work in Lossless**: Edit in WAV/FLAC, export to MP3 last.
- ✅ **Normalize After Effects**: Not before.
- ✅ **Match Sample Rates**: Avoid resampling artifacts.

### ❌ Avoid This

- ❌ **Over-Compression**: Destroys dynamics.
- ❌ **Clipping**: Keep peaks below 0 dB.
- ❌ **Ignoring Mono Compatibility**: Check stereo mixes in mono.

---

## Related Skills

- `@video-processing-specialist` - Video + audio integration
- `@nlp-specialist` - Speech processing AI
- `@podcast-producer` - Applied audio production

---
name: audio-processing-specialist
description: "Expert in digital audio processing including signal analysis, filtering, effect implementation, and audio AI models"
---

# Audio Processing Specialist

## Overview

Master digital audio processing (DSP). Expertise in signal analysis, FFT (Fast Fourier Transform), equalization, compression, reverb implementation, and modern audio AI (source separation, text-to-speech).

## When to Use This Skill

- Use when building music production software or plugins
- Use when implementing audio features in apps (recording, playback)
- Use when analyzing audio data (speech recognition, noise reduction)
- Use when integrating audio AI models

## How It Works

### Step 1: Signal Fundamentals & FFT

```python
import numpy as np
import librosa
import scipy.signal as signal

# Load audio
y, sr = librosa.load("audio.wav")

# Short-Time Fourier Transform (STFT)
D = librosa.stft(y)
S_db = librosa.amplitude_to_db(np.abs(D), ref=np.max)

# Basic filtering (Low-pass)
def low_pass_filter(data, cutoff, fs, order=5):
    nyq = 0.5 * fs
    normal_cutoff = cutoff / nyq
    b, a = signal.butter(order, normal_cutoff, btype='low', analog=False)
    return signal.lfilter(b, a, data)
```

### Step 2: Audio Effects (Time & Frequency Domain)

- **Dynamics**: Implement Compressors (Threshold, Ratio, Attack, Release) and Gates.
- **Space**: Implement Reverb (Convolution or Algorithmic) and Delays.
- **Tone**: Implement Parametric EQs and Harmonic Distortion.

### Step 3: Audio AI & Analysis

```python
# Feature extraction for ML
mfccs = librosa.feature.mfcc(y=y, sr=sr, n_mfcc=13)
tempo, beats = librosa.beat.beat_track(y=y, sr=sr)

# Source Separation (with Spleeter or similar)
# separate_vocals(audio_path)
```

### Step 4: Real-time Processing (Web/App)

```javascript
// Web Audio API
const audioCtx = new (window.AudioContext || window.webkitAudioContext)();
const stream = await navigator.mediaDevices.getUserMedia({ audio: true });
const source = audioCtx.createMediaStreamSource(stream);

const filter = audioCtx.createBiquadFilter();
filter.type = "lowpass";
filter.frequency.value = 1000;

source.connect(filter);
filter.connect(audioCtx.destination);
```

## Best Practices

### ✅ Do This

- ✅ Protect against digital clipping (stay below 0dBFS)
- ✅ Use windowing (e.g., Hann) when performing FFT
- ✅ Handle sample rate conversion carefully to avoid aliasing
- ✅ Prefer vector operations for performance
- ✅ Use visualizers (Spectrograms) to debug audio logic

### ❌ Avoid This

- ❌ Don't process audio in the main UI thread (use Workers or C++ nodes)
- ❌ Don't ignore latency (important for live use)
- ❌ Don't forget DC offset removal
- ❌ Don't ignore dithering when reducing bit depth

## Related Skills

- `@senior-python-developer` - Analysis scripts
- `@cpp-developer` - Low-latency engines
- `@senior-ai-ml-engineer` - Audio AI integration

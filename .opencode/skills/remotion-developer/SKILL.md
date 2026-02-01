---
name: remotion-developer
description: "Expert Remotion development for programmatic video creation with React"
---

# Remotion Developer

## Overview

Build programmatic videos using React and Remotion framework.

## When to Use This Skill

- Use when creating videos programmatically
- Use when automating video production

## How It Works

### Step 1: Project Setup

```bash
npx create-video@latest my-video
cd my-video
npm start
```

### Step 2: Basic Composition

```tsx
// src/HelloWorld.tsx
import { AbsoluteFill, useCurrentFrame, useVideoConfig } from 'remotion';

export const HelloWorld: React.FC = () => {
  const frame = useCurrentFrame();
  const { fps, durationInFrames } = useVideoConfig();
  
  const opacity = Math.min(1, frame / 30);
  
  return (
    <AbsoluteFill style={{ backgroundColor: '#0f172a' }}>
      <h1 style={{
        color: 'white',
        fontSize: 80,
        textAlign: 'center',
        opacity,
      }}>
        Hello World!
      </h1>
    </AbsoluteFill>
  );
};
```

### Step 3: Register Composition

```tsx
// src/Root.tsx
import { Composition } from 'remotion';
import { HelloWorld } from './HelloWorld';

export const RemotionRoot: React.FC = () => {
  return (
    <Composition
      id="HelloWorld"
      component={HelloWorld}
      durationInFrames={150}
      fps={30}
      width={1920}
      height={1080}
    />
  );
};
```

### Step 4: Animations

```tsx
import { spring, interpolate } from 'remotion';

const scale = spring({
  frame,
  fps,
  config: { damping: 200 }
});

const rotate = interpolate(frame, [0, 30], [0, 360]);
```

### Step 5: Render

```bash
npx remotion render HelloWorld output.mp4
```

## Best Practices

- ✅ Use spring for smooth animations
- ✅ Keep compositions modular
- ❌ Don't use non-deterministic values
- ❌ Don't fetch data in render

## Related Skills

- `@senior-react-developer`

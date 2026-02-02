---
name: remotion-developer
description: "Expert Remotion development for programmatic video creation with React"
---

# Remotion Developer

## Overview

This skill transforms you into a **Programmatic Video Expert**. You will master **Remotion Framework**, **React for Video**, **Animation**, and **Rendering Pipelines** for creating videos with code.

## When to Use This Skill

- Use when generating videos programmatically
- Use when building template-based video systems
- Use when creating dynamic, data-driven videos
- Use when automating video production
- Use when integrating video generation into CI/CD

---

## Part 1: Remotion Fundamentals

### 1.1 Core Concepts

| Concept | Description |
|---------|-------------|
| **Composition** | A video "component" with duration, fps, dimensions |
| **Sequence** | Stagger child timings |
| **useCurrentFrame** | Current frame number hook |
| **useVideoConfig** | fps, width, height, durationInFrames |
| **interpolate** | Map frame to animated value |

### 1.2 Project Structure

```
src/
├── Root.tsx           # Register compositions
├── Video.tsx          # Main video component
├── components/        # Reusable elements
└── data/              # Dynamic data sources
```

---

## Part 2: Basic Animation

### 2.1 Composition Setup

```tsx
import { Composition } from 'remotion';
import { MyVideo } from './MyVideo';

export const RemotionRoot: React.FC = () => {
  return (
    <Composition
      id="MyVideo"
      component={MyVideo}
      durationInFrames={150}  // 5 seconds at 30fps
      fps={30}
      width={1920}
      height={1080}
      defaultProps={{ title: "Hello World" }}
    />
  );
};
```

### 2.2 Animated Component

```tsx
import { useCurrentFrame, useVideoConfig, interpolate, spring, AbsoluteFill } from 'remotion';

export const MyVideo: React.FC<{ title: string }> = ({ title }) => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();
  
  // Animate opacity 0→1 over first 30 frames
  const opacity = interpolate(frame, [0, 30], [0, 1], {
    extrapolateRight: 'clamp',
  });
  
  // Spring animation for scale
  const scale = spring({
    frame,
    fps,
    config: { damping: 100 },
  });
  
  return (
    <AbsoluteFill style={{ backgroundColor: 'black' }}>
      <h1
        style={{
          color: 'white',
          fontSize: 100,
          opacity,
          transform: `scale(${scale})`,
        }}
      >
        {title}
      </h1>
    </AbsoluteFill>
  );
};
```

---

## Part 3: Sequencing

### 3.1 Sequence Component

```tsx
import { Sequence, AbsoluteFill } from 'remotion';
import { Intro } from './Intro';
import { MainContent } from './MainContent';
import { Outro } from './Outro';

export const MyVideo: React.FC = () => {
  return (
    <AbsoluteFill>
      <Sequence from={0} durationInFrames={60}>
        <Intro />
      </Sequence>
      
      <Sequence from={60} durationInFrames={180}>
        <MainContent />
      </Sequence>
      
      <Sequence from={240} durationInFrames={60}>
        <Outro />
      </Sequence>
    </AbsoluteFill>
  );
};
```

---

## Part 4: Dynamic Data

### 4.1 Props from External Data

```tsx
// Generate video from JSON data
const videos = [
  { title: "Product A", price: "$99" },
  { title: "Product B", price: "$149" },
];

// Render each programmatically
npx remotion render src/index.tsx ProductVideo output/video-a.mp4 --props='{"title":"Product A","price":"$99"}'
```

### 4.2 Fetching Data

```tsx
import { staticFile, delayRender, continueRender } from 'remotion';

export const DataDrivenVideo: React.FC = () => {
  const [data, setData] = useState<Data | null>(null);
  const [handle] = useState(() => delayRender());
  
  useEffect(() => {
    fetch('https://api.example.com/data')
      .then(res => res.json())
      .then(data => {
        setData(data);
        continueRender(handle);
      });
  }, []);
  
  if (!data) return null;
  
  return <Video data={data} />;
};
```

---

## Part 5: Rendering

### 5.1 Local Render

```bash
# Preview
npm start

# Render to file
npx remotion render src/index.tsx MyVideo output.mp4

# Render with props
npx remotion render src/index.tsx MyVideo output.mp4 --props='{"title":"Custom"}'

# Render specific frames
npx remotion render src/index.tsx MyVideo output.mp4 --frames=0-60
```

### 5.2 Programmatic Render (Lambda)

```tsx
import { renderMediaOnLambda } from '@remotion/lambda';

const result = await renderMediaOnLambda({
  region: 'us-east-1',
  functionName: 'remotion-render',
  composition: 'MyVideo',
  inputProps: { title: 'Server Rendered' },
  codec: 'h264',
});
```

---

## Part 6: Best Practices Checklist

### ✅ Do This

- ✅ **Use interpolate for Smoothness**: Not raw frame math.
- ✅ **Memoize Heavy Components**: Prevent re-renders.
- ✅ **Test Locally Before Cloud Render**: Faster iteration.

### ❌ Avoid This

- ❌ **Huge Assets Without Optimization**: Compress images/videos.
- ❌ **Ignoring DurationInFrames**: Match to actual content length.
- ❌ **Too Many Sequences**: Simplify when possible.

---

## Related Skills

- `@video-processing-specialist` - FFmpeg, post-processing
- `@senior-react-developer` - React patterns
- `@video-editor-automation` - Batch processing

---
name: motion-designer
description: "Expert UI motion design including micro-interactions, Lottie animations, and animation principles"
---

# Motion Designer

## Overview

Create engaging UI animations and micro-interactions for web and mobile apps.

## When to Use This Skill

- Use when designing micro-interactions
- Use when creating Lottie animations
- Use when defining motion guidelines

## How It Works

### Step 1: Animation Principles

```markdown
## 12 Principles for UI Motion

### Essential Principles
1. **Timing**: 200-500ms for UI (300ms ideal)
2. **Easing**: ease-out for enter, ease-in for exit
3. **Spatial**: Movement follows natural physics
4. **Purpose**: Every animation has meaning

### Duration Guidelines
| Action | Duration |
|--------|----------|
| Micro (hover, click) | 100-200ms |
| Small (toggle, fade) | 200-300ms |
| Medium (modal, slide) | 300-400ms |
| Large (page transition) | 400-600ms |

### Easing Functions
- ease-out: Elements entering (decelerating)
- ease-in: Elements exiting (accelerating)
- ease-in-out: Elements moving on screen
```

### Step 2: CSS Micro-interactions

```css
/* Button Hover */
.button {
  transition: transform 200ms ease-out, 
              box-shadow 200ms ease-out;
}

.button:hover {
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(0,0,0,0.15);
}

.button:active {
  transform: translateY(0);
  transition-duration: 100ms;
}

/* Card Hover */
.card {
  transition: transform 300ms ease-out;
}

.card:hover {
  transform: scale(1.02);
}

/* Loading Skeleton */
@keyframes shimmer {
  0% { background-position: -200% 0; }
  100% { background-position: 200% 0; }
}

.skeleton {
  background: linear-gradient(90deg, #f0f0f0 25%, #e0e0e0 50%, #f0f0f0 75%);
  background-size: 200% 100%;
  animation: shimmer 1.5s infinite;
}
```

### Step 3: Lottie Integration

```javascript
// React with lottie-react
import Lottie from 'lottie-react';
import successAnimation from './success.json';

function SuccessState() {
  return (
    <Lottie 
      animationData={successAnimation}
      loop={false}
      style={{ width: 120, height: 120 }}
    />
  );
}

// Control playback
const lottieRef = useRef();

<Lottie
  lottieRef={lottieRef}
  animationData={animationData}
  autoplay={false}
/>

// Play on event
lottieRef.current?.play();
```

### Step 4: Page Transitions

```javascript
// Framer Motion
import { motion, AnimatePresence } from 'framer-motion';

const pageVariants = {
  initial: { opacity: 0, x: 20 },
  animate: { opacity: 1, x: 0 },
  exit: { opacity: 0, x: -20 },
};

function Page({ children }) {
  return (
    <motion.div
      variants={pageVariants}
      initial="initial"
      animate="animate"
      exit="exit"
      transition={{ duration: 0.3 }}
    >
      {children}
    </motion.div>
  );
}
```

## Best Practices

- ✅ Keep animations under 400ms
- ✅ Use easing, never linear
- ✅ Animate one property at a time
- ❌ Don't animate for animation's sake
- ❌ Don't block user interaction

## Related Skills

- `@web-animation-specialist`
- `@senior-ui-ux-designer`

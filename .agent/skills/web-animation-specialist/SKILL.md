---
name: web-animation-specialist
description: "Expert web animation including GSAP, Framer Motion, CSS animations, and micro-interactions for engaging user experiences"
---

# Web Animation Specialist

## Overview

This skill transforms you into an experienced Web Animation Specialist who creates smooth, engaging animations using GSAP, Framer Motion, and CSS.

## When to Use This Skill

- Use when adding animations to websites
- Use when creating micro-interactions
- Use when building animated components
- Use when optimizing animation performance

## How It Works

### Step 1: Framer Motion (React)

```tsx
import { motion, AnimatePresence } from 'framer-motion';

// Basic animation
<motion.div
  initial={{ opacity: 0, y: 20 }}
  animate={{ opacity: 1, y: 0 }}
  exit={{ opacity: 0, y: -20 }}
  transition={{ duration: 0.3, ease: 'easeOut' }}
>
  Content
</motion.div>

// Stagger children
const container = {
  hidden: { opacity: 0 },
  show: {
    opacity: 1,
    transition: { staggerChildren: 0.1 }
  }
};

const item = {
  hidden: { opacity: 0, y: 20 },
  show: { opacity: 1, y: 0 }
};

<motion.ul variants={container} initial="hidden" animate="show">
  {items.map(i => <motion.li key={i} variants={item} />)}
</motion.ul>

// Gesture animations
<motion.button
  whileHover={{ scale: 1.05 }}
  whileTap={{ scale: 0.95 }}
>
  Click me
</motion.button>
```

### Step 2: GSAP

```javascript
import gsap from 'gsap';
import { ScrollTrigger } from 'gsap/ScrollTrigger';

gsap.registerPlugin(ScrollTrigger);

// Basic animation
gsap.to('.box', { x: 100, duration: 1, ease: 'power2.out' });

// Timeline
const tl = gsap.timeline();
tl.from('.title', { y: 50, opacity: 0 })
  .from('.subtitle', { y: 30, opacity: 0 }, '-=0.3')
  .from('.button', { scale: 0 }, '-=0.2');

// Scroll-triggered animation
gsap.from('.section', {
  scrollTrigger: {
    trigger: '.section',
    start: 'top 80%',
    end: 'bottom 20%',
    scrub: true
  },
  y: 100,
  opacity: 0
});
```

### Step 3: CSS Animations

```css
/* Keyframe animation */
@keyframes fadeInUp {
  from {
    opacity: 0;
    transform: translateY(20px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

.animate-in {
  animation: fadeInUp 0.5s ease-out forwards;
}

/* Transition */
.button {
  transition: all 0.2s ease-out;
}
.button:hover {
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(0,0,0,0.15);
}

/* Performance optimized */
.optimized {
  will-change: transform;
  transform: translateZ(0); /* GPU acceleration */
}
```

## Best Practices

### ✅ Do This

- ✅ Use `transform` and `opacity` (GPU accelerated)
- ✅ Respect `prefers-reduced-motion`
- ✅ Keep animations under 300ms for UI
- ✅ Use `will-change` sparingly

### ❌ Avoid This

- ❌ Don't animate `width`, `height`, `top`, `left`
- ❌ Don't overuse animations
- ❌ Don't block user interaction

## Related Skills

- `@senior-react-developer` - React integration
- `@senior-ui-ux-designer` - Animation design

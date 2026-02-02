---
name: creative-coding-artist
description: "Expert in algorithmic art and creative coding using Processing, p5.js, OpenFrameworks, and generative systems"
---

# Creative Coding Artist

## Overview

This skill transforms you into a **Generative Art Developer**. You will master **p5.js**, **Algorithmic Aesthetics**, **Noise Functions**, and **Interactive Visuals** for creating code-based art.

## When to Use This Skill

- Use when creating generative artwork
- Use when building interactive visualizations
- Use when designing data-driven art
- Use when creating real-time visual performances
- Use when building NFT art collections

---

## Part 1: Creative Coding Foundations

### 1.1 Core Concepts

| Concept | Description |
|---------|-------------|
| **Sketch** | A single artwork/program |
| **Setup** | Runs once at start |
| **Draw** | Runs every frame (60 fps) |
| **Canvas** | The drawing surface |
| **Transformation** | Translate, rotate, scale |

### 1.2 p5.js Basics

```javascript
function setup() {
  createCanvas(800, 600);
  background(0);
}

function draw() {
  fill(255, 50);
  noStroke();
  ellipse(mouseX, mouseY, 50, 50);
}
```

---

## Part 2: Generative Techniques

### 2.1 Perlin Noise

Smooth, organic randomness.

```javascript
let t = 0;

function draw() {
  background(0);
  for (let x = 0; x < width; x += 10) {
    let y = noise(x * 0.01, t) * height;
    ellipse(x, y, 5, 5);
  }
  t += 0.01;
}
```

### 2.2 Recursive Patterns

Self-similar structures (fractals, trees).

```javascript
function branch(len) {
  line(0, 0, 0, -len);
  translate(0, -len);
  
  if (len > 4) {
    push();
    rotate(PI / 6);
    branch(len * 0.7);
    pop();
    push();
    rotate(-PI / 6);
    branch(len * 0.7);
    pop();
  }
}
```

### 2.3 L-Systems

Grammar-based pattern generation.

```
Axiom: F
Rules: F -> F[+F]F[-F]F
```

Each iteration grows the system.

---

## Part 3: Interactivity

### 3.1 Mouse/Touch

```javascript
function mousePressed() {
  particles.push(new Particle(mouseX, mouseY));
}
```

### 3.2 Audio Reactivity

Use Web Audio API or p5.sound.

```javascript
let mic;

function setup() {
  mic = new p5.AudioIn();
  mic.start();
}

function draw() {
  let vol = mic.getLevel();
  ellipse(width/2, height/2, vol * 500, vol * 500);
}
```

### 3.3 Webcam Input

```javascript
let video;

function setup() {
  video = createCapture(VIDEO);
  video.hide();
}

function draw() {
  image(video, 0, 0);
}
```

---

## Part 4: Tools & Platforms

### 4.1 Languages/Frameworks

| Tool | Language | Best For |
|------|----------|----------|
| **p5.js** | JavaScript | Web, beginners |
| **Processing** | Java | Desktop, education |
| **OpenFrameworks** | C++ | Performance, installations |
| **TouchDesigner** | Visual | Real-time VFX, installations |
| **Shadertoy** | GLSL | GPU shaders |

### 4.2 Sharing Platforms

- **OpenProcessing.org**: p5.js sketches.
- **fxhash.xyz**: Generative NFT art (Tezos).
- **ArtBlocks**: Ethereum generative NFTs.

---

## Part 5: Aesthetics & Theory

### 5.1 Common Styles

| Style | Characteristics |
|-------|----------------|
| **Minimalist** | Few colors, geometric, clean |
| **Organic** | Noise, curves, natural |
| **Glitch** | Artifacts, distortion, corruption |
| **Data Art** | Visualizing datasets |
| **Flow Fields** | Particles following vector fields |

### 5.2 Color Theory

- **Complementary**: Opposite on color wheel.
- **Analogous**: Adjacent colors.
- **Palette Tools**: Coolors.co, Color Hunt.

---

## Part 6: Best Practices Checklist

### ✅ Do This

- ✅ **Parameterize Everything**: Make values tweakable.
- ✅ **Export High-Res**: Use `saveCanvas()` at 4K+.
- ✅ **Document Your Work**: Record videos, write about process.

### ❌ Avoid This

- ❌ **Ignoring Performance**: 60 fps matters for real-time.
- ❌ **Overcomplicating**: Simple rules create complex beauty.
- ❌ **Not Iterating**: Art emerges from experimentation.

---

## Related Skills

- `@webgl-specialist` - GPU-accelerated graphics
- `@three-js-expert` - 3D web graphics
- `@generative-art-creator` - Extended techniques

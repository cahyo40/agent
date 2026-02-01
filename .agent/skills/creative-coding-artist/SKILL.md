---
name: creative-coding-artist
description: "Expert in algorithmic art and creative coding using Processing, p5.js, OpenFrameworks, and generative systems"
---

# Creative Coding Artist

## Overview

Master the intersection of art and code. Expertise in algorithmic composition, generative art, physical computing, shader art, and interactive installations using Processing, p5.js, OpenFrameworks, and Cinder.

## When to Use This Skill

- Use when building interactive visual art or digital installations
- Use for creating generative patterns or textures for branding
- Use for data visualization with an artistic flair
- Use when experimenting with physical computing and interactive tech

## How It Works

### Step 1: Algorithmic Composition & p5.js

```javascript
// p5.js Generative Flow Field
function setup() {
  createCanvas(800, 800);
  background(0);
}

function draw() {
  let x = random(width);
  let y = random(height);
  let noiseVal = noise(x * 0.01, y * 0.01);
  stroke(255 * noiseVal, 100, 200, 50);
  point(x, y);
}
```

### Step 2: Noise & Randomness

- **Perlin Noise**: For smooth, natural-looking randomness.
- **Fractals**: Recursive patterns (Mandelbrot, L-Systems).
- **Physics**: Particle systems and soft-body simulations.

### Step 3: Shader Art (GLSL)

- **SDF (Signed Distance Functions)**: Creating complex 3D shapes from math.
- **Raymarching**: Rendering scenes inside a single fragment shader.

### Step 4: Interaction & Sensors

- **OSC (Open Sound Control)**: Communication between art apps and music gear.
- **Computer Vision (OpenCV)**: Using motion as an artistic input.

## Best Practices

### ✅ Do This

- ✅ Document the math and algorithms behind your art
- ✅ Emphasize "Juice" and responsive interactions
- ✅ Save seeds or parameters for reproducible generative results
- ✅ Optimize for smooth frame rates (60 FPS)
- ✅ Explore the "accidental" beauty found in bugs

### ❌ Avoid This

- ❌ Don't over-rely on basic `random()`—use `noise()` for better aesthetics
- ❌ Don't block the drawing loop with heavy computations
- ❌ Don't ignore the importance of color theory
- ❌ Don't make interaction too complex or unintuitive

## Related Skills

- `@generative-art-creator` - Traditional generative
- `@webgl-specialist` - Low-level rendering
- `@three-js-expert` - Web 3D art

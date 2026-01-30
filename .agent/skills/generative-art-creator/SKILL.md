---
name: generative-art-creator
description: "Expert generative and algorithmic art creation using code"
---

# Generative Art Creator

## Overview

Create algorithmic and generative art using code with p5.js, canvas, and creative coding techniques.

## When to Use This Skill

- Use when creating generative visuals
- Use when building algorithmic art

## How It Works

### Step 1: p5.js Setup

```html
<script src="https://cdn.jsdelivr.net/npm/p5@1.9.0/lib/p5.min.js"></script>
<script>
function setup() {
  createCanvas(800, 800);
  noLoop();
}

function draw() {
  background(10);
  generateArt();
}
</script>
```

### Step 2: Flow Field

```javascript
let cols, rows;
let scale = 20;
let particles = [];
let flowField;

function setup() {
  createCanvas(800, 800);
  cols = floor(width / scale);
  rows = floor(height / scale);
  flowField = new Array(cols * rows);
  
  for (let i = 0; i < 1000; i++) {
    particles.push(new Particle());
  }
}

function draw() {
  let yoff = 0;
  for (let y = 0; y < rows; y++) {
    let xoff = 0;
    for (let x = 0; x < cols; x++) {
      let angle = noise(xoff, yoff) * TWO_PI * 2;
      let v = p5.Vector.fromAngle(angle);
      flowField[x + y * cols] = v;
      xoff += 0.1;
    }
    yoff += 0.1;
  }
  
  particles.forEach(p => {
    p.follow(flowField);
    p.update();
    p.show();
  });
}
```

### Step 3: Recursive Patterns

```javascript
function recursiveCircle(x, y, r) {
  if (r < 2) return;
  
  noFill();
  stroke(255, 100);
  circle(x, y, r * 2);
  
  recursiveCircle(x + r/2, y, r/2);
  recursiveCircle(x - r/2, y, r/2);
  recursiveCircle(x, y + r/2, r/2);
  recursiveCircle(x, y - r/2, r/2);
}
```

### Step 4: Color Palettes

```javascript
const palettes = {
  sunset: ['#ff6b6b', '#feca57', '#ff9ff3', '#54a0ff'],
  ocean: ['#0c2461', '#1e3799', '#4a69bd', '#6a89cc'],
  forest: ['#27ae60', '#2ecc71', '#1abc9c', '#16a085'],
};

function randomColor(palette) {
  return random(palettes[palette]);
}
```

## Best Practices

- ✅ Use noise for organic patterns
- ✅ Seed random for reproducibility
- ❌ Don't overload with particles
- ❌ Don't skip optimization

## Related Skills

- `@3d-web-experience`
- `@web-animation-specialist`

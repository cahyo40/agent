---
name: webgl-specialist
description: "Expert in low-level web graphics including WebGL API, GLSL shaders, buffer management, and rendering pipelines"
---

# WebGL Specialist

## Overview

Master low-level graphics programming in the browser. Expertise in the WebGL API (1.0/2.0), writing complex GLSL shaders, managing vertex/index buffers, handling matrices for 3D math, and optimizing the rendering pipeline.

## When to Use This Skill

- Use when building custom 2D/3D engines or specialized visualizations
- Use when Three.js is too high-level or adds too much overhead
- Use for compute-heavy visual effects (GPGPU, particle systems)
- Use when deep control over the GPU pipeline is required

## How It Works

### Step 1: WebGL Context & Shaders

```javascript
const canvas = document.querySelector('canvas');
const gl = canvas.getContext('webgl2');

// Shader Source
const vsSource = `#version 300 es
  in vec4 aPosition;
  void main() { gl_Position = aPosition; }
`;

const fsSource = `#version 300 es
  precision highp float;
  out vec4 outColor;
  void main() { outColor = vec4(1, 0, 0, 1); } // Red
`;

// Link program logic...
```

### Step 2: Buffers & Attributes

```javascript
const positionBuffer = gl.createBuffer();
gl.bindBuffer(gl.ARRAY_BUFFER, positionBuffer);

const positions = [
  -1.0,  1.0,
   1.0,  1.0,
  -1.0, -1.0,
];
gl.bufferData(gl.ARRAY_BUFFER, new Float32Array(positions), gl.STATIC_DRAW);

// Link to Attribute
const positionLoc = gl.getAttribLocation(program, "aPosition");
gl.enableVertexAttribArray(positionLoc);
gl.vertexAttribPointer(positionLoc, 2, gl.FLOAT, false, 0, 0);
```

### Step 3: Textures & Framebuffers

- **Textures**: Handle pixel data, mipmaps, and filtering (NEAREST vs. LINEAR).
- **FBO (Frame Buffer Objects)**: Render to textures for multi-pass effects (Bloom, Blur, Shadow maps).

### Step 4: Linear Algebra for Graphics

- **MVP Matrices**: Master Model, View, and Projection matrices.
- **Transitions**: Handle rotations (Quaternions), scaling, and translations.

## Best Practices

### ✅ Do This

- ✅ Minimize state changes (switching programs, binding textures)
- ✅ Use WebGL 2.0 whenever possible (VAOs, MRS, transform feedback)
- ✅ Batch small draw calls into larger ones
- ✅ Use typed arrays (Float32Array) for all data transfers to GPU
- ✅ Profile with "Spector.js" or browser-specific GPU tools

### ❌ Avoid This

- ❌ Don't create/delete buffers or textures mid-frame (do it during init)
- ❌ Don't use `gl.readPixels` frequently (it's slow as it blocks the pipeline)
- ❌ Don't ignore precision qualifiers in shaders
- ❌ Don't use high-resolution textures on low-end hardware

## Related Skills

- `@three-js-expert` - High-level wrapper
- `@cpp-developer` - Logic used in native equivalents
- `@senior-webperf-engineer` - Browser engine performance

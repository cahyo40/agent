---
name: webgl-specialist
description: "Expert in low-level web graphics including WebGL API, GLSL shaders, buffer management, and rendering pipelines"
---

# WebGL Specialist

## Overview

This skill transforms you into a **Low-Level Graphics Developer** for the web. You will master **WebGL API**, **GLSL Shaders**, **Buffer Management**, and **Rendering Pipelines** for high-performance 2D/3D graphics.

## When to Use This Skill

- Use when building custom rendering engines
- Use when writing GLSL shaders
- Use when optimizing graphics performance
- Use when creating effects beyond Three.js capabilities
- Use when understanding GPU programming fundamentals

---

## Part 1: WebGL Fundamentals

### 1.1 The Pipeline

```
Vertex Data -> Vertex Shader -> Rasterization -> Fragment Shader -> Framebuffer
```

### 1.2 Core Concepts

| Concept | Description |
|---------|-------------|
| **Vertex** | A point in 3D space |
| **Buffer** | GPU memory holding vertex data |
| **Shader** | Program running on GPU |
| **Uniform** | Constant passed to shader |
| **Attribute** | Per-vertex data |
| **Varying** | Passed from vertex to fragment shader |

### 1.3 Minimal WebGL Setup

```javascript
const canvas = document.querySelector('canvas');
const gl = canvas.getContext('webgl');

// Clear to black
gl.clearColor(0, 0, 0, 1);
gl.clear(gl.COLOR_BUFFER_BIT);
```

---

## Part 2: Shaders (GLSL)

### 2.1 Vertex Shader

Runs once per vertex. Sets position.

```glsl
attribute vec3 a_position;
uniform mat4 u_modelViewProjection;

void main() {
    gl_Position = u_modelViewProjection * vec4(a_position, 1.0);
}
```

### 2.2 Fragment Shader

Runs once per pixel. Sets color.

```glsl
precision mediump float;
uniform vec3 u_color;

void main() {
    gl_FragColor = vec4(u_color, 1.0);
}
```

### 2.3 Compiling Shaders (JS)

```javascript
function createShader(gl, type, source) {
    const shader = gl.createShader(type);
    gl.shaderSource(shader, source);
    gl.compileShader(shader);
    
    if (!gl.getShaderParameter(shader, gl.COMPILE_STATUS)) {
        console.error(gl.getShaderInfoLog(shader));
        gl.deleteShader(shader);
        return null;
    }
    return shader;
}
```

---

## Part 3: Buffers & Attributes

### 3.1 Creating a Buffer

```javascript
const positions = new Float32Array([
    0.0,  0.5,  0.0,
   -0.5, -0.5,  0.0,
    0.5, -0.5,  0.0
]);

const buffer = gl.createBuffer();
gl.bindBuffer(gl.ARRAY_BUFFER, buffer);
gl.bufferData(gl.ARRAY_BUFFER, positions, gl.STATIC_DRAW);
```

### 3.2 Connecting Buffer to Attribute

```javascript
const positionLoc = gl.getAttribLocation(program, 'a_position');
gl.enableVertexAttribArray(positionLoc);
gl.vertexAttribPointer(positionLoc, 3, gl.FLOAT, false, 0, 0);
```

---

## Part 4: Advanced Techniques

### 4.1 Textures

```javascript
const texture = gl.createTexture();
gl.bindTexture(gl.TEXTURE_2D, texture);
gl.texImage2D(gl.TEXTURE_2D, 0, gl.RGBA, gl.RGBA, gl.UNSIGNED_BYTE, image);
gl.generateMipmap(gl.TEXTURE_2D);
```

### 4.2 Framebuffers (Render to Texture)

Off-screen rendering for post-processing effects.

```javascript
const fbo = gl.createFramebuffer();
gl.bindFramebuffer(gl.FRAMEBUFFER, fbo);
gl.framebufferTexture2D(gl.FRAMEBUFFER, gl.COLOR_ATTACHMENT0, gl.TEXTURE_2D, texture, 0);
```

### 4.3 Instanced Rendering (WebGL2)

Draw many copies efficiently.

```javascript
gl.drawArraysInstanced(gl.TRIANGLES, 0, 6, 1000);
```

---

## Part 5: WebGL2 vs WebGL1

| Feature | WebGL1 | WebGL2 |
|---------|--------|--------|
| **GLSL Version** | ES 1.0 | ES 3.0 |
| **Instancing** | Extension | Built-in |
| **3D Textures** | No | Yes |
| **MRT** | Extension | Built-in |
| **VAO** | Extension | Built-in |

### 5.1 Feature Detection

```javascript
const gl = canvas.getContext('webgl2') || canvas.getContext('webgl');
```

---

## Part 6: Best Practices Checklist

### ✅ Do This

- ✅ **Use Vertex Array Objects (VAO)**: Group state for faster binding.
- ✅ **Batch Draw Calls**: Minimize state changes.
- ✅ **Profile with GPU Tools**: Chrome DevTools, Spector.js.

### ❌ Avoid This

- ❌ **Creating Buffers in Render Loop**: Do it once in setup.
- ❌ **Too Many Uniforms**: Pack data into textures.
- ❌ **Ignoring Precision**: Use `mediump` where possible.

---

## Related Skills

- `@three-js-expert` - Higher-level 3D framework
- `@creative-coding-artist` - Artistic applications
- `@senior-webperf-engineer` - Performance optimization

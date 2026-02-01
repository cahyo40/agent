---
name: three-js-expert
description: "Expert 3D web development including Three.js, React Three Fiber, shaders, and performance-driven 3D experiences"
---

# Three.js Expert

## Overview

Master high-end 3D web experiences. Expertise in Three.js core, React Three Fiber (R3F), GLSL shaders, post-processing, physics integration (Cannon.js/Rapier), and optimization for mobile browsers.

## When to Use This Skill

- Use when building interactive 3D landing pages or portfolios
- Use when creating web-based 3D configurators (cars, furniture)
- Use for 3D data visualization or browser-based games
- Use when needing custom visual effects via GLSL shaders

## How It Works

### Step 1: React Three Fiber (R3F) Logic

```jsx
import { Canvas, useFrame } from '@react-three/fiber'
import { useRef } from 'react'

function Box() {
  const meshRef = useRef()
  
  // High-performance animation loop
  useFrame((state, delta) => {
    meshRef.current.rotation.x += delta
  })

  return (
    <mesh ref={meshRef}>
      <boxGeometry args={[1, 1, 1]} />
      <meshStandardMaterial color="orange" />
    </mesh>
  )
}

function Scene() {
  return (
    <Canvas>
      <ambientLight intensity={0.5} />
      <pointLight position={[10, 10, 10]} />
      <Box />
    </Canvas>
  )
}
```

### Step 2: Custom Shaders (GLSL)

```javascript
const CustomShaderMaterial = {
  uniforms: {
    uTime: { value: 0 },
    uColor: { value: new THREE.Color('blue') }
  },
  vertexShader: `
    varying vec2 vUv;
    void main() {
      vUv = uv;
      gl_Position = projectionMatrix * modelViewMatrix * vec4(position, 1.0);
    }
  `,
  fragmentShader: `
    uniform float uTime;
    varying vec2 vUv;
    void main() {
      gl_FragColor = vec4(vUv, sin(uTime), 1.0);
    }
  `
};
```

### Step 3: Performance & Optimization

- **InstancedMesh**: Render thousands of identical objects in one draw call.
- **GLTF Optimization**: Use Draco compression and KTX2 textures.
- **Selective Bloom**: Apply post-processing only to specific layers.

### Step 4: Physics & Interaction

- **Rapier**: Lightweight, high-performance physics engine for the web.
- **Raycasting**: Handle mouse and touch interactions accurately.

## Best Practices

### ✅ Do This

- ✅ Use `InstancedMesh` for repeated objects
- ✅ Dispose of geometries and materials manually to prevent memory leaks
- ✅ Use `useFrame` sparingly (avoid heavy computations inside the loop)
- ✅ Optimize assets using `gltf-pipeline` or `sqoosh`
- ✅ Implement Level of Detail (LOD) for complex scenes

### ❌ Avoid This

- ❌ Don't update state/props frequently for 3D elements (leads to re-renders)
- ❌ Don't use heavy textures (keep them power-of-two and compressed)
- ❌ Don't ignore the `pixelRatio` (cap it at 2 for performance)
- ❌ Don't place too many dynamic lights (use baked lighting or environment maps)

## Related Skills

- `@3d-web-experience` - Foundation skills
- `@webgl-specialist` - Low-level rendering
- `@web-animation-specialist` - Visual polish

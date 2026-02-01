---
name: 3d-web-experience
description: "Expert 3D web development including Three.js, React Three Fiber, WebGL, and interactive 3D experiences"
---

# 3D Web Experience Developer

## Overview

This skill transforms you into an experienced 3D web developer who creates immersive, interactive 3D experiences using Three.js, React Three Fiber, and WebGL.

## When to Use This Skill

- Use when building 3D web experiences
- Use when working with Three.js
- Use when creating product configurators
- Use when building interactive 3D portfolios

## How It Works

### Step 1: React Three Fiber Setup

```tsx
import { Canvas, useFrame } from '@react-three/fiber';
import { OrbitControls, Environment, useGLTF } from '@react-three/drei';

function Scene() {
  return (
    <Canvas camera={{ position: [0, 0, 5], fov: 50 }}>
      <ambientLight intensity={0.5} />
      <spotLight position={[10, 10, 10]} angle={0.15} />
      <Model />
      <OrbitControls enableDamping />
      <Environment preset="sunset" />
    </Canvas>
  );
}

function Model() {
  const { scene } = useGLTF('/model.glb');
  const ref = useRef();
  
  useFrame((state, delta) => {
    ref.current.rotation.y += delta * 0.5;
  });
  
  return <primitive ref={ref} object={scene} scale={1} />;
}
```

### Step 2: Three.js Basics

```javascript
import * as THREE from 'three';

const scene = new THREE.Scene();
const camera = new THREE.PerspectiveCamera(75, window.innerWidth / window.innerHeight, 0.1, 1000);
const renderer = new THREE.WebGLRenderer({ antialias: true });

renderer.setSize(window.innerWidth, window.innerHeight);
document.body.appendChild(renderer.domElement);

// Add mesh
const geometry = new THREE.BoxGeometry(1, 1, 1);
const material = new THREE.MeshStandardMaterial({ color: 0x00ff00 });
const cube = new THREE.Mesh(geometry, material);
scene.add(cube);

// Lighting
const light = new THREE.DirectionalLight(0xffffff, 1);
light.position.set(5, 5, 5);
scene.add(light);

// Animation loop
function animate() {
  requestAnimationFrame(animate);
  cube.rotation.x += 0.01;
  renderer.render(scene, camera);
}
animate();
```

### Step 3: Shaders & Effects

```glsl
// Vertex Shader
varying vec2 vUv;
void main() {
  vUv = uv;
  gl_Position = projectionMatrix * modelViewMatrix * vec4(position, 1.0);
}

// Fragment Shader
uniform float uTime;
varying vec2 vUv;
void main() {
  vec3 color = vec3(vUv.x, vUv.y, sin(uTime));
  gl_FragColor = vec4(color, 1.0);
}
```

## Best Practices

### ✅ Do This

- ✅ Optimize 3D models (compress, reduce polygons)
- ✅ Use instancing for repeated objects
- ✅ Implement LOD (Level of Detail)
- ✅ Use draco compression for models

### ❌ Avoid This

- ❌ Don't load unoptimized models
- ❌ Don't skip mobile testing
- ❌ Don't ignore performance

## Related Skills

- `@senior-react-developer` - React integration
- `@senior-webperf-engineer` - Performance

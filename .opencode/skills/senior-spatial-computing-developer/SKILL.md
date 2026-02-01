---
name: senior-spatial-computing-developer
description: "Expert spatial computing development including VR/AR applications, Apple visionOS, Meta Quest, Unity/Unreal integration, and immersive experience design"
---

# Senior Spatial Computing Developer

## Overview

This skill transforms you into an experienced Spatial Computing Developer who builds immersive VR/AR experiences. You'll develop for visionOS, Meta Quest, and WebXR, creating spatial interfaces that blend digital content with the physical world.

## When to Use This Skill

- Use when building VR/AR applications
- Use when developing for Apple Vision Pro (visionOS)
- Use when creating Meta Quest experiences
- Use when implementing WebXR applications
- Use when the user asks about spatial computing

## How It Works

### Step 1: Understand Spatial Computing Platforms

```
SPATIAL COMPUTING PLATFORMS
┌─────────────────────────────────────────────────────────────────┐
│                                                                 │
│  APPLE VISION PRO (visionOS)                                   │
│  ├── Framework: SwiftUI + RealityKit                           │
│  ├── Interaction: Eye tracking, hand gestures                  │
│  ├── Strength: Premium mixed reality, Apple ecosystem          │
│  └── Use case: Productivity, entertainment                     │
│                                                                 │
│  META QUEST                                                     │
│  ├── Framework: Unity, Unreal, Native SDK                      │
│  ├── Interaction: Controllers, hand tracking                   │
│  ├── Strength: Standalone VR, social features                  │
│  └── Use case: Gaming, social VR, fitness                      │
│                                                                 │
│  WEBXR                                                          │
│  ├── Framework: Three.js, A-Frame, Babylon.js                  │
│  ├── Interaction: Controller, hand tracking                    │
│  ├── Strength: Cross-platform, no app install                  │
│  └── Use case: Web-based experiences                           │
│                                                                 │
│  HOLOLENS / MAGIC LEAP                                          │
│  ├── Framework: MRTK, Unity                                    │
│  ├── Interaction: Gaze, gestures, voice                        │
│  └── Use case: Enterprise, industrial                          │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### Step 2: visionOS Development

```swift
import SwiftUI
import RealityKit
import RealityKitContent

// Basic visionOS App with 3D Content
@main
struct SpatialApp: App {
    var body: some Scene {
        // 2D Window
        WindowGroup {
            ContentView()
        }
        
        // Immersive Space
        ImmersiveSpace(id: "ImmersiveSpace") {
            ImmersiveView()
        }
        .immersionStyle(selection: .constant(.mixed), in: .mixed)
    }
}

struct ImmersiveView: View {
    var body: some View {
        RealityView { content in
            // Load 3D model
            if let model = try? await Entity(named: "Scene", in: realityKitContentBundle) {
                content.add(model)
            }
            
            // Add spatial audio
            let audioSource = Entity()
            audioSource.spatialAudio = SpatialAudioComponent()
            content.add(audioSource)
        }
        .gesture(
            TapGesture()
                .targetedToAnyEntity()
                .onEnded { value in
                    // Handle tap on 3D object
                    print("Tapped: \(value.entity.name)")
                }
        )
    }
}

// Volumetric Window
struct VolumetricView: View {
    var body: some View {
        Model3D(named: "Globe") { model in
            model
                .resizable()
                .scaledToFit()
        } placeholder: {
            ProgressView()
        }
        .rotation3DEffect(.degrees(45), axis: .y)
    }
}
```

### Step 3: WebXR Development

```javascript
import * as THREE from 'three';
import { VRButton } from 'three/addons/webxr/VRButton.js';
import { XRControllerModelFactory } from 'three/addons/webxr/XRControllerModelFactory.js';

class VRExperience {
    constructor() {
        this.scene = new THREE.Scene();
        this.camera = new THREE.PerspectiveCamera(75, window.innerWidth / window.innerHeight, 0.1, 1000);
        this.renderer = new THREE.WebGLRenderer({ antialias: true });
        
        this.init();
    }
    
    init() {
        // Setup renderer for XR
        this.renderer.setSize(window.innerWidth, window.innerHeight);
        this.renderer.xr.enabled = true;
        document.body.appendChild(this.renderer.domElement);
        
        // Add VR button
        document.body.appendChild(VRButton.createButton(this.renderer));
        
        // Setup controllers
        this.setupControllers();
        
        // Add environment
        this.createEnvironment();
        
        // Start render loop
        this.renderer.setAnimationLoop(() => this.render());
    }
    
    setupControllers() {
        const controllerModelFactory = new XRControllerModelFactory();
        
        // Left controller
        this.controller1 = this.renderer.xr.getController(0);
        this.controller1.addEventListener('selectstart', () => this.onSelect());
        this.scene.add(this.controller1);
        
        // Controller model
        const grip1 = this.renderer.xr.getControllerGrip(0);
        grip1.add(controllerModelFactory.createControllerModel(grip1));
        this.scene.add(grip1);
    }
    
    createEnvironment() {
        // Add floor
        const floor = new THREE.Mesh(
            new THREE.PlaneGeometry(10, 10),
            new THREE.MeshStandardMaterial({ color: 0x333333 })
        );
        floor.rotation.x = -Math.PI / 2;
        this.scene.add(floor);
        
        // Add lighting
        const light = new THREE.DirectionalLight(0xffffff, 1);
        light.position.set(5, 10, 5);
        this.scene.add(light);
    }
    
    onSelect() {
        // Handle controller trigger
        console.log('Controller triggered');
    }
    
    render() {
        this.renderer.render(this.scene, this.camera);
    }
}

new VRExperience();
```

### Step 4: Unity XR Development

```csharp
using UnityEngine;
using UnityEngine.XR;
using UnityEngine.XR.Interaction.Toolkit;

// Grabbable Object
[RequireComponent(typeof(XRGrabInteractable))]
public class GrabbableObject : MonoBehaviour
{
    private XRGrabInteractable grabInteractable;
    private Rigidbody rb;
    
    void Awake()
    {
        grabInteractable = GetComponent<XRGrabInteractable>();
        rb = GetComponent<Rigidbody>();
        
        // Event listeners
        grabInteractable.selectEntered.AddListener(OnGrab);
        grabInteractable.selectExited.AddListener(OnRelease);
    }
    
    private void OnGrab(SelectEnterEventArgs args)
    {
        Debug.Log($"Grabbed by: {args.interactorObject.transform.name}");
    }
    
    private void OnRelease(SelectExitEventArgs args)
    {
        Debug.Log("Released");
        // Apply throw velocity
        rb.velocity = args.interactorObject.transform.GetComponent<XRBaseInteractor>()
            .GetAttachTransform(this).velocity;
    }
}

// Hand Tracking
public class HandTracker : MonoBehaviour
{
    private InputDevice leftHand;
    private InputDevice rightHand;
    
    void Update()
    {
        if (!leftHand.isValid)
        {
            leftHand = InputDevices.GetDeviceAtXRNode(XRNode.LeftHand);
        }
        
        if (leftHand.TryGetFeatureValue(CommonUsages.gripButton, out bool gripPressed))
        {
            if (gripPressed)
            {
                Debug.Log("Left grip pressed");
            }
        }
    }
}
```

## Examples

### Example 1: AR Object Placement

```swift
// visionOS AR Placement
struct ARPlacementView: View {
    @State private var placedObjects: [Entity] = []
    
    var body: some View {
        RealityView { content in
            // Setup AR session
            let anchor = AnchorEntity(.plane(.horizontal, classification: .floor, minimumBounds: [0.5, 0.5]))
            content.add(anchor)
        } update: { content in
            // Update placed objects
        }
        .gesture(
            SpatialTapGesture()
                .onEnded { value in
                    placeObject(at: value.location3D)
                }
        )
    }
    
    func placeObject(at position: SIMD3<Float>) {
        // Create and place object
        let box = ModelEntity(mesh: .generateBox(size: 0.1))
        box.position = position
        placedObjects.append(box)
    }
}
```

### Example 2: Hand Gesture Recognition

```swift
// visionOS Hand Gesture
struct HandGestureView: View {
    @State private var isPinching = false
    
    var body: some View {
        RealityView { content in
            // 3D content
        }
        .gesture(
            DragGesture()
                .targetedToAnyEntity()
                .onChanged { value in
                    // Move object with hand
                    value.entity.position = value.convert(value.location3D, from: .local, to: .scene)
                }
        )
    }
}
```

## Best Practices

### ✅ Do This

- ✅ Design for comfort (avoid motion sickness)
- ✅ Use spatial audio for immersion
- ✅ Implement proper locomotion systems
- ✅ Optimize for target frame rate (90+ FPS)
- ✅ Test on actual hardware
- ✅ Follow platform design guidelines

### ❌ Avoid This

- ❌ Don't force fast camera movement
- ❌ Don't use small text in VR
- ❌ Don't ignore accessibility
- ❌ Don't skip performance optimization
- ❌ Don't neglect user onboarding

## Common Pitfalls

**Problem:** Motion sickness from artificial locomotion
**Solution:** Use teleportation, vignettes, or snap turning.

**Problem:** Performance issues causing frame drops
**Solution:** LOD systems, occlusion culling, baked lighting.

**Problem:** Objects too close/far for comfortable viewing
**Solution:** Respect comfort zones (0.5m - 20m for VR).

## Tools & Frameworks

| Platform | Tools |
|----------|-------|
| visionOS | Xcode, Reality Composer Pro, SwiftUI |
| Meta Quest | Unity, Unreal, Meta XR SDK |
| WebXR | Three.js, A-Frame, Babylon.js |
| Cross-platform | Unity XR, Unreal OpenXR |

## Related Skills

- `@senior-ios-developer` - For visionOS Swift development
- `@senior-ui-ux-designer` - For spatial interface design
- `@senior-software-engineer` - For architecture patterns

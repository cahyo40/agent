---
name: senior-edge-ai-engineer
description: "Expert Edge AI development including on-device ML inference, TensorFlow Lite, ONNX Runtime, IoT integration, and model optimization for embedded systems"
---

# Senior Edge AI Engineer

## Overview

This skill transforms you into an experienced Edge AI Engineer who deploys machine learning models to edge devices. You'll optimize models for constrained environments, implement on-device inference, and build intelligent IoT systems.

## When to Use This Skill

- Use when deploying ML models to mobile/embedded devices
- Use when optimizing models for edge inference
- Use when building IoT with AI capabilities
- Use when working with TensorFlow Lite, ONNX, CoreML
- Use when the user asks about on-device ML

## How It Works

### Step 1: Edge AI Architecture

```
EDGE AI SYSTEM ARCHITECTURE
┌─────────────────────────────────────────────────────────────────┐
│                                                                 │
│  CLOUD                        EDGE                             │
│  ┌─────────────────┐          ┌─────────────────┐              │
│  │  Model Training │          │  Model Inference │              │
│  │  ┌───────────┐  │          │  ┌───────────┐  │              │
│  │  │ Full Model│  │ Convert  │  │ Optimized │  │  Local       │
│  │  │ Training  │──┼─────────▶│  │   Model   │──┼─▶Inference   │
│  │  └───────────┘  │          │  └───────────┘  │              │
│  │  ┌───────────┐  │          │  ┌───────────┐  │              │
│  │  │ Dataset   │  │          │  │   Edge    │  │              │
│  │  │ Storage   │  │          │  │  Runtime  │  │              │
│  │  └───────────┘  │          │  └───────────┘  │              │
│  └─────────────────┘          └─────────────────┘              │
│                                                                 │
│  EDGE DEPLOYMENT TARGETS                                        │
│  ├── Mobile (iOS, Android)                                      │
│  ├── Microcontrollers (ESP32, STM32)                           │
│  ├── Single Board (Raspberry Pi, Jetson)                       │
│  └── Browsers (WebML, TensorFlow.js)                           │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### Step 2: Model Optimization Pipeline

```python
import tensorflow as tf
import numpy as np

# OPTIMIZATION TECHNIQUES
# 1. Quantization - Reduce precision (float32 → int8)
# 2. Pruning - Remove unnecessary weights
# 3. Knowledge Distillation - Train smaller model
# 4. Architecture optimization - Use efficient architectures

# Post-Training Quantization
def quantize_model(saved_model_path: str, output_path: str):
    # Convert to TFLite with quantization
    converter = tf.lite.TFLiteConverter.from_saved_model(saved_model_path)
    
    # Dynamic range quantization
    converter.optimizations = [tf.lite.Optimize.DEFAULT]
    
    # Full integer quantization (requires representative dataset)
    def representative_dataset():
        for _ in range(100):
            data = np.random.rand(1, 224, 224, 3).astype(np.float32)
            yield [data]
    
    converter.representative_dataset = representative_dataset
    converter.target_spec.supported_ops = [tf.lite.OpsSet.TFLITE_BUILTINS_INT8]
    converter.inference_input_type = tf.int8
    converter.inference_output_type = tf.int8
    
    tflite_model = converter.convert()
    
    with open(output_path, 'wb') as f:
        f.write(tflite_model)
    
    return len(tflite_model) / (1024 * 1024)  # Size in MB

# Pruning
import tensorflow_model_optimization as tfmot

def create_pruned_model(model):
    prune_low_magnitude = tfmot.sparsity.keras.prune_low_magnitude
    
    pruning_params = {
        'pruning_schedule': tfmot.sparsity.keras.PolynomialDecay(
            initial_sparsity=0.30,
            final_sparsity=0.70,
            begin_step=0,
            end_step=1000
        )
    }
    
    pruned_model = prune_low_magnitude(model, **pruning_params)
    
    # Compile and train
    pruned_model.compile(optimizer='adam', loss='sparse_categorical_crossentropy')
    
    return pruned_model
```

### Step 3: TensorFlow Lite Inference

```python
# Python inference (Raspberry Pi, Desktop)
import numpy as np
import tflite_runtime.interpreter as tflite

class EdgeInference:
    def __init__(self, model_path: str):
        # Use EdgeTPU if available
        try:
            delegate = tflite.load_delegate('libedgetpu.so.1')
            self.interpreter = tflite.Interpreter(
                model_path=model_path,
                experimental_delegates=[delegate]
            )
        except:
            self.interpreter = tflite.Interpreter(model_path=model_path)
        
        self.interpreter.allocate_tensors()
        self.input_details = self.interpreter.get_input_details()
        self.output_details = self.interpreter.get_output_details()
    
    def preprocess(self, image: np.ndarray) -> np.ndarray:
        # Resize and normalize
        resized = cv2.resize(image, (224, 224))
        normalized = resized.astype(np.float32) / 255.0
        return np.expand_dims(normalized, axis=0)
    
    def predict(self, image: np.ndarray) -> np.ndarray:
        input_data = self.preprocess(image)
        self.interpreter.set_tensor(self.input_details[0]['index'], input_data)
        self.interpreter.invoke()
        return self.interpreter.get_tensor(self.output_details[0]['index'])

# Usage
model = EdgeInference("model.tflite")
result = model.predict(camera_frame)
```

### Step 4: ONNX Runtime

```python
import onnxruntime as ort
import numpy as np

class ONNXInference:
    def __init__(self, model_path: str):
        # Session options for optimization
        sess_options = ort.SessionOptions()
        sess_options.graph_optimization_level = ort.GraphOptimizationLevel.ORT_ENABLE_ALL
        sess_options.intra_op_num_threads = 4
        
        # Choose execution provider
        providers = ['CUDAExecutionProvider', 'CPUExecutionProvider']
        
        self.session = ort.InferenceSession(
            model_path,
            sess_options,
            providers=providers
        )
        
        self.input_name = self.session.get_inputs()[0].name
        self.output_name = self.session.get_outputs()[0].name
    
    def predict(self, input_data: np.ndarray) -> np.ndarray:
        return self.session.run(
            [self.output_name],
            {self.input_name: input_data}
        )[0]

# Convert PyTorch to ONNX
import torch

def export_to_onnx(model, input_shape, output_path):
    model.eval()
    dummy_input = torch.randn(input_shape)
    
    torch.onnx.export(
        model,
        dummy_input,
        output_path,
        input_names=['input'],
        output_names=['output'],
        dynamic_axes={'input': {0: 'batch_size'}, 'output': {0: 'batch_size'}},
        opset_version=13
    )
```

### Step 5: ESP32 with TensorFlow Lite Micro

```cpp
#include "tensorflow/lite/micro/all_ops_resolver.h"
#include "tensorflow/lite/micro/micro_interpreter.h"
#include "tensorflow/lite/schema/schema_generated.h"

// Model data (converted to C array)
extern const unsigned char model_data[];
extern const int model_data_len;

// Tensor arena size
constexpr int kTensorArenaSize = 10 * 1024;
uint8_t tensor_arena[kTensorArenaSize];

class TFLiteMicroInference {
private:
    const tflite::Model* model;
    tflite::MicroInterpreter* interpreter;
    TfLiteTensor* input;
    TfLiteTensor* output;
    
public:
    bool init() {
        model = tflite::GetModel(model_data);
        if (model->version() != TFLITE_SCHEMA_VERSION) {
            return false;
        }
        
        static tflite::AllOpsResolver resolver;
        
        static tflite::MicroInterpreter static_interpreter(
            model, resolver, tensor_arena, kTensorArenaSize);
        interpreter = &static_interpreter;
        
        if (interpreter->AllocateTensors() != kTfLiteOk) {
            return false;
        }
        
        input = interpreter->input(0);
        output = interpreter->output(0);
        
        return true;
    }
    
    float* predict(float* input_data, int input_size) {
        // Copy input data
        for (int i = 0; i < input_size; i++) {
            input->data.f[i] = input_data[i];
        }
        
        // Run inference
        if (interpreter->Invoke() != kTfLiteOk) {
            return nullptr;
        }
        
        return output->data.f;
    }
};
```

## Examples

### Example 1: Real-time Object Detection on Mobile

```kotlin
// Android with TensorFlow Lite
class ObjectDetector(private val context: Context) {
    private val interpreter: Interpreter
    private val labels: List<String>
    
    init {
        val options = Interpreter.Options().apply {
            setNumThreads(4)
            // Use GPU if available
            addDelegate(GpuDelegate())
        }
        
        val model = FileUtil.loadMappedFile(context, "detect.tflite")
        interpreter = Interpreter(model, options)
        
        labels = FileUtil.loadLabels(context, "labels.txt")
    }
    
    fun detect(bitmap: Bitmap): List<Detection> {
        // Preprocess
        val inputBuffer = preprocessImage(bitmap)
        
        // Output buffers
        val locations = Array(1) { Array(10) { FloatArray(4) } }
        val classes = Array(1) { FloatArray(10) }
        val scores = Array(1) { FloatArray(10) }
        val numDetections = FloatArray(1)
        
        val outputs = mapOf(
            0 to locations,
            1 to classes,
            2 to scores,
            3 to numDetections
        )
        
        // Run inference
        interpreter.runForMultipleInputsOutputs(arrayOf(inputBuffer), outputs)
        
        return parseResults(locations, classes, scores, numDetections)
    }
}
```

## Best Practices

### ✅ Do This

- ✅ Profile model before optimization
- ✅ Use quantization for size/speed
- ✅ Benchmark on target hardware
- ✅ Implement fallback for unsupported ops
- ✅ Cache model in memory
- ✅ Use hardware acceleration (NPU, GPU, TPU)

### ❌ Avoid This

- ❌ Don't assume desktop performance = edge
- ❌ Don't skip testing on real devices
- ❌ Don't ignore power consumption
- ❌ Don't use excessive model size

## Common Pitfalls

**Problem:** Model too large for device memory
**Solution:** Apply quantization, pruning, or use smaller architecture.

**Problem:** Inference too slow
**Solution:** Use NPU/GPU acceleration, reduce input resolution, batch inference.

**Problem:** Accuracy drops after quantization
**Solution:** Use quantization-aware training, calibrate with representative data.

## Tools & Frameworks

| Category | Tools |
|----------|-------|
| Conversion | TFLite, ONNX, CoreML, OpenVINO |
| Optimization | TF Model Optimization Toolkit, NVIDIA TensorRT |
| Inference | TFLite Runtime, ONNX Runtime, TFLite Micro |
| Hardware | Edge TPU, Neural Compute Stick, Jetson |

## Related Skills

- `@senior-ai-ml-engineer` - For model training
- `@senior-devops-engineer` - For edge deployment
- `@senior-ios-developer` - For CoreML integration

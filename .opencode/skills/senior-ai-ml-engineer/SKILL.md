---
name: senior-ai-ml-engineer
description: "Expert AI/ML engineering including deep learning, LLM fine-tuning, MLOps, model deployment, and production ML systems"
---

# Senior AI/ML Engineer

## Overview

This skill transforms you into an experienced Senior AI/ML Engineer who builds production-ready machine learning systems. You'll design model architectures, implement training pipelines, fine-tune LLMs, deploy models to production, and establish MLOps practices.

## When to Use This Skill

- Use when building ML models and pipelines
- Use when fine-tuning LLMs for specific tasks
- Use when deploying models to production
- Use when implementing MLOps practices
- Use when the user asks about AI/ML development
- Use when optimizing model performance

## How It Works

### Step 1: ML Project Lifecycle

```
ML PROJECT LIFECYCLE
┌─────────────────────────────────────────────────────────────────┐
│                                                                 │
│  1. PROBLEM FRAMING      Define success metrics                │
│     ├── Business objective                                     │
│     ├── ML feasibility                                         │
│     └── Evaluation criteria                                    │
│                                                                 │
│  2. DATA                 Collect, clean, analyze               │
│     ├── Data collection                                        │
│     ├── Exploratory analysis                                   │
│     ├── Feature engineering                                    │
│     └── Data validation                                        │
│                                                                 │
│  3. MODELING             Train, evaluate, iterate              │
│     ├── Baseline model                                         │
│     ├── Experimentation                                        │
│     ├── Hyperparameter tuning                                  │
│     └── Model selection                                        │
│                                                                 │
│  4. DEPLOYMENT           Serve, monitor, maintain              │
│     ├── Model packaging                                        │
│     ├── Serving infrastructure                                 │
│     ├── Monitoring & alerting                                  │
│     └── Continuous retraining                                  │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### Step 2: Model Architecture Selection

```
MODEL SELECTION GUIDE
├── TABULAR DATA
│   ├── XGBoost, LightGBM, CatBoost    (structured, fast)
│   ├── Random Forest                   (interpretable)
│   └── Neural Networks                 (large datasets)
│
├── TEXT/NLP
│   ├── Transformer (BERT, RoBERTa)     (classification)
│   ├── LLMs (GPT, Llama, Mistral)      (generation)
│   └── Sentence Transformers           (embeddings)
│
├── COMPUTER VISION
│   ├── CNN (ResNet, EfficientNet)      (classification)
│   ├── YOLO, Faster R-CNN              (detection)
│   ├── U-Net, Mask R-CNN               (segmentation)
│   └── Vision Transformers (ViT)       (modern approach)
│
├── TIME SERIES
│   ├── ARIMA, Prophet                  (traditional)
│   ├── LSTM, GRU                       (sequential)
│   └── Temporal Fusion Transformer     (state-of-art)
│
└── GENERATIVE
    ├── GANs                            (images)
    ├── Diffusion Models                (high quality)
    └── LLMs                            (text)
```

### Step 3: LLM Fine-Tuning

```python
# Fine-tuning with Hugging Face + PEFT (LoRA)
from transformers import AutoModelForCausalLM, AutoTokenizer, TrainingArguments
from peft import LoraConfig, get_peft_model, prepare_model_for_kbit_training
from trl import SFTTrainer

# Load base model with quantization
model = AutoModelForCausalLM.from_pretrained(
    "mistralai/Mistral-7B-v0.1",
    load_in_4bit=True,
    device_map="auto"
)
tokenizer = AutoTokenizer.from_pretrained("mistralai/Mistral-7B-v0.1")

# Configure LoRA
lora_config = LoraConfig(
    r=16,                    # Rank
    lora_alpha=32,           # Alpha scaling
    target_modules=["q_proj", "v_proj", "k_proj", "o_proj"],
    lora_dropout=0.05,
    bias="none",
    task_type="CAUSAL_LM"
)

# Prepare model
model = prepare_model_for_kbit_training(model)
model = get_peft_model(model, lora_config)

# Training arguments
training_args = TrainingArguments(
    output_dir="./output",
    num_train_epochs=3,
    per_device_train_batch_size=4,
    gradient_accumulation_steps=4,
    learning_rate=2e-4,
    warmup_ratio=0.03,
    logging_steps=10,
    save_strategy="epoch"
)

# Train with SFT
trainer = SFTTrainer(
    model=model,
    train_dataset=dataset,
    args=training_args,
    tokenizer=tokenizer,
    max_seq_length=2048
)
trainer.train()
```

### Step 4: MLOps Pipeline

```
MLOps ARCHITECTURE
┌─────────────────────────────────────────────────────────────────┐
│                                                                 │
│  DATA PIPELINE                                                  │
│  ┌─────────┐    ┌─────────┐    ┌─────────┐    ┌─────────┐      │
│  │ Ingest  │───▶│ Validate│───▶│Transform│───▶│ Store   │      │
│  └─────────┘    └─────────┘    └─────────┘    └─────────┘      │
│       │              │              │              │            │
│       └──────────────┴──────────────┴──────────────┘            │
│                         Great Expectations                      │
│                                                                 │
│  TRAINING PIPELINE                                              │
│  ┌─────────┐    ┌─────────┐    ┌─────────┐    ┌─────────┐      │
│  │ Feature │───▶│  Train  │───▶│Evaluate │───▶│Register │      │
│  │  Store  │    │         │    │         │    │  Model  │      │
│  └─────────┘    └─────────┘    └─────────┘    └─────────┘      │
│                                                                 │
│  SERVING PIPELINE                                               │
│  ┌─────────┐    ┌─────────┐    ┌─────────┐    ┌─────────┐      │
│  │  Load   │───▶│  Serve  │───▶│ Monitor │───▶│Retrain  │      │
│  │  Model  │    │  (API)  │    │  Drift  │    │ Trigger │      │
│  └─────────┘    └─────────┘    └─────────┘    └─────────┘      │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

## Examples

### Example 1: Model Training Pipeline

```python
import mlflow
from sklearn.model_selection import train_test_split
from sklearn.metrics import accuracy_score, f1_score
import xgboost as xgb

def train_model(X, y, params):
    # Split data
    X_train, X_test, y_train, y_test = train_test_split(
        X, y, test_size=0.2, random_state=42
    )
    
    with mlflow.start_run():
        # Log parameters
        mlflow.log_params(params)
        
        # Train model
        model = xgb.XGBClassifier(**params)
        model.fit(X_train, y_train)
        
        # Evaluate
        y_pred = model.predict(X_test)
        accuracy = accuracy_score(y_test, y_pred)
        f1 = f1_score(y_test, y_pred, average='weighted')
        
        # Log metrics
        mlflow.log_metrics({
            "accuracy": accuracy,
            "f1_score": f1
        })
        
        # Log model
        mlflow.xgboost.log_model(model, "model")
        
        return model, accuracy
```

### Example 2: Model Serving with FastAPI

```python
from fastapi import FastAPI
from pydantic import BaseModel
import mlflow

app = FastAPI()

# Load model from registry
model = mlflow.pyfunc.load_model("models:/my_model/Production")

class PredictionRequest(BaseModel):
    features: list[float]

class PredictionResponse(BaseModel):
    prediction: int
    probability: float

@app.post("/predict", response_model=PredictionResponse)
async def predict(request: PredictionRequest):
    prediction = model.predict([request.features])[0]
    probability = model.predict_proba([request.features])[0].max()
    
    return PredictionResponse(
        prediction=int(prediction),
        probability=float(probability)
    )
```

## Best Practices

### ✅ Do This

- ✅ Start with baseline models before complex ones
- ✅ Version everything (data, code, models)
- ✅ Use experiment tracking (MLflow, W&B)
- ✅ Validate data at every step
- ✅ Monitor model performance in production
- ✅ Plan for model retraining from day one
- ✅ Document model decisions and limitations

### ❌ Avoid This

- ❌ Don't skip exploratory data analysis
- ❌ Don't train on test data (data leakage)
- ❌ Don't deploy without monitoring
- ❌ Don't ignore model fairness/bias
- ❌ Don't use outdated dependencies

## Common Pitfalls

**Problem:** Data leakage causing overfit
**Solution:** Strict train/test separation, time-based splits for time-series.

**Problem:** Model drift in production
**Solution:** Monitor distributions, set up automatic retraining triggers.

**Problem:** Slow inference time
**Solution:** Quantization, distillation, batching, GPU optimization.

## Tools

| Category | Tools |
|----------|-------|
| Training | PyTorch, TensorFlow, scikit-learn, XGBoost |
| LLM | Hugging Face, vLLM, Ollama |
| Experiment | MLflow, Weights & Biases, Neptune |
| Feature Store | Feast, Tecton |
| Serving | TorchServe, TensorFlow Serving, Triton |
| Pipeline | Kubeflow, Airflow, Prefect |

## Related Skills

- `@senior-data-engineer` - For data pipelines
- `@senior-devops-engineer` - For deployment
- `@senior-ai-agent-developer` - For AI agents

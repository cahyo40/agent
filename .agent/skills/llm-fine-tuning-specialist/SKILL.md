---
name: llm-fine-tuning-specialist
description: "Expert LLM fine-tuning including LoRA, QLoRA, PEFT, dataset preparation, training optimization, and model deployment"
---

# LLM Fine-Tuning Specialist

## Overview

This skill transforms you into an expert in fine-tuning Large Language Models (LLMs) for specific tasks. You'll handle dataset preparation, PEFT techniques (LoRA, QLoRA), training optimization, and model deployment.

## When to Use This Skill

- Fine-tuning open-source LLMs (Llama, Mistral, etc.)
- Creating domain-specific models
- Implementing efficient training with LoRA/QLoRA
- Preparing and curating training datasets
- Optimizing training for limited hardware

## Key Techniques

### LoRA (Low-Rank Adaptation)

Fine-tune only small adapter weights instead of full model:

```python
from peft import LoraConfig, get_peft_model

lora_config = LoraConfig(
    r=16,                     # Rank
    lora_alpha=32,            # Scaling factor
    target_modules=["q_proj", "v_proj", "k_proj", "o_proj"],
    lora_dropout=0.05,
    bias="none",
    task_type="CAUSAL_LM"
)

model = get_peft_model(base_model, lora_config)
model.print_trainable_parameters()
# trainable params: 4M || all params: 7B || trainable%: 0.06%
```

### QLoRA (Quantized LoRA)

Combine 4-bit quantization with LoRA for memory efficiency:

```python
from transformers import BitsAndBytesConfig
import torch

bnb_config = BitsAndBytesConfig(
    load_in_4bit=True,
    bnb_4bit_quant_type="nf4",
    bnb_4bit_compute_dtype=torch.bfloat16,
    bnb_4bit_use_double_quant=True,
)

model = AutoModelForCausalLM.from_pretrained(
    "meta-llama/Llama-2-7b-hf",
    quantization_config=bnb_config,
    device_map="auto",
)
```

## Dataset Preparation

### Format Options

```python
# Alpaca format (instruction-following)
{
    "instruction": "Summarize the following article",
    "input": "Article text here...",
    "output": "Summary of the article..."
}

# ChatML format (multi-turn)
{
    "messages": [
        {"role": "system", "content": "You are a helpful assistant"},
        {"role": "user", "content": "User message"},
        {"role": "assistant", "content": "Assistant response"}
    ]
}
```

### Dataset Loading

```python
from datasets import load_dataset

dataset = load_dataset("json", data_files="train.jsonl", split="train")

def format_prompt(sample):
    return f"""### Instruction:
{sample['instruction']}

### Input:
{sample['input']}

### Response:
{sample['output']}"""

dataset = dataset.map(lambda x: {"text": format_prompt(x)})
```

## Training Configuration

```python
from transformers import TrainingArguments
from trl import SFTTrainer

training_args = TrainingArguments(
    output_dir="./output",
    num_train_epochs=3,
    per_device_train_batch_size=4,
    gradient_accumulation_steps=4,
    learning_rate=2e-4,
    warmup_ratio=0.03,
    lr_scheduler_type="cosine",
    logging_steps=10,
    save_strategy="epoch",
    bf16=True,           # Use bfloat16 if supported
    optim="paged_adamw_8bit",
)

trainer = SFTTrainer(
    model=model,
    train_dataset=dataset,
    args=training_args,
    peft_config=lora_config,
    dataset_text_field="text",
    max_seq_length=2048,
)

trainer.train()
```

## Merging & Deployment

```python
# Merge LoRA weights into base model
from peft import PeftModel

base_model = AutoModelForCausalLM.from_pretrained("base-model")
model = PeftModel.from_pretrained(base_model, "lora-adapter")
merged_model = model.merge_and_unload()

# Save merged model
merged_model.save_pretrained("merged-model")
tokenizer.save_pretrained("merged-model")

# Push to Hugging Face Hub
merged_model.push_to_hub("username/my-fine-tuned-model")
```

## Best Practices

### ✅ Do This

- Start with smaller rank (r=8 or 16) and increase if needed
- Use high-quality, curated datasets (quality > quantity)
- Monitor training loss for overfitting
- Validate on held-out test set
- Use gradient checkpointing for memory efficiency
- Save checkpoints regularly

### ❌ Avoid

- Don't fine-tune on noisy or low-quality data
- Don't use too high learning rate (>5e-4)
- Don't skip validation during training
- Don't ignore license restrictions of base models

## Hardware Requirements

| Method | VRAM (7B Model) | VRAM (13B Model) |
|--------|-----------------|------------------|
| Full Fine-tuning | 120GB+ | 200GB+ |
| LoRA | 16-24GB | 32-40GB |
| QLoRA (4-bit) | 8-12GB | 16-24GB |

## Related Skills

- `@senior-ai-ml-engineer` - ML engineering
- `@senior-rag-engineer` - RAG systems
- `@senior-prompt-engineer` - Prompt engineering

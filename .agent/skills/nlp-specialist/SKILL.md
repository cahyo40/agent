---
name: nlp-specialist
description: "Expert Natural Language Processing including text classification, sentiment analysis, named entity recognition, and language models"
---

# NLP Specialist

## Overview

This skill transforms you into an **NLP Engineer**. You will move beyond Regex and Bag-of-Words to mastering **Transformers (BERT/GPT)**, interacting with **Hugging Face**, fine-tuning **LLMs**, and deploying production-ready inference endpoints.

## When to Use This Skill

- Use when building Chatbots or RAG systems
- Use when classifying text (Sentiment, Spam, Intent)
- Use when extracting structured data (Named Entity Recognition - NER)
- Use when summarizing long documents
- Use when fine-tuning models (PEFT/LoRA) for custom tasks

---

## Part 1: Modern NLP Pipeline (Transformers)

Spacy is great, but Transformers are SOTA.

### 1.1 The Hugging Face Ecosystem

```python
from transformers import pipeline

# Zero-Shot Classification (No training needed!)
classifier = pipeline("zero-shot-classification", model="facebook/bart-large-mnli")

text = "The new iPhone 15 features a titanium frame."
labels = ["technology", "politics", "sports"]

result = classifier(text, labels)
print(result) 
# Output: {'labels': ['technology', ...], 'scores': [0.99, ...]}
```

### 1.2 Tokenization

Computers don't read text. They read tokens.

```python
from transformers import AutoTokenizer

tokenizer = AutoTokenizer.from_pretrained("bert-base-uncased")
text = "Hello, world!"
tokens = tokenizer(text, padding=True, truncation=True, return_tensors="pt")

print(tokens['input_ids']) # [101, 7592, 1010, 2088, 999, 102]
```

---

## Part 2: Task Specific Models

### 2.1 Named Entity Recognition (NER)

Extracting Companies, Dates, Locations.

```python
ner = pipeline("ner", aggregation_strategy="simple")
text = "Apple bought a startup in San Francisco for $1 Billion."
print(ner(text))
# [{'entity_group': 'ORG', 'word': 'Apple'}, {'entity_group': 'LOC', 'word': 'San Francisco'}]
```

### 2.2 Text Embedding (Semantic Search)

Converting text to vectors for RAG.

```python
from sentence_transformers import SentenceTransformer

model = SentenceTransformer('all-MiniLM-L6-v2')
embeddings = model.encode(["This is a sentence", "This is another one"])
# Returns [384]-dimensional dense vectors
```

---

## Part 3: Fine-Tuning (PEFT / LoRA)

Don't retrain the whole model. Use **Low-Rank Adaptation (LoRA)**.

```python
from peft import LoraConfig, get_peft_model, TaskType

peft_config = LoraConfig(
    task_type=TaskType.SEQ_CLS, 
    inference_mode=False, 
    r=8, 
    lora_alpha=32, 
    lora_dropout=0.1
)

model = get_peft_model(base_model, peft_config)
model.print_trainable_parameters()
# "trainable params: 0.1% of all params" (Very Fast!)
```

---

## Part 4: LLM Integration (LangChain / OpenAI)

### 4.1 Prompt Templates

```python
from langchain.prompts import PromptTemplate

template = "Translate the following english text to {language}: {text}"
prompt = PromptTemplate(template=template, input_variables=["language", "text"])

final_prompt = prompt.format(language="French", text="Hello")
```

### 4.2 Agents (Tool Use)

Giving LLMs access to calculators, search, or APIs.

---

## Part 5: Deployment & Optimization

### 5.1 Quantization (Running big models on small GPUs)

- **FP32** (32-bit float): Standard. Huge VRAM.
- **INT8** (8-bit integer): 4x smaller. Minimal accuracy loss.
- **4-bit (QLoRA)**: Run Llama-2-70b on consumer GPUs.

### 5.2 ONNX Runtime

Convert PyTorch models to ONNX for 2x faster inference on CPU/Edge.

```python
# Export
torch.onnx.export(model, dummy_input, "model.onnx")
```

---

## Part 6: Best Practices Checklist

### ✅ Do This

- ✅ **Use Pre-trained Models**: Don't train from scratch unless you have 10TB of text. Fine-tune instead.
- ✅ **Clean Your Data**: Text quality > Model Architecture. Remove HTML tags, fix encoding.
- ✅ **Chunking**: For RAG, split text intelligently (by paragraph/header), not just by character count.
- ✅ **Eval**: Use metrics like BLEU/ROUGE for translation, but use **LLM-as-a-Judge** for subjective quality.

### ❌ Avoid This

- ❌ **Regex for Complicated Tasks**: Don't parse natural language with Regex. It breaks on edge cases.
- ❌ **Ignoring Token Limits**: LLMs have context windows (4k/8k/128k). Truncate or chunk inputs.
- ❌ **Leaking PII**: Anonymize names/emails before sending to external APIs (OpenAI).

---

## Related Skills

- `@senior-ai-ml-engineer` - Deep Learning foundations
- `@senior-rag-engineer` - Retrieval Augmented Generation
- `@senior-python-developer` - The language of AI

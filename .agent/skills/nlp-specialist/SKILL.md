---
name: nlp-specialist
description: "Expert Natural Language Processing including text classification, sentiment analysis, named entity recognition, and language models"
---

# NLP Specialist

## Overview

Master Natural Language Processing including text preprocessing, sentiment analysis, named entity recognition, text classification, and language model integration.

## When to Use This Skill

- Use when building text analysis
- Use when sentiment detection needed
- Use when entity extraction required
- Use when language understanding

## How It Works

### Step 1: Text Preprocessing

```python
import re
import nltk
from nltk.tokenize import word_tokenize, sent_tokenize
from nltk.corpus import stopwords
from nltk.stem import WordNetLemmatizer, PorterStemmer

nltk.download(['punkt', 'stopwords', 'wordnet', 'averaged_perceptron_tagger'])

class TextPreprocessor:
    def __init__(self, language='english'):
        self.stop_words = set(stopwords.words(language))
        self.lemmatizer = WordNetLemmatizer()
        self.stemmer = PorterStemmer()
    
    def clean_text(self, text: str) -> str:
        # Lowercase
        text = text.lower()
        # Remove URLs
        text = re.sub(r'http\S+|www\S+|https\S+', '', text)
        # Remove HTML tags
        text = re.sub(r'<.*?>', '', text)
        # Remove special characters
        text = re.sub(r'[^\w\s]', '', text)
        # Remove extra whitespace
        text = ' '.join(text.split())
        return text
    
    def tokenize(self, text: str) -> list[str]:
        return word_tokenize(text)
    
    def remove_stopwords(self, tokens: list[str]) -> list[str]:
        return [t for t in tokens if t not in self.stop_words]
    
    def lemmatize(self, tokens: list[str]) -> list[str]:
        return [self.lemmatizer.lemmatize(t) for t in tokens]
    
    def process(self, text: str) -> list[str]:
        text = self.clean_text(text)
        tokens = self.tokenize(text)
        tokens = self.remove_stopwords(tokens)
        tokens = self.lemmatize(tokens)
        return tokens

# Usage
preprocessor = TextPreprocessor()
tokens = preprocessor.process("The cats are running quickly in the park!")
# Output: ['cat', 'running', 'quickly', 'park']
```

### Step 2: Sentiment Analysis

```python
from transformers import pipeline, AutoModelForSequenceClassification, AutoTokenizer

# Using Hugging Face pipeline
sentiment_analyzer = pipeline("sentiment-analysis", model="cardiffnlp/twitter-roberta-base-sentiment-latest")

def analyze_sentiment(texts: list[str]) -> list[dict]:
    results = sentiment_analyzer(texts)
    return results

# Example
texts = [
    "I love this product! It's amazing!",
    "Terrible experience, would not recommend.",
    "It's okay, nothing special."
]
results = analyze_sentiment(texts)
# [{'label': 'positive', 'score': 0.98}, ...]

# Custom sentiment model
class SentimentClassifier:
    def __init__(self, model_name="distilbert-base-uncased"):
        self.tokenizer = AutoTokenizer.from_pretrained(model_name)
        self.model = AutoModelForSequenceClassification.from_pretrained(
            model_name, num_labels=3
        )
    
    def predict(self, text: str) -> dict:
        inputs = self.tokenizer(text, return_tensors="pt", truncation=True, max_length=512)
        outputs = self.model(**inputs)
        probs = outputs.logits.softmax(dim=-1)
        
        labels = ['negative', 'neutral', 'positive']
        pred_idx = probs.argmax().item()
        
        return {
            'label': labels[pred_idx],
            'confidence': probs[0][pred_idx].item()
        }
```

### Step 3: Named Entity Recognition

```python
import spacy
from transformers import pipeline

# Using spaCy
nlp = spacy.load("en_core_web_lg")

def extract_entities_spacy(text: str) -> list[dict]:
    doc = nlp(text)
    entities = []
    for ent in doc.ents:
        entities.append({
            'text': ent.text,
            'label': ent.label_,
            'start': ent.start_char,
            'end': ent.end_char
        })
    return entities

# Example
text = "Apple Inc. was founded by Steve Jobs in Cupertino, California in 1976."
entities = extract_entities_spacy(text)
# [
#   {'text': 'Apple Inc.', 'label': 'ORG', ...},
#   {'text': 'Steve Jobs', 'label': 'PERSON', ...},
#   {'text': 'Cupertino', 'label': 'GPE', ...},
#   {'text': 'California', 'label': 'GPE', ...},
#   {'text': '1976', 'label': 'DATE', ...}
# ]

# Using Hugging Face
ner_pipeline = pipeline("ner", model="dslim/bert-base-NER", aggregation_strategy="simple")

def extract_entities_hf(text: str) -> list[dict]:
    results = ner_pipeline(text)
    return [
        {
            'text': r['word'],
            'label': r['entity_group'],
            'score': r['score']
        }
        for r in results
    ]
```

### Step 4: Text Classification

```python
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.naive_bayes import MultinomialNB
from sklearn.pipeline import Pipeline
from sklearn.model_selection import train_test_split
from sklearn.metrics import classification_report

# Traditional ML approach
class TextClassifier:
    def __init__(self):
        self.pipeline = Pipeline([
            ('tfidf', TfidfVectorizer(max_features=5000, ngram_range=(1, 2))),
            ('clf', MultinomialNB())
        ])
    
    def train(self, texts: list[str], labels: list[str]):
        X_train, X_test, y_train, y_test = train_test_split(
            texts, labels, test_size=0.2, random_state=42
        )
        self.pipeline.fit(X_train, y_train)
        
        # Evaluate
        y_pred = self.pipeline.predict(X_test)
        print(classification_report(y_test, y_pred))
    
    def predict(self, text: str) -> str:
        return self.pipeline.predict([text])[0]

# Transformer-based classification
from transformers import Trainer, TrainingArguments

def train_transformer_classifier(train_dataset, eval_dataset, num_labels):
    model = AutoModelForSequenceClassification.from_pretrained(
        "distilbert-base-uncased", num_labels=num_labels
    )
    
    training_args = TrainingArguments(
        output_dir="./results",
        num_train_epochs=3,
        per_device_train_batch_size=16,
        per_device_eval_batch_size=64,
        evaluation_strategy="epoch",
        save_strategy="epoch",
        load_best_model_at_end=True
    )
    
    trainer = Trainer(
        model=model,
        args=training_args,
        train_dataset=train_dataset,
        eval_dataset=eval_dataset
    )
    
    trainer.train()
    return model
```

## Best Practices

### ✅ Do This

- ✅ Preprocess text consistently
- ✅ Handle edge cases (empty, special chars)
- ✅ Use appropriate models for task
- ✅ Evaluate with proper metrics
- ✅ Consider language/domain

### ❌ Avoid This

- ❌ Don't skip text cleaning
- ❌ Don't ignore class imbalance
- ❌ Don't overtrain on small data
- ❌ Don't hardcode stopwords

## Related Skills

- `@senior-ai-ml-engineer` - ML engineering
- `@senior-python-developer` - Python development

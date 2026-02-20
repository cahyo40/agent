---
name: llm-ops-engineer
description: "LLM Operations engineer specializing in LLM deployment, monitoring, prompt versioning, evaluation, cost optimization, and production AI system management"
---

# LLM Operations Engineer

## Overview

This skill transforms you into an **LLM Operations (LLMOps) Engineer** who deploys, monitors, and manages large language models in production. You'll master prompt versioning, model evaluation, cost optimization, caching strategies, and observability for AI-powered applications.

## When to Use This Skill

- Use when deploying LLM applications to production
- Use when implementing LLM monitoring and observability
- Use when managing prompt versions and iterations
- Use when evaluating LLM performance and quality
- Use when optimizing LLM costs and latency

---

## Part 1: LLMOps Fundamentals

### 1.1 LLMOps vs MLOps

| Aspect | MLOps | LLMOps |
|--------|-------|--------|
| **Model** | Trained from scratch | Pre-trained + fine-tuned |
| **Data** | Structured training data | Prompts + completions |
| **Evaluation** | Accuracy, F1, ROC | Quality, relevance, safety |
| **Monitoring** | Drift, performance | Token usage, cost, quality |
| **Versioning** | Model weights | Prompts + models + configs |

### 1.2 LLMOps Stack

```
┌─────────────────────────────────────────────────────────────┐
│                    LLM Application Layer                     │
│  (Chatbots, Copilots, Search, Content Generation)           │
├─────────────────────────────────────────────────────────────┤
│                    Orchestration Layer                       │
│  (LangChain, LlamaIndex, Semantic Kernel, Haystack)         │
├─────────────────────────────────────────────────────────────┤
│                    Model Layer                               │
│  (OpenAI, Anthropic, Cohere, Self-hosted LLMs)              │
├─────────────────────────────────────────────────────────────┤
│                    Infrastructure Layer                      │
│  (GPU Cloud, Vector DBs, Caching, Monitoring)               │
└─────────────────────────────────────────────────────────────┘
```

---

## Part 2: Prompt Management

### 2.1 Prompt Versioning

```yaml
# prompts/customer-support.yaml
version: 2.1.0
name: customer-support-assistant
description: Handles customer support inquiries

model: gpt-4-turbo-preview
temperature: 0.7
max_tokens: 1000

system: |
  You are a helpful customer support assistant for {{company_name}}.
  
  Guidelines:
  - Be friendly and professional
  - Acknowledge customer concerns
  - Provide clear, actionable solutions
  - Escalate complex issues to human agents
  
  Product Information:
  {{product_context}}

user: |
  Customer inquiry:
  {{customer_message}}
  
  Conversation history:
  {{conversation_history}}
  
  Please provide a helpful response.

metadata:
  created_by: team-support
  created_at: 2024-01-15
  tags:
    - support
    - customer-facing
  test_coverage: 95%
```

### 2.2 Prompt Registry

```python
# prompt_registry.py
from typing import Dict, Optional
from datetime import datetime
import yaml

class PromptVersion:
    def __init__(self, name: str, version: str, config: Dict):
        self.name = name
        self.version = version
        self.config = config
        self.created_at = datetime.now()
    
    def render(self, **kwargs) -> str:
        """Render prompt with variables."""
        from jinja2 import Template
        template = Template(self.config['system'])
        return template.render(**kwargs)

class PromptRegistry:
    def __init__(self):
        self.prompts: Dict[str, Dict[str, PromptVersion]] = {}
    
    def register(self, prompt: PromptVersion):
        """Register a new prompt version."""
        if prompt.name not in self.prompts:
            self.prompts[prompt.name] = {}
        self.prompts[prompt.name][prompt.version] = prompt
    
    def get(self, name: str, version: str = "latest") -> PromptVersion:
        """Get prompt by name and version."""
        if name not in self.prompts:
            raise ValueError(f"Prompt '{name}' not found")
        
        if version == "latest":
            return max(
                self.prompts[name].values(),
                key=lambda p: p.created_at
            )
        
        return self.prompts[name][version]
    
    def list_versions(self, name: str) -> list:
        """List all versions of a prompt."""
        if name not in self.prompts:
            return []
        return sorted(
            self.prompts[name].keys(),
            key=lambda v: self.prompts[name][v].created_at
        )

# Usage
registry = PromptRegistry()

# Load prompts from YAML
with open('prompts/customer-support.yaml') as f:
    config = yaml.safe_load(f)
    prompt = PromptVersion(
        name=config['name'],
        version=config['version'],
        config=config
    )
    registry.register(prompt)

# Get and render prompt
prompt = registry.get('customer-support-assistant', 'latest')
rendered = prompt.render(
    company_name="Acme Inc",
    product_context="Our SaaS platform...",
    customer_message="I can't login to my account",
    conversation_history=[]
)
```

### 2.3 Prompt A/B Testing

```python
class PromptABTest:
    def __init__(self, variants: Dict[str, PromptVersion]):
        self.variants = variants
        self.results = {name: [] for name in variants}
    
    def get_variant(self, user_id: str) -> tuple:
        """Get variant for user (consistent hashing)."""
        import hashlib
        
        variant_names = list(self.variants.keys())
        hash_input = f"{user_id}:{':'.join(variant_names)}"
        hash_value = int(hashlib.md5(hash_input.encode()).hexdigest(), 16)
        
        variant_index = hash_value % len(variant_names)
        variant_name = variant_names[variant_index]
        
        return variant_name, self.variants[variant_name]
    
    def record_result(self, variant: str, metrics: Dict):
        """Record test result for variant."""
        self.results[variant].append({
            'timestamp': datetime.now(),
            **metrics
        })
    
    def get_stats(self) -> Dict:
        """Get A/B test statistics."""
        stats = {}
        for variant, results in self.results.items():
            if not results:
                continue
            
            stats[variant] = {
                'samples': len(results),
                'avg_rating': sum(r.get('rating', 0) for r in results) / len(results),
                'avg_tokens': sum(r.get('tokens', 0) for r in results) / len(results),
                'success_rate': sum(r.get('success', 0) for r in results) / len(results),
            }
        
        return stats

# Usage
ab_test = PromptABTest({
    'control': registry.get('customer-support', '2.0.0'),
    'variant': registry.get('customer-support', '2.1.0'),
})

# During inference
variant_name, prompt = ab_test.get_variant(user_id='user_123')
response = llm.generate(prompt.render(**variables))

# Record results
ab_test.record_result(variant_name, {
    'rating': user_feedback_rating,
    'tokens': response.usage.total_tokens,
    'success': 1 if issue_resolved else 0,
})
```

---

## Part 3: LLM Monitoring

### 3.1 Key Metrics

| Metric | Description | Alert Threshold |
|--------|-------------|-----------------|
| **Latency** | Time to first token, total time | >3s |
| **Token Usage** | Input + output tokens | Budget exceeded |
| **Cost** | API costs per request/day | >daily budget |
| **Error Rate** | API errors, timeouts | >1% |
| **Quality Score** | Human/AI evaluation | <threshold |
| **Hallucination Rate** | Factually incorrect outputs | >5% |

### 3.2 Monitoring Implementation

```python
# llm_monitor.py
from dataclasses import dataclass
from datetime import datetime
from typing import Dict, Optional
import logging

@dataclass
class LLMRequest:
    id: str
    model: str
    prompt: str
    response: str
    tokens_input: int
    tokens_output: int
    latency_ms: float
    cost_usd: float
    timestamp: datetime
    user_id: Optional[str]
    metadata: Dict

class LLMMonitor:
    def __init__(self, metrics_client):
        self.metrics = metrics_client
        self.logger = logging.getLogger('llm')
    
    def record_request(self, request: LLMRequest):
        """Record LLM request metrics."""
        # Log request
        self.logger.info('LLM request', extra={
            'request_id': request.id,
            'model': request.model,
            'tokens': request.tokens_input + request.tokens_output,
            'latency_ms': request.latency_ms,
            'cost_usd': request.cost_usd,
        })
        
        # Record metrics
        self.metrics.increment('llm.requests.total', tags={'model': request.model})
        self.metrics.histogram('llm.latency', request.latency_ms, tags={'model': request.model})
        self.metrics.histogram('llm.tokens.input', request.tokens_input)
        self.metrics.histogram('llm.tokens.output', request.tokens_output)
        self.metrics.histogram('llm.cost', request.cost_usd * 100)  # cents
        
        # Track daily spend
        self.metrics.increment('llm.cost.daily', request.cost_usd)
    
    def record_feedback(self, request_id: str, rating: int, feedback: str = ''):
        """Record user feedback."""
        self.metrics.histogram('llm.feedback.rating', rating)
        
        if rating <= 2:
            self.metrics.increment('llm.feedback.negative')
            self.logger.warning(f'Negative feedback for request {request_id}: {feedback}')
    
    def record_error(self, error_type: str, model: str):
        """Record LLM error."""
        self.metrics.increment('llm.errors.total', tags={'type': error_type, 'model': model})
    
    def get_daily_spend(self) -> float:
        """Get today's LLM spend."""
        return self.metrics.get('llm.cost.daily')
    
    def check_budget(self, daily_budget: float) -> bool:
        """Check if we're within budget."""
        return self.get_daily_spend() < daily_budget

# Usage with decorator
def track_llm_call(monitor: LLMMonitor):
    def decorator(func):
        async def wrapper(*args, **kwargs):
            start = datetime.now()
            request_id = str(uuid.uuid4())
            
            try:
                response = await func(*args, **kwargs)
                
                latency = (datetime.now() - start).total_seconds() * 1000
                cost = calculate_cost(response.usage, response.model)
                
                request = LLMRequest(
                    id=request_id,
                    model=response.model,
                    prompt=args[0] if args else '',
                    response=response.content,
                    tokens_input=response.usage.prompt_tokens,
                    tokens_output=response.usage.completion_tokens,
                    latency_ms=latency,
                    cost_usd=cost,
                    timestamp=start,
                    user_id=kwargs.get('user_id'),
                    metadata=kwargs.get('metadata', {})
                )
                
                monitor.record_request(request)
                return response
                
            except Exception as e:
                monitor.record_error(type(e).__name__, kwargs.get('model', 'unknown'))
                raise
        
        return wrapper
    return decorator
```

### 3.3 Alerting Rules

```yaml
# alerting_rules.yaml
groups:
  - name: llm-alerts
    rules:
      # High error rate
      - alert: LLMHighErrorRate
        expr: |
          sum(rate(llm_errors_total[5m])) 
          / 
          sum(rate(llm_requests_total[5m])) > 0.01
        for: 5m
        annotations:
          summary: "LLM error rate above 1%"
      
      # High latency
      - alert: LLMHighLatency
        expr: |
          histogram_quantile(0.95, rate(llm_latency_bucket[5m])) > 3000
        for: 10m
        annotations:
          summary: "LLM P95 latency above 3s"
      
      # Budget exceeded
      - alert: LLMBudgetExceeded
        expr: |
          llm_cost_daily > 100  # $100 daily budget
        annotations:
          summary: "Daily LLM budget exceeded"
      
      # Quality degradation
      - alert: LLMQualityDegradation
        expr: |
          avg(llm_feedback_rating[1h]) < 3.5
        for: 30m
        annotations:
          summary: "LLM quality score below threshold"
```

---

## Part 4: Cost Optimization

### 4.1 Caching Strategies

```python
# llm_cache.py
import hashlib
import json
from typing import Optional, Dict
from datetime import datetime, timedelta

class LLMSemanticCache:
    """Cache similar prompts using embeddings."""
    
    def __init__(self, vector_store, embedding_model, threshold=0.95):
        self.vector_store = vector_store
        self.embedding_model = embedding_model
        self.threshold = threshold
    
    def get(self, prompt: str) -> Optional[str]:
        """Get cached response for similar prompt."""
        # Generate embedding
        embedding = self.embedding_model.encode(prompt)
        
        # Search for similar prompts
        results = self.vector_store.search(
            embedding=embedding,
            limit=1,
            filter={'similarity': {'$gte': self.threshold}}
        )
        
        if results:
            return results[0]['response']
        return None
    
    def set(self, prompt: str, response: str, metadata: Dict = None):
        """Cache prompt-response pair."""
        embedding = self.embedding_model.encode(prompt)
        
        self.vector_store.upsert({
            'embedding': embedding,
            'prompt': prompt,
            'response': response,
            'metadata': metadata or {},
            'created_at': datetime.now().isoformat()
        })

class LLMLiteralCache:
    """Exact match cache for identical prompts."""
    
    def __init__(self, redis_client, ttl_hours=24):
        self.redis = redis_client
        self.ttl = timedelta(hours=ttl_hours)
    
    def _key(self, prompt: str, model: str) -> str:
        """Generate cache key."""
        content = f"{model}:{prompt}"
        return f"llm:cache:{hashlib.sha256(content.encode()).hexdigest()}"
    
    def get(self, prompt: str, model: str) -> Optional[str]:
        """Get cached response."""
        key = self._key(prompt, model)
        return self.redis.get(key)
    
    def set(self, prompt: str, model: str, response: str):
        """Cache response."""
        key = self._key(prompt, model)
        self.redis.setex(key, self.ttl, response)

# Usage with fallback
class CachedLLMClient:
    def __init__(self, client, literal_cache, semantic_cache):
        self.client = client
        self.literal_cache = literal_cache
        self.semantic_cache = semantic_cache
        self.cache_hits = 0
        self.cache_misses = 0
    
    async def generate(self, prompt: str, model: str, **kwargs) -> str:
        """Generate with caching."""
        # Try literal cache first
        cached = self.literal_cache.get(prompt, model)
        if cached:
            self.cache_hits += 1
            return cached
        
        # Try semantic cache
        cached = self.semantic_cache.get(prompt)
        if cached:
            self.cache_hits += 1
            return cached
        
        # Cache miss - generate
        self.cache_misses += 1
        response = await self.client.generate(prompt, model, **kwargs)
        
        # Cache the response
        self.literal_cache.set(prompt, model, response)
        self.semantic_cache.set(prompt, response)
        
        return response
    
    @property
    def cache_hit_rate(self) -> float:
        total = self.cache_hits + self.cache_misses
        return self.cache_hits / total if total > 0 else 0
```

### 4.2 Model Routing

```python
class ModelRouter:
    """Route requests to appropriate models based on complexity."""
    
    def __init__(self, models: Dict[str, LLMClient]):
        self.models = models
        self.classifier = ComplexityClassifier()
    
    async def route(self, prompt: str, **kwargs) -> str:
        """Route to appropriate model."""
        complexity = await self.classifier.classify(prompt)
        
        if complexity == 'simple':
            # Use cheaper model for simple queries
            return await self.models['gpt-3.5-turbo'].generate(prompt, **kwargs)
        elif complexity == 'medium':
            return await self.models['gpt-4-turbo'].generate(prompt, **kwargs)
        else:
            # Use most capable model for complex queries
            return await self.models['gpt-4'].generate(prompt, **kwargs)

class ComplexityClassifier:
    """Classify prompt complexity."""
    
    async def classify(self, prompt: str) -> str:
        """Classify as simple, medium, or complex."""
        # Simple heuristics
        word_count = len(prompt.split())
        has_code = '```' in prompt or 'def ' in prompt
        has_math = any(c in prompt for c in ['=', '+', '-', '*', '/'])
        
        if word_count < 20 and not has_code and not has_math:
            return 'simple'
        elif word_count < 100 and not has_code:
            return 'medium'
        else:
            return 'complex'
```

### 4.3 Cost Tracking

```python
# Cost calculation
COST_PER_1K_TOKENS = {
    'gpt-4': {'input': 0.03, 'output': 0.06},
    'gpt-4-turbo': {'input': 0.01, 'output': 0.03},
    'gpt-3.5-turbo': {'input': 0.0005, 'output': 0.0015},
    'claude-3-opus': {'input': 0.015, 'output': 0.075},
    'claude-3-sonnet': {'input': 0.003, 'output': 0.015},
}

def calculate_cost(usage, model: str) -> float:
    """Calculate cost from token usage."""
    rates = COST_PER_1K_TOKENS.get(model, {'input': 0, 'output': 0})
    
    input_cost = (usage.prompt_tokens / 1000) * rates['input']
    output_cost = (usage.completion_tokens / 1000) * rates['output']
    
    return input_cost + output_cost

# Budget enforcement
class BudgetEnforcer:
    def __init__(self, daily_budget: float, monitor: LLMMonitor):
        self.daily_budget = daily_budget
        self.monitor = monitor
    
    def can_proceed(self, estimated_cost: float) -> bool:
        """Check if request is within budget."""
        current_spend = self.monitor.get_daily_spend()
        return current_spend + estimated_cost <= self.daily_budget
    
    def get_remaining_budget(self) -> float:
        """Get remaining daily budget."""
        return self.daily_budget - self.monitor.get_daily_spend()
```

---

## Part 5: LLM Evaluation

### 5.1 Evaluation Metrics

```python
from typing import List, Dict
from dataclasses import dataclass

@dataclass
class EvaluationResult:
    prompt: str
    response: str
    expected: str
    metrics: Dict

class LLMEvaluator:
    """Evaluate LLM outputs."""
    
    def __init__(self, llm_client):
        self.llm = llm_client
    
    async def evaluate_relevance(self, prompt: str, response: str) -> float:
        """Evaluate response relevance (1-5 scale)."""
        eval_prompt = f"""
        Rate the relevance of this response to the prompt:
        
        Prompt: {prompt}
        Response: {response}
        
        Rate from 1 (irrelevant) to 5 (highly relevant).
        Respond with only a number.
        """
        
        result = await self.llm.generate(eval_prompt)
        return float(result.strip())
    
    async def evaluate_accuracy(self, response: str, expected: str) -> float:
        """Evaluate factual accuracy."""
        eval_prompt = f"""
        Compare these responses for factual accuracy:
        
        Expected: {expected}
        Actual: {response}
        
        Rate accuracy from 1 (completely wrong) to 5 (completely accurate).
        Respond with only a number.
        """
        
        result = await self.llm.generate(eval_prompt)
        return float(result.strip())
    
    async def evaluate_safety(self, response: str) -> bool:
        """Check if response is safe/appropriate."""
        eval_prompt = f"""
        Is this response safe and appropriate?
        
        Response: {response}
        
        Respond with YES or NO.
        """
        
        result = await self.llm.generate(eval_prompt)
        return 'YES' in result.upper()
    
    async def run_evaluation(self, test_cases: List[Dict]) -> Dict:
        """Run full evaluation suite."""
        results = []
        
        for case in test_cases:
            response = await self.llm.generate(case['prompt'])
            
            metrics = {
                'relevance': await self.evaluate_relevance(case['prompt'], response),
                'accuracy': await self.evaluate_accuracy(response, case.get('expected', '')),
                'safety': await self.evaluate_safety(response),
            }
            
            results.append(EvaluationResult(
                prompt=case['prompt'],
                response=response,
                expected=case.get('expected', ''),
                metrics=metrics
            ))
        
        # Aggregate results
        return {
            'total': len(results),
            'avg_relevance': sum(r.metrics['relevance'] for r in results) / len(results),
            'avg_accuracy': sum(r.metrics['accuracy'] for r in results) / len(results),
            'safety_pass_rate': sum(1 for r in results if r.metrics['safety']) / len(results),
            'results': results,
        }
```

### 5.2 Test Dataset

```yaml
# test_cases/customer-support.yaml
test_cases:
  - name: login_issue
    prompt: "I can't login to my account"
    expected: "I understand you're having trouble logging in. Let me help you with that. Can you tell me what error message you're seeing?"
    category: support
    
  - name: refund_request
    prompt: "I want a refund for my purchase"
    expected: "I'd be happy to help you with a refund. Can you provide your order number and the reason for the refund request?"
    category: billing
    
  - name: feature_question
    prompt: "Does your product integrate with Slack?"
    expected: "Yes, we offer Slack integration! You can connect your account in Settings > Integrations > Slack."
    category: product

  - name: pricing_inquiry
    prompt: "What are your pricing plans?"
    expected: "We offer three plans: Starter ($9/mo), Professional ($29/mo), and Enterprise (custom pricing). Would you like more details?"
    category: sales
```

---

## Best Practices

### ✅ Do This

- ✅ Version all prompts with semantic versioning
- ✅ Implement comprehensive monitoring
- ✅ Set up cost alerts and budgets
- ✅ Cache responses when appropriate
- ✅ Evaluate model outputs regularly
- ✅ Use model routing for cost optimization
- ✅ Track user feedback
- ✅ Implement fallback strategies

### ❌ Avoid This

- ❌ Hardcoding prompts in application code
- ❌ No monitoring or alerting
- ❌ Ignoring cost optimization
- ❌ No evaluation framework
- ❌ Single model dependency
- ❌ No caching strategy
- ❌ Ignoring rate limits

---

## Related Skills

- `@senior-ai-agent-developer` - AI agent development
- `@senior-rag-engineer` - RAG systems
- `@llm-fine-tuning-specialist` - Model fine-tuning
- `@llm-security-specialist` - LLM security
- `@observability-engineer` - Observability patterns

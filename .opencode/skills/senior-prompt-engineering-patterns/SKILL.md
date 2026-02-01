---
name: senior-prompt-engineering-patterns
description: "Advanced prompt engineering patterns including meta-prompting, prompt chaining, evaluation frameworks, and production AI systems"
---

# Senior Prompt Engineering Patterns

## Overview

This skill extends prompt engineering with advanced patterns for production AI systems. You'll implement prompt chaining, evaluation frameworks, meta-prompting, and system-level prompt architectures.

## When to Use This Skill

- Use when building complex AI workflows
- Use when chaining multiple AI calls
- Use when evaluating prompt quality
- Use when designing agent systems
- Use when optimizing for production

## How It Works

### Step 1: Prompt Chaining

```
CHAIN PATTERNS
┌─────────────────────────────────────────────────────────────────┐
│                                                                 │
│  SEQUENTIAL CHAIN                                               │
│  [Extract] → [Analyze] → [Summarize] → [Format]                │
│                                                                 │
│  PARALLEL CHAIN                                                 │
│       ┌─→ [Sentiment] ─┐                                       │
│  [In] ├─→ [Entities]  ─┼→ [Merge] → [Out]                      │
│       └─→ [Keywords]  ─┘                                       │
│                                                                 │
│  CONDITIONAL CHAIN                                              │
│  [Classify] → if code → [Review] → [Output]                    │
│            → if text → [Edit] → [Output]                       │
│                                                                 │
│  LOOP CHAIN                                                     │
│  [Generate] → [Evaluate] → if fail → [Refine] → [Evaluate]    │
│                          → if pass → [Output]                  │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### Step 2: Meta-Prompting

```
META-PROMPT: Generate prompts for specific tasks

System: You are a prompt engineer. Given a task description,
generate an optimized prompt that includes:
1. Clear role definition
2. Specific instructions
3. Output format
4. 2-3 examples

User: Create a prompt for summarizing technical documents.

Output: [Generated optimized prompt]
```

### Step 3: Evaluation Framework

```
PROMPT EVALUATION CRITERIA
├── ACCURACY
│   ├── Correct information
│   ├── No hallucinations
│   └── Factual grounding
│
├── RELEVANCE
│   ├── Answers the question
│   ├── Appropriate detail level
│   └── On-topic
│
├── COHERENCE
│   ├── Logical flow
│   ├── Clear structure
│   └── No contradictions
│
├── HELPFULNESS
│   ├── Actionable
│   ├── Complete
│   └── User-focused
│
└── SAFETY
    ├── No harmful content
    ├── Appropriate tone
    └── Follows guidelines
```

## Examples

### Example 1: Prompt Chain Implementation

```python
async def research_chain(topic: str) -> Report:
    # Step 1: Generate research questions
    questions = await llm.call(
        system="Generate 5 research questions",
        user=f"Topic: {topic}"
    )
    
    # Step 2: Search for each question (parallel)
    contexts = await asyncio.gather(*[
        search(q) for q in questions
    ])
    
    # Step 3: Synthesize findings
    synthesis = await llm.call(
        system="Synthesize research findings",
        user=f"Questions: {questions}\nContexts: {contexts}"
    )
    
    # Step 4: Format as report
    return await llm.call(
        system="Format as structured report",
        user=synthesis
    )
```

### Example 2: Self-Evaluation Pattern

```
Generate answer, then evaluate it:

Step 1: [Answer the question]
Step 2: Rate your answer 1-10 on:
- Accuracy
- Completeness
- Clarity
Step 3: If any score < 7, improve that aspect
Step 4: Return final answer
```

## Best Practices

### ✅ Do This

- ✅ Break complex tasks into chain steps
- ✅ Evaluate prompts with test cases
- ✅ Use structured output (JSON)
- ✅ Implement fallback strategies
- ✅ Log prompts and responses

### ❌ Avoid This

- ❌ Don't chain too many steps (latency)
- ❌ Don't skip evaluation phase
- ❌ Don't hardcode prompts (use templates)
- ❌ Don't ignore error handling

## Common Pitfalls

**Problem:** Chain failures cascade
**Solution:** Add validation between steps, implement retries.

**Problem:** Inconsistent intermediate outputs
**Solution:** Use strongly typed outputs (JSON schemas).

## Related Skills

- `@senior-prompt-engineer` - Core techniques
- `@senior-software-engineer` - Implementation

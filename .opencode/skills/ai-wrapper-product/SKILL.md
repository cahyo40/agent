---
name: ai-wrapper-product
description: "Expert in building AI-powered products that wrap LLM APIs into focused, valuable tools and applications"
---

# AI Wrapper Product

## Overview

Build products that leverage LLM APIs to solve focused problems.

## When to Use This Skill

- Use when building AI-powered tools
- Use when wrapping GPT/Claude APIs

## How It Works

### Step 1: Product Categories

```markdown
## AI Wrapper Types

### Writing Tools
- Blog post generators
- Email writers
- Copy assistants

### Productivity
- Meeting summarizers
- Document Q&A
- Code assistants

### Creative
- Image generators
- Video script writers
- Music assistants

### Business
- Customer support bots
- Sales email generators
- Report analyzers
```

### Step 2: API Integration

```python
from openai import OpenAI

client = OpenAI()

def generate_content(prompt: str, context: str):
    response = client.chat.completions.create(
        model="gpt-4",
        messages=[
            {"role": "system", "content": context},
            {"role": "user", "content": prompt}
        ],
        temperature=0.7
    )
    return response.choices[0].message.content

# Product-specific wrapper
def write_blog_post(topic: str, tone: str = "professional"):
    context = f"""You are a blog writer. 
    Write in a {tone} tone.
    Include intro, 3 sections, conclusion."""
    
    return generate_content(f"Write about: {topic}", context)
```

### Step 3: Prompt Engineering

```markdown
## System Prompts

### Role Definition
"You are a [specific expert] who [specific task]"

### Output Format
"Return response as JSON with keys: ..."

### Constraints
"Keep response under X words"
"Only include factual information"

### Examples
Provide 1-2 examples of desired output
```

## Best Practices

- ✅ Solve one problem well
- ✅ Add value beyond raw API
- ✅ Handle errors gracefully
- ❌ Don't just wrap API
- ❌ Don't ignore rate limits

## Related Skills

- `@senior-ai-agent-developer`
- `@senior-prompt-engineer`

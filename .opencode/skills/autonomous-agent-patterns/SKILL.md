---
name: autonomous-agent-patterns
description: "Design patterns for building autonomous AI agents including tool integration, permission systems, and human-in-the-loop workflows"
---

# Autonomous Agent Patterns

## Overview

This skill helps you design and build autonomous AI agents that can independently plan, execute, and self-correct while maintaining safety and reliability.

## When to Use This Skill

- Use when building AI agents
- Use when designing agent architectures
- Use when implementing tool use
- Use when adding agentic capabilities

## How It Works

### Step 1: Agent Architecture

```
AUTONOMOUS AGENT ARCHITECTURE
┌─────────────────────────────────────────────────────────────────┐
│                                                                 │
│                    ┌───────────────────┐                       │
│                    │   USER REQUEST    │                       │
│                    └─────────┬─────────┘                       │
│                              │                                  │
│                    ┌─────────▼─────────┐                       │
│                    │     PLANNER       │                       │
│                    │  (Goal Decompose) │                       │
│                    └─────────┬─────────┘                       │
│                              │                                  │
│              ┌───────────────┼───────────────┐                 │
│              │               │               │                 │
│     ┌────────▼────────┐ ┌────▼────┐ ┌───────▼───────┐         │
│     │    EXECUTOR     │ │  MEMORY │ │   OBSERVER    │         │
│     │  (Run Tools)    │ │ (State) │ │  (Evaluate)   │         │
│     └────────┬────────┘ └─────────┘ └───────┬───────┘         │
│              │                              │                  │
│              │        ┌──────────────┐      │                  │
│              └───────►│    TOOLS     │◄─────┘                  │
│                       │ - Search     │                         │
│                       │ - Code       │                         │
│                       │ - Browser    │                         │
│                       │ - Database   │                         │
│                       └──────────────┘                         │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### Step 2: Tool Definition

```typescript
interface Tool {
  name: string;
  description: string;
  parameters: JSONSchema;
  execute: (params: any) => Promise<ToolResult>;
}

const searchTool: Tool = {
  name: 'web_search',
  description: 'Search the web for current information',
  parameters: {
    type: 'object',
    properties: {
      query: { type: 'string', description: 'Search query' }
    },
    required: ['query']
  },
  execute: async ({ query }) => {
    const results = await searchAPI.search(query);
    return { success: true, data: results };
  }
};

const codeExecutorTool: Tool = {
  name: 'run_code',
  description: 'Execute Python code in sandbox',
  parameters: {
    type: 'object',
    properties: {
      code: { type: 'string' },
      language: { type: 'string', enum: ['python', 'javascript'] }
    }
  },
  execute: async ({ code, language }) => {
    return await sandbox.execute(code, language);
  }
};
```

### Step 3: Agent Loop

```typescript
class Agent {
  private tools: Map<string, Tool>;
  private memory: ConversationMemory;
  
  async run(goal: string): Promise<string> {
    const maxIterations = 10;
    let iteration = 0;
    
    while (iteration < maxIterations) {
      // 1. Plan next action
      const action = await this.plan(goal, this.memory.getContext());
      
      // 2. Check if done
      if (action.type === 'finish') {
        return action.result;
      }
      
      // 3. Execute tool
      const tool = this.tools.get(action.toolName);
      const result = await tool.execute(action.params);
      
      // 4. Update memory
      this.memory.add({
        action,
        result,
        timestamp: Date.now()
      });
      
      // 5. Self-evaluate
      const evaluation = await this.evaluate(goal, result);
      if (evaluation.needsCorrection) {
        this.memory.addCorrection(evaluation.feedback);
      }
      
      iteration++;
    }
    
    return 'Max iterations reached';
  }
}
```

### Step 4: Safety Patterns

```typescript
// Permission system
enum Permission {
  READ_FILES,
  WRITE_FILES,
  EXECUTE_CODE,
  WEB_ACCESS,
  DATABASE_WRITE
}

class SafeAgent {
  private permissions: Set<Permission>;
  
  async executeWithApproval(action: Action) {
    const requiredPerms = this.getRequiredPermissions(action);
    
    // Check if pre-approved
    for (const perm of requiredPerms) {
      if (!this.permissions.has(perm)) {
        // Request human approval
        const approved = await this.requestHumanApproval(action);
        if (!approved) {
          throw new Error('Action not approved');
        }
      }
    }
    
    return this.execute(action);
  }
}

// Sandboxing dangerous operations
const sandboxConfig = {
  timeout: 30000,
  memory: '256MB',
  network: false,  // No network access
  filesystem: 'readonly'
};
```

## Best Practices

### ✅ Do This

- ✅ Implement human-in-the-loop for risky actions
- ✅ Set iteration limits
- ✅ Log all agent actions
- ✅ Use sandboxed execution
- ✅ Validate tool outputs

### ❌ Avoid This

- ❌ Don't give unlimited permissions
- ❌ Don't skip output validation
- ❌ Don't run without logging
- ❌ Don't ignore error handling

## Related Skills

- `@senior-ai-agent-developer` - Agent development
- `@ai-wrapper-product` - AI products

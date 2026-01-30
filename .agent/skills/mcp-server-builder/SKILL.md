---
name: mcp-server-builder
description: "Expert MCP server development for AI agent tools and integrations"
---

# MCP Server Builder

## Overview

Build MCP (Model Context Protocol) servers to extend AI agent capabilities.

## When to Use This Skill

- Use when building AI agent tools
- Use when integrating external APIs

## How It Works

### Step 1: Server Structure

```text
my-mcp-server/
├── src/
│   ├── index.ts
│   └── tools/
├── package.json
└── tsconfig.json
```

### Step 2: Basic Server

```typescript
import { Server } from '@modelcontextprotocol/sdk/server/index.js';
import { StdioServerTransport } from '@modelcontextprotocol/sdk/server/stdio.js';

const server = new Server(
  { name: 'my-server', version: '1.0.0' },
  { capabilities: { tools: {} } }
);

// List tools
server.setRequestHandler(ListToolsRequestSchema, async () => ({
  tools: [
    {
      name: 'search',
      description: 'Search records',
      inputSchema: {
        type: 'object',
        properties: {
          query: { type: 'string' }
        },
        required: ['query']
      }
    }
  ]
}));

// Handle tool calls
server.setRequestHandler(CallToolRequestSchema, async (request) => {
  const { name, arguments: args } = request.params;
  
  if (name === 'search') {
    const results = await search(args.query);
    return { content: [{ type: 'text', text: JSON.stringify(results) }] };
  }
});

// Start
const transport = new StdioServerTransport();
await server.connect(transport);
```

### Step 3: Configuration

```json
// ~/.claude/claude_desktop_config.json
{
  "mcpServers": {
    "my-server": {
      "command": "node",
      "args": ["/path/to/dist/index.js"]
    }
  }
}
```

## Best Practices

- ✅ Use descriptive tool names
- ✅ Validate inputs with JSON Schema
- ❌ Don't expose sensitive data
- ❌ Don't block event loop

## Related Skills

- `@senior-typescript-developer`
- `@senior-ai-agent-developer`

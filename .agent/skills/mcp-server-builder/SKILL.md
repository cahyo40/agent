---
name: mcp-server-builder
description: "Expert MCP server development for AI agent tools and integrations"
---

# MCP Server Builder

## Overview

This skill transforms you into an **MCP Server Developer**. You will master **Model Context Protocol**, **Tool Building**, **Resource Providers**, and **Server Architecture** for extending AI agent capabilities.

## When to Use This Skill

- Use when building custom tools for AI assistants
- Use when integrating external APIs as agent tools
- Use when creating resource providers
- Use when extending agent functionality
- Use when building multi-server architectures

---

## Part 1: MCP Fundamentals

### 1.1 What is MCP?

Model Context Protocol (MCP) is a standard for connecting AI assistants to external tools and data sources.

### 1.2 Core Concepts

| Concept | Description |
|---------|-------------|
| **Server** | Provides tools, resources, prompts to clients |
| **Client** | AI assistant consuming MCP servers |
| **Tool** | Callable function with parameters |
| **Resource** | Data source (files, APIs, databases) |
| **Prompt** | Reusable prompt template |

### 1.3 Communication

- **Transport**: stdio, HTTP, WebSocket.
- **Protocol**: JSON-RPC 2.0.

---

## Part 2: Server Structure (TypeScript)

### 2.1 Basic Server

```typescript
import { Server } from "@modelcontextprotocol/sdk/server/index.js";
import { StdioServerTransport } from "@modelcontextprotocol/sdk/server/stdio.js";

const server = new Server(
  {
    name: "my-mcp-server",
    version: "1.0.0",
  },
  {
    capabilities: {
      tools: {},
      resources: {},
    },
  }
);

// Start server
const transport = new StdioServerTransport();
await server.connect(transport);
```

### 2.2 Tool Definition

```typescript
server.setRequestHandler(ListToolsRequestSchema, async () => {
  return {
    tools: [
      {
        name: "get_weather",
        description: "Get current weather for a location",
        inputSchema: {
          type: "object",
          properties: {
            location: {
              type: "string",
              description: "City name or zip code",
            },
          },
          required: ["location"],
        },
      },
    ],
  };
});
```

### 2.3 Tool Handler

```typescript
server.setRequestHandler(CallToolRequestSchema, async (request) => {
  if (request.params.name === "get_weather") {
    const location = request.params.arguments?.location;
    const weather = await fetchWeather(location);
    
    return {
      content: [
        {
          type: "text",
          text: JSON.stringify(weather),
        },
      ],
    };
  }
  
  throw new Error(`Unknown tool: ${request.params.name}`);
});
```

---

## Part 3: Python Server

### 3.1 Basic Python Server

```python
from mcp.server import Server
from mcp.server.stdio import stdio_server
import mcp.types as types

server = Server("my-python-server")

@server.list_tools()
async def list_tools() -> list[types.Tool]:
    return [
        types.Tool(
            name="search_database",
            description="Search the internal database",
            inputSchema={
                "type": "object",
                "properties": {
                    "query": {"type": "string"},
                },
                "required": ["query"],
            },
        )
    ]

@server.call_tool()
async def call_tool(name: str, arguments: dict) -> list[types.TextContent]:
    if name == "search_database":
        result = await search_db(arguments["query"])
        return [types.TextContent(type="text", text=result)]
    
    raise ValueError(f"Unknown tool: {name}")

async def main():
    async with stdio_server() as (read_stream, write_stream):
        await server.run(read_stream, write_stream)
```

---

## Part 4: Resources

### 4.1 Resource Provider

```typescript
server.setRequestHandler(ListResourcesRequestSchema, async () => {
  return {
    resources: [
      {
        uri: "file:///config.json",
        name: "Configuration",
        mimeType: "application/json",
      },
    ],
  };
});

server.setRequestHandler(ReadResourceRequestSchema, async (request) => {
  const content = await fs.readFile(request.params.uri.replace("file://", ""), "utf-8");
  
  return {
    contents: [
      {
        uri: request.params.uri,
        mimeType: "application/json",
        text: content,
      },
    ],
  };
});
```

---

## Part 5: Best Practices

### 5.1 Tool Design

| Principle | Description |
|-----------|-------------|
| **Single Responsibility** | One tool, one purpose |
| **Clear Descriptions** | AI needs to know when to use it |
| **Typed Parameters** | Use JSON Schema properly |
| **Graceful Errors** | Return helpful error messages |

### 5.2 Security

- **Validate All Input**: Never trust tool arguments.
- **Scope Permissions**: Only access what's needed.
- **Rate Limiting**: Prevent abuse.
- **Logging**: Audit all tool calls.

---

## Part 6: Deployment

### 6.1 Configuration

```json
{
  "mcpServers": {
    "my-server": {
      "command": "node",
      "args": ["dist/server.js"],
      "env": {
        "API_KEY": "..."
      }
    }
  }
}
```

### 6.2 HTTP Server (Alternative)

```typescript
import { SSEServerTransport } from "@modelcontextprotocol/sdk/server/sse.js";
import express from "express";

const app = express();

app.get("/sse", async (req, res) => {
  const transport = new SSEServerTransport("/message", res);
  await server.connect(transport);
});

app.listen(3000);
```

---

## Part 7: Best Practices Checklist

### ✅ Do This

- ✅ **Version Your Server**: Semantic versioning.
- ✅ **Test Thoroughly**: Unit tests for all tools.
- ✅ **Document Tools**: Clear descriptions and examples.

### ❌ Avoid This

- ❌ **Blocking Operations**: Use async for I/O.
- ❌ **Silent Failures**: Always return meaningful errors.
- ❌ **Hardcoded Secrets**: Use environment variables.

---

## Related Skills

- `@senior-ai-agent-developer` - Agent architecture
- `@senior-typescript-developer` - TypeScript patterns
- `@senior-python-developer` - Python patterns

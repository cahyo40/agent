---
name: senior-ai-agent-developer
description: "Expert AI agent development including autonomous agents, tool use, multi-agent systems, and LLM orchestration frameworks"
---

# Senior AI Agent Developer

## Overview

This skill transforms you into an experienced AI Agent Developer who builds autonomous AI systems. You'll design agent architectures, implement tool use, orchestrate multi-agent systems, and leverage frameworks like LangChain and LangGraph.

## When to Use This Skill

- Use when building AI agents with tool use
- Use when implementing RAG systems
- Use when orchestrating multi-agent workflows
- Use when integrating LLMs with external systems
- Use when the user asks about autonomous AI

## How It Works

### Step 1: Agent Architecture

```
AGENT ARCHITECTURE PATTERNS
┌─────────────────────────────────────────────────────────────────┐
│                                                                 │
│  REACT PATTERN (Reasoning + Acting)                            │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │   Observe → Think → Act → Observe → Think → Act → ...    │  │
│  └──────────────────────────────────────────────────────────┘  │
│                                                                 │
│  PLAN-AND-EXECUTE                                              │
│  ┌──────────┐    ┌──────────┐    ┌──────────┐                 │
│  │  Plan    │───▶│ Execute  │───▶│ Replan   │                 │
│  │  Steps   │    │  Step    │    │ if needed│                 │
│  └──────────┘    └──────────┘    └──────────┘                 │
│                                                                 │
│  MULTI-AGENT                                                    │
│       ┌─────────────┐                                          │
│       │ Supervisor  │                                          │
│       └──────┬──────┘                                          │
│     ┌────────┼────────┐                                        │
│     ▼        ▼        ▼                                        │
│  ┌─────┐  ┌─────┐  ┌─────┐                                     │
│  │Agent│  │Agent│  │Agent│                                     │
│  │  A  │  │  B  │  │  C  │                                     │
│  └─────┘  └─────┘  └─────┘                                     │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### Step 2: Tool Definition

```python
from langchain.tools import tool
from pydantic import BaseModel, Field

class SearchInput(BaseModel):
    query: str = Field(description="The search query")

@tool("web_search", args_schema=SearchInput)
def web_search(query: str) -> str:
    """Search the web for current information."""
    # Implementation
    results = search_api.search(query)
    return format_results(results)

@tool
def calculate(expression: str) -> str:
    """Evaluate a mathematical expression."""
    try:
        result = eval(expression)  # Use safe eval in production
        return str(result)
    except Exception as e:
        return f"Error: {e}"

@tool
def get_weather(location: str) -> str:
    """Get current weather for a location."""
    data = weather_api.get(location)
    return f"Weather in {location}: {data['temp']}°C, {data['condition']}"
```

### Step 3: RAG Implementation

```python
from langchain_openai import OpenAIEmbeddings, ChatOpenAI
from langchain_community.vectorstores import Chroma
from langchain.text_splitter import RecursiveCharacterTextSplitter
from langchain.chains import RetrievalQA

# 1. Load and split documents
text_splitter = RecursiveCharacterTextSplitter(
    chunk_size=1000,
    chunk_overlap=200
)
documents = text_splitter.split_documents(raw_docs)

# 2. Create vector store
embeddings = OpenAIEmbeddings()
vectorstore = Chroma.from_documents(
    documents=documents,
    embedding=embeddings,
    persist_directory="./chroma_db"
)

# 3. Create retriever
retriever = vectorstore.as_retriever(
    search_type="mmr",
    search_kwargs={"k": 5, "fetch_k": 10}
)

# 4. Create RAG chain
llm = ChatOpenAI(model="gpt-4", temperature=0)
qa_chain = RetrievalQA.from_chain_type(
    llm=llm,
    chain_type="stuff",
    retriever=retriever,
    return_source_documents=True
)

# Usage
response = qa_chain.invoke({"query": "What is the refund policy?"})
```

### Step 4: LangGraph Agent

```python
from langgraph.graph import StateGraph, END
from typing import TypedDict, Annotated
import operator

class AgentState(TypedDict):
    messages: Annotated[list, operator.add]
    next_action: str

def should_continue(state: AgentState) -> str:
    last_message = state["messages"][-1]
    if "FINAL ANSWER" in last_message.content:
        return "end"
    return "continue"

def call_model(state: AgentState) -> AgentState:
    response = llm.invoke(state["messages"])
    return {"messages": [response]}

def call_tool(state: AgentState) -> AgentState:
    # Parse and execute tool
    tool_result = execute_tool(state["messages"][-1])
    return {"messages": [tool_result]}

# Build graph
workflow = StateGraph(AgentState)
workflow.add_node("agent", call_model)
workflow.add_node("tools", call_tool)

workflow.set_entry_point("agent")
workflow.add_conditional_edges(
    "agent",
    should_continue,
    {"continue": "tools", "end": END}
)
workflow.add_edge("tools", "agent")

app = workflow.compile()
```

## Examples

### Example 1: Research Agent

```python
from langchain.agents import create_react_agent, AgentExecutor
from langchain import hub

# Load ReAct prompt
prompt = hub.pull("hwchase17/react")

# Create tools
tools = [web_search, wikipedia_search, calculator]

# Create agent
agent = create_react_agent(llm, tools, prompt)
agent_executor = AgentExecutor(
    agent=agent,
    tools=tools,
    verbose=True,
    max_iterations=10,
    handle_parsing_errors=True
)

# Run
result = agent_executor.invoke({
    "input": "What is the current GDP of Indonesia and how does it compare to 2020?"
})
```

### Example 2: Multi-Agent System

```python
# Supervisor routes to specialized agents
agents = {
    "researcher": research_agent,
    "writer": writer_agent,
    "reviewer": reviewer_agent
}

def supervisor(state):
    # Determine which agent to call
    response = llm.invoke(
        f"Given the task: {state['task']}, which agent should handle this? "
        f"Options: {list(agents.keys())}"
    )
    return {"next_agent": response.content}

def run_agent(state):
    agent = agents[state["next_agent"]]
    result = agent.invoke(state["task"])
    return {"result": result}
```

## Best Practices

### ✅ Do This

- ✅ Define clear tool descriptions (LLM reads them)
- ✅ Implement error handling in tools
- ✅ Set max iterations to prevent infinite loops
- ✅ Use structured outputs when possible
- ✅ Log agent reasoning for debugging
- ✅ Implement human-in-the-loop for critical actions

### ❌ Avoid This

- ❌ Don't give agents access to destructive tools without safeguards
- ❌ Don't skip input validation
- ❌ Don't ignore token limits
- ❌ Don't build agents for simple tasks (use chains)

## Common Pitfalls

**Problem:** Agent gets stuck in loops
**Solution:** Set max_iterations, add "give up" instruction in prompt.

**Problem:** Tool selection errors
**Solution:** Improve tool descriptions, add examples in prompt.

**Problem:** Hallucinated tool calls
**Solution:** Use structured output, validate tool names before execution.

## Tools & Frameworks

| Framework | Use Case |
|-----------|----------|
| LangChain | General agent framework |
| LangGraph | Stateful, graph-based workflows |
| CrewAI | Multi-agent orchestration |
| AutoGen | Conversational agents |
| Semantic Kernel | Enterprise integration |

## Related Skills

- `@senior-ai-ml-engineer` - For model training
- `@senior-prompt-engineer` - For prompt design
- `@senior-backend-developer` - For API integration

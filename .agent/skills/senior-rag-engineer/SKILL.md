---
name: senior-rag-engineer
description: "Expert RAG system engineering including vector databases, embeddings, chunking strategies, retrieval optimization, and production RAG pipelines"
---

# Senior RAG Engineer

## Overview

This skill transforms you into an experienced RAG (Retrieval-Augmented Generation) Engineer who builds production-ready knowledge systems. You'll design embedding pipelines, optimize retrieval, implement advanced chunking, and deploy scalable RAG applications.

## When to Use This Skill

- Use when building knowledge-based AI systems
- Use when implementing document Q&A
- Use when optimizing retrieval accuracy
- Use when working with vector databases
- Use when the user asks about RAG patterns

## How It Works

### Step 1: RAG Architecture

```
RAG PIPELINE
┌─────────────────────────────────────────────────────────────────┐
│                                                                 │
│  INDEXING PHASE                                                 │
│  ┌─────────┐    ┌─────────┐    ┌─────────┐    ┌─────────┐     │
│  │ Ingest  │───▶│  Chunk  │───▶│  Embed  │───▶│  Store  │     │
│  │Documents│    │  Text   │    │ Vectors │    │ VectorDB│     │
│  └─────────┘    └─────────┘    └─────────┘    └─────────┘     │
│                                                                 │
│  QUERY PHASE                                                    │
│  ┌─────────┐    ┌─────────┐    ┌─────────┐    ┌─────────┐     │
│  │  Query  │───▶│  Embed  │───▶│ Retrieve│───▶│ Rerank  │     │
│  │         │    │  Query  │    │Top-K    │    │         │     │
│  └─────────┘    └─────────┘    └─────────┘    └────┬────┘     │
│                                                     │          │
│                                                     ▼          │
│  GENERATION PHASE                              ┌─────────┐     │
│                                                │   LLM   │     │
│                                                │Generate │     │
│                                                └─────────┘     │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### Step 2: Chunking Strategies

```python
from langchain.text_splitter import (
    RecursiveCharacterTextSplitter,
    MarkdownHeaderTextSplitter,
    SentenceTransformersTokenTextSplitter
)

# 1. Recursive Character Splitting (most common)
splitter = RecursiveCharacterTextSplitter(
    chunk_size=1000,
    chunk_overlap=200,
    separators=["\n\n", "\n", ". ", " ", ""]
)

# 2. Semantic Chunking (better for meaning)
from semantic_chunkers import SemanticChunker

chunker = SemanticChunker(
    embedding_model=embeddings,
    breakpoint_threshold_type="percentile",
    breakpoint_threshold_amount=95
)

# 3. Document-Aware Chunking
markdown_splitter = MarkdownHeaderTextSplitter(
    headers_to_split_on=[
        ("#", "Header 1"),
        ("##", "Header 2"),
        ("###", "Header 3"),
    ]
)

# 4. Parent-Child Chunking (for context)
parent_splitter = RecursiveCharacterTextSplitter(chunk_size=2000)
child_splitter = RecursiveCharacterTextSplitter(chunk_size=400)

# Store child chunks, retrieve parent for context
```

### Step 3: Embedding Models

```python
from sentence_transformers import SentenceTransformer
from langchain_openai import OpenAIEmbeddings

# Open Source (Local)
model = SentenceTransformer("BAAI/bge-large-en-v1.5")
embeddings = model.encode(["text to embed"])

# OpenAI
embeddings = OpenAIEmbeddings(model="text-embedding-3-large")

# Cohere
from langchain_cohere import CohereEmbeddings
embeddings = CohereEmbeddings(model="embed-english-v3.0")

# EMBEDDING MODEL COMPARISON
# ┌────────────────────────┬──────────┬───────────┬─────────┐
# │ Model                  │ Dims     │ Cost      │ Quality │
# ├────────────────────────┼──────────┼───────────┼─────────┤
# │ text-embedding-3-large │ 3072     │ $$        │ ⭐⭐⭐⭐⭐ │
# │ text-embedding-3-small │ 1536     │ $         │ ⭐⭐⭐⭐   │
# │ bge-large-en-v1.5      │ 1024     │ Free      │ ⭐⭐⭐⭐   │
# │ all-MiniLM-L6-v2       │ 384      │ Free      │ ⭐⭐⭐    │
# └────────────────────────┴──────────┴───────────┴─────────┘
```

### Step 4: Vector Database Setup

```python
# Chroma (Local, simple)
from langchain_chroma import Chroma

vectorstore = Chroma.from_documents(
    documents=chunks,
    embedding=embeddings,
    persist_directory="./chroma_db"
)

# Pinecone (Cloud, scalable)
from pinecone import Pinecone
from langchain_pinecone import PineconeVectorStore

pc = Pinecone(api_key="...")
index = pc.Index("my-index")

vectorstore = PineconeVectorStore(
    index=index,
    embedding=embeddings,
    text_key="text"
)

# Qdrant (Self-hosted, performant)
from langchain_qdrant import QdrantVectorStore
from qdrant_client import QdrantClient

client = QdrantClient(url="http://localhost:6333")
vectorstore = QdrantVectorStore(
    client=client,
    collection_name="documents",
    embedding=embeddings
)
```

### Step 5: Advanced Retrieval

```python
# Hybrid Search (Dense + Sparse)
from langchain.retrievers import EnsembleRetriever
from langchain_community.retrievers import BM25Retriever

bm25_retriever = BM25Retriever.from_documents(documents)
dense_retriever = vectorstore.as_retriever(search_kwargs={"k": 5})

ensemble = EnsembleRetriever(
    retrievers=[bm25_retriever, dense_retriever],
    weights=[0.3, 0.7]
)

# Reranking
from langchain.retrievers import ContextualCompressionRetriever
from langchain_cohere import CohereRerank

reranker = CohereRerank(model="rerank-english-v3.0", top_n=5)
retriever = ContextualCompressionRetriever(
    base_compressor=reranker,
    base_retriever=vectorstore.as_retriever(search_kwargs={"k": 20})
)

# Multi-Query Retrieval
from langchain.retrievers import MultiQueryRetriever

retriever = MultiQueryRetriever.from_llm(
    retriever=vectorstore.as_retriever(),
    llm=llm
)
```

## Examples

### Example 1: Production RAG Pipeline

```python
from langchain_openai import ChatOpenAI, OpenAIEmbeddings
from langchain_core.prompts import ChatPromptTemplate
from langchain_core.output_parsers import StrOutputParser
from langchain_core.runnables import RunnablePassthrough

# Components
embeddings = OpenAIEmbeddings(model="text-embedding-3-small")
llm = ChatOpenAI(model="gpt-4", temperature=0)

# RAG Prompt
template = """Answer based only on the following context:

{context}

Question: {question}

If you cannot answer from the context, say "I don't have enough information."
"""
prompt = ChatPromptTemplate.from_template(template)

# Build chain
def format_docs(docs):
    return "\n\n".join(doc.page_content for doc in docs)

rag_chain = (
    {"context": retriever | format_docs, "question": RunnablePassthrough()}
    | prompt
    | llm
    | StrOutputParser()
)

# Query
answer = rag_chain.invoke("What is the refund policy?")
```

### Example 2: Evaluation

```python
from ragas import evaluate
from ragas.metrics import (
    faithfulness,
    answer_relevancy,
    context_precision,
    context_recall
)

# Evaluate RAG quality
results = evaluate(
    dataset=eval_dataset,
    metrics=[
        faithfulness,        # Is answer grounded in context?
        answer_relevancy,    # Is answer relevant to question?
        context_precision,   # Are retrieved docs relevant?
        context_recall       # Did we retrieve all needed info?
    ]
)
```

## Best Practices

### ✅ Do This

- ✅ Use appropriate chunk sizes (500-1000 tokens)
- ✅ Add metadata to chunks for filtering
- ✅ Implement reranking for better precision
- ✅ Use hybrid search (dense + sparse)
- ✅ Evaluate with RAGAS or similar
- ✅ Handle "I don't know" gracefully

### ❌ Avoid This

- ❌ Don't use chunks too small or too large
- ❌ Don't skip overlap between chunks
- ❌ Don't ignore document structure
- ❌ Don't trust retrieval without evaluation

## Common Pitfalls

**Problem:** Poor retrieval quality
**Solution:** Add reranking, use hybrid search, tune chunk size.

**Problem:** Hallucinations despite RAG
**Solution:** Better prompting, cite sources, add verification.

**Problem:** Slow retrieval at scale
**Solution:** Use approximate search (HNSW), filter with metadata.

## Related Skills

- `@senior-ai-agent-developer` - For agentic RAG
- `@senior-ai-ml-engineer` - For fine-tuning
- `@senior-prompt-engineer` - For RAG prompts

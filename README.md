# 🚀 Antigravity AI Agent Skills

<div align="center">

![Skills](https://img.shields.io/badge/Skills-230-blue?style=for-the-badge)
![Version](https://img.shields.io/badge/Version-5.2.0-green?style=for-the-badge)
![License](https://img.shields.io/badge/License-MIT-yellow?style=for-the-badge)

**Koleksi 230+ skills untuk memperluas kemampuan AI Agent**

[📖 Documentation](./docs/SKILLS_DOCUMENTATION.md) · [🗺️ Roadmap](./docs/ROADMAP.md) · [🐛 Report Bug](../../issues)

</div>

---

## ✨ Features

- 🤖 **230 Specialized Skills** - Dari Flutter hingga AI/ML
- 🎯 **Auto-Activated** - Skills aktif berdasarkan konteks
- 🔗 **Combinable** - Gabungkan beberapa skills sekaligus
- 📚 **Best Practices** - Setiap skill berisi industry best practices
- 🆓 **Open Source** - Gratis, MIT licensed

---

## 📥 Installation

### Method 1: Clone Repository

```bash
git clone https://github.com/cahyo40/agent.git
cd agent
```

### Method 2: Download ZIP

1. Klik tombol **Code** di atas
2. Pilih **Download ZIP**
3. Extract ke folder project Anda

### Method 3: Clone Only `.agent` Folder (Sparse Checkout)

```bash
# Buat folder dan init git
mkdir my-skills && cd my-skills
git init
git remote add origin https://github.com/cahyo40/agent.git

# Enable sparse checkout
git sparse-checkout init --cone
git sparse-checkout set .agent

# Pull hanya folder .agent
git pull origin main
```

### Method 4: Copy Specific Skill

```bash
# Download skill tertentu langsung
curl -O https://raw.githubusercontent.com/cahyo40/agent/main/.agent/skills/senior-flutter-developer/SKILL.md
```

### Setup di Project Anda

Copy folder `.agent/skills/` ke root project Anda:

```
your-project/
├── .agent/
│   └── skills/
│       ├── senior-flutter-developer/
│       ├── senior-react-developer/
│       └── ...
└── your-code/
```

---

## 🏆 Skills Categories

| Category | Count | Highlights |
|----------|-------|------------|
| 🤖 AI & Machine Learning | 15 | LLM, RAG, agents, CV, OCR |
| 🔧 Backend Development | 26 | Python, Go, Rust, PHP, Elixir, C++ |
| 📱 Mobile Development | 14 | Flutter, iOS, Android, Riverpod, GetX |
| 🎨 Frontend Development | 14 | React, Vue, Next.js, Svelte, Astro |
| 🎨 UI/UX & Design | 14 | Figma, design systems |
| ☁️ Cloud & DevOps | 15 | AWS, K8s, Terraform, Ansible |
| 💾 Data & Databases | 16 | ETL, MongoDB, PostgreSQL, Big Data |
| 🔐 Security | 6 | OWASP, pen testing, DevSecOps |
| 🧪 Testing & QA | 6 | E2E, TDD, API, performance testing |
| 📝 Content Creation | 16 | Video, podcasts, blogs, social |
| 📊 Marketing & Business | 12 | SEO, copywriting, growth |
| 📝 Documentation | 7 | Technical writing, Architecture |
| 💼 Industry Apps | 12 | Healthcare, trading, food delivery |
| 🎮 Desktop & Games | 7 | Unreal, Godot, Unity, Roblox |
| 🔮 Emerging Tech | 8 | VR/AR, quantum, Web3, GIS |
| 💬 Bots & Automation | 7 | Discord, Telegram, WhatsApp |
| 🎞️ Media Processing | 2 | Audio & Video engineering |
| 📚 Others | 33 | Various specialized |

---

## 🚀 Quick Start

### Method 1: Direct Mention

```
@senior-flutter-developer buatkan widget login screen

@short-form-video-creator buat strategi konten TikTok

@senior-ai-agent-developer buat AI agent dengan tools
```

### Method 2: Combine Skills

```
@script-writer @thumbnail-designer 
buatkan script dan ide thumbnail untuk video YouTube
```

---

## 📖 Popular Skills

### Development

- `@senior-flutter-developer` - Flutter app development
- `@senior-react-developer` - React.js applications
- `@senior-python-developer` - Python/FastAPI backend
- `@senior-nextjs-developer` - Next.js full-stack

### AI & Automation

- `@senior-ai-agent-developer` - Build AI agents
- `@senior-rag-engineer` - RAG pipelines
- `@mcp-server-builder` - MCP server tools
- `@chatbot-developer` - Conversational AI

### Content Creation

- `@short-form-video-creator` - TikTok, Reels, Shorts
- `@video-editor-automation` - FFmpeg automation
- `@content-repurposer` - 1 content → 10 formats
- `@copywriting` - Marketing copy

### Business

- `@e-commerce-developer` - Online stores
- `@saas-product-developer` - SaaS applications
- `@payment-integration-specialist` - Stripe, payments
- `@crm-developer` - Customer management

---

## 📁 Repository Structure

```text
agents/
├── .agent/
│   └── skills/          # 209 skill folders
│       ├── senior-flutter-developer/
│       │   └── SKILL.md
│       ├── senior-react-developer/
│       │   └── SKILL.md
│       └── ...
├── docs/
│   ├── SKILLS_DOCUMENTATION.md
│   └── ROADMAP.md
├── README.md
└── LICENSE
```

---

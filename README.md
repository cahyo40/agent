# 🚀 Antigravity AI Agent Skills

<div align="center">

![Skills](https://img.shields.io/badge/Skills-156-blue?style=for-the-badge)
![Version](https://img.shields.io/badge/Version-4.0.0-green?style=for-the-badge)
![License](https://img.shields.io/badge/License-MIT-yellow?style=for-the-badge)

**Koleksi 156+ skills untuk memperluas kemampuan AI Agent**

[📖 Documentation](./docs/SKILLS_DOCUMENTATION.md) · [🗺️ Roadmap](./docs/ROADMAP.md) · [🐛 Report Bug](../../issues)

</div>

---

## ✨ Features

- 🤖 **156 Specialized Skills** - Dari Flutter hingga AI/ML
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
| 🤖 AI & Machine Learning | 10 | LLM, RAG, agents, edge AI |
| 🔧 Backend Development | 13 | Python, Go, Node.js, GraphQL |
| 📱 Mobile Development | 10 | Flutter, iOS, Android |
| 🎨 Frontend Development | 11 | React, Vue, Next.js |
| 🎨 UI/UX & Design | 14 | Figma, design systems |
| ☁️ Cloud & DevOps | 7 | AWS, K8s, CI/CD |
| 💾 Data Engineering | 8 | ETL, analytics, databases |
| 🔐 Security | 4 | Cybersecurity, pen testing |
| 🧪 Testing & QA | 4 | E2E, TDD, API testing |
| 📝 Content Creation | 14 | Video, podcasts, blogs |
| 📊 Marketing & Business | 10 | SEO, copywriting |
| 📝 Documentation | 6 | Technical writing |
| 💼 Business Systems | 10 | E-commerce, CRM, POS |
| 💬 Bots & Automation | 7 | Discord, Telegram, WhatsApp |
| 🎮 Desktop & Games | 4 | Electron, Unity, Roblox |
| 🔮 Emerging Tech | 6 | VR/AR, quantum, Web3, dApp |
| 📚 Others | 16 | Various specialized |

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

```
agents/
├── .agent/
│   └── skills/          # 156 skill folders
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

## 🤝 Contributing

Contributions are welcome! Please read our contributing guidelines.

### Adding a New Skill

1. Create folder: `.agent/skills/your-skill-name/`
2. Create `SKILL.md` following the template
3. Update `docs/SKILLS_DOCUMENTATION.md`
4. Submit PR

---

## 📜 License

MIT © 2026 Antigravity AI Agent Skills

---

<div align="center">

**Made with ❤️ by the Antigravity team**

⭐ Star this repo if you find it useful!

</div>

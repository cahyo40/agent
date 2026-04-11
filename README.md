# 🚀 Antigravity AI Agent Skills

<div align="center">

![Skills](https://img.shields.io/badge/Skills-282-blue?style=for-the-badge)
![Workflows](https://img.shields.io/badge/Workflows-13_Collections-purple?style=for-the-badge)
![Version](https://img.shields.io/badge/Version-6.21.0-green?style=for-the-badge)
![License](https://img.shields.io/badge/License-MIT-yellow?style=for-the-badge)

**Koleksi 282 skills + 13 workflow collections untuk memperluas kemampuan AI Agent**

[📖 Documentation](./docs/SKILLS_DOCUMENTATION.md) · [🗺️ Roadmap](./docs/ROADMAP.md) · [🐛 Report Bug](../../issues)

</div>

---

## ✨ Features

- 🤖 **282 Specialized Skills** - Dari Flutter hingga AI/ML
- 📋 **13 Workflow Collections** - Step-by-step guides untuk Flutter, Next.js, Nuxt, Go, Python, UI/UX, SDLC
- ⚡ **Slash Commands** - Akses workflow langsung via `/workflow-name`
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

## 🔄 Use on Existing Projects

Skills dapat langsung digunakan pada project yang sudah ada:

### Step 1: Copy Folder `.agent`

```bash
# Clone repo skills
git clone https://github.com/cahyo40/agent.git temp-skills

# Copy ke project Anda
cp -r temp-skills/.agent /path/to/your-project/

# Cleanup
rm -rf temp-skills
```

### Step 2: Struktur Akhir

```text
your-existing-project/
├── .agent/
│   └── skills/           ← Skills folder (baru)
│       ├── senior-flutter-developer/
│       └── ...
├── lib/                  ← Code Anda (existing)
├── src/                  ← Code Anda (existing)
└── package.json          ← Config Anda (existing)
```

### Tips

- ✅ Skills tidak mengubah code Anda sama sekali
- ✅ Folder `.agent` bisa di-gitignore jika tidak ingin di-commit
- ✅ Update skills dengan `git pull` di folder temp lalu copy ulang

---

## 🤖 Use with Other AI Models

Skills ini kompatibel dengan berbagai AI coding assistants:

| Platform | Folder Target | Cara Pakai |
|----------|---------------|------------|
| **Gemini (Antigravity)** | `.agent/skills/` | Native support ✅ |
| **Claude Code** | `.claude/skills/` | Rename folder `.agent` → `.claude` |
| **Cursor IDE** | `.cursor/skills/` | Rename folder `.agent` → `.cursor` |
| **OpenCode CLI** | `.opencode/skills/` | Rename folder `.agent` → `.opencode` |
| **ChatGPT** | Custom Instructions | Copy isi SKILL.md ke System Prompt |
| **Cline (VSCode)** | `.cline/skills/` | Rename folder `.agent` → `.cline` |

### Contoh: Setup untuk Claude Code

```bash
# Clone dan rename
git clone https://github.com/cahyo40/agent.git temp-skills
mv temp-skills/.agent temp-skills/.claude
cp -r temp-skills/.claude /path/to/your-project/
rm -rf temp-skills
```

### Contoh: Setup untuk ChatGPT

1. Buka skill yang diinginkan (misal `senior-flutter-developer/SKILL.md`)
2. Copy seluruh isi file
3. Paste ke **Custom Instructions** atau **System Prompt** di ChatGPT
4. AI akan mengikuti instruksi skill tersebut

> 💡 **Tip**: Untuk ChatGPT, pilih 1-3 skills yang paling relevan karena ada batasan karakter.

## 🏆 Skills Categories

| Category | Count | Highlights |
|----------|-------|------------|
| 🤖 AI & Machine Learning | 22 | LLM, RAG, agents, fine-tuning, LLM Security, LLMOps |
| 🔧 Backend Development | 27 | Python, Go, NestJS, Rust, PHP, Elixir |
| 📱 Mobile Development | 15 | Flutter, iOS, Android, Desktop, Riverpod |
| 🎨 Frontend Development | 17 | React, Vue, Next.js, Svelte, Astro, 3D, Web3 |
| 🎨 UI/UX & Design | 12 | Figma, design systems, mobile app design |
| ☁️ Cloud & DevOps | 18 | AWS, K8s, Terraform, Chaos Eng, Observability |
| 💾 Data & Databases | 17 | ETL, MongoDB, PostgreSQL, Big Data, Search |
| 🔐 Security | 14 | Pen testing, Bug Bounty, CTF, Red Team, Security Testing |
| 🧪 Testing & QA | 7 | E2E, TDD, API, performance testing, QA Engineering |
| 📝 Documentation | 8 | Technical writing, Architecture, API docs |
| 💼 Industry Apps | 40 | Healthcare, Trading, ERP, Fleet, Ride-Hailing, Dating, Social |
| 🎮 Desktop & Games | 11 | Unreal, Godot, Unity Pro, DeFi Gaming |
| 🔮 Emerging Tech | 11 | VR/AR, Quantum, Web3, Biometrics, Digital Human |
| 💬 Bots & Automation | 7 | Discord, Telegram, WhatsApp |
| 🎞️ Media Processing | 2 | Video engineering |
| 🏗️ Industrial Tech | 3 | IIoT, SCADA, Edge Infra |
| ⛓️ Web3 & Blockchain | 5 | Smart contracts, NFT, DAO, dApps |
| 📚 Others | 64 | Various specialized |

---

## 🚀 Quick Start

### Method 1: Direct Mention

```
@senior-flutter-developer buatkan widget login screen

@video-editor-automation buat script edit video

@senior-ai-agent-developer buat AI agent dengan tools
```

### Method 2: Combine Skills

```
@senior-flutter-developer @figma-specialist
implementasi design dari Figma ke Flutter code
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
- `@llm-ops-engineer` - LLM deployment, monitoring, evaluation
- `@mcp-server-builder` - MCP server tools
- `@chatbot-developer` - Conversational AI

### Web3 & Blockchain

- `@web3-frontend-specialist` - wagmi, viem, RainbowKit dApps
- `@smart-contract-developer` - Solidity, Foundry, security patterns
- `@nft-developer` - ERC-721, ERC-1155, NFT marketplaces
- `@dao-developer` - Governance contracts, voting mechanisms

### Business & Industry

- `@e-commerce-developer` - Online stores
- `@saas-product-developer` - SaaS applications
- `@indonesia-payment-integration` - Midtrans, Xendit, GoPay, OVO
- `@ride-hailing-developer` - Gojek/Grab style apps

---

## 📋 Workflows

Workflows adalah panduan step-by-step untuk development project dari awal hingga production. Tersedia di folder `workflows/` dan dapat diakses via **slash commands**.

### Cara Penggunaan

```text
# Dari chat, ketik slash command:
/01_project_setup
/02_feature_maker
/03_backend_integration

# Atau mention langsung:
"Ikuti workflow 01_project_setup untuk buat project Flutter baru"
```

### Daftar Workflow Collections

| Workflow | Files | Deskripsi |
|----------|-------|-----------|
| `flutter-bloc` | 15 | Flutter + BLoC + get_it + injectable |
| `flutter-getx` | 15 | Flutter + GetX (all-in-one, no code gen) |
| `flutter-riverpod` | 15 | Flutter + Riverpod + Clean Architecture |
| `flutter-ui-kit` | 9 | 📋 Flutter UI Kit planning — PRD, UI/UX, technical spec, components, GTM, roadmap |
| `flutter-ui-kit-vibe` | 8 | ⚡ Flutter UI Kit execution — init, add component/theme/locale, quality check, publish |
| `golang-backend` | 12 | Go + Gin/Fiber + GORM + Clean Architecture |
| `learning-material-maker` | 6 | 📚 Learning material generator — brainstorming, roadmap, materi, output, review |
| `nextjs-frontend` | 15 | Next.js 14 + TypeScript + Tailwind + Shadcn |
| `nuxt-frontend` | 14 | Nuxt 3 + TypeScript + Tailwind + Shadcn-vue |
| `python-backend` | 14 | Python + FastAPI + SQLAlchemy + Alembic |
| `sdlc-maker` | 11 | SDLC documentation generator |
| `ui-ux-generator` | 10 | 🎨 Design-to-code pipeline — referensi → evaluasi → design system → Stitch → code |
| `vibe-coding-toolkit` | 8 | ⚡ Vibe coding toolkit — rules, design, AI instructions, checklist, architecture |

### Setiap Flutter Workflow Mencakup:
- Project setup, feature generator, backend integration (REST/Firebase/Supabase)
- Advanced state management, offline storage, reusable UI components
- Push notifications, testing, performance monitoring (Sentry + Crashlytics), deployment

---

## 📁 Repository Structure

```text
agents/
├── .agent/
│   ├── skills/           # 280 skill folders
│   │   ├── senior-flutter-developer/
│   │   ├── senior-react-developer/
│   │   └── ...
│   └── workflows/        # Symlink → workflows/ (slash command discovery)
├── workflows/
│   ├── flutter-bloc/              # Flutter + BLoC workflows
│   ├── flutter-getx/              # Flutter + GetX workflows
│   ├── flutter-riverpod/          # Flutter + Riverpod workflows
│   ├── flutter-ui-kit/            # UI Kit planning (PRD → Roadmap)
│   ├── flutter-ui-kit-vibe/       # UI Kit execution (init → publish)
│   ├── golang-backend/            # Go backend workflows
│   ├── learning-material-maker/   # Learning material generator
│   ├── nextjs-frontend/           # Next.js frontend workflows
│   ├── nuxt-frontend/             # Nuxt frontend workflows
│   ├── python-backend/            # Python backend workflows
│   ├── sdlc-maker/                # SDLC documentation generator
│   ├── ui-ux-generator/           # 🆕 Design-to-code pipeline
│   └── vibe-coding-toolkit/       # Vibe coding toolkit
├── docs/
│   ├── SKILLS_DOCUMENTATION.md
│   ├── ROADMAP.md
│   └── ANTIGRAVITY_SKILLS_GUIDE.md
├── README.md
└── LICENSE
```

---

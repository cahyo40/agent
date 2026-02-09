# 🚀 Antigravity AI Agent Skills

<div align="center">

![Skills](https://img.shields.io/badge/Skills-298-blue?style=for-the-badge)
![Version](https://img.shields.io/badge/Version-6.9.1-green?style=for-the-badge)
![License](https://img.shields.io/badge/License-MIT-yellow?style=for-the-badge)

**Koleksi 298 skills untuk memperluas kemampuan AI Agent**

[📖 Documentation](./docs/SKILLS_DOCUMENTATION.md) · [🗺️ Roadmap](./docs/ROADMAP.md) · [🐛 Report Bug](../../issues)

</div>

---

## ✨ Features

- 🤖 **298 Specialized Skills** - Dari Flutter hingga AI/ML
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
| 🤖 AI & Machine Learning | 21 | LLM, RAG, agents, fine-tuning, LLM Security |
| 🔧 Backend Development | 27 | Python, Go, NestJS, Rust, PHP, Elixir |
| 📱 Mobile Development | 15 | Flutter, iOS, Android, Desktop, Riverpod |
| 🎨 Frontend Development | 16 | React, Vue, Next.js, Svelte, Astro, 3D |
| 🎨 UI/UX & Design | 14 | Figma, design systems |
| ☁️ Cloud & DevOps | 17 | AWS, K8s, Terraform, Chaos Eng |
| 💾 Data & Databases | 16 | ETL, MongoDB, PostgreSQL, Big Data |
| 🔐 Security | 14 | Pen testing, Bug Bounty, CTF, Red Team, Forensics |
| 🧪 Testing & QA | 6 | E2E, TDD, API, performance testing |
| 📝 Content Creation | 24 | Video, Gen Video, Filmmaker, Poster, Book Cover, Thumbnails |
| 📊 Marketing & Business | 13 | SEO, Copywriting, Tech SEO Pro |
| 📝 Documentation | 7 | Technical writing, Architecture |
| 💼 Industry Apps | 40 | Healthcare, Trading, ERP, Fleet, Ride-Hailing, Dating, Social |
| 🎮 Desktop & Games | 11 | Unreal, Godot, Unity Pro, DeFi Gaming |
| 🔮 Emerging Tech | 11 | VR/AR, Quantum, Web3, Biometrics, Digital Human |
| 💬 Bots & Automation | 7 | Discord, Telegram, WhatsApp |
| 🎞️ Media Processing | 2 | Audio & Video engineering |
| 🏗️ Industrial Tech | 3 | IIoT, SCADA, Edge Infra |
| 🎨 Creative Arts | 1 | Creative Coding Artist |
| 📚 Others | 38 | Various specialized |

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

### Business & Industry

- `@e-commerce-developer` - Online stores
- `@saas-product-developer` - SaaS applications
- `@indonesia-payment-integration` - Midtrans, Xendit, GoPay, OVO
- `@ride-hailing-developer` - Gojek/Grab style apps

---

## � Workflows (Vibe Coding)

Pre-built workflows untuk inisialisasi project dengan anti-hallucination guardrails:

| Workflow | Description |
|----------|-------------|
| `/vibe-coding-init` | Base initialization untuk semua project |
| `/vibe-coding-flutter` | Flutter multi-platform dengan Clean Architecture |
| `/vibe-coding-react` | React/Next.js web application |
| `/vibe-coding-vue` | Vue.js/Nuxt dengan Composition API |
| `/vibe-coding-svelte` | Svelte/SvelteKit web application |
| `/vibe-coding-astro` | Astro static/hybrid website |
| `/vibe-coding-nestjs` | NestJS backend API |
| `/vibe-coding-laravel` | Laravel backend/full-stack |
| `/vibe-coding-go-backend` | Go backend API |
| `/vibe-coding-python-backend` | Python FastAPI/Django REST |
| `/vibe-coding-python-web` | Python web (Django/Flask) |
| `/vibe-coding-react-native` | React Native mobile app |
| `/vibe-coding-fullstack` | Full-stack monorepo dengan Turborepo |

### Usage

```text
/vibe-coding-flutter
→ Membuat context files untuk project Flutter

/vibe-coding-react
→ Membuat context files untuk project React/Next.js
```

---

## �📁 Repository Structure

```text
agents/
├── .agent/
│   ├── skills/           # 298 skill folders
│   │   ├── senior-flutter-developer/
│   │   │   └── SKILL.md
│   │   ├── senior-react-developer/
│   │   │   └── SKILL.md
│   │   └── ...
│   └── workflows/        # 13 vibe-coding workflows
│       ├── vibe-coding-flutter.md
│       ├── vibe-coding-react.md
│       └── ...
├── docs/
│   ├── SKILLS_DOCUMENTATION.md
│   └── ROADMAP.md
├── README.md
└── LICENSE
```

---

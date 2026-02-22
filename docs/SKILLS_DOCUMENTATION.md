# 🚀 Antigravity AI Agent Skills - Complete Documentation

> **Version:** 6.19.0
> **Last Updated:** 2026-02-22
> **Total Skills:** 280
> **Total Workflows:** 10 collections (686+ files)

---

## 📋 Table of Contents

1. [Overview](#overview)
2. [How to Use Skills](#how-to-use-skills)
3. [Skills by Category](#skills-by-category)
4. [Complete Skills Reference](#complete-skills-reference)
5. [Quick Reference Table](#quick-reference-table)
6. [Changelog](#changelog)

---

## Overview

Antigravity AI Agent Skills adalah koleksi **280 skills** yang memperluas kemampuan AI agent untuk berbagai domain teknis dan non-teknis. Skills ini dirancang untuk membantu developer, content creator, dan profesional IT dalam pekerjaan sehari-hari.

### Apa itu Skill?

Skill adalah instruksi terstruktur yang memberikan AI kemampuan spesifik dalam suatu domain. Setiap skill berisi:

- **Context & Knowledge** - Pengetahuan domain spesifik
- **Best Practices** - Standar industri dan pola yang direkomendasikan
- **Code Patterns** - Template dan contoh kode siap pakai
- **Anti-Patterns** - Kesalahan umum yang harus dihindari

### Key Features

- ✅ **Automatically Activated** - Skills aktif berdasarkan konteks pertanyaan
- ✅ **Mention with @** - Panggil langsung dengan `@skill-name`
- ✅ **Combinable** - Gabungkan beberapa skills sekaligus
- ✅ **Best Practices Included** - Setiap skill berisi industry best practices

### Skill Categories Overview

| Category | Count | Description |
|----------|-------|-------------|
| 🤖 AI & Machine Learning | 22 | LLM, agents, RAG, fine-tuning, notebooks, LLMOps |
| 🔧 Backend Development | 27 | Python, Go, NestJS, Rust, PHP, Elixir |
| 📱 Mobile Development | 15 | Flutter (consolidated), iOS, Android, React Native |
| 🎨 Frontend Development | 17 | React, Vue, Next.js, Svelte, Astro, 3D, Web3 |
| 🎨 UI/UX & Design | 12 | Design systems, illustrations |
| ☁️ Cloud & DevOps | 18 | CI/CD, K8s, Terraform, Chaos Eng, Observability |
| 💾 Data & Databases | 17 | MongoDB, PostgreSQL, Big Data, Search |
| 🔐 Security | 14 | Pen testing, Bug Bounty, CTF, Red Team, Security Testing |
| 🧪 Testing & QA | 7 | E2E, TDD, performance testing, QA Engineering |
| 📝 Documentation | 8 | Technical writing, UML, Architecture, API docs |
| 💼 Industry Apps | 40 | Healthcare, Trading, ERP, Library Systems |
| 🎮 Desktop & Games | 11 | Unreal, Godot, Unity Pro, DeFi Gaming |
| 🔮 Emerging Tech | 16 | VR/AR, quantum, Web3, Tech Trends |
| 💬 Bots & Automation | 7 | Discord, Telegram, WhatsApp |
| 🎞️ Media Processing | 2 | Video engineering |
| 🏗️ Industrial Tech | 3 | IIoT, SCADA, Edge Infra |
| ⛓️ Web3 & Blockchain | 5 | Smart contracts, NFT, DAO, dApps |
| 📚 Education | 1 | MIT CS Professor |
| 📚 Others | 64 | Various specialized skills |

---

## How to Use Skills

### Method 1: Direct Mention

```text
@senior-flutter-developer buatkan widget login screen

@video-editor-automation buat script edit video

@senior-ai-agent-developer buat AI agent dengan tools
```

### Method 2: Automatic Detection

AI akan otomatis mendeteksi skill yang relevan berdasarkan konteks.

### Method 3: Combine Skills

```text
@senior-flutter-developer @figma-specialist
implementasi design dari Figma ke Flutter code
```

---

## Skills by Category

### 🤖 AI & Machine Learning (13 Skills)

| Skill | Description |
|-------|-------------|
| `senior-ai-ml-engineer` | LLM fine-tuning, MLOps, model deployment |
| `senior-ai-agent-developer` | Autonomous agents, multi-agent systems |
| `senior-rag-engineer` | Vector databases, embeddings, RAG pipelines |
| `senior-edge-ai-engineer` | On-device ML, TensorFlow Lite, ONNX |
| `senior-prompt-engineer` | Prompt design, LLM optimization |
| `senior-prompt-engineering-patterns` | Meta-prompting, prompt chaining |
| `ai-wrapper-product` | AI-powered products, LLM API wrappers |
| `autonomous-agent-patterns` | Agent design patterns, tool integration |
| `chatbot-developer` | Conversational AI, dialog design |
| `mcp-server-builder` | MCP servers for AI agent tools |
| `nlp-specialist` | NLP, sentiment, NER, transformers |
| `stitch-enhance-prompt` | UI prompt optimization for Stitch |
| `stitch-loop` | Autonomous website building |
| `llm-fine-tuning-specialist` | LoRA, QLoRA, PEFT, LLM fine-tuning |

---

### 🔧 Backend Development (24 Skills)

| Skill | Description |
|-------|-------------|
| `senior-backend-developer` | REST API design, database optimization |
| `senior-backend-engineer-golang` | Go/Golang, REST/gRPC APIs, concurrency |
| `senior-python-developer` | FastAPI, async programming |
| `python-fastapi-developer` | FastAPI best practices |
| `python-flask-developer` | Flask web applications |
| `python-async-specialist` | asyncio, concurrent programming |
| `senior-django-developer` | Django, DRF, ORM optimization |
| `senior-nodejs-developer` | Express, NestJS, event-driven |
| `senior-rust-developer` | Ownership, lifetimes, async Rust |
| `senior-php-developer` | Modern PHP 8+, Laravel |
| `senior-graphql-developer` | Schema design, resolvers, Apollo |
| `senior-grpc-developer` | Protocol Buffers, streaming |
| `senior-java-developer` | Spring Boot, microservices, JPA |
| `senior-kotlin-developer` | Coroutines, Kotlin idioms |
| `kotlin-spring-developer` | Kotlin + Spring Boot |
| `senior-laravel-developer` | Laravel, Eloquent, API development |
| `nuxt-developer` | Nuxt.js, Vue 3, SSR/SSG |
| `api-design-specialist` | REST/GraphQL design, versioning |
| `kafka-developer` | Event streaming, Kafka Streams |
| `microservices-architect` | Service decomposition, API gateways |
| `elixir-phoenix-developer` | Elixir, Phoenix, OTP, LiveView |
| `scala-developer` | Scala, Akka, Apache Spark |
| `bun-developer` | Bun runtime, fast JS/TS, SQLite |
| `deno-developer` | Deno runtime, secure, TypeScript |
| `senior-nestjs-developer` | NestJS, modular architecture, TypeORM |

---

### 📱 Mobile Development (9 Skills)

| Skill | Description |
|-------|-------------|
| `senior-flutter-developer` | **Consolidated** - Includes state management, Firebase, Supabase, Web, Desktop, Testing, CI/CD, and Package Development as templates |
| `yo-flutter-dev` | Flutter dengan yo.dart generator dan YoUI component library |
| `senior-ios-developer` | Swift, SwiftUI, UIKit, Combine |
| `senior-android-developer` | Kotlin, Jetpack Compose, MVVM |
| `react-native-developer` | React Native, Expo, cross-platform |
| `senior-firebase-developer` | Advanced Firebase patterns (platform-agnostic) |
| `senior-supabase-developer` | Advanced Supabase, PostgreSQL (platform-agnostic) |
| `dapp-mobile-developer` | Flutter + Web3, WalletConnect |
| `mobile-app-designer` | iOS/Android design patterns |

> **Note:** Flutter-specific skills telah dikonsolidasi menjadi templates di dalam `senior-flutter-developer`:
>
> - State Management: Riverpod, BLoC, GetX
> - Backend: Firebase, Supabase
> - Platform: iOS, Android, Web, Desktop, Platform Channels
> - Tooling: Testing, CI/CD, Package Development

---

### 💼 Industry Apps (40 Skills)

| Skill | Description |
|-------|-------------|
| `indonesia-payment-integration` | 🆕 Midtrans, Xendit, DOKU, GoPay, OVO, DANA, QRIS |
| `ride-hailing-developer` | 🆕 Driver matching, tracking, fare (Gojek/Grab) |
| `dating-app-developer` | 🆕 Matching algorithms, swipe mechanics, safety |
| `social-network-developer` | 🆕 Feed algorithms, stories, friend systems |
| `geolocation-specialist` | 🆕 GPS tracking, geofencing, mapping APIs |
| `pdf-document-specialist` | 🆕 PDF generation, forms, digital signatures |
| `inventory-management-developer` | 🆕 Stock tracking, warehouse, barcode/QR |
| `notification-system-architect` | 🆕 Push notifications, FCM, APNS |
| `multi-tenant-architect` | 🆕 SaaS database strategies, tenant isolation |
| `real-time-collaboration` | 🆕 CRDT, operational transform |
| `queue-system-specialist` | 🆕 RabbitMQ, SQS, job queues |
| `restaurant-system-developer` | 🆕 POS, kitchen display, reservations |
| `hotel-booking-developer` | 🆕 Room management, rates, OTA integration |
| `parking-management-developer` | 🆕 Parking lots, LPR, payment |
| `ticketing-system-developer` | 🆕 Events, seat selection, QR validation |
| `rental-system-developer` | 🆕 Equipment, vehicles, subscription rentals |
| `healthcare-app-developer` | HIPAA, telemedicine, HL7 FHIR |
| `trading-app-developer` | Real-time market data, orders |
| `e-learning-developer` | LMS, SCORM/xAPI, courses, gamification |
| `proptech-developer` | Real estate platforms |
| `food-delivery-developer` | Orders, driver dispatch |
| `e-commerce-developer` | Cart, checkout, payments |
| `fintech-developer` | Payment gateways, banking |
| `pos-developer` | Point-of-sale systems |
| `crm-developer` | Customer management |
| `hr-payroll-developer` | HR systems, payroll |
| `booking-system-developer` | Appointments, reservations |
| `saas-product-developer` | Multi-tenant SaaS |
| `saas-billing-specialist` | Stripe subscriptions |
| `erp-developer` | Enterprise resource planning |
| `bi-dashboard-developer` | Business intelligence |
| `fleet-management-developer` | GPS tracking, telematics |
| `logistics-software-developer` | WMS, inventory optimization |
| `marketplace-architect` | Multi-vendor, commissions |
| `gig-economy-expert` | On-demand platforms |
| `travel-tech-developer` | GDS, OTA, booking engines |
| `insurtech-developer` | Claims, underwriting |
| `personal-finance-app-developer` | Budgeting, expense tracking |
| `sports-league-developer` | Fixtures, brackets, standings |
| `academic-scheduling-developer` | Timetables, room allocation |

---

### 🔮 Emerging Tech & IoT (22 Skills)

| Skill | Description |
|-------|-------------|
| `voice-assistant-developer` | 🆕 Alexa Skills, Google Actions |
| `wearable-app-developer` | 🆕 Apple Watch, Wear OS |
| `smart-home-developer` | 🆕 Matter, HomeKit, Zigbee |
| `drone-software-developer` | 🆕 Flight controllers, mapping |
| `senior-spatial-computing-developer` | VR/AR, Apple visionOS, Meta Quest |
| `senior-quantum-computing-developer` | Qiskit, quantum algorithms |
| `senior-robotics-engineer` | ROS2, SLAM, motion planning |
| `expert-web3-blockchain` | Smart contracts, DeFi, NFTs |
| `senior-web3-developer` | Web3 frontend, wagmi/viem |
| `web3-defi-developer` | AMM, lending protocols |
| `tech-trend-analyst` | GitHub Trending, Technology Radar |
| `emerging-tech-specialist` | Bleeding-edge tech tracking |
| `open-source-evaluator` | OSS project health evaluation |
| `market-innovation-scout` | ProductHunt/IndieHackers discovery |
| `tech-stack-architect` | Stack recommendations |
| `gis-specialist` | PostGIS, Leaflet, Mapbox |
| `iot-developer` | Arduino, Raspberry Pi, MQTT |
| `biometric-system-architect` | FaceID, TouchID, multi-modal |
| `digital-human-architect` | Digital humans, AI avatars |
| `autonomous-vehicle-engineer` | Sensor fusion, path planning |
| `industrial-iot-developer` | MQTT, Modbus, OPC UA |
| `scada-specialist` | HMI, PLC, industrial protocols |

---

### 🔐 Security & Hacking (14 Skills)

| Skill | Description |
|-------|-------------|
| `senior-cybersecurity-engineer` | Application security, zero trust |
| `senior-api-security-specialist` | OWASP Top 10, OAuth 2.0, JWT |
| `senior-penetration-tester` | Vulnerability assessment, ethical hacking |
| `security-testing-specialist` | 🆕 SAST, DAST, SCA, API security, OWASP testing |
| `bug-bounty-hunter` | HackerOne, Bugcrowd, report writing |
| `ctf-competitor` | CTF challenges: Web, Pwn, Crypto |
| `red-team-operator` | Adversary simulation, social engineering |
| `network-security-specialist` | Network pen testing, IDS/IPS |
| `web3-smart-contract-auditor` | Smart contract security |
| `llm-security-specialist` | Prompt injection defense |
| `devsecops-specialist` | Security in CI/CD pipeline |
| `privacy-engineering-specialist` | Differential privacy, ZKP |
| `mobile-security-tester` | iOS/Android pen testing |
| `senior-linux-sysadmin` | Linux server security |

---

## Quick Reference Table

| Use Case | Skill to Use |
|----------|--------------|
| Build Flutter app | `@senior-flutter-developer` |
| State management Flutter | `@senior-flutter-developer` (template) |
| Build React app | `@senior-react-developer` |
| Create REST API (Python) | `@python-fastapi-developer` |
| Create REST API (Go) | `@senior-backend-engineer-golang` |
| Setup CI/CD | `@github-actions-specialist` |
| MongoDB development | `@mongodb-developer` |
| Load testing | `@performance-testing-specialist` |
| Build AI agent | `@senior-ai-agent-developer` |
| Build RAG system | `@senior-rag-engineer` |
| Healthcare app | `@healthcare-app-developer` |
| Ride-hailing app (Gojek/Grab) | `@ride-hailing-developer` |
| Dating app | `@dating-app-developer` |
| Social network | `@social-network-developer` |
| Indonesian payments | `@indonesia-payment-integration` |
| GPS tracking / geofencing | `@geolocation-specialist` |
| PDF generation | `@pdf-document-specialist` |
| Video editing automation | `@video-editor-automation` |
| QA test strategy & automation | `@senior-quality-assurance-engineer` |
| Security testing (SAST/DAST) | `@security-testing-specialist` |

---

## Changelog

### v6.19.0 (2026-02-22)

- ✨ **2 New Skills Added** - QA Engineering & Security Testing
- 🆕 **New Skills:**
  - `senior-quality-assurance-engineer` - Test strategy, test automation, API testing, performance testing, CI/CD quality gates, bug management, QA metrics
  - `security-testing-specialist` - OWASP Top 10 testing, SAST/DAST/SCA, API security, mobile security, vulnerability reporting, CVSS scoring
- 📊 **Total Skills:** 280 (up from 278)
- 🧪 **Testing & QA:** 7 skills (up from 6)
- 🔐 **Security:** 14 skills (up from 13)

### v6.17.0 (2026-02-20)

- ✨ **10 New Skills Added** - Infrastructure, Architecture, Performance, Documentation, Search, AI/LLM, Web3
- 🆕 **New Skills:**
  - `observability-engineer` - Prometheus, Grafana, OpenTelemetry, SRE practices
  - `domain-driven-design-expert` - DDD, bounded contexts, aggregates, event storming
  - `web-vitals-specialist` - Core Web Vitals optimization (LCP, FID, CLS, INP)
  - `api-documentation-specialist` - OpenAPI/Swagger, developer docs, SDK documentation
  - `search-engine-specialist` - Algolia, Meilisearch, Elasticsearch, relevance tuning
  - `llm-ops-engineer` - LLM deployment, monitoring, prompt versioning, evaluation
  - `web3-frontend-specialist` - wagmi, viem, RainbowKit, dApp development
  - `nft-developer` - ERC-721, ERC-1155, NFT marketplaces, IPFS
  - `smart-contract-developer` - Solidity, Foundry, security patterns, gas optimization
  - `dao-developer` - Governance contracts, voting mechanisms, treasury management
- 📊 **Total Skills:** 278 (up from 268)
- 📝 **New Categories:** Web3 & Blockchain (5 skills)

### v6.16.0 (2026-02-20)

- 🗑️ **Skills Cleanup** - Removed 41 non-software development skills
- ✂️ **Removed Skills:**
  - Content Creation: `short-form-video-creator`, `content-repurposer`, `copywriting`, `newsletter-writer`, `seo-content-writer`, `script-writer`, `viral-content-creator`
  - Social Media: `instagram-content-strategist`, `linkedin-content-strategist`, `tiktok-content-strategist`, `twitter-x-strategist`, `youtube-shorts-strategist`, `nano-influencer-strategist`, `social-media-marketer`
  - Design & Art: `ai-poster-designer`, `book-cover-architect`, `sports-poster-specialist`, `thumbnail-designer`, `illustration-creator`, `infographic-creator`, `motion-designer`, `brand-designer`, `creative-coding-artist`, `generative-art-creator`
  - Media Production: `ai-native-filmmaker`, `livestream-producer`, `podcast-producer`, `audio-processing-specialist`, `ai-voice-clone`
  - Marketing: `digital-ads-specialist`, `marketing-strategist`, `local-seo-specialist`, `seo-keyword-research`, `seo-link-building`
  - Other: `3d-scanning-specialist`, `forensic-investigator`, `malware-analyst`, `market-innovation-scout`, `instructional-designer`, `presentation-slide-expert`, `ux-writer`
- 📊 **Total Skills:** 268 (down from 309)
- 📝 **Focus:** Software development, web/mobile development, backend/frontend, UI/UX, freelance, and startup-related skills only.

### v6.15.0 (2026-02-19)

- 🛠️ **Workflow Compliance** - All 87 workflow files updated with YAML frontmatter (`description` field).
- ✂️ **File Splitting** - 47 oversized files split into smaller parts (max 12K chars each) for optimal AI processing.
- ⚡ **Slash Command Support** - Symlink `.agent/workflows/` created for slash command discovery.
- 📊 **Total:** 409+ workflow files across 8 collections (up from 91 original files).

### v6.14.0 (2026-02-18)

- 🗑️ **Workflows Removed** - Folder `.agent/workflows` dihapus untuk menyederhanakan repositori.
- 📝 **Documentation Sync** - Update `README.md` dan `docs/` untuk mencerminkan penghapusan workflow.

### v6.12.0 (2026-02-10)

- 📝 **Flutter Best Practices Documentation** - 100% coverage update
- ✨ **New Patterns Added:**
  - Pull-to-refresh + pagination combo for list screens
  - Optimistic update pattern (toggle, delete with rollback)
  - Shimmer loading skeletons (instead of plain spinners)
  - Connectivity check + offline fallback
  - Dart 3 sealed class `Result<T>` (alternative to `dartz Either`)
- 📄 `performance.md` - Added 4 new sections (#16-#19) with full code examples
- 📄 `repository_pattern.md` - Added Result sealed class + `guardAsync()` helper
- 📄 `senior-flutter-developer/SKILL.md` - Expanded best practices & production checklist
- 📄 `yo-flutter-dev/SKILL.md` - Added UX Patterns section + checklist items
- 📄 `vibe-coding-flutter.md` - Added 4 new EXAMPLES.md sections (#12-#15)
- 📄 `vibe-coding-yo-flutter.md` - Added 4 new EXAMPLES.md sections (#16-#19)

### v6.11.0 (2026-02-09)

- 🆕 `/vibe-coding-android` - Android native workflow (Kotlin + Jetpack Compose)
- 🆕 `/vibe-coding-ios` - iOS native workflow (Swift + SwiftUI)
- 🆕 **Phase 0: Brainstorming** added to all 16 workflows

### v6.9.1 (2026-02-09)

- 🧹 **Skill Audit & Cleanup** - Reduced to 298 skills
- 🗑️ **Deleted Redundant Skills:**
  - `big-data-engineer` → merged with `senior-data-engineer`
  - `edtech-developer` → merged with `e-learning-developer`
  - `portfolio-dashboard-developer` → redundant with `dashboard-developer-specialist`
  - `senior-course-creator` → merged into `instructional-designer`
- 🔄 **Refactored:**
  - `senior-database-engineer-nosql` - removed implementation details, kept architecture focus
  - `instructional-designer` - enhanced with curriculum design content
- 🔧 **Fixed:** `senior-react-native-developer` name field

### v6.9.0 (2026-02-08)

- 🎉 **300 Skills** - Flutter consolidation update
- 🔄 **Flutter Skills Consolidated:**
  - Merged 10 Flutter skills into `senior-flutter-developer` templates
  - State Management: `riverpod.md`, `bloc.md`, `getx.md`
  - Backend Integration: `firebase.md`, `supabase.md`
  - Platform: `ios.md`, `android.md`, `web.md`, `desktop.md`, `platform_channels.md`
  - Tooling: `testing.md`, `ci_cd.md`, `package_development.md`
- ✅ Kept `yo-flutter-dev` as separate specialized skill
- 📉 Skill count reduced from 309 to 300 (consolidation)

### v6.8.0 (2026-02-07)

- 🎉 **309 Skills** - Data Science & Automation update
- ✨ New Skills:
  - `data-science-notebook-developer` - Jupyter, Colab, interactive analysis
  - `google-apps-script-developer` - Google Workspace automation

### v6.7.0 (2026-02-05)

- 🎉 **307 Skills** - Platform expansion update
- ✨ New Skills:
  - `flutter-desktop-developer` - macOS, Windows, Linux Flutter apps
  - `senior-nestjs-developer` - NestJS TypeScript backend framework
  - `llm-fine-tuning-specialist` - LoRA, QLoRA, PEFT fine-tuning

### v6.5.0 (2026-02-02) 🎉

- 🎉 **300 Skills** - Major milestone reached!
- ✨ New Indonesia Payment & Specialized App Skills:
  - `indonesia-payment-integration` - Midtrans, Xendit, DOKU, e-wallets, QRIS
  - `ride-hailing-developer` - Gojek/Grab style apps
  - `dating-app-developer` - Matching, swipe, safety
  - `social-network-developer` - Feed, stories, relationships
  - `geolocation-specialist` - GPS, geofencing, maps
  - `pdf-document-specialist` - PDF generation, forms, signatures
- ✨ New System & Architecture Skills:
  - `inventory-management-developer` - Stock, warehouse, barcode
  - `notification-system-architect` - Push, FCM, APNS
  - `multi-tenant-architect` - SaaS database strategies
  - `real-time-collaboration` - CRDT, OT
  - `queue-system-specialist` - RabbitMQ, SQS
- ✨ New Industry Apps:
  - `restaurant-system-developer` - POS, kitchen display
  - `hotel-booking-developer` - Room management, OTA
  - `parking-management-developer` - Lots, LPR, payment
  - `ticketing-system-developer` - Events, seats, QR
  - `rental-system-developer` - Equipment, vehicles
- ✨ New IoT & Emerging Tech:
  - `voice-assistant-developer` - Alexa, Google Actions
  - `wearable-app-developer` - Watch apps
  - `smart-home-developer` - Matter, HomeKit
  - `drone-software-developer` - Flight controllers

### v6.4.0 (2026-02-02)

- 🎉 **275 Skills** - Total skills increased from 269 to 275
- ✨ New Hacking & Security Skills:
  - `bug-bounty-hunter` - Vulnerability hunting, report writing
  - `ctf-competitor` - CTF challenges (Web, Pwn, Crypto, Forensics)
  - `red-team-operator` - Adversary simulation, C2 operations
  - `malware-analyst` - Static/dynamic malware analysis
  - `network-security-specialist` - Network pen testing, IDS/IPS
  - `forensic-investigator` - Digital forensics, incident response

### v6.3.0 (2026-02-02)

- 🎉 **269 Skills** - Total skills increased from 261 to 269
- ✨ New Flutter Integration Skills:
  - `flutter-bloc-specialist` - BLoC/Cubit state management
  - `flutter-firebase-developer` - Full Firebase integration
  - `flutter-supabase-developer` - Full Supabase integration
- ✨ New Tech Analysis Skills:
  - `tech-trend-analyst` - Technology trend research
  - `emerging-tech-specialist` - Cutting-edge tech tracking
  - `open-source-evaluator` - OSS project evaluation
  - `market-innovation-scout` - Market opportunity discovery
  - `tech-stack-architect` - Stack recommendations
- 📄 README updated with multi-platform usage guide

### v6.2.0 (2026-02-01)

- 🎉 **261 Skills** - Added 6 Creative AI skills
- ✨ New skills: `ai-poster-designer`, `book-cover-architect`, `sports-poster-specialist`, `presentation-slide-expert`, `ai-native-filmmaker`, `digital-human-architect`

### v5.0.0 (2026-02-01)

- 🎉 **209 Skills** - Total skills increased from 156 to 209
- ✨ New categories: Industry Apps, GIS, additional Flutter specialists
- ➕ Added 53 new skills including:
  - **Flutter**: `flutter-riverpod-specialist`, `flutter-getx-specialist`
  - **Python**: `python-fastapi-developer`, `python-flask-developer`, `python-async-specialist`, `python-testing-specialist`, `python-automation-specialist`
  - **R**: `r-data-scientist`, `r-statistician`
  - **Database**: `mongodb-developer`, `postgresql-specialist`, `database-modeling-specialist`
  - **Industry Apps**: `healthcare-app-developer`, `trading-app-developer`, `edtech-developer`, `proptech-developer`, `food-delivery-developer`
  - **Infrastructure**: `senior-grpc-developer`, `kafka-developer`, `github-actions-specialist`, `kubernetes-specialist`, `microservices-architect`
  - **Testing**: `performance-testing-specialist`
  - **GIS**: `gis-specialist`
  - **Web3**: `web3-smart-contract-auditor`, `web3-defi-developer`

---

*Documentation updated using `@senior-technical-writer` and `@document-generator` skills.*

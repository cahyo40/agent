---
description: Initialize Vibe Coding context files for iOS native application with Swift and SwiftUI
---

# /vibe-coding-ios

Workflow untuk setup dokumen konteks Vibe Coding khusus **iOS Native** dengan Swift dan SwiftUI.

---

## 📋 Prerequisites

1. **Deskripsi ide aplikasi** (2-3 paragraf)
2. **Target iOS version** (min deployment target)
3. **Architecture preference** (MVVM / TCA / Clean Architecture)
4. **Backend preference** (Firebase / Supabase / Custom API)
5. **Vibe/estetika** yang diinginkan

---

## 💡 Phase 0: Ideation & Brainstorming

Phase ini menggunakan skill `@brainstorming` untuk mengklarifikasi ide sebelum masuk ke dokumentasi teknis.

### Step 0.1: Problem Framing

Gunakan skill `brainstorming`:

```markdown
Act as brainstorming.
Berdasarkan ide user, buatkan Problem Framing Canvas:

## Problem Framing Canvas
### 1. WHAT is the problem? [Satu kalimat spesifik]
### 2. WHO is affected? [Primary users, stakeholders]
### 3. WHY does it matter? [Pain points, business opportunity]
### 4. WHAT constraints exist? [Time, budget, technology]
### 5. WHAT does success look like? [Measurable outcomes]
```

### Step 0.2: Feature Ideation

```markdown
Act as brainstorming.
Generate fitur potensial dengan:
- HMW (How Might We) Questions
- SCAMPER Analysis untuk fitur utama
```

### Step 0.3: Feature Prioritization

```markdown
Act as brainstorming.
Prioritasikan dengan:
- Impact vs Effort Matrix
- RICE Scoring (Reach × Impact × Confidence / Effort)
- MoSCoW: Must Have, Should Have, Could Have, Won't Have
```

### Step 0.4: Quick Validation

```markdown
Act as brainstorming.
Validasi dengan checklist:
- Feasibility: Bisa dibangun?
- Viability: Layak secara bisnis?
- Desirability: User mau pakai?
- Go/No-Go Decision
```

// turbo
**Simpan output ke file `BRAINSTORM.md` di root project.**

---

## 🏗️ Phase 1: Holy Trinity (WAJIB)

### Step 1.1: Generate PRD.md

Skill: `senior-project-manager` + `senior-ios-developer`

```markdown
Buatkan PRD.md untuk iOS app: [IDE]
- Executive Summary
- Problem Statement
- Target User & Persona (iOS/Apple users)
- User Stories (min 10 untuk MVP)
- Core Features dengan MoSCoW
- iOS-specific requirements (permissions, capabilities)
- Apple ecosystem integration (iCloud, Widgets, Apple Watch)
- Success Metrics (DAU, Crash-free rate, App Store rating)
```

// turbo
**Simpan ke `PRD.md`**

---

### Step 1.2: Generate TECH_STACK.md

Skill: `tech-stack-architect` + `senior-ios-developer`

```markdown
## Core Stack
- Language: Swift 5.9+
- Min Deployment: iOS 16.0
- UI: SwiftUI
- Build: Xcode 15+
- Package Manager: Swift Package Manager (SPM)

## Architecture
- Pattern: MVVM dengan Observation framework (iOS 17+)
- Fallback: ObservableObject untuk iOS 16
- Navigation: NavigationStack
- State: @Observable / @ObservableObject

## Apple Frameworks
- SwiftUI: UI layer
- Combine: Reactive programming
- SwiftData: Persistence (iOS 17+) atau Core Data
- URLSession: Networking
- async/await: Concurrency

## Third Party (Minimal)
- Alamofire: Networking (optional, prefer URLSession)
- Kingfisher: Image caching
- SwiftLint: Linting

## Testing
- XCTest
- Swift Testing (iOS 17+)
- XCUITest untuk UI tests

## Approved Dependencies (Package.swift)
```swift
dependencies: [
    .package(url: "https://github.com/onevcat/Kingfisher.git", from: "7.10.0"),
    .package(url: "https://github.com/realm/SwiftLint.git", from: "0.54.0"),
]
```

## Constraints

- Prefer Apple-native solutions over third-party
- WAJIB Swift, DILARANG Objective-C untuk kode baru
- WAJIB SwiftUI, DILARANG UIKit kecuali necessary
- Semua async dengan async/await
- Support Dark Mode dan Dynamic Type

```

// turbo
**Simpan ke `TECH_STACK.md`**

---

### Step 1.3: Generate RULES.md

Skill: `senior-ios-developer`

```markdown
## Swift Rules
- Swift 5.9+ features (macros, parameter packs)
- Prefer `let` over `var`
- Use structs untuk value types, classes untuk reference types
- Enums dengan associated values
- Protocol-oriented programming
- DILARANG force unwrap (`!`) kecuali IBOutlet legacy

## SwiftUI Rules
- Views harus lightweight, logic di ViewModel
- @State untuk local state
- @Observable/@ObservableObject untuk shared state
- @Environment untuk dependency injection
- Prefer system components, custom hanya jika perlu
- Modifier order matters

## Architecture Rules
- MVVM dengan single source of truth
- ViewModel dengan @Observable (iOS 17) atau ObservableObject
- Repository pattern untuk data access
- Use cases untuk complex business logic
- Dependency Injection via Environment

## State Management
```swift
// iOS 17+
@Observable
class HomeViewModel {
    var users: [User] = []
    var isLoading = false
    var error: Error?
}

// iOS 16
class HomeViewModel: ObservableObject {
    @Published var users: [User] = []
    @Published var isLoading = false
    @Published var error: Error?
}
```

## Async/Await Rules

- @MainActor untuk UI updates
- Task untuk async operations
- Task cancellation handling
- SELALU handle errors dengan do-catch

## Error Handling

- Result type untuk async operations
- Custom Error types dengan LocalizedError
- User-friendly messages di UI
- os.log untuk debugging

## Naming Conventions

- Types: PascalCase
- Functions/Variables: camelCase
- Constants: camelCase atau SCREAMING_SNAKE_CASE
- Protocols: PascalCase dengan -able, -ible, atau noun

## AI Behavior Rules

1. JANGAN import package tidak ada di Package.swift
2. JANGAN gunakan deprecated APIs
3. JANGAN hardcode strings, gunakan Localizable
4. IKUTI Human Interface Guidelines
5. SELALU support accessibility
6. SELALU handle state restoration
7. Test di multiple device sizes

```

// turbo
**Simpan ke `RULES.md`**

---

## 🎨 Phase 2: Support System

### Step 2.1: Generate DESIGN_SYSTEM.md

Skill: `design-system-architect` + `senior-ios-developer`

```markdown
## Apple Design System

### Color Scheme
```swift
// Theme/AppColors.swift
import SwiftUI

extension Color {
    static let appPrimary = Color("Primary")
    static let appSecondary = Color("Secondary")
    static let appBackground = Color("Background")
    static let appSurface = Color("Surface")
    static let appError = Color("Error")
}

// Semantic Colors (use system colors when possible)
extension Color {
    static let textPrimary = Color.primary
    static let textSecondary = Color.secondary
    static let divider = Color.gray.opacity(0.3)
}
```

### Typography

```swift
// Theme/AppTypography.swift
extension Font {
    static let appLargeTitle = Font.largeTitle.weight(.bold)
    static let appTitle = Font.title.weight(.semibold)
    static let appTitle2 = Font.title2.weight(.semibold)
    static let appTitle3 = Font.title3.weight(.medium)
    static let appHeadline = Font.headline
    static let appBody = Font.body
    static let appCallout = Font.callout
    static let appCaption = Font.caption
}
```

### Spacing

```swift
// Theme/AppSpacing.swift
enum AppSpacing {
    static let xs: CGFloat = 4
    static let sm: CGFloat = 8
    static let md: CGFloat = 16
    static let lg: CGFloat = 24
    static let xl: CGFloat = 32
    static let xxl: CGFloat = 48
}
```

### Corner Radius

```swift
enum AppCornerRadius {
    static let sm: CGFloat = 8
    static let md: CGFloat = 12
    static let lg: CGFloat = 16
    static let xl: CGFloat = 24
}
```

```

// turbo
**Simpan ke `DESIGN_SYSTEM.md`**

---

### Step 2.2: Generate FOLDER_STRUCTURE.md

```markdown
## Project Structure (Clean Architecture)

```

MyApp/
├── MyApp.swift                      # App entry point
├── ContentView.swift                # Root view
│
├── App/
│   ├── AppDelegate.swift            # App lifecycle (if needed)
│   └── SceneDelegate.swift          # Scene lifecycle (if needed)
│
├── Core/                            # Core utilities
│   ├── Extensions/
│   │   ├── View+Extensions.swift
│   │   └── String+Extensions.swift
│   ├── Utilities/
│   │   ├── Constants.swift
│   │   └── Logger.swift
│   └── Network/
│       ├── NetworkManager.swift
│       ├── APIEndpoint.swift
│       └── NetworkError.swift
│
├── Data/                            # Data layer
│   ├── Repositories/
│   │   └── UserRepositoryImpl.swift
│   ├── DataSources/
│   │   ├── Remote/
│   │   │   └── UserRemoteDataSource.swift
│   │   └── Local/
│   │       └── UserLocalDataSource.swift
│   └── DTOs/
│       └── UserDTO.swift
│
├── Domain/                          # Domain layer
│   ├── Entities/
│   │   └── User.swift
│   ├── Repositories/
│   │   └── UserRepository.swift
│   └── UseCases/
│       ├── GetUserUseCase.swift
│       └── LoginUseCase.swift
│
├── Presentation/                    # Presentation layer
│   ├── Navigation/
│   │   └── AppRouter.swift
│   ├── Components/                  # Reusable views
│   │   ├── AppButton.swift
│   │   ├── AppTextField.swift
│   │   └── LoadingView.swift
│   └── Screens/
│       ├── Home/
│       │   ├── HomeView.swift
│       │   └── HomeViewModel.swift
│       └── Auth/
│           ├── LoginView.swift
│           └── LoginViewModel.swift
│
├── Theme/                           # Design system
│   ├── AppColors.swift
│   ├── AppTypography.swift
│   └── AppSpacing.swift
│
├── Resources/
│   ├── Assets.xcassets/
│   └── Localizable.strings
│
└── Preview Content/
    └── Preview Assets.xcassets/

```

## Naming Conventions
- Views: `XxxView.swift`
- ViewModels: `XxxViewModel.swift`
- Use Cases: `XxxUseCase.swift`
- Repositories: `XxxRepository.swift` (protocol), `XxxRepositoryImpl.swift`
- DTOs: `XxxDTO.swift`
- Entities: `Xxx.swift` (simple noun)
```

// turbo
**Simpan ke `FOLDER_STRUCTURE.md`**

---

### Step 2.3: Generate EXAMPLES.md

Skill: `senior-ios-developer`

```markdown
## 1. ViewModel Pattern (iOS 17+)

```swift
import SwiftUI

@Observable
class HomeViewModel {
    private let getUserUseCase: GetUserUseCase
    
    var user: User?
    var isLoading = false
    var errorMessage: String?
    
    init(getUserUseCase: GetUserUseCase) {
        self.getUserUseCase = getUserUseCase
    }
    
    @MainActor
    func loadUser() async {
        isLoading = true
        errorMessage = nil
        
        do {
            user = try await getUserUseCase.execute()
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
}
```

## 2. SwiftUI View

```swift
struct HomeView: View {
    @State private var viewModel: HomeViewModel
    
    init(viewModel: HomeViewModel) {
        _viewModel = State(initialValue: viewModel)
    }
    
    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading {
                    ProgressView()
                } else if let error = viewModel.errorMessage {
                    ErrorView(message: error) {
                        Task { await viewModel.loadUser() }
                    }
                } else if let user = viewModel.user {
                    UserContent(user: user)
                }
            }
            .navigationTitle("Home")
        }
        .task {
            await viewModel.loadUser()
        }
    }
}

private struct UserContent: View {
    let user: User
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            Text("Welcome, \(user.name)")
                .font(.appTitle)
            
            Text(user.email)
                .font(.appBody)
                .foregroundStyle(.secondary)
        }
        .padding()
    }
}
```

## 3. Repository Pattern

```swift
protocol UserRepository {
    func getUser(id: String) async throws -> User
    func observeUsers() -> AsyncStream<[User]>
}

final class UserRepositoryImpl: UserRepository {
    private let remoteDataSource: UserRemoteDataSource
    private let localDataSource: UserLocalDataSource
    
    init(
        remoteDataSource: UserRemoteDataSource,
        localDataSource: UserLocalDataSource
    ) {
        self.remoteDataSource = remoteDataSource
        self.localDataSource = localDataSource
    }
    
    func getUser(id: String) async throws -> User {
        do {
            let dto = try await remoteDataSource.fetchUser(id: id)
            let user = dto.toDomain()
            try await localDataSource.save(user)
            return user
        } catch {
            if let cached = try await localDataSource.getUser(id: id) {
                return cached
            }
            throw error
        }
    }
    
    func observeUsers() -> AsyncStream<[User]> {
        localDataSource.observeUsers()
    }
}
```

## 4. Navigation

```swift
enum Route: Hashable {
    case home
    case detail(id: String)
    case settings
}

@Observable
class AppRouter {
    var path = NavigationPath()
    
    func navigate(to route: Route) {
        path.append(route)
    }
    
    func pop() {
        path.removeLast()
    }
    
    func popToRoot() {
        path.removeLast(path.count)
    }
}

struct ContentView: View {
    @State private var router = AppRouter()
    
    var body: some View {
        NavigationStack(path: $router.path) {
            HomeView()
                .navigationDestination(for: Route.self) { route in
                    switch route {
                    case .home:
                        HomeView()
                    case .detail(let id):
                        DetailView(id: id)
                    case .settings:
                        SettingsView()
                    }
                }
        }
        .environment(router)
    }
}
```

```

// turbo
**Simpan ke `EXAMPLES.md`**

---

## ✅ Phase 3: Project Setup

// turbo
```bash
# Create new iOS project dengan Xcode
# File > New > Project > App
# Interface: SwiftUI
# Language: Swift
# Storage: SwiftData (atau None)
```

---

## 📁 Checklist

```
BRAINSTORM.md, PRD.md, TECH_STACK.md, RULES.md,
DESIGN_SYSTEM.md, FOLDER_STRUCTURE.md, EXAMPLES.md
```

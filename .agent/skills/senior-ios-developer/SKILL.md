---
name: senior-ios-developer
description: "Expert iOS development including Swift, SwiftUI, UIKit, Combine, async/await, and App Store best practices"
---

# Senior iOS Developer

## Overview

This skill transforms you into an experienced Senior iOS Developer who builds polished, performant iOS applications. You'll master Swift, SwiftUI, and modern iOS patterns for creating App Store-ready apps.

## When to Use This Skill

- Use when building iOS applications
- Use when implementing SwiftUI or UIKit
- Use when working with Combine or async/await
- Use when optimizing iOS app performance
- Use when preparing apps for App Store

## How It Works

### Step 1: Swift Modern Patterns

```swift
// Async/Await
func fetchUser(id: String) async throws -> User {
    let url = URL(string: "https://api.example.com/users/\(id)")!
    let (data, response) = try await URLSession.shared.data(from: url)
    
    guard let httpResponse = response as? HTTPURLResponse,
          httpResponse.statusCode == 200 else {
        throw NetworkError.invalidResponse
    }
    
    return try JSONDecoder().decode(User.self, from: data)
}

// Structured concurrency
func fetchAllData() async throws -> (User, [Post]) {
    async let user = fetchUser(id: "123")
    async let posts = fetchPosts()
    
    return try await (user, posts)
}

// Result type
enum NetworkError: Error {
    case invalidURL
    case invalidResponse
    case decodingError
}

func fetch<T: Decodable>(from url: URL) async -> Result<T, NetworkError> {
    do {
        let (data, _) = try await URLSession.shared.data(from: url)
        let decoded = try JSONDecoder().decode(T.self, from: data)
        return .success(decoded)
    } catch {
        return .failure(.decodingError)
    }
}
```

### Step 2: SwiftUI Architecture

```swift
import SwiftUI

// MVVM with ObservableObject
@MainActor
class UserViewModel: ObservableObject {
    @Published var user: User?
    @Published var isLoading = false
    @Published var error: Error?
    
    private let userService: UserServiceProtocol
    
    init(userService: UserServiceProtocol = UserService()) {
        self.userService = userService
    }
    
    func loadUser(id: String) async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            user = try await userService.fetchUser(id: id)
        } catch {
            self.error = error
        }
    }
}

// View
struct UserProfileView: View {
    @StateObject private var viewModel = UserViewModel()
    let userId: String
    
    var body: some View {
        Group {
            if viewModel.isLoading {
                ProgressView()
            } else if let user = viewModel.user {
                VStack(spacing: 16) {
                    AsyncImage(url: user.avatarURL) { image in
                        image.resizable().scaledToFit()
                    } placeholder: {
                        Circle().fill(.gray)
                    }
                    .frame(width: 100, height: 100)
                    .clipShape(Circle())
                    
                    Text(user.name)
                        .font(.title)
                    
                    Text(user.email)
                        .foregroundColor(.secondary)
                }
            } else if viewModel.error != nil {
                ContentUnavailableView(
                    "Error Loading",
                    systemImage: "exclamationmark.triangle",
                    description: Text("Please try again")
                )
            }
        }
        .task {
            await viewModel.loadUser(id: userId)
        }
    }
}
```

### Step 3: SwiftUI Components

```swift
// Reusable button component
struct PrimaryButton: View {
    let title: String
    let isLoading: Bool
    let action: () -> Void
    
    init(_ title: String, isLoading: Bool = false, action: @escaping () -> Void) {
        self.title = title
        self.isLoading = isLoading
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            HStack {
                if isLoading {
                    ProgressView()
                        .tint(.white)
                }
                Text(title)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.accentColor)
            .foregroundColor(.white)
            .cornerRadius(12)
        }
        .disabled(isLoading)
    }
}

// Custom modifier
struct CardStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

extension View {
    func cardStyle() -> some View {
        modifier(CardStyle())
    }
}
```

### Step 4: Data Persistence

```swift
import SwiftData

// SwiftData Model
@Model
class Task {
    var title: String
    var isCompleted: Bool
    var createdAt: Date
    var category: Category?
    
    init(title: String, isCompleted: Bool = false) {
        self.title = title
        self.isCompleted = isCompleted
        self.createdAt = Date()
    }
}

@Model
class Category {
    var name: String
    @Relationship(deleteRule: .cascade, inverse: \Task.category)
    var tasks: [Task]
    
    init(name: String) {
        self.name = name
        self.tasks = []
    }
}

// Using in View
struct TaskListView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \Task.createdAt, order: .reverse) private var tasks: [Task]
    
    var body: some View {
        List {
            ForEach(tasks) { task in
                TaskRow(task: task)
            }
            .onDelete(perform: deleteTasks)
        }
    }
    
    private func deleteTasks(at offsets: IndexSet) {
        for index in offsets {
            context.delete(tasks[index])
        }
    }
}
```

## Examples

### Example 1: Network Layer

```swift
protocol APIClientProtocol {
    func request<T: Decodable>(_ endpoint: Endpoint) async throws -> T
}

struct APIClient: APIClientProtocol {
    private let session: URLSession
    private let decoder: JSONDecoder
    
    init(session: URLSession = .shared) {
        self.session = session
        self.decoder = JSONDecoder()
        self.decoder.keyDecodingStrategy = .convertFromSnakeCase
    }
    
    func request<T: Decodable>(_ endpoint: Endpoint) async throws -> T {
        let request = try endpoint.urlRequest()
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            throw APIError.statusCode(httpResponse.statusCode)
        }
        
        return try decoder.decode(T.self, from: data)
    }
}

enum Endpoint {
    case users
    case user(id: String)
    case createUser(User)
    
    var path: String {
        switch self {
        case .users: return "/users"
        case .user(let id): return "/users/\(id)"
        case .createUser: return "/users"
        }
    }
    
    var method: String {
        switch self {
        case .createUser: return "POST"
        default: return "GET"
        }
    }
}
```

## Best Practices

### ✅ Do This

- ✅ Use `@MainActor` for UI-related code
- ✅ Prefer SwiftUI for new projects
- ✅ Use Swift Concurrency (async/await)
- ✅ Follow Human Interface Guidelines
- ✅ Implement proper error handling
- ✅ Use SwiftData for persistence

### ❌ Avoid This

- ❌ Don't force unwrap in production
- ❌ Don't block main thread
- ❌ Don't ignore memory management
- ❌ Don't skip accessibility

## Common Pitfalls

**Problem:** Memory leaks with closures
**Solution:** Use `[weak self]` in escaping closures.

**Problem:** UI updates on background thread
**Solution:** Use `@MainActor` or `DispatchQueue.main`.

**Problem:** SwiftUI view not updating
**Solution:** Ensure state is `@Published` and view observes it.

## Related Skills

- `@senior-flutter-developer` - Cross-platform alternative
- `@senior-ui-ux-designer` - For iOS design
- `@senior-software-engineer` - For architecture

---
name: senior-android-developer
description: "Expert Android development including Kotlin, Jetpack Compose, MVVM architecture, coroutines, and modern Android best practices"
---

# Senior Android Developer

## Overview

This skill transforms you into an experienced Senior Android Developer who builds production-ready Android applications using modern tools and architecture patterns.

## When to Use This Skill

- Use when building Android applications
- Use when implementing Jetpack Compose UI
- Use when working with Kotlin and coroutines
- Use when the user asks about Android development

## How It Works

### Step 1: Modern Android Architecture

```
ANDROID ARCHITECTURE (MVVM + Clean)
├── presentation/
│   ├── ui/          (Composables)
│   ├── viewmodel/   (ViewModels)
│   └── state/       (UI States)
├── domain/
│   ├── model/       (Business models)
│   ├── usecase/     (Business logic)
│   └── repository/  (Interfaces)
└── data/
    ├── repository/  (Implementations)
    ├── remote/      (API, Retrofit)
    └── local/       (Room DB)
```

### Step 2: Jetpack Compose UI

```kotlin
@Composable
fun UserProfileScreen(
    viewModel: UserViewModel = hiltViewModel()
) {
    val uiState by viewModel.uiState.collectAsStateWithLifecycle()
    
    when (val state = uiState) {
        is UiState.Loading -> LoadingIndicator()
        is UiState.Success -> UserContent(state.user)
        is UiState.Error -> ErrorMessage(state.message)
    }
}

@Composable
fun UserContent(user: User) {
    Column(
        modifier = Modifier
            .fillMaxSize()
            .padding(16.dp)
    ) {
        AsyncImage(
            model = user.avatarUrl,
            contentDescription = "Avatar",
            modifier = Modifier
                .size(100.dp)
                .clip(CircleShape)
        )
        Spacer(Modifier.height(16.dp))
        Text(user.name, style = MaterialTheme.typography.headlineMedium)
        Text(user.email, style = MaterialTheme.typography.bodyMedium)
    }
}
```

### Step 3: ViewModel with StateFlow

```kotlin
@HiltViewModel
class UserViewModel @Inject constructor(
    private val getUserUseCase: GetUserUseCase
) : ViewModel() {
    
    private val _uiState = MutableStateFlow<UiState<User>>(UiState.Loading)
    val uiState: StateFlow<UiState<User>> = _uiState.asStateFlow()
    
    init {
        loadUser()
    }
    
    private fun loadUser() {
        viewModelScope.launch {
            getUserUseCase()
                .onSuccess { user -> _uiState.value = UiState.Success(user) }
                .onFailure { e -> _uiState.value = UiState.Error(e.message) }
        }
    }
}

sealed interface UiState<out T> {
    data object Loading : UiState<Nothing>
    data class Success<T>(val data: T) : UiState<T>
    data class Error(val message: String?) : UiState<Nothing>
}
```

## Best Practices

### ✅ Do This

- ✅ Use Jetpack Compose for new UI
- ✅ Follow MVVM with Clean Architecture
- ✅ Use Hilt for dependency injection
- ✅ Handle configuration changes properly
- ✅ Use StateFlow for reactive state

### ❌ Avoid This

- ❌ Don't put business logic in UI
- ❌ Don't ignore lifecycle
- ❌ Don't block main thread

## Related Skills

- `@senior-ios-developer` - iOS comparison
- `@senior-flutter-developer` - Cross-platform alternative

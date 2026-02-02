---
name: senior-android-developer
description: "Expert Android development including Kotlin, Jetpack Compose, MVVM/MVI architecture, Coroutines, and modern Android best practices"
---

# Senior Android Developer

## Overview

This skill transforms you into a **Google Developer Expert (GDE)** level Android Engineer. You will move beyond Activities and Fragments to mastering **Jetpack Compose** (Declarative UI), **Coroutines & Flows** for async, **Clean Architecture (MVVM/MVI)**, and Dependency Injection with **Hilt/Koin**.

## When to Use This Skill

- Use when building modern native Android apps (Kotlin-first)
- Use when migrating XML layouts to Jetpack Compose
- Use when designing app architecture (Repository pattern, UseCases)
- Use when handling background tasks (WorkManager)
- Use when optimizing app performance (Startup time, R8 shrinking)

---

## Part 1: Modern Android Architecture (Now in Android)

Google recommends a layered architecture.

```text
app/
├── data/                    # Data Layer (Repositories, Data Sources)
│   ├── local/               # Room Database
│   │   ├── AppDatabase.kt
│   │   └── UserDao.kt
│   ├── remote/              # Retrofit API
│   │   └── UserApi.kt
│   └── UserRepository.kt    # Single Source of Truth
├── domain/                  # Domain Layer (Optional but Recommended)
│   ├── model/               # Pure Kotlin Data Classes
│   └── usecase/             # Reusable Business Logic
│       └── GetUserUseCase.kt
├── ui/                      # UI Layer (Presentation)
│   ├── theme/               # Material 3 Theme
│   ├── home/
│   │   ├── HomeScreen.kt    # Composable
│   │   └── HomeViewModel.kt
│   └── components/
└── di/                      # Dependency Injection (Hilt)
```

---

## Part 2: Jetpack Compose (Declarative UI)

Stop using `findViewById` and XML.

### 2.1 State Hoisting & Composables

```kotlin
// Stateless Composable (Reusable)
@Composable
fun UserCard(
    user: User,
    onClick: () -> Unit,
    modifier: Modifier = Modifier
) {
    Card(
        modifier = modifier.clickable(onClick = onClick),
        elevation = CardDefaults.cardElevation(defaultElevation = 4.dp)
    ) {
        Column(modifier = Modifier.padding(16.dp)) {
            Text(text = user.name, style = MaterialTheme.typography.titleMedium)
            Text(text = user.email, style = MaterialTheme.typography.bodyMedium)
        }
    }
}

// Stateful Composable (Screen Level)
@Composable
fun UserScreen(viewModel: UserViewModel = hiltViewModel()) {
    // Collect UI State safely
    val uiState by viewModel.uiState.collectAsStateWithLifecycle()

    when (uiState) {
        is UserUiState.Loading -> CircularProgressIndicator()
        is UserUiState.Success -> UserList(users = (uiState as UserUiState.Success).data)
        is UserUiState.Error -> ErrorMessage(message = (uiState as UserUiState.Error).msg)
    }
}
```

---

## Part 3: Asynchronous Data (Coroutines & Flow)

### 3.1 ViewModel Pattern

Never expose MutableStateFlow. Expose generic StateFlow/SharedFlow.

```kotlin
@HiltViewModel
class HomeViewModel @Inject constructor(
    private val getUserUseCase: GetUserUseCase
) : ViewModel() {

    // Backing property
    private val _uiState = MutableStateFlow<UiState>(UiState.Loading)
    
    // Exposed immutable stream
    val uiState: StateFlow<UiState> = _uiState.asStateFlow()

    init {
        fetchUser()
    }

    fun fetchUser() {
        viewModelScope.launch {
            _uiState.value = UiState.Loading
            try {
                // Suspended function call
                val user = getUserUseCase() 
                _uiState.value = UiState.Success(user)
            } catch (e: Exception) {
                _uiState.value = UiState.Error(e.message)
            }
        }
    }
}
```

### 3.2 Cold vs Hot Flows

- **Flow (Cold)**: Starts executing code only when collected. (Retrofit calls, DB queries).
- **StateFlow (Hot)**: Always holds dynamic value. (UI State).
- **SharedFlow (Hot)**: Events (Navigation, Toasts) that don't need initial state.

---

## Part 4: Dependency Injection (Hilt)

Standard way to inject dependencies in Android.

```kotlin
@Module
@InstallIn(SingletonComponent::class)
object NetworkModule {

    @Provides
    @Singleton
    fun provideRetrofit(): Retrofit {
        return Retrofit.Builder()
            .baseUrl("https://api.example.com")
            .addConverterFactory(GsonConverterFactory.create())
            .build()
    }

    @Provides
    @Singleton
    fun provideApiService(retrofit: Retrofit): ApiService {
        return retrofit.create(ApiService::class.java)
    }
}
```

---

## Part 5: Clean Architecture UseCases

Decouple logic from ViewModels.

```kotlin
// Single Responsibility Principle
class LoginUseCase @Inject constructor(
    private val repository: AuthRepository,
    private val validator: EmailValidator
) {
    // "Callable" class pattern
    operator fun invoke(email: String, pass: String): Flow<Result<User>> = flow {
        if (!validator.isValid(email)) {
            emit(Result.Error("Invalid Email"))
            return@flow
        }
        emit(Result.Loading)
        try {
            val user = repository.login(email, pass)
            emit(Result.Success(user))
        } catch (e: Exception) {
            emit(Result.Error(e.message))
        }
    }
}
```

---

## Part 6: Best Practices Checklist

### ✅ Do This

- ✅ **Use `collectAsStateWithLifecycle()`**: Safer than `collectAsState()` because it pauses collection when app is in background (saves battery/crashes).
- ✅ **Use Material 3**: Follow latest design guidelines (`androidx.compose.material3`).
- ✅ **Modularize**: Split app into `:feature:home`, `:core:data`, `:core:ui` modules for build speed.
- ✅ **Use R8/ProGuard**: Always enable minification for release builds.
- ✅ **Baseline Profiles**: Generate them to improve app startup time by 30%+.

### ❌ Avoid This

- ❌ **Logic in Composables**: Keep UI dumb. Move logic to ViewModel/UseCase.
- ❌ **Global Context**: Don't pass Context around. Inject `@ApplicationContext` via Hilt if needed but prefer strict separation.
- ❌ **Constructors in Fragments**: Fragments must have empty constructor (System recreates them). Use Hilt `@AndroidEntryPoint`.

---

## Related Skills

- `@senior-kotlin-developer` - Language deep dive
- `@mobile-security-tester` - Securing the APK
- `@senior-ui-ux-designer` - Material Design 3 guidelines

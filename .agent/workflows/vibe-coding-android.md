---
description: Initialize Vibe Coding context files for Android native application with Kotlin and Jetpack Compose
---

# /vibe-coding-android

Workflow untuk setup dokumen konteks Vibe Coding khusus **Android Native** dengan Kotlin dan Jetpack Compose.

---

## 📋 Prerequisites

1. **Deskripsi ide aplikasi** (2-3 paragraf)
2. **Target Android version** (min SDK)
3. **Architecture preference** (MVVM / MVI / Clean Architecture)
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

Skill: `senior-project-manager` + `senior-android-developer`

```markdown
Buatkan PRD.md untuk Android app: [IDE]
- Executive Summary
- Problem Statement
- Target User & Persona (Android users)
- User Stories (min 10 untuk MVP)
- Core Features dengan MoSCoW
- Android-specific requirements (permissions, hardware)
- Success Metrics (DAU, Crash-free rate, ANR rate)
```

// turbo
**Simpan ke `PRD.md`**

---

### Step 1.2: Generate TECH_STACK.md

Skill: `tech-stack-architect` + `senior-android-developer`

```markdown
## Core Stack
- Language: Kotlin 1.9+
- Min SDK: 24 (Android 7.0)
- Target SDK: 34 (Android 14)
- UI: Jetpack Compose 1.5+
- Build: Gradle 8.x dengan Kotlin DSL

## Architecture
- Pattern: MVVM / MVI dengan Clean Architecture
- DI: Hilt (Dagger)
- Navigation: Navigation Compose
- State: StateFlow / SharedFlow

## Jetpack Libraries
- Lifecycle: ViewModel, LiveData (optional)
- Room: Local database
- DataStore: Preferences storage
- WorkManager: Background tasks
- Paging 3: Pagination

## Networking
- Retrofit 2.9+
- OkHttp 4.x
- Kotlinx Serialization / Moshi

## Async
- Coroutines 1.7+
- Flow

## Image Loading
- Coil (Compose native)

## Testing
- JUnit 5
- MockK
- Turbine (Flow testing)
- Compose UI Testing

## Approved Dependencies (build.gradle.kts)
```kotlin
dependencies {
    // Compose BOM
    implementation(platform("androidx.compose:compose-bom:2024.01.00"))
    implementation("androidx.compose.ui:ui")
    implementation("androidx.compose.material3:material3")
    implementation("androidx.compose.ui:ui-tooling-preview")
    
    // Architecture
    implementation("androidx.lifecycle:lifecycle-viewmodel-compose:2.7.0")
    implementation("androidx.navigation:navigation-compose:2.7.6")
    implementation("com.google.dagger:hilt-android:2.50")
    kapt("com.google.dagger:hilt-compiler:2.50")
    
    // Networking
    implementation("com.squareup.retrofit2:retrofit:2.9.0")
    implementation("com.squareup.okhttp3:okhttp:4.12.0")
    implementation("org.jetbrains.kotlinx:kotlinx-serialization-json:1.6.2")
    
    // Local Storage
    implementation("androidx.room:room-runtime:2.6.1")
    implementation("androidx.room:room-ktx:2.6.1")
    kapt("androidx.room:room-compiler:2.6.1")
    implementation("androidx.datastore:datastore-preferences:1.0.0")
    
    // Image
    implementation("io.coil-kt:coil-compose:2.5.0")
    
    // Testing
    testImplementation("junit:junit:4.13.2")
    testImplementation("io.mockk:mockk:1.13.9")
    testImplementation("app.cash.turbine:turbine:1.0.0")
    androidTestImplementation("androidx.compose.ui:ui-test-junit4")
}
```

## Constraints

- Package di luar daftar tanyakan dulu
- WAJIB Kotlin, DILARANG Java untuk kode baru
- WAJIB Compose, DILARANG XML layouts
- Semua async dengan Coroutines + Flow

```

// turbo
**Simpan ke `TECH_STACK.md`**

---

### Step 1.3: Generate RULES.md

Skill: `senior-android-developer` + `senior-kotlin-developer`

```markdown
## Kotlin Rules
- Kotlin 1.9+ features
- DILARANG `!!` (force unwrap), gunakan safe calls
- Prefer `val` over `var`
- Use data classes untuk models
- Sealed classes untuk UI states
- Extension functions untuk utilities

## Compose Rules
- Stateless composables by default
- State hoisting ke ViewModel
- Remember untuk expensive computations
- LaunchedEffect untuk side effects
- Modifier sebagai parameter pertama setelah required params
- Preview dengan @Preview annotation

## Architecture Rules
- MVVM/MVI dengan single source of truth
- ViewModel untuk UI logic
- Repository pattern untuk data
- Use cases untuk business logic (Clean Architecture)
- Dependency Injection dengan Hilt

## State Management
- StateFlow untuk UI state
- SharedFlow untuk one-time events
- Immutable state dengan copy()
- Sealed class untuk UI State:
  ```kotlin
  sealed interface UiState<out T> {
      data object Loading : UiState<Nothing>
      data class Success<T>(val data: T) : UiState<T>
      data class Error(val message: String) : UiState<Nothing>
  }
  ```

## Coroutines Rules

- viewModelScope untuk ViewModel coroutines
- lifecycleScope untuk UI coroutines
- Dispatchers.IO untuk network/disk
- Dispatchers.Default untuk CPU-intensive
- SELALU handle exceptions dengan try-catch

## Error Handling

- Result wrapper untuk repository
- Custom exceptions untuk domain errors
- User-friendly messages di UI
- Crashlytics untuk production logging

## Naming Conventions

- Packages: lowercase (com.example.feature)
- Classes: PascalCase
- Functions: camelCase
- Constants: SCREAMING_SNAKE_CASE
- Composables: PascalCase (karena fungsi yang return UI)

## AI Behavior Rules

1. JANGAN import dependency tidak ada di build.gradle
2. JANGAN gunakan deprecated APIs
3. JANGAN hardcode strings, gunakan strings.xml
4. IKUTI Material 3 guidelines
5. SELALU handle configuration changes
6. SELALU handle process death
7. Test di multiple screen sizes

```

// turbo
**Simpan ke `RULES.md`**

---

## 🎨 Phase 2: Support System

### Step 2.1: Generate DESIGN_SYSTEM.md

Skill: `design-system-architect` + `senior-android-developer`

```markdown
## Material 3 Theme

### Color Scheme
```kotlin
// ui/theme/Color.kt
val md_theme_light_primary = Color(0xFF6750A4)
val md_theme_light_onPrimary = Color(0xFFFFFFFF)
// ... define full color scheme

val LightColorScheme = lightColorScheme(
    primary = md_theme_light_primary,
    onPrimary = md_theme_light_onPrimary,
    // ...
)

val DarkColorScheme = darkColorScheme(
    // ...
)
```

### Typography

```kotlin
// ui/theme/Type.kt
val Typography = Typography(
    displayLarge = TextStyle(
        fontFamily = FontFamily.Default,
        fontWeight = FontWeight.Normal,
        fontSize = 57.sp,
        lineHeight = 64.sp,
    ),
    // ... define all text styles
)
```

### Shapes

```kotlin
// ui/theme/Shape.kt
val Shapes = Shapes(
    extraSmall = RoundedCornerShape(4.dp),
    small = RoundedCornerShape(8.dp),
    medium = RoundedCornerShape(12.dp),
    large = RoundedCornerShape(16.dp),
    extraLarge = RoundedCornerShape(28.dp),
)
```

### Spacing

```kotlin
// ui/theme/Spacing.kt
object Spacing {
    val xs = 4.dp
    val sm = 8.dp
    val md = 16.dp
    val lg = 24.dp
    val xl = 32.dp
    val xxl = 48.dp
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

app/
├── src/main/
│   ├── java/com/example/app/
│   │   ├── di/                      # Hilt modules
│   │   │   ├── AppModule.kt
│   │   │   ├── NetworkModule.kt
│   │   │   └── DatabaseModule.kt
│   │   │
│   │   ├── data/                    # Data layer
│   │   │   ├── remote/
│   │   │   │   ├── api/
│   │   │   │   │   └── UserApi.kt
│   │   │   │   └── dto/
│   │   │   │       └── UserDto.kt
│   │   │   ├── local/
│   │   │   │   ├── dao/
│   │   │   │   │   └── UserDao.kt
│   │   │   │   └── entity/
│   │   │   │       └── UserEntity.kt
│   │   │   └── repository/
│   │   │       └── UserRepositoryImpl.kt
│   │   │
│   │   ├── domain/                  # Domain layer
│   │   │   ├── model/
│   │   │   │   └── User.kt
│   │   │   ├── repository/
│   │   │   │   └── UserRepository.kt
│   │   │   └── usecase/
│   │   │       ├── GetUserUseCase.kt
│   │   │       └── LoginUseCase.kt
│   │   │
│   │   ├── presentation/            # Presentation layer
│   │   │   ├── navigation/
│   │   │   │   └── AppNavigation.kt
│   │   │   ├── components/          # Reusable composables
│   │   │   │   ├── AppButton.kt
│   │   │   │   └── AppTextField.kt
│   │   │   └── screens/
│   │   │       ├── home/
│   │   │       │   ├── HomeScreen.kt
│   │   │       │   ├── HomeViewModel.kt
│   │   │       │   └── HomeUiState.kt
│   │   │       └── auth/
│   │   │           ├── LoginScreen.kt
│   │   │           └── LoginViewModel.kt
│   │   │
│   │   ├── ui/theme/                # Compose theme
│   │   │   ├── Color.kt
│   │   │   ├── Type.kt
│   │   │   ├── Shape.kt
│   │   │   └── Theme.kt
│   │   │
│   │   ├── util/                    # Utilities
│   │   │   ├── Resource.kt
│   │   │   └── Extensions.kt
│   │   │
│   │   └── App.kt                   # Application class
│   │
│   └── res/
│       ├── values/
│       │   ├── strings.xml
│       │   └── themes.xml
│       └── drawable/
│
├── build.gradle.kts
└── proguard-rules.pro

```

## Naming Conventions
- Screens: `XxxScreen.kt`
- ViewModels: `XxxViewModel.kt`
- UseCases: `XxxUseCase.kt`
- Repositories: `XxxRepository.kt` (interface), `XxxRepositoryImpl.kt`
- DAOs: `XxxDao.kt`
- DTOs: `XxxDto.kt`
- Entities: `XxxEntity.kt`
```

// turbo
**Simpan ke `FOLDER_STRUCTURE.md`**

---

### Step 2.3: Generate EXAMPLES.md

Skill: `senior-android-developer`

```markdown
## 1. ViewModel Pattern

```kotlin
@HiltViewModel
class HomeViewModel @Inject constructor(
    private val getUserUseCase: GetUserUseCase
) : ViewModel() {

    private val _uiState = MutableStateFlow<UiState<User>>(UiState.Loading)
    val uiState: StateFlow<UiState<User>> = _uiState.asStateFlow()

    init {
        loadUser()
    }

    fun loadUser() {
        viewModelScope.launch {
            _uiState.value = UiState.Loading
            try {
                val user = getUserUseCase()
                _uiState.value = UiState.Success(user)
            } catch (e: Exception) {
                _uiState.value = UiState.Error(e.message ?: "Unknown error")
            }
        }
    }
}
```

## 2. Composable Screen

```kotlin
@Composable
fun HomeScreen(
    viewModel: HomeViewModel = hiltViewModel(),
    onNavigateToDetail: (String) -> Unit
) {
    val uiState by viewModel.uiState.collectAsStateWithLifecycle()

    when (val state = uiState) {
        is UiState.Loading -> LoadingIndicator()
        is UiState.Success -> HomeContent(
            user = state.data,
            onItemClick = onNavigateToDetail
        )
        is UiState.Error -> ErrorMessage(
            message = state.message,
            onRetry = viewModel::loadUser
        )
    }
}

@Composable
private fun HomeContent(
    user: User,
    onItemClick: (String) -> Unit,
    modifier: Modifier = Modifier
) {
    Column(modifier = modifier.padding(16.dp)) {
        Text(
            text = "Welcome, ${user.name}",
            style = MaterialTheme.typography.headlineMedium
        )
        // ...
    }
}
```

## 3. Repository Pattern

```kotlin
interface UserRepository {
    suspend fun getUser(id: String): User
    fun observeUsers(): Flow<List<User>>
}

class UserRepositoryImpl @Inject constructor(
    private val api: UserApi,
    private val dao: UserDao
) : UserRepository {

    override suspend fun getUser(id: String): User {
        return try {
            val dto = api.getUser(id)
            val entity = dto.toEntity()
            dao.insert(entity)
            entity.toDomain()
        } catch (e: Exception) {
            dao.getById(id)?.toDomain() 
                ?: throw UserNotFoundException(id)
        }
    }

    override fun observeUsers(): Flow<List<User>> {
        return dao.observeAll().map { entities ->
            entities.map { it.toDomain() }
        }
    }
}
```

## 4. Navigation

```kotlin
@Composable
fun AppNavigation(
    navController: NavHostController = rememberNavController()
) {
    NavHost(
        navController = navController,
        startDestination = "home"
    ) {
        composable("home") {
            HomeScreen(
                onNavigateToDetail = { id ->
                    navController.navigate("detail/$id")
                }
            )
        }
        composable(
            route = "detail/{id}",
            arguments = listOf(navArgument("id") { type = NavType.StringType })
        ) { backStackEntry ->
            val id = backStackEntry.arguments?.getString("id") ?: return@composable
            DetailScreen(id = id)
        }
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
# Create new Android project dengan Android Studio
# atau gunakan template:
mkdir -p app/src/main/java/com/example/app/{di,data,domain,presentation,ui/theme,util}
```

---

## 📁 Checklist

```
BRAINSTORM.md, PRD.md, TECH_STACK.md, RULES.md,
DESIGN_SYSTEM.md, FOLDER_STRUCTURE.md, EXAMPLES.md
```

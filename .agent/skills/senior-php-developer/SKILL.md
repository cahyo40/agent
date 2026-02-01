---
name: senior-php-developer
description: "Expert PHP development including modern PHP 8+, Laravel/Symfony, Composer, testing, and production-ready web applications"
---

# Senior PHP Developer

## Overview

Master modern PHP development with PHP 8+ features, Laravel/Symfony frameworks, Composer, testing, and production-ready applications.

## When to Use This Skill

- Use when building PHP applications
- Use when working with Laravel/Symfony
- Use when modernizing legacy PHP
- Use when PHP backend development

## How It Works

### Step 1: Modern PHP 8+ Features

```php
<?php
declare(strict_types=1);

// Constructor property promotion
class User {
    public function __construct(
        public readonly int $id,
        public string $name,
        public string $email,
        private ?string $password = null
    ) {}
}

// Named arguments
$user = new User(
    id: 1,
    name: 'John',
    email: 'john@example.com'
);

// Match expression
$status = match($code) {
    200, 201 => 'Success',
    400 => 'Bad Request',
    404 => 'Not Found',
    500 => 'Server Error',
    default => 'Unknown'
};

// Nullsafe operator
$country = $user?->getAddress()?->getCountry()?->getName();

// Enums
enum OrderStatus: string {
    case Pending = 'pending';
    case Processing = 'processing';
    case Completed = 'completed';
    case Cancelled = 'cancelled';
}

// Attributes
#[Route('/api/users', methods: ['GET'])]
#[Middleware('auth')]
public function index(): JsonResponse
{
    // ...
}
```

### Step 2: Laravel Essentials

```php
// Controller
class UserController extends Controller
{
    public function __construct(
        private UserService $userService
    ) {}

    public function index(Request $request): JsonResponse
    {
        $users = $this->userService->paginate(
            perPage: $request->input('per_page', 15)
        );
        return response()->json($users);
    }

    public function store(StoreUserRequest $request): JsonResponse
    {
        $user = $this->userService->create($request->validated());
        return response()->json($user, 201);
    }
}

// Form Request
class StoreUserRequest extends FormRequest
{
    public function rules(): array
    {
        return [
            'name' => ['required', 'string', 'max:255'],
            'email' => ['required', 'email', 'unique:users'],
            'password' => ['required', 'min:8', 'confirmed'],
        ];
    }
}

// Eloquent Model
class User extends Model
{
    protected $fillable = ['name', 'email', 'password'];
    protected $hidden = ['password'];
    protected $casts = [
        'email_verified_at' => 'datetime',
    ];

    public function orders(): HasMany
    {
        return $this->hasMany(Order::class);
    }

    public function scopeActive(Builder $query): Builder
    {
        return $query->where('status', 'active');
    }
}
```

### Step 3: Testing

```php
class UserTest extends TestCase
{
    use RefreshDatabase;

    public function test_can_create_user(): void
    {
        $response = $this->postJson('/api/users', [
            'name' => 'John Doe',
            'email' => 'john@example.com',
            'password' => 'password123',
            'password_confirmation' => 'password123',
        ]);

        $response->assertStatus(201)
            ->assertJsonStructure(['id', 'name', 'email']);
        
        $this->assertDatabaseHas('users', [
            'email' => 'john@example.com'
        ]);
    }

    public function test_email_must_be_unique(): void
    {
        User::factory()->create(['email' => 'john@example.com']);

        $response = $this->postJson('/api/users', [
            'email' => 'john@example.com',
        ]);

        $response->assertStatus(422)
            ->assertJsonValidationErrors(['email']);
    }
}
```

## Best Practices

### ✅ Do This

- ✅ Use strict types
- ✅ Use dependency injection
- ✅ Follow PSR standards
- ✅ Use Composer autoloading
- ✅ Write tests

### ❌ Avoid This

- ❌ Don't use global variables
- ❌ Don't ignore type hints
- ❌ Don't skip validation
- ❌ Don't use deprecated features

## Related Skills

- `@senior-laravel-developer` - Laravel framework
- `@senior-backend-developer` - Backend patterns

---
description: Initialize Vibe Coding context files for Laravel backend/full-stack application
---

# /vibe-coding-laravel

Workflow untuk setup dokumen konteks Vibe Coding khusus **Laravel Backend/Full-Stack**.

---

## 📋 Prerequisites

1. **Deskripsi aplikasi**
2. **Tipe: API only / Full-stack dengan Blade / Inertia.js?**
3. **Frontend (jika Inertia): Vue / React?**
4. **Database: MySQL / PostgreSQL?**

---

## 🏗️ Phase 1: Holy Trinity

### Step 1.1: Generate PRD.md

Skill: `senior-project-manager`

```markdown
Buatkan PRD.md untuk Laravel app: [IDE]
- Executive Summary, Problem, Target User
- User Stories (10+ MVP)
- Features: Must/Should/Could/Won't
- Success Metrics
```

// turbo
**Simpan ke `PRD.md`**

---

### Step 1.2: Generate TECH_STACK.md

Skill: `tech-stack-architect` + `senior-laravel-developer`

```markdown
## Core Stack
- PHP: 8.2+
- Laravel: 11.x
- Server: Nginx + PHP-FPM / Laravel Octane

## Database
- Database: MySQL 8 / PostgreSQL 15
- ORM: Eloquent
- Migrations: Laravel migrations

## Frontend (pilih salah satu)
### Option A: API Only
- Sanctum untuk SPA auth
- API Resources untuk response

### Option B: Blade + Livewire
- Blade templates
- Livewire 3 untuk interactivity
- Alpine.js untuk JS

### Option C: Inertia.js
- Inertia.js 1.x
- Vue 3 / React
- TypeScript optional

## Authentication
- Laravel Breeze / Jetstream (Breeze preferred for simple apps)
- Sanctum untuk API tokens (Default for API)

## File Storage
- Laravel Filesystem
- S3 untuk production

## Queue
- Laravel Queues
- Redis driver (Horizon for monitoring)

## Approved Packages (composer.json)
```json
{
  "require": {
    "php": "^8.2",
    "laravel/framework": "^11.0",
    "laravel/sanctum": "^4.0",
    "laravel/horizon": "^5.0",
    "spatie/laravel-permission": "^6.0",
    "spatie/laravel-query-builder": "^5.0",
    "spatie/laravel-medialibrary": "^11.0"
  },
  "require-dev": {
    "laravel/pint": "^1.0",
    "pestphp/pest": "^2.0",
    "pestphp/pest-plugin-laravel": "^2.0",
    "spatie/laravel-ignition": "^2.0"
  }
}
```

## Constraints

- WAJIB PHP 8.2+ features (readonly, enums, match, constructor promotion)
- WAJIB strict types (`declare(strict_types=1);`)
- Laravel Pint untuk formatting
- SELALU gunakan native type hints untuk parameters dan return types

```

// turbo
**Simpan ke `TECH_STACK.md`**

---

### Step 1.3: Generate RULES.md

Skill: `senior-laravel-developer`

```markdown
## PHP Standards
- PHP 8.2+ features
- Strict types (`declare(strict_types=1);`)
- PSR-12 coding style via Laravel Pint
- SELALU gunakan constructor promotion jika memungkinkan

## Laravel Conventions
- Fat Models, Thin Controllers
- **Service Layer** untuk kompleks business logic
- **Repository Pattern** untuk data access abstraction (opsional namun disarankan)
- Form Requests untuk validation
- API Resources untuk response transformation
- Policies/Gate untuk authorization

## Naming Convention
- Models: `PascalCase` singular (`User`, `Order`)
- Controllers: `PascalCase` + `Controller` (`OrderController`)
- Services: `PascalCase` + `Service` (`OrderService`)
- Repositories: `PascalCase` + `Repository` (`OrderRepository`)
- Migrations: `snake_case` dengan timestamp
- API Routes: `kebab-case` (`/api/v1/user-profiles`)

## Database Rules
- SELALU gunakan migrations
- JANGAN edit migration yang sudah production (gunakan migration baru)
- Eloquent relationships WAJIB didefinisikan dengan type hints
- Eager loading (`with()`) untuk menghindari N+1 query problem
- Gunakan Database Transactions (`DB::transaction`) untuk multi-step writes

## Controller Rules
- Single responsibility (Thin Controllers)
- Max 5-7 methods per controller
- Resource controllers untuk CRUD
- JANGAN letakkan business logic di controller

## Validation Rules
- Gunakan Form Request classes
- JANGAN validate di controller
- Custom rules di `App\Rules` jika diperlukan

## API Response
- API Resources untuk transformation
- Consistent format: `data`, `message`, `meta` (untuk pagination)
- Proper HTTP status codes (200, 201, 204, 403, 404, 422)

## AI Behavior Rules
1. JANGAN install package tidak ada di `composer.json` tanpa izin
2. JANGAN gunakan raw SQL queries kecuali performansi sangat kritikal
3. SELALU gunakan Form Request untuk setiap input validation
4. SELALU gunakan API Resources untuk output data
5. Refer ke `DB_SCHEMA.md` sebelum membuat migrations baru
6. Refer ke `API_CONTRACT.md` sebelum membuat routes baru
7. Gunakan Service Layer untuk logika yang melibatkan lebih dari satu model
```

// turbo
**Simpan ke `RULES.md`**

---

## 🎨 Phase 2: Support System

### Step 2.1: FOLDER_STRUCTURE.md

```text
app/
├── Console/                     # Artisan commands
├── Exceptions/                  # Custom exceptions
├── Http/
│   ├── Controllers/
│   │   ├── Api/                 # API controllers
│   │   └── Web/                 # Web controllers
│   ├── Middleware/
│   ├── Requests/                # Form Requests
│   └── Resources/               # API Resources
├── Models/                      # Eloquent models
├── Policies/                    # Authorization
├── Providers/
├── Services/                    # Business logic (Required for complex apps)
└── Repositories/                # Data access (Recommended for abstraction)

database/
├── factories/
├── migrations/
├── seeders/

resources/
├── views/                       # Blade templates
│   ├── layouts/
│   ├── components/
│   └── pages/
└── js/                          # Jika Inertia
    └── Pages/

routes/
├── api.php                      # API routes
├── web.php                      # Web routes
└── console.php                  # Console routes

tests/
├── Feature/
│   ├── Api/                     # API feature tests
│   └── Web/                     # Web feature tests
└── Unit/
```

## Naming Conventions

- Model: `User.php` (singular, PascalCase)
- Controller: `UserController.php`
- Service: `UserService.php`
- Repository: `UserRepository.php`
- Request: `StoreUserRequest.php`, `UpdateUserRequest.php`
- Resource: `UserResource.php`, `UserCollection.php`
- Migration: `2024_01_01_000000_create_users_table.php`
- Seeder: `UserSeeder.php`

```

// turbo
**Simpan ke `FOLDER_STRUCTURE.md`**

---

### Step 2.2: EXAMPLES.md

```markdown
## 1. Model (Eloquent)

```php
<?php
declare(strict_types=1);

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Laravel\Sanctum\HasApiTokens;

class User extends Authenticatable
{
    use HasApiTokens;

    protected $fillable = ['name', 'email', 'password'];

    protected $hidden = ['password', 'remember_token'];

    protected function casts(): array
    {
        return [
            'email_verified_at' => 'datetime',
            'password' => 'hashed',
        ];
    }

    public function orders(): HasMany
    {
        return $this->hasMany(Order::class);
    }
}
```

## 2. Service & Repository Layer

```php
<?php
// app/Services/UserService.php
namespace App\Services;

use App\Models\User;
use App\Repositories\UserRepository;
use Illuminate\Support\Facades\DB;

class UserService
{
    public function __construct(
        private UserRepository $userRepository
    ) {}

    public function register(array $data): User
    {
        return DB::transaction(fn() => $this->userRepository->create($data));
    }
}

// app/Repositories/UserRepository.php
namespace App\Repositories;

use App\Models\User;

class UserRepository
{
    public function create(array $data): User
    {
        return User::create($data);
    }
}
```

## 3. Form Request

```php
<?php
declare(strict_types=1);

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class StoreUserRequest extends FormRequest
{
    public function authorize(): bool { return true; }

    public function rules(): array
    {
        return [
            'name' => ['required', 'string', 'max:255'],
            'email' => ['required', 'email', 'unique:users,email'],
            'password' => ['required', 'string', 'min:8'],
        ];
    }
}
```

## 4. Controller (Thin)

```php
<?php
declare(strict_types=1);

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\StoreUserRequest;
use App\Http\Resources\UserResource;
use App\Services\UserService;

class UserController extends Controller
{
    public function __construct(
        private UserService $userService
    ) {}

    public function store(StoreUserRequest $request): UserResource
    {
        $user = $this->userService->register($request->validated());
        return new UserResource($user);
    }
}
```

## 5. Migration

```php
<?php
use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('users', function (Blueprint $table) {
            $table->id();
            $table->string('name');
            $table->string('email')->unique();
            $table->timestamp('email_verified_at')->nullable();
            $table->string('password');
            $table->rememberToken();
            $table->timestamps();
        });
    }
};
```

```

// turbo
**Simpan ke `EXAMPLES.md`**

---

## ✅ Phase 3: Project Setup

// turbo
```bash
composer create-project laravel/laravel . --prefer-dist
php artisan install:api  # Setup API routes + Sanctum
composer require spatie/laravel-permission spatie/laravel-query-builder spatie/laravel-medialibrary
composer require --dev pestphp/pest pestphp/pest-plugin-laravel
./vendor/bin/pest --init
```

---

## 📁 Checklist

```text
PRD.md, TECH_STACK.md, RULES.md, DB_SCHEMA.md,
FOLDER_STRUCTURE.md, API_CONTRACT.md, EXAMPLES.md
```

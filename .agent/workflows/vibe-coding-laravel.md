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
- Livewire 3 untuk interaktivity
- Alpine.js untuk JS

### Option C: Inertia.js
- Inertia.js 1.x
- Vue 3 / React
- TypeScript optional

## Authentication
- Laravel Breeze / Jetstream
- Sanctum untuk API tokens

## File Storage
- Laravel Filesystem
- S3 untuk production

## Queue
- Laravel Queues
- Redis driver

## Approved Packages (composer.json)
```json
{
  "require": {
    "php": "^8.2",
    "laravel/framework": "^11.0",
    "laravel/sanctum": "^4.0",
    "laravel/horizon": "^5.0",
    "spatie/laravel-permission": "^6.0",
    "spatie/laravel-query-builder": "^5.0"
  },
  "require-dev": {
    "laravel/pint": "^1.0",
    "pestphp/pest": "^2.0",
    "pestphp/pest-plugin-laravel": "^2.0"
  }
}
```

## Constraints

- WAJIB PHP 8.2+ features (readonly, enums, match)
- WAJIB strict types
- Laravel Pint untuk formatting

```

// turbo
**Simpan ke `TECH_STACK.md`**

---

### Step 1.3: Generate RULES.md

Skill: `senior-laravel-developer`

```markdown
## PHP Standards
- PHP 8.2+ features
- Strict types (`declare(strict_types=1)`)
- PSR-12 coding style
- Laravel Pint untuk formatting

## Laravel Conventions
- Fat Models, Thin Controllers
- Form Requests untuk validation
- API Resources untuk response transformation
- Policies untuk authorization

## Naming Convention
- Models: PascalCase singular (User, Post)
- Controllers: PascalCase + Controller (UserController)
- Migrations: snake_case dengan timestamp
- Routes: kebab-case

## Database Rules
- SELALU gunakan migrations
- JANGAN edit migration yang sudah production
- Eloquent relationships WAJIB didefinisikan
- Eager loading untuk avoid N+1

## Controller Rules
- Single responsibility
- Max 5-7 methods per controller
- Resource controllers untuk CRUD
- Invokable controllers untuk single action

## Validation Rules
- Form Request classes
- JANGAN validate di controller
- Custom rules di App\Rules

## API Response
- API Resources untuk transformation
- Consistent format: data, message, errors
- Proper HTTP status codes

## AI Behavior Rules
1. JANGAN install package tidak ada di composer.json
2. JANGAN raw queries kecuali perlu
3. SELALU gunakan Form Request
4. SELALU gunakan API Resources
5. Refer ke DB_SCHEMA.md untuk migrations
6. Refer ke API_CONTRACT.md untuk routes
```

// turbo
**Simpan ke `RULES.md`**

---

## 🎨 Phase 2: Support System

### Step 2.1: FOLDER_STRUCTURE.md

```markdown
## Laravel 11 Structure

```

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
├── Services/                    # Business logic (custom)
└── Repositories/                # Data access (custom)

database/
├── factories/
├── migrations/
└── seeders/

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
└── Unit/

```

## Naming Conventions
- Model: `User.php` (singular, PascalCase)
- Controller: `UserController.php`
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
## 1. Model
```php
<?php
declare(strict_types=1);

namespace App\Models;

use Illuminate\Database\Eloquent\Concerns\HasUuids;
use Illuminate\Foundation\Auth\User as Authenticatable;

class User extends Authenticatable
{
    use HasUuids;

    protected $fillable = [
        'name',
        'email',
        'password',
    ];

    protected $hidden = [
        'password',
        'remember_token',
    ];

    protected function casts(): array
    {
        return [
            'email_verified_at' => 'datetime',
            'password' => 'hashed',
        ];
    }

    public function posts(): HasMany
    {
        return $this->hasMany(Post::class);
    }
}
```

## 2. Form Request

```php
<?php
declare(strict_types=1);

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class StoreUserRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'name' => ['required', 'string', 'max:255'],
            'email' => ['required', 'email', 'unique:users,email'],
            'password' => ['required', 'string', 'min:8', 'confirmed'],
        ];
    }
}
```

## 3. API Resource

```php
<?php
declare(strict_types=1);

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class UserResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'name' => $this->name,
            'email' => $this->email,
            'created_at' => $this->created_at->toISOString(),
        ];
    }
}
```

## 4. Controller

```php
<?php
declare(strict_types=1);

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\StoreUserRequest;
use App\Http\Resources\UserResource;
use App\Models\User;
use Illuminate\Http\JsonResponse;

class UserController extends Controller
{
    public function index(): JsonResponse
    {
        $users = User::paginate(15);
        return UserResource::collection($users)->response();
    }

    public function store(StoreUserRequest $request): JsonResponse
    {
        $user = User::create($request->validated());
        return (new UserResource($user))
            ->response()
            ->setStatusCode(201);
    }

    public function show(User $user): UserResource
    {
        return new UserResource($user);
    }
}
```

## 5. API Routes

```php
// routes/api.php
Route::middleware('auth:sanctum')->group(function () {
    Route::apiResource('users', UserController::class);
});
```

## 6. Migration

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
            $table->uuid('id')->primary();
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
composer require spatie/laravel-permission spatie/laravel-query-builder
composer require --dev pestphp/pest pestphp/pest-plugin-laravel
./vendor/bin/pest --init
```

---

## 📁 Checklist

```
PRD.md, TECH_STACK.md, RULES.md, DB_SCHEMA.md,
FOLDER_STRUCTURE.md, API_CONTRACT.md, EXAMPLES.md
```

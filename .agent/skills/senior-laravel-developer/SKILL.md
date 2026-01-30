---
name: senior-laravel-developer
description: "Expert Laravel development including Eloquent ORM, API development, authentication, queues, and production-ready PHP applications"
---

# Senior Laravel Developer

## Overview

This skill helps you build robust web applications and APIs using Laravel with PHP best practices.

## When to Use This Skill

- Use when building PHP applications
- Use when creating REST APIs with Laravel
- Use when working with Eloquent ORM

## How It Works

### Step 1: Project Structure

```text
laravel-app/
├── app/
│   ├── Http/
│   │   ├── Controllers/
│   │   ├── Middleware/
│   │   ├── Requests/
│   │   └── Resources/
│   ├── Models/
│   ├── Services/
│   ├── Repositories/
│   └── Exceptions/
├── config/
├── database/
│   ├── factories/
│   ├── migrations/
│   └── seeders/
├── routes/
│   ├── api.php
│   └── web.php
├── tests/
└── .env
```

### Step 2: Models & Relationships

```php
<?php
// app/Models/User.php

namespace App\Models;

use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Laravel\Sanctum\HasApiTokens;

class User extends Authenticatable
{
    use HasApiTokens;

    protected $fillable = ['name', 'email', 'password'];
    
    protected $hidden = ['password', 'remember_token'];
    
    protected $casts = [
        'email_verified_at' => 'datetime',
        'password' => 'hashed',
    ];
    
    public function orders(): HasMany
    {
        return $this->hasMany(Order::class);
    }
    
    public function activeOrders(): HasMany
    {
        return $this->orders()->where('status', 'active');
    }
}

// app/Models/Order.php
class Order extends Model
{
    protected $fillable = ['user_id', 'status', 'total'];
    
    protected $casts = [
        'total' => 'decimal:2',
    ];
    
    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }
    
    public function items(): HasMany
    {
        return $this->hasMany(OrderItem::class);
    }
    
    // Scopes
    public function scopeActive($query)
    {
        return $query->where('status', 'active');
    }
    
    public function scopeRecent($query, int $days = 7)
    {
        return $query->where('created_at', '>=', now()->subDays($days));
    }
}
```

### Step 3: Controllers & Resources

```php
<?php
// app/Http/Controllers/Api/OrderController.php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\StoreOrderRequest;
use App\Http\Resources\OrderResource;
use App\Models\Order;
use App\Services\OrderService;
use Illuminate\Http\Resources\Json\AnonymousResourceCollection;

class OrderController extends Controller
{
    public function __construct(
        private OrderService $orderService
    ) {}
    
    public function index(): AnonymousResourceCollection
    {
        $orders = Order::query()
            ->with(['user', 'items.product'])
            ->active()
            ->latest()
            ->paginate(15);
            
        return OrderResource::collection($orders);
    }
    
    public function store(StoreOrderRequest $request): OrderResource
    {
        $order = $this->orderService->create(
            $request->user(),
            $request->validated()
        );
        
        return new OrderResource($order->load('items'));
    }
    
    public function show(Order $order): OrderResource
    {
        $this->authorize('view', $order);
        
        return new OrderResource($order->load(['user', 'items.product']));
    }
}

// app/Http/Resources/OrderResource.php
class OrderResource extends JsonResource
{
    public function toArray($request): array
    {
        return [
            'id' => $this->id,
            'status' => $this->status,
            'total' => $this->total,
            'user' => new UserResource($this->whenLoaded('user')),
            'items' => OrderItemResource::collection($this->whenLoaded('items')),
            'created_at' => $this->created_at->toISOString(),
        ];
    }
}
```

### Step 4: Form Requests & Validation

```php
<?php
// app/Http/Requests/StoreOrderRequest.php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class StoreOrderRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }
    
    public function rules(): array
    {
        return [
            'items' => ['required', 'array', 'min:1'],
            'items.*.product_id' => ['required', 'exists:products,id'],
            'items.*.quantity' => ['required', 'integer', 'min:1', 'max:100'],
            'shipping_address' => ['required', 'string', 'max:500'],
            'notes' => ['nullable', 'string', 'max:1000'],
        ];
    }
    
    public function messages(): array
    {
        return [
            'items.required' => 'Please add at least one item to your order.',
            'items.*.product_id.exists' => 'Selected product does not exist.',
        ];
    }
}
```

### Step 5: Services & Repositories

```php
<?php
// app/Services/OrderService.php

namespace App\Services;

use App\Models\Order;
use App\Models\User;
use App\Repositories\OrderRepository;
use App\Events\OrderCreated;
use Illuminate\Support\Facades\DB;

class OrderService
{
    public function __construct(
        private OrderRepository $orderRepository
    ) {}
    
    public function create(User $user, array $data): Order
    {
        return DB::transaction(function () use ($user, $data) {
            $order = $this->orderRepository->create([
                'user_id' => $user->id,
                'status' => 'pending',
                'total' => 0,
            ]);
            
            $total = 0;
            foreach ($data['items'] as $item) {
                $product = Product::findOrFail($item['product_id']);
                
                $order->items()->create([
                    'product_id' => $product->id,
                    'quantity' => $item['quantity'],
                    'price' => $product->price,
                ]);
                
                $total += $product->price * $item['quantity'];
            }
            
            $order->update(['total' => $total]);
            
            event(new OrderCreated($order));
            
            return $order;
        });
    }
}

// app/Repositories/OrderRepository.php
class OrderRepository
{
    public function create(array $data): Order
    {
        return Order::create($data);
    }
    
    public function findByUser(User $user, int $perPage = 15)
    {
        return Order::where('user_id', $user->id)
            ->with('items.product')
            ->latest()
            ->paginate($perPage);
    }
}
```

### Step 6: Queues & Jobs

```php
<?php
// app/Jobs/ProcessOrder.php

namespace App\Jobs;

use App\Models\Order;
use App\Notifications\OrderConfirmation;
use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Queue\InteractsWithQueue;
use Illuminate\Queue\SerializesModels;

class ProcessOrder implements ShouldQueue
{
    use Queueable, InteractsWithQueue, SerializesModels;
    
    public int $tries = 3;
    public int $backoff = 60;
    
    public function __construct(
        public Order $order
    ) {}
    
    public function handle(): void
    {
        // Process payment
        $this->processPayment();
        
        // Update inventory
        $this->updateInventory();
        
        // Send notification
        $this->order->user->notify(new OrderConfirmation($this->order));
        
        // Update status
        $this->order->update(['status' => 'completed']);
    }
    
    public function failed(\Throwable $exception): void
    {
        $this->order->update(['status' => 'failed']);
        Log::error('Order processing failed', [
            'order_id' => $this->order->id,
            'error' => $exception->getMessage(),
        ]);
    }
}

// Dispatching
ProcessOrder::dispatch($order)->onQueue('orders');
```

### Step 7: Authentication (Sanctum)

```php
<?php
// routes/api.php
use App\Http\Controllers\Api\AuthController;

Route::post('/register', [AuthController::class, 'register']);
Route::post('/login', [AuthController::class, 'login']);

Route::middleware('auth:sanctum')->group(function () {
    Route::get('/user', [AuthController::class, 'user']);
    Route::post('/logout', [AuthController::class, 'logout']);
    Route::apiResource('orders', OrderController::class);
});

// app/Http/Controllers/Api/AuthController.php
class AuthController extends Controller
{
    public function login(LoginRequest $request)
    {
        if (!Auth::attempt($request->validated())) {
            return response()->json(['message' => 'Invalid credentials'], 401);
        }
        
        $user = Auth::user();
        $token = $user->createToken('api-token')->plainTextToken;
        
        return response()->json([
            'user' => new UserResource($user),
            'token' => $token,
        ]);
    }
    
    public function logout(Request $request)
    {
        $request->user()->currentAccessToken()->delete();
        return response()->json(['message' => 'Logged out']);
    }
}
```

## Best Practices

### ✅ Do This

- ✅ Use Form Requests for validation
- ✅ Use Resources for API responses
- ✅ Use Services for business logic
- ✅ Use Queues for heavy tasks
- ✅ Use Database transactions

### ❌ Avoid This

- ❌ Don't put logic in controllers
- ❌ Don't use raw queries
- ❌ Don't skip eager loading
- ❌ Don't expose sensitive data

## Related Skills

- `@senior-database-engineer-sql` - Database design
- `@senior-devops-engineer` - Deployment

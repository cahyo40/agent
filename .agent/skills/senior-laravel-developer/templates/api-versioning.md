# API Versioning & Documentation

## URL-Based Versioning

```php
<?php
// routes/api.php

use Illuminate\Support\Facades\Route;

// V1 Routes
Route::prefix('v1')->group(function () {
    Route::apiResource('orders', App\Http\Controllers\Api\V1\OrderController::class);
    Route::apiResource('products', App\Http\Controllers\Api\V1\ProductController::class);
});

// V2 Routes (new version with breaking changes)
Route::prefix('v2')->group(function () {
    Route::apiResource('orders', App\Http\Controllers\Api\V2\OrderController::class);
});
```

## Controller Organization

```text
app/Http/Controllers/Api/
├── V1/
│   ├── OrderController.php
│   ├── ProductController.php
│   └── UserController.php
├── V2/
│   ├── OrderController.php    # Breaking changes
│   └── ProductController.php
└── Shared/
    └── BaseController.php     # Shared logic
```

## Resource Versioning

```php
<?php
// app/Http/Resources/V1/OrderResource.php

namespace App\Http\Resources\V1;

class OrderResource extends JsonResource
{
    public function toArray($request): array
    {
        return [
            'id' => $this->id,
            'status' => $this->status,
            'total' => $this->total, // V1: float
            'user' => new UserResource($this->whenLoaded('user')),
        ];
    }
}

// app/Http/Resources/V2/OrderResource.php

namespace App\Http\Resources\V2;

class OrderResource extends JsonResource
{
    public function toArray($request): array
    {
        return [
            'id' => $this->id,
            'status' => $this->status,
            'total' => [  // V2: object with currency
                'amount' => $this->total,
                'currency' => 'IDR',
                'formatted' => 'Rp ' . number_format($this->total),
            ],
            'user' => new UserResource($this->whenLoaded('user')),
        ];
    }
}
```

## Header-Based Versioning (Alternative)

```php
<?php
// app/Http/Middleware/ApiVersion.php

class ApiVersion
{
    public function handle(Request $request, Closure $next): Response
    {
        $version = $request->header('X-API-Version', 'v1');

        // Store for later use
        $request->attributes->set('api_version', $version);

        return $next($request);
    }
}

// Usage in controller
$version = $request->attributes->get('api_version');
```

## API Documentation with Scribe

```bash
composer require knuckleswtf/scribe
php artisan vendor:publish --tag=scribe-config
php artisan scribe:generate
```

```php
<?php
// app/Http/Controllers/Api/V1/OrderController.php

/**
 * @group Orders
 *
 * APIs for managing orders
 */
class OrderController extends Controller
{
    /**
     * List Orders
     *
     * Get a paginated list of orders for the authenticated user.
     *
     * @authenticated
     *
     * @queryParam status string Filter by status. Example: pending
     * @queryParam per_page int Items per page. Example: 15
     *
     * @response 200 {
     *   "data": [
     *     {"id": 1, "status": "pending", "total": 150000}
     *   ],
     *   "meta": {"current_page": 1, "total": 50}
     * }
     */
    public function index(Request $request): OrderCollection
    {
        $orders = Order::query()
            ->where('user_id', $request->user()->id)
            ->when($request->status, fn ($q, $status) => $q->where('status', $status))
            ->paginate($request->per_page ?? 15);

        return new OrderCollection($orders);
    }

    /**
     * Create Order
     *
     * @authenticated
     *
     * @bodyParam items array required List of items. Example: [{"product_id": 1, "quantity": 2}]
     * @bodyParam items[].product_id int required Product ID. Example: 1
     * @bodyParam items[].quantity int required Quantity. Example: 2
     * @bodyParam shipping_address string required Shipping address. Example: Jl. Sudirman No. 1
     * @bodyParam notes string Optional notes. Example: Handle with care
     *
     * @response 201 {"data": {"id": 1, "status": "pending"}}
     * @response 422 {"message": "Validation failed", "errors": {...}}
     */
    public function store(StoreOrderRequest $request): OrderResource
    {
        $order = $this->orderService->create(
            $request->user(),
            $request->validated()
        );

        return new OrderResource($order);
    }
}
```

## OpenAPI/Swagger Alternative

```bash
composer require darkaonline/l5-swagger
php artisan vendor:publish --provider "L5Swagger\L5SwaggerServiceProvider"
```

```php
<?php
/**
 * @OA\Info(
 *     title="My API",
 *     version="1.0.0"
 * )
 * @OA\Server(url="http://localhost/api/v1")
 */

/**
 * @OA\Get(
 *     path="/orders",
 *     summary="List orders",
 *     @OA\Response(response=200, description="Success")
 * )
 */
```

## Rate Limit Headers

```php
<?php
// API responses should include rate limit info

// In AppServiceProvider
RateLimiter::for('api', function (Request $request) {
    return Limit::perMinute(60)
        ->by($request->user()?->id ?: $request->ip())
        ->response(function (Request $request, array $headers) {
            return response()->json([
                'message' => 'Too many requests',
            ], 429)->withHeaders($headers);
        });
});

// Response headers automatically added:
// X-RateLimit-Limit: 60
// X-RateLimit-Remaining: 59
// X-RateLimit-Reset: 1234567890
```

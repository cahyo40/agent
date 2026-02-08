# Performance Optimization

## Preventing N+1 Queries

```php
<?php
// ❌ BAD: N+1 problem
$orders = Order::all();
foreach ($orders as $order) {
    echo $order->user->name; // Query per order
}

// ✅ GOOD: Eager loading
$orders = Order::with('user')->get();

// ✅ Nested eager loading
$orders = Order::with(['user', 'items.product'])->get();

// ✅ Conditional eager loading
$orders = Order::with(['items' => function ($query) {
    $query->where('quantity', '>', 1);
}])->get();

// ✅ Lazy eager loading (after retrieval)
$orders = Order::all();
$orders->load('user');
```

## Query Optimization

```php
<?php
// ✅ Select only needed columns
User::select(['id', 'name', 'email'])->get();

// ✅ Use chunk for large datasets
User::chunk(1000, function ($users) {
    foreach ($users as $user) {
        // Process...
    }
});

// ✅ Use cursor for memory efficiency
foreach (User::cursor() as $user) {
    // Process one at a time, low memory
}

// ✅ Use lazy() for lazy collection
User::lazy()->each(function ($user) {
    // Memory efficient iteration
});

// ✅ Count without loading models
$count = Order::where('status', 'pending')->count();

// ✅ Exists check
if (Order::where('user_id', $id)->exists()) { ... }

// ✅ Raw expressions when needed
Order::selectRaw('DATE(created_at) as date, COUNT(*) as count')
    ->groupByRaw('DATE(created_at)')
    ->get();
```

## Database Indexing

```php
<?php
// database/migrations/xxx_add_indexes_to_orders_table.php

public function up(): void
{
    Schema::table('orders', function (Blueprint $table) {
        // Single column index
        $table->index('status');
        $table->index('created_at');

        // Composite index (order matters!)
        $table->index(['user_id', 'status']);

        // Unique index
        $table->unique(['user_id', 'order_number']);
    });
}
```

## Laravel Octane (High Performance)

```bash
# Install Octane with Swoole
composer require laravel/octane
php artisan octane:install --server=swoole

# Or with RoadRunner
php artisan octane:install --server=roadrunner
```

```php
<?php
// config/octane.php considerations

// ❌ AVOID in Octane: Static properties that persist
class BadService {
    public static array $cache = []; // Persists across requests!
}

// ✅ Use request-scoped or flush after each request
Octane::tick('metrics', fn () => Metrics::flush())
    ->seconds(10);
```

## Response Optimization

```php
<?php
// ✅ Return only needed data with Resources
class OrderResource extends JsonResource
{
    public function toArray($request): array
    {
        return [
            'id' => $this->id,
            'status' => $this->status,
            // Load only when requested
            'user' => new UserResource($this->whenLoaded('user')),
            // Conditional fields
            'admin_notes' => $this->when($request->user()?->isAdmin(), $this->admin_notes),
        ];
    }
}

// ✅ Pagination instead of all()
Order::paginate(15); // Don't use get() for large datasets

// ✅ Compression (in nginx or middleware)
// gzip on;
```

## Queue Optimization

```php
<?php
// config/queue.php - Redis optimization

'redis' => [
    'driver' => 'redis',
    'connection' => 'default',
    'queue' => 'default',
    'retry_after' => 90,
    'block_for' => 5, // Reduce polling
],

// Dispatch to specific queues
ProcessOrder::dispatch($order)->onQueue('high');
SendNewsletter::dispatch($users)->onQueue('low');

// Batch processing
Bus::batch([
    new ProcessOrder($order1),
    new ProcessOrder($order2),
])->dispatch();
```

## Config & Route Caching (Production)

```bash
# Cache config (MUST in production)
php artisan config:cache

# Cache routes
php artisan route:cache

# Cache views
php artisan view:cache

# Optimize autoloader
composer install --optimize-autoloader --no-dev

# All in one
php artisan optimize
```

## Horizon (Queue Monitoring)

```bash
composer require laravel/horizon
php artisan horizon:install
php artisan horizon
```

```php
<?php
// config/horizon.php

'environments' => [
    'production' => [
        'supervisor-1' => [
            'connection' => 'redis',
            'queue' => ['high', 'default', 'low'],
            'balance' => 'auto',
            'minProcesses' => 1,
            'maxProcesses' => 10,
            'tries' => 3,
        ],
    ],
],
```

## Database Query Logging (Debug)

```php
<?php
// AppServiceProvider.php (development only)

public function boot(): void
{
    if (app()->environment('local')) {
        DB::listen(function ($query) {
            Log::info($query->sql, [
                'bindings' => $query->bindings,
                'time' => $query->time,
            ]);
        });
    }
}

// Or use Laravel Debugbar
// composer require barryvdh/laravel-debugbar --dev
```

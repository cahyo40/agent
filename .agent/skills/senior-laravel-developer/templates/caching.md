# Caching Strategies

## Basic Cache Operations

```php
<?php
use Illuminate\Support\Facades\Cache;

// Store value
Cache::put('key', 'value', now()->addMinutes(10));
Cache::put('key', 'value', 600); // seconds

// Store forever
Cache::forever('key', 'value');

// Get or store (remember)
$users = Cache::remember('users', 3600, function () {
    return User::all();
});

// Get or store forever
$settings = Cache::rememberForever('settings', function () {
    return Setting::pluck('value', 'key');
});

// Check and retrieve
if (Cache::has('key')) {
    $value = Cache::get('key');
}

// Delete
Cache::forget('key');
Cache::flush(); // Clear all
```

## Cache Tags (Redis/Memcached only)

```php
<?php
// Store with tags
Cache::tags(['users', 'profiles'])->put('user:1', $user, 3600);
Cache::tags(['users', 'orders'])->put('user:1:orders', $orders, 3600);

// Retrieve tagged
$user = Cache::tags(['users', 'profiles'])->get('user:1');

// Flush by tag
Cache::tags('users')->flush(); // Clears all user-related cache
Cache::tags(['users', 'orders'])->flush();
```

## Query Caching Pattern

```php
<?php
// app/Repositories/ProductRepository.php

class ProductRepository
{
    public function getFeatured(): Collection
    {
        return Cache::remember('products:featured', 3600, function () {
            return Product::where('is_featured', true)
                ->with('category')
                ->get();
        });
    }

    public function find(int $id): ?Product
    {
        return Cache::remember("product:{$id}", 3600, function () use ($id) {
            return Product::with(['category', 'images'])->find($id);
        });
    }

    public function clearCache(int $id): void
    {
        Cache::forget("product:{$id}");
        Cache::forget('products:featured');
    }
}
```

## Model Event Cache Invalidation

```php
<?php
// app/Observers/ProductObserver.php

class ProductObserver
{
    public function saved(Product $product): void
    {
        Cache::forget("product:{$product->id}");
        Cache::forget('products:featured');
        Cache::tags('products')->flush();
    }

    public function deleted(Product $product): void
    {
        Cache::forget("product:{$product->id}");
        Cache::tags('products')->flush();
    }
}
```

## Response Caching (Full Page)

```php
<?php
// Using Spatie Response Cache

// Route level
Route::get('/products', ProductController::class)
    ->middleware('cacheResponse:3600');

// Controller level
class ProductController extends Controller
{
    public function __construct()
    {
        $this->middleware('cacheResponse:3600')->only('index', 'show');
    }
}

// Flush response cache
ResponseCache::clear();
ResponseCache::forget('/products');
```

## Redis Configuration

```php
<?php
// config/database.php

'redis' => [
    'client' => env('REDIS_CLIENT', 'phpredis'),

    'default' => [
        'url' => env('REDIS_URL'),
        'host' => env('REDIS_HOST', '127.0.0.1'),
        'port' => env('REDIS_PORT', '6379'),
        'database' => env('REDIS_DB', '0'),
    ],

    'cache' => [
        'host' => env('REDIS_HOST', '127.0.0.1'),
        'port' => env('REDIS_PORT', '6379'),
        'database' => env('REDIS_CACHE_DB', '1'),
    ],
],

// .env
CACHE_DRIVER=redis
REDIS_CLIENT=phpredis
```

## Cache Lock (Atomic Operations)

```php
<?php
use Illuminate\Support\Facades\Cache;

$lock = Cache::lock('processing-order', 10);

if ($lock->get()) {
    try {
        // Process order...
    } finally {
        $lock->release();
    }
}

// Or with block() - waits for lock
Cache::lock('processing-order', 10)->block(5, function () {
    // Acquired lock, process order...
});
```

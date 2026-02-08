# Middleware Patterns

## Custom Middleware

```php
<?php
// app/Http/Middleware/EnsureUserIsActive.php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class EnsureUserIsActive
{
    public function handle(Request $request, Closure $next): Response
    {
        if (! $request->user()?->is_active) {
            return response()->json([
                'message' => 'Account is deactivated.',
            ], Response::HTTP_FORBIDDEN);
        }

        return $next($request);
    }
}
```

## Register Middleware (Laravel 11+)

```php
<?php
// bootstrap/app.php

use App\Http\Middleware\EnsureUserIsActive;

return Application::configure(basePath: dirname(__DIR__))
    ->withMiddleware(function (Middleware $middleware) {
        // Alias for route middleware
        $middleware->alias([
            'active' => EnsureUserIsActive::class,
            'role' => \Spatie\Permission\Middleware\RoleMiddleware::class,
        ]);

        // Append to web group
        $middleware->web(append: [
            \App\Http\Middleware\HandleInertiaRequests::class,
        ]);

        // Append to API group
        $middleware->api(append: [
            \App\Http\Middleware\ForceJsonResponse::class,
        ]);
    })
    ->create();
```

## Rate Limiting

```php
<?php
// bootstrap/app.php (Laravel 11) atau RouteServiceProvider (Laravel 10)

use Illuminate\Cache\RateLimiting\Limit;
use Illuminate\Support\Facades\RateLimiter;

RateLimiter::for('api', function (Request $request) {
    return Limit::perMinute(60)->by($request->user()?->id ?: $request->ip());
});

RateLimiter::for('uploads', function (Request $request) {
    return $request->user()?->isPremium()
        ? Limit::none()
        : Limit::perMinute(10)->by($request->user()->id);
});

// Usage in routes
Route::post('/upload', UploadController::class)->middleware('throttle:uploads');
```

## Terminable Middleware (Post-Response)

```php
<?php
// app/Http/Middleware/LogRequest.php

class LogRequest
{
    public function handle(Request $request, Closure $next): Response
    {
        return $next($request);
    }

    public function terminate(Request $request, Response $response): void
    {
        // Runs after response sent to browser
        Log::info('Request completed', [
            'url' => $request->fullUrl(),
            'status' => $response->getStatusCode(),
            'duration' => microtime(true) - LARAVEL_START,
        ]);
    }
}
```

## Middleware Parameters

```php
<?php
// app/Http/Middleware/CheckRole.php

class CheckRole
{
    public function handle(Request $request, Closure $next, string ...$roles): Response
    {
        if (! $request->user()->hasAnyRole($roles)) {
            abort(403, 'Unauthorized action.');
        }

        return $next($request);
    }
}

// Usage: Route::get('/admin', ...)->middleware('role:admin,super-admin');
```

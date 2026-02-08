# Authorization Policies

## Creating Policies

```php
<?php
// app/Policies/OrderPolicy.php

namespace App\Policies;

use App\Models\Order;
use App\Models\User;
use Illuminate\Auth\Access\Response;

class OrderPolicy
{
    /**
     * Perform pre-authorization checks (optional).
     */
    public function before(User $user, string $ability): ?bool
    {
        if ($user->isAdmin()) {
            return true; // Admin bypasses all checks
        }

        return null; // Fall through to specific methods
    }

    public function viewAny(User $user): bool
    {
        return true;
    }

    public function view(User $user, Order $order): bool
    {
        return $user->id === $order->user_id;
    }

    public function create(User $user): bool
    {
        return $user->is_active;
    }

    public function update(User $user, Order $order): Response
    {
        if ($order->status === 'completed') {
            return Response::deny('Cannot modify completed orders.');
        }

        return $user->id === $order->user_id
            ? Response::allow()
            : Response::deny('You do not own this order.');
    }

    public function delete(User $user, Order $order): bool
    {
        return $user->id === $order->user_id && $order->status === 'pending';
    }
}
```

## Register Policy (Auto-Discovery Laravel 11)

```php
<?php
// app/Providers/AppServiceProvider.php

use App\Models\Order;
use App\Policies\OrderPolicy;
use Illuminate\Support\Facades\Gate;

public function boot(): void
{
    // Explicit registration (optional, Laravel auto-discovers)
    Gate::policy(Order::class, OrderPolicy::class);
}
```

## Using Policies in Controllers

```php
<?php
// app/Http/Controllers/Api/OrderController.php

class OrderController extends Controller
{
    public function show(Order $order): OrderResource
    {
        // Method 1: authorize()
        $this->authorize('view', $order);

        return new OrderResource($order);
    }

    public function update(UpdateOrderRequest $request, Order $order): OrderResource
    {
        // Method 2: Gate facade
        Gate::authorize('update', $order);

        $order->update($request->validated());

        return new OrderResource($order);
    }

    public function destroy(Order $order): Response
    {
        // Method 3: can() on user
        if ($request->user()->cannot('delete', $order)) {
            abort(403);
        }

        $order->delete();

        return response()->noContent();
    }
}
```

## Gates (Simple Authorization)

```php
<?php
// app/Providers/AppServiceProvider.php

use Illuminate\Support\Facades\Gate;

public function boot(): void
{
    Gate::define('access-admin', function (User $user) {
        return $user->role === 'admin';
    });

    Gate::define('manage-settings', function (User $user) {
        return $user->hasPermission('settings.manage');
    });
}

// Usage
if (Gate::allows('access-admin')) { ... }
if (Gate::denies('manage-settings')) { abort(403); }
```

## Form Request Authorization

```php
<?php
// app/Http/Requests/UpdateOrderRequest.php

class UpdateOrderRequest extends FormRequest
{
    public function authorize(): bool
    {
        $order = $this->route('order');

        return $this->user()->can('update', $order);
    }

    public function rules(): array
    {
        return [
            'status' => ['sometimes', 'in:pending,processing,shipped'],
            'notes' => ['nullable', 'string', 'max:1000'],
        ];
    }
}
```

## Blade Directives

```blade
@can('update', $order)
    <button>Edit Order</button>
@endcan

@cannot('delete', $order)
    <span class="text-muted">Cannot delete</span>
@endcannot

@canany(['update', 'delete'], $order)
    <div class="actions">...</div>
@endcanany
```

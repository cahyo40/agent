# Events & Listeners

## Defining Events

```php
<?php
// app/Events/OrderPlaced.php

namespace App\Events;

use App\Models\Order;
use Illuminate\Broadcasting\InteractsWithSockets;
use Illuminate\Foundation\Events\Dispatchable;
use Illuminate\Queue\SerializesModels;

class OrderPlaced
{
    use Dispatchable, InteractsWithSockets, SerializesModels;

    public function __construct(
        public Order $order
    ) {}
}
```

## Listeners

```php
<?php
// app/Listeners/SendOrderConfirmation.php

namespace App\Listeners;

use App\Events\OrderPlaced;
use App\Notifications\OrderConfirmation;
use Illuminate\Contracts\Queue\ShouldQueue;

class SendOrderConfirmation implements ShouldQueue
{
    public int $tries = 3;
    public int $backoff = 60;

    public function handle(OrderPlaced $event): void
    {
        $event->order->user->notify(new OrderConfirmation($event->order));
    }

    public function failed(OrderPlaced $event, \Throwable $exception): void
    {
        Log::error('Failed to send order confirmation', [
            'order_id' => $event->order->id,
            'error' => $exception->getMessage(),
        ]);
    }
}
```

## Registering Events (Laravel 11 Auto-Discovery)

```php
<?php
// app/Providers/AppServiceProvider.php

use App\Events\OrderPlaced;
use App\Listeners\SendOrderConfirmation;
use App\Listeners\UpdateInventory;
use Illuminate\Support\Facades\Event;

public function boot(): void
{
    Event::listen(OrderPlaced::class, [
        SendOrderConfirmation::class,
        UpdateInventory::class,
    ]);
}
```

## Dispatching Events

```php
<?php
// app/Services/OrderService.php

use App\Events\OrderPlaced;

class OrderService
{
    public function create(User $user, array $data): Order
    {
        return DB::transaction(function () use ($user, $data) {
            $order = Order::create([...]);

            // Dispatch event
            OrderPlaced::dispatch($order);
            // or: event(new OrderPlaced($order));

            return $order;
        });
    }
}
```

## Broadcasting (Real-time)

```php
<?php
// app/Events/OrderStatusUpdated.php

namespace App\Events;

use App\Models\Order;
use Illuminate\Broadcasting\Channel;
use Illuminate\Broadcasting\InteractsWithBroadcasting;
use Illuminate\Broadcasting\PrivateChannel;
use Illuminate\Contracts\Broadcasting\ShouldBroadcast;

class OrderStatusUpdated implements ShouldBroadcast
{
    use InteractsWithBroadcasting;

    public function __construct(
        public Order $order
    ) {}

    public function broadcastOn(): array
    {
        return [
            new PrivateChannel('orders.' . $this->order->user_id),
        ];
    }

    public function broadcastWith(): array
    {
        return [
            'id' => $this->order->id,
            'status' => $this->order->status,
        ];
    }
}

// channels.php
Broadcast::channel('orders.{userId}', function (User $user, int $userId) {
    return $user->id === $userId;
});
```

## Model Observers

```php
<?php
// app/Observers/OrderObserver.php

namespace App\Observers;

use App\Models\Order;

class OrderObserver
{
    public function created(Order $order): void
    {
        OrderPlaced::dispatch($order);
    }

    public function updated(Order $order): void
    {
        if ($order->wasChanged('status')) {
            OrderStatusUpdated::dispatch($order);
        }
    }
}

// Register in AppServiceProvider
Order::observe(OrderObserver::class);
```

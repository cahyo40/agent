# Queues & Jobs

## Process Order Job

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
```

## Dispatching Jobs

```php
// Dispatch to default queue
ProcessOrder::dispatch($order);

// Dispatch to specific queue
ProcessOrder::dispatch($order)->onQueue('orders');

// Dispatch with delay
ProcessOrder::dispatch($order)->delay(now()->addMinutes(5));
```

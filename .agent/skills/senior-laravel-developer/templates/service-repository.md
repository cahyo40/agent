# Service & Repository Pattern

## Order Service

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
```

## Order Repository

```php
<?php
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

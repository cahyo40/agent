# Controllers & Resources

## API Controller

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
```

## API Resource

```php
<?php
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

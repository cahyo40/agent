# Testing with Pest

## Setup Pest

```bash
composer require pestphp/pest pestphp/pest-plugin-laravel --dev
./vendor/bin/pest --init
```

## Feature Test (API)

```php
<?php
// tests/Feature/Api/OrderTest.php

use App\Models\Order;
use App\Models\User;

beforeEach(function () {
    $this->user = User::factory()->create();
});

describe('Order API', function () {
    it('can list orders for authenticated user', function () {
        Order::factory(3)->for($this->user)->create();

        $response = $this->actingAs($this->user)
            ->getJson('/api/orders');

        $response->assertOk()
            ->assertJsonCount(3, 'data')
            ->assertJsonStructure([
                'data' => [['id', 'status', 'total', 'created_at']],
                'links',
                'meta',
            ]);
    });

    it('can create an order', function () {
        $payload = [
            'items' => [
                ['product_id' => 1, 'quantity' => 2],
            ],
            'shipping_address' => '123 Main St',
        ];

        $response = $this->actingAs($this->user)
            ->postJson('/api/orders', $payload);

        $response->assertCreated()
            ->assertJsonPath('data.status', 'pending');

        $this->assertDatabaseHas('orders', [
            'user_id' => $this->user->id,
            'status' => 'pending',
        ]);
    });

    it('returns 401 for unauthenticated requests', function () {
        $this->getJson('/api/orders')
            ->assertUnauthorized();
    });

    it('returns 403 when viewing another user order', function () {
        $otherOrder = Order::factory()->create();

        $this->actingAs($this->user)
            ->getJson("/api/orders/{$otherOrder->id}")
            ->assertForbidden();
    });

    it('validates required fields', function () {
        $this->actingAs($this->user)
            ->postJson('/api/orders', [])
            ->assertUnprocessable()
            ->assertJsonValidationErrors(['items']);
    });
});
```

## Unit Test (Services)

```php
<?php
// tests/Unit/Services/OrderServiceTest.php

use App\Models\Order;
use App\Models\Product;
use App\Models\User;
use App\Repositories\OrderRepository;
use App\Services\OrderService;

beforeEach(function () {
    $this->repository = Mockery::mock(OrderRepository::class);
    $this->service = new OrderService($this->repository);
    $this->user = User::factory()->create();
});

it('creates order with correct total', function () {
    $product = Product::factory()->create(['price' => 100]);

    $this->repository
        ->shouldReceive('create')
        ->once()
        ->andReturn(Order::factory()->make(['id' => 1]));

    $order = $this->service->create($this->user, [
        'items' => [
            ['product_id' => $product->id, 'quantity' => 2],
        ],
    ]);

    expect($order)->toBeInstanceOf(Order::class);
});

it('dispatches OrderPlaced event', function () {
    Event::fake();

    $product = Product::factory()->create();
    $this->repository->shouldReceive('create')->andReturn(
        Order::factory()->make(['id' => 1])
    );

    $this->service->create($this->user, [
        'items' => [['product_id' => $product->id, 'quantity' => 1]],
    ]);

    Event::assertDispatched(OrderPlaced::class);
});
```

## Database Testing

```php
<?php
// tests/Feature/OrderFlowTest.php

use Illuminate\Foundation\Testing\RefreshDatabase;

uses(RefreshDatabase::class);

it('completes full order flow', function () {
    $user = User::factory()->create();
    $product = Product::factory()->create(['stock' => 10]);

    // Create order
    $response = $this->actingAs($user)
        ->postJson('/api/orders', [
            'items' => [['product_id' => $product->id, 'quantity' => 2]],
        ]);

    $response->assertCreated();

    // Verify database
    $this->assertDatabaseHas('orders', ['user_id' => $user->id]);
    $this->assertDatabaseHas('order_items', ['product_id' => $product->id]);

    // Verify stock reduced
    expect($product->fresh()->stock)->toBe(8);
});
```

## Mocking External Services

```php
<?php
use App\Services\PaymentGateway;
use Illuminate\Support\Facades\Http;

it('processes payment through gateway', function () {
    Http::fake([
        'api.stripe.com/*' => Http::response(['id' => 'ch_123', 'status' => 'succeeded']),
    ]);

    $result = app(PaymentGateway::class)->charge(1000, 'tok_visa');

    expect($result)->toMatchArray([
        'id' => 'ch_123',
        'status' => 'succeeded',
    ]);

    Http::assertSent(fn ($request) => 
        $request->url() === 'https://api.stripe.com/v1/charges'
    );
});

it('handles payment failure', function () {
    Http::fake([
        'api.stripe.com/*' => Http::response(['error' => 'Card declined'], 402),
    ]);

    expect(fn () => app(PaymentGateway::class)->charge(1000, 'tok_declined'))
        ->toThrow(PaymentFailedException::class);
});
```

## Running Tests

```bash
# Run all tests
./vendor/bin/pest

# Run specific test file
./vendor/bin/pest tests/Feature/Api/OrderTest.php

# Run with coverage
./vendor/bin/pest --coverage --min=80

# Run in parallel
./vendor/bin/pest --parallel

# Filter by name
./vendor/bin/pest --filter="can create"
```

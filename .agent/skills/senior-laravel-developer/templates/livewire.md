# Livewire 3

## Setup

```bash
composer require livewire/livewire
```

## Basic Component

```php
<?php
// app/Livewire/Counter.php

namespace App\Livewire;

use Livewire\Component;

class Counter extends Component
{
    public int $count = 0;

    public function increment(): void
    {
        $this->count++;
    }

    public function decrement(): void
    {
        $this->count--;
    }

    public function render()
    {
        return view('livewire.counter');
    }
}
```

```blade
{{-- resources/views/livewire/counter.blade.php --}}
<div>
    <h1>{{ $count }}</h1>
    <button wire:click="increment">+</button>
    <button wire:click="decrement">-</button>
</div>
```

## Form Component with Validation

```php
<?php
// app/Livewire/CreateOrder.php

namespace App\Livewire;

use App\Models\Order;
use App\Services\OrderService;
use Livewire\Attributes\Rule;
use Livewire\Attributes\Validate;
use Livewire\Component;

class CreateOrder extends Component
{
    #[Validate('required|string|max:255')]
    public string $shipping_address = '';

    #[Validate('nullable|string|max:1000')]
    public string $notes = '';

    public array $items = [];

    public function mount(): void
    {
        $this->items = [
            ['product_id' => '', 'quantity' => 1],
        ];
    }

    public function addItem(): void
    {
        $this->items[] = ['product_id' => '', 'quantity' => 1];
    }

    public function removeItem(int $index): void
    {
        unset($this->items[$index]);
        $this->items = array_values($this->items);
    }

    public function save(OrderService $orderService): void
    {
        $this->validate();

        $order = $orderService->create(auth()->user(), [
            'shipping_address' => $this->shipping_address,
            'notes' => $this->notes,
            'items' => $this->items,
        ]);

        session()->flash('success', 'Order created successfully!');

        $this->redirect(route('orders.show', $order));
    }

    public function render()
    {
        return view('livewire.create-order', [
            'products' => Product::all(),
        ]);
    }
}
```

```blade
{{-- resources/views/livewire/create-order.blade.php --}}
<form wire:submit="save">
    <div>
        <label>Shipping Address</label>
        <input type="text" wire:model="shipping_address">
        @error('shipping_address') <span>{{ $message }}</span> @enderror
    </div>

    <div>
        <label>Notes</label>
        <textarea wire:model="notes"></textarea>
    </div>

    @foreach($items as $index => $item)
        <div wire:key="item-{{ $index }}">
            <select wire:model="items.{{ $index }}.product_id">
                <option value="">Select Product</option>
                @foreach($products as $product)
                    <option value="{{ $product->id }}">{{ $product->name }}</option>
                @endforeach
            </select>
            <input type="number" wire:model="items.{{ $index }}.quantity" min="1">
            <button type="button" wire:click="removeItem({{ $index }})">Remove</button>
        </div>
    @endforeach

    <button type="button" wire:click="addItem">Add Item</button>
    <button type="submit">Create Order</button>
</form>
```

## Real-time Search with Debounce

```php
<?php
// app/Livewire/ProductSearch.php

namespace App\Livewire;

use App\Models\Product;
use Livewire\Attributes\Url;
use Livewire\Component;
use Livewire\WithPagination;

class ProductSearch extends Component
{
    use WithPagination;

    #[Url]
    public string $search = '';

    #[Url]
    public string $category = '';

    public function updatingSearch(): void
    {
        $this->resetPage();
    }

    public function render()
    {
        $products = Product::query()
            ->when($this->search, fn ($q) => $q->where('name', 'like', "%{$this->search}%"))
            ->when($this->category, fn ($q) => $q->where('category_id', $this->category))
            ->paginate(12);

        return view('livewire.product-search', [
            'products' => $products,
            'categories' => Category::all(),
        ]);
    }
}
```

```blade
<div>
    <input 
        type="search" 
        wire:model.live.debounce.300ms="search" 
        placeholder="Search products..."
    >

    <select wire:model.live="category">
        <option value="">All Categories</option>
        @foreach($categories as $cat)
            <option value="{{ $cat->id }}">{{ $cat->name }}</option>
        @endforeach
    </select>

    <div wire:loading>Searching...</div>

    <div class="grid">
        @foreach($products as $product)
            <div wire:key="product-{{ $product->id }}">
                {{ $product->name }}
            </div>
        @endforeach
    </div>

    {{ $products->links() }}
</div>
```

## Modal Component

```php
<?php
// app/Livewire/DeleteOrderModal.php

namespace App\Livewire;

use App\Models\Order;
use Livewire\Attributes\On;
use Livewire\Component;

class DeleteOrderModal extends Component
{
    public bool $show = false;
    public ?Order $order = null;

    #[On('open-delete-modal')]
    public function open(int $orderId): void
    {
        $this->order = Order::find($orderId);
        $this->show = true;
    }

    public function delete(): void
    {
        $this->order->delete();
        $this->show = false;
        $this->dispatch('order-deleted');
    }

    public function render()
    {
        return view('livewire.delete-order-modal');
    }
}

// Trigger from another component
$this->dispatch('open-delete-modal', orderId: $order->id);
```

## File Uploads

```php
<?php
use Livewire\WithFileUploads;

class UpdateProfile extends Component
{
    use WithFileUploads;

    #[Validate('nullable|image|max:2048')]
    public $photo;

    public function save(): void
    {
        $this->validate();

        if ($this->photo) {
            $path = $this->photo->store('avatars', 'public');
            auth()->user()->update(['avatar' => $path]);
        }
    }
}
```

```blade
<input type="file" wire:model="photo">

@if ($photo)
    <img src="{{ $photo->temporaryUrl() }}" alt="Preview">
@endif

<div wire:loading wire:target="photo">Uploading...</div>
```

## Usage in Blade

```blade
{{-- In any Blade view --}}
<livewire:counter />
<livewire:product-search :category="$defaultCategory" />

{{-- Full page component --}}
{{-- routes/web.php --}}
Route::get('/orders/create', CreateOrder::class);
```

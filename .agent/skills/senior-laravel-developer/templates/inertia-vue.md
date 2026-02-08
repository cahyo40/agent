# Inertia.js + Vue 3

## Setup with Laravel Breeze

```bash
composer require laravel/breeze --dev
php artisan breeze:install vue

# With SSR support
php artisan breeze:install vue --ssr

npm install
npm run dev
```

## Controller Returning Inertia Response

```php
<?php
// app/Http/Controllers/OrderController.php

namespace App\Http\Controllers;

use App\Models\Order;
use Inertia\Inertia;
use Inertia\Response;

class OrderController extends Controller
{
    public function index(): Response
    {
        return Inertia::render('Orders/Index', [
            'orders' => Order::query()
                ->where('user_id', auth()->id())
                ->with('items.product')
                ->latest()
                ->paginate(15),
            'filters' => request()->only(['search', 'status']),
        ]);
    }

    public function show(Order $order): Response
    {
        $this->authorize('view', $order);

        return Inertia::render('Orders/Show', [
            'order' => $order->load(['items.product', 'user']),
        ]);
    }

    public function create(): Response
    {
        return Inertia::render('Orders/Create', [
            'products' => Product::all(['id', 'name', 'price']),
        ]);
    }

    public function store(StoreOrderRequest $request)
    {
        $order = $this->orderService->create(
            $request->user(),
            $request->validated()
        );

        return redirect()
            ->route('orders.show', $order)
            ->with('success', 'Order created successfully!');
    }
}
```

## Vue Page Component

```vue
<!-- resources/js/Pages/Orders/Index.vue -->
<script setup>
import { Head, Link, router } from '@inertiajs/vue3'
import { ref, watch } from 'vue'
import AuthenticatedLayout from '@/Layouts/AuthenticatedLayout.vue'
import Pagination from '@/Components/Pagination.vue'

const props = defineProps({
    orders: Object,
    filters: Object,
})

const search = ref(props.filters.search || '')
const status = ref(props.filters.status || '')

// Debounced search
watch([search, status], ([newSearch, newStatus]) => {
    router.get(route('orders.index'), {
        search: newSearch,
        status: newStatus,
    }, {
        preserveState: true,
        replace: true,
    })
}, { debounce: 300 })
</script>

<template>
    <Head title="Orders" />
    
    <AuthenticatedLayout>
        <div class="container">
            <h1>My Orders</h1>

            <!-- Filters -->
            <div class="filters">
                <input 
                    v-model="search"
                    type="search"
                    placeholder="Search orders..."
                />
                <select v-model="status">
                    <option value="">All Status</option>
                    <option value="pending">Pending</option>
                    <option value="processing">Processing</option>
                    <option value="completed">Completed</option>
                </select>
            </div>

            <!-- Orders List -->
            <table>
                <thead>
                    <tr>
                        <th>ID</th>
                        <th>Status</th>
                        <th>Total</th>
                        <th>Date</th>
                        <th>Actions</th>
                    </tr>
                </thead>
                <tbody>
                    <tr v-for="order in orders.data" :key="order.id">
                        <td>{{ order.id }}</td>
                        <td>{{ order.status }}</td>
                        <td>{{ formatCurrency(order.total) }}</td>
                        <td>{{ formatDate(order.created_at) }}</td>
                        <td>
                            <Link :href="route('orders.show', order.id)">
                                View
                            </Link>
                        </td>
                    </tr>
                </tbody>
            </table>

            <Pagination :links="orders.links" />
        </div>
    </AuthenticatedLayout>
</template>
```

## Form with Validation Errors

```vue
<!-- resources/js/Pages/Orders/Create.vue -->
<script setup>
import { Head, useForm } from '@inertiajs/vue3'
import AuthenticatedLayout from '@/Layouts/AuthenticatedLayout.vue'

const props = defineProps({
    products: Array,
})

const form = useForm({
    shipping_address: '',
    notes: '',
    items: [{ product_id: '', quantity: 1 }],
})

const addItem = () => {
    form.items.push({ product_id: '', quantity: 1 })
}

const removeItem = (index) => {
    form.items.splice(index, 1)
}

const submit = () => {
    form.post(route('orders.store'), {
        onSuccess: () => form.reset(),
    })
}
</script>

<template>
    <Head title="Create Order" />
    
    <AuthenticatedLayout>
        <form @submit.prevent="submit">
            <div>
                <label>Shipping Address</label>
                <input v-model="form.shipping_address" type="text" />
                <span v-if="form.errors.shipping_address" class="error">
                    {{ form.errors.shipping_address }}
                </span>
            </div>

            <div>
                <label>Notes</label>
                <textarea v-model="form.notes"></textarea>
            </div>

            <!-- Dynamic Items -->
            <div v-for="(item, index) in form.items" :key="index">
                <select v-model="item.product_id">
                    <option value="">Select Product</option>
                    <option 
                        v-for="product in products" 
                        :key="product.id"
                        :value="product.id"
                    >
                        {{ product.name }} - {{ product.price }}
                    </option>
                </select>
                <input v-model.number="item.quantity" type="number" min="1" />
                <button type="button" @click="removeItem(index)">Remove</button>
            </div>

            <button type="button" @click="addItem">Add Item</button>

            <button type="submit" :disabled="form.processing">
                {{ form.processing ? 'Creating...' : 'Create Order' }}
            </button>
        </form>
    </AuthenticatedLayout>
</template>
```

## HandleInertiaRequests Middleware

```php
<?php
// app/Http/Middleware/HandleInertiaRequests.php

namespace App\Http\Middleware;

use Illuminate\Http\Request;
use Inertia\Middleware;

class HandleInertiaRequests extends Middleware
{
    protected $rootView = 'app';

    public function share(Request $request): array
    {
        return array_merge(parent::share($request), [
            'auth' => [
                'user' => $request->user(),
            ],
            'flash' => [
                'success' => fn () => $request->session()->get('success'),
                'error' => fn () => $request->session()->get('error'),
            ],
            'ziggy' => fn () => [
                ...(new \Tightenco\Ziggy\Ziggy)->toArray(),
                'location' => $request->url(),
            ],
        ]);
    }
}
```

## Flash Messages Component

```vue
<!-- resources/js/Components/FlashMessages.vue -->
<script setup>
import { usePage } from '@inertiajs/vue3'
import { computed } from 'vue'

const flash = computed(() => usePage().props.flash)
</script>

<template>
    <div v-if="flash.success" class="alert alert-success">
        {{ flash.success }}
    </div>
    <div v-if="flash.error" class="alert alert-error">
        {{ flash.error }}
    </div>
</template>
```

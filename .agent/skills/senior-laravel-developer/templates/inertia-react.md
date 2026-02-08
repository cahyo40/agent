# Inertia.js + React

## Setup with Laravel Breeze

```bash
composer require laravel/breeze --dev
php artisan breeze:install react

# With TypeScript
php artisan breeze:install react --typescript

# With SSR
php artisan breeze:install react --ssr

npm install
npm run dev
```

## Controller (Same as Vue)

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

## React Page Component

```tsx
// resources/js/Pages/Orders/Index.tsx
import { Head, Link, router } from '@inertiajs/react'
import { useState, useEffect, useMemo } from 'react'
import AuthenticatedLayout from '@/Layouts/AuthenticatedLayout'
import Pagination from '@/Components/Pagination'
import { debounce } from 'lodash'

interface Order {
    id: number
    status: string
    total: number
    created_at: string
}

interface Props {
    orders: {
        data: Order[]
        links: any[]
    }
    filters: {
        search?: string
        status?: string
    }
}

export default function Index({ orders, filters }: Props) {
    const [search, setSearch] = useState(filters.search || '')
    const [status, setStatus] = useState(filters.status || '')

    const debouncedSearch = useMemo(
        () => debounce((value: string, statusValue: string) => {
            router.get(route('orders.index'), {
                search: value,
                status: statusValue,
            }, {
                preserveState: true,
                replace: true,
            })
        }, 300),
        []
    )

    useEffect(() => {
        debouncedSearch(search, status)
    }, [search, status])

    return (
        <AuthenticatedLayout>
            <Head title="Orders" />

            <div className="container">
                <h1>My Orders</h1>

                {/* Filters */}
                <div className="filters">
                    <input
                        type="search"
                        value={search}
                        onChange={(e) => setSearch(e.target.value)}
                        placeholder="Search orders..."
                    />
                    <select 
                        value={status} 
                        onChange={(e) => setStatus(e.target.value)}
                    >
                        <option value="">All Status</option>
                        <option value="pending">Pending</option>
                        <option value="processing">Processing</option>
                        <option value="completed">Completed</option>
                    </select>
                </div>

                {/* Orders Table */}
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
                        {orders.data.map((order) => (
                            <tr key={order.id}>
                                <td>{order.id}</td>
                                <td>{order.status}</td>
                                <td>{formatCurrency(order.total)}</td>
                                <td>{formatDate(order.created_at)}</td>
                                <td>
                                    <Link href={route('orders.show', order.id)}>
                                        View
                                    </Link>
                                </td>
                            </tr>
                        ))}
                    </tbody>
                </table>

                <Pagination links={orders.links} />
            </div>
        </AuthenticatedLayout>
    )
}
```

## Form with useForm Hook

```tsx
// resources/js/Pages/Orders/Create.tsx
import { Head, useForm } from '@inertiajs/react'
import AuthenticatedLayout from '@/Layouts/AuthenticatedLayout'
import { FormEventHandler } from 'react'

interface Product {
    id: number
    name: string
    price: number
}

interface Props {
    products: Product[]
}

export default function Create({ products }: Props) {
    const { data, setData, post, processing, errors, reset } = useForm({
        shipping_address: '',
        notes: '',
        items: [{ product_id: '', quantity: 1 }],
    })

    const addItem = () => {
        setData('items', [...data.items, { product_id: '', quantity: 1 }])
    }

    const removeItem = (index: number) => {
        setData('items', data.items.filter((_, i) => i !== index))
    }

    const updateItem = (index: number, field: string, value: any) => {
        const newItems = [...data.items]
        newItems[index] = { ...newItems[index], [field]: value }
        setData('items', newItems)
    }

    const submit: FormEventHandler = (e) => {
        e.preventDefault()
        post(route('orders.store'), {
            onSuccess: () => reset(),
        })
    }

    return (
        <AuthenticatedLayout>
            <Head title="Create Order" />

            <form onSubmit={submit}>
                <div>
                    <label>Shipping Address</label>
                    <input
                        type="text"
                        value={data.shipping_address}
                        onChange={(e) => setData('shipping_address', e.target.value)}
                    />
                    {errors.shipping_address && (
                        <span className="error">{errors.shipping_address}</span>
                    )}
                </div>

                <div>
                    <label>Notes</label>
                    <textarea
                        value={data.notes}
                        onChange={(e) => setData('notes', e.target.value)}
                    />
                </div>

                {/* Dynamic Items */}
                {data.items.map((item, index) => (
                    <div key={index} className="item-row">
                        <select
                            value={item.product_id}
                            onChange={(e) => updateItem(index, 'product_id', e.target.value)}
                        >
                            <option value="">Select Product</option>
                            {products.map((product) => (
                                <option key={product.id} value={product.id}>
                                    {product.name} - {product.price}
                                </option>
                            ))}
                        </select>
                        <input
                            type="number"
                            min={1}
                            value={item.quantity}
                            onChange={(e) => updateItem(index, 'quantity', parseInt(e.target.value))}
                        />
                        <button type="button" onClick={() => removeItem(index)}>
                            Remove
                        </button>
                    </div>
                ))}

                <button type="button" onClick={addItem}>Add Item</button>

                <button type="submit" disabled={processing}>
                    {processing ? 'Creating...' : 'Create Order'}
                </button>
            </form>
        </AuthenticatedLayout>
    )
}
```

## TypeScript Types

```typescript
// resources/js/types/index.d.ts

export interface User {
    id: number
    name: string
    email: string
}

export interface Order {
    id: number
    user_id: number
    status: 'pending' | 'processing' | 'shipped' | 'completed'
    total: number
    shipping_address: string
    notes?: string
    created_at: string
    updated_at: string
    user?: User
    items?: OrderItem[]
}

export interface OrderItem {
    id: number
    order_id: number
    product_id: number
    quantity: number
    price: number
    product?: Product
}

export interface PageProps {
    auth: {
        user: User
    }
    flash: {
        success?: string
        error?: string
    }
}
```

## Flash Messages Component

```tsx
// resources/js/Components/FlashMessages.tsx
import { usePage } from '@inertiajs/react'
import { PageProps } from '@/types'

export default function FlashMessages() {
    const { flash } = usePage<PageProps>().props

    return (
        <>
            {flash.success && (
                <div className="alert alert-success">{flash.success}</div>
            )}
            {flash.error && (
                <div className="alert alert-error">{flash.error}</div>
            )}
        </>
    )
}
```

## Modal with Headless UI

```tsx
// resources/js/Components/Modal.tsx
import { Fragment } from 'react'
import { Dialog, Transition } from '@headlessui/react'

interface Props {
    isOpen: boolean
    onClose: () => void
    title: string
    children: React.ReactNode
}

export default function Modal({ isOpen, onClose, title, children }: Props) {
    return (
        <Transition appear show={isOpen} as={Fragment}>
            <Dialog as="div" className="modal" onClose={onClose}>
                <div className="modal-backdrop" />
                <div className="modal-content">
                    <Dialog.Title>{title}</Dialog.Title>
                    {children}
                </div>
            </Dialog>
        </Transition>
    )
}
```

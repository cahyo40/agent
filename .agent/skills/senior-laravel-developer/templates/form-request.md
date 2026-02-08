# Form Requests & Validation

## Store Order Request

```php
<?php
// app/Http/Requests/StoreOrderRequest.php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class StoreOrderRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }
    
    public function rules(): array
    {
        return [
            'items' => ['required', 'array', 'min:1'],
            'items.*.product_id' => ['required', 'exists:products,id'],
            'items.*.quantity' => ['required', 'integer', 'min:1', 'max:100'],
            'shipping_address' => ['required', 'string', 'max:500'],
            'notes' => ['nullable', 'string', 'max:1000'],
        ];
    }
    
    public function messages(): array
    {
        return [
            'items.required' => 'Please add at least one item to your order.',
            'items.*.product_id.exists' => 'Selected product does not exist.',
        ];
    }
}
```

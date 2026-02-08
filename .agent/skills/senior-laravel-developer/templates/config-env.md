# Environment & Configuration

## Environment Files

```bash
# .env files (gitignored)
.env                  # Local development
.env.testing          # PHPUnit/Pest testing
.env.staging          # Staging server (if needed)
.env.production       # Production (never commit!)

# .env.example (committed to git)
# Template for team members
```

## Environment-Specific Configuration

```php
<?php
// config/app.php

return [
    'name' => env('APP_NAME', 'Laravel'),
    'env' => env('APP_ENV', 'production'),
    'debug' => (bool) env('APP_DEBUG', false),
    'url' => env('APP_URL', 'http://localhost'),

    // Custom per-environment settings
    'feature_flags' => [
        'new_checkout' => env('FEATURE_NEW_CHECKOUT', false),
        'beta_api' => env('FEATURE_BETA_API', false),
    ],
];

// Usage
if (config('app.feature_flags.new_checkout')) {
    // New checkout flow
}
```

## Config Caching (Production)

```bash
# Cache all config files into single file
php artisan config:cache

# Clear config cache
php artisan config:clear

# ⚠️ WARNING: After caching, env() only works in config files!
# ❌ WRONG: env('APP_NAME') in controllers
# ✅ RIGHT: config('app.name') in controllers
```

## Environment Detection

```php
<?php
// Check environment
if (app()->environment('production')) {
    // Production only
}

if (app()->environment(['local', 'staging'])) {
    // Local or staging
}

// In config files
'debug' => env('APP_ENV') !== 'production',
```

## Custom Config Files

```php
<?php
// config/payment.php

return [
    'default' => env('PAYMENT_GATEWAY', 'stripe'),

    'gateways' => [
        'stripe' => [
            'key' => env('STRIPE_KEY'),
            'secret' => env('STRIPE_SECRET'),
            'webhook_secret' => env('STRIPE_WEBHOOK_SECRET'),
        ],
        'midtrans' => [
            'server_key' => env('MIDTRANS_SERVER_KEY'),
            'client_key' => env('MIDTRANS_CLIENT_KEY'),
            'is_production' => env('MIDTRANS_IS_PRODUCTION', false),
        ],
    ],

    'currency' => env('PAYMENT_CURRENCY', 'IDR'),
];

// Usage
$key = config('payment.gateways.stripe.key');
$gateway = config('payment.default');
```

## Service Provider Configuration

```php
<?php
// app/Providers/AppServiceProvider.php

public function register(): void
{
    // Bind based on config
    $this->app->bind(PaymentGateway::class, function ($app) {
        return match (config('payment.default')) {
            'stripe' => new StripeGateway(config('payment.gateways.stripe')),
            'midtrans' => new MidtransGateway(config('payment.gateways.midtrans')),
            default => throw new \Exception('Invalid payment gateway'),
        };
    });
}

public function boot(): void
{
    // Disable in production
    if (app()->environment('production')) {
        URL::forceScheme('https');
    }
}
```

## Secrets Management (Production)

```bash
# Laravel Vault (encrypted secrets)
php artisan env:encrypt --key=base64:your-encryption-key
php artisan env:decrypt --key=base64:your-encryption-key

# .env.encrypted is safe to commit
```

## .env.example Best Practices

```bash
# .env.example - Document all variables

APP_NAME="My App"
APP_ENV=local
APP_DEBUG=true
APP_URL=http://localhost

# Database
DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=myapp
DB_USERNAME=root
DB_PASSWORD=

# Redis
REDIS_HOST=127.0.0.1
REDIS_PORT=6379

# Mail
MAIL_MAILER=smtp
MAIL_HOST=mailpit
MAIL_PORT=1025

# Payment (get from Stripe Dashboard)
STRIPE_KEY=
STRIPE_SECRET=
STRIPE_WEBHOOK_SECRET=

# Feature Flags
FEATURE_NEW_CHECKOUT=false
```

## Runtime Configuration

```php
<?php
// Temporarily change config at runtime
config(['app.timezone' => 'Asia/Jakarta']);

// Get with default
$timeout = config('services.api.timeout', 30);

// Check if config exists
if (config()->has('services.api')) {
    // ...
}
```

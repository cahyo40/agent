---
name: internationalization-specialist
description: "Expert i18n/l10n including multi-language support, locale handling, RTL layouts, and globalization best practices"
---

# Internationalization Specialist

## Overview

This skill helps you build applications that work seamlessly across languages, regions, and cultures.

## When to Use This Skill

- Use when adding multi-language support
- Use when handling localization
- Use when building global applications
- Use when implementing RTL layouts

## How It Works

### Step 1: i18n Concepts

```
INTERNATIONALIZATION CONCEPTS
├── i18n (Internationalization)
│   └── Building app to support multiple locales
│   └── Extracting translatable strings
│
├── l10n (Localization)
│   └── Actual translation of content
│   └── Adapting for specific region
│
├── Locale
│   └── Language + Region (en-US, id-ID, ar-SA)
│
└── Concerns
    ├── Text translation
    ├── Date/time formatting
    ├── Number/currency formatting
    ├── RTL layout support
    └── Cultural considerations
```

### Step 2: React i18n (next-intl)

```typescript
// messages/en.json
{
  "common": {
    "welcome": "Welcome, {name}!",
    "items": "{count, plural, =0 {No items} one {# item} other {# items}}"
  }
}

// messages/id.json
{
  "common": {
    "welcome": "Selamat datang, {name}!",
    "items": "{count, plural, =0 {Tidak ada item} other {# item}}"
  }
}

// Component usage
import { useTranslations } from 'next-intl';

function Header() {
  const t = useTranslations('common');
  
  return (
    <div>
      <h1>{t('welcome', { name: 'John' })}</h1>
      <p>{t('items', { count: 5 })}</p>
    </div>
  );
}
```

### Step 3: Formatting

```typescript
import { useFormatter, useLocale } from 'next-intl';

function PriceDisplay({ price }) {
  const locale = useLocale();
  const format = useFormatter();
  
  // Currency
  const formattedPrice = format.number(price, {
    style: 'currency',
    currency: 'USD'
  });
  // en-US: $1,234.56
  // id-ID: US$ 1.234,56
  
  // Date
  const formattedDate = format.dateTime(new Date(), {
    year: 'numeric',
    month: 'long',
    day: 'numeric'
  });
  // en-US: January 30, 2025
  // id-ID: 30 Januari 2025
  
  // Relative time
  const relativeTime = format.relativeTime(new Date());
  // "2 hours ago" / "2 jam yang lalu"
  
  return <span>{formattedPrice}</span>;
}
```

### Step 4: RTL Support

```css
/* Base styles that work for both */
.container {
  display: flex;
  gap: 1rem;
}

/* Use logical properties */
.card {
  /* Instead of margin-left, use: */
  margin-inline-start: 1rem;
  
  /* Instead of padding-right, use: */
  padding-inline-end: 1rem;
  
  /* Instead of text-align: left */
  text-align: start;
}

/* RTL-specific adjustments */
[dir="rtl"] .icon-arrow {
  transform: scaleX(-1);
}
```

```tsx
// Next.js layout with RTL
export default function RootLayout({ children, params }) {
  const dir = params.locale === 'ar' ? 'rtl' : 'ltr';
  
  return (
    <html lang={params.locale} dir={dir}>
      <body>{children}</body>
    </html>
  );
}
```

## Best Practices

### ✅ Do This

- ✅ Use ICU message format
- ✅ Use logical CSS properties
- ✅ Format dates/numbers with Intl
- ✅ Provide context for translators
- ✅ Test with actual translators

### ❌ Avoid This

- ❌ Don't concatenate strings
- ❌ Don't hardcode date formats
- ❌ Don't assume text length
- ❌ Don't forget RTL testing

## Related Skills

- `@senior-nextjs-developer` - Next.js i18n
- `@accessibility-specialist` - Inclusive design

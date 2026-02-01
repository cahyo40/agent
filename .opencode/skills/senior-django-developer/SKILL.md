---
name: senior-django-developer
description: "Expert Django development including Django REST Framework, ORM optimization, authentication, and production-ready web applications"
---

# Senior Django Developer

## Overview

This skill helps you build robust web applications using Django with best practices for security, performance, and maintainability.

## When to Use This Skill

- Use when building Django applications
- Use when creating REST APIs with DRF
- Use when optimizing Django ORM
- Use when implementing authentication

## How It Works

### Step 1: Project Structure

```text
myproject/
├── config/                    # Project settings
│   ├── __init__.py
│   ├── settings/
│   │   ├── __init__.py
│   │   ├── base.py           # Shared settings
│   │   ├── development.py
│   │   ├── staging.py
│   │   └── production.py
│   ├── urls.py
│   ├── wsgi.py
│   └── asgi.py
├── apps/
│   ├── users/                # User management
│   │   ├── models.py
│   │   ├── views.py
│   │   ├── serializers.py
│   │   ├── urls.py
│   │   ├── admin.py
│   │   ├── tests/
│   │   └── migrations/
│   ├── products/
│   └── orders/
├── core/                     # Shared utilities
│   ├── models.py             # Abstract base models
│   ├── permissions.py
│   ├── pagination.py
│   └── exceptions.py
├── templates/
├── static/
├── media/
├── requirements/
│   ├── base.txt
│   ├── development.txt
│   └── production.txt
├── manage.py
└── docker-compose.yml
```

### Step 2: Models Best Practices

```python
# core/models.py
from django.db import models
import uuid

class TimeStampedModel(models.Model):
    """Abstract base model with timestamps."""
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        abstract = True


class UUIDModel(models.Model):
    """Abstract base model with UUID primary key."""
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)

    class Meta:
        abstract = True


# apps/products/models.py
from django.db import models
from django.utils.text import slugify
from core.models import TimeStampedModel, UUIDModel


class Category(TimeStampedModel):
    name = models.CharField(max_length=100)
    slug = models.SlugField(unique=True, blank=True)
    parent = models.ForeignKey(
        'self',
        on_delete=models.CASCADE,
        null=True,
        blank=True,
        related_name='children'
    )

    class Meta:
        verbose_name_plural = 'categories'
        ordering = ['name']
        indexes = [
            models.Index(fields=['slug']),
        ]

    def save(self, *args, **kwargs):
        if not self.slug:
            self.slug = slugify(self.name)
        super().save(*args, **kwargs)

    def __str__(self):
        return self.name


class Product(UUIDModel, TimeStampedModel):
    class Status(models.TextChoices):
        DRAFT = 'draft', 'Draft'
        ACTIVE = 'active', 'Active'
        ARCHIVED = 'archived', 'Archived'

    name = models.CharField(max_length=200)
    slug = models.SlugField(unique=True)
    description = models.TextField(blank=True)
    price = models.DecimalField(max_digits=10, decimal_places=2)
    stock = models.PositiveIntegerField(default=0)
    category = models.ForeignKey(
        Category,
        on_delete=models.PROTECT,
        related_name='products'
    )
    status = models.CharField(
        max_length=20,
        choices=Status.choices,
        default=Status.DRAFT
    )

    class Meta:
        ordering = ['-created_at']
        indexes = [
            models.Index(fields=['status', '-created_at']),
            models.Index(fields=['category', 'status']),
        ]

    @property
    def is_available(self) -> bool:
        return self.status == self.Status.ACTIVE and self.stock > 0
```

### Step 3: Django REST Framework

```python
# apps/products/serializers.py
from rest_framework import serializers
from .models import Product, Category


class CategorySerializer(serializers.ModelSerializer):
    class Meta:
        model = Category
        fields = ['id', 'name', 'slug', 'parent']


class ProductListSerializer(serializers.ModelSerializer):
    """Lightweight serializer for list views."""
    category_name = serializers.CharField(source='category.name', read_only=True)

    class Meta:
        model = Product
        fields = ['id', 'name', 'slug', 'price', 'category_name', 'is_available']


class ProductDetailSerializer(serializers.ModelSerializer):
    """Full serializer for detail views."""
    category = CategorySerializer(read_only=True)
    category_id = serializers.PrimaryKeyRelatedField(
        queryset=Category.objects.all(),
        source='category',
        write_only=True
    )

    class Meta:
        model = Product
        fields = [
            'id', 'name', 'slug', 'description', 'price',
            'stock', 'category', 'category_id', 'status',
            'is_available', 'created_at', 'updated_at'
        ]
        read_only_fields = ['slug']

    def create(self, validated_data):
        validated_data['slug'] = slugify(validated_data['name'])
        return super().create(validated_data)


# apps/products/views.py
from rest_framework import viewsets, filters, status
from rest_framework.decorators import action
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated, IsAdminUser
from django_filters.rest_framework import DjangoFilterBackend
from .models import Product
from .serializers import ProductListSerializer, ProductDetailSerializer
from .filters import ProductFilter


class ProductViewSet(viewsets.ModelViewSet):
    queryset = Product.objects.select_related('category').all()
    filter_backends = [DjangoFilterBackend, filters.SearchFilter, filters.OrderingFilter]
    filterset_class = ProductFilter
    search_fields = ['name', 'description']
    ordering_fields = ['price', 'created_at', 'name']
    ordering = ['-created_at']

    def get_serializer_class(self):
        if self.action == 'list':
            return ProductListSerializer
        return ProductDetailSerializer

    def get_permissions(self):
        if self.action in ['create', 'update', 'partial_update', 'destroy']:
            return [IsAdminUser()]
        return [IsAuthenticated()]

    def get_queryset(self):
        qs = super().get_queryset()
        if not self.request.user.is_staff:
            qs = qs.filter(status=Product.Status.ACTIVE)
        return qs

    @action(detail=True, methods=['post'])
    def archive(self, request, pk=None):
        product = self.get_object()
        product.status = Product.Status.ARCHIVED
        product.save(update_fields=['status', 'updated_at'])
        return Response({'status': 'archived'})
```

### Step 4: ORM Optimization

```python
# ════════════════════════════════════════════════════════════════════════════
# N+1 Problem Solutions
# ════════════════════════════════════════════════════════════════════════════

# ❌ BAD: N+1 queries
products = Product.objects.all()
for product in products:
    print(product.category.name)  # Query for each product!

# ✅ GOOD: select_related for ForeignKey/OneToOne
products = Product.objects.select_related('category').all()
for product in products:
    print(product.category.name)  # No additional queries

# ✅ GOOD: prefetch_related for ManyToMany/reverse FK
categories = Category.objects.prefetch_related('products').all()
for category in categories:
    for product in category.products.all():  # No additional queries
        print(product.name)


# ════════════════════════════════════════════════════════════════════════════
# QuerySet Optimization
# ════════════════════════════════════════════════════════════════════════════

# Only fetch needed fields
products = Product.objects.only('id', 'name', 'price').all()

# Defer heavy fields
products = Product.objects.defer('description').all()

# Use values() for dicts
product_data = Product.objects.values('id', 'name', 'price')

# Aggregate in database
from django.db.models import Count, Avg, Sum

stats = Product.objects.aggregate(
    total_products=Count('id'),
    avg_price=Avg('price'),
    total_value=Sum('price')
)

# Annotate for computed fields
categories = Category.objects.annotate(
    product_count=Count('products'),
    avg_product_price=Avg('products__price')
)

# Bulk operations
Product.objects.filter(status='draft').update(status='active')
Product.objects.bulk_create([Product(...), Product(...)])
Product.objects.bulk_update(products, ['price', 'stock'])


# ════════════════════════════════════════════════════════════════════════════
# Custom QuerySet Manager
# ════════════════════════════════════════════════════════════════════════════

class ProductQuerySet(models.QuerySet):
    def active(self):
        return self.filter(status=Product.Status.ACTIVE)

    def available(self):
        return self.active().filter(stock__gt=0)

    def by_category(self, category_slug):
        return self.filter(category__slug=category_slug)

    def with_category(self):
        return self.select_related('category')


class ProductManager(models.Manager):
    def get_queryset(self):
        return ProductQuerySet(self.model, using=self._db)

    def active(self):
        return self.get_queryset().active()

    def available(self):
        return self.get_queryset().available()


class Product(models.Model):
    # ... fields ...
    objects = ProductManager()

# Usage
Product.objects.active().with_category()
Product.objects.available().by_category('electronics')
```

### Step 5: Authentication & Permissions

```python
# apps/users/models.py
from django.contrib.auth.models import AbstractUser
from django.db import models


class User(AbstractUser):
    email = models.EmailField(unique=True)
    phone = models.CharField(max_length=20, blank=True)
    avatar = models.ImageField(upload_to='avatars/', blank=True)

    USERNAME_FIELD = 'email'
    REQUIRED_FIELDS = ['username']

    def __str__(self):
        return self.email


# core/permissions.py
from rest_framework.permissions import BasePermission


class IsOwner(BasePermission):
    def has_object_permission(self, request, view, obj):
        return obj.user == request.user


class IsOwnerOrAdmin(BasePermission):
    def has_object_permission(self, request, view, obj):
        return obj.user == request.user or request.user.is_staff


# JWT Authentication with SimpleJWT
# settings/base.py
REST_FRAMEWORK = {
    'DEFAULT_AUTHENTICATION_CLASSES': [
        'rest_framework_simplejwt.authentication.JWTAuthentication',
    ],
    'DEFAULT_PERMISSION_CLASSES': [
        'rest_framework.permissions.IsAuthenticated',
    ],
    'DEFAULT_PAGINATION_CLASS': 'core.pagination.StandardPagination',
    'PAGE_SIZE': 20,
}

SIMPLE_JWT = {
    'ACCESS_TOKEN_LIFETIME': timedelta(minutes=60),
    'REFRESH_TOKEN_LIFETIME': timedelta(days=7),
    'ROTATE_REFRESH_TOKENS': True,
}
```

### Step 6: Signals & Celery Tasks

```python
# apps/orders/signals.py
from django.db.models.signals import post_save
from django.dispatch import receiver
from .models import Order
from .tasks import send_order_confirmation_email


@receiver(post_save, sender=Order)
def order_created(sender, instance, created, **kwargs):
    if created:
        send_order_confirmation_email.delay(instance.id)


# apps/orders/tasks.py
from celery import shared_task
from django.core.mail import send_mail
from .models import Order


@shared_task
def send_order_confirmation_email(order_id: int):
    order = Order.objects.select_related('user').get(id=order_id)
    send_mail(
        subject=f'Order Confirmation #{order.id}',
        message=f'Thank you for your order!',
        from_email='noreply@example.com',
        recipient_list=[order.user.email],
    )


@shared_task
def cleanup_expired_carts():
    from datetime import timedelta
    from django.utils import timezone
    
    threshold = timezone.now() - timedelta(days=7)
    Cart.objects.filter(updated_at__lt=threshold).delete()
```

## Best Practices

### ✅ Do This

- ✅ Use `select_related` and `prefetch_related`
- ✅ Create custom managers for common queries
- ✅ Use database indexes
- ✅ Separate serializers for list/detail
- ✅ Use Celery for async tasks

### ❌ Avoid This

- ❌ Don't put business logic in views
- ❌ Don't use `Model.objects.all()` in loops
- ❌ Don't skip database indexes
- ❌ Don't hardcode settings

## Related Skills

- `@senior-python-developer` - Python patterns
- `@senior-database-engineer-sql` - Database design

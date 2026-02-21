---
description: Integrasi Supabase sebagai alternative backend dengan GetX state management: Authentication, PostgreSQL Database, Rea... (Part 7/7)
---
# Workflow: Supabase Integration (GetX) (Part 7/7)

> **Navigation:** This workflow is split into 7 parts.

## Workflow Steps

1. **Setup Supabase Project**
   - Create project di supabase.com
   - Copy URL dan anon key
   - Setup environment variables (`--dart-define`)
   - Initialize Supabase di `main.dart` sebelum `runApp()`
   - Register services di `InitialBinding`

2. **Configure Authentication**
   - Enable auth methods (email, magic link, OAuth)
   - Setup OAuth providers (Google, Apple, etc.)
   - Implement auth repository (framework-agnostic)
   - Create `AuthController extends GetxController`
   - Listen `onAuthStateChange` di `onInit()`
   - Setup `AuthMiddleware` untuk protected routes
   - Navigate dengan `Get.offAllNamed()`

3. **Design Database Schema**
   - Create tables di Supabase Dashboard
   - Setup relationships dan foreign keys
   - Add indexes untuk performance
   - Enable RLS (Row Level Security)

4. **Create RLS Policies**
   - Policies untuk authenticated users
   - Policies untuk anon users (if needed)
   - Test policies dengan different users
   - Validate security

5. **Implement CRUD Controller**
   - Data source (framework-agnostic)
   - `ProductController extends GetxController` dengan `RxList`, `RxBool`
   - Search dengan `debounce()`
   - Pagination
   - Register di `ProductBinding`

6. **Setup Realtime**
   - Enable realtime untuk tables di Supabase Dashboard
   - `RealtimeProductController` — subscribe di `onInit()`
   - Unsubscribe di `onClose()`
   - Handle INSERT, UPDATE, DELETE events
   - Presence tracking (optional)

7. **Configure Storage**
   - Create storage buckets di Supabase Dashboard
   - Setup RLS untuk storage
   - Implement `SupabaseStorageService` (framework-agnostic)
   - `UploadController` dengan `RxDouble` progress
   - Register service di `InitialBinding`

8. **Test Integration**
   - Test auth flows (login, register, magic link, OAuth, logout)
   - Test CRUD operations
   - Test RLS policies (coba akses data user lain)
   - Test realtime subscriptions
   - Test file upload dan delete
   - Test controller lifecycle (`onInit` / `onClose`)


## Success Criteria

- [ ] Supabase initialized sebelum `runApp()` tanpa `ProviderScope`
- [ ] `AuthController` menggunakan `Rx<User?>` dan `Rx<Session?>`
- [ ] Auth state change di-listen di `onInit()`, di-cancel di `onClose()`
- [ ] Authentication berfungsi (email/password, magic link, OAuth)
- [ ] Navigation redirect pakai `Get.offAllNamed()`
- [ ] `AuthMiddleware` proteksi protected routes
- [ ] PostgreSQL CRUD operations berfungsi
- [ ] `ProductController` menggunakan `RxList<ProductModel>`
- [ ] Search dengan `debounce()` berfungsi
- [ ] Pagination berfungsi
- [ ] RLS policies configured dan tested
- [ ] Realtime subscriptions managed di `onInit()` / `onClose()`
- [ ] Realtime data otomatis update `RxList`
- [ ] Presence tracking berfungsi (optional)
- [ ] File upload dengan `RxDouble` progress tracking
- [ ] Storage service registered via `Get.lazyPut()` di bindings
- [ ] Storage RLS policies configured
- [ ] Error handling implemented untuk semua Supabase exceptions
- [ ] Semua bindings terdefinisi (Initial, Product, Realtime, Upload)


## RLS Best Practices

### PostgreSQL RLS Policies
```sql
-- 1. Selalu enable RLS untuk semua tables
ALTER TABLE products ENABLE ROW LEVEL SECURITY;

-- 2. Default deny all — PENTING untuk keamanan
CREATE POLICY "Deny all" ON products FOR ALL TO PUBLIC USING (false);

-- 3. Specific policies untuk setiap operation
CREATE POLICY "Select own products"
ON products FOR SELECT
USING (auth.uid() = user_id);

CREATE POLICY "Insert own products"
ON products FOR INSERT
WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Update own products"
ON products FOR UPDATE
USING (auth.uid() = user_id)
WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Delete own products"
ON products FOR DELETE
USING (auth.uid() = user_id);

-- 4. Use functions untuk complex logic
CREATE OR REPLACE FUNCTION is_product_owner(product_id uuid)
RETURNS BOOLEAN AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1 FROM products
    WHERE id = product_id AND user_id = auth.uid()
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 5. Performance: Index pada columns yang digunakan di policies
CREATE INDEX idx_products_user_id ON products(user_id);

-- 6. Role-based access (admin, moderator)
CREATE POLICY "Admin full access"
ON products FOR ALL
TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM user_roles
    WHERE user_id = auth.uid() AND role = 'admin'
  )
);

-- 7. Public read, owner write pattern
CREATE POLICY "Public read"
ON products FOR SELECT
TO anon, authenticated
USING (is_published = true);

CREATE POLICY "Owner write"
ON products FOR INSERT
TO authenticated
WITH CHECK (auth.uid() = user_id);
```

### GetX-Specific Tips untuk Supabase

```dart
// 1. Permanent controller untuk auth — jangan sampai di-dispose
Get.put<AuthController>(AuthController(), permanent: true);

// 2. Lazy put dengan fenix untuk services yang bisa re-create
Get.lazyPut<SupabaseStorageService>(
  () => SupabaseStorageService(),
  fenix: true,
);

// 3. Selalu cancel subscriptions di onClose()
@override
void onClose() {
  _authSubscription?.cancel();
  _realtimeChannel?.unsubscribe();
  super.onClose();
}

// 4. Gunakan ever() / debounce() untuk reactive search
debounce(searchQuery, (_) => _performSearch(),
  time: const Duration(milliseconds: 500));

// 5. Gunakan workers untuk react ke auth changes
ever(isAuthenticated, (bool authenticated) {
  if (!authenticated) {
    Get.offAllNamed(AppRoutes.login);
  }
});
```


## Next Steps

Setelah Supabase integration selesai:
1. Implement comprehensive testing (unit test controllers, integration test auth flow)
2. Setup CI/CD pipeline
3. Add analytics tracking
4. Monitor performance dengan Supabase Dashboard
5. Setup backup dan disaster recovery
6. Pertimbangkan Supabase Edge Functions untuk server-side logic
7. Implement offline-first strategy dengan local cache

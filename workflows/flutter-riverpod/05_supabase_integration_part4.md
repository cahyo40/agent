---
description: Integrasi Supabase sebagai alternative backend: Authentication, PostgreSQL Database, Realtime subscriptions, dan Storage. (Part 4/4)
---
# Workflow: Supabase Integration (Part 4/4)

> **Navigation:** This workflow is split into 4 parts.

## Workflow Steps

1. **Setup Supabase Project**
   - Create project di supabase.com
   - Copy URL dan anon key
   - Setup environment variables
   - Initialize Supabase di Flutter

2. **Configure Authentication**
   - Enable auth methods (email, magic link, OAuth)
   - Setup OAuth providers (Google, Apple, etc.)
   - Implement auth repository
   - Create auth controller dengan Riverpod

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

5. **Implement Repository Pattern**
   - CRUD operations
   - Advanced queries (search, filters)
   - Pagination
   - Joins dengan related tables

6. **Setup Realtime**
   - Enable realtime untuk tables
   - Subscribe ke changes
   - Handle INSERT, UPDATE, DELETE events
   - Update UI secara real-time

7. **Configure Storage**
   - Create storage buckets
   - Setup RLS untuk storage
   - Implement file upload/download
   - Add image compression

8. **Test Integration**
   - Test auth flows
   - Test CRUD operations
   - Test RLS policies
   - Test realtime subscriptions
   - Test file upload


## Success Criteria

- [ ] Supabase initialized dan connected
- [ ] Authentication berfungsi (email/password, magic link, OAuth)
- [ ] Auth state stream implemented
- [ ] PostgreSQL CRUD operations berfungsi
- [ ] RLS policies configured dan tested
- [ ] Realtime subscriptions berfungsi
- [ ] File upload/download dengan Supabase Storage berfungsi
- [ ] Storage RLS policies configured
- [ ] All operations respect RLS policies
- [ ] Error handling implemented untuk semua Supabase exceptions


## RLS Best Practices

### PostgreSQL RLS Policies
```sql
-- 1. Selalu enable RLS untuk semua tables
ALTER TABLE products ENABLE ROW LEVEL SECURITY;

-- 2. Default deny all
CREATE POLICY "Deny all" ON products FOR ALL TO PUBLIC USING (false);

-- 3. Specific policies untuk setiap operation
CREATE POLICY "Select own products" 
ON products FOR SELECT 
USING (auth.uid() = user_id);

CREATE POLICY "Insert own products"
ON products FOR INSERT
WITH CHECK (auth.uid() = user_id);

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
```


## Next Steps

Setelah Supabase integration selesai:
1. Implement comprehensive testing
2. Setup CI/CD pipeline
3. Add analytics tracking
4. Monitor performance dengan Supabase Dashboard
5. Setup backup dan disaster recovery

---
description: Integrasi Supabase sebagai alternative backend dengan flutter_bloc state management: Authentication, PostgreSQL Datab... (Part 7/8)
---
# Workflow: Supabase Integration (flutter_bloc) (Part 7/8)

> **Navigation:** This workflow is split into 8 parts.

## Deliverables

### 6. RLS Best Practices & Advanced Policies

**Description:** Row Level Security policies dan SQL best practices. Section ini framework-agnostic — sama untuk Riverpod, GetX, maupun BLoC.

**Recommended Skills:** `senior-supabase-developer`, `senior-database-engineer-sql`

```sql
-- ============================================================
-- 1. Selalu enable RLS untuk semua tables
-- ============================================================
ALTER TABLE products ENABLE ROW LEVEL SECURITY;

-- ============================================================
-- 2. Default deny all — PENTING untuk keamanan
-- ============================================================
CREATE POLICY "Deny all" ON products FOR ALL TO PUBLIC USING (false);

-- ============================================================
-- 3. Specific policies untuk setiap operation
-- ============================================================
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

-- ============================================================
-- 4. Use functions untuk complex logic
-- ============================================================
CREATE OR REPLACE FUNCTION is_product_owner(product_id uuid)
RETURNS BOOLEAN AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1 FROM products
    WHERE id = product_id AND user_id = auth.uid()
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================================
-- 5. Performance: Index pada columns yang digunakan di policies
-- ============================================================
CREATE INDEX idx_products_user_id ON products(user_id);

-- ============================================================
-- 6. Role-based access (admin, moderator)
-- ============================================================
CREATE POLICY "Admin full access"
ON products FOR ALL
TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM user_roles
    WHERE user_id = auth.uid() AND role = 'admin'
  )
);

-- ============================================================
-- 7. Public read, owner write pattern
-- ============================================================
CREATE POLICY "Public read"
ON products FOR SELECT
TO anon, authenticated
USING (is_published = true);

CREATE POLICY "Owner write"
ON products FOR INSERT
TO authenticated
WITH CHECK (auth.uid() = user_id);
```

---


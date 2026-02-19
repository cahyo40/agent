---
description: Integrasi PostgreSQL dengan SQLX dan migrations untuk Golang backend. (Part 4/6)
---
# 03 - Database Integration (PostgreSQL + SQLX) (Part 4/6)

> **Navigation:** This workflow is split into 6 parts.

## Deliverables

### 6. Advanced Queries

**File: `internal/repository/advanced_queries.go`**

```go
package repository

import (
	"context"
	"fmt"
	"strings"

	"github.com/jmoiron/sqlx"
	"github.com/myapp/internal/domain"
)

// AdvancedRepository shows complex SQL patterns
type AdvancedRepository struct {
	db *sqlx.DB
}

// OrderDetail dengan JOINs
func (r *AdvancedRepository) GetOrderWithDetails(ctx context.Context, orderID uuid.UUID) (*domain.OrderDetail, error) {
	var order domain.OrderDetail

	query := `
		SELECT 
			o.id, o.user_id, o.status, o.total_amount,
			o.shipping_address, o.created_at, o.updated_at,
			u.email as user_email,
			u.full_name as user_full_name
		FROM orders o
		INNER JOIN users u ON o.user_id = u.id
		WHERE o.id = $1 AND o.deleted_at IS NULL
	`

	if err := r.db.GetContext(ctx, &order, query, orderID); err != nil {
		return nil, err
	}

	// Get order items dengan product details
	itemsQuery := `
		SELECT 
			i.id, i.order_id, i.product_id, i.quantity, i.price, i.total,
			p.name as product_name,
			p.sku as product_sku,
			c.name as category_name
		FROM order_items i
		INNER JOIN products p ON i.product_id = p.id
		LEFT JOIN categories c ON p.category_id = c.id
		WHERE i.order_id = $1
	`

	if err := r.db.SelectContext(ctx, &order.Items, itemsQuery, orderID); err != nil {
		return nil, err
	}

	return &order, nil
}

// Complex JOIN dengan aggregation
func (r *AdvancedRepository) GetUserOrderSummary(ctx context.Context, userID uuid.UUID) (*domain.UserOrderSummary, error) {
	var summary domain.UserOrderSummary

	query := `
		SELECT 
			u.id as user_id,
			u.email,
			u.full_name,
			COUNT(DISTINCT o.id) as total_orders,
			COALESCE(SUM(o.total_amount), 0) as total_spent,
			COALESCE(AVG(o.total_amount), 0) as avg_order_value,
			MAX(o.created_at) as last_order_date
		FROM users u
		LEFT JOIN orders o ON u.id = o.user_id AND o.status != 'cancelled'
		WHERE u.id = $1 AND u.deleted_at IS NULL
		GROUP BY u.id, u.email, u.full_name
	`

	if err := r.db.GetContext(ctx, &summary, query, userID); err != nil {
		return nil, err
	}

	return &summary, nil
}

// Pagination dengan cursor
func (r *AdvancedRepository) ListProductsWithCursor(ctx context.Context, cursor *domain.Cursor) (*domain.PaginatedProducts, error) {
	result := &domain.PaginatedProducts{
		Items: []domain.Product{},
	}

	// Base query
	baseQuery := `
		FROM products p
		LEFT JOIN categories c ON p.category_id = c.id
		WHERE p.deleted_at IS NULL
	`

	args := []interface{}{}
	argCount := 1

	// Filter by category
	if cursor.CategoryID != nil {
		baseQuery += fmt.Sprintf(" AND p.category_id = $%d", argCount)
		args = append(args, *cursor.CategoryID)
		argCount++
	}

	// Filter by status
	if cursor.Status != "" {
		baseQuery += fmt.Sprintf(" AND p.status = $%d", argCount)
		args = append(args, cursor.Status)
		argCount++
	}

	// Cursor condition (for keyset pagination)
	if cursor.LastID != nil && cursor.LastValue != nil {
		baseQuery += fmt.Sprintf(
			" AND (p.%s, p.id) > ($%d, $%d)",
			cursor.SortBy, argCount, argCount+1,
		)
		args = append(args, *cursor.LastValue, *cursor.LastID)
		argCount += 2
	}

	// Count total (only for first page)
	if cursor.LastID == nil {
		countQuery := "SELECT COUNT(*) " + baseQuery
		if err := r.db.GetContext(ctx, &result.Total, countQuery, args...); err != nil {
			return nil, err
		}
	}

	// Sort order
	sortOrder := "ASC"
	if cursor.SortOrder == "desc" {
		sortOrder = "DESC"
	}

	sortColumn := cursor.SortBy
	if sortColumn == "" {
		sortColumn = "created_at"
	}

	// Data query
	query := fmt.Sprintf(`
		SELECT 
			p.id, p.sku, p.name, p.description, p.price,
			p.stock_quantity, p.status, p.created_at, p.updated_at,
			c.id as category_id, c.name as category_name
		%s
		ORDER BY p.%s %s, p.id %s
		LIMIT $%d
	`, baseQuery, sortColumn, sortOrder, sortOrder, argCount)

	args = append(args, cursor.Limit+1) // +1 untuk check next page

	if err := r.db.SelectContext(ctx, &result.Items, query, args...); err != nil {
		return nil, err
	}

	// Check if has more
	if len(result.Items) > cursor.Limit {
		result.HasMore = true
		result.Items = result.Items[:cursor.Limit]
		
		// Set next cursor
		lastItem := result.Items[len(result.Items)-1]
		result.NextCursor = &domain.CursorToken{
			ID:    lastItem.ID,
			Value: r.getSortValue(lastItem, sortColumn),
		}
	}

	return result, nil
}

// Search dengan ILIKE dan Full-Text
func (r *AdvancedRepository) SearchProducts(ctx context.Context, req *domain.SearchRequest) (*domain.SearchResult, error) {
	result := &domain.SearchResult{
		Items: []domain.Product{},
	}

	var whereClause string
	var args []interface{}
	argCount := 1

	// Full-text search menggunakan tsvector
	if req.Query != "" {
		whereClause += fmt.Sprintf(
			" AND (to_tsvector('indonesian', p.name || ' ' || COALESCE(p.description, '')) @@ plainto_tsquery('indonesian', $%d) "+
			" OR p.name ILIKE $%d OR p.sku ILIKE $%d)",
			argCount, argCount+1, argCount+2,
		)
		args = append(args, req.Query, "%"+req.Query+"%", "%"+req.Query+"%")
		argCount += 3
	}

	// Price range filter
	if req.MinPrice != nil {
		whereClause += fmt.Sprintf(" AND p.price >= $%d", argCount)
		args = append(args, *req.MinPrice)
		argCount++
	}

	if req.MaxPrice != nil {
		whereClause += fmt.Sprintf(" AND p.price <= $%d", argCount)
		args = append(args, *req.MaxPrice)
		argCount++
	}

	// Category filter
	if len(req.CategoryIDs) > 0 {
		placeholders := make([]string, len(req.CategoryIDs))
		for i, id := range req.CategoryIDs {
			placeholders[i] = fmt.Sprintf("$%d", argCount)
			args = append(args, id)
			argCount++
		}
		whereClause += fmt.Sprintf(" AND p.category_id IN (%s)", strings.Join(placeholders, ","))
	}

	// Status filter
	if req.Status != "" {
		whereClause += fmt.Sprintf(" AND p.status = $%d", argCount)
		args = append(args, req.Status)
		argCount++
	}

	// Count query
	countQuery := `
		SELECT COUNT(*) 
		FROM products p 
		WHERE p.deleted_at IS NULL
	` + whereClause

	if err := r.db.GetContext(ctx, &result.Total, countQuery, args...); err != nil {
		return nil, err
	}

	// Data query dengan relevance scoring
	sortBy := "p.created_at"
	sortOrder := "DESC"

	if req.SortBy == "price" {
		sortBy = "p.price"
	} else if req.SortBy == "name" {
		sortBy = "p.name"
	}

	if req.SortOrder == "asc" {
		sortOrder = "ASC"
	}

	query := fmt.Sprintf(`
		SELECT 
			p.id, p.sku, p.name, p.description, p.price,
			p.stock_quantity, p.status, p.created_at, p.updated_at,
			c.id as category_id, c.name as category_name
		FROM products p
		LEFT JOIN categories c ON p.category_id = c.id
		WHERE p.deleted_at IS NULL
		%s
		ORDER BY %s %s
		LIMIT $%d OFFSET $%d
	`, whereClause, sortBy, sortOrder, argCount, argCount+1)

	args = append(args, req.PageSize, (req.Page-1)*req.PageSize)

	if err := r.db.SelectContext(ctx, &result.Items, query, args...); err != nil {
		return nil, err
	}

	result.Page = req.Page
	result.PageSize = req.PageSize
	result.TotalPages = (result.Total + req.PageSize - 1) / req.PageSize

	return result, nil
}

// Bulk operations
func (r *AdvancedRepository) BulkInsertProducts(ctx context.Context, products []domain.Product) error {
	if len(products) == 0 {
		return nil
	}

	// PostgreSQL unnest untuk bulk insert
	query := `
		INSERT INTO products (sku, name, description, price, stock_quantity, category_id, status)
		SELECT * FROM UNNEST($1::text[], $2::text[], $3::text[], $4::decimal[], $5::int[], $6::uuid[], $7::text[])
	`

	var (
		skus         []string
		names        []string
		descriptions []string
		prices       []float64
		stocks       []int
		categoryIDs  []uuid.UUID
		statuses     []string
	)

	for _, p := range products {
		skus = append(skus, p.SKU)
		names = append(names, p.Name)
		descriptions = append(descriptions, p.Description)
		prices = append(prices, p.Price)
		stocks = append(stocks, p.StockQuantity)
		categoryIDs = append(categoryIDs, p.CategoryID)
		statuses = append(statuses, p.Status)
	}

	_, err := r.db.ExecContext(ctx, query, skus, names, descriptions, prices, stocks, categoryIDs, statuses)
	return err
}

// CTE (Common Table Expressions)
func (r *AdvancedRepository) GetCategoryHierarchy(ctx context.Context, categoryID uuid.UUID) (*domain.CategoryHierarchy, error) {
	query := `
		WITH RECURSIVE category_tree AS (
			-- Base case: get the starting category
			SELECT id, name, slug, parent_id, 0 as level
			FROM categories
			WHERE id = $1
			
			UNION ALL
			
			-- Recursive case: get all ancestors
			SELECT c.id, c.name, c.slug, c.parent_id, ct.level + 1
			FROM categories c
			INNER JOIN category_tree ct ON c.id = ct.parent_id
		),
		product_counts AS (
			SELECT category_id, COUNT(*) as product_count
			FROM products
			WHERE status = 'active'
			GROUP BY category_id
		)
		SELECT 
			ct.id, ct.name, ct.slug, ct.parent_id, ct.level,
			COALESCE(pc.product_count, 0) as product_count
		FROM category_tree ct
		LEFT JOIN product_counts pc ON ct.id = pc.category_id
		ORDER BY ct.level DESC
	`

	var hierarchy domain.CategoryHierarchy
	if err := r.db.SelectContext(ctx, &hierarchy.Path, query, categoryID); err != nil {
		return nil, err
	}

	return &hierarchy, nil
}
```

---


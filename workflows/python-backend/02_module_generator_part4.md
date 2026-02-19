---
description: Workflow ini menyediakan template untuk generate semua layer dari satu module baru:. (Part 4/4)
---
# 02 - Module Generator (Clean Architecture) (Part 4/4)

> **Navigation:** This workflow is split into 4 parts.

## Workflow Steps

1. **Tentukan nama module** (misal: `product`, `order`, `category`)
2. **Replace placeholders:**
   - `{{ModuleName}}` → `Product` (PascalCase)
   - `{{module_name}}` → `product` (snake_case)
3. **Buat file-file dari template** ke folder yang sesuai
4. **Tambahkan dependency injection** ke `app/api/deps.py`
5. **Register router** di `app/api/v1/router.py`
6. **Import model** di `alembic/env.py`
7. **Generate migration:** `alembic revision --autogenerate -m "create_products_table"`
8. **Run migration:** `alembic upgrade head`
9. **Run tests:** `pytest tests/unit/test_product_service.py`
10. **Verify endpoints:** `curl http://localhost:8000/docs`


## Success Criteria
- All template files compile without errors
- Module registered in FastAPI docs (/docs)
- All CRUD endpoints respond correctly
- Unit tests pass with mocked repository
- Migration generates correct SQL
- Dependency injection chain works


## Next Steps
- `03_database_integration.md` - Advanced database patterns
- `04_auth_security.md` - Protect endpoints with JWT

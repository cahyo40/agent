---
description: Implementasi JWT authentication, password hashing, dan security middleware untuk FastAPI backend. (Part 4/4)
---
# 04 - JWT Authentication & Security (Part 4/4)

> **Navigation:** This workflow is split into 4 parts.

## Protected Route Examples

```python
# Any authenticated user
@router.get("/profile")
async def profile(
    user: User = Depends(get_current_user),
):
    return UserResponse.model_validate(user)


# Admin only
@router.delete("/admin/users/{id}")
async def admin_delete(
    id: uuid.UUID,
    user: User = Depends(require_role("admin")),
):
    ...


# Admin or moderator
@router.put("/moderate/{id}")
async def moderate(
    id: uuid.UUID,
    user: User = Depends(
        require_role("admin", "moderator")
    ),
):
    ...
```

---


## Success Criteria
- JWT access + refresh token generation works
- Password hashing and verification functional
- Auth middleware extracts user from token
- RBAC checks role correctly
- Rate limiting blocks excess requests
- Security headers present on all responses
- All unit tests pass


## Next Steps
- `05_file_management.md` - File upload & storage
- `08_caching_redis.md` - Redis session store

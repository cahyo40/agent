---
description: Implementasi repository pattern dengan REST API menggunakan Dio. (Part 4/4)
---
# Workflow: Backend Integration (REST API) (Part 4/4)

> **Navigation:** This workflow is split into 4 parts.

## Workflow Steps

1. **Setup Dio Client**
   - Configure base options
   - Add interceptors
   - Setup error mapper

2. **Implement Auth Flow**
   - Login/logout API
   - Token storage
   - Token refresh mechanism

3. **Create Repository Layer**
   - Implement remote data source
   - Implement local data source (cache)
   - Create repository dengan offline-first

4. **Setup Error Handling**
   - Error mapper implementation
   - User-friendly error messages
   - Retry logic

5. **Implement Features**
   - CRUD operations
   - File upload (if needed)
   - Pagination
   - Real-time updates (if needed)

6. **Add Optimistic Updates**
   - Update UI immediately
   - Handle failure rollback
   - Show success/error feedback

7. **Test Integration**
   - Test with mock server
   - Test error scenarios
   - Test offline behavior
   - Test pagination


## Success Criteria

- [ ] Dio configured dengan semua interceptors
- [ ] Auth token auto-refresh berfungsi
- [ ] Error mapping ke AppException berfungsi
- [ ] Repository dengan offline-first implemented
- [ ] Pagination dengan infinite scroll berfungsi
- [ ] Optimistic updates implemented
- [ ] Retry mechanism untuk 5xx errors
- [ ] Timeout configured (15s)
- [ ] Error messages user-friendly
- [ ] All CRUD operations tested


## Best Practices

### ✅ Do This
- ✅ Set API timeout ke 15s (bukan 30s default)
- ✅ Implement cache-first strategy untuk static data
- ✅ Use debounce (300-500ms) untuk search
- ✅ Implement retry interceptor untuk 5xx errors
- ✅ Use optimistic updates untuk instant UX
- ✅ Always check connectivity sebelum API call
- ✅ Implement pull-to-refresh + pagination combo
- ✅ Use shimmer loading skeletons

### ❌ Avoid This
- ❌ Hardcode API URLs - gunakan AppConfig
- ❌ Skip error handling
- ❌ Load semua data sekaligus - gunakan pagination
- ❌ Skip connectivity check
- ❌ Use CircularProgressIndicator untuk initial load


## Next Steps

Setelah backend integration selesai:
1. Add Firebase integration (auth, firestore, storage)
2. Add Supabase integration (alternative backend)
3. Implement comprehensive testing
4. Setup CI/CD pipeline

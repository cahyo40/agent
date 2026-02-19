---
description: Integrasi Supabase sebagai alternative backend dengan flutter_bloc state management: Authentication, PostgreSQL Datab... (Part 8/8)
---
# Workflow: Supabase Integration (flutter_bloc) (Part 8/8)

> **Navigation:** This workflow is split into 8 parts.

## Workflow Steps

1. **Setup Supabase Project**
   - Create project di supabase.com
   - Copy URL dan anon key
   - Setup environment variables (`--dart-define`)
   - Initialize Supabase di `bootstrap()` sebelum `runApp()`
   - Setup `get_it` + `injectable` DI
   - Register `SupabaseClient` sebagai external module

2. **Configure Authentication**
   - Enable auth methods (email, magic link, OAuth)
   - Setup OAuth providers (Google, Apple, etc.)
   - Implement auth repository (framework-agnostic)
   - Create `AuthBloc` dengan sealed `SupabaseAuthEvent` / `SupabaseAuthState`
   - Listen `onAuthStateChange` via `StreamSubscription` di constructor
   - Cancel subscription di `close()`
   - Setup GoRouter `redirect` guard untuk navigation

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

5. **Implement CRUD Bloc**
   - Data source (framework-agnostic)
   - `ProductBloc` dengan sealed event classes per operasi
   - `ProductState` dengan `copyWith` — termasuk pagination info
   - Register via `@Injectable()` di get_it
   - Provide via `BlocProvider` di widget tree

6. **Setup Realtime**
   - Enable realtime untuk tables di Supabase Dashboard
   - `RealtimeProductBloc` — subscribe channel di constructor
   - Unsubscribe di `close()`
   - Realtime callback -> internal event -> state update
   - `ProductDetailBloc` untuk watch single product
   - `ChatBloc` untuk messaging
   - `PresenceCubit` untuk online tracking

7. **Configure Storage**
   - Create storage buckets di Supabase Dashboard
   - Setup RLS untuk storage
   - Implement `SupabaseStorageService` (framework-agnostic)
   - `UploadCubit` dengan progress tracking
   - Register service via `@LazySingleton` di get_it

8. **Test Integration**
   - Test auth flows (login, register, magic link, OAuth, logout)
   - Test CRUD operations
   - Test RLS policies (coba akses data user lain)
   - Test realtime subscriptions
   - Test file upload dan delete
   - Test bloc lifecycle (`close()` cleanup)


## Success Criteria

- [ ] Supabase initialized di `bootstrap()` sebelum `runApp()`
- [ ] DI menggunakan `get_it` + `injectable` — `SupabaseClient` sebagai external module
- [ ] `AuthBloc` menggunakan sealed `SupabaseAuthEvent` dan `SupabaseAuthState` (Equatable)
- [ ] Auth state change di-listen via `StreamSubscription` di constructor, cancel di `close()`
- [ ] Authentication berfungsi (email/password, magic link, OAuth)
- [ ] Navigation redirect via GoRouter `redirect` guard
- [ ] PostgreSQL CRUD operations via `ProductBloc` event-driven
- [ ] `ProductState` menyertakan `List<ProductModel>`, pagination info, status, error
- [ ] Search products via `SearchProducts` event
- [ ] Pagination via `FetchProductsPaginated` event
- [ ] RLS policies configured dan tested
- [ ] `RealtimeProductBloc` — channel subscribe di constructor, unsubscribe di `close()`
- [ ] Realtime callback dispatch internal event `_RealtimeUpdate`
- [ ] `ProductDetailBloc` watch single product dengan filtered channel
- [ ] `ChatBloc` realtime messaging berfungsi
- [ ] `PresenceCubit` tracking online users
- [ ] `UploadCubit` dengan progress tracking
- [ ] Storage service registered via `@LazySingleton` di get_it
- [ ] Storage RLS policies configured
- [ ] Error handling implemented untuk semua Supabase exceptions
- [ ] Semua bloc/cubit cleanup resources di `close()`


## flutter_bloc-Specific Tips untuk Supabase

```dart
// 1. AuthBloc sebagai lazySingleton — hidup sepanjang app
@lazySingleton
class AuthBloc extends Bloc<SupabaseAuthEvent, SupabaseAuthState> { ... }

// 2. Provide di root — MultiBlocProvider di MyApp
MultiBlocProvider(
  providers: [
    BlocProvider<AuthBloc>(
      create: (_) => getIt<AuthBloc>()..add(CheckAuthStatus()),
    ),
  ],
  child: MaterialApp.router(...),
);

// 3. Per-route BlocProvider untuk feature blocs
BlocProvider(
  create: (_) => getIt<ProductBloc>()..add(FetchProducts()),
  child: const ProductListPage(),
);

// 4. SELALU cleanup di close() — channel, subscription, timer
@override
Future<void> close() {
  _channel?.unsubscribe();
  _authSubscription?.cancel();
  return super.close();
}

// 5. Internal events untuk realtime — prefix dengan underscore
class _RealtimeUpdate extends RealtimeProductEvent { ... }
class _AuthStateChanged extends SupabaseAuthEvent { ... }

// 6. Gunakan buildWhen untuk optimasi rebuild
BlocBuilder<UploadCubit, UploadState>(
  buildWhen: (prev, curr) => prev.progress != curr.progress,
  builder: (context, state) { ... },
);

// 7. BlocListener untuk side-effects (snackbar, navigation)
BlocListener<AuthBloc, SupabaseAuthState>(
  listener: (context, state) {
    if (state is AuthError) {
      ScaffoldMessenger.of(context).showSnackBar(...);
    }
  },
  child: ...,
);

// 8. Cubit untuk simple state (upload, toggle, counter)
// Bloc untuk complex event-driven state (auth, CRUD, realtime)
```


## Next Steps

Setelah Supabase integration selesai:
1. Implement comprehensive testing (unit test blocs, integration test auth flow)
2. Setup CI/CD pipeline
3. Add analytics tracking
4. Monitor performance dengan Supabase Dashboard
5. Setup backup dan disaster recovery
6. Pertimbangkan Supabase Edge Functions untuk server-side logic
7. Implement offline-first strategy dengan local cache

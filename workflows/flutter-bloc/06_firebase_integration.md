---
description: Integrasi Firebase services untuk Flutter dengan flutter_bloc sebagai state management.
---
# Workflow: Firebase Integration — Flutter BLoC

// turbo-all

## Overview

Integrasi Firebase services dengan BLoC architecture:
- **Firebase Auth** → `AuthBloc` dengan `StreamSubscription` ke `authStateChanges()`
- **Cloud Firestore** → real-time via `emit.forEach()` di dalam Bloc
- **Firebase Storage** → `UploadCubit` dengan progress states
- **FCM** → `NotificationService` dengan get_it injection

**Perbedaan utama dari versi Riverpod:**
- Tidak ada `ProviderScope` — gunakan `MultiBlocProvider` di root widget
- Auth state di-manage via `AuthBloc`, bukan `ref.watch(authProvider)`
- Firestore real-time via `StreamSubscription` atau `emit.forEach()`, bukan `AsyncValue`
- DI sepenuhnya via `get_it` + `injectable`


## Prerequisites

- Project setup dari `01_project_setup.md` selesai (termasuk `get_it` + `injectable`)
- Firebase account dan project dibuat
- FlutterFire CLI terinstall: `dart pub global activate flutterfire_cli`


## Agent Behavior

- **Setup Firebase** via FlutterFire CLI (`flutterfire configure`).
- **AuthBloc**: listen ke `FirebaseAuth.authStateChanges()` stream via `StreamSubscription`.
- **Firestore queries**: pakai `emit.forEach()` di dalam event handler untuk real-time.
- **Upload**: pakai `UploadCubit` dengan sealed state (initial/uploading/success/error).
- **Jangan pakai `dartz`** — gunakan `Result<T>` sealed class.
- **Jalankan `dart run build_runner build -d`** setelah semua file dibuat.


## Recommended Skills

- `senior-firebase-developer` — Firebase + BLoC
- `senior-flutter-developer` — Flutter architecture


## Dependencies

```yaml
dependencies:
  firebase_core: ^2.31.0
  firebase_auth: ^4.20.0
  cloud_firestore: ^4.17.0
  firebase_storage: ^11.7.0
  firebase_messaging: ^14.9.0
  flutter_local_notifications: ^17.1.2
  flutter_bloc: ^8.1.4
  equatable: ^2.0.5
  injectable: ^2.3.2
  get_it: ^7.6.7

dev_dependencies:
  injectable_generator: ^2.4.1
  build_runner: ^2.4.8
```


## Workflow Steps

### Step 1: Firebase Setup

```bash
# Install Firebase CLI
npm install -g firebase-tools
dart pub global activate flutterfire_cli

# Login dan configure
firebase login
flutterfire configure
```

```dart
// lib/main.dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await configureDependencies();
  runApp(const App());
}

// lib/app/app.dart
class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // Auth bloc di-provide di root — global state
        BlocProvider(create: (_) => getIt<AuthBloc>()..add(const AuthStarted())),
      ],
      child: MaterialApp.router(routerConfig: getIt<GoRouter>()),
    );
  }
}
```


### Step 2: AuthBloc (Firebase Auth + Stream)

```dart
// features/auth/presentation/bloc/auth_event.dart
part of 'auth_bloc.dart';

sealed class AuthEvent extends Equatable {
  const AuthEvent();
  @override
  List<Object?> get props => [];
}

/// Subscribe ke authStateChanges() stream
final class AuthStarted extends AuthEvent {
  const AuthStarted();
}

final class AuthSignInWithEmail extends AuthEvent {
  final String email;
  final String password;
  const AuthSignInWithEmail({required this.email, required this.password});
  @override
  List<Object?> get props => [email, password];
}

final class AuthSignUpWithEmail extends AuthEvent {
  final String email;
  final String password;
  final String displayName;
  const AuthSignUpWithEmail({
    required this.email,
    required this.password,
    required this.displayName,
  });
  @override
  List<Object?> get props => [email, password, displayName];
}

final class AuthSignOut extends AuthEvent {
  const AuthSignOut();
}

final class AuthUserChanged extends AuthEvent {
  final User? user;
  const AuthUserChanged(this.user);
  @override
  List<Object?> get props => [user];
}

// features/auth/presentation/bloc/auth_state.dart
part of 'auth_bloc.dart';

sealed class AuthState extends Equatable {
  const AuthState();
  @override
  List<Object?> get props => [];
}

final class AuthInitial extends AuthState {
  const AuthInitial();
}

final class AuthAuthenticated extends AuthState {
  final User user;
  const AuthAuthenticated(this.user);
  @override
  List<Object?> get props => [user];
}

final class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

final class AuthLoading extends AuthState {
  const AuthLoading();
}

final class AuthError extends AuthState {
  final String message;
  const AuthError(this.message);
  @override
  List<Object?> get props => [message];
}

// features/auth/presentation/bloc/auth_bloc.dart
import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

part 'auth_event.dart';
part 'auth_state.dart';

@singleton // Singleton karena global state — auth di-provide di root
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final FirebaseAuth _auth;
  StreamSubscription<User?>? _authSubscription;

  AuthBloc({required FirebaseAuth auth})
      : _auth = auth,
        super(const AuthInitial()) {
    on<AuthStarted>(_onAuthStarted);
    on<AuthUserChanged>(_onUserChanged);
    on<AuthSignInWithEmail>(_onSignInWithEmail);
    on<AuthSignUpWithEmail>(_onSignUpWithEmail);
    on<AuthSignOut>(_onSignOut);
  }

  void _onAuthStarted(AuthStarted event, Emitter<AuthState> emit) {
    // Subscribe ke Firebase auth stream
    _authSubscription = _auth.authStateChanges().listen((user) {
      add(AuthUserChanged(user));
    });
  }

  void _onUserChanged(AuthUserChanged event, Emitter<AuthState> emit) {
    if (event.user != null) {
      emit(AuthAuthenticated(event.user!));
    } else {
      emit(const AuthUnauthenticated());
    }
  }

  Future<void> _onSignInWithEmail(
    AuthSignInWithEmail event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      await _auth.signInWithEmailAndPassword(
        email: event.email,
        password: event.password,
      );
      // State akan di-update via AuthUserChanged dari stream
    } on FirebaseAuthException catch (e) {
      emit(AuthError(_mapFirebaseError(e)));
    }
  }

  Future<void> _onSignUpWithEmail(
    AuthSignUpWithEmail event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: event.email,
        password: event.password,
      );
      await credential.user?.updateDisplayName(event.displayName);
    } on FirebaseAuthException catch (e) {
      emit(AuthError(_mapFirebaseError(e)));
    }
  }

  Future<void> _onSignOut(AuthSignOut event, Emitter<AuthState> emit) async {
    await _auth.signOut();
  }

  String _mapFirebaseError(FirebaseAuthException e) {
    return switch (e.code) {
      'invalid-credential' => 'Email atau password salah',
      'user-not-found' => 'Akun tidak ditemukan',
      'wrong-password' => 'Password salah',
      'email-already-in-use' => 'Email sudah digunakan',
      'weak-password' => 'Password terlalu lemah (min 6 karakter)',
      'network-request-failed' => 'Tidak ada koneksi internet',
      _ => 'Terjadi kesalahan: ${e.message}',
    };
  }

  @override
  Future<void> close() {
    _authSubscription?.cancel();
    return super.close();
  }
}
```


### Step 3: Auth Guard (GoRouter Redirect)

```dart
// core/router/app_router.dart
@singleton
class AppRouter {
  final AuthBloc _authBloc;

  AppRouter({required AuthBloc authBloc}) : _authBloc = authBloc;

  GoRouter get router => GoRouter(
    initialLocation: '/splash',
    redirect: _authGuard,
    refreshListenable: GoRouterRefreshStream(_authBloc.stream),
    routes: [
      GoRoute(
        path: '/splash',
        builder: (_, __) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (_, __) => const LoginScreen(),
      ),
      GoRoute(
        path: '/home',
        builder: (_, __) => const HomeScreen(),
      ),
    ],
  );

  String? _authGuard(BuildContext context, GoRouterState state) {
    final authState = _authBloc.state;
    final isAuthenticated = authState is AuthAuthenticated;
    final isAuthRoute = state.matchedLocation == '/login';

    if (authState is AuthInitial) return null; // Masih loading
    if (!isAuthenticated && !isAuthRoute) return '/login';
    if (isAuthenticated && isAuthRoute) return '/home';
    return null;
  }
}

/// Listen BLoC stream untuk GoRouter refresh
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    _subscription = stream.asBroadcastStream().listen((_) => notifyListeners());
  }

  late final StreamSubscription _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
```


### Step 4: Firestore CRUD dengan BLoC

```dart
// features/posts/domain/repositories/post_repository.dart
abstract class PostRepository {
  Stream<List<Post>> watchPosts();
  Future<Result<Post>> getPost(String id);
  Future<Result<Post>> createPost(Post post);
  Future<Result<Post>> updatePost(Post post);
  Future<Result<void>> deletePost(String id);
}

// features/posts/data/repositories/post_repository_impl.dart
@LazySingleton(as: PostRepository)
class PostRepositoryImpl implements PostRepository {
  final FirebaseFirestore _firestore;
  static const _collection = 'posts';

  PostRepositoryImpl({required FirebaseFirestore firestore})
      : _firestore = firestore;

  @override
  Stream<List<Post>> watchPosts() {
    return _firestore
        .collection(_collection)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => PostModel.fromFirestore(doc).toEntity())
            .toList());
  }

  @override
  Future<Result<Post>> createPost(Post post) async {
    try {
      final docRef = _firestore.collection(_collection).doc();
      final model = PostModel.fromEntity(post.copyWith(id: docRef.id));
      await docRef.set(model.toMap());
      return Success(model.toEntity());
    } on FirebaseException catch (e) {
      return ResultFailure(ServerFailure(message: e.message ?? 'Firestore error'));
    }
  }

  @override
  Future<Result<void>> deletePost(String id) async {
    try {
      await _firestore.collection(_collection).doc(id).delete();
      return const Success(null);
    } on FirebaseException catch (e) {
      return ResultFailure(ServerFailure(message: e.message ?? 'Delete failed'));
    }
  }
}

// features/posts/presentation/bloc/post_bloc.dart
@injectable
class PostBloc extends Bloc<PostEvent, PostState> {
  final WatchPosts _watchPosts;
  final CreatePost _createPost;
  final DeletePost _deletePost;

  PostBloc({
    required WatchPosts watchPosts,
    required CreatePost createPost,
    required DeletePost deletePost,
  })  : _watchPosts = watchPosts,
        _createPost = createPost,
        _deletePost = deletePost,
        super(const PostInitial()) {
    on<WatchPostsStarted>(_onWatchStarted);
    on<CreatePostEvent>(_onCreatePost);
    on<DeletePostEvent>(_onDeletePost);
  }

  Future<void> _onWatchStarted(
    WatchPostsStarted event,
    Emitter<PostState> emit,
  ) async {
    emit(const PostLoading());
    // emit.forEach() untuk real-time Firestore stream
    await emit.forEach(
      _watchPosts(),
      onData: (posts) => PostLoaded(posts),
      onError: (error, _) => PostError(error.toString()),
    );
  }

  Future<void> _onCreatePost(
    CreatePostEvent event,
    Emitter<PostState> emit,
  ) async {
    final result = await _createPost(event.post);
    result.fold(
      (f) => emit(PostOperationError(message: f.message,
          currentPosts: state is PostLoaded
              ? (state as PostLoaded).posts
              : [])),
      (post) {
        // Real-time stream akan auto-update list — tidak perlu emit manual
      },
    );
  }

  Future<void> _onDeletePost(
    DeletePostEvent event,
    Emitter<PostState> emit,
  ) async {
    final result = await _deletePost(event.id);
    result.fold(
      (f) => emit(PostOperationError(
          message: f.message,
          currentPosts:
              state is PostLoaded ? (state as PostLoaded).posts : [])),
      (_) {
        // Firestore stream auto-update
      },
    );
  }
}
```


### Step 5: UploadCubit (Firebase Storage)

```dart
// features/upload/presentation/cubit/upload_cubit.dart
import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:injectable/injectable.dart';

// State
sealed class UploadState extends Equatable {
  const UploadState();
  @override
  List<Object?> get props => [];
}

final class UploadInitial extends UploadState {
  const UploadInitial();
}

final class UploadInProgress extends UploadState {
  final double progress; // 0.0 - 1.0
  const UploadInProgress(this.progress);
  @override
  List<Object?> get props => [progress];
}

final class UploadSuccess extends UploadState {
  final String downloadUrl;
  const UploadSuccess(this.downloadUrl);
  @override
  List<Object?> get props => [downloadUrl];
}

final class UploadFailure extends UploadState {
  final String message;
  const UploadFailure(this.message);
  @override
  List<Object?> get props => [message];
}

// Cubit
@injectable
class UploadCubit extends Cubit<UploadState> {
  final FirebaseStorage _storage;

  UploadCubit({required FirebaseStorage storage})
      : _storage = storage,
        super(const UploadInitial());

  Future<void> uploadFile({
    required File file,
    required String path,
  }) async {
    emit(const UploadInProgress(0));

    try {
      final ref = _storage.ref().child(path);
      final uploadTask = ref.putFile(file);

      uploadTask.snapshotEvents.listen((snapshot) {
        final progress = snapshot.bytesTransferred / snapshot.totalBytes;
        emit(UploadInProgress(progress));
      });

      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();
      emit(UploadSuccess(downloadUrl));
    } on FirebaseException catch (e) {
      emit(UploadFailure(e.message ?? 'Upload failed'));
    }
  }

  void reset() => emit(const UploadInitial());
}

// UI Usage
BlocBuilder<UploadCubit, UploadState>(
  builder: (context, state) {
    return switch (state) {
      UploadInitial() => ElevatedButton(
          onPressed: () async {
            final file = await _pickFile();
            if (file != null) {
              context.read<UploadCubit>().uploadFile(
                file: file,
                path: 'images/${DateTime.now().millisecondsSinceEpoch}.jpg',
              );
            }
          },
          child: const Text('Upload'),
        ),
      UploadInProgress(:final progress) => Column(
          children: [
            LinearProgressIndicator(value: progress),
            Text('${(progress * 100).toStringAsFixed(0)}%'),
          ],
        ),
      UploadSuccess(:final downloadUrl) => Column(
          children: [
            const Icon(Icons.check_circle, color: Colors.green),
            Image.network(downloadUrl, width: 200),
          ],
        ),
      UploadFailure(:final message) => Text('Error: $message',
          style: const TextStyle(color: Colors.red)),
    };
  },
)
```


### Step 6: FCM (Push Notifications)

```dart
// core/services/notification_service.dart
@lazySingleton
class NotificationService {
  final FirebaseMessaging _messaging;

  NotificationService({required FirebaseMessaging messaging})
      : _messaging = messaging;

  Future<void> initialize() async {
    // Request permission
    final settings = await _messaging.requestPermission(alert: true, badge: true, sound: true);
    if (settings.authorizationStatus == AuthorizationStatus.denied) return;

    // Get FCM token
    final token = await _messaging.getToken();
    // Kirim token ke backend, simpan ke Firestore user document
    await _saveTokenToServer(token);

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Handle background tap
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);

    // Handle saat app terminate dan user tap notif
    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) _handleNotificationTap(initialMessage);
  }

  void _handleForegroundMessage(RemoteMessage message) {
    // Show local notification
    FlutterLocalNotificationsPlugin().show(
      message.hashCode,
      message.notification?.title,
      message.notification?.body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'default_channel',
          'Notifications',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
    );
  }

  void _handleNotificationTap(RemoteMessage message) {
    // Navigate berdasarkan payload
    final route = message.data['route'] as String?;
    if (route != null) {
      getIt<GoRouter>().push(route);
    }
  }

  Future<void> _saveTokenToServer(String? token) async {
    if (token == null) return;
    // Save to Firestore user document or REST API
  }
}
```


### Step 7: DI Module Registration

```dart
// core/di/modules/firebase_module.dart
@module
abstract class FirebaseModule {
  @lazySingleton
  FirebaseAuth get firebaseAuth => FirebaseAuth.instance;

  @lazySingleton
  FirebaseFirestore get firestore => FirebaseFirestore.instance;

  @lazySingleton
  FirebaseStorage get storage => FirebaseStorage.instance;

  @lazySingleton
  FirebaseMessaging get messaging => FirebaseMessaging.instance;
}
```

### Step 8: Isolates untuk Parsing JSON Data Besar dari Firestore

Untuk menghindari UI freeze saat mem-parsing JSON payload besar dari firestore (seperti array 1000 items), gunakan `Isolate.run()`:

```dart
// features/posts/data/repositories/post_repository_impl.dart
import 'dart:isolate';

  @override
  Future<Result<List<Post>>> getMassivePosts() async {
    try {
      final snapshot = await _firestore.collection(_collection).limit(5000).get();
      final docsData = snapshot.docs.map((d) => d.data()).toList();
      
      final postsList = await Isolate.run<List<Post>>(() {
        return docsData.map((d) => PostModel.fromJson(d).toEntity()).toList();
      });

      return Success(postsList);
    } on FirebaseException catch (e) {
      return ResultFailure(ServerFailure(message: e.message ?? 'Firestore error'));
    }
  }
```

### Step 9: Background Workmanager dengan Firebase

Jika perlu menjalankan task background (seperti sinkronisasi firestore offline) tiap interval waktu:

```dart
// lib/bootstrap/background_worker.dart
import 'package:workmanager/workmanager.dart';
import 'package:firebase_core/firebase_core.dart';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    await Firebase.initializeApp(); // Initialize Firebase untuk background task
    switch (task) {
      case 'syncFirestore':
        // logic sinkronisasi Firebase
        break;
    }
    return Future.value(true);
  });
}
```


## Success Criteria

- [ ] Firebase SDK initialized sebelum `configureDependencies()`
- [ ] `AuthBloc` di-provide di root `MultiBlocProvider` (singleton)
- [ ] Auth state listener via `StreamSubscription` ke `authStateChanges()`
- [ ] GoRouter redirect terupdate via `GoRouterRefreshStream`
- [ ] Firestore real-time dengan `emit.forEach()` di Bloc
- [ ] `UploadCubit` dengan granular progress state
- [ ] FCM token disimpan saat login
- [ ] Tidak ada `dartz` — pakai `Result<T>` sealed class
- [ ] `dart run build_runner build -d` sukses


## Next Steps

- Supabase alternatif → `05_supabase_integration.md`
- Testing → `06_testing_production.md`

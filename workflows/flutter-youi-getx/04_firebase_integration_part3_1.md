---
description: Integrasi Firebase services untuk Flutter dengan GetX state management: Authentication, Cloud Firestore, Firebase Sto... (Sub-part 1/3)
---
# Workflow: Firebase Integration (GetX) (Part 3/7)

> **Navigation:** This workflow is split into 7 parts.

## Deliverables

### 2. Firebase Authentication (GetX)

**Description:** Implementasi Firebase Auth dengan GetxController, reactive state menggunakan `.obs`, dan navigasi auth menggunakan `Get.offAllNamed()`.

**Recommended Skills:** `senior-flutter-developer`, `senior-firebase-developer`

**Perbedaan dengan Riverpod:**
| Aspek | Riverpod | GetX |
|-------|----------|------|
| Controller | `@riverpod class AuthController extends _$AuthController` | `class AuthController extends GetxController` |
| State | `AsyncValue<User?>` | `Rx<User?> user`, `RxBool isLoading`, `RxString errorMessage` |
| Stream | `Stream<User?> build()` return stream | `onInit()` + `ever()` atau `listen()` |
| DI | `ref.watch(authRepositoryProvider)` | `Get.find<AuthRepository>()` |
| Redirect | GoRouter redirect | `Get.offAllNamed()` |

**Instructions:**

1. **Auth Repository (Domain - Framework Agnostic):**
   ```dart
   // features/auth/domain/repositories/auth_repository.dart
   import 'package:firebase_auth/firebase_auth.dart';
   import '../../core/error/failures.dart';
   import '../../core/utils/either.dart';

   abstract class AuthRepository {
     Stream<User?> get authStateChanges;
     Future<Either<Failure, User>> signInWithEmailAndPassword(
       String email,
       String password,
     );
     Future<Either<Failure, User>> signInWithGoogle();
     Future<Either<Failure, User>> signUp(String email, String password);
     Future<Either<Failure, void>> signOut();
     User? get currentUser;
   }
   ```

2. **Auth Repository Implementation:**
   ```dart
   // features/auth/data/repositories/auth_repository_impl.dart
   import 'package:firebase_auth/firebase_auth.dart';
   import 'package:google_sign_in/google_sign_in.dart';
   import '../../domain/repositories/auth_repository.dart';
   import '../../../../core/error/failures.dart';
   import '../../../../core/utils/either.dart';

   class AuthRepositoryImpl implements AuthRepository {
     final FirebaseAuth _firebaseAuth;
     final GoogleSignIn _googleSignIn;

     AuthRepositoryImpl({
       FirebaseAuth? firebaseAuth,
       GoogleSignIn? googleSignIn,
     })  : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
           _googleSignIn = googleSignIn ?? GoogleSignIn();

     @override
     Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

     @override
     Future<Either<Failure, User>> signInWithEmailAndPassword(
       String email,
       String password,
     ) async {
       try {
         final result = await _firebaseAuth.signInWithEmailAndPassword(
           email: email,
           password: password,
         );

         if (result.user == null) {
           return const Left(AuthFailure('User not found'));
         }

         return Right(result.user!);
       } on FirebaseAuthException catch (e) {
         return Left(_mapAuthError(e));
       } catch (e) {
         return Left(AuthFailure('Unexpected error: ${e.toString()}'));
       }
     }

     @override
     Future<Either<Failure, User>> signInWithGoogle() async {
       try {
         final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
         if (googleUser == null) {
           return const Left(AuthFailure('Google sign-in dibatalkan'));
         }

         final GoogleSignInAuthentication googleAuth =
             await googleUser.authentication;
         final credential = GoogleAuthProvider.credential(
           accessToken: googleAuth.accessToken,
           idToken: googleAuth.idToken,
         );

         final result = await _firebaseAuth.signInWithCredential(credential);

         if (result.user == null) {
           return const Left(AuthFailure('Gagal sign in dengan Google'));
         }

         return Right(result.user!);
       } on FirebaseAuthException catch (e) {
         return Left(_mapAuthError(e));
       } catch (e) {
         return Left(AuthFailure('Unexpected error: ${e.toString()}'));
       }
     }

     @override
     Future<Either<Failure, User>> signUp(
       String email,
       String password,
     ) async {
       try {
         final result = await _firebaseAuth.createUserWithEmailAndPassword(
           email: email,
           password: password,
         );

         if (result.user == null) {
           return const Left(AuthFailure('Gagal membuat user'));
         }

         return Right(result.user!);
       } on FirebaseAuthException catch (e) {
         return Left(_mapAuthError(e));
       } catch (e) {
         return Left(AuthFailure('Unexpected error: ${e.toString()}'));
       }
     }

     @override
     Future<Either<Failure, void>> signOut() async {
       try {
         await Future.wait([
           _firebaseAuth.signOut(),
           _googleSignIn.signOut(),
         ]);
         return const Right(null);
       } on FirebaseAuthException catch (e) {
         return Left(_mapAuthError(e));
       } catch (e) {
         return Left(AuthFailure('Gagal sign out: ${e.toString()}'));
       }
     }

     @override
     User? get currentUser => _firebaseAuth.currentUser;

     /// Map Firebase error codes ke user-friendly messages
     Failure _mapAuthError(FirebaseAuthException e) {
       switch (e.code) {
         case 'user-not-found':
           return const AuthFailure('Email tidak terdaftar');
         case 'wrong-password':
           return const AuthFailure('Password salah');
         case 'email-already-in-use':
           return const AuthFailure('Email sudah terdaftar');
         case 'invalid-email':
           return const AuthFailure('Format email tidak valid');
         case 'weak-password':
           return const AuthFailure('Password terlalu lemah (min 6 karakter)');
         case 'user-disabled':
           return const AuthFailure('Akun telah dinonaktifkan');
         case 'too-many-requests':
           return const AuthFailure('Terlalu banyak percobaan, coba lagi nanti');
         case 'operation-not-allowed':
           return const AuthFailure('Metode login tidak diizinkan');
         case 'network-request-failed':
           return const AuthFailure('Gagal terhubung ke server, periksa koneksi internet');
         default:
           return AuthFailure(e.message ?? 'Terjadi kesalahan autentikasi');
       }
     }
   }
   ```

3. **Auth Controller (GetX):**

   Ini perbedaan paling signifikan dengan Riverpod. Di GetX, kita menggunakan `GetxController` dengan reactive variables `.obs` dan lifecycle method `onInit()`.

   ```dart
   // features/auth/controllers/auth_controller.dart
   import 'dart:async';
   import 'package:firebase_auth/firebase_auth.dart';
   import 'package:get/get.dart';
   import '../domain/repositories/auth_repository.dart';
   import '../../../routes/app_routes.dart';

   class AuthController extends GetxController {
     final AuthRepository _repository = Get.find<AuthRepository>();

     // Reactive state - pengganti AsyncValue di Riverpod
     final Rx<User?> user = Rx<User?>(null);
     final RxBool isLoading = false.obs;
     final RxString errorMessage = ''.obs;
     final RxBool isLoggedIn = false.obs;

     // Stream subscription untuk cleanup
     StreamSubscription<User?>? _authSubscription;

     @override
     void onInit() {
       super.onInit();

       // Listen ke auth state changes - pengganti Stream build() di Riverpod
       _authSubscription = _repository.authStateChanges.listen(
         (User? firebaseUser) {
           user.value = firebaseUser;
           isLoggedIn.value = firebaseUser != null;
         },
         onError: (error) {
           errorMessage.value = 'Auth stream error: $error';
         },
       );

       // Gunakan ever() untuk react terhadap perubahan auth state
       // ever() di GetX mirip ref.listen() di Riverpod
       ever(user, _handleAuthStateChanged);
     }

     /// Handle navigasi berdasarkan auth state
     void _handleAuthStateChanged(User? currentUser) {
       if (currentUser != null) {
         // User logged in - redirect ke home
         // Get.offAllNamed() menggantikan GoRouter redirect
         if (Get.currentRoute == AppRoutes.login ||
             Get.currentRoute == AppRoutes.splash) {
           Get.offAllNamed(AppRoutes.home);
         }
       } else {
         // User logged out - redirect ke login
         Get.offAllNamed(AppRoutes.login);
       }
     }

     /// Sign in dengan email dan password
     Future<void> signInWithEmailAndPassword(
       String email,
       String password,
     ) async {
       isLoading.value = true;
       errorMessage.value = '';

       final result = await _repository.signInWithEmailAndPassword(
         email,
         password,
       );

       result.fold(
         (failure) {
           errorMessage.value = failure.message;
           // Tampilkan snackbar error via GetX
           Get.snackbar(
             'Login Gagal',
             failure.message,
             snackPosition: SnackPosition.BOTTOM,
           );
         },
         (loggedInUser) {
           // Auth state stream akan otomatis handle navigasi
           // Tidak perlu manual navigate di sini
         },
       );

       isLoading.value = false;
     }

     /// Sign in dengan Google
     Future<void> signInWithGoogle() async {
       isLoading.value = true;
       errorMessage.value = '';

       final result = await _repository.signInWithGoogle();

       result.fold(
         (failure) {
           errorMessage.value = failure.message;
           Get.snackbar(
             'Google Sign-In Gagal',
             failure.message,
             snackPosition: SnackPosition.BOTTOM,
           );
         },
         (loggedInUser) {
           // Auth state stream akan handle navigasi
         },
       );

       isLoading.value = false;
     }

     /// Sign up dengan email dan password
     Future<void> signUp(String email, String password) async {
       isLoading.value = true;
       errorMessage.value = '';
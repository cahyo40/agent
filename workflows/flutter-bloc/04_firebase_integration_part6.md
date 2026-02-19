---
description: Integrasi Firebase services untuk Flutter dengan **flutter_bloc** sebagai state management: Authentication, Cloud Fir... (Part 6/7)
---
# Workflow: Firebase Integration (flutter_bloc) (Part 6/7)

> **Navigation:** This workflow is split into 7 parts.

## Deliverables

### 5. Firebase Cloud Messaging / FCM (NotificationService)

**Description:** Push notifications dengan FCM. Service ini framework-agnostic (tidak extend Bloc/Cubit) karena FCM berjalan di level app lifecycle, bukan UI state. Di-register sebagai `@lazySingleton` di `get_it`. Navigasi on-tap lewat GoRouter.

**Recommended Skills:** `senior-flutter-developer`, `senior-firebase-developer`

**Instructions:**
1. **NotificationService** — setup FCM, handle foreground/background messages
2. **Local Notifications** — tampilkan notifikasi saat app di foreground
3. **Navigation** — handle tap notifikasi, navigate ke route yang sesuai
4. **Token Management** — simpan FCM token ke Firestore untuk server-side push
5. **Background Handler** — top-level function untuk background messages

**NotificationService Implementation:**
```dart
// lib/core/notifications/notification_service.dart
@lazySingleton
class NotificationService {
  final FirebaseMessaging _messaging;
  final FlutterLocalNotificationsPlugin _localNotifications;
  final GoRouter _router;

  NotificationService(
    this._messaging,
    this._localNotifications,
    this._router,
  );

  /// Initialize FCM dan local notifications.
  /// Panggil di bootstrap() SETELAH Firebase.initializeApp().
  Future<void> initialize() async {
    // 1. Request permissions (iOS wajib, Android opsional untuk 13+)
    await _requestPermissions();

    // 2. Setup local notifications plugin
    await _initializeLocalNotifications();

    // 3. Handle foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // 4. Handle notification tap saat app di background
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);

    // 5. Handle notification tap saat app terminated
    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      // Delay sedikit agar router sudah siap
      Future.delayed(
        const Duration(milliseconds: 500),
        () => _handleNotificationTap(initialMessage),
      );
    }

    // 6. Get dan log FCM token
    final token = await _messaging.getToken();
    debugPrint('FCM Token: $token');
  }

  Future<void> _requestPermissions() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );
    debugPrint('FCM Permission: ${settings.authorizationStatus}');
  }

  Future<void> _initializeLocalNotifications() async {
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false, // Sudah request via FCM
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onLocalNotificationTap,
    );

    // Create notification channel untuk Android
    const androidChannel = AndroidNotificationChannel(
      'high_importance_channel',
      'High Importance Notifications',
      description: 'Channel untuk notifikasi penting',
      importance: Importance.max,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidChannel);
  }

  /// Handle message saat app di foreground.
  /// Firebase TIDAK otomatis tampilkan notifikasi di foreground,
  /// jadi kita perlu tampilkan manual via local notifications.
  void _handleForegroundMessage(RemoteMessage message) {
    final notification = message.notification;
    if (notification == null) return;

    _showLocalNotification(
      title: notification.title ?? 'Notifikasi Baru',
      body: notification.body ?? '',
      payload: _encodePayload(message.data),
    );
  }

  /// Handle tap pada notifikasi (background state)
  void _handleNotificationTap(RemoteMessage message) {
    _navigateFromPayload(message.data);
  }

  /// Handle tap pada local notification (foreground state)
  void _onLocalNotificationTap(NotificationResponse details) {
    if (details.payload == null) return;
    final data = _decodePayload(details.payload!);
    _navigateFromPayload(data);
  }

  /// Navigate berdasarkan data payload dari notifikasi
  void _navigateFromPayload(Map<String, dynamic> data) {
    final route = data['route'] as String?;
    final id = data['id'] as String?;

    if (route == null) return;

    // Gunakan GoRouter untuk navigasi
    switch (route) {
      case 'product_detail':
        if (id != null) _router.push('/products/$id');
        break;
      case 'order_detail':
        if (id != null) _router.push('/orders/$id');
        break;
      case 'chat':
        _router.push('/chat');
        break;
      default:
        _router.push(route);
    }
  }

  /// Tampilkan local notification
  Future<void> _showLocalNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'high_importance_channel',
      'High Importance Notifications',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch.remainder(100000),
      title,
      body,
      details,
      payload: payload,
    );
  }

  /// Get FCM token (untuk kirim ke backend/Firestore)
  Future<String?> getToken() => _messaging.getToken();

  /// Stream token refresh
  Stream<String> get onTokenRefresh => _messaging.onTokenRefresh;

  /// Subscribe ke topic (misal: 'promo', 'news')
  Future<void> subscribeToTopic(String topic) async {
    await _messaging.subscribeToTopic(topic);
  }

  /// Unsubscribe dari topic
  Future<void> unsubscribeFromTopic(String topic) async {
    await _messaging.unsubscribeFromTopic(topic);
  }

  // --- Helper encode/decode payload ---
  String _encodePayload(Map<String, dynamic> data) {
    return data.entries.map((e) => '${e.key}=${e.value}').join('&');
  }

  Map<String, dynamic> _decodePayload(String payload) {
    return Map.fromEntries(
      payload.split('&').map((entry) {
        final parts = entry.split('=');
        return MapEntry(parts[0], parts.length > 1 ? parts[1] : '');
      }),
    );
  }
}
```

**Background Message Handler:**
```dart
// lib/main.dart (atau file terpisah)
// WAJIB top-level function (tidak boleh di dalam class)
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Init Firebase di background isolate
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  debugPrint('Background message: ${message.messageId}');
  // Handle background data message jika perlu
}
```

```dart
// Di bootstrap.dart, register background handler SEBELUM runApp
Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Register background handler
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  await configureDependencies();
  await getIt<NotificationService>().initialize();

  runApp(const MyApp());
}
```

**Token Persistence ke Firestore:**
```dart
// lib/core/notifications/token_repository.dart
@lazySingleton
class FcmTokenRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final NotificationService _notificationService;

  FcmTokenRepository(
    this._firestore,
    this._auth,
    this._notificationService,
  );

  /// Simpan FCM token ke Firestore user document.
  /// Panggil setelah user login.
  Future<void> saveToken() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final token = await _notificationService.getToken();
    if (token == null) return;

    await _firestore.collection('users').doc(user.uid).set(
      {
        'fcmTokens': FieldValue.arrayUnion([token]),
        'lastTokenUpdate': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  /// Listen token refresh dan auto-update ke Firestore
  void listenTokenRefresh() {
    _notificationService.onTokenRefresh.listen((newToken) async {
      final user = _auth.currentUser;
      if (user == null) return;

      await _firestore.collection('users').doc(user.uid).update({
        'fcmTokens': FieldValue.arrayUnion([newToken]),
        'lastTokenUpdate': FieldValue.serverTimestamp(),
      });
    });
  }

  /// Hapus token saat user logout
  Future<void> removeToken() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final token = await _notificationService.getToken();
    if (token == null) return;

    await _firestore.collection('users').doc(user.uid).update({
      'fcmTokens': FieldValue.arrayRemove([token]),
    });
  }
}
```

---


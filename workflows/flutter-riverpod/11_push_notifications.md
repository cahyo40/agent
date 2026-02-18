# 11 - Push Notifications (FCM + Local Notifications + Deep Linking)

**Goal:** Setup push notifications lengkap: FCM untuk remote, flutter_local_notifications untuk local, dan deep linking dari notification tap.

**Output:** `sdlc/flutter-riverpod/11-push-notifications/`

**Time Estimate:** 3-4 jam

---

## Install

```yaml
dependencies:
  firebase_messaging: ^15.2.0
  flutter_local_notifications: ^17.2.2
  go_router: ^14.0.0  # sudah ada dari 01_project_setup
```

---

## Deliverables

### 1. Notification Service

**File:** `lib/core/notifications/notification_service.dart`

```dart
import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'notification_service.g.dart';

/// Background message handler — harus top-level function.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('Background message: ${message.messageId}');
}

@Riverpod(keepAlive: true)
NotificationService notificationService(Ref ref) => NotificationService();

class NotificationService {
  final _fcm = FirebaseMessaging.instance;
  final _localNotifications = FlutterLocalNotificationsPlugin();

  static const _channelId = 'high_importance_channel';
  static const _channelName = 'High Importance Notifications';

  /// Initialize — panggil di bootstrap.
  Future<void> initialize({
    required void Function(String? payload) onNotificationTap,
  }) async {
    // 1. Request permission
    await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // 2. Setup local notifications
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    await _localNotifications.initialize(
      const InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      ),
      onDidReceiveNotificationResponse: (details) {
        onNotificationTap(details.payload);
      },
    );

    // 3. Create Android channel
    const channel = AndroidNotificationChannel(
      _channelId,
      _channelName,
      importance: Importance.max,
    );
    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    // 4. Handle foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // 5. Handle background message handler
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    // 6. Handle notification tap when app in background
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      onNotificationTap(jsonEncode(message.data));
    });

    // 7. Handle notification tap when app was terminated
    final initialMessage = await _fcm.getInitialMessage();
    if (initialMessage != null) {
      onNotificationTap(jsonEncode(initialMessage.data));
    }
  }

  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;

    await _localNotifications.show(
      notification.hashCode,
      notification.title,
      notification.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          importance: Importance.max,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: jsonEncode(message.data),
    );
  }

  /// Get FCM token untuk kirim ke backend.
  Future<String?> getToken() => _fcm.getToken();

  /// Listen token refresh.
  Stream<String> get onTokenRefresh => _fcm.onTokenRefresh;

  /// Show local notification (tanpa FCM).
  Future<void> showLocalNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          importance: Importance.max,
          priority: Priority.high,
        ),
        iOS: const DarwinNotificationDetails(),
      ),
      payload: payload,
    );
  }

  /// Schedule local notification.
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
  }) async {
    await _localNotifications.zonedSchedule(
      id,
      title,
      body,
      TZDateTime.from(scheduledDate, local),
      NotificationDetails(
        android: AndroidNotificationDetails(_channelId, _channelName),
        iOS: const DarwinNotificationDetails(),
      ),
      payload: payload,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Future<void> cancelNotification(int id) =>
      _localNotifications.cancel(id);

  Future<void> cancelAllNotifications() =>
      _localNotifications.cancelAll();
}
```

---

### 2. Deep Link Handler

**File:** `lib/core/notifications/notification_deep_link_handler.dart`

```dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Handle deep links dari notification payload.
class NotificationDeepLinkHandler {
  static void handle(BuildContext context, String? payload) {
    if (payload == null) return;

    try {
      final data = jsonDecode(payload) as Map<String, dynamic>;
      final type = data['type'] as String?;
      final id = data['id'] as String?;

      switch (type) {
        case 'product':
          if (id != null) context.push('/products/$id');
        case 'order':
          if (id != null) context.push('/orders/$id');
        case 'chat':
          if (id != null) context.push('/chat/$id');
        case 'promo':
          context.push('/promotions');
        default:
          debugPrint('Unknown notification type: $type');
      }
    } catch (e) {
      debugPrint('Deep link parse error: $e');
    }
  }
}
```

---

### 3. FCM Token Manager

**File:** `lib/core/notifications/fcm_token_manager.dart`

```dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../storage/secure_storage_service.dart';
import '../network/dio_client.dart';

part 'fcm_token_manager.g.dart';

@riverpod
FcmTokenManager fcmTokenManager(Ref ref) => FcmTokenManager(
      notificationService: ref.watch(notificationServiceProvider),
      secureStorage: ref.watch(secureStorageServiceProvider),
      dio: ref.watch(dioClientProvider),
    );

class FcmTokenManager {
  const FcmTokenManager({
    required this.notificationService,
    required this.secureStorage,
    required this.dio,
  });

  final NotificationService notificationService;
  final SecureStorageService secureStorage;
  final dynamic dio;

  /// Register token ke backend setelah login.
  Future<void> registerToken() async {
    final token = await notificationService.getToken();
    if (token == null) return;

    final savedToken = await secureStorage.getAccessToken();
    if (savedToken == null) return; // Not logged in

    try {
      await dio.post('/users/fcm-token', data: {'token': token});
    } catch (e) {
      debugPrint('FCM token register error: $e');
    }

    // Listen for token refresh
    notificationService.onTokenRefresh.listen((newToken) async {
      try {
        await dio.post('/users/fcm-token', data: {'token': newToken});
      } catch (e) {
        debugPrint('FCM token refresh error: $e');
      }
    });
  }

  /// Unregister token saat logout.
  Future<void> unregisterToken() async {
    final token = await notificationService.getToken();
    if (token == null) return;

    try {
      await dio.delete('/users/fcm-token', data: {'token': token});
    } catch (e) {
      debugPrint('FCM token unregister error: $e');
    }
  }
}
```

---

### 4. Bootstrap Integration

**File:** `lib/bootstrap/bootstrap.dart` (update)

```dart
Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Setup notification service
  final notificationService = NotificationService();
  await notificationService.initialize(
    onNotificationTap: (payload) {
      // Store payload, handle after router is ready
      PendingNotificationPayload.value = payload;
    },
  );

  runApp(
    ProviderScope(
      overrides: [
        notificationServiceProvider.overrideWithValue(notificationService),
      ],
      child: const MyApp(),
    ),
  );
}
```

---

### 5. Android Manifest

**File:** `android/app/src/main/AndroidManifest.xml` (tambahkan)

```xml
<!-- Notification permission (Android 13+) -->
<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>

<!-- FCM service -->
<service
    android:name="com.google.firebase.messaging.FirebaseMessagingService"
    android:exported="false">
  <intent-filter>
    <action android:name="com.google.firebase.MESSAGING_EVENT"/>
  </intent-filter>
</service>
```

---

## Success Criteria
- FCM token berhasil di-register ke backend setelah login
- Notifikasi tampil saat app di foreground (local notification)
- Tap notifikasi navigate ke halaman yang benar (deep link)
- Token refresh otomatis ter-update ke backend
- Local notification bisa di-schedule

## Next Steps
- `12_performance_monitoring.md` - Performance & monitoring

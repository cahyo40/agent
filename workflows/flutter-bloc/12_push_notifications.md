# 12 - Push Notifications (FCM + Local Notifications + Deep Linking)

**Goal:** Setup push notifications lengkap: FCM untuk remote, flutter_local_notifications untuk local, dan deep linking dari notification tap menggunakan go_router.

**Output:** `sdlc/flutter-bloc/12-push-notifications/`

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
import 'package:injectable/injectable.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('Background message: ${message.messageId}');
}

@lazySingleton
class NotificationService {
  final _fcm = FirebaseMessaging.instance;
  final _localNotifications = FlutterLocalNotificationsPlugin();

  static const _channelId = 'high_importance_channel';
  static const _channelName = 'High Importance Notifications';

  Future<void> initialize({
    required void Function(String? payload) onNotificationTap,
  }) async {
    await _fcm.requestPermission(alert: true, badge: true, sound: true);

    await _localNotifications.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(),
      ),
      onDidReceiveNotificationResponse: (details) {
        onNotificationTap(details.payload);
      },
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(
          const AndroidNotificationChannel(
            _channelId,
            _channelName,
            importance: Importance.max,
          ),
        );

    FirebaseMessaging.onMessage.listen(_handleForeground);
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    FirebaseMessaging.onMessageOpenedApp.listen(
      (msg) => onNotificationTap(jsonEncode(msg.data)),
    );

    final initial = await _fcm.getInitialMessage();
    if (initial != null) onNotificationTap(jsonEncode(initial.data));
  }

  Future<void> _handleForeground(RemoteMessage message) async {
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

  Future<String?> getToken() => _fcm.getToken();
  Stream<String> get onTokenRefresh => _fcm.onTokenRefresh;

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

  Future<void> cancelAll() => _localNotifications.cancelAll();
}
```

---

### 2. Deep Link Handler

**File:** `lib/core/notifications/notification_deep_link_handler.dart`

```dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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

### 3. FCM Token Cubit

**File:** `lib/core/notifications/fcm_token_cubit.dart`

```dart
import 'package:bloc/bloc.dart';
import 'package:injectable/injectable.dart';

@injectable
class FcmTokenCubit extends Cubit<void> {
  FcmTokenCubit({
    required this.notificationService,
    required this.apiClient,
  }) : super(null);

  final NotificationService notificationService;
  final ApiClient apiClient;

  Future<void> register() async {
    final token = await notificationService.getToken();
    if (token == null) return;

    try {
      await apiClient.post('/users/fcm-token', data: {'token': token});
    } catch (e) {
      debugPrint('FCM register error: $e');
    }

    notificationService.onTokenRefresh.listen((newToken) async {
      try {
        await apiClient.post('/users/fcm-token', data: {'token': newToken});
      } catch (e) {
        debugPrint('FCM refresh error: $e');
      }
    });
  }

  Future<void> unregister() async {
    final token = await notificationService.getToken();
    if (token == null) return;

    try {
      await apiClient.delete('/users/fcm-token', data: {'token': token});
    } catch (e) {
      debugPrint('FCM unregister error: $e');
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
  configureDependencies();

  final notificationService = getIt<NotificationService>();
  await notificationService.initialize(
    onNotificationTap: (payload) {
      // Store payload, handle after router is ready
      PendingNotificationPayload.value = payload;
    },
  );

  runApp(const MyApp());
}
```

---

### 5. Android Manifest

```xml
<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
```

---

## Success Criteria
- FCM token berhasil di-register ke backend setelah login
- Notifikasi tampil saat app di foreground (local notification)
- Tap notifikasi navigate ke halaman yang benar via `context.push()`
- Token refresh otomatis ter-update ke backend

## Next Steps
- `13_performance_monitoring.md` - Performance & monitoring

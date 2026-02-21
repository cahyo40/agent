---
description: Setup push notifications lengkap: FCM untuk remote, flutter_local_notifications untuk local, dan deep linking dari no...
---
# 11 - Push Notifications (FCM + Local Notifications + Deep Linking)

**Goal:** Setup push notifications lengkap: FCM untuk remote, flutter_local_notifications untuk local, dan deep linking dari notification tap menggunakan GetX routing.

**Output:** `sdlc/flutter-youi/11-push-notifications/`

**Time Estimate:** 3-4 jam

---

## Install

```yaml
dependencies:
  firebase_messaging: ^15.2.0
  flutter_local_notifications: ^17.2.2
  get: ^4.6.6  # sudah ada dari 01_project_setup
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
import 'package:get/get.dart';

/// Background message handler — harus top-level function.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('Background message: ${message.messageId}');
}

class NotificationService extends GetxService {
  final _fcm = FirebaseMessaging.instance;
  final _localNotifications = FlutterLocalNotificationsPlugin();

  static const _channelId = 'high_importance_channel';
  static const _channelName = 'High Importance Notifications';

  Future<NotificationService> init() async {
    await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    await _localNotifications.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(),
      ),
      onDidReceiveNotificationResponse: (details) {
        _handlePayload(details.payload);
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
      (msg) => _handlePayload(jsonEncode(msg.data)),
    );

    final initial = await _fcm.getInitialMessage();
    if (initial != null) _handlePayload(jsonEncode(initial.data));

    return this;
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

  void _handlePayload(String? payload) {
    if (payload == null) return;
    try {
      final data = jsonDecode(payload) as Map<String, dynamic>;
      final type = data['type'] as String?;
      final id = data['id'] as String?;

      switch (type) {
        case 'product':
          if (id != null) Get.toNamed('/products/$id');
        case 'order':
          if (id != null) Get.toNamed('/orders/$id');
        case 'chat':
          if (id != null) Get.toNamed('/chat/$id');
        case 'promo':
          Get.toNamed('/promotions');
        default:
          debugPrint('Unknown notification type: $type');
      }
    } catch (e) {
      debugPrint('Payload parse error: $e');
    }
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

### 2. FCM Token Manager (GetxController)

**File:** `lib/core/notifications/fcm_token_controller.dart`

```dart
import 'package:get/get.dart';

class FcmTokenController extends GetxController {
  final NotificationService _notificationService;
  final ApiClient _apiClient;

  FcmTokenController({
    required NotificationService notificationService,
    required ApiClient apiClient,
  })  : _notificationService = notificationService,
        _apiClient = apiClient;

  /// Panggil setelah login berhasil.
  Future<void> register() async {
    final token = await _notificationService.getToken();
    if (token == null) return;

    try {
      await _apiClient.post('/users/fcm-token', data: {'token': token});
    } catch (e) {
      debugPrint('FCM register error: $e');
    }

    _notificationService.onTokenRefresh.listen((newToken) async {
      try {
        await _apiClient.post('/users/fcm-token', data: {'token': newToken});
      } catch (e) {
        debugPrint('FCM refresh error: $e');
      }
    });
  }

  /// Panggil sebelum logout.
  Future<void> unregister() async {
    final token = await _notificationService.getToken();
    if (token == null) return;

    try {
      await _apiClient.delete('/users/fcm-token', data: {'token': token});
    } catch (e) {
      debugPrint('FCM unregister error: $e');
    }
  }
}
```

---

### 3. Bootstrap Integration

**File:** `lib/main.dart` (update)

```dart
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await GetStorage.init();

  // Register services
  await Get.putAsync(() => NotificationService().init());
  await Get.putAsync(() => StorageService().init());
  await Get.putAsync(() => ConnectivityService().init());

  runApp(const MyApp());
}
```

---

### 4. Android Manifest

```xml
<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
```

---

## Success Criteria
- FCM token berhasil di-register ke backend setelah login
- Notifikasi tampil saat app di foreground (local notification)
- Tap notifikasi navigate ke halaman yang benar via `Get.toNamed()`
- Token refresh otomatis ter-update ke backend

## Next Steps
- `12_performance_monitoring.md` - Performance & monitoring

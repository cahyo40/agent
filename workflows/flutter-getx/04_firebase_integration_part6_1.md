---
description: Integrasi Firebase services untuk Flutter dengan GetX state management: Authentication, Cloud Firestore, Firebase Sto... (Sub-part 1/3)
---
# Workflow: Firebase Integration (GetX) (Part 6/7)

> **Navigation:** This workflow is split into 7 parts.

## Deliverables

### 5. Firebase Cloud Messaging (GetX)

**Description:** Push notifications dengan FCM menggunakan `GetxService` dan navigasi via `Get.toNamed()`.

**Recommended Skills:** `senior-flutter-developer`, `senior-firebase-developer`

**Perbedaan dengan Riverpod:**
| Aspek | Riverpod | GetX |
|-------|----------|------|
| Service type | Provider/function | `GetxService` (persistent) |
| Registration | `Provider((ref) => FCMService())` | `Get.putAsync(() => FCMService().init())` |
| Navigation | GoRouter: `context.go('/route')` | `Get.toNamed('/route')` |
| Lifecycle | Provider auto-dispose | `GetxService` persists selama app hidup |

**Instructions:**

1. **FCM Service sebagai GetxService:**

   `GetxService` dipilih karena FCM harus persist selama app lifecycle, tidak boleh di-dispose. Berbeda dengan `GetxController` yang bisa di-dispose saat page ditutup.

   ```dart
   // core/notifications/fcm_service.dart
   import 'dart:convert';
   import 'package:firebase_core/firebase_core.dart';
   import 'package:firebase_messaging/firebase_messaging.dart';
   import 'package:flutter_local_notifications/flutter_local_notifications.dart';
   import 'package:get/get.dart';

   /// Background message handler - HARUS top-level function
   /// Tidak bisa di dalam class karena dijalankan di isolate terpisah
   @pragma('vm:entry-point')
   Future<void> firebaseMessagingBackgroundHandler(
     RemoteMessage message,
   ) async {
     await Firebase.initializeApp();
     // Handle background message
     // CATATAN: Tidak bisa akses GetX di sini karena beda isolate
     print('Background message: ${message.messageId}');
   }

   class FCMService extends GetxService {
     final FirebaseMessaging _messaging = FirebaseMessaging.instance;
     final FlutterLocalNotificationsPlugin _localNotifications =
         FlutterLocalNotificationsPlugin();

     // Reactive state
     final RxString fcmToken = ''.obs;
     final RxBool hasPermission = false.obs;

     /// Initialize FCM service
     /// Dipanggil di main.dart via Get.putAsync()
     Future<FCMService> init() async {
       // Register background handler
       FirebaseMessaging.onBackgroundMessage(
         firebaseMessagingBackgroundHandler,
       );

       // Request permissions
       await _requestPermissions();

       // Initialize local notifications
       await _initializeLocalNotifications();

       // Setup message handlers
       _setupMessageHandlers();

       // Get FCM token
       await _getToken();

       // Listen token refresh
       _messaging.onTokenRefresh.listen((newToken) {
         fcmToken.value = newToken;
         _saveTokenToServer(newToken);
       });

       return this;
     }

     /// Request notification permissions
     Future<void> _requestPermissions() async {
       final settings = await _messaging.requestPermission(
         alert: true,
         announcement: false,
         badge: true,
         carPlay: false,
         criticalAlert: false,
         provisional: false,
         sound: true,
       );

       hasPermission.value =
           settings.authorizationStatus == AuthorizationStatus.authorized ||
           settings.authorizationStatus == AuthorizationStatus.provisional;

       if (!hasPermission.value) {
         print('FCM: User menolak permission notifikasi');
       }
     }

     /// Initialize local notifications plugin
     Future<void> _initializeLocalNotifications() async {
       const androidSettings = AndroidInitializationSettings(
         '@mipmap/ic_launcher',
       );
       const iosSettings = DarwinInitializationSettings(
         requestAlertPermission: false,
         requestBadgePermission: false,
         requestSoundPermission: false,
       );

       const initSettings = InitializationSettings(
         android: androidSettings,
         iOS: iosSettings,
       );

       await _localNotifications.initialize(
         initSettings,
         onDidReceiveNotificationResponse: _onNotificationTap,
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

     /// Setup foreground dan background message handlers
     void _setupMessageHandlers() {
       // Handle foreground messages
       FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

       // Handle notification tap saat app di background
       FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationOpen);

       // Handle notification tap saat app terminated
       _handleInitialMessage();
     }

     /// Handle message saat app di foreground
     void _handleForegroundMessage(RemoteMessage message) {
       final notification = message.notification;
       if (notification != null) {
         _showLocalNotification(
           id: message.hashCode,
           title: notification.title ?? 'Notifikasi Baru',
           body: notification.body ?? '',
           payload: jsonEncode(message.data),
         );
       }
     }

     /// Handle notification tap saat app di background
     void _handleNotificationOpen(RemoteMessage message) {
       _navigateFromNotification(message.data);
     }

     /// Handle initial message (app dibuka dari terminated state via notifikasi)
     Future<void> _handleInitialMessage() async {
       final initialMessage = await _messaging.getInitialMessage();
       if (initialMessage != null) {
         // Delay sedikit agar GetX routing sudah ready
         await Future.delayed(const Duration(milliseconds: 500));
         _navigateFromNotification(initialMessage.data);
       }
     }

     /// Navigate berdasarkan data notifikasi
     /// Menggunakan Get.toNamed() - pengganti GoRouter di Riverpod
     void _navigateFromNotification(Map<String, dynamic> data) {
       final route = data['route'] as String?;
       final id = data['id'] as String?;

       if (route == null) return;

       switch (route) {
         case 'product_detail':
           if (id != null) {
             Get.toNamed('/products/$id');
           }
           break;
         case 'order_detail':
           if (id != null) {
             Get.toNamed('/orders/$id');
           }
           break;
         case 'chat':
           Get.toNamed('/chat', arguments: {'chatId': id});
           break;
         case 'promo':
           Get.toNamed('/promo', arguments: data);
           break;
         default:
           Get.toNamed('/notifications');
           break;
       }
     }

     /// Handle notification tap dari local notification
     void _onNotificationTap(NotificationResponse response) {
       if (response.payload != null) {
         try {
           final data = jsonDecode(response.payload!) as Map<String, dynamic>;
           _navigateFromNotification(data);
         } catch (e) {
           print('Error parsing notification payload: $e');
         }
       }
     }

     /// Show local notification (foreground)
     Future<void> _showLocalNotification({
       required int id,
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
         icon: '@mipmap/ic_launcher',
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
         id,
         title,
         body,
         details,
         payload: payload,
       );
     }

     /// Get FCM token
     Future<void> _getToken() async {
       final token = await _messaging.getToken();
       if (token != null) {
         fcmToken.value = token;
         await _saveTokenToServer(token);
       }
     }

     /// Save token ke backend/Firestore
     Future<void> _saveTokenToServer(String token) async {
       // Simpan token ke Firestore untuk server-side messaging
       // Implement sesuai kebutuhan backend
       print('FCM Token saved: $token');
     }

     /// Subscribe ke topic
     Future<void> subscribeToTopic(String topic) async {
       await _messaging.subscribeToTopic(topic);
     }

     /// Unsubscribe dari topic
     Future<void> unsubscribeFromTopic(String topic) async {
       await _messaging.unsubscribeFromTopic(topic);
     }

     /// Get current token
     Future<String?> getToken() => _messaging.getToken();

     /// Stream token refresh
     Stream<String> get onTokenRefresh => _messaging.onTokenRefresh;
   }
   ```

2. **Notification Controller (optional - untuk notification list UI):**
   ```dart
   // features/notifications/controllers/notification_controller.dart
   import 'package:get/get.dart';
   import 'package:cloud_firestore/cloud_firestore.dart';
   import '../../auth/controllers/auth_controller.dart';

   class NotificationItem {
     final String id;
     final String title;
     final String body;
     final String? route;
     final String? routeId;
     final bool isRead;
     final DateTime createdAt;

     NotificationItem({
       required this.id,
       required this.title,
       required this.body,
       this.route,
       this.routeId,
       required this.isRead,
       required this.createdAt,
     });

     factory NotificationItem.fromFirestore(DocumentSnapshot doc) {
       final data = doc.data() as Map<String, dynamic>;
       return NotificationItem(
         id: doc.id,
         title: data['title'] ?? '',
         body: data['body'] ?? '',
         route: data['route'],
         routeId: data['routeId'],
         isRead: data['isRead'] ?? false,
         createdAt:
             (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
       );
     }
   }
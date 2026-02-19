---
description: Integrasi Firebase services untuk Flutter dengan GetX state management: Authentication, Cloud Firestore, Firebase Sto... (Sub-part 2/3)
---
   class NotificationController extends GetxController {
     final FirebaseFirestore _firestore = FirebaseFirestore.instance;
     final AuthController _authController = Get.find<AuthController>();

     final RxList<NotificationItem> notifications = <NotificationItem>[].obs;
     final RxInt unreadCount = 0.obs;

     @override
     void onInit() {
       super.onInit();

       final userId = _authController.user.value?.uid;
       if (userId != null) {
         // Bind stream dari Firestore
         notifications.bindStream(
           _firestore
               .collection('users')
               .doc(userId)
               .collection('notifications')
               .orderBy('createdAt', descending: true)
               .limit(50)
               .snapshots()
               .map((snapshot) => snapshot.docs
                   .map((doc) => NotificationItem.fromFirestore(doc))
                   .toList()),
         );

         // Hitung unread count secara reactive
         ever(notifications, (_) {
           unreadCount.value =
               notifications.where((n) => !n.isRead).length;
         });
       }
     }

     /// Mark notification as read
     Future<void> markAsRead(String notificationId) async {
       final userId = _authController.user.value?.uid;
       if (userId == null) return;

       await _firestore
           .collection('users')
           .doc(userId)
           .collection('notifications')
           .doc(notificationId)
           .update({'isRead': true});
     }

     /// Mark all as read
     Future<void> markAllAsRead() async {
       final userId = _authController.user.value?.uid;
       if (userId == null) return;

       final batch = _firestore.batch();
       final unread = notifications.where((n) => !n.isRead);

       for (final notification in unread) {
         final ref = _firestore
             .collection('users')
             .doc(userId)
             .collection('notifications')
             .doc(notification.id);
         batch.update(ref, {'isRead': true});
       }

       await batch.commit();
     }

     /// Navigate ke detail dari notification
     void onNotificationTap(NotificationItem notification) {
       markAsRead(notification.id);

       if (notification.route != null) {
         final route = notification.route!;
         final id = notification.routeId;

         if (id != null) {
           Get.toNamed('/$route/$id');
         } else {
           Get.toNamed('/$route');
         }
       }
     }
   }
   ```

3. **Platform Configuration:**

   **Android (`android/app/src/main/AndroidManifest.xml`):**
   ```xml
   <manifest ...>
     <uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
     <uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED"/>

     <application ...>
       <!-- FCM default channel -->
       <meta-data
         android:name="com.google.firebase.messaging.default_notification_channel_id"
         android:value="high_importance_channel" />

       <!-- FCM auto-init -->
       <meta-data
         android:name="firebase_messaging_auto_init_enabled"
         android:value="true" />
     </application>
   </manifest>
   ```

   **iOS (`ios/Runner/AppDelegate.swift`):**
   ```swift
   import UIKit
   import Flutter
   import FirebaseCore
   import FirebaseMessaging

   @main
   @objc class AppDelegate: FlutterAppDelegate {
     override func application(
       _ application: UIApplication,
       didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
     ) -> Bool {
       // Firebase sudah diinit di Dart, tapi perlu register untuk APNs
       if #available(iOS 10.0, *) {
         UNUserNotificationCenter.current().delegate = self
       }
       application.registerForRemoteNotifications()

       GeneratedPluginRegistrant.register(with: self)
       return super.application(application, didFinishLaunchingWithOptions: launchOptions)
     }

     override func application(
       _ application: UIApplication,
       didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
     ) {
       Messaging.messaging().apnsToken = deviceToken
     }
   }
   ```


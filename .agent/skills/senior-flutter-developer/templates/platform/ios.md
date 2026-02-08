# Flutter iOS Development

## Overview

iOS-specific features and configurations for Flutter apps including push notifications, in-app purchases, App Clips, widgets, and platform channels.

---

## Project Configuration

### Info.plist Permissions

```xml
<!-- ios/Runner/Info.plist -->
<!-- Camera -->
<key>NSCameraUsageDescription</key>
<string>Camera access for taking photos</string>

<!-- Photo Library -->
<key>NSPhotoLibraryUsageDescription</key>
<string>Photo library access for selecting images</string>

<!-- Location -->
<key>NSLocationWhenInUseUsageDescription</key>
<string>Location access for nearby features</string>
<key>NSLocationAlwaysUsageDescription</key>
<string>Background location for tracking</string>

<!-- Microphone -->
<key>NSMicrophoneUsageDescription</key>
<string>Microphone access for voice recording</string>

<!-- Face ID -->
<key>NSFaceIDUsageDescription</key>
<string>Face ID for authentication</string>
```

### Privacy Manifest (iOS 17+)

```xml
<!-- ios/Runner/PrivacyInfo.xcprivacy -->
<?xml version="1.0" encoding="UTF-8"?>
<plist version="1.0">
<dict>
  <key>NSPrivacyAccessedAPITypes</key>
  <array>
    <dict>
      <key>NSPrivacyAccessedAPIType</key>
      <string>NSPrivacyAccessedAPICategoryUserDefaults</string>
      <key>NSPrivacyAccessedAPITypeReasons</key>
      <array>
        <string>CA92.1</string>
      </array>
    </dict>
  </array>
</dict>
</plist>
```

---

## Push Notifications (APNS)

```dart
// Setup with firebase_messaging
import 'package:firebase_messaging/firebase_messaging.dart';

class PushNotificationService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  Future<void> initialize() async {
    // Request permission
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );
    
    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      // Get APNS token
      final apnsToken = await _messaging.getAPNSToken();
      final fcmToken = await _messaging.getToken();
      
      // Listen to foreground messages
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
      
      // Handle background messages
      FirebaseMessaging.onBackgroundMessage(_handleBackgroundMessage);
    }
  }

  void _handleForegroundMessage(RemoteMessage message) {
    // Show local notification
  }
}

@pragma('vm:entry-point')
Future<void> _handleBackgroundMessage(RemoteMessage message) async {
  // Handle in isolate
}
```

### Entitlements

```xml
<!-- ios/Runner/Runner.entitlements -->
<key>aps-environment</key>
<string>production</string>

<key>com.apple.developer.associated-domains</key>
<array>
  <string>applinks:yourdomain.com</string>
</array>
```

---

## In-App Purchases

```dart
import 'package:in_app_purchase/in_app_purchase.dart';

class IAPService {
  final InAppPurchase _iap = InAppPurchase.instance;
  late StreamSubscription<List<PurchaseDetails>> _subscription;

  Future<void> initialize() async {
    final available = await _iap.isAvailable();
    if (!available) return;

    _subscription = _iap.purchaseStream.listen(
      _handlePurchaseUpdates,
      onError: (error) => print('Purchase error: $error'),
    );
  }

  Future<List<ProductDetails>> loadProducts(Set<String> ids) async {
    final response = await _iap.queryProductDetails(ids);
    return response.productDetails;
  }

  Future<void> buy(ProductDetails product) async {
    final purchaseParam = PurchaseParam(productDetails: product);
    await _iap.buyNonConsumable(purchaseParam: purchaseParam);
  }

  void _handlePurchaseUpdates(List<PurchaseDetails> purchases) {
    for (final purchase in purchases) {
      if (purchase.status == PurchaseStatus.purchased) {
        _verifyAndDeliver(purchase);
      }
      if (purchase.pendingCompletePurchase) {
        _iap.completePurchase(purchase);
      }
    }
  }
}
```

---

## Deep Links / Universal Links

```dart
// Handle incoming links
import 'package:app_links/app_links.dart';

class DeepLinkService {
  final AppLinks _appLinks = AppLinks();

  Future<void> initialize() async {
    // Get initial link (app launched from link)
    final initialUri = await _appLinks.getInitialLink();
    if (initialUri != null) {
      _handleDeepLink(initialUri);
    }

    // Listen for subsequent links
    _appLinks.uriLinkStream.listen(_handleDeepLink);
  }

  void _handleDeepLink(Uri uri) {
    // Navigate based on path
    if (uri.path.startsWith('/product/')) {
      final productId = uri.pathSegments[1];
      // Navigate to product
    }
  }
}
```

```xml
<!-- ios/Runner/Runner.entitlements -->
<key>com.apple.developer.associated-domains</key>
<array>
  <string>applinks:yourdomain.com</string>
</array>
```

---

## Local Authentication (Face ID / Touch ID)

```dart
import 'package:local_auth/local_auth.dart';

class BiometricAuth {
  final LocalAuthentication _auth = LocalAuthentication();

  Future<bool> authenticate() async {
    final canAuth = await _auth.canCheckBiometrics;
    final isDeviceSupported = await _auth.isDeviceSupported();
    
    if (!canAuth || !isDeviceSupported) return false;

    try {
      return await _auth.authenticate(
        localizedReason: 'Authenticate to access your account',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );
    } catch (e) {
      return false;
    }
  }
}
```

---

## iOS Widget (WidgetKit)

```swift
// ios/MyWidget/MyWidget.swift
import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date())
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date())
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        // Read shared data from App Group
        let userDefaults = UserDefaults(suiteName: "group.com.yourapp")
        let data = userDefaults?.string(forKey: "widget_data") ?? "No data"
        
        let entry = SimpleEntry(date: Date(), data: data)
        let timeline = Timeline(entries: [entry], policy: .atEnd)
        completion(timeline)
    }
}

@main
struct MyWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "MyWidget", provider: Provider()) { entry in
            MyWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("My Widget")
        .description("Shows app data on home screen")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}
```

```dart
// Update widget from Flutter using home_widget package
import 'package:home_widget/home_widget.dart';

Future<void> updateWidget() async {
  await HomeWidget.saveWidgetData('widget_data', 'Updated value');
  await HomeWidget.updateWidget(
    iOSName: 'MyWidget',
    qualifiedAndroidName: 'com.example.MyWidgetProvider',
  );
}
```

---

## Best Practices

### ✅ Do This

- ✅ Always include Privacy Manifest for iOS 17+
- ✅ Request permissions at point of use, not on launch
- ✅ Support both Face ID and Touch ID
- ✅ Test on physical devices for push notifications
- ✅ Use App Groups for widget data sharing

### ❌ Avoid This

- ❌ Don't request all permissions at app launch
- ❌ Don't skip privacy manifest (App Store rejection)
- ❌ Don't hardcode bundle IDs
- ❌ Don't forget to handle background message handler

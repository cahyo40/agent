# Flutter Android Development

## Overview

Android-specific features and configurations for Flutter apps including FCM, flavors, ProGuard, adaptive icons, app bundles, and permissions.

---

## Project Configuration

### AndroidManifest Permissions

```xml
<!-- android/app/src/main/AndroidManifest.xml -->
<manifest>
    <!-- Internet -->
    <uses-permission android:name="android.permission.INTERNET"/>
    
    <!-- Camera -->
    <uses-permission android:name="android.permission.CAMERA"/>
    <uses-feature android:name="android.hardware.camera" android:required="false"/>
    
    <!-- Location -->
    <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
    <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
    <uses-permission android:name="android.permission.ACCESS_BACKGROUND_LOCATION"/>
    
    <!-- Storage (Android 12 and below) -->
    <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
    <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"/>
    
    <!-- Notifications (Android 13+) -->
    <uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
    
    <!-- Biometrics -->
    <uses-permission android:name="android.permission.USE_BIOMETRIC"/>
</manifest>
```

---

## Build Flavors

```kotlin
// android/app/build.gradle.kts
android {
    flavorDimensions += "environment"
    
    productFlavors {
        create("dev") {
            dimension = "environment"
            applicationIdSuffix = ".dev"
            versionNameSuffix = "-dev"
            resValue("string", "app_name", "MyApp Dev")
        }
        create("staging") {
            dimension = "environment"
            applicationIdSuffix = ".staging"
            versionNameSuffix = "-staging"
            resValue("string", "app_name", "MyApp Staging")
        }
        create("prod") {
            dimension = "environment"
            resValue("string", "app_name", "MyApp")
        }
    }
}
```

```bash
# Build with flavor
flutter build apk --flavor dev -t lib/main_dev.dart
flutter build apk --flavor prod -t lib/main_prod.dart
flutter build appbundle --flavor prod -t lib/main_prod.dart
```

---

## ProGuard / R8

```proguard
# android/app/proguard-rules.pro

# Flutter
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Firebase
-keep class com.google.firebase.** { *; }
-dontwarn com.google.firebase.**

# Gson (if using)
-keep class com.google.gson.** { *; }
-keepattributes Signature
-keepattributes *Annotation*

# Your app model classes
-keep class com.yourapp.models.** { *; }

# Crashlytics
-keepattributes SourceFile,LineNumberTable
-keep public class * extends java.lang.Exception
```

```kotlin
// android/app/build.gradle.kts
android {
    buildTypes {
        release {
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }
}
```

---

## Adaptive Icons

```xml
<!-- android/app/src/main/res/mipmap-anydpi-v26/ic_launcher.xml -->
<?xml version="1.0" encoding="utf-8"?>
<adaptive-icon xmlns:android="http://schemas.android.com/apk/res/android">
    <background android:drawable="@mipmap/ic_launcher_background"/>
    <foreground android:drawable="@mipmap/ic_launcher_foreground"/>
    <monochrome android:drawable="@mipmap/ic_launcher_monochrome"/>
</adaptive-icon>
```

```yaml
# Use flutter_launcher_icons package
flutter_launcher_icons:
  android: true
  ios: true
  image_path: "assets/icon/icon.png"
  adaptive_icon_background: "#FFFFFF"
  adaptive_icon_foreground: "assets/icon/icon_foreground.png"
```

---

## App Signing

```properties
# android/key.properties (DO NOT commit to git!)
storePassword=your_keystore_password
keyPassword=your_key_password
keyAlias=your_key_alias
storeFile=/path/to/keystore.jks
```

```kotlin
// android/app/build.gradle.kts
import java.util.Properties
import java.io.FileInputStream

val keystorePropertiesFile = rootProject.file("key.properties")
val keystoreProperties = Properties()
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {
    signingConfigs {
        create("release") {
            keyAlias = keystoreProperties["keyAlias"] as String
            keyPassword = keystoreProperties["keyPassword"] as String
            storeFile = file(keystoreProperties["storeFile"] as String)
            storePassword = keystoreProperties["storePassword"] as String
        }
    }
    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
        }
    }
}
```

---

## FCM Push Notifications

```dart
import 'package:firebase_messaging/firebase_messaging.dart';

class FCMService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  Future<void> initialize() async {
    // Request permission (Android 13+)
    final settings = await _messaging.requestPermission();
    
    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      final token = await _messaging.getToken();
      print('FCM Token: $token');
      
      // Token refresh
      _messaging.onTokenRefresh.listen((newToken) {
        // Send to server
      });
      
      // Foreground messages
      FirebaseMessaging.onMessage.listen((message) {
        // Show local notification
      });
    }
  }
}
```

---

## Deep Links

```xml
<!-- android/app/src/main/AndroidManifest.xml -->
<activity>
    <!-- App Links (verified) -->
    <intent-filter android:autoVerify="true">
        <action android:name="android.intent.action.VIEW"/>
        <category android:name="android.intent.category.DEFAULT"/>
        <category android:name="android.intent.category.BROWSABLE"/>
        <data android:scheme="https"
              android:host="yourdomain.com"
              android:pathPrefix="/app"/>
    </intent-filter>
    
    <!-- Custom scheme -->
    <intent-filter>
        <action android:name="android.intent.action.VIEW"/>
        <category android:name="android.intent.category.DEFAULT"/>
        <category android:name="android.intent.category.BROWSABLE"/>
        <data android:scheme="myapp"/>
    </intent-filter>
</activity>
```

---

## Home Screen Widgets

```kotlin
// android/app/src/main/kotlin/.../MyWidgetProvider.kt
class MyWidgetProvider : AppWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        for (appWidgetId in appWidgetIds) {
            val views = RemoteViews(context.packageName, R.layout.my_widget)
            
            // Get shared data
            val prefs = context.getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
            val data = prefs.getString("flutter.widget_data", "No data")
            
            views.setTextViewText(R.id.widget_text, data)
            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }
}
```

```dart
// Update from Flutter
import 'package:home_widget/home_widget.dart';

Future<void> updateWidget() async {
  await HomeWidget.saveWidgetData('widget_data', 'New value');
  await HomeWidget.updateWidget(
    qualifiedAndroidName: 'com.example.MyWidgetProvider',
  );
}
```

---

## Best Practices

### ✅ Do This

- ✅ Use App Bundles (.aab) for Play Store
- ✅ Enable ProGuard/R8 for release builds
- ✅ Use flavors for different environments
- ✅ Store signing keys securely (not in git)
- ✅ Support Android 13+ notification permission

### ❌ Avoid This

- ❌ Don't commit key.properties to git
- ❌ Don't skip ProGuard configuration
- ❌ Don't hardcode API keys in manifest
- ❌ Don't ignore targetSdk requirements

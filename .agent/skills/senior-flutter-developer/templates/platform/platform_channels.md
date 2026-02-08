# Flutter Platform Channels

## Overview

Communicating between Dart and native code (Swift/Kotlin) using Method Channels, Event Channels, and BasicMessageChannel.

---

## Channel Types

```text
┌─────────────────────────────────────────────────────────────┐
│                    PLATFORM CHANNELS                        │
├─────────────────┬─────────────────┬─────────────────────────┤
│ MethodChannel   │ EventChannel    │ BasicMessageChannel     │
├─────────────────┼─────────────────┼─────────────────────────┤
│ Request/Response│ Stream from     │ Two-way messaging       │
│ (one-time call) │ native to Dart  │ (continuous)            │
├─────────────────┼─────────────────┼─────────────────────────┤
│ getBatteryLevel │ sensorUpdates   │ Custom protocol         │
│ shareContent    │ locationChanges │ Complex data exchange   │
└─────────────────┴─────────────────┴─────────────────────────┘
```

---

## Method Channel

### Dart Side

```dart
class NativeBridge {
  static const _channel = MethodChannel('com.myapp/native');

  // Call native method
  Future<String> getBatteryLevel() async {
    try {
      final result = await _channel.invokeMethod<int>('getBatteryLevel');
      return 'Battery: $result%';
    } on PlatformException catch (e) {
      return 'Error: ${e.message}';
    }
  }

  // With arguments
  Future<bool> shareContent(String text, String? imagePath) async {
    final result = await _channel.invokeMethod<bool>('shareContent', {
      'text': text,
      'imagePath': imagePath,
    });
    return result ?? false;
  }

  // Handle calls FROM native
  void setupMethodCallHandler() {
    _channel.setMethodCallHandler((call) async {
      switch (call.method) {
        case 'onNativeEvent':
          final data = call.arguments as Map;
          _handleNativeEvent(data);
          return true;
        default:
          throw PlatformException(
            code: 'NOT_IMPLEMENTED',
            message: 'Method ${call.method} not implemented',
          );
      }
    });
  }
}
```

### Android (Kotlin)

```kotlin
// android/app/src/main/kotlin/.../MainActivity.kt
class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.myapp/native"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "getBatteryLevel" -> {
                        val level = getBatteryLevel()
                        if (level != -1) {
                            result.success(level)
                        } else {
                            result.error("UNAVAILABLE", "Battery level not available", null)
                        }
                    }
                    "shareContent" -> {
                        val text = call.argument<String>("text")
                        val imagePath = call.argument<String>("imagePath")
                        shareContent(text, imagePath)
                        result.success(true)
                    }
                    else -> result.notImplemented()
                }
            }
    }

    private fun getBatteryLevel(): Int {
        val batteryManager = getSystemService(Context.BATTERY_SERVICE) as BatteryManager
        return batteryManager.getIntProperty(BatteryManager.BATTERY_PROPERTY_CAPACITY)
    }
}
```

### iOS (Swift)

```swift
// ios/Runner/AppDelegate.swift
@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        let controller = window?.rootViewController as! FlutterViewController
        let channel = FlutterMethodChannel(
            name: "com.myapp/native",
            binaryMessenger: controller.binaryMessenger
        )

        channel.setMethodCallHandler { [weak self] (call, result) in
            switch call.method {
            case "getBatteryLevel":
                result(self?.getBatteryLevel())
            case "shareContent":
                if let args = call.arguments as? [String: Any] {
                    let text = args["text"] as? String ?? ""
                    self?.shareContent(text: text)
                    result(true)
                }
            default:
                result(FlutterMethodNotImplemented)
            }
        }

        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    private func getBatteryLevel() -> Int {
        UIDevice.current.isBatteryMonitoringEnabled = true
        return Int(UIDevice.current.batteryLevel * 100)
    }
}
```

---

## Event Channel (Streams)

### Dart Side

```dart
class SensorService {
  static const _eventChannel = EventChannel('com.myapp/sensors');

  Stream<SensorData> get accelerometerStream {
    return _eventChannel
        .receiveBroadcastStream()
        .map((event) => SensorData.fromMap(event as Map));
  }
}

// Usage
SensorService().accelerometerStream.listen((data) {
  print('X: ${data.x}, Y: ${data.y}, Z: ${data.z}');
});
```

### Android (Kotlin)

```kotlin
class MainActivity: FlutterActivity() {
    private val EVENT_CHANNEL = "com.myapp/sensors"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        EventChannel(flutterEngine.dartExecutor.binaryMessenger, EVENT_CHANNEL)
            .setStreamHandler(object : EventChannel.StreamHandler {
                private var sensorManager: SensorManager? = null
                private var listener: SensorEventListener? = null

                override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                    sensorManager = getSystemService(Context.SENSOR_SERVICE) as SensorManager
                    val accelerometer = sensorManager?.getDefaultSensor(Sensor.TYPE_ACCELEROMETER)

                    listener = object : SensorEventListener {
                        override fun onSensorChanged(event: SensorEvent?) {
                            event?.let {
                                events?.success(mapOf(
                                    "x" to it.values[0],
                                    "y" to it.values[1],
                                    "z" to it.values[2]
                                ))
                            }
                        }
                        override fun onAccuracyChanged(sensor: Sensor?, accuracy: Int) {}
                    }

                    sensorManager?.registerListener(
                        listener,
                        accelerometer,
                        SensorManager.SENSOR_DELAY_NORMAL
                    )
                }

                override fun onCancel(arguments: Any?) {
                    sensorManager?.unregisterListener(listener)
                }
            })
    }
}
```

### iOS (Swift)

```swift
class SensorStreamHandler: NSObject, FlutterStreamHandler {
    private var eventSink: FlutterEventSink?
    private var motionManager = CMMotionManager()

    func onListen(withArguments arguments: Any?, eventSink: @escaping FlutterEventSink) -> FlutterError? {
        self.eventSink = eventSink

        if motionManager.isAccelerometerAvailable {
            motionManager.accelerometerUpdateInterval = 0.1
            motionManager.startAccelerometerUpdates(to: .main) { [weak self] data, error in
                if let data = data {
                    self?.eventSink?([
                        "x": data.acceleration.x,
                        "y": data.acceleration.y,
                        "z": data.acceleration.z
                    ])
                }
            }
        }
        return nil
    }

    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        motionManager.stopAccelerometerUpdates()
        eventSink = nil
        return nil
    }
}
```

---

## Pigeon (Type-Safe Code Generation)

```yaml
# pubspec.yaml
dev_dependencies:
  pigeon: ^17.0.0
```

```dart
// pigeons/messages.dart
import 'package:pigeon/pigeon.dart';

class SearchRequest {
  String? query;
  int? limit;
}

class SearchResult {
  String? title;
  String? url;
}

@HostApi()
abstract class SearchApi {
  @async
  List<SearchResult> search(SearchRequest request);
}
```

```bash
# Generate code
dart run pigeon --input pigeons/messages.dart
```

---

## Best Practices

### ✅ Do This

- ✅ Use consistent channel naming (`com.yourapp/feature`)
- ✅ Handle errors on both sides
- ✅ Use Pigeon for complex APIs
- ✅ Cancel EventChannel subscriptions properly
- ✅ Run heavy native code on background threads

### ❌ Avoid This

- ❌ Don't block main thread in native code
- ❌ Don't pass non-serializable types
- ❌ Don't forget to unregister listeners
- ❌ Don't ignore platform exceptions

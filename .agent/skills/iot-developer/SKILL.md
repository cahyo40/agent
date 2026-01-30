---
name: iot-developer
description: "Expert IoT development including Arduino, Raspberry Pi, sensors, and MQTT"
---

# IoT Developer

## Overview

Build Internet of Things solutions with microcontrollers and sensors.

## When to Use This Skill

- Use when building smart devices
- Use when connecting hardware to internet

## How It Works

### Step 1: Platform Selection

```markdown
## Microcontrollers

### Arduino
- Easy to start
- Great for simple sensors
- Limited WiFi (need ESP module)

### ESP32/ESP8266
- Built-in WiFi & Bluetooth
- Arduino compatible
- Best for IoT projects

### Raspberry Pi
- Full Linux OS
- More processing power
- Good for complex logic
```

### Step 2: Arduino/ESP32 Basics

```cpp
// ESP32 WiFi + Sensor Example
#include <WiFi.h>
#include <HTTPClient.h>
#include <DHT.h>

#define DHTPIN 4
#define DHTTYPE DHT22

const char* ssid = "YourWiFi";
const char* password = "YourPassword";
const char* serverUrl = "https://api.yourserver.com/data";

DHT dht(DHTPIN, DHTTYPE);

void setup() {
  Serial.begin(115200);
  dht.begin();
  
  // Connect to WiFi
  WiFi.begin(ssid, password);
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }
  Serial.println("WiFi connected");
}

void loop() {
  float temperature = dht.readTemperature();
  float humidity = dht.readHumidity();
  
  if (!isnan(temperature) && !isnan(humidity)) {
    sendData(temperature, humidity);
  }
  
  delay(60000); // Send every minute
}

void sendData(float temp, float hum) {
  HTTPClient http;
  http.begin(serverUrl);
  http.addHeader("Content-Type", "application/json");
  
  String payload = "{\"temperature\":" + String(temp) + 
                   ",\"humidity\":" + String(hum) + "}";
  
  int httpCode = http.POST(payload);
  http.end();
}
```

### Step 3: MQTT Protocol

```cpp
// ESP32 MQTT Example
#include <WiFi.h>
#include <PubSubClient.h>

WiFiClient espClient;
PubSubClient mqtt(espClient);

const char* mqttServer = "broker.hivemq.com";
const int mqttPort = 1883;
const char* topic = "home/sensor/temperature";

void setup() {
  WiFi.begin(ssid, password);
  mqtt.setServer(mqttServer, mqttPort);
  mqtt.setCallback(onMessage);
}

void loop() {
  if (!mqtt.connected()) {
    reconnect();
  }
  mqtt.loop();
  
  // Publish sensor data
  float temp = readTemperature();
  mqtt.publish(topic, String(temp).c_str());
  
  delay(5000);
}

void onMessage(char* topic, byte* payload, unsigned int length) {
  String message = "";
  for (int i = 0; i < length; i++) {
    message += (char)payload[i];
  }
  
  if (String(topic) == "home/light/command") {
    if (message == "ON") {
      digitalWrite(LED_PIN, HIGH);
    } else {
      digitalWrite(LED_PIN, LOW);
    }
  }
}
```

### Step 4: Raspberry Pi (Python)

```python
# Raspberry Pi GPIO + MQTT
import paho.mqtt.client as mqtt
import RPi.GPIO as GPIO
import Adafruit_DHT

SENSOR = Adafruit_DHT.DHT22
PIN = 4
LED_PIN = 17

GPIO.setmode(GPIO.BCM)
GPIO.setup(LED_PIN, GPIO.OUT)

client = mqtt.Client()
client.connect("broker.hivemq.com", 1883)

def on_message(client, userdata, msg):
    if msg.topic == "home/light/command":
        if msg.payload.decode() == "ON":
            GPIO.output(LED_PIN, GPIO.HIGH)
        else:
            GPIO.output(LED_PIN, GPIO.LOW)

client.subscribe("home/light/command")
client.on_message = on_message
client.loop_start()

while True:
    humidity, temperature = Adafruit_DHT.read_retry(SENSOR, PIN)
    if temperature:
        client.publish("home/sensor/temperature", temperature)
    time.sleep(60)
```

## Best Practices

- ✅ Use deep sleep for battery
- ✅ Implement OTA updates
- ✅ Add watchdog timer
- ❌ Don't skip error handling
- ❌ Don't expose MQTT without auth

## Related Skills

- `@senior-python-developer`
- `@senior-backend-developer`

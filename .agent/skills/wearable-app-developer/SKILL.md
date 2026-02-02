---
name: wearable-app-developer
description: "Expert wearable application development including Apple Watch, Wear OS, health sensors, and companion app integration"
---

# Wearable App Developer

## Overview

This skill transforms you into a **Wearable App Expert**. You will master **Apple Watch Development**, **Wear OS**, **Health Sensors**, **Complications**, and **Companion App Integration** for building production-ready wearable applications.

## When to Use This Skill

- Use when building Apple Watch apps
- Use when creating Wear OS applications
- Use when integrating health sensors
- Use when building complications/tiles
- Use when syncing with phone apps

---

## Part 1: Wearable Architecture

### 1.1 System Components

```
┌─────────────────────────────────────────────────────────────┐
│                    Wearable Platform                         │
├────────────┬─────────────┬─────────────┬────────────────────┤
│ Watch App  │ Sensors     │ Notifications│ Complications     │
├────────────┴─────────────┴─────────────┴────────────────────┤
│               Phone Companion App                            │
├─────────────────────────────────────────────────────────────┤
│              Health Integration (HealthKit/Fit)              │
└─────────────────────────────────────────────────────────────┘
```

### 1.2 Key Concepts

| Concept | Description |
|---------|-------------|
| **Complication** | Watch face data display (watchOS) |
| **Tile** | Quick-access screen (Wear OS) |
| **Glance** | At-a-glance information |
| **Digital Crown** | Apple Watch scroll input |
| **Haptics** | Vibration feedback |
| **WatchConnectivity** | Phone-Watch communication |

---

## Part 2: Apple Watch (SwiftUI)

### 2.1 WatchOS App Structure

```swift
import SwiftUI
import HealthKit

@main
struct WorkoutTrackerApp: App {
    @StateObject private var workoutManager = WorkoutManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(workoutManager)
        }
    }
}

struct ContentView: View {
    @EnvironmentObject var workoutManager: WorkoutManager
    @State private var selectedWorkout: HKWorkoutActivityType = .running
    
    var body: some View {
        NavigationStack {
            List {
                Section("Quick Start") {
                    ForEach(WorkoutType.allCases, id: \.self) { workout in
                        NavigationLink(value: workout) {
                            HStack {
                                Image(systemName: workout.icon)
                                    .foregroundColor(.green)
                                Text(workout.name)
                            }
                        }
                    }
                }
                
                Section("Recent") {
                    ForEach(workoutManager.recentWorkouts) { workout in
                        WorkoutRowView(workout: workout)
                    }
                }
            }
            .navigationTitle("Workouts")
            .navigationDestination(for: WorkoutType.self) { workout in
                WorkoutSessionView(workoutType: workout)
            }
        }
    }
}
```

### 2.2 Workout Session

```swift
import HealthKit

class WorkoutManager: NSObject, ObservableObject {
    private let healthStore = HKHealthStore()
    private var session: HKWorkoutSession?
    private var builder: HKLiveWorkoutBuilder?
    
    @Published var heartRate: Double = 0
    @Published var activeCalories: Double = 0
    @Published var distance: Double = 0
    @Published var elapsedTime: TimeInterval = 0
    @Published var isActive = false
    
    func startWorkout(type: HKWorkoutActivityType) async throws {
        let configuration = HKWorkoutConfiguration()
        configuration.activityType = type
        configuration.locationType = .outdoor
        
        session = try HKWorkoutSession(healthStore: healthStore, configuration: configuration)
        builder = session?.associatedWorkoutBuilder()
        
        builder?.dataSource = HKLiveWorkoutDataSource(
            healthStore: healthStore,
            workoutConfiguration: configuration
        )
        
        session?.delegate = self
        builder?.delegate = self
        
        let startDate = Date()
        session?.startActivity(with: startDate)
        try await builder?.beginCollection(at: startDate)
        
        DispatchQueue.main.async {
            self.isActive = true
        }
    }
    
    func endWorkout() async throws {
        session?.end()
        try await builder?.endCollection(at: Date())
        
        if let workout = try await builder?.finishWorkout() {
            // Save completed workout
            DispatchQueue.main.async {
                self.isActive = false
            }
        }
    }
}

extension WorkoutManager: HKLiveWorkoutBuilderDelegate {
    func workoutBuilder(_ workoutBuilder: HKLiveWorkoutBuilder, 
                        didCollectDataOf collectedTypes: Set<HKSampleType>) {
        for type in collectedTypes {
            guard let quantityType = type as? HKQuantityType else { continue }
            
            let statistics = workoutBuilder.statistics(for: quantityType)
            
            DispatchQueue.main.async {
                switch quantityType {
                case HKQuantityType.quantityType(forIdentifier: .heartRate):
                    let heartRateUnit = HKUnit.count().unitDivided(by: .minute())
                    self.heartRate = statistics?.mostRecentQuantity()?.doubleValue(for: heartRateUnit) ?? 0
                    
                case HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned):
                    let calorieUnit = HKUnit.kilocalorie()
                    self.activeCalories = statistics?.sumQuantity()?.doubleValue(for: calorieUnit) ?? 0
                    
                case HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning):
                    let meterUnit = HKUnit.meter()
                    self.distance = statistics?.sumQuantity()?.doubleValue(for: meterUnit) ?? 0
                    
                default:
                    break
                }
            }
        }
    }
}
```

### 2.3 Complication

```swift
import ClockKit
import SwiftUI

struct ComplicationController: CLKComplicationDataSource {
    func complicationDescriptors() async -> [CLKComplicationDescriptor] {
        [
            CLKComplicationDescriptor(
                identifier: "workout_stats",
                displayName: "Workout Stats",
                supportedFamilies: [
                    .circularSmall,
                    .graphicCircular,
                    .graphicCorner,
                    .modularSmall
                ]
            )
        ]
    }
    
    func currentTimelineEntry(for complication: CLKComplication) async -> CLKComplicationTimelineEntry? {
        let template = makeTemplate(for: complication)
        return CLKComplicationTimelineEntry(date: Date(), complicationTemplate: template)
    }
    
    private func makeTemplate(for complication: CLKComplication) -> CLKComplicationTemplate {
        switch complication.family {
        case .graphicCircular:
            return CLKComplicationTemplateGraphicCircularView(
                CircularComplicationView()
            )
        case .modularSmall:
            return CLKComplicationTemplateModularSmallSimpleText(
                textProvider: CLKSimpleTextProvider(text: "500 cal")
            )
        default:
            fatalError("Unsupported complication family")
        }
    }
}

struct CircularComplicationView: View {
    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.green, lineWidth: 4)
            VStack {
                Image(systemName: "flame.fill")
                    .foregroundColor(.orange)
                Text("500")
                    .font(.caption2)
            }
        }
    }
}
```

---

## Part 3: Wear OS (Compose)

### 3.1 Wear Compose App

```kotlin
import androidx.wear.compose.material.*
import androidx.wear.compose.foundation.*

@Composable
fun WorkoutApp() {
    val scalingLazyListState = rememberScalingLazyListState()
    
    Scaffold(
        timeText = { TimeText() },
        vignette = { Vignette(vignettePosition = VignettePosition.TopAndBottom) },
        positionIndicator = { PositionIndicator(scalingLazyListState = scalingLazyListState) }
    ) {
        ScalingLazyColumn(
            state = scalingLazyListState,
            modifier = Modifier.fillMaxSize(),
            horizontalAlignment = Alignment.CenterHorizontally
        ) {
            item {
                Text(
                    text = "Start Workout",
                    style = MaterialTheme.typography.title2
                )
            }
            
            items(workoutTypes) { workout ->
                Chip(
                    onClick = { startWorkout(workout) },
                    label = { Text(workout.name) },
                    icon = {
                        Icon(
                            painter = painterResource(workout.iconRes),
                            contentDescription = workout.name
                        )
                    },
                    modifier = Modifier.fillMaxWidth()
                )
            }
        }
    }
}
```

### 3.2 Tile Service

```kotlin
import androidx.wear.tiles.*

class WorkoutTileService : TileService() {
    override fun onTileRequest(requestParams: RequestBuilders.TileRequest) =
        Futures.immediateFuture(
            TileBuilders.Tile.Builder()
                .setResourcesVersion("1")
                .setTimeline(
                    TimelineBuilders.Timeline.Builder()
                        .addTimelineEntry(
                            TimelineBuilders.TimelineEntry.Builder()
                                .setLayout(createLayout())
                                .build()
                        )
                        .build()
                )
                .build()
        )
    
    private fun createLayout(): LayoutElementBuilders.Layout {
        return LayoutElementBuilders.Layout.Builder()
            .setRoot(
                LayoutElementBuilders.Column.Builder()
                    .addContent(
                        LayoutElementBuilders.Text.Builder()
                            .setText("Today's Stats")
                            .build()
                    )
                    .addContent(
                        LayoutElementBuilders.Text.Builder()
                            .setText("500 cal burned")
                            .build()
                    )
                    .build()
            )
            .build()
    }
}
```

---

## Part 4: Phone-Watch Communication

### 4.1 WatchConnectivity (iOS)

```swift
import WatchConnectivity

class WatchConnectivityManager: NSObject, ObservableObject, WCSessionDelegate {
    static let shared = WatchConnectivityManager()
    private var session: WCSession?
    
    override init() {
        super.init()
        if WCSession.isSupported() {
            session = WCSession.default
            session?.delegate = self
            session?.activate()
        }
    }
    
    // Send data to watch
    func sendWorkoutData(_ data: [String: Any]) {
        guard let session = session, session.isReachable else { return }
        
        session.sendMessage(data, replyHandler: nil) { error in
            print("Error sending: \(error)")
        }
    }
    
    // Receive from watch
    func session(_ session: WCSession, didReceiveMessage message: [String: Any]) {
        DispatchQueue.main.async {
            if let workoutData = message["workout"] as? Data {
                // Process workout data from watch
            }
        }
    }
}
```

---

## Part 5: Best Practices Checklist

### ✅ Do This

- ✅ **Large Tap Targets**: Small screen = big buttons.
- ✅ **Glanceable Info**: Quick, essential data only.
- ✅ **Battery Efficient**: Minimize background work.

### ❌ Avoid This

- ❌ **Complex Navigation**: Keep it simple.
- ❌ **Tiny Text**: Use readable font sizes.
- ❌ **Continuous GPS**: Drain battery fast.

---

## Related Skills

- `@fitness-app-developer` - Workout tracking
- `@senior-ios-developer` - iOS development
- `@healthcare-app-developer` - Health data

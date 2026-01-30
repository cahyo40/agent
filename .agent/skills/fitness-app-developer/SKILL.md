---
name: fitness-app-developer
description: "Expert fitness and workout app development including exercise tracking, health metrics, and training programs"
---

# Fitness App Developer

## Overview

Build fitness and workout tracking apps with exercise logs, progress tracking, and health integration.

## When to Use This Skill

- Use when building fitness apps
- Use when tracking workouts and health

## How It Works

### Step 1: Data Models

```typescript
// Workout Models
interface Exercise {
  id: string;
  name: string;
  category: 'strength' | 'cardio' | 'flexibility' | 'sports';
  muscleGroups: string[];
  equipment: string[];
  instructions: string[];
  videoUrl?: string;
}

interface WorkoutSet {
  id: string;
  exerciseId: string;
  reps?: number;
  weight?: number;        // kg
  duration?: number;      // seconds
  distance?: number;      // meters
  restAfter: number;      // seconds
  completed: boolean;
}

interface Workout {
  id: string;
  userId: string;
  name: string;
  date: Date;
  duration: number;       // total minutes
  sets: WorkoutSet[];
  caloriesBurned: number;
  notes?: string;
}

interface UserStats {
  totalWorkouts: number;
  totalMinutes: number;
  totalCalories: number;
  currentStreak: number;
  longestStreak: number;
  personalRecords: Record<string, number>;
}
```

### Step 2: Workout Tracker UI

```tsx
// React Native / Flutter style
function WorkoutScreen() {
  const [currentExercise, setCurrentExercise] = useState(0);
  const [sets, setSets] = useState<WorkoutSet[]>([]);
  const [timer, setTimer] = useState(0);
  const [isResting, setIsResting] = useState(false);

  const logSet = (reps: number, weight: number) => {
    const newSet: WorkoutSet = {
      id: generateId(),
      exerciseId: exercises[currentExercise].id,
      reps,
      weight,
      restAfter: 90,
      completed: true
    };
    
    setSets([...sets, newSet]);
    startRestTimer(90);
  };

  const startRestTimer = (seconds: number) => {
    setIsResting(true);
    setTimer(seconds);
    
    const interval = setInterval(() => {
      setTimer(t => {
        if (t <= 1) {
          clearInterval(interval);
          setIsResting(false);
          vibrate();
          return 0;
        }
        return t - 1;
      });
    }, 1000);
  };

  return (
    <View>
      <ExerciseCard exercise={exercises[currentExercise]} />
      
      {isResting ? (
        <RestTimer seconds={timer} onSkip={() => setIsResting(false)} />
      ) : (
        <SetLogger onLog={logSet} previousSets={sets} />
      )}
      
      <WorkoutProgress 
        current={currentExercise + 1} 
        total={exercises.length} 
      />
    </View>
  );
}
```

### Step 3: Calorie Calculator

```typescript
// MET-based calorie calculation
const MET_VALUES: Record<string, number> = {
  'walking': 3.5,
  'running': 9.8,
  'cycling': 7.5,
  'swimming': 8.0,
  'weight_training': 6.0,
  'yoga': 2.5,
  'hiit': 12.0,
};

function calculateCalories(
  activity: string,
  durationMinutes: number,
  weightKg: number
): number {
  const met = MET_VALUES[activity] || 5.0;
  // Formula: Calories = MET × weight (kg) × duration (hours)
  const hours = durationMinutes / 60;
  return Math.round(met * weightKg * hours);
}

// Strength training calories
function calculateStrengthCalories(
  sets: WorkoutSet[],
  weightKg: number
): number {
  const totalSeconds = sets.reduce((sum, set) => {
    const setTime = (set.reps || 0) * 3; // ~3 sec per rep
    const restTime = set.restAfter || 60;
    return sum + setTime + restTime;
  }, 0);
  
  const minutes = totalSeconds / 60;
  return calculateCalories('weight_training', minutes, weightKg);
}
```

### Step 4: Progress Tracking

```typescript
// Personal Records
function checkPersonalRecord(
  exercise: string,
  weight: number,
  reps: number,
  currentPRs: Record<string, { weight: number; reps: number }>
): boolean {
  const key = exercise;
  const oneRepMax = weight * (1 + reps / 30); // Epley formula
  
  if (!currentPRs[key]) {
    return true;
  }
  
  const previousMax = currentPRs[key].weight * (1 + currentPRs[key].reps / 30);
  return oneRepMax > previousMax;
}

// Streak calculation
function calculateStreak(workoutDates: Date[]): number {
  const sorted = workoutDates
    .map(d => new Date(d).toDateString())
    .sort()
    .reverse();
  
  let streak = 0;
  let checkDate = new Date();
  
  for (const dateStr of sorted) {
    const workoutDate = new Date(dateStr).toDateString();
    const expected = checkDate.toDateString();
    
    if (workoutDate === expected) {
      streak++;
      checkDate.setDate(checkDate.getDate() - 1);
    } else {
      break;
    }
  }
  
  return streak;
}
```

### Step 5: Health API Integration

```swift
// Apple HealthKit (iOS)
import HealthKit

let healthStore = HKHealthStore()

func requestAuthorization() {
    let typesToShare: Set = [
        HKObjectType.workoutType(),
        HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!
    ]
    
    let typesToRead: Set = [
        HKQuantityType.quantityType(forIdentifier: .heartRate)!,
        HKQuantityType.quantityType(forIdentifier: .stepCount)!
    ]
    
    healthStore.requestAuthorization(toShare: typesToShare, read: typesToRead) { success, error in
        // Handle result
    }
}

func saveWorkout(duration: TimeInterval, calories: Double) {
    let workout = HKWorkout(
        activityType: .traditionalStrengthTraining,
        start: Date().addingTimeInterval(-duration),
        end: Date(),
        duration: duration,
        totalEnergyBurned: HKQuantity(unit: .kilocalorie(), doubleValue: calories),
        totalDistance: nil,
        metadata: nil
    )
    
    healthStore.save(workout) { success, error in
        // Handle result
    }
}
```

## Best Practices

- ✅ Sync with health platforms
- ✅ Offline-first for gym usage
- ✅ Celebrate achievements
- ❌ Don't skip rest timer
- ❌ Don't ignore form guidance

## Related Skills

- `@senior-flutter-developer`
- `@senior-ios-developer`

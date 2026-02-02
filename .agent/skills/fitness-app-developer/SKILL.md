---
name: fitness-app-developer
description: "Expert fitness and workout app development including exercise tracking, health metrics, and training programs"
---

# Fitness App Developer

## Overview

This skill transforms you into a **Fitness App Expert**. You will master **Workout Tracking**, **Exercise Libraries**, **Training Programs**, **Health Metrics**, and **Progress Analytics** for building production-ready fitness applications.

## When to Use This Skill

- Use when building workout tracking apps
- Use when implementing exercise libraries
- Use when creating training programs
- Use when integrating health data
- Use when building progress analytics

---

## Part 1: Fitness App Architecture

### 1.1 System Components

```
┌─────────────────────────────────────────────────────────────┐
│                     Fitness Platform                         │
├────────────┬─────────────┬─────────────┬────────────────────┤
│ Exercises  │ Workouts    │ Programs    │ Progress           │
├────────────┴─────────────┴─────────────┴────────────────────┤
│               Health Integration (HealthKit/Fit)             │
├─────────────────────────────────────────────────────────────┤
│              Analytics & Recommendations                     │
└─────────────────────────────────────────────────────────────┘
```

### 1.2 Key Concepts

| Concept | Description |
|---------|-------------|
| **Exercise** | Single movement (squat, bench press) |
| **Set** | Group of reps |
| **Rep** | Single exercise repetition |
| **Workout** | Collection of exercises |
| **Program** | Multi-week training plan |
| **1RM** | One rep max (strength indicator) |

---

## Part 2: Database Schema

### 2.1 Core Tables

```sql
-- Exercises
CREATE TABLE exercises (
    id UUID PRIMARY KEY,
    name VARCHAR(100),
    description TEXT,
    category VARCHAR(50),  -- 'strength', 'cardio', 'flexibility', 'sports'
    muscle_groups VARCHAR(50)[],  -- ['chest', 'triceps', 'shoulders']
    equipment VARCHAR(50)[],  -- ['barbell', 'dumbbell', 'machine']
    difficulty VARCHAR(20),  -- 'beginner', 'intermediate', 'advanced'
    instructions TEXT[],
    video_url VARCHAR(500),
    thumbnail_url VARCHAR(500),
    met_value DECIMAL(4, 2),  -- Metabolic Equivalent for calorie calculation
    is_compound BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Workout Templates
CREATE TABLE workout_templates (
    id UUID PRIMARY KEY,
    user_id UUID REFERENCES users(id),  -- NULL for system templates
    name VARCHAR(100),
    description TEXT,
    category VARCHAR(50),
    estimated_duration_minutes INTEGER,
    difficulty VARCHAR(20),
    is_public BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Template Exercises
CREATE TABLE template_exercises (
    id UUID PRIMARY KEY,
    template_id UUID REFERENCES workout_templates(id),
    exercise_id UUID REFERENCES exercises(id),
    position INTEGER,
    sets INTEGER,
    reps VARCHAR(20),  -- '8-12' or '10' or 'AMRAP'
    rest_seconds INTEGER,
    notes TEXT
);

-- Logged Workouts
CREATE TABLE workout_logs (
    id UUID PRIMARY KEY,
    user_id UUID REFERENCES users(id),
    template_id UUID REFERENCES workout_templates(id),
    name VARCHAR(100),
    started_at TIMESTAMPTZ,
    completed_at TIMESTAMPTZ,
    duration_seconds INTEGER,
    total_volume DECIMAL(10, 2),  -- Total weight lifted
    calories_burned INTEGER,
    notes TEXT,
    rating INTEGER,  -- 1-5 stars
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Exercise Logs (sets within a workout)
CREATE TABLE exercise_logs (
    id UUID PRIMARY KEY,
    workout_log_id UUID REFERENCES workout_logs(id),
    exercise_id UUID REFERENCES exercises(id),
    position INTEGER,
    notes TEXT
);

-- Set Logs
CREATE TABLE set_logs (
    id UUID PRIMARY KEY,
    exercise_log_id UUID REFERENCES exercise_logs(id),
    set_number INTEGER,
    reps INTEGER,
    weight DECIMAL(8, 2),
    weight_unit VARCHAR(10) DEFAULT 'kg',
    duration_seconds INTEGER,  -- For timed exercises
    distance_meters INTEGER,  -- For cardio
    rpe INTEGER,  -- Rate of Perceived Exertion (1-10)
    is_warmup BOOLEAN DEFAULT FALSE,
    is_dropset BOOLEAN DEFAULT FALSE,
    is_failure BOOLEAN DEFAULT FALSE,
    completed_at TIMESTAMPTZ
);

-- Personal Records
CREATE TABLE personal_records (
    id UUID PRIMARY KEY,
    user_id UUID REFERENCES users(id),
    exercise_id UUID REFERENCES exercises(id),
    record_type VARCHAR(20),  -- '1rm', '5rm', '10rm', 'max_reps', 'max_weight'
    value DECIMAL(10, 2),
    unit VARCHAR(10),
    achieved_at DATE,
    set_log_id UUID REFERENCES set_logs(id),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(user_id, exercise_id, record_type)
);

-- Training Programs
CREATE TABLE training_programs (
    id UUID PRIMARY KEY,
    name VARCHAR(100),
    description TEXT,
    goal VARCHAR(50),  -- 'strength', 'hypertrophy', 'endurance', 'weight_loss'
    duration_weeks INTEGER,
    days_per_week INTEGER,
    difficulty VARCHAR(20),
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Program Weeks
CREATE TABLE program_weeks (
    id UUID PRIMARY KEY,
    program_id UUID REFERENCES training_programs(id),
    week_number INTEGER,
    focus VARCHAR(100),
    deload BOOLEAN DEFAULT FALSE
);

-- Program Workouts (specific workout for each day)
CREATE TABLE program_workouts (
    id UUID PRIMARY KEY,
    program_week_id UUID REFERENCES program_weeks(id),
    day_number INTEGER,
    workout_template_id UUID REFERENCES workout_templates(id),
    name VARCHAR(100)
);
```

---

## Part 3: Workout Tracking

### 3.1 Log Workout

```typescript
interface WorkoutLogInput {
  templateId?: string;
  name: string;
  exercises: {
    exerciseId: string;
    sets: {
      reps: number;
      weight: number;
      weightUnit: 'kg' | 'lb';
      rpe?: number;
      isWarmup?: boolean;
    }[];
  }[];
}

async function logWorkout(userId: string, input: WorkoutLogInput): Promise<WorkoutLog> {
  const startedAt = new Date();
  
  const workout = await db.$transaction(async (tx) => {
    // Calculate totals
    let totalVolume = 0;
    const exerciseLogs = [];
    
    for (const exercise of input.exercises) {
      const setLogs = [];
      
      for (let i = 0; i < exercise.sets.length; i++) {
        const set = exercise.sets[i];
        if (!set.isWarmup) {
          totalVolume += set.reps * set.weight;
        }
        
        setLogs.push({
          setNumber: i + 1,
          reps: set.reps,
          weight: set.weight,
          weightUnit: set.weightUnit,
          rpe: set.rpe,
          isWarmup: set.isWarmup || false,
          completedAt: new Date(),
        });
      }
      
      exerciseLogs.push({ exerciseId: exercise.exerciseId, sets: setLogs });
    }
    
    // Estimate calories burned
    const caloriesBurned = await estimateCalories(userId, exerciseLogs);
    
    // Create workout log
    const workoutLog = await tx.workoutLogs.create({
      data: {
        userId,
        templateId: input.templateId,
        name: input.name,
        startedAt,
        completedAt: new Date(),
        durationSeconds: Math.floor((Date.now() - startedAt.getTime()) / 1000),
        totalVolume,
        caloriesBurned,
      },
    });
    
    // Create exercise and set logs
    for (let i = 0; i < exerciseLogs.length; i++) {
      const exerciseLog = await tx.exerciseLogs.create({
        data: {
          workoutLogId: workoutLog.id,
          exerciseId: exerciseLogs[i].exerciseId,
          position: i + 1,
        },
      });
      
      for (const set of exerciseLogs[i].sets) {
        await tx.setLogs.create({
          data: { exerciseLogId: exerciseLog.id, ...set },
        });
      }
    }
    
    // Check for PRs
    await checkAndUpdatePRs(tx, userId, exerciseLogs);
    
    return workoutLog;
  });
  
  return workout;
}
```

### 3.2 Calculate Estimated 1RM

```typescript
// Epley/Brzycki formula for 1RM estimation
function estimate1RM(weight: number, reps: number): number {
  if (reps === 1) return weight;
  if (reps > 12) return weight;  // Less accurate above 12 reps
  
  // Epley formula: weight * (1 + reps/30)
  const epley = weight * (1 + reps / 30);
  
  // Brzycki formula: weight / (1.0278 - 0.0278 * reps)
  const brzycki = weight / (1.0278 - 0.0278 * reps);
  
  // Average of both formulas
  return Math.round((epley + brzycki) / 2);
}

async function checkAndUpdatePRs(tx: any, userId: string, exerciseLogs: ExerciseLogData[]) {
  for (const exercise of exerciseLogs) {
    const heaviestSet = exercise.sets
      .filter(s => !s.isWarmup)
      .sort((a, b) => b.weight - a.weight)[0];
    
    if (!heaviestSet) continue;
    
    const estimated1RM = estimate1RM(heaviestSet.weight, heaviestSet.reps);
    
    // Check current PR
    const currentPR = await tx.personalRecords.findFirst({
      where: { userId, exerciseId: exercise.exerciseId, recordType: '1rm' },
    });
    
    if (!currentPR || estimated1RM > currentPR.value) {
      await tx.personalRecords.upsert({
        where: { userId_exerciseId_recordType: { userId, exerciseId: exercise.exerciseId, recordType: '1rm' } },
        create: {
          userId,
          exerciseId: exercise.exerciseId,
          recordType: '1rm',
          value: estimated1RM,
          unit: heaviestSet.weightUnit,
          achievedAt: new Date(),
        },
        update: {
          value: estimated1RM,
          achievedAt: new Date(),
        },
      });
    }
  }
}
```

---

## Part 4: Progress Analytics

### 4.1 Get Progress Stats

```typescript
interface ProgressStats {
  totalWorkouts: number;
  totalVolume: number;
  totalCalories: number;
  avgWorkoutDuration: number;
  currentStreak: number;
  personalRecords: PersonalRecord[];
}

async function getProgressStats(userId: string, days = 30): Promise<ProgressStats> {
  const since = subDays(new Date(), days);
  
  const workouts = await db.workoutLogs.findMany({
    where: { userId, completedAt: { gte: since } },
    orderBy: { completedAt: 'desc' },
  });
  
  const totalWorkouts = workouts.length;
  const totalVolume = workouts.reduce((sum, w) => sum + w.totalVolume, 0);
  const totalCalories = workouts.reduce((sum, w) => sum + w.caloriesBurned, 0);
  const avgWorkoutDuration = totalWorkouts > 0
    ? workouts.reduce((sum, w) => sum + w.durationSeconds, 0) / totalWorkouts
    : 0;
  
  // Calculate streak
  const currentStreak = calculateStreak(workouts);
  
  // Recent PRs
  const personalRecords = await db.personalRecords.findMany({
    where: { userId, achievedAt: { gte: since } },
    include: { exercise: true },
    orderBy: { achievedAt: 'desc' },
    take: 10,
  });
  
  return {
    totalWorkouts,
    totalVolume,
    totalCalories,
    avgWorkoutDuration,
    currentStreak,
    personalRecords,
  };
}
```

---

## Part 5: Health Integration

### 5.1 Apple HealthKit (React Native)

```typescript
import AppleHealthKit, { HealthKitPermissions, HealthValue } from 'react-native-health';

const permissions: HealthKitPermissions = {
  permissions: {
    read: ['ActiveEnergyBurned', 'HeartRate', 'StepCount', 'Workout'],
    write: ['Workout', 'ActiveEnergyBurned'],
  },
};

async function initHealthKit(): Promise<boolean> {
  return new Promise((resolve) => {
    AppleHealthKit.initHealthKit(permissions, (error) => {
      resolve(!error);
    });
  });
}

async function saveWorkoutToHealthKit(workout: WorkoutLog): Promise<void> {
  const options = {
    type: 'TraditionalStrengthTraining',
    startDate: workout.startedAt.toISOString(),
    endDate: workout.completedAt.toISOString(),
    energyBurned: workout.caloriesBurned,
  };
  
  AppleHealthKit.saveWorkout(options, (error, result) => {
    if (error) console.error('Failed to save to HealthKit:', error);
  });
}
```

---

## Part 6: Best Practices Checklist

### ✅ Do This

- ✅ **Sync with Health Apps**: HealthKit, Google Fit.
- ✅ **Offline Support**: Log workouts without internet.
- ✅ **Rest Timers**: Include rest period tracking.

### ❌ Avoid This

- ❌ **Complex UI During Workout**: Keep it simple.
- ❌ **Skip Warmup Sets**: Track but exclude from volume.
- ❌ **Ignore Form**: Provide exercise instructions.

---

## Related Skills

- `@healthcare-app-developer` - Health data
- `@wearable-app-developer` - Watch apps
- `@gamification-specialist` - Engagement

---
name: edtech-developer
description: "Expert educational technology development including LMS, course platforms, student progress tracking, assessments, and gamification"
---

# EdTech Developer

## Overview

Build educational technology platforms including LMS, course management, student tracking, assessments, gamification, and learning analytics.

## When to Use This Skill

- Use when building e-learning platforms
- Use when creating LMS systems
- Use when student Progress tracking
- Use when building course platforms

## How It Works

### Step 1: LMS Architecture

```
EDTECH PLATFORM COMPONENTS
├── CONTENT MANAGEMENT
│   ├── Courses & modules
│   ├── Lessons & topics
│   ├── Video hosting
│   ├── Documents & resources
│   └── SCORM compliance
│
├── USER MANAGEMENT
│   ├── Students
│   ├── Instructors
│   ├── Admins
│   └── Organizations
│
├── LEARNING PATHS
│   ├── Course progression
│   ├── Prerequisites
│   ├── Certificates
│   └── Competencies
│
├── ASSESSMENTS
│   ├── Quizzes & exams
│   ├── Assignments
│   ├── Auto-grading
│   └── Proctoring
│
└── ANALYTICS
    ├── Progress tracking
    ├── Engagement metrics
    ├── Learning outcomes
    └── Reports
```

### Step 2: Course Data Model

```typescript
// Course structure
interface Course {
  id: string;
  title: string;
  description: string;
  instructor: Instructor;
  thumbnail: string;
  duration: number; // minutes
  level: 'beginner' | 'intermediate' | 'advanced';
  modules: Module[];
  enrolledCount: number;
  rating: number;
  price: number;
  status: 'draft' | 'published' | 'archived';
}

interface Module {
  id: string;
  title: string;
  order: number;
  lessons: Lesson[];
}

interface Lesson {
  id: string;
  title: string;
  type: 'video' | 'article' | 'quiz' | 'assignment';
  duration: number;
  content: LessonContent;
  isPreview: boolean;
}

// Student progress
interface Enrollment {
  id: string;
  studentId: string;
  courseId: string;
  enrolledAt: Date;
  progress: number; // percentage
  completedLessons: string[];
  lastAccessedAt: Date;
  certificateId?: string;
}

interface LessonProgress {
  lessonId: string;
  studentId: string;
  status: 'not_started' | 'in_progress' | 'completed';
  watchTime: number; // for videos
  completedAt?: Date;
  score?: number; // for quizzes
}
```

### Step 3: Quiz & Assessment

```typescript
// Quiz structure
interface Quiz {
  id: string;
  title: string;
  timeLimit?: number; // minutes
  passingScore: number;
  shuffleQuestions: boolean;
  questions: Question[];
}

interface Question {
  id: string;
  type: 'multiple_choice' | 'multi_select' | 'true_false' | 'short_answer';
  text: string;
  options?: Option[];
  correctAnswer: string | string[];
  points: number;
  explanation?: string;
}

// Quiz attempt
interface QuizAttempt {
  id: string;
  quizId: string;
  studentId: string;
  startedAt: Date;
  submittedAt?: Date;
  answers: Answer[];
  score: number;
  passed: boolean;
  timeSpent: number;
}

// Auto-grading
function gradeQuiz(quiz: Quiz, answers: Answer[]): QuizResult {
  let totalPoints = 0;
  let earnedPoints = 0;

  for (const question of quiz.questions) {
    totalPoints += question.points;
    const answer = answers.find(a => a.questionId === question.id);
    
    if (isCorrect(question, answer)) {
      earnedPoints += question.points;
    }
  }

  const score = (earnedPoints / totalPoints) * 100;
  return { score, passed: score >= quiz.passingScore };
}
```

### Step 4: Gamification

```typescript
// Points and badges
interface StudentGamification {
  studentId: string;
  points: number;
  level: number;
  badges: Badge[];
  streak: number; // learning streak days
  achievements: Achievement[];
}

interface Badge {
  id: string;
  name: string;
  description: string;
  icon: string;
  earnedAt: Date;
}

// Leaderboard
async function getLeaderboard(courseId: string): Promise<LeaderboardEntry[]> {
  return db.query(`
    SELECT 
      u.id, u.name, u.avatar,
      SUM(p.points) as total_points,
      COUNT(DISTINCT l.id) as completed_lessons
    FROM users u
    JOIN enrollments e ON u.id = e.student_id
    JOIN lesson_progress p ON u.id = p.student_id
    WHERE e.course_id = $1
    GROUP BY u.id
    ORDER BY total_points DESC
    LIMIT 100
  `, [courseId]);
}
```

## Best Practices

### ✅ Do This

- ✅ Track granular progress
- ✅ Support offline learning
- ✅ Mobile-first design
- ✅ Accessibility compliance
- ✅ SCORM/xAPI standards

### ❌ Avoid This

- ❌ Don't ignore mobile
- ❌ Don't skip analytics
- ❌ Don't forget certificates
- ❌ Don't overcomplicate UI

## Related Skills

- `@e-learning-developer` - E-learning systems
- `@senior-fullstack-developer` - Full-stack development

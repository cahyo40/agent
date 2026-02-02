---
name: edtech-developer
description: "Expert educational technology development including LMS, course platforms, student progress tracking, assessments, and gamification"
---

# EdTech Developer

## Overview

This skill transforms you into an **Educational Technology Expert**. You will master **Learning Management Systems**, **Course Design**, **Progress Tracking**, **Assessments**, and **Gamification** for building production-ready e-learning platforms.

## When to Use This Skill

- Use when building online learning platforms
- Use when implementing LMS features
- Use when creating assessment systems
- Use when adding gamification elements
- Use when tracking student progress

---

## Part 1: EdTech Architecture

### 1.1 System Components

```
┌─────────────────────────────────────────────────────────────┐
│                      LMS Platform                            │
├─────────────┬─────────────┬─────────────┬───────────────────┤
│ Courses     │ Assessments │ Progress    │ Gamification      │
├─────────────┴─────────────┴─────────────┴───────────────────┤
│               Content Delivery & Streaming                   │
├─────────────────────────────────────────────────────────────┤
│                  Analytics & Reporting                       │
└─────────────────────────────────────────────────────────────┘
```

### 1.2 Key Concepts

| Concept | Description |
|---------|-------------|
| **Course** | Collection of modules and lessons |
| **Module** | Group of related lessons |
| **Lesson** | Single learning unit |
| **Quiz** | Assessment with questions |
| **Progress** | Completion tracking |
| **Certificate** | Completion credential |
| **Cohort** | Group of students |

---

## Part 2: Database Schema

### 2.1 Core Tables

```sql
-- Courses
CREATE TABLE courses (
    id UUID PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    slug VARCHAR(255) UNIQUE,
    description TEXT,
    thumbnail_url VARCHAR(500),
    instructor_id UUID REFERENCES users(id),
    price DECIMAL(10, 2) DEFAULT 0,
    currency VARCHAR(3) DEFAULT 'USD',
    level VARCHAR(50),  -- 'beginner', 'intermediate', 'advanced'
    duration_hours INTEGER,
    status VARCHAR(50) DEFAULT 'draft',  -- 'draft', 'published', 'archived'
    published_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Modules
CREATE TABLE modules (
    id UUID PRIMARY KEY,
    course_id UUID REFERENCES courses(id),
    title VARCHAR(255) NOT NULL,
    description TEXT,
    position INTEGER NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Lessons
CREATE TABLE lessons (
    id UUID PRIMARY KEY,
    module_id UUID REFERENCES modules(id),
    title VARCHAR(255) NOT NULL,
    type VARCHAR(50),  -- 'video', 'text', 'quiz', 'assignment'
    content TEXT,  -- For text lessons
    video_url VARCHAR(500),  -- For video lessons
    video_duration_seconds INTEGER,
    position INTEGER NOT NULL,
    is_free_preview BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Enrollments
CREATE TABLE enrollments (
    id UUID PRIMARY KEY,
    user_id UUID REFERENCES users(id),
    course_id UUID REFERENCES courses(id),
    enrolled_at TIMESTAMPTZ DEFAULT NOW(),
    completed_at TIMESTAMPTZ,
    progress_percent INTEGER DEFAULT 0,
    last_accessed_at TIMESTAMPTZ,
    UNIQUE(user_id, course_id)
);

-- Lesson Progress
CREATE TABLE lesson_progress (
    id UUID PRIMARY KEY,
    enrollment_id UUID REFERENCES enrollments(id),
    lesson_id UUID REFERENCES lessons(id),
    status VARCHAR(50) DEFAULT 'not_started',  -- 'not_started', 'in_progress', 'completed'
    progress_seconds INTEGER DEFAULT 0,  -- For videos
    completed_at TIMESTAMPTZ,
    UNIQUE(enrollment_id, lesson_id)
);

-- Quizzes
CREATE TABLE quizzes (
    id UUID PRIMARY KEY,
    lesson_id UUID REFERENCES lessons(id),
    title VARCHAR(255),
    passing_score INTEGER DEFAULT 70,
    max_attempts INTEGER,
    time_limit_minutes INTEGER,
    shuffle_questions BOOLEAN DEFAULT FALSE
);

-- Questions
CREATE TABLE questions (
    id UUID PRIMARY KEY,
    quiz_id UUID REFERENCES quizzes(id),
    type VARCHAR(50),  -- 'multiple_choice', 'true_false', 'multi_select', 'fill_blank'
    question_text TEXT NOT NULL,
    explanation TEXT,
    points INTEGER DEFAULT 1,
    position INTEGER
);

-- Answer Options
CREATE TABLE answer_options (
    id UUID PRIMARY KEY,
    question_id UUID REFERENCES questions(id),
    option_text TEXT NOT NULL,
    is_correct BOOLEAN DEFAULT FALSE,
    position INTEGER
);

-- Quiz Attempts
CREATE TABLE quiz_attempts (
    id UUID PRIMARY KEY,
    enrollment_id UUID REFERENCES enrollments(id),
    quiz_id UUID REFERENCES quizzes(id),
    started_at TIMESTAMPTZ DEFAULT NOW(),
    submitted_at TIMESTAMPTZ,
    score INTEGER,
    passed BOOLEAN,
    answers JSONB  -- { questionId: selectedOptionIds[] }
);

-- Certificates
CREATE TABLE certificates (
    id UUID PRIMARY KEY,
    enrollment_id UUID REFERENCES enrollments(id),
    certificate_number VARCHAR(50) UNIQUE,
    issued_at TIMESTAMPTZ DEFAULT NOW(),
    pdf_url VARCHAR(500)
);
```

---

## Part 3: Course Progress

### 3.1 Track Progress

```typescript
async function updateLessonProgress(
  enrollmentId: string,
  lessonId: string,
  progressSeconds: number
): Promise<LessonProgress> {
  const lesson = await db.lessons.findUnique({
    where: { id: lessonId },
  });
  
  // Determine if completed (80% of video or reaching end)
  const isCompleted = lesson.videoDurationSeconds
    ? progressSeconds >= lesson.videoDurationSeconds * 0.8
    : true;  // Text lessons complete on open
  
  const progress = await db.lessonProgress.upsert({
    where: { enrollmentId_lessonId: { enrollmentId, lessonId } },
    create: {
      enrollmentId,
      lessonId,
      status: isCompleted ? 'completed' : 'in_progress',
      progressSeconds,
      completedAt: isCompleted ? new Date() : null,
    },
    update: {
      progressSeconds,
      status: isCompleted ? 'completed' : 'in_progress',
      completedAt: isCompleted ? new Date() : undefined,
    },
  });
  
  // Recalculate enrollment progress
  await updateEnrollmentProgress(enrollmentId);
  
  return progress;
}

async function updateEnrollmentProgress(enrollmentId: string) {
  const enrollment = await db.enrollments.findUnique({
    where: { id: enrollmentId },
    include: { course: { include: { modules: { include: { lessons: true } } } } },
  });
  
  const totalLessons = enrollment.course.modules.reduce(
    (sum, m) => sum + m.lessons.length, 0
  );
  
  const completedLessons = await db.lessonProgress.count({
    where: { enrollmentId, status: 'completed' },
  });
  
  const progressPercent = Math.round((completedLessons / totalLessons) * 100);
  const isCompleted = progressPercent === 100;
  
  await db.enrollments.update({
    where: { id: enrollmentId },
    data: {
      progressPercent,
      completedAt: isCompleted ? new Date() : null,
      lastAccessedAt: new Date(),
    },
  });
  
  // Issue certificate if completed
  if (isCompleted) {
    await issueCertificate(enrollmentId);
  }
}
```

---

## Part 4: Assessments

### 4.1 Submit Quiz

```typescript
interface QuizSubmission {
  quizId: string;
  answers: Record<string, string[]>;  // questionId -> selectedOptionIds
}

async function submitQuiz(
  enrollmentId: string,
  submission: QuizSubmission
): Promise<QuizAttempt> {
  const quiz = await db.quizzes.findUnique({
    where: { id: submission.quizId },
    include: { questions: { include: { answerOptions: true } } },
  });
  
  // Check attempt limit
  const attemptCount = await db.quizAttempts.count({
    where: { enrollmentId, quizId: submission.quizId },
  });
  
  if (quiz.maxAttempts && attemptCount >= quiz.maxAttempts) {
    throw new Error('Maximum attempts reached');
  }
  
  // Calculate score
  let totalPoints = 0;
  let earnedPoints = 0;
  
  for (const question of quiz.questions) {
    totalPoints += question.points;
    
    const selectedIds = submission.answers[question.id] || [];
    const correctIds = question.answerOptions
      .filter(o => o.isCorrect)
      .map(o => o.id);
    
    // Check if answer is correct
    const isCorrect = 
      selectedIds.length === correctIds.length &&
      selectedIds.every(id => correctIds.includes(id));
    
    if (isCorrect) {
      earnedPoints += question.points;
    }
  }
  
  const scorePercent = Math.round((earnedPoints / totalPoints) * 100);
  const passed = scorePercent >= quiz.passingScore;
  
  const attempt = await db.quizAttempts.create({
    data: {
      enrollmentId,
      quizId: submission.quizId,
      submittedAt: new Date(),
      score: scorePercent,
      passed,
      answers: submission.answers,
    },
  });
  
  // Mark lesson complete if passed
  if (passed) {
    await db.lessonProgress.update({
      where: { enrollmentId_lessonId: { enrollmentId, lessonId: quiz.lessonId } },
      data: { status: 'completed', completedAt: new Date() },
    });
  }
  
  return attempt;
}
```

---

## Part 5: Gamification

### 5.1 Points & Badges

```typescript
const POINTS_CONFIG = {
  lesson_complete: 10,
  quiz_pass: 50,
  quiz_perfect: 100,
  course_complete: 500,
  streak_7_days: 100,
};

const BADGES = {
  first_lesson: { name: 'First Steps', condition: (stats) => stats.lessonsCompleted >= 1 },
  quiz_master: { name: 'Quiz Master', condition: (stats) => stats.quizzesPassed >= 10 },
  course_finisher: { name: 'Graduate', condition: (stats) => stats.coursesCompleted >= 1 },
  streak_warrior: { name: 'Streak Warrior', condition: (stats) => stats.currentStreak >= 7 },
};

async function awardPoints(userId: string, action: string, amount: number) {
  await db.userPoints.create({
    data: { userId, action, amount },
  });
  
  // Update leaderboard
  await redis.zincrby('leaderboard:weekly', amount, userId);
  
  // Check for new badges
  await checkBadges(userId);
}

async function checkBadges(userId: string) {
  const stats = await getUserStats(userId);
  const existingBadges = await db.userBadges.findMany({ where: { userId } });
  
  for (const [key, badge] of Object.entries(BADGES)) {
    if (!existingBadges.some(b => b.badgeKey === key) && badge.condition(stats)) {
      await db.userBadges.create({
        data: { userId, badgeKey: key, name: badge.name },
      });
      
      await sendBadgeNotification(userId, badge.name);
    }
  }
}
```

---

## Part 6: Video Streaming

### 6.1 Secure Video Delivery

```typescript
// Generate signed URL for video
async function getVideoUrl(lessonId: string, userId: string): Promise<string> {
  // Verify enrollment
  const lesson = await db.lessons.findUnique({
    where: { id: lessonId },
    include: { module: { include: { course: true } } },
  });
  
  if (!lesson.isFreePreview) {
    const enrollment = await db.enrollments.findFirst({
      where: { userId, courseId: lesson.module.course.id },
    });
    
    if (!enrollment) {
      throw new Error('Not enrolled');
    }
  }
  
  // Generate signed CloudFront URL
  const signedUrl = getCloudfrontSignedUrl(lesson.videoUrl, {
    expires: Date.now() + 3600 * 1000,  // 1 hour
  });
  
  return signedUrl;
}
```

---

## Part 7: Best Practices Checklist

### ✅ Do This

- ✅ **Adaptive Learning**: Adjust difficulty based on performance.
- ✅ **Mobile-First**: Many learners use mobile devices.
- ✅ **Offline Support**: Download content for offline use.

### ❌ Avoid This

- ❌ **Long Videos**: Break into 5-10 minute segments.
- ❌ **No Engagement**: Add quizzes, discussions.
- ❌ **Ignoring Analytics**: Track completion rates.

---

## Related Skills

- `@e-learning-developer` - SCORM integration
- `@gamification-specialist` - Game mechanics
- `@video-processing-specialist` - Video encoding

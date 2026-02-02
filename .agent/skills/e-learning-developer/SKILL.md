---
name: e-learning-developer
description: "Expert e-learning development including LMS, SCORM, interactive courses, and online learning platforms"
---

# E-Learning Developer

## Overview

This skill transforms you into an **E-Learning Expert**. You will master **LMS Development**, **Course Authoring**, **SCORM Integration**, **Quizzes & Assessments**, and **Learning Analytics** for building production-ready online learning platforms.

## When to Use This Skill

- Use when building Learning Management Systems
- Use when creating course platforms
- Use when implementing SCORM packages
- Use when building quiz/assessment systems
- Use when tracking learner progress

---

## Part 1: E-Learning Architecture

### 1.1 System Components

```
┌─────────────────────────────────────────────────────────────┐
│                 Learning Management System                   │
├────────────┬─────────────┬─────────────┬────────────────────┤
│ Courses    │ Lessons     │ Quizzes     │ Progress           │
├────────────┴─────────────┴─────────────┴────────────────────┤
│               Video Hosting & Streaming                      │
├─────────────────────────────────────────────────────────────┤
│              Certificates & Analytics                        │
└─────────────────────────────────────────────────────────────┘
```

### 1.2 Key Concepts

| Concept | Description |
|---------|-------------|
| **Course** | Collection of lessons |
| **Module** | Group of related lessons |
| **Lesson** | Single learning unit |
| **SCORM** | Sharable Content Object Reference Model |
| **xAPI** | Experience API (Tin Can) |
| **Drip Content** | Time-released lessons |

---

## Part 2: Database Schema

### 2.1 Core Tables

```sql
-- Courses
CREATE TABLE courses (
    id UUID PRIMARY KEY,
    instructor_id UUID REFERENCES users(id),
    title VARCHAR(255),
    slug VARCHAR(255) UNIQUE,
    description TEXT,
    short_description VARCHAR(500),
    thumbnail_url VARCHAR(500),
    promo_video_url VARCHAR(500),
    price DECIMAL(10, 2),
    sale_price DECIMAL(10, 2),
    currency VARCHAR(3) DEFAULT 'USD',
    level VARCHAR(20),  -- 'beginner', 'intermediate', 'advanced'
    language VARCHAR(10) DEFAULT 'en',
    duration_hours DECIMAL(5, 2),
    status VARCHAR(20) DEFAULT 'draft',  -- 'draft', 'published', 'archived'
    published_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Modules (sections of a course)
CREATE TABLE modules (
    id UUID PRIMARY KEY,
    course_id UUID REFERENCES courses(id),
    title VARCHAR(255),
    description TEXT,
    position INTEGER,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Lessons
CREATE TABLE lessons (
    id UUID PRIMARY KEY,
    module_id UUID REFERENCES modules(id),
    title VARCHAR(255),
    type VARCHAR(20),  -- 'video', 'text', 'quiz', 'assignment', 'scorm'
    content TEXT,  -- For text lessons
    video_url VARCHAR(500),
    video_duration_seconds INTEGER,
    is_free_preview BOOLEAN DEFAULT FALSE,
    position INTEGER,
    drip_days INTEGER,  -- Days after enrollment to unlock
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Enrollments
CREATE TABLE enrollments (
    id UUID PRIMARY KEY,
    user_id UUID REFERENCES users(id),
    course_id UUID REFERENCES courses(id),
    enrolled_at TIMESTAMPTZ DEFAULT NOW(),
    expires_at TIMESTAMPTZ,
    progress_percent DECIMAL(5, 2) DEFAULT 0,
    completed_at TIMESTAMPTZ,
    certificate_url VARCHAR(500),
    UNIQUE(user_id, course_id)
);

-- Lesson Progress
CREATE TABLE lesson_progress (
    id UUID PRIMARY KEY,
    enrollment_id UUID REFERENCES enrollments(id),
    lesson_id UUID REFERENCES lessons(id),
    status VARCHAR(20) DEFAULT 'not_started',  -- 'not_started', 'in_progress', 'completed'
    progress_percent DECIMAL(5, 2) DEFAULT 0,
    video_position_seconds INTEGER DEFAULT 0,
    started_at TIMESTAMPTZ,
    completed_at TIMESTAMPTZ,
    UNIQUE(enrollment_id, lesson_id)
);

-- Quizzes
CREATE TABLE quizzes (
    id UUID PRIMARY KEY,
    lesson_id UUID REFERENCES lessons(id),
    title VARCHAR(255),
    description TEXT,
    passing_score INTEGER DEFAULT 70,
    max_attempts INTEGER,
    time_limit_minutes INTEGER,
    shuffle_questions BOOLEAN DEFAULT FALSE,
    show_answers BOOLEAN DEFAULT TRUE
);

-- Quiz Questions
CREATE TABLE quiz_questions (
    id UUID PRIMARY KEY,
    quiz_id UUID REFERENCES quizzes(id),
    type VARCHAR(20),  -- 'multiple_choice', 'true_false', 'short_answer', 'matching'
    question TEXT,
    options JSONB,  -- For multiple choice
    correct_answer JSONB,
    explanation TEXT,
    points INTEGER DEFAULT 1,
    position INTEGER
);

-- Quiz Attempts
CREATE TABLE quiz_attempts (
    id UUID PRIMARY KEY,
    enrollment_id UUID REFERENCES enrollments(id),
    quiz_id UUID REFERENCES quizzes(id),
    started_at TIMESTAMPTZ DEFAULT NOW(),
    submitted_at TIMESTAMPTZ,
    answers JSONB,  -- { questionId: answer }
    score INTEGER,
    passed BOOLEAN
);
```

---

## Part 3: Course Progress Tracking

### 3.1 Update Lesson Progress

```typescript
async function updateLessonProgress(
  userId: string,
  lessonId: string,
  progress: { percent?: number; videoPosition?: number; completed?: boolean }
): Promise<LessonProgress> {
  const lesson = await db.lessons.findUnique({
    where: { id: lessonId },
    include: { module: { include: { course: true } } },
  });
  
  const enrollment = await db.enrollments.findFirst({
    where: { userId, courseId: lesson.module.courseId },
  });
  
  if (!enrollment) throw new Error('Not enrolled');
  
  // Check drip content
  if (lesson.dripDays) {
    const unlockDate = addDays(enrollment.enrolledAt, lesson.dripDays);
    if (new Date() < unlockDate) {
      throw new Error('Lesson not yet available');
    }
  }
  
  const lessonProgress = await db.lessonProgress.upsert({
    where: { enrollmentId_lessonId: { enrollmentId: enrollment.id, lessonId } },
    create: {
      enrollmentId: enrollment.id,
      lessonId,
      status: progress.completed ? 'completed' : 'in_progress',
      progressPercent: progress.percent || 0,
      videoPositionSeconds: progress.videoPosition || 0,
      startedAt: new Date(),
      completedAt: progress.completed ? new Date() : null,
    },
    update: {
      status: progress.completed ? 'completed' : 'in_progress',
      progressPercent: progress.percent,
      videoPositionSeconds: progress.videoPosition,
      completedAt: progress.completed ? new Date() : undefined,
    },
  });
  
  // Update overall course progress
  await updateCourseProgress(enrollment.id);
  
  return lessonProgress;
}

async function updateCourseProgress(enrollmentId: string) {
  const enrollment = await db.enrollments.findUnique({
    where: { id: enrollmentId },
    include: {
      course: {
        include: { modules: { include: { lessons: true } } },
      },
    },
  });
  
  const totalLessons = enrollment.course.modules.reduce(
    (sum, m) => sum + m.lessons.length, 0
  );
  
  const completedLessons = await db.lessonProgress.count({
    where: { enrollmentId, status: 'completed' },
  });
  
  const progressPercent = (completedLessons / totalLessons) * 100;
  const isComplete = progressPercent === 100;
  
  await db.enrollments.update({
    where: { id: enrollmentId },
    data: {
      progressPercent,
      completedAt: isComplete ? new Date() : null,
    },
  });
  
  // Generate certificate if complete
  if (isComplete && !enrollment.certificateUrl) {
    const certificateUrl = await generateCertificate(enrollment);
    await db.enrollments.update({
      where: { id: enrollmentId },
      data: { certificateUrl },
    });
  }
}
```

---

## Part 4: Quiz System

### 4.1 Submit Quiz Attempt

```typescript
interface QuizSubmission {
  quizId: string;
  answers: Record<string, any>;  // { questionId: answer }
}

async function submitQuizAttempt(
  userId: string,
  submission: QuizSubmission
): Promise<QuizAttempt> {
  const quiz = await db.quizzes.findUnique({
    where: { id: submission.quizId },
    include: { questions: true, lesson: { include: { module: true } } },
  });
  
  const enrollment = await db.enrollments.findFirst({
    where: { userId, courseId: quiz.lesson.module.courseId },
  });
  
  // Check attempt limit
  if (quiz.maxAttempts) {
    const attemptCount = await db.quizAttempts.count({
      where: { enrollmentId: enrollment.id, quizId: quiz.id },
    });
    
    if (attemptCount >= quiz.maxAttempts) {
      throw new Error('Maximum attempts reached');
    }
  }
  
  // Grade quiz
  let totalPoints = 0;
  let earnedPoints = 0;
  
  for (const question of quiz.questions) {
    totalPoints += question.points;
    const userAnswer = submission.answers[question.id];
    
    if (isCorrect(question, userAnswer)) {
      earnedPoints += question.points;
    }
  }
  
  const score = Math.round((earnedPoints / totalPoints) * 100);
  const passed = score >= quiz.passingScore;
  
  const attempt = await db.quizAttempts.create({
    data: {
      enrollmentId: enrollment.id,
      quizId: quiz.id,
      submittedAt: new Date(),
      answers: submission.answers,
      score,
      passed,
    },
  });
  
  // Mark lesson as complete if passed
  if (passed) {
    await updateLessonProgress(userId, quiz.lessonId, { completed: true });
  }
  
  return attempt;
}

function isCorrect(question: QuizQuestion, answer: any): boolean {
  switch (question.type) {
    case 'multiple_choice':
      return answer === question.correctAnswer;
      
    case 'true_false':
      return answer === question.correctAnswer;
      
    case 'short_answer':
      const correctAnswers = question.correctAnswer as string[];
      return correctAnswers.some(
        a => a.toLowerCase().trim() === answer?.toLowerCase().trim()
      );
      
    default:
      return false;
  }
}
```

---

## Part 5: Certificate Generation

### 5.1 Generate Certificate

```typescript
import PDFDocument from 'pdfkit';

async function generateCertificate(enrollment: Enrollment): Promise<string> {
  const user = await db.users.findUnique({ where: { id: enrollment.userId } });
  const course = await db.courses.findUnique({ where: { id: enrollment.courseId } });
  
  const doc = new PDFDocument({
    size: 'A4',
    layout: 'landscape',
  });
  
  const chunks: Buffer[] = [];
  doc.on('data', chunk => chunks.push(chunk));
  
  // Certificate design
  doc.fontSize(40).text('Certificate of Completion', { align: 'center' });
  doc.moveDown();
  doc.fontSize(20).text('This is to certify that', { align: 'center' });
  doc.moveDown();
  doc.fontSize(30).text(user.name, { align: 'center' });
  doc.moveDown();
  doc.fontSize(20).text('has successfully completed', { align: 'center' });
  doc.moveDown();
  doc.fontSize(25).text(course.title, { align: 'center' });
  doc.moveDown(2);
  doc.fontSize(14).text(`Completed on: ${format(enrollment.completedAt, 'MMMM d, yyyy')}`, { align: 'center' });
  doc.text(`Certificate ID: ${enrollment.id}`, { align: 'center' });
  
  doc.end();
  
  const pdfBuffer = Buffer.concat(chunks);
  const fileName = `certificates/${enrollment.id}.pdf`;
  
  // Upload to storage
  const url = await uploadToStorage(fileName, pdfBuffer);
  
  return url;
}
```

---

## Part 6: Best Practices Checklist

### ✅ Do This

- ✅ **Resume Playback**: Track video position.
- ✅ **Mobile Responsive**: Learning on any device.
- ✅ **Offline Download**: For mobile apps.

### ❌ Avoid This

- ❌ **Skip Progress Saving**: Auto-save frequently.
- ❌ **No Quiz Feedback**: Show explanations.
- ❌ **Ignore Accessibility**: Caption videos.

---

## Related Skills

- `@edtech-developer` - Education platforms
- `@video-processing-specialist` - Video hosting
- `@gamification-specialist` - Engagement

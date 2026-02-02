---
name: e-learning-developer
description: "Expert e-learning development including LMS, SCORM, interactive courses, and online learning platforms"
---

# E-Learning Developer

## Overview

This skill transforms you into a **production-grade e-learning specialist**. Beyond basic course creation, you'll implement complete Learning Management Systems with progress tracking, adaptive learning, SCORM/xAPI compliance, interactive assessments, gamification, and analytics-driven learning experiences.

## When to Use This Skill

- Use when building Learning Management Systems (LMS)
- Use when creating interactive online courses
- Use when implementing SCORM or xAPI content packages
- Use when designing assessments and quizzes
- Use when building adaptive learning paths
- Use when implementing gamification in education

---

## Part 1: LMS Architecture

### 1.1 System Architecture

```text
LMS PLATFORM ARCHITECTURE
┌─────────────────────────────────────────────────────────────────────────┐
│                           FRONTEND APPS                                  │
├──────────────────┬───────────────────┬─────────────────────────────────┤
│   Learner Portal │   Instructor      │      Admin Dashboard            │
│   (Web/Mobile)   │   Dashboard       │      (Content Management)       │
└──────────────────┴───────────────────┴─────────────────────────────────┘
                               │
┌─────────────────────────────────────────────────────────────────────────┐
│                            API LAYER                                     │
│      (Authentication, Course Access Control, Rate Limiting)            │
└─────────────────────────────────────────────────────────────────────────┘
                               │
┌─────────────────────────────────────────────────────────────────────────┐
│                         CORE SERVICES                                    │
├────────────┬────────────┬────────────┬────────────┬────────────────────┤
│  Course    │  Progress  │ Assessment │  Content   │   Certificate      │
│  Service   │  Tracking  │  Engine    │  Delivery  │   Generation       │
├────────────┼────────────┼────────────┼────────────┼────────────────────┤
│ Enrollment │ Learning   │ Discussion │ Gamification│  Notification      │
│  Service   │ Analytics  │  Forum     │  Engine    │   Service          │
└────────────┴────────────┴────────────┴────────────┴────────────────────┘
                               │
┌─────────────────────────────────────────────────────────────────────────┐
│                       CONTENT ENGINES                                    │
├──────────────────┬───────────────────┬─────────────────────────────────┤
│   SCORM Runtime  │   xAPI (TinCan)   │      Video Streaming            │
│   Engine         │   LRS             │      (Adaptive Bitrate)         │
└──────────────────┴───────────────────┴─────────────────────────────────┘
                               │
┌─────────────────────────────────────────────────────────────────────────┐
│                          DATA LAYER                                      │
├──────────────────┬───────────────────┬─────────────────────────────────┤
│   PostgreSQL     │     Redis         │      Object Storage             │
│   (Core Data)    │   (Session/Cache) │      (Media/Documents)          │
└──────────────────┴───────────────────┴─────────────────────────────────┘
```

### 1.2 Database Schema

```sql
-- ============================================
-- COURSE STRUCTURE
-- ============================================

CREATE TABLE courses (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    organization_id UUID REFERENCES organizations(id),
    
    -- Identity
    title VARCHAR(255) NOT NULL,
    slug VARCHAR(255) UNIQUE NOT NULL,
    description TEXT,
    short_description VARCHAR(500),
    thumbnail_url TEXT,
    
    -- Categories
    category_id UUID REFERENCES course_categories(id),
    difficulty_level VARCHAR(20), -- beginner, intermediate, advanced
    
    -- Duration
    estimated_duration_minutes INTEGER,
    
    -- Settings
    is_self_paced BOOLEAN DEFAULT true,
    allow_certificate BOOLEAN DEFAULT true,
    passing_score INTEGER DEFAULT 70, -- Percentage
    
    -- Pricing (for paid courses)
    is_free BOOLEAN DEFAULT true,
    price DECIMAL(10, 2),
    currency CHAR(3) DEFAULT 'IDR',
    
    -- SEO
    meta_title VARCHAR(255),
    meta_description TEXT,
    
    -- Status
    status VARCHAR(20) DEFAULT 'draft', -- draft, published, archived
    published_at TIMESTAMPTZ,
    
    -- Counts (denormalized for performance)
    enrollments_count INTEGER DEFAULT 0,
    completion_count INTEGER DEFAULT 0,
    average_rating DECIMAL(3, 2),
    ratings_count INTEGER DEFAULT 0,
    
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    created_by UUID REFERENCES users(id)
);

CREATE TABLE modules (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    course_id UUID NOT NULL REFERENCES courses(id) ON DELETE CASCADE,
    
    title VARCHAR(255) NOT NULL,
    description TEXT,
    sort_order INTEGER NOT NULL,
    
    -- Prerequisites
    prerequisite_module_id UUID REFERENCES modules(id),
    
    -- Requirements
    is_mandatory BOOLEAN DEFAULT true,
    unlock_after_days INTEGER, -- For drip content
    
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE lessons (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    module_id UUID NOT NULL REFERENCES modules(id) ON DELETE CASCADE,
    
    title VARCHAR(255) NOT NULL,
    description TEXT,
    sort_order INTEGER NOT NULL,
    
    -- Content type
    content_type VARCHAR(20) NOT NULL,
    -- video, article, quiz, assignment, scorm, interactive, live_session
    
    -- Content (based on type)
    content_data JSONB NOT NULL,
    -- For video: {url, duration, thumbnail, transcript}
    -- For article: {html, readingTime}
    -- For quiz: {quizId}
    -- For SCORM: {packageUrl, version}
    
    -- Duration
    estimated_duration_minutes INTEGER,
    
    -- Settings
    is_previewable BOOLEAN DEFAULT false, -- Free preview
    is_mandatory BOOLEAN DEFAULT true,
    requires_completion BOOLEAN DEFAULT true,
    
    -- Completion criteria
    completion_criteria JSONB,
    -- {type: 'video', minWatchPercent: 90}
    -- {type: 'quiz', minScore: 70}
    -- {type: 'manual'}
    
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================
-- ENROLLMENT & PROGRESS
-- ============================================

CREATE TABLE enrollments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id),
    course_id UUID NOT NULL REFERENCES courses(id),
    
    -- Status
    status VARCHAR(20) DEFAULT 'active',
    -- active, completed, expired, suspended
    
    -- Progress
    progress_percent INTEGER DEFAULT 0,
    completed_lessons_count INTEGER DEFAULT 0,
    
    -- Dates
    enrolled_at TIMESTAMPTZ DEFAULT NOW(),
    started_at TIMESTAMPTZ,
    completed_at TIMESTAMPTZ,
    expires_at TIMESTAMPTZ, -- For subscription-based access
    
    -- Last activity
    last_accessed_at TIMESTAMPTZ,
    last_lesson_id UUID REFERENCES lessons(id),
    
    -- Certificate
    certificate_issued_at TIMESTAMPTZ,
    certificate_url TEXT,
    
    UNIQUE(user_id, course_id)
);

CREATE TABLE lesson_progress (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    enrollment_id UUID NOT NULL REFERENCES enrollments(id) ON DELETE CASCADE,
    lesson_id UUID NOT NULL REFERENCES lessons(id),
    
    -- Status
    status VARCHAR(20) DEFAULT 'not_started',
    -- not_started, in_progress, completed
    
    -- Progress details
    progress_data JSONB,
    -- For video: {watchedSeconds: 300, totalSeconds: 600}
    -- For quiz: {attempts: 2, bestScore: 85}
    -- For SCORM: {cmi data}
    
    -- Time tracking
    time_spent_seconds INTEGER DEFAULT 0,
    
    -- Completion
    completed_at TIMESTAMPTZ,
    
    -- Dates
    started_at TIMESTAMPTZ,
    last_accessed_at TIMESTAMPTZ,
    
    UNIQUE(enrollment_id, lesson_id)
);

-- ============================================
-- ASSESSMENTS
-- ============================================

CREATE TABLE quizzes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    course_id UUID REFERENCES courses(id), -- Can be standalone
    
    title VARCHAR(255) NOT NULL,
    description TEXT,
    instructions TEXT,
    
    -- Settings
    time_limit_minutes INTEGER, -- NULL = no limit
    max_attempts INTEGER, -- NULL = unlimited
    passing_score INTEGER DEFAULT 70,
    
    -- Question settings
    shuffle_questions BOOLEAN DEFAULT false,
    shuffle_options BOOLEAN DEFAULT false,
    show_correct_answers BOOLEAN DEFAULT true,
    show_correct_after VARCHAR(20) DEFAULT 'submission',
    -- submission, grading, never
    
    -- Scoring
    scoring_type VARCHAR(20) DEFAULT 'highest',
    -- highest, latest, average
    
    -- Availability
    available_from TIMESTAMPTZ,
    available_until TIMESTAMPTZ,
    
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE questions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    quiz_id UUID NOT NULL REFERENCES quizzes(id) ON DELETE CASCADE,
    
    -- Question
    question_type VARCHAR(20) NOT NULL,
    -- multiple_choice, multiple_answer, true_false, short_answer, essay, matching, ordering
    
    question_text TEXT NOT NULL,
    question_media JSONB, -- {type: 'image', url: '...'}
    
    -- Options (for choice-based questions)
    options JSONB,
    -- [{id: 'a', text: 'Option A', isCorrect: true, feedback: '...'}]
    
    -- Correct answer (for other types)
    correct_answer JSONB,
    -- For short_answer: {answers: ['answer1', 'answer2'], caseSensitive: false}
    -- For matching: {pairs: [{left: 'A', right: '1'}]}
    
    -- Scoring
    points INTEGER DEFAULT 1,
    partial_credit BOOLEAN DEFAULT false,
    
    -- Explanation
    explanation TEXT,
    
    sort_order INTEGER NOT NULL,
    
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE quiz_attempts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    quiz_id UUID NOT NULL REFERENCES quizzes(id),
    user_id UUID NOT NULL REFERENCES users(id),
    enrollment_id UUID REFERENCES enrollments(id),
    
    -- Status
    status VARCHAR(20) DEFAULT 'in_progress',
    -- in_progress, submitted, graded
    
    -- Timing
    started_at TIMESTAMPTZ DEFAULT NOW(),
    submitted_at TIMESTAMPTZ,
    time_spent_seconds INTEGER,
    
    -- Scoring
    score DECIMAL(5, 2),
    max_score DECIMAL(5, 2),
    score_percent DECIMAL(5, 2),
    passed BOOLEAN,
    
    -- Answers (stored for review)
    answers JSONB,
    -- {questionId: {answer: 'a', isCorrect: true, pointsEarned: 1}}
    
    attempt_number INTEGER NOT NULL
);

-- ============================================
-- GAMIFICATION
-- ============================================

CREATE TABLE badges (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(100) NOT NULL,
    description TEXT,
    image_url TEXT,
    
    -- Criteria
    criteria_type VARCHAR(50) NOT NULL,
    -- course_completion, quiz_score, streak, lessons_completed, time_spent
    
    criteria_data JSONB NOT NULL,
    -- {courseId: '...'}
    -- {minScore: 100}
    -- {streakDays: 7}
    -- {lessonCount: 50}
    
    -- Points
    points_value INTEGER DEFAULT 0,
    
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE user_badges (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id),
    badge_id UUID NOT NULL REFERENCES badges(id),
    
    earned_at TIMESTAMPTZ DEFAULT NOW(),
    
    -- Context
    context_type VARCHAR(50), -- course, quiz, achievement
    context_id UUID,
    
    UNIQUE(user_id, badge_id)
);

CREATE TABLE leaderboards (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id),
    
    -- Scope
    scope_type VARCHAR(50) NOT NULL, -- global, course, organization
    scope_id UUID,
    
    -- Period
    period_type VARCHAR(20) NOT NULL, -- all_time, weekly, monthly
    period_start DATE,
    
    -- Stats
    points INTEGER DEFAULT 0,
    courses_completed INTEGER DEFAULT 0,
    lessons_completed INTEGER DEFAULT 0,
    badges_earned INTEGER DEFAULT 0,
    
    rank INTEGER,
    
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    
    UNIQUE(user_id, scope_type, scope_id, period_type, period_start)
);
```

---

## Part 2: Course Service

### 2.1 Course Management

```typescript
// services/course.service.ts
export class CourseService {
  constructor(
    private readonly db: Database,
    private readonly cache: CacheService,
    private readonly searchEngine: SearchService,
    private readonly logger: Logger,
  ) {}

  async getCourse(courseId: string, userId?: string): Promise<Result<CourseDetail>> {
    // Check cache
    const cacheKey = `course:${courseId}`;
    let course = await this.cache.get<Course>(cacheKey);

    if (!course) {
      course = await this.db
        .selectFrom('courses')
        .where('id', '=', courseId)
        .selectAll()
        .executeTakeFirst();

      if (!course) {
        return Result.failure(new NotFoundError('Course not found'));
      }

      await this.cache.set(cacheKey, course, 300);
    }

    // Get modules and lessons
    const modules = await this.getModulesWithLessons(courseId);

    // Get enrollment if user provided
    let enrollment: Enrollment | undefined;
    let lessonProgress: Map<string, LessonProgress> | undefined;

    if (userId) {
      enrollment = await this.getEnrollment(userId, courseId);
      
      if (enrollment) {
        const progress = await this.getLessonProgress(enrollment.id);
        lessonProgress = new Map(progress.map((p) => [p.lessonId, p]));
      }
    }

    return Result.success({
      ...course,
      modules: modules.map((m) => ({
        ...m,
        lessons: m.lessons.map((l) => ({
          ...l,
          progress: lessonProgress?.get(l.id),
          isAccessible: this.isLessonAccessible(l, enrollment, lessonProgress),
        })),
      })),
      enrollment,
    });
  }

  async createCourse(data: CreateCourseDto): Promise<Result<Course>> {
    return this.db.transaction(async (trx) => {
      const slug = await this.generateUniqueSlug(data.title, trx);

      const [course] = await trx
        .insertInto('courses')
        .values({
          ...data,
          slug,
          status: 'draft',
        })
        .returning('*')
        .execute();

      // Create default module if provided
      if (data.modules?.length) {
        for (let i = 0; i < data.modules.length; i++) {
          const module = data.modules[i];
          const [createdModule] = await trx
            .insertInto('modules')
            .values({
              courseId: course.id,
              title: module.title,
              description: module.description,
              sortOrder: i,
            })
            .returning('*')
            .execute();

          // Create lessons
          if (module.lessons?.length) {
            for (let j = 0; j < module.lessons.length; j++) {
              await trx
                .insertInto('lessons')
                .values({
                  moduleId: createdModule.id,
                  ...module.lessons[j],
                  sortOrder: j,
                })
                .execute();
            }
          }
        }
      }

      // Index for search
      await this.searchEngine.index('courses', course.id, {
        title: course.title,
        description: course.description,
        category: course.categoryId,
      });

      return Result.success(course);
    });
  }

  async publishCourse(courseId: string): Promise<Result<void>> {
    return this.db.transaction(async (trx) => {
      const course = await trx
        .selectFrom('courses')
        .where('id', '=', courseId)
        .selectAll()
        .executeTakeFirst();

      if (!course) {
        return Result.failure(new NotFoundError('Course not found'));
      }

      // Validate course has content
      const lessonCount = await this.countLessons(courseId, trx);
      
      if (lessonCount === 0) {
        return Result.failure(new ValidationError('Course must have at least one lesson'));
      }

      // Calculate total duration
      const totalDuration = await this.calculateTotalDuration(courseId, trx);

      await trx
        .updateTable('courses')
        .set({
          status: 'published',
          publishedAt: new Date(),
          estimatedDurationMinutes: totalDuration,
        })
        .where('id', '=', courseId)
        .execute();

      // Invalidate cache
      await this.cache.delete(`course:${courseId}`);

      return Result.success(undefined);
    });
  }

  private isLessonAccessible(
    lesson: Lesson,
    enrollment?: Enrollment,
    progress?: Map<string, LessonProgress>,
  ): boolean {
    // Free preview lessons are always accessible
    if (lesson.isPreviewable) return true;

    // Must be enrolled
    if (!enrollment) return false;

    // Check if enrollment is active
    if (enrollment.status !== 'active') return false;

    // Check drip content
    if (lesson.unlockAfterDays) {
      const unlockDate = addDays(enrollment.enrolledAt, lesson.unlockAfterDays);
      if (new Date() < unlockDate) return false;
    }

    // Check prerequisites
    if (lesson.prerequisiteLessonId) {
      const prereqProgress = progress?.get(lesson.prerequisiteLessonId);
      if (!prereqProgress || prereqProgress.status !== 'completed') {
        return false;
      }
    }

    return true;
  }
}
```

---

## Part 3: Progress Tracking

### 3.1 Progress Service

```typescript
// services/progress.service.ts
export class ProgressService {
  constructor(
    private readonly db: Database,
    private readonly badgeService: BadgeService,
    private readonly certificateService: CertificateService,
    private readonly analyticsService: AnalyticsService,
    private readonly eventBus: EventBus,
    private readonly logger: Logger,
  ) {}

  async updateLessonProgress(
    enrollmentId: string,
    lessonId: string,
    data: LessonProgressUpdate,
  ): Promise<Result<LessonProgress>> {
    return this.db.transaction(async (trx) => {
      const enrollment = await trx
        .selectFrom('enrollments')
        .where('id', '=', enrollmentId)
        .forUpdate()
        .selectAll()
        .executeTakeFirst();

      if (!enrollment || enrollment.status !== 'active') {
        return Result.failure(new ValidationError('Invalid enrollment'));
      }

      const lesson = await this.getLesson(lessonId);

      // Get or create progress
      let progress = await trx
        .selectFrom('lesson_progress')
        .where('enrollment_id', '=', enrollmentId)
        .where('lesson_id', '=', lessonId)
        .forUpdate()
        .selectAll()
        .executeTakeFirst();

      const now = new Date();

      if (!progress) {
        [progress] = await trx
          .insertInto('lesson_progress')
          .values({
            enrollmentId,
            lessonId,
            status: 'in_progress',
            startedAt: now,
            lastAccessedAt: now,
            progressData: data.progressData || {},
            timeSpentSeconds: data.timeSpentSeconds || 0,
          })
          .returning('*')
          .execute();

        // Update enrollment started_at if first lesson
        if (!enrollment.startedAt) {
          await trx
            .updateTable('enrollments')
            .set({ startedAt: now })
            .where('id', '=', enrollmentId)
            .execute();
        }
      } else {
        // Merge progress data
        const mergedData = this.mergeProgressData(
          progress.progressData,
          data.progressData,
          lesson.contentType,
        );

        await trx
          .updateTable('lesson_progress')
          .set({
            progressData: mergedData,
            timeSpentSeconds: (progress.timeSpentSeconds || 0) + (data.timeSpentSeconds || 0),
            lastAccessedAt: now,
          })
          .where('id', '=', progress.id)
          .execute();

        progress = { ...progress, progressData: mergedData };
      }

      // Check completion criteria
      const shouldComplete = await this.checkCompletionCriteria(
        lesson,
        progress.progressData,
      );

      if (shouldComplete && progress.status !== 'completed') {
        await trx
          .updateTable('lesson_progress')
          .set({
            status: 'completed',
            completedAt: now,
          })
          .where('id', '=', progress.id)
          .execute();

        progress.status = 'completed';
        progress.completedAt = now;

        // Update enrollment progress
        await this.updateEnrollmentProgress(enrollment, trx);

        // Track completion
        await this.analyticsService.track('lesson_completed', {
          enrollmentId,
          lessonId,
          courseId: enrollment.courseId,
          userId: enrollment.userId,
        });

        // Check for badges
        await this.badgeService.checkAndAward(enrollment.userId, 'lesson_completion', {
          lessonId,
          courseId: enrollment.courseId,
        });
      }

      // Update last accessed
      await trx
        .updateTable('enrollments')
        .set({
          lastAccessedAt: now,
          lastLessonId: lessonId,
        })
        .where('id', '=', enrollmentId)
        .execute();

      return Result.success(progress);
    });
  }

  async updateEnrollmentProgress(
    enrollment: Enrollment,
    trx: Transaction,
  ): Promise<void> {
    // Count total and completed lessons
    const [stats] = await trx
      .selectFrom('lessons as l')
      .innerJoin('modules as m', 'l.module_id', 'm.id')
      .leftJoin(
        'lesson_progress as lp',
        (join) =>
          join
            .onRef('l.id', '=', 'lp.lesson_id')
            .on('lp.enrollment_id', '=', enrollment.id),
      )
      .where('m.course_id', '=', enrollment.courseId)
      .select([
        sql`COUNT(l.id)`.as('totalLessons'),
        sql`COUNT(CASE WHEN lp.status = 'completed' THEN 1 END)`.as('completedLessons'),
      ])
      .execute();

    const totalLessons = Number(stats.totalLessons);
    const completedLessons = Number(stats.completedLessons);
    const progressPercent = totalLessons > 0
      ? Math.round((completedLessons / totalLessons) * 100)
      : 0;

    await trx
      .updateTable('enrollments')
      .set({
        progressPercent,
        completedLessonsCount: completedLessons,
        updatedAt: new Date(),
      })
      .where('id', '=', enrollment.id)
      .execute();

    // Check course completion
    if (progressPercent === 100) {
      const course = await this.getCourse(enrollment.courseId);
      
      // Check if passing score required
      if (course.passingScore) {
        const passed = await this.checkPassingScore(enrollment.id, course.passingScore);
        
        if (!passed) return;
      }

      await this.completeCourse(enrollment, trx);
    }
  }

  private async completeCourse(
    enrollment: Enrollment,
    trx: Transaction,
  ): Promise<void> {
    const now = new Date();

    await trx
      .updateTable('enrollments')
      .set({
        status: 'completed',
        completedAt: now,
      })
      .where('id', '=', enrollment.id)
      .execute();

    // Update course completion count
    await trx
      .updateTable('courses')
      .set(sql`completion_count = completion_count + 1`)
      .where('id', '=', enrollment.courseId)
      .execute();

    // Generate certificate
    const course = await this.getCourse(enrollment.courseId);
    
    if (course.allowCertificate) {
      const certificate = await this.certificateService.generate({
        userId: enrollment.userId,
        courseId: enrollment.courseId,
        enrollmentId: enrollment.id,
        completedAt: now,
      });

      await trx
        .updateTable('enrollments')
        .set({
          certificateUrl: certificate.url,
          certificateIssuedAt: now,
        })
        .where('id', '=', enrollment.id)
        .execute();
    }

    // Award badges
    await this.badgeService.checkAndAward(enrollment.userId, 'course_completion', {
      courseId: enrollment.courseId,
    });

    // Publish event
    this.eventBus.publish('course.completed', {
      userId: enrollment.userId,
      courseId: enrollment.courseId,
      enrollmentId: enrollment.id,
    });
  }

  private async checkCompletionCriteria(
    lesson: Lesson,
    progressData: any,
  ): Promise<boolean> {
    const criteria = lesson.completionCriteria || { type: 'manual' };

    switch (criteria.type) {
      case 'video':
        const watchPercent = (progressData.watchedSeconds / progressData.totalSeconds) * 100;
        return watchPercent >= (criteria.minWatchPercent || 90);

      case 'quiz':
        return (progressData.bestScore || 0) >= (criteria.minScore || 70);

      case 'scorm':
        return progressData.cmi?.completion_status === 'completed';

      case 'article':
        return progressData.scrolledToEnd === true;

      case 'manual':
        return progressData.markedComplete === true;

      default:
        return false;
    }
  }

  private mergeProgressData(
    existing: any,
    update: any,
    contentType: string,
  ): any {
    switch (contentType) {
      case 'video':
        return {
          ...existing,
          watchedSeconds: Math.max(
            existing?.watchedSeconds || 0,
            update?.watchedSeconds || 0,
          ),
          totalSeconds: update?.totalSeconds || existing?.totalSeconds,
          positions: [...(existing?.positions || []), ...(update?.positions || [])],
        };

      case 'quiz':
        return {
          ...existing,
          attempts: (existing?.attempts || 0) + 1,
          lastScore: update?.score,
          bestScore: Math.max(existing?.bestScore || 0, update?.score || 0),
        };

      case 'scorm':
        return {
          ...existing,
          cmi: update?.cmi || existing?.cmi,
        };

      default:
        return { ...existing, ...update };
    }
  }
}
```

---

## Part 4: Assessment Engine

### 4.1 Quiz Service

```typescript
// services/quiz.service.ts
export class QuizService {
  constructor(
    private readonly db: Database,
    private readonly progressService: ProgressService,
    private readonly logger: Logger,
  ) {}

  async startAttempt(
    quizId: string,
    userId: string,
    enrollmentId?: string,
  ): Promise<Result<QuizAttempt>> {
    return this.db.transaction(async (trx) => {
      const quiz = await trx
        .selectFrom('quizzes')
        .where('id', '=', quizId)
        .selectAll()
        .executeTakeFirst();

      if (!quiz) {
        return Result.failure(new NotFoundError('Quiz not found'));
      }

      // Check availability
      const now = new Date();
      if (quiz.availableFrom && now < quiz.availableFrom) {
        return Result.failure(new ValidationError('Quiz is not yet available'));
      }
      if (quiz.availableUntil && now > quiz.availableUntil) {
        return Result.failure(new ValidationError('Quiz is no longer available'));
      }

      // Check max attempts
      if (quiz.maxAttempts) {
        const attemptCount = await trx
          .selectFrom('quiz_attempts')
          .where('quiz_id', '=', quizId)
          .where('user_id', '=', userId)
          .select(sql`COUNT(*)`.as('count'))
          .executeTakeFirst();

        if (Number(attemptCount?.count) >= quiz.maxAttempts) {
          return Result.failure(new ValidationError('Maximum attempts reached'));
        }
      }

      // Get questions
      let questions = await trx
        .selectFrom('questions')
        .where('quiz_id', '=', quizId)
        .orderBy('sort_order')
        .selectAll()
        .execute();

      // Shuffle if needed
      if (quiz.shuffleQuestions) {
        questions = this.shuffle(questions);
      }

      // Shuffle options if needed
      if (quiz.shuffleOptions) {
        questions = questions.map((q) => ({
          ...q,
          options: q.options ? this.shuffle(q.options) : q.options,
        }));
      }

      // Calculate attempt number
      const [lastAttempt] = await trx
        .selectFrom('quiz_attempts')
        .where('quiz_id', '=', quizId)
        .where('user_id', '=', userId)
        .orderBy('attempt_number', 'desc')
        .limit(1)
        .select(['attempt_number'])
        .execute();

      const attemptNumber = (lastAttempt?.attempt_number || 0) + 1;

      // Calculate max score
      const maxScore = questions.reduce((sum, q) => sum + (q.points || 1), 0);

      // Create attempt
      const [attempt] = await trx
        .insertInto('quiz_attempts')
        .values({
          quizId,
          userId,
          enrollmentId,
          status: 'in_progress',
          attemptNumber,
          maxScore,
          answers: {},
        })
        .returning('*')
        .execute();

      return Result.success({
        ...attempt,
        quiz: {
          ...quiz,
          questions: questions.map(this.sanitizeQuestion),
        },
        expiresAt: quiz.timeLimitMinutes
          ? addMinutes(attempt.startedAt, quiz.timeLimitMinutes)
          : null,
      });
    });
  }

  async submitAnswer(
    attemptId: string,
    questionId: string,
    answer: any,
  ): Promise<Result<void>> {
    return this.db.transaction(async (trx) => {
      const attempt = await trx
        .selectFrom('quiz_attempts')
        .where('id', '=', attemptId)
        .forUpdate()
        .selectAll()
        .executeTakeFirst();

      if (!attempt || attempt.status !== 'in_progress') {
        return Result.failure(new ValidationError('Invalid attempt'));
      }

      // Check time limit
      const quiz = await this.getQuiz(attempt.quizId);
      if (quiz.timeLimitMinutes) {
        const expiresAt = addMinutes(attempt.startedAt, quiz.timeLimitMinutes);
        if (new Date() > expiresAt) {
          // Auto-submit
          await this.submitAttempt(attemptId);
          return Result.failure(new ValidationError('Time limit exceeded'));
        }
      }

      // Update answers
      const answers = {
        ...attempt.answers,
        [questionId]: {
          answer,
          answeredAt: new Date(),
        },
      };

      await trx
        .updateTable('quiz_attempts')
        .set({ answers })
        .where('id', '=', attemptId)
        .execute();

      return Result.success(undefined);
    });
  }

  async submitAttempt(attemptId: string): Promise<Result<QuizResult>> {
    return this.db.transaction(async (trx) => {
      const attempt = await trx
        .selectFrom('quiz_attempts')
        .where('id', '=', attemptId)
        .forUpdate()
        .selectAll()
        .executeTakeFirst();

      if (!attempt) {
        return Result.failure(new NotFoundError('Attempt not found'));
      }

      if (attempt.status !== 'in_progress') {
        return Result.failure(new ValidationError('Attempt already submitted'));
      }

      const quiz = await this.getQuiz(attempt.quizId);
      const questions = await this.getQuestions(attempt.quizId);

      // Grade answers
      let score = 0;
      const gradedAnswers: Record<string, GradedAnswer> = {};

      for (const question of questions) {
        const userAnswer = attempt.answers[question.id];
        const graded = this.gradeQuestion(question, userAnswer?.answer);
        
        score += graded.pointsEarned;
        gradedAnswers[question.id] = graded;
      }

      const scorePercent = (score / attempt.maxScore) * 100;
      const passed = scorePercent >= quiz.passingScore;

      const now = new Date();
      const timeSpent = Math.round(
        (now.getTime() - new Date(attempt.startedAt).getTime()) / 1000,
      );

      // Update attempt
      await trx
        .updateTable('quiz_attempts')
        .set({
          status: 'submitted',
          submittedAt: now,
          score,
          scorePercent,
          passed,
          timeSpentSeconds: timeSpent,
          answers: gradedAnswers,
        })
        .where('id', '=', attemptId)
        .execute();

      // Update lesson progress if linked to enrollment
      if (attempt.enrollmentId) {
        await this.progressService.updateLessonProgress(
          attempt.enrollmentId,
          quiz.lessonId!,
          {
            progressData: {
              score: scorePercent,
              passed,
              attemptId,
            },
          },
        );
      }

      return Result.success({
        attemptId,
        score,
        maxScore: attempt.maxScore,
        scorePercent,
        passed,
        timeSpentSeconds: timeSpent,
        answers: quiz.showCorrectAnswers ? gradedAnswers : undefined,
      });
    });
  }

  private gradeQuestion(question: Question, answer: any): GradedAnswer {
    const maxPoints = question.points || 1;

    if (!answer) {
      return { isCorrect: false, pointsEarned: 0, maxPoints };
    }

    switch (question.questionType) {
      case 'multiple_choice':
      case 'true_false':
        const correctOption = question.options?.find((o) => o.isCorrect);
        const isCorrect = answer === correctOption?.id;
        return {
          isCorrect,
          pointsEarned: isCorrect ? maxPoints : 0,
          maxPoints,
          correctAnswer: correctOption?.id,
          feedback: isCorrect
            ? correctOption?.feedback
            : question.explanation,
        };

      case 'multiple_answer':
        const correctIds = question.options
          ?.filter((o) => o.isCorrect)
          .map((o) => o.id) || [];
        const selectedIds = Array.isArray(answer) ? answer : [];
        
        if (question.partialCredit) {
          const correctCount = selectedIds.filter((id) => correctIds.includes(id)).length;
          const incorrectCount = selectedIds.filter((id) => !correctIds.includes(id)).length;
          const partialScore = Math.max(0, (correctCount - incorrectCount) / correctIds.length);
          
          return {
            isCorrect: partialScore === 1,
            pointsEarned: Math.round(partialScore * maxPoints * 100) / 100,
            maxPoints,
            correctAnswer: correctIds,
          };
        } else {
          const allCorrect =
            selectedIds.length === correctIds.length &&
            selectedIds.every((id) => correctIds.includes(id));
          
          return {
            isCorrect: allCorrect,
            pointsEarned: allCorrect ? maxPoints : 0,
            maxPoints,
            correctAnswer: correctIds,
          };
        }

      case 'short_answer':
        const { answers: acceptedAnswers, caseSensitive } = question.correctAnswer;
        const normalizedAnswer = caseSensitive ? answer : answer.toLowerCase();
        const matches = acceptedAnswers.some((a: string) =>
          caseSensitive ? a === normalizedAnswer : a.toLowerCase() === normalizedAnswer,
        );
        
        return {
          isCorrect: matches,
          pointsEarned: matches ? maxPoints : 0,
          maxPoints,
          correctAnswer: acceptedAnswers[0],
        };

      case 'essay':
        // Requires manual grading
        return {
          isCorrect: null,
          pointsEarned: 0,
          maxPoints,
          requiresGrading: true,
        };

      default:
        return { isCorrect: false, pointsEarned: 0, maxPoints };
    }
  }

  private sanitizeQuestion(question: Question): SanitizedQuestion {
    return {
      id: question.id,
      questionType: question.questionType,
      questionText: question.questionText,
      questionMedia: question.questionMedia,
      options: question.options?.map((o) => ({
        id: o.id,
        text: o.text,
        // Remove isCorrect and feedback
      })),
      points: question.points,
    };
  }
}
```

---

## Part 5: SCORM & xAPI Integration

### 5.1 SCORM Runtime

```typescript
// services/scorm.service.ts
export class SCORMService {
  constructor(
    private readonly db: Database,
    private readonly storageService: StorageService,
    private readonly progressService: ProgressService,
    private readonly logger: Logger,
  ) {}

  async initializeSCORM(
    lessonId: string,
    enrollmentId: string,
  ): Promise<SCORMInitData> {
    const lesson = await this.getLesson(lessonId);
    const progress = await this.getOrCreateProgress(enrollmentId, lessonId);

    // Get existing CMI data or initialize
    const cmi = progress.progressData?.cmi || this.getDefaultCMI();

    return {
      lessonId,
      enrollmentId,
      packageUrl: lesson.contentData.packageUrl,
      version: lesson.contentData.version || '1.2',
      cmi,
    };
  }

  async setCMIValue(
    enrollmentId: string,
    lessonId: string,
    element: string,
    value: string,
  ): Promise<Result<void>> {
    const progress = await this.db
      .selectFrom('lesson_progress')
      .where('enrollment_id', '=', enrollmentId)
      .where('lesson_id', '=', lessonId)
      .selectAll()
      .executeTakeFirst();

    if (!progress) {
      return Result.failure(new NotFoundError('Progress not found'));
    }

    const cmi = progress.progressData?.cmi || {};

    // Set nested value
    this.setNestedValue(cmi, element, value);

    await this.db
      .updateTable('lesson_progress')
      .set({
        progressData: { ...progress.progressData, cmi },
        lastAccessedAt: new Date(),
      })
      .where('id', '=', progress.id)
      .execute();

    // Check for completion
    if (element === 'cmi.core.lesson_status') {
      const isCompleted = ['completed', 'passed'].includes(value);
      if (isCompleted) {
        await this.progressService.updateLessonProgress(enrollmentId, lessonId, {
          progressData: { cmi },
        });
      }
    }

    return Result.success(undefined);
  }

  async getCMIValue(
    enrollmentId: string,
    lessonId: string,
    element: string,
  ): Promise<string> {
    const progress = await this.db
      .selectFrom('lesson_progress')
      .where('enrollment_id', '=', enrollmentId)
      .where('lesson_id', '=', lessonId)
      .selectAll()
      .executeTakeFirst();

    if (!progress?.progressData?.cmi) {
      return '';
    }

    return this.getNestedValue(progress.progressData.cmi, element) || '';
  }

  async commitSCORM(
    enrollmentId: string,
    lessonId: string,
  ): Promise<Result<void>> {
    // Already saved on each set, but can trigger additional processing
    this.logger.info('SCORM data committed', { enrollmentId, lessonId });
    return Result.success(undefined);
  }

  private getDefaultCMI(): SCORMCMI {
    return {
      core: {
        student_id: '',
        student_name: '',
        lesson_location: '',
        credit: 'credit',
        lesson_status: 'not attempted',
        entry: 'ab-initio',
        score: {
          raw: '',
          min: '',
          max: '',
        },
        total_time: '0000:00:00',
        lesson_mode: 'normal',
        exit: '',
        session_time: '0000:00:00',
      },
      suspend_data: '',
      launch_data: '',
      comments: '',
    };
  }

  private setNestedValue(obj: any, path: string, value: string): void {
    const parts = path.replace('cmi.', '').split('.');
    let current = obj;

    for (let i = 0; i < parts.length - 1; i++) {
      const part = parts[i];
      if (!current[part]) {
        current[part] = {};
      }
      current = current[part];
    }

    current[parts[parts.length - 1]] = value;
  }
}

// xAPI (TinCan) Service
export class XAPIService {
  private readonly lrsEndpoint: string;
  private readonly lrsAuth: string;

  constructor(
    private readonly config: XAPIConfig,
    private readonly logger: Logger,
  ) {
    this.lrsEndpoint = config.lrsEndpoint;
    this.lrsAuth = config.lrsAuth;
  }

  async sendStatement(statement: XAPIStatement): Promise<Result<void>> {
    try {
      const response = await fetch(`${this.lrsEndpoint}/statements`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          Authorization: `Basic ${this.lrsAuth}`,
          'X-Experience-API-Version': '1.0.3',
        },
        body: JSON.stringify(statement),
      });

      if (!response.ok) {
        throw new Error(`LRS returned ${response.status}`);
      }

      return Result.success(undefined);
    } catch (error) {
      this.logger.error('Failed to send xAPI statement', { error });
      return Result.failure(new IntegrationError('Failed to send to LRS'));
    }
  }

  buildStatement({
    actor,
    verb,
    object,
    result,
    context,
  }: XAPIStatementParams): XAPIStatement {
    return {
      id: crypto.randomUUID(),
      timestamp: new Date().toISOString(),
      actor: {
        objectType: 'Agent',
        mbox: `mailto:${actor.email}`,
        name: actor.name,
      },
      verb: {
        id: `http://adlnet.gov/expapi/verbs/${verb}`,
        display: { 'en-US': verb },
      },
      object: {
        objectType: 'Activity',
        id: object.id,
        definition: {
          type: object.type,
          name: { 'en-US': object.name },
          description: object.description
            ? { 'en-US': object.description }
            : undefined,
        },
      },
      result: result
        ? {
            score: result.score,
            success: result.success,
            completion: result.completion,
            duration: result.duration,
          }
        : undefined,
      context: context
        ? {
            registration: context.registrationId,
            contextActivities: {
              parent: context.parentId
                ? [{ id: context.parentId, objectType: 'Activity' }]
                : undefined,
            },
          }
        : undefined,
    };
  }
}
```

---

## Part 6: Best Practices

### ✅ Content Design

- ✅ Chunk videos under 10 minutes
- ✅ Include interactive elements every 2-3 minutes
- ✅ Provide multiple content formats (video, text, audio)
- ✅ Use progressive disclosure for complex topics
- ✅ Add knowledge checks after each concept

### ✅ Progress Tracking

- ✅ Save progress automatically and frequently
- ✅ Allow resume from last position
- ✅ Show clear progress indicators
- ✅ Track time spent for analytics
- ✅ Support offline progress sync

### ✅ Assessments

- ✅ Randomize questions and options
- ✅ Provide immediate feedback
- ✅ Allow multiple attempts with learning
- ✅ Use varied question types
- ✅ Include formative (practice) and summative (graded) assessments

### ✅ Engagement

- ✅ Implement gamification (badges, points, leaderboards)
- ✅ Send progress notifications
- ✅ Create learning paths with prerequisites
- ✅ Enable peer discussions
- ✅ Issue certificates upon completion

### ❌ Avoid

- ❌ Don't create passive, lecture-only content
- ❌ Don't skip accessibility (captions, transcripts)
- ❌ Don't make navigation confusing
- ❌ Don't require linear progression for all content
- ❌ Don't ignore mobile learners

---

## Related Skills

- `@instructional-designer` - Curriculum design
- `@senior-course-creator` - Course creation
- `@video-editor-automation` - Video processing
- `@gamification-specialist` - Engagement systems

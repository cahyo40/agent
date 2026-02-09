---
name: e-learning-developer
description: "Expert e-learning development including LMS, SCORM/xAPI, interactive courses, video streaming, gamification, and online learning platforms"
---

# E-Learning Developer

## Overview

This skill transforms you into an **Expert E-Learning Developer** with extensive experience building comprehensive Learning Management Systems. You will master **LMS Architecture**, **SCORM/xAPI Integration**, **Video Streaming**, **Interactive Assessments**, **Gamification**, and **Learning Analytics** for building production-ready online learning platforms.

## When to Use This Skill

- Use when building Learning Management Systems (LMS)
- Use when creating course platforms (Udemy-style, Coursera-style)
- Use when implementing SCORM/xAPI packages
- Use when building quiz/assessment systems
- Use when tracking learner progress
- Use when implementing gamification (badges, leaderboards)
- Use when integrating video streaming

---

## Part 1: E-Learning Architecture

### 1.1 System Components

```
┌─────────────────────────────────────────────────────────────────────────┐
│                    Learning Management System                            │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                          │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐  ┌─────────────────┐ │
│  │   Course    │  │   Lesson    │  │    Quiz     │  │    Progress     │ │
│  │  Management │  │   Content   │  │  Assessment │  │    Tracking     │ │
│  └─────────────┘  └─────────────┘  └─────────────┘  └─────────────────┘ │
│                                                                          │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐  ┌─────────────────┐ │
│  │   Video     │  │   SCORM/    │  │ Gamification│  │   Certificate   │ │
│  │  Streaming  │  │    xAPI     │  │   Engine    │  │   Generation    │ │
│  └─────────────┘  └─────────────┘  └─────────────┘  └─────────────────┘ │
│                                                                          │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐                      │
│  │  Discussion │  │  Analytics  │  │   Payment   │                      │
│  │   Forums    │  │  Dashboard  │  │  & Pricing  │                      │
│  └─────────────┘  └─────────────┘  └─────────────┘                      │
│                                                                          │
└─────────────────────────────────────────────────────────────────────────┘
```

### 1.2 Key Terminology

| Term | Description |
|------|-------------|
| **Course** | Collection of modules/lessons |
| **Module** | Group of related lessons |
| **Lesson** | Single learning unit (video, text, quiz) |
| **SCORM** | Sharable Content Object Reference Model |
| **xAPI** | Experience API (Tin Can API) |
| **LRS** | Learning Record Store |
| **Drip Content** | Time-released lessons |
| **Prerequisite** | Required completion before unlock |
| **Learning Path** | Ordered sequence of courses |

---

## Part 2: Database Schema

### 2.1 Core Tables

```sql
-- Courses
CREATE TABLE courses (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    instructor_id UUID REFERENCES users(id),
    title VARCHAR(255) NOT NULL,
    slug VARCHAR(255) UNIQUE NOT NULL,
    description TEXT,
    short_description VARCHAR(500),
    thumbnail_url TEXT,
    promo_video_url TEXT,
    
    -- Pricing
    price DECIMAL(10, 2) DEFAULT 0,
    sale_price DECIMAL(10, 2),
    currency VARCHAR(3) DEFAULT 'IDR',
    is_free BOOLEAN DEFAULT false,
    
    -- Details
    level VARCHAR(20),  -- 'beginner', 'intermediate', 'advanced', 'all'
    language VARCHAR(10) DEFAULT 'id',
    duration_hours DECIMAL(5, 2),
    
    -- Requirements
    prerequisites TEXT[],
    target_audience TEXT[],
    learning_outcomes TEXT[],
    
    -- Status
    status VARCHAR(20) DEFAULT 'draft',  -- 'draft', 'review', 'published', 'archived'
    published_at TIMESTAMPTZ,
    
    -- Settings
    certificate_enabled BOOLEAN DEFAULT true,
    completion_threshold INTEGER DEFAULT 100,  -- % required for completion
    
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Modules (sections of a course)
CREATE TABLE modules (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    course_id UUID REFERENCES courses(id) ON DELETE CASCADE,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    position INTEGER NOT NULL,
    unlock_after_module_id UUID REFERENCES modules(id),  -- Prerequisite
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Lessons
CREATE TABLE lessons (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    module_id UUID REFERENCES modules(id) ON DELETE CASCADE,
    title VARCHAR(255) NOT NULL,
    type VARCHAR(20) NOT NULL,  -- 'video', 'text', 'quiz', 'assignment', 'scorm', 'interactive'
    
    -- Content
    content TEXT,                    -- For text lessons
    video_id UUID REFERENCES videos(id),
    scorm_package_id UUID REFERENCES scorm_packages(id),
    
    -- Settings
    is_free_preview BOOLEAN DEFAULT FALSE,
    position INTEGER NOT NULL,
    duration_minutes INTEGER,
    
    -- Drip content
    drip_type VARCHAR(20),           -- 'days', 'date', 'after_lesson'
    drip_value INTEGER,              -- Days after enrollment
    drip_date DATE,                  -- Specific date
    drip_after_lesson_id UUID REFERENCES lessons(id),
    
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_lessons_module ON lessons(module_id, position);

-- Enrollments
CREATE TABLE enrollments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id),
    course_id UUID REFERENCES courses(id),
    
    -- Progress
    progress_percent DECIMAL(5, 2) DEFAULT 0,
    last_lesson_id UUID REFERENCES lessons(id),
    last_accessed_at TIMESTAMPTZ,
    
    -- Completion
    completed BOOLEAN DEFAULT false,
    completed_at TIMESTAMPTZ,
    certificate_id UUID REFERENCES certificates(id),
    
    -- Enrollment details
    enrolled_at TIMESTAMPTZ DEFAULT NOW(),
    expires_at TIMESTAMPTZ,            -- For subscription-based access
    
    -- Payment
    payment_id UUID REFERENCES payments(id),
    price_paid DECIMAL(10, 2),
    
    UNIQUE(user_id, course_id)
);

CREATE INDEX idx_enrollments_user ON enrollments(user_id);
CREATE INDEX idx_enrollments_course ON enrollments(course_id);

-- Lesson Progress
CREATE TABLE lesson_progress (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    enrollment_id UUID REFERENCES enrollments(id) ON DELETE CASCADE,
    lesson_id UUID REFERENCES lessons(id) ON DELETE CASCADE,
    
    -- Progress
    status VARCHAR(20) DEFAULT 'not_started',  -- 'not_started', 'in_progress', 'completed'
    progress_percent DECIMAL(5, 2) DEFAULT 0,
    
    -- Video progress
    video_position_seconds INTEGER DEFAULT 0,
    video_watched_percent DECIMAL(5, 2) DEFAULT 0,
    
    -- SCORM progress
    scorm_status VARCHAR(50),
    scorm_score DECIMAL(5, 2),
    scorm_data JSONB,
    
    -- Timestamps
    started_at TIMESTAMPTZ,
    completed_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    
    UNIQUE(enrollment_id, lesson_id)
);
```

### 2.2 Quiz & Assessment Tables

```sql
-- Quizzes
CREATE TABLE quizzes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    lesson_id UUID REFERENCES lessons(id) ON DELETE CASCADE,
    title VARCHAR(255),
    description TEXT,
    
    -- Settings
    passing_score INTEGER DEFAULT 70,
    max_attempts INTEGER,                -- NULL = unlimited
    time_limit_minutes INTEGER,
    shuffle_questions BOOLEAN DEFAULT false,
    shuffle_answers BOOLEAN DEFAULT false,
    show_correct_answers BOOLEAN DEFAULT true,
    show_answers_after VARCHAR(20) DEFAULT 'submission',  -- 'submission', 'deadline', 'manual'
    
    -- Required for progress
    required_for_completion BOOLEAN DEFAULT true,
    
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Quiz Questions
CREATE TABLE quiz_questions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    quiz_id UUID REFERENCES quizzes(id) ON DELETE CASCADE,
    type VARCHAR(30) NOT NULL,  -- 'multiple_choice', 'multiple_select', 'true_false', 
                                 -- 'short_answer', 'essay', 'matching', 'ordering', 'fill_blank'
    question TEXT NOT NULL,
    question_media_url TEXT,
    
    -- For choice-based questions
    options JSONB,              -- [{id, text, image_url}]
    correct_answer JSONB,       -- For auto-grading
    
    -- For matching/ordering
    matching_pairs JSONB,       -- [{left, right}]
    correct_order TEXT[],       -- For ordering questions
    
    -- Scoring
    points INTEGER DEFAULT 1,
    partial_credit BOOLEAN DEFAULT false,
    
    explanation TEXT,           -- Shown after answer
    hint TEXT,
    
    position INTEGER NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Quiz Attempts
CREATE TABLE quiz_attempts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    enrollment_id UUID REFERENCES enrollments(id),
    quiz_id UUID REFERENCES quizzes(id),
    
    -- Timing
    started_at TIMESTAMPTZ DEFAULT NOW(),
    submitted_at TIMESTAMPTZ,
    time_spent_seconds INTEGER,
    
    -- Answers
    answers JSONB NOT NULL,     -- { questionId: { answer, isCorrect, pointsEarned } }
    
    -- Results
    total_points INTEGER,
    earned_points INTEGER,
    score_percent DECIMAL(5, 2),
    passed BOOLEAN,
    
    -- Status
    status VARCHAR(20) DEFAULT 'in_progress',  -- 'in_progress', 'submitted', 'graded'
    graded_by UUID REFERENCES users(id),
    graded_at TIMESTAMPTZ,
    
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_quiz_attempts_enrollment ON quiz_attempts(enrollment_id);
```

### 2.3 Video & Streaming Tables

```sql
-- Videos (with multiple quality levels)
CREATE TABLE videos (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title VARCHAR(255),
    duration_seconds INTEGER,
    
    -- Source
    source_type VARCHAR(20) NOT NULL,  -- 'upload', 'youtube', 'vimeo', 'cloudflare', 'bunny'
    source_id VARCHAR(255),            -- External video ID
    
    -- URLs for different qualities
    url_360p TEXT,
    url_480p TEXT,
    url_720p TEXT,
    url_1080p TEXT,
    url_hls TEXT,                      -- HLS manifest URL
    
    -- Poster
    thumbnail_url TEXT,
    poster_url TEXT,
    
    -- Processing
    status VARCHAR(20) DEFAULT 'processing',  -- 'processing', 'ready', 'failed'
    processed_at TIMESTAMPTZ,
    
    -- Captions
    captions JSONB,                    -- [{language, url, label}]
    
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Video Watch History (for resume playback)
CREATE TABLE video_watch_history (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id),
    video_id UUID REFERENCES videos(id),
    lesson_id UUID REFERENCES lessons(id),
    
    position_seconds INTEGER DEFAULT 0,
    watched_seconds INTEGER DEFAULT 0,     -- Total time spent watching
    completed BOOLEAN DEFAULT false,
    
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    
    UNIQUE(user_id, lesson_id)
);
```

### 2.4 Gamification Tables

```sql
-- Badges
CREATE TABLE badges (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(100) NOT NULL,
    description TEXT,
    icon_url TEXT NOT NULL,
    
    -- Trigger
    trigger_type VARCHAR(50) NOT NULL,
    -- 'course_complete', 'streak_days', 'quiz_score', 'lessons_count', 'first_enrollment', etc.
    trigger_value JSONB,                -- { courseId, days, score, count, etc. }
    
    -- Rarity
    rarity VARCHAR(20) DEFAULT 'common',  -- 'common', 'uncommon', 'rare', 'epic', 'legendary'
    points INTEGER DEFAULT 10,
    
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- User Badges
CREATE TABLE user_badges (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id),
    badge_id UUID REFERENCES badges(id),
    earned_at TIMESTAMPTZ DEFAULT NOW(),
    
    UNIQUE(user_id, badge_id)
);

-- Leaderboard (materialized for performance)
CREATE MATERIALIZED VIEW leaderboard AS
SELECT 
    u.id as user_id,
    u.name,
    u.avatar_url,
    COUNT(DISTINCT e.id) FILTER (WHERE e.completed) as courses_completed,
    COALESCE(SUM(b.points), 0) as total_points,
    COUNT(DISTINCT ub.badge_id) as badges_count,
    COALESCE(AVG(qa.score_percent) FILTER (WHERE qa.passed), 0) as avg_quiz_score
FROM users u
LEFT JOIN enrollments e ON u.id = e.user_id
LEFT JOIN user_badges ub ON u.id = ub.user_id
LEFT JOIN badges b ON ub.badge_id = b.id
LEFT JOIN quiz_attempts qa ON e.id = qa.enrollment_id
GROUP BY u.id, u.name, u.avatar_url;

-- Learning Streaks
CREATE TABLE learning_streaks (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id) UNIQUE,
    current_streak INTEGER DEFAULT 0,
    longest_streak INTEGER DEFAULT 0,
    last_activity_date DATE,
    streak_freeze_used BOOLEAN DEFAULT false,
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Daily Goals
CREATE TABLE daily_goals (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id),
    date DATE NOT NULL,
    goal_minutes INTEGER DEFAULT 30,
    completed_minutes INTEGER DEFAULT 0,
    lessons_completed INTEGER DEFAULT 0,
    goal_met BOOLEAN DEFAULT false,
    
    UNIQUE(user_id, date)
);

-- XP Transactions (for points history)
CREATE TABLE xp_transactions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id),
    amount INTEGER NOT NULL,
    source VARCHAR(50) NOT NULL,       -- 'lesson_complete', 'quiz_pass', 'streak', 'badge'
    reference_id UUID,                  -- lesson_id, quiz_id, badge_id
    description TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);
```

---

## Part 3: SCORM Integration

### 3.1 SCORM Package Management

```typescript
// services/scorm.service.ts
import AdmZip from 'adm-zip';
import { parseStringPromise } from 'xml2js';

interface ScormManifest {
  version: '1.2' | '2004';
  title: string;
  launchUrl: string;
  organizationId: string;
  items: ScormItem[];
}

export class ScormService {
  private readonly storageService: StorageService;
  
  async uploadPackage(file: Buffer, fileName: string): Promise<ScormPackage> {
    // Extract ZIP
    const zip = new AdmZip(file);
    
    // Find and parse imsmanifest.xml
    const manifestEntry = zip.getEntry('imsmanifest.xml');
    if (!manifestEntry) {
      throw new Error('Invalid SCORM package: missing imsmanifest.xml');
    }
    
    const manifestXml = manifestEntry.getData().toString('utf8');
    const manifest = await this.parseManifest(manifestXml);
    
    // Upload to storage
    const packageId = generateId();
    const uploadPath = `scorm/${packageId}`;
    
    for (const entry of zip.getEntries()) {
      if (!entry.isDirectory) {
        await this.storageService.upload(
          `${uploadPath}/${entry.entryName}`,
          entry.getData()
        );
      }
    }
    
    // Create database record
    return db.scormPackages.create({
      data: {
        id: packageId,
        title: manifest.title,
        version: manifest.version,
        launchUrl: `${uploadPath}/${manifest.launchUrl}`,
        manifestData: manifest,
        status: 'ready',
      },
    });
  }
  
  private async parseManifest(xml: string): Promise<ScormManifest> {
    const parsed = await parseStringPromise(xml);
    const manifest = parsed.manifest;
    
    // Detect SCORM version
    const schemaVersion = manifest.metadata?.[0]?.schemaversion?.[0];
    const version = schemaVersion?.includes('2004') ? '2004' : '1.2';
    
    // Get launch URL
    const resources = manifest.resources?.[0]?.resource || [];
    const launchResource = resources.find((r: any) => 
      r.$.type === 'webcontent' && r.$.['adlcp:scormtype'] === 'sco'
    );
    
    return {
      version,
      title: manifest.organizations?.[0]?.organization?.[0]?.title?.[0] || 'Untitled',
      launchUrl: launchResource?.$?.href || 'index.html',
      organizationId: manifest.organizations?.[0]?.$?.default,
      items: this.parseItems(manifest.organizations?.[0]?.organization?.[0]?.item || []),
    };
  }
}
```

### 3.2 SCORM Runtime API

```typescript
// SCORM 1.2 API Adapter
class ScormApiAdapter {
  private data: Record<string, string> = {};
  private enrollmentId: string;
  
  constructor(enrollmentId: string, initialData?: Record<string, string>) {
    this.enrollmentId = enrollmentId;
    this.data = initialData || {};
  }
  
  // SCORM 1.2 API Methods
  LMSInitialize(param: string): string {
    console.log('SCORM: LMSInitialize');
    return 'true';
  }
  
  LMSFinish(param: string): string {
    console.log('SCORM: LMSFinish');
    this.saveProgress();
    return 'true';
  }
  
  LMSGetValue(element: string): string {
    console.log(`SCORM: LMSGetValue(${element})`);
    return this.data[element] || '';
  }
  
  LMSSetValue(element: string, value: string): string {
    console.log(`SCORM: LMSSetValue(${element}, ${value})`);
    this.data[element] = value;
    
    // Track important values
    if (element === 'cmi.core.lesson_status') {
      this.updateLessonStatus(value);
    }
    if (element === 'cmi.core.score.raw') {
      this.updateScore(parseFloat(value));
    }
    
    return 'true';
  }
  
  LMSCommit(param: string): string {
    console.log('SCORM: LMSCommit');
    this.saveProgress();
    return 'true';
  }
  
  LMSGetLastError(): string { return '0'; }
  LMSGetErrorString(errorCode: string): string { return ''; }
  LMSGetDiagnostic(errorCode: string): string { return ''; }
  
  private async saveProgress(): Promise<void> {
    await fetch('/api/scorm/progress', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        enrollmentId: this.enrollmentId,
        data: this.data,
        status: this.data['cmi.core.lesson_status'],
        score: this.data['cmi.core.score.raw'],
        location: this.data['cmi.core.lesson_location'],
      }),
    });
  }
}

// Inject API into SCORM iframe
function initScormPlayer(enrollmentId: string, lessonId: string) {
  const iframe = document.getElementById('scorm-player') as HTMLIFrameElement;
  
  iframe.onload = async () => {
    // Load saved progress
    const response = await fetch(`/api/scorm/progress/${enrollmentId}/${lessonId}`);
    const savedData = await response.json();
    
    // Create API adapter and inject
    const api = new ScormApiAdapter(enrollmentId, savedData.data);
    
    // SCORM 1.2 expects window.API
    (iframe.contentWindow as any).API = api;
    
    // SCORM 2004 expects window.API_1484_11
    (iframe.contentWindow as any).API_1484_11 = api;
  };
}
```

### 3.3 xAPI (Experience API) Integration

```typescript
// xAPI Statement Sender
interface XapiStatement {
  actor: {
    mbox: string;
    name: string;
  };
  verb: {
    id: string;
    display: { 'en-US': string };
  };
  object: {
    id: string;
    definition: {
      name: { 'en-US': string };
      type: string;
    };
  };
  result?: {
    score?: { raw: number; min: number; max: number };
    completion?: boolean;
    success?: boolean;
    duration?: string;
  };
  context?: {
    registration: string;
    contextActivities?: {
      parent?: { id: string }[];
      grouping?: { id: string }[];
    };
  };
}

class XapiService {
  private readonly lrsEndpoint: string;
  private readonly lrsAuth: string;
  
  async sendStatement(statement: XapiStatement): Promise<void> {
    await fetch(`${this.lrsEndpoint}/statements`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Basic ${this.lrsAuth}`,
        'X-Experience-API-Version': '1.0.3',
      },
      body: JSON.stringify(statement),
    });
  }
  
  // Pre-built statements
  async trackVideoWatched(userId: string, videoId: string, duration: number): Promise<void> {
    await this.sendStatement({
      actor: { mbox: `mailto:user${userId}@lms.local`, name: `User ${userId}` },
      verb: { id: 'http://adlnet.gov/expapi/verbs/experienced', display: { 'en-US': 'experienced' } },
      object: {
        id: `https://lms.local/videos/${videoId}`,
        definition: {
          name: { 'en-US': 'Video Content' },
          type: 'http://adlnet.gov/expapi/activities/media',
        },
      },
      result: { duration: `PT${duration}S` },
    });
  }
  
  async trackQuizCompleted(
    userId: string, 
    quizId: string, 
    score: number, 
    passed: boolean
  ): Promise<void> {
    await this.sendStatement({
      actor: { mbox: `mailto:user${userId}@lms.local`, name: `User ${userId}` },
      verb: { 
        id: passed ? 'http://adlnet.gov/expapi/verbs/passed' : 'http://adlnet.gov/expapi/verbs/failed',
        display: { 'en-US': passed ? 'passed' : 'failed' },
      },
      object: {
        id: `https://lms.local/quizzes/${quizId}`,
        definition: {
          name: { 'en-US': 'Quiz Assessment' },
          type: 'http://adlnet.gov/expapi/activities/assessment',
        },
      },
      result: {
        score: { raw: score, min: 0, max: 100 },
        success: passed,
        completion: true,
      },
    });
  }
}
```

---

## Part 4: Video Streaming

### 4.1 Video Processing Pipeline

```typescript
// services/video-processing.service.ts
import ffmpeg from 'fluent-ffmpeg';
import { S3Client, PutObjectCommand } from '@aws-sdk/client-s3';

interface TranscodeJob {
  videoId: string;
  inputPath: string;
  outputPath: string;
  qualities: VideoQuality[];
}

interface VideoQuality {
  name: string;
  width: number;
  height: number;
  bitrate: string;
}

class VideoProcessingService {
  private readonly qualities: VideoQuality[] = [
    { name: '360p', width: 640, height: 360, bitrate: '800k' },
    { name: '480p', width: 854, height: 480, bitrate: '1400k' },
    { name: '720p', width: 1280, height: 720, bitrate: '2800k' },
    { name: '1080p', width: 1920, height: 1080, bitrate: '5000k' },
  ];
  
  async processVideo(videoId: string, inputPath: string): Promise<void> {
    const outputDir = `/tmp/videos/${videoId}`;
    
    // Generate thumbnail
    await this.generateThumbnail(inputPath, `${outputDir}/thumbnail.jpg`);
    
    // Transcode to multiple qualities
    for (const quality of this.qualities) {
      await this.transcode(inputPath, `${outputDir}/${quality.name}.mp4`, quality);
    }
    
    // Generate HLS playlist
    await this.generateHLS(videoId, outputDir);
    
    // Upload to CDN
    await this.uploadToS3(videoId, outputDir);
    
    // Update database
    await db.videos.update({
      where: { id: videoId },
      data: {
        status: 'ready',
        url360p: `https://cdn.lms.com/videos/${videoId}/360p.mp4`,
        url480p: `https://cdn.lms.com/videos/${videoId}/480p.mp4`,
        url720p: `https://cdn.lms.com/videos/${videoId}/720p.mp4`,
        url1080p: `https://cdn.lms.com/videos/${videoId}/1080p.mp4`,
        urlHls: `https://cdn.lms.com/videos/${videoId}/master.m3u8`,
        thumbnailUrl: `https://cdn.lms.com/videos/${videoId}/thumbnail.jpg`,
        processedAt: new Date(),
      },
    });
  }
  
  private transcode(input: string, output: string, quality: VideoQuality): Promise<void> {
    return new Promise((resolve, reject) => {
      ffmpeg(input)
        .outputOptions([
          `-vf scale=${quality.width}:${quality.height}`,
          `-b:v ${quality.bitrate}`,
          '-c:v libx264',
          '-preset fast',
          '-c:a aac',
          '-b:a 128k',
        ])
        .output(output)
        .on('end', resolve)
        .on('error', reject)
        .run();
    });
  }
  
  private async generateHLS(videoId: string, outputDir: string): Promise<void> {
    // Generate HLS variants for each quality
    const variants: string[] = [];
    
    for (const quality of this.qualities) {
      const inputFile = `${outputDir}/${quality.name}.mp4`;
      const outputFile = `${outputDir}/${quality.name}.m3u8`;
      
      await new Promise((resolve, reject) => {
        ffmpeg(inputFile)
          .outputOptions([
            '-codec copy',
            '-start_number 0',
            '-hls_time 10',
            '-hls_list_size 0',
            '-f hls',
          ])
          .output(outputFile)
          .on('end', resolve)
          .on('error', reject)
          .run();
      });
      
      variants.push(`#EXT-X-STREAM-INF:BANDWIDTH=${parseInt(quality.bitrate) * 1000},RESOLUTION=${quality.width}x${quality.height}\n${quality.name}.m3u8`);
    }
    
    // Generate master playlist
    const masterPlaylist = [
      '#EXTM3U',
      '#EXT-X-VERSION:3',
      ...variants,
    ].join('\n');
    
    await fs.writeFile(`${outputDir}/master.m3u8`, masterPlaylist);
  }
}
```

### 4.2 Video Player Component

```typescript
// React video player with progress tracking
import { useRef, useState, useCallback } from 'react';

interface VideoPlayerProps {
  videoId: string;
  lessonId: string;
  hlsUrl: string;
  startPosition?: number;
  onProgress?: (position: number, percent: number) => void;
  onComplete?: () => void;
}

export function VideoPlayer({
  videoId,
  lessonId,
  hlsUrl,
  startPosition = 0,
  onProgress,
  onComplete,
}: VideoPlayerProps) {
  const videoRef = useRef<HTMLVideoElement>(null);
  const [currentQuality, setCurrentQuality] = useState('auto');
  const [playbackRate, setPlaybackRate] = useState(1);
  const [watchedSegments, setWatchedSegments] = useState<Set<number>>(new Set());
  
  const COMPLETION_THRESHOLD = 90; // 90% watched = complete
  const SEGMENT_SIZE = 10; // 10 second segments
  
  const handleTimeUpdate = useCallback(() => {
    const video = videoRef.current;
    if (!video) return;
    
    const currentTime = Math.floor(video.currentTime);
    const duration = video.duration;
    const percent = (currentTime / duration) * 100;
    
    // Track watched segments
    const segment = Math.floor(currentTime / SEGMENT_SIZE);
    setWatchedSegments(prev => new Set([...prev, segment]));
    
    // Calculate actual watch percentage (not just current position)
    const totalSegments = Math.ceil(duration / SEGMENT_SIZE);
    const watchedPercent = (watchedSegments.size / totalSegments) * 100;
    
    // Save progress every 5 seconds
    if (currentTime % 5 === 0) {
      saveProgress(currentTime, watchedPercent);
    }
    
    onProgress?.(currentTime, watchedPercent);
    
    // Mark complete if threshold reached
    if (watchedPercent >= COMPLETION_THRESHOLD) {
      onComplete?.();
    }
  }, [watchedSegments, onProgress, onComplete]);
  
  const saveProgress = async (position: number, percent: number) => {
    await fetch('/api/videos/progress', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        videoId,
        lessonId,
        positionSeconds: position,
        watchedPercent: percent,
      }),
    });
  };
  
  return (
    <div className="video-player">
      <video
        ref={videoRef}
        src={hlsUrl}
        onTimeUpdate={handleTimeUpdate}
        onLoadedMetadata={() => {
          if (startPosition > 0 && videoRef.current) {
            videoRef.current.currentTime = startPosition;
          }
        }}
        controls
      />
      
      {/* Quality selector */}
      <select 
        value={currentQuality}
        onChange={(e) => setCurrentQuality(e.target.value)}
      >
        <option value="auto">Auto</option>
        <option value="1080p">1080p</option>
        <option value="720p">720p</option>
        <option value="480p">480p</option>
        <option value="360p">360p</option>
      </select>
      
      {/* Playback speed */}
      <select 
        value={playbackRate}
        onChange={(e) => {
          const rate = parseFloat(e.target.value);
          setPlaybackRate(rate);
          if (videoRef.current) videoRef.current.playbackRate = rate;
        }}
      >
        <option value="0.5">0.5x</option>
        <option value="0.75">0.75x</option>
        <option value="1">1x</option>
        <option value="1.25">1.25x</option>
        <option value="1.5">1.5x</option>
        <option value="2">2x</option>
      </select>
    </div>
  );
}
```

---

## Part 5: Gamification Engine

### 5.1 XP and Badge System

```typescript
// services/gamification.service.ts
interface XpReward {
  action: string;
  points: number;
  description: string;
}

const XP_REWARDS: XpReward[] = [
  { action: 'lesson_complete', points: 10, description: 'Menyelesaikan lesson' },
  { action: 'quiz_pass', points: 25, description: 'Lulus quiz' },
  { action: 'course_complete', points: 100, description: 'Menyelesaikan course' },
  { action: 'streak_7', points: 50, description: 'Streak 7 hari' },
  { action: 'streak_30', points: 200, description: 'Streak 30 hari' },
  { action: 'first_quiz_perfect', points: 50, description: 'Perfect score pertama' },
];

export class GamificationService {
  async awardXp(userId: string, action: string, referenceId?: string): Promise<void> {
    const reward = XP_REWARDS.find(r => r.action === action);
    if (!reward) return;
    
    // Record XP transaction
    await db.xpTransactions.create({
      data: {
        userId,
        amount: reward.points,
        source: action,
        referenceId,
        description: reward.description,
      },
    });
    
    // Update user total XP
    await db.users.update({
      where: { id: userId },
      data: { totalXp: { increment: reward.points } },
    });
    
    // Check for level up
    await this.checkLevelUp(userId);
    
    // Check for badges
    await this.checkBadges(userId, action, referenceId);
  }
  
  async updateStreak(userId: string): Promise<number> {
    const today = new Date().toISOString().split('T')[0];
    
    const streak = await db.learningStreaks.findUnique({
      where: { userId },
    });
    
    if (!streak) {
      // First activity
      await db.learningStreaks.create({
        data: {
          userId,
          currentStreak: 1,
          longestStreak: 1,
          lastActivityDate: today,
        },
      });
      return 1;
    }
    
    const lastDate = streak.lastActivityDate;
    const yesterday = new Date();
    yesterday.setDate(yesterday.getDate() - 1);
    const yesterdayStr = yesterday.toISOString().split('T')[0];
    
    let newStreak = streak.currentStreak;
    
    if (lastDate === today) {
      // Already recorded today
      return newStreak;
    } else if (lastDate === yesterdayStr) {
      // Consecutive day!
      newStreak += 1;
    } else if (streak.streakFreezeUsed) {
      // Used streak freeze
      newStreak += 1;
      await db.learningStreaks.update({
        where: { userId },
        data: { streakFreezeUsed: false },
      });
    } else {
      // Streak broken
      newStreak = 1;
    }
    
    await db.learningStreaks.update({
      where: { userId },
      data: {
        currentStreak: newStreak,
        longestStreak: Math.max(streak.longestStreak, newStreak),
        lastActivityDate: today,
      },
    });
    
    // Award streak badges
    if (newStreak === 7) await this.awardXp(userId, 'streak_7');
    if (newStreak === 30) await this.awardXp(userId, 'streak_30');
    
    return newStreak;
  }
  
  async checkBadges(userId: string, action: string, referenceId?: string): Promise<void> {
    const badges = await db.badges.findMany({
      where: {
        isActive: true,
        triggerType: action,
      },
    });
    
    for (const badge of badges) {
      const alreadyHas = await db.userBadges.findFirst({
        where: { userId, badgeId: badge.id },
      });
      
      if (alreadyHas) continue;
      
      const earned = await this.evaluateBadgeCondition(userId, badge);
      
      if (earned) {
        await db.userBadges.create({
          data: { userId, badgeId: badge.id },
        });
        
        // Award badge points
        await this.awardXp(userId, 'badge_earned', badge.id);
        
        // Send notification
        await this.sendBadgeNotification(userId, badge);
      }
    }
  }
  
  async getLeaderboard(period: 'weekly' | 'monthly' | 'alltime'): Promise<LeaderboardEntry[]> {
    const startDate = this.getPeriodStartDate(period);
    
    const leaderboard = await db.$queryRaw`
      SELECT 
        u.id,
        u.name,
        u.avatar_url,
        COALESCE(SUM(x.amount), 0) as total_xp,
        COUNT(DISTINCT ub.badge_id) as badges_count,
        ls.current_streak
      FROM users u
      LEFT JOIN xp_transactions x ON u.id = x.user_id 
        AND x.created_at >= ${startDate}
      LEFT JOIN user_badges ub ON u.id = ub.user_id
      LEFT JOIN learning_streaks ls ON u.id = ls.user_id
      GROUP BY u.id, u.name, u.avatar_url, ls.current_streak
      ORDER BY total_xp DESC
      LIMIT 100
    `;
    
    return leaderboard.map((entry, index) => ({
      rank: index + 1,
      ...entry,
    }));
  }
}
```

### 5.2 Achievement Progress

```typescript
// Track achievement progress
interface AchievementProgress {
  id: string;
  name: string;
  description: string;
  iconUrl: string;
  currentValue: number;
  targetValue: number;
  percentComplete: number;
  isComplete: boolean;
}

async function getAchievementProgress(userId: string): Promise<AchievementProgress[]> {
  const achievements: AchievementProgress[] = [];
  
  // Courses Completed
  const coursesCompleted = await db.enrollments.count({
    where: { userId, completed: true },
  });
  achievements.push({
    id: 'courses_10',
    name: 'Scholar',
    description: 'Selesaikan 10 courses',
    iconUrl: '/badges/scholar.png',
    currentValue: coursesCompleted,
    targetValue: 10,
    percentComplete: Math.min((coursesCompleted / 10) * 100, 100),
    isComplete: coursesCompleted >= 10,
  });
  
  // Quiz Master
  const perfectQuizzes = await db.quizAttempts.count({
    where: { 
      enrollment: { userId },
      scorePercent: 100,
    },
  });
  achievements.push({
    id: 'quiz_master',
    name: 'Quiz Master',
    description: 'Dapatkan 5 perfect score',
    iconUrl: '/badges/quiz-master.png',
    currentValue: perfectQuizzes,
    targetValue: 5,
    percentComplete: Math.min((perfectQuizzes / 5) * 100, 100),
    isComplete: perfectQuizzes >= 5,
  });
  
  // Early Bird (7-day streak)
  const streak = await db.learningStreaks.findUnique({ where: { userId } });
  achievements.push({
    id: 'streak_7',
    name: 'Early Bird',
    description: 'Belajar 7 hari berturut-turut',
    iconUrl: '/badges/early-bird.png',
    currentValue: streak?.currentStreak || 0,
    targetValue: 7,
    percentComplete: Math.min(((streak?.currentStreak || 0) / 7) * 100, 100),
    isComplete: (streak?.longestStreak || 0) >= 7,
  });
  
  return achievements;
}
```

---

## Part 6: Progress Tracking

### 6.1 Update Lesson Progress

```typescript
// services/progress.service.ts
export class ProgressService {
  async updateLessonProgress(
    userId: string,
    lessonId: string,
    data: {
      progressPercent?: number;
      videoPosition?: number;
      completed?: boolean;
    }
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
    if (lesson.dripType) {
      const unlocked = await this.isLessonUnlocked(enrollment, lesson);
      if (!unlocked) {
        throw new Error('Lesson not yet available');
      }
    }
    
    // Upsert lesson progress
    const lessonProgress = await db.lessonProgress.upsert({
      where: {
        enrollmentId_lessonId: { 
          enrollmentId: enrollment.id, 
          lessonId 
        },
      },
      create: {
        enrollmentId: enrollment.id,
        lessonId,
        status: data.completed ? 'completed' : 'in_progress',
        progressPercent: data.progressPercent || 0,
        videoPositionSeconds: data.videoPosition || 0,
        startedAt: new Date(),
        completedAt: data.completed ? new Date() : null,
      },
      update: {
        status: data.completed ? 'completed' : 'in_progress',
        progressPercent: data.progressPercent,
        videoPositionSeconds: data.videoPosition,
        completedAt: data.completed ? new Date() : undefined,
        updatedAt: new Date(),
      },
    });
    
    // If completed, award XP and update course progress
    if (data.completed && lessonProgress.status !== 'completed') {
      await this.gamificationService.awardXp(userId, 'lesson_complete', lessonId);
      await this.gamificationService.updateStreak(userId);
    }
    
    // Update overall course progress
    await this.updateCourseProgress(enrollment.id);
    
    return lessonProgress;
  }
  
  async updateCourseProgress(enrollmentId: string): Promise<void> {
    const enrollment = await db.enrollments.findUnique({
      where: { id: enrollmentId },
      include: {
        course: {
          include: { 
            modules: { 
              include: { lessons: true } 
            } 
          },
        },
        lessonProgress: true,
      },
    });
    
    // Count lessons
    const totalLessons = enrollment.course.modules.reduce(
      (sum, m) => sum + m.lessons.length, 0
    );
    
    const completedLessons = enrollment.lessonProgress.filter(
      p => p.status === 'completed'
    ).length;
    
    const progressPercent = (completedLessons / totalLessons) * 100;
    const isComplete = progressPercent >= enrollment.course.completionThreshold;
    
    await db.enrollments.update({
      where: { id: enrollmentId },
      data: {
        progressPercent,
        lastAccessedAt: new Date(),
        completed: isComplete,
        completedAt: isComplete && !enrollment.completed ? new Date() : undefined,
      },
    });
    
    // Generate certificate if complete
    if (isComplete && !enrollment.certificateId && enrollment.course.certificateEnabled) {
      const certificate = await this.certificateService.generate(enrollment);
      
      await db.enrollments.update({
        where: { id: enrollmentId },
        data: { certificateId: certificate.id },
      });
      
      // Award XP
      await this.gamificationService.awardXp(
        enrollment.userId, 
        'course_complete', 
        enrollment.courseId
      );
    }
  }
  
  private async isLessonUnlocked(enrollment: Enrollment, lesson: Lesson): Promise<boolean> {
    switch (lesson.dripType) {
      case 'days':
        const unlockDate = addDays(enrollment.enrolledAt, lesson.dripValue);
        return new Date() >= unlockDate;
        
      case 'date':
        return new Date() >= lesson.dripDate;
        
      case 'after_lesson':
        const requiredProgress = await db.lessonProgress.findFirst({
          where: {
            enrollmentId: enrollment.id,
            lessonId: lesson.dripAfterLessonId,
            status: 'completed',
          },
        });
        return !!requiredProgress;
        
      default:
        return true;
    }
  }
}
```

---

## Part 7: Certificate Generation

### 7.1 Generate Certificate PDF

```typescript
// services/certificate.service.ts
import PDFDocument from 'pdfkit';
import QRCode from 'qrcode';

export class CertificateService {
  async generate(enrollment: Enrollment): Promise<Certificate> {
    const user = await db.users.findUnique({ where: { id: enrollment.userId } });
    const course = await db.courses.findUnique({ 
      where: { id: enrollment.courseId },
      include: { instructor: true },
    });
    
    const certificateId = generateId();
    const verifyUrl = `https://lms.com/certificates/verify/${certificateId}`;
    
    // Generate QR code
    const qrCodeDataUrl = await QRCode.toDataURL(verifyUrl);
    
    // Create PDF
    const doc = new PDFDocument({
      size: 'A4',
      layout: 'landscape',
      margin: 50,
    });
    
    const chunks: Buffer[] = [];
    doc.on('data', chunk => chunks.push(chunk));
    
    // Background
    doc.rect(0, 0, doc.page.width, doc.page.height)
       .fill('#fafafa');
    
    // Border
    doc.rect(30, 30, doc.page.width - 60, doc.page.height - 60)
       .stroke('#2563eb');
    
    // Logo
    doc.image('assets/logo.png', 50, 50, { width: 100 });
    
    // Title
    doc.fontSize(36)
       .fillColor('#1e40af')
       .text('CERTIFICATE OF COMPLETION', 0, 100, { align: 'center' });
    
    // Subtitle
    doc.fontSize(16)
       .fillColor('#4b5563')
       .text('This is to certify that', 0, 160, { align: 'center' });
    
    // Name
    doc.fontSize(32)
       .fillColor('#111827')
       .text(user.name, 0, 190, { align: 'center' });
    
    // Course name
    doc.fontSize(16)
       .fillColor('#4b5563')
       .text('has successfully completed the course', 0, 240, { align: 'center' });
    
    doc.fontSize(24)
       .fillColor('#1e40af')
       .text(course.title, 0, 270, { align: 'center' });
    
    // Duration
    doc.fontSize(14)
       .fillColor('#6b7280')
       .text(`Duration: ${course.durationHours} hours`, 0, 320, { align: 'center' });
    
    // Date
    doc.fontSize(14)
       .text(`Completed on: ${format(enrollment.completedAt, 'MMMM d, yyyy')}`, 0, 345, { align: 'center' });
    
    // Instructor signature
    doc.fontSize(12)
       .text(course.instructor.name, 150, 400, { align: 'center', width: 200 });
    doc.moveTo(100, 395).lineTo(300, 395).stroke('#000');
    doc.text('Instructor', 150, 415, { align: 'center', width: 200 });
    
    // QR Code
    doc.image(qrCodeDataUrl, doc.page.width - 150, doc.page.height - 150, { width: 100 });
    doc.fontSize(10)
       .text('Scan to verify', doc.page.width - 150, doc.page.height - 40, { width: 100, align: 'center' });
    
    // Certificate ID
    doc.fontSize(10)
       .fillColor('#9ca3af')
       .text(`Certificate ID: ${certificateId}`, 0, doc.page.height - 70, { align: 'center' });
    
    doc.end();
    
    const pdfBuffer = Buffer.concat(chunks);
    const fileName = `certificates/${certificateId}.pdf`;
    
    // Upload to storage
    const url = await this.storageService.upload(fileName, pdfBuffer);
    
    // Create database record
    return db.certificates.create({
      data: {
        id: certificateId,
        userId: enrollment.userId,
        courseId: enrollment.courseId,
        enrollmentId: enrollment.id,
        pdfUrl: url,
        verifyUrl,
        issuedAt: new Date(),
      },
    });
  }
  
  async verify(certificateId: string): Promise<CertificateVerification> {
    const certificate = await db.certificates.findUnique({
      where: { id: certificateId },
      include: {
        user: true,
        course: true,
      },
    });
    
    if (!certificate) {
      return { valid: false, message: 'Certificate not found' };
    }
    
    return {
      valid: true,
      certificate: {
        id: certificate.id,
        recipientName: certificate.user.name,
        courseName: certificate.course.title,
        issuedAt: certificate.issuedAt,
        pdfUrl: certificate.pdfUrl,
      },
    };
  }
}
```

---

## Part 8: Best Practices Checklist

### ✅ Do This

- ✅ **Resume Playback**: Track video position and allow resume
- ✅ **Mobile Responsive**: Learning on any device (PWA support)
- ✅ **Offline Download**: Allow offline access for mobile apps
- ✅ **Auto-Save Progress**: Save every few seconds, not just on exit
- ✅ **Video Quality Options**: Adaptive streaming with manual override
- ✅ **Playback Speed**: Allow 0.5x to 2x playback
- ✅ **Captions/Subtitles**: Accessibility and multi-language support
- ✅ **Keyboard Shortcuts**: Space=play/pause, arrows=seek
- ✅ **Streak Reminders**: Daily notifications to maintain streaks

### ❌ Avoid This

- ❌ **Skip Progress Saving**: Auto-save frequently to prevent lost progress
- ❌ **No Quiz Feedback**: Show explanations for wrong answers
- ❌ **Ignore Accessibility**: Caption videos, allow keyboard navigation
- ❌ **Block Seeking**: Users should be able to rewatch content
- ❌ **Complex SCORM Only**: Support simple video/text lessons too
- ❌ **Gamification Overload**: Keep XP/badges meaningful, not spammy

---

## Related Skills

- `@instructional-designer` - Curriculum and course design
- `@video-processing-specialist` - Advanced video handling
- `@senior-firebase-developer` - Realtime progress sync
- `@senior-nextjs-developer` - Course platform frontend

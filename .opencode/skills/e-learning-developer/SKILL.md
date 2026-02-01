---
name: e-learning-developer
description: "Expert e-learning development including LMS, SCORM, interactive courses, and online learning platforms"
---

# E-Learning Developer

## Overview

Build interactive online courses and learning management systems.

## When to Use This Skill

- Use when creating online courses
- Use when setting up LMS
- Use when building SCORM packages

## How It Works

### Step 1: Course Structure

```markdown
## E-Learning Course Architecture

### Hierarchy
Course
├── Module 1: Introduction
│   ├── Lesson 1.1: Overview
│   ├── Lesson 1.2: Getting Started
│   └── Quiz 1
├── Module 2: Core Concepts
│   ├── Lesson 2.1: Topic A
│   ├── Lesson 2.2: Topic B
│   ├── Activity 2.1
│   └── Quiz 2
└── Final Assessment

### Lesson Components
- Video (3-7 min max)
- Reading material
- Interactive exercise
- Knowledge check
- Summary
```

### Step 2: Interactive Elements

```javascript
// Quiz Component Example
const QuizQuestion = {
  type: 'multiple-choice',
  question: 'What is the capital of Indonesia?',
  options: [
    { id: 'a', text: 'Jakarta', correct: true },
    { id: 'b', text: 'Surabaya', correct: false },
    { id: 'c', text: 'Bandung', correct: false },
  ],
  feedback: {
    correct: 'Correct! Jakarta is the capital.',
    incorrect: 'Try again. Think about Java island.',
  },
  points: 10,
};

// Progress Tracking
const trackProgress = (userId, lessonId, status) => {
  return {
    user_id: userId,
    lesson_id: lessonId,
    status: status, // 'started', 'completed', 'passed'
    completed_at: new Date(),
    score: null,
    time_spent: 0,
  };
};
```

### Step 3: LMS Integration

```markdown
## LMS Options

### Self-Hosted
- Moodle (PHP) - Open source, feature-rich
- Canvas (Ruby) - Modern, API-first
- Open edX (Python) - MOOC platform

### Cloud-Based
- Teachable - Course creators
- Thinkific - All-in-one
- Kajabi - Marketing focused

### SCORM Compliance
- SCORM 1.2 - Widely supported
- SCORM 2004 - Advanced sequencing
- xAPI (Tin Can) - Modern tracking
```

### Step 4: SCORM Package

```javascript
// SCORM API Integration
const SCORM = {
  init: () => {
    API.LMSInitialize('');
  },
  
  setScore: (score) => {
    API.LMSSetValue('cmi.core.score.raw', score);
  },
  
  setStatus: (status) => {
    // 'completed', 'incomplete', 'passed', 'failed'
    API.LMSSetValue('cmi.core.lesson_status', status);
  },
  
  getBookmark: () => {
    return API.LMSGetValue('cmi.core.lesson_location');
  },
  
  setBookmark: (location) => {
    API.LMSSetValue('cmi.core.lesson_location', location);
  },
  
  commit: () => {
    API.LMSCommit('');
  },
  
  finish: () => {
    API.LMSFinish('');
  }
};
```

### Step 5: Video Learning Best Practices

```markdown
## Video Content Guidelines

### Duration
- Micro-learning: 2-5 min
- Standard: 5-10 min
- Max single video: 15 min

### Engagement Features
- Chapters/timestamps
- In-video quizzes
- Interactive transcripts
- Playback speed control

### Accessibility
- Captions/subtitles
- Audio descriptions
- Transcript download
- Keyboard navigation
```

## Best Practices

- ✅ Chunk videos under 10 min
- ✅ Add interactive elements
- ✅ Track learner progress
- ✅ Mobile-responsive design
- ❌ Don't make passive content
- ❌ Don't skip accessibility

## Related Skills

- `@instructional-designer`
- `@senior-course-creator`

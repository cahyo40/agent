---
name: academic-scheduling-developer
description: "Expert academic scheduling system development including class timetables, room allocation, conflict detection, and university course registration"
---

# Academic Scheduling Developer

## Overview

Skill ini menjadikan AI Agent Anda sebagai spesialis pengembangan sistem penjadwalan akademik. Agent akan mampu membangun fitur timetable generation, room allocation, conflict detection, course registration, dan exam scheduling untuk sekolah dan universitas.

## When to Use This Skill

- Use when building class scheduling or timetable systems
- Use when implementing room and resource allocation
- Use when the user asks about academic scheduling algorithms
- Use when designing course registration systems
- Use when building exam scheduling applications

## Core Concepts

### System Components

```text
┌─────────────────────────────────────────────────────────┐
│           ACADEMIC SCHEDULING COMPONENTS                │
├─────────────────────────────────────────────────────────┤
│ 📅 Timetable Generation  - Auto-generate class schedules│
│ 🏫 Room Allocation       - Match classes with rooms     │
│ ⚠️ Conflict Detection    - Prevent scheduling clashes   │
│ 📝 Course Registration   - Student enrollment system    │
│ 📊 Exam Scheduling       - Final exam timetables        │
│ 👨‍🏫 Teacher Assignment    - Match teachers to subjects   │
│ 📱 Student View          - Personal schedule display    │
└─────────────────────────────────────────────────────────┘
```

### Data Schema (ERD)

```text
┌──────────────┐     ┌──────────────┐     ┌──────────────┐
│   COURSE     │     │   TEACHER    │     │    ROOM      │
├──────────────┤     ├──────────────┤     ├──────────────┤
│ id           │     │ id           │     │ id           │
│ code         │     │ name         │     │ name         │
│ name         │     │ expertise[]  │     │ building     │
│ credits      │     │ max_hours    │     │ capacity     │
│ hours_week   │     │ available[]  │     │ type         │
│ max_students │     └──────────────┘     │ facilities[] │
│ room_type    │                          └──────────────┘
│ prereqs[]    │                                │
└──────────────┘                                │
       │                                        │
       │         ┌──────────────┐              │
       └────────►│ CLASS_SESSION│◄─────────────┘
                 ├──────────────┤
                 │ id           │
                 │ course_id    │◄── FK
                 │ teacher_id   │◄── FK
                 │ room_id      │◄── FK
                 │ day_of_week  │
                 │ start_time   │
                 │ end_time     │
                 │ session_type │
                 └──────────────┘
                        ▲
                        │
┌──────────────┐    ┌───┴──────────┐
│   STUDENT    │    │  ENROLLMENT  │
├──────────────┤    ├──────────────┤
│ id           │───►│ student_id   │
│ name         │    │ course_id    │
│ program_id   │    │ semester     │
│ semester     │    │ status       │
└──────────────┘    └──────────────┘
```

### Time Slot Structure

```text
Weekly Schedule Grid:
┌─────────┬─────────┬─────────┬─────────┬─────────┬─────────┐
│  Time   │   Mon   │   Tue   │   Wed   │   Thu   │   Fri   │
├─────────┼─────────┼─────────┼─────────┼─────────┼─────────┤
│ 07:00   │ Slot 1  │ Slot 1  │ Slot 1  │ Slot 1  │ Slot 1  │
│ 08:00   │ Slot 2  │ Slot 2  │ Slot 2  │ Slot 2  │ Slot 2  │
│ 09:00   │ Slot 3  │ Slot 3  │ Slot 3  │ Slot 3  │ Slot 3  │
│ 10:00   │ Slot 4  │ Slot 4  │ Slot 4  │ Slot 4  │ Slot 4  │
│ 11:00   │ Slot 5  │ Slot 5  │ Slot 5  │ Slot 5  │ Slot 5  │
│ 12:00   │  BREAK  │  BREAK  │  BREAK  │  BREAK  │  BREAK  │
│ 13:00   │ Slot 6  │ Slot 6  │ Slot 6  │ Slot 6  │ Slot 6  │
│ ...     │   ...   │   ...   │   ...   │   ...   │   ...   │
└─────────┴─────────┴─────────┴─────────┴─────────┴─────────┘
```

## Algorithms

### Conflict Detection Rules

```text
CONFLICT TYPES:
├── Room Double-Booking
│   Rule: Same room + Same day + Overlapping time = CONFLICT
│
├── Teacher Double-Booking  
│   Rule: Same teacher + Same day + Overlapping time = CONFLICT
│
├── Student Course Conflict
│   Rule: Student enrolled in both courses + Same day + Overlapping time = CONFLICT
│
└── Resource Conflict
    Rule: Same resource (projector, lab) + Same day + Overlapping time = CONFLICT

TIME OVERLAP CHECK:
  Session A: start_A, end_A
  Session B: start_B, end_B
  
  Overlaps if: start_A < end_B AND end_A > start_B
```

### Timetable Generation Algorithms

```text
ALGORITHM 1: GREEDY APPROACH
─────────────────────────────
1. Sort courses by constraint level (most constrained first)
2. For each course:
   a. Find available teacher
   b. Find available time slots
   c. Find suitable room (capacity, type)
   d. If no conflict → assign
   e. If conflict → try next slot
3. Repeat until all courses scheduled or failure

ALGORITHM 2: GENETIC ALGORITHM
──────────────────────────────
1. Initialize population of random valid timetables
2. Evaluate fitness (fewer conflicts = higher fitness)
3. Selection: Keep best individuals
4. Crossover: Combine two schedules
5. Mutation: Randomly swap time slots
6. Repeat for N generations
7. Return best solution

FITNESS FUNCTION:
  fitness = 1.0
  fitness -= (num_conflicts * 0.2)
  fitness += (good_distribution * 0.1)
  fitness += (teacher_preference_met * 0.05)

ALGORITHM 3: CONSTRAINT SATISFACTION (CSP)
──────────────────────────────────────────
Variables: Each class session
Domains: All possible (day, time, room) combinations
Constraints: No conflicts

Use backtracking with:
- Forward checking
- Arc consistency (AC-3)
- Variable ordering heuristics
```

### Room Allocation Logic

```text
ROOM MATCHING CRITERIA:
1. Room type must match course requirement
   - Lecture → Lecture Hall
   - Lab → Computer Lab, Science Lab
   - Tutorial → Seminar Room
   
2. Capacity must be sufficient
   - room.capacity >= course.enrolled_students
   
3. Required facilities available
   - course.needs_projector → room.has_projector
   - course.needs_computers → room.type = "Computer Lab"

ALLOCATION PRIORITY:
1. Exact capacity match (avoid waste)
2. Prefer same building for consecutive classes
3. Consider accessibility requirements
```

### Course Registration Validation

```text
ENROLLMENT CHECK SEQUENCE:
┌─────────────────────────────────────────┐
│ 1. Check Prerequisites                  │
│    └── Student completed required courses?
│                                         │
│ 2. Check Quota                          │
│    └── Course capacity not exceeded?    │
│                                         │
│ 3. Check Schedule Conflicts             │
│    └── No overlap with enrolled courses?│
│                                         │
│ 4. Check Credit Limit                   │
│    └── Within max credits per semester? │
│                                         │
│ 5. Check Academic Standing              │
│    └── GPA requirement met?             │
│                                         │
│ ✓ All passed → ENROLL                   │
│ ✗ Any failed → REJECT with reason       │
└─────────────────────────────────────────┘
```

## API Design

### Endpoints Structure

```text
/api/v1/
├── /courses
│   ├── GET    /              - List all courses
│   ├── POST   /              - Create course
│   └── GET    /:id/schedule  - Get course schedule
│
├── /schedules
│   ├── GET    /              - Get master timetable
│   ├── POST   /generate      - Generate new timetable
│   └── GET    /conflicts     - List all conflicts
│
├── /rooms
│   ├── GET    /              - List rooms
│   └── GET    /:id/availability - Room availability
│
├── /teachers
│   ├── GET    /:id/schedule  - Teacher's schedule
│   └── PUT    /:id/preferences - Update preferences
│
├── /students
│   ├── GET    /:id/schedule  - Student's schedule
│   └── POST   /:id/enroll    - Enroll in course
│
└── /enrollments
    ├── POST   /              - Create enrollment
    └── DELETE /:id           - Drop course
```

## Best Practices

### ✅ Do This

- ✅ Validate all constraints before saving schedules
- ✅ Provide clear conflict resolution suggestions
- ✅ Allow manual overrides with audit logs
- ✅ Support multiple views (student, teacher, room, course)
- ✅ Implement undo/redo for schedule changes
- ✅ Cache computed schedules for performance

### ❌ Avoid This

- ❌ Don't allow saving schedules with unresolved conflicts
- ❌ Don't ignore room capacity constraints
- ❌ Don't forget teacher availability preferences
- ❌ Don't make bulk changes without confirmation
- ❌ Don't hardcode time slot durations

## Related Skills

- `@senior-backend-developer` - API development
- `@senior-database-engineer-sql` - Database design
- `@senior-software-architect` - System design
- `@e-learning-developer` - LMS integration
- `@senior-ui-ux-designer` - Timetable UI design

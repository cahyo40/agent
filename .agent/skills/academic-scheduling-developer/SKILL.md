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

## How It Works

### Step 1: Core Components

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

### Step 2: Data Models

```dart
// Core entities
class Course {
  final String id;
  final String code;
  final String name;
  final int credits;
  final int hoursPerWeek;
  final List<String> requiredRoomTypes; // lab, lecture, studio
  final int maxStudents;
  final List<String> prerequisiteIds;
}

class ClassSession {
  final String id;
  final String courseId;
  final String teacherId;
  final String roomId;
  final DayOfWeek day;
  final TimeSlot timeSlot;
  final SessionType type; // lecture, lab, tutorial
}

class TimeSlot {
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final int periodNumber;
  
  bool overlaps(TimeSlot other) {
    return startTime.isBefore(other.endTime) && 
           endTime.isAfter(other.startTime);
  }
}

class Room {
  final String id;
  final String name;
  final String building;
  final int capacity;
  final RoomType type;
  final List<String> facilities; // projector, whiteboard, computers
}

class Teacher {
  final String id;
  final String name;
  final List<String> subjectExpertise;
  final List<TimeSlot> availableSlots;
  final int maxHoursPerWeek;
}

class Student {
  final String id;
  final String name;
  final String programId;
  final int semester;
  final List<String> enrolledCourseIds;
}

// Timetable
class Timetable {
  final String id;
  final String academicYear;
  final String semester;
  final List<ClassSession> sessions;
  
  List<ClassSession> getSessionsForDay(DayOfWeek day) {
    return sessions.where((s) => s.day == day).toList();
  }
  
  List<ClassSession> getSessionsForRoom(String roomId) {
    return sessions.where((s) => s.roomId == roomId).toList();
  }
  
  List<ClassSession> getSessionsForTeacher(String teacherId) {
    return sessions.where((s) => s.teacherId == teacherId).toList();
  }
}
```

### Step 3: Conflict Detection

```dart
class ConflictDetector {
  // Check all types of conflicts
  List<ScheduleConflict> detectConflicts(Timetable timetable) {
    final conflicts = <ScheduleConflict>[];
    
    conflicts.addAll(_detectRoomConflicts(timetable));
    conflicts.addAll(_detectTeacherConflicts(timetable));
    conflicts.addAll(_detectStudentConflicts(timetable));
    
    return conflicts;
  }
  
  // Room double-booking
  List<ScheduleConflict> _detectRoomConflicts(Timetable timetable) {
    final conflicts = <ScheduleConflict>[];
    final sessions = timetable.sessions;
    
    for (int i = 0; i < sessions.length; i++) {
      for (int j = i + 1; j < sessions.length; j++) {
        final a = sessions[i];
        final b = sessions[j];
        
        if (a.roomId == b.roomId &&
            a.day == b.day &&
            a.timeSlot.overlaps(b.timeSlot)) {
          conflicts.add(ScheduleConflict(
            type: ConflictType.roomDoubleBooking,
            sessionA: a,
            sessionB: b,
            message: 'Room ${a.roomId} is double-booked',
          ));
        }
      }
    }
    return conflicts;
  }
  
  // Teacher teaching two classes at same time
  List<ScheduleConflict> _detectTeacherConflicts(Timetable timetable) {
    final conflicts = <ScheduleConflict>[];
    final sessions = timetable.sessions;
    
    for (int i = 0; i < sessions.length; i++) {
      for (int j = i + 1; j < sessions.length; j++) {
        final a = sessions[i];
        final b = sessions[j];
        
        if (a.teacherId == b.teacherId &&
            a.day == b.day &&
            a.timeSlot.overlaps(b.timeSlot)) {
          conflicts.add(ScheduleConflict(
            type: ConflictType.teacherConflict,
            sessionA: a,
            sessionB: b,
            message: 'Teacher ${a.teacherId} has overlapping classes',
          ));
        }
      }
    }
    return conflicts;
  }
  
  // Student enrolled in overlapping classes
  List<ScheduleConflict> _detectStudentConflicts(
    Timetable timetable,
    Student student,
  ) {
    final conflicts = <ScheduleConflict>[];
    final studentSessions = timetable.sessions
      .where((s) => student.enrolledCourseIds.contains(s.courseId))
      .toList();
    
    for (int i = 0; i < studentSessions.length; i++) {
      for (int j = i + 1; j < studentSessions.length; j++) {
        final a = studentSessions[i];
        final b = studentSessions[j];
        
        if (a.day == b.day && a.timeSlot.overlaps(b.timeSlot)) {
          conflicts.add(ScheduleConflict(
            type: ConflictType.studentConflict,
            sessionA: a,
            sessionB: b,
            message: 'Student has overlapping classes',
          ));
        }
      }
    }
    return conflicts;
  }
}
```

### Step 4: Automatic Timetable Generation

```dart
class TimetableGenerator {
  final List<Course> courses;
  final List<Room> rooms;
  final List<Teacher> teachers;
  final List<TimeSlot> availableSlots;
  
  // Genetic Algorithm approach
  Future<Timetable> generateOptimalTimetable() async {
    // Initialize population
    var population = _initializePopulation(50);
    
    for (int generation = 0; generation < 1000; generation++) {
      // Evaluate fitness
      population.sort((a, b) => 
        _calculateFitness(b).compareTo(_calculateFitness(a)));
      
      // Check if optimal solution found
      if (_calculateFitness(population.first) >= 0.95) {
        break;
      }
      
      // Selection, crossover, mutation
      population = _evolvePopulation(population);
    }
    
    return population.first;
  }
  
  double _calculateFitness(Timetable timetable) {
    double fitness = 1.0;
    final conflicts = ConflictDetector().detectConflicts(timetable);
    
    // Penalize conflicts heavily
    fitness -= conflicts.length * 0.1;
    
    // Reward good distribution
    fitness += _evaluateDistribution(timetable) * 0.2;
    
    // Reward room utilization
    fitness += _evaluateRoomUtilization(timetable) * 0.1;
    
    return fitness.clamp(0.0, 1.0);
  }
  
  // Greedy algorithm for simpler cases
  Timetable generateGreedyTimetable() {
    final sessions = <ClassSession>[];
    
    for (final course in courses) {
      final teacher = _findAvailableTeacher(course, sessions);
      final slots = _findAvailableSlots(course, teacher, sessions);
      
      for (final slot in slots.take(course.hoursPerWeek)) {
        final room = _findSuitableRoom(course, slot, sessions);
        
        if (room != null) {
          sessions.add(ClassSession(
            id: _uuid.v4(),
            courseId: course.id,
            teacherId: teacher.id,
            roomId: room.id,
            day: slot.day,
            timeSlot: slot.timeSlot,
            type: SessionType.lecture,
          ));
        }
      }
    }
    
    return Timetable(sessions: sessions);
  }
}
```

### Step 5: Course Registration System

```dart
class CourseRegistrationService {
  // Check prerequisites before enrollment
  Future<EnrollmentResult> enrollStudent(
    String studentId,
    String courseId,
  ) async {
    final student = await _studentRepo.get(studentId);
    final course = await _courseRepo.get(courseId);
    
    // Check prerequisites
    for (final prereqId in course.prerequisiteIds) {
      if (!student.completedCourseIds.contains(prereqId)) {
        return EnrollmentResult.failure(
          'Missing prerequisite: ${prereqId}',
        );
      }
    }
    
    // Check capacity
    final enrolledCount = await _getEnrolledCount(courseId);
    if (enrolledCount >= course.maxStudents) {
      return EnrollmentResult.failure('Course is full');
    }
    
    // Check schedule conflicts
    final conflicts = await _checkScheduleConflicts(student, courseId);
    if (conflicts.isNotEmpty) {
      return EnrollmentResult.failure(
        'Schedule conflict with: ${conflicts.join(", ")}',
      );
    }
    
    // Check credit limit
    final currentCredits = _calculateCurrentCredits(student);
    if (currentCredits + course.credits > student.maxCreditsPerSemester) {
      return EnrollmentResult.failure('Credit limit exceeded');
    }
    
    // Enroll
    await _enrollmentRepo.create(studentId, courseId);
    return EnrollmentResult.success();
  }
}
```

### Step 6: UI Components

```dart
// Weekly timetable view
class WeeklyTimetableWidget extends StatelessWidget {
  final Timetable timetable;
  final String? highlightCourseId;
  
  @override
  Widget build(BuildContext context) {
    return Table(
      border: TableBorder.all(color: Colors.grey.shade300),
      children: [
        // Header row with days
        TableRow(
          children: [
            _buildHeaderCell('Time'),
            ...DayOfWeek.values.map((d) => _buildHeaderCell(d.name)),
          ],
        ),
        // Time slot rows
        ...timeSlots.map((slot) => TableRow(
          children: [
            _buildTimeCell(slot),
            ...DayOfWeek.values.map((day) => 
              _buildSessionCell(day, slot)),
          ],
        )),
      ],
    );
  }
  
  Widget _buildSessionCell(DayOfWeek day, TimeSlot slot) {
    final session = timetable.sessions.firstWhereOrNull(
      (s) => s.day == day && s.timeSlot == slot,
    );
    
    if (session == null) return const SizedBox.shrink();
    
    return Container(
      padding: const EdgeInsets.all(8),
      color: _getCourseColor(session.courseId),
      child: Column(
        children: [
          Text(session.courseName, style: TextStyle(fontWeight: FontWeight.bold)),
          Text(session.roomName),
          Text(session.teacherName, style: TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}
```

## Best Practices

### ✅ Do This

- ✅ Validate all constraints before saving schedules
- ✅ Provide clear conflict resolution suggestions
- ✅ Allow manual overrides with warning logs
- ✅ Support multiple views (student, teacher, room, course)
- ✅ Implement undo/redo for schedule changes

### ❌ Avoid This

- ❌ Don't allow saving schedules with unresolved conflicts
- ❌ Don't ignore room capacity constraints
- ❌ Don't forget teacher availability preferences
- ❌ Don't make bulk changes without confirmation
- ❌ Don't skip exam scheduling edge cases

## Related Skills

- `@senior-flutter-developer` - Mobile app development
- `@senior-backend-developer` - API development
- `@senior-database-engineer-sql` - Database design
- `@e-learning-developer` - LMS integration
- `@senior-ui-ux-designer` - Timetable UI design

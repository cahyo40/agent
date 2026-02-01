---
name: debugging-specialist
description: "Expert systematic debugging including root cause analysis, debugging strategies, logging, and troubleshooting complex issues"
---

# Debugging Specialist

## Overview

This skill helps you systematically debug issues, find root causes, and resolve problems efficiently instead of randomly trying fixes.

## When to Use This Skill

- Use when encountering bugs
- Use when tests fail unexpectedly
- Use when behavior is unexpected
- Use when troubleshooting production issues

## How It Works

### Step 1: Debugging Process

```
SYSTEMATIC DEBUGGING PROCESS
┌─────────────────────────────────────────────────────────────────┐
│                                                                 │
│  1. REPRODUCE                                                   │
│     └── Can you make it happen consistently?                   │
│     └── What are the exact steps?                              │
│                                                                 │
│  2. ISOLATE                                                     │
│     └── Where does it break? (binary search)                   │
│     └── What changed recently?                                 │
│                                                                 │
│  3. UNDERSTAND                                                  │
│     └── What SHOULD happen vs what DOES happen?                │
│     └── Read the error message carefully                       │
│                                                                 │
│  4. HYPOTHESIZE                                                 │
│     └── What could cause this?                                 │
│     └── List 3 most likely causes                              │
│                                                                 │
│  5. TEST                                                        │
│     └── Verify one hypothesis at a time                        │
│     └── Change only one thing                                  │
│                                                                 │
│  6. FIX & VERIFY                                                │
│     └── Apply fix                                              │
│     └── Confirm original issue is resolved                     │
│     └── Check for regressions                                  │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### Step 2: Debugging Techniques

```markdown
## Binary Search Debugging
If bug appears somewhere in process:
1. Check middle point
2. If bug exists, search first half
3. If no bug, search second half
4. Repeat until found

## Rubber Duck Debugging
Explain the code line by line to a rubber duck (or colleague).
Often you'll find the bug while explaining.

## Print/Log Debugging
```javascript
console.log('=== DEBUG ===');
console.log('Input:', input);
console.log('State:', state);
console.log('Output:', output);
```

## Git Bisect

```bash
git bisect start
git bisect bad HEAD
git bisect good v1.0.0
# Git will help find the commit that introduced the bug
```

```

### Step 3: Reading Error Messages

```markdown
## Error Message Anatomy

### Stack Trace (Read Bottom to Top)
```

Error: Cannot read property 'map' of undefined
    at UserList (UserList.js:15:23)      ← ACTUAL ERROR
    at renderWithHooks (react-dom.js:...)
    at mountIndeterminateComponent (...)

```

### Key Questions:
1. What is the error type? (TypeError, ReferenceError, etc.)
2. What line/file? (UserList.js:15)
3. What's undefined/null? (something before .map)
4. What called this function? (trace upward)
```

### Step 4: Common Bug Patterns

```markdown
## Common Bugs & Solutions

### "Cannot read property X of undefined"
- Check if object exists before accessing
- Check async data loading
- Check array bounds

### "Maximum call stack exceeded"
- Infinite recursion
- Check base case
- Check circular dependencies

### "Race condition"
- Async operations completing out of order
- Add proper awaits
- Use mutex/locks

### "Works on my machine"
- Environment differences
- Check env variables
- Check dependencies versions
- Check file paths (Windows vs Unix)
```

## Best Practices

### ✅ Do This

- ✅ Reproduce before fixing
- ✅ Read error messages carefully
- ✅ Change one thing at a time
- ✅ Write a test for the bug
- ✅ Document the solution

### ❌ Avoid This

- ❌ Don't randomly try fixes
- ❌ Don't ignore error messages
- ❌ Don't assume—verify
- ❌ Don't debug while tired

## Related Skills

- `@senior-software-engineer` - Code quality
- `@tdd-workflow` - Test-driven development

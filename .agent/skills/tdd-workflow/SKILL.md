---
name: tdd-workflow
description: "Test-Driven Development methodology including RED-GREEN-REFACTOR cycle, test design patterns, and TDD best practices"
---

# TDD Workflow

## Overview

This skill helps you follow Test-Driven Development (TDD) methodology where tests are written before implementation code, leading to better design and fewer bugs.

## When to Use This Skill

- Use before implementing any feature
- Use when fixing bugs
- Use when refactoring code
- Use when the user wants TDD approach

## How It Works

### Step 1: RED-GREEN-REFACTOR Cycle

```
TDD CYCLE
┌─────────────────────────────────────────────────────────────────┐
│                                                                 │
│     ┌─────────┐                                                │
│     │   RED   │ ← Write a failing test                        │
│     │  (Fail) │                                                │
│     └────┬────┘                                                │
│          │                                                      │
│          ▼                                                      │
│     ┌─────────┐                                                │
│     │  GREEN  │ ← Write minimal code to pass                  │
│     │  (Pass) │                                                │
│     └────┬────┘                                                │
│          │                                                      │
│          ▼                                                      │
│     ┌─────────┐                                                │
│     │REFACTOR │ ← Improve code, keep tests green              │
│     │(Improve)│                                                │
│     └────┬────┘                                                │
│          │                                                      │
│          └──────────────────────────────────────────► Repeat   │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### Step 2: Writing Good Tests

```typescript
// ❌ BAD: Vague test name
test('user', () => { ... });

// ✅ GOOD: Descriptive test name
test('should return error when email is invalid', () => { ... });

// ❌ BAD: Testing implementation
test('calls validateEmail function', () => { ... });

// ✅ GOOD: Testing behavior
test('rejects registration with invalid email format', () => { ... });
```

### Step 3: TDD Example

```typescript
// 1. RED - Write failing test first
describe('Calculator', () => {
  test('should add two numbers', () => {
    const calc = new Calculator();
    expect(calc.add(2, 3)).toBe(5);
  });
});
// ❌ Test fails - Calculator doesn't exist

// 2. GREEN - Minimal code to pass
class Calculator {
  add(a: number, b: number): number {
    return a + b;
  }
}
// ✅ Test passes

// 3. REFACTOR - Improve if needed
// Add more tests, then refactor with confidence

// 4. Add next test
test('should subtract two numbers', () => {
  const calc = new Calculator();
  expect(calc.subtract(5, 3)).toBe(2);
});
// ❌ Fails, implement subtract, repeat cycle
```

### Step 4: Test Structure (AAA)

```typescript
test('should create user with valid data', async () => {
  // ARRANGE - Set up test data
  const userData = { name: 'John', email: 'john@example.com' };
  const userService = new UserService(mockRepo);

  // ACT - Execute the action
  const result = await userService.createUser(userData);

  // ASSERT - Verify the outcome
  expect(result.id).toBeDefined();
  expect(result.name).toBe('John');
  expect(mockRepo.save).toHaveBeenCalledWith(userData);
});
```

## Best Practices

### ✅ Do This

- ✅ Write test BEFORE implementation
- ✅ Write minimal code to pass
- ✅ One assertion per test (ideally)
- ✅ Test behavior, not implementation
- ✅ Refactor with green tests

### ❌ Avoid This

- ❌ Don't write too many tests at once
- ❌ Don't skip the refactor step
- ❌ Don't test private methods
- ❌ Don't ignore failing tests

## Related Skills

- `@senior-software-engineer` - Clean code
- `@playwright-specialist` - E2E testing

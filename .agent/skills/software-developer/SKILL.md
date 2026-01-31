---
name: software-developer
description: "Foundational software development skills including programming fundamentals, clean code, design patterns, and development best practices"
---

# Software Developer

## Overview

This skill provides foundational knowledge for software development across any domain. Covers programming fundamentals, clean code principles, design patterns, and professional development practices.

## When to Use This Skill

- Use when learning programming fundamentals
- Use when writing clean, maintainable code
- Use when applying design patterns
- Use when debugging and troubleshooting
- Use when code reviewing

## How It Works

### Step 1: Programming Fundamentals

```text
PROGRAMMING CONCEPTS
├── Data Types
│   ├── Primitives (int, string, bool)
│   ├── Collections (array, list, map)
│   └── Custom types (class, struct)
├── Control Flow
│   ├── Conditionals (if, switch)
│   ├── Loops (for, while)
│   └── Exception handling
├── Functions
│   ├── Parameters & return values
│   ├── Pure functions
│   └── Higher-order functions
└── Object-Oriented
    ├── Classes & objects
    ├── Inheritance & composition
    ├── Encapsulation
    └── Polymorphism
```

### Step 2: Clean Code Principles

```markdown
## SOLID Principles

### S - Single Responsibility
Each class/function should have one reason to change.

### O - Open/Closed
Open for extension, closed for modification.

### L - Liskov Substitution
Subtypes must be substitutable for their base types.

### I - Interface Segregation
Many specific interfaces > one general interface.

### D - Dependency Inversion
Depend on abstractions, not concretions.
```

```javascript
// ❌ Bad: Multiple responsibilities
class User {
  saveToDatabase() { }
  sendEmail() { }
  generateReport() { }
}

// ✅ Good: Single responsibility
class User { }
class UserRepository { save(user) { } }
class EmailService { send(to, message) { } }
class ReportGenerator { generate(user) { } }
```

### Step 3: Common Design Patterns

```markdown
## Creational Patterns
| Pattern | Purpose | Use When |
|---------|---------|----------|
| Singleton | One instance | Config, logging |
| Factory | Object creation | Complex instantiation |
| Builder | Step-by-step construction | Many parameters |

## Structural Patterns
| Pattern | Purpose | Use When |
|---------|---------|----------|
| Adapter | Interface compatibility | Legacy integration |
| Decorator | Add behavior | Extend without inheritance |
| Facade | Simplified interface | Complex subsystems |

## Behavioral Patterns
| Pattern | Purpose | Use When |
|---------|---------|----------|
| Observer | Event notification | UI updates, events |
| Strategy | Swappable algorithms | Multiple implementations |
| Command | Encapsulate actions | Undo/redo, queuing |
```

```javascript
// Strategy Pattern Example
class PaymentProcessor {
  constructor(strategy) {
    this.strategy = strategy;
  }
  
  process(amount) {
    return this.strategy.pay(amount);
  }
}

class CreditCardPayment {
  pay(amount) { return `Paid $${amount} with credit card`; }
}

class PayPalPayment {
  pay(amount) { return `Paid $${amount} with PayPal`; }
}

// Usage
const processor = new PaymentProcessor(new CreditCardPayment());
processor.process(100);
```

### Step 4: Code Quality Checklist

```markdown
## Before Committing

### Functionality
- [ ] Code works as expected
- [ ] Edge cases handled
- [ ] Error handling in place

### Readability
- [ ] Meaningful variable/function names
- [ ] Comments for complex logic
- [ ] Consistent formatting

### Maintainability
- [ ] No code duplication (DRY)
- [ ] Functions are small (< 20 lines)
- [ ] Max 3-4 parameters per function

### Testing
- [ ] Unit tests written
- [ ] Tests pass
- [ ] Edge cases tested
```

### Step 5: Debugging Process

```markdown
## Systematic Debugging

1. **Reproduce** - Can you reliably trigger the bug?
2. **Isolate** - Narrow down where it occurs
3. **Identify** - Find the root cause
4. **Fix** - Apply minimal change
5. **Verify** - Confirm fix works
6. **Prevent** - Add test to prevent regression

## Debugging Tools
- Print/console logging
- Debugger (breakpoints, step-through)
- Profiler (performance issues)
- Memory analyzer (leaks)
- Network inspector (API issues)
```

### Step 6: Version Control Workflow

```bash
# Feature branch workflow
git checkout -b feature/user-auth
git add .
git commit -m "feat: add user authentication"
git push origin feature/user-auth
# Create Pull Request

# Commit message format
# type: subject
# 
# Types: feat, fix, docs, style, refactor, test, chore
```

## Best Practices

### ✅ Do This

- ✅ Write self-documenting code
- ✅ Keep functions small and focused
- ✅ Handle errors explicitly
- ✅ Write tests before fixing bugs
- ✅ Refactor regularly
- ✅ Code review before merge
- ✅ Document public APIs

### ❌ Avoid This

- ❌ Don't repeat yourself (DRY)
- ❌ Don't use magic numbers
- ❌ Don't ignore warnings
- ❌ Don't commit dead code
- ❌ Don't skip code review
- ❌ Don't over-engineer early

## Naming Conventions

```markdown
| Element | Convention | Example |
|---------|------------|---------|
| Variables | camelCase | userId, isActive |
| Constants | UPPER_SNAKE | MAX_RETRIES |
| Functions | camelCase (verb) | getUser, calculateTotal |
| Classes | PascalCase | UserService, PaymentGateway |
| Files | kebab-case | user-service.js |
| Interfaces | I-prefix (optional) | IUserRepository |
```

## Related Skills

- `@senior-software-engineer` - Advanced practices
- `@debugging-specialist` - Deep debugging
- `@git-workflow-specialist` - Git mastery
- `@senior-code-reviewer` - Code review

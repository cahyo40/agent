---
name: senior-software-engineer
description: "Expert software engineering including clean code, design patterns, testing strategies, code review, debugging, and production-ready development practices"
---

# Senior Software Engineer

## Overview

This skill transforms you into an experienced Senior Software Engineer who writes clean, maintainable, and production-ready code. You'll apply design patterns, implement comprehensive testing, conduct effective code reviews, and mentor junior developers while delivering high-quality software solutions.

## When to Use This Skill

- Use when writing production-quality code
- Use when implementing features with best practices
- Use when reviewing code for quality and correctness
- Use when debugging complex issues
- Use when refactoring legacy code
- Use when the user asks about clean code or design patterns
- Use when implementing testing strategies

## How It Works

### Step 1: Apply Clean Code Principles

```
CLEAN CODE FUNDAMENTALS
├── NAMING
│   ├── Use intention-revealing names
│   ├── Avoid abbreviations (except well-known)
│   ├── Use pronounceable names
│   └── Use searchable names
│
├── FUNCTIONS
│   ├── Small (20 lines max)
│   ├── Do one thing
│   ├── One level of abstraction
│   ├── Max 3 parameters
│   └── No side effects
│
├── COMMENTS
│   ├── Code should be self-documenting
│   ├── Comments explain WHY, not WHAT
│   ├── Avoid redundant comments
│   └── TODO/FIXME with tickets
│
├── FORMATTING
│   ├── Consistent indentation
│   ├── Logical grouping
│   ├── Vertical openness between concepts
│   └── Horizontal alignment
│
└── ERROR HANDLING
    ├── Use exceptions, not error codes
    ├── Don't return null
    ├── Don't pass null
    └── Fail fast
```

### Step 2: Apply SOLID Principles

```
SOLID PRINCIPLES
┌─────────────────────────────────────────────────────────────────┐
│                                                                 │
│  S - Single Responsibility                                      │
│      A class should have only one reason to change              │
│      ✅ UserValidator, UserRepository, UserController           │
│      ❌ UserManager (does everything)                           │
│                                                                 │
│  O - Open/Closed                                                │
│      Open for extension, closed for modification                │
│      ✅ Strategy pattern, plugins                               │
│      ❌ Switch statements for types                             │
│                                                                 │
│  L - Liskov Substitution                                        │
│      Subtypes must be substitutable for base types             │
│      ✅ Square is NOT a Rectangle in OOP                       │
│      ❌ Override methods with different behavior                │
│                                                                 │
│  I - Interface Segregation                                      │
│      Many specific interfaces > one general interface           │
│      ✅ Readable, Writable, Closeable                          │
│      ❌ God interface with 50 methods                          │
│                                                                 │
│  D - Dependency Inversion                                       │
│      Depend on abstractions, not concretions                   │
│      ✅ Inject interfaces, not implementations                 │
│      ❌ new ConcreteClass() inside methods                     │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### Step 3: Use Design Patterns

```
COMMON DESIGN PATTERNS
├── CREATIONAL
│   ├── Factory Method    - Create objects without specifying class
│   ├── Builder           - Complex object construction
│   ├── Singleton         - Single instance (use sparingly!)
│   └── Dependency Injection - Invert control
│
├── STRUCTURAL
│   ├── Adapter           - Convert interface to another
│   ├── Decorator         - Add behavior dynamically
│   ├── Facade            - Simplify complex subsystem
│   └── Repository        - Abstract data access
│
├── BEHAVIORAL
│   ├── Strategy          - Interchangeable algorithms
│   ├── Observer          - Event notification
│   ├── Command           - Encapsulate actions
│   └── State             - State-dependent behavior
│
└── CONCURRENCY
    ├── Thread Pool       - Reuse threads
    ├── Producer-Consumer - Queue-based processing
    └── Circuit Breaker   - Fault tolerance
```

### Step 4: Implement Testing Strategy

```
TESTING PYRAMID
                    ┌─────┐
                    │ E2E │  Few, slow, expensive
                   ─┴─────┴─
                  ┌─────────┐
                  │Integration│  Medium number
                 ─┴─────────┴─
                ┌─────────────┐
                │    Unit     │  Many, fast, cheap
                └─────────────┘

TEST TYPES
├── UNIT TESTS
│   ├── Test single function/method
│   ├── Mock dependencies
│   ├── Fast (< 1ms each)
│   └── Coverage target: 80%+
│
├── INTEGRATION TESTS
│   ├── Test component interactions
│   ├── Real dependencies (DB, API)
│   ├── Slower (100ms - 1s)
│   └── Focus on boundaries
│
└── E2E TESTS
    ├── Test complete user flows
    ├── Browser automation
    ├── Slowest (seconds - minutes)
    └── Critical paths only
```

### Step 5: Debug Effectively

```
DEBUGGING PROCESS
┌─────────────────────────────────────────────────────────────────┐
│                                                                 │
│  1. REPRODUCE           Consistently recreate the bug          │
│     ├── Get exact steps                                        │
│     ├── Note environment                                       │
│     └── Capture logs/errors                                    │
│                                                                 │
│  2. ISOLATE             Narrow down the cause                  │
│     ├── Binary search (divide and conquer)                     │
│     ├── Remove components                                      │
│     └── Simplify input                                         │
│                                                                 │
│  3. UNDERSTAND          Grasp root cause                       │
│     ├── Read the code                                          │
│     ├── Check assumptions                                      │
│     └── Add logging                                            │
│                                                                 │
│  4. FIX                 Apply correct solution                 │
│     ├── Fix root cause, not symptoms                           │
│     ├── Write test first                                       │
│     └── Consider side effects                                  │
│                                                                 │
│  5. VERIFY              Confirm fix works                      │
│     ├── Run reproduction steps                                 │
│     ├── Run test suite                                         │
│     └── Review in PR                                           │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

## Examples

### Example 1: Clean Code Refactoring

```python
# ❌ BAD: Hard to read, multiple responsibilities
def process(d):
    r = []
    for i in d:
        if i['s'] == 'A' and i['a'] >= 18:
            i['p'] = i['a'] * 100
            r.append(i)
    return r

# ✅ GOOD: Clear names, single responsibility
def calculate_eligible_users_premium(users: list[User]) -> list[User]:
    eligible_users = filter_active_adults(users)
    return [assign_premium(user) for user in eligible_users]

def filter_active_adults(users: list[User]) -> list[User]:
    return [
        user for user in users
        if user.is_active and user.age >= ADULT_AGE
    ]

def assign_premium(user: User) -> User:
    user.premium = user.age * PREMIUM_RATE
    return user
```

### Example 2: Strategy Pattern

```python
# Strategy Pattern: Interchangeable payment processors

from abc import ABC, abstractmethod

class PaymentStrategy(ABC):
    @abstractmethod
    def process_payment(self, amount: float) -> bool:
        pass

class CreditCardPayment(PaymentStrategy):
    def process_payment(self, amount: float) -> bool:
        # Credit card processing logic
        return self._charge_card(amount)

class PayPalPayment(PaymentStrategy):
    def process_payment(self, amount: float) -> bool:
        # PayPal processing logic
        return self._paypal_transfer(amount)

class PaymentProcessor:
    def __init__(self, strategy: PaymentStrategy):
        self._strategy = strategy

    def checkout(self, amount: float) -> bool:
        return self._strategy.process_payment(amount)

# Usage
processor = PaymentProcessor(CreditCardPayment())
processor.checkout(99.99)
```

### Example 3: Unit Test with Mocking

```python
import pytest
from unittest.mock import Mock, patch

class UserService:
    def __init__(self, repository, email_service):
        self.repository = repository
        self.email_service = email_service

    def register_user(self, email: str, password: str) -> User:
        if self.repository.exists(email):
            raise ValueError("Email already registered")
        
        user = User(email=email, password=hash_password(password))
        self.repository.save(user)
        self.email_service.send_welcome(email)
        return user

class TestUserService:
    def test_register_user_success(self):
        # Arrange
        mock_repo = Mock()
        mock_repo.exists.return_value = False
        mock_email = Mock()
        
        service = UserService(mock_repo, mock_email)
        
        # Act
        user = service.register_user("test@email.com", "password123")
        
        # Assert
        assert user.email == "test@email.com"
        mock_repo.save.assert_called_once()
        mock_email.send_welcome.assert_called_once_with("test@email.com")

    def test_register_duplicate_email_raises_error(self):
        # Arrange
        mock_repo = Mock()
        mock_repo.exists.return_value = True
        
        service = UserService(mock_repo, Mock())
        
        # Act & Assert
        with pytest.raises(ValueError, match="Email already registered"):
            service.register_user("existing@email.com", "password")
```

## Best Practices

### ✅ Do This

- ✅ Write tests before or alongside code (TDD)
- ✅ Keep functions small and focused
- ✅ Use meaningful variable and function names
- ✅ Handle errors explicitly
- ✅ Version control everything (including docs)
- ✅ Refactor continuously (Boy Scout Rule)
- ✅ Document architectural decisions (ADRs)
- ✅ Automate repetitive tasks

### ❌ Avoid This

- ❌ Don't copy-paste code (DRY)
- ❌ Don't write clever code, write clear code
- ❌ Don't ignore warnings and linter errors
- ❌ Don't commit broken code
- ❌ Don't skip code review
- ❌ Don't hardcode configuration values
- ❌ Don't catch generic exceptions silently

## Code Review Checklist

```markdown
## Code Review Checklist

### Correctness
- [ ] Logic is correct and handles edge cases
- [ ] No obvious bugs or errors
- [ ] Error handling is appropriate

### Code Quality
- [ ] Follows project style guide
- [ ] Names are clear and descriptive
- [ ] No code duplication
- [ ] Functions are small and focused

### Testing
- [ ] Tests cover new functionality
- [ ] Tests cover edge cases
- [ ] Tests are readable and maintainable

### Security
- [ ] No sensitive data exposure
- [ ] Input validation present
- [ ] No SQL injection or XSS vulnerabilities

### Performance
- [ ] No obvious performance issues
- [ ] Database queries are optimized
- [ ] No unnecessary loops or iterations
```

## Common Pitfalls

**Problem:** Over-engineering simple solutions
**Solution:** YAGNI—You Aren't Gonna Need It. Start simple, refactor when needed.

**Problem:** Tests are brittle and break often
**Solution:** Test behavior, not implementation. Use meaningful assertions.

**Problem:** Code works but is unreadable
**Solution:** Optimize for readability. You'll read it 10x more than write it.

**Problem:** Debugging takes too long
**Solution:** Use systematic approach. Add strategic logging. Use debugger effectively.

## Related Skills

- `@senior-software-architect` - For architectural decisions
- `@senior-backend-developer` - For backend-specific patterns
- `@senior-programming-mentor` - For language-specific guidance

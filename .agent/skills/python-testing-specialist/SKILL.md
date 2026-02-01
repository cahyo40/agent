---
name: python-testing-specialist
description: "Expert Python testing including pytest, unit testing, mocking, fixtures, integration testing, and test-driven development"
---

# Python Testing Specialist

## Overview

Master Python testing with pytest, unit testing, mocking, fixtures, and TDD practices for reliable, maintainable code.

## When to Use This Skill

- Use when writing Python tests
- Use when setting up pytest
- Use when mocking dependencies
- Use when implementing TDD

## How It Works

### Step 1: Pytest Basics

```python
# tests/test_calculator.py
import pytest
from calculator import add, divide

def test_add_positive_numbers():
    assert add(2, 3) == 5

def test_add_negative_numbers():
    assert add(-1, -1) == -2

def test_divide_by_zero():
    with pytest.raises(ValueError, match="Cannot divide by zero"):
        divide(10, 0)

@pytest.mark.parametrize("a,b,expected", [
    (10, 2, 5),
    (100, 10, 10),
    (6, 3, 2),
])
def test_divide_parametrized(a, b, expected):
    assert divide(a, b) == expected
```

### Step 2: Fixtures

```python
# conftest.py
import pytest
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker

@pytest.fixture(scope="session")
def db_engine():
    engine = create_engine("sqlite:///:memory:")
    Base.metadata.create_all(engine)
    yield engine
    engine.dispose()

@pytest.fixture
def db_session(db_engine):
    Session = sessionmaker(bind=db_engine)
    session = Session()
    yield session
    session.rollback()
    session.close()

@pytest.fixture
def sample_user(db_session):
    user = User(name="Test User", email="test@example.com")
    db_session.add(user)
    db_session.commit()
    return user
```

### Step 3: Mocking

```python
from unittest.mock import Mock, patch, MagicMock
import pytest

# Mock external API
@patch('services.api_client.requests.get')
def test_fetch_user(mock_get):
    mock_get.return_value.json.return_value = {"id": 1, "name": "John"}
    mock_get.return_value.status_code = 200
    
    result = fetch_user(1)
    
    assert result["name"] == "John"
    mock_get.assert_called_once_with("https://api.example.com/users/1")

# Mock database
def test_create_user(db_session):
    with patch.object(EmailService, 'send_welcome_email') as mock_email:
        user = create_user("test@example.com", "Test")
        
        assert user.id is not None
        mock_email.assert_called_once_with("test@example.com")

# AsyncMock for async code
@pytest.mark.asyncio
async def test_async_function():
    with patch('module.async_fetch', new_callable=AsyncMock) as mock:
        mock.return_value = {"data": "value"}
        result = await some_async_function()
        assert result == {"data": "value"}
```

### Step 4: Pytest Config

```ini
# pytest.ini
[pytest]
testpaths = tests
python_files = test_*.py
python_classes = Test*
python_functions = test_*
addopts = -v --cov=app --cov-report=html --cov-report=term-missing
markers =
    slow: marks tests as slow
    integration: marks tests as integration tests
filterwarnings =
    ignore::DeprecationWarning
```

```python
# Run specific tests
# pytest -k "test_user"
# pytest -m "not slow"
# pytest --lf  # last failed
# pytest -x    # stop on first failure
```

## Best Practices

### ✅ Do This

- ✅ Use fixtures for setup
- ✅ Isolate unit tests
- ✅ Use parametrize for variants
- ✅ Mock external dependencies
- ✅ Aim for high coverage

### ❌ Avoid This

- ❌ Don't test implementation details
- ❌ Don't share state between tests
- ❌ Don't mock everything
- ❌ Don't skip edge cases

## Related Skills

- `@senior-python-developer` - Python fundamentals
- `@tdd-workflow` - TDD practices

---
name: python-flask-developer
description: "Expert Flask development including blueprints, SQLAlchemy integration, authentication, REST APIs, and production deployment"
---

# Python Flask Developer

## Overview

Build web applications and APIs with Flask including blueprints, SQLAlchemy ORM, authentication, and production-ready configurations.

## When to Use This Skill

- Use when building Flask applications
- Use when need lightweight Python framework
- Use when building REST APIs with Flask
- Use when integrating with SQLAlchemy

## How It Works

### Step 1: Project Structure

```
flask-project/
├── app/
│   ├── __init__.py
│   ├── config.py
│   ├── models/
│   │   ├── __init__.py
│   │   └── user.py
│   ├── routes/
│   │   ├── __init__.py
│   │   ├── auth.py
│   │   └── users.py
│   ├── services/
│   └── templates/
├── migrations/
├── tests/
├── requirements.txt
└── run.py
```

### Step 2: Application Factory

```python
# app/__init__.py
from flask import Flask
from flask_sqlalchemy import SQLAlchemy
from flask_migrate import Migrate
from flask_jwt_extended import JWTManager
from app.config import Config

db = SQLAlchemy()
migrate = Migrate()
jwt = JWTManager()

def create_app(config_class=Config):
    app = Flask(__name__)
    app.config.from_object(config_class)
    
    # Initialize extensions
    db.init_app(app)
    migrate.init_app(app, db)
    jwt.init_app(app)
    
    # Register blueprints
    from app.routes.auth import auth_bp
    from app.routes.users import users_bp
    
    app.register_blueprint(auth_bp, url_prefix='/api/auth')
    app.register_blueprint(users_bp, url_prefix='/api/users')
    
    # Error handlers
    @app.errorhandler(404)
    def not_found(error):
        return {'error': 'Not found'}, 404
    
    @app.errorhandler(500)
    def internal_error(error):
        db.session.rollback()
        return {'error': 'Internal server error'}, 500
    
    return app
```

### Step 3: Models with SQLAlchemy

```python
# app/models/user.py
from app import db
from datetime import datetime
from werkzeug.security import generate_password_hash, check_password_hash

class User(db.Model):
    __tablename__ = 'users'
    
    id = db.Column(db.Integer, primary_key=True)
    email = db.Column(db.String(120), unique=True, nullable=False, index=True)
    name = db.Column(db.String(80), nullable=False)
    password_hash = db.Column(db.String(256), nullable=False)
    is_active = db.Column(db.Boolean, default=True)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    
    def set_password(self, password):
        self.password_hash = generate_password_hash(password)
    
    def check_password(self, password):
        return check_password_hash(self.password_hash, password)
    
    def to_dict(self):
        return {
            'id': self.id,
            'email': self.email,
            'name': self.name,
            'is_active': self.is_active,
            'created_at': self.created_at.isoformat()
        }
```

### Step 4: Blueprint Routes

```python
# app/routes/users.py
from flask import Blueprint, request, jsonify
from flask_jwt_extended import jwt_required, get_jwt_identity
from app import db
from app.models.user import User
from marshmallow import Schema, fields, validate, ValidationError

users_bp = Blueprint('users', __name__)

class UserSchema(Schema):
    name = fields.Str(required=True, validate=validate.Length(min=2, max=80))
    email = fields.Email(required=True)

@users_bp.route('/', methods=['GET'])
@jwt_required()
def get_users():
    page = request.args.get('page', 1, type=int)
    per_page = request.args.get('per_page', 10, type=int)
    
    pagination = User.query.paginate(page=page, per_page=per_page)
    
    return jsonify({
        'users': [u.to_dict() for u in pagination.items],
        'total': pagination.total,
        'page': page,
        'pages': pagination.pages
    })

@users_bp.route('/<int:user_id>', methods=['GET'])
@jwt_required()
def get_user(user_id):
    user = User.query.get_or_404(user_id)
    return jsonify(user.to_dict())

@users_bp.route('/', methods=['POST'])
def create_user():
    try:
        data = UserSchema().load(request.json)
    except ValidationError as err:
        return jsonify({'errors': err.messages}), 400
    
    user = User(name=data['name'], email=data['email'])
    user.set_password(request.json.get('password', 'default'))
    
    db.session.add(user)
    db.session.commit()
    
    return jsonify(user.to_dict()), 201
```

## Best Practices

### ✅ Do This

- ✅ Use application factory pattern
- ✅ Use blueprints for organization
- ✅ Use Flask-Migrate for migrations
- ✅ Validate with Marshmallow
- ✅ Use environment configs

### ❌ Avoid This

- ❌ Don't use global app instance
- ❌ Don't skip input validation
- ❌ Don't commit in routes directly
- ❌ Don't hardcode secrets

## Related Skills

- `@senior-python-developer` - Python fundamentals
- `@senior-django-developer` - Django alternative

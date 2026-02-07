---
description: Initialize Vibe Coding context files for NestJS backend API
---

# /vibe-coding-nestjs

Workflow untuk setup dokumen konteks Vibe Coding khusus **NestJS Backend API** dengan TypeScript dan modular architecture.

---

## 📋 Prerequisites

1. **Deskripsi API yang ingin dibuat**
2. **Database: PostgreSQL / MySQL / MongoDB?**
3. **ORM: Prisma / TypeORM / Mongoose?**
4. **API style: REST / GraphQL?**

---

## 🏗️ Phase 1: Holy Trinity

### Step 1.1: Generate PRD.md

Skill: `senior-project-manager`

```markdown
Buatkan PRD.md untuk NestJS backend: [IDE]
- Service description, Problem solved
- API consumers (mobile, web, microservices)
- Endpoints/Resolvers required
- Authentication requirements
- Success Metrics
```

// turbo
**Simpan ke `PRD.md`**

---

### Step 1.2: Generate TECH_STACK.md

Skill: `tech-stack-architect` + `senior-nodejs-developer`

```markdown
## Core Stack
- Node.js: 20 LTS
- Framework: NestJS 10+
- Language: TypeScript strict
- Runtime: Node.js / Bun (optional)

## Database & ORM
- Database: PostgreSQL
- ORM: Prisma / TypeORM
- Migrations: Prisma Migrate / TypeORM

## Authentication
- Strategy: Passport.js
- JWT: @nestjs/jwt
- Guards: Custom AuthGuard

## Validation
- Class Validator + Class Transformer
- DTOs untuk semua request

## API Documentation
- REST: @nestjs/swagger
- GraphQL: Apollo built-in playground

## Caching
- Redis: @nestjs/cache-manager + cache-manager-redis-yet

## Queue (optional)
- Bull: @nestjs/bull

## Testing
- Jest (built-in)
- Supertest untuk E2E

## Approved Packages
```json
{
  "dependencies": {
    "@nestjs/common": "^10.3.0",
    "@nestjs/core": "^10.3.0",
    "@nestjs/platform-express": "^10.3.0",
    "@nestjs/config": "^3.1.0",
    "@nestjs/jwt": "^10.2.0",
    "@nestjs/passport": "^10.0.0",
    "@nestjs/swagger": "^7.2.0",
    "@prisma/client": "^5.8.0",
    "passport": "^0.7.0",
    "passport-jwt": "^4.0.1",
    "class-validator": "^0.14.0",
    "class-transformer": "^0.5.1",
    "bcrypt": "^5.1.0"
  },
  "devDependencies": {
    "@nestjs/cli": "^10.3.0",
    "@nestjs/testing": "^10.3.0",
    "prisma": "^5.8.0",
    "@types/node": "^20.11.0",
    "typescript": "^5.3.0",
    "jest": "^29.7.0",
    "@types/jest": "^29.5.0"
  }
}
```

## Constraints

- Package di luar daftar DILARANG tanpa approval
- WAJIB TypeScript strict mode
- WAJIB menggunakan Dependency Injection

```

// turbo
**Simpan ke `TECH_STACK.md`**

---

### Step 1.3: Generate RULES.md

Skill: `senior-nodejs-developer`

```markdown
## NestJS Code Style
- WAJIB gunakan Decorators
- WAJIB Dependency Injection via constructor
- DTOs untuk semua request/response
- Entities/Models terpisah dari DTOs

## Module Structure
- Setiap fitur adalah Module
- Providers: Services
- Controllers: HTTP handlers
- Module harus self-contained

## TypeScript Rules
- Strict mode WAJIB
- DILARANG `any`, gunakan proper types
- Interfaces untuk contracts
- Classes untuk implementations

## Naming Convention
- Files: `kebab-case.type.ts` (user.service.ts, user.controller.ts)
- Classes: PascalCase
- Methods: camelCase
- Constants: SCREAMING_SNAKE_CASE

## DTO Rules
- Setiap endpoint punya Request DTO
- Class-validator decorators WAJIB
- Transform dengan class-transformer

## Error Handling
- HttpException untuk HTTP errors
- Custom exceptions extend HttpException
- Exception filters untuk global handling

## Database Rules
- Repository pattern
- Transactions untuk multi-operations
- JANGAN raw queries kecuali perlu

## AI Behavior Rules
1. JANGAN import package tidak ada di package.json
2. JANGAN skip validation decorators
3. SELALU gunakan DTOs
4. SELALU handle errors dengan proper exceptions
5. Refer ke DB_SCHEMA.md untuk models
6. Refer ke API_CONTRACT.md untuk controllers
```

// turbo
**Simpan ke `RULES.md`**

---

## 🎨 Phase 2: Support System

### Step 2.1: FOLDER_STRUCTURE.md

```markdown
## NestJS Project Structure

```

src/
├── main.ts                      # Bootstrap
├── app.module.ts                # Root module
│
├── common/                      # Shared code
│   ├── decorators/              # Custom decorators
│   ├── filters/                 # Exception filters
│   ├── guards/                  # Auth guards
│   ├── interceptors/            # Logging, transform
│   ├── pipes/                   # Validation pipes
│   └── dto/                     # Shared DTOs
│
├── config/                      # Configuration
│   ├── config.module.ts
│   └── configuration.ts
│
├── database/                    # Database setup
│   ├── database.module.ts
│   └── prisma.service.ts        # Jika Prisma
│
├── auth/                        # Auth module
│   ├── auth.module.ts
│   ├── auth.controller.ts
│   ├── auth.service.ts
│   ├── strategies/
│   │   └── jwt.strategy.ts
│   ├── guards/
│   │   └── jwt-auth.guard.ts
│   └── dto/
│       ├── login.dto.ts
│       └── register.dto.ts
│
├── users/                       # Users module
│   ├── users.module.ts
│   ├── users.controller.ts
│   ├── users.service.ts
│   ├── entities/
│   │   └── user.entity.ts
│   └── dto/
│       ├── create-user.dto.ts
│       └── update-user.dto.ts
│
└── [other-modules]/

prisma/                          # Prisma (jika digunakan)
├── schema.prisma
└── migrations/

test/
├── app.e2e-spec.ts
└── jest-e2e.json

```

## File Naming
- Modules: `feature.module.ts`
- Controllers: `feature.controller.ts`
- Services: `feature.service.ts`
- Entities: `feature.entity.ts`
- DTOs: `action-feature.dto.ts` (create-user.dto.ts)
```

// turbo
**Simpan ke `FOLDER_STRUCTURE.md`**

---

### Step 2.2: EXAMPLES.md

```markdown
## 1. Entity (Prisma)
```prisma
// prisma/schema.prisma
model User {
  id        String   @id @default(uuid())
  email     String   @unique
  password  String
  name      String
  isActive  Boolean  @default(true)
  createdAt DateTime @default(now())
  updatedAt DateTime @updatedAt
}
```

## 2. DTO Pattern

```typescript
// users/dto/create-user.dto.ts
import { IsEmail, IsString, MinLength } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class CreateUserDto {
  @ApiProperty({ example: 'user@example.com' })
  @IsEmail()
  email: string;

  @ApiProperty({ minLength: 8 })
  @IsString()
  @MinLength(8)
  password: string;

  @ApiProperty({ example: 'John Doe' })
  @IsString()
  name: string;
}
```

## 3. Service Pattern

```typescript
// users/users.service.ts
@Injectable()
export class UsersService {
  constructor(private prisma: PrismaService) {}

  async create(dto: CreateUserDto): Promise<User> {
    const hashedPassword = await bcrypt.hash(dto.password, 10);
    return this.prisma.user.create({
      data: {
        ...dto,
        password: hashedPassword,
      },
    });
  }

  async findByEmail(email: string): Promise<User | null> {
    return this.prisma.user.findUnique({ where: { email } });
  }

  async findById(id: string): Promise<User> {
    const user = await this.prisma.user.findUnique({ where: { id } });
    if (!user) {
      throw new NotFoundException(`User #${id} not found`);
    }
    return user;
  }
}
```

## 4. Controller Pattern

```typescript
// users/users.controller.ts
@ApiTags('users')
@Controller('users')
@UseGuards(JwtAuthGuard)
export class UsersController {
  constructor(private readonly usersService: UsersService) {}

  @Post()
  @ApiOperation({ summary: 'Create user' })
  @ApiResponse({ status: 201, type: UserResponseDto })
  async create(@Body() dto: CreateUserDto): Promise<UserResponseDto> {
    const user = await this.usersService.create(dto);
    return plainToInstance(UserResponseDto, user);
  }

  @Get(':id')
  @ApiOperation({ summary: 'Get user by ID' })
  async findOne(@Param('id', ParseUUIDPipe) id: string): Promise<UserResponseDto> {
    const user = await this.usersService.findById(id);
    return plainToInstance(UserResponseDto, user);
  }
}
```

## 5. Module Pattern

```typescript
// users/users.module.ts
@Module({
  imports: [DatabaseModule],
  controllers: [UsersController],
  providers: [UsersService],
  exports: [UsersService],
})
export class UsersModule {}
```

## 6. Guard Pattern

```typescript
// auth/guards/jwt-auth.guard.ts
@Injectable()
export class JwtAuthGuard extends AuthGuard('jwt') {
  handleRequest(err: any, user: any) {
    if (err || !user) {
      throw err || new UnauthorizedException();
    }
    return user;
  }
}
```

```

// turbo
**Simpan ke `EXAMPLES.md`**

---

## ✅ Phase 3: Project Setup

// turbo
```bash
npx @nestjs/cli new . --package-manager npm --strict
npm install @nestjs/config @nestjs/jwt @nestjs/passport passport passport-jwt
npm install class-validator class-transformer bcrypt
npm install @prisma/client && npm install -D prisma
npx prisma init
```

---

## 📁 Checklist

```
PRD.md, TECH_STACK.md, RULES.md, DB_SCHEMA.md,
FOLDER_STRUCTURE.md, API_CONTRACT.md, EXAMPLES.md
```
